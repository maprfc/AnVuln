	;; prog2.asm
	global _start
	section .text

_start:
	mov eax,0x04
	mov ebx,0x06
	mul ebx
	
