section .note.GNU-stack


section .data
;;printf_string
printf_string db "%ld", 10, 0

section .bss
;; buffer size
text_buffer resb 100

section .text

global reverse_polish_notation
extern fgets
extern stdin
extern printf
extern atol

reverse_polish_notation:
	push rbp
	mov rbp, rsp
	xor rax, rax

fgets_while_loop:
	mov rdi, text_buffer
	;; buffer size
	mov rsi, 100
	mov rdx, [stdin]
	call fgets

	;; if rax = null pointer
	cmp rax, 0
	je end_task2


	mov bl, [rax]

	cmp bl, '+'
	je addition
	cmp bl, '-'
	je subtraction
	cmp bl, '*'
	je multiplication
	cmp bl, '/'
	je division


	mov rdi, text_buffer
	call atol
	;; push number on stack
	push rax
	jmp fgets_while_loop


addition:
	pop r8
	pop r9
	add r8, r9
	push r8
	jmp fgets_while_loop

subtraction:
	pop r8
	pop r9
	sub r9, r8
	push r9
	jmp fgets_while_loop

multiplication:
	pop r8
	pop r9
	imul r8, r9
	push r8
	jmp fgets_while_loop

division:
	pop rbx
	pop rax
	xor rdx, rdx
	div rbx
	push rax
	jmp fgets_while_loop



end_task2:
	pop r8

	mov rdi, printf_string
	mov rsi, r8
	call printf

	leave
	ret
