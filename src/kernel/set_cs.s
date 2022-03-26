/*
.global set_cs
set_cs:
	pushw (%rdi)
	ljmp (%rsp)
*/

.global set_cs
set_cs:
	sub $6, %rsp
	movw (%rdi), %ax
	movw %ax, (%rsp)
	movq $1f, %rax
	mov %eax, 2(%rsp)
	ljmp *(%rsp)
1:
	nop
	add $6, %rsp
	ret
