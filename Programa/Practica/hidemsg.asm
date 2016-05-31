section .data
    header   db  "P6",10,0
    len_hed  equ $-header

    header2  db  "255",10,0
    len_hed2 equ $-header2

    error_message: db "Se ha producido un error"
    error_message_length: equ $ - error_message

    fds dd 0            ;File descriptor de salida

section .bss
    msg             resw 2
    nombreArchivoE  resw 2
    nombreArchivoS resw 2

    msg_len         resw 2

section .text
    global _start

_strlen:               ; Metodo para calcular la longitud de un string
                       ; Sacado de http://tuttlem.github.io/2013/01/08/strlen-implementation-in-nasm.html

  push  ecx            ; save and clear out counter
  xor   ecx, ecx

_strlen_next:

  cmp   [edi], byte 0  ; null byte yet?
  jz    _strlen_null   ; yes, get out

  inc   ecx            ; char is ok, count it
  inc   edi            ; move to next char
  jmp   _strlen_next   ; process again

_strlen_null:

  mov   eax, ecx       ; rcx = the length (put in rax)

  pop   ecx            ; restore rcx
  ret                  ; get out

_exit:
    mov eax, 1
    mov ebx, 0
    int 80h

_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_message
    mov edx, error_message_length
    int 80h

    mov eax, 1
    mov ebx, -1
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

_crear_archivo_salida:
    mov eax, 8
    mov ebx, [nombreArchivoS]
    mov ecx, 644O
    int 80h

    mov [fds], eax

    mov eax, 4
    mov ebx, [fds]
    mov ecx, header
    mov edx, len_hed
    int 80h

    cmp eax, -1
    je _error

    ;Agregar el la cantidad de pixeles

    mov eax, 4
    mov ebx, [fds]
    mov ecx, header2
    mov edx, len_hed2
    int 80h

    cmp eax, -1
    je _error


    mov edi, msg
    call _strlen
    mov [msg_len], eax

    mov eax, 4
    mov ebx, [fds]
    mov ecx, [msg]
    mov edx, [msg_len]

    int 80h

_cerrar_Archivo:
    mov eax, 6
    mov ebx, [fds]
    int 80h

    jmp _exit