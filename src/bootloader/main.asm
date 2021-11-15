[bits 16]
[org 0x7C00]

    jmp 0x0000:main
main:
    mov bp, 0x9000          ;stack at 0x9000
    mov sp, bp

    mov ax, 0x0003          ;set video mode Text (80 x 25)
    int 0x10
    cld                     ;clear direction flag for string operations

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, hello_world
    call print_string

    hlt


; si: null-terminated string
print_string:
    xor bh, bh
    mov bl, white
    mov ah, 0x0E

.loop:
    lodsb
    cmp al, 0x00
    je .end
    int 0x10
    jmp .loop

.end:
    ret


white equ 0x0F
hello_world db 'Hello World!', 0

times 510 - ($ - $$) db 0
dw 0xAA55