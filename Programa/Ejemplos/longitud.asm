section .data
    bueno db "Esta bueno",10,0
    bueno_len equ $-bueno

    malo  db "esta malo",10, 0
    malo_len equ $-malo

    msg   db "Este es un mensaje de prueba"

section .bss
    msg_len resb 8


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

_start:
    mov edi, msg
    call _strlen

    cmp eax, 28
    je _bueno
    jmp _malo


_bueno:
    mov eax, 4
    mov ebx, 1
    mov ecx, bueno
    mov edx, bueno_len
    int 80h
    jmp _exit

_malo:
    mov eax, 4
    mov ebx, 1
    mov ecx, malo
    mov edx, malo_len
    int 80h

_exit:
    mov eax,1
    mov ebx,0
    int 80h