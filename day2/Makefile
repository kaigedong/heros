# ref: https://github.com/zchrissirhcz/osask-linux/blob/master/day2.1/makefile

all:img
boot:
	nasm -o bootloader ipl.nas
img:boot
	dd if=bootloader of=heros.img count=1 bs=512
	dd if=/dev/zero of=heros.img bs=512 seek=1 skip=1 count=2879
run:
	qemu-system-i386 -drive file=heros.img,if=floppy
clean:
	rm bootloader heros.img
