prog3.o: prog3.asm
	nasm -f elf -o prog3.o prog3.asm

prog3: prog3.o
	ld -o prog3 prog3.o

all: prog3
