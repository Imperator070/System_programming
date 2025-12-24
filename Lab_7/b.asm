format ELF64

include 'func.asm'

public _start

THREAD_FLAGS = 2147585792
ARRLEN = 613

section '.bss' writable
    array rb ARRLEN
    buffer rb 20
    f db "/dev/random", 0
    stack1 rq 4096

    msg1 db "Количество чисел, сумма цифр которых кратна 3:", 0xA, 0
    msg2 db "0.75-квантиль:", 0xA, 0
    msg3 db "Количество простых чисел:", 0xA, 0
    msg4 db "Среднее арифметическое:", 0xA, 0
    msg_array db "Массив:", 0xA, 0

section '.text' executable
_start:
    mov rax, 2
    mov rdi, f
    mov rsi, 0
    syscall
    mov r8, rax

    mov rax, 0
    mov rdi, r8
    mov rsi, array
    mov rdx, ARRLEN
    syscall

    .filter_loop:
        call filter
        cmp rax, 0
        jne .filter_loop

    mov rsi, msg_array
    call print_str
    call new_line
    call print_array

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall
    cmp rax, 0
    je .count_sum_digits_div3

    call input_keyboard
    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall
    cmp rax, 0
    je .quantile_75

    call input_keyboard
    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall
    cmp rax, 0
    je .count_primes

    call input_keyboard
    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    mov rax, 56
    mov rdi, THREAD_FLAGS
    mov rsi, 4096
    add rsi, stack1
    syscall
    cmp rax, 0
    je .Arithmetic_mean

    call input_keyboard
    mov rax, 61
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    syscall

    call exit

.count_sum_digits_div3:
    mov rsi, msg1
    call print_str
    call new_line

    xor rcx, rcx
    xor r9, r9

    .loop1:
        cmp r9, ARRLEN
        jge .done1

        mov al, [array + r9]
        call digit_sum
        movzx rax, al
        test rax, 3
        jnz .skip1
        inc rcx
    .skip1:
        inc r9
        jmp .loop1
    .done1:
        mov rax, rcx
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit

.quantile_75:
    mov rsi, msg2
    call print_str
    call new_line

    mov rax, ARRLEN
    mov rbx, 4
    xor rdx, rdx
    div rbx
    mov rbx, 3
    mul rbx

    movzx rax, byte [array + rax]
    mov rsi, buffer
    call number_str
    call print_str
    call new_line
    call exit

.count_primes:
    mov rsi, msg3
    call print_str
    call new_line

    xor rcx, rcx
    xor r9, r9

    .loop3:
        cmp r9, ARRLEN
        jge .done3

        mov al, [array + r9]
        movzx rax, al
        cmp rax, 2
        jl .not_prime

        call is_prime
        test al, al
        jz .not_prime
        inc rcx
    .not_prime:
        inc r9
        jmp .loop3
    .done3:
        mov rax, rcx
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit

.Arithmetic_mean:
    mov rsi, msg4
    call print_str
    call new_line

    xor r8, r8
    xor r9, r9

    .sum_loop:
        cmp r9, ARRLEN
        jge .div_mean
        movzx rax, byte [array + r9]
        add r8, rax
        inc r9
        jmp .sum_loop
    .div_mean:
        mov rax, r8
        mov rbx, ARRLEN
        xor rdx, rdx
        div rbx

        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        call exit

digit_sum:
    push rbx
    push rcx
    movzx rax, al
    xor rcx, rcx
    mov rbx, 10
    .ds_loop:
        xor rdx, rdx
        div rbx
        add rcx, rdx
        test rax, rax
        jnz .ds_loop
    mov al, cl
    pop rcx
    pop rbx
    ret

is_prime:
    push rbx
    push rcx
    cmp rax, 2
    je .prime
    test al, 1
    jz .not_prime2

    mov rbx, 3
    .check_div:
        mov rcx, rbx
        mul rcx

        mov rcx, rax
        xor rdx, rdx
        mov rax, rcx
        div rbx
        test rdx, rdx
        jz .not_prime2
        add rbx, 2
        mov rdx, rbx
        mul rbx
        cmp rax, rcx
        jbe .check_div
    .prime:
        mov al, 1
        jmp .finish_prime
    .not_prime2:
        mov al, 0
    .finish_prime:
        pop rcx
        pop rbx
        ret


print_array:
    xor r9, r9
    .print_loop:
        cmp r9, ARRLEN
        jge .done
        mov al, [array + r9]
        mov rsi, buffer
        call number_str
        call print_str
        call new_line
        inc r9
        jmp .print_loop
    .done:
        ret

filter:
    xor rax, rax
    mov rsi, array
    mov rcx, ARRLEN
    dec rcx
    .check:
        mov dl, [rsi]
        mov dh, [rsi + 1]
        cmp dl, dh
        jbe .ok
        mov [rsi], dh
        mov [rsi + 1], dl
        inc rax
    .ok:
        inc rsi
    loop .check
    ret
