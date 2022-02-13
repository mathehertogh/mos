OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    . = 0xb000;
    .text : AT(ADDR(.text)) {
        *(.entry)
        *(.text)
    }

    .data ALIGN(4K) : ALIGN(4K) {
        *(.data)
    }

    .rodata ALIGN(4K) : ALIGN(4K) {
        *(.rodata)
    }

    /DISCARD/ :
    {
        *(*)
    }
}
