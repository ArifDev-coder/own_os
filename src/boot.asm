[org 0x7c00]                ; BIOS memuat bootloader ke alamat memori ini

mov si, msg                 ; Simpan alamat memori 'msg' ke register 'si'

print_char:
    lodsb                   ; Ambil satu huruf dari alamat di 'si', simpan ke 'al'
    or al, al               ; Cek apakah hurufnya kosong (nol)?
    jz done                 ; Jika nol, lompat ke label 'selesai'

    mov ah, 0x0e            ; Mode teletype (cetak karakter)
    int 0x10                ; Panggil BIOS interrupt untuk video
    jmp print_char          ; Ulangi lagi

done:
    jmp $                   ; Loop selamanya (agar komputer tidak mengeksekusi sampah)

msg:
    db "Anjay, Assembly nih BOSS!", 0   ; '0' adalah penanda akhir (null terminator)

times 510-($-$$) db 0       ; Isi sisa 512 byte dengan nol
dw 0xaa55                   ; Magic number supaya BIOS tahu ini bootable 