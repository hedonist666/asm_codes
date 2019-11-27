include 'include/linux_def.inc' ; linux constants
include 'include/unistd64.inc'  ; syscalls

READ_SIZE = 0x10

format ELF64 executable at 0000000100000000h

segment readable executable

entry $
  mov rax, [rsp]
  cmp rax, 2
  jbe fail_1
  jmp ok_1

fail_1:
  lea rdi, [args_err_mes]
  jmp exit_with_mes

ok_1:
  mov rax, [rsp+8*2]
  mov [chars_src], rax
  mov rdi, rax
  call strlen
  mov [src_len], rax

  mov rax, [rsp+8*3]
  mov [chars_dst], rax
  mov rdi, rax
  call strlen
  mov [dst_len], rax

for_1:
  mov rdi, STDIN
  lea rsi, [rsp]
  mov rdx, READ_SIZE
  mov eax, sys_read
  syscall
  mov r8, rax
  xor rcx, rcx
  for_2:
    mov al, byte [rsp+rcx]
    call check_char
    mov [rsp+rcx], al
    inc rcx
    cmp rcx, r8
    jb for_2

  mov rdx, r8
  mov rdi, STDOUT
  lea rsi, [rsp]
  mov eax, sys_write
  syscall
  cmp r8, READ_SIZE
  je for_1

   
  mov eax, sys_exit
  mov rdi, 666
  syscall


check_char:
  push rcx
  xor rbx, rbx
  xor rcx, rcx
check_char_for:
  lea rdx, [chars_src]
  mov rdx, [rdx]
  add rdx, rcx
  mov bl, byte [rdx]
  cmp rax, rbx
  je matched
  inc rcx
  cmp rcx, [src_len]
  jb check_char_for
  jmp _end
matched:
  cmp rcx, [dst_len]
  jbe to_dst_char
  jmp to_
to_dst_char:
  lea rdx, [chars_dst]
  mov rdx, [rdx]
  add rdx, rcx
  mov al, byte [rdx]
  jmp _end
to_:
  mov al, 0x5f ; '_'
_end:
  pop rcx
  ret
 
    

exit_with_mes:
  mov rsi, rdi
  call strlen
  mov rdx, rax
  mov rdi, STDOUT
  mov eax, sys_write
  syscall
  mov eax, sys_exit
  mov rdi, 666
  syscall

strlen:
  xor rcx, rcx
for:
  cmp byte [rdi+rcx], 0
  je strlen_finish
  inc rcx
  jmp for
strlen_finish:
  inc rcx
  mov rax, rcx
  ret

segment readable writable
chars_dst rq 1
chars_src rq 1
src_len rq 1
dst_len rq 1
read_size rq 1

args_err_mes db 'not enough args', 0xa, 0x0
