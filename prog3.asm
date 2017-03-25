	;; prog3.asm
	global _start
	section .text

_start:
	;mov eax,0xfaceb00c	
	cmp eax,0xfaceb00c
	jne  _noface
_siface:
	mov  edx,24		;Longitud de la cadena
	mov  ecx,siface         ;direccion de la cadena
	mov  ebx,1		;file descriptor (1 = stdout)
	mov  eax,4		;syscall write (sys_write)
	int 80h			;Pedimos la impresion de la cadena al sistema
	jmp _fin
_noface:
	mov  edx,27		;Longitud de la cadena
	mov  ecx,noface         ;direccion de la cadena
	mov  ebx,1		;file descriptor (1 = stdout)
	mov  eax,4		;syscall write (sys_write)
	int 80h			;Pedimos la impresion de la cadena al sistema
_fin:
	mov eax,0x1		; syscall exit
	mov ebx,0		;Codigo de salida
	int 80h			;Regresar el control al sistema

	;; Area de datos, donde se definen las variables.
	;; Define dos mensajes
	section .data
	siface db "EAX tiene 0xFACEB00C :)",0xa,0
	lensi equ $ - siface
	noface db "EAX no tiene 0xFACEB00C :V",0xa,0
	lenno equ $ - noface
