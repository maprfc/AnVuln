	;; prog3.asm
	global _start
	section .text

_start:
	mov eax,0x1		; syscall exit
	mov ebx,0		;Codigo de salida
	int 80h			;Regresar el control al sistema
