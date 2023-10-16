# Lab2
## 实验目的
* 理解页表的建立和使用方法
* 理解物理内存的管理方法
* 理解页面分配算法
  
## 练习1：理解first-fit连续物理内存分配算法
first-fit算法是指从空闲物理页链表中的第一个开始查找，把最先能够满足大小要求的空闲分区分配给该程序。该算法可以减少查找的时间，分配和释放的时间性能较好，并且较大的空闲分区可以被保留在内存高端。
但缺点是随着低端分区不断划分而产生较多小分区，每次分配时查找时间开销会增大。
* ##### default_init()
  将空闲链表free_list初始化，空闲页数量nr_free初始化为0。
* ##### default_init_memmap(struct Page* base,size_t n)
  该函数的作用是初始化n个空闲页链表并按照地址升序将页面加入到空闲页链表free_list中去。
  base是第一个页，随后生成起始地址为base的n个连续页并遍历每个页进行初始化工作。空闲页数目nr_free设为n。
  如果此时的空闲页面链表为空，直接将当前页面添加进去；若不为空，则遍历链表，找到地址大小合适的位置插入当前页面，形成一个按地址顺序排序的链表。
* ##### default_alloc_pages(size_t n)
  n表示需要分配的页的大小，首先判断n是否大于当前空闲物理页数nr_free，若大于，则无法分配，直接返回NULL。
  若可以分配，遍历整个空闲页链表，找到第一个大小>=n的内存块，分配给其大小为n的内存，返回该内存块的地址，并将剩余的内存重新链入空闲链表。此时的nr_free要减去n。
* ##### default_free_pages(size_t n)
  首先要将这一段连续内存空间初始化，修改flags、ref为0。之后判断该内存空间是否和其他空闲内存空间相邻，如果是则合并，并将这块新的、更大的内存链入到空闲链表的合适位置。如果没有相邻的，则直接链入链表中。nr_free再加上n。
* ##### 你的first fit算法是否有进一步的改进空间？
  在分配和释放内存时，都需要遍历空闲链表找到合适的位置，所以可以使用二叉搜索树，对内存地址进行排序，提高查找效率。
## 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
仅对区别于first-fit算法部分进行说明，仅展示需要完成的代码部分。  

best-fit算法是指将分区按由小到大的顺序组织，找到的第一个适应分区是大小与要求相差最小的空闲分区。个别来看，外碎片较小，整体来看，会形成较多外碎片。但较大的空闲分区可以被保留。

* ##### default_init()
  与first-fit算法一样，将空闲链表free_list初始化，空闲页数量nr_free初始化为0。
* ##### default_init_memmap(struct Page* base,size_t n)
  该函数的作用是初始化n个空闲页链表并按照地址升序将页面加入到空闲页链表free_list中去。
  ```c
    for (; p != base + n; p ++) {
        assert(PageReserved(p));

        /*LAB2 EXERCISE 2: YOUR CODE*/ 
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
        p->flags = p->property = 0;
        set_page_ref(p,0);
    }
  ```
  ```c
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
             /*LAB2 EXERCISE 2: YOUR CODE*/ 
            // 编写代码
            // 1、当base < page时，找到第一个大于base的页，将base插入到它前面，并退出循环
            if(base < page){
            	list_add_before(le,&(base->page_link));
            	break;
            }
            // 2、当list_next(le) == &free_list时，若已经到达链表结尾，将base插入到链表尾部
            else if(list_next(le) == &free_list){
            	list_add(le,&(base->page_link));
            }
        }
    }
  ```
* ##### default_alloc_pages(size_t n)
  ```c
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
    /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) {
            page = p;
            min_size = p->property;//update min_size until find the best
        }
    }
  
  ```
  新声明了一个size_t类型的变量min_size，记录当前找到的最小连续空闲页数量。遍历空闲块链表时，如果当前块满足内存大小条件，并且空闲页数量小于min_size，更新它，从而可以找到与要求相差最小的空闲分区。
* ##### default_free_pages(size_t n)
  ```c
  /*LAB2 EXERCISE 2: YOUR CODE*/ 
  // 编写代码
  // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
  base->property = n;
  SetPageProperty(base);
  nr_free += n;
  ```

  ```c
  if (le != &free_list) {
        p = le2page(le, page_link);
        /*LAB2 EXERCISE 2: YOUR CODE*/ 
        // 编写代码
        // 1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        // 4、从链表中删除当前页块
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
        if(p+p->property == base){
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
  }
  ```
* ##### 你的 Best-Fit 算法是否有进一步的改进空间？
  在查找满足需求的空闲块时，需要遍历整个链表，导致时间复杂度较高。可以考虑使用平衡二叉树的数据结构，以提高查找效率。  
  此外，best-fit容易产生外部碎片，可以优化算法，综合考虑空闲块的大小以及分配后产生的碎片情况，从而选择更合适的空闲块进行分配。


## 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
* 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？
  
  由于在 Qemu 中，可以使用 -m 指定 RAM 的大小，默认是 128MiB。因此，默认的 DRAM 物理内存地址范围就是[0x80000000,0x88000000)。我们直接将 DRAM 物理内存结束地址硬编码到内核中。  
  当无法提前知道当前硬件的可用物理内存范围时，OpenSBI固件会完成对于包括物理内存在内的各外设的扫描，将扫描结果以 DTB(Device Tree Blob) 的格式保存在物理内存中的某个地方。随后 OpenSBI 会将其地址保存在 a1 寄存器中，供OS使用。  
  此外还可以设计算法，尝试访问特定的内存地址，并观察是否能够成功读写，探测可用的物理内存范围。
