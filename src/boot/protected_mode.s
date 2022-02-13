.code16
.section .text

CR0_PROTECTION_ENABLED = 1 << 0
CODE_SELECTOR = 0x8
DATA_SELECTOR = 0x10

/* protected_mode_activate
 *
 * Switch from real mode to protected mode.
 *
 * WARNING: Does _not_ set up an IDT and the corresponding interrupt handlers
 *          properly. Interrupts are assumed to be disabled completely. Switch
 *          to long mode and set up interrupts there before re-enabling them.
 *
 * REFERENCES:
 *   AMD system manual 14.4
 *   Intel system manual 9.9.1
 */
.global protected_mode_activate
protected_mode_activate:
	lgdt (gdtr)

	mov %cr0, %eax
	or $CR0_PROTECTION_ENABLED, %eax
	mov %eax, %cr0

	ljmp $CODE_SELECTOR, $1f
1:
	movw $DATA_SELECTOR, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss

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
CODE            = 0x1 << 3
DATA			= 0x0 << 3
USER_TYPE       = 0x1 << 4
USER_PRIVILEDGE = 0x3 << 5
PRESENT         = 0x1 << 7
MAX_LIMIT       = 0xf << 8
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
