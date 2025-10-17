format ELF64

public _start

include 'funcnew.asm'

section '.bss' writable
    buffer     db 101
    buf        db ?

section '.text' executable
_start:
    pop rcx
    cmp rcx, 1
    je .l1

    mov rdi, [rsp+8]
    mov rax, 2
    mov rsi, 0
    syscall
    cmp rax, 0
    jl .l1
    mov r8, rax
    mov rdi, [rsp+16]
    mov rax, 2
    mov rsi, 1101o
    syscall
    cmp rax, 0
    jl .l1
    mov r9, rax

    xor rcx, rcx
.loop_read:
    push rcx
    mov rax, 0
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 1
    syscall
    pop rcx
    cmp rax, 0
    je .next
    cmp byte [buffer], '.'
    je .reverse_write
    cmp byte [buffer], '!'
    je .reverse_write
    cmp byte [buffer], '?'
    je .reverse_write
    mov al, [buffer]
    mov [buf+rcx], al
    inc rcx
    jmp .loop_read
.reverse_write:
    dec rcx
    add rax, buf
    mov rsi, buf
    add rsi, rcx
    push rcx
    mov rax, 1
    mov rdi, r9
    mov rdx, 1
    syscall
    pop rcx
    mov [buf+rcx], 0
    cmp rcx, 0
    jg .reverse_write
    mov rsi, buffer
    mov rax, 1
    mov rdi, r9
    mov rdx, 1
    syscall
    xor rcx, rcx
    jmp .loop_read
.next:
    mov rax, buf
    call len_str
    cmp rax, 0
    je .closing
    mov rsi, buf
    mov rdx, rax
    mov rax, 1
    mov rdi, r9
    syscall
.closing:
    mov rdi, r8
    mov rax, 3
    syscall
    mov rdi, r9
    mov rax, 3
    syscall

.l1:
    call exit
