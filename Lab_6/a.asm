format ELF64

public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep

section '.bss' writable
    xmax dq 1
    ymax dq 1
    palette dq 1
    delay dq 50000  ; Увеличена задержка до 50000 микросекунд (50 мс)
    step dq ?

section '.text' executable

_start:
    call initscr
    xor rdi, rdi
    mov rdi, [stdscr]
    call getmaxx
    dec rax
    mov [xmax], rax
    call getmaxy
    dec rax
    mov [ymax], rax

    call start_color

    ; COLOR_WHITE
    mov rdi, 1
    mov rsi, 7
    mov rdx, 7
    call init_pair

    ; COLOR_CYAN
    mov rdi, 2
    mov rsi, 6
    mov rdx, 6
    call init_pair

    call refresh
    call noecho
    call raw

    mov rax, ' '
    or rax, 0x100
    mov [palette], rax
    mov r8, [xmax]    ; Начинаем с правого края
    mov r9, [ymax]    ; Начинаем с нижнего края
    mov [step], -1    ; Двигаемся вверх

    .main_loop:
        cmp r8, 0     ; Проверяем, достигли ли левого края
        jg .loop
        mov r8, [xmax] ; Сбрасываем в правый нижний угол
        mov r9, [ymax]
        mov [step], -1

        mov rax, [palette]
        and rax, 0x100
        cmp rax, 0
        jne .mag
        mov rax, [palette]
        and rax, 0xff
        or rax, 0x100
        jmp @f
        .mag:
        mov rax, [palette]
        and rax, 0xff
        or rax, 0x200
        @@:
        mov [palette], rax

    .loop:
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh
        mov rdi, 1
        call timeout
        call getch

        cmp rax, 'o'
        jne @f
        jmp .exit

        @@:
        cmp rax, 'w'
        jne @f
        cmp [delay], 50000  ; Обновлено значение для проверки
        je .fast
        mov [delay], 50000  ; Нормальная скорость
        jmp @f
        .fast:
        mov [delay], 10000  ; Быстрая скорость (все еще медленнее, чем было)
        @@:
        mov rdi, [delay]
        call usleep

        pop r9
        pop r8
        add r9, [step]    ; Изменяем Y координату (движение по вертикали)
        cmp r9, 0
        jl .chdir_up
        cmp r9, [ymax]
        jg .chdir_down
        jmp .loop

    .chdir_up:
        mov [step], 1     ; Меняем направление на вниз
        mov r9, 0         ; Корректируем позицию
        dec r8            ; Двигаемся влево
        jmp .main_loop

    .chdir_down:
        mov [step], -1    ; Меняем направление на вверх
        mov r9, [ymax]    ; Корректируем позицию
        dec r8            ; Двигаемся влево
        jmp .main_loop

    .exit:
    call endwin
    call exit
