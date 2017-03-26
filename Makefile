prog3.o: prog3.asm
	nasm -f elf -o prog3.o prog3.asm

prog3: prog3.o
	ld -N -o prog3 prog3.o

list.o: list.asm
	nasm -f elf -o list.o list.asm

list: list.o
	ld -N -o list list.o

shell-stack.o: shell-stack.asm
	nasm -f elf -o shell-stack.o shell-stack.asm

shell-stack: shell-stack.o
	ld -N -o shell-stack shell-stack.o

shell-rem.o: shell-rem.asm
	nasm -f elf -o shell-rem.o shell-rem.asm

shell-rem: shell-rem.o
	ld -N -o shell-rem shell-rem.o

all: prog3

clean:
	rm -f *.o shell-rem shell-stack shell-scm list 
