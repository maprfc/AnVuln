#!/usr/bin/perl
##
## Mario Arturo Perez Rangel
## 25-03-2017
##
## Mi propia version de shellcode. El programa lee los primeros 96 (0x60) bytes del
## ejecutable, donde se encuentra la cabecera ELF y la(s) cabecera(s) de programa
## En la primera se encuentra informacion sobre la arquitectura, si es de 32 0 64 bits,
## si es un executable, una biblioteca dinamica (relocalizable) o estatica, y si esta
## en formato little/big endian, ademas de otros valores que no uso.
##
## En la cabecera de programa se encuentra el offset (distancia desde el inicio del archivo)
## donde esta la seccion de texto (instrucciones para el procesador) y el tamanio del del mismo.
##
## Con esa informacion en mano leemos la parte del codigo y se muestra en formato
## hexadecimal (\x90\x90) por defecto. Con la opcion -n se muestran solo los digitos
## hexadecimales (9090) y con la opcion -u se muestra en formato unicode (\u9090).
##
## El programa usa el modulo Getopt::Long disponible para instalar en debian 8 a traves
## del paquete libgetopt-mixed-perl.
##
## Referencia
## (n.d.) Executable and Linkable Format. Recuperado de
## https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
##
use warnings;
use strict;
use IO::File qw(SEEK_SET);
use Getopt::Long;

my ($file, $buffer, $readit);
my ($unicode, $nonhex);
my ($ei_magic, $ei_class, $ei_data, $e_type);
my ($e_phnum, $p_off, $p_filesz);

# Manejo de las opciones en linea de comandos
GetOptions('u' => \$unicode,
           'n' => \$nonhex);

if ($unicode and $nonhex) {
    print "Las opciones -u y -n son exclusivas, solo debe usar una de ellas.";
    print "Ignorando ambas opciones.\n";
    $unicode  = 0;
    $nonhex = 0;
}
if ($#ARGV < 0) {
    print "Falta el archivo\n";
    exit (-1);
}

if ((stat($ARGV[0]))[3] < 0) { # Verifica la existencia del ejecutable
    print $ARGV[0], "No existe\n";
    exit (-1);
}
open($file, "$ARGV[0]")
    or die "No se pudo abrir el archivo.\n";

##================================================
##Leer la cabecera ELF y la cabecera de programa
#
if (($readit = read($file,$buffer,96)) != 96)  {
    print "No fue posible leer los primeros bytes.\n";
    exit (-1);
}
($ei_magic, $ei_class, $ei_data) =
    unpack("NC2", substr($buffer,0, 6));

# Numero magico de un ejecutable de linux en formato ELF
if ($ei_magic != 0x7f454c46) {
    print "No es un ejecutable de linux (formato ELF)!!!\n";
    exit(-1);
}

if ($ei_class == 2) { # Arquitectura de 64 bits?
    print "Por el momento este programa solo soporta arquitecturas de 32 bits.\n";
    exit (-1);
}

## Segun el modo en que estan ordenados los bytes es como leemos
## la informacion de las cabeceras
if ($ei_data == 1) { # 32 bits, little endian
    $e_type = unpack("v",substr($buffer,0x10,2));

    if ($e_type != 2) {
	print "El tipo de objeto no es ejecutable.\n";
	exit (-1);
    }
    getSO32le (\$p_off, \$p_filesz, $buffer);
} elsif ($ei_data == 2) { # 32 bits, big endian
    $e_type = unpack("n",substr($buffer,0x10,2));

    if ($e_type != 2) {
	print "El tipo de objeto no es ejecutable.\n";
	exit (-1);
    }
    getSO32be (\$p_off, \$p_filesz, $buffer);
} else { ## ????
    exit (-2);
}

## Colocamos el puntero del archivo en la posicion, contada desde
## el inicio, del lugar donde se encuentran las instrucciones
## del programa.
##
seek ($file,$p_off,SEEK_SET);

## Leemos todos los bytes correspondientes al programa
##
if(($readit = read($file,$buffer,$p_filesz)) != $p_filesz) {
    print "Hubo problemas al tratar de obtener el segmento de texto.\n";
    exit (-1);
}
close ($file);

## Mostramos el codigo en el formato pedido
##
if ($nonhex) { # opcion -n
    map {printf "%02x", $_} unpack ("C*", $buffer);
} elsif ($unicode) { # opcion -u 
    map {printf "\\u%04x", $_} unpack ("n*", $buffer);
} else { # Sin opciones
    map {printf "\\x%02x", $_} unpack ("C*", $buffer);
}
print "\n";

## geSO32le obtiene de la cabecera ELF el lugar en el archivo, contado
## a partir del inicio, de la cabecera del programa. De ahi se obtiene
## la posicion dentro del archivo, a partir del inicio, de las instrucciones
## del programa y el tama~no que ocupan.
## La informacion esta ordenada en forma "little-endian"
##
## Recibe: la variable de offset desde el inicio del archivo, la variable
## de la longitud del codigo y el buffer de los primeros 96 bytes leidos.
## Regresa las variables con los datos necesarios en ella.
## 
sub getSO32le {
    my ($offset, $length, $buffer) = @_;
    my $h_phoff;

    $h_phoff = unpack("V",substr($buffer,0x1c,4));
    $$offset = unpack("V",substr($buffer,$h_phoff+4,4));
    $$length = unpack("V",substr($buffer,$h_phoff+0x10,4));
}

## geSO32be obtiene de la cabecera ELF el lugar en el archivo, contado
## a partir del inicio, de la cabecera del programa. De ahi se obtiene
## la posicion dentro del archivo, a partir del inicio, de las instrucciones
## del programa y el tama~no que ocupan.
## La informacion esta ordenada en forma "big-endian"
##
## Recibe: la variable de offset desde el inicio del archivo, la variable
## de la longitud del codigo y el buffer de los primeros 96 bytes leidos.
## Regresa las variables con los datos necesarios en ella.
## 
sub getSO32be {
    my ($offset, $length, $buffer) = @_;
    my $h_phoff;
    
    $h_phoff = unpack("N",substr($buffer,0x1c,4));
    $$offset = unpack("N",substr($buffer,$h_phoff+4,4));
    $$length = unpack("N",substr($buffer,$h_phoff+0x10,4));
}
1;
    
