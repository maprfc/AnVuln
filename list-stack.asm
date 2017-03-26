	;; prog3.asm
	global _start
	section .text

_start:
	xor eax,eax
	push eax

	;; PUSH //bin/sh en forma inversa
	push 0x74616c2d
	push 0x736c2f6e
	push 0x69622f2f
	mov edx,esp		;ebx apunta a //bin/sh en el stack

	push eax

	push 0x736c2f6e
	push 0x69622f2f
	mov  ebx,esp
	
	;; push la direccion de //bin/sh en el stack y hace que ecx apunte a esa parte del stack
	push eax
	push edx
	mov ecx,esp

	push eax
	mov edx,esp

	mov al,0xb
	int 0x80
	
