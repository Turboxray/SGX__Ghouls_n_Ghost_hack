
;################################################
  .incbin "Daimakaimura.sgx"                   ;#
;################################################


  .bank 0

    .org $FBD0

;##################################################################################################
;##################################################################################################
;##################################################################################################
;##################################################################################################
; Author: Turboxray
; Comment: This is temporary and just a proof of concept. The header/string ID need to be worked out
;          for other asset blocks. Probably build a table and put it in the upper 1MB area.
Hook_1:
        lda <$08
        cmp #$fd
      bne .out
        lda <$09
        cmp #$5a
      bne .out
        lda <$0c
        cmp #$00
      bne .out
        lda <$0d
        cmp #$5a
      bne .out
        lda <$10
        cmp #$00
      bne .out
        jmp .cont

.out
        jmp $EF55

.cont
        tma #$02
          pha
        tma #$03
          pha
        tma #$04
          pha

        stz $FFF1

        lda #$40
        tam #$02
        inc a
        tam #$03
        inc a
        tam #$04

        tia $4000, $0002, ($7d40-$5a00)*2

        lda #$90
        sta $402
        lda #$01
        sta $403

        tii ($4000+$4800), $2573, 32

        stz $FFF0

          pla
        tam #$04
          pla
        tam #$03
          pla
        tam #$02


        lda #$01
        sta <$28
  rts


;..............................................
; Author: Upsilandre's edits.

    .org $1f40

      .db $a2, $50, $a9, $ff, $4c, $ad, $ce

    .org $1f50

      .db $04, $10, $00, $02, $02, $1f, $04


;##################################################################################################
;##################################################################################################
;##################################################################################################
;##################################################################################################

  .bank $01

    .org $203D
    .db $22

    .org $2d7d
    .db $9f

    .org $2d87
    .db $20

    .org $2d91
    .db $20

    .org $2d9b
    .db $20

    .org $2da5
    .db $20

    .org $2daf
    .db $9f

    .org $2db9
    .db $20

    .org $2dc3
    .db $ac

    .org $2dcd
    .db $30

    .org $2dd7
    .db $00

    .org $2de1
    .db $a0

    .org $2df5
    .db $9f


  .bank $02

    .org $50c9
    .db $98


  .bank $03

    .org $6ef5

    ; Resolution and vram access settings: 7.16mhz. Intro and title screen
    .db $05, $10, $00
    .db $03, $05, $27, $06

;..............................................
; Author: Turboxray
    ; Resolution and vram access settings: 10.74mhz. In game
    .db $06, $1a, $00
    .db $02, $13, $2f, $0f

    .org $6f0f
    .db $50

    .org $6f0f
    .db $a3

    .org $70f4
    .db $00

    .org $71d3
    .db $2f

    ; Upsilandre's hook that lives in the fixed bank
    .org $7285
    jsr $ff40


  .bank $09

    .org $2037
    .db $40


  .bank $0A

    .org $11f5
    .db $09


  .bank $0b

;..............................................
; Author: Upsilandre's edits.
; Comment: I'm not sure what these are for.

    .org $1ad9
    .db $90, $7c, $ad, $6a, $2b, $18, $79
    .db $20, $4b, $85, $0c, $ad, $ea, $2a, $38
    .db $e5, $20, $85, $14, $ad, $eb, $2a, $e5
    .db $21, $85, $15, $a5, $0c, $18, $65, $14
    .db $85, $14, $90, $02, $e6, $15, $a5, $0c
    .db $0A, $C5, $14, $62, $E5, $15, $90, $4F
    .db $A9, $08, $1D, $50, $AA, $9D, $50, $AA
    .db $A9, $20, $1D, $40, $AB, $9D, $40, $AB
    .db $BD, $18, $B5, $30, $3A, $A9, $C0, $14
    .db $64, $A9, $80, $85, $28, $AD, $EC, $2A
    .db $C5, $22, $AD, $ED, $2A, $E5, $23, $90
    .db $04, $A9, $40, $85, $28, $A5, $28, $04
    .db $64, $CE, $58, $2B, $10, $10, $9C, $58
    .db $2B, $A9, $08, $04, $63, $A9, $FF, $8D
    .db $E7, $2A, $60, $EA, $EA, $EA

    .org $1b64
    .db $6E, $33, $7D, $00, $BE, $85, $16, $BD
    .db $E6, $33, $7D, $78, $BE, $85, $17, $A5
    .db $16, $38, $E5, $22, $85, $08, $A5, $17
    .db $E5, $23, $85, $09, $A5, $0C, $18, $65
    .db $08, $85, $08, $90, $02, $E6, $09, $A5
    .db $09, $D0, $62, $A5, $0C, $0A, $C5, $08
    .db $90, $5B, $BD, $F0, $BE, $18, $65, $28
    .db $85, $10, $BD, $D6, $34, $7D, $10, $BD
    .db $85, $14, $BD, $4E, $35, $7D, $88, $BD
    .db $85, $15, $A5, $14, $38, $E5, $20, $85
    .db $08, $A5, $15, $E5, $21, $85, $09, $A5
    .db $10, $18, $65, $08, $85, $08, $90, $02
    .db $E6, $09, $A5, $09, $D0, $27, $A5, $10
    .db $0A, $C5, $08, $90, $20, $BD, $20, $AD
    .db $C9, $03, $F0, $1D, $BD, $C0, $B2, $A4
    .db $66, $D9, $C0, $B2, $F0, $0F, $99, $C0
    .db $B2, $7A, $A9, $00, $60, $EA, $EA, $EA
    .db $EA, $EA, $EA, $EA, $EA

    .org $1bfb
    .db $dc


  .bank $0d

;..............................................
; Author: Upsilandre's edits.
; Comment: Looks like code (EA -> NOPs)
    .org $0489
    .db $3A, $C9, $05, $90, $02, $A9, $04, $9D, $3E, $36, $60, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA


    .org $13d1

        jsr Hook_1


  .bank $23

    .org $135f

        ; note: A9 E0 8D 6F 2C A9 07
        lda #$e0
        sta $2c6f
        lda #$07
        sta $2c70

  .bank $2a

    .org $143c

        ;note:? Looks like a right side screen bounds check
        cmp #$2d


  .bank $5a

    .org $0f16

        ;note:? Looks like vram wait state setting. Might be dead code.. it's pretty far into the rom, and isn't the normal loading method for VDC config params.
        lda #$10
        sta $0012


    .org $100a

        ;note:? Another bounds check?
        cmp #$20


;##################################################################################################
;##################################################################################################
;##################################################################################################
;##################################################################################################

  ; From Upsilandre's hack.
  ; Comment: I think these are related to HUD offsets. All the values are 0x20 less than their
  ;          original values.

  .bank $5b

    .org $00d5
    .db $9f

    .org $00df
    .db $9f

    .org $00e9
    .db $20

    .org $00f3
    .db $20

    .org $00fd
    .db $1f

    .org $0107
    .db $1f

    .org $0111
    .db $20

    .org $011b
    .db $9f

    .org $0125
    .db $80

    .org $012f
    .db $80

    .org $0139
    .db $20

    .org $0143
    .db $20

    .org $014d
    .db $80

    .org $0157
    .db $80

    .org $0161
    .db $20

    .org $016b
    .db $00

    .org $0175
    .db $1f

    .org $017f
    .db $1f

    .org $0189
    .db $a0

    .org $0193
    .db $a0

    .org $02c5
    .db $9f

    .org $02cf
    .db $9f

    .org $02d9
    .db $20

    .org $02e3
    .db $20

    .org $02ed
    .db $1f

    .org $02f7
    .db $1f

    .org $0301
    .db $20

    .org $030b
    .db $9f

    .org $0315
    .db $20

    .org $031f
    .db $20

    .org $0329
    .db $20

    .org $0333
    .db $20

    .org $033d
    .db $80

    .org $0347
    .db $80

    .org $0351
    .db $20

    .org $035b
    .db $00

    .org $0365
    .db $1f

    .org $036f
    .db $1f

    .org $0379
    .db $a0

    .org $0383
    .db $a0

    .org $0476
        lda #$50

    .org $048a
        lda #$20

    .org $0ccf
        lda #$a0


  .bank $80

  .incspr "assets/reaper/reaper.png"
  .incpal "assets/reaper/reaper.png"

