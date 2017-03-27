cifra.o: cifra.asm
	nasm -f elf -o cifra.o cifra.asm

cifra: cifra.o
	ld -N -o cifra cifra.o

descifra.o: descifra.asm
	nasm -f elf -o descifra.o descifra.asm

descifra: descifra.o
	ld -N -o descifra descifra.o

list.o: list.asm
	nasm -f elf -o list.o list.asm

list: list.o
	ld -N -o list list.o

shell.o: shell.asm
	nasm -f elf -o shell.o shell.asm

shell: shell.o
	ld -N -o shell shell.o

shell-stack.o: shell-stack.asm
	nasm -f elf -o shell-stack.o shell-stack.asm

shell-stack: shell-stack.o
	ld -N -o shell-stack shell-stack.o

shell-rem.o: shell-rem.asm
	nasm -f elf -o shell-rem.o shell-rem.asm

shell-rem: shell-rem.o
	ld -N -o shell-rem shell-rem.o

shell-ne.o: shell-ne.asm
	nasm -f elf -o shell-ne.o shell-ne.asm

shell-ne: shell-ne.o
	ld -N -o shell-ne shell-ne.o

all: cifra descifra

clean:
	rm -f *.o shell-ne shell-rem shell-stack shell-scm list 
