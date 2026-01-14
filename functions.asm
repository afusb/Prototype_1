; Dependency functions for calculator
; ----------------------------------------------------------------------------------------------------------------------------------------------------
section .text
    ; Allow these functions to be called from other files
    global quit
    global print_string
    global print_string_then_new_line
    global ascii_to_integer
    global print_integer_new_line

section .data
    ; Error messages
    error_message_overflow   db 0xA, "Error: Number too large (Max 32-bit limit)", 0xA, 0
    error_message_bad_input  db 0xA, "Error: Invalid input (digits only)", 0xA, 0 

section .text

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Exit the program
; ----------------------------------------------------------------------------------------------------------------------------------------------------
quit:
    mov     eax, 1          ; sys_exit
    xor     ebx, ebx        ; Return 0
    int     0x80

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Get string length
; Returns length in EAX
; ----------------------------------------------------------------------------------------------------------------------------------------------------
string_length:
    push    ebx             ; Save EBX
    mov     ebx, eax        ; Store start address
 
.next_char:
    cmp     byte [eax], 0   ; End of string?
    jz      .done
    inc     eax
    jmp     .next_char
 
.done:
    sub     eax, ebx        ; Length = End - Start
    pop     ebx
    ret

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Print string to standard output
; Expects string address in EAX
; ----------------------------------------------------------------------------------------------------------------------------------------------------
print_string:
    push    edx
    push    ecx
    push    ebx
    push    eax
    
    call    string_length   ; Get length for syscall
 
    mov     edx, eax        ; Length
    pop     eax             ; Restore string address
 
    mov     ecx, eax        ; Buffer to print
    mov     ebx, 1          ; Standard output
    mov     eax, 4          ; sys_write
    int     0x80
 
    pop     ebx
    pop     ecx
    pop     edx
    ret

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Print string followed by a newline
; ----------------------------------------------------------------------------------------------------------------------------------------------------
print_string_then_new_line:
    call    print_string
 
    push    eax
    mov     eax, 0x0A       ; Newline char
    push    eax             ; Push to stack to get an address
    
    mov     eax, esp        ; Print from stack
    call    print_string
    
    pop     eax             ; Clean stack
    pop     eax
    ret

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Convert ASCII string to Integer / atoi
; Handles sign, validation, and overflow
; ----------------------------------------------------------------------------------------------------------------------------------------------------
ascii_to_integer:
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi             ; Sign flag (1 = negative)
 
    mov     esi, eax        ; Source string
    mov     eax, 0          ; Result
    mov     ecx, 0          ; Loop index
    mov     edi, 0

    ; Check for negative
    cmp     byte [esi], '-'
    jne     .loop
    inc     ecx             ; Skip '-'
    mov     edi, 1          ; Set flag

.loop:
    xor     ebx, ebx
    mov     bl, [esi+ecx]   ; Get char
 
    ; Validation
    cmp     bl, 10          ; Newline?
    je      .done
    cmp     bl, 0           ; Null?
    je      .done
    
    cmp     bl, '0'
    jl      .error_char
    cmp     bl, '9'
    jg      .error_char

    sub     bl, '0'         ; ASCII to Int
    
    ; Overflow check
    mov     edx, 10
    imul    eax, edx        ; Shift left
    jo      .error_overflow
    
    add     eax, ebx        ; Add digit
    jo      .error_overflow

    inc     ecx
    jmp     .loop
 
.done:
    cmp     ecx, 0          ; Empty input check
    je      .restore        
    
    cmp     edi, 1          ; Apply sign if needed
    jne     .restore
    neg     eax

.restore:
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

.error_char:
    mov     eax, error_message_bad_input
    call    print_string_then_new_line
    call    quit

.error_overflow:
    mov     eax, error_message_overflow
    call    print_string_then_new_line
    call    quit

; ----------------------------------------------------------------------------------------------------------------------------------------------------
; Print Integer with Newline
; ----------------------------------------------------------------------------------------------------------------------------------------------------
print_integer_new_line:
    push    eax
    push    ecx
    push    edx
    push    esi
    
    cmp     eax, 0
    jge     .setup
    
    ; Handle negative output
    push    eax
    mov     eax, '-'
    push    eax
    mov     eax, esp
    call    print_string
    pop     eax
    pop     eax
    neg     eax

.setup:
    mov     ecx, 0
 
.divide_loop:
    inc     ecx
    mov     ebx, 10
    xor     edx, edx
    div     ebx             ; Divide by 10
    add     edx, '0'        ; Int to ASCII
    push    edx             ; Push remainder
    cmp     eax, 0
    jnz     .divide_loop
 
.print_loop:
    dec     ecx
    mov     eax, esp        ; Print char from stack
    call    print_string
    pop     eax
    cmp     ecx, 0
    jnz     .print_loop
 
    ; Print newline
    push    eax
    mov     eax, 0x0A
    push    eax
    mov     eax, esp
    call    print_string
    pop     eax
    pop     eax
 
    pop     esi             
    pop     edx
    pop     ecx
    pop     eax
    ret