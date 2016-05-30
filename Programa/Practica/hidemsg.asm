section .data
    len db 1

section .bss
    msg resw 2
    nombreArchivoE resw 2
    nombreArchivoS resw 2

section .text
    global _start

_exit:
    mov eax, 1
    mov ebx, 0
    int 80h

_start:

    pop ebx
    pop ebx
    pop ebx
    mov [msg], ebx    ;Se saca el mensaje a esconder

    pop ebx           ;Aca está el -f (puede que no sea asi)

    pop ebx
    mov [nombreArchivoE], ebx

    pop ebx           ;Aca esta el -o (puede que no sea asi)

    pop ebx
    mov [nombreArchivoS], ebx

    mov eax, 4
    mov ebx, 1
    mov ecx, [msg]
    mov edx, len

    int 80h

    jmp _exit
