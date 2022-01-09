# ref: https://github.com/zchrissirhcz/osask-linux/blob/master/day2.1/makefile

all:img

boot:
	nasm -o bootloader ipl.asm

img:boot
	dd if=bootloader of=heros.img count=1 bs=512
	dd if=/dev/zero of=heros.img bs=512 seek=1 skip=1 count=2879

run:img
	qemu-system-i386 -drive format=raw,file=heros.img,if=floppy

clean:
	rm bootloader heros.img
