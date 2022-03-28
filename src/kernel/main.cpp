#include <types.h>
#include <segmentation.h>
#include <device/serial_port.h>

int y = 5;

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

	// TODO fix far jump in set_cs() and uncomment gdt_init().
	// gdt_init();

	SerialPort sp(COM1_PORT);
	sp.send("hallo hallo mathe hier\n");

	while(true);

	return 0;
}
