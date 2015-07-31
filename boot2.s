bits 16

org 0x8000

jmp kmain

kprints:
	lodsb
	or al, al
	jz	kprints_done
	mov ah, 0x0E
	int 0x10
	jmp kprints
kprints_done:
	ret

kmain:
	cli
	push cs
	pop ds
	sti
	
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	
	mov si, msg
	call kprints
	
	cli
	hlt



gdt_start:
;**********NULL DESCRIPTOR*************;

	dd 0
	dd 0

;*********CODE DESCRIPTOR**************;

dw 0xFFFF
dw 0x0000
db 0x00
db 10011010b
db 11001111b
db 0x00

;*********DATA DESCRIPTOR**************;

dw 0xFFFF
dw 0x0000
db 0x00
db 10010010b
db 11001111b
db 0x00

gdt_end:

gdt_ld  dw gdt_end - gdt_start - 1
	dd gdt_start

mov eax, cr0
or eax, 1
mov cr0, eax

cli
LGDT [gdt_ld]
sti

jmp 0x08:pModeMain


bits 32

pModeMain:
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 0x90000
	
	mov eax, 0xB8000
	mov edi, eax


;***********************************
;ENABLE THE A20 LINE 
;
;**********************************
	
mov al, 0xD0
out 0x64, al
call wait_out

in al, 0x60
push eax
call wait_in

mov al, 0xD1
out 0x64, al
call wait_in

pop eax
or al, 2
out 0x60, al

jmp A20_done

wait_in:

in al, 0x64
test al, 2
jnz wait_in
ret

wait_out:
in al, 0x64
test al, 1
jnz wait_out
ret


A20_done:

	mov edi, 0xB8000

	mov byte [edi], 'H'
	mov byte [edi + 1], 0x07
	cli
	hlt

msg db "Now Entering kmain", 0





times 4096 - ($ - $$) db 0
