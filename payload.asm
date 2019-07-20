.include "rommap.i"
.define LOCATION $7900

; Chunk header, includes 16 bytes of sync-data and then the real header
.org LOCATION-26
	.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
	.db $00
    ; 17 bytes
	
	.db $01, $80, $00, (LOCATION>>8)		; Copy with PPU off, set $2000 to $80 while copying, and then jump to LOCATION
	.db $00, $01, $00, (LOCATION>>8)        ; Copy 1 banks (256 bytes) of RAM data to LOCATION (this code)
	.db $ff	                                ; End of payload
    ; 9 bytes
    
    ; 26 bytes header


.org LOCATION
payload:
    lda #$b0
    sta $2000                   ; re-enable NMI
    
    lda #$1e
    sta $2001                   ; re-enable PPU

    jmp $e95c                   ; Jump to credits

.org LOCATION+$ff
    .db $ff                     ; pad to $100 bytes