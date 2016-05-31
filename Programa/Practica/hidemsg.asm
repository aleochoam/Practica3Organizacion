section .data


section .bss
    msg resw 2
    nombreArchivoE resw 2
    nombreArchivoS resw 2

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

  mov   eax, ecx       ; rcx = the length (put in rax)

  pop   ecx            ; restore rcx
  ret                  ; get out

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

    mov edi, msg
    call _strlen
    mov edx, eax

    mov eax, 4
    mov ebx, 1
    mov ecx, [msg]

    int 80h

    jmp _exit
