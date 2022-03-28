#include <segmentation.h>

GateDescriptor idt[IDT_SIZE];

void only_handler()
{
	
}

void idt_init()
{
	for (int i = 0; i < 32; ++i) {
		idt[i].set_handler(TYPE_INTERRUPT_GATE, only_handler);
	}
}
