#include "segmentation.h"

extern "C" void set_cs(SegmentSelector *sel);

void SystemDescriptor::set_type(SegmentType st)
{
	switch (st)
	{
		case SegmentType::null:
			type = 0;
			system = 0;
			dpl = 0;
			present = 0;
			operand_size = 0;
			granularity = 0;
			break;

		case SegmentType::kernel_code:
			type = 0b1100;    // code, conforming, ignored, ignored
			system = 1;       // user
			dpl = 0;          // kernel privilege
			present = 1;      // present
			operand_size = 0; // required in long mode
			break;

		case SegmentType::user_code:
			type = 0b1100;    // code, conforming, ignored, ignored
			system = 1;       // user
			dpl = 3;          // user privilege
			present = 1;      // present
			operand_size = 0; // required in long mode
			break;

		case SegmentType::data:
			type = 0b1000; // data, ignored, ignored, ignored
			system = 1;    // user
			present = 1;   // present
			break;

		case SegmentType::task_state:
			type = 0x9;      // available 64-bit TSS
			system = 0;      // system
			dpl = 0;         // kernel privilege
			present = 1;     // present
			granularity = 0; // byte granular
	}
}

void SystemDescriptor::set_base(uint64_t base)
{
	base1 = base & 0xffff;
	base2 = (base >> 16) & 0xff;
	base3 = (base >> 24) & 0xff;
	base4 = base >> 32;
}

void SystemDescriptor::set_limit(uint32_t limit)
{
	limit1 = limit & 0xffff;
	limit2 = (limit >> 16) & 0xf;
}

SegmentSelector::SegmentSelector(uint8_t rpl, uint8_t ti, uint16_t index)
	: rpl(rpl), ti(ti), zero(0), index(index) { }

uint16_t SegmentSelector::get_index()
{
	return index;
}

SystemDescriptor gdt[GDT_SIZE]; // Global Descriptor Table

SegmentSelector        null_selector(0, 0, 0);
SegmentSelector kernel_code_selector(0, 0, 1);
SegmentSelector   user_code_selector(3, 0, 2);
SegmentSelector        data_selector(0, 0, 3);
SegmentSelector  task_state_selector(0, 0, 4);

/* Load the Global Descriptor Table Register.
 */
void lgdt(DescriptorTableRegister *gdtr)
{
	__asm__ __volatile__ ("lgdt %0\n" : : "m"(gdtr) : );
}

// void set_cs(SegmentSelector *sel)
// {
// 	uint16_t *cs = (uint16_t *)sel;
// 	__asm__ __volatile__ ("ljmp $0x08,$boing\n\t"
// 	                      "boing:"
// 		                   : : "ax"(*cs) : );
// }

void gdt_init()
{
	gdt[       null_selector.get_index()].set_type(SegmentType::null);
	gdt[kernel_code_selector.get_index()].set_type(SegmentType::kernel_code);
	gdt[  user_code_selector.get_index()].set_type(SegmentType::user_code);
	gdt[       data_selector.get_index()].set_type(SegmentType::data);
	gdt[ task_state_selector.get_index()].set_type(SegmentType::task_state);

	DescriptorTableRegister gdtr = {
		.limit = GDT_SIZE * sizeof(SystemDescriptor),
		.base = (uint64_t)&gdt
	};
	//lgdt(&gdtr);

	set_cs(&kernel_code_selector);
	//set_ds,es,fs,gs,ss
}

void GateDescriptor::set_handler(uint8_t _type, interrupt_handler handler)
{
	uint64_t offset = (uint64_t)handler;
	offset1 = offset & 0xffff;
	offset2 = (offset >> 16) & 0xffff;
	offset3 = offset >> 32;

	selector = *(uint16_t *)&kernel_code_selector;
	type = _type;
	dpl = 3; // Gate must also be accessible from user space.
	present = 1;
}
