section .data
    filename: db "text.txt",0

    error_message: db "Something went wrong"
    error_message_length: equ $ - error_message

    hello: db "Hello File", 0
    hello_length: equ $ - hello

    fd: dd 0

section .text
    global _start

_start:
    mov eax, 8
    mov ebx, filename
    mov ecx, 6440
    int 80h

    cmp eax, -1
    je error

    mov [fd], eax

    mov eax, 4
    mov ebx, [fd]
    mov ecx, hello
    mov edx, hello_length
    int 80h

    cmp eax, -1
    je error

    mov eax, 6
    mov ebx, [fd]
    int 80h

    mov eax, 1
    mov ebx, 0
    int 80h

error:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_message
    mov edx, error_message_length
    int 80h

    mov eax, 1
    mov ebx, 1
    int 80h