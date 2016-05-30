section .data
    mensaje    db  0xA,"---vamos a probar esto---",0xA
    longitud   equ $ - mensaje
    mensaje2   db  0xA,"---hemos terminado---",0xA
    longitud2  equ $ - mensaje2
    tamano     equ 1024

section .bss
    buffer: resb 1024

section .text
    global _start    ;definimos el punto de entrada

_start:
    mov edx, longitud ;EDX=long. de la cadena
    mov ecx, mensaje  ;ECX=cadena a imprimir
    mov ebx, 1        ;EBX=manejador de fichero (STDOUT)
    mov eax, 4
    int 80h

    pop ebx
    pop ebx

    pop ebx
    mov eax, 5
    mov ecx, 0
    int 80h

    test eax,eax
    jns leer_del_fichero

hubo_error:
    mov ebx, eax
    mov eax, 1
    int 80h

leer_del_fichero:
    mov ebx, eax
    push ebx
    mov eax, 3
    mov ecx, buffer
    mov edx, tamano
    int 80
    js hubo_error

mostrar_por_pantalla:
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    int 80h

cerrar_fichero:
    pop ebx
    mov eax, 6
    int 80h

    mov edx, longitud2
    mov ecx, mensaje2
    mov ebx, 1
    mov eax, 4
    int 80h


    mov ebx, 0
    mov eax, 1
    int 80h