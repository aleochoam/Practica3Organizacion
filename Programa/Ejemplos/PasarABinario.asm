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
    mov ebx, msg
    mov ecx, msg_len
    int 80h

    jmp _exit

_strtobin
    mov eax, byte[msg + ecx]
    mov eax, [msg]
    mov edi, num
    call _intToBin
    ret

_intToBin
    mov ecx, 7
    mov edx, edi

_nextNibble
    shl al, 1
    setc byte[edi]
    add byte [edi], "0"
    add edi, 1
    dec ecx
    jns _nextNibble

    mov byte[edi], 10
    mov eax, edi
    sub eax, edx
    inc eax
    ret

_start:
    pop ebx
    pop ebx
    pop ebx
    mov [msg], ebx

    mov edi, [msg]
    call _strlen
    mov [msg_len], eax

    call _strtobin
    mov edx, eax
    mov esi, nummov edi, 1
