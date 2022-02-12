
run: mos
	qemu-system-i386 -machine q35 -drive format=raw,file=build/mos.img -serial mon:stdio

debug: mos
	qemu-system-i386 -machine q35 -drive format=raw,file=build/mos.img -serial mon:stdio -nographic -S -gdb tcp::1234

mos: boot kernel
	cat build/boot/boot.img build/kernel/kernel.img > build/mos.img
	truncate -s 5M build/mos.img

boot: build_dirs src/boot/boot.s src/boot/boot.ld
	x86_64-elf-g++ -o build/boot/boot.o -nostdlib -c -m32 src/boot/boot.s
	x86_64-elf-g++ -o build/boot/bios/screen_puts.o -nostdlib -c -m32 src/boot/bios/screen_puts.s
	x86_64-elf-g++ -o build/boot/bios/disk_read.o -nostdlib -c -m32 src/boot/bios/disk_read.s
	x86_64-elf-ld -o build/boot/boot.elf --script src/boot/boot.ld -N -m32 -melf_i386 -static build/boot/boot.o build/boot/bios/screen_puts.o build/boot/bios/disk_read.o
	objcopy -O binary build/boot/boot.elf build/boot/boot.img

kernel: src/kernel/kernel.ld src/kernel/main.cpp
	x86_64-elf-g++ -o build/kernel/main.o -nostdlib -static -fno-common -fno-exceptions -fno-non-call-exceptions -fno-weak -fno-rtti -m32 -c src/kernel/main.cpp
	x86_64-elf-ld -o build/kernel/kernel.elf --script src/kernel/kernel.ld -N -m32 -melf_i386 -static build/kernel/main.o
	objcopy -O binary build/kernel/kernel.elf build/kernel/kernel.img

build_dirs:
	mkdir -p build/boot/bios
	mkdir -p build/kernel

clean:
	-rm -r ./build

.PHONY: mos boot kernel build_dirs clean

