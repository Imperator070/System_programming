section '.bss' writable
    place rb 1        ; Буфер для print_symbl

section '.text' executable

;Function exit
exit:
     mov rax, 60
     mov rdi, 0
     syscall

;Function printing of string
;input rsi - place of memory of begin string
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

;The function makes new line
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret

;The function finds the length of a string
;input rax - place of memory of begin string
;output rax - length of the string
len_str:
  push rdx
  mov rdx, rax
  .iter:
      cmp byte [rax], 0
      je .next
      inc rax
      jmp .iter
  .next:
     sub rax, rdx
     pop rdx
     ret

;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
    push rcx
    push rbx
    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished
    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop
.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx
.restore:
    pop rbx
    pop rcx
    ret

;The function converts the nubmer to string
;input rax - number
;rsi -address of begin of string
number_str:
  push rax
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rbx, 10
  .loop_1:
    xor rdx, rdx
    div rbx
    add rdx, 48
    push rdx
    inc rcx
    cmp rax, 0
    jne .loop_1
  xor rdx, rdx
  .loop_2:
    pop rax
    mov byte [rsi+rdx], al
    inc rdx
    dec rcx
    cmp rcx, 0
  jne .loop_2
  mov byte [rsi+rdx], 0   
  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret

;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string
input_keyboard:
  push rax
  push rdi
  push rdx
  mov rax, 0
  mov rdi, 0
  mov rdx, 255
  syscall
  xor rcx, rcx
  .loop:
     mov al, [rsi+rcx]
     inc rcx
     cmp rax, 0x0A
     jne .loop
  dec rcx
  mov byte [rsi+rcx], 0
  pop rdx
  pop rdi
  pop rax
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

print_symbl:
    push rbx
    push rdx
    push rcx
    push rax
    push rsi
    push rdi
    
    ; Используем глобальный буфер place
    mov [place], al    ; Сохраняем символ
    mov rsi, place     ; Адрес буфера
    
    mov rax, 1        ; sys_write
    mov rdi, 1        ; stdout
    mov rdx, 1        ; длина 1 символ
    syscall
    
    pop rdi
    pop rsi
    pop rax
    pop rcx
    pop rdx
    pop rbx
    ret