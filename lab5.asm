.386
.model flat,stdcall
option casemap:none
include kernel32.inc
include user32.inc
includelib kernel32.lib
includelib user32.lib
include msvcrt.inc
includelib msvcrt.lib
BSIZE equ 256
.data
ifmt db "%0x", 0
nstr byte 13, 10
count byte 0
stdin dd ?
emptyLine db 10, 0
bin_str1 byte ?
bin_str2 byte ?
buffer_key_1 byte BSIZE dup(?)
cdkey dd ?
rez dd 0
count2 byte 8
bitcount byte 0

.code
start:
	invoke GetStdHandle, -10
	mov stdin, eax
    @1:
		invoke ReadConsoleInput, stdin, ADDR buffer_key_1, BSIZE, ADDR cdkey;
		cmp count, 1
		je next_byte
		cmp [buffer_key_1 + 14d], 0Dh 
		je @2

    check: 
		cmp [buffer_key_1 + 14d], 0 
		je @1 
		cmp [buffer_key_1 + 14d], 30h 
		jl @1 
		cmp [buffer_key_1 + 14d], 31h 
		jg @1 
		cmp [buffer_key_1 + 04d], 1h 
		jne @1 
		cmp bitcount, 8 
		je @1 
		
    result:
		inc bitcount 
		mov eax, rez 
		shl al, 1 
		mov rez, eax
		xor eax, eax
		mov al, [buffer_key_1 + 14d]
		sub al, 30h
		add rez, eax 
		invoke crt_printf, offset ifmt, al
		jmp @1 
			
    next_byte:
		inc count
		invoke crt_printf, offset emptyLine
		jmp check

    @2:
		cmp bitcount, 0 
		je @1 	
		inc count 
		mov bitcount, 0 
		mov al, bin_str1 
		mov bin_str2, al 
		mov eax, rez 
		mov bin_str1, al	
		cmp count, 3 
		jne @1 



    and bin_str2 , 10101010b    
	mov al, bin_str1 
    or al, bin_str2        
    and al, 10101010b
    mov bin_str1, al
    shr bin_str1, 2       
	not bin_str1 
 	invoke crt_printf, offset emptyLine
 	
 	
 	mov eax, DWORD PTR [bin_str1] 
	mov ecx, 8       
reverse_loop:
	shr eax, 1      
	rcl bin_str1, 1  
	loop reverse_loop 
	mov eax, 0
	mov al, 0
           print_bit:   
		mov bl, 1        ; Устанавливаем маску на 00000001b
           print_loop:
		mov al, bin_str1   
		and al, bl       
		test al, al      ; Проверяем выделенный бит
		jz zero_bit        
		invoke crt_printf, offset ifmt, 1
		jmp continue_print
            zero_bit:
		invoke crt_printf, offset ifmt, 0 
            continue_print:
		shr bin_str1, 1     
		dec count2           
		cmp count2, 0
		jne print_loop    
		
    invoke crt_printf, offset emptyLine
    invoke ExitProcess, 0 
end start
