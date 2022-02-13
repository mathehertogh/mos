.code16
.section .text

CR0_PROTECTION_ENABLED = 1 << 0
CODE_SELECTOR = 0x8
DATA_SELECTOR = 0x10

/* long_mode_activate
 *
 * Switch from protected mode to 64-bit long mode.
 *
 * REFERENCES:
 *   AMD system manual 14.4
 *   Intel system manual 9.9.1
 */
.global long_mode_activate
long_mode_activate:
	
	ret


