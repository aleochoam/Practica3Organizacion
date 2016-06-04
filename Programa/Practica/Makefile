hidemsg: hidemsg.o
	ld -m elf_i386 hidemsg.o -o hidemsg
hidemsg.o: hidemsg.asm
	nasm -f elf -g hidemsg.asm
clean:
	rm -f *.o
	rm -f hidemsg
	rm -f image2.ppm
