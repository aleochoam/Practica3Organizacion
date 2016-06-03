section .data

section .bss
    msg resb 1024
    msg_len resb 16

    num resb 9

section .text
    global _start

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

_exit
    mov eax, 1
    mov ebx, 0
    int 80h

_print
    mov eax, 4
    mov ebx, num
    mov ecx, msg_len
    int 80h

    jmp _exit

_string_binario:
    movzx eax, byte[msg + ecx]
    cmp eax, byte 0

    je _print

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

_start:
    pop ebx
    pop ebx
    pop ebx
    mov [msg], ebx

    mov edi, [msg]
    call _strlen
    mov [msg_len], eax

    call _string_binario
    mov edx, eax
    mov esi, num
    mov edi, 1
