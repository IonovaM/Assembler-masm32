.386
.model flat,stdcall
option casemap:none
include includes\kernel32.inc
include includes\user32.inc
includelib includes\kernel32.lib
includelib includes\user32.lib
BSIZE equ 100
.data
	ifmt db "%d", 0
	bfr db BSIZE dup(?)
	buf db BSIZE dup(?)
	stdout dd ?
	stdin dd ?
	cWritten dd ?
	a dd 0
    b dd 0
    s dd 1
    d dd 0
    e dd 1
    f dd 0
    g dd 1
    h dd 0
    k dd 1
    m dd 0
    newline db 13, 10, 0 ; Перевод строки (CRLF)
.code
start:
	invoke GetStdHandle, -10
	mov stdin, eax
	invoke ReadConsoleA, stdin, ADDR bfr, BSIZE, ADDR cWritten, 0
	
	invoke GetStdHandle, -11
	mov stdout, eax
	invoke WriteConsoleA, stdout, ADDR bfr, BSIZE, ADDR cWritten, 0
	invoke WriteConsoleA, stdout, ADDR newline, 1, 0, 0 ; переход на новую строку для красоты вывода следующей

;(ab + c/d) e + f/(g+h)+km
;(a or b + c and d) or e + f and (g + h) + k or m
;   3    1    2     8    5    7     4    6    9
    mov eax, b
    add eax, s
    and eax, d
     or eax, a ; (a or b + c and d)
    mov ecx, g
    add ecx, h ; (g + h)
    mov ebx, e
    add ebx, f ; e + f
    add ecx, k ; () + k
    and ebx, ecx ; e + f and (g + h) + k
     or eax, ebx
     or eax, m ; () or () or m

	; Форматирование результата в строку
	invoke wsprintf, ADDR buf, ADDR ifmt, eax

	; Вывод результата
	invoke GetStdHandle, -11
	mov stdout, eax
	invoke WriteConsoleA, stdout, addr buf, BSIZE, ADDR cWritten, 0
	invoke WriteConsoleA, stdout, addr newline, sizeof newline - 1, 0, 0

	invoke ExitProcess,0
end start
