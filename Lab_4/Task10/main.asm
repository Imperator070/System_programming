format ELF64
public _start
include "func.asm"

section '.data' writable
   wrong db "Неверный пароль", 0xA, 0
   right db "Вошли", 0xA, 0
   fail db "Неудача", 0xA, 0

section '.bss' writable
   parol rb 255     ; Буфер для правильного пароля
   try rb 255       ; Буфер для попытки ввода

section '.text' executable

_start:
   ; Ввод правильного пароля
   mov rsi, parol
   call input_keyboard

   mov rbx, 5       ; 5 попыток
   
check:
   ; Ввод попытки пароля
   mov rsi, try
   call input_keyboard

   ; Сравнение строк
   mov rsi, parol
   mov rdi, try
   call compare_strings
   cmp rax, 0
   je good          ; Если равны - успех

   dec rbx          ; Уменьшаем счётчик попыток
   jz failed        ; Если попытки кончились - неудача

bad:
   ; Неверный пароль
   mov rsi, wrong
   call print_str
   jmp check        ; Повторяем ввод

failed:
   ; Неудача после 5 попыток
   mov rsi, fail
   call print_str
   call exit

good:
   ; Успешный вход
   mov rsi, right
   call print_str
   call exit

; Функция сравнения строк
compare_strings:
    push rsi
    push rdi
    push rbx
.loop:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne .not_equal
    test al, al        ; Проверка конца строки (0)
    jz .equal
    inc rsi
    inc rdi
    jmp .loop
.equal:
    xor rax, rax       ; Возвращаем 0 (равны)
    jmp .end
.not_equal:
    mov rax, 1         ; Возвращаем 1 (не равны)
.end:
    pop rbx
    pop rdi
    pop rsi
    ret