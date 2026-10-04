section .note.GNU-stack


section .data
;; heavy string
printf_heavy db "The number is heavy", 10, 0
;; not heavy string
printf_not_heavy db "The number is not heavy", 10, 0
;; max element string
printf_max_element db "%d", 10, 0



section .text

global ave
global switch_cases
global heavy
global flat_matrix

extern printf


;; void ave(char *src rdi, char *dest rsi, int n rdx);
;;(c - 'A' + n) mod 31 + 'A'
ave:
	push rbp
	mov rbp, rsp
	xor rax, rax

	xor rcx, rcx ;;rcx counter
	mov r9, rdx
ave_while_loop:
	xor rbx, rbx
	xor rax, rax
	;;rbx = src[rcx]
	mov bl, [rdi + rcx]

	;; if null terminator
	cmp bl, 0
	je end_ave

	add rbx, r9
	sub rbx, 'A'

	mov rax, rbx
	;; modulo 31
	mov r8, 31
	xor rdx, rdx

	;; if (c - 'A' + n) is negative
	cmp rbx, 0
	jge skip1
	;; changes the sign of rdx
	mov rdx, -1
skip1:
	idiv r8

	add rdx, 'A'
	mov [rsi + rcx], dl

	inc rcx
	jmp ave_while_loop


end_ave:
	;; null terminator
	mov byte [rsi + rcx], 0


	leave
	ret



;; void switch_cases(char *src rdi, char *dest rsi);
switch_cases:
	push rbp
	mov rbp, rsp
	xor rax, rax

	xor rcx, rcx;; rcx counter
switch_cases_while_loop:
	xor rbx, rbx
	xor rax, rax
	;;rbx = src[rcx]
	mov bl, [rdi + rcx]

	;; if null terminator
	cmp bl, 0
	je end_switch_cases

	cmp bl, 'A'
	jl skip_further_modifications

	cmp bl, 'Z'
	jle to_lower

	cmp bl, 'z'
	jg skip_further_modifications

	cmp bl, 'a'
	jge to_upper

to_lower:
	;; makes letter lowercase
	add bl, 32
	jmp skip_further_modifications

to_upper:
	;; makes letter uppercase
	sub bl, 32

skip_further_modifications:
	mov [rsi + rcx], bl


	inc rcx
	jmp switch_cases_while_loop

end_switch_cases:
	;; null terminator
	mov byte [rsi + rcx], 0


	leave
	ret




;; void heavy(int number rdi);
heavy:
	push rbp
	mov rbp, rsp
	xor rax, rax

	;; rbx = 1
	mov rbx, 1
	;; rbx has only msb set
	shl rbx, 31

	mov rcx, rdi
	and rcx, rbx
	;; if msb not set
	cmp rcx, 0
	je not_heavy

	;; gets rid of the first 2 bytes
	shr rdi, 16
	mov rdx, rdi
	;; concatenating 3rd and 4th byte
	mov al, dh
	mov ah, dl

	;; if resulting nr <= 255
	cmp ax, 255
	jbe not_heavy

is_heavy:
	mov rdi, printf_heavy
	call printf
	jmp end_heavy

not_heavy:
	mov rdi, printf_not_heavy
	call printf

end_heavy:

	leave
	ret






;; void flat_matrix(int *mat rdi, int n rsi);
flat_matrix:
	push rbp
	mov rbp, rsp
	xor rax, rax

	xor rcx, rcx ;; rcx column counter
	xor rbx, rbx ;; rbx row counter
	xor r9, r9
	xor r10, r10 ;; line of max element

for_columns:
	xor rbx, rbx
	mov r8d, -999999 ;; r8 = max value

for_rows:

	mov rax, rbx
	mul esi
	add rax, rcx
	mov rdx, rax
	;; sizeof int = 4
	mov rax, 4
	mul rdx
	;; mat[rbx][rcx]
	mov r9d, [rdi + rax]
	cmp r9d, r8d
	jle skip_switch

	mov r8d, r9d
	mov r10, rbx

skip_switch:


	inc rbx
	cmp ebx, esi
	jne for_rows

	push rdi
	push rsi
	push rbx
	push rcx

	mov eax, r10d
	mul esi
	add rax, rcx
	mov rdx, rax
	;; sizeof int = 4
	mov rax, 4
	mul rdx
	;; mat[rbx][rcx]
	mov esi, [rdi + rax]

	mov rdi, printf_max_element
	call printf

	pop rcx
	pop rbx
	pop rsi
	pop rdi




	inc rcx
	cmp ecx, esi
	jne for_columns


	leave
	ret
