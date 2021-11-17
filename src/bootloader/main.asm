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

PrintBootDiskNumber:
    mov si, boot_disk_number
    call PrintString
    mov bl, dl
    call PrintByteAsHex
    call PrintNewline

ResetDiskSystem:
    xor al, al
    int 0x13
    jnc ResetDiskSystem
    cmp ah, 0
    jne ResetDiskSystemError

CheckExtensionPresent:
    mov bx, 0x55AA
    mov ah, 0x41
    int 0x13

    jc EDDError
    cmp bx, [magic_number]
    jne EDDError
    and cx, 0x04
    jz EDDError

HALT:
    cli
    hlt

ResetDiskSystemError:
    mov si, reset_disk_system_error
    call PrintString
    mov bl, ah
    call PrintByteAsHex
    call PrintNewline
    jmp BootError

EDDError:
    mov si, edd_error
    call PrintString
    call PrintNewline
    jmp BootError

BootError:
    mov si, boot_error
    call PrintString
    call PrintNewline
    jmp HALT

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

; bl: byte to print
; clears: ax, bh
PrintByteAsHex:
    xor bh, bh
    mov ah, 0x0E

    mov al, bl
    shr al, 4
    mov cx, 2
.print_digit:
    cmp al, 0xA
    jge .letter
    add al, '0'
    jmp .print
.letter:
    add al, 'A'-0xA
.print:
    int 0x10
    mov al, bl
    and al, 0xF
    loop .print_digit
    ret

; clears: ax, bh
PrintNewline:
    xor bh, bh
    mov ax, 0x0E0A      ; mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10
    ret


boot_disk_number db "Boot Disk Number: 0x", 0
reset_disk_system_error db "Reset Disk System Error: 0x", 0
edd_error db "Enhanced Disk Drive not supported", 0
boot_error db "Boot Error", 0
;guid db "pow's bootloader", 0

times 510 - ($ - $$) db 0
magic_number dw 0xAA55