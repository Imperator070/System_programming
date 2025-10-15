format ELF64
public _start
public calcuate_sum

include 'help.asm'
include 'calcuator.asm'

section '.data'
symbol db '-'

section '.bss' writable
    place rb 255
    answer rb 2
    
section '.text' executable
_start:
    mov rsi, place
    call input_keyboard
    call str_number
    call calcuate_sum
    test rdi, 8000h
    jz .non_negative
    call print_minus
    neg rdi
    .non_negative:
    mov rax, rdi
    mov rsi, answer
    call number_str
    call print_str
    call new_line
    call exit