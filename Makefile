src=src/bootloader/legacy
build=build
flags=-f bin
loop=2

all: stage1 stage2 install run

stage1:
	nasm $(flags) -o $(build)/stage1 $(src)/stage1.asm

stage2:
	nasm $(flags) -o $(build)/stage2 $(src)/stage2.asm

install:
	sudo dd if=$(build)/stage1 of=/dev/loop$(loop) bs=446 count=446 iflag=count_bytes
	#sudo dd if=$(build)/stage2 of=/dev/loop$(loop) bs=512 seek=512 oflag=seek_bytes 	#mbr
	sudo dd if=$(build)/stage2 of=/dev/loop28 bs=512 									#gpt

inspect:
	sudo xxd -len 1024 /dev/loop$(loop)

run:
	sudo qemu-system-x86_64 /dev/loop$(loop)

clean:
	rm $(build)/stage1
	rm $(build)/stage2