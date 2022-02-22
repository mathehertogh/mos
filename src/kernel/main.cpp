#include <types.h>

int y = 5;

int kernel_main(uint16_t boot_drive_number, char *mmap) __attribute__((section (".entry")));

int kernel_main(uint16_t boot_drive_number, char *mmap) {
	int x;

	x = 7;

	x += (int)boot_drive_number;
	x *= y;

	while(true);

	return 0;
}
