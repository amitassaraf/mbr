[bits 16]
[org 0x7C00]

jmp check_a20_enabled

enable_a20:
	in al, 0x92
    or al, 2
    out 0x92, al

check_a20_enabled:
	mov dx, 0FFFFh
	mov es, dx
	xor dx, dx
	mov dx, [es:010h]
	add dx, 01h
	not [dx]
	cmp dx, [es:010h]
	je a20_disabled
	jne a20_enabled

a20_enabled:
	xor bh, bh
	mov cx, 01h
	mov al, 079h
	mov ah, 00Ah
	int 10h
	jmp exit

a20_disabled:
	xor bh, bh
	mov cx, 01h
	mov al, 06eh
	mov ah, 00Ah
	int 10h
	jmp enable_a20

exit:
	nop

times 510 - ($ - $$) db 0
dw 0xAA55