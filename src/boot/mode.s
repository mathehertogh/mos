.code16
.section .text

CR0_PROTECTED_MODE_ENABLE = 1 << 0
CR0_PAGING_ENABLE = 1 << 31
CR4_PHYSICAL_ADDRESS_EXTENSION = 1 << 5
EFER_LONG_MODE_ENABLE = 1 << 8
MSR_EFER = 0xC0000080
CODE_SELECTOR = 0x8
DATA_SELECTOR = 0x10

/* protected_mode_activate
 *
 * Switch from real mode to protected mode. Interrupts (including NMIs) should
 * be disabled.
 *
 * WARNING: IDT and interrupt handlers are _not_ set up.
 *
 * REFERENCES:
 *   AMD system manual 14.4
 *   Intel system manual 9.9.1
 */
.global protected_mode_activate
protected_mode_activate:
	lgdt (gdtr)

	movl %cr0, %eax
	orl $CR0_PROTECTED_MODE_ENABLE, %eax
	movl %eax, %cr0

	ljmp $CODE_SELECTOR, $1f
1:
	movw $DATA_SELECTOR, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss

	ret


/* long_mode_activate
 *
 * Switch from protected mode to 64-bit long mode.
 *
 * REFERENCES:
 *   AMD system manual 14.4
 *   Intel system manual 9.9.1
 */
.global long_mode_activate
long_mode_activate:
	/* Enable physical address extensions.
	 */
	movl %cr4, %eax
	orl $CR4_PHYSICAL_ADDRESS_EXTENSION, %eax
	movl %eax, %cr4

	/* Load the root of our initial page tables into CR3.
	 */
	movl $pml4, %eax
	movl %eax, %cr3
	
	/* Enable long mode.
	 */
	movl $MSR_EFER, %ecx
	rdmsr
	orl $EFER_LONG_MODE_ENABLE, %eax
	wrmsr

	/* Activate long mode by enabling paging.
	 */
	movl %cr0, %eax
	orl $CR0_PAGING_ENABLE, %eax
	movl %eax, %cr0

	/* Far jump to (re-)load the code segment. This jump is required by the
	 * hardware. Note that we use the same code segment as before. The L-bit
	 * (LONG_16BIT_MODE) was already set, but as that bit is reserverd in
	 * protected mode, it was ignored until now. Now that we activated long mode
	 * the L-bit signifies that we run in 16-bit mode (as oposed to
	 * compatibility mode).
	 */
	ljmp $CODE_SELECTOR, $1f
1:
	ret


.section .data

/* Attributes of segment descriptors.
 * See e.g. AMD systems manual 4.7 for details.
 */
ACCESSED        = 0x1 << 0
READABLE        = 0x1 << 1 /* for code descriptors */
WRITABLE        = 0x1 << 1 /* for data descriptors */
CONFORMING      = 0x1 << 2 /* for code descriptors */
EXPAND_DOWN     = 0x1 << 2 /* for data descriptors */
CODE            = 0x1 << 3 /* requires user type */
DATA			= 0x0 << 3 /* requires user type */
USER_TYPE       = 0x1 << 4
USER_PRIVILEDGE = 0x3 << 5
PRESENT         = 0x1 << 7
MAX_LIMIT       = 0xf << 8
LONG_64BIT_MODE = 0x1 << 13 /* only interpreted in long mode */
OPSIZE_32BIT    = 0x1 << 14
PAGE_GRANULAR   = 0x1 << 15

gdt:
	null:
		.8byte 0
	code:
		.2byte 0xffff /* limit */
		.2byte 0x0    /* base */
		.byte 0x0     /* base */
		.2byte READABLE | CODE | USER_TYPE | PRESENT | MAX_LIMIT
		.byte 0x0     /* base */
	data:
		.2byte 0xffff /* limit */
		.2byte 0x0    /* base */
		.byte 0x0     /* base */
		.2byte WRITABLE | DATA | USER_TYPE | PRESENT | MAX_LIMIT
		.byte 0x0     /* base */

gdtr:
	.2byte 0x18 /* limit */
	.4byte gdt  /* base */
