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
  ; уменьшаем число на 1
  dec r15

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
  ; считываем 1 байт из файла из
  mov rax, 0
  mov rdi, r8
  mov rsi, reading_buffer
  mov rdx, 1
  syscall

  ; проверяем, что удалось прочитать что-то
  cmp rax, 0
  je .next

  ; записываем прочитанный байт в файл куда
  mov rax, 1
  mov rdi, r10
  mov rsi, reading_buffer
  syscall

  ; пропускаем k байт в файле из
  mov rax, 0
  mov rdi, r8
  mov rsi, writing_buffer
  mov rdx, r15
  syscall

  ; проверяем, что пропускание прошло успешно
  cmp rax, 0
  je .next

  ; продолжаем цикл чтения
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