.code16
.section .text

/* nmi_enable
 *
 * Disable Non-Maskable Interrupts.
 *
 * REFERENCES:
 *   https://wiki.osdev.org/CMOS#Non-Maskable_Interrupts
 *   https://wiki.osdev.org/NMI
 */
.global nmi_enable
nmi_enable:
	in $0x70, %al
	btr $7, %ax
	out %al, $0x70
	in $0x71, %al
    ret

/* nmi_disable
 *
 * Disable Non-Maskable Interrupts.
 *
 * REFERENCES:
 *   https://wiki.osdev.org/CMOS#Non-Maskable_Interrupts
 *   https://wiki.osdev.org/NMI
 */
.global nmi_disable
nmi_disable:
	in $0x70, %al
	bts $7, %ax
	out %al, $0x70
	in $0x71, %al
    ret
