
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00277617          	auipc	a2,0x277
ffffffffc0200042:	43a60613          	addi	a2,a2,1082 # ffffffffc0477478 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	7e6010ef          	jal	ra,ffffffffc0201834 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	7f250513          	addi	a0,a0,2034 # ffffffffc0201848 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	0a2010ef          	jal	ra,ffffffffc020110c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	27c010ef          	jal	ra,ffffffffc0201326 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	248010ef          	jal	ra,ffffffffc0201326 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	75850513          	addi	a0,a0,1880 # ffffffffc0201898 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	76250513          	addi	a0,a0,1890 # ffffffffc02018b8 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	6e458593          	addi	a1,a1,1764 # ffffffffc0201846 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	76e50513          	addi	a0,a0,1902 # ffffffffc02018d8 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	77a50513          	addi	a0,a0,1914 # ffffffffc02018f8 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00277597          	auipc	a1,0x277
ffffffffc020018e:	2ee58593          	addi	a1,a1,750 # ffffffffc0477478 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	78650513          	addi	a0,a0,1926 # ffffffffc0201918 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00277597          	auipc	a1,0x277
ffffffffc02001a2:	6d958593          	addi	a1,a1,1753 # ffffffffc0477877 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	77850513          	addi	a0,a0,1912 # ffffffffc0201938 <etext+0xf2>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	69860613          	addi	a2,a2,1688 # ffffffffc0201868 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	6a450513          	addi	a0,a0,1700 # ffffffffc0201880 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0201a48 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	87458593          	addi	a1,a1,-1932 # ffffffffc0201a68 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	87450513          	addi	a0,a0,-1932 # ffffffffc0201a70 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	87660613          	addi	a2,a2,-1930 # ffffffffc0201a80 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	89658593          	addi	a1,a1,-1898 # ffffffffc0201aa8 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	85650513          	addi	a0,a0,-1962 # ffffffffc0201a70 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	89260613          	addi	a2,a2,-1902 # ffffffffc0201ab8 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	8aa58593          	addi	a1,a1,-1878 # ffffffffc0201ad8 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201a70 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	74050513          	addi	a0,a0,1856 # ffffffffc02019b0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	74650513          	addi	a0,a0,1862 # ffffffffc02019d8 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	6c0c8c93          	addi	s9,s9,1728 # ffffffffc0201968 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	75098993          	addi	s3,s3,1872 # ffffffffc0201a00 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	75090913          	addi	s2,s2,1872 # ffffffffc0201a08 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	74eb0b13          	addi	s6,s6,1870 # ffffffffc0201a10 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	79ea8a93          	addi	s5,s5,1950 # ffffffffc0201a68 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	3dc010ef          	jal	ra,ffffffffc02016b2 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	52e010ef          	jal	ra,ffffffffc0201816 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	66ad0d13          	addi	s10,s10,1642 # ffffffffc0201968 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	4e0010ef          	jal	ra,ffffffffc02017ec <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	4cc010ef          	jal	ra,ffffffffc02017ec <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	490010ef          	jal	ra,ffffffffc0201816 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	69250513          	addi	a0,a0,1682 # ffffffffc0201a30 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	70a50513          	addi	a0,a0,1802 # ffffffffc0201ae8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	56c50513          	addi	a0,a0,1388 # ffffffffc0201960 <etext+0x11a>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	368010ef          	jal	ra,ffffffffc020178c <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	6d650513          	addi	a0,a0,1750 # ffffffffc0201b08 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3400106f          	j	ffffffffc020178c <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	31a0106f          	j	ffffffffc0201770 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	34e0106f          	j	ffffffffc02017a8 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	79c50513          	addi	a0,a0,1948 # ffffffffc0201c20 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	7a450513          	addi	a0,a0,1956 # ffffffffc0201c38 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201c50 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	7b850513          	addi	a0,a0,1976 # ffffffffc0201c68 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	7c250513          	addi	a0,a0,1986 # ffffffffc0201c80 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	7cc50513          	addi	a0,a0,1996 # ffffffffc0201c98 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	7d650513          	addi	a0,a0,2006 # ffffffffc0201cb0 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	7e050513          	addi	a0,a0,2016 # ffffffffc0201cc8 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	7ea50513          	addi	a0,a0,2026 # ffffffffc0201ce0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	7f450513          	addi	a0,a0,2036 # ffffffffc0201cf8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	7fe50513          	addi	a0,a0,2046 # ffffffffc0201d10 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	80850513          	addi	a0,a0,-2040 # ffffffffc0201d28 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	81250513          	addi	a0,a0,-2030 # ffffffffc0201d40 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	81c50513          	addi	a0,a0,-2020 # ffffffffc0201d58 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	82650513          	addi	a0,a0,-2010 # ffffffffc0201d70 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	83050513          	addi	a0,a0,-2000 # ffffffffc0201d88 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0201da0 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	84450513          	addi	a0,a0,-1980 # ffffffffc0201db8 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	84e50513          	addi	a0,a0,-1970 # ffffffffc0201dd0 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	85850513          	addi	a0,a0,-1960 # ffffffffc0201de8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	86250513          	addi	a0,a0,-1950 # ffffffffc0201e00 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201e18 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	87650513          	addi	a0,a0,-1930 # ffffffffc0201e30 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	88050513          	addi	a0,a0,-1920 # ffffffffc0201e48 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201e60 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	89450513          	addi	a0,a0,-1900 # ffffffffc0201e78 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0201e90 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	8a850513          	addi	a0,a0,-1880 # ffffffffc0201ea8 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201ec0 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0201ed8 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201ef0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201f08 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201f20 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201f38 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201f50 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201f68 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201f80 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	46870713          	addi	a4,a4,1128 # ffffffffc0201b24 <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201bb8 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	4be50513          	addi	a0,a0,1214 # ffffffffc0201b98 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	47250513          	addi	a0,a0,1138 # ffffffffc0201b58 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	4e650513          	addi	a0,a0,1254 # ffffffffc0201bd8 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	4d650513          	addi	a0,a0,1238 # ffffffffc0201c00 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	44250513          	addi	a0,a0,1090 # ffffffffc0201b78 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	4a450513          	addi	a0,a0,1188 # ffffffffc0201bf0 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
int nr_block;//已分配的块数

static void buddy_init()
{
    list_init(&free_list);
    nr_free=0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <buddy_free_pages>:
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200846:	00006897          	auipc	a7,0x6
ffffffffc020084a:	c0a88893          	addi	a7,a7,-1014 # ffffffffc0206450 <nr_block>
ffffffffc020084e:	0008a803          	lw	a6,0(a7)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200852:	00006e17          	auipc	t3,0x6
ffffffffc0200856:	be6e0e13          	addi	t3,t3,-1050 # ffffffffc0206438 <free_area>
ffffffffc020085a:	008e3683          	ld	a3,8(t3)
ffffffffc020085e:	19005863          	blez	a6,ffffffffc02009ee <buddy_free_pages+0x1a8>
    if(rec[i].base==base)
ffffffffc0200862:	000a2617          	auipc	a2,0xa2
ffffffffc0200866:	ff660613          	addi	a2,a2,-10 # ffffffffc02a2858 <rec>
ffffffffc020086a:	621c                	ld	a5,0(a2)
ffffffffc020086c:	18f50763          	beq	a0,a5,ffffffffc02009fa <buddy_free_pages+0x1b4>
ffffffffc0200870:	000a2717          	auipc	a4,0xa2
ffffffffc0200874:	00070713          	mv	a4,a4
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200878:	4781                	li	a5,0
ffffffffc020087a:	a031                	j	ffffffffc0200886 <buddy_free_pages+0x40>
    if(rec[i].base==base)
ffffffffc020087c:	0761                	addi	a4,a4,24
ffffffffc020087e:	fe873303          	ld	t1,-24(a4) # ffffffffc02a2858 <rec>
ffffffffc0200882:	16a30463          	beq	t1,a0,ffffffffc02009ea <buddy_free_pages+0x1a4>
  for(i=0;i<nr_block;i++)//找到块
ffffffffc0200886:	2785                	addiw	a5,a5,1
ffffffffc0200888:	ff079ae3          	bne	a5,a6,ffffffffc020087c <buddy_free_pages+0x36>
  int offset=rec[i].offset;
ffffffffc020088c:	00181513          	slli	a0,a6,0x1
ffffffffc0200890:	010507b3          	add	a5,a0,a6
ffffffffc0200894:	078e                	slli	a5,a5,0x3
ffffffffc0200896:	97b2                	add	a5,a5,a2
ffffffffc0200898:	479c                	lw	a5,8(a5)
  while(i<offset)
ffffffffc020089a:	00f05763          	blez	a5,ffffffffc02008a8 <buddy_free_pages+0x62>
  i=0;
ffffffffc020089e:	4701                	li	a4,0
    i++;
ffffffffc02008a0:	2705                	addiw	a4,a4,1
ffffffffc02008a2:	6694                	ld	a3,8(a3)
  while(i<offset)
ffffffffc02008a4:	fee79ee3          	bne	a5,a4,ffffffffc02008a0 <buddy_free_pages+0x5a>
  if(!IS_POWER_OF_2(n))
ffffffffc02008a8:	fff58713          	addi	a4,a1,-1
ffffffffc02008ac:	8f6d                	and	a4,a4,a1
     allocpages=n;
ffffffffc02008ae:	2581                	sext.w	a1,a1
  if(!IS_POWER_OF_2(n))
ffffffffc02008b0:	c70d                	beqz	a4,ffffffffc02008da <buddy_free_pages+0x94>
  size |= size >> 1;
ffffffffc02008b2:	0015d71b          	srliw	a4,a1,0x1
ffffffffc02008b6:	8dd9                	or	a1,a1,a4
ffffffffc02008b8:	2581                	sext.w	a1,a1
  size |= size >> 2;
ffffffffc02008ba:	0025d71b          	srliw	a4,a1,0x2
ffffffffc02008be:	8dd9                	or	a1,a1,a4
ffffffffc02008c0:	2581                	sext.w	a1,a1
  size |= size >> 4;
ffffffffc02008c2:	0045d71b          	srliw	a4,a1,0x4
ffffffffc02008c6:	8dd9                	or	a1,a1,a4
ffffffffc02008c8:	2581                	sext.w	a1,a1
  size |= size >> 8;
ffffffffc02008ca:	0085d71b          	srliw	a4,a1,0x8
ffffffffc02008ce:	8dd9                	or	a1,a1,a4
ffffffffc02008d0:	2581                	sext.w	a1,a1
  size |= size >> 16;
ffffffffc02008d2:	0105d71b          	srliw	a4,a1,0x10
ffffffffc02008d6:	8dd9                	or	a1,a1,a4
   allocpages=fixsize(n);
ffffffffc02008d8:	2585                	addiw	a1,a1,1
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc02008da:	1207c263          	bltz	a5,ffffffffc02009fe <buddy_free_pages+0x1b8>
ffffffffc02008de:	00006317          	auipc	t1,0x6
ffffffffc02008e2:	b7a30313          	addi	t1,t1,-1158 # ffffffffc0206458 <root>
ffffffffc02008e6:	00032703          	lw	a4,0(t1)
ffffffffc02008ea:	00078e9b          	sext.w	t4,a5
ffffffffc02008ee:	10eef863          	bleu	a4,t4,ffffffffc02009fe <buddy_free_pages+0x1b8>
  index = offset + self->size - 1;
ffffffffc02008f2:	fff7079b          	addiw	a5,a4,-1
ffffffffc02008f6:	01d787bb          	addw	a5,a5,t4
  self[index].longest = allocpages;
ffffffffc02008fa:	02079713          	slli	a4,a5,0x20
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc02008fe:	010e2e83          	lw	t4,16(t3)
  self[index].longest = allocpages;
ffffffffc0200902:	9301                	srli	a4,a4,0x20
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200904:	00058e1b          	sext.w	t3,a1
  self[index].longest = allocpages;
ffffffffc0200908:	070e                	slli	a4,a4,0x3
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc020090a:	01ce8ebb          	addw	t4,t4,t3
  self[index].longest = allocpages;
ffffffffc020090e:	971a                	add	a4,a4,t1
ffffffffc0200910:	01c72223          	sw	t3,4(a4)
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200914:	00006f17          	auipc	t5,0x6
ffffffffc0200918:	b3df2a23          	sw	t4,-1228(t5) # ffffffffc0206448 <free_area+0x10>
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc020091c:	4701                	li	a4,0
     p->property=1;
ffffffffc020091e:	4e85                	li	t4,1
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200920:	4e09                	li	t3,2
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200922:	00b05e63          	blez	a1,ffffffffc020093e <buddy_free_pages+0xf8>
     p->flags=0;
ffffffffc0200926:	fe06b823          	sd	zero,-16(a3)
     p->property=1;
ffffffffc020092a:	ffd6ac23          	sw	t4,-8(a3)
ffffffffc020092e:	ff068f13          	addi	t5,a3,-16
ffffffffc0200932:	41cf302f          	amoor.d	zero,t3,(t5)
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200936:	2705                	addiw	a4,a4,1
ffffffffc0200938:	6694                	ld	a3,8(a3)
ffffffffc020093a:	fee596e3          	bne	a1,a4,ffffffffc0200926 <buddy_free_pages+0xe0>
  node_size = 1;
ffffffffc020093e:	4e05                	li	t3,1
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc0200940:	c7b9                	beqz	a5,ffffffffc020098e <buddy_free_pages+0x148>
    index = PARENT(index);
ffffffffc0200942:	2785                	addiw	a5,a5,1
ffffffffc0200944:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200948:	35fd                	addiw	a1,a1,-1
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc020094a:	0015969b          	slliw	a3,a1,0x1
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc020094e:	ffe7f713          	andi	a4,a5,-2
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200952:	2685                	addiw	a3,a3,1
ffffffffc0200954:	1682                	slli	a3,a3,0x20
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200956:	1702                	slli	a4,a4,0x20
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200958:	9281                	srli	a3,a3,0x20
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc020095a:	9301                	srli	a4,a4,0x20
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc020095c:	068e                	slli	a3,a3,0x3
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc020095e:	070e                	slli	a4,a4,0x3
ffffffffc0200960:	971a                	add	a4,a4,t1
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200962:	969a                	add	a3,a3,t1
    right_longest = self[RIGHT_LEAF(index)].longest;
ffffffffc0200964:	00472e83          	lw	t4,4(a4)
    left_longest = self[LEFT_LEAF(index)].longest;
ffffffffc0200968:	42d4                	lw	a3,4(a3)
ffffffffc020096a:	02059713          	slli	a4,a1,0x20
ffffffffc020096e:	8375                	srli	a4,a4,0x1d
    node_size *= 2;
ffffffffc0200970:	001e1e1b          	slliw	t3,t3,0x1
    if (left_longest + right_longest == node_size) 
ffffffffc0200974:	01d68fbb          	addw	t6,a3,t4
    index = PARENT(index);
ffffffffc0200978:	0005879b          	sext.w	a5,a1
    if (left_longest + right_longest == node_size) 
ffffffffc020097c:	971a                	add	a4,a4,t1
ffffffffc020097e:	07cf8263          	beq	t6,t3,ffffffffc02009e2 <buddy_free_pages+0x19c>
      self[index].longest = MAX(left_longest, right_longest);
ffffffffc0200982:	85b6                	mv	a1,a3
ffffffffc0200984:	01d6f363          	bleu	t4,a3,ffffffffc020098a <buddy_free_pages+0x144>
ffffffffc0200988:	85f6                	mv	a1,t4
ffffffffc020098a:	c34c                	sw	a1,4(a4)
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc020098c:	fbdd                	bnez	a5,ffffffffc0200942 <buddy_free_pages+0xfc>
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
ffffffffc020098e:	0008a783          	lw	a5,0(a7)
ffffffffc0200992:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200996:	88ba                	mv	a7,a4
ffffffffc0200998:	04e85063          	ble	a4,a6,ffffffffc02009d8 <buddy_free_pages+0x192>
ffffffffc020099c:	ffe7859b          	addiw	a1,a5,-2
ffffffffc02009a0:	410585bb          	subw	a1,a1,a6
ffffffffc02009a4:	1582                	slli	a1,a1,0x20
ffffffffc02009a6:	9181                	srli	a1,a1,0x20
ffffffffc02009a8:	01058733          	add	a4,a1,a6
ffffffffc02009ac:	00171593          	slli	a1,a4,0x1
ffffffffc02009b0:	95ba                	add	a1,a1,a4
ffffffffc02009b2:	010507b3          	add	a5,a0,a6
ffffffffc02009b6:	078e                	slli	a5,a5,0x3
ffffffffc02009b8:	058e                	slli	a1,a1,0x3
ffffffffc02009ba:	000a2717          	auipc	a4,0xa2
ffffffffc02009be:	eb670713          	addi	a4,a4,-330 # ffffffffc02a2870 <rec+0x18>
ffffffffc02009c2:	97b2                	add	a5,a5,a2
ffffffffc02009c4:	95ba                	add	a1,a1,a4
    rec[i]=rec[i+1];
ffffffffc02009c6:	6f90                	ld	a2,24(a5)
ffffffffc02009c8:	7394                	ld	a3,32(a5)
ffffffffc02009ca:	7798                	ld	a4,40(a5)
ffffffffc02009cc:	e390                	sd	a2,0(a5)
ffffffffc02009ce:	e794                	sd	a3,8(a5)
ffffffffc02009d0:	eb98                	sd	a4,16(a5)
ffffffffc02009d2:	07e1                	addi	a5,a5,24
  for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
ffffffffc02009d4:	fef599e3          	bne	a1,a5,ffffffffc02009c6 <buddy_free_pages+0x180>
  nr_block--;//更新分配块数的值
ffffffffc02009d8:	00006797          	auipc	a5,0x6
ffffffffc02009dc:	a717ac23          	sw	a7,-1416(a5) # ffffffffc0206450 <nr_block>
ffffffffc02009e0:	8082                	ret
      self[index].longest = node_size;
ffffffffc02009e2:	01c72223          	sw	t3,4(a4)
  while (index) {//向上合并，修改先祖节点的记录值
ffffffffc02009e6:	ffb1                	bnez	a5,ffffffffc0200942 <buddy_free_pages+0xfc>
ffffffffc02009e8:	b75d                	j	ffffffffc020098e <buddy_free_pages+0x148>
  for(i=0;i<nr_block;i++)//找到块
ffffffffc02009ea:	883e                	mv	a6,a5
ffffffffc02009ec:	b545                	j	ffffffffc020088c <buddy_free_pages+0x46>
ffffffffc02009ee:	4801                	li	a6,0
ffffffffc02009f0:	000a2617          	auipc	a2,0xa2
ffffffffc02009f4:	e6860613          	addi	a2,a2,-408 # ffffffffc02a2858 <rec>
ffffffffc02009f8:	bd51                	j	ffffffffc020088c <buddy_free_pages+0x46>
ffffffffc02009fa:	4801                	li	a6,0
ffffffffc02009fc:	bd41                	j	ffffffffc020088c <buddy_free_pages+0x46>
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc02009fe:	1141                	addi	sp,sp,-16
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc0200a00:	00001697          	auipc	a3,0x1
ffffffffc0200a04:	6b068693          	addi	a3,a3,1712 # ffffffffc02020b0 <commands+0x748>
ffffffffc0200a08:	00001617          	auipc	a2,0x1
ffffffffc0200a0c:	6d860613          	addi	a2,a2,1752 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200a10:	0cc00593          	li	a1,204
ffffffffc0200a14:	00001517          	auipc	a0,0x1
ffffffffc0200a18:	6e450513          	addi	a0,a0,1764 # ffffffffc02020f8 <commands+0x790>
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc0200a1c:	e406                	sd	ra,8(sp)
  assert(self && offset >= 0 && offset < self->size);//是否合法
ffffffffc0200a1e:	98fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a22 <buddy_check>:

//以下是一个测试函数
static void

buddy_check(void) {
ffffffffc0200a22:	7179                	addi	sp,sp,-48
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a24:	4505                	li	a0,1
buddy_check(void) {
ffffffffc0200a26:	f406                	sd	ra,40(sp)
ffffffffc0200a28:	f022                	sd	s0,32(sp)
ffffffffc0200a2a:	ec26                	sd	s1,24(sp)
ffffffffc0200a2c:	e84a                	sd	s2,16(sp)
ffffffffc0200a2e:	e44e                	sd	s3,8(sp)
ffffffffc0200a30:	e052                	sd	s4,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a32:	650000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200a36:	28050863          	beqz	a0,ffffffffc0200cc6 <buddy_check+0x2a4>
ffffffffc0200a3a:	842a                	mv	s0,a0
    assert((A = alloc_page()) != NULL);
ffffffffc0200a3c:	4505                	li	a0,1
ffffffffc0200a3e:	644000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200a42:	84aa                	mv	s1,a0
ffffffffc0200a44:	26050163          	beqz	a0,ffffffffc0200ca6 <buddy_check+0x284>
    assert((B = alloc_page()) != NULL);
ffffffffc0200a48:	4505                	li	a0,1
ffffffffc0200a4a:	638000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200a4e:	892a                	mv	s2,a0
ffffffffc0200a50:	22050b63          	beqz	a0,ffffffffc0200c86 <buddy_check+0x264>

    assert(p0 != A && p0 != B && A != B);
ffffffffc0200a54:	18940963          	beq	s0,s1,ffffffffc0200be6 <buddy_check+0x1c4>
ffffffffc0200a58:	18a40763          	beq	s0,a0,ffffffffc0200be6 <buddy_check+0x1c4>
ffffffffc0200a5c:	18a48563          	beq	s1,a0,ffffffffc0200be6 <buddy_check+0x1c4>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200a60:	401c                	lw	a5,0(s0)
ffffffffc0200a62:	1a079263          	bnez	a5,ffffffffc0200c06 <buddy_check+0x1e4>
ffffffffc0200a66:	409c                	lw	a5,0(s1)
ffffffffc0200a68:	18079f63          	bnez	a5,ffffffffc0200c06 <buddy_check+0x1e4>
ffffffffc0200a6c:	411c                	lw	a5,0(a0)
ffffffffc0200a6e:	18079c63          	bnez	a5,ffffffffc0200c06 <buddy_check+0x1e4>
    free_page(p0);
ffffffffc0200a72:	8522                	mv	a0,s0
ffffffffc0200a74:	4585                	li	a1,1
ffffffffc0200a76:	650000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    free_page(A);
ffffffffc0200a7a:	8526                	mv	a0,s1
ffffffffc0200a7c:	4585                	li	a1,1
ffffffffc0200a7e:	648000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    free_page(B);
ffffffffc0200a82:	4585                	li	a1,1
ffffffffc0200a84:	854a                	mv	a0,s2
ffffffffc0200a86:	640000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    
    A=alloc_pages(500);
ffffffffc0200a8a:	1f400513          	li	a0,500
ffffffffc0200a8e:	5f4000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200a92:	842a                	mv	s0,a0
    B=alloc_pages(500);
ffffffffc0200a94:	1f400513          	li	a0,500
ffffffffc0200a98:	5ea000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200a9c:	84aa                	mv	s1,a0
    cprintf("A %p\n",A);
ffffffffc0200a9e:	85a2                	mv	a1,s0
ffffffffc0200aa0:	00001517          	auipc	a0,0x1
ffffffffc0200aa4:	5b850513          	addi	a0,a0,1464 # ffffffffc0202058 <commands+0x6f0>
ffffffffc0200aa8:	e0eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("B %p\n",B);
ffffffffc0200aac:	85a6                	mv	a1,s1
ffffffffc0200aae:	00001517          	auipc	a0,0x1
ffffffffc0200ab2:	5b250513          	addi	a0,a0,1458 # ffffffffc0202060 <commands+0x6f8>
ffffffffc0200ab6:	e00ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(A,250);
ffffffffc0200aba:	0fa00593          	li	a1,250
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	606000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    free_pages(B,500);
ffffffffc0200ac4:	1f400593          	li	a1,500
ffffffffc0200ac8:	8526                	mv	a0,s1
ffffffffc0200aca:	5fc000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    free_pages(A+250,250);
ffffffffc0200ace:	6509                	lui	a0,0x2
ffffffffc0200ad0:	71050513          	addi	a0,a0,1808 # 2710 <BASE_ADDRESS-0xffffffffc01fd8f0>
ffffffffc0200ad4:	0fa00593          	li	a1,250
ffffffffc0200ad8:	9522                	add	a0,a0,s0
ffffffffc0200ada:	5ec000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    
    p0=alloc_pages(1024);
ffffffffc0200ade:	40000513          	li	a0,1024
ffffffffc0200ae2:	5a0000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200ae6:	8a2a                	mv	s4,a0
    cprintf("p0 %p\n",p0);
ffffffffc0200ae8:	85aa                	mv	a1,a0
ffffffffc0200aea:	00001517          	auipc	a0,0x1
ffffffffc0200aee:	57e50513          	addi	a0,a0,1406 # ffffffffc0202068 <commands+0x700>
ffffffffc0200af2:	dc4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(p0 == A);
ffffffffc0200af6:	13441863          	bne	s0,s4,ffffffffc0200c26 <buddy_check+0x204>


    A=alloc_pages(70);  
ffffffffc0200afa:	04600513          	li	a0,70
ffffffffc0200afe:	584000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
ffffffffc0200b02:	892a                	mv	s2,a0
    B=alloc_pages(35);
ffffffffc0200b04:	02300513          	li	a0,35
ffffffffc0200b08:	57a000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
    assert(A+128==B);//检查是否相邻
ffffffffc0200b0c:	6405                	lui	s0,0x1
ffffffffc0200b0e:	40040793          	addi	a5,s0,1024 # 1400 <BASE_ADDRESS-0xffffffffc01fec00>
ffffffffc0200b12:	97ca                	add	a5,a5,s2
    B=alloc_pages(35);
ffffffffc0200b14:	84aa                	mv	s1,a0
    assert(A+128==B);//检查是否相邻
ffffffffc0200b16:	14f51863          	bne	a0,a5,ffffffffc0200c66 <buddy_check+0x244>
    cprintf("A %p\n",A);
ffffffffc0200b1a:	85ca                	mv	a1,s2
ffffffffc0200b1c:	00001517          	auipc	a0,0x1
ffffffffc0200b20:	53c50513          	addi	a0,a0,1340 # ffffffffc0202058 <commands+0x6f0>
ffffffffc0200b24:	d92ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("B %p\n",B);
ffffffffc0200b28:	85a6                	mv	a1,s1
ffffffffc0200b2a:	00001517          	auipc	a0,0x1
ffffffffc0200b2e:	53650513          	addi	a0,a0,1334 # ffffffffc0202060 <commands+0x6f8>
ffffffffc0200b32:	d84ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    C=alloc_pages(80);
ffffffffc0200b36:	05000513          	li	a0,80
ffffffffc0200b3a:	548000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200b3e:	678d                	lui	a5,0x3
ffffffffc0200b40:	80078793          	addi	a5,a5,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200b44:	97ca                	add	a5,a5,s2
    C=alloc_pages(80);
ffffffffc0200b46:	89aa                	mv	s3,a0
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200b48:	0ef51f63          	bne	a0,a5,ffffffffc0200c46 <buddy_check+0x224>
    cprintf("C %p\n",C);
ffffffffc0200b4c:	85aa                	mv	a1,a0
ffffffffc0200b4e:	00001517          	auipc	a0,0x1
ffffffffc0200b52:	54a50513          	addi	a0,a0,1354 # ffffffffc0202098 <commands+0x730>
ffffffffc0200b56:	d60ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(A,70);//释放A
ffffffffc0200b5a:	854a                	mv	a0,s2
ffffffffc0200b5c:	04600593          	li	a1,70
ffffffffc0200b60:	566000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    cprintf("B %p\n",B);
ffffffffc0200b64:	85a6                	mv	a1,s1
ffffffffc0200b66:	00001517          	auipc	a0,0x1
ffffffffc0200b6a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0202060 <commands+0x6f8>
ffffffffc0200b6e:	d48ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    D=alloc_pages(60);
ffffffffc0200b72:	03c00513          	li	a0,60
ffffffffc0200b76:	50c000ef          	jal	ra,ffffffffc0201082 <alloc_pages>
    cprintf("D %p\n",D);
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200b7a:	a0040413          	addi	s0,s0,-1536
    cprintf("D %p\n",D);
ffffffffc0200b7e:	85aa                	mv	a1,a0
    D=alloc_pages(60);
ffffffffc0200b80:	892a                	mv	s2,a0
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200b82:	9426                	add	s0,s0,s1
    cprintf("D %p\n",D);
ffffffffc0200b84:	00001517          	auipc	a0,0x1
ffffffffc0200b88:	51c50513          	addi	a0,a0,1308 # ffffffffc02020a0 <commands+0x738>
ffffffffc0200b8c:	d2aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200b90:	14891b63          	bne	s2,s0,ffffffffc0200ce6 <buddy_check+0x2c4>
    free_pages(B,35);
ffffffffc0200b94:	8526                	mv	a0,s1
ffffffffc0200b96:	02300593          	li	a1,35
ffffffffc0200b9a:	52c000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    cprintf("D %p\n",D);
ffffffffc0200b9e:	85ca                	mv	a1,s2
ffffffffc0200ba0:	00001517          	auipc	a0,0x1
ffffffffc0200ba4:	50050513          	addi	a0,a0,1280 # ffffffffc02020a0 <commands+0x738>
ffffffffc0200ba8:	d0eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(D,60);
ffffffffc0200bac:	854a                	mv	a0,s2
ffffffffc0200bae:	03c00593          	li	a1,60
ffffffffc0200bb2:	514000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    cprintf("C %p\n",C);
ffffffffc0200bb6:	85ce                	mv	a1,s3
ffffffffc0200bb8:	00001517          	auipc	a0,0x1
ffffffffc0200bbc:	4e050513          	addi	a0,a0,1248 # ffffffffc0202098 <commands+0x730>
ffffffffc0200bc0:	cf6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(C,80);
ffffffffc0200bc4:	854e                	mv	a0,s3
ffffffffc0200bc6:	05000593          	li	a1,80
ffffffffc0200bca:	4fc000ef          	jal	ra,ffffffffc02010c6 <free_pages>
    free_pages(p0,1000);//全部释放
}
ffffffffc0200bce:	7402                	ld	s0,32(sp)
ffffffffc0200bd0:	70a2                	ld	ra,40(sp)
ffffffffc0200bd2:	64e2                	ld	s1,24(sp)
ffffffffc0200bd4:	6942                	ld	s2,16(sp)
ffffffffc0200bd6:	69a2                	ld	s3,8(sp)
    free_pages(p0,1000);//全部释放
ffffffffc0200bd8:	8552                	mv	a0,s4
}
ffffffffc0200bda:	6a02                	ld	s4,0(sp)
    free_pages(p0,1000);//全部释放
ffffffffc0200bdc:	3e800593          	li	a1,1000
}
ffffffffc0200be0:	6145                	addi	sp,sp,48
    free_pages(p0,1000);//全部释放
ffffffffc0200be2:	4e40006f          	j	ffffffffc02010c6 <free_pages>
    assert(p0 != A && p0 != B && A != B);
ffffffffc0200be6:	00001697          	auipc	a3,0x1
ffffffffc0200bea:	41268693          	addi	a3,a3,1042 # ffffffffc0201ff8 <commands+0x690>
ffffffffc0200bee:	00001617          	auipc	a2,0x1
ffffffffc0200bf2:	4f260613          	addi	a2,a2,1266 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200bf6:	0fd00593          	li	a1,253
ffffffffc0200bfa:	00001517          	auipc	a0,0x1
ffffffffc0200bfe:	4fe50513          	addi	a0,a0,1278 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200c02:	faaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200c06:	00001697          	auipc	a3,0x1
ffffffffc0200c0a:	41268693          	addi	a3,a3,1042 # ffffffffc0202018 <commands+0x6b0>
ffffffffc0200c0e:	00001617          	auipc	a2,0x1
ffffffffc0200c12:	4d260613          	addi	a2,a2,1234 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200c16:	0fe00593          	li	a1,254
ffffffffc0200c1a:	00001517          	auipc	a0,0x1
ffffffffc0200c1e:	4de50513          	addi	a0,a0,1246 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200c22:	f8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == A);
ffffffffc0200c26:	00001697          	auipc	a3,0x1
ffffffffc0200c2a:	44a68693          	addi	a3,a3,1098 # ffffffffc0202070 <commands+0x708>
ffffffffc0200c2e:	00001617          	auipc	a2,0x1
ffffffffc0200c32:	4b260613          	addi	a2,a2,1202 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200c36:	10d00593          	li	a1,269
ffffffffc0200c3a:	00001517          	auipc	a0,0x1
ffffffffc0200c3e:	4be50513          	addi	a0,a0,1214 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200c42:	f6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A+256==C);//检查C有没有和A重叠
ffffffffc0200c46:	00001697          	auipc	a3,0x1
ffffffffc0200c4a:	44268693          	addi	a3,a3,1090 # ffffffffc0202088 <commands+0x720>
ffffffffc0200c4e:	00001617          	auipc	a2,0x1
ffffffffc0200c52:	49260613          	addi	a2,a2,1170 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200c56:	11600593          	li	a1,278
ffffffffc0200c5a:	00001517          	auipc	a0,0x1
ffffffffc0200c5e:	49e50513          	addi	a0,a0,1182 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200c62:	f4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(A+128==B);//检查是否相邻
ffffffffc0200c66:	00001697          	auipc	a3,0x1
ffffffffc0200c6a:	41268693          	addi	a3,a3,1042 # ffffffffc0202078 <commands+0x710>
ffffffffc0200c6e:	00001617          	auipc	a2,0x1
ffffffffc0200c72:	47260613          	addi	a2,a2,1138 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200c76:	11200593          	li	a1,274
ffffffffc0200c7a:	00001517          	auipc	a0,0x1
ffffffffc0200c7e:	47e50513          	addi	a0,a0,1150 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200c82:	f2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200c86:	00001697          	auipc	a3,0x1
ffffffffc0200c8a:	35268693          	addi	a3,a3,850 # ffffffffc0201fd8 <commands+0x670>
ffffffffc0200c8e:	00001617          	auipc	a2,0x1
ffffffffc0200c92:	45260613          	addi	a2,a2,1106 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200c96:	0fb00593          	li	a1,251
ffffffffc0200c9a:	00001517          	auipc	a0,0x1
ffffffffc0200c9e:	45e50513          	addi	a0,a0,1118 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200ca2:	f0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200ca6:	00001697          	auipc	a3,0x1
ffffffffc0200caa:	31268693          	addi	a3,a3,786 # ffffffffc0201fb8 <commands+0x650>
ffffffffc0200cae:	00001617          	auipc	a2,0x1
ffffffffc0200cb2:	43260613          	addi	a2,a2,1074 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200cb6:	0fa00593          	li	a1,250
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	43e50513          	addi	a0,a0,1086 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200cc2:	eeaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cc6:	00001697          	auipc	a3,0x1
ffffffffc0200cca:	2d268693          	addi	a3,a3,722 # ffffffffc0201f98 <commands+0x630>
ffffffffc0200cce:	00001617          	auipc	a2,0x1
ffffffffc0200cd2:	41260613          	addi	a2,a2,1042 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200cd6:	0f900593          	li	a1,249
ffffffffc0200cda:	00001517          	auipc	a0,0x1
ffffffffc0200cde:	41e50513          	addi	a0,a0,1054 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200ce2:	ecaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(B+64==D);//检查B，D是否相邻
ffffffffc0200ce6:	00001697          	auipc	a3,0x1
ffffffffc0200cea:	3c268693          	addi	a3,a3,962 # ffffffffc02020a8 <commands+0x740>
ffffffffc0200cee:	00001617          	auipc	a2,0x1
ffffffffc0200cf2:	3f260613          	addi	a2,a2,1010 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200cf6:	11c00593          	li	a1,284
ffffffffc0200cfa:	00001517          	auipc	a0,0x1
ffffffffc0200cfe:	3fe50513          	addi	a0,a0,1022 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200d02:	eaaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d06 <buddy2_new.part.2>:
  root[0].size = size;
ffffffffc0200d06:	00005717          	auipc	a4,0x5
ffffffffc0200d0a:	74a72923          	sw	a0,1874(a4) # ffffffffc0206458 <root>
  node_size = size * 2;
ffffffffc0200d0e:	0015161b          	slliw	a2,a0,0x1
  for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200d12:	4705                	li	a4,1
ffffffffc0200d14:	02c75563          	ble	a2,a4,ffffffffc0200d3e <buddy2_new.part.2+0x38>
ffffffffc0200d18:	00005717          	auipc	a4,0x5
ffffffffc0200d1c:	74470713          	addi	a4,a4,1860 # ffffffffc020645c <root+0x4>
ffffffffc0200d20:	fff6051b          	addiw	a0,a2,-1
ffffffffc0200d24:	4781                	li	a5,0
    if (IS_POWER_OF_2(i+1))
ffffffffc0200d26:	0017869b          	addiw	a3,a5,1
ffffffffc0200d2a:	00f6f5b3          	and	a1,a3,a5
ffffffffc0200d2e:	87b6                	mv	a5,a3
ffffffffc0200d30:	e199                	bnez	a1,ffffffffc0200d36 <buddy2_new.part.2+0x30>
      node_size /= 2;
ffffffffc0200d32:	0016561b          	srliw	a2,a2,0x1
    root[i].longest = node_size;
ffffffffc0200d36:	c310                	sw	a2,0(a4)
ffffffffc0200d38:	0721                	addi	a4,a4,8
  for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200d3a:	fea796e3          	bne	a5,a0,ffffffffc0200d26 <buddy2_new.part.2+0x20>
}
ffffffffc0200d3e:	8082                	ret

ffffffffc0200d40 <buddy_init_memmap>:
{
ffffffffc0200d40:	1141                	addi	sp,sp,-16
ffffffffc0200d42:	e406                	sd	ra,8(sp)
    assert(n>0);
ffffffffc0200d44:	c5f5                	beqz	a1,ffffffffc0200e30 <buddy_init_memmap+0xf0>
    for(;p!=base + n;p++)
ffffffffc0200d46:	00259613          	slli	a2,a1,0x2
ffffffffc0200d4a:	962e                	add	a2,a2,a1
ffffffffc0200d4c:	060e                	slli	a2,a2,0x3
ffffffffc0200d4e:	962a                	add	a2,a2,a0
ffffffffc0200d50:	0aa60b63          	beq	a2,a0,ffffffffc0200e06 <buddy_init_memmap+0xc6>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d54:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200d56:	8b85                	andi	a5,a5,1
ffffffffc0200d58:	cfc5                	beqz	a5,ffffffffc0200e10 <buddy_init_memmap+0xd0>
ffffffffc0200d5a:	00005697          	auipc	a3,0x5
ffffffffc0200d5e:	6de68693          	addi	a3,a3,1758 # ffffffffc0206438 <free_area>
        p->property = 1;
ffffffffc0200d62:	4885                	li	a7,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d64:	4809                	li	a6,2
ffffffffc0200d66:	a021                	j	ffffffffc0200d6e <buddy_init_memmap+0x2e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d68:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200d6a:	8b85                	andi	a5,a5,1
ffffffffc0200d6c:	c3d5                	beqz	a5,ffffffffc0200e10 <buddy_init_memmap+0xd0>
        p->flags = 0;
ffffffffc0200d6e:	00053423          	sd	zero,8(a0)
        p->property = 1;
ffffffffc0200d72:	01152823          	sw	a7,16(a0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d76:	00052023          	sw	zero,0(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d7a:	00850793          	addi	a5,a0,8
ffffffffc0200d7e:	4107b02f          	amoor.d	zero,a6,(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d82:	629c                	ld	a5,0(a3)
ffffffffc0200d84:	01850713          	addi	a4,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200d88:	00005317          	auipc	t1,0x5
ffffffffc0200d8c:	6ae33823          	sd	a4,1712(t1) # ffffffffc0206438 <free_area>
ffffffffc0200d90:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200d92:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc0200d94:	ed1c                	sd	a5,24(a0)
    for(;p!=base + n;p++)
ffffffffc0200d96:	02850513          	addi	a0,a0,40
ffffffffc0200d9a:	fca617e3          	bne	a2,a0,ffffffffc0200d68 <buddy_init_memmap+0x28>
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200d9e:	0015d793          	srli	a5,a1,0x1
ffffffffc0200da2:	8fcd                	or	a5,a5,a1
ffffffffc0200da4:	0027d713          	srli	a4,a5,0x2
ffffffffc0200da8:	8fd9                	or	a5,a5,a4
ffffffffc0200daa:	0047d713          	srli	a4,a5,0x4
ffffffffc0200dae:	8f5d                	or	a4,a4,a5
ffffffffc0200db0:	00875793          	srli	a5,a4,0x8
ffffffffc0200db4:	8f5d                	or	a4,a4,a5
    nr_free += n;
ffffffffc0200db6:	4a94                	lw	a3,16(a3)
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200db8:	01075793          	srli	a5,a4,0x10
    nr_free += n;
ffffffffc0200dbc:	0005851b          	sext.w	a0,a1
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200dc0:	8fd9                	or	a5,a5,a4
ffffffffc0200dc2:	8385                	srli	a5,a5,0x1
    nr_free += n;
ffffffffc0200dc4:	00a6873b          	addw	a4,a3,a0
ffffffffc0200dc8:	00005697          	auipc	a3,0x5
ffffffffc0200dcc:	68e6a023          	sw	a4,1664(a3) # ffffffffc0206448 <free_area+0x10>
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200dd0:	8dfd                	and	a1,a1,a5
ffffffffc0200dd2:	e19d                	bnez	a1,ffffffffc0200df8 <buddy_init_memmap+0xb8>
  nr_block=0;
ffffffffc0200dd4:	00005797          	auipc	a5,0x5
ffffffffc0200dd8:	6607ae23          	sw	zero,1660(a5) # ffffffffc0206450 <nr_block>
  if (size < 1 || !IS_POWER_OF_2(size))
ffffffffc0200ddc:	00a05b63          	blez	a0,ffffffffc0200df2 <buddy_init_memmap+0xb2>
ffffffffc0200de0:	fff5079b          	addiw	a5,a0,-1
ffffffffc0200de4:	8fe9                	and	a5,a5,a0
ffffffffc0200de6:	2781                	sext.w	a5,a5
ffffffffc0200de8:	e789                	bnez	a5,ffffffffc0200df2 <buddy_init_memmap+0xb2>
}
ffffffffc0200dea:	60a2                	ld	ra,8(sp)
ffffffffc0200dec:	0141                	addi	sp,sp,16
ffffffffc0200dee:	f19ff06f          	j	ffffffffc0200d06 <buddy2_new.part.2>
ffffffffc0200df2:	60a2                	ld	ra,8(sp)
ffffffffc0200df4:	0141                	addi	sp,sp,16
ffffffffc0200df6:	8082                	ret
    int allocpages=UINT32_ROUND_DOWN(n);
ffffffffc0200df8:	fff7c713          	not	a4,a5
ffffffffc0200dfc:	00a777b3          	and	a5,a4,a0
ffffffffc0200e00:	0007851b          	sext.w	a0,a5
ffffffffc0200e04:	bfc1                	j	ffffffffc0200dd4 <buddy_init_memmap+0x94>
ffffffffc0200e06:	00005697          	auipc	a3,0x5
ffffffffc0200e0a:	63268693          	addi	a3,a3,1586 # ffffffffc0206438 <free_area>
ffffffffc0200e0e:	bf41                	j	ffffffffc0200d9e <buddy_init_memmap+0x5e>
        assert(PageReserved(p));
ffffffffc0200e10:	00001697          	auipc	a3,0x1
ffffffffc0200e14:	30068693          	addi	a3,a3,768 # ffffffffc0202110 <commands+0x7a8>
ffffffffc0200e18:	00001617          	auipc	a2,0x1
ffffffffc0200e1c:	2c860613          	addi	a2,a2,712 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200e20:	05500593          	li	a1,85
ffffffffc0200e24:	00001517          	auipc	a0,0x1
ffffffffc0200e28:	2d450513          	addi	a0,a0,724 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200e2c:	d80ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n>0);
ffffffffc0200e30:	00001697          	auipc	a3,0x1
ffffffffc0200e34:	2d868693          	addi	a3,a3,728 # ffffffffc0202108 <commands+0x7a0>
ffffffffc0200e38:	00001617          	auipc	a2,0x1
ffffffffc0200e3c:	2a860613          	addi	a2,a2,680 # ffffffffc02020e0 <commands+0x778>
ffffffffc0200e40:	05100593          	li	a1,81
ffffffffc0200e44:	00001517          	auipc	a0,0x1
ffffffffc0200e48:	2b450513          	addi	a0,a0,692 # ffffffffc02020f8 <commands+0x790>
ffffffffc0200e4c:	d60ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e50 <buddy2_alloc>:
int buddy2_alloc(struct buddy2* self, int size) {
ffffffffc0200e50:	882a                	mv	a6,a0
  if (self==NULL)//无法分配
ffffffffc0200e52:	c169                	beqz	a0,ffffffffc0200f14 <buddy2_alloc+0xc4>
  if (size <= 0)//分配不合理
ffffffffc0200e54:	4605                	li	a2,1
ffffffffc0200e56:	00b05963          	blez	a1,ffffffffc0200e68 <buddy2_alloc+0x18>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
ffffffffc0200e5a:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200e5e:	8fed                	and	a5,a5,a1
ffffffffc0200e60:	2781                	sext.w	a5,a5
ffffffffc0200e62:	0005861b          	sext.w	a2,a1
ffffffffc0200e66:	ebcd                	bnez	a5,ffffffffc0200f18 <buddy2_alloc+0xc8>
  if (self[index].longest < size)//可分配内存不足
ffffffffc0200e68:	00482783          	lw	a5,4(a6)
ffffffffc0200e6c:	0ac7e463          	bltu	a5,a2,ffffffffc0200f14 <buddy2_alloc+0xc4>
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc0200e70:	00082503          	lw	a0,0(a6)
ffffffffc0200e74:	0cc50763          	beq	a0,a2,ffffffffc0200f42 <buddy2_alloc+0xf2>
ffffffffc0200e78:	85aa                	mv	a1,a0
  unsigned index = 0;//节点的标号
ffffffffc0200e7a:	4781                	li	a5,0
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc0200e7c:	0017989b          	slliw	a7,a5,0x1
ffffffffc0200e80:	0018879b          	addiw	a5,a7,1
ffffffffc0200e84:	02079713          	slli	a4,a5,0x20
ffffffffc0200e88:	8375                	srli	a4,a4,0x1d
ffffffffc0200e8a:	9742                	add	a4,a4,a6
ffffffffc0200e8c:	00472303          	lw	t1,4(a4)
ffffffffc0200e90:	0028869b          	addiw	a3,a7,2
       if(self[RIGHT_LEAF(index)].longest>=size)
ffffffffc0200e94:	02069713          	slli	a4,a3,0x20
ffffffffc0200e98:	8375                	srli	a4,a4,0x1d
ffffffffc0200e9a:	9742                	add	a4,a4,a6
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc0200e9c:	00c36763          	bltu	t1,a2,ffffffffc0200eaa <buddy2_alloc+0x5a>
       if(self[RIGHT_LEAF(index)].longest>=size)
ffffffffc0200ea0:	4358                	lw	a4,4(a4)
ffffffffc0200ea2:	00c76763          	bltu	a4,a2,ffffffffc0200eb0 <buddy2_alloc+0x60>
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
ffffffffc0200ea6:	00677563          	bleu	t1,a4,ffffffffc0200eb0 <buddy2_alloc+0x60>
      index = RIGHT_LEAF(index);
ffffffffc0200eaa:	87b6                	mv	a5,a3
    if (self[LEFT_LEAF(index)].longest >= size)
ffffffffc0200eac:	0038869b          	addiw	a3,a7,3
  for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc0200eb0:	0015d59b          	srliw	a1,a1,0x1
ffffffffc0200eb4:	fcc594e3          	bne	a1,a2,ffffffffc0200e7c <buddy2_alloc+0x2c>
  offset = (index + 1) * node_size - self->size;
ffffffffc0200eb8:	02d586bb          	mulw	a3,a1,a3
  self[index].longest = 0;//标记节点为已使用
ffffffffc0200ebc:	02079713          	slli	a4,a5,0x20
ffffffffc0200ec0:	8375                	srli	a4,a4,0x1d
ffffffffc0200ec2:	9742                	add	a4,a4,a6
ffffffffc0200ec4:	00072223          	sw	zero,4(a4)
  while (index) {
ffffffffc0200ec8:	40a6853b          	subw	a0,a3,a0
ffffffffc0200ecc:	c7a9                	beqz	a5,ffffffffc0200f16 <buddy2_alloc+0xc6>
    index = PARENT(index);
ffffffffc0200ece:	2785                	addiw	a5,a5,1
ffffffffc0200ed0:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200ed4:	367d                	addiw	a2,a2,-1
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0200ed6:	0016169b          	slliw	a3,a2,0x1
ffffffffc0200eda:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200ede:	2685                	addiw	a3,a3,1
ffffffffc0200ee0:	1682                	slli	a3,a3,0x20
ffffffffc0200ee2:	1702                	slli	a4,a4,0x20
ffffffffc0200ee4:	9281                	srli	a3,a3,0x20
ffffffffc0200ee6:	9301                	srli	a4,a4,0x20
ffffffffc0200ee8:	068e                	slli	a3,a3,0x3
ffffffffc0200eea:	070e                	slli	a4,a4,0x3
ffffffffc0200eec:	9742                	add	a4,a4,a6
ffffffffc0200eee:	96c2                	add	a3,a3,a6
ffffffffc0200ef0:	434c                	lw	a1,4(a4)
ffffffffc0200ef2:	42d4                	lw	a3,4(a3)
    self[index].longest = 
ffffffffc0200ef4:	02061713          	slli	a4,a2,0x20
ffffffffc0200ef8:	8375                	srli	a4,a4,0x1d
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0200efa:	0006831b          	sext.w	t1,a3
ffffffffc0200efe:	0005889b          	sext.w	a7,a1
    index = PARENT(index);
ffffffffc0200f02:	0006079b          	sext.w	a5,a2
    self[index].longest = 
ffffffffc0200f06:	9742                	add	a4,a4,a6
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
ffffffffc0200f08:	01137363          	bleu	a7,t1,ffffffffc0200f0e <buddy2_alloc+0xbe>
ffffffffc0200f0c:	86ae                	mv	a3,a1
    self[index].longest = 
ffffffffc0200f0e:	c354                	sw	a3,4(a4)
  while (index) {
ffffffffc0200f10:	ffdd                	bnez	a5,ffffffffc0200ece <buddy2_alloc+0x7e>
ffffffffc0200f12:	8082                	ret
    return -1;
ffffffffc0200f14:	557d                	li	a0,-1
}
ffffffffc0200f16:	8082                	ret
  size |= size >> 1;
ffffffffc0200f18:	0016579b          	srliw	a5,a2,0x1
ffffffffc0200f1c:	8e5d                	or	a2,a2,a5
ffffffffc0200f1e:	2601                	sext.w	a2,a2
  size |= size >> 2;
ffffffffc0200f20:	0026579b          	srliw	a5,a2,0x2
ffffffffc0200f24:	8e5d                	or	a2,a2,a5
ffffffffc0200f26:	2601                	sext.w	a2,a2
  size |= size >> 4;
ffffffffc0200f28:	0046579b          	srliw	a5,a2,0x4
ffffffffc0200f2c:	8e5d                	or	a2,a2,a5
ffffffffc0200f2e:	2601                	sext.w	a2,a2
  size |= size >> 8;
ffffffffc0200f30:	0086579b          	srliw	a5,a2,0x8
ffffffffc0200f34:	8e5d                	or	a2,a2,a5
ffffffffc0200f36:	2601                	sext.w	a2,a2
  size |= size >> 16;
ffffffffc0200f38:	0106579b          	srliw	a5,a2,0x10
ffffffffc0200f3c:	8e5d                	or	a2,a2,a5
  return size+1;
ffffffffc0200f3e:	2605                	addiw	a2,a2,1
ffffffffc0200f40:	b725                	j	ffffffffc0200e68 <buddy2_alloc+0x18>
  self[index].longest = 0;//标记节点为已使用
ffffffffc0200f42:	00082223          	sw	zero,4(a6)
ffffffffc0200f46:	4501                	li	a0,0
ffffffffc0200f48:	8082                	ret

ffffffffc0200f4a <buddy_alloc_pages>:
buddy_alloc_pages(size_t n){
ffffffffc0200f4a:	7179                	addi	sp,sp,-48
ffffffffc0200f4c:	f406                	sd	ra,40(sp)
ffffffffc0200f4e:	f022                	sd	s0,32(sp)
ffffffffc0200f50:	ec26                	sd	s1,24(sp)
ffffffffc0200f52:	e84a                	sd	s2,16(sp)
ffffffffc0200f54:	e44e                	sd	s3,8(sp)
ffffffffc0200f56:	e052                	sd	s4,0(sp)
  assert(n>0);
ffffffffc0200f58:	10050563          	beqz	a0,ffffffffc0201062 <buddy_alloc_pages+0x118>
ffffffffc0200f5c:	892a                	mv	s2,a0
  if(n>nr_free)
ffffffffc0200f5e:	00005797          	auipc	a5,0x5
ffffffffc0200f62:	4ea7e783          	lwu	a5,1258(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200f66:	00005497          	auipc	s1,0x5
ffffffffc0200f6a:	4d248493          	addi	s1,s1,1234 # ffffffffc0206438 <free_area>
   return NULL;
ffffffffc0200f6e:	4501                	li	a0,0
  if(n>nr_free)
ffffffffc0200f70:	0b27e963          	bltu	a5,s2,ffffffffc0201022 <buddy_alloc_pages+0xd8>
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200f74:	0009041b          	sext.w	s0,s2
ffffffffc0200f78:	00005a17          	auipc	s4,0x5
ffffffffc0200f7c:	4d8a0a13          	addi	s4,s4,1240 # ffffffffc0206450 <nr_block>
ffffffffc0200f80:	85a2                	mv	a1,s0
ffffffffc0200f82:	00005517          	auipc	a0,0x5
ffffffffc0200f86:	4d650513          	addi	a0,a0,1238 # ffffffffc0206458 <root>
ffffffffc0200f8a:	000a2983          	lw	s3,0(s4)
ffffffffc0200f8e:	ec3ff0ef          	jal	ra,ffffffffc0200e50 <buddy2_alloc>
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200f92:	000a2583          	lw	a1,0(s4)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200f96:	00199793          	slli	a5,s3,0x1
ffffffffc0200f9a:	97ce                	add	a5,a5,s3
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200f9c:	00159893          	slli	a7,a1,0x1
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200fa0:	000a2817          	auipc	a6,0xa2
ffffffffc0200fa4:	8b880813          	addi	a6,a6,-1864 # ffffffffc02a2858 <rec>
ffffffffc0200fa8:	078e                	slli	a5,a5,0x3
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200faa:	00b88733          	add	a4,a7,a1
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200fae:	97c2                	add	a5,a5,a6
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200fb0:	070e                	slli	a4,a4,0x3
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200fb2:	c788                	sw	a0,8(a5)
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200fb4:	9742                	add	a4,a4,a6
ffffffffc0200fb6:	4718                	lw	a4,8(a4)
  rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
ffffffffc0200fb8:	86a2                	mv	a3,s0
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200fba:	0a074263          	bltz	a4,ffffffffc020105e <buddy_alloc_pages+0x114>
ffffffffc0200fbe:	2705                	addiw	a4,a4,1
ffffffffc0200fc0:	4781                	li	a5,0
  list_entry_t *le=&free_list,*len;
ffffffffc0200fc2:	8626                	mv	a2,s1
  for(i=0;i<rec[nr_block].offset+1;i++)
ffffffffc0200fc4:	2785                	addiw	a5,a5,1
    return listelm->next;
ffffffffc0200fc6:	6610                	ld	a2,8(a2)
ffffffffc0200fc8:	fef71ee3          	bne	a4,a5,ffffffffc0200fc4 <buddy_alloc_pages+0x7a>
  if(!IS_POWER_OF_2(n))
ffffffffc0200fcc:	fff90793          	addi	a5,s2,-1
ffffffffc0200fd0:	0127f933          	and	s2,a5,s2
  page=le2page(le,page_link);
ffffffffc0200fd4:	fe860513          	addi	a0,a2,-24
  if(!IS_POWER_OF_2(n))
ffffffffc0200fd8:	8322                	mv	t1,s0
ffffffffc0200fda:	04091c63          	bnez	s2,ffffffffc0201032 <buddy_alloc_pages+0xe8>
  rec[nr_block].base=page;//记录分配块首页
ffffffffc0200fde:	98ae                	add	a7,a7,a1
ffffffffc0200fe0:	088e                	slli	a7,a7,0x3
ffffffffc0200fe2:	9846                	add	a6,a6,a7
  nr_block++;
ffffffffc0200fe4:	2585                	addiw	a1,a1,1
  rec[nr_block].base=page;//记录分配块首页
ffffffffc0200fe6:	00a83023          	sd	a0,0(a6)
  rec[nr_block].nr=allocpages;//记录分配的页数
ffffffffc0200fea:	00d83823          	sd	a3,16(a6)
  nr_block++;
ffffffffc0200fee:	00005797          	auipc	a5,0x5
ffffffffc0200ff2:	46b7a123          	sw	a1,1122(a5) # ffffffffc0206450 <nr_block>
  for(i=0;i<allocpages;i++)
ffffffffc0200ff6:	87b2                	mv	a5,a2
ffffffffc0200ff8:	4701                	li	a4,0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ffa:	5875                	li	a6,-3
ffffffffc0200ffc:	00d05a63          	blez	a3,ffffffffc0201010 <buddy_alloc_pages+0xc6>
ffffffffc0201000:	678c                	ld	a1,8(a5)
ffffffffc0201002:	17c1                	addi	a5,a5,-16
ffffffffc0201004:	6107b02f          	amoand.d	zero,a6,(a5)
ffffffffc0201008:	2705                	addiw	a4,a4,1
    le=len;
ffffffffc020100a:	87ae                	mv	a5,a1
  for(i=0;i<allocpages;i++)
ffffffffc020100c:	fee69ae3          	bne	a3,a4,ffffffffc0201000 <buddy_alloc_pages+0xb6>
  nr_free-=allocpages;//减去已被分配的页数
ffffffffc0201010:	489c                	lw	a5,16(s1)
ffffffffc0201012:	406787bb          	subw	a5,a5,t1
ffffffffc0201016:	00005717          	auipc	a4,0x5
ffffffffc020101a:	42f72923          	sw	a5,1074(a4) # ffffffffc0206448 <free_area+0x10>
  page->property=n;
ffffffffc020101e:	fe862c23          	sw	s0,-8(a2)
}
ffffffffc0201022:	70a2                	ld	ra,40(sp)
ffffffffc0201024:	7402                	ld	s0,32(sp)
ffffffffc0201026:	64e2                	ld	s1,24(sp)
ffffffffc0201028:	6942                	ld	s2,16(sp)
ffffffffc020102a:	69a2                	ld	s3,8(sp)
ffffffffc020102c:	6a02                	ld	s4,0(sp)
ffffffffc020102e:	6145                	addi	sp,sp,48
ffffffffc0201030:	8082                	ret
  size |= size >> 1;
ffffffffc0201032:	0014569b          	srliw	a3,s0,0x1
ffffffffc0201036:	8ec1                	or	a3,a3,s0
ffffffffc0201038:	2681                	sext.w	a3,a3
  size |= size >> 2;
ffffffffc020103a:	0026d79b          	srliw	a5,a3,0x2
ffffffffc020103e:	8edd                	or	a3,a3,a5
ffffffffc0201040:	2681                	sext.w	a3,a3
  size |= size >> 4;
ffffffffc0201042:	0046d79b          	srliw	a5,a3,0x4
ffffffffc0201046:	8edd                	or	a3,a3,a5
ffffffffc0201048:	2681                	sext.w	a3,a3
  size |= size >> 8;
ffffffffc020104a:	0086d79b          	srliw	a5,a3,0x8
ffffffffc020104e:	8edd                	or	a3,a3,a5
ffffffffc0201050:	2681                	sext.w	a3,a3
  size |= size >> 16;
ffffffffc0201052:	0106d79b          	srliw	a5,a3,0x10
ffffffffc0201056:	8edd                	or	a3,a3,a5
  return size+1;
ffffffffc0201058:	2685                	addiw	a3,a3,1
   allocpages=fixsize(n);
ffffffffc020105a:	8336                	mv	t1,a3
ffffffffc020105c:	b749                	j	ffffffffc0200fde <buddy_alloc_pages+0x94>
  list_entry_t *le=&free_list,*len;
ffffffffc020105e:	8626                	mv	a2,s1
ffffffffc0201060:	b7b5                	j	ffffffffc0200fcc <buddy_alloc_pages+0x82>
  assert(n>0);
ffffffffc0201062:	00001697          	auipc	a3,0x1
ffffffffc0201066:	0a668693          	addi	a3,a3,166 # ffffffffc0202108 <commands+0x7a0>
ffffffffc020106a:	00001617          	auipc	a2,0x1
ffffffffc020106e:	07660613          	addi	a2,a2,118 # ffffffffc02020e0 <commands+0x778>
ffffffffc0201072:	08f00593          	li	a1,143
ffffffffc0201076:	00001517          	auipc	a0,0x1
ffffffffc020107a:	08250513          	addi	a0,a0,130 # ffffffffc02020f8 <commands+0x790>
ffffffffc020107e:	b2eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201082 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201082:	100027f3          	csrr	a5,sstatus
ffffffffc0201086:	8b89                	andi	a5,a5,2
ffffffffc0201088:	eb89                	bnez	a5,ffffffffc020109a <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020108a:	00276797          	auipc	a5,0x276
ffffffffc020108e:	3d678793          	addi	a5,a5,982 # ffffffffc0477460 <pmm_manager>
ffffffffc0201092:	639c                	ld	a5,0(a5)
ffffffffc0201094:	0187b303          	ld	t1,24(a5)
ffffffffc0201098:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc020109a:	1141                	addi	sp,sp,-16
ffffffffc020109c:	e406                	sd	ra,8(sp)
ffffffffc020109e:	e022                	sd	s0,0(sp)
ffffffffc02010a0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010a2:	bc2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010a6:	00276797          	auipc	a5,0x276
ffffffffc02010aa:	3ba78793          	addi	a5,a5,954 # ffffffffc0477460 <pmm_manager>
ffffffffc02010ae:	639c                	ld	a5,0(a5)
ffffffffc02010b0:	8522                	mv	a0,s0
ffffffffc02010b2:	6f9c                	ld	a5,24(a5)
ffffffffc02010b4:	9782                	jalr	a5
ffffffffc02010b6:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02010b8:	ba6ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010bc:	8522                	mv	a0,s0
ffffffffc02010be:	60a2                	ld	ra,8(sp)
ffffffffc02010c0:	6402                	ld	s0,0(sp)
ffffffffc02010c2:	0141                	addi	sp,sp,16
ffffffffc02010c4:	8082                	ret

ffffffffc02010c6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010c6:	100027f3          	csrr	a5,sstatus
ffffffffc02010ca:	8b89                	andi	a5,a5,2
ffffffffc02010cc:	eb89                	bnez	a5,ffffffffc02010de <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010ce:	00276797          	auipc	a5,0x276
ffffffffc02010d2:	39278793          	addi	a5,a5,914 # ffffffffc0477460 <pmm_manager>
ffffffffc02010d6:	639c                	ld	a5,0(a5)
ffffffffc02010d8:	0207b303          	ld	t1,32(a5)
ffffffffc02010dc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02010de:	1101                	addi	sp,sp,-32
ffffffffc02010e0:	ec06                	sd	ra,24(sp)
ffffffffc02010e2:	e822                	sd	s0,16(sp)
ffffffffc02010e4:	e426                	sd	s1,8(sp)
ffffffffc02010e6:	842a                	mv	s0,a0
ffffffffc02010e8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010ea:	b7aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010ee:	00276797          	auipc	a5,0x276
ffffffffc02010f2:	37278793          	addi	a5,a5,882 # ffffffffc0477460 <pmm_manager>
ffffffffc02010f6:	639c                	ld	a5,0(a5)
ffffffffc02010f8:	85a6                	mv	a1,s1
ffffffffc02010fa:	8522                	mv	a0,s0
ffffffffc02010fc:	739c                	ld	a5,32(a5)
ffffffffc02010fe:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201100:	6442                	ld	s0,16(sp)
ffffffffc0201102:	60e2                	ld	ra,24(sp)
ffffffffc0201104:	64a2                	ld	s1,8(sp)
ffffffffc0201106:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201108:	b56ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020110c <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020110c:	00001797          	auipc	a5,0x1
ffffffffc0201110:	01478793          	addi	a5,a5,20 # ffffffffc0202120 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201114:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201116:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	05850513          	addi	a0,a0,88 # ffffffffc0202170 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201120:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201122:	00276717          	auipc	a4,0x276
ffffffffc0201126:	32f73f23          	sd	a5,830(a4) # ffffffffc0477460 <pmm_manager>
void pmm_init(void) {
ffffffffc020112a:	e822                	sd	s0,16(sp)
ffffffffc020112c:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020112e:	00276417          	auipc	s0,0x276
ffffffffc0201132:	33240413          	addi	s0,s0,818 # ffffffffc0477460 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201136:	f81fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020113a:	601c                	ld	a5,0(s0)
ffffffffc020113c:	679c                	ld	a5,8(a5)
ffffffffc020113e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201140:	57f5                	li	a5,-3
ffffffffc0201142:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201144:	00001517          	auipc	a0,0x1
ffffffffc0201148:	04450513          	addi	a0,a0,68 # ffffffffc0202188 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020114c:	00276717          	auipc	a4,0x276
ffffffffc0201150:	30f73e23          	sd	a5,796(a4) # ffffffffc0477468 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201154:	f63fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201158:	46c5                	li	a3,17
ffffffffc020115a:	06ee                	slli	a3,a3,0x1b
ffffffffc020115c:	40100613          	li	a2,1025
ffffffffc0201160:	16fd                	addi	a3,a3,-1
ffffffffc0201162:	0656                	slli	a2,a2,0x15
ffffffffc0201164:	07e005b7          	lui	a1,0x7e00
ffffffffc0201168:	00001517          	auipc	a0,0x1
ffffffffc020116c:	03850513          	addi	a0,a0,56 # ffffffffc02021a0 <buddy_pmm_manager+0x80>
ffffffffc0201170:	f47fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201174:	777d                	lui	a4,0xfffff
ffffffffc0201176:	00277797          	auipc	a5,0x277
ffffffffc020117a:	30178793          	addi	a5,a5,769 # ffffffffc0478477 <end+0xfff>
ffffffffc020117e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201180:	00088737          	lui	a4,0x88
ffffffffc0201184:	00005697          	auipc	a3,0x5
ffffffffc0201188:	28e6ba23          	sd	a4,660(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020118c:	4601                	li	a2,0
ffffffffc020118e:	00276717          	auipc	a4,0x276
ffffffffc0201192:	2ef73123          	sd	a5,738(a4) # ffffffffc0477470 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201196:	4681                	li	a3,0
ffffffffc0201198:	00005897          	auipc	a7,0x5
ffffffffc020119c:	28088893          	addi	a7,a7,640 # ffffffffc0206418 <npage>
ffffffffc02011a0:	00276597          	auipc	a1,0x276
ffffffffc02011a4:	2d058593          	addi	a1,a1,720 # ffffffffc0477470 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011a8:	4805                	li	a6,1
ffffffffc02011aa:	fff80537          	lui	a0,0xfff80
ffffffffc02011ae:	a011                	j	ffffffffc02011b2 <pmm_init+0xa6>
ffffffffc02011b0:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc02011b2:	97b2                	add	a5,a5,a2
ffffffffc02011b4:	07a1                	addi	a5,a5,8
ffffffffc02011b6:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011ba:	0008b703          	ld	a4,0(a7)
ffffffffc02011be:	0685                	addi	a3,a3,1
ffffffffc02011c0:	02860613          	addi	a2,a2,40
ffffffffc02011c4:	00a707b3          	add	a5,a4,a0
ffffffffc02011c8:	fef6e4e3          	bltu	a3,a5,ffffffffc02011b0 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011cc:	6190                	ld	a2,0(a1)
ffffffffc02011ce:	00271793          	slli	a5,a4,0x2
ffffffffc02011d2:	97ba                	add	a5,a5,a4
ffffffffc02011d4:	fec006b7          	lui	a3,0xfec00
ffffffffc02011d8:	078e                	slli	a5,a5,0x3
ffffffffc02011da:	96b2                	add	a3,a3,a2
ffffffffc02011dc:	96be                	add	a3,a3,a5
ffffffffc02011de:	c02007b7          	lui	a5,0xc0200
ffffffffc02011e2:	08f6e863          	bltu	a3,a5,ffffffffc0201272 <pmm_init+0x166>
ffffffffc02011e6:	00276497          	auipc	s1,0x276
ffffffffc02011ea:	28248493          	addi	s1,s1,642 # ffffffffc0477468 <va_pa_offset>
ffffffffc02011ee:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02011f0:	45c5                	li	a1,17
ffffffffc02011f2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011f4:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02011f6:	04b6e963          	bltu	a3,a1,ffffffffc0201248 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02011fa:	601c                	ld	a5,0(s0)
ffffffffc02011fc:	7b9c                	ld	a5,48(a5)
ffffffffc02011fe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201200:	00001517          	auipc	a0,0x1
ffffffffc0201204:	03850513          	addi	a0,a0,56 # ffffffffc0202238 <buddy_pmm_manager+0x118>
ffffffffc0201208:	eaffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020120c:	00004697          	auipc	a3,0x4
ffffffffc0201210:	df468693          	addi	a3,a3,-524 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201214:	00005797          	auipc	a5,0x5
ffffffffc0201218:	20d7b623          	sd	a3,524(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020121c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201220:	06f6e563          	bltu	a3,a5,ffffffffc020128a <pmm_init+0x17e>
ffffffffc0201224:	609c                	ld	a5,0(s1)
}
ffffffffc0201226:	6442                	ld	s0,16(sp)
ffffffffc0201228:	60e2                	ld	ra,24(sp)
ffffffffc020122a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020122c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020122e:	8e9d                	sub	a3,a3,a5
ffffffffc0201230:	00276797          	auipc	a5,0x276
ffffffffc0201234:	22d7b423          	sd	a3,552(a5) # ffffffffc0477458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201238:	00001517          	auipc	a0,0x1
ffffffffc020123c:	02050513          	addi	a0,a0,32 # ffffffffc0202258 <buddy_pmm_manager+0x138>
ffffffffc0201240:	8636                	mv	a2,a3
}
ffffffffc0201242:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201244:	e73fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201248:	6785                	lui	a5,0x1
ffffffffc020124a:	17fd                	addi	a5,a5,-1
ffffffffc020124c:	96be                	add	a3,a3,a5
ffffffffc020124e:	77fd                	lui	a5,0xfffff
ffffffffc0201250:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201252:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201256:	04e7f663          	bleu	a4,a5,ffffffffc02012a2 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc020125a:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020125c:	97aa                	add	a5,a5,a0
ffffffffc020125e:	00279513          	slli	a0,a5,0x2
ffffffffc0201262:	953e                	add	a0,a0,a5
ffffffffc0201264:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201266:	8d95                	sub	a1,a1,a3
ffffffffc0201268:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020126a:	81b1                	srli	a1,a1,0xc
ffffffffc020126c:	9532                	add	a0,a0,a2
ffffffffc020126e:	9782                	jalr	a5
ffffffffc0201270:	b769                	j	ffffffffc02011fa <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201272:	00001617          	auipc	a2,0x1
ffffffffc0201276:	f5e60613          	addi	a2,a2,-162 # ffffffffc02021d0 <buddy_pmm_manager+0xb0>
ffffffffc020127a:	06f00593          	li	a1,111
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	f7a50513          	addi	a0,a0,-134 # ffffffffc02021f8 <buddy_pmm_manager+0xd8>
ffffffffc0201286:	926ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020128a:	00001617          	auipc	a2,0x1
ffffffffc020128e:	f4660613          	addi	a2,a2,-186 # ffffffffc02021d0 <buddy_pmm_manager+0xb0>
ffffffffc0201292:	08a00593          	li	a1,138
ffffffffc0201296:	00001517          	auipc	a0,0x1
ffffffffc020129a:	f6250513          	addi	a0,a0,-158 # ffffffffc02021f8 <buddy_pmm_manager+0xd8>
ffffffffc020129e:	90eff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02012a2:	00001617          	auipc	a2,0x1
ffffffffc02012a6:	f6660613          	addi	a2,a2,-154 # ffffffffc0202208 <buddy_pmm_manager+0xe8>
ffffffffc02012aa:	06b00593          	li	a1,107
ffffffffc02012ae:	00001517          	auipc	a0,0x1
ffffffffc02012b2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0202228 <buddy_pmm_manager+0x108>
ffffffffc02012b6:	8f6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012ba <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02012ba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012be:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02012c0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012c4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012c6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012ca:	f022                	sd	s0,32(sp)
ffffffffc02012cc:	ec26                	sd	s1,24(sp)
ffffffffc02012ce:	e84a                	sd	s2,16(sp)
ffffffffc02012d0:	f406                	sd	ra,40(sp)
ffffffffc02012d2:	e44e                	sd	s3,8(sp)
ffffffffc02012d4:	84aa                	mv	s1,a0
ffffffffc02012d6:	892e                	mv	s2,a1
ffffffffc02012d8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02012dc:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02012de:	03067e63          	bleu	a6,a2,ffffffffc020131a <printnum+0x60>
ffffffffc02012e2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012e4:	00805763          	blez	s0,ffffffffc02012f2 <printnum+0x38>
ffffffffc02012e8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02012ea:	85ca                	mv	a1,s2
ffffffffc02012ec:	854e                	mv	a0,s3
ffffffffc02012ee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02012f0:	fc65                	bnez	s0,ffffffffc02012e8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012f2:	1a02                	slli	s4,s4,0x20
ffffffffc02012f4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02012f8:	00001797          	auipc	a5,0x1
ffffffffc02012fc:	13078793          	addi	a5,a5,304 # ffffffffc0202428 <error_string+0x38>
ffffffffc0201300:	9a3e                	add	s4,s4,a5
}
ffffffffc0201302:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201304:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201308:	70a2                	ld	ra,40(sp)
ffffffffc020130a:	69a2                	ld	s3,8(sp)
ffffffffc020130c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020130e:	85ca                	mv	a1,s2
ffffffffc0201310:	8326                	mv	t1,s1
}
ffffffffc0201312:	6942                	ld	s2,16(sp)
ffffffffc0201314:	64e2                	ld	s1,24(sp)
ffffffffc0201316:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201318:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020131a:	03065633          	divu	a2,a2,a6
ffffffffc020131e:	8722                	mv	a4,s0
ffffffffc0201320:	f9bff0ef          	jal	ra,ffffffffc02012ba <printnum>
ffffffffc0201324:	b7f9                	j	ffffffffc02012f2 <printnum+0x38>

ffffffffc0201326 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201326:	7119                	addi	sp,sp,-128
ffffffffc0201328:	f4a6                	sd	s1,104(sp)
ffffffffc020132a:	f0ca                	sd	s2,96(sp)
ffffffffc020132c:	e8d2                	sd	s4,80(sp)
ffffffffc020132e:	e4d6                	sd	s5,72(sp)
ffffffffc0201330:	e0da                	sd	s6,64(sp)
ffffffffc0201332:	fc5e                	sd	s7,56(sp)
ffffffffc0201334:	f862                	sd	s8,48(sp)
ffffffffc0201336:	f06a                	sd	s10,32(sp)
ffffffffc0201338:	fc86                	sd	ra,120(sp)
ffffffffc020133a:	f8a2                	sd	s0,112(sp)
ffffffffc020133c:	ecce                	sd	s3,88(sp)
ffffffffc020133e:	f466                	sd	s9,40(sp)
ffffffffc0201340:	ec6e                	sd	s11,24(sp)
ffffffffc0201342:	892a                	mv	s2,a0
ffffffffc0201344:	84ae                	mv	s1,a1
ffffffffc0201346:	8d32                	mv	s10,a2
ffffffffc0201348:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020134a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020134c:	00001a17          	auipc	s4,0x1
ffffffffc0201350:	f4ca0a13          	addi	s4,s4,-180 # ffffffffc0202298 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201354:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201358:	00001c17          	auipc	s8,0x1
ffffffffc020135c:	098c0c13          	addi	s8,s8,152 # ffffffffc02023f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201360:	000d4503          	lbu	a0,0(s10)
ffffffffc0201364:	02500793          	li	a5,37
ffffffffc0201368:	001d0413          	addi	s0,s10,1
ffffffffc020136c:	00f50e63          	beq	a0,a5,ffffffffc0201388 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201370:	c521                	beqz	a0,ffffffffc02013b8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201372:	02500993          	li	s3,37
ffffffffc0201376:	a011                	j	ffffffffc020137a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201378:	c121                	beqz	a0,ffffffffc02013b8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020137a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020137c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020137e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201380:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201384:	ff351ae3          	bne	a0,s3,ffffffffc0201378 <vprintfmt+0x52>
ffffffffc0201388:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020138c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201390:	4981                	li	s3,0
ffffffffc0201392:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201394:	5cfd                	li	s9,-1
ffffffffc0201396:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201398:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020139c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020139e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02013a2:	0ff6f693          	andi	a3,a3,255
ffffffffc02013a6:	00140d13          	addi	s10,s0,1
ffffffffc02013aa:	20d5e563          	bltu	a1,a3,ffffffffc02015b4 <vprintfmt+0x28e>
ffffffffc02013ae:	068a                	slli	a3,a3,0x2
ffffffffc02013b0:	96d2                	add	a3,a3,s4
ffffffffc02013b2:	4294                	lw	a3,0(a3)
ffffffffc02013b4:	96d2                	add	a3,a3,s4
ffffffffc02013b6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02013b8:	70e6                	ld	ra,120(sp)
ffffffffc02013ba:	7446                	ld	s0,112(sp)
ffffffffc02013bc:	74a6                	ld	s1,104(sp)
ffffffffc02013be:	7906                	ld	s2,96(sp)
ffffffffc02013c0:	69e6                	ld	s3,88(sp)
ffffffffc02013c2:	6a46                	ld	s4,80(sp)
ffffffffc02013c4:	6aa6                	ld	s5,72(sp)
ffffffffc02013c6:	6b06                	ld	s6,64(sp)
ffffffffc02013c8:	7be2                	ld	s7,56(sp)
ffffffffc02013ca:	7c42                	ld	s8,48(sp)
ffffffffc02013cc:	7ca2                	ld	s9,40(sp)
ffffffffc02013ce:	7d02                	ld	s10,32(sp)
ffffffffc02013d0:	6de2                	ld	s11,24(sp)
ffffffffc02013d2:	6109                	addi	sp,sp,128
ffffffffc02013d4:	8082                	ret
    if (lflag >= 2) {
ffffffffc02013d6:	4705                	li	a4,1
ffffffffc02013d8:	008a8593          	addi	a1,s5,8
ffffffffc02013dc:	01074463          	blt	a4,a6,ffffffffc02013e4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02013e0:	26080363          	beqz	a6,ffffffffc0201646 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02013e4:	000ab603          	ld	a2,0(s5)
ffffffffc02013e8:	46c1                	li	a3,16
ffffffffc02013ea:	8aae                	mv	s5,a1
ffffffffc02013ec:	a06d                	j	ffffffffc0201496 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02013ee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02013f2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013f6:	b765                	j	ffffffffc020139e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02013f8:	000aa503          	lw	a0,0(s5)
ffffffffc02013fc:	85a6                	mv	a1,s1
ffffffffc02013fe:	0aa1                	addi	s5,s5,8
ffffffffc0201400:	9902                	jalr	s2
            break;
ffffffffc0201402:	bfb9                	j	ffffffffc0201360 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201404:	4705                	li	a4,1
ffffffffc0201406:	008a8993          	addi	s3,s5,8
ffffffffc020140a:	01074463          	blt	a4,a6,ffffffffc0201412 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020140e:	22080463          	beqz	a6,ffffffffc0201636 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201412:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201416:	24044463          	bltz	s0,ffffffffc020165e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020141a:	8622                	mv	a2,s0
ffffffffc020141c:	8ace                	mv	s5,s3
ffffffffc020141e:	46a9                	li	a3,10
ffffffffc0201420:	a89d                	j	ffffffffc0201496 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201422:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201426:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201428:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020142a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020142e:	8fb5                	xor	a5,a5,a3
ffffffffc0201430:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201434:	1ad74363          	blt	a4,a3,ffffffffc02015da <vprintfmt+0x2b4>
ffffffffc0201438:	00369793          	slli	a5,a3,0x3
ffffffffc020143c:	97e2                	add	a5,a5,s8
ffffffffc020143e:	639c                	ld	a5,0(a5)
ffffffffc0201440:	18078d63          	beqz	a5,ffffffffc02015da <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201444:	86be                	mv	a3,a5
ffffffffc0201446:	00001617          	auipc	a2,0x1
ffffffffc020144a:	09260613          	addi	a2,a2,146 # ffffffffc02024d8 <error_string+0xe8>
ffffffffc020144e:	85a6                	mv	a1,s1
ffffffffc0201450:	854a                	mv	a0,s2
ffffffffc0201452:	240000ef          	jal	ra,ffffffffc0201692 <printfmt>
ffffffffc0201456:	b729                	j	ffffffffc0201360 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201458:	00144603          	lbu	a2,1(s0)
ffffffffc020145c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020145e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201460:	bf3d                	j	ffffffffc020139e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201462:	4705                	li	a4,1
ffffffffc0201464:	008a8593          	addi	a1,s5,8
ffffffffc0201468:	01074463          	blt	a4,a6,ffffffffc0201470 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020146c:	1e080263          	beqz	a6,ffffffffc0201650 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201470:	000ab603          	ld	a2,0(s5)
ffffffffc0201474:	46a1                	li	a3,8
ffffffffc0201476:	8aae                	mv	s5,a1
ffffffffc0201478:	a839                	j	ffffffffc0201496 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020147a:	03000513          	li	a0,48
ffffffffc020147e:	85a6                	mv	a1,s1
ffffffffc0201480:	e03e                	sd	a5,0(sp)
ffffffffc0201482:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201484:	85a6                	mv	a1,s1
ffffffffc0201486:	07800513          	li	a0,120
ffffffffc020148a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020148c:	0aa1                	addi	s5,s5,8
ffffffffc020148e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201492:	6782                	ld	a5,0(sp)
ffffffffc0201494:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201496:	876e                	mv	a4,s11
ffffffffc0201498:	85a6                	mv	a1,s1
ffffffffc020149a:	854a                	mv	a0,s2
ffffffffc020149c:	e1fff0ef          	jal	ra,ffffffffc02012ba <printnum>
            break;
ffffffffc02014a0:	b5c1                	j	ffffffffc0201360 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014a2:	000ab603          	ld	a2,0(s5)
ffffffffc02014a6:	0aa1                	addi	s5,s5,8
ffffffffc02014a8:	1c060663          	beqz	a2,ffffffffc0201674 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02014ac:	00160413          	addi	s0,a2,1
ffffffffc02014b0:	17b05c63          	blez	s11,ffffffffc0201628 <vprintfmt+0x302>
ffffffffc02014b4:	02d00593          	li	a1,45
ffffffffc02014b8:	14b79263          	bne	a5,a1,ffffffffc02015fc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014bc:	00064783          	lbu	a5,0(a2)
ffffffffc02014c0:	0007851b          	sext.w	a0,a5
ffffffffc02014c4:	c905                	beqz	a0,ffffffffc02014f4 <vprintfmt+0x1ce>
ffffffffc02014c6:	000cc563          	bltz	s9,ffffffffc02014d0 <vprintfmt+0x1aa>
ffffffffc02014ca:	3cfd                	addiw	s9,s9,-1
ffffffffc02014cc:	036c8263          	beq	s9,s6,ffffffffc02014f0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02014d0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014d2:	18098463          	beqz	s3,ffffffffc020165a <vprintfmt+0x334>
ffffffffc02014d6:	3781                	addiw	a5,a5,-32
ffffffffc02014d8:	18fbf163          	bleu	a5,s7,ffffffffc020165a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02014dc:	03f00513          	li	a0,63
ffffffffc02014e0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014e2:	0405                	addi	s0,s0,1
ffffffffc02014e4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02014e8:	3dfd                	addiw	s11,s11,-1
ffffffffc02014ea:	0007851b          	sext.w	a0,a5
ffffffffc02014ee:	fd61                	bnez	a0,ffffffffc02014c6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02014f0:	e7b058e3          	blez	s11,ffffffffc0201360 <vprintfmt+0x3a>
ffffffffc02014f4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014f6:	85a6                	mv	a1,s1
ffffffffc02014f8:	02000513          	li	a0,32
ffffffffc02014fc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014fe:	e60d81e3          	beqz	s11,ffffffffc0201360 <vprintfmt+0x3a>
ffffffffc0201502:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201504:	85a6                	mv	a1,s1
ffffffffc0201506:	02000513          	li	a0,32
ffffffffc020150a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020150c:	fe0d94e3          	bnez	s11,ffffffffc02014f4 <vprintfmt+0x1ce>
ffffffffc0201510:	bd81                	j	ffffffffc0201360 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201512:	4705                	li	a4,1
ffffffffc0201514:	008a8593          	addi	a1,s5,8
ffffffffc0201518:	01074463          	blt	a4,a6,ffffffffc0201520 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020151c:	12080063          	beqz	a6,ffffffffc020163c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201520:	000ab603          	ld	a2,0(s5)
ffffffffc0201524:	46a9                	li	a3,10
ffffffffc0201526:	8aae                	mv	s5,a1
ffffffffc0201528:	b7bd                	j	ffffffffc0201496 <vprintfmt+0x170>
ffffffffc020152a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020152e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201532:	846a                	mv	s0,s10
ffffffffc0201534:	b5ad                	j	ffffffffc020139e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201536:	85a6                	mv	a1,s1
ffffffffc0201538:	02500513          	li	a0,37
ffffffffc020153c:	9902                	jalr	s2
            break;
ffffffffc020153e:	b50d                	j	ffffffffc0201360 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201540:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201544:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201548:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020154a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020154c:	e40dd9e3          	bgez	s11,ffffffffc020139e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201550:	8de6                	mv	s11,s9
ffffffffc0201552:	5cfd                	li	s9,-1
ffffffffc0201554:	b5a9                	j	ffffffffc020139e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201556:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020155a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020155e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201560:	bd3d                	j	ffffffffc020139e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201562:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201566:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020156a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020156c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201570:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201574:	fcd56ce3          	bltu	a0,a3,ffffffffc020154c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201578:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020157a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020157e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201582:	0196873b          	addw	a4,a3,s9
ffffffffc0201586:	0017171b          	slliw	a4,a4,0x1
ffffffffc020158a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020158e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201592:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201596:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020159a:	fcd57fe3          	bleu	a3,a0,ffffffffc0201578 <vprintfmt+0x252>
ffffffffc020159e:	b77d                	j	ffffffffc020154c <vprintfmt+0x226>
            if (width < 0)
ffffffffc02015a0:	fffdc693          	not	a3,s11
ffffffffc02015a4:	96fd                	srai	a3,a3,0x3f
ffffffffc02015a6:	00ddfdb3          	and	s11,s11,a3
ffffffffc02015aa:	00144603          	lbu	a2,1(s0)
ffffffffc02015ae:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b0:	846a                	mv	s0,s10
ffffffffc02015b2:	b3f5                	j	ffffffffc020139e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02015b4:	85a6                	mv	a1,s1
ffffffffc02015b6:	02500513          	li	a0,37
ffffffffc02015ba:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015bc:	fff44703          	lbu	a4,-1(s0)
ffffffffc02015c0:	02500793          	li	a5,37
ffffffffc02015c4:	8d22                	mv	s10,s0
ffffffffc02015c6:	d8f70de3          	beq	a4,a5,ffffffffc0201360 <vprintfmt+0x3a>
ffffffffc02015ca:	02500713          	li	a4,37
ffffffffc02015ce:	1d7d                	addi	s10,s10,-1
ffffffffc02015d0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02015d4:	fee79de3          	bne	a5,a4,ffffffffc02015ce <vprintfmt+0x2a8>
ffffffffc02015d8:	b361                	j	ffffffffc0201360 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015da:	00001617          	auipc	a2,0x1
ffffffffc02015de:	eee60613          	addi	a2,a2,-274 # ffffffffc02024c8 <error_string+0xd8>
ffffffffc02015e2:	85a6                	mv	a1,s1
ffffffffc02015e4:	854a                	mv	a0,s2
ffffffffc02015e6:	0ac000ef          	jal	ra,ffffffffc0201692 <printfmt>
ffffffffc02015ea:	bb9d                	j	ffffffffc0201360 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02015ec:	00001617          	auipc	a2,0x1
ffffffffc02015f0:	ed460613          	addi	a2,a2,-300 # ffffffffc02024c0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02015f4:	00001417          	auipc	s0,0x1
ffffffffc02015f8:	ecd40413          	addi	s0,s0,-307 # ffffffffc02024c1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015fc:	8532                	mv	a0,a2
ffffffffc02015fe:	85e6                	mv	a1,s9
ffffffffc0201600:	e032                	sd	a2,0(sp)
ffffffffc0201602:	e43e                	sd	a5,8(sp)
ffffffffc0201604:	1c2000ef          	jal	ra,ffffffffc02017c6 <strnlen>
ffffffffc0201608:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020160c:	6602                	ld	a2,0(sp)
ffffffffc020160e:	01b05d63          	blez	s11,ffffffffc0201628 <vprintfmt+0x302>
ffffffffc0201612:	67a2                	ld	a5,8(sp)
ffffffffc0201614:	2781                	sext.w	a5,a5
ffffffffc0201616:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201618:	6522                	ld	a0,8(sp)
ffffffffc020161a:	85a6                	mv	a1,s1
ffffffffc020161c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020161e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201620:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201622:	6602                	ld	a2,0(sp)
ffffffffc0201624:	fe0d9ae3          	bnez	s11,ffffffffc0201618 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201628:	00064783          	lbu	a5,0(a2)
ffffffffc020162c:	0007851b          	sext.w	a0,a5
ffffffffc0201630:	e8051be3          	bnez	a0,ffffffffc02014c6 <vprintfmt+0x1a0>
ffffffffc0201634:	b335                	j	ffffffffc0201360 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201636:	000aa403          	lw	s0,0(s5)
ffffffffc020163a:	bbf1                	j	ffffffffc0201416 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020163c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201640:	46a9                	li	a3,10
ffffffffc0201642:	8aae                	mv	s5,a1
ffffffffc0201644:	bd89                	j	ffffffffc0201496 <vprintfmt+0x170>
ffffffffc0201646:	000ae603          	lwu	a2,0(s5)
ffffffffc020164a:	46c1                	li	a3,16
ffffffffc020164c:	8aae                	mv	s5,a1
ffffffffc020164e:	b5a1                	j	ffffffffc0201496 <vprintfmt+0x170>
ffffffffc0201650:	000ae603          	lwu	a2,0(s5)
ffffffffc0201654:	46a1                	li	a3,8
ffffffffc0201656:	8aae                	mv	s5,a1
ffffffffc0201658:	bd3d                	j	ffffffffc0201496 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020165a:	9902                	jalr	s2
ffffffffc020165c:	b559                	j	ffffffffc02014e2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020165e:	85a6                	mv	a1,s1
ffffffffc0201660:	02d00513          	li	a0,45
ffffffffc0201664:	e03e                	sd	a5,0(sp)
ffffffffc0201666:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201668:	8ace                	mv	s5,s3
ffffffffc020166a:	40800633          	neg	a2,s0
ffffffffc020166e:	46a9                	li	a3,10
ffffffffc0201670:	6782                	ld	a5,0(sp)
ffffffffc0201672:	b515                	j	ffffffffc0201496 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201674:	01b05663          	blez	s11,ffffffffc0201680 <vprintfmt+0x35a>
ffffffffc0201678:	02d00693          	li	a3,45
ffffffffc020167c:	f6d798e3          	bne	a5,a3,ffffffffc02015ec <vprintfmt+0x2c6>
ffffffffc0201680:	00001417          	auipc	s0,0x1
ffffffffc0201684:	e4140413          	addi	s0,s0,-447 # ffffffffc02024c1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201688:	02800513          	li	a0,40
ffffffffc020168c:	02800793          	li	a5,40
ffffffffc0201690:	bd1d                	j	ffffffffc02014c6 <vprintfmt+0x1a0>

ffffffffc0201692 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201692:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201694:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201698:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020169a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020169c:	ec06                	sd	ra,24(sp)
ffffffffc020169e:	f83a                	sd	a4,48(sp)
ffffffffc02016a0:	fc3e                	sd	a5,56(sp)
ffffffffc02016a2:	e0c2                	sd	a6,64(sp)
ffffffffc02016a4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016a6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016a8:	c7fff0ef          	jal	ra,ffffffffc0201326 <vprintfmt>
}
ffffffffc02016ac:	60e2                	ld	ra,24(sp)
ffffffffc02016ae:	6161                	addi	sp,sp,80
ffffffffc02016b0:	8082                	ret

ffffffffc02016b2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02016b2:	715d                	addi	sp,sp,-80
ffffffffc02016b4:	e486                	sd	ra,72(sp)
ffffffffc02016b6:	e0a2                	sd	s0,64(sp)
ffffffffc02016b8:	fc26                	sd	s1,56(sp)
ffffffffc02016ba:	f84a                	sd	s2,48(sp)
ffffffffc02016bc:	f44e                	sd	s3,40(sp)
ffffffffc02016be:	f052                	sd	s4,32(sp)
ffffffffc02016c0:	ec56                	sd	s5,24(sp)
ffffffffc02016c2:	e85a                	sd	s6,16(sp)
ffffffffc02016c4:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02016c6:	c901                	beqz	a0,ffffffffc02016d6 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02016c8:	85aa                	mv	a1,a0
ffffffffc02016ca:	00001517          	auipc	a0,0x1
ffffffffc02016ce:	e0e50513          	addi	a0,a0,-498 # ffffffffc02024d8 <error_string+0xe8>
ffffffffc02016d2:	9e5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02016d6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016d8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02016da:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02016dc:	4aa9                	li	s5,10
ffffffffc02016de:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02016e0:	00005b97          	auipc	s7,0x5
ffffffffc02016e4:	930b8b93          	addi	s7,s7,-1744 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016e8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02016ec:	a43fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02016f0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02016f2:	00054b63          	bltz	a0,ffffffffc0201708 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016f6:	00a95b63          	ble	a0,s2,ffffffffc020170c <readline+0x5a>
ffffffffc02016fa:	029a5463          	ble	s1,s4,ffffffffc0201722 <readline+0x70>
        c = getchar();
ffffffffc02016fe:	a31fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201702:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201704:	fe0559e3          	bgez	a0,ffffffffc02016f6 <readline+0x44>
            return NULL;
ffffffffc0201708:	4501                	li	a0,0
ffffffffc020170a:	a099                	j	ffffffffc0201750 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020170c:	03341463          	bne	s0,s3,ffffffffc0201734 <readline+0x82>
ffffffffc0201710:	e8b9                	bnez	s1,ffffffffc0201766 <readline+0xb4>
        c = getchar();
ffffffffc0201712:	a1dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201716:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201718:	fe0548e3          	bltz	a0,ffffffffc0201708 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020171c:	fea958e3          	ble	a0,s2,ffffffffc020170c <readline+0x5a>
ffffffffc0201720:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201722:	8522                	mv	a0,s0
ffffffffc0201724:	9c7fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201728:	009b87b3          	add	a5,s7,s1
ffffffffc020172c:	00878023          	sb	s0,0(a5)
ffffffffc0201730:	2485                	addiw	s1,s1,1
ffffffffc0201732:	bf6d                	j	ffffffffc02016ec <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201734:	01540463          	beq	s0,s5,ffffffffc020173c <readline+0x8a>
ffffffffc0201738:	fb641ae3          	bne	s0,s6,ffffffffc02016ec <readline+0x3a>
            cputchar(c);
ffffffffc020173c:	8522                	mv	a0,s0
ffffffffc020173e:	9adfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201742:	00005517          	auipc	a0,0x5
ffffffffc0201746:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0206010 <edata>
ffffffffc020174a:	94aa                	add	s1,s1,a0
ffffffffc020174c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201750:	60a6                	ld	ra,72(sp)
ffffffffc0201752:	6406                	ld	s0,64(sp)
ffffffffc0201754:	74e2                	ld	s1,56(sp)
ffffffffc0201756:	7942                	ld	s2,48(sp)
ffffffffc0201758:	79a2                	ld	s3,40(sp)
ffffffffc020175a:	7a02                	ld	s4,32(sp)
ffffffffc020175c:	6ae2                	ld	s5,24(sp)
ffffffffc020175e:	6b42                	ld	s6,16(sp)
ffffffffc0201760:	6ba2                	ld	s7,8(sp)
ffffffffc0201762:	6161                	addi	sp,sp,80
ffffffffc0201764:	8082                	ret
            cputchar(c);
ffffffffc0201766:	4521                	li	a0,8
ffffffffc0201768:	983fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020176c:	34fd                	addiw	s1,s1,-1
ffffffffc020176e:	bfbd                	j	ffffffffc02016ec <readline+0x3a>

ffffffffc0201770 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201770:	00005797          	auipc	a5,0x5
ffffffffc0201774:	89878793          	addi	a5,a5,-1896 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201778:	6398                	ld	a4,0(a5)
ffffffffc020177a:	4781                	li	a5,0
ffffffffc020177c:	88ba                	mv	a7,a4
ffffffffc020177e:	852a                	mv	a0,a0
ffffffffc0201780:	85be                	mv	a1,a5
ffffffffc0201782:	863e                	mv	a2,a5
ffffffffc0201784:	00000073          	ecall
ffffffffc0201788:	87aa                	mv	a5,a0
}
ffffffffc020178a:	8082                	ret

ffffffffc020178c <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020178c:	00005797          	auipc	a5,0x5
ffffffffc0201790:	c9c78793          	addi	a5,a5,-868 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201794:	6398                	ld	a4,0(a5)
ffffffffc0201796:	4781                	li	a5,0
ffffffffc0201798:	88ba                	mv	a7,a4
ffffffffc020179a:	852a                	mv	a0,a0
ffffffffc020179c:	85be                	mv	a1,a5
ffffffffc020179e:	863e                	mv	a2,a5
ffffffffc02017a0:	00000073          	ecall
ffffffffc02017a4:	87aa                	mv	a5,a0
}
ffffffffc02017a6:	8082                	ret

ffffffffc02017a8 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02017a8:	00005797          	auipc	a5,0x5
ffffffffc02017ac:	85878793          	addi	a5,a5,-1960 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02017b0:	639c                	ld	a5,0(a5)
ffffffffc02017b2:	4501                	li	a0,0
ffffffffc02017b4:	88be                	mv	a7,a5
ffffffffc02017b6:	852a                	mv	a0,a0
ffffffffc02017b8:	85aa                	mv	a1,a0
ffffffffc02017ba:	862a                	mv	a2,a0
ffffffffc02017bc:	00000073          	ecall
ffffffffc02017c0:	852a                	mv	a0,a0
ffffffffc02017c2:	2501                	sext.w	a0,a0
ffffffffc02017c4:	8082                	ret

ffffffffc02017c6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017c6:	c185                	beqz	a1,ffffffffc02017e6 <strnlen+0x20>
ffffffffc02017c8:	00054783          	lbu	a5,0(a0)
ffffffffc02017cc:	cf89                	beqz	a5,ffffffffc02017e6 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02017ce:	4781                	li	a5,0
ffffffffc02017d0:	a021                	j	ffffffffc02017d8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017d2:	00074703          	lbu	a4,0(a4)
ffffffffc02017d6:	c711                	beqz	a4,ffffffffc02017e2 <strnlen+0x1c>
        cnt ++;
ffffffffc02017d8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017da:	00f50733          	add	a4,a0,a5
ffffffffc02017de:	fef59ae3          	bne	a1,a5,ffffffffc02017d2 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02017e2:	853e                	mv	a0,a5
ffffffffc02017e4:	8082                	ret
    size_t cnt = 0;
ffffffffc02017e6:	4781                	li	a5,0
}
ffffffffc02017e8:	853e                	mv	a0,a5
ffffffffc02017ea:	8082                	ret

ffffffffc02017ec <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017ec:	00054783          	lbu	a5,0(a0)
ffffffffc02017f0:	0005c703          	lbu	a4,0(a1)
ffffffffc02017f4:	cb91                	beqz	a5,ffffffffc0201808 <strcmp+0x1c>
ffffffffc02017f6:	00e79c63          	bne	a5,a4,ffffffffc020180e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02017fa:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017fc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201800:	0585                	addi	a1,a1,1
ffffffffc0201802:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201806:	fbe5                	bnez	a5,ffffffffc02017f6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201808:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020180a:	9d19                	subw	a0,a0,a4
ffffffffc020180c:	8082                	ret
ffffffffc020180e:	0007851b          	sext.w	a0,a5
ffffffffc0201812:	9d19                	subw	a0,a0,a4
ffffffffc0201814:	8082                	ret

ffffffffc0201816 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201816:	00054783          	lbu	a5,0(a0)
ffffffffc020181a:	cb91                	beqz	a5,ffffffffc020182e <strchr+0x18>
        if (*s == c) {
ffffffffc020181c:	00b79563          	bne	a5,a1,ffffffffc0201826 <strchr+0x10>
ffffffffc0201820:	a809                	j	ffffffffc0201832 <strchr+0x1c>
ffffffffc0201822:	00b78763          	beq	a5,a1,ffffffffc0201830 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201826:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201828:	00054783          	lbu	a5,0(a0)
ffffffffc020182c:	fbfd                	bnez	a5,ffffffffc0201822 <strchr+0xc>
    }
    return NULL;
ffffffffc020182e:	4501                	li	a0,0
}
ffffffffc0201830:	8082                	ret
ffffffffc0201832:	8082                	ret

ffffffffc0201834 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201834:	ca01                	beqz	a2,ffffffffc0201844 <memset+0x10>
ffffffffc0201836:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201838:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020183a:	0785                	addi	a5,a5,1
ffffffffc020183c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201840:	fec79de3          	bne	a5,a2,ffffffffc020183a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201844:	8082                	ret
