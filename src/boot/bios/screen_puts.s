.code16
.section .text

/* screen_puts - Write a string to the screen
 *
 * Clears the screen to yellow and writes a string in red to the middle of the
 * screen.
 *
 * INPUT:
 *   ax - string to print
 *   bx - string length
 */
 .global screen_puts
screen_puts:
    push %bp
    push %ax
    push %bx

    /* First clear the screen and make it yellow.
     * http://www.ctyme.com/intr/rb-0097.htm
     */
    movw $0x0700, %ax
    movb $0xee, %bh
    movw $0x0, %cx
    movw $0xffff, %dx
    int $0x10

    /* Write the string to the screen using EGA.
     * http://www.ctyme.com/intr/rb-0210.htm
     * https://en.wikipedia.org/wiki/INT_10H
     * https://en.wikipedia.org/wiki/Enhanced_Graphics_Adapter
     */
    movw $0x1300, %ax  /* ah: choose "write string" function
                        * al: write mode */
    movw $0x00e4, %bx  /* bh: page number
                        * bl: color (bits 0-3 character, bits 4-7 background) */
    pop %cx            /* cx: length of the string */
    movw $0x0c1b, %dx  /* dh: row
                        * dl: column */
    pop %bp            /* es:bp: pointer to string */
    int $0x10

    pop %bp
    ret
