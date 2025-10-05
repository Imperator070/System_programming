format ELF64
public _start
place db "23453", 0
a dq 0
b dq 0
c dq 0
chis dq 0
include 'func.asm'


_start:
    add rsp, 16
    xor rsi, rsi
    xor rax, rax
    pop rsi
    call str_to_int
    mov [a], rax
    xor rsi, rsi
    pop rsi
    call str_to_int
    mov [b], rax
    xor rsi, rsi
    pop rsi
    call str_to_int
    mov [c], rax
    xor rsi, rsi

    mov rax, [a]       ; Загружаем a в rax
    cqo                ; Знаковое расширение rax в rdx:rax
    idiv qword [b]     ; rax = a / b
    sub rax, [a]       ; rax = (a/b) - a
    add rax, [c]       ; rax = ((a/b)-a) + c
    cqo                ; Знаковое расширение для деления
    idiv qword [c]     ; rax = (((a/b)-a)+c) / c
    imul rax, [b]      ; rax = ((((a/b)-a)+c)/c) * b

    call print_int
    xor rsi, rsi
    call new_line
    call exit


str_to_int:
    push rsi
    push rbx
    push rcx
    push rdx
    xor rax, rax
    xor rdx, rdx
    mov rcx, 10
    itera:
        mov byte bl, [rsi + rdx]

        cmp bl, '0'
        jl next
        cmp bl, '9'
        jg next
        sub bl, '0'
        add rax, rbx
        cmp byte [rsi+rdx+1], 0
        je next
        push rdx
        mov rcx, 10
        mul rcx
        pop rdx
        inc rdx
    jmp itera
    next:
    pop rdx
    pop rcx
    pop rbx
    pop rsi
  ret

print_int:
    mov rcx, 10
    xor rbx, rbx
    .iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax,0
    jne .iter1
    .iter2:
      pop rax
      call print_symbl
      dec rbx
      cmp rbx, 0
    jne .iter2
 ret