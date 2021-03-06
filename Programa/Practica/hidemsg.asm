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
    fin                  db 10
    fin_len              equ $-fin

    error_message        db "Se ha producido un error",10,0
    error_message_length equ $-error_message

    error_Argumentos     db "Error con los argumentos, ingresarlos de \
la siguiente manera:", 10, "./hidemsg 'mensaje' -f archivo.ppm -o archivo2.ppm",10,0
    error_args_len       equ $ - error_Argumentos

    error_Archivo        db "Error abriendo el archivo",10,0
    error_Archivo_len    equ $ - error_Archivo

    fds dd 0            ;File descriptor de salida
    fde dd 0            ;File descriptor de entrada

section .bss
    msg             resb 1024
    msg_len         resb 16

    stat            resb sizeof(STAT)

    nombreArchivoE  resw 2
    nombreArchivoS  resw 2

    imagen:         resb 5242880
    tam_imagen      resb 1024

    strBin          resb 1024
    strBin_len      resb 16

    tam_header      resb 16

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

_errorArchivo:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_Archivo
    mov edx, error_Archivo_len
    int 80h

    mov eax, 1
    mov ebx, -1
    int 80h

_error_Args:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_Argumentos
    mov edx, error_args_len
    int 80h

    mov eax, 1
    mov ebx, -1
    int 80h

_start:

    pop ebx             ;Numero de parametros

    cmp ebx, 6          ;Verifico el numero de argumentos
    jne _error_Args

;Nombre de programa
    pop ebx             ;Saco el nombre del programa
    pop ebx             ;Se saca el mensaje a esconder
    mov [msg], ebx

;Calculo la longitud del mensaje
    mov edi, [msg]
    call _strlen
    mov [msg_len], eax

;Analizo el -f
    pop ebx              ;Aca está el -f (puede que no sea asi)
    cmp byte[ebx], '-'
    jne _error_Args
    cmp byte[ebx+1], 'f'
    jne _error_Args

;Saco el nombre del archivo de entrada
    pop ebx
    mov [nombreArchivoE], ebx

;Obtengo el tamaño de la imagen
_obtener_tamano_archivo:
    mov eax, 106
    mov ebx, [nombreArchivoE]
    mov ecx, stat
    int 80h

    mov eax, dword [stat + STAT.st_size]
    mov [tam_imagen], eax

;Analizo el -o
    pop ebx           ;Aca esta el -o (puede que no sea asi)
    cmp byte[ebx], '-'
    jne _error_Args
    cmp byte[ebx+1], 'o'
    jne _error_Args

;Saco el nombre del archivo de salida
    pop ebx
    mov [nombreArchivoS], ebx


_abrir_archivo_de_entrada:
    mov eax,5
    mov ebx, [nombreArchivoE]
    mov ecx,0
    int 80h

    test eax,eax
    js _errorArchivo

    mov [fde], eax

_leer_archivo_de_entrada:
    mov eax, 3
    mov ebx,[fde]
    mov ecx, imagen
    mov edx, tam_imagen
    int 80h
    js _error

    mov eax, 6
    mov ebx,[fde]
    int 80h

    mov esi, [msg]
    mov ecx, 0

_string_binario:
    movzx eax, byte[esi]
    cmp eax, 0
    je _finBin

_loop1:
    mov edx, 0
    cmp eax, 1
    je  fin_loop1
    mov ebx, 2
    div ebx
    cmp edx, 0
    je  es_cero
    jmp es_uno

es_cero:
    mov edi, '0'
    push edi
    jmp _loop1

es_uno:
    mov edi, '1'
    push edi
    jmp _loop1

fin_loop1:
    mov edi, '1'
    push edi

    cmp byte[esi], 127
    jg _finLetra
    cmp byte[esi], 64
    jge _unCero
    cmp byte[esi], 32
    jl _tresCeros
    jmp _dosCeros

_tresCeros:
    mov edi, '0'
    push edi
    mov edi, '0'
    push edi
    mov edi, '0'
    push edi
    jmp _finLetra

_dosCeros:
    mov edi, '0'
    push edi
    mov edi, '0'
    push edi
    jmp _finLetra

_unCero:
    mov edi, '0'
    push edi
    jmp _finLetra

_finLetra:
    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    pop edi
    mov [strBin + ecx], edi
    inc ecx

    inc esi
    jmp _string_binario

_finBin:
    mov byte [strBin + ecx], byte 10

    mov ebx, [msg_len]
    mov eax, 8
    mul ebx
    mov [strBin_len], eax

_crear_archivo_salida:

    mov eax, 8
    mov ebx, [nombreArchivoS]
    mov ecx, 644O
    int 80h

    mov [fds], eax

_encontrarImagen:
    mov ecx, imagen
    mov ebx, 0                  ;indicador fin de header
    mov edx, 0                  ;contador fin de linea

_cicloHeader:
    cmp byte[ecx], 10
    je _finDeLinea
    inc ebx
    inc ecx;
    jmp _cicloHeader

_finDeLinea:
    inc edx
    cmp edx, 3
    je _finHeader
    inc ebx
    inc ecx
    jmp _cicloHeader

_finHeader:
    inc ebx
    mov [tam_header], ebx

_meterElMensaje:
    mov ecx, [strBin_len]
    mov edi, 0
    mov esi, 0
    add esi, [tam_header]

_ciclo_escribir:

    movzx eax, byte [imagen + esi]
    mov ebx, 2
    mov edx, 0
    div ebx

    cmp edx, 1
    je _terminaEnUno
    jmp _terminaEnCero

_terminaEnUno:
    cmp byte[strBin + edi], '1'
    je _cambioHecho
    and byte[imagen + esi], 254
    jmp _cambioHecho

_terminaEnCero:
    cmp byte[strBin + edi], '0'
    je _cambioHecho
    or byte[imagen + esi], 1
    jmp _cambioHecho


_cambioHecho:
    inc esi
    inc edi

    dec ecx
    jz _finEsconder

    jmp _ciclo_escribir

_finEsconder:
    mov eax, 4
    mov ebx, [fds]
    mov ecx, imagen
    mov edx, [tam_imagen]
    int 80h

_cerrar_Archivo_Salida:

    mov eax, 6
    mov ebx, [fds]
    int 80h

    jmp _exit