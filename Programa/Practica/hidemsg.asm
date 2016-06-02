struc STAT
    .st_dev:        resd 1
    .st_ino:        resd 1
    .st_mode:       resw 1
    .st_nlink:      resw 1
    .st_uid:        resw 1
    .st_gid:        resw 1
    .st_rdev:       resd 1
    .st_size:       resd 1
    .st_blksize:    resd 1
    .st_blocks:     resd 1
    .st_atime:      resd 1
    .st_atime_nsec: resd 1
    .st_mtime:      resd 1
    .st_mtime_nsec: resd 1
    .st_ctime:      resd 1
    .st_ctime_nsec: resd 1
    .unused4:       resd 1
    .unused5:       resd 1
endstruc

%define sizeof(x) x %+ _size


section .data
    header   db  "P6",10
    len_hed  equ $-header

    header2  db  "255",10
    len_hed2 equ $-header2


    fin     db 10
    fin_len equ $-fin

    error_message: db "Se ha producido un error",10,0
    error_message_length: equ $-error_message

    fds dd 0            ;File descriptor de salida
    fde dd 0
     zero equ 0

section .bss
    msg             resb 1024
    msg_len         resb 28
    num             resb 9
    stat            resb sizeof(STAT)

    nombreArchivoE  resw 2
    nombreArchivoS  resw 2

    buffer:         resb 5242880
    len_buffer      resb 1024

section .text
    global _start

;Sacado de http://tuttlem.github.io/2013/01/08/strlen-implementation-in-nasm.html
;Metodo para calcular la longitud de un string

_strlen:

  push  ecx            ; save and clear out counter
  xor   ecx, ecx

_strlen_next:

  cmp   [edi], byte 0  ; null byte yet?
  jz    _strlen_null   ; yes, get out

  inc   ecx            ; char is ok, count it
  inc   edi            ; move to next char
  jmp   _strlen_next   ; process again

_strlen_null:

  mov   eax, ecx       ; ecx = the length (put in eax)

  pop   ecx            ; restore ecx
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
    
    mov ecx, 0

_string_binario:
    movzx eax, byte[msg + ecx]
    ;mov eax, 4
    cmp eax, 0

_loop1:
    mov edx, 0
    cmp eax, 1
    je  fin_binario
    mov ebx, 2
    div ebx
    cmp edx, 0
    je  es_cero
    jmp es_uno

es_cero:
   mov ebx, 0
   push ebx
   jmp _loop1

es_uno:
   mov ebx, 1
   push ebx
   jmp _loop1

fin_binario:
   mov  ebx, 1
   push ebx
   inc  ecx
   jmp _string_binario
    
_obtener_tamano_archivo:
    mov eax, 106
    mov ebx, nombreArchivoE
    mov ecx, stat
    int 80h

    mov eax, dword [stat + STAT.st_size]
    mov [len_buffer], eax

_abrir_archivo_de_entrada:
    mov eax,5
    mov ebx, [nombreArchivoE]
    mov ecx,0
    int 80h
    mov [fde], eax

_leer_archivo_de_entrada:
    mov eax, 3
    mov ebx,[fde]
    mov ecx,buffer
    mov edx, len_buffer
    int 80h
    js _error

;    mov ebx, 1
;    mov ecx, buffer
;    mov edx, len_buffer
;    mov eax, 4
;    int 80h

_cerrar_archivo_de_entrada:
    mov ebx,[fde]
    mov eax, 6
    int 80h

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

_agregar_el_mensaje:
    mov edi, [msg]
    call _strlen
    mov [msg_len], eax

    mov eax, 4
    mov ebx, [fds]
    mov ecx, [msg]
    mov edx, [msg_len]
    int 80h
    
    mov ebx, [fds]
    mov ecx, buffer
    mov edx, len_buffer
    mov eax, 4
    int 80h



_cerrar_Archivo:
    mov eax, 4
    mov ebx, [fds]
    mov ecx, fin
    mov edx, fin_len
    int 80h

    mov eax, 6
    mov ebx, [fds]
    int 80h

    jmp _exit
