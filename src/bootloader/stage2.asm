[bits 16]
[org 0x7C00]

    jmp 0x0000:Start        ; clear cs by far jumping to the next instruction, we can't use labels here since we haven't been relocated yet

Start:
    xor ax, ax
    mov ds, ax              ; clear ds
    mov es, ax              ; clear es

    mov bp, 0x9000          ; set stack and base pointer to 0x9000
    mov sp, bp

    mov ax, 0x3             ; set video mode Text (80 x 25)
    int 0x10

    cld                     ; clear direction flag for string operations

Stage2:
    mov si, stage2
    call PrintString
    call PrintNewline

EnableA20Line:
    call CheckA20Line       ; use different testing environment where A20 line is disabled
    jmp .enabled
.enabled:



HALT:
    cli
    hlt

CheckA20Line:
    push ds
    mov si, checking_a20_line
    call PrintString

    mov ax, 0xFFFF
    mov ds, ax
    mov si, 0x7C10
    mov di, 0x7C00
    mov al, [ds:si]
    inc al
    mov [es:di], al
    cmp [ds:si], al
    pop ds
    je .check_false
.check_true:
    mov si, enabled
    jmp .return
.check_false:
    mov si, disabled
.return:
    call PrintString
    call PrintNewline

    ret

; si: null-terminated string
; clears: ax, bh
PrintString:
    xor bh, bh
    mov ah, 0x0E

.print_char:
    lodsb
    or al, al
    jz .return
    int 0x10
    jmp .print_char
.return:
    ret

; clears: ax, bh
PrintNewline:
    xor bh, bh
    mov ax, 0x0E0A      ; mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10
    ret

checking_a20_line db "checking A20 line... ", 0
enabled db "enabled", 0
disabled db "disabled", 0
stage2 db "Stage 2", 0