[bits 16]
[org 0x7C00]

disable_a20:         ; Disable A20 in the begining
	in al, 0x92
    and al, 0xfd
    out 0x92, al

jmp check_a20_enabled

enable_a20:
	in al, 0x92
    or al, 2
    out 0x92, al

check_a20_enabled:
	mov dx, 0xffff
	mov es, dx
	xor dx, dx
	mov byte dl, [es:0x10] ; Save overflow value
	mov al, dl   
	not al                 
	mov [0], al            ; Change original value to notted overflow value
	mov byte al, [es:0x10]
	cmp al, dl             ; Compare new notted value to original
	jne a20_disabled       ; If they are different A20 is disabled
	je a20_enabled         ; If they are equal then A20 is enabled 

a20_enabled:
	xor bh, bh
	mov cx, 0x1
	mov al, 0x79           ; Print 'y' to the screen to indicated A20 is on
	mov ah, 0x0e
	int 0x10
	jmp exit

a20_disabled:
	xor bh, bh
	mov cx, 0x1
	mov al, 0x6e           ; Print 'n' to the screen to indicated A20 is off
	mov ah, 0x0e
	int 0x10
	jmp enable_a20

exit:
	nop

times 510 - ($ - $$) db 0
dw 0xAA55                  ; MBR Magic