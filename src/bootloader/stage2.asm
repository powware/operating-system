[bits 16]
[org 0x7c00]

jmp 0x0000:Setup            ; clear cs by far jumping to the next instruction, we can't use labels here since we haven't been relocated yet

Setup:
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
HALT:
    cli
    hlt

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

stage2 db "Stage 2", 0

times 512 - ($ - $$) db 0