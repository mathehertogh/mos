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
