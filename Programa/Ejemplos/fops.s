;----------------------------------------------------------
; fops.s demonstrates NASM file operations:
; create, write, read, sync, open, close
;
; Copyright 2011 by George Matveev
;
; www.matveev.se
;----------------------------------------------------------

section .text
	global _start

_start:
	nop				;required for debugging purposes

	pop ebx			;number of command line parameters
	cmp ebx, 2		;check if total number is 2
	jne error			;exit

	pop ebx			;name of the program

	pop ebx			;name of the file to be created
	cmp ebx, 0		;check if ebx is not zero (ok)
	jbe error			;exit

	mov [file], ebx	;store file name in local variable

; create file with (-rwxr-xr-x) access rights

; access modes of new file:
;1=--x, 5=--r-x, 6=--r, 7=--r-x, 15=-xr-x
;127=---xr-xr-x, 128=--w-------
;255=--wxr-xr-x, 256=-r--------
;511=-rwxr-xr-x, 512=---------T
;666=--w---x--T, 755=--wxr----t

	mov eax, 8		;sys_creat
	mov ecx, 511		;access rights
	int 80h

	cmp eax, 0		;check if file was created
	jbe error			;error creating file

; open file in read-write mode

	mov eax, 5		;sys_open file with fine name in ebx
	mov ebx, [file]	;name of the file to be opened
	mov ecx, 1		;0_RDWR
	int 80h

	cmp eax, 0		;check if fd in eax > 0 (ok)
	jbe error			;cannot open file

	mov ebx, eax		;store file descriptor of new file

; write line1 to file pointer we keep in ebx

	mov eax, 4		;sys_write
	mov edx, len
	mov ecx, line
	int 80h

; write second line to file

	mov eax, 4		;sys_write
	mov edx, len2
	mov ecx, line2
	int 80h

; sync all write buffers with files

	mov eax, 36		;sys_sync
	int 80h

; close file, fd in ebx may not be valid anymore

	mov eax, 6		;sys_close
	int 80h

; re-open same file in read-only mode

	mov eax, 5		;sys_open file
	mov ebx, [file]	;name of file to be re-opened
	mov ecx, 0		;O_RDONLY
	int 80h

	cmp eax, 0		;check if fd in eax > 0 (ok)
	jbe error			;can not open file

	mov ebx, eax		;store new (!) fd of the same file

; read from file into bss data buffer

	mov eax, 3		;sys_read
	mov ecx, bssbuf	;pointer to destination buffer
	mov edx, len		;length of data to be read
	int 80h
	js error			;file is open but cannot read

	cmp eax, len		;check number of bytes read
	jb close			;must close file first

; write bss data buffer to stderr

	mov eax, 4		;sys_write
	push ebx			;save fd on stack for sys_close
	mov ebx, 2		;fd of stderr which is unbuffered
	mov ecx, bssbuf	;pointer to buffer with data
	mov edx, len		;length of data to be written
	int 80h

	pop ebx			;restore fd in ebx from stack

close:
	mov eax, 6		;sys_close file
	int 80h

	mov eax, 1		;sys_exit
	mov ebx, 0		;ok
	int 80h

error:
	mov ebx, eax		;exit code = sys call result
	mov eax, 1		;sys_exit
	int 80h

section .data

	line db "This is George,",
		db " and his nasm line.", 0xa, 0
	len equ $ - line

	line2 db "This is line number 2.", 0xa, 0
	len2 equ $ - line2

section .bss

	bssbuf: resb len	;any int will do here, even 0,
	file: resb 4		;since pointer is allocated anyway


