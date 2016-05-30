section .data
    respuesta db 0
    tam db $-respuesta

section .text
    global _start

_start:
    mov eax, 5
    add eax, 3

    mov [respuesta], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, eax
    mov edx, tam

    int 80h

    mov eax, 1
    mov ebx, 0
    int 80h
