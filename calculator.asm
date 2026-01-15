; Calculator Entry Point
; Depends on functions.asm
; ----------------------------------------------------------------------------------------------------------------------------------------------------

section .data
    message_welcome_title        db  "NASM Calculator", 0
    message_prompt_first_number  db  "Enter first number: ", 0
    message_prompt_operator      db  "Enter operator (+, -, *, /): ", 0
    message_prompt_second_number db  "Enter second number: ", 0
    message_result_label         db  "Result: ", 0
    
    message_error_division_zero  db  "Error: Cannot divide by 0", 0
    message_error_invalid_op     db  "Error: Invalid Operator", 0
    message_error_overflow       db  "Error: Result exceeds 32-bit signed limit", 0

section .bss
    ; Input buffers
    buffer_input_first_number    resb 32     
    buffer_input_second_number   resb 32     
    buffer_input_operator        resb 2
    
    ; Parsed integers
    integer_first_number         resd 1      
    integer_second_number        resd 1      

section .text
    global _start

    ; Tell NASM these functions are in another file
    extern quit
    extern print_string
    extern print_string_then_new_line
    extern ascii_to_integer
    extern print_integer_new_line

_start:

    mov     eax, message_welcome_title
    call    print_string_then_new_line

    ;Input first number
    mov     eax, message_prompt_first_number
    call    print_string
    
    mov     edx, 32         ; Max bytes
    mov     ecx, buffer_input_first_number
    mov     ebx, 0          ; STDIN
    mov     eax, 3          ; sys_read
    int     0x80
    
    mov     eax, buffer_input_first_number
    call    ascii_to_integer
    mov     [integer_first_number], eax

    ; Input Operator
    mov     eax, message_prompt_operator
    call    print_string
    
    mov     edx, 2
    mov     ecx, buffer_input_operator
    mov     ebx, 0
    mov     eax, 3
    int     0x80

    ; Input second number
    mov     eax, message_prompt_second_number
    call    print_string
    
    mov     edx, 32         ; Max bytes (buffer size)
    mov     ecx, buffer_input_second_number
    mov     ebx, 0
    mov     eax, 3
    int     0x80
    
    mov     eax, buffer_input_second_number
    call    ascii_to_integer
    mov     [integer_second_number], eax

    ;Operator Logic
    mov     ah, [buffer_input_operator]
    
    cmp     ah, '+'         ;using ah 16-bit register to for input validation - avoids buffer overflow as predefined 
    je      perform_addition
    cmp     ah, '-'         
    je      perform_subtraction
    cmp     ah, '*'         
    je      perform_multiplication
    cmp     ah, '/'         
    je      perform_division
    
    ; Invalid operator
    mov     eax, message_error_invalid_op
    call    print_string_then_new_line
    call    quit

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Math Operations
; ----------------------------------------------------------------------------------------------------------------------------------------------------

perform_addition:
    mov     eax, [integer_first_number]
    add     eax, [integer_second_number]
    jo      handle_math_overflow            ; Check if addition overflowed
    jmp     display_final_result

perform_subtraction:
    mov     eax, [integer_first_number]
    sub     eax, [integer_second_number]
    jo      handle_math_overflow            ; Check if subtraction overflowed
    jmp     display_final_result

perform_multiplication:
    mov     eax, [integer_first_number]
    imul    eax, [integer_second_number]    ; Signed multiply
    jo      handle_math_overflow            ; imul sets OF if result doesn't fit in EAX
    jmp     display_final_result

perform_division:
    mov     eax, [integer_first_number]
    mov     ebx, [integer_second_number]
    
    cmp     ebx, 0                          ; Check divide by zero
    je      handle_division_zero_error
    
    cdq                                     ; Extend sign for signed division
    idiv    ebx
    jmp     display_final_result

handle_division_zero_error:
    mov     eax, message_error_division_zero
    call    print_string_then_new_line
    call    quit

handle_math_overflow:
    mov     eax, message_error_overflow
    call    print_string_then_new_line
    call    quit

display_final_result:
    push    eax             ; Save result
    mov     eax, message_result_label
    call    print_string
    pop     eax             ; Restore result
    call    print_integer_new_line
    call    quit