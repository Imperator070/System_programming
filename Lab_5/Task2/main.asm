format ELF64

public _start

include 'funcnew.asm'

section '.bss' writable
  reading_buffer rb 1
  writing_buffer rb 1

section '.text' executable
_start:

  pop rcx
  cmp rcx, 4
  jne .l1
  pop rcx

  pop rdi
  pop r14
  pop rsi
  call str_number
  mov r15, rax

  mov rax, 2
  mov rsi, 0o
  syscall
  cmp rax, 0
  jl .l1

  mov r8, rax
  mov rdi, r14
  mov rax, 2
  mov rsi, 577
  mov rdx, 777o
  syscall

  mov r10, rax

  .loop_read:
    mov rax, 0
    mov rdi, r8
    mov rsi, writing_buffer
    mov rdx, r15
    dec rdx
    cmp rdx, 0
    jle .read_byte
    syscall
    cmp rax, rdx
    jne .next

  .read_byte:
    mov rax, 0
    mov rdi, r8
    mov rsi, reading_buffer
    mov rdx, 1
    syscall
    cmp rax, 0
    je .next

    mov rax, 1
    mov rdi, r10
    mov rsi, reading_buffer
    mov rdx, 1
    syscall

    jmp .loop_read

.next:
  mov rdi, r8
  mov rax, 3
  syscall

  mov rdi, r14
  mov rax, 3
  syscall

.l1:
  call exit
