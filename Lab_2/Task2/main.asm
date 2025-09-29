format ELF64
public _start
public exit

section '.bss' writable
plus db "*"
newline db 0xA
M db 7
K db 13

section '.text' executable
_start:
  mov cl, [K]

  .iter1:
    push rcx
    mov dl,[M]

    .iter2:
        push rdx
        mov rcx, plus

        mov rax, 4
        mov rbx, 1
        mov rdx, 1
        int 0x80
        pop rdx
        dec rdx
        cmp rdx, 0
        jne .iter2


    mov rax, 4
    mov rbx, 1
    mov rdx, 1
    mov rcx, newline
    int 0x80


    pop rcx
    dec rcx
    cmp rcx, 0
    jne .iter1


  call exit


exit:
  mov rax, 1
  xor rbx, rbx
  int 0x80
