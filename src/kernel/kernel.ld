SECTIONS
{
    . = 0xb000;
    .text : AT(ADDR(.text)) {
        *(.entry)
        *(.text)
    }

    .data ALIGN(4K) : ALIGN(4K) {
        *(.bss)
    }

    .data ALIGN(4K) : ALIGN(4K) {
        *(.data)
    }

    .rodata ALIGN(4K) : ALIGN(4K) {
        *(.rodata)
    }

    .ctors : AT(ADDR(.ctors)) {
        ctors = .;
        *(.ctors)
    }

    /*
     * /DISCARD/ :
     * {
     *     *(*)
     * }
     */
}
