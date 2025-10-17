section '.text' executable

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

len_str:
    push rsi
    mov rsi, rax
    xor rax, rax
.count_loop:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .count_loop
.done:
    pop rsi
    ret

print_str:
    push rax
    push rdi
    push rdx
    push rcx
    mov rax, rsi
    call len_str
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

input_str:
    push rax
    push rdi
    push rdx
    mov rax, 0
    mov rdi, 0
    syscall
    mov rcx, rax
    dec rcx
    mov byte [rsi + rcx], 0
    pop rdx
    pop rdi
    pop rax
    ret

str_to_number:
    push rbx
    push rcx
    xor rax, rax
    xor rcx, rcx
.convert_loop:
    mov bl, [rsi + rcx]
    cmp bl, 0
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    sub bl, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .convert_loop
.done:
    pop rcx
    pop rbx
    ret

number_to_str:
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    mov rbx, 10
.convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .convert_loop
    xor rdx, rdx
.store_loop:
    pop rax
    mov [rsi + rdx], al
    inc rdx
    loop .store_loop
    mov byte [rsi + rdx], 0
    pop rdx
    pop rcx
    pop rbx
    ret

open_file:
    mov rax, 2
    syscall
    ret

close_file:
    mov rax, 3
    syscall
    ret

read_file:
    mov rax, 0
    syscall
    ret

write_file:
    mov rax, 1
    syscall
    ret

print_char:
    push rsi
    push rdx
    push rdi
    push rax
    mov [char_buffer], al
    mov rax, 1
    mov rdi, 1
    mov rsi, char_buffer
    mov rdx, 1
    syscall
    pop rax
    pop rdi
    pop rdx
    pop rsi
    ret

section '.bss' writable
    char_buffer db 0
