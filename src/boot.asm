[org 0x7c00]                ; BIOS memuat bootloader ke alamat memori ini
xor ax, ax                  ; ax = 0
mov ds, ax                  ; ds = 0
CODE_SEG equ 0x08
DATA_SEG equ 0x10

; Setup stack
mov bp, 0x9000              ; Pilih alamat yang jauh dari kode kita
mov sp, bp

; mov si, msg                 ; Simpan alamat memori 'msg' ke register 'si'
mov si, msg_hello
call print_string           ; Panggil fungsi untuk pesan pertama

call print_newline

mov si, msg_os
;call print_string           ; Panggil fungsi untuk pesan kedua

call switch_to_pm
jmp $

; Input: si = alamat string yang di akhiri angka 0
print_string:
    pusha                     ; Simpan semua register ke stack

.loop:
    lodsb
    or al, al
    jz .exit

    cmp al, ' '
    jne .skip_swap
    mov al, '_'

;.exit:
;  popa                      ; Kembalikan nilai register seperti semula
;  ret                       ; Pulang ke pemanggil

.skip_swap:
    mov ah, 0x0e
    int 0x10
    jmp .loop
  
.exit:
    popa
    ret

print_newline:
    mov ah, 0x0e
    mov al, 13                ; Carriage Return
    int 0x10
    mov al, 10
    int 0x10
    ret

; Data
msg_hello:
    db "Assembly Nih Bos", 0

msg_os:
    db "GwendengOS", 0

gdt_start:
    ; Null Descriptor
    dd 0x0                  ; 4 byte pertama
    dd 0x0                  ; 4 byte kedua nol (Total 8 byte Null Descriptor) 

    ; Code Segment Descriptor
    dw 0xffff               ; Limit (0-15 bit)
    dw 0x0                  ; Base (0-15 bit)
    db 0x0                  ; Base (16-23 bit)
    db 10011010b            ; Access byte (Present, Ring 0, Code, Executable, Readable)
    db 11001111b            ; Flags + Limit (16-19 bit)
    db 0x0                  ; Base (24-31 bit)

    dw 0xffff               ; Limit (0-15 bit)
    dw 0x0                  ; Base (0-15 bit)
    db 0x0                  ; Base (16-23 bit)
    db 10010010b            ; Access byte (Present, Ring 0, Data, Writeable)
    db 11001111b            ; Flags (Granularity, Size) + Limit (16-19 bit)
    db 0x0                  ; Base (24-31 bit)
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1          ; Size (2 byte)
    dd gdt_start                        ; Offset/Alamat (4 byte)

[bits 16]
switch_to_pm:
    cli                     ; Matikan interrupt
    lgdt [gdt_descriptor]   ; Muat tabel GDT

    mov eax, cr0
    or eax, 0x1             ; Set bit protected mode (bit 0)
    mov cr0, eax

    ; Far Jump ke segment kode kita (offset 0x08 di GDT)
    jmp CODE_SEG:init_pm

[bits 32]
init_pm:
    ; Protected Mode
    mov ax, DATA_SEG        ; Gunakan offset data segment (0x10)
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; Update stack ke tempat yang lebih luas
    mov esp, ebp

    mov [0xb8000], byte 'X'
    mov [0xb8001], byte 0x0f

    jmp $


; print_char_one:
;     lodsb                   ; Ambil satu huruf dari alamat di 'si', simpan ke 'al'
;     or al, al               ; Cek apakah hurufnya kosong (nol)?

;     ; cmp al, '!'
;     ; cmp al, ','
;     cmp al, 97

;     ; jz done                 ; Jika nol, lompat ke label 'selesai'
;     ; je done
;     jge done

;     mov ah, 0x0e            ; Mode teletype (cetak karakter)
;     ; mov bl, 0x04
;     int 0x10                ; Panggil BIOS interrupt untuk video
;     jmp print_char_one          ; Ulangi lagi

; print_char:
;     lodsb
;     cmp al, 97
;     jge done

;     cmp al, ' '             ; Cek apakah karakter di 'al' adalah spasi
;     jne skip_swap           ; JNE (Jump if Not Equal): Jika BUKAN spasi, lompat ke cetak
;     mov al, '_'             ; Jika spasi, ganti 'al' jadi underscore

; skip_swap:
;   mov ah, 0x0e
;   int 0x10
;   jmp print_char

; done:
;     jmp $                   ; Loop selamanya (agar komputer tidak mengeksekusi sampah)

; msg:
;     ; db "Anjay, Assembly nih BOSS!", 0   ; '0' adalah penanda akhir (null terminator)
;     ; db "Anjay, Assembly nih BOSS!", 'tes'

;     db "ANJAY OS", "stop", 0

times 510-($-$$) db 0       ; Isi sisa 512 byte dengan nol
dw 0xaa55                   ; Magic number supaya BIOS tahu ini bootable 
