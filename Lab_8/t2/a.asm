format ELF64
public _start

extrn printf
extrn scanf
extrn exit

SYS_EXIT        = 60
EXIT_SUCCESS    = 0

section '.data' writeable
    input_format      db "%lf", 0
    table_header      db "%-10s%-15s%-15s", 10, 0
    table_row         db "%-10.6f%-15.6f%-15d", 10, 0

    label_x           db "x", 0
    label_precision   db "epsilon", 0
    label_iterations  db "terms", 0

    prompt_x          db "Enter x (-1 < x < 1): ", 0
    prompt_precision  db "Enter epsilon: ", 0
    newline           db 10, 0

    constant_one      dq 1.0
    constant_four     dq 4.0

    input_value       rq 1        ; входной x
    precision_value   rq 1        ; точность
    series_sum        rq 1        ; сумма ряда
    iteration_num     rq 1        ; счетчик итераций
    current_value     rq 1        ; текущий член ряда
    storage_buffer    rq 1        ; временный буфер
    x_exponent        rq 1        ; степень x

section '.text' executable

_start:
    mov rdi, prompt_x
    xor rax, rax
    call printf

    mov rdi, input_format
    mov rsi, input_value
    xor rax, rax
    call scanf

    mov rdi, prompt_precision
    xor rax, rax
    call printf

    mov rdi, input_format
    mov rsi, precision_value
    xor rax, rax
    call scanf

    finit
    fld qword [input_value]
    fabs
    fld1
    fcomip st1
    fstp st0
    jbe .input_error

    call compute_analytic
    fstp qword [storage_buffer]

    call compute_series

    mov rdi, table_header
    mov rsi, label_x
    mov rdx, label_precision
    mov rcx, label_iterations
    xor rax, rax
    call printf

    mov rdi, table_row
    movq xmm0, [input_value]
    movq xmm1, [precision_value]
    mov rsi, [iteration_num]
    mov rax, 2
    call printf

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

    .input_error:
        mov rdi, newline
        call printf
        mov rdi, newline
        call printf

        mov rax, SYS_EXIT
        mov rdi, 1
        syscall


compute_analytic:
    push rbp
    mov rbp, rsp

    fld1
    fadd qword [input_value]
    fld1
    fsub qword [input_value]
    fdivp st1, st0
    fyl2x
    fldln2
    fmulp st1, st0

    fld qword [constant_one]
    fld qword [constant_four]
    fdivp st1, st0
    fmulp st1, st0

    fld qword [input_value]
    fld1
    fpatan

    fld1
    fadd st0, st0
    fdivrp st1, st0

    faddp st1, st0

    leave
    ret


compute_series:
    push rbp
    mov rbp, rsp

    finit
    fldz
    fstp qword [series_sum]

    mov qword [iteration_num], 0
    mov qword [x_exponent], 1

    fld qword [input_value]
    fstp qword [current_value]
    fld qword [input_value]
    fstp qword [x_exponent]

    .series_loop:
        inc qword [iteration_num]

        finit
        fld qword [x_exponent]

        fld qword [input_value]
        fmul st0, st0
        fmul st0, st0
        fmulp st1, st0
        fst qword [x_exponent]

        fild qword [iteration_num]
        fld qword [constant_four]
        fmulp st1, st0
        fld1
        faddp st1, st0

        fdivp st1, st0
        fst qword [current_value]

        fadd qword [series_sum]
        fstp qword [series_sum]

        fld qword [current_value]
        fabs
        fld qword [precision_value]
        fcomip st1
        fstp st0
        jb .continue_loop
        jmp .loop_end

    .continue_loop:
        cmp qword [iteration_num], 1000000
        jl .series_loop

    .loop_end:
        leave
        ret
