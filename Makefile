
CCFLAGS := -g -Og -nostdlib -static -fno-common -fno-exceptions -fno-non-call-exceptions -fno-weak -fno-rtti -Isrc/include -std=c++2a -mno-sse

run: mos
	qemu-system-x86_64 -machine q35 -drive format=raw,file=build/mos.img -serial mon:stdio -nographic

debug: mos
	qemu-system-x86_64 -machine q35 -drive format=raw,file=build/mos.img -serial mon:stdio -nographic -S -gdb tcp::1234 -d int -no-reboot

mos: kernel boot 
	cat build/boot/boot.img build/kernel/kernel.img > build/mos.img
	truncate -s 5M build/mos.img

boot: build_dirs kernel src/boot/boot.s src/boot/screen.s src/boot/disk.s src/boot/mmap.s src/boot/a20.s src/boot/boot.ld
	x86_64-elf-g++ -o build/boot/boot.o -nostdlib -c -m32 src/boot/boot.s
	x86_64-elf-g++ -o build/boot/screen.o -nostdlib -c -m32 src/boot/screen.s
	x86_64-elf-g++ -o build/boot/disk.o -nostdlib -c -m32 src/boot/disk.s
	x86_64-elf-g++ -o build/boot/mmap.o -nostdlib -c -m32 src/boot/mmap.s
	x86_64-elf-g++ -o build/boot/a20.o -nostdlib -c -m32 src/boot/a20.s
	x86_64-elf-g++ -o build/boot/nmi.o -nostdlib -c -m32 src/boot/nmi.s
	x86_64-elf-g++ -o build/boot/mode.o -nostdlib -c -m32 src/boot/mode.s
	x86_64-elf-ld -o build/boot/boot.elf --script src/boot/boot.ld -N -m32 -melf_i386 -static build/boot/boot.o build/boot/screen.o build/boot/disk.o build/boot/mmap.o build/boot/a20.o build/boot/nmi.o build/boot/mode.o
	objcopy -O binary build/boot/boot.elf build/boot/boot.img
	python3 src/boot/patch_sector_count.py

kernel: build_dirs src/kernel/kernel.ld src/kernel/main.cpp src/kernel/segmentation.cpp src/kernel/set_cs.s
	x86_64-elf-g++ -o build/kernel/main.o $(CCFLAGS) -c src/kernel/main.cpp
	x86_64-elf-g++ -o build/kernel/segmentation.o $(CCFLAGS) -c src/kernel/segmentation.cpp
	x86_64-elf-g++ -o build/kernel/interrupt.o $(CCFLAGS) -c src/kernel/interrupt.cpp
	x86_64-elf-g++ -o build/kernel/set_cs.o $(CCFLAGS) -c src/kernel/set_cs.s
	x86_64-elf-g++ -o build/kernel/device/serial_port.o $(CCFLAGS) -c src/kernel/device/serial_port.cpp
	x86_64-elf-g++ -o build/kernel/console.o $(CCFLAGS) -c src/kernel/console.cpp
	x86_64-elf-ld -o build/kernel/kernel.elf --script src/kernel/kernel.ld -N -static build/kernel/main.o build/kernel/segmentation.o build/kernel/interrupt.o build/kernel/set_cs.o build/kernel/device/serial_port.o build/kernel/console.o
	objcopy -O binary build/kernel/kernel.elf build/kernel/kernel.img

build_dirs:
	mkdir -p build/boot
	mkdir -p build/kernel/device

clean:
	-rm -r ./build

.PHONY: mos boot kernel build_dirs clean

