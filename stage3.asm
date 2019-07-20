.include "rommap.i"

;NESChunkLoader

;============== Loader configuration ==========
.define LOCATION $0101
.define HDR $5c6			; Free space in regular RAM
.define BUF $7800			; Used by RAW level data (only used when a level is loading)
.define TMP $3d				; Object velocities - should be safe to overwrite
;==============================================

.enum TMP
	target: dw
	size: db
	entrypoint: dw
.ende

.enum $f5
	p1: db
	p2: db
.ende
; If entry point is $0000, then we'll RTS instead of JMP since the loader was then called as a subroutine

; PPU on copying not implemented for SMB2 due to no vblank wait routine made yet.

;0x01, 0xPP, 0xBC, 0xAB	; PPU on/off, 	$2000 value, 	[entry point]		; 01 = PPU off
;0x00, 0xSS, 0xBC, 0xAB	; RAM/PPU, 		banks, 			[target address]		
;0x00, 0xSS, 0xBC, 0xAB	; RAM/PPU, 		banks, 			[target address]
;0x00, 0xSS, 0xBC, 0xAB	; RAM/PPU, 		banks, 			[target address]
;...
;0xFF					; end of header

.org LOCATION
sync:
    jsr read_joy    ; Call the games controller reading routine and read
					; data until we are not reading 0xFF, this is to sync
	cmp #$ff        ; the input stream so we know exactly what data we
	beq sync        ; are reading below.

	ldx #$00		; Read header into $a0
-	jsr read_joy		
	sta HDR, x
	inx
	cmp #$ff
	bne -
	ldx #$00
	lda HDR+2
	sta entrypoint
	LDA HDR+3
	sta entrypoint+1
	lda HDR
	bne read_block
	stx $2001		; Disable PPU
	stx $2000		; Disable NMI

read_block:
	inx
	inx
	inx
	inx
	
	lda HDR+2, x
	sta target
	lda HDR+3, x
	sta target+1
	lda #$00
	sta size
	lda HDR, x
	cmp #$ff			; Are we done?
	bne +
	jmp copy_done
+	cmp #$00
	beq copy_ram

copy_ppu:
	ldy #$00			; PPU copy
-	jsr read_joy		; First buffer 256 bytes into 0x200-0x2FF
	sta BUF, y
	iny
	bne -
	
	jsr ppu_copy
	inc size
	lda size
	cmp HDR+1, x
	bne copy_ppu
	jmp read_block

copy_ram:
	ldy #$00
-	jsr read_joy
	sta (target), y
	iny
	bne -	
	inc target+1
	inc size
	lda size
	cmp HDR+1, x
	bne copy_ram
	jmp read_block
	
copy_done:
	lda entrypoint+1
	beq +
	jmp (entrypoint)
+	rts

ppu_copy:
	txa
	pha
	ldx #$00
--	ldy #$00
	lda HDR
	beq +
	jsr wait_vblank

+	lda target+1
	sta $2006	
	stx $2006

-	lda BUF, x
	sta $2007
	iny
	inx
	cpy #$40
	bne -
	lda HDR
	
	beq +
	
	lda HDR+1
	sta $2000
	lda #$00
	sta $2005
	sta $2005
	
+	cpx #$00
	bne --
	inc target+1
	pla
	tax
	rts
	
wait_vblank:
	; Not implemented for SMB2
	rts
	
read_joy:
	txa
	pha
	tya
	pha
	jsr $f67e
	pla
	tay
	pla
	tax
	lda p1
	rts
