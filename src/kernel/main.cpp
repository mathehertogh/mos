#include <types.h>
#include <segmentation.h>
#include <console.h>

int y = 0;

typedef void(*global_constructor)(void);
extern "C" global_constructor ctors;

int kernel_main(uint16_t boot_drive_number, char *mmap) __attribute__((section (".entry")));

void call_global_constructors()
{
	global_constructor *ctor = &ctors;
	while (*ctor) {
		(*ctor)();
		++ctor;
	}
}

int kernel_main(uint16_t boot_drive_number, char *mmap)
{
	// TODO initialize .bss section with zeros?
	call_global_constructors();
	console.print("9X7 dubies!\n");

	gdt_init();
	idt_init();
	y = 7777 / y;

	console.print("na idt_init()\n");

	while(true);

	return 0;
}
