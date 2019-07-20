.include "rommap.i"

; Stage 2 loader, mutes audio/DPCM and reads joypads a bit faster and can read
; 00 bytes without issue.
;
; Note, this code cannot contain $00 bytes, and only indirect jumps since it might not be
; perfectly aligned.

.org $0100
return:
    .db $00, $01                 ; End of payload (return to $0101)
    .ds $ce, $ea                 ; Fill with NOP

stage2:
    sei
    ldx #$ff
    txs
    inx
    txa
    inx
    sta $1FFF, x                 ; Disable NMI
    sta $4015                    ; Disable DPCM
    tay
loop:
    jsr $f67e                    ; Read inputs (2 controllers)
    lda $f5
    sta $0101, y
    iny
    cpy #$d2
    bne loop
    jmp $0101