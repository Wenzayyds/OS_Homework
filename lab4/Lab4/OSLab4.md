# Lab4
## 实验目的
* 了解内核线程创建/执行的管理过程
* 了解内核线程的切换和基本调度过程

## 练习1：分配并初始化一个进程控制块（需要编码）
alloc_proc的执行过程为：在堆上分配一块内存空间用来存放进程控制块；
初始化进程控制块内的各个参数；返回分配的进程控制块。  

其中需要初始化的成员变量有：  
* proc->state：由于还没有加载到内存中，所以给进程设置为未初始化状态PROC_UNINIT
* proc->pid：未初始化的进程，因此pid先赋为-1，表示尚未初始化
* proc->runs：刚初始化的进程，运行次数为0
* proc->kstack：既没有开始执行也没有重定位，因此默认分配的内核栈地址为0
* proc->need_resched：目前不需要调度，因此赋值为0
* proc->parent：还没有运行因此父进程为0
* proc->mm：进程用户态空间还没有进行分配使用，因此虚拟内存为空
* proc->context：上下文初始化为0
* proc->tf：中断帧指针初始化为空
* proc->cr3：os启动后，已经对整个核心空间进行了管理，所以内核中的所有线程都不需再建立各自的页表，只需共享这个核心虚拟空间，因此设置页目录为内核页目录的基址(boot_cr3)
* proc->flags：标志位是0
* proc->name：进程名为0
##### 代码如下：
```c++
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    proc->state = PROC_UNINIT;
    proc->pid = -1;
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context),0,sizeof(struct context));
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
    proc->flags = 0;
    memset(proc->name,0,PROC_NAME_LEN);
    }
    return proc;
}
```
##### 问题：proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用？  
1. struct context context：进程的上下文，用于switch_to中实现进程的切换。主要保存了前一个进程的现场（各个寄存器的状态）。在uCore中，所有的进程在内核中也是相对独立的。使用context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。  
2. struct trapframe *tf中断帧的指针，总是指向内核栈的某个位置。当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链。

## 练习2：为新创建的内核线程分配资源（需要编码）
创建内核线程时，新线程相当于是当前线程fork出的一个子线程。调用kernel_thread函数创建线程时，需要指定线程的执行入口、入口函数的参数、是否需要采取写时复制的机制进行fork时父子进程的内存映射。  
do_fork函数的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。它的大致执行步骤包括：  
1. 调用alloc_proc，获得一块用户信息块。
2. 调用setup_kstack为进程分配一个内核栈。
3. copy_mm复制原进程的内存管理信息到新进程。
4. copy_thread复制原进程上下文到新进程。
5. 将新进程添加到进程列表
6. 唤醒新进程
7. 返回新进程号
##### 代码如下：
```c++
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //分配一个未初始化的线程控制块PCB
    if((proc = alloc_proc()) == NULL){
        goto fork_out;
    }
    proc->parent = current;
    if(setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }
    if(copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }
    //调用copy_thread()函数复制父进程的中断帧和上下文信息。
    copy_thread(proc,stack,tf);
    //禁用中断
    bool intr_flag;
    local_intr_save(intr_flag);
    
    proc->pid = get_pid();
    //将新进程加入进程列表中
    hash_proc(proc);
    list_add(&proc_list,&(proc->list_link));
    nr_process ++;
    
    local_intr_restore(intr_flag);
    //唤醒进程 RUNNABLE
    wakeup_proc(proc);
    //返回pid
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

```

##### 问题：请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。  
查看get_pid函数。
```c++
if (proc->pid == last_pid) {
    if (++ last_pid >= next_safe) {
        if (last_pid >= MAX_PID) {
            last_pid = 1;
        }
        next_safe = MAX_PID;
        goto repeat;
    }
}
else if (proc->pid > last_pid && next_safe > proc->pid) {
    next_safe = proc->pid;
}
```
这段代码设置了几个条件，首先判断当前取出的进程的PID是否等于last_pid，如果是，则表示该PID已经被使用；如果当前的last_pid已经大于等于next_safe，则需要重新分配PID。如果last_pid已经达到最大值，那么将其重置为1，并跳转到repeat处重新查找可用的PID；如果当前进程的PID大于last_pid，并且小于next_safe，那么更新next_safe为该进程的PID。  
所以可以确保给每个新fork的线程一个唯一的id。
## 练习3：编写proc_run 函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

1. 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换，最后设置中断使能；不相同则继续执行以下步骤。
2. 禁用中断。使用local_intr_save()关闭中断使能。
3. 切换当前进程为要运行的进程。使current指针指向当前进程proc。
4. 切换页表，以便使用新进程的地址空间。修改cr3寄存器内容为要运行进程的页目录表
5. 实现上下文切换。使用switch_to函数保存原线程的寄存器并恢复待调度线程的寄存器
6. 允许中断。local_intr_restore()

##### 代码如下：
```c++
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
    // LAB4:EXERCISE3 YOUR CODE
    bool intr_flag;
    struct proc_struct *prev = current, *next = proc;
    // 关闭中断,进行进程切换
    local_intr_save(intr_flag);
    {
        //当前进程设为待调度的进程
        current = proc;
        //load_esp0(next->kstack + KSTACKSIZE);
        //将当前的cr3寄存器改为需要运行进程的页目录表
        lcr3(next->cr3);
        //进行上下文切换，保存原线程的寄存器并恢复待调度线程的寄存器
        switch_to(&(prev->context), &(next->context));
    }
    local_intr_restore(intr_flag);
    }
}
```

##### 问题：在本实验的执行过程中，创建且运行了几个内核线程？  
两个，分别为idleproc和initproc内核线程。  
idleproc为第0个内核线程，其作为空闲进程，主要目的是在系统没有其他任务需要执行时，占用 CPU 时间，同时便于进程调度的统一化。initproc作为第个内核线程，用于创建特定的其他内核线程或用户进程。
kern_init函数调用了proc_init函数，proc_init函数启动了创建内核线程的步骤，uCore通过给当前执行的上下文分配一个进程控制块以及对它进行相应初始化，便创建了idleproc。接下来调用kernel_thread函数，再通过函数内调用do_fork函数最终完成了内核线程的创建工作，创建了initproc。

## 扩展练习 Challenge：
说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？  
local_intr_save(intr_flag);用于屏蔽中断，local_intr_restore(intr_flag);用于打开中断。  
proc_run函数中这两句目的是保护进程切换不会被打断，以免进程切换时其他进程再进行调度。在do_fork函数中，添加进程到列表的时候也需要有这个操作，是因为进程进入列表的时候，可能会发生一系列的调度事件，比如我们所熟知的抢断等，加上这么一个保护机制可以确保进程执行不被打乱。

## 相关知识点
* 内核线程是一种特殊的进程，内核线程与用户进程的区别有两个：内核线程只运行在内核态，而用户进程会在在用户态和内核态交替运行；所有内核线程共用ucore内核内存空间，不需为每个内核线程维护单独的内存空间，而用户进程需要维护各自的用户内存空间。  
* 进程与程序的区别
  * 程序是静态的实体，进程是动态的实体。
  * 程序是存储在某种介质上的二进制代码，进程对应了程序的执行过程，系统不需要为一个不执行的程序创建进程，一旦进程被创建，就处于不断变化的动态过程中，对应了一个不断变化的上下文环境。
  * 程序是永久的，进程是暂时存在的。程序的永久性是相对于进程而言的，只要不去删除它，它可以永久的存储在介质当中。
* 进程与程序的联系  
  * 进程是程序的一次执行，进程和程序并不是一一对应的。同一个程序可以在不同的数据集合上运行，因而构成若干个不同的进程。几个进程能并发地执行相同的程序代码，而同一个进程能顺序地执行几个程序。
* 进程的状态
  * 创建状态：进程在创建时需要申请一个空白PCB，向其中填写控制和管理进程的信息，完成资源分配。如果创建工作无法完成，比如资源无法满足，就无法被调度运行，把此时进程所处状态称为创建状态
  * 就绪状态：进程已经准备好，已分配到所需资源，只要分配到CPU就能够立即运行
  * 执行状态：进程处于就绪状态被调度后，进程进入执行状态
  * 阻塞状态：正在执行的进程由于某些事件（I/O请求，申请缓存区失败）而暂时无法运行，进程受到阻塞。在满足请求时进入就绪状态等待系统调用
  * 终止状态：进程结束，或出现错误，或被系统终止，进入终止状态。无法再执行  

  本次实验中进程状态结构体中的状态有：PROC_UNINIT = 0，未初始化状态、PROC_SLEEPING，睡眠（阻塞）状态、PROC_RUNNABLE，运行与就绪态、PROC_ZOMBIE，僵死状态。  
* init_proc线程的整个生命周期  
  1. 通过kernel_thread函数，构造一个临时的trap_frame栈帧，其中设置了cs指向内核代码段选择子、ds/es/ss等指向内核的数据段选择子。令中断栈帧中的tf_regs.ebx、tf_regs.edx保存参数fn和arg，tf_eip指向kernel_thread_entry。
  2. 通过do_fork分配一个未初始化的线程控制块proc_struct，设置并初始化其一系列状态。将init_proc加入ucore的就绪队列，等待CPU调度。
  3. 通过copy_thread中设置用户态线程/内核态进程通用的中断栈帧数据，设置线程上下文struct context中eip、esp的值，令上下文切换switch返回后跳转到forkret处。
  4. idle_proc在cpu_idle中触发schedule，将init_proc线程从就绪队列中取出，执行switch_to进行idle_proc和init_proc的context线程上下文的切换。
  5. switch_to返回时，CPU开始执行init_proc的执行流，跳转至之前构造好的forkret处。
  6. fork_ret中，进行中断返回。将之前存放在内核栈中的中断栈帧中的数据依次弹出，最后跳转至kernel_thread_entry处。
  7. kernel_thread_entry中，利用之前在中断栈中设置好的ebx(fn)，edx(arg)执行真正的init_proc业务逻辑的处理(init_main函数)，在init_main返回后，跳转至do_exit终止退出。

* 一个进程可以对应一个线程，也可以对应很多线程。这些线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体（因为操作系统分配网络等资源时往往是基于进程的），这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能。
* 寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。因为线程切换在一个函数当中，所以编译器会自动帮助我们生成保存和恢复调用者保存寄存器的代码，在实际的进程切换过程中我们只需要保存被调用者保存寄存器。