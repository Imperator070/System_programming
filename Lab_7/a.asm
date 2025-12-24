format ELF64
public _start

SYS_READ = 0
SYS_WRITE = 1
SYS_FORK = 57
SYS_EXECVE = 59
SYS_WAIT4 = 61
SYS_EXIT = 60
STDIN = 0
STDOUT = 1

section '.data' writeable
    cmd_prompt db "Введите команду: ", 0
    prompt_length = $ - cmd_prompt
    exec_error db "Ошибка: не удалось запустить программу", 10, 0
    error_length = $ - exec_error
    linebreak db 10

section '.bss' writeable
    command_buffer rb 256
    arg_pointers rq 16
    wait_status dd 1
    process_id rq 1
    env_ptr dq 0

section '.text' executable

_start:
    pop rcx
    lea rdi, [rsp + rcx*8 + 8]
    mov [env_ptr], rdi

shell_loop:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, cmd_prompt
    mov rdx, prompt_length
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, command_buffer
    mov rdx, 255
    syscall

    cmp rax, 1
    jle shell_loop

    dec rax
    mov byte [command_buffer + rax], 0

    call parse_command_line

    mov rax, SYS_FORK
    syscall

    test rax, rax
    js fork_failed
    jz execute_command

    mov [process_id], rax

wait_for_child:
    mov rax, SYS_WAIT4
    mov rdi, [process_id]
    mov rsi, wait_status
    mov rdx, 0
    mov r10, 0
    syscall

    jmp shell_loop

execute_command:
    mov rdx, [env_ptr]

    mov rax, SYS_EXECVE
    mov rdi, [arg_pointers]
    mov rsi, arg_pointers
    syscall

    call show_error
    call terminate

fork_failed:
    jmp shell_loop

parse_command_line:
    push rsi
    push rdi
    push rcx
    push rax
    push rbx

    lea rsi, [command_buffer]
    lea rdi, [arg_pointers]
    xor rcx, rcx

.skip_whitespace:
    mov al, [rsi]
    test al, al
    jz .parsing_done
    cmp al, ' '
    jne .begin_argument
    inc rsi
    jmp .skip_whitespace

.begin_argument:
    mov [rdi + rcx*8], rsi
    inc rcx

    cmp rcx, 15
    jge .max_args_reached

.find_argument_end:
    mov al, [rsi]
    test al, al
    jz .end_of_input
    cmp al, ' '
    jne .next_char
    mov byte [rsi], 0
    inc rsi
    jmp .skip_whitespace

.next_char:
    inc rsi
    jmp .find_argument_end

.end_of_input:
    mov qword [rdi + rcx*8], 0
    jmp .parsing_complete

.max_args_reached:
    mov qword [rdi + 15*8], 0

.parsing_done:
    mov qword [rdi], 0

.parsing_complete:
    pop rbx
    pop rax
    pop rcx
    pop rdi
    pop rsi
    ret

show_error:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, exec_error
    mov rdx, error_length
    syscall
    ret

terminate:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

output_newline:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, linebreak
    mov rdx, 1
    syscall
    ret
