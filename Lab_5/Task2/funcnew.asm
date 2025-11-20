str_number:
  xor rax, rax
  xor rbx, rbx
  .loop:
    mov bl, [rsi]
    cmp bl, 0
    je .end
    cmp bl, '0'
    jl .end
    cmp bl, '9'
    jg .end
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .loop
  .end:
    ret

exit:
  mov rax, 60
  mov rdi, 0
  syscall
