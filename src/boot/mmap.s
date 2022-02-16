.code16
.section .text

MMAP_ENTRY_SIZE = 0x18

/* mmap_get
 *
 * Obtain the BIOS provided memory map.
 *
 * REFERENCE:
 *   https://wiki.osdev.org/Detecting_Memory_(x86)#BIOS_Function:_INT_0x15.2C_EAX_.3D_0xE820
 *
 * INPUT:
 *   ax - buffer to store the memory map
 *
 * OUTPUT:
 *   ax - number of entries in the memory map
 */
.global mmap_get
mmap_get:
	push %di
	push %ax

	movl $0, %ebx
	movl $0x534d4150, %edx
	movw %ax, %di
1:
	movw $0xe820, %ax
	movl $MMAP_ENTRY_SIZE, %ecx
	int $0x15

	jc .error
	add $MMAP_ENTRY_SIZE, %di

	test %ebx, %ebx
	jne 1b

	/* Compute the number of entries in the memory map.
	 */
	movw %di, %ax
	pop %bx
	sub %bx, %ax
	movb $MMAP_ENTRY_SIZE, %cl
	div %cl

	pop %di
	ret

.error:
	movw $mmap_error_msg, %ax
	movw $mmap_error_msg_len, %bx
	call screen_puts
	hlt



.section .data

mmap_error_msg:
    .ascii "Fatal error: failed to obtain memory map"
    mmap_error_msg_len = . - mmap_error_msg
