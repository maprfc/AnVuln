;;; Mario Arturo Perez Rangel
;;; 25-03-2017
;;;
;;; cifra.asm
;;; Aplica las operaciones de corrimiento a la derecha, not, xor, rol e inc,
;;; en ese orden, a cada uno de los bytes de la cadena se obtiene una cadena
;;; cifrada. La cadena cifrada se convierte en caracteres hexadecimales
;;; imprimibles en la consola.
;;; Dado que en el corrimiento a la derecha se pierde informacion, se corren
;;; los bits desplazados al siguiente byte. En el ultimo byte, para no perder
;;; la informacion, se agrega un byte con los bits que se desplazaran.
;;; La cadena resultante tiene informacion del byte extra.

	global _start
	section .text

;;;========================================
;;; La cadena se va cifrando en orden inverso, desde el ultimo
;;; byte hasta el primero.

_start:
	mov ecx,mlen		;empezamos desde el ultimo
	dec ecx			;necesario para acceder el ultimo byte
	mov al,[msg+ecx]
	and al,0x0F		;Nos quedamos con el segundi nibble (digito hex)
	shl al,4		;a la izq. para representar el corrimiento a la izq.
	not al			;Negacion con complemento a 1
	xor al,0xCC		;XOR con el byte 11001100
	rol al,3		;Rotar el byte por 3 bits
	inc al			;Incrementamos en uno
	call to_hex		;Convertir a caracters imprimibles el byte obtenido

	;; Guardar en la cadena cifrada, en hexadecimal, al final
	mov [msgcifrado+2*(ecx+1)],ah
	mov [msgcifrado+2*(ecx+1)+1],al

;;; ======================================
;;; Ciclo decremental para procesar cada byte de la cadena
;;; ======================================
_for:
	cmp ecx,0		;Principio de la cadena? requiere procesamiento
	je  _fin_for		;especial
	mov al,[msg+ecx]
	shr al,4		;Corrimiento a la derecha del byte
	mov bl,[msg+ecx-1]	;Tomamos los cuatro bits de la "derecha"
	and bl,0x0F		;para copiarlos en el byte en proceso en el
	shl bl,4		;lado "izquierdo"
	or  al,bl
	not al			;Negacion con complemento a 1
	xor al,0xCC		;XOR con el byte 11001100
	rol al,3		;Rotar a 3 bits
	inc al			;Aumentar en uno
	call to_hex		;Convertir el resultado en algo imprimible
	;; Guardar en hexadecimal este byte
	mov [msgcifrado+2*ecx],ah
	mov [msgcifrado+2*ecx+1],al
	
	dec ecx
	jmp _for

;;; Queda por procesar el primer byte de la cadena.
;;; La parte baja del byte ya fue copiada en el siguiente byte.
_fin_for:
	mov al,[msg]
	shr al,4		;Corrimiento a la derecha
	not al
	xor al,0xCC
	rol al,3
	inc al
	call to_hex		;Convertir a algo imprimible
	mov [msgcifrado],ah
	mov [msgcifrado+1],al

;;; La cadena ya cifrada y en formato imprimible se muestra
;;; en la terminal
	mov edx,(mlen+1)*2+1	;Longitud de la cadena
	mov ecx,msgcifrado     ;direccion de la cadena
	mov ebx,1		;file descriptor (1 = stdout)
	mov eax,4		;system call number (sys_write)
	int 80h			;Pedimos la impresion de la cadena al sistema
	
	mov eax,0x1		;syscall exit
	mov ebx,0		;Todo salio bien
	int 80h			;Regresar el control al sistema

;;; ====================================
;;; to_hex recibe en el registro AL el byte a convertir en una cadena
;;; de dos caracteres hexadecimales que se pueden mostrar en la terminal.
;;; Regresa en el registro AH el nibble menos significativo y en AL el nibble
;;; mas significativo.
to_hex:
        push ebp
        mov  ebp,esp
	;; primer digito hexadecimal
	mov ah,al
	and al,0x0F
	add al,0x30
	cmp al,0x3a		; 0 a 9? asi se queda
	jb  _donel		; 10 a 15? sumamos lo necesario para
	add al,0x7		; tener de la A a la F
_donel:	
	;; Segundo digito hexadecimal
	and ah,0xF0
	shr ah,4
	add ah,0x30
	cmp ah,0x3a
	jb  _doneh
	add ah,0x7
_doneh:	
        leave  			;AH=digito alto, AL=digito bajo
        ret

	section .data
msgcifrado db 'FFFFFFFFFFFFFFFF',0xa
msg db 'secreto'
mlen equ $ - $msg
