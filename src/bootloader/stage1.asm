[bits 16]                   ; DH and ES:DI should be preserved by the MBR for full Plug-and-Play support
[org 0x600]                 ; we use the relocated origin and only use labels after relocation


    jmp 0x0000:0x7C00 + setup_offset      ; clear cs by far jumping to the next instruction, we can't use labels here since we haven't been relocated yet

setup_offset equ $ - $$
Setup:

    xor ax, ax
    mov ds, ax              ; clear ds
    mov es, ax              ; clear es

    mov bp, 0x9000          ; set stack and base pointer to 0x9000
    mov sp, bp

    mov ax, 0x3             ; set video mode Text (80 x 25)
    int 0x10

    cld                     ; clear direction flag for string operations

Relocate:
    mov di, 0x600
    mov si, 0x7C00
    mov cx, 512
    rep movsb                           ; copy all code to 0x0600
    jmp 0x0000:0x600 + stage1_offset    ; jump to Stage1 in relocated code

stage1_offset equ $ - $$
Stage1:
    mov si, stage1
    call PrintString
    call PrintNewline

PrintBootDisk:
    mov si, boot_disk
    call PrintString
    mov bl, dl
    call PrintByteAsHex
    call PrintNewline

ResetDiskSystem:
    mov si, resetting_disk_system
    call PrintString

    xor ah, ah
    int 0x13
    jc ResetDiskSystemError

    mov si, success
    call PrintString
    call PrintNewline

CheckExtensionPresent:
    mov si, checking_extension_present
    call PrintString

    mov bx, 0x55AA
    mov ah, 0x41
    int 0x13

    jc EDDError
    cmp bx, [boot_signature]
    jne EDDError
    and cx, 0x04
    jz EDDError

    mov si, supported
    call PrintString
    call PrintNewline

LoadStage2:
    mov si, loading_stage2
    call PrintString

    mov ah, 0x2
    mov al, 1
    mov ch, 0           ; cylinder
    mov cl, 2           ; sector
    mov dh, 0           ; head
    mov bx, 0x7C00
    int 0x13
    jc LoadStage2Error
    cmp al, 1
    jne LoadStage2Error

    mov si, success
    call PrintString
    call PrintNewline

    jmp 0x0000:0x7C00   ; jump to Stage 2

ResetDiskSystemError:
    mov si, error
    call PrintString
    call PrintNewline
    jmp BootError

EDDError:
    mov si, not_supported
    call PrintString
    call PrintNewline
    jmp BootError

LoadStage2Error:
    mov si, error
    call PrintString
    call PrintNewline
    jmp BootError

BootError:
    mov si, boot_error
    call PrintString
    call PrintNewline

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

stage1 db "Stage 1", 0
success db " success", 0
error db " error", 0
boot_disk db "Boot Disk: 0x", 0
resetting_disk_system db "Resetting Disk System...", 0
checking_extension_present db "Checking Enhanced Disk Drive...", 0
supported db " supported", 0
not_supported db " not supported", 0
loading_stage2 db "Loading Stage 2...", 0
press_to_proceed db "Press any key to proceed..."
boot_error db "Boot error.", 0

times 446 - ($ - $$) db 0
partion_entry0 times 16 db 0
partion_entry1 times 16 db 0
partion_entry2 times 16 db 0
partion_entry3 times 16 db 0
boot_signature dw 0xAA55
