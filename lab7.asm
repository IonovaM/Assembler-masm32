.386
.model flat,stdcall
option casemap:none
include includes\windows.inc
include includes\kernel32.inc
include includes\masm32.inc
includelib includes\masm32.lib
includelib includes\kernel32.lib

.data
stdin DWORD ? 
stdout DWORD ? 
a	dd ?
b	dd ?
cc	dd ?
d	dd ?
e	dd ?
f	dd ?
g	dd ?
h	dd ?
k	dd ?
m	dd ?
x	dd ?
count_byte	dd ?		
read_byte INPUT_RECORD <?>	
input_a	db 'a = '
input_b	db 13,10,'b = '
input_c	db 13,10,'c = '
input_d	db 13,10,'d = '
input_e	db 13,10,'e = '
input_f	db 13,10,'f = '
input_g	db 13,10,'g = '
input_h	db 13,10,'h = '
input_k	db 13,10,'k = '
input_m	db 13,10,'m = '
input_0	db 13,10,'zero divisor'
output_res	db 13,10,'result = '
empty	db 13,10
chislo	db 0
.code
WriteNumber proc
	push ecx
	push edx
	push ebx
	mov ebx, 10
	xor ecx, ecx
convert_loop:	
	xor edx, edx
	div ebx	
	push edx
	inc ecx	
	test eax, eax	
	jnz convert_loop
convert_loop1:	
	pop eax
	add al, '0'
	push eax
	push ecx
	push edx
	mov chislo, al
	invoke WriteConsole, stdout, offset chislo, 1, ADDR count_byte, 0
	pop edx
	pop ecx
	pop eax
	loop convert_loop1
	pop ebx	
	pop edx
	pop ecx
	ret	
WriteNumber endp

start:
	invoke GetStdHandle, -10
	mov stdin, eax
	invoke GetStdHandle, -11
	mov stdout, eax
	invoke WriteConsole, stdout, offset input_a, sizeof input_a, ADDR count_byte, 0
	call input
	mov a, eax
	invoke WriteConsole, stdout, offset input_b, sizeof input_b, ADDR count_byte, 0
	call input
	mov b, eax
	invoke WriteConsole, stdout, offset input_c, sizeof input_c, ADDR count_byte, 0
	call input
	mov cc, eax
	invoke WriteConsole, stdout, offset input_d, sizeof input_d, ADDR count_byte, 0
	call input
	mov d, eax
	invoke WriteConsole, stdout, offset input_e, sizeof input_e, ADDR count_byte, 0
	call input
	mov e, eax
	invoke WriteConsole, stdout, offset input_f, sizeof input_f, ADDR count_byte, 0
	call input
	mov f, eax
	invoke WriteConsole, stdout, offset input_g, sizeof input_g, ADDR count_byte, 0	
	call input
	mov g, eax
	invoke WriteConsole, stdout, offset input_h, sizeof input_h, ADDR count_byte, 0
	call input
	mov h, eax
	invoke WriteConsole, stdout, offset input_k, sizeof input_k, ADDR count_byte, 0
	call input
	mov k, eax
	invoke WriteConsole, stdout, offset input_m, sizeof input_m, ADDR count_byte, 0
	call input
	mov m, eax
	cmp f, 0
	jz error_0
	cmp m, 0
	jz error_0
	; a * b + c + (d + e)/f + g * h + k/m   
	mov eax, d		;d
	add eax, e		;d+e
	mov edx, 0
	div f			;(d+e)/f
	mov ecx, eax	;ecx=(d+e)/f
	mov eax, g		;g
	mul h			;g*h
	mov ebx, eax	;ebx=g*h
	mov eax, k		;k
	mov edx, 0
	div m			;k/m
	mov esi, eax	;esi=k/m
	mov eax, a		;a
	mul b			;a*b
	add eax, cc		;a*b+c
	add eax, ecx	;a*b+c+(d+e)/f
	add eax, ebx	;a*b+c+(d+e)/f+g*h
	add eax, esi	;a*b+c+(d+e)/f+g*h+k/m
	mov x, eax		
	invoke WriteConsole, stdout, offset output_res, sizeof output_res, ADDR count_byte, 0
	mov eax, x
	call WriteNumber
exit:
	invoke WriteConsole, stdout, offset empty, sizeof empty, ADDR count_byte, 0	
	invoke ExitProcess,0
error_0:	
	invoke WriteConsole, stdout, offset input_0, sizeof input_0, ADDR count_byte, 0
	jmp exit


input	proc
	mov bh, 0 
	xor edi, edi

input_loop:
	invoke ReadConsoleInput, stdin, offset read_byte, 1, offset count_byte
	cmp read_byte.EventType,KEY_EVENT
	jnz input_loop
	cmp read_byte.KeyEvent.bKeyDown, 0
	jz input_loop
	mov ax, read_byte.KeyEvent.wVirtualKeyCode
	and eax, 0ffffh	
	cmp al, 13
	jz end_input
	cmp bh, 4
	jz input_loop
	cmp al, '0'
	jb input_loop
	cmp al, '9'
	ja input_loop
	mov bl, al
	sub al, '0'
	shl edi, 1
	add eax, edi
	shl edi, 2
	add edi, eax
	inc bh
	mov al, bl
	mov chislo, al
	invoke WriteConsole, stdout, offset chislo, 1, ADDR count_byte, 0	
	jmp input_loop
end_input:	
	cmp bh, 0
	jz input_loop
	mov eax, edi
	ret
input endp

end start
