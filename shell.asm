	;; prog3.asm
	global _start
	section .text

_start:
	jmp dir_cadena
codigo:
	pop esi			;almacena en el registro ESI, el valor inicial de la pila

	mov byte[esi+7],0	;/bin/sh\0xxxxyyyy
	mov eax,0xb		;syscall execve
	lea ebx,[esi]		;EBX ahora tiene la direccion de la cadena
	mov [esi+8],ebx		;'/bin/sh\0<dir_cadena>YYYY'
	lea ecx,[esi+8]		;ECX tiene la direccion <dir_cadena>
	mov dword [esi+12],0	;'/bin/sh\0<dir_cadena>0000'
	lea edx,[esi+12]	;EDX tiene la direccion donde esta almacenado el valor 000
	int 0x80
	
dir_cadena:	
	call codigo		;guarda la direccion inicial de la cadena en la pila
	db '/bin/shNXXXXYYYY'
	
	
