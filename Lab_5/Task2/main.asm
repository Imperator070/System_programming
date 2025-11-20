format ELF64

public _start

include 'funcnew.asm'

section '.bss' writable
  ; буфер для чтения
  reading_buffer rb 1
  ; буфер для записи
  writing_buffer rb 1

section '.text' executable
_start:

  pop rcx
  ; проверяем, что количество аргументов равно 4
  cmp rcx, 4
  ; если не равно, выходим
  jne .l1
  ; извлекаем следующий аргумент
  pop rcx

  ; извлекаем аргумент argv[1] - имя файла из
  pop rdi ; имя файла из
  ; извлекаем аргумент argv[2] - имя файла куда
  pop r14 ; имя файла куда
  ; извлекаем аргумент argv[3] - число
  pop rsi
  ; вызываем функцию str_number для преобразования строки в число
  call str_number
  ; сохраняем полученное число в регистр r15
  mov r15, rax ; k

  ; открываем файл из
  mov rax, 2 ; open из
  mov rsi, 0o
  syscall
  ; проверяем, что файл открылся успешно
  cmp rax, 0
  jl .l1

  ; сохраняем дескриптор файла из в регистр r8
  mov r8, rax ; дескриптор из
  mov rdi, r14
  mov rax, 2
  mov rsi, 577
  mov rdx, 777o
  syscall

  ; сохраняем дескриптор файла куда в регистр r10
  mov r10, rax ; дескриптор куда

  ; цикл чтения и записи
  .loop_read:
    ; пропускаем (k-1) байт перед чтением k-го
    mov rax, 0
    mov rdi, r8
    mov rsi, writing_buffer
    mov rdx, r15
    dec rdx        ; теперь пропускаем (k-1) байт
    cmp rdx, 0
    jle .read_byte ; если k=1, не пропускаем ничего
    syscall
    cmp rax, rdx   ; если прочитали меньше — конец файла
    jne .next

  .read_byte:
    ; считываем 1 байт (k-й)
    mov rax, 0
    mov rdi, r8
    mov rsi, reading_buffer
    mov rdx, 1
    syscall
    cmp rax, 0
    je .next

    ; записываем прочитанный байт в файл куда
    mov rax, 1
    mov rdi, r10
    mov rsi, reading_buffer
    mov rdx, 1
    syscall

    ; продолжаем цикл
    jmp .loop_read

  ; выход из цикла
.next:
  ; закрываем файл из
  mov rdi, r8
  mov rax, 3
  syscall

  ; закрываем файл куда
  mov rdi, r14
  mov rax, 3
  syscall

  ; выход из программы
.l1:
  call exit
