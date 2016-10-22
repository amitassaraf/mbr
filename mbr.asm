[bits 16]
[org 0x7C00]

A20_ENABLED equ 0x1
A20_DISABLED equ 0x0


mbr:						; Main sequence
	mov sp, 0x500
	call disable_a20        ; Disable A20 in the beggining
check:
	call check_a20_enabled  ; Check if A20 is enabled
	cmp eax, A20_ENABLED
	jne disabled
	call print_enabled
	jmp exit				; We enabled A20 successfuly, exit
disabled:
	call print_disabled
	call enable_a20
	jmp check


disable_a20:       
	in al, 0x92
	and al, 0xfd
	out 0x92, al
	ret

enable_a20:
	in al, 0x92
	or al, 2
	out 0x92, al
	ret

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
a20_disabled:
	mov eax, A20_DISABLED
	ret
a20_enabled:
	mov eax, A20_ENABLED
	ret

print_enabled:
	push 0x79
	call print_letter   ; Print 'y' to the screen to indicated A20 is enabled
	add sp, 2
	ret

print_disabled:
	push 0x6e
	call print_letter    ; Print 'n' to the screen to indicated A20 is disabled
	add sp, 2
	ret

print_done:
	push 0x64
	call print_letter     ; Print 'd' to the screen to indicated the MBR finished
	add sp, 2
	ret

print_letter:
	push bp
	mov bp, sp
	xor bh, bh
	mov cx, 0x1
	mov al, [bp + 4]           ; Print the letter to the screen to indicated the MBR finished
	mov ah, 0x0e
	int 0x10
	pop bp
	ret

exit:
	call print_done
	nop

times 510 - ($ - $$) db 0
dw 0xAA55                  ; MBR Magic