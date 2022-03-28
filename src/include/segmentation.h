#pragma once

#include <types.h>

class SegmentSelector
{
public:
	SegmentSelector(uint8_t rpl, uint8_t ti, uint16_t index);

	uint16_t get_index();

private:
	uint16_t rpl   :  2; // Requestor Priviledge Level
	uint16_t ti    :  1; // Table Indicator
	uint16_t zero  :  1; // We use 16-byte descriptors, so this bit is zero
	uint16_t index : 12; // Selector Index
};

struct DescriptorTableRegister
{
	uint16_t limit;
	uint64_t base;
};

enum class SegmentType
{
	null,
	kernel_code,
	user_code,
	data,
	task_state
};

class SystemDescriptor
{
public:
	void set_type(const SegmentType st);
	void set_base(uint64_t base);
	void set_limit(uint32_t limit);

private:
	uint16_t limit1           = 0;
	uint16_t base1            = 0;
	uint8_t  base2            = 0;
	uint8_t  type         : 4 = 0;
	uint8_t  system       : 1 = 0;
	uint8_t  dpl          : 2 = 0; // Descriptor Privilege Level
	uint8_t  present      : 1 = 0;
	uint8_t  limit2       : 4 = 0;
	uint8_t  avl          : 1 = 0; // Available to software; we don't use it
	uint8_t  long_mode    : 1 = 1;
	uint8_t  operand_size : 1 = 0;
	uint8_t  granularity  : 1 = 0;
	uint8_t  base3            = 0;
	uint32_t base4            = 0;
	uint8_t  reserved1        = 0;
	uint8_t  zero         : 5 = 0;
	uint8_t  reserved2    : 3 = 0;
	uint16_t reserved3        = 0;
};

constexpr size_t GDT_SIZE = 5;
extern SystemDescriptor gdt[GDT_SIZE]; // Global Descriptor Table

extern SegmentSelector null_selector;
extern SegmentSelector kernel_code_selector;
extern SegmentSelector user_code_selector;
extern SegmentSelector data_selector;
extern SegmentSelector task_state_selector;

/* Initialize the Global Offset Table.
 */
void gdt_init();

#define TYPE_INTERRUPT_GATE 0xe
#define TYPE_TRAP_GATE      0xf

typedef void (*interrupt_handler)(void);

class GateDescriptor
{
public:
	void set_handler(uint8_t type, interrupt_handler handler);

private:
	// The offset fields together hold the address of the interrupt handler.
	uint16_t offset1       = 0;
	uint16_t selector      = 0; // code segment selector
	uint16_t ist       : 3 = 0; // Interrupt Stack Table
	uint16_t reserved1 : 5 = 0;
	uint16_t type      : 4 = 0;
	uint16_t reserved2 : 1 = 0;
	uint16_t dpl       : 3 = 0; // Descriptor Priviledge Level
	uint16_t present   : 1 = 0;
	uint16_t offset2       = 0;
	uint32_t offset3       = 0;
};

constexpr size_t IDT_SIZE = 5;
extern GateDescriptor idt[IDT_SIZE]; // Interrupt Descriptor Table

/* Initialize the Interrupt Descriptor Table.
 */
void idt_init();
