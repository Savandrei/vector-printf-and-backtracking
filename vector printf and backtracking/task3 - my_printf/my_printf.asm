section .note.GNU-stack

section .text

global my_printf
extern putc
extern stdout

my_printf:
	push rbp
	mov rbp, rsp
	xor rax, rax

	push r9
	push r8
	push rcx
	push rdx
	push rsi

	xor r10, r10 ;;r10 counter
	mov r14, rdi
	xor r9, r9 ;; r9 '%' counter
my_printf_while_loop:
	xor rbx, rbx
	mov bl, [r14 + r10]
	inc r10
	;; if not null terminator
	cmp bl, 0
	je end_task3

	cmp bl, '%'
	jne print_normal_char

	inc r9


	xor rbx, rbx
	mov bl, [r14 + r10]
	inc r10 ;; skips over '%'
	cmp bl, 'c'
	je print_char_percent

	cmp bl, 's'
	je print_string

	inc r10 ;;skips 'u' in %lu
	jmp print_uint


print_normal_char:
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	mov rdi, rbx
	mov rsi, [stdout]
	call putc

	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	jmp my_printf_while_loop



print_char_percent:
	;; if parameters >= 6 (7 - the string)
	cmp r9, 6
	jl skip11
	;;size of parameter on the stack
	mov rax, 8
	mul r9
	;; gets the parameter value from stack
	mov rbx, [rbp + rax - 32]
	jmp skip12
skip11:
	;;gets value from stack
	pop rbx
skip12:

	jmp print_normal_char



print_string:
	;; if parameters >= 6 (7 - the string)
	cmp r9, 6
	jl skip21
	;;size of parameter on the stack
	mov rax, 8
	mul r9
	;; gets the parameter value from stack
	mov r8, [rbp + rax - 32]
	jmp skip22
skip21:
	pop r8 ;; gets char*
skip22:

	xor r12, r12 ;; r12 counter
print_string_loop:
	xor rcx, rcx
	add cl, [r8 + r12]
	inc r12
	;; if not null terminator
	cmp cl, 0
	je my_printf_while_loop


	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	mov rdi, rcx
	mov rsi, [stdout]
	call putc

	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	jmp print_string_loop



print_uint:
	;; if parameters >= 6 (7 - the string)
	cmp r9, 6
	jl skip3
	;;size of parameter on the stack
	mov rax, 8
	mul r9
	;; gets the parameter value from stack
	mov rax, [rbp + rax - 32]
	jmp skip4
skip3:
	pop rax ;;uint value
skip4:
	xor rcx, rcx
	xor r11, r11 ;; digit counter

uint_to_string_on_stack:
	inc r11
	xor rdx, rdx
	;; number /= 10
	mov ecx, 10
	div ecx
	;; number != 0
	cmp rax, 0
	je last_digit
	;; converts digit to char
	add rdx, 48
	push rdx

	jmp uint_to_string_on_stack

last_digit:
	;; converts digit to char
	add rdx, 48
	push rdx

print_digit_string:

	pop rcx

	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14

	mov rdi, rcx
	mov rsi, [stdout]
	call putc

	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax


	dec r11
	;; digit on stack counter != 0
	cmp r11, 0
	jne print_digit_string
	jmp my_printf_while_loop


end_task3:



	leave
	ret
