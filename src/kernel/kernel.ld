OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    /* Let us load the kernel at 0x7d00, right after the bootloader.
     */
    . = 0x7d00;
    .kernel : AT(ADDR(.kernel)) {
        *(.entry)
        *(.text)
        *(.data)
    }

    /DISCARD/ :
    {
        *(*)
    }
}
