section .note.GNU-stack

section .text

global check_langford
global generate_langford_sequences

extern calloc
extern free
extern printf
extern realloc


;; int check_langford(int *sequence rdi, int len rsi);
check_langford:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx

	;; making array for checked numbers
	push rdi
	push rsi
	mov rdi, rsi
	inc rdi
	;; sizeof char
	mov rsi, 1
	call calloc
	pop rsi
	pop rdi
	mov r8, rax

	xor rcx, rcx ;; rcx counter
check_for_loop:

	xor rbx, rbx
	xor r10, r10

	;; ebx = sequence[rcx]
	mov ebx, [rdi + rcx * 4]

	mov r10b, [r8 + rbx]
	;; if counter > 1
	cmp r10b, 1
	jg not_langford_sequence

	;; if counter = 1
	cmp r10b, 1
	je skip_check


	;; position of the same number
	lea r11, [rcx + rbx + 1]
	;; if in bounds
	cmp r11, rsi
	jge not_langford_sequence
	;; seq[rbx + rcx + 1]
	cmp ebx, [rdi + r11 * 4]
	jne not_langford_sequence

skip_check:
	inc byte [r8 + rbx]
	inc rcx
	cmp rcx, rsi
	jne check_for_loop

is_langford:
	;; output = 1
	mov rax, 1
	jmp end_check_langdord


not_langford_sequence:
	xor rax, rax

end_check_langdord:
	push rax
	mov rdi, r8
	call free
	pop rax
	pop rbx

	leave
	ret













;; int **generate_langford_sequences(int n rdi, int *seq_num rsi);
generate_langford_sequences:
	push rbp
	mov rbp, rsp
	xor rax, rax
	;;removing seg fault from checker
	mov dword [rsi], 0

	mov rax, rdi
	;; rax = rax % 4
	and rax, 3
	;; if rax % 4 = 0
	cmp rax, 0
	je exists
	;; if rax % 4 = 3
	cmp rax, 3
	je exists

	xor rax, rax
	leave
	ret

exists:

	mov r14, rdi ;; r14 = n
	mov rcx, rsi ;; rcx = int *seq_num

	;; array allocation
	;; rdi = 2n
	shl edi, 1
	;; sizeof int
	mov rsi, 4

	push rcx
	push r14

	call calloc

	pop r14
	pop rcx

	mov r13, rax
	mov rdi, rax ;;rdi = int sequence[2n]
	;; r14 = 2n
	shl r14, 1
	mov rsi, r14
	xor rdx, rdx

	push r13
	push rdi
	push rdx
	push rsi
	push rcx
	push r9
	push r8
	;; 1 pointer
	mov rdi, 1
	;; sizeof int*
	mov rsi, 8
	call calloc

	pop r8
	pop r9
	pop rcx
	pop rsi
	pop rdx
	pop rdi
	pop r13

	mov r8, rax


	push r13
	push r8
	push rdi
	call backtracking_mess
	pop rdi
	pop r8
	pop r13
	mov r8, rax

	push r8
	mov rdi, r13
	call free
	pop r8

	mov rax, r8



	leave
	ret



;; I initially made it so it would print the sequences, thats why I use skip_print1 and 2
;; it also used to test all the combinations, at test 10 reaching a small 8^16

;; void backtracking_mess(int *sequence rdi, int len 2n rsi, int pos rdx, int *seq_num rcx, int **results r8)
backtracking_mess:
	push rbp
	mov rbp, rsp

	;; if pos = 2n
	cmp rsi, rdx
	jne skip_print1


check_seq:
	push rdi
	push rdx
	push rsi
	push rcx
	push r9
	push r8

	call check_langford

	pop r8
	pop r9
	pop rcx
	pop rsi
	pop rdx
	pop rdi

	;; if it is a lnagford seq
	cmp rax, 1
	jne skip_print2



save_seq:




	mov r10d, [rcx]
	inc r10d

	push rdi
	push rdx
	push rsi
	push rcx
	push r9
	push r8

	mov rdi, r8
	;; rsi = (nr of results) * sizeof int*
	lea rsi, [r10 * 8]
	call realloc

	pop r8
	pop r9
	pop rcx
	pop rsi
	pop rdx
	pop rdi

	mov r8, rax

	mov r10d, [rcx]

	push rdi
	push rdx
	push rsi
	push rcx
	push r9
	push r8

	mov rdi, rsi
	;; rsi = sizeof int
	mov rsi, 4
	call calloc

	pop r8
	pop r9
	pop rcx
	pop rsi
	pop rdx
	pop rdi

	xor r10, r10
	mov r10d, [rcx]
	;; pointer from calloc
	mov [r8 + r10 * 8], rax




	mov r10d, [rcx]
	inc dword [rcx]

	xor r9, r9
	;; int* to the current sequence reserved spot
	mov r12, [r8 + r10 * 8]
sequence_to_results_loop:
	;; copy number from current sequence
	mov eax, [rdi + r9 * 4]
	;; copy the number onto the final array
	mov [r12 + r9 * 4], eax


	inc r9
	cmp r9d, esi
	jne sequence_to_results_loop

skip_print2:
	mov rax, r8
	leave
	ret


skip_print1:

first_empty_pos:
	cmp rdx, rsi
	je check_seq
	;; the number on the current pos
	mov r14d, [rdi + rdx * 4]

	;; if spot is empty
	cmp r14d, 0
	je found_empty
	inc rdx
	jmp first_empty_pos

found_empty:


	;; r9 = 1
	mov r9, 1;; r9 for loop counter
for_loop_backtracking:
	;; if the second number would be placed over the limit
	lea r14, [rdx + r9 + 1]
	cmp r14, rsi
	jge continue_loop

	;; if the second number is also in an empty spot
	cmp dword [rdi + r14 * 4], 0
	jne continue_loop

	;; seq[pos] = 0
	mov [rdi + rdx * 4], r9d
	;; seq[pos + r9 + 1] = r9, the next number's pos
	mov [rdi + r14 * 4], r9d
	inc rdx

	push rdi
	push rsi
	push rdx
	push rcx
	push r9
	push r8
	push r14

	call backtracking_mess

	pop r14
	pop r8
	pop r9
	pop rcx
	pop rdx
	pop rsi
	pop rdi

	mov r8, rax

	dec rdx
	;; seq[pos] = 0
	mov [rdi + rdx * 4], dword 0
	;; seq[pos + r9 + 1] = 0, the next number's pos
	mov [rdi + r14 * 4], dword 0

continue_loop:
	inc r9
	mov r11, rsi
	;; r11 = n (or 2n/2)
	shr r11, 1
	inc r11
	cmp r9, r11
	jne for_loop_backtracking

	mov rax, r8
	leave
	ret