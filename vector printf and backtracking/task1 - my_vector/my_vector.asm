section .note.GNU-stack

struc my_vector
	arr: resq 1
	len: resd 1
	cap: resd 1
endstruc

section .data
;; why do I even have to explain obvious code repeteadly
;; like "mov rax, -1", when it is pointed out in the task
;; printf_start_string
printf_start_string db "v -> {(",0
;; printf_int
printf_int db "[%d]",0
;; printf_blank
printf_blank db "[]",0
;; printf_middle
printf_middle db "), %d",0
;; printf_end
printf_end db ", %d}", 10, 0
;; printf_empty_vector
printf_empty_vector db "The vector is empty", 10, 0
;; printf_error_len
printf_error_len db "Error: len <= %d", 10, 0


section .text

global new_vector
global set_element
global get_element
global push_element
global pop_element
global print_vector
global free_vector

extern calloc
extern realloc
extern printf
extern free

;; vector *new_vector(int cap(rdi));
new_vector:
	push rbp
	mov rbp, rsp
	push rbx
	push r14
	xor rax, rax
	xor r8, r8
	xor r14, r14

	;; if cap = 0
	cmp rdi, 0
	jne skip1
	inc rdi

skip1:
	mov r14d, edi
	mov r8d, edi
	;; one vector
	mov rdi, 1
	;; sizeof vector  = 16
	mov rsi, 16


	push rbx
	call calloc
	pop rbx


	mov [rax + cap], r14d

	mov rbx, rax

	mov rdi, r14
	;; sizeof int = 4
	mov rsi, 4
	push rbx
	call calloc
	pop rbx
	mov [rbx + arr], rax
	mov rax, rbx

	pop r14
	pop rbx
	leave
	ret


;; int set_element(struct vector *rdi, int elem(rsi), int pos(rdx));
set_element:
	push rbp
	mov rbp, rsp
	push rbx
	xor rax, rax

	cmp edx, [rdi + len]
	jge set_element_not_valid

	;;rbx = array pointer
	mov rbx, [rdi + arr]

	;; arr[rdx]
	mov [rbx + rdx * 4], esi
	mov rax, rdx
	jmp set_element_valid


set_element_not_valid:
	mov rsi, rdx
	mov rdi, printf_error_len
	call printf
	;; rax = -1
	mov rax, -1

set_element_valid:

	pop rbx
	leave
	ret



;; int get_element(struct vector *rdi, int pos(rsi);
get_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx

	cmp esi, [rdi + len]
	jge get_element_not_valid

	;;rbx = array pointer
	mov rbx, [rdi + arr]
	;; arr[rbx]
	mov eax, [rbx + rsi * 4]
	jmp get_element_valid


get_element_not_valid:
	mov rdi, printf_error_len
	call printf
	;;rax = -1
	mov rax, -1

get_element_valid:

	pop rbx
	leave
	ret




;; int push_element(struct vector *rdi, int elem(rsi));
push_element:
	push rbp
	mov rbp, rsp
	push rbx
	push r10
	xor rax, rax

	mov r10, rsi
	xor rcx, rcx
	xor rbx, rbx
	mov r9, rdi

	mov ebx, [rdi + cap]
	mov ecx, [rdi + len]


	cmp ebx, ecx
	jg skip_push_realloc

	;; eax = 2 * cap * sizeof int
	mov eax, 2
	mul ebx
	mov [rdi + cap], eax
	;; sizeof int
	mov ebx, 4
	mul ebx

	mov rdi, [rdi + arr]
	mov rsi, rax
	push r10
	push rbx
	push rcx
	push r9
	call realloc
	pop r9
	pop rcx
	pop rbx
	pop r10
	mov [r9 + arr], rax


skip_push_realloc:
	mov rax, rcx
	mov r8, [r9 + arr]
	;; arr[rcx] = r10d
	mov [r8 + rcx * 4], r10d
	;; len++
	add dword [r9 + len], 1

	pop r10
	pop rbx

	leave
	ret




;; int pop_element(struct vector *rdi);
pop_element:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx
	push r10

	xor rcx, rcx
	xor r10, r10
	xor rbx, rbx
	mov r9, rdi

	mov ebx, [rdi + cap]
	mov ecx, [rdi + len]
	;; if ecx = 0
	cmp ecx, 0
	je no_elements_pop

	dec dword [rdi + len]
	mov ecx, [rdi + len]

	mov r8, [rdi + arr]
	;; arr[rcx]
	mov r10d, [r8 + 4 * rcx]
	;; arr[rcx] = 0
	mov dword [r8 + 4 * rcx], 0

	;; ecx = 2 * len
	shl ecx, 1
	cmp ecx, ebx
	jg skip_pop_realloc
	;; if cap = 1
	cmp dword [rdi + cap], 1
	je skip_pop_realloc


;; realloc part
	mov ecx, [rdi + cap]
	;;ecx /= 2
	shr ecx, 1
	mov [rdi + cap], ecx
	mov rdi, [rdi + arr]
	;; rsi = cap/2 *sizeof int
	lea rsi, [rcx * 4]
	push r10
	push r9
	call realloc
	pop r9
	pop r10

	mov [r9 + arr], rax

skip_pop_realloc:

	mov rax, r10
	jmp pop_end

no_elements_pop:
	mov rdi, printf_empty_vector
	call printf
	;;rax = -1
	mov rax, -1

pop_end:

	pop r10
	pop rbx
	leave
	ret





;; void print_vector(struct vector *rdi);
print_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx

	xor rbx, rbx
	mov r9, rdi

	mov ebx, [rdi + len]
	mov r8, [rdi + arr]
	xor rcx, rcx ;; counter

	mov rdi, printf_start_string
	push rbx
	push rcx
	push r8
	push r9
	push rbx
	push r8
	call printf
	pop r8
	pop rbx
	pop r9
	pop r8
	pop rcx
	pop rbx

	;;if ebx = 0
	cmp ebx, 0
	jz skip_element_loop

printf_while_loop:

	xor rsi, rsi
	mov rdi, printf_int
	;; arr[rcx]
	mov esi, [r8 + rcx * 4]
	push rcx
	push r8
	push r9
	push rbx
	push r8
	call printf
	pop r8
	pop rbx
	pop r9
	pop r8
	pop rcx


	inc rcx
	cmp ecx, ebx
	jne printf_while_loop

skip_element_loop:

	cmp ecx, [r9 + cap]
	je skip_empty_element_loop

	mov ebx, [r9 + cap]

printf_empty_while_loop:

	mov rdi, printf_blank
	push rcx
	push r8
	push r9
	push rbx
	push r8
	call printf
	pop r8
	pop rbx
	pop r9
	pop r8
	pop rcx


	inc rcx
	cmp ecx, ebx
	jne printf_empty_while_loop

skip_empty_element_loop:

	xor rsi, rsi
	mov rdi, printf_middle
	mov esi, [r9 + len]
	push r8
	push r9
	push rbx
	call printf
	pop rbx
	pop r9
	pop r8

	xor rsi, rsi
	mov rdi, printf_end
	mov esi, [r9 + cap]
	push r8
	push r9
	push rbx
	call printf
	pop rbx
	pop r9
	pop r8

	pop rbx
	leave
	ret







;; void free_vector(struct vector **rdi);
free_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx

	mov r8, rdi

	mov rbx, [rdi]
	mov rdi, [rbx + arr]
	push rbx
	push r8
	call free
	pop r8
	pop rbx


	mov rdi, rbx
	push rbx
	push r8
	call free
	pop r8
	pop rbx

	;;pointer = NULL
	mov qword [r8], 0

	pop rbx
	leave
	ret
