
  .mlist
  .list

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
; Comment: Implemented a table for source bank:addr lookup. Eventually this won't be needed.


data_addr_lo = $2074
data_addr_hi = $2075

xfer_asset.lsb = data_addr_lo
xfer_asset.msb = data_addr_hi

xfer_asset = xfer_asset.lsb

_ptr = $200c


sf2_page_0 = 0
sf2_page_1 = 1
sf2_page_2 = 2
sf2_page_3 = 3

no_entry_found:
              plx
              pla
            sta <_ptr+1
              pla
            sta <_ptr

            stz $FFF0 + sf2_page_0
              pla
            tam #$02
              plp
            jmp $EF55

Hook_1:
            php
            sei
            tma #$02
            tay
            pha
            stz $FFF0 + sf2_page_1
            lda #$40
            tam #$02

find_entry:

            lda <_ptr
            pha
            lda <_ptr+1
            pha
            phx



            lda bank_table,y
            cmp #$ff
          beq no_entry_found
            ; jmp .no.match
            lsr a
            sta <$77
            asl a

            adc #low(level_sprite_data)
            sta <_ptr
            lda #high(level_sprite_data)
            adc #$00
            sta <_ptr+1
            ldx bank_entry_len,y
            lda <data_addr_hi
            sta <data_addr_hi

            cly
.check.match

            lda [_ptr],y
            iny
            cmp <data_addr_lo
          bne .next.0
            lda [_ptr],y
            iny
            cmp <data_addr_hi
          bne .next.1

.match.found


            tya
            lsr a
            dec
            adc <$77
            tay

              plx
              pla
            sta <_ptr+1
              pla
            sta <_ptr

            tma #$03
              pha
            tma #$04
              pha

            lda assets.addr.lo,y
            sta xfer_asset.lsb
            lda assets.addr.hi,y
            sta xfer_asset.msb

              phx
            ldx assets.block,y

            lda assets.bank,y
            tam #$02
            inc a
            tam #$03
            inc a
            tam #$04
            stz $FFF0,x

            jsr .load_asset

            stz $FFF0 + sf2_page_0
              plx

              pla
            tam #$04
              pla
            tam #$03
              pla
            tam #$02

            lda #$01
            sta <$28
            stz <$18          ; Needed so the game doesn't try to do funny bitplane stuffs
              plp
  rts

.next.0
            iny
.next.1
            dex
          bne .check.match

.no.match
              plx
              pla
            sta <_ptr+1
              pla
            sta <_ptr

            stz $FFF0 + sf2_page_0
            pla
            tam #$02
              plp
            jmp $EF55

.load_asset
            jmp [xfer_asset]

hook_d600:
            tma #$02
            cmp #$04
          bne .original.code
            ldx <$66
            lda <$08
            sta $AD98,x
            stz <$28
  rts

.original.code
            lda <$29
          bne .skip
            jmp $D604
.skip
            jmp $D62D

hook_eef7:
            ldx <$00
            cpx #$e1
          bne .skip
            ldx <$01
            cpx #$ca
          bne .skip
            ldx #$70
            stx <$00
    rts

.skip

            ldx <$00
            cpx #$67
          bne .skip1
            ldx <$01
            cpx #$d4
          bne .skip1
            ldx #$70
            stx <$00
    rts

.skip1
          ldx #$80
          stx <$78
          jmp $eefb





;..............................................
; Author: Upsilandre's edits.

    .org $1f40

      .db $a2, $50, $a9, $ff, $4c, $ad, $ce

    .org $1f50

      .db $04, $10, $00, $02, $02, $1f, $04

;..............................................
; Author: Txray

    .org $eef7
      jmp hook_eef7
      nop


;##################################################################################################
;##################################################################################################
;##################################################################################################
;##################################################################################################

;---------------------------------------
;---------------------------------------

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

;---------------------------------------
;---------------------------------------

  .bank $02

    .org $50c9
    .db $98

    .org $D600
      jmp hook_d600
      nop

;---------------------------------------
;---------------------------------------

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

;---------------------------------------
;---------------------------------------

  .bank $09

    .org $2037
    .db $40

;---------------------------------------
;---------------------------------------

  .bank $0A

    .org $11f5
    .db $09

;---------------------------------------
;---------------------------------------

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

;---------------------------------------
;---------------------------------------

  .bank $0d

;..............................................
; Author: Upsilandre's edits.
; Comment: Looks like code (EA -> NOPs)
    .org $0489
    .db $3A, $C9, $05, $90, $02, $A9, $04, $9D, $3E, $36, $60, $EA, $EA, $EA, $EA, $EA, $EA, $EA, $EA


    .org $d3d0      ; Load full blocks of sprites at start of level

        jsr Hook_1

    .org $d149      ; Load segments of sprites during mid and end level

        jsr Hook_1

;---------------------------------------
;---------------------------------------
  .bank $14

    .org $c146
      .db $0e,$0e       ; changed from $09,$09. Palette for guillotine sprites.

    .org $c638

        lda #$0e        ; change from #$09

;---------------------------------------
;---------------------------------------
  .bank $23

    .org $135f

        ; note: A9 E0 8D 6F 2C A9 07
        lda #$e0
        sta $2c6f
        lda #$07
        sta $2c70
;---------------------------------------
;---------------------------------------

  .bank $2a

    .org $143c

        ;note:? Looks like a right side screen bounds check
        cmp #$2d

;---------------------------------------
;---------------------------------------

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

;---------------------------------------
;---------------------------------------

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






;....................................................................................................................
;####################################################################################################################
;####################################################################################################################
;####################################################################################################################
;                                                                                                                   #
; Replacement sprite assets                                                                                         #
;                                                                                                                   #
;####################################################################################################################
;....................................................................................................................


;....................................................................................
;....................................................................................
; Look up table data                                                                .
;....................................................................................

  .bank $80, "LUTs"
      .org $4000

bank_table:

      ; Bank Match
      ;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F

    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 0
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 1
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 2
    .db $00,$06,$0a,$ff,$ff,$10,$14,$ff,$24,$26,$2c,$30,$ff,$ff,$ff,$1c       ; 3
    .db $ff,$ff,$ff,$20,$ff,$ff,$22,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 4
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 5
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 6
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 7

bank_entry_len:

      ; Bank entry len
      ;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F

    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 0
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 1
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 2
    .db $03,$02,$03,$ff,$ff,$02,$04,$ff,$02,$06,$04,$06,$ff,$ff,$ff,$02       ; 3
    .db $ff,$ff,$ff,$01,$ff,$ff,$01,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 4
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 5
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 6
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff       ; 7

level_sprite_data
    ; level 1 initial load
    .dw $ffff ;.dw $520f
    .dw $ffff ;.dw $4e43
    .dw $5451

    .dw $ffff ;.dw $535d
    .dw $ffff ;.dw $4318

    .dw $ffff ;.dw $40fd
    .dw $ffff ;.dw $4dc7
    .dw $5afd

    .dw $ffff ;.dw $577b
    .dw $ffff ;.dw $5cc6

    .dw $ffff ;.dw $5f5f
    .dw $ffff ;.dw $4355
    .dw $ffff ;.dw $45a0
    .dw $ffff ;.dw $442a

    .dw $ffff ;.dw $4657
    .dw $ffff ;.dw $564b

    .dw $ffff ;.dw $4e5a

    .dw $57b1

    .dw $4000 ;38   level 1 boss

    .dw $5708 ;39
    .dw $526c
    .dw $5be0

    .dw $54b5 ;3A
    .dw $5e4d

    .dw $4ecf ;3B
    .dw $553a
    .dw $5a8c

assets.bank
    ;0-7
    .db 0
    .db 0
    .db bank(Enemy.guillotine)
    .db 0
    .db 0
    .db 0
    .db 0
    .db bank(Enemy.reaper)
    ;8-15
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    ;16-23
    .db 0
    .db bank(Enemy.buzzard)
    .db bank(Enemy.boss_1.p0)
    .db bank(Enemy.boss_1.p1)
    .db bank(Enemy.boss_1.p2)
    .db bank(Enemy.boss_1.p3)
    .db bank(Enemy.boss_1.p4)
    .db bank(Enemy.boss_1.p5)
    ;24-31
    .db bank(Enemy.boss_1.p6)
    .db bank(Enemy.boss_1.p7)
    .db bank(Enemy.boss_1.p8)
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0

assets.block
    ;0-7
    .db 0
    .db 0
    .db sf2_page_1
    .db 0
    .db 0
    .db 0
    .db 0
    .db sf2_page_1
    ;8-15
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    ;16-23
    .db 0
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    ;24-31
    .db sf2_page_1
    .db sf2_page_1
    .db sf2_page_1
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0

assets.addr.lo
    ;0-7
    .db 0
    .db 0
    .db low(Enemy.guillotine)
    .db 0
    .db 0
    .db 0
    .db 0
    .db low(Enemy.reaper)
    ;8-15
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    ;16-23
    .db 0
    .db low(Enemy.buzzard)
    .db low(Enemy.boss_1.p0)
    .db low(Enemy.boss_1.p1)
    .db low(Enemy.boss_1.p2)
    .db low(Enemy.boss_1.p3)
    .db low(Enemy.boss_1.p4)
    .db low(Enemy.boss_1.p5)
    ;24-31
    .db low(Enemy.boss_1.p6)
    .db low(Enemy.boss_1.p7)
    .db low(Enemy.boss_1.p8)
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0

assets.addr.hi
    ;0-7
    .db 0
    .db 0
    .db high(Enemy.guillotine)
    .db 0
    .db 0
    .db 0
    .db 0
    .db high(Enemy.reaper)
    ;8-15
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    ;16-23
    .db 0
    .db high(Enemy.buzzard)
    .db high(Enemy.boss_1.p0)
    .db high(Enemy.boss_1.p1)
    .db high(Enemy.boss_1.p2)
    .db high(Enemy.boss_1.p3)
    .db high(Enemy.boss_1.p4)
    .db high(Enemy.boss_1.p5)
    ;24-31
    .db high(Enemy.boss_1.p6)
    .db high(Enemy.boss_1.p7)
    .db high(Enemy.boss_1.p8)
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    ;24-31
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0
    .db 0



;....................................................................................
;....................................................................................
; Sprite assets                                                                     .
;....................................................................................



;..........................................
;..........................................
;..........................................
;..........................................

  .bank $81, "Reaper"
    .org $4000

Enemy.reaper

        tia Enemy.repear.offset, $0002, Enemy.repear.len
        tii Enemy.repear.pal, $2573, 32
  rts

Enemy.repear.data
  .incspr "assets/reaper/reaper.png"

Enemy.repear.pal
  .incpal "assets/reaper/reaper.png"

Enemy.repear.offset = Enemy.repear.data + (8 * 128)

;                                    start_offset   end_offset
Enemy.repear.len = ( 256 * 160 / 2) - (8 * 128)  -  (10 * 128)




;..........................................
;..........................................
;..........................................
;..........................................

  .bank $85, "guillotine"
    .org $4000

Enemy.guillotine

        tia Enemy.guillotine.offset, $0012, Enemy.guillotine.len
        tii Enemy.guillotine.pal, $2613, 32
  rts

Enemy.guillotine.data
  .incspr "assets/head_stone/guillotine.png"

Enemy.guillotine.pal
  .incpal "assets/head_stone/guillotine.png"

Enemy.guillotine.offset = Enemy.guillotine.data + (8 * 128)

;                                    start_offset   end_offset
Enemy.guillotine.len = ( 256 * 32 / 2) - (8 * 128)


;..........................................
;..........................................
;..........................................
;..........................................

  .bank $88, "level-1 Boss"
    .org $4000

;....>>>>>>>>>>>>>>>>>>......
    .page 2
Enemy.boss_1.p0

        tia Enemy.head.offset, $0002, Enemy.head.len
        tii Enemy.head.pal, $2453 + (3*$20), 32
        tii Enemy.head_damage.pal, $2453 + (4*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts

Enemy.head.data
  .incspr "assets/shielder/shielder_head.png"
Enemy.head.pal
  .incpal "assets/shielder/shielder_head.png"
Enemy.head_damage.pal
  .incpal "assets/shielder/shielder_head_damage.png"

Enemy.head.offset = Enemy.head.data + (12 * 128)
Enemy.head.len = ( 256 * 96 / 2) - (12 * 128) - (6 * 128)


;....>>>>>>>>>>>>>>>>>>......
  .bank $8A, "level-1 p1"
    .page 2
Enemy.boss_1.p1

        tia Enemy.legs.offset, $0012, Enemy.legs.len
        tii Enemy.legs.pal, $2453 + (9*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.boss_1.p2

        tia Enemy.chest.offset, $0012, Enemy.chest.len
        tii Enemy.legs.pal, $2453 + (9*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.body_legs.data
  .incspr "assets/shielder/shielder_body_legs.png"
Enemy.legs.pal
  .incpal "assets/shielder/shielder_body_legs.png"
Enemy.legs.offset = Enemy.body_legs.data + (4 * 128)
Enemy.legs.len = ( 256 * 112 / 2) - (4 * 128) - (6 * 128)
Enemy.chest.offset = Enemy.body_legs.data + ( 256 * 96 / 2) + (12 * 128)
Enemy.chest.len = ( 256 * 48 / 2) - (12 * 128) - (6 * 128)

;....>>>>>>>>>>>>>>>>>>......
  .bank $8D, "level-1 p2"
    .page 2
Enemy.boss_1.p3

        tia Enemy.arm1.offset, $0012, Enemy.arm1.len
        tii Enemy.arms.pal, $2453 + (10*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts

Enemy.arms.data
  .incspr "assets/shielder/shielder_arms.png"
Enemy.arms.pal
  .incpal "assets/shielder/shielder_arms.png"
Enemy.arm1.offset = Enemy.arms.data + (8 * 128)
Enemy.arm1.len = ( 256 * 112 / 2) - (8 * 128) - (12 * 128)

;....>>>>>>>>>>>>>>>>>>......
  .bank $8F, "level-1 p3"
    .page 2
Enemy.boss_1.p4

        tia Enemy.arm2.offset, $0002, Enemy.arm2.len
        tii Enemy.arms_2.pal, $2453 + (10*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.arms_2.data
  .incspr "assets/shielder/shielder_arms_2.png"
Enemy.arms_2.pal
  .incpal "assets/shielder/shielder_arms_2.png"
Enemy.arm2.offset = Enemy.arms_2.data + (12 * 128)
Enemy.arm2.len = ( 256 * 48 / 2) - (12 * 128) - (1 * 128)



;....>>>>>>>>>>>>>>>>>>......
  .bank $91, "level-1 p4"
    .page 2
Enemy.boss_1.p5

        tia Enemy.tail.offset, $0012, Enemy.tail.len
        tii Enemy.tail.pal, $2453 + (11*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
        stz $Ae10,x
  rts
Enemy.tail.data
  .incspr "assets/shielder/shielder_tail.png"

Enemy.tail.pal
  .incpal "assets/shielder/shielder_tail.png"

Enemy.tail.offset = Enemy.tail.data
Enemy.tail.len = ( 256 * 64 / 2) - (1 * 128)

;....>>>>>>>>>>>>>>>>>>......
  .bank $94, "level-1 p4"
    .page 2
Enemy.boss_1.p6

        tia Enemy.fireball.offset, $0002, Enemy.fireball.len
        tii Enemy.fireball.pal, $2453 + (12*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.fireball.data
  .incspr "assets/shielder/shielder_fireball.png"

Enemy.fireball.pal
  .incpal "assets/shielder/shielder_fireball.png"
Enemy.fireball.offset = Enemy.fireball.data
Enemy.fireball.len = ( 256 * 32 / 2) - (6 * 128)

;....>>>>>>>>>>>>>>>>>>......
    .page 2
Enemy.boss_1.p7

        tia Enemy.debris.offset, $0002, Enemy.debris.len
        tii Enemy.debris.pal, $2453 + (2*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.debris.data
  .incspr "assets/shielder/shielder_debris.png"

Enemy.debris.pal
  .incpal "assets/shielder/shielder_debris.png"
Enemy.debris.offset = Enemy.debris.data
Enemy.debris.len = ( 256 * 32 / 2) - (10 * 128)

;....>>>>>>>>>>>>>>>>>>......
    .page 2
Enemy.boss_1.p8

        tia Enemy.shielder_explosion.offset, $0002, Enemy.shielder_explosion.len
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.shielder_explosion.data
  .incspr "assets/shielder/shielder_explosion.png"
Enemy.shielder_explosion.offset = Enemy.shielder_explosion.data + (8 * 128)
Enemy.shielder_explosion.len = ( 256 * 32 / 2) - (8 * 128) - (8 * 128)


;..........................................
;..........................................
;..........................................
;..........................................

  .bank $96, "Buzzard"
    .page 2
Enemy.buzzard

        tia Enemy.buzzard.offset, $0012, Enemy.buzzard.len
        tii Enemy.buzzard.pal, $2453 + (13*$20), 32
        lda <$08
        ldx <$66
        sta $AD98,x
        stz $Ae10,x
  rts
Enemy.buzzard.data
  .incspr "assets/buzzard/buzzard.png"

Enemy.buzzard.pal
  .incpal "assets/buzzard/buzzard.png"
Enemy.buzzard.offset = Enemy.buzzard.data
Enemy.buzzard.len = ( 256 * 128 / 2) - (9 * 128)