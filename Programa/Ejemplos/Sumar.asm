section .data
    res: db 0

section .text
    global _start

_start:
    mov eax, 5
    add eax, 3

    mov res, eax

    mov eax, 4
    mov ebx, 1
    mov ecx, res
    mov edx, 1

    int 80h

    mov eax, 1
    mov ebx, 0
    int 80
