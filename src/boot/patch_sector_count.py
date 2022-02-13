# The bootloader needs to know how many sectors it needs to read from disk into
# memory.
# The bootloader needs to load the initial page tables and the entire kernel
# image. This script computes the number of disk sectors that the initial page
# tables and the kernel together occupy. It inserts that number into section
# .sector_count of the bootloader (which consists of only a 2-byte counter).
#
# WARNING: We assume the bootloader and kernel have already been build.

import os

sector_size = 512
page_table_size = 4096

no_page_tables = 3 # PML4, PTDP, PTD
page_tables_sector_count = no_page_tables * page_table_size // sector_size

kernel_size = os.path.getsize("build/kernel/kernel.img")
kernel_sector_count = (kernel_size + 512 - 1) // 512

sector_count = page_tables_sector_count + kernel_sector_count

with open("build/boot/boot.img", "r+b") as bootloader:
	bootloader.seek(512-4)
	bootloader.write(sector_count.to_bytes(2, "little"))
