format ELF64
public _start

SYS_READ        = 0
SYS_WRITE       = 1
SYS_CLOSE       = 3
SYS_SOCKET      = 41
SYS_CONNECT     = 42
SYS_EXIT        = 60
AF_INET         = 2
SOCK_STREAM     = 1

section '.data' writeable
    notify_connect  db 'Initiating duel...', 10, 0

    target_address:
        dw AF_INET
        db 0x1E, 0x61
        db 127,0,0,1
        dq 0

    comm_socket     dq 0
    server_reply    rb 512
    player_action   db 0

section '.text' executable
_start:
    mov rsi, notify_connect
    call show_text

    mov rax, SYS_SOCKET
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall
    mov [comm_socket], rax

    mov rax, SYS_CONNECT
    mov rdi, [comm_socket]
    mov rsi, target_address
    mov rdx, 16
    syscall

match_loop:
    mov byte [server_reply], 0
    mov rax, SYS_READ
    mov rdi, [comm_socket]
    mov rsi, server_reply
    mov rdx, 511
    syscall

    cmp rax, 0
    jle disconnect

    mov rdx, rax
    mov rax, SYS_WRITE
    mov rdi, 1
    syscall

    mov rax, SYS_READ
    mov rdi, 0
    mov rsi, player_action
    mov rdx, 2
    syscall

    mov rax, SYS_WRITE
    mov rdi, [comm_socket]
    mov rsi, player_action
    mov rdx, 1
    syscall

    jmp match_loop

disconnect:
    mov rax, SYS_CLOSE
    mov rdi, [comm_socket]
    syscall
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

show_text:
    push rdi
    push rax
    push rdx
    push rcx
    mov rdi, rsi
    call text_length
    mov rdx, rax
    mov rax, SYS_WRITE
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rax
    pop rdi
    ret

text_length:
    xor rax, rax
.loop_check:
    cmp byte [rdi + rax], 0
    je .length_ready
    inc rax
    jmp .loop_check
.length_ready:
    ret
