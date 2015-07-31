bits 16

org 0x7C00

;*****************************************
;16-Bit 2-Stage Bootloader: Stage 1
;Just print Welcome Message and load 
;the 2nd stage from disk please
;*****************************************




start:
	;get into mode 0x03 just in case

	mov ah, 0x00
	mov al, 0x12
	int 0x10

	jmp load
	msg db "Welcome to FAFAMA OS", 0
	
prints:
	lodsb
	cmp al, 0x00
	je prints_done
	mov ah, 0x0E
	int 0x10
	jmp prints

prints_done:
	ret



load_stage_2:

.rstflp:		;Reset The Floppy System
	mov ah, 0x00
	mov dl, 0x00
	int 0x13
	jc .rstflp
	
	;***************************************
	;Load Sectors 2-9 on Floppy (4k)
	;2nd Stage Bootloader
	;**************************************

	mov ah, 0x02
	mov al, 0x08
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, 0x00
	
	mov bx, 0x8000		;totally arbitrary load location
	int 0x13
	jc load_stage_2
	jmp 0x0000:0x8000

load:
	xor ax, ax
	xor bx, bx	
	mov ds, ax
	mov es, ax
	mov si, msg
	call prints
	call load_stage_2
	cli
	hlt

times 510 - ($ - $$) db 0

dw 0xAA55
