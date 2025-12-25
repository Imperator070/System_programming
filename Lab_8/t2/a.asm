format ELF64
public _start

extrn printf
extrn scanf
extrn exit

SYS_EXIT        = 60
EXIT_SUCCESS    = 0

section '.data' writeable
    input_format      db "%lf", 0
    table_header      db "%-10s%-15s%-15s%-15s", 10, 0
    table_row         db "%-10.6f%-15.6f%-15.6f%-15d", 10, 0
    analytic_header   db 10, "Analytic value (left side): %.10f", 10, 0
    series_header     db 10, "Series iterations (right side):", 10, 0
    iter_format       db "Iter %-5d: term = %-15.10f, sum = %-15.10f", 10, 0
    final_result      db 10, "Final result: %.10f", 10, "Iterations: %d", 10, 0

    label_x           db "x", 0
    label_analytic    db "analytic", 0
    label_series      db "series", 0
    label_iterations  db "terms", 0

    prompt_x          db "Enter x (-1 < x < 1): ", 0
    prompt_precision  db "Enter epsilon: ", 0
    newline           db 10, 0
    error_msg         db "Error: |x| must be < 1", 10, 0

    constant_one      dq 1.0
    constant_two      dq 2.0
    constant_four     dq 4.0
    constant_neg_one  dq -1.0

    input_value       rq 1        
    precision_value   rq 1        
    analytic_value    rq 1        
    series_sum        rq 1        
    iteration_num     rq 1        
    current_term      rq 1        
    x_power          rq 1        
    temp_buffer      rq 1        

section '.text' executable

_start:
    ; Ввод x
    mov rdi, prompt_x
    xor rax, rax
    call printf

    mov rdi, input_format
    mov rsi, input_value
    xor rax, rax
    call scanf

    ; Ввод epsilon
    mov rdi, prompt_precision
    xor rax, rax
    call printf

    mov rdi, input_format
    mov rsi, precision_value
    xor rax, rax
    call scanf

    ; Проверка |x| < 1
    finit
    fld qword [input_value]
    fabs
    fld1
    fcomip st1
    fstp st0
    jbe .input_error

    ; Вычисление аналитического значения (левая часть)
    call compute_analytic
    fstp qword [analytic_value]

    ; Вывод аналитического значения
    mov rdi, analytic_header
    movq xmm0, [analytic_value]
    mov rax, 1
    call printf

    mov rdi, series_header
    xor rax, rax
    call printf

    ; Вычисление ряда (правая часть) с выводом итераций
    call compute_series

    ; Вывод финального результата
    mov rdi, final_result
    movq xmm0, [series_sum]
    mov rsi, [iteration_num]
    mov rax, 1
    call printf

    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.input_error:
    mov rdi, error_msg
    xor rax, rax
    call printf
    
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

compute_analytic:
    push rbp
    mov rbp, rsp
    
    ; (1+x)/(1-x)
    fld1
    fadd qword [input_value]     ; st0 = 1+x
    fld1
    fsub qword [input_value]     ; st0 = 1-x, st1 = 1+x
    fdivp st1, st0               ; st0 = (1+x)/(1-x)
    
    ; Вычисляем ln((1+x)/(1-x))
    fldln2                       ; st0 = ln(2), st1 = (1+x)/(1-x)
    fxch st1                     ; st0 = (1+x)/(1-x), st1 = ln(2)
    fyl2x                        ; st0 = ln((1+x)/(1-x)) = ln(2) * log2((1+x)/(1-x))
    
    fld1
    fld qword [constant_four]
    fdivp st1, st0               ; st0 = 1/4
    fmulp st1, st0               ; st0 = (1/4)*ln((1+x)/(1-x))
    
    fst qword [temp_buffer]
    
    fld qword [input_value]      ; st0 = x
    fld1                         ; st0 = 1, st1 = x
    fpatan                       ; st0 = arctan(x)
    
    fld1
    fld qword [constant_two]
    fdivp st1, st0               ; st0 = 1/2
    fmulp st1, st0               ; st0 = (1/2)*arctan(x)
    
    fadd qword [temp_buffer]     ; st0 = (1/4)*ln((1+x)/(1-x)) + (1/2)*arctan(x)
    
    leave
    ret

compute_series:
    push rbp
    mov rbp, rsp

    finit
    fldz
    fstp qword [series_sum]      
    mov qword [iteration_num], 0

    fld qword [input_value]
    fstp qword [x_power]

    .series_loop:
        inc qword [iteration_num]

        fild qword [iteration_num]
        fld1
        fsubp st1, st0           ; n = iteration_num - 1
        fld qword [constant_four]
        fmulp st1, st0           ; 4n
        fld1
        faddp st1, st0           ; 4n + 1
        fst st1         
        
        fld qword [x_power]      ; st0 = x^(4n+1)
        
        ; x^(4n+1) / (4n+1)
        fdivrp st1, st0          ; st0 = x^(4n+1) / (4n+1)
        fst qword [current_term] ; сохраняем текущий член

        fadd qword [series_sum]
        fstp qword [series_sum] 

        ; Вывод текущей итерации
        mov rdi, iter_format
        mov rsi, [iteration_num]
        movq xmm0, [current_term]
        movq xmm1, [series_sum]
        mov rax, 2
        call printf

        ; Обновляем степень x для следующей итерации: умножаем на x^4
        fld qword [x_power]
        fld qword [input_value]
        fmul st0, st0            ; x^2
        fmul st0, st0            ; x^4
        fmulp st1, st0           ; x_power * x^4
        fstp qword [x_power]

        ; |current_term| < epsilon
        fld qword [current_term]
        fabs
        fld qword [precision_value]
        fcomip st1
        fstp st0
        jbe .check_max_iter   

        jmp .loop_end

    .check_max_iter:
        cmp qword [iteration_num], 1000000
        jl .series_loop

    .loop_end:
        leave
        ret