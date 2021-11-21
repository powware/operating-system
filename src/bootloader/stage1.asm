[bits 16]                   ; DH and ES:DI should be preserved by the MBR for full Plug-and-Play support
[org 0x600]                 ; we use the relocated origin and only use labels after relocation

    jmp 0x0000:boot_address + start      ; clear cs by far jumping to the next instruction, we can't use labels here since we haven't been relocated yet
start equ $ - $$

    xor ax, ax
    mov ds, ax              ; clear ds
    mov es, ax              ; clear es

    mov bp, 0x7FFF          ; set stack and base pointer to 0x7FFF
    mov sp, bp

    mov ax, 0x3             ; set video mode Text (80 x 25)
    int 0x10

    cld                     ; clear direction flag for string operations

Relocate:
    mov di, relocation_address
    mov si, boot_address
    mov cx, 512
    rep movsb                                       ; copy all code to 0x0600
    jmp 0x0000:relocation_address + next             ; jump to relocated code
next equ $ - $$

ResetDiskSystem:
    xor ah, ah
    int 0x13
    jc ResetDiskSystemError

LoadStage2:
    mov al, [partion_entry0.type]
    cmp al, 0xEE
    je LoadStage2GPT

LoadStage2MBR:
    mov ah, 0x2
    mov al, 1
    mov ch, 0                                           ; cylinder
    mov cl, 2                                           ; sector
    mov dh, 0                                           ; head
    mov bx, boot_address
    int 0x13
    jc LoadStage2Error
    cmp al, 1
    jne LoadStage2Error
    jmp Stage2

LoadStage2GPT:
.checking_extension_present:
    mov bx, 0x55AA
    mov ah, 0x41
    int 0x13                                            ; int 0x13 ah=0x41: Check Extensions Present
    jc EDDError
    cmp bx, [boot_signature]
    jne EDDError
    and cx, 0x04
    jz EDDError

; .extended_read_drive_parameters:
;     mov ax, result_buffer_size
;     mov [result_buffer], ax                             ; 0x00: 2 bytes: size of Result Buffer (set this to 0x1E)
;     mov ah, 0x48                                        ; int 0x13 ax=0x48: Extended Read Drive Parameters
;     mov si, result_buffer                               ; pointer to Result Buffer
;     jc BootError

;     mov ax, [result_buffer_bytes_per_sector]           ; 0x18: 2 bytes: bytes per sector

.read_gpt_header:
    mov si, disk_address_packet
    mov ah, 0x42                                        ; int 0x13 ah=0x42: Extended Read Sectors From Drive
    int 0x13
    jc BootError

    mov cx, [gpt_header_partion_entries_count]
    mov ax, [gpt_header_partion_entries]
    mov [disk_address_packet.source], ax

.read_gpt_entry:
    mov ah, 0x42                                        ; int 0x13 ah=0x42: Extended Read Sectors From Drive
    int 0x13
    jc BootError

    call CheckPartitionType
    je ReadStage2

    inc word [disk_address_packet.source]
    loop .read_gpt_entry

    jmp BootError

ReadStage2:
    mov di, disk_address_packet.source
    mov si, gpt_entry_first_lba
    mov cx, 8
    rep movsb                                           ; copy address of first LBA into source for read

    mov bx, [gpt_entry_first_lba]
    mov ax, [gpt_entry_last_lba]
    sub ax, bx
    inc ax                                              ; calculate number of sectors to read

    mov bl, ah
    call PrintByteAsHex
    mov bl, al
    call PrintByteAsHex

    mov word [disk_address_packet.number_of_sectors], 127 ; should be ax, but 128 is max number
    mov word [disk_address_packet.segment], 0x7C0
    mov word [disk_address_packet.offset], 0
    mov si, disk_address_packet
    mov ah, 0x42
    int 0x13                                            ; copy first LBA into boot address 0x07C0:0000 => 0x7C00
    jc BootError



Stage2:
    jmp 0x0000:boot_address                             ; jump to Stage 2

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

CheckPartitionType:
    push si
    push di
    push cx

    mov si, gpt_entry_partition_type
    mov di, partition_type

    mov cx, 16
    rep cmpsb

    pop cx
    pop di
    pop si
    ret

; si: null-terminated string
PrintString:
    push ax
    push bx
    xor bh, bh
    mov ah, 0x0E

.print_char:
    lodsb
    or al, al
    jz .return
    int 0x10
    jmp .print_char
.return:
    pop bx
    pop ax
    ret

; bl: byte to print
PrintByteAsHex:
    push ax
    push bx
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
    pop bx
    pop ax
    ret

PrintNewline:
    push ax
    push bx
    xor bh, bh
    mov ax, 0x0E0A      ; mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10
    pop bx
    pop ax
    ret

;PrintGUID:
;    push ax
;    push bx
;    push si
;    mov si, gpt_header
;    mov cx, 16
;.loop:
;    push cx
;    lodsb
;    mov bl, al
;    call PrintByteAsHex
;    pop cx
;    loop .loop
;    pop si
;    pop bx
;    pop ax
;    ret

stage1 db "1", 0
success db " s", 0
error db " e", 0
boot_disk db "Disk: 0x", 0
resetting_disk_system db "RDS", 0
supported db " s", 0
not_supported db " ns", 0
loading_stage2 db "2.", 0
boot_error db "Boot error.", 0

disk_address_packet             db 0x1                  ; 0x00: 1 byte:	    size of DAP (set this to 0x10)
                                db 0                    ; 0x01: 1 byte:	    unused, should be zero
.number_of_sectors              dw 0x1                  ; 0x02: 2 bytes:	number of sectors to be read (GPT header is contained in a single sector)
.offset                         dw gpt_header           ; 0x04: 2 bytes:    offset
.segment                        dw 0                    ; 0x06: 2 bytes:    segment
.source                         dw 0x1                  ; 0x08: 2 bytes:    absolute number of the start of the sectors to be read 8 bytes, initialized with LBA1 for GPT Header
                                dw 0                    ; 0x0A: 2 bytes:
                                dd 0                    ; 0x0C: 4 bytes:

partition_type             db "pow's bootloader"   ; 27776F70-2073-6F62-6f74-6C6F61646572

padding    times 446 - ($ - $$) db 0

partion_entry0                  db 0
.first_sector           times 3 db 0
.type                           db 0
.last_sector            times 3 db 0
.first_sector_lba               dd 0
.sector_count                   dd 0

partion_entry1                  db 0
.first_sector           times 3 db 0
.type                           db 0
.last_sector            times 3 db 0
.first_sector_lba               dd 0
.sector_count                   dd 0

partion_entry2                  db 0
.first_sector           times 3 db 0
.type                           db 0
.last_sector            times 3 db 0
.first_sector_lba               dd 0
.sector_count                   dd 0

partion_entry3                  db 0
.first_sector           times 3 db 0
.type                           db 0
.last_sector            times 3 db 0
.first_sector_lba               dd 0
.sector_count                   dd 0

boot_signature                  dw 0xAA55

; Macros

relocation_address equ 0x600
boot_address equ 0x7C00

; RAM Macros

ram equ relocation_address + 512

result_buffer_size equ 0x1E
result_buffer equ ram
result_buffer_bytes_per_sector equ result_buffer + 0x18             ; 2 bytes

gpt_header_size equ 0x5C                                            ; 8 bytes
gpt_header equ result_buffer + result_buffer_size                   ; 8 bytes
gpt_header_partion_entries equ gpt_header + 0x48                    ; 8 bytes
gpt_header_partion_entries_count equ gpt_header + 0x50              ; 4 bytes

gpt_entry equ gpt_header
gpt_entry_partition_type equ gpt_entry
gpt_entry_first_lba equ gpt_header + 0x20
gpt_entry_last_lba equ gpt_header + 0x28
