[bits 16]
[org 0x7C00]

    jmp 0x0000:Start        ; clear cs by far jumping (set cs:ip to 0x0000:Start)

Start: ;DH and ES:DI should be preserved by the MBR for full Plug-and-Play support
    xor ax, ax
    mov ds, ax              ; clear ds
    mov es, ax              ; clear es

    mov bp, 0x9000          ; set stack and base pointer to 0x9000
    mov sp, bp

    ;push dx                 ; dl holds the drive number so conserve it

    mov ax, 0x0003          ;set video mode Text (80 x 25)
    int 0x10

    cld                     ;clear direction flag for string operations

PrintDiskNumber:
    mov si, disk_number
    call PrintString
    mov bl, dl
    call PrintByteAsHex
    call PrintNewline

ResetDiskSystem:
    xor al, al
    int 0x13
    jnc ResetDiskSystem
    call CheckInterruptReturnCode

CheckExtensionPresent:
    mov bx, 0x55AA
    mov ah, 0x41
    int 0x13

    jc BootError
    cmp bx, [magic_number]
    jne BootError
    and cx, 0x10
    jz BootError
    jmp HALT

BootError:
    call PrintNewline
    mov bl, ch
    call PrintByteAsHex
    mov bl, cl
    call PrintByteAsHex
    call PrintNewline
    mov si, boot_error
    call PrintString

HALT:
    cli
    hlt

; ah: return code
; clears: ax, bh, si
CheckInterruptReturnCode:
    cmp ah, 0
    je .return
    mov si, interrupt_error
    call PrintString
    mov bl, ah
    call PrintByteAsHex
.return:
    ret


; si: null-terminated string
; clears: ax, bh
PrintString:
    xor bh, bh
    mov ah, 0x0E

.loop:
    lodsb
    or al, al
    jz .return
    int 0x10
    jmp .loop

.return:
    ret

; bl: byte to print
; clears: ax, bh
PrintByteAsHex:
    xor bh, bh
    mov ah, 0x0E

    mov al, bl
    and al, 0xF0
    shr al, 4
    cmp al, 0xA
    jge .letter1
    add al, '0'
    jmp .print1
.letter1:
    add al, 'A'-0xA
.print1:
    int 0x10

    mov al, bl
    and al, 0x0F
    cmp al, 0xA
    jge .letter2
    add al, '0'
    jmp .print2
.letter2:
    add al, 'A'-0xA
.print2:
    int 0x10
    ret

; clears: ax, bh
PrintNewline:
    xor bh, bh
    mov ax, 0x0E0A
    int 0x10
    mov al, 0x0D
    int 0x10
    ret


disk_number db "Disk number: 0x", 0
interrupt_error db "Interrupt error: 0x", 0
boot_error db "Boot Error", 0
;guid db "pow's bootloader", 0

times 510 - ($ - $$) db 0
magic_number dw 0xAA55