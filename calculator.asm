section .data
    prompt db 'Enter first number: ', 0
    prompt_len equ $ - prompt
    
    prompt2 db 'Enter operator (+, -, *, /): ', 0
    prompt2_len equ $ - prompt2
    
    prompt3 db 'Enter second number: ', 0
    prompt3_len equ $ - prompt3
    
    result_msg db 'Result: ', 0
    result_msg_len equ $ - result_msg
    
    newline db 0xA
    error_msg db 'Invalid operator!', 0xA
    error_len equ $ - error_msg
    
    div_zero_msg db 'Error: Division by zero!', 0xA
    div_zero_len equ $ - div_zero_msg

section .bss
    num1 resb 10
    num2 resb 10
    operator resb 2
    result resb 20

section .text
    global _start

_start:
    ; Print first prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall
    
    ; Read first number
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 10
    syscall
    
    ; Print operator prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall
    
    ; Read operator
    mov rax, 0
    mov rdi, 0
    mov rsi, operator
    mov rdx, 2
    syscall
    
    ; Print second number prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt3
    mov rdx, prompt3_len
    syscall
    
    ; Read second number
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 10
    syscall
    
    ; Convert num1 from ASCII to integer
    mov rsi, num1
    call string_to_int
    mov rbx, rax        ; Store num1 in rbx
    
    ; Convert num2 from ASCII to integer
    mov rsi, num2
    call string_to_int
    mov rcx, rax        ; Store num2 in rcx
    
    ; Check operator and perform operation
    mov al, [operator]
    
    cmp al, '+'
    je add_numbers
    
    cmp al, '-'
    je sub_numbers
    
    cmp al, '*'
    je mul_numbers
    
    cmp al, '/'
    je div_numbers
    
    ; Invalid operator
    jmp invalid_op

add_numbers:
    add rbx, rcx
    jmp print_result

sub_numbers:
    sub rbx, rcx
    jmp print_result

mul_numbers:
    mov rax, rbx
    imul rcx
    mov rbx, rax
    jmp print_result

div_numbers:
    ; Check for division by zero
    cmp rcx, 0
    je division_by_zero
    
    mov rax, rbx
    cqo                 ; Sign extend rax to rdx:rax
    idiv rcx
    mov rbx, rax
    jmp print_result

division_by_zero:
    mov rax, 1
    mov rdi, 1
    mov rsi, div_zero_msg
    mov rdx, div_zero_len
    syscall
    jmp exit

invalid_op:
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    jmp exit

print_result:
    ; Print "Result: "
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall
    
    ; Convert result to string
    mov rax, rbx
    mov rdi, result
    call int_to_string
    
    ; Print result
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, r8         ; Length returned from int_to_string
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

exit:
    mov rax, 60
    mov rdi, 0
    syscall

; Convert string to integer
; Input: rsi = pointer to string
; Output: rax = integer value
string_to_int:
    push rbx
    push rcx
    push rdx
    
    xor rax, rax        ; Clear rax (result)
    xor rcx, rcx        ; Clear rcx (for character)
    xor rbx, rbx        ; Sign flag (0 = positive, 1 = negative)
    
    ; Check for negative sign
    mov cl, [rsi]
    cmp cl, '-'
    jne .parse_loop
    mov rbx, 1          ; Set sign flag
    inc rsi             ; Skip the '-'
    
.parse_loop:
    mov cl, [rsi]       ; Get current character
    cmp cl, 0xA         ; Check for newline
    je .done
    cmp cl, 0           ; Check for null terminator
    je .done
    cmp cl, '0'
    jl .done
    cmp cl, '9'
    jg .done
    
    sub cl, '0'         ; Convert ASCII to digit
    imul rax, 10        ; Multiply result by 10
    add rax, rcx        ; Add current digit
    
    inc rsi             ; Move to next character
    jmp .parse_loop

.done:
    ; Apply sign if negative
    cmp rbx, 1
    jne .positive
    neg rax
    
.positive:
    pop rdx
    pop rcx
    pop rbx
    ret

; Convert integer to string
; Input: rax = integer value, rdi = buffer
; Output: r8 = length of string
int_to_string:
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rbx, 10         ; Divisor
    xor rcx, rcx        ; Counter for digits
    mov rsi, rdi        ; Save buffer pointer
    
    ; Handle negative numbers
    test rax, rax
    jns .positive
    neg rax
    mov byte [rdi], '-'
    inc rdi
    inc rcx
    
.positive:
    ; Handle zero case
    cmp rax, 0
    jne .convert_loop
    mov byte [rdi], '0'
    inc rdi
    inc rcx
    jmp .reverse_done

.convert_loop:
    xor rdx, rdx
    div rbx             ; Divide by 10
    add dl, '0'         ; Convert remainder to ASCII
    mov [rdi], dl
    inc rdi
    inc rcx
    
    test rax, rax
    jnz .convert_loop
    
    ; Reverse the digits (excluding sign if present)
    mov rax, rsi        ; Start of buffer
    cmp byte [rax], '-'
    jne .set_reverse_start
    inc rax             ; Skip sign for reversal
    
.set_reverse_start:
    mov rbx, rdi
    dec rbx             ; End of string
    
.reverse_loop:
    cmp rax, rbx
    jge .reverse_done
    
    mov dl, [rax]
    mov dh, [rbx]
    mov [rax], dh
    mov [rbx], dl
    
    inc rax
    dec rbx
    jmp .reverse_loop

.reverse_done:
    mov r8, rcx         ; Return length
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret