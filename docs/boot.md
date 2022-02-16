Memory layout
=============
The physical memory after boot up looks as follows:

:     ...     :
|-------------|
|   kernel    |
|-------------| 0xb000
| page tables |
|-------------| 0x8000
|             |
|-------------| 0x7e00
| bootloader  |
| ------------| 0x7c00
|    stack    |
:     ...     :
|-------------|
|             |
|-------------|
| memory map  |
|-------------| 0x500
:     ...     :

Bootloader overview
===================
The BIOS loads the first sector of the hard disk (containing the MOS image) into
region [0x7c00, 0x7e00) and jumps to 0x7c00.
This sector contains our bootloader, which starts executing.
The main body of the bootloader can be found in boot.s.

Our bootloader sets up its stack at (..., 0x7c00].
Then it prints a welcome message to the screen.
Next it retreives a physical memory map from the BIOS. This is a list of
uncertain size, which we put at 0x500.
Then the bootloader reads the rest of the MOS image from the disk and puts it at
0x8000.
The first 24 sectors (3 pages) contain our intial page tables.
Directly after the page tables, at 0xb000, we put our kernel image.

Then the bootloader starts setting up the CPU for running the kernel.
It enables the A20 line, allowing us to access memory above 1MiB.
Then it activates protected mode, after which it can activate (64-bit) long
mode.

Lastly, our bootloader jumps to the entry point of the kernel at 0xb000.

Calling conventions
===================
We use custom calling conventions in the bootloader code.
Functions may only clobber registers ax, bx, cx and dx.
Hence the caller is responsible for saving those.
Functions are responsible for preserving all other registers.
Parameters are passed as follows:
Parameter 1 - ax
Parameter 2 - bx
Parameter 3 - cx
Parameter 4 - dx
