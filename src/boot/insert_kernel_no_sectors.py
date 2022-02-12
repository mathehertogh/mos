# The bootloader needs to know the size of the kernel image in order to load it
# from disk into memory.
# We assume the bootloader and kernel have already been build.
# This script looks up the size of the kernel image, computes the number of disk
# sectors the image occupies, and inserts that number into section
# .kernel_no_sectors of the bootloader.

import os
kernel_size = os.path.getsize("build/kernel/kernel.img")
kernel_no_sectors = (kernel_size + 512 - 1) // 512

with open("build/boot/boot.img", "r+b") as bootloader:
	bootloader.seek(512-4)
	bootloader.write(kernel_no_sectors.to_bytes(2, "little"))
