	;; prog3.asm
	global _start
	section .text

_start:
	xor eax,eax
	push eax

	;; PUSH //bin/sh en forma inversa
	push 0x68732f6e
	push 0x69622f2f
	mov ebx,esp		;ebx apunta a //bin/sh en el stack

	;; PUSH 0x000000000 usando eax y apunta edx a esa parte del stack
	push eax
	mov edx,esp

	;; push la direccion de //bin/sh en el stack y hace que ecx apunte a esa parte del stack
	push ebx
	mov ecx,esp

	mov al,0xb
	int 0x80
	
