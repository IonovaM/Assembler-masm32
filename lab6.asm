.386
.model flat,stdcall
option casemap:none
include includes\windows.inc
include includes\user32.inc
include includes\kernel32.inc
includelib includes\kernel32.lib
includelib includes\user32.lib

.data
inFileName	db 'in.txt',0
outFileName	db 'out.txt',0
inHandle		dd 0
outHandle		dd 0
str_in		db 1024 dup (0)
str_out		db 1024 dup (0)
str_number	dd 0
symbols		dd 0
symbolbuff	db 8 dup(0)

.code
WriteNumberToFile proc
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
	stosb
	loop convert_loop1
	pop ebx
	pop edx
	pop ecx
	ret
WriteNumberToFile endp
start:
	invoke CreateFileA, offset inFileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov inHandle, eax
	invoke CreateFileA, offset outFileName, GENERIC_WRITE, 0, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov outHandle, eax
read_loop:	
	push edi
	push ebx
	push ecx
	push edx
	lea edi, str_in
str_loop:
	invoke ReadFile, inHandle, offset symbolbuff, 1, offset symbols, NULL
	cmp symbols, 0
	jz end_read
	mov al, symbolbuff
	cmp al, 0dh
	jz next_str
	stosb
	jmp str_loop
next_str:
	invoke ReadFile, inHandle, offset symbolbuff, 1, offset symbols, NULL
strlen:
	mov eax, edi
	sub eax, offset str_in
	jmp end_srt
end_read:	
	cmp edi, offset str_in
	jnz strlen
	mov eax, -1
end_srt:	
	mov [edi], byte ptr 0
	pop edx
	pop ecx
	pop ebx
	pop edi

	cmp eax, -1
	jz file_end
	mov ebp, eax
	inc str_number
	mov ebx, 0
	lea esi, str_in
split_words_loop:
	lodsb		
	cmp al, 0
	jz str_end
	cmp al, ' '
	jnz spaceFound
	jmp split_words_loop
spaceFound:	
	dec esi
	mov edi, esi
get_word_loop:
	lodsb
	cmp al, 0
	jz word_end
	cmp al, ' '
	jz word_end
	jmp get_word_loop
word_end:	
	dec esi
	mov edx, esi
	mov ecx, esi
	sub ecx, edi
	shr ecx, 1
	jecxz isPalindrome
	dec esi
check_palindrome:
	cmpsb
	jnz notPalindrome
	sub esi, 2
	loop check_palindrome
isPalindrome:
	inc ebx
notPalindrome:
	mov esi, edx
	jmp split_words_loop
str_end:
	lea edi, str_out
	mov eax, str_number
	call WriteNumberToFile
	mov al, ' '
	stosb
	;mov ecx, ebp
	;jecxz skip
	;lea esi, strf
	;rep movsb
end_check:
	mov al, '-'		
	stosb
	mov al, ' '
	stosb
	mov eax, ebx
	call WriteNumberToFile	
	mov al, 13
	stosb
	mov al, 10
	stosb				
	
	mov ecx, edi
	sub ecx, offset str_out
	invoke WriteFile, outHandle, offset str_out, ecx, offset symbols, NULL
	jmp read_loop
file_end:
	invoke CloseHandle, inHandle
	invoke CloseHandle, outHandle
exit:	
	invoke ExitProcess, 0
end start
