format ELF64
public _start
include "func.asm"

section '.data' writable
    prompt db "Введите число n: ", 0
    result db "Числа, делящиеся на две своих последних цифры:", 0xA, 0
    space db " ", 0

section '.bss' writable
    n_str rb 20
    num_buffer rb 20
    n dq ?

section '.text' executable

_start:
    ; Выводим приглашение
    mov rsi, prompt
    call print_str

    ; Вводим число n
    mov rsi, n_str
    call input_keyboard
    
    ; Преобразуем строку в число (исправленная функция)
    mov rsi, n_str
    call simple_str_to_number
    mov [n], rax

    ; Выводим заголовок результата
    mov rsi, result
    call print_str

    ; Проверяем все числа от 10 до n (меньше 10 не имеют двух цифр)
    mov rbx, 10

check_loop:
    cmp rbx, [n]
    jg program_end

    ; Проверяем текущее число
    mov rax, rbx
    call check_number
    cmp rax, 1
    jne next_number

    ; Выводим подходящее число
    mov rax, rbx
    mov rsi, num_buffer
    call number_str
    call print_str
    
    ; Выводим пробел
    mov rsi, space
    call print_str

next_number:
    inc rbx
    jmp check_loop

program_end:
    call new_line
    call exit

; Простая функция преобразования строки в число
; Вход: RSI = строка
; Выход: RAX = число
simple_str_to_number:
    push rbx
    push rcx
    xor rax, rax        ; обнуляем результат
    xor rcx, rcx        ; обнуляем счётчик
    
.convert_loop:
    mov bl, [rsi + rcx] ; берём текущий символ
    cmp bl, 0           ; конец строки?
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    
    sub bl, '0'         ; преобразуем символ в цифру
    imul rax, 10        ; умножаем результат на 10
    add rax, rbx        ; добавляем новую цифру
    
    inc rcx
    jmp .convert_loop
    
.done:
    pop rcx
    pop rbx
    ret

; Функция проверки числа
; Вход: RAX = число
; Выход: RAX = 1 если подходит, 0 если нет
check_number:
    push rbx
    push rdx
    push rcx
    
    mov rbx, rax        ; сохраняем число в RBX
    
    ; Получаем две последние цифры
    mov rax, rbx
    mov rcx, 100
    xor rdx, rdx
    div rcx             ; RDX = две последние цифры
    
    ; Проверяем, что две последние цифры не 00
    cmp rdx, 0
    je .not_suitable
    
    ; Проверяем делимость числа на две последние цифры
    mov rax, rbx
    mov rcx, rdx
    xor rdx, rdx
    div rcx
    
    cmp rdx, 0          ; Проверяем остаток
    jne .not_suitable
    
    mov rax, 1          ; Число подходит
    jmp .end
    
.not_suitable:
    mov rax, 0          ; Число не подходит

.end:
    pop rcx
    pop rdx
    pop rbx
    ret