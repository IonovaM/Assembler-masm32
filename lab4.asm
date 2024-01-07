.386
.model flat, stdcall
option casemap:none
include includes\user32.inc
includelib includes\user32.lib
include includes\kernel32.inc
includelib includes\kernel32.lib
include includes\msvcrt.inc
includelib includes\msvcrt.lib
.data
    dividend dd 60    ; a
    divider dd ?      ; x
    y1 dd ?
    y2 dd ?
    y dd ?
    ostatok dd ?
    ost dd 0
    hex dd 16
    remainder dd ?
    remainder1 dd ?
    remainder2 dd ?
    remainder3 dd ?
    remainder4 dd ?
    remainder5 dd ?
    decimal dd 1000000   ; Количество десятичных знаков после запятой
    decFormat db "x = %d		y = %d.%d		y1 = %d		y2 = %d.%d", 10, 0
    hexFormat db "x = %X		y = %X.%X%X%X%X%X		y1 = %2X		y2 = %X.%X%X%X%X%X", 10, 0
    emptyLine db 10, 0    ; Для вывода пустой строки
.code
start:
    mov divider, 0
    y1_calculated:
    ; Проверка условия |x| > 4
	mov eax, divider
    	or eax, eax
    	jns positive
    	neg eax
    	positive:
    	cmp eax, 4
    	jnge x_leq_4
    	jnle x_gt_4
    x_leq_4:
    ; x <= 4
    	mov eax, dividend
    	mov y1, eax
    	add y1, 4
    	jmp y2_calculated
    x_gt_4:
    ; x > 4
    	mov eax, divider
    	mov y1, eax
    	shl y1, 1
    y2_calculated:
    ; Проверка условия x == 0
    	cmp divider, 0
    	je x_is_0
    	jne x_not_0
    x_is_0:
    ; x == 0
    	mov y2, 9
    	jmp calculate_y
    x_not_0:
    ; x != 0
    	mov eax, dividend
    	xor edx, edx  ; Обнуляем edx (остаток)
    	div divider    ; a/x,  результат в eax, остаток в edx
; Разделяем результат на целую и дробную части
		mov y2, eax 	; Сохраняем целую часть
		
; Умножаем остаток (дробную часть) на 1000000 (для получения пяти знаков после запятной: шестой для округления)
		mov eax, edx
		mul decimal 	; Результат в eax
		div divider  ; Делим на x, результат в eax

; Округление: если последняя цифра (единицы) >= 5, увеличиваем предпоследнюю цифру (десятки) на 1
		mov ecx, 10     ; Делитель для определения последней цифры
		mov edx, 0   	; Сбрасываем остаток
		div ecx      	; Делим на 10
		cmp edx, 5
		jbe done      	; Если последняя цифра <= 5 переходим сразу на вывод
		add eax, 1    	; Округляем: увеличиваем предпоследнюю цифру на 1

    done:
    	mov remainder, eax ; Сохраняем округленную дробную часть
    
    calculate_y:
    ; Вычисление y = y1 + y2
		mov eax, y1
		add eax, y2
		mov y, eax
		invoke crt_printf, offset decFormat, divider, y, remainder, y1, y2, remainder
		
; перевод остатка в шестнадцатеричную систему счисления
; организован перевод уже округленной дробной части
		mov ostatok, 0
		oostatok:
			mov eax, remainder
			mov ecx, 100000
			mul hex
			div ecx
			mov remainder, edx
			mov ost, eax
			push ost
			inc ostatok
			cmp ostatok, 4
			jbe oostatok
		
		pop remainder1
		pop remainder2
		pop remainder3
		pop remainder4
		pop remainder5
		invoke crt_printf, offset hexFormat, divider, y,remainder5, remainder4, remainder3, remainder2, remainder1, y1, y2, remainder5, remainder4, remainder3, remainder2, remainder1 ; вывод в 16сс
		
		; Вывод пустой строки
		invoke crt_printf, offset emptyLine
		inc divider
		cmp divider, 15
		jbe y1_calculated

Exit:
    invoke ExitProcess, 0
end start
