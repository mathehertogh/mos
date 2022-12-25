#include <segmentation.h>
#include <console.h>

GateDescriptor idt[IDT_SIZE];

/* Load the Interrupt Descriptor Table Register.
 */
void lidt(DescriptorTableRegister *idtr)
{
	__asm__ __volatile__ ("lidt (%0)\n" : : "r"(idtr) : );
}

void only_handler()
{
	console.print("only_handler() called; starting infinite loop\n");
	while(1);
}

void idt_init()
{
	for (int i = 0; i < IDT_SIZE; ++i) {
		idt[i].set_handler(TYPE_INTERRUPT_GATE, only_handler);
	}

	DescriptorTableRegister idtr = {
		.limit = IDT_SIZE * sizeof(GateDescriptor),
		.base = (uint64_t)&idt
	};
	lidt(&idtr);
}
