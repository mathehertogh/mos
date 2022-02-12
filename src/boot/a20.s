.code16
.section .text

/* a20_enable
 *
 * Enable the a20 line, allowing us to use memory above 1MiB.
 *
 * REFERENCE:
 *   https://wiki.osdev.org/A20_Line
 */
.global a20_enable
a20_enable:

	movw $0x2401, %ax
	int $0x15

	jc .error

	ret

.error:
	movw $a20_error_msg, %ax
	movw $a20_error_msg_len, %bx
	call screen_puts
	hlt

.section .data
a20_error_msg:
    .ascii "Fatal error: failed to enable the A20-line"
    a20_error_msg_len = . - a20_error_msg
