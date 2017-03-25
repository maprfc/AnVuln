;;; Mario Arturo Perez Rangel
;;; 25-03-2017
;;;
;;; decifra.asm
;;; Toma una cadena generada por el programa cifra y le aplica
;;; el proceso inverso para obtener la cadena inicial.
;;; La cadena es un numero para de caracteres hexadecimales.
	global _start
	section .text

;;; =======================================================
;;; Comienza a descifrar desde el primer byte de la cadena
_start:
	mov ecx,0
_for:
	cmp ecx,mlen
	je  _fin_for		;Terminamos?
	
;;; Toma un par de hexadecimales posteriores al que esta en proceso
;;; y los regresa a un valor numerico.
	mov ah,[msgcifrado+2*(ecx+1)]
	mov al,[msgcifrado+2*(ecx+1)+1]
	call to_byte		;AL tiene el valor numerico
	mov bl,al
	dec bl			;Decrementa en uno
	ror bl,3		;Rota 3 bits a la derecha
	xor bl,0xCC		;XOR con el byte 11001100
	not bl			;Negacion con complemento a uno
	and bl,0xF0		;Solo nos interesan los cuatro bits de la izquierda
	shr bl,4		;para pegarlos como los cuatro bits de la derecha
				;en el byte en proceso
	
	mov ah,[msgcifrado+2*ecx] ;Tomamos el par de hexadecimales
	mov al,[msgcifrado+2*ecx+1]
	call to_byte		;se convierten en numero
	dec al			;Restamos uno
	ror al,3		;Rotamos el byte tres bits a la derecha
	xor al,0xCC		;XOR con el byte 11001100
	not al			;Negacion con complemento a uno
	shl al,4		;Desplazamiento cuatro bits a la izquierda
	or  al,bl		;Pegamos los cuatro bits del siguiente byte
	mov [msg+ecx],al	;Guarda este byte del mensaje original
	inc ecx
	jmp _for
_fin_for:
	mov  byte [msg+ecx],0xa	;Agregamos un salto de linea

;;; Mostrar el mensaje original
	mov edx,mlen+1		;Longitud de la cadena
	mov ecx,msg     	;direccion de la cadena
	mov ebx,1		;file descriptor (1 = stdout)
	mov eax,4		;system call number (sys_write)
	int 80h			;Pedimos la impresion de la cadena al 

;;; Terminar el programa
	mov eax,0x1		;syscall exit
	mov ebx,0		;todo salio bien
	int 80h			;Regresar el control al sistema
;;; =====================================================================
;;; to_byte recibe en AH la parte alta de un par de digitos hexadecimales
;;; y en AL la parte baja del mismo. Los convierte en numero que se regresa
;;; en el registro AL. El registro AH se "clarea" por precaucion.
to_byte:
	push ebp
	mov ebp,esp
	sub al,48
	cmp al,0x11
	jb  _donel		;Digito mayor a 10?
	sub al,0x7		;restale lo que falto
_donel:
	sub ah,48
	cmp ah,0x11             ;Digito mayor a 10?  
	jb  _doneh              ;restale lo que falto
	sub ah,0x7
_doneh:	
	shl ah,4
	or  al,ah		;Suma ambas partes y eso regresalo en AL
	xor ah,ah
	leave
	ret

	section .data

msgcifrado db 'A2292C21A924AC1F'
msg db 'xxxxxxx',0xa
mlen equ $ - $msg
