    cpu 68000
    supmode on
    padding off
    include "flicky_equals.inc"
    include "flicky_rams.inc"
    include "flicky_externs.inc"
    include "flicky_funcs.inc"

; segment "ROM"
; ROM segment
off_0:          dc.l unk_FFFF70
                dc.l EntryPoint
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l EXT
                dc.l ErrorTrap
                dc.l HBLANK
                dc.l ErrorTrap
                dc.l VBLANK
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
                dc.l ErrorTrap
CopyRights:     dc.b "SEGA MEGA DRIVE (C)SEGA 1991.FEB"
DomesticName:   dc.b "FLICKY                                                         "
                dc.b " FLICKY                          GM 00001022-00"
Checksum:       dc.w $B7E0
Peripherials:   dc.b "J               "
RomStart:       dc.l         0
RomEnd:         dc.l byte_1FFFF
RamStart:       dc.l M68K_RAM
RamEnd:         dc.l dword_FFFFFC+3
SramCode:       dc.b "            "
ModemCode:      dc.b "            "
Reserved:       dc.b "                                        "
CountryCode:    dc.b "JUE             "
ErrorTrap:
                nop
                nop
                bra.s   ErrorTrap
EntryPoint:
                tst.l   (IO_CT1_CTRL).l
                bne.s   port_A_ok
                tst.w   (IO_EXT_CTRL).l

port_A_ok:
                bne.s   skip_setup
                lea     SetupValues(pc),a5
                movem.w (a5)+,d5-d7
                movem.l (a5)+,a0-a4
                move.b  -$10FF(a1),d0
                andi.b  #$F,d0
                beq.s   skip_security
                move.l  #'SEGA',$2F00(a1)

skip_security:
                move.w  (a4),d0
                moveq   #0,d0
                movea.l d0,a6
                move    a6,usp
                moveq   #$17,d1

vdp_init_loop:
                move.b  (a5)+,d5
                move.w  d5,(a4)
                add.w   d7,d5
                dbf     d1,vdp_init_loop
                move.l  (a5)+,(a4)
                move.w  d0,(a3)
                move.w  d7,(a1)
                move.w  d7,(a2)

wait_for_z80:
                btst    d0,(a1)
                bne.s   wait_for_z80
                moveq   #$25,d2

z80_init_loop:
                move.b  (a5)+,(a0)+
                dbf     d2,z80_init_loop
                move.w  d0,(a2)
                move.w  d0,(a1)
                move.w  d7,(a2)

clr_ram_loop:
                move.l  d0,-(a6)
                dbf     d6,clr_ram_loop
                move.l  (a5)+,(a4)
                move.l  (a5)+,(a4)
                moveq   #$1F,d3

clr_cram_loop:
                move.l  d0,(a3)
                dbf     d3,clr_cram_loop
                move.l  (a5)+,(a4)
                moveq   #$13,d4

clr_vsram_loop:
                move.l  d0,(a3)
                dbf     d4,clr_vsram_loop
                moveq   #3,d5

psg_init_loop:
                move.b  (a5)+,$11(a3)
                dbf     d5,psg_init_loop
                move.w  d0,(a2)
                movem.l (a6),d0-d7/a0-a6
                move    #$2700,sr

skip_setup:
                bra.s   GameProgram
SetupValues:
                dc.w $8000
                dc.w $3FFF
                dc.w $100
                dc.l Z80_RAM
                dc.l IO_Z80BUS
                dc.l IO_Z80RES
                dc.l VDP_DATA
                dc.l VDP_CTRL
                dc.b 4, $14, $30, $3C, 7, $6C, 0, 0
                dc.b 0, 0, $FF, 0, $81, $37, 0, 1
                dc.b 1, 0, 0, $FF, $FF, 0, 0, $80
                dc.l $40000080
                dc.b $AF, 1, $D9, $1F, $11, $27, 0, $21
                dc.b $26, 0, $F9, $77, $ED, $B0, $DD, $E1
                dc.b $FD, $E1, $ED, $47, $ED, $4F, $D1, $E1
                dc.b $F1, 8, $D9, $C1, $D1, $E1, $F1, $F9
                dc.b $F3, $ED, $56, $36, $E9, $E9
                dc.l $81048F02
                dc.l $C0000000
                dc.l $40000010
                dc.b $9F,$BF,$DF,$FF

GameProgram:
                tst.w   (VDP_CTRL).l
                move    #$2700,sr
                move.b  (IO_PCBVER+1).l,d0
                andi.b  #$F,d0
                beq.s   checksum_check
                move.l  #'SEGA',(IO_TMSS).l

checksum_check:
                movea.l #RomEnd,a0
                move.l  (a0),d1
                addq.l  #1,d1
                movea.l #ErrorTrap,a0
                sub.l   a0,d1
                asr.l   #1,d1
                move.w  d1,d2
                subq.w  #1,d2
                swap    d1
                moveq   #0,d0

checksum_loop:
                add.w   (a0)+,d0
                dbf     d2,checksum_loop
                dbf     d1,checksum_loop
                cmp.w   (Checksum).w,d0
                beq.s   CheckSumOk
                bra.w   CheckSumError

CheckSumOk:
                btst    #6,(IO_EXT_CTRL+1).l
                bne.s   loc_3AA
                move    #$2700,sr
                lea     ((IO_CT1_DATA+1)).l,a0
                bsr.w   sub_43A
                cmpi.b  #0,d0
                beq.s   loc_374
                nop
                nop
                nop
                nop
                nop

loc_374:
                moveq   #$40,d0
                move.b  d0,(IO_CT1_CTRL+1).l
                move.b  d0,(IO_CT2_CTRL+1).l
                move.b  d0,(IO_EXT_CTRL+1).l

loc_388:
                lea     (M68K_RAM).l,a6
                moveq   #0,d7
                move.w  #$3FFF,d6

loc_394:
                move.l  d7,(a6)+
                dbf     d6,loc_394
                move.l  #'init',(dword_FFFFFC).w
                move.l  #$100000,(dword_FFCC00).w

loc_3AA:
                cmpi.l  #'init',(dword_FFFFFC).w
                bne.s   loc_388
                bsr.w   LoadFuncTable
                bsr.w   SetInitialVDPRegs
                bsr.w   sub_E82
                bsr.w   sub_402
                bsr.w   LoadZ80Driver
                lea     (sub_10000).l,a0
                lea     (M68K_RAM).l,a1
                move.w  #$2FFF,d0

loc_3D8:
                move.l  (a0)+,(a1)+
                dbf     d0,loc_3D8
                jmp     M68K_RAM

CheckSumError:
                bsr.w   sub_402
                move.l  #$C0000000,(VDP_CTRL).l
                moveq   #$3F,d7

fill_red_screen:
                move.w  #$E,(VDP_DATA).l
                dbf     d7,fill_red_screen

endless_loop:
                bra.s   endless_loop

sub_402:
                move.l  #$C0000000,(VDP_CTRL).l
                moveq   #$3F,d0

loc_40E:
                move.w  #0,(VDP_DATA).l
                dbf     d0,loc_40E
                move.l  #$40000000,(VDP_CTRL).l
                lea     (VDP_DATA).l,a5
                move.w  #0,d6
                move.w  #$53FF,d7

loc_432:
                move.w  d6,(a5)
                dbf     d7,loc_432
                rts

sub_43A:
                movem.l d1-d2/a1,-(sp)
                lea     byte_466(pc),a1
                move.b  (a1),6(a0)
                moveq   #0,d0
                moveq   #8,d1

loc_44A:
                move.b  (a1)+,(a0)
                nop
                nop
                move.b  (a0),d2
                and.b   (a1)+,d2
                beq.s   loc_458
                or.b    d1,d0

loc_458:
                lsr.b   #1,d1
                bne.s   loc_44A
                clr.b   6(a0)
                movem.l (sp)+,d1-d2/a1
                rts

byte_466:       dc.b $40, $C, $40, 3, 0, $C, 0, 3
LoadSegaScreen:
                bsr.w   sub_872
                lea     word_4F6(pc),a5 ; palette cycle data?
                bsr.w   sub_1280
                move.w  #$B4,d1
                moveq   #0,d2

loc_480:
                bsr.w   sub_F3C
                subq.w  #1,d1
                move.w  d1,d0
                andi.w  #3,d0
                bne.s   loc_480
                cmpi.w  #$28,d2
                bgt.s   locret_4B2
                move.w  d2,d3
                addq.w  #2,d2
                lea     (unk_FFF7E4).w,a1
                moveq   #$A,d7

loc_49E:
                cmpi.w  #$28,d3
                blt.s   loc_4A6
                moveq   #0,d3

loc_4A6:
                move.w  sega_pal(pc,d3.w),(a1)+
                addq.w  #2,d3
                dbf     d7,loc_49E
                bra.s   loc_480

locret_4B2:
                rts

sega_pal:       dc.b $E, $C0, $E, $A0, $E, $80, $E, $60, $E, $40
                dc.b $E, $20, $E, 0, $C, 0, $A, 0, 8, 0
                dc.b 6, 0, 8, 0, $A, 0, $C, 0, $E, 0
                dc.b $E, $20, $E, $40, $E, $60, $E, $80, $E, $A0
SegaScreen:
                btst    #7,(word_FFFF8E+1).w
                bne.s   loc_4EC
                cmpi.w  #$78,(word_FFFF92).w
                bcs.s   loc_4F2

loc_4EC:
                move.w  #0,(word_FFFFC0).w

loc_4F2:
                bra.w   sub_1114

word_4F6:       dc.w $1EEE, $2EC0, $3EA0, $4E80, $5E60, $6E40, $7E20, $8E00, $9C00
                dc.w $AA01, $E316, 1, $C04, $600, 0, 0, $3CF3, $FF80
sega_tiles:     dc.b $80, $30, $80, 4, 5, $14, 7, $23, 1, $35, $11, $46, $2B, $57, $6B, $66
                dc.b $32, $74, 4, $81, 3, 0, $16, $34, $82, 6, $2E, $18, $F0, $38, $EE, $83
                dc.b 4, 6, $17, $75, $84, 6, $2A, $16, $37, $27, $70, $37, $72, $85, 6, $30
                dc.b $17, $6C, $27, $6D, $38, $F7, $86, 5, $12, $16, $2F, $27, $66, $37, $67, $87
                dc.b 5, $10, $15, $16, $28, $F6, $37, $6A, $88, 6, $31, $17, $76, $28, $F1, $37
                dc.b $74, $89, 5, $14, $17, $79, $27, $71, $37, $73, $8B, 7, $7A, $8D, 8, $EF
                dc.b $8F, 5, $13, $FF, $4A, $FF, $42, $74, $B4, $9C, $55, 7, $A, $2A, $45, $62
                dc.b $2A, $AE, $A, $B, $58, $55, $EE, $25, $FF, $1C, $DC, $F1, $33, $21, 1, $99
                dc.b $86, $7E, $36, $CF, $E6, $FD, $5D, $BF, $A2, $FE, $3F, $9B, $D6, $C4, $6B, $15
                dc.b 2, $C6, $9D, $16, $A5, $F3, $E2, $7B, $71, $1B, $1F, $FE, $36, $CF, $6D, $6C
                dc.b $42, $45, $8E, $68, $DA, $FD, $97, $89, $5B, $FE, $3C, $FA, $24, $C8, $43, $2E
                dc.b $7E, $37, $F3, $ED, $6E, $9E, $7F, $63, $1F, $D5, $9D, $2B, $16, $62, $2A, $47
                dc.b $C7, $F3, $6B, $52, $B2, $F6, $F5, $5F, $9F, $C5, $D, $B2, $FF, $8C, $33, $F1
                dc.b $45, 6, $69, $11, $9B, $CA, $DB, $3D, $25, $A6, $AC, $7F, $E3, $4E, $9F, $AB
                dc.b $45, 5, $91, $FC, $F4, $FC, $DF, $1E, $9E, $BC, $79, $FE, $2B, $4D, $7E, $91
                dc.b $13, $2F, $59, $7A, $D6, $3F, $14, $2B, $15, $FE, $84, $E9, $C5, $C5, $F1, $12
                dc.b $AC, $40, $CD, $1E, $A, $F, $9C, $D0, $BD, $C1, $D1, $46, $3A, $56, $3B, $C
                dc.b $B1, $11, $F, $8E, $88, $43, $E2, $16, $98, $F3, $FD, $B, $87, $11, $FD, $8D
                dc.b $7A, $24, $44, $42, $20, $AB, $68, $BD, $C1, $64, $88, $2C, $91, 9, $18, $1C
                dc.b $2A, $58, $61, $FB, $3A, $77, $B8, $33, $43, $C, $F4, $7B, $67, $62, $12, $2C
                dc.b $43, $FE, $77, $F5, $F0, $6B, $9C, $24, $47, $1E, $C8, $65, $44, $A6, $B9, $AD
                dc.b $23, $E1, $DF, $4B, $5C, $C9, $90, $CA, 0, $B3, $C1, $14, $16, $47, $EB, $75
                dc.b $3F, $3B, $F8, $E9, $A1, $99, $19, $F9, $C3, $3F, $14, $50, $66, $8F, $F9, $FF
                dc.b $C7, $4B, $C3, $F3, $B1, 8, $7C, $5C, $3D, $12, $B0, $88, $29, $ED, $FB, $38
                dc.b $84, $8B, $1C, $DA, $EF, $76, $21, $22, $C4, $53, $F5, $B3, $C7, $F5, $E8, $41
                dc.b $97, $3F, $1B, $F9, $F6, $79, $A1, $11, $9C, $7B, $E5, $6E, $88, $D5, $8A, $B1
                dc.b $CB, $14, $88, $A9, $32, $B, $38, $4A, $D2, $C2, $A2, $17, $32, $31, $19, $42
                dc.b $45, $88, $48, $B5, $94, $2F, $EB, $71, $FC, $FD, $A8, $E1, $1F, $11, $10, $65
                dc.b $44, $21, $71, $45, $95, 8, $5B, $E, $94, $44, $44, 8, $99, $69, $CB, 0
                dc.b $F0, $22, $A5, $17, $24, 8, $71, $76, $C7, $FD, 9, $D8, $BD, $DB, $6B, $81
                dc.b $FE, $16, $D, $C3, $54, $B2, $91, $62, $13, $93, $1C, $38, $56, $B, $3F, $5F
                dc.b $CE, $EF, $85, $CF, $35, $A1, $96, $B8, $19, $A2, $4D, $22, $35, $E1, $73, $5E
                dc.b $BE, $11, $E1, $C, $99, $20, $42, $3D, $4B, 2, $16, $A4, $F0, $C1, $76, $6F
                dc.b $ED, $9E, $84, $19, $A3, $10, $6A, $D5, $9B, $7D, $57, $A6, $F6, $F0, $EB, $43
                dc.b 4, $48, $3C, $F2, $95, $70, $5B, $E8, $91, $84, $AE, $EF, $AB, $F, $D1, $45
                dc.b $96, $C8, $A1, $10, $1B, $57, $BC, 8, $2C, $BB, $6A, $FD, $6C, $33, $25, $60
                dc.b $CD, $22, $C, $D2, $20, $FE, $7E, $17, $AF, $5B, $B2, $D1, $1C, $5C, $89, 8
                dc.b $8B, $91, $E0, $BD, $FB, $DD, $B5, $B2, $F, $BC, $41, $64, $5B, $2E, $EE, $C9
                dc.b $67, 5, $95, $A5, $87, $EF, $66, $66, $43, $DF, $10, $66, $91, $B, $7C, $D2
                dc.b $20, $CD, $67, 9, $40, $5B, $14, $41, $88, $4D, $61, $31, $1A, $C5, $74, $FC
                dc.b $57, $AB, $BA, $EE, $E0, $C1, $FA, $F7, $60, $BF, $A3, $EE, $48, $84, $8F, $EC
                dc.b $FF, $45, $B3, $95, $9C, $16, $86, $DE, $50, $F7, $E0, $C9, 2, $10, $DD, $EF
                dc.b $C1, $61, $99, $5A, $E8, $28, $48, $82, $24, $19, $15, $9E, 1, $43, $2D, $81
                dc.b $15, $69, $5D, $DD, $47, $C, $E, $CD, $70, $DB, $55, $7B, $41, $82, $16, $B8
                dc.b $C1, $F4, $EE, $F7, $AB, $54, $93, $86, $A9, $72, $D4, $B, $24, $41, $67, $D9
                dc.b $CA, $D9, $95, $BF, $44, $99, $95, $83, $E6, $AC, $56, $2B, $C, $41, $D, $75
                dc.b $A4, $74, $5F, $F2, $DD, $B1, $44, $6E, $DB, $C0, $ED, $DD, $E0, $42, $46, 4
                dc.b $77, $7B, $EA, $5C, $CD, $95, $5E, $CA, $1F, $7F, $6A, $D8, $84, $8B, $11, $CB
                dc.b $55, $15, $BB, $B0, $9B, $83, 5, $92, $38, $7B, $92, $B0, $8F, $7F, $EC, $EE
                dc.b $7D, $9C, $A0, $41, $68, $F2, $BA, $3C, $E, $15, $C0, $88, $E1, $5F, $81, $C3
                dc.b $7F, $6B, $D6, $54, $20, $CF, $54, $8D, $5A, $A4, $85, $88, $47, $DF, $55, $FC
                dc.b $57, $F6, $26, $81, $C, $D0, $D0, $19, $A6, $BB, $F8, $90
nullsub_1:
                rte

LoadFuncTable:
                lea     func_table(pc),a0
                lea     (EXT).w,a1
                move.w  (a0)+,d0

loc_862:
                move.w  #$4EF9,(a1)+
                moveq   #0,d1
                move.w  (a0)+,d1
                move.l  d1,(a1)+
                dbf     d0,loc_862
                rts

sub_872:
                lea     (unk_FFFF70).w,a6
                moveq   #0,d7
                move.w  #$13,d6

loc_87C:
                move.l  d7,(a6)+
                dbf     d6,loc_87C
                lea     (word_FFF7E0).w,a6
                moveq   #0,d7
                move.w  #$3F,d6

loc_88C:
                move.l  d7,(a6)+
                dbf     d6,loc_88C
                move.w  #4,(word_FFFF98).w
                addq.w  #4,(word_FFFFC0).w
                clr.l   (dword_FFF550).w
                movem.w word_8D4(pc),d0-d5
                movem.w d0-d5,(word_FFFFD8).w
                bsr.w   SetInitialVDPRegs
                btst    #6,(IO_PCBVER+1).l
                beq.s   loc_8C0
                move.b  #$3C,(byte_FFFF71).w

loc_8C0:
                bsr.w   sub_E82
                move.l  #$C0000000,(a6)
                move.w  #0,-4(a6)
                bra.w   sub_EA2

word_8D4:       dc.w $BE00, $B800, $B000, $C000, $E000, $40
sub_8E0:
                movem.w d0-d2,-(sp)
                move.w  #$400,d0
                bsr.s   loc_906
                movem.w (sp)+,d0-d2
                addi.w  #$400,d2
                subi.w  #$400,d0
                cmpi.w  #$400,d0
                bls.s   loc_906
                bra.s   sub_8E0

sub_8FE:
                moveq   #0,d1

loc_900:
                cmpi.w  #$400,d0
                bhi.s   sub_8E0

loc_906:
                lea     (VDP_CTRL).l,a6
                subq.w  #1,d0
                swap    d1
                move.w  #$8F01,(a6)
                move.w  d0,d1
                andi.w  #$FF,d0
                ori.w   #$9300,d0
                move.w  d0,(a6)
                lsr.w   #8,d1
                ori.w   #$9400,d1
                move.w  d1,(a6)
                swap    d1
                move.w  #$9780,(a6)
                move.l  #$200000,d0
                move.w  d2,d0
                lsl.l   #2,d0
                move.w  d2,d0
                andi.w  #$3FFF,d0
                ori.w   #$4000,d0
                swap    d0
                move.l  d0,(a6)
                move.b  d1,-4(a6)
                bsr.w   sub_9D8
                move.w  #$8F02,(a6)
                rts

sub_954:
                movem.w d0-d2,-(sp)
                move.w  #$200,d0
                bsr.s   loc_97C
                movem.w (sp)+,d0-d2
                addi.w  #$200,d2
                addi.w  #$200,d1
                subi.w  #$200,d0
                cmpi.w  #$200,d0
                bls.s   loc_97C
                bra.s   sub_954

sub_976:
                cmpi.w  #$200,d0
                bhi.s   sub_954

loc_97C:
                lea     (VDP_CTRL).l,a6
                swap    d1
                move.w  #$8F01,(a6)
                move.w  d0,d1
                andi.w  #$FF,d0
                ori.w   #$9300,d0
                move.w  d0,(a6)
                lsr.w   #8,d1
                ori.w   #$9400,d1
                move.w  d1,(a6)
                swap    d1
                move.w  d1,d0
                andi.w  #$FF,d0
                ori.w   #$9500,d0
                move.w  d0,(a6)
                lsr.w   #8,d1
                ori.w   #$9600,d1
                move.w  d1,(a6)
                move.w  #$97C0,(a6)
                move.l  #$300000,d0
                move.w  d2,d0
                lsl.l   #2,d0
                move.w  d2,d0
                andi.w  #$3FFF,d0
                ori.w   #$4000,d0
                swap    d0
                move.l  d0,(a6)
                bsr.w   sub_9D8
                move.w  #$8F02,(a6)
                rts

sub_9D8:
                move.w  (a6),d0
                andi.w  #2,d0
                bne.s   sub_9D8
                rts

sub_9E2:
                movem.w d0-d2,-(sp)
                move.w  #$400,d0
                bsr.s   loc_A12
                movem.w (sp)+,d0-d2
                addi.w  #$400,d1
                addi.w  #$400,d2
                subi.w  #$400,d0
                cmpi.w  #$400,d0
                bls.s   loc_A12
                bra.s   sub_9E2

sub_A04:
                bsr.s   sub_A1A
                ori.w   #$C000,d0
                bra.s   sub_A66

sub_A0C:
                cmpi.w  #$400,d0
                bhi.s   sub_9E2

loc_A12:
                bsr.s   sub_A1A
                ori.w   #$4000,d0
                bra.s   sub_A66

sub_A1A:
                lea     (VDP_CTRL).l,a6
                lsr.w   #1,d0
                swap    d1
                move.w  d0,d1
                andi.w  #$FF,d0
                ori.w   #$9300,d0
                move.w  d0,(a6)
                lsr.w   #8,d1
                ori.w   #$9400,d1
                move.w  d1,(a6)
                swap    d1
                lsr.w   #1,d1
                move.w  d1,d0
                andi.w  #$FF,d0
                ori.w   #$9500,d0
                move.w  d0,(a6)
                lsr.w   #8,d1
                ori.w   #$9680,d1
                move.w  d1,(a6)
                move.w  #$977F,(a6)
                move.l  #$200000,d0
                move.w  d2,d0
                lsl.l   #2,d0
                move.w  d2,d0
                andi.w  #$3FFF,d0
                rts

sub_A66:
                move.w  d0,(a6)
                swap    d0
                move.w  d0,(word_FFFFAE).w
                move.w  (word_FFFFAE).w,(a6)
                rts

sub_A74:
                moveq   #0,d1

loc_A76:
                movem.l d3/a5,-(sp)
                lea     (VDP_CTRL).l,a6
                lea     VDP_DATA-VDP_CTRL(a6),a5
                move.b  d1,d3
                lsl.w   #8,d3
                move.b  d1,d3
                move.w  d3,d1
                swap    d3
                move.w  d1,d3
                clr.l   d1
                move.w  d2,d1
                lsl.l   #2,d1
                move.w  d2,d1
                andi.w  #$3FFF,d1
                ori.w   #$4000,d1
                swap    d1
                move.l  d1,(a6)
                addq.w  #3,d0
                lsr.w   #2,d0
                move.w  d0,d1
                lsr.w   #3,d1
                bra.s   loc_ABE

loc_AAE:
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)
                move.l  d3,(a5)

loc_ABE:
                dbf     d1,loc_AAE
                andi.w  #7,d0
                bra.s   loc_ACA

loc_AC8:
                move.l  d3,(a5)

loc_ACA:
                dbf     d0,loc_AC8
                movem.l (sp)+,d3/a5
                rts

Nem_Decomp:
                movem.l d0-d7/a0-a1/a3-a5,-(sp)
                lea     (Nem_PCD_WriteRowToVDP).l,a3
                lea     (VDP_DATA).l,a4
                bra.s   Nem_Decomp_Main

Nem_Decomp_To_RAM:
                movem.l d0-d7/a0-a1/a3-a5,-(sp)
                lea     (Nem_PCD_WriteRowToRAM).l,a3

Nem_Decomp_Main:
                lea     (word_FFE630).w,a1
                move.w  (a0)+,d2
                lsl.w   #1,d2
                bcc.s   loc_AFE
                adda.w  #(Nem_PCD_WriteRowToRAM-2-Nem_PCD_WriteRowToVDP_XOR),a3

loc_AFE:
                lsl.w   #2,d2
                movea.w d2,a5
                moveq   #8,d3
                moveq   #0,d2
                moveq   #0,d4
                bsr.w   Nem_Build_Code_Table
                bsr.w   sub_C0C

Nem_Process_Compressed_Data:
                moveq   #8,d0
                bsr.w   sub_C16
                cmpi.w  #$FC,d1
                bcc.s   loc_B4C
                add.w   d1,d1
                move.b  (a1,d1.w),d0
                ext.w   d0
                bsr.w   Nem_PCD_InlineData
                move.b  1(a1,d1.w),d1

Nem_PCD_GetRepeatCount:
                move.w  d1,d0
                andi.w  #$F,d1
                andi.w  #$F0,d0
                lsr.w   #4,d0

Nem_PCD_WritePixel:
                lsl.l   #4,d4
                or.b    d1,d4
                subq.w  #1,d3
                bne.s   Nem_PCD_WritePixel_Loop
                jmp     (a3)

Nem_PCD_NewRow:
                moveq   #0,d4
                moveq   #8,d3

Nem_PCD_WritePixel_Loop:
                dbf     d0,Nem_PCD_WritePixel
                bra.s   Nem_Process_Compressed_Data

loc_B4C:
                moveq   #6,d0
                bsr.w   Nem_PCD_InlineData
                moveq   #7,d0
                bsr.w   sub_C26
                bra.s   Nem_PCD_GetRepeatCount

Nem_PCD_WriteRowToVDP:
                move.l  d4,(a4)
                subq.w  #1,a5
                move.w  a5,d4
                bne.s   Nem_PCD_NewRow
                bra.s   loc_B84

Nem_PCD_WriteRowToVDP_XOR:
                eor.l   d4,d2
                move.l  d2,(a4)
                subq.w  #1,a5
                move.w  a5,d4
                bne.s   Nem_PCD_NewRow

loc_B6E:
                bra.s   loc_B84

Nem_PCD_WriteRowToRAM:
                move.l  d4,(a4)+
                subq.w  #1,a5
                move.w  a5,d4
                bne.s   Nem_PCD_NewRow
                bra.s   loc_B84
                eor.l   d4,d2
                move.l  d2,(a4)+
                subq.w  #1,a5
                move.w  a5,d4
                bne.s   Nem_PCD_NewRow

loc_B84:
                movem.l (sp)+,d0-d7/a0-a1/a3-a5
                rts

Nem_Build_Code_Table:
                move.b  (a0)+,d0

Nem_BCT_ChkEnd:
                cmpi.b  #$FF,d0
                bne.s   Nem_BCT_NewPalIndex
                rts

Nem_BCT_NewPalIndex:
                move.w  d0,d7

Nem_BCT_Loop:
                move.b  (a0)+,d0
                cmpi.b  #$80,d0
                bcc.s   Nem_BCT_ChkEnd
                move.b  d0,d1
                andi.w  #$F,d7
                andi.w  #$70,d1
                or.w    d1,d7
                andi.w  #$F,d0
                move.b  d0,d1
                lsl.w   #8,d1
                or.w    d1,d7
                moveq   #8,d1
                sub.w   d0,d1
                bne.s   Nem_BCT_ShortCode
                move.b  (a0)+,d0
                add.w   d0,d0
                move.w  d7,(a1,d0.w)
                bra.s   Nem_BCT_Loop

Nem_BCT_ShortCode:
                move.b  (a0)+,d0
                lsl.w   d1,d0
                add.w   d0,d0
                moveq   #1,d5
                lsl.w   d1,d5
                subq.w  #1,d5

Nem_BCT_ShortCode_Loop:
                move.w  d7,(a1,d0.w)
                addq.w  #2,d0
                dbf     d5,Nem_BCT_ShortCode_Loop
                bra.s   Nem_BCT_Loop

sub_BDC:
                lsl.w   d0,d5
                add.w   d0,d6
                add.w   d0,d0
                and.w   locret_C38(pc,d0.w),d1
                add.w   d1,d5
                move.w  d6,d0
                subq.w  #8,d0
                bcs.s   locret_BFE
                bne.s   loc_BF6
                clr.w   d6
                move.b  d5,(a0)+
                rts

loc_BF6:
                move.w  d5,d6
                lsr.w   d0,d6
                move.b  d6,(a0)+
                move.w  d0,d6

locret_BFE:
                rts

sub_C00:
                neg.w   d6
                beq.s   locret_C0A
                addq.w  #8,d6
                lsl.w   d6,d5
                move.b  d5,(a0)+

locret_C0A:
                rts

sub_C0C:
                move.b  (a0)+,d5
                asl.w   #8,d5
                move.b  (a0)+,d5
                moveq   #$10,d6
                rts

sub_C16:
                move.w  d6,d7
                sub.w   d0,d7
                move.w  d5,d1
                lsr.w   d7,d1
                add.w   d0,d0
                and.w   word_C3A-2(pc,d0.w),d1
                rts

sub_C26:
                bsr.s   sub_C16
                lsr.w   #1,d0

Nem_PCD_InlineData:
                sub.w   d0,d6
                cmpi.w  #9,d6
                bcc.s   locret_C38
                addq.w  #8,d6
                asl.w   #8,d5
                move.b  (a0)+,d5

locret_C38:
                rts

word_C3A:       dc.w 1
                dc.w 3
                dc.w 7
                dc.w $F
                dc.w $1F
                dc.w $3F
                dc.w $7F
                dc.w $FF
                dc.w $1FF
                dc.w $3FF
                dc.w $7FF
                dc.w $FFF
                dc.w $1FFF
                dc.w $3FFF
                dc.w $7FFF
                dc.w $FFFF
sub_C5A:
                move.w  a3,d3
                swap    d4
                bpl.s   loc_C6A
                subq.w  #1,d6
                btst    d6,d5
                beq.s   loc_C6A
                ori.w   #$1000,d3

loc_C6A:
                swap    d4
                bpl.s   loc_C78
                subq.w  #1,d6
                btst    d6,d5
                beq.s   loc_C78
                ori.w   #$800,d3

loc_C78:
                move.w  d5,d1
                move.w  d6,d7
                sub.w   a5,d7
                bcc.s   loc_CA8
                move.w  d7,d6
                addi.w  #$10,d6
                neg.w   d7
                lsl.w   d7,d1
                move.b  (a0),d5
                rol.b   d7,d5
                add.w   d7,d7
                and.w   locret_C38(pc,d7.w),d5
                add.w   d5,d1

loc_C96:
                move.w  a5,d0
                add.w   d0,d0
                and.w   locret_C38(pc,d0.w),d1
                add.w   d3,d1
                move.b  (a0)+,d5
                lsl.w   #8,d5
                move.b  (a0)+,d5
                rts

loc_CA8:
                beq.s   loc_CBC
                lsr.w   d7,d1
                move.w  a5,d0
                add.w   d0,d0
                and.w   locret_C38(pc,d0.w),d1
                add.w   d3,d1
                move.w  a5,d0
                bra.w   Nem_PCD_InlineData

loc_CBC:
                moveq   #$10,d6
                bra.s   loc_C96

sub_CC0:
                movem.l d0-d6/a0/a4,-(sp)
                moveq   #0,d4
                lea     (VDP_DATA).l,a4
                bra.s   loc_CD4

sub_CCE:
                movem.l d0-d6/a0/a4,-(sp)
                moveq   #4,d4

loc_CD4:
                asl.w   #3,d1
                subq.w  #1,d1
                move.b  d0,d2
                move.b  d2,d3
                lsr.b   #4,d2
                andi.b  #$F,d3

loc_CE2:
                moveq   #7,d6
                move.b  (a0)+,d0

loc_CE6:
                lsl.l   #4,d5
                btst    d6,d0
                beq.s   loc_CF0
                or.b    d2,d5
                bra.s   loc_CF2

loc_CF0:
                or.b    d3,d5

loc_CF2:
                dbf     d6,loc_CE6
                move.l  d5,(a4)
                adda.l  d4,a4
                dbf     d1,loc_CE2
                movem.l (sp)+,d0-d6/a0/a4
                rts

sub_D04:
                movem.l d0-d7/a1-a5,-(sp)
                movea.w d0,a3
                move.b  (a0)+,d0
                ext.w   d0
                movea.w d0,a5
                move.b  (a0)+,d0
                ext.w   d0
                ext.l   d0
                ror.l   #1,d0
                ror.w   #1,d0
                move.l  d0,d4
                movea.w (a0)+,a2
                adda.w  a3,a2
                movea.w (a0)+,a4
                adda.w  a3,a4
                bsr.w   sub_C0C

loc_D28:
                moveq   #7,d0
                bsr.w   sub_C16
                move.w  d1,d2
                moveq   #7,d0
                cmpi.w  #$40,d1
                bcc.s   loc_D3C
                moveq   #6,d0
                lsr.w   #1,d2

loc_D3C:
                bsr.w   Nem_PCD_InlineData
                andi.w  #$F,d2
                lsr.w   #4,d1
                add.w   d1,d1
                jmp     loc_D98(pc,d1.w)

sub_D4C:
                move.w  a2,(a1)+
                addq.w  #1,a2
                dbf     d2,sub_D4C
                bra.s   loc_D28

sub_D56:
                move.w  a4,(a1)+
                dbf     d2,sub_D56
                bra.s   loc_D28

sub_D5E:
                bsr.w   sub_C5A

loc_D62:
                move.w  d1,(a1)+
                dbf     d2,loc_D62
                bra.s   loc_D28

sub_D6A:
                bsr.w   sub_C5A

loc_D6E:
                move.w  d1,(a1)+
                addq.w  #1,d1
                dbf     d2,loc_D6E
                bra.s   loc_D28

sub_D78:
                bsr.w   sub_C5A

loc_D7C:
                move.w  d1,(a1)+
                subq.w  #1,d1
                dbf     d2,loc_D7C
                bra.s   loc_D28

sub_D86:
                cmpi.w  #$F,d2
                beq.s   loc_DA8

loc_D8C:
                bsr.w   sub_C5A
                move.w  d1,(a1)+
                dbf     d2,loc_D8C
                bra.s   loc_D28

loc_D98:
                bra.s   sub_D4C
                bra.s   sub_D4C
                bra.s   sub_D56
                bra.s   sub_D56
                bra.s   sub_D5E
                bra.s   sub_D6A
                bra.s   sub_D78
                bra.s   sub_D86

loc_DA8:
                subq.w  #1,a0
                cmpi.w  #$10,d6
                bne.s   loc_DB2
                subq.w  #1,a0

loc_DB2:
                move.w  a0,d0
                lsr.w   #1,d0
                bcc.s   loc_DBA
                addq.w  #1,a0

loc_DBA:
                movem.l (sp)+,d0-d7/a1-a5
                rts

sub_DC0:
                bsr.w   InitJoypads
                lea     (unk_FFFF83).w,a0
                move.w  (word_FFFF8E).w,d0
                moveq   #$E,d1
                moveq   #6,d2

loc_DD0:
                btst    d1,d0
                sne     (a0)+
                subq.b  #1,d1
                dbf     d2,loc_DD0
                moveq   #6,d1
                moveq   #2,d2

loc_DDE:
                btst    d1,d0
                sne     (a0)+
                subq.b  #1,d1
                dbf     d2,loc_DDE
                andi.b  #$70,d0
                sne     (a0)+
                tst.b   (byte_FFFF87).w
                beq.s   locret_DF8
                clr.b   (byte_FFFF86).w

locret_DF8:
                rts

InitJoypads:
                bsr.w   RequestZ80Bus
                lea     (word_FFFF8E).w,a0
                lea     ((IO_CT1_DATA+1)).l,a1
                bsr.s   sub_E12
                addq.w  #2,a1
                bsr.s   sub_E12
                bra.w   sub_107E

sub_E12:
                move.b  #0,(a1)
                nop
                nop
                move.b  (a1),d0
                lsl.b   #2,d0
                andi.b  #$C0,d0
                move.b  #$40,(a1)
                nop
                nop
                move.b  (a1),d1
                andi.b  #$3F,d1
                or.b    d1,d0
                not.b   d0
                move.b  d0,d1
                move.b  (a0),d2
                eor.b   d2,d0
                move.b  d1,(a0)+
                and.b   d1,d0
                move.b  d0,(a0)+
                rts

sub_E42:
                lea     byte_E6E(pc),a1
                bra.s   loc_E4C

SetInitialVDPRegs:
                lea     initial_vdp_regs(pc),a1

loc_E4C:
                lea     (unk_FFFF70).w,a2
                moveq   #$12,d7

loc_E52:
                move.b  (a1)+,(a2)+
                dbf     d7,loc_E52
                rts

initial_vdp_regs:dc.b 4, $34, $30, $2C, 7, $5F, 0, 0, 0, 0
                dc.b $30, 2, 0, $2E, 0, 2, 0, 0, 0, 0
byte_E6E:       dc.b 4, $14, $30, $2C, 7, $54, 0, 0, 0, 0
                dc.b $30, 0, $81, $2B, 0, 2, 1, 0, 0, 0
sub_E82:
                lea     (unk_FFFF70).w,a1
                lea     (VDP_CTRL).l,a6
                move.w  #$8000,d7

loc_E90:
                move.w  d7,d0
                move.b  (a1)+,d0
                move.w  d0,(a6)
                addi.w  #$100,d7
                cmpi.w  #$9300,d7
                bcs.s   loc_E90
                rts

sub_EA2:
                move.w  #$B000,d2
                move.w  #$5000,d0
                bsr.w   sub_A74
                clr.l   (dword_FFFFA4).w
                clr.l   (dword_FFFFA8).w
                lea     (dword_FFF550).w,a6
                moveq   #0,d7
                move.w  #$7F,d6

loc_EC0:
                move.l  d7,(a6)+
                dbf     d6,loc_EC0
                rts

sub_EC8:
                lea     (VDP_CTRL).l,a2
                lea     (VDP_DATA).l,a3
                move.l  #$800000,d7

loc_EDA:
                move.l  d0,(a2)
                move.w  d1,d4

loc_EDE:
                move.w  (a1)+,(a3)
                dbf     d4,loc_EDE
                add.l   d7,d0
                dbf     d2,loc_EDA
                rts

sub_EEC:
                lea     (VDP_CTRL).l,a2
                lea     (VDP_DATA).l,a3
                move.l  #$800000,d5

loc_EFE:
                move.l  d0,(a2)
                move.w  d1,d3

loc_F02:
                move.w  d4,(a3)
                dbf     d3,loc_F02
                add.l   d5,d0
                dbf     d2,loc_EFE
                rts

sub_F10:
                asl.w   #5,d0

sub_F12:
                clr.l   d1
                move.w  d0,d1
                lsl.l   #2,d1
                move.w  d0,d1
                andi.w  #$3FFF,d1
                ori.w   #$4000,d1
                swap    d1
                move.l  d1,(a6)
                rts

sub_F28:
                asl.w   #5,d0

loc_F2A:
                clr.l   d1
                move.w  d0,d1
                lsl.l   #2,d1
                move.w  d0,d1
                andi.w  #$3FFF,d1
                swap    d1
                move.l  d1,(a6)
                rts

sub_F3C:
                move.w  (word_FFFF98).w,(word_FFFF96).w

loc_F42:
                tst.w   (word_FFFF96).w
                bne.s   loc_F42
                rts

RandomNumber:
                move.l  (dword_FFFFCA).w,d1
                bne.s   loc_F56
                move.l  #'*m6Z',d1

loc_F56:
                move.l  d1,d0
                asl.l   #2,d1
                add.l   d0,d1
                asl.l   #3,d1
                add.l   d0,d1
                move.w  d1,d0
                swap    d1
                add.w   d1,d0
                move.w  d0,d1
                swap    d1
                move.l  d1,(dword_FFFFCA).w
                rts

sub_F70:
                movem.l d2-d5,-(sp)
                moveq   #$40,d0
                cmp.w   d0,d2
                bcs.s   loc_F92
                tst.w   d3
                beq.s   loc_F82
                cmp.w   d2,d3
                bcs.s   loc_F86

loc_F82:
                move.w  d0,d2
                bra.s   loc_F92

loc_F86:
                sub.w   d3,d2
                neg.w   d2
                add.w   d0,d2
                cmp.w   d2,d0
                bcc.s   loc_F92
                moveq   #0,d2

loc_F92:
                lea     (word_FFF7E0).w,a0
                lea     (unk_FFF860).w,a1
                cmpi.w  #$40,d2
                bne.s   loc_FAA
                moveq   #$1F,d4

loc_FA2:
                move.l  (a1)+,(a0)+
                dbf     d4,loc_FA2
                bra.s   loc_FCE

loc_FAA:
                moveq   #$3F,d4

loc_FAC:
                move.w  (a1)+,d0
                rol.w   #4,d0
                moveq   #0,d3
                moveq   #2,d5

loc_FB4:
                lsl.w   #4,d3
                rol.w   #4,d0
                move.w  d0,d1
                andi.w  #$F,d1
                mulu.w  d2,d1
                lsr.w   #6,d1
                or.w    d1,d3
                dbf     d5,loc_FB4
                move.w  d3,(a0)+
                dbf     d4,loc_FAC

loc_FCE:
                move.w  d2,d0
                movem.l (sp)+,d2-d5
                rts

sub_FD6:
                cmpi.w  #$40,d0
                beq.s   locret_FFE
                lea     (unk_FFF860).w,a0
                lea     (word_FFF7E0).w,a1
                movem.l (dword_FFFFB8).w,d0-d1
                moveq   #$3F,d2

loc_FEC:
                roxl.l  #1,d1
                roxl.l  #1,d0
                bcc.s   loc_FF6
                move.w  (a0)+,(a1)+
                bra.s   loc_FFA

loc_FF6:
                addq.w  #2,a0
                addq.w  #2,a1

loc_FFA:
                dbf     d2,loc_FEC

locret_FFE:
                rts

sub_1000:
                lea     (word_FFF7E0).w,a0
                lea     (unk_FFF860).w,a1
                moveq   #$1F,d0

loc_100A:
                move.l  (a0),(a1)+
                clr.l   (a0)+
                dbf     d0,loc_100A
                rts

LoadZ80Driver:
                bsr.w   sub_105E
                bsr.w   sub_108E
                bsr.w   sub_115E
                move.w  #$FE5,d0
                moveq   #0,d1
                moveq   #2,d2
                lea     z80_part1(pc),a0
                bsr.w   sub_10A6
                moveq   #8,d0
                move.w  #$1C00,d1
                moveq   #1,d2
                lea     byte_1046(pc),a0
                bsr.w   sub_10A6
                clr.w   (word_FFFFA2).w
                rts

byte_1046:      dc.b 0, $80, 0, $80, 0, 0, 0, 0, $20, 0
RequestZ80Bus:
                btst    #0,(IO_Z80BUS).l
                sne     (byte_FFFFC8).w
                beq.s   locret_107C

sub_105E:
                movem.w d0,-(sp)
                move.w  #$100,(IO_Z80BUS).l
                moveq   #$F,d0

loc_106C:
                btst    #0,(IO_Z80BUS).l
                dbeq    d0,loc_106C
                movem.w (sp)+,d0

locret_107C:
                rts

sub_107E:
                tst.b   (byte_FFFFC8).w
                beq.s   locret_108C

ReleaseZ80Bus:
                move.w  #0,(IO_Z80BUS).l

locret_108C:
                rts

sub_108E:
                move.w  #0,(IO_Z80RES).l
                bsr.s   nullsub_2
                bsr.s   nullsub_2
                bsr.s   nullsub_2
                move.w  #$100,(IO_Z80RES).l

nullsub_2:
                rts

sub_10A6:
                movem.l d0-d3/a0-a1,-(sp)
                bsr.s   sub_105E
                lea     (Z80_RAM).l,a1
                adda.w  d1,a1

loc_10B4:
                move.b  (a0)+,d1
                moveq   #$F,d3

loc_10B8:
                move.b  d1,(a1)
                cmp.b   (a1),d1
                beq.s   loc_10C4
                dbf     d3,loc_10B8
                bra.s   loc_10D4

loc_10C4:
                addq.w  #1,a1
                dbf     d0,loc_10B4
                lsr.w   #1,d2
                bcc.s   loc_10D0
                bsr.s   sub_108E

loc_10D0:
                lsr.w   #1,d2
                bcs.s   loc_10D6

loc_10D4:
                bsr.s   ReleaseZ80Bus

loc_10D6:
                movem.l (sp)+,d0-d3/a0-a1
                rts

sub_10DC:
                movem.l d1/a0,-(sp)
                bsr.w   sub_105E
                lea     (unk_A01C04).l,a0
                moveq   #0,d1
                move.b  d1,(a0)+
                move.b  d1,(a0)+
                move.b  d1,(a0)+
                move.b  d1,(a0)
                addq.w  #2,a0
                move.b  d0,(a0)
                bsr.s   ReleaseZ80Bus
                movem.l (sp)+,d1/a0
                rts

sub_1100:
                movea.w (word_FFFFA2).w,a0
                cmpa.w  #8,a0
                bcc.s   locret_1112
                move.b  d0,-$66(a0)
                addq.w  #1,(word_FFFFA2).w

locret_1112:
                rts

sub_1114:
                movea.w (word_FFFFA2).w,a0
                move.w  a0,d0
                beq.s   loc_115A
                move.b  -$67(a0),d0
                subq.w  #1,(word_FFFFA2).w
                bsr.w   sub_105E
                tst.b   (byte_A01C0A).l
                bne.s   loc_1138
                move.b  d0,(byte_A01C0A).l
                bra.s   loc_1156

loc_1138:
                tst.b   (byte_A01C0B).l
                bne.s   loc_1148
                move.b  d0,(byte_A01C0B).l
                bra.s   loc_1156

loc_1148:
                tst.b   (byte_A01C0C).l
                bne.s   loc_1156
                move.b  d0,(byte_A01C0C).l

loc_1156:
                bsr.w   ReleaseZ80Bus

loc_115A:
                bra.w   sub_F3C

sub_115E:
                move.w  #$1FFF,d0
                lea     (Z80_RAM).l,a0

loc_1168:
                moveq   #$F,d1

loc_116A:
                move.b  #0,(a0)
                tst.b   (a0)
                dbeq    d1,loc_116A
                addq.l  #1,a0
                dbf     d0,loc_1168
                rts

sub_117C:
                movem.w d1,-(sp)
                bsr.w   sub_105E
                move.b  (byte_A01C0A).l,d1
                bsr.w   ReleaseZ80Bus
                cmp.b   d0,d1
                movem.w (sp)+,d1
                rts

sub_1196:
                movem.l d0-d2/a0,-(sp)
                lea     (word_FFF7E0).w,a0

loc_119E:
                move.w  (a5),d0
                andi.w  #$10,d0
                move.w  (a5),d1
                rol.w   #4,d1
                andi.w  #$F,d1
                or.w    d1,d0
                move.w  (a5),d1
                andi.w  #$100,d1
                lsr.w   #3,d1
                or.w    d1,d0
                add.w   d0,d0
                move.w  (a5)+,d2
                move.w  d2,d1
                andi.w  #$EEE,d1
                move.w  d1,(a0,d0.w)
                lsr.w   #1,d2
                bcc.s   loc_119E
                movem.l (sp)+,d0-d2/a0
                rts

sub_11D0:
                move.w  #$8100,d0
                move.b  (byte_FFFF71).w,d0
                ori.b   #$40,d0
                move.w  d0,(a6)
                move.l  #$40000010,(VDP_CTRL).l
                move.l  (dword_FFFFA4).w,-4(a6)
                move.w  (word_FFFFDA).w,d0
                bsr.w   sub_F12
                move.l  (dword_FFFFA8).w,d0
                neg.w   d0
                swap    d0
                neg.w   d0
                swap    d0
                move.l  d0,-4(a6)
                rts

sub_1208:
                lea     (VDP_CTRL).l,a6
                move.w  d0,d3
                move.w  d0,(word_FFFFE4).w
                lsl.w   #5,d3
                clr.b   d4

loc_1218:
                move.w  d3,d2
                move.w  d4,d1
                moveq   #$20,d0
                add.w   d0,d3
                bsr.w   loc_A76
                addi.b  #$11,d4
                bcc.s   loc_1218
                rts

sub_122C:
                movem.l d1-d5/a0,-(sp)
                movea.l a5,a0
                bsr.s   sub_124A
                clr.w   d0
                lea     (unk_FFC3E0).w,a1
                bsr.w   sub_D04
                movea.l a0,a5
                movea.l a1,a0
                bsr.s   sub_1260
                movem.l (sp)+,d1-d5/a0
                rts

sub_124A:
                lea     (VDP_CTRL).l,a6
                move.w  (a0)+,d2
                move.w  (a0)+,d3
                move.w  #$FF,d4
                move.w  d4,d5
                add.b   (a0)+,d4
                add.b   (a0)+,d5
                rts

sub_1260:
                move.w  d2,d0
                bsr.w   sub_F12
                move.w  d4,d0

loc_1268:
                move.w  (a0)+,d1
                add.w   d3,d1
                move.w  d1,-4(a6)
                dbf     d0,loc_1268
                add.w   (word_FFFFE2).w,d2
                dbf     d5,sub_1260
                move.w  d3,d0
                rts

sub_1280:
                bsr.w   sub_1196
                bsr.s   sub_122C
                bsr.w   sub_F10
                movea.l a5,a0
                bra.w   Nem_Decomp

sub_1290:
                movem.l a0/a5,-(sp)
                lea     (VDP_CTRL).l,a6
                lea     VDP_DATA-VDP_CTRL(a6),a5
                ori.l   #$FFFF0000,d1
                movea.l d1,a0
                clr.l   d1
                move.w  d2,d1
                lsl.l   #2,d1
                move.w  d2,d1
                andi.w  #$3FFF,d1
                ori.w   #$C000,d1
                swap    d1
                move.l  d1,(a6)
                bra.s   loc_12E6

sub_12BC:
                movem.l a0/a5,-(sp)
                lea     (VDP_CTRL).l,a6
                lea     VDP_DATA-VDP_CTRL(a6),a5
                ori.l   #$FFFF0000,d1
                movea.l d1,a0
                clr.l   d1
                move.w  d2,d1
                lsl.l   #2,d1
                move.w  d2,d1
                andi.w  #$3FFF,d1
                ori.w   #$4000,d1
                swap    d1
                move.l  d1,(a6)

loc_12E6:
                addq.w  #3,d0
                lsr.w   #2,d0
                move.w  d0,d1
                lsr.w   #3,d1
                bra.s   loc_1300

loc_12F0:
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)
                move.l  (a0)+,(a5)

loc_1300:
                dbf     d1,loc_12F0
                andi.w  #7,d0
                bra.s   loc_130C

loc_130A:
                move.l  (a0)+,(a5)

loc_130C:
                dbf     d0,loc_130A
                movem.l (sp)+,a0/a5
                rts

z80_part1:      dc.b $F3, $F3, $ED, $56, $18, $4D, 0, 0, $3A, 0, $40, $CB, $7F, $20, $F9, $C9
                dc.b $DD, $CB, 1, $7E, $C0, $C3, $A2, 4, $32, 0, $40, $CF, $79, $C3, $B2, 4
                dc.b $2A, 2, $1C, $C3, $7A, 4, 0, 0, $4F, 6, 0, 9, 9, 0, 0, 0
                dc.b $7E, $23, $66, $6F, $C9, 0, 0, 0, $F5, $C5, $D5, $E5, $21, $FF, $1F, $7E
                dc.b $B7, $28, 3, $35, $18, 7, $3A, 7, $1C, $B7, $CC, $E5, 0, $E1, $D1, $C1
                dc.b $F1, $FB, $C9, $31, $FD, $1F, $3E, 3, $32, $FF, $1F, $FB, $3A, $FF, $1F, $B7
                dc.b $C2, $5B, 0, $CD, 1, 8, $CD, $26, 7, $CD, $B9, 0, $CD, $D3, 0, $FB
                dc.b $CD, $99, 8, $3A, 7, $1C, $B7, $28, $F6, $F3, $F2, $AA, 0, $CD, $99, 8
                dc.b $3A, 0, $40, $E6, 3, $28, $E8, $CB, $4F, $28, $10, $CD, $D3, 0, $21, $9B
                dc.b 0, $E5, $CD, $39, 7, $CD, $B, 5, $C3, $F, 1, $3A, 0, $40, $CB, $47
                dc.b $28, $CD, $CD, $B9, 0, $CD, $E5, 0, $18, $C5, $3A, 0, $40, $CB, $4F, $28
                dc.b $BE, $CD, $D3, 0, $CD, $E5, 0, $18, $B6, $2A, 4, $1C, $7D, $E6, 3, $4F
                dc.b $3E, $25, $DF, $CB, $3C, $CB, $1D, $CB, $3C, $CB, $1D, $4D, $3E, $24, $DF, $3E
                dc.b $1F, $18, 9, $3A, 6, $1C, $4F, $3E, $26, $DF, $3E, $2F, $21, $12, $1C, $B6
                dc.b $4F, $3E, $27, $DF, $C9, $CD, $39, 7, $CD, $80, 8, $CD, $B5, 7, $CD, $B
                dc.b 5, $3A, 7, $1C, $B7, $F4, $F, 1, $AF, $32, $19, $1C, $DD, $21, $40, $1C
                dc.b $DD, $CB, 0, $7E, $C4, $A2, 9, 6, 9, $DD, $21, $70, $1C, $18, $19, $3E
                dc.b 1, $32, $19, $1C, $DD, $21, $80, $1E, 6, 6, $CD, $28, 1, $3E, $80, $32
                dc.b $19, $1C, 6, 2, $DD, $21, $20, $1E, $C5, $DD, $CB, 0, $7E, $C4, $39, 1
                dc.b $11, $30, 0, $DD, $19, $C1, $10, $F0, $C9, $DD, $CB, 1, $7E, $C2, $1E, $F
                dc.b $CD, 4, 3, $20, $17, $CD, $D6, 1, $DD, $CB, 0, $66, $C0, $CD, $3A, 3
                dc.b $CD, $34, 4, $CD, $65, 3, $CD, $7E, 1, $C3, $D, 4, $CD, $EE, 2, $DD
                dc.b $CB, 0, $66, $C0, $CD, $C, 3, $DD, $7E, $1E, $B7, $28, 6, $DD, $35, $1E
                dc.b $CA, $2A, 4, $CD, $34, 4, $DD, $CB, 0, $76, $C0, $CD, $65, 3, $DD, $CB
                dc.b 0, $56, $C0, $DD, $CB, 0, $46, $C2, $93, 1, $3E, $A4, $4C, $D7, $3E, $A0
                dc.b $4D, $D7, $C9, $DD, $7E, 1, $FE, 2, $20, $F0, $CD, $C6, 1, $D9, $21, $C2
                dc.b 1, 6, 4, $7E, $F5, $23, $D9, $EB, $4E, $23, $46, $23, $EB, $DD, $6E, $D
                dc.b $DD, $66, $E, 9, $F1, $F5, $4C, $DF, $F1, $D6, 4, $4D, $DF, $D9, $10, $E3
                dc.b $D9, $C9, $AD, $AE, $AC, $A6, $11, $2A, $1C, $3A, $19, $1C, $B7, $C8, $11, $1A
                dc.b $1C, $F0, $11, $22, $1C, $C9, $DD, $5E, 3, $DD, $56, 4, $DD, $CB, 0, $8E
                dc.b $DD, $CB, 0, $A6, $1A, $13, $FE, $E0, $D2, $98, $B, 8, $CD, $24, 4, $CD
                dc.b $A8, 2, 8, $DD, $CB, 0, $5E, $C2, $50, 2, $B7, $F2, $76, 2, $D6, $81
                dc.b $F2, 8, 2, $CD, $C8, $F, $18, $2E, $DD, $86, 5, $21, 0, 9, $F5, $EF
                dc.b $F1, $DD, $CB, 1, $7E, $20, $19, $D5, $16, 8, $1E, $C, 8, $AF, 8, $93
                dc.b $38, 5, 8, $82, $18, $F8, 8, $83, $21, $8A, 9, $EF, 8, $B4, $67, $D1
                dc.b $DD, $75, $D, $DD, $74, $E, $DD, $CB, 0, $6E, $20, $D, $1A, $B7, $F2, $75
                dc.b 2, $DD, $7E, $C, $DD, $77, $B, $18, $33, $1A, $13, $DD, $77, $10, $18, $24
                dc.b $67, $1A, $13, $6F, $B4, $28, $C, $DD, $7E, 5, 6, 0, $B7, $F2, $61, 2
                dc.b 5, $4F, 9, $DD, $75, $D, $DD, $74, $E, $DD, $CB, 0, $6E, $28, 5, $1A
                dc.b $13, $DD, $77, $10, $1A, $13, $CD, $9E, 2, $DD, $77, $C, $DD, $73, 3, $DD
                dc.b $72, 4, $DD, $7E, $C, $DD, $77, $B, $DD, $CB, 0, $4E, $C0, $AF, $DD, $77
                dc.b $25, $DD, $77, $22, $DD, $7E, $1F, $DD, $77, $1E, $DD, $77, $17, $C9, $DD, $46
                dc.b 2, 5, $C8, $4F, $81, $10, $FD, $C9, $DD, $7E, $11, $3D, $F8, $20, $3B, $DD
                dc.b $CB, 0, $4E, $C0, $DD, $35, $16, $C0, $D9, $DD, $7E, $15, $DD, $77, $16, $DD
                dc.b $7E, $12, $21, $F6, 2, $EF, $DD, $5E, $13, $DD, $34, $13, $DD, $7E, $14, $3D
                dc.b $BB, $20, $E, $DD, $35, $13, $DD, $7E, $11, $FE, 2, $28, 4, $DD, $36, $13
                dc.b 0, $16, 0, $19, $EB, $CD, $89, $D, $D9, $C9, $AF, $DD, $77, $13, $DD, $7E
                dc.b $11, $D6, 2, $F8, $18, $BE, $FE, 2, $FF, 2, 0, 3, 1, 3, $C0, $80
                dc.b $C0, $40, $80, $C0, $DD, $7E, $B, $3D, $DD, $77, $B, $C9, $DD, $7E, $18, $B7
                dc.b $C8, $3D, $E, $A, $E7, $EF, $CD, $97, $F, $DD, $66, $1D, $DD, $6E, $1C, $11
                dc.b $DE, 4, 6, 4, $DD, $4E, $19, $F5, $CB, $29, $C5, $30, 6, $86, $E6, $7F
                dc.b $4F, $1A, $D7, $C1, $13, $23, $F1, $10, $EE, $C9, $DD, $CB, 7, $7E, $C8, $DD
                dc.b $CB, 0, $4E, $C0, $DD, $5E, $20, $DD, $56, $21, $DD, $E5, $E1, 6, 0, $E
                dc.b $24, 9, $EB, $ED, $A0, $ED, $A0, $ED, $A0, $7E, $CB, $3F, $12, $AF, $DD, $77
                dc.b $22, $DD, $77, $23, $C9, $DD, $7E, 7, $B7, $C8, $FE, $80, $20, $48, $DD, $35
                dc.b $24, $C0, $DD, $34, $24, $E5, $DD, $6E, $22, $DD, $66, $23, $DD, $35, $25, $20
                dc.b $20, $DD, $5E, $20, $DD, $56, $21, $D5, $FD, $E1, $FD, $7E, 1, $DD, $77, $25
                dc.b $DD, $7E, $26, $4F, $E6, $80, 7, $ED, $44, $47, 9, $DD, $75, $22, $DD, $74
                dc.b $23, $C1, 9, $DD, $35, $27, $C0, $FD, $7E, 3, $DD, $77, $27, $DD, $7E, $26
                dc.b $ED, $44, $DD, $77, $26, $C9, $3D, $EB, $E, 8, 6, $80, $CD, $E7, 5, $18
                dc.b 3, $DD, $77, $25, $E5, $DD, $4E, $25, $CD, $81, 4, $E1, $CB, $7F, $CA, $FE
                dc.b 3, $FE, $82, $28, $12, $FE, $80, $28, $12, $FE, $84, $28, $11, $26, $FF, $30
                dc.b $1F, $DD, $CB, 0, $F6, $E1, $C9, 3, $A, $18, $D6, $AF, $18, $D3, 3, $A
                dc.b $DD, $86, $22, $DD, $77, $22, $DD, $34, $25, $DD, $34, $25, $18, $C6, $26, 0
                dc.b $6F, $DD, $46, $22, 4, $EB, $19, $10, $FD, $DD, $34, $25, $C9, $DD, $7E, $D
                dc.b $DD, $B6, $E, $C8, $DD, $7E, 0, $E6, 6, $C0, $DD, $7E, 1, $F6, $F0, $4F
                dc.b $3E, $28, $DF, $C9, $DD, $7E, 0, $E6, 6, $C0, $DD, $4E, 1, $CB, $79, $C0
                dc.b $3E, $28, $DF, $C9, 6, 0, $DD, $7E, $10, $B7, $F2, $3E, 4, 5, $DD, $66
                dc.b $E, $DD, $6E, $D, $4F, 9, $DD, $CB, 1, $7E, $20, $22, $EB, $3E, 7, $A2
                dc.b $47, $4B, $B7, $21, $83, 2, $ED, $42, $38, 6, $21, $85, $FA, $19, $18, $E
                dc.b $B7, $21, 8, 5, $ED, $42, $30, 5, $21, $7C, 5, $19, $EB, $EB, $DD, $CB
                dc.b 0, $6E, $C8, $DD, $74, $E, $DD, $75, $D, $C9, 6, 0, 9, 8, $F7, 8
                dc.b $C9, 6, 0, 9, $4D, $44, $A, $C9, $2A, $37, $1C, $3A, $19, $1C, $B7, $28
                dc.b 6, $DD, $6E, $2A, $DD, $66, $2B, $AF, $B0, $28, 6, $11, $19, 0, $19, $10
                dc.b $FD, $C9, $DD, $CB, 1, $56, $20, $E, $DD, $CB, 0, $56, $C0, $DD, $86, 1
                dc.b $DF, $C9, $32, 1, $40, $C9, $DD, $CB, 0, $56, $C0, $DD, $86, 1, $D6, 4
                dc.b $32, 2, $40, $CF, $79, $32, 3, $40, $C9, $B0, $30, $38, $34, $3C, $50, $58
                dc.b $54, $5C, $60, $68, $64, $6C, $70, $78, $74, $7C, $80, $88, $84, $8C, $40, $48
                dc.b $44, $4C, $90, $98, $94, $9C, $11, $C9, 4, $DD, $4E, $A, $3E, $B4, $D7, $CD
                dc.b 5, 5, $DD, $77, $1B, 6, $14, $CD, 5, 5, $10, $FB, $DD, $75, $1C, $DD
                dc.b $74, $1D, $C3, $A3, $D, $1A, $13, $4E, $23, $D7, $C9, $3A, 9, $1C, $CB, $7F
                dc.b $CA, 1, 8, $FE, $90, $DA, $57, 5, $FE, $D0, $DA, $15, 6, $FE, $E0, $DA
                dc.b $A, 6, $FE, $F9, $D2, 1, 8, $D6, $E0, $21, $2E, 5, $EF, $E9, $92, 7
                dc.b 1, 8, $69, 8, $36, 5, $DD, $21, $20, $1E, 6, 2, $3E, $80, $32, $19
                dc.b $1C, $C5, $DD, $CB, 0, $7E, $C4, $52, 5, $11, $30, 0, $DD, $19, $C1, $10
                dc.b $F0, $C9, $E5, $E5, $C3, $40, $E, $D6, $81, $F8, $F5, $CD, 1, 8, $F1, $E
                dc.b 4, 6, 8, $CD, $E7, 5, $E5, $E5, $F7, $22, $37, $1C, $E1, $FD, $E1, $FD
                dc.b $7E, 5, $32, $13, $1C, $32, $14, $1C, $11, 6, 0, $19, $22, $33, $1C, $21
                dc.b $F6, 5, $22, $35, $1C, $11, $40, $1C, $FD, $46, 2, $FD, $7E, 4, $C5, $2A
                dc.b $35, $1C, $ED, $A0, $ED, $A0, $12, $13, $22, $35, $1C, $2A, $33, $1C, $ED, $A0
                dc.b $ED, $A0, $ED, $A0, $ED, $A0, $22, $33, $1C, $CD, $DC, 6, $C1, $10, $DF, $FD
                dc.b $7E, 3, $B7, $CA, $E1, 5, $47, $21, 4, 6, $22, $35, $1C, $11, $90, $1D
                dc.b $FD, $7E, 4, $C5, $2A, $35, $1C, $ED, $A0, $ED, $A0, $12, $13, $22, $35, $1C
                dc.b $2A, $33, $1C, 1, 6, 0, $ED, $B0, $22, $33, $1C, $CD, $E3, 6, $C1, $10
                dc.b $E2, $3E, $80, $32, 9, $1C, $C9, $B8, $38, 9, $90, $21, 0, $80, $CD, $7A
                dc.b 4, $18, 1, $E7, $EF, $C9, $80, 2, $80, 0, $80, 1, $80, 4, $80, 5
                dc.b $80, 6, $80, 2, $80, $80, $80, $A0, $80, $C0, $D6, $D0, $F5, $E, 2, $E7
                dc.b $EF, $3E, $80, $18, $D, $D6, $90, $F5, $E, 6, $21, 8, $1C, $46, $CD, $E7
                dc.b 5, $AF, $32, $19, $1C, $F1, $E5, $F7, $22, $39, $1C, $AF, $32, $15, $1C, $E1
                dc.b $E5, $FD, $E1, $FD, $7E, 2, $32, $3B, $1C, $11, 4, 0, $19, $FD, $46, 3
                dc.b $C5, $E5, $23, $4E, $CD, $A3, 6, $CB, $D6, $DD, $E5, $3A, $19, $1C, $B7, $28
                dc.b 3, $E1, $FD, $E5, $D1, $E1, $ED, $A0, $1A, $FE, 2, $CC, $2B, 8, $ED, $A0
                dc.b $3A, $3B, $1C, $12, $13, $ED, $A0, $ED, $A0, $ED, $A0, $ED, $A0, $CD, $DC, 6
                dc.b $DD, $CB, 0, $7E, $28, $C, $DD, $7E, 1, $FD, $BE, 1, $20, 4, $FD, $CB
                dc.b 0, $D6, $E5, $2A, $39, $1C, $3A, $19, $1C, $B7, $28, 4, $FD, $E5, $DD, $E1
                dc.b $DD, $75, $2A, $DD, $74, $2B, $CD, $24, 4, $CD, $37, 8, $E1, $C1, $10, $A0
                dc.b $C3, $E1, 5, $CB, $79, $20, 5, $79, $D6, 2, $18, $16, $3E, $1F, $CD, $D1
                dc.b $F, $3E, $FF, $32, $11, $7F, $79, $CB, $3F, $CB, $3F, $CB, $3F, $CB, $3F, $CB
                dc.b $3F, $3C, $32, $32, $1C, $F5, $21, 6, 7, $EF, $E5, $DD, $E1, $F1, $F5, $21
                dc.b $F6, 6, $EF, $E5, $FD, $E1, $F1, $21, $16, 7, $EF, $C9, 8, $AF, $12, $13
                dc.b $12, $13, 8, $EB, $36, $30, $23, $36, $C0, $23, $36, 1, 6, $24, $23, $36
                dc.b 0, $10, $FB, $23, $EB, $C9, $20, $1E, $20, $1E, $20, $1E, $20, $1E, $50, $1E
                dc.b $20, $1E, $20, $1E, $50, $1E, $80, $1E, $B0, $1E, $B0, $1E, $B0, $1E, $E0, $1E
                dc.b $10, $1F, $40, $1F, $70, $1F, $60, $1D, 0, $1D, 0, $1D, 0, $1D, $30, $1D
                dc.b $90, $1D, $C0, $1D, $F0, $1D, $3A, 1, $1C, 7, $32, 0, $60, 6, 8, $3A
                dc.b 0, $1C, $32, 0, $60, $F, $10, $FA, $C9, $21, $10, $1C, $7E, $B7, $C8, $FA
                dc.b $4A, 7, $D1, $3D, $C0, $36, 2, $C3, $3E, 8, $AF, $77, $3A, $D, $1C, $B7
                dc.b $C2, 1, 8, $DD, $21, $70, $1C, 6, 6, $3A, $11, $1C, $B7, $20, 6, $DD
                dc.b $CB, 0, $7E, $28, 6, $DD, $4E, $A, $3E, $B4, $D7, $11, $30, 0, $DD, $19
                dc.b $10, $E7, $DD, $21, $20, $1E, 6, 8, $DD, $CB, 0, $7E, $28, $C, $DD, $CB
                dc.b 1, $7E, $20, 6, $DD, $4E, $A, $3E, $B4, $D7, $11, $30, 0, $DD, $19, $10
                dc.b $E7, $C9, $3E, $28, $32, $D, $1C, $3E, 6, $32, $F, $1C, $32, $E, $1C, $AF
                dc.b $32, $40, $1C, $32, $60, $1D, $32, $F0, $1D, $32, $90, $1D, $32, $C0, $1D, $CD
                dc.b $69, 8, $C3, $E1, 5, $21, $D, $1C, $7E, $B7, $C8, $FC, $9F, 7, $CB, $BE
                dc.b $3A, $F, $1C, $3D, $28, 4, $32, $F, $1C, $C9, $3A, $E, $1C, $32, $F, $1C
                dc.b $3A, $D, $1C, $3D, $32, $D, $1C, $28, $28, $DD, $21, $40, $1C, 6, 6, $DD
                dc.b $34, 6, $F2, $EA, 7, $DD, $35, 6, $18, $F, $DD, $CB, 0, $7E, $28, 9
                dc.b $DD, $CB, 0, $56, $20, 3, $CD, $A3, $D, $11, $30, 0, $DD, $19, $10, $DF
                dc.b $C9, $21, 9, $1C, $11, $A, $1C, 1, $96, 3, $36, 0, $ED, $B0, $DD, $21
                dc.b $F6, 5, 6, 6, $C5, $CD, $E2, 8, $CD, $37, 8, $DD, $23, $DD, $23, $C1
                dc.b $10, $F2, 6, 7, $AF, $32, $D, $1C, $CD, $69, 8, $3E, $F, $32, $12, $1C
                dc.b $4F, $3E, $27, $DF, $C3, $E1, 5, $3E, $90, $E, 0, $C3, $F6, 8, $CD, $69
                dc.b 8, $C5, $F5, 6, 3, $3E, $B4, $E, 0, $F5, $DF, $F1, $3C, $10, $FA, 6
                dc.b 3, $3E, $B4, $F5, $CD, $C0, 4, $F1, $3C, $10, $F8, $E, 0, 6, 7, $3E
                dc.b $28, $F5, $DF, $C, $F1, $10, $FA, $F1, $C1, $E5, $C5, $21, $7C, 8, 6, 4
                dc.b $7E, $32, $11, $7F, $23, $10, $F9, $C1, $E1, $C3, $E1, 5, $9F, $BF, $DF, $FF
                dc.b $21, $13, $1C, $7E, $B7, $C8, $35, $C0, $3A, $14, $1C, $77, $21, $4B, $1C, $11
                dc.b $30, 0, 6, $A, $34, $19, $10, $FC, $C9, $ED, $5F, $32, $17, $1C, $11, $A
                dc.b $1C, $CD, $AD, 8, $11, $B, $1C, $CD, $AD, 8, $11, $C, $1C, $1A, $CB, $7F
                dc.b $C8, $D6, $81, $2A, 2, $1C, $E, 0, $E7, $4F, 6, 0, 9, $CB, $7E, $28
                dc.b $E, $1A, $32, 9, $1C, $AF, $21, $A, $1C, $77, $23, $77, $23, $77, $C9, $3A
                dc.b $18, $1C, $BE, $28, 2, $30, 8, $1A, $32, 9, $1C, $7E, $32, $18, $1C, $AF
                dc.b $12, $C9, $CD, $F2, 8, $3E, $40, $E, $7F, $CD, $F6, 8, $DD, $4E, 1, $C3
                dc.b $30, 4, $3E, $80, $E, $FF, 6, 4, $F5, $D7, $F1, $C6, 4, $10, $F9, $C9
                dc.b $56, 3, $26, 3, $F9, 2, $CE, 2, $A5, 2, $80, 2, $5C, 2, $3A, 2
                dc.b $1A, 2, $FB, 1, $DF, 1, $C4, 1, $AB, 1, $93, 1, $7D, 1, $67, 1
                dc.b $53, 1, $40, 1, $2E, 1, $1D, 1, $D, 1, $FE, 0, $EF, 0, $E2, 0
                dc.b $D6, 0, $C9, 0, $BE, 0, $B4, 0, $A9, 0, $A0, 0, $97, 0, $8F, 0
                dc.b $87, 0, $7F, 0, $78, 0, $71, 0, $6B, 0, $65, 0, $5F, 0, $5A, 0
                dc.b $55, 0, $50, 0, $4B, 0, $47, 0, $43, 0, $40, 0, $3C, 0, $39, 0
                dc.b $36, 0, $33, 0, $30, 0, $2D, 0, $2B, 0, $28, 0, $26, 0, $24, 0
                dc.b $22, 0, $20, 0, $1F, 0, $1D, 0, $1B, 0, $1A, 0, $18, 0, $17, 0
                dc.b $16, 0, $15, 0, $13, 0, $12, 0, $11, 0, $84, 2, $AB, 2, $D3, 2
                dc.b $FE, 2, $2D, 3, $5C, 3, $8F, 3, $C5, 3, $FF, 3, $3C, 4, $7C, 4
                dc.b $C0, 4, $CD, 4, 3, $CC, $A9, 9, $C9, $DD, $5E, 3, $DD, $56, 4, $1A
                dc.b $13, $FE, $E0, $D2, $56, $A, $B7, $FA, $BE, 9, $1B, $DD, $7E, $D, $DD, $77
                dc.b $D, $FE, $80, $CA, $40, $A, $D5, $21, $60, $1D, $CB, $56, $20, $44, $E6, $F
                dc.b $28, $40, 8, $CD, $24, 4, 8, $11, $50, $A, $EB, $ED, $A0, $ED, $A0, $ED
                dc.b $A0, $3D, $21, $7A, $A, $EF, 1, 6, 0, $ED, $B0, $CD, $E3, 6, $21, $65
                dc.b $1D, $DD, $7E, 5, $86, $77, $3A, $68, $1D, $21, $8E, $A, $EF, $3A, $66, $1D
                dc.b $DD, $5E, 6, $D5, $83, $DD, $77, 6, $CD, $E6, 4, $D1, $DD, $73, 6, $CD
                dc.b $2B, 8, $21, $F0, $1D, $CB, $56, $20, $26, $DD, $7E, $D, $E6, $70, $28, $1F
                dc.b $11, $53, $A, $EB, $ED, $A0, $ED, $A0, $ED, $A0, $CB, $3F, $CB, $3F, $CB, $3F
                dc.b $CB, $3F, $3D, $21, $60, $A, $EF, 1, 6, 0, $ED, $B0, $CD, $E3, 6, $D1
                dc.b $1A, $13, $B7, $F2, $76, 2, $1B, $DD, $7E, $C, $DD, $77, $B, $C3, $7C, 2
                dc.b $80, 2, 1, $80, $C0, 1, $21, $5C, $A, $C3, $9B, $B, $13, $C3, $AF, 9
                dc.b $64, $A, $6F, $A, $6A, $A, 0, 4, 0, 1, $F3, $E7, $C2, 8, $F2, $75
                dc.b $A, 0, 6, 0, 2, $F3, $E7, $C5, 8, $F2, $9A, $A, $BC, $A, $C7, $A
                dc.b $D0, $A, $E4, $A, 6, $B, $DB, $A, $28, $B, $4A, $B, $71, $B, $A3, $A
                dc.b $ED, $A, $F, $B, $31, $B, $58, $B, $7F, $B, $A0, $A, 0, $E, $81, 0
                dc.b $B9, $10, $F2, $3E, $60, $30, $30, $30, $19, $1F, $1F, $1F, $15, $11, $11, $C
                dc.b $10, $A, 6, 9, $4F, $5F, $AF, $8F, 0, $82, $83, $80, $C2, $A, 0, $C
                dc.b $81, 0, $E0, $80, $B6, $A, $F2, $CD, $A, 0, $C, $81, 0, $B3, $A, $F2
                dc.b $D6, $A, 0, $C, $81, 0, $E0, $40, $B0, $A, $F2, $E1, $A, 0, $C, $81
                dc.b 0, $B2, $A, $F2, $EA, $A, 0, 3, $81, 1, $89, 8, $F2, $72, $33, $30
                dc.b $32, $31, $1E, $1B, $1C, $15, $16, $12, $17, $10, $10, $18, $1E, $14, $4F, $5F
                dc.b $4F, $4F, 8, 0, $10, $80, $C, $B, 0, 6, $81, 2, $B0, $16, $F2, $72
                dc.b $9E, $5B, $42, $22, $96, $96, $9E, $96, $16, $18, $16, $18, $10, $17, $11, $18
                dc.b $4F, $5F, $4F, $4F, 0, 0, $10, $80, $2E, $B, 0, $E, 0, 3, $B4, $10
                dc.b $F2, $3C, $F, 0, 0, 0, $1F, $1A, $18, $1C, $17, $11, $1A, $E, 0, $F
                dc.b $14, $10, $1F, $EC, $FF, $FF, 7, $80, $16, $80, $50, $B, $F7, $A, 0, 4
                dc.b $FE, 3, 0, 0, 0, $95, $20, $F2, $3C, $A, $50, $70, 0, $1F, $17, $19
                dc.b $1D, $1D, $15, $1A, $17, 6, $18, 7, $19, $F, $5F, $6F, $1F, $C, $95, 0
                dc.b $8E, $77, $B, 0, 7, 0, 7, $FE, 0, 3, 0, 3, $D1, 8, $F2, $3D
                dc.b 0, $F, $F, $F, $1F, $9F, $9F, $9F, $1F, $1F, $1F, $1F, 0, $E, $10, $F
                dc.b $F, $4F, $4F, $4F, 0, $90, $90, $85, $21, $A4, $B, $E5, $D6, $E0, $21, $AF
                dc.b $B, $EF, $1A, $E9, $13, $C3, $E4, 1, $21, $EF, $B, $EF, $13, $1A, $E9, $89
                dc.b $D, $9D, $C, $B2, $C, $E7, $C, $F7, $C, $C2, $D, $CA, $D, $A, $D, $ED
                dc.b $C, $9A, $D, $2B, $C, $38, $C, $B6, $C, $C9, $C, $CE, $C, $4D, $D, $D9
                dc.b $C, $A, $E, $40, $E, $E2, $D, $12, $E, 1, $E, $16, $E, 7, $F, $DA
                dc.b $E, $F4, $E, $DE, $D, $D7, $D, $1C, $E, $32, $E, $10, $D, $A8, $B, $27
                dc.b $C, $AA, $C, $4C, $C, $54, $C, $8F, $C, $18, $C, $FF, $B, $A1, $C, $DD
                dc.b $36, $18, $80, $DD, $73, $19, $DD, $72, $1A, $21, $E2, 4, 6, 4, $1A, $13
                dc.b $4F, $7E, $23, $D7, $10, $F8, $1B, $C9, $D9, 6, $A, $11, $30, 0, $21, $42
                dc.b $1C, $77, $19, $10, $FC, $D9, $C9, $32, 7, $1C, $C9, $21, 4, $1C, $EB, $ED
                dc.b $A0, $ED, $A0, $ED, $A0, $EB, $1B, $C9, $EB, $4E, $23, $46, $23, $EB, $2A, 4
                dc.b $1C, 9, $22, 4, $1C, $1A, $21, 6, $1C, $86, $77, $C9, $DD, $E5, $CD, $E
                dc.b 5, $DD, $E1, $C9, $32, $11, $1C, $B7, $28, $1D, $DD, $E5, $D5, $DD, $21, $40
                dc.b $1C, 6, $A, $11, $30, 0, $DD, $CB, 0, $BE, $CD, $2A, 4, $DD, $19, $10
                dc.b $F5, $D1, $DD, $E1, $C3, $69, 8, $DD, $E5, $D5, $DD, $21, $40, $1C, 6, $A
                dc.b $11, $30, 0, $DD, $CB, 0, $FE, $DD, $19, $10, $F8, $D1, $DD, $E1, $C9, $EB
                dc.b $5E, $23, $56, $23, $4E, 6, 0, $23, $EB, $ED, $B0, $1B, $C9, $DD, $77, $10
                dc.b $C9, $DD, $77, $18, $13, $1A, $DD, $77, $19, $C9, $21, $14, $1C, $86, $77, $2B
                dc.b $77, $C9, $32, $16, $1C, $C9, $DD, $CB, 1, $7E, $C8, $DD, $CB, 0, $A6, $DD
                dc.b $35, $17, $DD, $86, 6, $DD, $77, 6, $C9, $CD, $D3, $C, $D7, $C9, $CD, $D3
                dc.b $C, $DF, $C9, $EB, $7E, $23, $4E, $EB, $C9, $DD, $73, $20, $DD, $72, $21, $DD
                dc.b $36, 7, $80, $13, $13, $13, $C9, $CD, $E2, 8, $C3, $40, $E, $CD, $9E, 2
                dc.b $DD, $77, $1E, $DD, $77, $1F, $C9, $DD, $E5, $E1, 1, $11, 0, 9, $EB, 1
                dc.b 5, 0, $ED, $B0, $3E, 1, $12, $EB, $1B, $C9, $DD, $CB, 0, $CE, $1B, $C9
                dc.b $DD, $7E, 1, $FE, 2, $20, $2A, $DD, $CB, 0, $C6, $D9, $CD, $C6, 1, 6
                dc.b 4, $C5, $D9, $1A, $13, $D9, $21, $45, $D, $87, $4F, 6, 0, 9, $ED, $A0
                dc.b $ED, $A0, $C1, $10, $EC, $D9, $1B, $3E, $4F, $32, $12, $1C, $4F, $3E, $27, $DF
                dc.b $C9, $13, $13, $13, $C9, 0, 0, $32, 1, $8A, 1, $E4, 1, $DD, $CB, 1
                dc.b $7E, $20, $31, $CD, $F2, 8, $1A, $DD, $77, 8, $B7, $F2, $7A, $D, $13, $1A
                dc.b $DD, $77, $F, $D5, $DD, $7E, $F, $D6, $81, $E, 4, $CD, $EB, 5, $F7, $DD
                dc.b $7E, 8, $E6, $7F, $47, $CD, $97, 4, $18, 5, $D5, $47, $CD, $88, 4, $CD
                dc.b $E6, 4, $D1, $C9, $1A, $B7, $F0, $13, $C9, $E, $3F, $DD, $7E, $A, $A1, $EB
                dc.b $B6, $DD, $77, $A, $4F, $3E, $B4, $D7, $EB, $C9, $4F, $3E, $22, $DF, $13, $E
                dc.b $C0, $18, $E8, $D9, $11, $DE, 4, $DD, $6E, $1C, $DD, $66, $1D, 6, 4, $7E
                dc.b $B7, $F2, $B7, $D, $DD, $86, 6, $E6, $7F, $4F, $1A, $D7, $13, $23, $10, $EF
                dc.b $D9, $C9, $13, $DD, $86, 6, $DD, $77, 6, $1A, $DD, $CB, 1, $7E, $C0, $DD
                dc.b $86, 6, $DD, $77, 6, $18, $CC, $DD, $86, 5, $DD, $77, 5, $C9, $DD, $77
                dc.b 2, $C9, $DD, $CB, 1, $56, $C0, $3E, $DF, $32, $11, $7F, $1A, $DD, $77, $1A
                dc.b $DD, $CB, 0, $C6, $B7, $20, 6, $DD, $CB, 0, $86, $3E, $FF, $32, $11, $7F
                dc.b $C9, $DD, $CB, 1, $7E, $C8, $DD, $77, 8, $C9, $13, $DD, $CB, 1, $7E, $20
                dc.b 1, $1A, $DD, $77, 7, $C9, $EB, $5E, $23, $56, $1B, $C9, $FE, 1, $20, 5
                dc.b $DD, $CB, 0, $EE, $C9, $DD, $CB, 0, $8E, $DD, $CB, 0, $AE, $AF, $DD, $77
                dc.b $10, $C9, $FE, 1, $20, 5, $DD, $CB, 0, $DE, $C9, $DD, $CB, 0, $9E, $C9
                dc.b $DD, $CB, 0, $BE, $3E, $1F, $32, $15, $1C, $CD, $24, 4, $DD, $4E, 1, $DD
                dc.b $E5, $CD, $A3, 6, $3A, $19, $1C, $B7, $28, $69, $AF, $32, $18, $1C, $FD, $CB
                dc.b 0, $7E, $28, $12, $DD, $7E, 1, $FD, $BE, 1, $20, $A, $FD, $E5, $FD, $6E
                dc.b $2A, $FD, $66, $2B, $18, 4, $E5, $2A, $37, $1C, $DD, $E1, $DD, $CB, 0, $96
                dc.b $DD, $CB, 1, $7E, $20, $42, $DD, $CB, 0, $7E, $28, $37, $3E, 2, $DD, $BE
                dc.b 1, $20, $D, $3E, $4F, $DD, $CB, 0, $46, $20, 2, $E6, $F, $CD, $39, $D
                dc.b $DD, $7E, 8, $B7, $F2, $AC, $E, $CD, $63, $D, $18, $14, $47, $CD, $97, 4
                dc.b $CD, $E6, 4, $DD, $7E, $18, $B7, $F2, $C3, $E, $DD, $5E, $19, $DD, $56, $1A
                dc.b $CD, 9, $C, $DD, $E1, $E1, $E1, $C9, $DD, $CB, 0, $46, $28, $F5, $DD, $7E
                dc.b $1A, $B7, $F2, $D8, $E, $32, $11, $7F, $18, $E9, $4F, $13, $1A, $47, $C5, $DD
                dc.b $E5, $E1, $DD, $35, 9, $DD, $4E, 9, $DD, $35, 9, 6, 0, 9, $72, $2B
                dc.b $73, $D1, $1B, $C9, $DD, $E5, $E1, $DD, $4E, 9, 6, 0, 9, $5E, $23, $56
                dc.b $DD, $34, 9, $DD, $34, 9, $C9, $13, $C6, $28, $4F, 6, 0, $DD, $E5, $E1
                dc.b 9, $7E, $B7, $20, 2, $1A, $77, $13, $35, $C2, $16, $E, $13, $C9, $CD, 4
                dc.b 3, $20, $D, $CD, $D6, 1, $DD, $CB, 0, $66, $C0, $CD, $3A, 3, $18, $C
                dc.b $DD, $7E, $1E, $B7, $28, 6, $DD, $35, $1E, $CA, $C8, $F, $CD, $34, 4, $CD
                dc.b $65, 3, $DD, $CB, 0, $56, $C0, $DD, $4E, 1, $7D, $E6, $F, $B1, $32, $11
                dc.b $7F, $7D, $E6, $F0, $B4, $F, $F, $F, $F, $32, $11, $7F, $DD, $7E, 8, $B7
                dc.b $E, 0, $28, $C, $3D, $E, $A, 6, $80, $CD, $E7, 5, $CD, $97, $F, $4F
                dc.b $DD, $CB, 0, $66, $C0, $DD, $7E, 6, $81, $CB, $67, $28, 2, $3E, $F, $DD
                dc.b $B6, 1, $C6, $10, $DD, $CB, 0, $46, $20, 4, $32, $11, $7F, $C9, $C6, $20
                dc.b $32, $11, $7F, $C9, $DD, $77, $17, $E5, $DD, $4E, $17, $CD, $81, 4, $E1, $CB
                dc.b $7F, $28, $21, $FE, $83, $28, $C, $FE, $81, $28, $13, $FE, $80, $28, $C, 3
                dc.b $A, $18, $E1, $DD, $CB, 0, $E6, $E1, $C3, $C8, $F, $AF, $18, $D6, $E1, $DD
                dc.b $CB, 0, $E6, $C9, $DD, $34, $17, $C9, $DD, $CB, 0, $E6, $DD, $CB, 0, $56
                dc.b $C0, $3E, $1F, $DD, $86, 1, $B7, $F0, $32, $11, $7F, $DD, $CB, 0, $46, $C8
                dc.b $3E, $FF, $32, $11, $7F, $C9
func_table:     dc.w $39
                dc.w nullsub_1
                dc.w nullsub_1
                dc.w nullsub_1
                dc.w Nem_Decomp
                dc.w Nem_Decomp_To_RAM
                dc.w sub_CC0
                dc.w sub_CCE
                dc.w sub_C0C
                dc.w sub_C16
                dc.w sub_C26
                dc.w Nem_PCD_InlineData
                dc.w sub_BDC
                dc.w sub_C00
                dc.w sub_D04
                dc.w sub_1290
                dc.w sub_12BC
                dc.w sub_1208
                dc.w sub_A74
                dc.w loc_A76
                dc.w sub_9D8
                dc.w sub_8FE
                dc.w loc_900
                dc.w sub_976
                dc.w sub_A04
                dc.w sub_A0C
                dc.w sub_11D0
                dc.w sub_FD6
                dc.w sub_DC0
                dc.w InitJoypads
                dc.w SetInitialVDPRegs
                dc.w sub_E82
                dc.w sub_EA2
                dc.w LoadZ80Driver
                dc.w sub_105E
                dc.w ReleaseZ80Bus
                dc.w RequestZ80Bus
                dc.w sub_107E
                dc.w sub_108E
                dc.w sub_10A6
                dc.w sub_115E
                dc.w sub_10DC
                dc.w sub_1100
                dc.w sub_1114
                dc.w sub_F3C
                dc.w RandomNumber
                dc.w sub_EC8
                dc.w sub_EEC
                dc.w sub_F10
                dc.w sub_F12
                dc.w sub_F28
                dc.w loc_F2A
                dc.w sub_117C
                dc.w sub_F70
                dc.w sub_1000
                dc.w sub_872
                dc.w sub_1196
                dc.w sub_122C
                dc.w sub_1280
Jap1BPPTiles:   dc.b 0, 0, 0, 0, 0, 0, 0, 0, $10, $10, $10, $10, $10, 0, 0, $10
                dc.b $12, $12, $24, 0, 0, 0, 0, 0, 0, $48, $FC, $48, $48, $FC, $48, $48
                dc.b 0, $10, $7E, $90, $7C, $12, $FC, $10, 0, $E2, $A4, $E8, $10, $2E, $4A, $8E
                dc.b 0, $30, $48, $30, $62, $94, $88, $76, $3C, $42, $99, $A1, $A1, $99, $42, $3C
                dc.b 0, 4, 8, $10, $10, $10, 8, 4, 0, $20, $10, 8, 8, 8, $10, $20
                dc.b 0, $10, $54, $38, $38, $54, $10, 0, 0, $10, $10, $10, $FE, $10, $10, $10
                dc.b 0, 0, 0, 0, 0, $40, $40, $80, 0, 0, 0, 0, $F8, 0, 0, 0
                dc.b 0, 0, 0, 0, 0, 0, $C0, $C0, 0, 2, 4, 8, $10, $20, $40, $80
                dc.b 0, $78, $84, $84, $84, $84, $84, $78, 0, $10, $30, $10, $10, $10, $10, $38
                dc.b 0, $78, $84, 4, $18, $60, $80, $FC, 0, $FC, 4, 8, $18, 4, $84, $78
                dc.b 0, $18, $28, $48, $88, $FC, 8, 8, 0, $FC, $80, $80, $F8, 4, $84, $78
                dc.b 0, $78, $84, $80, $F8, $84, $84, $78, 0, $FC, $84, $88, $10, $20, $20, $20
                dc.b 0, $78, $84, $84, $78, $84, $84, $78, 0, $78, $84, $84, $7C, 4, 8, $30
                dc.b 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, 0, 0, 0, $10, $20
                dc.b 0, 4, 8, $10, $20, $10, 8, 4, 0, 0, 0, $7C, 0, $7C, 0, 0
                dc.b 0, $20, $10, 8, 4, 8, $10, $20, $38, $44, $44, 8, $10, $10, 0, $10
                dc.b 0, 8, $10, 0, 0, 0, 0, 0, 0, $30, $48, $84, $84, $FC, $84, $84
                dc.b 0, $F8, $84, $84, $F8, $84, $84, $F8, 0, $78, $84, $80, $80, $80, $84, $78
                dc.b 0, $F0, $88, $84, $84, $84, $88, $F0, 0, $FC, $80, $80, $F8, $80, $80, $FC
                dc.b 0, $FC, $80, $80, $F8, $80, $80, $80, 0, $78, $84, $80, $9C, $84, $84, $78
                dc.b 0, $84, $84, $84, $FC, $84, $84, $84, 0, $38, $10, $10, $10, $10, $10, $38
                dc.b 0, $3C, 8, 8, 8, $88, $88, $70, 0, $84, $88, $90, $A0, $D0, $88, $84
                dc.b 0, $80, $80, $80, $80, $80, $80, $FC, 0, $84, $CC, $B4, $84, $84, $84, $84
                dc.b 0, $84, $C4, $A4, $94, $8C, $84, $84, 0, $78, $84, $84, $84, $84, $84, $78
                dc.b 0, $F8, $84, $84, $F8, $80, $80, $80, 0, $78, $84, $84, $84, $94, $88, $74
                dc.b 0, $F8, $84, $84, $F8, $90, $88, $84, 0, $78, $84, $80, $78, 4, $84, $78
                dc.b 0, $7C, $10, $10, $10, $10, $10, $10, 0, $84, $84, $84, $84, $84, $84, $78
                dc.b 0, $84, $84, $84, $48, $48, $30, $30, 0, $84, $84, $84, $84, $B4, $CC, $84
                dc.b 0, $82, $44, $28, $10, $28, $44, $82, 0, $82, $44, $28, $10, $10, $10, $10
                dc.b 0, $FC, 8, $10, $20, $40, $80, $FC, 0, $1C, $10, $10, $10, $10, $10, $1C
                dc.b 0, $44, $28, $7C, $10, $7C, $10, $10, 0, $38, 8, 8, 8, 8, 8, $38
                dc.b 0, 0, 0, $60, $92, $C, 0, 0, 0, 0, 0, 0, 0, 0, 0, $FC
                dc.b $20, $FC, $20, $3C, $66, $AA, $92, $64, 0, $84, $82, $82, $82, $82, $90, $60
                dc.b $70, 0, $78, $84, 4, 4, 8, $30, $30, 0, $7E, 4, 8, $18, $28, $4E
                dc.b $22, $FA, $20, $3C, $62, $A2, $A2, $64, $20, $24, $F2, $2A, $48, $48, $A8, $90
                dc.b $20, $FC, $10, $FC, 8, $18, $80, $78, 8, $10, $20, $40, $40, $20, $10, 8
                dc.b 4, $84, $9E, $84, $84, $84, $84, 8, 0, $78, 4, 0, 0, $40, $80, $7C
                dc.b $20, $10, $FE, 8, $C, $80, $40, $3C, $40, $40, $40, $40, $40, $44, $44, $38
                dc.b 8, $FE, 8, $78, $48, $38, 8, $10, $44, $44, $FE, $44, $48, $40, $40, $3C
                dc.b $78, $10, $20, $FE, $10, $20, $20, $1C, $20, $20, $F8, $20, $4E, $40, $90, $8E
                dc.b $20, $20, $FC, $20, $3C, $42, 2, $3C, 0, 0, $FC, 2, 2, 2, $C, $30
                dc.b 0, $FE, $C, $10, $20, $20, $10, $C, $20, $20, $2C, $30, $40, $80, $80, $7E
                dc.b $20, $24, $F2, $40, $88, $38, $4C, $30, 0, $9E, $80, $80, $80, $80, $A0, $9E
                dc.b 8, $48, $7C, $52, $B2, $A6, $AA, $4C, $20, $20, $EC, $32, $22, $66, $AA, $2E
                dc.b 0, $38, $54, $92, $92, $92, $92, $64, 4, $84, $9E, $84, $84, $9E, $A4, $9C
                dc.b $F0, $24, $46, $84, $84, $88, $88, $70, $30, 8, 0, $10, $48, $8A, $8A, $30
                dc.b 0, $20, $50, $88, 4, 2, 0, 0, $9E, $84, $9E, $84, $9C, $A6, $A4, $9C
                dc.b $10, $7C, $10, $7C, $10, $78, $94, $70, $78, $10, $12, $12, $7E, $A2, $A4, $48
                dc.b $20, $F2, $22, $20, $60, $A0, $E2, $3C, 8, $48, $78, $4C, $D2, $B2, $A2, $44
                dc.b $20, $20, $F8, $20, $FC, $20, $22, $1C, $48, $48, $FC, $42, $52, $4C, $40, $20
                dc.b 8, $BC, $CA, $8A, $8A, $AA, $1C, $30, $10, $1C, $10, $10, $10, $70, $98, $64
                dc.b $30, 8, $40, $5C, $62, 2, 4, $18, $44, $44, $44, $44, $24, 4, 8, $10
                dc.b $7C, 8, $30, $7C, $82, $32, $52, $3C, $20, $20, $EC, $32, $22, $64, $A4, $22
                dc.b $F8, $10, $20, $78, $84, 4, 4, $78, $20, $20, $EC, $32, $22, $62, $A2, $24
                dc.b $10, $78, $20, $34, $58, $28, $20, $1C, $10, $10, $20, $20, $70, $50, $90, $8C
                dc.b 0, 0, $20, $78, $28, $74, $A4, $48, 0, 0, 0, $88, $84, $84, $80, $40
                dc.b 0, 0, $60, 0, $F0, 8, $10, $60, 0, 0, $60, 0, $F0, $10, $60, $98
                dc.b 0, 0, $20, $7A, $22, $78, $A4, $68, 0, 0, 0, $F0, 8, 8, $10, $60
                dc.b 0, 0, $50, $78, $D4, $44, $28, $20, 0, 0, $10, $B8, $D4, $D4, $98, $10
                dc.b 0, 0, $20, $38, $20, $60, $B0, $68, 0, $FE, $12, $14, $28, $20, $20, $40
                dc.b 4, 8, $10, $30, $D0, $10, $10, $10, $10, $10, $FE, $82, 4, 4, 8, $30
                dc.b 0, $7C, $10, $10, $10, $10, $10, $FE, 8, 8, $FE, $18, $28, $28, $48, $18
                dc.b $10, $10, $FE, $12, $12, $22, $4A, $84, $10, $10, $FE, $10, $FE, $10, $10, $10
                dc.b 0, $7C, $44, $84, 8, 8, $10, $60, 0, $40, $7E, $88, 8, 8, $10, $20
                dc.b 0, $FE, 2, 2, 2, 2, 2, $FE, $24, $24, $FE, $24, $24, 4, 8, $30
                dc.b 0, 0, $E0, 2, $E2, 4, 8, $F0, 0, $FE, 4, 8, $10, $28, $44, $82
                dc.b $40, $40, $FE, $44, $48, $40, $40, $7E, 0, $84, $84, $44, 8, 8, $10, $60
                dc.b $7E, $42, $42, $B2, $C, 4, 8, $30, 8, $10, $70, $10, $FE, $10, $10, $20
                dc.b 0, $52, $52, $52, 2, 4, 8, $70, $7C, 0, $FE, 8, 8, 8, $10, $20
                dc.b $40, $40, $40, $60, $50, $40, $40, $40, 8, 8, $FE, 8, 8, $10, $10, $60
                dc.b 0, $7C, 0, 0, 0, 0, 0, $FE, 0, $FE, 2, 4, $34, 8, $14, $62
                dc.b $10, $7C, 4, 8, $38, $D4, $12, $10, 0, 4, 4, 4, 8, 8, $10, $60
                dc.b 0, 0, 8, $44, $42, $42, $82, 2, 0, $80, $80, $9C, $F0, $80, $80, $7E
                dc.b 0, $FE, 2, 2, 4, 8, $10, $60, 0, $20, $50, $88, 4, 2, 0, 0
                dc.b $10, $10, $FE, $10, $54, $52, $92, $10, 0, $FE, 2, 2, 4, $28, $10, 8
                dc.b $78, 0, 0, $78, 0, 0, $FC, 2, 0, 8, $10, $20, $40, $84, $FC, 2
                dc.b 2, 2, $22, $14, 8, $14, $20, $C0, 0, $FC, $20, $20, $FE, $20, $20, $3E
                dc.b $20, $20, $FE, $22, $24, $20, $20, $20, 0, 0, $78, 8, 8, 8, 8, $FE
                dc.b 0, $FC, 4, 4, $FC, 4, 4, $FC, 0, $7C, 0, $FE, 2, 4, 8, $30
                dc.b 0, $44, $44, $44, $44, $24, 8, $10, 0, $50, $50, $50, $50, $50, $56, $9C
                dc.b 0, $40, $40, $40, $44, $44, $48, $70, 0, $FE, $82, $82, $82, $82, $FE, 0
                dc.b $FE, $82, $82, 2, 4, 4, 8, $30, $7E, 2, 2, $3E, 4, 4, 8, $30
                dc.b 0, $70, 2, 2, 2, 4, 8, $70, 0, 0, 0, $F8, $28, $30, $20, $40
                dc.b 0, 0, 8, $10, $30, $D0, $10, $10, 0, 0, $20, $F8, $88, $88, $10, $20
                dc.b 0, 0, 0, $70, $20, $20, $20, $F8, 0, 0, $10, $F8, $30, $30, $50, $90
                dc.b 0, 0, 0, $A8, $A8, 8, $10, $60, 0, 0, 0, $40, $F8, $28, $20, $20
                dc.b 0, 0, 0, $70, $10, $10, $10, $FC, 0, 0, 0, $F0, $10, $F0, $10, $F0
                dc.b 0, 0, 0, 0, 0, 0, $A, 5, 0, 0, 0, 0, 0, 7, 5, 7
                dc.b 0, 0, 0, 0, $FC, 0, 0, 0, 0, 0, 0, 0, 0, $60, $60, $20
                dc.b 0, 0, 0, 0, $30, $48, $48, $30
;empty_block_1:  dc.b [$D6F6]$FF
;                org $3000
sub_10000:
                move    #$2700,sr
                move.l  #sub_10E88,(dword_FFFA7E).w
                clr.w   (word_FFFF96).w
                move.w  #$40,(word_FFFFC0).w
                clr.w   (word_FFFFC4).w
                clr.w   (word_FFFFC2).w
                bsr.w   sub_10CD4
                bsr.w   sub_10CF6
                bsr.w   LoadTilesToVRAM
                lea     (dword_FFD800).w,a6
                moveq   #0,d7
                move.w  #$1FF,d6

loc_10034:
                move.l  d7,(a6)+
                dbf     d6,loc_10034
                move.l  #$40000010,(VDP_CTRL).l
                move.w  #0,(VDP_DATA).l
                move.l  #$40020010,(VDP_CTRL).l
                move.w  #0,(VDP_DATA).l
                bsr.w   sub_113BC
                move.w  #$101,(word_FFD82C).w
                move    #$2500,sr

loc_1006C:
                movea.w (off_0+2).w,sp
                move.w  (word_FFFFC0).w,d0
                andi.l  #$7C,d0
                jsr     loc_10084(pc,d0.w)
                addq.w  #1,(word_FFFF92).w
                bra.s   loc_1006C

loc_10084:
                bra.w   sub_11FB0
                bra.w   sub_12122
                bra.w   sub_1228E
                bra.w   sub_122E0
                bra.w   sub_125BE
                bra.w   sub_125F2
                bra.w   sub_12656
                bra.w   sub_1266E
                bra.w   sub_12A94
                bra.w   sub_12B46
                bra.w   sub_12F30
                bra.w   sub_12FDC
                bra.w   sub_13110
                bra.w   sub_13162
                bra.w   sub_139A2
                bra.w   sub_13A18
                bra.w   loc_100CC
                bra.w   loc_100D0

loc_100CC:
                jmp     LoadSegaScreen

loc_100D0:
                jmp     SegaScreen

sub_100D4:
                jsr     unk_FFFBB4
                lea     (word_FFD000).w,a6
                moveq   #0,d7
                move.w  #$1FF,d6

loc_100E2:
                move.l  d7,(a6)+
                dbf     d6,loc_100E2
                bsr.w   sub_113BC
                bsr.w   sub_110FE
                move.w  #$8000,(word_FFD884).w
                jmp     LoadLogoAndExitToVRAM

LoadTilesToVRAM:
                move.w  #$200,d0
                jsr     unk_FFFB8A
                lea     (LevelTiles).l,a0
                jsr     j_Nem_Decomp
                move.w  #$400,d0
                jsr     unk_FFFB8A
                lea     (SpritesTiles).l,a0
                jsr     j_Nem_Decomp
                move.b  #1,(byte_FFD88E).w

loc_10126:
                moveq   #$20,d0
                lea     (VDP_CTRL).l,a6
                jsr     unk_FFFB8A
                lea     (Jap1BPPTiles).w,a0
                moveq   #$20,d0
                add.b   (byte_FFD88E).w,d0
                move.w  #$B3,d1
                jsr     unk_FFFA8E
                moveq   #$30,d0
                lea     (VDP_CTRL).l,a6
                jsr     unk_FFFB8A
                lea     (Latin1BPPTiles).l,a0
                moveq   #$20,d0
                add.b   (byte_FFD88E).w,d0
                move.w  #$2B,d1
                jsr     unk_FFFA8E
                move.w  #$120,d0
                lea     (VDP_CTRL).l,a6
                jsr     unk_FFFB8A
                lea     (Jap1BPPTiles).w,a0
                moveq   #$30,d0
                add.b   (byte_FFD88E).w,d0
                move.w  #$B3,d1
                jsr     unk_FFFA8E
                move.w  #$130,d0
                lea     (VDP_CTRL).l,a6
                jsr     unk_FFFB8A
                lea     (Latin1BPPTiles).l,a0
                moveq   #$30,d0
                add.b   (byte_FFD88E).w,d0
                move.w  #$2B,d1
                jsr     unk_FFFA8E
                rts

LoadLogoAndExitToVRAM:
                lea     (VDP_CTRL).l,a6
                move.w  #$640,d0
                jsr     unk_FFFB8A
                lea     (ScoresTiles).l,a0
                jsr     j_Nem_Decomp
                move.w  #$693,d0
                jsr     unk_FFFB8A
                lea     (ExitTiles).l,a0
                jsr     j_Nem_Decomp
                rts

                ;org $81D4
z80_part2:      dc.b 1, $C8, $10, 0, 1, $E0, 9, $2C, $12, 0, 3, $A8, $14, $10, $42, $10
                dc.b $7D, $10, $B0, $10, $F8, $10, $26, $11, $26, $11, $62, $11, $94, $11, $14, $10
                dc.b $29, $10, 1, 1, $80, 5, $1E, $10, $F4, 0, $EF, 0, $F0, 1, 1, $32
                dc.b 0, $D2, $C, $CF, $F2, $6E, $13, $13, $13, $13, $13, $13, $13, $14, $12, $10
                dc.b $10, $12, $17, $12, $17, $17, $45, $1A, $AC, $3D, $88, $80, $80, $80, $64, $10
                dc.b 1, 1, $80, 5, $4C, $10, 0, 0, $F0, 1, 1, $16, 0, $EF, 0, $E4
                dc.b 2, 1, 0, 3, 1, $C2, 4, $C0, $BF, $BF, $C0, $BB, $BB, $C0, $C4, $F2
                dc.b $FD, 3, 3, $16, $33, $F, $F, $1F, $F, 0, $10, $10, $14, 0, 0, 0
                dc.b $10, $6F, $4F, $5F, $6F, $98, $80, $80, $80, $97, $10, 1, 1, $80, 5, $87
                dc.b $10, $F4, 0, $EF, 0, $F0, 3, 1, $F6, 2, $BE, 2, $80, 1, $C2, 6
                dc.b $D1, 8, $F2, $3C, $46, 3, $24, $22, $1D, $19, $1C, $19, $14, $F, $11, $13
                dc.b 6, $D, $10, $10, $1F, $1F, $1F, $1F, $14, 0, 6, $80, $DF, $10, 1, 1
                dc.b $80, 5, $BC, $10, 0, 0, $E1, 2, $EF, 0, $F0, 4, 1, $60, 6, $E4
                dc.b 2, 1, 2, 3, 1, $B1, 4, $B2, $B3, $B2, $B3, $B4, $B5, $B6, $B3, $B6
                dc.b $B7, $B6, $B7, $B8, $B9, $BA, $B8, $B9, $BA, $BB, $F2, $9C, $48, $23, $54, $22
                dc.b $1F, $1F, $15, $3C, 8, 8, $18, $18, $C, $C, $C, $E, $6B, $4F, $5F, $3F
                dc.b $36, $80, $2F, $90, $D, $11, 1, 1, $80, 5, 2, $11, 0, 0, $EF, 0
                dc.b $E4, 2, 3, 2, 3, 1, $BD, $18, $F2, $70, $16, 7, 7, $18, $1F, $1F
                dc.b $1F, $1F, $47, $10, $3F, $8C, $16, $10, $11, $11, $11, $12, $11, $1A, $96, $95
                dc.b $9D, $80, $49, $11, 1, 1, $80, 5, $30, $11, 0, 0, $E4, 3, 0, 3
                dc.b 3, 1, $EF, 0, $AE, 3, $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4
                dc.b $A3, $A2, $A1, $A0, $F2, $B4, $17, $17, $14, $14, $1F, $12, $1F, 8, $14, $14
                dc.b $14, $14, $D, $E, $E, $10, $11, $1F, $17, $C, $8E, $80, $84, $80, $7B, $11
                dc.b 1, 1, $80, 5, $6C, $11, 0, 0, $EF, 0, $BF, 4, $C3, $C5, $C8, $10
                dc.b $BF, 4, $C3, $C5, $C8, $10, $F2, $64, 4, 2, $14, 4, $2C, $19, $2C, $1C
                dc.b $10, 0, 0, 0, $1D, $11, $10, 6, 2, $1F, $1F, $1F, $92, $80, $92, $80
                dc.b $AE, $11, 1, 2, $80, 5, $A6, $11, 0, 0, $80, 6, $A4, $11, 0, $18
                dc.b $80, 2, $EF, 0, $C0, 6, $C4, $CF, $D4, $F2, $65, 6, 7, $11, $12, $F
                dc.b $F, $3F, $3A, $1F, $1F, $10, $1E, $1D, 0, 0, $21, $89, $7F, $C, $C, $A2
                dc.b $87, $8C, $80, 0, $E, $12, $12, $10, $4D, $12, 0, $10, $E, $12, $E, $12
                dc.b $90, 0, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
                dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
                dc.b $80, $70, $80, $80, $80, $80, $80, $70, $70, $70, 0, 0, $80, $10, $20, $70
                dc.b 0, 0, 0, 0, 0, 0, $70, $68, $78, $78, $80, $80, $80, $80, $80, $80
                dc.b $80, $5B, $12, $BF, $13, $FB, $14, $71, $17, $7D, $18, 0, 0, $4B, $1A, $74
                dc.b $13, 7, 0, 2, 0, $73, $13, 0, 0, $84, $12, $F4, 6, $B0, $12, $F4
                dc.b 8, $F7, $12, $F4, $20, $2C, $13, $F4, $20, $7D, $12, $F4, $10, $AE, $12, $F4
                dc.b $20, $80, 2, $E1, 8, $F6, $88, $12, $EA, $4E, 2, $E6, $EF, 2, $D7, $C
                dc.b $CB, $D7, $CB, $D7, $CB, $D7, $CB, $D5, $C9, $D5, $C9, $D5, $C9, $D5, $C9, $D4
                dc.b $C8, $D4, $C8, $D4, $C8, $D4, $C8, $D2, $C6, $D2, $C6, $D2, $C6, $D2, $C6, $F6
                dc.b $84, $12, $80, 2, $EF, 0, $E4, 2, 1, 3, 3, 3, $E8, 6, $CB, 6
                dc.b $CD, $CF, $C, $D2, $CF, $CB, 6, $CD, $CF, $C, $D2, $CF, $C9, 6, $CB, $CD
                dc.b $C, $D0, $CD, $C9, 6, $CB, $CD, $C, $D0, $CD, $C8, 6, $C9, $CB, $C, $D0
                dc.b $CB, $C8, 6, $C9, $CB, $C, $C4, $CB, $C6, 6, $C8, $CA, $C, $CD, $CA, $C6
                dc.b 6, $C5, $C6, $C8, $CA, $C8, $CA, $CD, $F6, $B0, $12, $EF, 1, $E8, 6, $B3
                dc.b $C, $B3, $B7, $B3, $B3, $B3, $B7, 6, $B5, $B3, $80, $B5, $C, $B1, $B5, $B1
                dc.b $B1, $B1, $B5, 6, $B3, $B1, $C, $B0, $B0, $B3, $B0, $B0, $B0, $B3, 6, $B1
                dc.b $B0, $C, $AE, $AE, $B2, $AE, $AE, $AE, $AE, 6, $B0, $B2, $C, $F6, $F7, $12
                dc.b $EF, 0, $D7, $C, $D7, 6, $D9, $DB, $80, $D9, $80, $D7, $80, $D2, $80, $D4
                dc.b $80, $D2, $80, $D9, $80, $D0, $D0, $D5, $80, $D0, $80, $D0, $80, $D5, $80, $D7
                dc.b $80, $D9, $80, $D4, $80, $D4, $D5, $D7, $80, $D4, $80, $D4, $D5, $D7, $80, $D0
                dc.b $80, $D0, $80, $D6, $C, $D6, 6, $D4, $D6, $80, $D4, $80, $D6, $80, $D2, $80
                dc.b $D4, $80, $D6, $80, $F6, $2C, $13, $F2, $2C, $72, $72, $32, $32, $1F, $16, $1F
                dc.b $1F, 0, $F, 0, $F, 0, 9, 0, 9, 6, $36, 6, $36, $15, $80, $14
                dc.b $80, $38, $36, $34, $30, $31, $1F, $1F, $5F, $5F, $12, $1E, $11, $A, $10, 8
                dc.b 4, 3, $2F, $4F, $3F, $2F, $30, $20, $14, $80, $38, $64, $32, $11, $32, $55
                dc.b $9B, $70, $D3, 2, 1, 1, 3, 3, 1, 3, 0, $15, $F, $F, $A0, $21
                dc.b $47, $21, $80, $65, $14, 7, 0, 2, 0, $64, $14, 0, $20, $E6, $13, $F4
                dc.b 6, $17, $14, $DC, $17, $3C, $14, 0, $17, $E1, $13, 0, $20, $10, $14, 0
                dc.b $20, $37, $14, $F4, 4, $EF, 3, $F6, $F2, $13, $EA, $68, 2, $E6, $EF, 1
                dc.b $E4, 2, 2, 3, 3, 3, $D7, 6, $D5, $D4, $80, $D4, $80, $D4, $80, $D7
                dc.b $D5, $D4, $80, $D4, $80, $D4, $80, $D7, $D5, $D4, $80, $DB, $D9, $D7, $80, $D9
                dc.b $DB, $DC, $18, $F2, $E1, 2, $EF, 4, $F6, $19, $14, $EF, 0, $C8, 6, $C8
                dc.b $CD, $80, $C8, $80, $CD, $80, $C8, $80, $CD, $80, $CD, $80, $CD, $80, $CD, $80
                dc.b $CD, $D0, $D4, $80, $C8, $CB, $CF, $80, $CD, $18, $F2, $EF, 5, $F6, $3E, $14
                dc.b $EF, 2, $80, $C, $D0, 6, $C8, $CB, $C8, $D0, $C8, $CB, $C8, $D0, $C8, $CB
                dc.b $C8, $D0, $C8, $CB, $C8, $D0, $C8, $CB, $C8, $D0, $CB, $CD, $CF, $D0, 3, $CF
                dc.b $CD, $CB, $C9, $C8, $C6, $C4, $DC, $C, $F2, $38, $38, $30, $30, $31, $1F, $1F
                dc.b $5F, $5F, $12, $E, $A, $A, 0, 4, 4, 3, $2F, $2F, $2F, $2F, $2A, $2C
                dc.b $D, $80, $36, $61, $44, $30, $31, $19, $1F, $1F, $1F, $1A, $41, $41, $51, $10
                dc.b $A, 6, 9, $49, $5D, $A9, $8A, 1, $80, $85, $80, $20, $6B, $6A, $63, $61
                dc.b $DF, $DF, $9F, $9F, 7, 6, 9, 6, 7, 6, 6, 8, $23, $12, $11, $54
                dc.b $1C, $3A, $16, $80, $20, $6B, $6A, $63, $61, $DF, $DF, $9F, $9F, 7, 6, 9
                dc.b 6, 7, 6, 6, 8, $23, $12, $11, $54, $1C, $3A, $16, $80, $14, $66, $41
                dc.b $62, $61, $DF, $DF, $9F, $9F, $15, $14, $19, $16, 7, 6, 6, 6, $23, $12
                dc.b $1F, $5F, $1C, $8A, $16, $80, $22, $65, $64, $63, $60, $9F, $DF, $9F, $9F, $C
                dc.b $16, $19, $16, 7, 6, 6, 8, $23, $12, $11, $54, $1C, $1A, $36, $80, $D
                dc.b $17, 7, 0, 2, 0, $C, $17, 0, $20, $29, $15, $F4, $10, $8B, $15, 0
                dc.b $18, $26, $16, $F4, $1C, $A9, $16, $F4, $C, $1D, $15, $F4, $18, $24, $16, $F4
                dc.b $18, $80, 3, $F0, $C, 1, 4, 8, $EF, 0, $F6, $2F, $15, $EA, $34, 2
                dc.b $E6, $EF, 0, $D7, 6, $D9, $D7, $D6, $D7, $80, $D6, $80, $D7, $12, $D5, 6
                dc.b $D4, $80, $D2, $80, $D0, $12, $D2, 6, $D4, $80, $D5, $80, $D7, $C, $80, $CB
                dc.b $80, $CB, $3C, $C8, $C, $C9, $CA, $CB, $3C, $D0, $C, $CF, $CD, $CB, $3C, $C9
                dc.b $C, $C8, $C6, $C9, $3C, $C6, $C, $C8, $C9, $CB, $3C, $C8, $C, $C9, $CA, $CB
                dc.b $3C, $D0, $C, $CF, $D0, $D2, $C, $80, $CB, 6, $CA, $CB, $80, $D2, $C, $80
                dc.b $CB, 6, $CA, $CB, $80, $CF, $C, $CD, $CF, $D0, $D2, $30, $F6, $4D, $15, $EF
                dc.b 1, $A7, $12, $A2, 6, $A7, $80, $A2, $80, $A7, $12, $A9, 6, $AA, $80, $AB
                dc.b $80, $AC, $12, $AC, 6, $AC, $80, $AC, $80, $AC, $C, $80, $A7, $80, $A0, 6
                dc.b $80, $A7, $A7, $A0, $80, $A7, $80, $F7, 0, 3, $AA, $15, $A0, $80, $A0, $A2
                dc.b $A4, $80, $A5, $80, $A7, $80, $9F, $9F, $A2, $80, $9F, $80, $A7, $80, $9F, $9F
                dc.b $A2, $80, $9F, $80, $A7, $80, $9F, $9F, $A2, $80, $9F, $A2, $A7, $80, $A7, $A9
                dc.b $AA, $80, $AB, $80, $A0, 6, $80, $A7, $A7, $A0, $80, $A7, $80, $A0, $80, $A7
                dc.b $A7, $A0, $80, $A7, $80, $A0, $80, $A7, $A7, $A0, $80, $9B, $80, $A0, $80, $A0
                dc.b $A2, $A4, $80, $A5, $80, $A7, $80, $A7, $A7, $A2, $80, $A2, $80, $A7, $80, $A7
                dc.b $A7, $A2, $80, $A2, $80, $A7, $80, $A6, $A6, $A7, $80, $A9, $80, $AB, $80, $A7
                dc.b $80, $A9, $80, $AB, $80, $F6, $AA, $15, $80, 3, $EF, 2, $80, $30, $D4, $12
                dc.b $D2, 6, $D0, $80, $CF, $80, $CB, $12, $CF, 6, $D0, $80, $D2, $80, $D4, $C
                dc.b $80, $CB, $80, $E4, 2, 2, 3, 3, 3, $F8, $9A, $16, $D4, $D5, $D4, $D2
                dc.b $D4, $D0, $D2, $D4, $D2, $D4, $D2, $D4, $D5, $D4, $D5, $D4, $D2, $D4, $D2, $D4
                dc.b $D5, $D4, $D5, $D4, $D2, $CB, $CD, $CF, $D0, $CF, $D0, $D2, $CF, $CB, $CD, $CF
                dc.b $D0, $D2, $D4, $D5, $F8, $9A, $16, $D4, $D5, $D7, $DC, $DB, $D9, $D7, $D4, $DE
                dc.b $DD, $DE, $80, $1E, $DE, 6, $DD, $DE, $80, $1E, $CB, 6, $CA, $CB, $CD, $CF
                dc.b $CD, $CF, $D0, $D2, $D4, $D2, $D4, $D2, $CF, $D0, $D2, $F6, $3F, $16, $D4, 6
                dc.b $D5, $D4, $D5, $D7, $D5, $D7, $D5, $F7, 0, 3, $9A, $16, $F9, $EF, 3, $80
                dc.b $30, $80, $80, $BA, 3, $BC, $BE, $BF, $C1, $C3, $C4, $C6, $CB, 6, $80, $12
                dc.b $C8, $C, $C4, $C8, $C4, $C8, $C4, $C6, $C7, $C8, $C4, $C8, $C4, $C8, $CB, $C9
                dc.b $C6, $F7, 0, 2, $BC, $16, $C8, $C4, $C8, $C4, $C8, $C4, $C8, $C4, $C8, $C4
                dc.b $C8, $C4, $C8, $C4, $C8, $C4, $CB, 6, $80, $CB, $80, $1E, $CB, 6, $80, $CB
                dc.b $80, $1E, $CB, 6, $CB, $BF, $80, $CB, $CB, $BF, $80, $BF, 3, $C1, $C3, $C4
                dc.b $C6, $C8, $CA, $CB, $CD, $CF, $D0, $D2, $D4, $CA, $CB, 6, $F6, $BC, $16, $F2
                dc.b $F2, $34, $35, $41, $75, $71, $5B, $9F, $5F, $1F, 4, 7, 7, 8, 0, 0
                dc.b 0, 0, $F0, $F4, $E0, $F6, $22, $80, $1F, $80, $38, $38, $30, $30, $31, $1F
                dc.b $1F, $5F, $5F, $12, $E, $A, $A, 0, 4, 4, 3, $2F, $2F, $2F, $2F, $24
                dc.b $2D, $18, $80, $3C, $32, $32, $74, $40, $1F, $18, $1F, $1E, 7, $1F, 7, $1F
                dc.b 0, 0, 0, 0, $1F, $F, $1F, $F, $21, $80, $19, $80, $2C, $72, $78, $34
                dc.b $34, $1F, $12, $1F, $12, 0, $A, 0, $A, 0, 0, 0, 0, $F, $1F, $F
                dc.b $1F, $16, $90, $17, $90, 0, $18, 7, 3, 2, 0, $FF, $17, 0, $20, $AF
                dc.b $17, $F4, $10, $D2, $17, $F4, $10, $E6, $17, $F4, $10, $A5, $17, $F4, $16, $D0
                dc.b $17, $F4, $10, $D7, $17, $F4, $10, $FE, $17, $F4, 8, 8, 0, $FE, $17, $F4
                dc.b 8, 0, 2, $FE, $17, $F4, 8, 0, 3, $80, 6, $F0, 6, 1, 4, 6
                dc.b $F6, $B3, $17, $EA, $90, 2, $E6, $EF, 1, $D4, 6, $CF, $CC, $C8, $C8, $C3
                dc.b $C0, $C8, $80, $18, $D4, 6, $CF, $CC, $C8, $C8, $C3, $C0, $BC, $C0, $C3, $C8
                dc.b $C0, $D4, $18, $F2, $D4, $17, $E0, $80, $EF, 1, $F2, $80, 1, $EF, 2, $E1
                dc.b 2, $E4, 1, 1, 0, 1, 3, $F6, $E6, $17, $EF, 0, $80, $30, $C8, 6
                dc.b $C3, $C0, $BC, $C0, $BC, $C0, $B7, $BC, $C0, $C3, $C0, $C3, $BC, $C0, $C3, $BC
                dc.b $18, $F2, $F2, $F2, $14, 4, 1, 0, 0, $1F, $1F, $1F, $1F, $10, $F, 9
                dc.b 8, 7, 0, 0, 0, $3F, $F, $F, $4F, $10, $80, $10, $80, $14, 4, 2
                dc.b 1, 2, $1F, $1F, $1F, $1F, $10, $F, 9, 8, 7, 0, 0, 0, $3F, $F
                dc.b $F, $4F, $10, $80, $10, $80, $10, 4, 2, 8, 4, $1F, $1F, $1F, $1F, $10
                dc.b $F, 9, 8, 7, 0, 0, 0, $3F, $F, $F, $4F, $20, $20, $20, $80, $10
                dc.b 4, 2, 8, 4, $1F, $1F, $1F, $1F, $10, $F, 9, 8, 7, 0, 0, 0
                dc.b $3F, $F, $F, $4F, $20, $20, $20, $80, $35, 5, 3, 7, 2, $19, $20, $15
                dc.b $F, $C, 9, $10, 6, $1F, 0, $10, 0, $1F, $3F, $3F, $3F, $10, $80, $80
                dc.b $80, $CE, $19, 7, 0, 2, 0, $CD, $19, 0, $20, $AB, $18, $F4, 7, $F2
                dc.b $18, $E8, $17, $56, $19, $F4, $10, $8A, $19, $E8, $1B, $9F, $18, $F4, $10, $C5
                dc.b $19, $F4, $10, $80, 3, $F0, 3, 1, 4, 5, $EF, 0, $F6, $B7, $18, $EA
                dc.b $44, 2, $E6, $EF, 0, $E4, 2, 1, 3, 2, 2, $D4, $C, $D6, $D4, $D6
                dc.b $D4, $D6, $D4, $D6, $D4, $D9, $18, $C, $D6, $80, $D4, $80, $D4, $D6, $D4, $D6
                dc.b $D4, $D6, $D4, $D6, $D4, $D9, $D8, $D6, $D4, $D6, $D8, $D9, $DB, $80, $D9, $D6
                dc.b $3C, $DB, $C, $80, $D9, $D4, $3C, $DB, $C, $80, $D9, $D6, $D4, $D6, $D8, $DB
                dc.b $D9, $D8, $D9, $D8, $D9, $F2, $EF, 2, $E4, 2, 1, 3, 3, 3, $D4, 6
                dc.b $CD, $D1, $CD, $D4, $CD, $D1, $CD, $D4, $CD, $D1, $CD, $D4, $CD, $D3, $D4, $F7
                dc.b 0, 4, $FA, $18, $D6, $CD, $D2, $CD, $D6, $CD, $D2, $CD, $D6, $CD, $D2, $CD
                dc.b $D6, $CD, $D5, $D6, $D4, $CD, $D1, $CD, $D4, $CD, $D1, $CD, $D4, $CD, $D1, $CD
                dc.b $D4, $CD, $D3, $D4, $D6, $CD, $D2, $CD, $D6, $CD, $D2, $D6, $D8, $CF, $D4, $CF
                dc.b $D8, $CF, $D4, $D8, $D9, $D1, $D8, $D1, $D9, $D1, $D8, $D1, $EF, 4, $D9, 3
                dc.b $D8, $D6, $D4, $D2, $D1, $CF, $CD, $D9, $C, $F2, $EF, 3, $E4, 2, 1, 3
                dc.b 3, 3, $80, $60, $80, $80, $80, $80, $30, $C6, 3, $C8, $CA, $CC, $CD, $CF
                dc.b $D1, $D2, $D4, $D6, $D8, $D9, $DB, $DD, $DE, 6, $80, $30, $C8, 3, $CA, $CC
                dc.b $CD, $CF, $D1, $D2, $D4, $D6, $D8, $D9, $DB, $DD, $DE, $E0, 6, $F2, $EF, 2
                dc.b $A9, $C, $B5, $A9, 6, $A9, $B5, $C, $F7, 0, 8, $8C, $19, $AE, $BA, $AE
                dc.b 6, $AE, $BA, $C, $AE, $B0, $B2, $B4, $B5, $C1, $B5, 6, $B5, $C1, $C, $B5
                dc.b $B4, $B2, $B0, $AE, $BA, $AE, 6, $AE, $BA, $C, $B0, $BC, $B0, 6, $B0, $BC
                dc.b $C, $B5, $B4, $B5, $B4, $B5, $80, $A9, $F2, $EF, 4, $EF, 4, $EF, 4, $F2
                dc.b $F2, $F2, $33, $31, 1, $10, $32, $10, $1F, $1F, $F, $F, 1, $16, $B, $B
                dc.b 7, $28, 0, $5F, $5F, $3A, $3A, $97, $18, $E4, $80, $10, 4, 2, 8, 4
                dc.b $1F, $1F, $1F, $1F, $10, $F, 9, 8, 7, 0, 0, 0, $3F, $F, $F, $4F
                dc.b $20, $20, $20, $80, $2C, $72, $72, $32, $32, $1F, $16, $1F, $1F, 0, $F, 0
                dc.b $F, 0, 9, 0, 9, 6, $36, 6, $3F, $15, $80, $14, $80, $2C, $26, $26
                dc.b $23, $23, $1F, $15, $1F, $14, $10, $10, $12, 9, 3, 3, 3, 3, $4F, $4F
                dc.b $4F, $4F, $15, $90, $14, $80, $3B, 6, $36, $63, $32, $DF, $54, $D0, $8F, 9
                dc.b 7, $B, 4, 3, 0, 0, 0, $EF, $FF, $2F, $F, $28, $29, $1C, $80, $E0
                dc.b $1A, 6, 2, 2, 0, $DF, $1A, 0, 0, $81, $1A, 1, 0, $B4, $1A, $FF
                dc.b 8, $75, $1A, $F5, $10, $A8, $1A, $F5, $10, $D7, $1A, $F5, $20, $DE, $1A, $F5
                dc.b 8, 1, 1, $DE, $1A, $F5, 8, 0, 2, $80, 5, $F0, 3, 1, 4, 9
                dc.b $EF, 0, $F6, $87, $1A, $EA, $27, 3, $E6, $EF, 0, $E4, 2, 3, 2, 3
                dc.b 3, $BE, $C, $C0, $BE, $C0, $B9, $80, $B9, $80, $BC, 6, $BB, $BA, $B9, $B8
                dc.b $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $F2, $80, 3, $F0, 3
                dc.b 1, 4, 9, $EF, 0, $F6, $B6, $1A, $EF, 0, $E4, 2, 3, 2, 2, 3
                dc.b $BE, $C, $C0, $BE, $C0, $B9, $80, $B9, $80, $BC, 6, $BB, $BA, $B9, $B8, $B7
                dc.b $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $F2, $EF, 0, $EF, 0, $EF
                dc.b 0, $F2, $F2, $F2, $F1, 4, 4, $12, $14, $F, $F, $3C, $3A, 0, $10, $10
                dc.b $14, 0, 0, 0, $10, $7F, $7F, $7F, $C, $96, $93, $99, $80, $10, 4, 2
                dc.b 8, 4, $1F, $1F, $1F, $1F, $10, $F, 9, 8, 7, 0, 0, 0, $3F, $F
                dc.b $F, $4F, $20, $20, $20, $80, $10, 4, 2, 8, 4, $1F, $1F, $1F, $1F, $10
                dc.b $F, 9, 8, 7, 0, 0, 0, $3F, $F, $F, $4F, $20, $20, $20, $80, 0
sub_10CD4:
                move.l  #$C0000000,(VDP_CTRL).l
                moveq   #$3F,d0

loc_10CE0:
                move.w  #0,(VDP_DATA).l
                dbf     d0,loc_10CE0
                moveq   #0,d2
                move.w  #$A800,d0
                jmp     unk_FFFAD6

sub_10CF6:
                jsr     j_LoadZ80Driver
                lea     (z80_part2).l,a1
                bsr.s   sub_10D24
                bsr.s   sub_10D24
                moveq   #8,d0
                move.w  #$1C00,d1
                moveq   #1,d2
                lea     byte_10D1A(pc),a0
                jsr     unk_FFFB54
                clr.w   (word_FFFFA2).w
                rts

byte_10D1A:     dc.b 0, $80, 0, $12, $B4, 0, $E6, $80, $20, 0
sub_10D24:
                moveq   #2,d2
                movem.w (a1)+,d0-d1/a0
                suba.l  #$10000,a0
                jmp     unk_FFFB54

sub_10D34:
                move.l  a0,-(sp)
                jsr     unk_FFFB36
                move.b  d0,(byte_A01C09).l
                jsr     unk_FFFB3C
                movea.l (sp)+,a0
                rts

sub_10D48:
                tst.b   (byte_FFD2A4).w
                bne.s   locret_10D50
                bsr.s   sub_10D34

locret_10D50:
                rts

sub_10D52:
                tst.b   (byte_FFD2A4).w
                beq.s   locret_10D6C
                addq.w  #1,(word_FFD2A2).w
                cmpi.w  #$1E,(word_FFD2A2).w
                bcs.s   locret_10D6C
                clr.w   (word_FFD2A2).w
                clr.b   (byte_FFD2A4).w

locret_10D6C:
                rts

sub_10D6E:
                movem.l d1,-(sp)
                clr.l   d1
                move.w  d0,d1
                lsl.l   #2,d1
                move.w  d0,d1
                andi.w  #$3FFF,d1
                ori.w   #$4000,d1
                swap    d1
                move.l  d1,d0
                movem.l (sp)+,d1
                rts

sub_10D8C:
                movea.l a4,a1
                clr.w   d1

loc_10D90:
                clr.w   d2
                move.b  (a0)+,d2
                beq.s   loc_10DB6
                bclr    #7,d2
                beq.s   loc_10DA8
                subq.b  #1,d2

loc_10D9E:
                move.b  (a0)+,(a1)
                adda.w  d0,a1
                dbf     d2,loc_10D9E
                bra.s   loc_10D90

loc_10DA8:
                subq.b  #1,d2
                move.b  (a0)+,d3

loc_10DAC:
                move.b  d3,(a1)
                adda.w  d0,a1
                dbf     d2,loc_10DAC
                bra.s   loc_10D90

loc_10DB6:
                movea.l a4,a1
                addq.w  #1,d1
                adda.w  d1,a1
                cmp.w   d1,d0
                bhi.s   loc_10D90
                rts

sub_10DC2:
                clr.w   d2
                move.b  (a0)+,d2
                beq.s   locret_10DE6
                bclr    #7,d2
                beq.s   loc_10DD8
                subq.b  #1,d2

loc_10DD0:
                move.b  (a0)+,(a4)+
                dbf     d2,loc_10DD0
                bra.s   sub_10DC2

loc_10DD8:
                subq.b  #1,d2
                move.b  (a0)+,d3

loc_10DDC:
                move.b  d3,(a4)+
                addq.b  #1,d3
                dbf     d2,loc_10DDC
                bra.s   sub_10DC2

locret_10DE6:
                rts

sub_10DE8:
                movem.l d0-d1,-(sp)
                clr.w   d5
                subi.w  #$20,d4
                bcc.s   loc_10E08
                cmpi.w  #$FFF3,d4
                bne.s   loc_10E02
                move.w  #$79,d4
                moveq   #1,d5
                bra.s   loc_10E3C

loc_10E02:
                addi.w  #$C0,d4
                bra.s   loc_10E3C

loc_10E08:
                moveq   #$40,d0
                cmp.w   d0,d4
                bcs.s   loc_10E3C
                sub.w   d0,d4
                moveq   #$40,d1
                moveq   #$50,d0
                cmp.w   d0,d4
                bcs.s   loc_10E1C
                sub.w   d0,d4
                moveq   #$77,d1

loc_10E1C:
                cmpi.w  #$37,d4
                bcs.s   loc_10E3A
                moveq   #1,d5
                cmpi.w  #$46,d4
                bcs.s   loc_10E36
                cmpi.w  #$4B,d4
                bcc.s   loc_10E34
                addq.w  #5,d4
                bra.s   loc_10E36

loc_10E34:
                moveq   #2,d5

loc_10E36:
                subi.w  #$32,d4

loc_10E3A:
                add.w   d1,d4

loc_10E3C:
                addi.w  #$40,d4
                tst.w   d5
                beq.s   loc_10E48
                addi.w  #$AD,d5

loc_10E48:
                addi.w  #$40,d5
                movem.l (sp)+,d0-d1
                rts

sub_10E52:
                trap    #0              ; ErrorTrap
                ror.l   #8,d1
                rts

sub_10E58:
                movem.l d0-d1/d7,-(sp)
                clr.w   (word_FFE630).w
                addq.w  #1,(word_FFE634).w
                move.w  (word_FFE632).w,d7
                subq.w  #1,d7
                bcs.s   loc_10E82

loc_10E6C:
                bsr.s   sub_10E52
                andi.l  #$FFFF,d1
                divu.w  (word_FFE634).w,d1
                swap    d1
                add.w   d1,(word_FFE630).w
                dbf     d7,loc_10E6C

loc_10E82:
                movem.l (sp)+,d0-d1/d7
                rts

sub_10E88:
                move    #$2700,sr
                movem.l d0-d7/a0-a6,-(sp)
                lea     (VDP_CTRL).l,a6
                move.w  (word_FFFF96).w,d0
                andi.w  #$C,d0
                jsr     loc_10EAC(pc,d0.w)
                clr.w   (word_FFFF96).w
                movem.l (sp)+,d0-d7/a0-a6
                rte

loc_10EAC:
                bra.w   locret_10EB8
                bra.w   sub_10EBA
                bra.w   sub_10EBA

locret_10EB8:
                rts

sub_10EBA:
                bsr.w   sub_1132A
                jsr     unk_FFFB12
                move.w  #$F550,d1
                move.w  #$BE00,d2
                move.w  #$200,d0
                jsr     unk_FFFACA
                moveq   #$F,d7
                lea     (word_FFF7E0).w,a0
                lea     (unk_FFF860).w,a1

loc_10EDC:
                cmpm.l  (a0)+,(a1)+
                bne.s   loc_10EEE
                dbf     d7,loc_10EDC
                bclr    #0,(byte_FFD00C).w
                bne.s   loc_10EF4
                bra.s   loc_10F14

loc_10EEE:
                move.b  #1,(byte_FFD00C).w

loc_10EF4:
                btst    #6,(IO_PCBVER+1).l
                beq.s   loc_10F06
                move.w  #$100,d0

loc_10F02:
                dbf     d0,loc_10F02

loc_10F06:
                move.w  #$F7E0,d1
                moveq   #0,d2
                move.w  #$80,d0
                jsr     unk_FFFAC4

loc_10F14:
                move.w  #$8100,d0
                move.b  (byte_FFFF71).w,d0
                ori.b   #$40,d0
                move.w  d0,(a6)
                rts

sub_10F24:
                add.w   d7,d7
                lsl.w   #6,d6
                add.w   d6,d7
                add.w   d5,d7
                move.w  d7,d5

sub_10F2E:
                lsl.l   #2,d5
                lsr.w   #2,d5
                bset    #$E,d5
                swap    d5
                rts

sub_10F3A:
                bsr.s   sub_10F24
                bra.s   loc_10F40

sub_10F3E:
                bsr.s   sub_10F2E

loc_10F40:
                move.l  d5,(VDP_CTRL).l
                move.w  d4,(VDP_DATA).l
                rts

sub_10F4E:
                lea     (VDP_CTRL).l,a4
                lea     (VDP_DATA).l,a3
                lsl.l   #2,d5
                lsr.w   #2,d5
                bset    #$E,d5
                swap    d5
                move.l  d5,(a4)

loc_10F66:
                move.w  (a6)+,(a3)
                dbf     d4,loc_10F66
                rts

sub_10F6E:
                bsr.s   sub_10F2E

sub_10F70:
                lea     (VDP_CTRL).l,a4
                lea     (VDP_DATA).l,a3
                move.l  #$400000,d0

loc_10F82:
                move.l  d5,(a4)
                move.w  d7,d1

loc_10F86:
                move.w  (a6)+,(a3)
                dbf     d1,loc_10F86
                add.l   d0,d5
                dbf     d6,loc_10F82
                rts

sub_10F94:
                cmpi.w  #$FFFF,(word_FFD884).w
                bne.s   loc_10FA2
                move.w  #$8020,d4
                bra.s   loc_10FA6

loc_10FA2:
                add.w   (word_FFD884).w,d4

loc_10FA6:
                bsr.s   sub_10F3E
                rts

sub_10FAA:
                moveq   #0,d6
                move.w  (a6)+,d6

loc_10FAE:
                moveq   #0,d4
                moveq   #0,d5
                move.w  d6,d5
                move.b  (a6)+,d4
                beq.s   locret_10FBE
                bsr.s   sub_10F94
                addq.w  #2,d6
                bra.s   loc_10FAE

locret_10FBE:
                rts

sub_10FC0:
                moveq   #0,d6
                move.w  (a6)+,d6

loc_10FC4:
                moveq   #0,d4
                moveq   #0,d5
                move.b  (a6)+,d4
                beq.s   locret_10FF2
                bsr.w   sub_10DE8
                move.w  d5,d3
                move.w  d6,d5
                subi.w  #$20,d4
                move.l  d5,-(sp)
                bsr.w   sub_10F3E
                move.l  (sp)+,d5
                subi.w  #$40,d5
                move.w  d3,d4
                subi.w  #$20,d4
                bsr.w   sub_10F3E
                addq.w  #2,d6
                bra.s   loc_10FC4

locret_10FF2:
                rts

sub_10FF4:
                clr.b   (byte_FFD00D).w
                subq.w  #2,d5

loc_10FFA:
                moveq   #0,d1
                move.b  (a6)+,d1
                move.w  d1,d4
                lsr.w   #4,d4
                addq.w  #2,d5
                movem.l d0-d1/d5,-(sp)
                bsr.w   sub_11036
                movem.l (sp)+,d0-d1/d5
                andi.w  #$F,d1
                move.w  d1,d4
                addq.w  #2,d5
                movem.l d0-d1/d5,-(sp)
                bsr.w   sub_11036
                movem.l (sp)+,d0-d1/d5
                dbf     d0,loc_10FFA
                tst.b   (byte_FFD00D).w
                bne.s   locret_11034
                moveq   #$30,d4
                bsr.w   sub_10F94

locret_11034:
                rts

sub_11036:
                tst.b   d4
                bne.s   loc_1104C
                tst.b   (byte_FFD00D).w
                bne.s   loc_11052
                tst.b   (byte_FFD29A).w
                beq.s   locret_1104A
                bsr.w   sub_10F94

locret_1104A:
                rts

loc_1104C:
                move.b  #1,(byte_FFD00D).w

loc_11052:
                addi.w  #$30,d4
                bsr.w   sub_10F94
                rts

sub_1105C:
                btst    #0,2(a0)
                bne.s   locret_110B8
                move.l  $34(a0),d1
                move.l  $30(a0),d2
                add.l   d1,d2
                cmpi.l  #$800000,d2
                bge.s   loc_1107C
                addi.l  #$1000000,d2

loc_1107C:
                cmpi.l  #$1800000,d2
                blt.s   loc_1108A
                subi.l  #$1000000,d2

loc_1108A:
                move.l  d2,$30(a0)
                swap    d2
                sub.w   (dword_FFFFA8).w,d2

loc_11094:
                cmpi.w  #$80,d2
                bge.s   loc_110A0
                addi.w  #$100,d2
                bra.s   loc_11094

loc_110A0:
                cmpi.w  #$180,d2
                blt.s   loc_110AC
                subi.w  #$100,d2
                bra.s   loc_110A0

loc_110AC:
                move.w  d2,$20(a0)
                move.l  $2C(a0),d3
                add.l   d3,$24(a0)

locret_110B8:
                rts

sub_110BA:
                move.l  $30(a0),d2
                sub.l   (dword_FFFFA8).w,d2

loc_110C2:
                cmpi.l  #$800000,d2
                bge.s   loc_110D2
                addi.l  #$1000000,d2
                bra.s   loc_110C2

loc_110D2:
                cmpi.l  #$1800000,d2
                blt.s   loc_110E2
                subi.l  #$1000000,d2
                bra.s   loc_110D2

loc_110E2:
                move.l  d2,$20(a0)
                move.l  $2C(a0),d3
                add.l   d3,$24(a0)
                rts

sub_110F0:
                movea.w a0,a6
                moveq   #$F,d7
                moveq   #0,d6

loc_110F6:
                move.l  d6,(a6)+
                dbf     d7,loc_110F6
                rts

sub_110FE:
                movem.l d5/a0,-(sp)
                move.w  #$1F,d5
                lea     (word_FFC000).w,a0

loc_1110A:
                bsr.s   sub_110F0
                movea.w a6,a0
                dbf     d5,loc_1110A
                movem.l (sp)+,d5/a0
                rts

sub_11118:
                movea.w a0,a6
                moveq   #$1E,d7
                moveq   #0,d6

loc_1111E:
                move.w  d6,(a6)+
                dbf     d7,loc_1111E
                rts

sub_11126:
                move.w  6(a0),d0
                movea.l 8(a0),a1
                movea.l (a1,d0.w),a1
                subq.b  #1,$11(a0)
                bpl.s   loc_11142
                move.b  1(a1),$11(a0)
                addq.b  #1,$10(a0)

loc_11142:
                moveq   #0,d0
                move.b  $10(a0),d0
                cmp.b   (a1),d0
                bcs.s   loc_11158
                clr.b   $10(a0)
                moveq   #0,d0
                bset    #2,2(a0)

loc_11158:
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                move.w  2(a1,d0.w),d1
                move.l  d1,$C(a0)
                rts

sub_11166:
                btst    #1,2(a0)
                beq.s   loc_11170
                rts

loc_11170:
                movea.l $C(a0),a1
                moveq   #0,d1
                move.b  (a1)+,d1
                move.b  (a1)+,4(a0)
                move.w  $24(a0),d2
                cmpi.w  #$180,d2
                bhi.s   locret_111D2
                move.w  $20(a0),d3

loc_1118A:
                move.b  (a1)+,d0
                ext.w   d0
                add.w   d2,d0
                move.w  d0,(a2)+
                move.b  (a1)+,(a2)+
                move.b  d6,(a2)+
                move.b  (a1)+,d0
                or.b    $13(a0),d0
                move.b  d0,(a2)+
                move.b  (a1)+,(a2)+
                move.b  (a1)+,d0
                tst.b   2(a0)
                bpl.s   loc_111B0
                bchg    #3,-2(a2)
                move.b  (a1),d0

loc_111B0:
                addq.w  #1,a1
                ext.w   d0
                add.w   d3,d0
                move.w  d0,d4
                subi.w  #$41,d4
                cmpi.w  #$17F,d4
                bcs.s   loc_111CA
                subq.w  #6,a2
                dbf     d1,loc_1118A
                rts

loc_111CA:
                move.w  d0,(a2)+
                addq.b  #1,d6
                dbf     d1,loc_1118A

locret_111D2:
                rts

sub_111D4:
                lea     (word_FFC000).w,a0
                bsr.w   sub_1129E
                bsr.w   loc_11254
                rts

sub_111E2:
                tst.b   (byte_FFD24E).w
                bne.s   loc_11228
                lea     (word_FFC440).w,a0
                bsr.w   sub_1129E
                lea     (unk_FFC200).w,a0
                moveq   #8,d0

loc_111F6:
                bsr.w   sub_1129E
                lea     $40(a0),a0
                dbf     d0,loc_111F6
                lea     (unk_FFC480).w,a0
                moveq   #$D,d0

loc_11208:
                bsr.w   sub_1129E
                lea     $40(a0),a0
                dbf     d0,loc_11208
                lea     (word_FFC000).w,a0
                moveq   #7,d0

loc_1121A:
                bsr.w   sub_1129E
                lea     $40(a0),a0
                dbf     d0,loc_1121A
                bra.s   loc_11254

loc_11228:
                lea     (unk_FFC580).w,a0
                bsr.w   sub_1129E
                lea     (word_FFC040).w,a0
                moveq   #$14,d0

loc_11236:
                bsr.w   sub_1129E
                lea     $40(a0),a0
                dbf     d0,loc_11236
                lea     (unk_FFC5C0).w,a0
                moveq   #3,d0

loc_11248:
                bsr.w   sub_1129E
                lea     $40(a0),a0
                dbf     d0,loc_11248

loc_11254:
                move.w  #$F550,(word_FFD000).w
                move.w  #1,(word_FFD002).w
                lea     (word_FFC000).w,a0
                moveq   #$1F,d7

loc_11266:
                move.w  d7,-(sp)
                tst.w   (a0)
                beq.s   loc_11280
                movea.w (word_FFD000).w,a2
                move.w  (word_FFD002).w,d6
                bsr.w   sub_11166
                move.w  d6,(word_FFD002).w
                move.w  a2,(word_FFD000).w

loc_11280:
                lea     $40(a0),a0
                move.w  (sp)+,d7
                dbf     d7,loc_11266
                movea.w (word_FFD000).w,a2
                cmpa.w  #$F550,a2
                beq.s   loc_1129A
                clr.b   -5(a2)
                rts

loc_1129A:
                clr.l   (a2)

locret_1129C:
                rts

sub_1129E:
                move.w  d0,-(sp)
                move.w  (a0),d0
                beq.s   loc_112AC
                andi.w  #$7FFC,d0
                jsr     loc_112B0(pc,d0.w)

loc_112AC:
                move.w  (sp)+,d0
                rts

loc_112B0:
                bra.w   locret_1129C
                bra.w   sub_1452E
                bra.w   sub_1483E
                bra.w   sub_13E70
                bra.w   sub_14EC6
                bra.w   sub_15D58
                bra.w   sub_16312
                bra.w   sub_16422
                bra.w   sub_16456
                bra.w   sub_164AE
                bra.w   sub_164EC
                bra.w   sub_16648
                bra.w   sub_165BA
                bra.w   sub_16600
                bra.w   sub_166C6
                bra.w   sub_16DAA
                bra.w   sub_12172
                bra.w   sub_121CC
                bra.w   sub_1223E
                bra.w   sub_12476
                bra.w   sub_134BC
                bra.w   sub_144DC
                bra.w   sub_16DCC

sub_1130C:
                move.l  (dword_FFD004).w,d0
                move.l  (dword_FFFFA8).w,d1
                add.l   d0,d1
                move.l  d1,(dword_FFFFA8).w
                move.l  (dword_FFD008).w,d0
                move.l  (dword_FFFFA4).w,d1
                add.l   d0,d1
                move.l  d1,(dword_FFFFA4).w
                rts

sub_1132A:
                lea     (VDP_CTRL).l,a6
                lea     (VDP_DATA).l,a5
                move.w  (dword_FFFFA8).w,d7
                neg.w   d7
                move.w  #$8F20,(a6)
                move.l  #$78400002,(VDP_CTRL).l
                moveq   #$17,d0

loc_1134C:
                move.w  d7,(a5)
                dbf     d0,loc_1134C
                move.l  #$78020002,(VDP_CTRL).l
                moveq   #$1B,d0

loc_1135E:
                move.w  d7,(a5)
                dbf     d0,loc_1135E
                move.w  #$8F02,(a6)
                move.w  (dword_FFFFA4).w,d7
                move.l  #$40000010,(VDP_CTRL).l
                move.w  d7,(a5)
                rts

sub_1137A:
                subq.b  #1,1(a0)
                bpl.s   loc_1138A
                move.b  1(a1),1(a0)
                addq.b  #1,0.w(a0)

loc_1138A:
                moveq   #0,d0
                move.b  0.w(a0),d0
                cmp.b   (a1),d0
                bcs.s   loc_113A0
                clr.b   0.w(a0)
                moveq   #0,d0
                move.b  #1,2(a0)

loc_113A0:
                asl.w   #2,d0
                movea.l 2(a1,d0.w),a6
                bsr.w   sub_10F70
                rts

sub_113AC:
                lea     (unk_FFC800).w,a0
                move.w  #$DF,d0

loc_113B4:
                clr.l   (a0)+
                dbf     d0,loc_113B4
                rts

sub_113BC:
                clr.l   (dword_FFFFA8).w
                clr.l   (dword_FFFFA4).w
                clr.l   (dword_FFD004).w
                clr.l   (dword_FFD008).w
                rts

sub_113CE:
                movem.w d4/d6-d7/a6,-(sp)
                lea     (unk_FFC800).w,a6
                lsl.w   #5,d6
                add.w   d7,d6
                move.b  d4,(a6,d6.w)
                movem.w (sp)+,d4/d6-d7/a6
                rts

sub_113E4:
                bsr.s   sub_113AC
                lea     (unk_FFC840).w,a0

loc_113EA:
                moveq   #0,d7
                move.b  (a6)+,d7
                beq.s   locret_113FA
                bclr    #7,d7
                bne.s   loc_113FC
                adda.l  d7,a0
                bra.s   loc_113EA

locret_113FA:
                rts

loc_113FC:
                bclr    #6,d7
                bne.s   loc_1140E
                subq.b  #1,d7

loc_11404:
                move.b  #1,(a0)+
                dbf     d7,loc_11404
                bra.s   loc_113EA

loc_1140E:
                movea.w a0,a1
                subq.b  #1,d7

loc_11412:
                move.b  #1,(a1)
                lea     $20(a1),a1
                dbf     d7,loc_11412
                addq.l  #1,a0
                bra.s   loc_113EA

sub_11422:
                bsr.s   sub_113E4
                bsr.s   sub_1148A
                bsr.w   sub_119C0
                bsr.w   sub_1194C
                bsr.w   sub_11976
                bsr.w   sub_11B86
                bsr.s   sub_1143A
                rts

sub_1143A:
                lea     (unk_FFC800).w,a0
                moveq   #$1F,d0

loc_11440:
                move.b  #$C,(a0)+
                dbf     d0,loc_11440
                lea     (unk_FFCB40).w,a0
                moveq   #$3F,d0

loc_1144E:
                move.b  #$C,(a0)+
                dbf     d0,loc_1144E
                lea     (unk_FFC840).w,a0
                moveq   #$1F,d0

loc_1145C:
                tst.b   (a0)
                beq.s   loc_1146C
                move.b  #3,-$20(a0)
                move.b  #$E,-$40(a0)

loc_1146C:
                addq.l  #1,a0
                dbf     d0,loc_1145C
                lea     (unk_FFCB20).w,a0
                moveq   #$1F,d0

loc_11478:
                tst.b   (a0)
                beq.s   loc_11482
                move.b  #$D,$20(a0)

loc_11482:
                addq.l  #1,a0
                dbf     d0,loc_11478
                rts

sub_1148A:
                lea     (byte_FFD82E).w,a0
                move.b  (a6),(a0)+
                move.b  1(a6),(a0)
                moveq   #0,d4
                moveq   #0,d0
                bsr.w   sub_11562
                lea     (byte_FFD830).w,a0
                moveq   #0,d0
                move.b  (a6),(a0)+
                move.b  1(a6),(a0)+
                moveq   #1,d4
                bsr.w   sub_11562
                lea     (unk_FFD832).w,a0
                moveq   #0,d0
                move.b  (a6),(a0)+
                move.b  1(a6),(a0)+
                moveq   #1,d4
                bsr.w   sub_11562
                lea     (byte_FFD834).w,a0
                move.b  (a6),(a0)+
                move.b  1(a6),(a0)
                moveq   #2,d4
                moveq   #0,d0
                bsr.w   sub_11562
                moveq   #3,d4
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_114E0
                subq.b  #1,d0
                bsr.w   sub_11562

loc_114E0:
                moveq   #4,d4
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_114EC
                subq.b  #1,d0
                bsr.s   sub_11562

loc_114EC:
                moveq   #5,d4
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_114F8
                subq.b  #1,d0
                bsr.s   sub_11562

loc_114F8:
                lea     (unk_FFC200).w,a0
                moveq   #5,d0

loc_114FE:
                move.w  #4,(a0)
                move.b  (a6)+,$3E(a0)
                move.b  (a6)+,$3F(a0)
                lea     $40(a0),a0
                dbf     d0,loc_114FE
                lea     (unk_FFC480).w,a0
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_1153A
                add.b   d0,(byte_FFD883).w
                subq.b  #1,d0

loc_11522:
                move.w  #8,(a0)
                move.b  (a6)+,$3E(a0)
                move.b  (a6)+,$3F(a0)
                clr.b   $3A(a0)
                lea     $40(a0),a0
                dbf     d0,loc_11522

loc_1153A:
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   locret_11560
                add.b   d0,(byte_FFD883).w
                subq.b  #1,d0

loc_11546:
                move.w  #8,(a0)
                move.b  (a6)+,$3E(a0)
                move.b  (a6)+,$3F(a0)
                move.b  #1,$3A(a0)
                lea     $40(a0),a0
                dbf     d0,loc_11546

locret_11560:
                rts

sub_11562:
                moveq   #0,d7
                moveq   #0,d6
                move.b  (a6)+,d7
                move.b  (a6)+,d6
                movem.l d0/d4/a6,-(sp)
                bsr.w   sub_11B16
                movem.l (sp)+,d0/d4/a6
                dbf     d0,sub_11562
                rts

sub_1157C:
                movem.l d6-d7/a1,-(sp)
                cmpi.w  #$80,d7
                bge.s   loc_1158A
                addi.w  #$100,d7

loc_1158A:
                cmpi.w  #$180,d7
                blt.s   loc_11594
                subi.w  #$100,d7

loc_11594:
                lea     (unk_FFC800).w,a1
                move.l  #$FFFF,d4
                and.l   d4,d7
                and.l   d4,d6
                subi.w  #$80,d7
                subi.w  #$80,d6
                lsr.w   #3,d7
                lsr.w   #3,d6
                lsl.w   #5,d6
                adda.l  d7,a1
                adda.l  d6,a1
                move.b  (a1),d4
                andi.b  #$F,d4
                movem.l (sp)+,d6-d7/a1
                rts

sub_115C0:
                add.w   $30(a0),d7
                add.w   $24(a0),d6
                cmpi.w  #$80,d7
                bge.s   loc_115D2
                addi.w  #$100,d7

loc_115D2:
                cmpi.w  #$180,d7
                blt.s   loc_115DC
                subi.w  #$100,d7

loc_115DC:
                movem.l d6-d7,-(sp)
                lea     (unk_FFC800).w,a1
                move.l  #$FFFF,d4
                and.l   d4,d7
                and.l   d4,d6
                subi.w  #$80,d7
                subi.w  #$80,d6
                lsr.w   #3,d7
                lsr.w   #3,d6
                lsl.w   #5,d6
                adda.l  d7,a1
                adda.l  d6,a1
                move.b  (a1),d4
                movem.l (sp)+,d6-d7
                rts

sub_11608:
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_1162A
                subq.w  #1,d0

loc_11610:
                moveq   #0,d7
                moveq   #0,d6
                lea     (unk_FFC800).w,a0
                move.b  (a6)+,d7
                move.b  (a6)+,d6
                adda.l  d7,a0
                lsl.w   #5,d6
                adda.l  d6,a0
                bset    #7,(a0)
                dbf     d0,loc_11610

loc_1162A:
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   loc_11650
                subq.w  #1,d0

loc_11632:
                moveq   #0,d7
                moveq   #0,d6
                lea     (unk_FFC800).w,a0
                move.b  (a6)+,d7
                move.b  (a6)+,d6
                adda.l  d7,a0
                lsl.w   #5,d6
                adda.l  d6,a0
                bset    #7,(a0)
                bset    #6,(a0)
                dbf     d0,loc_11632

loc_11650:
                moveq   #0,d0
                move.b  (a6)+,d0
                beq.s   locret_11672
                subq.w  #1,d0

loc_11658:
                moveq   #0,d7
                moveq   #0,d6
                lea     (unk_FFC800).w,a0
                move.b  (a6)+,d7
                move.b  (a6)+,d6
                adda.l  d7,a0
                lsl.w   #5,d6
                adda.l  d6,a0
                bset    #5,(a0)
                dbf     d0,loc_11658

locret_11672:
                rts

sub_11674:
                andi.w  #$FF,d7
                andi.w  #$FF,d6
                lsl.w   #3,d7
                lsl.w   #3,d6
                addi.w  #$80,d7
                addi.w  #$80,d6
                rts

sub_1168A:
                tst.b   (byte_FFD2A5).w
                bne.s   locret_116BC
                lea     (byte_FFD266).w,a2
                lea     (byte_FFD882).w,a1
                moveq   #3,d0
                move    #4,ccr

loc_1169E:
                abcd    -(a2),-(a1)
                dbf     d0,loc_1169E
                bsr.w   sub_11DC2
                move.l  (dword_FFD87E).w,d0
                move.l  (dword_FFCC00).w,d1
                cmp.l   d0,d1
                bge.s   locret_116BC
                move.l  d0,(dword_FFCC00).w
                bsr.w   sub_11DD4

locret_116BC:
                rts

sub_116BE:
                moveq   #1,d1
                move.b  (dword_FFD888+2).w,d0
                addi.b  #0,d0
                abcd    d1,d0
                move.b  d0,(dword_FFD888+2).w
                cmpi.b  #$60,d0
                bcs.s   locret_116FE
                clr.b   (dword_FFD888+2).w
                move.b  (dword_FFD888+1).w,d0
                addi.b  #0,d0
                abcd    d1,d0
                move.b  d0,(dword_FFD888+1).w
                cmpi.b  #$60,d0
                bcs.s   locret_116FE
                clr.b   (dword_FFD888+1).w
                move.b  (dword_FFD888).w,d0
                addi.b  #0,d0
                abcd    d1,d0
                move.b  d0,(dword_FFD888).w

locret_116FE:
                rts

sub_11700:
                lea     (byte_FFD82E).w,a0
                move.w  (a0)+,(word_FFC47E).w
                move.w  (a0),(word_FFC3BE).w
                move.w  (a0)+,(word_FFC6BE).w
                move.w  (a0),(word_FFC3FE).w
                move.w  (a0),(word_FFC6FE).w
                move.w  (a0),(word_FFC43E).w
                move.w  (a0),(word_FFC73E).w
                rts

sub_11722:
                lea     (unk_FFC480).w,a3
                lea     (unk_FFDE00).w,a4
                bra.s   loc_11734

sub_1172C:
                lea     (unk_FFDE00).w,a3
                lea     (unk_FFC480).w,a4

loc_11734:
                move.w  #$7F,d0

loc_11738:
                move.l  (a3)+,(a4)+
                dbf     d0,loc_11738
                rts

sub_11740:
                moveq   #0,d0
                move.b  (byte_FFD280).w,d0
                addq.b  #1,d0
                andi.b  #$F,d0
                move.b  d0,(byte_FFD280).w
                lsr.w   #2,d0
                lsl.w   #1,d0
                move.w  word_1175C(pc,d0.w),(word_FFD884).w
                rts

word_1175C:     dc.w $8100, $8000, $FFFF, $8000
sub_11764:
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0

loc_1176A:
                cmp.b   d7,d0
                bcs.s   locret_11772
                sub.b   d7,d0
                bra.s   loc_1176A

locret_11772:
                rts

sub_11774:
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0

loc_1177A:
                cmp.b   d7,d0
                bls.s   locret_11782
                sub.b   d7,d0
                bra.s   loc_1177A

locret_11782:
                rts

sub_11784:
                lea     (word_FFF7E0).w,a0
                lea     (unk_FFF860).w,a1
                moveq   #$1F,d0

loc_1178E:
                move.l  (a0)+,(a1)+
                dbf     d0,loc_1178E
                move.w  #$FFC0,(word_FFFFAC).w

loc_1179A:
                move.w  (word_FFFFAC).w,d2
                addq.w  #2,d2
                beq.s   locret_117BE
                cmpi.w  #$40,d2
                ble.s   loc_117AA
                subq.w  #2,d2

loc_117AA:
                move.w  d2,(word_FFFFAC).w
                moveq   #$FFFFFFC0,d3
                jsr     unk_FFFBA8
                jsr     unk_FFFB0C
                jsr     unk_FFFB6C
                bra.s   loc_1179A

locret_117BE:
                rts

sub_117C0:
                tst.w   (a1)
                beq.w   loc_11874
                moveq   #0,d0
                moveq   #0,d1
                move.b  4(a0),d0
                cmpi.b  #$FF,d0
                beq.w   loc_11874
                move.b  4(a1),d1
                cmpi.b  #$FF,d1
                beq.w   loc_11874
                lsl.w   #3,d0
                lsl.w   #3,d1
                move.w  $20(a0),d3
                lea     word_11878(pc),a6
                add.w   (a6,d0.w),d3
                move.w  d3,d2
                addq.l  #2,a6
                add.w   (a6,d0.w),d3
                move.w  $20(a1),d5
                add.w   word_11878(pc,d1.w),d5
                move.w  d5,d4
                add.w   word_1187A(pc,d1.w),d5
                cmp.w   d2,d4
                blt.s   loc_11812
                cmp.w   d3,d4
                bgt.s   loc_11812
                bra.s   loc_1182E

loc_11812:
                cmp.w   d2,d5
                blt.s   loc_1181C
                cmp.w   d3,d5
                bgt.s   loc_1181C
                bra.s   loc_1182E

loc_1181C:
                cmp.w   d4,d2
                blt.s   loc_11826
                cmp.w   d5,d2
                bgt.s   loc_11826
                bra.s   loc_1182E

loc_11826:
                cmp.w   d4,d3
                blt.s   loc_11874
                cmp.w   d5,d3
                bgt.s   loc_11874

loc_1182E:
                move.w  $24(a0),d3
                add.w   word_1187C(pc,d0.w),d3
                move.w  d3,d2
                add.w   word_1187E(pc,d0.w),d3
                move.w  $24(a1),d5
                add.w   word_1187C(pc,d1.w),d5
                move.w  d5,d4
                add.w   word_1187E(pc,d1.w),d5
                cmp.w   d2,d4
                blt.s   loc_11854
                cmp.w   d3,d4
                bgt.s   loc_11854
                bra.s   loc_11870

loc_11854:
                cmp.w   d2,d5
                blt.s   loc_1185E
                cmp.w   d3,d5
                bgt.s   loc_1185E
                bra.s   loc_11870

loc_1185E:
                cmp.w   d4,d2
                blt.s   loc_11868
                cmp.w   d5,d2
                bgt.s   loc_11868
                bra.s   loc_11870

loc_11868:
                cmp.w   d4,d3
                blt.s   loc_11874
                cmp.w   d5,d3
                bgt.s   loc_11874

loc_11870:
                moveq   #1,d0
                rts

loc_11874:
                moveq   #0,d0
                rts

word_11878:     dc.w $FFFF
word_1187A:     dc.w 2
word_1187C:     dc.w $FFEE
word_1187E:     dc.w $12
                dc.l $FFFF0002
                dc.l $FFF00010
                dc.l $FFFC0008
                dc.l $FFF2000C
                dc.l $FFF9000E
                dc.l $FFF4000C
                dc.l $FFFC0008
                dc.l $FFFA0006
                dc.l $FFFF0002
                dc.l $FFEE0012
                dc.l $FFFE0004
                dc.l $FFF60004
                dc.l $FFFC0008
                dc.l $FFF90007
                dc.l $FFFF0002
                dc.l $FFFA0006
                dc.l $FFFC0008
                dc.l $FFF6000A
                dc.l $FFFC0008
                dc.l $FFFC0002
                dc.l $FFFC0008
                dc.l $30002
                dc.l $FFFC0002
                dc.l $FFFC0008
                dc.l $40002
                dc.l $FFFC0008
                dc.l $FFFF0002
                dc.l $FFFD0006
                dc.l $FFFE0004
                dc.l 8
                dc.l $FFF80010
                dc.l $FFF00010
                dc.l $FFF80010
                dc.l $FFF00002
                dc.l $FFFF0002
                dc.l $FFEE000E
sub_11910:
                lsl.w   #1,d4
                move.w  word_1191C(pc,d4.w),d4
                bsr.w   sub_10F3E
                rts

word_1191C:     dc.w $220D, $2206, $2207, $2208, $2209, $220A, $220B, $220C
                dc.w $220D, $220E, $220F, $2210, $2211, $2212, $2213, $2214
sub_1193C:
                lsl.w   #1,d4
                movea.l (dword_FFD800).w,a1
                move.w  (a1,d4.w),d4
                bsr.w   sub_10F3E
                rts

sub_1194C:
                moveq   #0,d5
                move.w  #$E000,d5
                moveq   #7,d0

loc_11954:
                move.w  d0,-(sp)
                bsr.s   sub_11962
                move.w  (sp)+,d0
                addq.w  #8,d5
                dbf     d0,loc_11954
                rts

sub_11962:
                lea     (dword_FFD808).w,a6
                movea.l (a6),a6
                moveq   #3,d7
                moveq   #1,d6
                move.l  d5,-(sp)
                bsr.w   sub_10F6E
                move.l  (sp)+,d5
                rts

sub_11976:
                moveq   #0,d5
                move.w  #$E680,d5
                moveq   #7,d0

loc_1197E:
                move.w  d0,-(sp)
                bsr.s   sub_1198C
                move.w  (sp)+,d0
                addq.w  #8,d5
                dbf     d0,loc_1197E
                rts

sub_1198C:
                lea     (dword_FFD80C).w,a6
                movea.l (a6),a6
                moveq   #3,d7
                moveq   #1,d6
                move.l  d5,-(sp)
                bsr.w   sub_10F6E
                move.l  (sp)+,d5
                rts

sub_119A0:
                move.l  #$60800003,(VDP_CTRL).l
                movea.l (dword_FFD804).w,a0
                move.w  (a0),d1
                move.w  #$2FF,d0

loc_119B4:
                move.w  d1,(VDP_DATA).l
                dbf     d0,loc_119B4
                rts

sub_119C0:
                lea     (unk_FFC840).w,a0
                moveq   #0,d1
                moveq   #0,d2
                moveq   #0,d6
                move.w  #$E080,d6
                move.w  d6,d5
                move.w  #$2FF,d0

loc_119D4:
                moveq   #0,d4
                moveq   #0,d5
                move.w  d6,d5
                tst.b   (a0)
                beq.w   loc_119F4
                andi.w  #$1F,d2
                beq.w   loc_11A34
                cmpi.w  #$1F,d2
                beq.w   loc_11A66
                bra.w   loc_11A98

loc_119F4:
                andi.w  #$1F,d2
                beq.w   loc_11ACA
                bra.w   loc_11AF0

loc_11A00:
                addq.l  #1,a0
                addq.w  #1,d1
                move.w  d1,d2
                addq.w  #2,d6
                dbf     d0,loc_119D4
                lea     (unk_FFC840).w,a0
                moveq   #0,d5
                move.w  #$E080,d5
                moveq   #$1F,d0

loc_11A18:
                tst.b   (a0)+
                bne.s   loc_11A2C
                move.w  #3,d4
                movem.l d5/a0,-(sp)
                bsr.w   sub_1193C
                movem.l (sp)+,d5/a0

loc_11A2C:
                addq.w  #2,d5
                dbf     d0,loc_11A18
                rts

loc_11A34:
                tst.b   -$20(a0)
                beq.s   loc_11A3E
                bset    #0,d4

loc_11A3E:
                tst.b   $20(a0)
                beq.s   loc_11A48
                bset    #1,d4

loc_11A48:
                tst.b   $1F(a0)
                beq.s   loc_11A52
                bset    #2,d4

loc_11A52:
                tst.b   1(a0)
                beq.s   loc_11A5C
                bset    #3,d4

loc_11A5C:
                move.b  d4,(a0)
                bsr.w   sub_11910
                bra.w   loc_11A00

loc_11A66:
                tst.b   -$20(a0)
                beq.s   loc_11A70
                bset    #0,d4

loc_11A70:
                tst.b   $20(a0)
                beq.s   loc_11A7A
                bset    #1,d4

loc_11A7A:
                tst.b   -1(a0)
                beq.s   loc_11A84
                bset    #2,d4

loc_11A84:
                tst.b   -$1F(a0)
                beq.s   loc_11A8E
                bset    #3,d4

loc_11A8E:
                move.b  d4,(a0)
                bsr.w   sub_11910
                bra.w   loc_11A00

loc_11A98:
                tst.b   -$20(a0)
                beq.s   loc_11AA2
                bset    #0,d4

loc_11AA2:
                tst.b   $20(a0)
                beq.s   loc_11AAC
                bset    #1,d4

loc_11AAC:
                tst.b   -1(a0)
                beq.s   loc_11AB6
                bset    #2,d4

loc_11AB6:
                tst.b   1(a0)
                beq.s   loc_11AC0
                bset    #3,d4

loc_11AC0:
                move.b  d4,(a0)
                bsr.w   sub_11910
                bra.w   loc_11A00

loc_11ACA:
                tst.b   -$20(a0)
                beq.s   loc_11AD4
                bset    #0,d4

loc_11AD4:
                tst.b   -1(a0)
                beq.s   loc_11ADE
                bset    #1,d4

loc_11ADE:
                tst.b   $1F(a0)
                beq.s   loc_11AE8
                bset    #2,d4

loc_11AE8:
                bsr.w   sub_1193C
                bra.w   loc_11A00

loc_11AF0:
                tst.b   -$20(a0)
                beq.s   loc_11AFA
                bset    #0,d4

loc_11AFA:
                tst.b   -$21(a0)
                beq.s   loc_11B04
                bset    #1,d4

loc_11B04:
                tst.b   -1(a0)
                beq.s   loc_11B0E
                bset    #2,d4

loc_11B0E:
                bsr.w   sub_1193C
                bra.w   loc_11A00

sub_11B16:
                moveq   #0,d5
                move.w  #$C000,d5
                bsr.w   sub_10F24
                lsl.w   #2,d4
                move.w  word_11B3C(pc,d4.w),d7
                move.w  word_11B3E(pc,d4.w),d6
                lsr.w   #1,d4
                moveq   #$FFFFFFFF,d2
                move.w  word_11B54(pc,d4.w),d2
                movea.l d2,a6
                movea.l (a6),a6
                bsr.w   sub_10F70
                rts

word_11B3C:     dc.w 2
word_11B3E:     dc.w 2, 1, 1, 1, 2, 1, 2, 4, 2, 3, 3
word_11B54:     dc.w $D81C, $D820, $D824, $D810, $D814, $D818
sub_11B60:
                moveq   #0,d7
                moveq   #0,d6
                moveq   #0,d5
                move.b  (byte_FFD82E).w,d7
                move.b  (byte_FFD82F).w,d6
                move.w  #$E000,d5
                bsr.w   sub_10F24
                moveq   #2,d7
                moveq   #2,d6
                lea     (word_1A4B4).l,a6
                bsr.w   sub_10F70
                rts

sub_11B86:
                lea     (byte_FFD82E).w,a0
                moveq   #0,d7
                moveq   #0,d6
                moveq   #0,d5
                move.b  0.w(a0),d7
                move.b  1(a0),d6
                subq.b  #1,d6
                move.w  #$E000,d5
                bsr.w   sub_10F24
                moveq   #2,d7
                moveq   #0,d6
                lea     (word_1A262).l,a6
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11BBC
                lea     (word_11C98).l,a6

loc_11BBC:
                bsr.w   sub_10F70
                rts

sub_11BC2:
                moveq   #4,d0
                moveq   #5,d3

loc_11BC6:
                move.w  word_11BDC(pc,d0.w),d1
                move.w  word_11BDE(pc,d0.w),d4
                lsr.w   #1,d0
                moveq   #$FFFFFFFF,d2
                move.w  word_11BF8(pc,d0.w),d2
                lsl.w   #1,d0
                movea.l d2,a0
                bra.s   loc_11C06
word_11BDC:     dc.w 0
word_11BDE:     dc.w 0, 0, 0, 1, 1, 0, 2, $13, 3, 7, 4, 7, 5
word_11BF8:     dc.w 0, $D82E, $D830, $D834, $D836, $D85E, $D86E

loc_11C06:
                tst.b   2(a0)
                beq.s   loc_11C24
                moveq   #0,d7
                moveq   #0,d6
                move.b  0.w(a0),d7
                move.b  1(a0),d6
                movem.w d0-d4/a0,-(sp)
                bsr.w   sub_11B16
                movem.w (sp)+,d0-d4/a0

loc_11C24:
                addq.l  #4,a0
                dbf     d1,loc_11C06
                addq.w  #4,d0
                dbf     d3,loc_11BC6
                tst.b   (byte_FFD830).w
                beq.s   locret_11C3A
                bsr.w   sub_11B86

locret_11C3A:
                rts

sub_11C3C:
                lea     (unk_FFD258).w,a0
                lea     byte_11C74(pc),a1
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11C52
                lea     byte_11C86(pc),a1

loc_11C52:
                moveq   #0,d7
                moveq   #0,d6
                moveq   #0,d5
                move.b  (byte_FFD82E).w,d7
                move.b  (byte_FFD82F).w,d6
                subq.b  #1,d6
                move.w  #$E000,d5
                bsr.w   sub_10F24
                moveq   #2,d7
                moveq   #0,d6
                bsr.w   sub_1137A
                rts

byte_11C74:     dc.b 4
                dc.b 4
                dc.l word_1A262
                dc.l word_1A26E
                dc.l word_1A268
                dc.l word_1A26E
byte_11C86:     dc.b 4
                dc.b 4
                dc.l word_11C98
                dc.l word_11CA4
                dc.l word_11C9E
                dc.l word_11CA4
word_11C98:     dc.w $693, $694, $695
word_11C9E:     dc.w $696, $697, $698
word_11CA4:     dc.w $699, $69A, $69B
sub_11CAA:
                lea     byte_11CB8(pc),a1
                bsr.w   sub_11D38
                bsr.w   sub_116BE
                rts

byte_11CB8:     dc.b 4
                dc.b $F
                dc.l word_1A490
                dc.l word_1A46C
                dc.l word_1A47E
                dc.l word_1A490
sub_11CCA:
                lea     byte_11CD4(pc),a1
                jmp     sub_11D38

byte_11CD4:     dc.b 4
                dc.b 2
                dc.l word_1A274
                dc.l word_1A490
                dc.l word_1A47E
                dc.l word_1A46C
sub_11CE6:
                lea     byte_11CF0(pc),a1
                jmp     sub_11D38

byte_11CF0:     dc.b 5
                dc.b 2
                dc.l word_11D06
                dc.l word_1A46C
                dc.l word_1A47E
                dc.l word_1A490
                dc.l word_1A4A2
word_11D06:     dc.w 0, 0, 0, 0, 0, 0, 0, 0, 0
sub_11D18:
                lea     byte_11D22(pc),a1
                jmp     sub_11D38

byte_11D22:     dc.b 5
                dc.b 1
                dc.l word_1A274
                dc.l word_1A4A2
                dc.l word_1A490
                dc.l word_1A47E
                dc.l word_1A46C
sub_11D38:
                move.b  #1,(byte_FFD27B).w
                lea     (unk_FFD254).w,a0
                clr.l   (a0)
                moveq   #0,d7
                moveq   #0,d6
                moveq   #0,d5
                move.b  (byte_FFD82E).w,d7
                move.b  (byte_FFD82F).w,d6
                move.w  #$C000,d5
                bsr.w   sub_10F24
                moveq   #2,d7
                moveq   #2,d6

loc_11D5E:
                movem.l d5-d7/a0-a4,-(sp)
                bsr.w   sub_1137A
                tst.b   2(a0)
                bne.s   loc_11D7E
                bsr.w   sub_111E2
                bsr.w   sub_116BE
                jsr     unk_FFFB6C
                movem.l (sp)+,d5-d7/a0-a4
                bra.s   loc_11D5E

loc_11D7E:
                clr.b   (byte_FFD27B).w
                movem.l (sp)+,d5-d7/a0-a4
                rts

sub_11D88:
                moveq   #0,d0
                move.b  (byte_FFD882).w,d0
                beq.s   locret_11DC0
                subq.w  #1,d0
                beq.s   locret_11DC0
                subq.w  #1,d0
                move.l  #$46840003,(VDP_CTRL).l
                btst    #6,(IO_PCBVER+1).l
                beq.s   loc_11DB4
                move.l  #$47440003,(VDP_CTRL).l

loc_11DB4:
                move.w  #$4350,(VDP_DATA).l
                dbf     d0,loc_11DB4

locret_11DC0:
                rts

sub_11DC2:
                lea     (dword_FFD87E).w,a6
                moveq   #0,d5
                move.w  #$C04A,d5
                moveq   #3,d0
                bsr.w   sub_10FF4
                rts

sub_11DD4:
                lea     (dword_FFCC00).w,a6
                moveq   #0,d5
                move.w  #$C068,d5
                moveq   #3,d0
                bsr.w   sub_10FF4
                rts

sub_11DE6:
                lea     (word_FFD82C).w,a6
                moveq   #0,d5
                move.w  #$C6BA,d5
                btst    #6,(IO_PCBVER+1).l
                beq.s   loc_11DFE
                move.w  #$C77A,d5

loc_11DFE:
                moveq   #0,d0
                bsr.w   sub_10FF4
                rts

sub_11E06:
                lea     byte_11E46(pc),a6
                btst    #6,(IO_PCBVER+1).l
                beq.s   loc_11E18
                lea     byte_11E4C(pc),a6

loc_11E18:
                bsr.w   sub_10FAA

sub_11E1C:
                lea     (word_1A4CA).l,a6
                moveq   #1,d7
                moveq   #0,d6
                moveq   #0,d5
                move.w  #$C048,d5
                bsr.w   sub_10F6E
                lea     (word_1A4D2).l,a6
                moveq   #2,d7
                moveq   #0,d6
                moveq   #0,d5
                move.w  #$C064,d5
                bsr.w   sub_10F6E
                rts

byte_11E46:     dc.b $C6, $B4
aRd:            dc.b "RD.",0
byte_11E4C:     dc.b $C7, $74
aRd_0:          dc.b "RD.",0
sub_11E52:
                lea     (byte_FFD266).w,a6
                moveq   #0,d5
                move.w  #$C160,d5
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11E68
                subq.w  #4,d5

loc_11E68:
                moveq   #0,d0
                bsr.w   sub_10FF4
                lea     (byte_FFD267).w,a6
                moveq   #0,d5
                move.w  #$C16C,d5
                moveq   #0,d0
                bsr.w   sub_10FF4
                tst.b   (byte_FFD266).w
                bne.s   locret_11E94
                lea     (dword_FFD268).w,a6
                moveq   #0,d5
                move.w  #$C260,d5
                moveq   #3,d0
                bsr.w   sub_10FF4

locret_11E94:
                rts

sub_11E96:
                lea     byte_11F04(pc),a6
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11EA8
                lea     byte_11F40(pc),a6

loc_11EA8:
                bsr.w   sub_10FAA
                lea     byte_11F10(pc),a6
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11EBE
                lea     byte_11F4E(pc),a6

loc_11EBE:
                bsr.w   sub_10FAA
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11ED4
                lea     byte_11F56(pc),a6
                bsr.w   sub_10FAA

loc_11ED4:
                lea     byte_11F1E(pc),a6
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11EE6
                lea     byte_11F5E(pc),a6

loc_11EE6:
                bsr.w   sub_10FAA
                tst.b   (byte_FFD266).w
                bne.s   loc_11EFA
                lea     byte_11F2C(pc),a6
                bsr.w   sub_10FAA
                bra.s   locret_11F02

loc_11EFA:
                lea     byte_11F34(pc),a6
                bsr.w   sub_10FAA

locret_11F02:
                rts

byte_11F04:     dc.b $C1, $4A
aGameTime:      dc.b "GAME TIME",0
byte_11F10:     dc.b $C1, $64
aMinSec:        dc.b "MIN.  SEC.",0
                dc.b 0
byte_11F1E:     dc.b $C2, $4A
aTimeBonus:     dc.b "TIME BONUS",0
                dc.b 0
byte_11F2C:     dc.b $C2, $72
aPts:           dc.b "PTS.",0
                dc.b 0
byte_11F34:     dc.b $C2, $68
aNoBonus:       dc.b "NO BONUS",0
                dc.b 0
byte_11F40:     dc.b $C1, $48
aRoundTime:     dc.b "ROUND TIME",0
                dc.b 0
byte_11F4E:     dc.b $C1, $62
aMin:           dc.b "MIN.",0
                dc.b 0
byte_11F56:     dc.b $C1, $72
aSec:           dc.b "SEC.",0
                dc.b 0
byte_11F5E:     dc.b $C2, $48
aTimeBonus_0:   dc.b "TIME BONUS",0
                dc.b 0
sub_11F6C:
                tst.b   (byte_FFD28E).w
                beq.s   locret_11FAA
                lea     (byte_FFD28F).w,a6
                moveq   #0,d5
                move.w  #$C248,d5
                moveq   #0,d0
                bsr.w   sub_10FF4
                lea     ((dword_FFD290+2)).w,a6
                moveq   #0,d5
                move.w  #$C266,d5
                moveq   #1,d0
                bsr.w   sub_10FF4
                cmpi.b  #$14,(byte_FFD28E).w
                bne.s   locret_11FAA
                lea     byte_11FAC(pc),a6
                moveq   #0,d5
                move.w  #$C390,d5
                moveq   #3,d0
                bsr.w   sub_10FF4

locret_11FAA:
                rts

byte_11FAC:     dc.b 0, 1, 0, 0
sub_11FB0:
                bsr.w   sub_100D4
                move.w  #$740,d0
                jsr     unk_FFFB8A
                lea     (FlickyLogoTiles).l,a0
                jsr     j_Nem_Decomp
                clr.b   (byte_FFD88E).w
                bsr.w   loc_10126
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                lea     word_1210C(pc),a0
                lea     (unk_FFF840).w,a1
                moveq   #3,d0

loc_11FE2:
                move.l  (a0)+,(a1)+
                dbf     d0,loc_11FE2
                moveq   #5,d0
                lea     off_12086(pc),a0
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_11FFC
                lea     off_1209E(pc),a0

loc_11FFC:
                movea.l (a0)+,a6
                bsr.w   sub_10FAA
                dbf     d0,loc_11FFC
                move.b  #3,(byte_FFD882).w
                move.w  #$101,(word_FFD82C).w
                move.b  #1,(byte_FFD88F).w
                lea     (word_FFC000).w,a0
                moveq   #0,d1
                moveq   #3,d0

loc_12020:
                move.w  #$40,(a0)
                move.w  d1,$38(a0)
                lea     $40(a0),a0
                addq.w  #1,d1
                dbf     d0,loc_12020
                move.w  #$44,(a0)
                lea     (unk_FFC140).w,a0
                moveq   #0,d1
                moveq   #5,d0

loc_1203E:
                move.w  #$48,(a0)
                move.w  d1,$38(a0)
                lea     $40(a0),a0
                addq.w  #1,d1
                dbf     d0,loc_1203E
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_12062
                lea     byte_1211C(pc),a6
                bsr.w   sub_10FC0

loc_12062:
                bsr.w   sub_11E1C
                bsr.w   sub_11DC2
                bsr.w   sub_11DD4
                bsr.w   sub_111E2
                clr.w   (word_FFFF92).w
                move.b  #$85,d0
                jsr     unk_FFFB66
                jsr     unk_FFFB6C
                jmp     unk_FFFB6C

off_12086:      dc.l byte_120B6
                dc.l byte_120BE
                dc.l byte_120C8
                dc.l byte_120D2
                dc.l byte_120DE
                dc.l byte_120E6
off_1209E:      dc.l byte_120B6
                dc.l byte_120BE
                dc.l byte_120F4
                dc.l byte_120FC
                dc.l byte_12104
                dc.l byte_120E6
byte_120B6:     dc.b $C2, $9C
aCast:          dc.b "CAST",0
                dc.b 0
byte_120BE:     dc.b $C3, $10
aFlicky:        dc.b "FLICKY",0
                dc.b 0
byte_120C8:     dc.b $C3, $28
aPiopio:        dc.b "PIOPIO",0
                dc.b 0
byte_120D2:     dc.b $C3, $D0
aNyannyan:      dc.b "NYANNYAN",0
                dc.b 0
byte_120DE:     dc.b $C3, $E8
aChoro:         dc.b "CHORO",0
byte_120E6:     dc.b $C6, $54
aSega1991:      dc.b $27," SEGA 1991",0
byte_120F4:     dc.b $C3, $28
aChirp:         dc.b "CHIRP",0
byte_120FC:     dc.b $C3, $D0
aTiger:         dc.b "TIGER",0
byte_12104:     dc.b $C3, $E8
aIggy:          dc.b "IGGY",0
                dc.b 0
word_1210C:     dc.w 0, $EEE, $EAE, $C6E, $A4E, $A2E, $60A, 0
byte_1211C:     dc.b $C0, $EE
aTm:            dc.b "TM",0
                dc.b 0
sub_12122:
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_12146
                bsr.w   sub_11784
                move.b  #$E0,d0
                bsr.w   sub_10D34
                move.b  #1,(byte_FFD88E).w
                bsr.w   loc_10126
                move.w  #8,(word_FFFFC0).w

loc_12146:
                cmpi.w  #$400,(word_FFFF92).w
                bcs.s   loc_1216A
                bsr.w   sub_11784
                move.b  #$E0,d0
                bsr.w   sub_10D34
                move.b  #1,(byte_FFD88E).w
                bsr.w   loc_10126
                move.w  #$38,(word_FFFFC0).w

loc_1216A:
                bsr.w   sub_111E2
                jmp     unk_FFFB6C

sub_12172:
                bset    #7,(a0)
                bne.s   loc_1219E
                bset    #7,2(a0)
                move.w  $38(a0),d0
                lsl.w   #1,d0
                move.w  word_121B4(pc,d0.w),6(a0)
                lsl.w   #1,d0
                move.l  off_121A4(pc,d0.w),8(a0)
                move.w  word_121BC(pc,d0.w),$20(a0)
                move.w  word_121BE(pc,d0.w),$24(a0)

loc_1219E:
                bsr.w   sub_11126
                rts

off_121A4:      dc.l off_144AC
                dc.l off_14E12
                dc.l off_154AE
                dc.l off_162BC
word_121B4:     dc.w 0, 4, 4, 0
word_121BC:     dc.w $B0
word_121BE:     dc.w $F0, $110, $EC, $B0, $108, $110, $100
sub_121CC:
                bset    #7,(a0)
                bne.s   loc_121E6
                move.l  #word_1ACDC,$C(a0)
                move.w  #$F0,$20(a0)
                move.w  #$120,$24(a0)

loc_121E6:
                move.w  $3C(a0),d0
                andi.w  #$7C,d0
                jsr     loc_121F4(pc,d0.w)
                rts

loc_121F4:
                bra.w   sub_121FC
                bra.w   sub_1221E

sub_121FC:
                bset    #7,$3C(a0)
                bne.s   loc_12210
                bclr    #1,2(a0)
                move.w  #$3C,$3A(a0)

loc_12210:
                subq.w  #1,$3A(a0)
                bne.s   locret_1221C
                move.w  #4,$3C(a0)

locret_1221C:
                rts

sub_1221E:
                bset    #7,$3C(a0)
                bne.s   loc_12232
                bset    #1,2(a0)
                move.w  #$14,$3A(a0)

loc_12232:
                subq.w  #1,$3A(a0)
                bne.s   locret_1223C
                clr.w   $3C(a0)

locret_1223C:
                rts

sub_1223E:
                bset    #7,(a0)
                bne.s   locret_1225C
                move.w  $38(a0),d0
                lsl.w   #2,d0
                move.l  off_1225E(pc,d0.w),$C(a0)
                move.w  word_12276(pc,d0.w),$20(a0)
                move.w  word_12278(pc,d0.w),$24(a0)

locret_1225C:
                rts

off_1225E:      dc.l word_1AD52
                dc.l word_1AD5A
                dc.l word_1AD62
                dc.l word_1AD6A
                dc.l word_1AD72
                dc.l word_1AD7A
word_12276:     dc.w $D0
word_12278:     dc.w $C0, $E5, $C0, $F7, $C0, $107, $C0, $11C, $C0, $133, $C0
sub_1228E:
                moveq   #7,d1

loc_12290:
                jsr     unk_FFFB6C
                dbf     d1,loc_12290
                bsr.w   sub_100D4
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                clr.l   (dword_FFD87E).w
                clr.b   (byte_FFD887).w
                bsr.w   sub_1268E
                bsr.w   sub_12824
                bsr.w   sub_1230A
                lea     (word_FFC000).w,a0
                moveq   #0,d1
                moveq   #$13,d0

loc_122C2:
                move.w  #$4C,(a0)
                move.w  d1,$38(a0)
                lea     $40(a0),a0
                addq.w  #1,d1
                dbf     d0,loc_122C2
                bsr.w   sub_111E2
                jsr     unk_FFFB6C
                jmp     unk_FFFB6C

sub_122E0:
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_12306
                move.w  #$18,(word_FFFFC0).w
                move.b  (word_FFFF8E).w,d0
                bclr    #7,d0
                cmpi.b  #$61,d0
                bne.s   loc_12302
                move.w  #$10,(word_FFFFC0).w

loc_12302:
                bsr.w   sub_11784

loc_12306:
                jmp     unk_FFFB6C

sub_1230A:
                moveq   #5,d0
                lea     off_12384(pc),a0
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_1231E
                lea     off_123F0(pc),a0

loc_1231E:
                movea.l (a0)+,a6
                bsr.w   sub_10FC0
                dbf     d0,loc_1231E
                lea     (byte_FFD82E).w,a0
                moveq   #$E,d7
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_1233A
                moveq   #$F,d7

loc_1233A:
                moveq   #6,d6
                moveq   #0,d4
                move.b  d7,(a0)
                move.b  d6,1(a0)
                bsr.w   sub_11B16
                bsr.w   sub_11B86
                moveq   #5,d7
                moveq   #$17,d6
                moveq   #0,d4
                move.b  d7,(a0)
                move.b  d6,1(a0)
                bsr.w   sub_11B16
                bsr.w   sub_11B86
                bsr.w   sub_11976
                bsr.w   sub_1194C
                lea     (VDP_DATA).l,a0
                move.l  #$648A0003,(VDP_CTRL).l
                moveq   #$15,d0

loc_1237A:
                move.w  #$220D,(a0)
                dbf     d0,loc_1237A
                rts

off_12384:      dc.l byte_1239C
                dc.l byte_123A4
                dc.l byte_123AE
                dc.l byte_123B2
                dc.l byte_123C2
                dc.l byte_123DA
byte_1239C:     dc.b $C0, $DA
                dc.b $60, $6E, $A7, $65, $6F, 0
byte_123A4:     dc.b $C2, 8
                dc.b $8C, $6E, $62, $6A, $6B, $72, 0, 0
byte_123AE:     dc.b $C2, $18
                dc.b $8C, 0
byte_123B2:     dc.b $C2, $24
                dc.b $7E, $A4, $71, $89, $72, $61, $93, $72
                dc.b $67, $A1, $6A, $61, $12, 0
byte_123C2:     dc.b $C3, 6
                dc.b $FA, $BF, $DD, $8C, $64, $6C, $73, $11
                dc.b $ED, $E4, $DD, $FD, $20, $26, $20, $BB
                dc.b $E6, $E3, $C3, $12, 0, 0
byte_123DA:     dc.b $C5, $94
                dc.b $7E, $73, $81, $72, $71, $89, $72, $65
                dc.b $63, $88, $73, $11, $69, $62, $73, $67
                dc.b $72, $8D, $21, 0
off_123F0:      dc.l byte_12408
                dc.l byte_1241A
                dc.l byte_12422
                dc.l byte_1242A
                dc.l byte_1243A
                dc.l byte_1245C
byte_12408:     dc.b $C0, $D2
aMakeYourMove:  dc.b "MAKE YOUR MOVE",0
                dc.b 0
byte_1241A:     dc.b $C2, 2
aHelp:          dc.b "HELP",0
                dc.b 0
byte_12422:     dc.b $C2, $E
aGuide:         dc.b "GUIDE",0
byte_1242A:     dc.b $C2, $26
aToTheDoor:     dc.b "TO THE DOOR!",0
                dc.b 0
byte_1243A:     dc.b $C2, $C2
aPressButtonToJ:dc.b "PRESS BUTTON TO JUMP AND SHOOT",0
                dc.b 0
byte_1245C:     dc.b $C5, $92
aRackUpASuperSc:dc.b "RACK UP A SUPER SCORE!",0
                dc.b 0
sub_12476:
                bset    #7,(a0)
                bne.s   locret_124B8
                move.w  $38(a0),d0
                bclr    #7,2(a0)
                move.b  byte_124BA(pc,d0.w),d1
                beq.s   loc_12492
                bset    #7,2(a0)

loc_12492:
                lsl.w   #2,d0
                move.l  off_124CE(pc,d0.w),$C(a0)
                lea     word_1251E(pc),a1
                btst    #7,(IO_PCBVER+1).l
                beq.s   loc_124AC
                lea     word_1256E(pc),a1

loc_124AC:
                move.w  (a1,d0.w),$20(a0)
                move.w  2(a1,d0.w),$24(a0)

locret_124B8:
                rts

byte_124BA:     dc.b 0, 0, 1, 0, 1, 1, 1, 0, 0, 0
                dc.b 0, 0, 0, 1, 1, 1, 1, 1, 1, 1
off_124CE:      dc.l word_1A848
                dc.l word_1A7F0
                dc.l word_1A800
                dc.l word_1A7D8
                dc.l word_1A7C8
                dc.l word_1A7D8
                dc.l word_1A7F0
                dc.l word_1A830
                dc.l word_1A898
                dc.l word_1A7B8
                dc.l word_1A8D0
                dc.l word_1A528
                dc.l word_1A99A
                dc.l byte_1A8A8
                dc.l word_1A7E8
                dc.l word_1A848
                dc.l word_1A850
                dc.l word_1A7F8
                dc.l word_1A7F0
                dc.l word_1A858
word_1251E:     dc.w $B4, $A0, $C0, $A0, $CC, $A0, $D8, $A0, $120, $A0
                dc.w $12C, $A0, $138, $A0, $144, $A0, $98, $C8, $D8, $C8
                dc.w $D0, $100, $118, $100, $118, $110, $C0, $150, $C8, $150
                dc.w $D0, $150, $D8, $150, $E0, $150, $E8, $150, $F0, $150
word_1256E:     dc.w $94, $A0, $A0, $A0, $AC, $A0, $B8, $A0, $148, $A0
                dc.w $154, $A0, $160, $A0, $16C, $A0, $B0, $C8, $E8, $C8
                dc.w $D0, $100, $118, $100, $118, $110, $C0, $150, $C8, $150
                dc.w $D0, $150, $D8, $150, $E0, $150, $E8, $150, $F0, $150
sub_125BE:
                bsr.w   sub_100D4
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                lea     byte_125E8(pc),a6
                bsr.w   sub_10FAA
                move.b  #3,(byte_FFD882).w
                move.b  #1,(byte_FFD29A).w
                jsr     unk_FFFB6C
                jmp     unk_FFFB6C

byte_125E8:     dc.b $C3, $54
aRound:         dc.b "ROUND ",0
                dc.b 0
sub_125F2:
                move.b  (word_FFD82C).w,d1
                move.b  #1,d2
                move.b  (word_FFFF8E+1).w,d0
                btst    #0,d0
                beq.s   loc_1261A
                cmpi.b  #$36,d1
                beq.s   loc_12642
                addi.b  #0,d0
                abcd    d2,d1
                addq.b  #1,(word_FFD82C+1).w
                move.b  d1,(word_FFD82C).w
                bra.s   loc_12642

loc_1261A:
                btst    #1,d0
                beq.s   loc_12636
                cmpi.b  #1,d1
                beq.s   loc_12642
                addi.b  #0,d0
                sbcd    d2,d1
                subq.b  #1,(word_FFD82C+1).w
                move.b  d1,(word_FFD82C).w
                bra.s   loc_12642

loc_12636:
                btst    #7,d0
                beq.s   loc_12642
                move.w  #$18,(word_FFFFC0).w

loc_12642:
                lea     (word_FFD82C).w,a6
                moveq   #0,d5
                move.w  #$C360,d5
                moveq   #0,d0
                bsr.w   sub_10FF4
                jmp     unk_FFFB6C

sub_12656:
                bsr.w   sub_100D4
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                clr.l   (dword_FFD888).w
                clr.b   (byte_FFD88D).w
                rts

sub_1266E:
                move.w  #$20,(word_FFFFC0).w
                move.b  (word_FFD82C+1).w,d0
                andi.b  #3,d0
                cmpi.b  #3,d0
                bne.s   loc_12688
                move.w  #$28,(word_FFFFC0).w

loc_12688:
                jsr     unk_FFFB6C
                rts

sub_1268E:
                moveq   #$18,d7
                bsr.w   sub_11764
                lsr.w   #2,d0
                lsl.w   #2,d0
                lea     off_12728(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD804).w
                lea     off_12740(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD800).w
                lea     off_12758(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD808).w
                lea     off_12770(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD80C).w
                lea     off_127B8(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD814).w
                lea     off_127D0(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD818).w
                moveq   #$20,d7
                bsr.w   sub_11774
                subq.b  #1,d0
                lsr.w   #2,d0
                lsl.w   #2,d0
                lea     off_12788(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD810).w
                moveq   #$F,d7
                bsr.w   sub_11774
                subq.b  #1,d0
                lsl.w   #2,d0
                lea     off_127E8(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD828).w
                move.l  #word_1A274,(dword_FFD81C).w
                move.l  #word_1A292,(dword_FFD820).w
                move.l  #word_1A286,(dword_FFD824).w
                rts

off_12728:      dc.l byte_1A196
                dc.l byte_1A198
                dc.l byte_1A19A
                dc.l byte_1A19C
                dc.l byte_1A19E
                dc.l byte_1A1A0
off_12740:      dc.l word_1A2D6
                dc.l word_1A2E6
                dc.l word_1A2F6
                dc.l word_1A306
                dc.l word_1A316
                dc.l word_1A326
off_12758:      dc.l word_1A1A2
                dc.l word_1A1B2
                dc.l word_1A1C2
                dc.l word_1A1D2
                dc.l word_1A1E2
                dc.l word_1A1F2
off_12770:      dc.l word_1A202
                dc.l word_1A212
                dc.l word_1A222
                dc.l word_1A232
                dc.l word_1A242
                dc.l word_1A252
off_12788:      dc.l word_1A29A
                dc.l word_1A2A6
                dc.l word_1A2B2
                dc.l word_1A2BE
                dc.l word_1A2CA
                dc.l word_1A29A
                dc.l word_1A2A6
                dc.l word_1A2B2
                dc.l word_1A29A
                dc.l word_1A2A6
                dc.l word_1A2B2
                dc.l word_1A29A
off_127B8:      dc.l word_1A336
                dc.l word_1A336
                dc.l word_1A374
                dc.l word_1A3D2
                dc.l word_1A44E
                dc.l word_1A410
off_127D0:      dc.l word_1A354
                dc.l word_1A354
                dc.l word_1A392
                dc.l word_1A3B2
                dc.l word_1A3F0
                dc.l word_1A42E
off_127E8:      dc.l word_1A4E8
                dc.l word_1A518
                dc.l word_1A548
                dc.l word_1A578
                dc.l word_1A5A8
                dc.l word_1A5D8
                dc.l word_1A608
                dc.l word_1A638
                dc.l word_1A668
                dc.l word_1A698
                dc.l word_1A6C8
                dc.l word_1A6F8
                dc.l word_1A728
                dc.l word_1A758
                dc.l word_1A788
sub_12824:
                moveq   #$30,d7
                bsr.w   sub_11764
                lsr.w   #2,d0
                lsl.w   #1,d0
                lea     off_12866(pc),a0
                moveq   #$FFFFFFFF,d1
                move.w  (a0,d0.w),d1
                movea.l d1,a0
                lea     (unk_FFF800).w,a1
                moveq   #7,d0

loc_12840:
                move.l  (a0)+,(a1)+
                dbf     d0,loc_12840
                moveq   #$F,d7
                bsr.w   sub_11774
                subq.w  #1,d0
                lsl.w   #1,d0
                lea     off_129FE(pc),a0
                lea     (unk_FFF858).w,a1
                moveq   #$FFFFFFFF,d1
                move.w  (a0,d0.w),d1
                movea.l d1,a0
                move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                rts

off_12866:      dc.w word_1287E-sub_10000
                dc.w word_1289E-sub_10000
                dc.w word_128BE-sub_10000
                dc.w word_128DE-sub_10000
                dc.w word_128FE-sub_10000
                dc.w word_1291E-sub_10000
                dc.w word_1293E-sub_10000
                dc.w word_1295E-sub_10000
                dc.w word_1297E-sub_10000
                dc.w word_1299E-sub_10000
                dc.w word_129BE-sub_10000
                dc.w word_129DE-sub_10000
word_1287E:     dc.w 0, 6, $E, $CC4, $4AA, $6EE, $64, $64, $A2, $A2, $6EE, $8C, $8EE, $AE, $6E, $4CA
word_1289E:     dc.w 0, $68, $2AA, $4A, $EA8, $444, $C86, $CCC, $EA8, $AAA, 0, $A4, $AC, $C6, $62, $A8
word_128BE:     dc.w 0, $EE, $46C, $E28, $A0A, $C2A, $A8A, $E4E, $ACA, $64A, $CAC, $888, $EEE, $AAA, $444, $888
word_128DE:     dc.w 0, $A86, $C, $AAA, $464, $4A, $242, $8A, 0, $420, $864, $C6E, $CCE, $E8E, $A0E, $CAE
word_128FE:     dc.w 0, $E00, $E60, $AAA, $286, $2CA, $44, $A8, 0, 0, 0, $CC, $EEE, $EE, $86, $8EE
word_1291E:     dc.w 0, $62E, $EC0, $E00, $EE, $AEE, $66, $CA, 0, 0, 0, $888, $EEE, $AAA, $444, $888
word_1293E:     dc.w 0, 6, $E, $CC4, $4A8, $6EE, $AAA, $8CC, $CCC, $AEE, 0, $C2, $EEE, $E6, $A0, $4CA
word_1295E:     dc.w 0, $48, $8E, $4E, $4E4, $444, $8A, $AA2, $AE, $882, 0, $8E, $EE, $28E, $2A, $AA
word_1297E:     dc.w 0, $6A, $EE, $E0, $AE, $E0, $86, $68, $8A, $66, $AC, $888, $EEE, $AAA, $444, $888
word_1299E:     dc.w 0, $EAE, $E6E, $E48, $C06, $4A, $8A, $4E, 0, $44, 0, $AA, $6CC, $CC, $66, $A8
word_129BE:     dc.w 0, $E00, $E60, $AAA, $666, $A6E, 0, 0, $4AE, 6, 2, $EE0, $EEE, $EE6, $E60, $EEA
word_129DE:     dc.w 0, $62E, $EC0, $E00, $EE, $AEE, 0, 0, $4AE, $A, 2, $A6C, $EE6, $C8E, $406, $EEC
off_129FE:      dc.w word_12A1C-sub_10000
                dc.w word_12A24-sub_10000
                dc.w word_12A2C-sub_10000
                dc.w word_12A34-sub_10000
                dc.w word_12A3C-sub_10000
                dc.w word_12A44-sub_10000
                dc.w word_12A4C-sub_10000
                dc.w word_12A54-sub_10000
                dc.w word_12A5C-sub_10000
                dc.w word_12A64-sub_10000
                dc.w word_12A6C-sub_10000
                dc.w word_12A74-sub_10000
                dc.w word_12A7C-sub_10000
                dc.w word_12A84-sub_10000
                dc.w word_12A8C-sub_10000
word_12A1C:     dc.w $EE, $60, $48, $4E
word_12A24:     dc.w $EE, $40, $A, $6A
word_12A2C:     dc.w $EEE, $666, $EE0, $E44
word_12A34:     dc.w $AA, $8EE, $CC, $E
word_12A3C:     dc.w $AC, $EC, $8EE, $666
word_12A44:     dc.w $8EE, $AAA, $CCA, $8C2
word_12A4C:     dc.w $EE, 0, $28E, $E
word_12A54:     dc.w $A, 0, $EE, $22E
word_12A5C:     dc.w $444, $AAA, $EEE, $20E
word_12A64:     dc.w $EEE, $AAA, $4A, $8C
word_12A6C:     dc.w $EEE, 0, $E, $CAE
word_12A74:     dc.w $88E, 0, $2C, $A
word_12A7C:     dc.w $EEE, 0, $E22, $600
word_12A84:     dc.w $EEE, $666, $40C, $A8E
word_12A8C:     dc.w $EEE, $222, $AAA, $666
sub_12A94:
                jsr     sub_100D4
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                bsr.s   sub_12ABA
                move.w  #$83,d0
                jsr     unk_FFFB66
                bsr.w   sub_12E00
                bsr.w   sub_12E2E
                jmp     unk_FFFB6C

sub_12ABA:
                clr.b   (byte_FFD883).w
                bsr.w   sub_1268E
                bsr.w   sub_12824
                move.w  #1,(dword_FFFFA8).w
                moveq   #$30,d7
                bsr.w   sub_11774
                subq.b  #1,d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                lea     (off_1AD92).l,a0
                move.w  (a0,d0.w),d1
                movea.l d1,a6
                move.w  d0,-(sp)
                bsr.w   sub_11422
                move.w  (sp)+,d0
                moveq   #$FFFFFFFF,d1
                lea     off_15508(pc),a0
                move.w  (a0,d0.w),d1
                movea.l d1,a6
                move.w  d0,-(sp)
                bsr.w   sub_11608
                move.w  (sp)+,d0
                lsl.w   #2,d0
                lea     dword_15B94(pc),a0
                move.l  (a0,d0.w),(dword_FFD26E).w
                move.l  4(a0,d0.w),(dword_FFD272).w
                tst.b   (byte_FFD886).w
                beq.s   loc_12B20
                clr.b   (byte_FFD886).w
                bsr.w   sub_1172C

loc_12B20:
                bsr.w   sub_12DE4
                bsr.w   sub_11B60
                bsr.w   sub_12D1A
                bsr.w   sub_11700
                bsr.w   sub_11E06
                bsr.w   sub_11DC2
                bsr.w   sub_11DD4
                bsr.w   sub_11DE6
                bsr.w   sub_11D88
                rts

sub_12B46:
                move.w  (word_FFD2A0).w,d0
                andi.w  #$7FFC,d0
                jsr     loc_12B6A(pc,d0.w)
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_12B5E
                bsr.w   sub_12EF4

loc_12B5E:
                bsr.w   sub_12E90
                bsr.w   sub_10D52
                jmp     unk_FFFB6C

loc_12B6A:
                bra.w   sub_12B7E
                bra.w   sub_12B9A
                bra.w   sub_12BDC
                bra.w   sub_12C9A
                bra.w   sub_12CDA

sub_12B7E:
                cmpi.l  #$1C000,(dword_FFD296).w
                bgt.s   loc_12B8C
                addq.l  #7,(dword_FFD296).w

loc_12B8C:
                bsr.w   sub_12D84
                bsr.w   sub_111E2
                bsr.w   sub_116BE
                rts

sub_12B9A:
                bset    #7,(word_FFD2A0).w
                bne.s   loc_12BD2

loc_12BA2:
                tst.b   (byte_FFD2A4).w
                beq.s   loc_12BB2
                bsr.w   sub_10D52
                jsr     unk_FFFB6C
                bra.s   loc_12BA2

loc_12BB2:
                move.b  #$82,d0
                jsr     unk_FFFB66
                move.w  #$8000,(word_FFD884).w
                bsr.w   sub_11E96
                clr.w   (word_FFFF92).w
                lea     (word_FFC040).w,a0
                move.w  #4,word_FFC07C-word_FFC040(a0)

loc_12BD2:
                bsr.w   sub_111E2
                bsr.w   sub_12D42
                rts

sub_12BDC:
                bset    #7,(word_FFD2A0).w
                bne.s   loc_12C2E
                clr.w   (word_FFFF92).w
                moveq   #$30,d7
                bsr.w   sub_11774
                move.b  d0,d1
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0
                addq.b  #5,d0
                moveq   #$30,d7
                bsr.w   loc_1176A
                lsr.w   #3,d0
                cmp.b   byte_12C7C(pc,d0.w),d1
                bne.s   loc_12C74
                tst.b   (byte_FFD88F).w
                bne.s   loc_12C70
                lsl.w   #2,d0
                move.l  dword_12C82(pc,d0.w),(dword_FFD262).w
                moveq   #$A,d1

loc_12C16:
                jsr     unk_FFFB6C
                dbf     d1,loc_12C16
                lea     (word_FFC040).w,a0
                move.w  #$54,(a0)
                move.b  #$E1,d0
                jsr     unk_FFFB66

loc_12C2E:
                lea     (word_FFFF92).w,a0
                cmpi.w  #8,(a0)
                bne.s   loc_12C6A
                clr.w   (a0)
                move.w  #$8000,(word_FFD884).w
                bsr.w   sub_1168A
                movem.l d0/a0,-(sp)
                move.b  #$98,d0
                bsr.w   sub_10D48
                movem.l (sp)+,d0/a0
                addq.b  #1,(byte_FFD88C).w
                cmpi.b  #$A,(byte_FFD88C).w
                bne.s   loc_12C6A
                clr.b   (byte_FFD88C).w
                clr.b   (byte_FFD88D).w
                bra.s   loc_12C74

loc_12C6A:
                bsr.w   sub_111E2
                rts

loc_12C70:
                clr.b   (byte_FFD88F).w

loc_12C74:
                move.w  #4,(word_FFD2A0).w
                rts

byte_12C7C:     dc.b 2, $A, $12, $1A, $22, $2A
dword_12C82:    dc.l $200000, $1000, $5000, $10000, $50000, $100000
sub_12C9A:
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0
                addq.b  #5,d0
                moveq   #$30,d7
                bsr.w   loc_1176A
                lsr.w   #3,d0
                lsl.w   #1,d0
                move.w  (dword_FFD888).w,d1
                cmp.w   word_12CCE(pc,d0.w),d1
                bhi.s   loc_12CC0
                cmpi.b  #1,(byte_FFD88D).w
                bne.s   loc_12CC0
                bra.s   loc_12CC6

loc_12CC0:
                move.b  #1,(byte_FFD88F).w

loc_12CC6:
                move.w  #8,(word_FFD2A0).w
                rts

word_12CCE:     dc.w $25, $30, $35, $40, $45, $50
sub_12CDA:
                bset    #7,(word_FFD2A0).w
                bne.s   loc_12CFE
                moveq   #$1E,d1

loc_12CE4:
                jsr     unk_FFFB6C
                dbf     d1,loc_12CE4
                move.b  #$84,d0
                jsr     unk_FFFB66
                move.w  #$3C,(word_FFC000).w
                clr.b   (byte_FFD886).w

loc_12CFE:
                bsr.w   sub_111D4
                move.w  #$B4,d1

loc_12D06:
                jsr     unk_FFFB6C
                dbf     d1,loc_12D06
                bsr.w   sub_11784
                move.w  #$40,(word_FFFFC0).w
                rts

sub_12D1A:
                moveq   #0,d7
                moveq   #0,d6
                lea     (byte_FFD82E).w,a0
                move.b  (a0),d7
                move.b  1(a0),d6
                bsr.w   sub_11674
                move.w  d7,(word_FFD25E).w
                addi.w  #$17,d7
                move.w  d7,(word_FFD260).w
                addi.w  #$18,d6
                move.w  d6,(word_FFD25C).w
                rts

sub_12D42:
                move.w  (word_FFFF92).w,d0
                cmpi.w  #$FA,d0
                bhi.s   loc_12D56
                bsr.w   sub_11740
                bsr.w   sub_11E52
                rts

loc_12D56:
                addq.b  #1,(word_FFD82C+1).w
                bne.s   loc_12D60
                addq.b  #1,(word_FFD82C+1).w

loc_12D60:
                move.b  (word_FFD82C).w,d0
                moveq   #1,d1
                addi.b  #0,d0
                abcd    d1,d0
                move.b  d0,(word_FFD82C).w
                move.w  #$18,(word_FFFFC0).w
                cmpi.b  #$49,d0
                bne.s   locret_12D82
                move.w  #$30,(word_FFFFC0).w

locret_12D82:
                rts

sub_12D84:
                lea     (unk_FFC380).w,a0
                lea     (unk_FFC680).w,a1
                tst.w   (a0)
                bne.s   loc_12D98
                tst.w   (a1)
                bne.s   loc_12D98
                move.w  #$18,(a1)

loc_12D98:
                lea     (unk_FFC3C0).w,a0
                lea     (unk_FFC400).w,a1
                lea     (unk_FFC6C0).w,a2
                lea     (unk_FFC700).w,a3
                tst.w   (a0)
                bne.s   loc_12DBE
                tst.w   (a2)
                bne.s   loc_12DBE
                tst.w   (a3)
                bne.s   loc_12DBE
                move.w  #$18,(a2)
                move.b  #1,$16(a2)

loc_12DBE:
                cmpi.b  #$A,(word_FFD82C+1).w
                bcs.s   locret_12DE2
                tst.w   (a1)
                bne.s   locret_12DE2
                tst.w   (a3)
                bne.s   locret_12DE2
                tst.w   (a2)
                bne.s   locret_12DE2
                move.w  #$18,(a3)
                move.w  #4,$3C(a3)
                move.b  #2,$16(a3)

locret_12DE2:
                rts

sub_12DE4:
                lea     (unk_FFC480).w,a0
                moveq   #0,d1
                moveq   #7,d0

loc_12DEC:
                tst.w   (a0)
                beq.s   loc_12DF2
                addq.b  #1,d1

loc_12DF2:
                lea     $40(a0),a0
                dbf     d0,loc_12DEC
                move.b  d1,(byte_FFD883).w
                rts

sub_12E00:
                bsr.w   sub_111E2
                jsr     unk_FFFB6C
                moveq   #$3C,d2

loc_12E0A:
                bsr.w   sub_116BE
                jsr     unk_FFFB6C
                dbf     d2,loc_12E0A
                bsr.w   sub_11CAA
                move.w  #$C,(word_FFC440).w
                bsr.w   sub_111E2
                jsr     unk_FFFB6C
                bsr.w   sub_11CCA
                rts

sub_12E2E:
                move.w  #$136,d1
                move.l  #loc_14000,d2
                move.b  (word_FFD82C+1).w,d0
                cmpi.b  #$20,d0
                bls.s   loc_12E44
                moveq   #$20,d0

loc_12E44:
                subq.w  #5,d1
                addi.l  #$200,d2
                dbf     d0,loc_12E44
                move.w  d1,(word_FFD294).w
                move.l  d2,(dword_FFD27C).w
                move.l  #loc_14000,(dword_FFD296).w
                cmpi.b  #$30,(word_FFD82C+1).w
                bls.s   loc_12E70
                move.l  #$18000,(dword_FFD296).w

loc_12E70:
                moveq   #0,d1
                moveq   #$30,d7
                bsr.w   sub_11774
                subq.b  #1,d0
                lea     byte_15D28(pc),a0
                move.b  (a0,d0.w),d1
                lsl.w   #2,d1
                lea     dword_15D14(pc),a0
                move.l  (a0,d1.w),(dword_FFD276).w
                rts

sub_12E90:
                move.l  (dword_FFD87E).w,d0
                moveq   #0,d1
                moveq   #4,d7

loc_12E98:
                btst    d1,(byte_FFD887).w
                bne.s   loc_12EB2
                move.w  d1,d2
                lsl.w   #2,d2
                cmp.l   dword_12EE0(pc,d2.w),d0
                bcs.s   loc_12EB2
                bset    d1,(byte_FFD887).w
                bsr.w   sub_12EBA
                bra.s   locret_12EB8

loc_12EB2:
                addq.b  #1,d1
                dbf     d7,loc_12E98

locret_12EB8:
                rts

sub_12EBA:
                move.l  d0,-(sp)
                move.b  #1,(byte_FFD2A4).w
                move.b  #$97,d0
                jsr     unk_FFFB36
                move.b  d0,(byte_A01C09).l
                jsr     unk_FFFB3C
                move.l  (sp)+,d0
                addq.b  #1,(byte_FFD882).w
                bsr.w   sub_11D88
                rts

dword_12EE0:    dc.l $30000, $80000, $160000, $240000, $320000
sub_12EF4:
                jsr     unk_FFFB36
                move.b  #1,(byte_A01C10).l
                jsr     unk_FFFB3C
                move.w  #$58,(word_FFC000).w

loc_12F0A:
                bsr.w   sub_111D4
                jsr     unk_FFFB6C
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_12F0A
                jsr     unk_FFFB36
                move.b  #$80,(byte_A01C10).l
                jsr     unk_FFFB3C
                clr.w   (word_FFC000).w
                rts

sub_12F30:
                bsr.w   sub_100D4
                move.w  #$8F02,(VDP_CTRL).l
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                move.w  #$2C,(word_FFF82E).w
                bsr.w   sub_113AC
                bsr.w   sub_1268E
                bsr.w   sub_12824
                move.b  #1,(byte_FFD24E).w
                move.b  #$14,(byte_FFD883).w
                bsr.w   sub_1194C
                bsr.w   sub_11976
                lea     (unk_FFCAA0).w,a0
                moveq   #$1F,d0

loc_12F72:
                move.b  #1,(a0)+
                dbf     d0,loc_12F72
                lea     (VDP_DATA).l,a0
                move.l  #$65400003,(VDP_CTRL).l
                moveq   #$1F,d0

loc_12F8C:
                move.w  #$220D,(a0)
                dbf     d0,loc_12F8C
                lea     byte_12FCC(pc),a6
                bsr.w   sub_10FAA
                lea     byte_12FD4(pc),a6
                bsr.w   sub_10FAA
                bsr.w   sub_1303C
                bsr.w   sub_11E06
                bsr.w   sub_11DC2
                bsr.w   sub_11DD4
                bsr.w   sub_11DE6
                bsr.w   sub_11D88
                move.b  #$81,d0
                jsr     unk_FFFB66
                jsr     unk_FFFB6C
                jmp     unk_FFFB6C

byte_12FCC:     dc.b $C0, $D4
aBonus:         dc.b "BONUS",0
byte_12FD4:     dc.b $C0, $E0
aRound_0:       dc.b "ROUND",0
sub_12FDC:
                move.w  (word_FFD2A6).w,d0
                andi.w  #$7FFC,d0
                jsr     loc_13000(pc,d0.w)
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_12FF4
                bsr.w   sub_12EF4

loc_12FF4:
                bsr.w   sub_12E90
                bsr.w   sub_10D52
                jmp     unk_FFFB6C

loc_13000:
                bra.w   sub_13008
                bra.w   sub_1300E

sub_13008:
                bsr.w   sub_111E2
                rts

sub_1300E:
                bset    #7,(word_FFD2A6).w
                bne.s   loc_13032

loc_13016:
                tst.b   (byte_FFD2A4).w
                beq.s   loc_13026
                bsr.w   sub_10D52
                jsr     unk_FFFB6C
                bra.s   loc_13016

loc_13026:
                move.b  #$82,d0
                jsr     unk_FFFB66
                bsr.w   sub_1691C

loc_13032:
                bsr.w   sub_111E2
                bsr.w   sub_130D4
                rts

sub_1303C:
                lea     (unk_FFC580).w,a0
                move.w  #$C,(a0)
                move.w  #$D11,$3E(a0)
                move.w  #$2C,(word_FFC040).w
                lea     (unk_FFC640).w,a0
                move.w  #$30,(a0)
                lea     $40(a0),a0
                move.w  #$30,(a0)
                move.b  #1,$16(a0)
                lea     (unk_FFC5C0).w,a0
                move.w  #$34,(a0)
                lea     $40(a0),a0
                move.w  #$34,(a0)
                move.b  #1,$16(a0)
                lea     (unk_FFC080).w,a0
                moveq   #0,d1
                moveq   #$13,d0

loc_13084:
                move.w  #$38,(a0)
                move.b  d1,$38(a0)
                btst    #2,d1
                beq.s   loc_13098
                move.b  #1,$39(a0)

loc_13098:
                lea     $40(a0),a0
                addq.b  #1,d1
                dbf     d0,loc_13084
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0
                moveq   #$30,d7
                bsr.w   sub_11764
                subq.b  #3,d0
                lsr.w   #2,d0
                lsl.w   #2,d0
                lea     off_169F4(pc),a0
                move.l  (a0,d0.w),(dword_FFD282).w
                lea     off_16A9C(pc),a0
                move.l  (a0,d0.w),(dword_FFD286).w
                lea     off_16C34(pc),a0
                move.l  (a0,d0.w),(dword_FFD28A).w
                rts

sub_130D4:
                move.b  #1,(byte_FFD27B).w
                move.w  (word_FFFF92).w,d0
                cmpi.w  #$FA,d0
                bhi.s   loc_130EE
                bsr.w   sub_11740
                bsr.w   sub_11F6C
                rts

loc_130EE:
                addq.b  #1,(word_FFD82C+1).w
                bne.s   loc_130F8
                addq.b  #1,(word_FFD82C+1).w

loc_130F8:
                move.b  (word_FFD82C).w,d0
                moveq   #1,d1
                addi.b  #0,d0
                abcd    d1,d0
                move.b  d0,(word_FFD82C).w
                move.w  #$18,(word_FFFFC0).w
                rts

sub_13110:
                jsr     sub_100D4
                clr.b   (byte_FFD88E).w
                bsr.w   loc_10126
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                move.w  #$800,(word_FFF7E0).w
                bsr.w   sub_13566
                move    #$2700,sr
                moveq   #2,d2
                move.w  #$3BA,d0
                move.w  #$125B,d1
                lea     (word_135E8).l,a0
                jsr     unk_FFFB54
                move    #$2500,sr
                move.b  #$81,d0
                jsr     unk_FFFB66
                clr.w   (word_FFFF92).w
                jsr     unk_FFFB6C
                jmp     unk_FFFB6C

sub_13162:
                move.w  (word_FFD29E).w,d0
                andi.w  #$7FFC,d0
                jsr     loc_13176(pc,d0.w)
                bsr.w   sub_111E2
                jmp     unk_FFFB6C

loc_13176:
                bra.w   sub_13182
                bra.w   sub_1321A
                bra.w   sub_13492

sub_13182:
                bsr.w   sub_131D6
                cmpi.w  #$C8,(word_FFFF92).w
                bne.s   locret_131D4
                move.w  #4,(word_FFD29E).w
                move.w  #$8100,(word_FFD884).w
                move.w  #$EEE,(word_FFF7E6).w
                bsr.w   sub_131DA
                move.l  #$EFFFFFFF,(dword_FFFFB8).w
                move.l  #$FFFFFFFF,(dword_FFFFBC).w
                bsr.w   sub_11784
                lea     (VDP_DATA).l,a0
                move.l  #$40000003,(VDP_CTRL).l
                move.w  #$3FF,d0

loc_131CC:
                move.w  #0,(a0)
                dbf     d0,loc_131CC

locret_131D4:
                rts

sub_131D6:
                bsr.w   sub_11740

sub_131DA:
                lea     byte_131EC(pc),a6
                bsr.w   sub_10FAA
                lea     byte_13200(pc),a6
                bsr.w   sub_10FAA
                rts

byte_131EC:     dc.b $C2, $90
aCongratulation:dc.b "CONGRATULATIONS!",0
                dc.b 0
byte_13200:     dc.b $C3, $8A
aYouAreASuperPl:dc.b "YOU ARE A SUPER PLAYER.",0
sub_1321A:
                bset    #7,(word_FFD29E).w
                bne.s   loc_1325A
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                move.w  #$EEE,(word_FFF7E6).w
                clr.l   (dword_FFFFB8).w
                clr.l   (dword_FFFFBC).w
                move.w  #$4000,(dword_FFD008+2).w
                lea     (word_FFC000).w,a0
                moveq   #0,d1
                moveq   #4,d0

loc_13248:
                move.w  #$50,(a0)
                move.w  d1,$38(a0)
                lea     $40(a0),a0
                addq.w  #1,d1
                dbf     d0,loc_13248

loc_1325A:
                bsr.w   sub_1130C
                addq.b  #1,(byte_FFD29D).w
                cmpi.b  #$20,(byte_FFD29D).w
                bne.s   locret_1328C
                clr.b   (byte_FFD29D).w
                bsr.w   sub_1328E
                addq.b  #1,(byte_FFD29C).w
                cmpi.b  #$5D,(byte_FFD29C).w
                bne.s   locret_1328C
                move.w  #8,(word_FFD29E).w
                lea     (word_FFC000).w,a0
                move.w  #$44,(a0)

locret_1328C:
                rts

sub_1328E:
                moveq   #0,d0
                moveq   #0,d5
                move.w  (dword_FFFFA4).w,d0
                andi.w  #$FF,d0
                lsr.w   #3,d0
                subq.w  #2,d0
                bpl.s   loc_132A4
                addi.w  #$20,d0

loc_132A4:
                lsl.w   #6,d0
                addi.w  #-$3FF8,d0
                move.w  d0,d5
                move.w  d5,d6
                bsr.w   sub_10F2E
                move.l  d5,(VDP_CTRL).l
                moveq   #$1F,d1

loc_132BA:
                move.w  #0,(VDP_DATA).l
                dbf     d1,loc_132BA
                moveq   #0,d1
                move.b  (byte_FFD29C).w,d1
                lsl.w   #1,d1
                moveq   #$FFFFFFFF,d2
                lea     off_132E0(pc),a6 ; "     STAFF"
                move.w  (a6,d1.w),d2
                movea.l d2,a6
                bsr.w   loc_10FAE
                rts

off_132E0:      dc.w aStaff-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aDirector-sub_10000  
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aKFuzzy-sub_10000    
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aDesigner-sub_10000  
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aYumi-sub_10000      
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aProgrammer-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aOSamu-sub_10000     
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aSoundDesign-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aTSMusic-sub_10000   
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aAnd-sub_10000       
                dc.w byte_1339C-sub_10000
                dc.w aSpecialThanks-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aLee-sub_10000       
                dc.w byte_1339C-sub_10000
                dc.w aBo-sub_10000        
                dc.w byte_1339C-sub_10000
                dc.w aArcadeFlickySt-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aTestPlayers-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w aChallengeTheNe-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
                dc.w byte_1339C-sub_10000
byte_1339C:     dc.b 0, 0
aStaff:         dc.b "     STAFF",0
                dc.b 0
aDirector:      dc.b "    DIRECTOR",0
                dc.b 0
aKFuzzy:        dc.b "     K.FUZZY",0
                dc.b 0
aDesigner:      dc.b "    DESIGNER",0
                dc.b 0
aYumi:          dc.b "     YUMI",0
aProgrammer:    dc.b "    PROGRAMMER",0
                dc.b 0
aOSamu:         dc.b "     O.SAMU",0
aSoundDesign:   dc.b "    SOUND DESIGN",0
                dc.b 0
aTSMusic:       dc.b "     T@S MUSIC",0
                dc.b 0
aAnd:           dc.b "      AND",0
aSpecialThanks: dc.b "    SPECIAL THANKS",0
                dc.b 0
aArcadeFlickySt:dc.b "     ARCADE FLICKY STAFF",0
                dc.b 0
aTestPlayers:   dc.b "     TEST PLAYERS",0
aLee:           dc.b "     LEE",0
                dc.b 0
aBo:            dc.b "     BO",0
aChallengeTheNe:dc.b "CHALLENGE THE NEXT STAGE.",0
sub_13492:
                btst    #7,(word_FFFF8E+1).w
                beq.s   locret_134BA
                bsr.w   sub_11784
                move.b  #1,(byte_FFD88E).w
                bsr.w   loc_10126
                move.w  #$18,(word_FFFFC0).w
                move    #$2700,sr
                bsr.w   sub_10CF6
                move    #$2500,sr

locret_134BA:
                rts

sub_134BC:
                bset    #7,(a0)
                bne.s   loc_134E2
                bset    #1,2(a0)
                move.w  $38(a0),d0
                move.b  word_13516(pc,d0.w),$3A(a0)
                lsl.w   #1,d0
                move.w  word_1350C(pc,d0.w),6(a0)
                lsl.w   #1,d0
                move.l  off_134F8(pc,d0.w),8(a0)

loc_134E2:
                move.w  $3C(a0),d0
                andi.w  #$7FFC,d0
                jsr     loc_134F0(pc,d0.w)
                rts

loc_134F0:
                bra.w   sub_1351C
                bra.w   sub_1352E

off_134F8:      dc.l off_144AC
                dc.l off_14E12
                dc.l off_14E22
                dc.l off_154AE
                dc.l off_162BC
word_1350C:     dc.w 4, 0, 0, 8, $10
word_13516:     dc.w $D17, $212B, $3D00
sub_1351C:
                move.b  (byte_FFD29C).w,d0
                cmp.b   $3A(a0),d0
                bne.s   locret_1352C
                move.w  #4,$3C(a0)

locret_1352C:
                rts

sub_1352E:
                bset    #7,$3C(a0)
                bne.s   loc_13550
                move.w  #$E4,$30(a0)
                move.w  #$178,$24(a0)
                move.l  #$FFFFC000,$2C(a0)
                bclr    #1,2(a0)

loc_13550:
                bsr.w   sub_1105C
                cmpi.w  #$78,$24(a0)
                bgt.s   loc_13560
                bsr.w   sub_110F0

loc_13560:
                bsr.w   sub_11126
                rts

sub_13566:
                moveq   #9,d0
                moveq   #0,d1

loc_1356A:
                moveq   #0,d5
                movem.l d0-d1,-(sp)
                lsl.w   #1,d1
                move.w  word_135D4(pc,d1.w),d5
                moveq   #$FFFFFFFF,d2
                move.w  off_13598(pc,d1.w),d2
                movea.l d2,a6
                lsl.w   #1,d1
                move.w  byte_135AC(pc,d1.w),d7
                move.w  byte_135AC+2(pc,d1.w),d6
                bsr.w   sub_10F6E
                movem.l (sp)+,d0-d1
                addq.w  #1,d1
                dbf     d0,loc_1356A
                rts

off_13598:      dc.w word_1A354-sub_10000
                dc.w word_1A336-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A374-sub_10000
                dc.w word_1A354-sub_10000
                dc.w word_1A336-sub_10000
byte_135AC:     dc.b 0, 3, 0, 3, 0, 4, 0, 2, 0, 4
                dc.b 0, 2, 0, 4, 0, 2, 0, 4, 0, 2
                dc.b 0, 4, 0, 2, 0, 4, 0, 2, 0, 4
                dc.b 0, 2, 0, 3, 0, 3, 0, 4, 0, 2
word_135D4:     dc.w $E132, $E4B2, $E642, $E64C, $E656, $E660, $E66A, $E674, $E446, $E146
word_135E8:     dc.w $B115, $700, $200, $B015, 0, $8912, $F506, $2613, $F511, $DB13, $F51C, $3314, $E90E, $2115, $F510, $7D12
                dc.w $F508, $8004, $F018, $103, $3EF, $F6, $8F12, $EA61, $2E6, $EF00, $8060, $F8D7, $12C5, $C6C7, $F8D7, $12C3
                dc.w $C4C6, $C8C9, $C8C7, $C880, $BF80, $C180, $C6C5, $C680, $C1C4, $C3BF, $C1C3, $C680, $CBC9, $F80E, $13C3, $CC1
                dc.w $C3C4, $C680, $CBC9, $F80E, $13C6, $CC8, $C9CB, $CDC9, $CDD0, $CFCB, $CDCF, $D280, $24F6, $9112, $BF0C, $80C8
                dc.w $30C7, $CC8, $C7C8, $8048, $BF0C, $80C8, $30C7, $CC8, $C4C1, $8048, $C30C, $C4C6, $C3BF, $80CB, $C9C8, $C9CB
                dc.w $C8C4, $80C6, $C8C9, $80C1, $80C4, $80C3, $C4C6, $BFC1, $C3C4, $F9C8, $C7C8, $C9CB, $80C4, $80C1, $80CD, $CCCD
                dc.w $8024, $BF0C, $80CB, $CACB, $8024, $F9EF, $1B3, $C80, $B380, $B380, $B380, $AC18, $B306, $80B3, $80AC, $C80
                dc.w $B318, $ACB3, $680, $B380, $AC0C, $80B3, $18E8, $6AC, $B30C, $B3AC, $18B3, $ACB5, $CB5, $AC18, $B5AE, $B30C
                dc.w $B3AE, $18B3, $ACB3, $CB3, $AC18, $B3B5, $B10C, $B1B5, $18B1, $B3AE, $CAE, $B318, $B3F7, 2, $3113, $AC0C
                dc.w $B8AC, $B8AC, $B8AC, $B8B1, $BDB1, $BDB1, $BDB1, $BDB3, $BFB3, $BFB3, $BFB3, $BFB0, $BBB0, $BCB0, $BCB0, $BCF8
                dc.w $BE13, $B3BA, $B3BA, $ACB8, $ACB8, $B0B1, $B3B8, $F8BE, $13AE, $BAAE, $BAB3, $CAE, $6AE, $B30C, $AEB3, $18B3
                dc.w $F631, $13B1, $18B5, $6C1, $B4C0, $B518, $B50C, $B4B3, $18B3, $6BF, $B2BE, $B318, $B30C, $B8AE, $BAAE, $BAF9
                dc.w $EF03, $B360, $F80B, $14B5, $B3B3, $F80B, $14B1, $B3B3, $AC3C, $CB0, $B3B1, $3030, $B3B3, $F826, $14AE, $30B3
                dc.w $F826, $14AE, $3C0C, $B1B5, $B318, $1818, $18F6, $DF13, $AC30, $B3AC, $240C, $AEB0, $B318, $AC30, $B3B1, $240C
                dc.w $B3B5, $B818, $B330, $30AC, $ACB1, $F9AC, $3CAE, $CB0, $B3B1, $4818, $AC48, $18F9, $EF00, $E402, $103, $303
                dc.w $CF06, $CBCD, $CFD0, $CBCF, $D0D2, $CFD0, $D2D4, $D3D4, $D580, $CD4, $6D5, $D780, $D480, $DC80, $D480, $D780
                dc.w $D480, $F701, $34C, $14F8, $DC14, $80DE, $80D7, $80DB, $80D7, $8080, $CD4, $6D5, $D780, $D480, $DC80, $D480
                dc.w $D780, $D480, $F8DC, $1480, $12D7, $6D6, $D7D9, $DBD7, $F700, $24C, $1480, $CD4, $D4CB, $80D4, $D4CB, $80D5
                dc.w $D5CD, $80D5, $D5CD, $80D7, $D7D2, $80D7, $D7D2, $80D7, $D7D0, $80D7, $D7D0, $F8F6, $14D4, $CD3, $D4D5, $D780
                dc.w $D003, $D1D2, $D3D4, $D5D6, $D7F8, $F614, $DEDE, $DE80, $D503, $D7D8, $D9DA, $DBDC, $DDDE, $C80, $DF18, $F64C
                dc.w $1480, $CD5, $6D7, $D980, $D580, $DC80, $D580, $D980, $D580, $800C, $D706, $D9DB, $80D7, $F9D9, $C80, $D9D8
                dc.w $D006, $D5D9, $DCD9, $CD8, $D780, $D7D6, $D006, $D4D7, $DCD7, $CDC, $DE06, $DEDE, $80DE, $DEDE, $80DE, $DEDE
                dc.w $80DE, $DEDE, $80F9, $EF01, $8060, $8060, $8080, $8080, $8080, $80C8, $48C7, $CC8, $C7C8, $D3D4, $D3D4, $BF04
                dc.w $C1C3, $C4C5, $C6C8, $48C7, $CC8, $C4C1, $D3D4, $D0CD, $BD04, $BFC1, $C3C4, $C6CB, $C80, $CB80, $C980, $CB80
                dc.w $C880, $C480, $C880, $C480, $C980, $C180, $C480, $C980, $CB80, $CB80, $CB80, $CB80, $C40C, $C6C4, $C3C4, $80BF
                dc.w $80BD, $80C6, $C5C6, $80BD, $C1BF, $BABD, $BFC3, $80C6, $C3F8, $A415, $BF0C, $BDBF, $C1C3, $80C6, $C3F8, $A415
                dc.w $8060, $8048, $C318, $F625, $15C4, $C3C4, $C6C8, $80BF, $8080, $6080, $F9F2, $2C72, $7232, $321F, $111F, $F00
                dc.w $E00, $F00, $900, $906, $3606, $3615, $8014, $8038, $3A31, $3131, $1F1F, $5F5F, $120E, $A0A, 4, $403
                dc.w $2F2F, $2F2F, $242D, $E80, $373A, $3131, $311F, $1F5F, $5F12, $E0A, $A00, $404, $32F, $2F2F, $2F24, $2D0E
                dc.w $803C, $3233, $7243, $1F18, $1F5E, $71F, $71F, 0, 0, $1F0F, $1F1F, $1B80, $C80
sub_139A2:
                jsr     sub_100D4
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                move.w  (word_FFD890).w,d0
                andi.w  #3,d0
                move.b  byte_13A08(pc,d0.w),(word_FFD82C+1).w
                move.b  byte_13A0C(pc,d0.w),(word_FFD82C).w
                lsl.w   #1,d0
                move.w  off_13A10(pc,d0.w),(word_FFD2AA).w
                moveq   #$FFFFFFFF,d1
                move.w  (word_FFD2AA).w,d1
                movea.l d1,a0
                move.b  (a0),(byte_FFD2A8).w
                move.b  1(a0),(byte_FFD2AC).w
                addq.w  #1,(word_FFD890).w
                bsr.w   sub_12ABA
                clr.l   (dword_FFD888).w
                clr.b   (byte_FFD88D).w
                move.b  #1,(byte_FFD2A5).w
                move.w  #$44,(word_FFC000).w
                bsr.w   sub_12E00
                bsr.w   sub_12E2E
                jmp     unk_FFFB6C

byte_13A08:     dc.b 1, $A, $14, $18
byte_13A0C:     dc.b 1, $10, $20, $24
off_13A10:      dc.w word_13A82-sub_10000
                dc.w word_13B82-sub_10000
                dc.w word_13C52-sub_10000
                dc.w word_13D70-sub_10000
sub_13A18:
                btst    #7,(word_FFFF8E+1).w
                beq.s   loc_13A2A
                bsr.w   sub_11784
                move.w  #0,(word_FFFFC0).w

loc_13A2A:
                bsr.w   sub_13A5E
                cmpi.l  #$1C000,(dword_FFD296).w
                bgt.s   loc_13A3C
                addq.l  #7,(dword_FFD296).w

loc_13A3C:
                bsr.w   sub_12D84
                bsr.w   sub_111E2
                bsr.w   sub_116BE
                bclr    #0,(byte_FFD886).w
                beq.s   loc_13A5A
                bsr.w   sub_11784
                move.w  #$40,(word_FFFFC0).w

loc_13A5A:
                jmp     unk_FFFB6C

sub_13A5E:
                moveq   #$FFFFFFFF,d0
                move.w  (word_FFD2AA).w,d0
                movea.l d0,a0
                move.b  (a0),(word_FFFF8E).w
                subq.b  #1,(byte_FFD2AC).w
                bne.s   locret_13A80
                addq.l  #2,a0
                move.b  (a0),(byte_FFD2A8).w
                move.b  1(a0),(byte_FFD2AC).w
                move.w  a0,(word_FFD2AA).w

locret_13A80:
                rts

word_13A82:     dc.w $12, $801, $A15, $4A12, $4201, $4402, $40E, $1C
                dc.w $400A, $A, $40D, $C, $404, $50E, $405, 2
                dc.w $A14, $801, $27, $801, $A16, $40D, $1B, $801
                dc.w $A0B, $4A06, $4201, $440A, $411, $22, $801, $A07
                dc.w $801, $29, $406, $F, $4018, $F, $40B, $440D
                dc.w $401, 8, $A0D, $801, 6, $42E, $440B, $401
                dc.w $2A, $A0C, $D, $418, $33, $42A, $4406, $4004
                dc.w $A13, $801, $3F, $801, $A0B, $803, $A01, $201
                dc.w $409, $6B, $A02, $4A08, $A25, $4A04, $4201, $4001
                dc.w $4417, $4003, $A, $40F, $4409, $415, $D, $A1B
                dc.w $801, 8, $801, $4A0C, $A27, $202, $40E, $25
                dc.w $4009, $4403, $4504, $4403, $1C, $801, $A07, $4A07
                dc.w $A03, $201, $401, $510, $402, $E, $801, $A13
                dc.w $4A06, $A02, $201, $415, 7, $801, $A38, $201
                dc.w $43C, $4407, $416, $23, $A2C, $601, $40A, $38
                dc.w 0, 0, 0, 0, 0, 0, 0, 0
word_13B82:     dc.w $12, $801, $A09, $4A11, $A17, $14, $4004, $4A0B
                dc.w $A5A, $1C, $A0C, 9, $403, $502, $409, $1E
                dc.w $407, 3, $801, $A0F, $602, $40D, $4405, $400B
                dc.w $23, $408, 9, $40E, $441F, $D, $410, $440F
                dc.w $41C, $17, $A1B, $802, $46, $410, $2B, $40E
                dc.w $400C, $1F, $A0B, $4A12, $A35, $4A17, $4802, $4001
                dc.w 3, $410, $21, $404, $507, $4508, $4403, $4008
                dc.w $4801, $4A0D, $A05, $B, $40A, 7, $408, $33
                dc.w $420, 3, $A12, $A, $40A, $501, 1, $A10
                dc.w $201, $17, $A17, $801, 4, $802, $A07, $4A0D
                dc.w $4201, $4407, $4502, $4403, $4001, $19, $801, $A07
                dc.w $201, $406, $4405, $4003, 8, $A1E, $10, $A13
                dc.w $801, $1A, $414, $1F, $403, $504, $40C, $43
word_13C52:     dc.w $42C, $240C, $408, $A0E, $C, $41B, $2409, $2001
                dc.w $803, $A18, $802, $F, $515, $250B, $522, $401
                dc.w 8, $813, $12, $409, $A, $200B, 8, $80C
                dc.w $12, $814, 7, $409, $510, $402, $C, $808
                dc.w $20, $812, $A, $403, $509, $403, $1C, $816
                dc.w $1A, $80E, $A, $40A, $26, $200C, 4, $403
                dc.w $508, $403, $C, $80C, $14, $402, $522, $403
                dc.w $601, $202, $A0D, $801, $11, $403, $505, $402
                dc.w 8, $80C, $1F, $860, 9, $403, $504, $402
                dc.w $1E, $2001, $2809, $813, $901, $50F, 2, $803
                dc.w $2A13, $A01, $803, $A, $200C, 8, $82C, 9
                dc.w $409, 1, $200F, $38, $2001, $240D, $2501, $2401
                dc.w $2001, $21, $200F, $1F, $200A, $2803, $818, $1E
                dc.w $818, $2805, $2001, $2508, $506, $1A, $2005, $2402
                dc.w $200C, $D, $516, $101, $903, $801, $C, $508
                dc.w $101, $82E, $901, $101, $2509, $2002, $E, $40E
                dc.w $59, $51E, $101, $902, $808, $901, $F, $412
                dc.w $10, $426, $24, 0, 0, 0, 0
word_13D70:     dc.w $13, $A48, $202, 1, $401, $4407, $4008, $2E
                dc.w $40E, $4403, $4006, $4A03, $A11, $801, $1C, $40A
                dc.w 2, $4008, $14, $A09, $11, $40C, $440D, $407
                dc.w $4F, $41B, $A, $404, $4503, $4404, $4004, 1
                dc.w $409, $15, $A08, 8, $4013, $1E, $407, 5
                dc.w $A0A, $201, 1, $400E, $40B, $16, $410, $D
                dc.w $A0B, $17, $A11, $48, $203, $A2C, $202, $601
                dc.w $409, 2, $4023, 8, $40F, $4406, $4003, $4201
                dc.w $4A07, $4201, $13, $201, $A05, $201, $F, $202
                dc.w 3, $4009, $4206, $4003, $F, $40A, $D, $A36
                dc.w $4A13, $4202, $601, $40A, $12, $405, $4407, $4002
                dc.w 7, $A16, 5, $40A, $B, $205, 3, $404
                dc.w $10, $401B, $23, $A0E, $201, 2, $201, $A0B
                dc.w $4A03, $4005, $B, $A06, $201, $B, $408, $14
                dc.w $400E, $A1A, $15, $403, $514, $408, $4A, $4006
                dc.w $34, $410, $10, $A08, $801, $39, 0, 0
sub_13E70:
                bset    #7,(a0)
                bne.s   loc_13EA0
                move.l  #off_144AC,8(a0)
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addi.w  #$C,d7
                addi.w  #$18,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)
                move.b  #3,$3A(a0)

loc_13EA0:
                tst.b   (byte_FFD27B).w
                bne.s   locret_13EDC
                tst.b   (byte_FFD24F).w
                bne.s   loc_13EB6
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_13EDE(pc,d0.w)

loc_13EB6:
                move.w  $3C(a0),d0
                andi.w  #$7C,d0
                cmpi.w  #4,d0
                bcc.s   loc_13ECE
                tst.b   (byte_FFD24F).w
                bne.s   loc_13ECE
                bsr.w   sub_14476

loc_13ECE:
                bsr.w   sub_14272
                tst.b   (byte_FFD24E).w
                bne.s   locret_13EDC
                bsr.w   sub_11C3C

locret_13EDC:
                rts

loc_13EDE:
                bra.w   sub_13EEA
                bra.w   sub_1438C
                bra.w   sub_143FC

sub_13EEA:
                move.b  #$1E,5(a0)
                bsr.s   sub_13F26
                bsr.w   sub_142D6
                tst.b   (byte_FFD24F).w
                bne.s   loc_13F00
                bsr.w   sub_1130C

loc_13F00:
                bsr.w   sub_1105C
                bsr.w   sub_1407E
                bsr.w   sub_14128
                bsr.w   sub_14318
                move.l  $34(a0),d0
                beq.s   locret_13F24
                move.b  #1,$39(a0)
                tst.l   d0
                bmi.s   locret_13F24
                clr.b   $39(a0)

locret_13F24:
                rts

sub_13F26:
                move.b  (word_FFFF8E).w,d0
                andi.b  #$C,d0
                beq.w   loc_13FAA
                btst    #3,d0
                bne.w   loc_13FCE
                btst    #2,d0
                bne.w   loc_13FEC

loc_13F42:
                move.l  $30(a0),d2
                move.l  d1,$34(a0)
                tst.b   (byte_FFD24E).w
                bne.s   loc_13F54
                move.l  d1,(dword_FFD004).w

loc_13F54:
                bsr.w   sub_14038
                tst.b   $38(a0)
                bne.w   loc_1400A
                btst    #0,$3A(a0)
                beq.s   loc_13F98
                move.b  (word_FFFF8E).w,d0
                andi.b  #$70,d0
                beq.s   loc_13F98
                move.l  a0,-(sp)
                move.b  #$91,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                move.b  #1,$38(a0)
                move.l  #$FFFD7000,$2C(a0)
                bclr    #0,$3A(a0)
                bclr    #1,$3A(a0)

loc_13F98:
                move.b  (word_FFFF8E).w,d0
                andi.b  #$70,d0
                bne.s   locret_13FA8
                move.b  #3,$3A(a0)

locret_13FA8:
                rts

loc_13FAA:
                move.l  $34(a0),d1
                tst.b   $38(a0)
                bne.s   loc_13F42
                tst.l   d1
                beq.s   loc_13FCA
                tst.l   d1
                bmi.s   loc_13FC4
                subi.l  #$600,d1
                bra.s   loc_13FCA

loc_13FC4:
                addi.l  #$600,d1

loc_13FCA:
                bra.w   loc_13F42

loc_13FCE:
                move.l  $34(a0),d1
                cmpi.l  #$18000,d1
                bge.s   loc_13FE2
                addi.l  #$1800,d1
                bra.s   loc_13FE8

loc_13FE2:
                move.l  #$18000,d1

loc_13FE8:
                bra.w   loc_13F42

loc_13FEC:
                move.l  $34(a0),d1
                cmpi.l  #$FFFE8000,d1
                ble.s   loc_14000
                subi.l  #$1800,d1
                bra.s   loc_14006

loc_14000:
                move.l  #$FFFE8000,d1

loc_14006:
                bra.w   loc_13F42

loc_1400A:
                cmpi.l  #$30000,$2C(a0)
                bge.s   loc_1401C
                addi.l  #$1000,$2C(a0)

loc_1401C:
                move.b  (word_FFFF8E).w,d0
                andi.b  #$70,d0
                bne.s   locret_1402C
                move.b  #3,$3A(a0)

locret_1402C:
                rts

sub_1402E:
                clr.b   $38(a0)
                clr.l   $2C(a0)
                rts

sub_14038:
                btst    #1,$3A(a0)
                beq.s   locret_1407C
                move.b  (word_FFFF8E).w,d0
                andi.b  #$70,d0
                beq.s   locret_1407C
                tst.b   $3B(a0)
                beq.s   locret_1407C
                movea.l (dword_FFD250).w,a1
                move.w  #4,$34(a1)
                tst.b   $39(a0)
                beq.s   loc_14066
                move.w  #$FFFC,$34(a1)

loc_14066:
                move.w  #8,$3C(a1)
                move.l  $30(a0),$30(a1)
                clr.b   $3B(a0)
                bclr    #1,$3A(a0)

locret_1407C:
                rts

sub_1407E:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                tst.b   $38(a0)
                bne.s   loc_1409E
                addq.w  #1,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   locret_1409C
                move.b  #1,$38(a0)

locret_1409C:
                rts

loc_1409E:
                tst.l   $34(a0)
                bne.s   loc_140DA
                tst.l   $2C(a0)
                bpl.s   loc_140BC
                subi.w  #$E,d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_140BA
                clr.l   $2C(a0)

locret_140BA:
                rts

loc_140BC:
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_140D8
                clr.b   $38(a0)
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)

locret_140D8:
                rts

loc_140DA:
                tst.l   $2C(a0)
                bpl.s   loc_140FE
                subi.w  #$E,d6
                addq.w  #4,d7
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_140F8
                subq.w  #8,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_140FC

loc_140F8:
                clr.l   $2C(a0)

locret_140FC:
                rts

loc_140FE:
                subq.w  #4,d7
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_14112
                addq.w  #8,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_14126

loc_14112:
                clr.b   $38(a0)
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)

locret_14126:
                rts

sub_14128:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                move.l  $34(a0),d5
                tst.b   $38(a0)
                bne.s   loc_1419A
                subi.w  #$A,d6
                tst.l   d5
                beq.s   locret_1416E
                tst.l   d5
                bpl.s   loc_14170
                subq.w  #6,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_1416E
                move.l  $34(a0),d0
                subi.l  #$3000,d0
                cmpi.l  #$FFFE0200,d0
                bge.s   loc_14168
                move.l  #$FFFE0200,d0

loc_14168:
                neg.l   d0
                move.l  d0,$34(a0)

locret_1416E:
                rts

loc_14170:
                addq.w  #6,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_14198
                move.l  $34(a0),d0
                addi.l  #$3000,d0
                cmpi.l  #$1FE00,d0
                ble.s   loc_14192
                move.l  #$1FE00,d0

loc_14192:
                neg.l   d0
                move.l  d0,$34(a0)

locret_14198:
                rts

loc_1419A:
                subq.w  #8,d6
                tst.l   d5
                beq.w   loc_14248
                tst.l   d5
                bpl.s   loc_141DC
                subq.w  #6,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_141DA
                btst    #1,d4
                bne.s   loc_141BC
                btst    #0,d4
                beq.s   loc_14212

loc_141BC:
                move.l  $34(a0),d0
                subi.l  #$3000,d0
                cmpi.l  #$FFFE0200,d0
                bge.s   loc_141D4
                move.l  #$FFFE0200,d0

loc_141D4:
                neg.l   d0
                move.l  d0,$34(a0)

locret_141DA:
                rts

loc_141DC:
                addq.w  #6,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_14210
                btst    #1,d4
                bne.s   loc_141F2
                btst    #0,d4
                beq.s   loc_14212

loc_141F2:
                move.l  $34(a0),d0
                addi.l  #$3000,d0
                cmpi.l  #$1FE00,d0
                ble.s   loc_1420A
                move.l  #$1FE00,d0

loc_1420A:
                neg.l   d0
                move.l  d0,$34(a0)

locret_14210:
                rts

loc_14212:
                tst.l   $2C(a0)
                bpl.s   loc_14232
                move.w  d6,d0
                andi.w  #7,d0
                cmpi.w  #3,d0
                blt.s   locret_14230
                addi.w  #$10,d6
                move.w  d6,$24(a0)
                clr.l   $2C(a0)

locret_14230:
                rts

loc_14232:
                andi.w  #$FFF8,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                clr.l   $2C(a0)
                clr.b   $38(a0)
                rts

loc_14248:
                addq.w  #6,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_1425C
                move.l  #$FFFF4000,$34(a0)
                bra.s   locret_14270

loc_1425C:
                subi.w  #$C,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_14270
                move.l  #$C000,$34(a0)

locret_14270:
                rts

sub_14272:
                lea     (unk_FFD206).w,a2
                lea     (unk_FFD1FE).w,a1
                lea     (unk_FFD20A).w,a4
                lea     (unk_FFD202).w,a3
                moveq   #$3F,d0

loc_14284:
                move.l  (a1),(a2)
                move.l  (a3),(a4)
                subq.l  #8,a1
                subq.l  #8,a2
                subq.l  #8,a3
                subq.l  #8,a4
                dbf     d0,loc_14284
                lea     (byte_FFD24E).w,a2
                lea     (unk_FFD24D).w,a1
                moveq   #$3F,d0

loc_1429E:
                move.b  -(a1),-(a2)
                dbf     d0,loc_1429E
                move.l  $30(a0),(dword_FFD00E).w
                move.l  $24(a0),(dword_FFD012).w
                moveq   #0,d0
                tst.b   $38(a0)
                beq.s   loc_142BC
                bset    #7,d0

loc_142BC:
                move.l  $34(a0),d7
                beq.s   loc_142D0
                tst.l   d7
                bpl.s   loc_142CC
                bset    #1,d0
                bra.s   loc_142D0

loc_142CC:
                bset    #0,d0

loc_142D0:
                move.b  d0,(byte_FFD20E).w
                rts

sub_142D6:
                tst.b   (byte_FFD27A).w
                beq.s   locret_14316
                tst.b   $38(a0)
                bne.s   locret_14316
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                cmp.w   (word_FFD25C).w,d6
                bne.s   locret_14316
                cmp.w   (word_FFD25E).w,d7
                blt.s   locret_14316
                cmp.w   (word_FFD260).w,d7
                bgt.s   locret_14316
                move.b  #1,(byte_FFD24F).w
                clr.l   $34(a0)
                clr.l   (dword_FFD004).w
                addq.b  #1,(byte_FFD88D).w
                move.l  a0,-(sp)
                bsr.w   sub_11CE6
                movea.l (sp)+,a0

locret_14316:
                rts

sub_14318:
                bclr    #7,2(a0)
                move.l  $34(a0),d0
                move.b  (word_FFFF8E).w,d1
                tst.b   $38(a0)
                bne.s   loc_14366
                tst.l   d0
                beq.s   loc_1435C
                tst.l   d0
                bpl.s   loc_14342
                bset    #7,2(a0)
                btst    #2,d1
                bne.s   loc_14352
                bra.s   loc_14348

loc_14342:
                btst    #3,d1
                bne.s   loc_14352

loc_14348:
                move.l  #word_1A8A0,$C(a0)
                rts

loc_14352:
                clr.w   6(a0)
                bsr.w   sub_11126
                rts

loc_1435C:
                move.l  #word_1A898,$C(a0)
                rts

loc_14366:
                tst.l   d0
                beq.s   loc_14380
                move.w  #8,6(a0)
                tst.l   d0
                bpl.s   loc_1437A
                bset    #7,2(a0)

loc_1437A:
                bsr.w   sub_11126
                rts

loc_14380:
                move.w  #4,6(a0)
                bsr.w   sub_11126
                rts

sub_1438C:
                bset    #7,$3C(a0)
                bne.s   loc_143AE
                move.l  a0,-(sp)
                move.b  #$87,d0
                jsr     unk_FFFB66
                movea.l (sp)+,a0
                clr.b   5(a0)
                clr.l   $34(a0)
                move.w  #$C,6(a0)

loc_143AE:
                addi.l  #$1000,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_143E4
                tst.l   $2C(a0)
                bpl.s   loc_143DE
                subq.w  #8,d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_143DE
                clr.l   $2C(a0)

loc_143DE:
                bsr.w   sub_11126
                rts

loc_143E4:
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)
                move.w  #8,$3C(a0)
                rts

sub_143FC:
                bset    #7,$3C(a0)
                bne.s   loc_14418
                clr.b   5(a0)
                clr.b   $10(a0)
                bclr    #2,2(a0)
                move.b  #3,$39(a0)

loc_14418:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                bclr    #2,2(a0)
                beq.s   loc_14430
                subq.b  #1,$39(a0)
                bsr.w   sub_14464

loc_14430:
                tst.b   $39(a0)
                bne.s   locret_14462
                subq.b  #1,(byte_FFD882).w
                beq.s   loc_1445C
                move.b  #1,(byte_FFD886).w
                bsr.w   sub_11722
                move.w  #$20,(word_FFFFC0).w
                moveq   #$3C,d2

loc_1444E:
                bsr.w   sub_116BE
                jsr     unk_FFFB6C
                dbf     d2,loc_1444E
                bra.s   locret_14462

loc_1445C:
                move.w  #$10,(word_FFD2A0).w

locret_14462:
                rts

sub_14464:
                lea     (unk_FFC380).w,a1
                moveq   #2,d0

loc_1446A:
                clr.w   (a1)
                lea     $40(a1),a1
                dbf     d0,loc_1446A
                rts

sub_14476:
                lea     (unk_FFC380).w,a1
                moveq   #2,d1

loc_1447C:
                btst    #0,5(a1)
                beq.s   loc_144A2
                movem.w d1,-(sp)
                bsr.w   sub_117C0
                movem.w (sp)+,d1
                tst.b   d0
                beq.s   loc_144A2
                move.w  #4,$3C(a0)
                move.b  #1,(byte_FFD26D).w
                bra.s   locret_144AA

loc_144A2:
                lea     $40(a1),a1
                dbf     d1,loc_1447C

locret_144AA:
                rts

off_144AC:      dc.l byte_144BC
                dc.l byte_144C2
                dc.l byte_144C8
                dc.l byte_144CE
byte_144BC:     dc.b 2, 2
                dc.w byte_1A8A8-sub_10000
                dc.w byte_1A8B0-sub_10000
byte_144C2:     dc.b 2, 2
                dc.w byte_1A8B8-sub_10000
                dc.w byte_1A8C0-sub_10000
byte_144C8:     dc.b 2, 2
                dc.w byte_1A8C8-sub_10000
                dc.w word_1A8D0-sub_10000
byte_144CE:     dc.b 6, 3
                dc.w word_1A878-sub_10000
                dc.w word_1A880-sub_10000
                dc.w byte_1A888-sub_10000
                dc.w word_1A890-sub_10000
                dc.w byte_1A888-sub_10000
                dc.w word_1A890-sub_10000
sub_144DC:
                bset    #7,(a0)
                bne.s   loc_14504
                move.b  (byte_FFD834).w,d7
                move.b  (byte_FFD835).w,d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addi.w  #$18,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)
                move.l  #off_14524,8(a0)

loc_14504:
                move.w  $3C(a0),d0
                andi.w  #$7FFC,d0
                jsr     loc_14516(pc,d0.w)
                bsr.w   sub_1105C
                rts

loc_14516:
                bra.w   sub_1451E
                bra.w   nullsub_3

sub_1451E:
                bsr.w   sub_11126

nullsub_3:
                rts

off_14524:      dc.l byte_14528
byte_14528:     dc.b 2, 8
                dc.w word_1AD82-sub_10000
                dc.w word_1AD8A-sub_10000
sub_1452E:
                bset    #7,(a0)
                bne.s   loc_1455E
                move.l  (dword_FFD828).w,d0
                move.l  d0,$C(a0)
                move.b  #$60,$13(a0)
                moveq   #0,d7
                moveq   #0,d6
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addq.w  #8,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)

loc_1455E:
                tst.b   (byte_FFD27B).w
                bne.s   locret_1457A
                tst.b   (byte_FFD24F).w
                bne.s   locret_1457A
                tst.b   (byte_FFD26D).w
                bne.s   locret_1457A
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_1457C(pc,d0.w)

locret_1457A:
                rts

loc_1457C:
                bra.w   sub_14588
                bra.w   sub_145BC
                bra.w   sub_14610

sub_14588:
                move.b  #1,5(a0)
                lea     (word_FFC440).w,a1
                tst.l   dword_FFC46C-word_FFC440(a1)
                bmi.s   loc_145B6
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_145B6
                tst.b   $3B(a1)
                bne.s   loc_145B6
                move.w  #4,$3C(a0)
                move.b  #1,$3B(a1)
                move.l  a0,(dword_FFD250).w

loc_145B6:
                bsr.w   sub_1105C
                rts

sub_145BC:
                bset    #7,$3C(a0)
                bne.s   loc_145D0
                move.l  a0,-(sp)
                move.b  #$92,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0

loc_145D0:
                clr.b   5(a0)
                lea     (word_FFC440).w,a1
                move.l  dword_FFC470-word_FFC440(a1),d7
                move.l  $24(a1),d6
                tst.b   $38(a1)
                beq.s   loc_145EE
                addi.l  #$60000,d6
                bra.s   loc_14602

loc_145EE:
                tst.b   $39(a1)
                bne.s   loc_145FC
                addi.l  #$80000,d7
                bra.s   loc_14602

loc_145FC:
                subi.l  #$80000,d7

loc_14602:
                move.l  d7,$30(a0)
                move.l  d6,$24(a0)
                bsr.w   sub_1105C
                rts

sub_14610:
                bset    #7,$3C(a0)
                bne.s   loc_14650
                move.l  a0,-(sp)
                move.b  #$96,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                move.b  #$18,5(a0)
                move.l  #off_14730,8(a0)
                clr.b   $3B(a0)
                moveq   #0,d0
                move.b  (word_FFD82C+1).w,d0

loc_1463C:
                cmpi.b  #$F,d0
                bls.s   loc_14648
                subi.b  #$F,d0
                bra.s   loc_1463C

loc_14648:
                subq.b  #1,d0
                lsl.w   #2,d0
                move.w  d0,6(a0)

loc_14650:
                bsr.w   sub_14688
                tst.l   $34(a0)
                bne.s   loc_1465C
                clr.w   (a0)

loc_1465C:
                bsr.w   sub_14662
                rts

sub_14662:
                move.w  $20(a0),d7
                move.w  d7,d6
                lea     (word_FFC440).w,a1
                move.w  word_FFC460-word_FFC440(a1),d5
                move.w  d5,d4
                sub.w   d7,d5
                cmpi.w  #$7C,d5
                bge.s   loc_14684
                sub.w   d4,d6
                cmpi.w  #$7C,d6
                bge.s   loc_14684
                bra.s   locret_14686

loc_14684:
                clr.w   (a0)

locret_14686:
                rts

sub_14688:
                move.l  $34(a0),d7
                move.l  $2C(a0),d6
                bclr    #7,2(a0)
                tst.l   d7
                bpl.s   loc_146A0
                bset    #7,2(a0)

loc_146A0:
                bsr.w   sub_11126
                tst.b   $38(a0)
                bne.s   loc_146BE
                tst.l   d7
                bpl.s   loc_146B6
                addi.l  #$800,d7
                bra.s   loc_146BC

loc_146B6:
                subi.l  #$800,d7

loc_146BC:
                bra.s   loc_146C4

loc_146BE:
                addi.l  #$1000,d6

loc_146C4:
                move.l  d7,$34(a0)
                move.l  d6,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                addq.w  #1,d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_146FA
                clr.l   $2C(a0)
                clr.b   $38(a0)
                move.w  d6,d5
                andi.w  #$FFF8,d5
                move.w  d5,$24(a0)
                clr.w   $26(a0)
                bra.s   loc_14700

loc_146FA:
                move.b  #1,$38(a0)

loc_14700:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subq.w  #4,d6
                tst.l   $34(a0)
                bpl.s   loc_14720
                subq.w  #4,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_1471E
                neg.l   $34(a0)

locret_1471E:
                rts

loc_14720:
                addq.w  #4,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   locret_1472E
                neg.l   $34(a0)

locret_1472E:
                rts

off_14730:      dc.l byte_1476C
                dc.l byte_1477A
                dc.l byte_14788
                dc.l byte_14796
                dc.l byte_147A4
                dc.l byte_147B2
                dc.l byte_147C0
                dc.l byte_147CE
                dc.l byte_147DC
                dc.l byte_147EA
                dc.l byte_147F8
                dc.l byte_14806
                dc.l byte_14814
                dc.l byte_14822
                dc.l byte_14830
byte_1476C:     dc.b 6, 1
                dc.w word_1A4E8-sub_10000
                dc.w word_1A4F8-sub_10000
                dc.w word_1A508-sub_10000
                dc.w word_1A4F0-sub_10000
                dc.w word_1A510-sub_10000
                dc.w word_1A500-sub_10000
byte_1477A:     dc.b 6, 1
                dc.w word_1A518-sub_10000
                dc.w word_1A528-sub_10000
                dc.w word_1A538-sub_10000
                dc.w word_1A520-sub_10000
                dc.w word_1A540-sub_10000
                dc.w word_1A530-sub_10000
byte_14788:     dc.b 6, 1
                dc.w word_1A548-sub_10000
                dc.w word_1A558-sub_10000
                dc.w word_1A568-sub_10000
                dc.w word_1A550-sub_10000
                dc.w word_1A570-sub_10000
                dc.w word_1A560-sub_10000
byte_14796:     dc.b 6, 1
                dc.w word_1A578-sub_10000
                dc.w word_1A588-sub_10000
                dc.w word_1A598-sub_10000
                dc.w word_1A580-sub_10000
                dc.w word_1A5A0-sub_10000
                dc.w word_1A590-sub_10000
byte_147A4:     dc.b 6, 1
                dc.w word_1A5A8-sub_10000
                dc.w word_1A5B8-sub_10000
                dc.w word_1A5C8-sub_10000
                dc.w word_1A5B0-sub_10000
                dc.w word_1A5D0-sub_10000
                dc.w word_1A5C0-sub_10000
byte_147B2:     dc.b 6, 1
                dc.w word_1A5D8-sub_10000
                dc.w word_1A5E8-sub_10000
                dc.w word_1A5F8-sub_10000
                dc.w word_1A5E0-sub_10000
                dc.w word_1A600-sub_10000
                dc.w word_1A5F0-sub_10000
byte_147C0:     dc.b 6, 1
                dc.w word_1A608-sub_10000
                dc.w word_1A618-sub_10000
                dc.w word_1A628-sub_10000
                dc.w word_1A610-sub_10000
                dc.w word_1A630-sub_10000
                dc.w word_1A620-sub_10000
byte_147CE:     dc.b 6, 1
                dc.w word_1A638-sub_10000
                dc.w word_1A648-sub_10000
                dc.w word_1A658-sub_10000
                dc.w word_1A640-sub_10000
                dc.w word_1A660-sub_10000
                dc.w word_1A650-sub_10000
byte_147DC:     dc.b 6, 1
                dc.w word_1A668-sub_10000
                dc.w word_1A678-sub_10000
                dc.w word_1A688-sub_10000
                dc.w word_1A670-sub_10000
                dc.w word_1A690-sub_10000
                dc.w word_1A680-sub_10000
byte_147EA:     dc.b 6, 1
                dc.w word_1A698-sub_10000
                dc.w word_1A6A8-sub_10000
                dc.w word_1A6B8-sub_10000
                dc.w word_1A6A0-sub_10000
                dc.w word_1A6C0-sub_10000
                dc.w word_1A6B0-sub_10000
byte_147F8:     dc.b 6, 1
                dc.w word_1A6C8-sub_10000
                dc.w word_1A6D8-sub_10000
                dc.w word_1A6E8-sub_10000
                dc.w word_1A6D0-sub_10000
                dc.w word_1A6F0-sub_10000
                dc.w word_1A6E0-sub_10000
byte_14806:     dc.b 6, 1
                dc.w word_1A6F8-sub_10000
                dc.w word_1A708-sub_10000
                dc.w word_1A718-sub_10000
                dc.w word_1A700-sub_10000
                dc.w word_1A720-sub_10000
                dc.w word_1A710-sub_10000
byte_14814:     dc.b 6, 1
                dc.w word_1A728-sub_10000
                dc.w word_1A738-sub_10000
                dc.w word_1A748-sub_10000
                dc.w word_1A730-sub_10000
                dc.w word_1A750-sub_10000
                dc.w word_1A740-sub_10000
byte_14822:     dc.b 6, 1
                dc.w word_1A758-sub_10000
                dc.w word_1A768-sub_10000
                dc.w word_1A778-sub_10000
                dc.w word_1A760-sub_10000
                dc.w word_1A780-sub_10000
                dc.w word_1A770-sub_10000
byte_14830:     dc.b 6, 1
                dc.w word_1A788-sub_10000
                dc.w word_1A798-sub_10000
                dc.w word_1A7A8-sub_10000
                dc.w word_1A790-sub_10000
                dc.w word_1A7B0-sub_10000
                dc.w word_1A7A0-sub_10000
sub_1483E:
                bset    #7,(a0)
                bne.s   loc_14874
                move.l  #off_14E12,8(a0)
                tst.b   $3A(a0)
                beq.s   loc_1485A
                move.l  #off_14E22,8(a0)

loc_1485A:
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addi.w  #$10,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)

loc_14874:
                tst.b   (byte_FFD27B).w
                bne.s   locret_14898
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_1489A(pc,d0.w)
                move.l  $34(a0),d0
                beq.s   locret_14898
                move.b  #1,$39(a0)
                tst.l   d0
                bmi.s   locret_14898
                clr.b   $39(a0)

locret_14898:
                rts

loc_1489A:
                bra.w   sub_148AA
                bra.w   sub_14918
                bra.w   sub_14B42
                bra.w   sub_14D86

sub_148AA:
                tst.b   (byte_FFD24F).w
                bne.s   locret_14916
                bset    #7,$3C(a0)
                bne.s   loc_148C6
                move.b  #$30,$3B(a0)
                move.l  #$FFFFE000,$2C(a0)

loc_148C6:
                clr.w   6(a0)
                subq.b  #1,$3B(a0)
                bne.s   loc_148DA
                neg.l   $2C(a0)
                move.b  #$30,$3B(a0)

loc_148DA:
                lea     (word_FFC440).w,a1
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_1490E
                move.l  a0,-(sp)
                move.b  #$90,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                move.w  #4,$3C(a0)
                addq.b  #1,(byte_FFD27A).w
                move.b  (byte_FFD27A).w,$38(a0)
                move.l  #$10,(dword_FFD262).w
                bsr.w   sub_1168A

loc_1490E:
                bsr.w   sub_11126
                bsr.w   sub_1105C

locret_14916:
                rts

sub_14918:
                bset    #7,$3C(a0)
                bne.s   loc_14928
                clr.l   $34(a0)
                clr.l   $2C(a0)

loc_14928:
                tst.b   (byte_FFD26D).w
                beq.s   loc_14940
                clr.b   $38(a0)
                subq.b  #1,(byte_FFD27A).w
                move.w  #8,$3C(a0)
                bra.w   loc_14A12

loc_14940:
                moveq   #0,d0
                move.b  $38(a0),d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                lea     byte_14A58(pc),a1
                move.w  (a1,d0.w),d1
                movea.l d1,a1
                move.l  (a1),$30(a0)
                move.l  4(a1),$24(a0)
                bsr.w   sub_110BA
                lea     byte_14A6A(pc),a1
                move.w  (a1,d0.w),d1
                movea.l d1,a1
                moveq   #0,d1
                move.b  (a1),d1
                move.w  d1,-(sp)
                tst.b   (byte_FFD24F).w
                bne.s   loc_1497C
                bsr.w   sub_14AF0

loc_1497C:
                move.w  (sp)+,d1
                tst.b   (byte_FFD24F).w
                beq.s   loc_149F2
                lea     (word_FFC440).w,a1
                move.w  dword_FFC470-word_FFC440(a1),d7
                move.w  $24(a1),d6
                cmp.w   $30(a0),d7
                bne.s   loc_149F2
                cmp.w   $24(a0),d6
                bne.s   loc_149F2
                move.l  a0,-(sp)
                move.b  #$94,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                clr.w   (a0)
                bsr.w   sub_14A7C
                subq.b  #1,(byte_FFD883).w
                bne.s   loc_149CE
                move.b  #1,(byte_FFD281).w
                clr.w   (word_FFFF92).w
                move.b  (dword_FFD888).w,(byte_FFD266).w
                move.b  (dword_FFD888+1).w,(byte_FFD267).w
                bsr.w   sub_14DD4

loc_149CE:
                move.l  a0,-(sp)
                moveq   #2,d1

loc_149D2:
                jsr     unk_FFFB6C
                dbf     d1,loc_149D2
                movea.l (sp)+,a0
                clr.b   $38(a0)
                subq.b  #1,(byte_FFD27A).w
                bne.s   loc_149F2
                clr.b   (byte_FFD24F).w
                move.l  a0,-(sp)
                bsr.w   sub_11D18
                movea.l (sp)+,a0

loc_149F2:
                tst.b   (byte_FFD281).w
                beq.s   loc_14A12
                move.b  #1,(byte_FFD24F).w
                move.w  #$C,(word_FFD2A0).w
                cmpi.b  #1,(byte_FFD88D).w
                beq.s   loc_14A12
                move.b  #1,(byte_FFD88F).w

loc_14A12:
                bclr    #7,2(a0)
                clr.b   $39(a0)
                move.b  d1,d0
                andi.b  #3,d0
                bne.s   loc_14A2A
                clr.w   6(a0)
                bra.s   loc_14A4E

loc_14A2A:
                btst    #0,d1
                bne.s   loc_14A3C
                bset    #7,2(a0)
                move.b  #1,$39(a0)

loc_14A3C:
                tst.b   d1
                bmi.s   loc_14A48
                move.w  #8,6(a0)
                bra.s   loc_14A4E

loc_14A48:
                move.w  #4,6(a0)

loc_14A4E:
                bsr.w   sub_11126
                bsr.w   sub_110BA
                rts

byte_14A58:     dc.b 0, 0
                dc.w $D036, $D05E, $D086, $D0AE, $D0D6, $D0FE, $D126, $D14E
byte_14A6A:     dc.b 0, 0
                dc.w $D213, $D218, $D21D, $D222, $D227, $D22C, $D231, $D236
sub_14A7C:
                moveq   #0,d0
                move.b  $38(a0),d0
                subq.b  #1,d0
                lsl.w   #2,d0
                move.l  dword_14AC0(pc,d0.w),d0
                move.l  d0,(dword_FFD262).w
                bsr.w   sub_1168A
                moveq   #0,d0
                move.b  $38(a0),d0
                move.b  d0,d1
                subq.b  #1,d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d2
                lea     word_14AE0(pc),a2
                move.w  (a2,d0.w),d2
                movea.l d2,a2
                move.w  #$20,(a2)
                move.b  d1,$3A(a2)
                lea     (word_FFC440).w,a1
                move.w  dword_FFC470-word_FFC440(a1),d7
                move.w  d7,$30(a2)
                rts

dword_14AC0:    dc.l $100
                dc.l $200
                dc.l $300
                dc.l $400
                dc.l $500
                dc.l $1000
                dc.l $2000
                dc.l $5000
word_14AE0:     dc.w $C100, $C140, $C180, $C1C0, $C100, $C140, $C180, $C1C0
sub_14AF0:
                lea     (unk_FFC380).w,a1
                moveq   #1,d0

loc_14AF6:
                move.w  d0,-(sp)
                btst    #1,5(a1)
                beq.s   loc_14B30
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_14B30
                move.b  $38(a0),d0
                lea     (unk_FFC480).w,a2
                moveq   #7,d1

loc_14B12:
                cmp.b   $38(a2),d0
                bhi.s   loc_14B26
                clr.b   $38(a2)
                subq.b  #1,(byte_FFD27A).w
                move.w  #8,$3C(a2)

loc_14B26:
                lea     $40(a2),a2
                dbf     d1,loc_14B12
                bra.s   loc_14B3C

loc_14B30:
                lea     $40(a1),a1
                move.w  (sp)+,d0
                dbf     d0,loc_14AF6
                rts

loc_14B3C:
                move.w  (sp)+,d0
                rts

nullsub_4:
                rts

sub_14B42:
                tst.b   $3A(a0)
                bne.w   sub_14C6A
                bset    #7,$3C(a0)
                bne.s   loc_14B76
                moveq   #0,d0
                move.w  a0,d0
                subi.w  #$C480,d0
                lsr.w   #4,d0
                lea     dword_14C4A(pc),a1
                move.l  (a1,d0.w),$34(a0)
                tst.b   $39(a0)
                beq.s   loc_14B70
                neg.l   $34(a0)

loc_14B70:
                move.w  #8,6(a0)

loc_14B76:
                bsr.w   sub_1105C
                tst.l   $2C(a0)
                bne.w   loc_14BF8
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                addq.w  #1,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_14BA4
                addi.l  #$1000,$2C(a0)
                move.w  #4,6(a0)
                bra.s   loc_14BF6

loc_14BA4:
                move.l  $34(a0),d0
                beq.s   loc_14BBA
                tst.b   $39(a0)
                bne.s   loc_14BC6
                subi.l  #$400,$34(a0)
                bra.s   sub_14BDC

loc_14BBA:
                clr.l   $34(a0)
                move.w  #$C,$3C(a0)
                bra.s   loc_14BF6

loc_14BC6:
                addi.l  #$400,$34(a0)
                bra.s   sub_14BDC

sub_14BD0:
                clr.l   $34(a0)
                move.w  #$C,$3C(a0)
                bra.s   loc_14BF6

sub_14BDC:
                subq.w  #6,d6
                moveq   #4,d0
                tst.l   $34(a0)
                bpl.s   loc_14BE8
                neg.w   d0

loc_14BE8:
                add.w   d0,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_14BF6
                neg.l   $34(a0)

loc_14BF6:
                bra.s   loc_14C2E

loc_14BF8:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_14C20
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)
                move.w  #8,6(a0)
                bra.s   loc_14C2E

loc_14C20:
                addi.l  #$1000,$2C(a0)
                move.w  #4,6(a0)

loc_14C2E:
                bclr    #7,2(a0)
                tst.l   $34(a0)
                bpl.s   loc_14C40
                bset    #7,2(a0)

loc_14C40:
                bsr.w   sub_11126
                bsr.w   sub_14D52
                rts

dword_14C4A:    dc.l $A000
                dc.l $C000
                dc.l $E000
                dc.l $10000
                dc.l $12000
                dc.l $14000
                dc.l $16000
                dc.l $18000
sub_14C6A:
                bset    #7,$3C(a0)
                bne.s   loc_14C96
                moveq   #0,d0
                move.w  a0,d0
                subi.w  #$C480,d0
                lsr.w   #4,d0
                lea     dword_14D32(pc),a1
                move.l  (a1,d0.w),$34(a0)
                tst.b   $39(a0)
                beq.s   loc_14C90
                neg.l   $34(a0)

loc_14C90:
                move.w  #8,6(a0)

loc_14C96:
                bsr.w   sub_1105C
                tst.l   $2C(a0)
                bne.w   loc_14CE0
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                addq.w  #1,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_14CC4
                addi.l  #$1000,$2C(a0)
                move.w  #4,6(a0)
                bra.s   loc_14CDE

loc_14CC4:
                subq.w  #6,d6
                moveq   #4,d0
                tst.l   $34(a0)
                bpl.s   loc_14CD0
                neg.w   d0

loc_14CD0:
                add.w   d0,d7
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_14CDE
                neg.l   $34(a0)

loc_14CDE:
                bra.s   loc_14D16

loc_14CE0:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_14D08
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)
                move.w  #8,6(a0)
                bra.s   loc_14D16

loc_14D08:
                addi.l  #$1000,$2C(a0)
                move.w  #4,6(a0)

loc_14D16:
                bclr    #7,2(a0)
                tst.l   $34(a0)
                bpl.s   loc_14D28
                bset    #7,2(a0)

loc_14D28:
                bsr.w   sub_11126
                bsr.w   sub_14D52
                rts

dword_14D32:    dc.l $C000
                dc.l $D000
                dc.l $E000
                dc.l $F000
                dc.l $10000
                dc.l $11000
                dc.l $12000
                dc.l $13000
sub_14D52:
                lea     (word_FFC440).w,a1
                move.w  word_FFC47C-word_FFC440(a1),d0
                andi.w  #$7C,d0
                bne.s   locret_14D84
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   locret_14D84
                move.l  a0,-(sp)
                move.b  #$90,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                move.w  #4,$3C(a0)
                addq.b  #1,(byte_FFD27A).w
                move.b  (byte_FFD27A).w,$38(a0)

locret_14D84:
                rts

sub_14D86:
                bsr.w   sub_1105C
                bset    #7,$3C(a0)
                bne.s   loc_14DA2
                bclr    #2,2(a0)
                move.w  #$C,6(a0)
                clr.b   $10(a0)

loc_14DA2:
                bsr.w   sub_1105C
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   loc_14DB8
                bset    #7,2(a0)

loc_14DB8:
                bsr.w   sub_11126
                bclr    #2,2(a0)
                beq.s   loc_14DD0
                bchg    #0,$39(a0)
                move.w  #8,$3C(a0)

loc_14DD0:
                bsr.s   sub_14D52
                rts

sub_14DD4:
                clr.l   (dword_FFD268).w
                tst.b   (byte_FFD266).w
                bne.s   locret_14DF8
                moveq   #0,d0
                move.b  (byte_FFD267).w,d0
                lsr.w   #4,d0
                lsl.w   #2,d0
                move.l  dword_14DFA(pc,d0.w),d0
                move.l  d0,(dword_FFD268).w
                move.l  d0,(dword_FFD262).w
                bsr.w   sub_1168A

locret_14DF8:
                rts

dword_14DFA:    dc.l $20000
                dc.l $20000
                dc.l $10000
                dc.l $5000
                dc.l $3000
                dc.l $1000
off_14E12:      dc.l byte_14E32
                dc.l byte_14E96
                dc.l byte_14EA2
                dc.l byte_14EB2
off_14E22:      dc.l byte_14E64
                dc.l byte_14E9C
                dc.l byte_14EAA
                dc.l byte_14EBC
byte_14E32:     dc.b $18, 4
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7B8-sub_10000
                dc.w word_1A7C0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
                dc.w word_1A7C8-sub_10000
                dc.w word_1A7D0-sub_10000
byte_14E64:     dc.b $18, 4
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A818-sub_10000
                dc.w word_1A820-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
                dc.w word_1A828-sub_10000
                dc.w word_1A830-sub_10000
byte_14E96:     dc.b 2, 3
                dc.w word_1A7D8-sub_10000
                dc.w word_1A7E0-sub_10000
byte_14E9C:     dc.b 2, 3
                dc.w word_1A838-sub_10000
                dc.w word_1A840-sub_10000
byte_14EA2:     dc.b 3, 4
                dc.w word_1A7E8-sub_10000
                dc.w word_1A7F0-sub_10000
                dc.w word_1A7F8-sub_10000
byte_14EAA:     dc.b 3, 4
                dc.w word_1A848-sub_10000
                dc.w word_1A850-sub_10000
                dc.w word_1A858-sub_10000
byte_14EB2:     dc.b 4, $A
                dc.w word_1A800-sub_10000
                dc.w word_1A800-sub_10000
                dc.w word_1A808-sub_10000
                dc.w word_1A810-sub_10000
byte_14EBC:     dc.b 4, $A
                dc.w word_1A860-sub_10000
                dc.w word_1A860-sub_10000
                dc.w word_1A868-sub_10000
                dc.w word_1A870-sub_10000
sub_14EC6:
                bset    #7,(a0)
                bne.s   loc_14EFA
                moveq   #0,d7
                moveq   #0,d6
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addi.w  #$10,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)
                move.l  #off_154AE,8(a0)
                clr.l   $34(a0)
                clr.l   $2C(a0)

loc_14EFA:
                tst.b   (byte_FFD27B).w
                bne.s   loc_14F2E
                tst.b   (byte_FFD24F).w
                bne.s   loc_14F2E
                tst.b   (byte_FFD26D).w
                bne.s   loc_14F2E
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_14F44(pc,d0.w)
                move.w  $3C(a0),d0
                andi.w  #$7FFC,d0
                cmpi.w  #$14,d0
                beq.s   loc_14F2E
                cmpi.w  #$1C,d0
                beq.s   loc_14F2E
                bsr.w   sub_1540A

loc_14F2E:
                move.l  $34(a0),d0
                beq.s   locret_14F42
                move.b  #1,$39(a0)
                tst.l   d0
                bmi.s   locret_14F42
                clr.b   $39(a0)

locret_14F42:
                rts

loc_14F44:
                bra.w   sub_14F64
                bra.w   sub_14FD2
                bra.w   sub_15068
                bra.w   sub_1515A
                bra.w   sub_15256
                bra.w   sub_152B4
                bra.w   sub_152F6
                bra.w   sub_153A4

sub_14F64:
                bset    #7,$3C(a0)
                bne.s   loc_14F80
                clr.w   6(a0)
                bclr    #2,2(a0)
                clr.b   $10(a0)
                move.b  #6,5(a0)

loc_14F80:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                bclr    #2,2(a0)
                beq.s   locret_14FD0
                move.w  #8,$3C(a0)
                lea     (word_FFC440).w,a1
                move.w  $20(a0),d7
                move.w  $20(a1),d6
                clr.b   $39(a0)
                cmp.w   d7,d6
                bgt.s   loc_14FB0
                move.b  #1,$39(a0)

loc_14FB0:
                cmpi.w  #$30,(dword_FFD888).w
                bhi.s   locret_14FD0
                cmpi.b  #$31,(word_FFD82C+1).w
                bhi.s   locret_14FD0
                clr.b   $39(a0)
                tst.b   $16(a0)
                beq.s   locret_14FD0
                move.b  #1,$39(a0)

locret_14FD0:
                rts

sub_14FD2:
                bset    #7,$3C(a0)
                bne.s   loc_15004
                move.b  #7,5(a0)
                clr.l   $34(a0)
                move.b  #$14,$3B(a0)
                move.l  #word_1A918,$C(a0)
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   loc_15004
                bset    #7,2(a0)

loc_15004:
                bsr.w   sub_1105C
                move.w  $20(a0),d7
                move.w  $24(a0),d6
                lea     (word_FFC440).w,a1
                move.w  word_FFC460-word_FFC440(a1),d5
                move.w  $24(a1),d4
                cmp.w   d6,d4
                beq.s   loc_1502E
                move.b  #2,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

loc_1502E:
                tst.b   $39(a0)
                bne.s   loc_1504E
                cmp.w   d7,d5
                bgt.s   loc_15040
                move.w  #$10,$3C(a0)
                rts

loc_15040:
                move.b  #1,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

loc_1504E:
                cmp.w   d7,d5
                blt.s   loc_1505A
                move.w  #$10,$3C(a0)
                rts

loc_1505A:
                move.b  #1,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

sub_15068:
                bset    #7,$3C(a0)
                bne.s   loc_15094
                move.b  #7,5(a0)
                move.l  (dword_FFD296).w,$34(a0)
                tst.b   $16(a0)
                beq.s   loc_1508A
                move.l  #loc_14000,$34(a0)

loc_1508A:
                tst.b   $39(a0)
                beq.s   loc_15094
                neg.l   $34(a0)

loc_15094:
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subq.w  #8,d6
                tst.l   $34(a0)
                bpl.s   loc_150AC
                subq.w  #8,d7
                bra.s   loc_150AE

loc_150AC:
                addq.w  #8,d7

loc_150AE:
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_150BA
                neg.l   $34(a0)

loc_150BA:
                moveq   #0,d7
                moveq   #1,d6
                bsr.w   sub_115C0
                btst    #7,d4
                bne.s   loc_150EA
                tst.l   $34(a0)
                bpl.s   loc_150DC
                btst    #2,d4
                bne.s   loc_150DA
                move.w  #4,$3C(a0)

loc_150DA:
                bra.s   loc_15114

loc_150DC:
                btst    #3,d4
                bne.s   loc_150E8
                move.w  #4,$3C(a0)

loc_150E8:
                bra.s   loc_15114

loc_150EA:
                tst.b   $39(a0)
                bne.s   loc_150F8
                btst    #6,d4
                bne.s   loc_15114
                bra.s   loc_150FE

loc_150F8:
                btst    #6,d4
                beq.s   loc_15114

loc_150FE:
                lea     (word_FFC440).w,a1
                move.w  $24(a0),d6
                cmp.w   $24(a1),d6
                blt.s   loc_15114
                beq.s   loc_15132
                move.w  #$18,$3C(a0)

loc_15114:
                bclr    #7,2(a0)
                tst.l   $34(a0)
                bpl.s   loc_15126
                bset    #7,2(a0)

loc_15126:
                move.w  #4,6(a0)
                bsr.w   sub_11126
                rts

loc_15132:
                cmpi.w  #$30,(dword_FFD888).w
                bls.s   loc_15114
                move.w  $20(a1),d7
                tst.b   $39(a0)
                beq.s   loc_1514C
                cmp.w   $20(a0),d7
                blt.s   loc_15114
                bra.s   loc_15152

loc_1514C:
                cmp.w   $20(a0),d7
                bgt.s   loc_15114

loc_15152:
                move.w  #$18,$3C(a0)
                bra.s   loc_15114

sub_1515A:
                tst.b   $3B(a0)
                bne.w   loc_1524C
                bset    #7,$3C(a0)
                bne.s   loc_151B4
                move.b  #7,5(a0)
                move.b  $3A(a0),d0
                beq.s   loc_1518C
                cmpi.b  #1,d0
                beq.s   loc_1519A
                move.l  (dword_FFD276).w,$34(a0)
                move.l  #$FFFF8000,$2C(a0)
                bra.s   loc_151AA

loc_1518C:
                move.l  (dword_FFD26E).w,$34(a0)
                move.l  (dword_FFD272).w,$2C(a0)
                bra.s   loc_151AA

loc_1519A:
                move.l  #$1A000,$34(a0)
                move.l  #$FFFF0000,$2C(a0)

loc_151AA:
                tst.b   $39(a0)
                beq.s   loc_151B4
                neg.l   $34(a0)

loc_151B4:
                addi.l  #$1000,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_1520C
                subq.w  #8,d6
                tst.l   $34(a0)
                bpl.s   loc_151DC
                subq.w  #8,d7
                bra.s   loc_151DE

loc_151DC:
                addq.w  #8,d7

loc_151DE:
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_151EC
                neg.l   $34(a0)
                bra.s   loc_15222

loc_151EC:
                tst.l   $2C(a0)
                bpl.s   loc_1520A
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subi.w  #$D,d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_1520A
                clr.l   $2C(a0)

loc_1520A:
                bra.s   loc_15222

loc_1520C:
                clr.l   $2C(a0)
                andi.w  #$FFF8,d6
                clr.w   $26(a0)
                move.w  d6,$24(a0)
                move.w  #8,$3C(a0)

loc_15222:
                move.l  #word_1A970,$C(a0)
                tst.l   $2C(a0)
                bmi.s   loc_15238
                move.l  #word_1A97E,$C(a0)

loc_15238:
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   locret_1524A
                bset    #7,2(a0)

locret_1524A:
                rts

loc_1524C:
                subq.b  #1,$3B(a0)
                bsr.w   sub_1105C
                rts

sub_15256:
                tst.b   $3B(a0)
                bne.s   loc_152AA
                bset    #7,$3C(a0)
                bne.s   loc_1527A
                move.b  #7,5(a0)
                bclr    #2,2(a0)
                move.w  #$C,6(a0)
                clr.b   $10(a0)

loc_1527A:
                bsr.w   sub_1105C
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   loc_15290
                bset    #7,2(a0)

loc_15290:
                bsr.w   sub_11126
                bclr    #2,2(a0)
                beq.s   locret_152A8
                bchg    #0,$39(a0)
                move.w  #8,$3C(a0)

locret_152A8:
                rts

loc_152AA:
                subq.b  #1,$3B(a0)
                bsr.w   sub_1105C
                rts

sub_152B4:
                bset    #7,$3C(a0)
                bne.s   loc_152E4
                move.l  a0,-(sp)
                move.b  #$93,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                tst.b   $16(a0)
                bne.s   loc_152D6
                addi.l  #$1000,(dword_FFD296).w

loc_152D6:
                clr.b   5(a0)
                move.w  #8,6(a0)
                subq.b  #1,(byte_FFD26C).w

loc_152E4:
                bsr.w   sub_14688
                tst.l   $34(a0)
                bne.s   locret_152F4
                move.w  #$1C,$3C(a0)

locret_152F4:
                rts

sub_152F6:
                bset    #7,$3C(a0)
                bne.s   loc_15328
                move.b  #7,5(a0)
                clr.l   $34(a0)
                move.b  #$14,$3B(a0)
                move.l  #word_1A918,$C(a0)
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   loc_15328
                bset    #7,2(a0)

loc_15328:
                bsr.w   sub_1105C
                move.w  $20(a0),d7
                move.w  $24(a0),d6
                lea     (word_FFC440).w,a1
                move.w  word_FFC460-word_FFC440(a1),d5
                move.w  $24(a1),d4
                cmp.w   d6,d4
                beq.s   loc_15360
                bgt.s   loc_15352
                clr.b   $3A(a0)
                move.w  #$C,$3C(a0)
                rts

loc_15352:
                move.b  #2,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

loc_15360:
                tst.b   $39(a0)
                bne.s   loc_15380
                cmp.w   d7,d5
                bgt.s   loc_15372
                move.w  #$10,$3C(a0)
                rts

loc_15372:
                move.b  #1,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

loc_15380:
                cmp.w   d7,d5
                blt.s   loc_1538C
                move.w  #$10,$3C(a0)
                rts

loc_1538C:
                move.b  #1,$3A(a0)
                move.w  #$C,$3C(a0)
                rts

sub_1539A:
                subq.b  #1,$3B(a0)
                bsr.w   sub_1105C
                rts

sub_153A4:
                bset    #7,$3C(a0)
                bne.s   loc_153C8
                clr.b   5(a0)
                bclr    #2,2(a0)
                move.w  #$10,6(a0)
                clr.b   $10(a0)
                move.l  #$FFFFC000,$2C(a0)

loc_153C8:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                btst    #2,2(a0)
                beq.s   locret_15408
                move.b  (dword_FFD888+2).w,d0
                andi.b  #$F0,d0
                bne.s   loc_15404
                lea     (unk_FFC740).w,a1
                tst.b   $16(a0)
                beq.s   loc_153F0
                lea     $40(a1),a1

loc_153F0:
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                move.w  d7,$30(a1)
                move.w  d6,$24(a1)
                move.w  #$28,(a1)

loc_15404:
                bsr.w   sub_11118

locret_15408:
                rts

sub_1540A:
                lea     (unk_FFC200).w,a1
                moveq   #5,d0

loc_15410:
                move.w  d0,-(sp)
                btst    #3,5(a1)
                beq.s   loc_1548E
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_1548E
                move.w  #$14,$3C(a0)
                clr.b   5(a0)
                move.l  $34(a1),d7
                move.l  $2C(a1),d6
                move.l  d7,$34(a0)
                move.l  d6,$2C(a0)
                addq.b  #1,$3B(a1)
                moveq   #0,d0
                move.b  $3B(a1),d0
                subq.b  #1,d0
                lsl.w   #2,d0
                move.l  dword_1549E(pc,d0.w),d0
                move.l  d0,(dword_FFD262).w
                move.l  a1,-(sp)
                bsr.w   sub_1168A
                movea.l (sp)+,a1
                lea     (unk_FFC0C0).w,a2
                moveq   #3,d0

loc_15460:
                tst.b   (a2)
                bne.s   loc_15484
                move.w  #$1C,(a2)
                move.b  $3B(a1),d1
                move.b  d1,$3A(a2)
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subq.w  #8,d6
                move.w  d7,$30(a2)
                move.w  d6,$24(a2)
                bra.s   loc_1549A

loc_15484:
                lea     -$40(a2),a2
                dbf     d0,loc_15460
                bra.s   loc_1549A

loc_1548E:
                lea     $40(a1),a1
                move.w  (sp)+,d0
                dbf     d0,loc_15410
                rts

loc_1549A:
                move.w  (sp)+,d0
                rts

dword_1549E:    dc.l $200
                dc.l $400
                dc.l $800
                dc.l $1600
off_154AE:      dc.l byte_154C2
                dc.l byte_154D0
                dc.l byte_154E2
                dc.l byte_154F4
                dc.l byte_154FE
byte_154C2:     dc.b 6, $C
                dc.w word_1A8F8-sub_10000
                dc.w word_1A900-sub_10000
                dc.w word_1A8F8-sub_10000
                dc.w word_1A900-sub_10000
                dc.w word_1A908-sub_10000
                dc.w word_1A910-sub_10000
byte_154D0:     dc.b 8, 1
                dc.w word_1A918-sub_10000
                dc.w word_1A926-sub_10000
                dc.w word_1A93A-sub_10000
                dc.w word_1A94E-sub_10000
                dc.w word_1A94E-sub_10000
                dc.w word_1A95C-sub_10000
                dc.w word_1A93A-sub_10000
                dc.w word_1A926-sub_10000
byte_154E2:     dc.b 8, 1
                dc.w word_1A992-sub_10000
                dc.w word_1A99A-sub_10000
                dc.w word_1A9AE-sub_10000
                dc.w word_1A9B6-sub_10000
                dc.w word_1A9CA-sub_10000
                dc.w word_1A9D2-sub_10000
                dc.w word_1A9E6-sub_10000
                dc.w word_1A9EE-sub_10000
byte_154F4:     dc.b 4, 5
                dc.w word_1AA02-sub_10000
                dc.w word_1AA02-sub_10000
                dc.w word_1AA0A-sub_10000
                dc.w word_1AA12-sub_10000
byte_154FE:     dc.b 4, 6
                dc.w word_1AA7E-sub_10000
                dc.w word_1AA7E-sub_10000
                dc.w word_1AA86-sub_10000
                dc.w word_1AA8E-sub_10000
off_15508:      dc.w word_15568-sub_10000
                dc.w word_155A4-sub_10000
                dc.w word_155A4-sub_10000
                dc.w word_155C0-sub_10000
                dc.w word_155DC-sub_10000
                dc.w word_15610-sub_10000
                dc.w word_15610-sub_10000
                dc.w word_15624-sub_10000
                dc.w word_15646-sub_10000
                dc.w word_1566A-sub_10000
                dc.w word_1566A-sub_10000
                dc.w word_156A2-sub_10000
                dc.w word_156CE-sub_10000
                dc.w word_15714-sub_10000
                dc.w word_15714-sub_10000
                dc.w word_15740-sub_10000
                dc.w word_1576E-sub_10000
                dc.w word_157D2-sub_10000
                dc.w word_157D2-sub_10000
                dc.w word_157FA-sub_10000
                dc.w word_15822-sub_10000
                dc.w word_1584E-sub_10000
                dc.w word_1584E-sub_10000
                dc.w word_15886-sub_10000
                dc.w word_158A6-sub_10000
                dc.w word_158C6-sub_10000
                dc.w word_158C6-sub_10000
                dc.w word_158E2-sub_10000
                dc.w word_1590E-sub_10000
                dc.w word_1592A-sub_10000
                dc.w word_1592A-sub_10000
                dc.w word_15942-sub_10000
                dc.w word_15962-sub_10000
                dc.w word_15982-sub_10000
                dc.w word_15982-sub_10000
                dc.w word_159B6-sub_10000
                dc.w word_159DE-sub_10000
                dc.w word_15A02-sub_10000
                dc.w word_15A02-sub_10000
                dc.w word_15A2E-sub_10000
                dc.w word_15A46-sub_10000
                dc.w word_15AE6-sub_10000
                dc.w word_15AE6-sub_10000
                dc.w word_15B02-sub_10000
                dc.w word_15B1C-sub_10000
                dc.w word_15B52-sub_10000
                dc.w word_15B52-sub_10000
                dc.w word_15B70-sub_10000
word_15568:     dc.w $705, $A05, $1005, $1615, $715, $D15, $1315, $1A07, $1A0A, $1A10
                dc.w $1A16, $A07, $A0D, $A13, $A1A, $E0E, $80D, $C0E, $E0D, $120E
                dc.w $140D, $191E, $51D, $91E, $B1D, $F1E, $111D, $151E, $171D, $1900
word_155A4:     dc.w $30D, $141D, $1A1D, $E03, $20E, $21A, $1214, $60F, $1310, $910
                dc.w $1911, $1519, $F18, $1300
word_155C0:     dc.w $30C, $E0C, $140C, $1A03, $130E, $1314, $131A, $61A, $D1A, $131A
                dc.w $191B, $91B, $F1B, $1500
word_155DC:     dc.w $507, $A07, $1A0F, $1617, $121F, $E05, $E, $812, $1016, $180A
                dc.w $181A, $E05, $1105, $1906, $B06, $130D, $150D, $190E, $70E, $1715
                dc.w $1116, $B17, $1918, $131D, $191E, $F00
word_15610:     dc.w $606, $E0B, $1410, $1A16, $1E1B, $1400, $1A00, $208, $1309, $F00
word_15624:     dc.w $504, $C06, $1411, $1A13, $817, $1406, $30C, $A1A, $B0E, $161A
                dc.w $1B10, $1A14, $40D, $D0D, $190E, $90E, $1500
word_15646:     dc.w $419, $100D, $B09, $151D, $1A04, $21A, $1615, $120B, $610, $806
                dc.w $1406, $1907, $1107, $1619, $1419, $191A, $111A, $1600
word_1566A:     dc.w $607, $C07, $1213, $713, $D13, $1313, $1A0A, $606, $60C, $612
                dc.w $61A, $C07, $C0D, $C13, $1908, $180E, $1814, $A00, $B00, $170F
                dc.w $C0F, $120F, $1910, $810, $E10, $141F, $F1F, $1900
word_156A2:     dc.w $501, $908, $1A0A, $160C, $1110, $D05, $F0D, $1311, $1516, $171A
                dc.w $1E09, $A0D, $190E, $150F, $C0F, $1010, $510, $E11, $1211, $1713
                dc.w $814, $500
word_156CE:     dc.w $802, $1106, $706, $1A0E, $1612, $111A, $1A1E, $1515, $909, $115
                dc.w $51A, $60D, $D11, $1116, $191A, $1D11, $190D, $1409, $1000, $800
                dc.w $1603, $1904, $1208, $C09, $80C, $150C, $190D, $1212, $1513, $1213
                dc.w $171B, $191C, $121F, $141F, $1900
word_15714:     dc.w $404, $1009, $A1A, $1A1F, $1604, $16, $51A, $160A, $1B10, $C04
                dc.w $1905, $1109, $190A, $B0E, $190F, $615, $1916, $B19, $191A, $111E
                dc.w $191F, $1700
word_15740:     dc.w $703, $B04, $1609, $1A12, $1516, $111C, $1A15, $706, $B, $216
                dc.w $911, $1A11, $F07, $B1A, $801, $1502, $C07, $1908, $170F, $A0F
                dc.w $1910, $810, $1600
word_1576E:     dc.w $A02, $1206, $E0A, $A0A, $1A0E, $161A, $1A1E, $1612, $1216, $E1A
                dc.w $A0A, $116, $50A, $51A, $90E, $D12, $1116, $150A, $1D12, $151A
                dc.w $190E, $1C00, $700, $1703, $1103, $1904, $B04, $1307, $1908, $F0B
                dc.w $110B, $190C, $B0C, $130F, $150F, $1910, $710, $1713, $1113, $1914
                dc.w $B14, $1317, $1918, $F1B, $111B, $191C, $B1C, $131F, $151F, $1900
word_157D2:     dc.w $403, $A0F, $1A14, $161D, $1004, $210, $B16, $101A, $1C0A, $A03
                dc.w $F04, $B09, $190A, $170F, $1910, $914, $1915, $170A, $F0B, $B00
word_157FA:     dc.w $50D, $C0E, $1A19, $C19, $1219, $1A05, $A16, $120C, $1F0C, $1F12
                dc.w $1E16, $800, $1501, $1303, $B06, $713, $1714, $1315, $B16, $700
word_15822:     dc.w $500, $1A03, $1506, $1009, $C0C, $805, $1308, $160C, $1910, $1C15
                dc.w $1F1A, $A09, $140A, $110F, $70F, $B0F, $F10, $510, $910, $D14
                dc.w $1915, $1600
word_1584E:     dc.w $700, $1104, $A0F, $1515, $1015, $1A1A, $A1B, $1607, $416, $50A
                dc.w $A10, $A1A, $1015, $1B0A, $1F11, $C05, $1505, $1906, $B07, $1709
                dc.w $F0A, $50D, $190E, $1615, $F16, $519, $151A, $B00
word_15886:     dc.w $502, $1405, $F07, $1A08, $A1F, $1A05, $1A, $170A, $181A, $1A0F
                dc.w $1D14, $40B, $190C, $1713, $1914, $1700
word_158A6:     dc.w $51E, $1A02, $110C, $151D, $151B, $1103, $11A, $D0D, $1E09, $607
                dc.w $C08, $A15, $1016, $E1A, $191B, $1600
word_158C6:     dc.w $60F, $1502, $1A06, $150A, $110E, $D13, $902, $1409, $1A1A, $415
                dc.w $1916, $1617, $418, $100
word_158E2:     dc.w $500, $900, $1100, $1A0F, $D0F, $1505, $100D, $1015, $1F09, $1F11
                dc.w $1F1A, $A08, $C08, $1409, $A09, $1217, $817, $1017, $1918, $618
                dc.w $E18, $1600
word_1590E:     dc.w $405, $1509, $F1F, $A00, $1A02, $1D0A, $1F1A, $612, $912, $1413
                dc.w $613, $1019, $191A, $1600
word_1592A:     dc.w $801, $905, $140B, $F11, $90F, $1A15, $141B, $F1F, $1A02, 9
                dc.w $1009, 0
word_15942:     dc.w $403, $1A0C, $A0C, $100D, $1504, $1115, $120A, $1210, $1B1A, $613
                dc.w $1413, $1914, $1114, $1609, $140A, $1100
word_15962:     dc.w $400, $130A, $130E, $1A0E, $C04, $111A, $1513, $1F13, $110C, $60A
                dc.w $120B, $60F, $1910, $D1B, $191C, $1400
word_15982:     dc.w $806, $706, $D06, $1306, $1A16, $A16, $1016, $161D, $708, $A0A
                dc.w $A10, $A16, $1A07, $1A0D, $1A13, $1A1A, $207, $805, $1906, $140A
                dc.w $190B, $1715, $1916, $171A, $191B, $1400
word_159B6:     dc.w $805, $C05, $130E, $C0E, $130E, $1A14, $C14, $1318, $1A08, $81A
                dc.w $C0C, $C13, $120C, $1213, $121A, $1B0C, $1B13, $21B, $161C, $1400
word_159DE:     dc.w $409, $1A09, $811, $161D, $1A08, $213, $30C, $E16, $120C, $161A
                dc.w $1708, $1713, $1D0C, $40E, $190F, $1711, $B12, $500
word_15A02:     dc.w $601, $1402, $1A0B, $140E, $1A17, $1418, $1A06, $71A, $814, $111A
                dc.w $1414, $1D1A, $1E14, $800, $1509, $190A, $150F, $1910, $E15, $1916
                dc.w $151F, $1900
word_15A2E:     dc.w $40B, $814, $D14, $160A, $1102, $B11, $B1A, $400, $1706, $707
                dc.w $51F, $1900
word_15A46:     dc.w $1203, $803, $1003, $1A07, $C07, $140B, $80B, $100B, $1A1B, $1A0F
                dc.w $C0F, $1413, $813, $1013, $1A17, $C17, $141B, $81B, $1014, $10C
                dc.w $114, $508, $510, $51A, $90C, $914, $D08, $D10, $D1A, $110C
                dc.w $1114, $1508, $1510, $151A, $190C, $1914, $1D08, $1D10, $1D1A, $2800
                dc.w $500, $D00, $1504, $F04, $1905, $905, $1107, $B07, $1307, $1908
                dc.w $508, $D08, $150B, $F0B, $190C, $90C, $110F, $B0F, $130F, $1910
                dc.w $510, $D10, $1513, $F13, $1914, $914, $1118, $B17, $1317, $1919
                dc.w $518, $D18, $151B, $F1B, $191C, $91C, $111F, $B1F, $131F, $1900
word_15AE6:     dc.w $C, $10C, $90C, $110C, $190C, $413, $C13, $1413, $1C13, $71A
                dc.w $F1A, $171A, $1F1A, 0
word_15B02:     dc.w $20B, $1A19, $1A03, $213, $E1A, $180C, $603, $1904, $140F, $1910
                dc.w $618, $1919, $D00
word_15B1C:     dc.w $701, $1103, $1A09, $B0A, $160E, $1A12, $1019, $B06, $70B, $E10
                dc.w $1616, $170B, $1D1A, $1F11, $C01, $901, $1507, $1908, $F0F, $F0F
                dc.w $1911, $911, $1117, $1919, $F1F, $101F, $1900
word_15B52:     dc.w $702, $1305, $C06, $1A09, $160C, $F0D, $1A1F, $1A06, $1A, $130F
                dc.w $1616, $191A, $1A0C, $1D13, 0
word_15B70:     dc.w $40F, $C13, $1A18, $131F, $C04, $10C, $813, $D1A, $110C, $802
                dc.w $1203, $100B, $B0F, $120F, $1911, $1011, $1616, $900
dword_15B94:    dc.l $14000, $FFFE0000
                dc.l $10000, $FFFD8000
                dc.l $10000, $FFFD8000
                dc.l $14000, $FFFD8000
                dc.l $14000, $FFFE0000
                dc.l $14000, $FFFD8000
                dc.l $14000, $FFFD8000
                dc.l $14000, $FFFD8000
                dc.l $18000, $FFFDE000
                dc.l $14000, $FFFD8000
                dc.l $14000, $FFFD8000
                dc.l $4800, $FFFD9000
                dc.l $C000, $FFFDE000
                dc.l $8000, $FFFD8000
                dc.l $8000, $FFFD8000
                dc.l $10000, $FFFD8000
                dc.l $10000, $FFFE0000
                dc.l $A000, $FFFD5000
                dc.l $A000, $FFFD5000
                dc.l $10000, $FFFD9000
                dc.l $8000, $FFFDC000
                dc.l $A000, $FFFD8000
                dc.l $A000, $FFFD8000
                dc.l $7000, $FFFD8000
                dc.l $1A000, $FFFDC000
                dc.l $8000, $FFFD8000
                dc.l $8000, $FFFD8000
                dc.l $10000, $FFFDC000
                dc.l $A000, $FFFD8000
                dc.l $C000, $FFFD8000
                dc.l $C000, $FFFD8000
                dc.l $10000, $FFFD8000
                dc.l $8000, $FFFD0000
                dc.l $10000, $FFFE0000
                dc.l $10000, $FFFE0000
                dc.l $8000, $FFFD3000
                dc.l $A000, $FFFD4000
                dc.l $A000, $FFFD0000
                dc.l $A000, $FFFD0000
                dc.l $C000, $FFFD8000
                dc.l $8000, $FFFD8000
                dc.l $6000, $FFFD2000
                dc.l $10000, $FFFE0000
                dc.l $10000, $FFFD0000
                dc.l $C000, $FFFD4000
                dc.l $6000, $FFFD2000
                dc.l $6000, $FFFD2000
                dc.l $C000, $FFFD4000
dword_15D14:    dc.l $10000
                dc.l $14000
                dc.l $12000
                dc.l $E000
                dc.l $16000
byte_15D28:     dc.b 0, 0, 0, 1, 4, 0, 0, 2
                dc.b 2, 2, 0, 0, 0, 3, 0, 2
                dc.b 0, 0, 0, 0, 0, 3, 0, 2
                dc.b 0, 2, 0, 0, 0, 0, 0, 1
                dc.b 0, 4, 0, 3, 0, 0, 0, 0
                dc.b 0, 0, 0, 0, 0, 3, 0, 0
sub_15D58:
                bset    #7,(a0)
                bne.s   loc_15D8C
                moveq   #0,d7
                moveq   #0,d6
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addi.w  #$10,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)
                move.l  #off_162BC,8(a0)
                clr.l   $34(a0)
                clr.l   $2C(a0)

loc_15D8C:
                tst.b   (byte_FFD27B).w
                bne.s   locret_15DC0
                tst.b   (byte_FFD24F).w
                bne.s   locret_15DC0
                tst.b   (byte_FFD26D).w
                bne.s   locret_15DC0
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_15DC2(pc,d0.w)
                move.w  $3C(a0),d0
                andi.w  #$7C,d0
                cmpi.w  #$C,d0
                beq.s   locret_15DC0
                cmpi.w  #$10,d0
                beq.s   locret_15DC0
                bsr.w   sub_16218

locret_15DC0:
                rts

loc_15DC2:
                bra.w   sub_15DD6
                bra.w   sub_15E04
                bra.w   sub_160C8
                bra.w   sub_16188
                bra.w   sub_161BC

sub_15DD6:
                bset    #7,$3C(a0)
                bne.s   loc_15DF2
                move.b  #4,5(a0)
                move.l  #word_1AB74,$C(a0)
                move.b  #$A,$3B(a0)

loc_15DF2:
                bsr.w   sub_1105C
                subq.b  #1,$3B(a0)
                bne.s   locret_15E02
                move.w  #4,$3C(a0)

locret_15E02:
                rts

sub_15E04:
                bset    #7,$3C(a0)
                bne.s   loc_15E12
                move.b  #5,5(a0)

loc_15E12:
                moveq   #0,d0
                move.b  $3A(a0),d0
                lsl.w   #2,d0
                jsr     loc_15E20(pc,d0.w)
                rts

loc_15E20:
                bra.w   sub_15E40
                bra.w   sub_15EE6
                bra.w   sub_15EE6
                bra.w   sub_15EE6
                bra.w   sub_15F9E
                bra.w   sub_15F9E
                bra.w   sub_16036
                bra.w   sub_160C8

sub_15E40:
                clr.w   6(a0)
                bclr    #7,2(a0)
                move.l  (dword_FFD27C).w,$34(a0)
                clr.l   $2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_15E86
                addq.w  #4,d7
                subq.w  #4,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_15EA8
                moveq   #0,d7
                moveq   #$FFFFFFFC,d6
                bsr.w   sub_115C0
                tst.b   d4
                bne.s   loc_15ED6
                bsr.w   sub_11126
                rts

loc_15E86:
                move.b  #6,$3A(a0)
                move.w  $30(a0),d7
                andi.w  #$FFF8,d7
                subq.w  #1,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                move.l  #word_1AC04,$C(a0)
                rts

loc_15EA8:
                move.b  #5,$3A(a0)
                andi.w  #$FFF8,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                addq.w  #4,$20(a0)
                andi.w  #$FFF8,d6
                addq.w  #7,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1ABCC,$C(a0)
                rts

loc_15ED6:
                move.w  #8,$3C(a0)
                move.l  #word_1AC4C,$C(a0)
                rts

sub_15EE6:
                move.w  #4,6(a0)
                bset    #7,2(a0)
                move.l  (dword_FFD27C).w,d0
                neg.l   d0
                move.l  d0,$34(a0)
                clr.l   $2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_15F32
                subq.w  #4,d7
                addq.w  #4,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_15F5A
                moveq   #0,d7
                moveq   #4,d6
                bsr.w   sub_115C0
                tst.b   d4
                bne.s   loc_15F8E
                bsr.w   sub_11126
                rts

loc_15F32:
                move.b  #5,$3A(a0)
                move.w  $30(a0),d7
                andi.w  #$FFF8,d7
                addq.w  #8,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                move.l  #word_1AC20,$C(a0)
                bclr    #7,2(a0)
                rts

loc_15F5A:
                move.b  #6,$3A(a0)
                andi.w  #$FFF8,d7
                addq.w  #7,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                subq.w  #4,$20(a0)
                andi.w  #$FFF8,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1ABE8,$C(a0)
                bclr    #7,2(a0)
                rts

loc_15F8E:
                move.w  #8,$3C(a0)
                move.l  #word_1AC64,$C(a0)
                rts

sub_15F9E:
                move.w  #8,6(a0)
                bclr    #7,2(a0)
                clr.l   $34(a0)
                move.l  (dword_FFD27C).w,d0
                neg.l   d0
                move.l  d0,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_15FDE
                subq.w  #4,d7
                subq.w  #4,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_16004
                bsr.w   sub_11126
                rts

loc_15FDE:
                clr.b   $3A(a0)
                move.w  $24(a0),d6
                andi.w  #$FFF8,d6
                addq.w  #8,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1AC2E,$C(a0)
                bclr    #7,2(a0)
                rts

loc_16004:
                move.b  #3,$3A(a0)
                andi.w  #$FFF8,d7
                addq.w  #7,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                andi.w  #$FFF8,d6
                addq.w  #7,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1ABDA,$C(a0)
                bclr    #7,2(a0)
                rts

sub_16036:
                move.w  #$C,6(a0)
                bset    #7,2(a0)
                clr.l   $34(a0)
                move.l  (dword_FFD27C).w,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                bsr.w   sub_1157C
                tst.b   d4
                beq.s   loc_16072
                addq.w  #4,d7
                addq.w  #4,d6
                bsr.w   sub_1157C
                tst.b   d4
                bne.s   loc_1609A
                bsr.w   sub_11126
                rts

loc_16072:
                move.b  #3,$3A(a0)
                move.w  $24(a0),d6
                andi.w  #$FFF8,d6
                subq.w  #1,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1AC12,$C(a0)
                bclr    #7,2(a0)
                rts

loc_1609A:
                move.b  #0,$3A(a0)
                andi.w  #$FFF8,d7
                move.w  d7,$30(a0)
                clr.w   $32(a0)
                andi.w  #$FFF8,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1ABF6,$C(a0)
                bclr    #7,2(a0)
                rts

sub_160C8:
                bset    #7,$3C(a0)
                bne.s   loc_160D6
                move.b  #5,5(a0)

loc_160D6:
                btst    #1,$3A(a0)
                bne.s   loc_16136
                move.w  #$10,6(a0)
                clr.l   $34(a0)
                move.l  (dword_FFD27C).w,d0
                neg.l   d0
                move.l  d0,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subq.w  #8,d6
                bsr.w   sub_1157C
                bne.s   loc_1610C
                bsr.w   sub_11126
                rts

loc_1610C:
                move.w  #4,$3C(a0)
                bchg    #0,$3A(a0)
                bchg    #1,$3A(a0)
                andi.w  #$FFF8,d6
                addq.w  #7,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1AC64,$C(a0)
                rts

loc_16136:
                move.w  #$14,6(a0)
                clr.l   $34(a0)
                move.l  (dword_FFD27C).w,$2C(a0)
                bsr.w   sub_1105C
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                addq.w  #8,d6
                bsr.w   sub_1157C
                bne.s   loc_16160
                bsr.w   sub_11126
                rts

loc_16160:
                move.w  #4,$3C(a0)
                bchg    #0,$3A(a0)
                bchg    #1,$3A(a0)
                andi.w  #$FFF8,d6
                move.w  d6,$24(a0)
                clr.w   $26(a0)
                move.l  #word_1AC4C,$C(a0)
                rts

sub_16188:
                bset    #7,$3C(a0)
                bne.s   loc_161AA
                move.l  a0,-(sp)
                move.b  #$93,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                move.w  #$18,6(a0)
                subq.b  #1,(byte_FFD26C).w
                clr.b   5(a0)

loc_161AA:
                bsr.w   sub_14688
                tst.l   $34(a0)
                bne.s   locret_161BA
                move.w  #$10,$3C(a0)

locret_161BA:
                rts

sub_161BC:
                bset    #7,$3C(a0)
                bne.s   loc_161E0
                bclr    #2,2(a0)
                move.w  #$1C,6(a0)
                clr.b   $10(a0)
                move.l  #$FFFFC000,$2C(a0)
                clr.b   5(a0)

loc_161E0:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                btst    #2,2(a0)
                beq.s   locret_16216
                move.b  (dword_FFD888+2).w,d0
                andi.b  #$F0,d0
                bne.s   loc_16212
                lea     (unk_FFC7C0).w,a1
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                move.w  d7,$30(a1)
                move.w  d6,$24(a1)
                move.w  #$28,(a1)

loc_16212:
                bsr.w   sub_11118

locret_16216:
                rts

sub_16218:
                lea     (unk_FFC200).w,a1
                moveq   #5,d0

loc_1621E:
                move.w  d0,-(sp)
                btst    #4,5(a1)
                beq.s   loc_1629C
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_1629C
                move.w  #$C,$3C(a0)
                clr.b   5(a0)
                move.l  $34(a1),d7
                move.l  $2C(a1),d6
                move.l  d7,$34(a0)
                move.l  d6,$2C(a0)
                addq.b  #1,$3B(a1)
                moveq   #0,d0
                move.b  $3B(a1),d0
                subq.b  #1,d0
                lsl.w   #2,d0
                move.l  dword_162AC(pc,d0.w),d0
                move.l  d0,(dword_FFD262).w
                move.l  a1,-(sp)
                bsr.w   sub_1168A
                movea.l (sp)+,a1
                lea     (unk_FFC0C0).w,a2
                moveq   #3,d0

loc_1626E:
                tst.b   (a2)
                bne.s   loc_16292
                move.w  #$1C,(a2)
                move.b  $3B(a1),d1
                move.b  d1,$3A(a2)
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                subq.w  #8,d6
                move.w  d7,$30(a2)
                move.w  d6,$24(a2)
                bra.s   loc_162A8

loc_16292:
                lea     -$40(a2),a2
                dbf     d0,loc_1626E
                bra.s   loc_162A8

loc_1629C:
                lea     $40(a1),a1
                move.w  (sp)+,d0
                dbf     d0,loc_1621E
                rts

loc_162A8:
                move.w  (sp)+,d0
                rts

dword_162AC:    dc.l $200, $400, $800, $1600
off_162BC:      dc.l byte_162DC
                dc.l byte_162E6
                dc.l byte_162F0
                dc.l byte_162F6
                dc.l byte_162FC
                dc.l byte_16302
                dc.l byte_16308
                dc.l byte_154FE
byte_162DC:     dc.b 4, 1
                dc.w word_1AB7C-sub_10000
                dc.w word_1AB84-sub_10000
                dc.w word_1AB8C-sub_10000
                dc.w word_1AB84-sub_10000
byte_162E6:     dc.b 4, 1
                dc.w word_1AB94-sub_10000
                dc.w word_1AB9C-sub_10000
                dc.w word_1ABA4-sub_10000
                dc.w word_1AB9C-sub_10000
byte_162F0:     dc.b 2, 1
                dc.w word_1ABAC-sub_10000
                dc.w word_1ABB4-sub_10000
byte_162F6:     dc.b 2, 1
                dc.w word_1ABBC-sub_10000
                dc.w word_1ABC4-sub_10000
byte_162FC:     dc.b 2, 1
                dc.w word_1AC3C-sub_10000
                dc.w word_1AC44-sub_10000
byte_16302:     dc.b 2, 1
                dc.w word_1AC54-sub_10000
                dc.w word_1AC5C-sub_10000
byte_16308:     dc.b 4, 1
                dc.w word_1AC6C-sub_10000
                dc.w word_1AC7A-sub_10000
                dc.w word_1AC88-sub_10000
                dc.w word_1AC96-sub_10000
sub_16312:
                bset    #7,(a0)
                bne.s   loc_1633E
                move.b  $3E(a0),d7
                move.b  $3F(a0),d6
                bsr.w   sub_11674
                addq.w  #8,d7
                addi.w  #$10,d6
                move.w  d7,$30(a0)
                move.w  d6,$24(a0)
                tst.b   (byte_FFD26C).w
                beq.s   loc_1633E
                move.w  (word_FFD294).w,$38(a0)

loc_1633E:
                move.l  #off_163E0,8(a0)
                tst.b   (byte_FFD24F).w
                bne.s   locret_1635C
                tst.b   (byte_FFD27B).w
                bne.s   locret_1635C
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_1635E(pc,d0.w)

locret_1635C:
                rts

loc_1635E:
                bra.w   sub_16366
                bra.w   sub_16396

sub_16366:
                bset    #7,$3C(a0)
                bne.s   loc_16378
                addq.b  #1,(byte_FFD26C).w
                bset    #1,2(a0)

loc_16378:
                bsr.w   sub_1105C
                tst.w   $38(a0)
                bne.s   loc_16390
                bclr    #1,2(a0)
                move.w  #4,$3C(a0)
                rts

loc_16390:
                subq.w  #1,$38(a0)
                rts

sub_16396:
                bset    #7,$3C(a0)
                bne.s   loc_163AC
                bclr    #2,2(a0)
                clr.b   $10(a0)
                clr.w   6(a0)

loc_163AC:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                bclr    #2,2(a0)
                beq.s   locret_163DE
                movea.l a0,a1
                suba.l  #$300,a1
                move.b  $16(a0),d0
                move.w  #$10,(a1)
                move.b  d0,$16(a1)
                cmpi.b  #2,d0
                bne.s   loc_163DA
                move.w  #$14,(a1)

loc_163DA:
                bsr.w   sub_11118

locret_163DE:
                rts

off_163E0:      dc.l byte_163E4
byte_163E4:     dc.b $1C, 4
                dc.w word_1AAEC-sub_10000
                dc.w word_1AAEC-sub_10000
                dc.w word_1AAEC-sub_10000
                dc.w word_1AAF4-sub_10000
                dc.w word_1AAF4-sub_10000
                dc.w word_1AAF4-sub_10000
                dc.w word_1AAFC-sub_10000
                dc.w word_1AB04-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB1C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB04-sub_10000
                dc.w word_1AAFC-sub_10000
                dc.w word_1AB04-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB1C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB04-sub_10000
                dc.w word_1AAFC-sub_10000
                dc.w word_1AB04-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB1C-sub_10000
                dc.w word_1AB14-sub_10000
                dc.w word_1AB0C-sub_10000
                dc.w word_1AB04-sub_10000
sub_16422:
                bset    #7,(a0)
                bne.s   loc_16442
                moveq   #0,d0
                move.b  $3A(a0),d0
                subq.b  #1,d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                move.w  off_16450(pc,d0.w),d1
                move.l  d1,$C(a0)
                move.w  #$3C,$38(a0)

loc_16442:
                bsr.w   sub_1105C
                subq.w  #1,$38(a0)
                bne.s   locret_1644E
                clr.w   (a0)

locret_1644E:
                rts

off_16450:      dc.w byte_1AB2C-sub_10000
                dc.w word_1AB3C-sub_10000
                dc.w word_1AB4C-sub_10000
sub_16456:
                bset    #7,(a0)
                bne.s   loc_16490
                move.b  $3A(a0),d0
                subq.b  #1,d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                move.w  off_1649E(pc,d0.w),d1
                move.l  d1,$C(a0)
                lsl.w   #2,d0
                move.w  (word_FFD25C).w,d6
                cmpi.w  #$F0,d6
                bcs.s   loc_16482
                sub.w   d0,d6
                subi.w  #$18,d6
                bra.s   loc_16486

loc_16482:
                add.w   d0,d6
                addq.w  #8,d6

loc_16486:
                move.w  d6,$24(a0)
                move.w  #$1E,$38(a0)

loc_16490:
                bsr.w   sub_1105C
                subq.w  #1,$38(a0)
                bne.s   locret_1649C
                clr.w   (a0)

locret_1649C:
                rts

off_1649E:      dc.w word_1AB24-sub_10000
                dc.w byte_1AB2C-sub_10000
                dc.w word_1AB34-sub_10000
                dc.w word_1AB3C-sub_10000
                dc.w word_1AB44-sub_10000
                dc.w word_1AB54-sub_10000
                dc.w word_1AB5C-sub_10000
                dc.w word_1AB6C-sub_10000
sub_164AE:
                bset    #7,(a0)
                bne.s   loc_164CC
                moveq   #0,d0
                move.b  $3A(a0),d0
                lsl.w   #1,d0
                moveq   #$FFFFFFFF,d1
                move.w  off_164DA(pc,d0.w),d1
                move.l  d1,$C(a0)
                move.w  #$3C,$38(a0)

loc_164CC:
                bsr.w   sub_1105C
                subq.w  #1,$38(a0)
                bne.s   locret_164D8
                clr.w   (a0)

locret_164D8:
                rts

off_164DA:      dc.w word_1AB24-sub_10000
                dc.w byte_1AB2C-sub_10000
                dc.w word_1AB34-sub_10000
                dc.w word_1AB3C-sub_10000
                dc.w word_1AB44-sub_10000
                dc.w word_1AB4C-sub_10000
                dc.w word_1AB54-sub_10000
                dc.w word_1AB5C-sub_10000
                dc.w word_1AB64-sub_10000
sub_164EC:
                bset    #7,(a0)
                bne.s   loc_1651A
                clr.b   5(a0)
                clr.l   $34(a0)
                clr.l   $2C(a0)
                addq.w  #7,$24(a0)
                move.l  #byte_165AC,8(a0)
                clr.w   6(a0)
                move.w  #$12C,$38(a0)
                bclr    #7,2(a0)

loc_1651A:
                bsr.w   sub_1105C
                bsr.w   sub_11126
                lea     (word_FFC440).w,a1
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   loc_1657C
                move.l  a0,-(sp)
                move.b  #$98,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                lea     (unk_FFC0C0).w,a2
                moveq   #3,d0

loc_16540:
                tst.w   (a2)
                bne.s   loc_16574
                move.w  $30(a0),d7
                move.w  $24(a0),d6
                move.w  d7,$30(a2)
                subq.w  #8,d6
                move.w  d6,$24(a2)
                moveq   #0,d7
                move.b  (byte_FFD27A).w,d7
                move.b  d7,$3A(a2)
                move.w  #$24,(a2)
                lsl.w   #2,d7
                move.l  dword_16588(pc,d7.w),d7
                move.l  d7,(dword_FFD262).w
                bsr.w   sub_1168A
                bra.s   loc_16582

loc_16574:
                lea     -$40(a2),a2
                dbf     d0,loc_16540

loc_1657C:
                subq.w  #1,$38(a0)
                bne.s   locret_16586

loc_16582:
                bsr.w   sub_11118

locret_16586:
                rts

dword_16588:    dc.l $100, $200, $300, $400, $500, $800, $1000, $2000, $3000
byte_165AC:     dc.b 0, 1
                dc.w byte_165B0-sub_10000
byte_165B0:     dc.b 4, 5
                dc.w word_1A8D8-sub_10000
                dc.w word_1A8E0-sub_10000
                dc.w word_1A8E8-sub_10000
                dc.w word_1A8F0-sub_10000
sub_165BA:
                bset    #7,(a0)
                bne.s   loc_165F0
                move.w  #$140,$30(a0)
                bclr    #7,2(a0)
                tst.b   $16(a0)
                beq.s   loc_165DE
                move.w  #$C0,$30(a0)
                bset    #7,2(a0)

loc_165DE:
                move.w  #$150,$24(a0)
                move.l  #off_1669A,8(a0)
                clr.w   6(a0)

loc_165F0:
                tst.b   (byte_FFD27B).w
                bne.s   locret_165FE
                bsr.w   sub_1105C
                bsr.w   sub_11126

locret_165FE:
                rts

sub_16600:
                bset    #7,(a0)
                bne.s   loc_16638
                move.w  #$130,$30(a0)
                bclr    #7,2(a0)
                tst.b   $16(a0)
                beq.s   loc_16624
                move.w  #$D0,$30(a0)
                bset    #7,2(a0)

loc_16624:
                move.w  #$150,$24(a0)
                move.l  #off_1669A,8(a0)
                move.w  #4,6(a0)

loc_16638:
                tst.b   (byte_FFD27B).w
                bne.s   locret_16646
                bsr.w   sub_1105C
                bsr.w   sub_11126

locret_16646:
                rts

sub_16648:
                lea     (unk_FFC580).w,a1
                move.l  dword_FFC5B0-unk_FFC580(a1),d7
                move.l  $24(a1),d6
                move.l  d7,$30(a0)
                move.l  d6,$24(a0)
                addi.w  #$A,$24(a0)
                tst.b   $39(a1)
                beq.s   loc_16674
                bclr    #7,2(a0)
                subq.w  #8,$30(a0)
                bra.s   loc_1667E

loc_16674:
                bset    #7,2(a0)
                addq.w  #8,$30(a0)

loc_1667E:
                bsr.w   sub_1105C
                move.l  #word_1AAD6,$C(a0)
                tst.l   $34(a1)
                beq.s   locret_16698
                move.l  #word_1AAE4,$C(a0)

locret_16698:
                rts

off_1669A:      dc.l byte_166A2
                dc.l byte_166B4
byte_166A2:     dc.b 8, 7
                dc.w word_1AA96-sub_10000
                dc.w word_1AAA4-sub_10000
                dc.w word_1AAB2-sub_10000
                dc.w word_1AABA-sub_10000
                dc.w word_1AAC8-sub_10000
                dc.w word_1AABA-sub_10000
                dc.w word_1AAB2-sub_10000
                dc.w word_1AAA4-sub_10000
byte_166B4:     dc.b 8, 7
                dc.w word_1AA1A-sub_10000
                dc.w word_1AA2E-sub_10000
                dc.w word_1AA42-sub_10000
                dc.w word_1AA56-sub_10000
                dc.w word_1AA6A-sub_10000
                dc.w word_1AA56-sub_10000
                dc.w word_1AA42-sub_10000
                dc.w word_1AA2E-sub_10000
sub_166C6:
                bset    #7,(a0)
                bne.s   loc_166EC
                bset    #1,2(a0)
                move.l  #off_14E12,8(a0)
                movea.l (dword_FFD282).w,a1
                moveq   #0,d0
                move.b  $38(a0),d0
                lsl.w   #1,d0
                move.w  (a1,d0.w),$3A(a0)

loc_166EC:
                moveq   #$7C,d0
                and.w   $3C(a0),d0
                jsr     loc_166FC(pc,d0.w)
                bsr.w   sub_11126
                rts

loc_166FC:
                bra.w   sub_16708
                bra.w   sub_16782
                bra.w   sub_167D6

sub_16708:
                tst.w   $3A(a0)
                bne.s   loc_16778
                bset    #7,$3C(a0)
                bne.s   loc_16756
                bclr    #1,2(a0)
                move.w  #4,6(a0)
                move.w  #$150,$24(a0)
                move.w  #$80,$30(a0)
                move.l  #$8000,$34(a0)
                bclr    #7,2(a0)
                tst.b   $39(a0)
                beq.s   loc_16756
                move.w  #$17F,$30(a0)
                move.l  #$FFFF8000,$34(a0)
                bset    #7,2(a0)

loc_16756:
                bsr.w   sub_1105C
                lea     (unk_FFC640).w,a1
                tst.b   $39(a0)
                bne.s   loc_16768
                lea     $40(a1),a1

loc_16768:
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   locret_16776
                move.w  #4,$3C(a0)

locret_16776:
                rts

loc_16778:
                subq.w  #1,$3A(a0)
                bsr.w   sub_1105C
                rts

sub_16782:
                bset    #7,$3C(a0)
                bne.s   loc_167B8
                movea.l (dword_FFD286).w,a1
                moveq   #0,d0
                move.b  $38(a0),d0
                lsl.w   #1,d0
                move.b  (a1,d0.w),d7
                move.b  1(a1,d0.w),d6
                ext.w   d7
                ext.l   d7
                ext.w   d6
                ext.l   d6
                moveq   #$C,d0
                lsl.l   d0,d7
                lsl.l   d0,d6
                move.l  d7,$34(a0)
                move.l  d6,$2C(a0)
                bsr.w   sub_16892

loc_167B8:
                addi.l  #$1000,$2C(a0)
                bne.s   loc_167C8
                move.w  #8,$3C(a0)

loc_167C8:
                bsr.w   sub_16854
                bsr.w   sub_1105C
                bsr.w   sub_11126
                rts

sub_167D6:
                bset    #7,$3C(a0)
                bne.s   loc_16806
                clr.w   6(a0)
                move.l  $34(a0),d7
                bpl.s   loc_167F0
                neg.l   d7
                lsr.l   #1,d7
                neg.l   d7
                bra.s   loc_167F2

loc_167F0:
                lsr.l   #1,d7

loc_167F2:
                move.l  d7,$34(a0)
                cmpi.w  #$FFFF,$3A(a0)
                beq.s   loc_16806
                addq.b  #1,$3E(a0)
                bsr.w   sub_16892

loc_16806:
                cmpi.l  #$18000,$2C(a0)
                bgt.s   loc_16818
                addi.l  #$400,$2C(a0)

loc_16818:
                bsr.w   sub_16854
                bsr.w   sub_1105C
                bsr.w   sub_168E2
                cmpi.w  #$180,$24(a0)
                bcs.s   loc_16834
                bsr.w   sub_110F0
                subq.b  #1,(byte_FFD883).w

loc_16834:
                bsr.w   sub_11126
                tst.b   (byte_FFD883).w
                bne.s   locret_16852
                clr.w   (word_FFFF92).w
                move.b  #1,(byte_FFD281).w
                move.w  #4,(word_FFD2A6).w
                bsr.w   sub_16988

locret_16852:
                rts

sub_16854:
                move.w  $3A(a0),d0
                cmpi.w  #$FFFF,d0
                beq.s   locret_16890
                subq.w  #1,d0
                bne.s   loc_1686C
                addq.b  #1,$3E(a0)
                bsr.w   sub_16892
                bra.s   sub_16854

loc_1686C:
                move.w  d0,$3A(a0)
                move.l  $34(a0),d7
                move.l  $1C(a0),d6
                bmi.s   loc_16884
                cmp.l   d6,d7
                bge.s   loc_16882
                add.l   $18(a0),d7

loc_16882:
                bra.s   loc_1688C

loc_16884:
                cmp.l   d6,d7
                ble.s   loc_1688C
                add.l   $18(a0),d7

loc_1688C:
                move.l  d7,$34(a0)

locret_16890:
                rts

sub_16892:
                moveq   #0,d0
                move.b  $38(a0),d0
                movea.l (dword_FFD28A).w,a1
                move.b  (a1,d0.w),d0
                lsl.w   #2,d0
                lea     off_16D18(pc),a1
                movea.l (a1,d0.w),a1
                moveq   #0,d0
                move.b  $3E(a0),d0
                lsl.w   #2,d0
                move.w  (a1,d0.w),$3A(a0)
                move.b  2(a1,d0.w),d7
                move.b  3(a1,d0.w),d6
                ext.w   d7
                ext.l   d7
                ext.w   d6
                ext.l   d6
                lsl.l   #8,d7
                moveq   #$C,d0
                lsl.l   d0,d6
                tst.b   $39(a0)
                beq.s   loc_168D8
                neg.l   d7
                neg.l   d6

loc_168D8:
                move.l  d7,$18(a0)
                move.l  d6,$1C(a0)
                rts

sub_168E2:
                lea     (word_FFC040).w,a1
                bsr.w   sub_117C0
                tst.b   d0
                beq.s   locret_1691A
                move.l  a0,-(sp)
                move.b  #$90,d0
                bsr.w   sub_10D48
                movea.l (sp)+,a0
                bsr.w   sub_110F0
                subq.b  #1,(byte_FFD883).w
                addq.b  #1,(byte_FFD28E).w
                moveq   #1,d0
                move.b  (byte_FFD28F).w,d1
                addi.b  #0,d1
                abcd    d0,d1
                move.b  d1,(byte_FFD28F).w
                bsr.w   sub_169D4

locret_1691A:
                rts

sub_1691C:
                tst.b   (byte_FFD28E).w
                beq.s   loc_16944
                lea     byte_1694C(pc),a6
                bsr.w   sub_10FAA
                cmpi.b  #$14,(byte_FFD28E).w
                bne.s   locret_16942
                lea     byte_16964(pc),a6
                bsr.w   sub_10FAA
                lea     byte_16974(pc),a6
                bsr.w   sub_10FAA

locret_16942:
                rts

loc_16944:
                lea     byte_1697C(pc),a6
                bra.w   sub_10FAA

byte_1694C:     dc.b $C2, $4E
a250PtsPts:     dc.b "; 250 PTS.=      PTS.",0
byte_16964:     dc.b $C3, $12
aPerfectBonus:  dc.b "PERFECT BONUS",0
byte_16974:     dc.b $C3, $A2
aPts_0:         dc.b "PTS.",0
                dc.b 0
byte_1697C:     dc.b $C3, $16
aNoBonus_0:     dc.b "NO BONUS",0
                dc.b 0
sub_16988:
                moveq   #0,d0
                move.b  (byte_FFD28E).w,d0
                beq.s   locret_169D2
                subq.w  #1,d0

loc_16992:
                move.l  #$250,(dword_FFD262).w
                lea     (byte_FFD266).w,a2
                lea     (word_FFD294).w,a1
                moveq   #3,d1
                move    #4,ccr

loc_169A8:
                abcd    -(a2),-(a1)
                dbf     d1,loc_169A8
                dbf     d0,loc_16992
                move.l  (dword_FFD290).w,d0
                move.l  d0,(dword_FFD262).w
                bsr.w   sub_1168A
                cmpi.b  #$14,(byte_FFD28E).w
                bne.s   locret_169D2
                move.l  #$10000,(dword_FFD262).w
                bsr.w   sub_1168A

locret_169D2:
                rts

sub_169D4:
                moveq   #0,d0
                move.b  (byte_FFD28E).w,d0
                subq.w  #1,d0
                move.l  #$414C0003,(VDP_CTRL).l

loc_169E6:
                move.w  #$E351,(VDP_DATA).l
                dbf     d0,loc_169E6
                rts

off_169F4:      dc.l word_16A24
                dc.l word_16A24
                dc.l word_16A24
                dc.l word_16A4C
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
                dc.l word_16A74
word_16A24:     dc.w 0, $F, $1E, $2D, $6E, $7D, $8C, $9B, $DC, $EB
                dc.w $FA, $109, $14A, $159, $168, $177, $1B8, $1C7, $1D6, $1E5
word_16A4C:     dc.w $1E, $2D, $3C, $4B, 0, $F, $1E, $2D, $FA, $109
                dc.w $118, $127, $DC, $EB, $FA, $109, $1B8, $1C7, $1D6, $1E5
word_16A74:     dc.w 0, $F, $1E, $2D, $64, $73, $82, $91, $C8, $D7
                dc.w $E6, $F5, $12C, $13B, $14A, $159, $190, $19F, $1AE, $1BD
off_16A9C:      dc.l word_16ACC
                dc.l word_16AF4
                dc.l word_16B1C
                dc.l word_16B44
                dc.l word_16B6C
                dc.l word_16B94
                dc.l word_16BBC
                dc.l word_16B94
                dc.l word_16ACC
                dc.l word_16BE4
                dc.l word_16C0C
                dc.l word_16B94
word_16ACC:     dc.w $EB4, $EB4, $EB4, $EB4, $F2B4, $F2B4, $F2B4, $F2B4, $EB4, $EB4
                dc.w $EB4, $EB4, $F2B4, $F2B4, $F2B4, $F2B4, $EB4, $EB4, $EB4, $EB4
word_16AF4:     dc.w $EB4, $CB4, $AB4, $8B4, $F2B4, $F4B4, $F6B4, $F8B4, $EB4, $CB4
                dc.w $AB4, $8B4, $F2B4, $F4B4, $F6B4, $F8B4, $EB4, $CB4, $AB4, $8B4
word_16B1C:     dc.w $EB4, $EB8, $EBC, $EC0, $F2B4, $F2B8, $F2BC, $F2C0, $EB4, $EB8
                dc.w $EBC, $EC0, $F2B4, $F2B8, $F2BC, $F2C0, $EB4, $EB8, $EBC, $EC0
word_16B44:     dc.w $AB4, $AB4, $AB4, $AB4, $F6B4, $F6B4, $F6B4, $F6B4, $AB4, $AB4
                dc.w $AB4, $AB4, $F6B4, $F6B4, $F6B4, $F6B4, $5B4, $8B4, $BB4, $EB4
word_16B6C:     dc.w $22B4, $22B4, $22B4, $22B4, $DEB4, $DEB4, $DEB4, $DEB4, $22B4, $22B4
                dc.w $22B4, $22B4, $DEB4, $DEB4, $DEB4, $DEB4, $22B4, $22B4, $22B4, $22B4
word_16B94:     dc.w $9B4, $9B4, $9B4, $9B4, $F7B4, $F7B4, $F7B4, $F7B4, $9B4, $9B4
                dc.w $9B4, $9B4, $F7B4, $F7B4, $F7B4, $F7B4, $9B4, $9B4, $9B4, $9B4
word_16BBC:     dc.w $12B4, $12B4, $12B4, $12B4, $EEB4, $EEB4, $EEB4, $EEB4, $12B4, $12B4
                dc.w $12B4, $12B4, $EEB4, $EEB4, $EEB4, $EEB4, $12B4, $12B4, $12B4, $12B4
word_16BE4:     dc.w $E0B4, $E0B4, $E0B4, $E0B4, $20B4, $20B4, $20B4, $20B4, $E0B4, $E0B4
                dc.w $E0B4, $E0B4, $20B4, $20B4, $20B4, $20B4, $E0B4, $E0B4, $E0B4, $E0B4
word_16C0C:     dc.w $40B4, $40B4, $40B4, $40B4, $C0B4, $C0B4, $C0B4, $C0B4, $40B4, $40B4
                dc.w $40B4, $40B4, $C0B4, $C0B4, $C0B4, $C0B4, $40B4, $40B4, $40B4, $40B4
off_16C34:      dc.l word_16C64
                dc.l word_16C64
                dc.l word_16C64
                dc.l word_16C64
                dc.l word_16C78
                dc.l word_16C8C
                dc.l word_16CA0
                dc.l word_16CB4
                dc.l word_16CC8
                dc.l word_16CDC
                dc.l word_16CF0
                dc.l word_16D04
word_16C64:     dc.w 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
word_16C78:     dc.w $101, $101, $101, $101, $101, $101, $101, $101, $101, $101
word_16C8C:     dc.w $202, $202, $202, $202, $202, $202, $202, $202, $202, $202
word_16CA0:     dc.w $303, $303, $303, $303, $303, $303, $303, $303, $303, $303
word_16CB4:     dc.w $404, $404, $404, $404, $404, $404, $404, $404, $404, $404
word_16CC8:     dc.w $505, $505, $505, $505, $505, $505, $505, $505, $505, $505
word_16CDC:     dc.w $606, $606, $606, $606, $606, $606, $606, $606, $606, $606
word_16CF0:     dc.w $707, $707, $707, $707, $707, $707, $707, $707, $707, $707
word_16D04:     dc.w $808, $808, $808, $808, $808, $808, $808, $808, $808, $808
off_16D18:      dc.l word_16D3C
                dc.l word_16D3E
                dc.l word_16D48
                dc.l word_16D5A
                dc.l word_16D68
                dc.l word_16D7A
                dc.l word_16D8C
                dc.l word_16D92
                dc.l word_16DA0
word_16D3C:     dc.w $FFFF
word_16D3E:     dc.w $12C, $F4E8, $12C, $310, $FFFF
word_16D48:     dc.w $12C, $FEF8, $14, $C10, $40, $FAF0, $12C, $610, $FFFF
word_16D5A:     dc.w $12C, 0, $58, 0, $12C, $C0DE, $FFFF
word_16D68:     dc.w $12C, $FEF8, $30, $1220, $3A, $EEE0, $12C, $620, $FFFF
word_16D7A:     dc.w $12C, 0, $32, 0, $18, $E4E0, $12C, $1C0C, $FFFF
word_16D8C:     dc.w $12C, $D1C, $FFFF
word_16D92:     dc.w $12C, $F2E0, $28, $FCE0, $12C, $320, $FFFF
word_16DA0:     dc.w $12C, $FEF8, $12C, $320, $FFFF
sub_16DAA:
                bset    #7,(a0)
                bne.s   locret_16DCA
                move.w  #$D8,$20(a0)
                move.w  #$118,$24(a0)
                move.l  #word_1ACA4,$C(a0)
                move.b  #1,(byte_FFD27B).w

locret_16DCA:
                rts

sub_16DCC:
                bset    #7,(a0)
                bne.s   locret_16DE6
                move.l  #word_1AD32,$C(a0)
                move.w  #$F0,$20(a0)
                move.w  #$108,$24(a0)

locret_16DE6:
                nop
                rts

word_16DE8:     dc.w $2EEE, $300E, $4666, $5006, $62EE, $7E4E, $8E66, $9EE2
                dc.w $A2A0, $B242, $CE00, $DC8E, $EC80, $FE40, $1016, $201E
                dc.w $3CD4, $44BA, $56FE, $6094, $7094, $82D2, $92D2, $A6FE
                dc.w $C8FE, $D0BE, $E07E, $F4DA, $1D60, $2920, $3900, $43EE
                dc.w $51CE, $618C, $7D2E, $8700, $9FEA, $A322, $B148, $C9CE
                dc.w $D1E8, $E1C0, $F140, $1FD0, $2DDC, $33BA, $4176, $5776
                dc.w $6332, $71FE, $913C, $A17C, $C1FE, $D170, $E158, $F15F
LevelTiles:     dc.b $81, $57, $80, 3, 0, $14, 3, $24, 6, $35, $13, $45, $16, $55, $15, $66
                dc.b $32, $74, 5, $81, 4, 4, $16, $2F, $27, $6E, $38, $E6, $82, 5, $10, $17
                dc.b $6F, $83, 4, 2, $16, $30, $28, $E2, $78, $EE, $84, 6, $31, $18, $F1, $85
                dc.b 5, $11, $18, $E7, $86, 5, $14, $17, $6C, $28, $EB, $87, 4, 7, $17, $6A
                dc.b $28, $E9, $88, 8, $E3, $89, 7, $6D, $18, $ED, $8A, 6, $33, $18, $EA, $28
                dc.b $EC, $8B, 8, $E8, $8C, 5, $12, $17, $70, $8D, 7, $6B, $8E, 6, $34, $8F
                dc.b 6, $2E, $17, $72, $FF, $E3, $FD, $4F, $1F, $6F, $1D, $E6, $82, $F1, $79, $DE
                dc.b $10, $73, $1A, $55, $F, $98, $20, $BC, $EF, $17, $84, $3B, $EE, $FC, $F5, $DF
                dc.b $AE, $E4, $D7, $35, $CD, $75, $AE, $6B, $8F, $91, $F2, $3B, $8F, $95, $B9, $1D
                dc.b $C7, $C8, $FF, $7F, $D, $7C, $A0, $77, $7E, $76, $E1, $E, $5F, $BD, $B9, $BF
                dc.b $65, $AE, $E8, $28, $FD, $96, $BB, $A1, $77, $EF, $6E, $6B, $BF, $3B, $70, $85
                dc.b $DB, $CE, $1A, $6B, $51, $FC, $C1, $FC, $11, $FE, $11, $CC, $3F, $D8, $A3, $FD
                dc.b $9F, $F1, $FE, $77, $2B, $6E, $9D, $F6, $BE, $D7, $D5, $2B, $FE, $95, $75, $55
                dc.b $55, $55, $D3, $5F, $47, $2E, $8F, $CE, $B6, 3, 5, $55, $55, 5, $1D, $F1
                dc.b $56, $2F, $DA, $DB, $52, $AA, $AA, $D7, 1, $83, $60, $30, $55, $55, $55, 5
                dc.b $1D, $F1, $3F, $F1, $8F, $F3, $C, $7F, $AE, $A3, $1F, $EB, $8A, $7F, $55, $46
                dc.b $11, $BE, $3C, $47, $80, $C3, $65, $71, $D4, $B6, $C7, $F6, $ED, $4F, $E2, $A9
                dc.b $96, $5F, $D3, $3F, $EB, $1E, $3F, $B7, $56, $C7, $55, $A9, $1C, $8A, $A4, $78
                dc.b $E, $23, $C0, $61, $B2, $B8, $EA, $5B, $63, $AA, $D4, $8E, $45, $5C, $23, $BE
                dc.b $2D, $FE, $33, $FE, $B3, $7F, $1D, $5B, $F8, $E0, $BF, $AA, $A0, $A3, $7C, $70
                dc.b $6C, 1, $65, $1A, $5B, $A5, $5B, $F8, $E7, $FD, $50, $4B, $97, $F8, $CF, $FA
                dc.b $CD, $FC, $75, $B7, $4D, $79, $D5, $B0, $18, $36, 0, $B2, $8D, $2D, $D2, $B6
                dc.b $7D, $EA, $A0, $A3, $BE, $27, $DD, $FF, $6C, $7F, $CE, $B8, $FF, $9E, $9F, $E5
                dc.b $5C, $23, $7C, $78, $8F, 0, $43, $64, $E3, $4C, $75, $1F, $4A, $E3, $FE, $7A
                dc.b $7F, $95, $4B, $2E, $EF, $FB, $63, $FE, $75, $C7, $51, $F4, $D2, $33, $E7, 5
                dc.b $52, $3C, 7, $11, $E0, 8, $6C, $9C, $69, $8E, $A3, $E9, $5C, $75, $1F, $4D
                dc.b $23, $3E, $70, $55, $E8, $CE, $5D, $19, $CB, $6F, $1D, $C8, $68, $2F, $17, $9D
                dc.b $E1, $34, $E6, $34, $AA, $1D, $DB, $82, $B, $CE, $F1, $78, $B8, $EF, $FD, $77
                dc.b $2F, $D7, $5E, $68, $2F, $17, $9D, $E1, 7, $31, $A5, $50, $F9, $82, $B, $CE
                dc.b $F1, $78, $43, $BD, $92, $EF, $D7, $5E, $68, $2F, $17, $9D, $E1, 7, $31, $A5
                dc.b $50, $F9, $82, $B, $CE, $F1, $78, $43, $BF, $F5, $DC, $BF, $5D, $72, $1A, $B
                dc.b $C5, $E7, $78, $4D, $39, $8D, $2A, $87, $76, $E0, $82, $F3, $BC, $5E, $2E, $3B
                dc.b $EE, $FC, $F5, $CD, $7B, $5C, $D7, $35, $D3, $D2, $E6, $B8, $F9, $1F, $23, $BB
                dc.b $41, $CA, $DC, $8E, $E3, $B9, $F, $97, $E7, $93, $F5, $C9, $A5, $CD, $73, $5C
                dc.b $D7, $5A, $E6, $B8, $F9, $1F, $23, $B8, $F9, $56, $E3, $B8, $EE, $6E, $47, $70
                dc.b $FC, $F2, $69, $73, $5C, $D7, $35, $D6, $B9, $AE, $3E, $47, $C8, $EE, $3E, $56
                dc.b $E4, $77, $1F, $23, $E5, $F9, $E4, $FD, $72, $68, $8D, $73, $5D, $A1, $DD, $6B
                dc.b $9A, $E3, $B9, $F, $91, $DC, $7C, $AC, $97, $1D, $C7, $C8, $FF, $7E, $2E, $BF
                dc.b $F5, $DF, $BF, $3F, $F7, $B6, $8D, $C9, $4E, $12, $3E, $42, $EF, $CE, $A7, $26
                dc.b $BB, $F3, $B7, $1D, $DF, $9E, $E1, $F9, $E9, $68, $3F, $7E, $21, $FC, $FD, $77
                dc.b $56, $1A, $EE, $82, $CE, $1A, $EE, $87, $EF, $F5, $DC, $DF, $BF, $10, $BA, $7F
                dc.b $9E, $96, $83, $F7, $E7, $FE, $FC, $B9, $2D, $79, $F, $EF, $B7, $EF, $CE, $EF
                dc.b $CF, $70, $FC, $F4, $BF, $3C, $3F, $3B, $70, $85, $C2, $EF, $D6, $DC, $DA, $7E
                dc.b $8B, $5D, $D0, $3D, $17, $7E, $BB, $A0, $39, $16, $BB, $A7, $FA, $F1, $F, $E7
                dc.b $A0, $92, $16, $52, $E6, $1F, $9E, $4B, $B4, $1F, $BE, $BF, $41, $FB, $E1, $28
                dc.b $7F, 5, $47, $B, $B9, $BF, $7F, $D, $39, $2F, $34, $85, $FF, $AE, $1C, $DF
                dc.b $AE, $1C, $C3, $77, $EF, $14, $6E, $FD, $E7, $35, $DA, $29, $FF, 4, $7F, $38
                dc.b $7F, $B8, $7E, $F8, $7F, $85, $47, $F8, $7F, $85, $A7, $22, $C9, $3F, $78, $2F
                dc.b $D0, $20, $E6, $FC, $F2, $E, $60, $97, $7F, $31, $45, $F0, $FD, $E7, $EE, $3F
                dc.b $6D, $B7, $F7, $5D, $A6, $47, $C5, $3C, $2D, 2, $B5, $F5, $4C, $27, $DB, $9E
                dc.b $DE, $C1, $FB, $6F, $DB, $FE, $F3, $4E, $56, $BE, $13, $24, $C1, $BF, $86, $78
                dc.b $E, $23, $23, $E2, $1F, $CA, $DB, $9A, $A7, $F2, $BB, $6D, $C5, $3C, $2D, $83
                dc.b $50, $61, $52, $AF, $FA, $87, $FD, $F5, $FE, $FB, $91, $91, $DF, 9, $DF, $84
                dc.b $D3, $88, $FF, $A6, $64, $7C, $43, $F9, $5B, $73, $57, $55, $56, $2A, $92, $15
                dc.b $89, $A, $A4, $AA, $A2, $39, $45, $55, $54, $D2, $3B, $D2, $3B, $D5, $46, $38
                dc.b $5B, $F4, $8C, $47, $A8, $CB, $1B, $78, $D2, $D8, $D3, $2B, $D4, $C9, $4A, $78
                dc.b $8C, $6D, $41, $4C, $46, $36, $A6, $20, $AD, $4C, $4E, 2, $F8, 2, $55, $3C
                dc.b $70, $B7, $12, $AA, $8C, $70, $E, $D8, $E0, $AA, $31, $C2, $DF, $A4, $AE, $A5
                dc.b $51, $8E, $16, $C7, $7A, $A8, $C7, 3, $D8, $3F, $48, $3F, $48, $7A, $86, $38
                dc.b $29, $EA, $3D, $50, $1B, $20, $31, $7C, $8B, $2C, $68, $3A, $CD, $FF, $A8, $D8
                dc.b $E0, $31, $25, $6D, $47, $A8, $74, $A9, $EA, $51, $C5, $6E, $25, $5B, $74, $9E
                dc.b $A3, $D4, $A7, $A9, $46, $38, $5B, $F4, $95, $D4, $B5, $D4, $7A, $93, $AD, $23
                dc.b $B3, $FC, $66, $40, $8F, 1, $C4, $7F, $B3, $1F, $B3, $18, $F, $D9, $9F, $11
                dc.b $E0, $38, $8C, $A0, $78, 2, $80, $FE, $1C, 5, 9, $A0, $C4, $A, 1, $F
                dc.b 8, 4, $62, $80, $4A, $34, 2, $51, $26, $94, $4B, $24, $75, $14, $1C, $E1
                dc.b $FC, $36, $83, $11, $A0, $81, 2, $64, $10, $C1, $A8, $82, 4, $C9, $44, $10
                dc.b $9A, $51, 5, $E5, $8B, $D0, $40, $77, $11, $90, $21, $81, $F1, $1F, $EC, $C6
                dc.b 3, $F6, $63, $F6, $67, $C4, $20, $47, $C4, $20, $4C, $50, $4C, 6, $10, $6E
                dc.b $24, 8, $78, $20, $DD, $82, 4, $74, $72, $40, $94, $E, $10, $23, $A0, $43
                dc.b $4A, $1F, $35, $2F, $1B, $12, $88, $2F, $67, $41, $7C, $DE, $F9, $A0, $74, $9D
                dc.b $10, $3A, $32, $3A, 7, $49, $D2, $F6, $EB, $7D, $9A, $9A, $F0, $94, $6B, $C2
                dc.b $3C, $EF, $7B, $23, $84, $64, $70, $94, $34, $70, $8E, $8D, $7D, $27, 2, $14
                dc.b $7C, $4E, $18, $C, 2, 4, $E2, 9, 4, 9, $80, $78, $3A, 4, $C0, $38
                dc.b $A2, 4, $20, $81, $1D, 7, $31, $D1, 6, $2F, $1F, $18, $94, $14, $40, $B2
                dc.b $87, $F0, $DB, $F8, $5F, $E3, $1F, $D3, 5, $1B, $61, $8F, $F8, $46, $EC, $2F
                dc.b $9E, $F3, $2C, $A1, $5E, $E3, $FE, $9A, $13, $40, $E0, $21, $79, $6E, $10, $C2
                dc.b $F2, $6D, $EA, $70, $C2, $B0, $1F, $E3, $4F, $E9, $88, $1C, $18, $B7, $16, $E5
                dc.b $C9, 7, $F0, $D0, $FF, $85, $3E, $E1, $DD, $6F, $D2, $9E, 2, $27, $16, $25
                dc.b $68, $B1, $1C, $4F, 3, $8D, $BB, $87, $74, $FF, $45, $38, $34, $E, $13, $81
                dc.b $C1, $A1, $38, 8, $31, $1C, $1A, 3, $FA, $69, $DC, $7F, $A2, $9C, $1A, $D
                dc.b 9, $C1, $A0, $D0, $9C, 4, $E, $D, 3, $24, $FE, $98, $EE, $3C, $F, $9C
                dc.b $13, $45, $58, $9A, $33, $C0, $E2, $30, $B4, $48, $7F, $4C, $7F, $8F, $9B, $F4
                dc.b $A4, $D8, $9D, $10, $F1, $3A, $21, $E2, $74, $4B, $51, $15, $55, $8B, $52, $64
                dc.b $F9, $3A, $B4, $2B, 2, $E, $D0, $C4, $DD, $4E, $18, $BD, $A1, $4B, $D6, $CE
                dc.b $70, $26, $73, $C5, $A, $A4, $8A, $55, $24, $9D, 5, $22, $FC, $41, $28, $78
                dc.b $CD, $28, $78, $CD, $28, $78, $CD, $28, $A6, $F9, $3E, $45, $A9, 2, 7, $AB
                dc.b $AA, $AB, $E4, $EA, $9C, $E5, $FA, $22, $FD, $90, $C4, $A0, $D0, $C4, $6A, $B7
                dc.b $4A, $CF, $12, $81, $36, $E0, $8D, $FC, $3F, $F1, $16, $38, 4, $DE, $43, $56
                dc.b $29, $3E, $90, $4A, $78, $94, $A, $77, $8B, $DB, $FA, $67, $FE, $22, $FE, $11
                dc.b $47, $16, $7C, $9D, $66, $F9, $3A, $E5, $FC, $22, $E7, $40, $81, 2, $F, $E8
                dc.b $B7, $F4, $59, 5, $E1, $2C, $81, 9, $8A, $C4, 9, $B0, $32, $32, $42, $80
                dc.b $82, 8, $6E, 8, $39, $82, 4, $34, $34, $17, $D5, $2A, $40, $81, 2, $1F
                dc.b $D3, $3F, $D9, $A1, $40, $40, $41, $90, $73, $1A, $B, $CF, $74, $D0, $21, $A2
                dc.b $CC, $81, $4C, $98, $86, $10, $24, $28, 8, $11, $DE, $7C, $C2, $F1, $CC, $DC
                dc.b $D3, $40, $8A, $4C, $40, $87, $10, $C0, $71, $19, 2, $18, 2, $32, 4, $A
                dc.b $64, $65, $32, $FF, $C, 7, $F5, $C3, $AE, $54, $8D, $23, $D7, 1, $FB, $3B
                dc.b $10, $20, $59, $10, $FF, $C, 7, $F5, $C3, $AE, $5F, $B6, $8E, $C8, $13, $60
                dc.b $64, $64, 8, $13, $13, $17, $F8, $60, $3F, $AE, $1D, $72, $A4, $69, $1D, $91
                dc.b $80, $20, $46, $56, $20, $56, $20, $43, $FC, $30, $1F, $D7, $E, $B9, $7F, $91
                dc.b $55, $55, $6D, $C, $A0, $AA, $AA, $AA, $71, $CA, $2A, $AA, $AA, $AB, $64, $C9
                dc.b $14, $E3, $94, $55, $55, $55, $41, $54, $81, $4C, $82, 2, $62, 8, $A, $64
                dc.b $A, $A4, $AB, $6F, $E2, $FE, $90, $6E, $55, $17, $8F, $F8, $8B, $D5, $46, $E1
                dc.b $FA, $5F, $E2, $2F, $75, $F0, $6D, $E6, $50, $1F, $A2, $62, $DF, $32, 5, $B
                dc.b $CC, $81, $42, $FF, $D9, $27, $12, $F7, $34, $39, $A0, $20, $46, $43, $79, $36
                dc.b $10, $20, $47, $84, 8, $11, $F1, $27, $F0, $91, $7B, $A0, $90, $48, $24, $C8
                dc.b $12, $1E, 0, $82, $36, $10, $21, $78, $28, 8, $11, $C1, $38, $93, $7A, $F7
                dc.b $24, $12, 9, $D, $C4, 9, $89, 1, $F, $D9, $82, $86, 3, $8A, 2, 4
                dc.b $38, $BF, $64, $90, $41, $C5, $B, $10, $28, $5E, $64, $A, $17, $B1, $6F, $99
                dc.b $40, $7E, $8A, $F8, $36, $FE, $EC, $37, $7E, $88, $43, $88, $CA, 4, 8, $F0
                dc.b $81, 2, $3C, $37, $93, $61, 1, 2, $32, $9C, $39, $BB, $93, $F8, $77, $94
                dc.b $1A, $18, 2, $80, $81, $36, $10, $21, $7E, 0, $82, $4C, $81, $21, $C1, $20
                dc.b $90, $43, $EE, $FE, $1A, $7E, $89, $A1, $80, $28, 8, $10, $C0, $14, $30, $18
                dc.b $20, $21, $FB, $34, $20, $4C, $49, 4, $82, $42, $FE, $E4, $C5, $31, $4C, $53
                dc.b $1F, $FA, $88, $88, $88, $88, $FF, $D3, $B9, $7F, $A6, $71, $B1, $F, $14, $C5
                dc.b $31, $47, $FF, $A8, $88, $88, $88, $8F, $FD, $3B, $94, $7F, $4D, 9, $A0, $70
                dc.b $4C, $53, $12, $C5, $31, $FF, $A8, $88, $88, $88, $8F, $FD, $3B, $95, $3F, $A6
                dc.b $20, $70, $62, $4C, $52, $89, $8A, $63, $FF, $51, $11, $11, $11, $1F, $FA, $77
                dc.b $29, $FF, $4C, $15, $A3, $48, $9E, 2, $27, $16, $25, $68, $B1, $1C, $4F, 0
                dc.b $51, $B1, $F, $E9, $9F, $71, $E0, $7C, $E0, $9A, $2A, $C4, $D1, $32, $18, $1C
                dc.b $4C, $AD, $13, $EE, $FE, $9E, $FF, $E9, $9F, $F4, $55, $55, $7F, $6D, $3F, $DB
                dc.b $57, $FA, $27, $BB, 4, $B6, $F9, $96, $44, $AC, $99, $22, $9F, $F4, $4F, $FA
                dc.b $23, $F4, $56, $FD, $12, $CF, $71, $FF, $44, $F7, $29, $FF, $44, $53, $57, $30
                dc.b $EB, $5E, $69, $FF, 7, $24, $55, $AA, $64, $8D, $85, $70, $CB, $F6, $F3, $FD
                dc.b $BA, $AE, 6, $98, $C, $D, $30, $55, $1A, $AB, $A9, $55, $67, $85, $70, $51
                dc.b $FB, $29, $FE, $C9, $55, $5B, $F8, $68, $7F, $C3, $45, $55, $B7, $4D, $BA, $54
                dc.b $FF, $EF, $FD, $1D, $4A, $BF, $D6, $3E, $E5, $FF, $97, $F9, $A1, $FD, $17, $25
                dc.b $5F, $EA, $A9, $29, $7F, $CB, $FE, $DF, $F1, $55, $1F, $F5, $5C, $BF, $E5, $FF
                dc.b $6F, $F8, $AA, $FF, $D5, $57, $FE, $46, $53, $C0, $13, $7E, $CC, $77, $31, $1C
                dc.b 2, $B, $C2, $D, $C2, $F6, $43, $45, $1F, $D2, $48, $10, $20, $40, $86, 3
                dc.b $F6, $60, $82, 2, $32, $46, $43, $DC, $3F, $A2, $77, $9A, $32, $4F, $F4, $49
                dc.b $FA, $24, $21, $80, $E2, 4, $7F, $B3, $3C, 7, $10, $48, $1A, 2, $BC, $21
                dc.b $DE, $10, $D1, $5B, $F6, $49, 4, $80, $21, $82, $FF, $4C, $7E, $CD, 9, $C
                dc.b $92, $1C, $C1, $D, 6, $E0, $93, $43, $41, $FF, $5F, $F8, $AF, $F8, $54, $7F
                dc.b $85, $47, $FC, $7F, $EA, $B3, $86, $50, $55, $55, $C8, $AA, $48, $56, $24, $2A
                dc.b $92, $AA, $AA, $AA, $99, $54, $92, $A4, $99, $12, $AA, $AA, $96, $44, $AA, $AA
                dc.b $7F, $C7, $37, $3C, $D, $C6, $1C, $E1, $C1, $73, $AC, $CA, $2A, $B5, $2E, $BB
                dc.b $DC, $60, $6F, $38, $E0, $1E, $7C, $E4, $1D, $6D, $12, $55, $CA, $2A, $B9, $13
                dc.b $7E, $DA, $2D, $FC, $36, $8F, $5C, $58, $8C, $96, $36, $2A, $95, $4B, $2F, $DB
                dc.b $13, $7F, $D, $A3, $4E, $79, $92, $B4, $66, $55, $26, $2A, $95, $48, $14, $C8
                dc.b $14, $E3, $B3, $9C, $87, $F8, $C1, $47, $AC, $98, $95, $55, $6C, $43, $F6, $A7
                dc.b $FE, $31, $FB, $7A, $EA, $18, $1B, $8C, $39, $C3, $82, $E7, $59, $94, $55, $6A
                dc.b $5B, $37, $3F, $10, $D4, $DC, $F8, 7, $9F, $39, 7, $59, $95, $A, $64, $A
                dc.b $64, 9, $8A, $38, $1C, $55, $72, $8D, $4A, $A5, $52, 5, $32, 4, $22, $A
                dc.b $80, $8E, $2C, $46, $4C, $46, $53, $88, $2A, $91, $95, $4A, $A5, $6A, $15, $8A
                dc.b $84, $D4, $62, $32, $A9, $54, $8C, $98, $8C, $AA, $56, $D9, $FA, $52, $7F, $F1
                dc.b $E3, $FC, $62, $A9, $54, $AA, $55, $23, $26, $23, $29, $F5, $F3, $9F, $F8, $C7
                dc.b $F1, $EB, $A8, $C8, $DE, $65, $6E, $2D, $46, $5C, $E4, 8, $14, $66, $59, $61
                dc.b $5C, $31, $DC, $ED, $A9, $5C, $F8, $AB, $CE, $47, $A9, $A2, $40, $B2, $2A, $E0
                dc.b $A, $27, $FA, $55, $55, $AF, $3A, $AA, $82, $88, $C2, $33, $20, $53, $20, $55
                dc.b $2A, $D1, $58, $AA, $55, $29, $91, $91, $C6, $64, $A, $64, $A, $A5, $52, $62
                dc.b $A9, $1B, $97, $E9, $76, $10, $7F, $E9, $E2, $9F, $A5, $A1, $19, $19, $54, $AA
                dc.b $55, $25, $CB, $F8, $A7, $FE, $31, $FB, $7C, $9F, $F6, $66, $E5, $FB, $50, $E5
                dc.b $19, $B9, $45, $55, $6A, $5B, $39, $BF, $66, $ED, $12, $11, $27, $AC, $49, $EB
                dc.b $12, $75, $9E, $16, $29, $D0, $A3, $C5, $48, $CF, $A, $FE, $CD, $55, $56, $DC
                dc.b $51, $28, $E0, $29, $11, $11, $C4, $65, $11, $15, $55, $C0, $C8, $E8, $B3, $89
                dc.b $45, $A9, $16, $FE, $1A, $AB, $94, $6A, $E5, $1A, $B9, $7E, $D5, $9F, $F6, $70
                dc.b $7C, $53, $61, 2, $55, $59, $C4, $9E, $71, $27, $11, $21, $12, $73, $FD, $9B
                dc.b $E5, $FB, $75, $3F, $E9, $CF, $F6, $AD, $15, $55, $A9, $7F, $19, $7F, $A6, $7F
                dc.b $B5, $5A, $54, $AA, $40, $A6, $43, 6, $A4, $68, $A, $3B, $2B, $F9, $8C, $B8
                dc.b $EC, $55, $23, $26, $20, $40, $A7, $80, $E3, $6E, $2F, $CC, $7E, $97, 8, $EC
                dc.b $FC, $DE, $13, $E3, 5, $62, $C8, $95, $89, $B8, $CC, $A7, $F9, $82, $B7, $58
                dc.b $28, $EC, $62, $56, $2A, $94, $E2, $A, $B1, $EB, $3F, $E9, $AD, $3F, $4B, $42
                dc.b $32, $32, $A9, $54, $AA, $4D, $16, $FD, $AC, $FF, $A6, $A7, $77, $F9, $73, $FF
                dc.b $39, $EB, $FE, $39, $E7, $FC, $79, $FE, $DE, $DD, $8A, $A1, $C3, $8E, $A1, $FE
                dc.b $7D, $3F, $8F, $AC, $FF, $8F, $A1, $FE, $DE, $7D, $8A, $B6, $CF, $5E, $7A, $B4
                dc.b $D7, $A2, $AD, $BB, $27, $FB, $73, $CF, $F8, $67, $AF, $F8, $79, $FF, $8C, $7E
                dc.b $7B, $12, 4, $AA, $3B, $2D, $FB, $79, $FF, $F, $43, $FE, $1E, $B3, $FF, $1E
                dc.b $9F, $E2, $90, $EB, $14, $9E, $C5, $AE, $CA, $EC, $53, $D8, $28, $DD, $6A, $28
                dc.b $3A, $C5, $27, $45, $A2, $E5, $4A, $D2, $74, $1D, $62, $8A, $74, $14, $14, $3D
                dc.b $96, $D8, $AD, $43, $D8, $74, $14, $3D, $99, $50, $E8, $AD, $FA, $51, $19, $F3
                dc.b $AD, $79, $EB, $CE, $A7, $CE, $22, $DF, $A5, $51, $11, $FA, $51, $19, $C5, $62
                dc.b $B9, $46, $B1, $9C, $47, $E9, $44, $54, $E2, $22, $22, $7C, $F6, $E7, $56, $89
                dc.b $F3, $9C, $44, $4F, $9F, $28, $9C, $55, $BA, $43, $CF, $52, $D7, $55, $75, $29
                dc.b $EA, $E, $DD, $2A, $1C, $74, $87, $9B, $AB, $AE, $4F, $57, $9B, $8E, $90, $EA
                dc.b $6E, $1C, $39, $EA, $B6, $A5, $67, $3D, $46, $E1, $CF, $56, $4E, $6E, $7F, $F7
                dc.b $FF, $A4, $F9, $8D, 2, $D, $4C, $81, $1E, $8C, $F4, 9, $6A, 4, $9D, 2
                dc.b $38, $F1, $8F, $8C, $61, $FB, $41, $FB, $4B, $DB, $73, $A4, $F5, $50, $23, $6C
                dc.b 8, $C8, $68, $F3, $BD, $E6, $81, $F7, $C4, $63, $CF, $F, $FA, $7F, $44, $FF
                dc.b $8E, $D4, $3D, $88, $DB, $2C, $8D, $79, $BE, $E7, $6A, $6E, $A2, $2C, $F7, $55
                dc.b $C2, $55, $D2, $DB, $17, $73, $5F, $D2, $28, $22, $8E, $D4, $AA, 4, $34, $A0
                dc.b $7A, $32, $A, $1A, $35, $FB, $11, $9D, $92, $6E, $BB, $1E, $14, $1B, $15, $B6
                dc.b $21, $F5, $A8, $BC, $F9, $9D, $B7, $59, $32, $40, $8E, $1F, $66, $54, $34, $FD
                dc.b $B2, $CF, $74, $D3, $A6, $69, $D6, $7F, $F4, $F1, $88, $F1, $DF, $5D, $86, $87
                dc.b $79, $DE, $CF, $7B, $D9, $D5, $28, $86, $9B, $3F, $48, $3F, $69, $1F, $18, $FE
                dc.b $D1, $92, $68, $77, $B2, $33, $A2, $A9, $A1, $A5, $10, $FF, $E9, $FC, $3E, $C6
                dc.b $ED, $C3, $8C, $F6, $E1, $F9, $B3, $DA, $5F, $9B, $53, $2D, $A5, $D0, $D8, 2
                dc.b $FD, $C7, $47, $18, $2F, $E4, $19, $71, $F3, $6D, $E3, $C3, $B6, $7C, $7D, $18
                dc.b $6D, $3C, 7, $E6, $CB, $68, $25, $9F, $41, $6D, $FE, $C1, 2, $FC, $C7, $EA
                dc.b $C8, $17, $40, $E2, $E8, $55, $C8, $AA, $55, $21, $C7, $32, $50, $46, $5D, 5
                dc.b $52, $32, $A9, $54, $AA, $4C, $4D, $D0, $64, $C4, $64, 8, $C8, $10, $26, $20
                dc.b $4D, $D1, $32, $53, $2A, $95, $48, $14, $C8, $11, $91, $F1, $F4, $7E, $60, $66
                dc.b $3A, 7, $EC, $F3, $FC, $C7, $EA, $C1, $19, $54, $95, $56, $A5, $FA, $8E, $83
                dc.b $FE, $18, $E8, $1F, $FA, $55, $85, $B7, $D7, $8A, $C9, $5B, $EB, $41, $79, $EF
                dc.b $8A, $1E, $F6, $82, $9F, $E8, $8E, 6, $87, $BD, $91, $BF, $6D, $CC, $ED, $CC
                dc.b $1E, $B7, $EC, $9F, $E8, $9B, $7D, $77, $B4, $27, 3, $87, $F1, $B7, $8F, $E0
                dc.b $CE, $26, $EC, $F0, $D4, $AA, $BF, $B2, $6F, $E1, $34, $15, $56, 2, $13, $DE
                dc.b $3F, $A4, $D0, $1B, $EB, 6, $81, $C2, $B0, $9F, $E8, $8F, $F6, $43, $79, $C2
                dc.b $3A, $AF, $68, $AB, $3A, $AB, $45, $B1, $67, $14, $7C, $59, $28, $35, $35, $E3
                dc.b $57, $F0, $5B, $F6, $E4, $AA, $DF, $B4, $9F, $8E, $F2, $70, $8E, $9A, $A9, $AB
                dc.b $AC, $DF, $76, $50, $9D, $F0, $3A, $31, $78, $AA, $AF, $5B, $A0, $C4, $6E, $3D
                dc.b $FB, $17, $62, $EC, $55, $53, $79, $E3, 7, $1F, $B6, $DF, $A9, $55, $54, $FF
                dc.b $8E, $35, $2D, $75, $46, $97, $D1, $C4, $2B, 1, $86, $3A, $93, $7A, $60, $36
                dc.b $2B, $20, $4A, $A2, $B6, $AD, $CA, $86, $94, $17, $8D, $F4, $3D, $E4, $C8, $38
                dc.b $B7, $9A, $1A, $5A, $F5, $B6, $E3, $80, $4E, $24, 5, 2, $10, $20, $82, $18
                dc.b $21, $DE, $11, $92, $7B, $95, $5A, $1B, $37, $A6, $A2, $F1, $DE, $28, $78, $5A
                dc.b $F1, $79, $B9, $DE, $37, $32, 4, $B2, 4, 9, $34, $6F, $F3, $AE, $54, $4A
                dc.b $36, $C6, $A3, $D0, $20, $40, $93, $40, $87, $7A, $E5, $CC, $77, $FE, $E4, $27
                dc.b $6C, $D3, $6A, $AA, $AD, $53, $24, $CB, $B5, $72, $DA, $AB, $6C, $EB, $99, $7F
                dc.b $62, 9, $F9, $85, $FC, $C2, $F1, $AA, $F1, $9E, $79, $12, $DB, $F3, $A, $AA
                dc.b $AA, $A9, $B6, $BC, $7B, $67, $9E, $DA, $E6, $59, $66, $AA, $AA, $36, $9E, $D3
                dc.b $D3, $B4, $F6, $8E, $3A, $16, $59, $AA, $A8, $D0, $F8, $DB, $4A, $E8, $34, $B6
                dc.b $CF, $D4, $2A, $AC, $FF, $D2, $7D, $A7, $B5, $54, $FF, $51, $7F, $1A, $1E, $D9
                dc.b $ED, $6F, $DC, $B7, $F6, $53, $6A, $AA, $D7, $B4, $FF, $7D, $DB, $6D, $36, $B6
                dc.b $AD, $2D, $B5, $57, $B5, $72, $ED, $D1, $B6, $FE, $61, $34, $6D, $AB, $96, $DC
                dc.b $B6, $AA, $A6, $5B, $4F, $F7, $17, $AA, $AA, $AA, $A9, $A7, $EA, $2F, $FC, $C2
                dc.b $6D, $55, $C9, $36, $AA, $AD, $BF, $31, $B6, $7B, $72, $DA, $AB, $FC, $99, $EE
                dc.b $55, $9E, $DF, $D4, $6D, $1F, $98, $DB, $64, $1D, $B3, $DA, $A8, $3B, $67, $B4
                dc.b $D3, $6E, $49, $B7, $24, $E3, $DA, $3F, $30, $7D, $A9, $C7, $3E, $DA, $F1, $8E
                dc.b $39, $F1, $8E, $3D, $A3, $F5, $A, $7B, $52, $7D, $A8, $DD, $B7, $B7, $1D, $EA
                dc.b $AA, $AA, $AB, $34, $C9, $15, $72, $45, $AA, $38, $FE, 9, $A7, $F1, $CD, $3F
                dc.b $8C, $94, $1B, $A6, $9D, $28, $CE, $A1, 3, $A1, $DE, $11, $55, $D0, $FF, $6E
                dc.b $8B, $3A, $35, $27, $41, $41, $49, $D1, 2, $52, $7B, $8E, $8C, $93, $A2, $FF
                dc.b $19, $45, $2B, $41, $99, $D1, $76, $5A, $8D, $2C, $ED, $2C, $E7, $41, $9D, $5D
                dc.b $45, $2C, $94, $14, $3A, $66, $10, $26, $C1, $98, $DC, $72, $64, $6C, $EB, $2B
                dc.b $5F, $AF, $AE, $DB, $9C, $20, $49, $B8, $47, $41, $78, $E9, $46, $BD, $43, $DE
                dc.b $EC, $83, $50, $E9, $46, $BC, $E9, $A8, $DD, $92, $7B, $2F, $76, $41, $A8, $23
                dc.b $73, $29, $A2, $B7, $FA, $86, $63, $A3, $31, $D0, $33, $6C, $C7, $E6, $C6, $6D
                dc.b $98, $FD, $59, $F4, $C, $C7, $E6, $CF, $A0, $FB, $F, $35, $3E, $A1, $9A, $E
                dc.b $AE, $8A, $FE, $6E, $DF, $9B, $1F, $BA, $1D, 3, $33, $E8, $1D, $8D, $F9, $BB
                dc.b $66, $3F, $37, $6E, $A4, $FD, $D4, $F3, $1D, $19, $9F, $54, $FA, $BA, $27, $98
                dc.b $FC, $DD, $BF, $36, $33, $6F, $CD, $F5, 4, $34, $CD, $91, $73, $45, $56, $D5
                dc.b $67, $E7, $9B, $C7, 6, $78, $94, $DE, $24, $B3, $71, $1E, $B4, $71, $FB, $50
                dc.b $FC, $FF, $B3, $E7, $C2, $78, $58, $AC, $40, $AC, $56, $A5, $51, $FF, $A2, $BA
                dc.b $AB, $CE, $F6, $C2, $2F, $52, $8B, $D4, $A2, $EA, $69, $42, 5, $4B, $D6, 0
                dc.b $95, $8B, $6D, $9F, $1B, $39, $E8, $CF, $57, $B1, $53, $FA, $EA, $B9, $16, $DB
                dc.b $11, $ED, $62, $18, $9E, $D0, $43, $11, $A1, $94, $DF, $B7, 0, $94, 5, $52
                dc.b $C7, $69, $94, $5C, $F4, $DB, $3C, $5B, $6D, $74, $1B, $6B, $A2, $B6, $28, $DA
                dc.b $62, $8A, $A7, $FC, $EC, $72, $CD, $4F, $FB, $E7, $FD, $5C, $6E, $6F, $D2, $C
                dc.b $CF, $16, $C5, $4F, $19, $F6, $7F, $39, $7F, $FF, $FF, $5F, $E2, $66, $22, $AA
                dc.b $BF, $CE, $56, $FE, $FC, $47, $F9, $47, $F8, $9D, $6B, $F9, $B9, $DF, $D5, $3F
                dc.b $DD, $35, $3F, $74, $CF, $64, $E8, $FD, $D1, $A7, $F2, $85, $E7, $DA, $7F, $BA
                dc.b $ED, $3F, $DD, $37, $56, $59, $9B, $91, $E6, $CE, $4B, $D8, $1F, $77, $EA, $C3
                dc.b $EE, $6F, $DD, $24, $FA, $87, $43, $67, $3E, $8B, $76, $22, $A7, $FE, $BA, $3B
                dc.b $1B, $34, $CB, $F7, $53, $EC, $3E, $A1, $D8, $79, $82, $FE, $D0, $2B, $D5, $FF
                dc.b $95, $78, $EC, $9B, $A9, $E7, $97, $63, $DB, $A9, $ED, $D4, $1F, $27, $B6, $79
                dc.b $67, $37, $6F, $DD, $6B, $FF, $D7, $FE, $BA, $91, $BB, $3A, $1B, $33, $49, $F5
                dc.b $23, $7F, $AD, $16, $7D, 7, $9D, $BB, $2D, $7E, $75, $4C, $D6, $BD, $5C, $DD
                dc.b 8, $DB, $7B, $1F, $68, $CC, $86, $61, $CB, $F7, $56, $FD, $D3, $66, $59, $ED
                dc.b $EA, $19, $8D, $A0, $86, $63, $F, $ED, $61, $FB, $AF, $DD, $E6, $BD, $9D, $D
                dc.b $D8, $77, $8E, $C3, $EA, $E8, $D7, $B7, $F9, $5D, $E, $46, $F7, $8E, $C4, $A3
                dc.b $7E, $AD, $4F, $F3, $B5, $CC, $6B, $AF, $54, $F5, $DB, $F3, $B9, $B7, $E7, $46
                dc.b $73, $EC, $3F, $FB, $CF, $F8, $E7, $AE, $6E, $79, $CF, $A5, $54, $6A, $B3, $9F
                dc.b $F1, $ED, $BA, $68, $72, $FD, $6B, $EC, $90, $EC, $6C, $D7, $33, $FF, $BA, $D7
                dc.b $FF, $A7, $FF, $AA, $F5, 7, $67, $FC, $EB, $B3, $D9, $C3, $D5, $C3, $D5, $C6
                dc.b $BD, $53, $7C, $CD, $ED, $D3, $37, $55, $CB, $F6, $F5, $D5, $37, $1F, $D7, $51
                dc.b $FB, $73, $7C, $9D, $56, $DD, $2A, $AA, $BA, $97, $F5, $BB, $87, $56, $BC, $E4
                dc.b $28, $FA, $C3, $8C, $E8, $AD, $FD, $75, $5C, $B5, $DB, $F3, $A1, $CF, $F3, $A7
                dc.b $98, $71, $FB, $D7, $3E, $96, $FE, $39, $BD, $B5, $28, $FD, $EB, $F5, $1F, $63
                dc.b $75, $35, $25, $D5, $FB, $7B, $F5, $2F, $4E, $4F, $5C, $F5, $BD, $B3, $19, $D7
                dc.b $31, $F9, $D7, $41, $D4, $79, $D0, $3F, $EF, $5E, $F5, $FF, $B2, $9F, $F5, $1B
                dc.b $42, $FC, $F1, $37, $EB, $46, $B6, $D6, $34, 4, $DA, $E0, $A, $D0, $32, $3C
                dc.b $5F, $3E, $DC, $D7, $FE, $9F, $AE, $97, $E7, $B8, $10, $20, $50, $B4, $8A, $70
                dc.b $4D, $70, $64, 8, $D0, $1F, $98, $ED, $FC, $C6, $7C, $6B, $FF, $4D, $38, $69
                dc.b $2D, $25, $A4, $F, $F4, $4D, $70, $96, $83, $F4, $57, 9, $69, $BC, $40, $7E
                dc.b $C9, 7, $E6, $3A, $BF, $31, $B6, $2B, $FD, $43, $FD, $66, $B9, $59, $15, $27
                dc.b $B9, $61, $3E, $D9, 4, $D7, $C7, $16, $82, $15, $ED, 1, $B, $DA, 2, $EB
                dc.b $5D, 3, $83, $5C, $2E, $10, $6B, $B4, $95, $D0, $6D, $7A, $17, $E7, $78, $F6
                dc.b $EB, $DF, $AE, $1A, $D0, $24, $8F, $78, $41, $A3, $41, $3F, $84, $70, $38, 8
                dc.b $1E, $BB, $40, $B5, $8D, $62, 5, 4, $3F, $CE, $C0, $8F, $5C, 6, $B8, $60
                dc.b $2E, $81, $A3, $40, $C8, $23, $11, $F3, $11, $EE, $9C, $2F, 8, $3F, $A2, 8
                dc.b $20, $43, $23, $41, $7E, $BC, $DC, $22, $A5, $AF, $AA, $1C, $2E, $6B, $E1, $F9
                dc.b $D6, $C3, $F3, $B9, $7E, $75, $BA, $88, $6B, $2E, $A6, $FC, $E8, $D7, $32, $1F
                dc.b $AD, $62, $D3, $58, $D6, $DA, $DB, $46, $D0, $5D, 4, $6E, $68, $4D, 2, $43
                dc.b $AB, $5C, 9, $F, $59, $EF, $4B, $93, $59, $DE, $34, $21, $AF, $4E, $2D, $7A
                dc.b $15, $DF, $9D, $3F, $D7, $40, $7E, $74, $68, 9, $B5, $8D, 6, $B9, $93, $60
                dc.b $30, $3C, $C, $A7, $81, $EB, $62, $6D, $60, $AC, $55, $23, $43, $C0, $E0, $30
                dc.b $3E, $6D, $B, $42, $BA, $5B, $71, $2D, $3F, $3B, $73, $68, $42, $E8, $31, $69
                dc.b 1, 9, $A0, $49, $DF, $B, $21, $94, $1B, 0, $50, $6E, $AD, $2F, $D7, $C6
                dc.b $F3, $40, $96, $4D, $69, $B, $6B, $BE, $77, $84, $6F, $D6, $6B, $91, $FF, $53
                dc.b $FF, $B1, $7F, $D2, $47, $C4, $40, $15, $E3, $9A, 8, $10, $D0, $20, $43, $43
                dc.b $BD, $BF, $F9, $FF, $4F, $FE, $C7, $17, $E7, $F1, $8A, 8, $5E, $12, 1, $18
                dc.b $A0, $5B, $88, $60, $77, $C3, $70, $FF, $66, $BF, $FA, $7F, $F7, $56, $2F, $1D
                dc.b $BA, $CC, $84, $26, $41, $2A, $93, $C4, $25, $B1, $1F, $CC, $6F, $EA, $1F, $FB
                dc.b $47, $FE, $C4, $84, $AD, $41, $2B, $66, $72, $39, 9, $1C, $8E, $42, $53, $FD
                dc.b $60, $CF, $80, $FD, $60, $A4, $84, $9E, $47, $21, $C1, $E4, $AA, $A2, $42, $56
                dc.b $96, $52, 5, $23, $B8, $15, $D8, $4A, $E2, $1C, $A5, $74, $AE, $92, $AA, $D6
                dc.b $53, $91, $C8, $48, $E5, $32, $17, $4E, $57, $B, $A7, $25, $59, $CA, $D2, $12
                dc.b $B4, $95, $55, $55, $54, $E5, $5F, $D6, $1C, $87, $C, $F8, 9, $36, $62, $53
                dc.b $E1, $C8, $E4, $54, $81, $34, $84, $60, $53, $E4, $30, $B7, $EB, $14, $48, $4A
                dc.b $D2, $12, $39, $E, $17, $69, $C8, $85, $20, $10, $21, $5D, $18, $15, $C4, $92
                dc.b 5, $22, $BA, $5F, $AF, $12, $B8, $B8, $5C, $D2, $A0, $E0, $7C, $29, $2B, $BF
                dc.b $58, $38, $B, $84, $AE, $69, $31, $F, $D6, 9, 2, $E0, $24, $38, 9, $F
                dc.b $D6, $19, $4B, $39, 9, $4F, $3E, 2, $E2, $FD, $60, $CC, $20, $93, $6D, $94
                dc.b $A, $4D, $70, $E1, $62, $6E, $42, $5B, $79, $4B, $69, $CB, $68, $B8, $66, $2E
                dc.b $D2, $FD, $20, $57, $FE, $B0, $40, $B6, $A7, $EB, $13, $7F, $40, $85, $E3, $F3
                dc.b $D2, $BA, $58, $71, $D6, $4F, $CA, $42, $E9, $34, $48, $5C, $77, $24, $45, $D2
                dc.b $12, $B8, $23, $5C, $77, $91, $91, $E0, $DC, $E, $5D, 5, $C2, $9C, 7, $41
                dc.b $CB, $36, $E0, $7C, $1A, $47, $29, $C8, $E4, $AA, $AD, $2C, $A5, $39, 9, $34
                dc.b $84, $84, $9B, $84, $E4, $2E, $CE, $E6, $E1, $76, $D2, $9C, $81, $4A, $B2, $12
                dc.b $3B, $A5, $A4, $B4, $E0, $2E, $94, $A, $D, $2B, $8A, $E2, $E0, $24, $57, $48
                dc.b $A4, $DC, $33, $39, $34, $B3, $39, 9, $1F, 6, $94, $F8, $69, $74, $AE, $E0
                dc.b $41, 8, $15, 1, 2, $90, $96, $BF, $DE, $E, $1D, $12, $B7, $EB, $14, $E4
                dc.b $72, $39, 9, $1C, $9B, $80, $93, $48, $4A, $7C, 7, $F3, $28, $28, $24, $38
                dc.b $52, $54, $39, $1F, $F7, $1A, $47, $25, $5B, $67, $96, $6B, $69, $57, $84, $DC
                dc.b $4A, $CE, $25, $94, $94, $49, $A4, $D2, $69, $5A, $59, $48, $E5, $39, $1C, $A7
                dc.b $29, $E6, $25, $68, $89, $5A, $E1, $9D, $65, $9D, $64, $24, $2E, $12, $17, 9
                dc.b $B, $A4, $2E, $21, $23, $29, $5D, $C0, $72, $21, $70, $C0, $CA, $E0, $FF, $EF
                dc.b $76, $90, $B8, $70, $39, $72, $1F, $AC, $BA, $44, $7C, $A, $E9, $11, $F1, $70
                dc.b $23, $2B, $8A, $42, $42, $42, $57, $7E, $B0, $70, $39, 9, $66, $72, $39, $C
                dc.b $E5, $39, $1C, $8E, $56, $80, $95, $A0, $D7, $65, $72, $89, $35, $D3, $91, $97
                dc.b $EB, $32, $FD, $61, $94, $8E, $4E, $64, $24, $25, $D0, $D7, $69, $70, $95, $DC
                dc.b $B, $42, $9D, $D0, $91, $70, $C0, $68, $2E, $C0, $16, $B8, $4A, $EC, 1, $6F
                dc.b $B8, $F4, $2B, $9C, $15, $C3, $4B, $A4, $FC, 6, 3, $F9, $98, $48, $E5, 1
                dc.b $A4, $8A, $45, $D, $38, $5C, $42, $E8, $1E, $DB, $BF, $98, $1C, $E4, $2E, $12
                dc.b $3F, $D6, $5D, $C1, $A5, $75, $64, $55, $E0, $25, $95, $24, $7F, $AC, $14, $90
                dc.b $91, $C8, $70, $5B, $A5, $62, $BB, $46, $E0, $9A, $4F, $85, $ED, $21, $21, $74
                dc.b $E, $42, $5C, $8F, $4E, $52, $86, $B1, $A2, $C, $3F, $3C, $48, $30, $18, $6B
                dc.b $3D, $2E, $DD, $20, $52, $D3, $F8, $3B, $F7, 2, $80, $24, $10, $48, $68, $97
                dc.b $69, 1, $FA, $E2, $12, $C2, $EE, 5, $28, $5C, $D0, $10, $4D, $2E, $42, $D6
                dc.b $81, 5, $C9, $71, $EF, $40, $52, $43, $2B, $B0, $10, $49, $14, $85, $C4, $2E
                dc.b $12, $23, $BA, $65, $C0, $10, $90, $90, $90, $B8, $48, $E5, $95, $1B, $81, $E6
                dc.b $DF, $AC, $CA, $56, $94, $E4, $72, $3E, $42, $47, $B, $85, $D2, $81, $C2, $E2
                dc.b $38, $4E, $47, $29, $C8, $49, $A4, $24, $24, $D2, $5B, $4B, $F3, $C7, $74, $87
                dc.b $E8, $84, $AE, $90, $D3, $F7, $8D, $23, $E0, $D2, $69, $56, $4D, $9B, $49, $B3
                dc.b $68, $5A, $43, $46, $93, $48, $48, $48, $49, $A4, $D9, $89, 9, $35, 4, $84
                dc.b $86, $62, $56, $CD, $B3, $CB, $3A, $CB, $29, $57, $31, $2B, $66, $24, $AA, $A7
                dc.b $C, $A0, $3F, $E2, $AA, $AA, $AA, $BF, $F2, $1F, $E4, $3F, $E8, $C4, $20, $E9
                dc.b $40, $81, $1F, $61, $BD, 2, $1A, $1D, 2, 4, $71, $40, $8E, $1C, $47, $14
                dc.b $A5, $FB, $FC, $67, $E3, $92, $2A, $2D, $51, $72, $48, $E3, $1C, $23, $8C, $7F
                dc.b $C8, $3F, $C3, $1F, $F3, $8E, $B3, $D9, $16, $D8, $DB, $99, $22, $35, $6E, $71
                dc.b $1D, $9B, $A8, $8B, $1B, $D9, $D, $C2, $1B, $D0, $DD, $2D, $B1, $B6, $36, $E6
                dc.b $BF, $A5, $90, $5E, $E1, $15, $2A, $99, $5F, $92, $64, $8B, $93, $D1, $EF, $7A
                dc.b $28, $A4, $F6, $44, $7E, $D9, $AF, $9A, $45, $C7, $33, $9B, $EE, $B2, $59, $C3
                dc.b $EC, $7A, $25, $A8, $71, $FD, $B2, $9A, $D, $C6, $8F, $1E, $99, $C7, $AC, $D2
                dc.b $83, $FC, $91, $C6, $38, $47, $C5, $52, $B7, $AA, $E4, $95, $4F, $19, $F8, $EF
                dc.b $1A, $86, $23, $63, $21, $A0, $43, $BC, $3D, $EC, $F1, $E, $B5, $D8, $86, $94
                dc.b $8F, $F9, $14, $FF, $C9, $1F, $E0, $9C, $47, $4A, $32, $3E, $C0, $82, $21, $D
                dc.b $E, $21, 2, $3B, $23, $87, $68, $D1, $1E, $FA, $22, $AA, $AA, $AA, $C7, $FA
                dc.b $71, $FF, $21, $FF, $46, $27, $FC, $76, $EB, $38, $84, $6D, $8D, $BA, $68, $35
                dc.b $5F, $1C, $6F, $D8, $E1, $2D, $43, $8B, $20, $43, $43, $7A, $32, $4D, 4, $5B
                dc.b $62, $1E, $E3, $41, $1E, $99, $A3, $9E, $C7, $45, 9, $49, $C4, $20, $FD, $B3
                dc.b $5F, $57, $1B, $A2, $CF, $BA, $C8, $C8, $E6, $82, $F6, $A1, $A0, $8E, $C5, $3B
                dc.b $C4, $50, $D1, $D9, $EB, $1A, $1A, $51, $F, $FE, $98, $EF, $8F, $8C, $4F, $63
                dc.b $44, $5E, $10, $E2, $6F, $7D, $5D, $6C, $9B, $10, $E3, $FE, $4C, $A2, $43, $F8
                dc.b $87, $1D, $D6, $D4, $96, $D8, $11, $A2, $69, $38, $84, $7A, $BD, $A8, $9B, $E3
                dc.b $8C, $48, $FF, $89, $3E, $68, $CF, $A6, $DD, $73, $46, $8C, $F7, $4D, 6, $A8
                dc.b $92, 7, $14, $7A, $35, $2A, $81, $2C, $F4, $54, $B6, $C4, $68, $A1, $A4, $DE
                dc.b $B4, $70, $8F, $47, $A2, $B2, $52, $A8, $36, $46, $77, $D5, $C2, $46, $CF, $7D
                dc.b $53, $1A, $38, $47, $A0, $21, $4A, $C5, $92, $B7, $D9, $1D, $6A, $94, $49, $FF
                dc.b $10, $CA, $3E, $3B, $C1, $4F, $65, $AF, 9, $67, $BE, $AE, $B6, $4D, $88, $DF
                dc.b $C4, 5, $13, $8F, $10, $FD, $24, $E2, $99, $25, $62, $12, $A9, $58, $BA, $D6
                dc.b $89, $44, $8F, $14, $FF, $49, $5B, $E3, $57, $CA, $91, $B2, $2A, $46, $C8, $64
                dc.b $94, $BF, $AC, $52, $B1, 9, $5A, $2A, $5A, $34, $4C, $91, $6C, $4F, $4B, $E8
                dc.b $94, $5B, $25, $2A, $82, $35, $48, $D5, $D5, $41, $3D, $2F, $A2, $51, $4D, $2B
                dc.b $7D, $A2, $EB, $58, $D1, $2B, $FA, $49, $F1, $45, $1D, $29, $5A, $46, $D7, $E4
                dc.b $F1, $55, $B2, $52, $33, $FD, $20, $A2, $63, $F, $DB, $9F, $F6, $8D, $FF, $71
                dc.b 3, $7B, $BF, $51, 3, $E3, $8B, $FE, $A0, $F8, $E0, $F7, $7E, $62, $DA, $9B
                dc.b $79, $EA, $84, $7F, $31, $D9, $F9, $DF, $ED, $6B, $1F, $D8, $F, $77, $EE, $2E
                dc.b $78, $F, $DC, $D, $E3, $F7, 2, 3, $51, $EA, $51, $D5, $AF, $AB, $5D, $DC
                dc.b $7F, $DA, $38, $7E, $E1, $CE, $1F, $A8, $B9, $CF, $F5, $F, $1E, $33, $FC, $C5
                dc.b $CF, $E, $36, $D5, $6D, $47, $BC, $F9, $75, $1D, $DC, $67, $41, $F9, $8D, $F3
                dc.b $D6, $B6, $A0, $D6, $70, $3A, $D, $67, $1C, $9E, $7A, $DB, $8E, $E9, $76, $7F
                dc.b $CB, $7A, $AF, $FC, $BF, $EB, $FF, $75, $DE, $7F, $98, $D7, $9E, $FF, $CC, $A
                dc.b $5B, $5A, $CE, 7, $AC, $50, $E2, $7A, $C5, $D, $D4, $F5, $CF, $3D, $6D, $4D
                dc.b $71, $9E, $AC, $E2, $7A, $B9, $FB, $4F, $9C, $6D, 9, $3D, $1F, $63, $68, $37
                dc.b $1E, $82, $F0, $87, $C3, $5F, $EB, $23, $F, $EB, $FF, $D7, $8F, $F5, $3C, $7F
                dc.b $A9, $BC, $6E, 8, $FD, $6F, $D6, $37, $F, $E0, $8D, $C1, $35, $FE, $B3, $5F
                dc.b $EB, $1F, $8E, $71, $84, $73, $D5, $3E, $3D, $BC, $FA, $8E, $FD, $A3, $9C, $DF
                dc.b $66, $96, $DD, $A3, $5E, $2F, $D0, $F5, $FE, $B3, $5C, $8F, $1F, $DA, $D1, $31
                dc.b $80, $E3, $2E, $32, $DE, $9C, $61, 7, $1A, $31, 2, $56, $C7, $8F, $47, $D3
                dc.b $8F, $13, $89, $A6, $26, $F4, $BC, $B5, $1F, $E8, $92, $C, $EC, $E6, $E1, $C3
                dc.b $87, $67, $F, $37, $67, $3F, $F3, $9F, $F1, $E7, $D3, $62, $FE, $28, $2A, $63
                dc.b $AB, $C4, $A9, $89, $5B, $10, $4B, $6C, $6A, $54, $C4, $8C, $8C, $A9, $FB, $7C
                dc.b $79, $E8, $74, $E7, $FD, $BE, $34, $26, $20, $58, $D0, $AB, $8B, $10, $2B, $60
                dc.b $78, $D7, $1A, $16, $AF, $D2, $50, $87, $3D, $E, $9C, $E0, $A9, $FB, $7C, $4A
                dc.b $98, $82, $9E, $20, $94, $81, $1E, $20, $81, $19, $53, $13, $C0, $CA, $9F, $B7
                dc.b $C5, $41, $53, $F8, $E5, $4C, $70, $32, $18, $AE, $58, $D4, $A9, $8D, $4A, $9E
                dc.b $3A, $B1, $E7, $A5, $9F, $1F, $DB, $F8, $E0, $30, 4, $AA, $A6, $43, 0, $43
                dc.b $C7, $F6, $FE, $20
Latin1BPPTiles: dc.b 0, $7C, $C6, $E6, $D6, $CE, $C6, $7C
                dc.b 0, $18, $38, $18, $18, $18, $18, $3C
                dc.b 0, $7C, $C6, $C6, 6, $7C, $C0, $FE
                dc.b 0, $7C, $C6, 6, $3C, 6, $C6, $7C
                dc.b 0, $C, $1C, $3C, $6C, $CC, $FE, $C
                dc.b 0, $FC, $C0, $C0, $FC, 6, $C6, $7C
                dc.b 0, $7C, $C6, $C0, $FC, $C6, $C6, $7C
                dc.b 0, $FE, $C6, $C, $18, $30, $30, $30
                dc.b 0, $7C, $C6, $C6, $7C, $C6, $C6, $7C
                dc.b 0, $7C, $C6, $C6, $7E, 6, $C6, $7C
                dc.b 0, $18, $18, 0, $18, $18, 0, 0
                dc.b 0, $82, $44, $28, $10, $28, $44, $82
                dc.b 0, 6, $18, $60, $80, $60, $18, 6
                dc.b 0, 0, 0, $FE, 0, $FE, 0, 0
                dc.b 0, $C0, $30, $C, 2, $C, $30, $C0
                dc.b 0, $7C, $C6, 6, $1C, $30, 0, $30
                dc.b 0, $E, $C, $18, 0, 0, 0, 0
                dc.b 0, $38, $7C, $E2, $E2, $FE, $E2, $E2
                dc.b 0, $FC, $E2, $E2, $FC, $E2, $E2, $FC
                dc.b 0, $7C, $E2, $E0, $E0, $E0, $E2, $7C
                dc.b 0, $F8, $E4, $E2, $E2, $E2, $E4, $F8
                dc.b 0, $FE, $E0, $E0, $FC, $E0, $E0, $FE
                dc.b 0, $FE, $E0, $E0, $FC, $E0, $E0, $E0
                dc.b 0, $3C, $62, $E0, $E0, $EE, $66, $3A
                dc.b 0, $E2, $E2, $E2, $FE, $E2, $E2, $E2
                dc.b 0, $7C, $38, $38, $38, $38, $38, $7C
                dc.b 0, $3E, $1C, $1C, $1C, $1C, $9C, $78
                dc.b 0, $E2, $E4, $E8, $F4, $E4, $E2, $E2
                dc.b 0, $E0, $E0, $E0, $E0, $E0, $E2, $FE
                dc.b 0, $E2, $F6, $FE, $EA, $EA, $EA, $EA
                dc.b 0, $F2, $F2, $FA, $EA, $EE, $E6, $E6
                dc.b 0, $7C, $E2, $E2, $E2, $E2, $E2, $7C
                dc.b 0, $FC, $E2, $E2, $E2, $FC, $E0, $E0
                dc.b 0, $7C, $E2, $E2, $E2, $EA, $E6, $7E
                dc.b 0, $FC, $E2, $E2, $E2, $FC, $E4, $E6
                dc.b 0, $7C, $E2, $E0, $7C, 2, $E2, $7C
                dc.b 0, $FE, $38, $38, $38, $38, $38, $38
                dc.b 0, $E2, $E2, $E2, $E2, $E2, $E2, $7C
                dc.b 0, $E2, $E2, $62, $62, $24, $3C, $38
                dc.b 0, $E2, $EA, $EA, $EA, $EA, $7E, $12
                dc.b 0, $E2, $F4, $78, $3C, $3E, $4E, $86
                dc.b 0, $E2, $E2, $74, $78, $38, $38, $38
                dc.b 0, $FE, $E, $1C, $38, $70, $E0, $FE
ExitTiles:      dc.b 0, 9, $81, 3, 5, $35, $1D, $82
                dc.b 4, 9, $35, $1E, $83, 4, 8, $37
                dc.b $7C, $84, 2, 0, $14, $C, $25, $1C
                dc.b $34, $D, $47, $7D, $63, 3, $73, 2
                dc.b $FF, $4B, $3C, $4E, $4B, $F6, $CB, $F1
                dc.b $29, $29, $3F, $24, $7F, $4B, $93, $93
                dc.b $B2, $7E, $8B, $92, $49, $F9, $23, $F4
                dc.b $49, $23, $F8, $5F, $65, $CB, $97, $29
                dc.b $2F, $EA, $74, $B9, $5F, $76, $BE, $95
                dc.b $25, $4F, $C8, $9F, $D1, $E5, $CB, $B4
                dc.b $FD, $F, $29, $4F, $C8, $9F, $A1, $49
                dc.b $1F, $C1, $FB, $5D, $75, $D4, $97, $F5
                dc.b $3E, $11, $90, $FE, $6C, $3F, $84, $24
                dc.b $A0, $FC, $99, $FD, $3E, $46, $46, $C1
                dc.b $FA, $3E, $41, 7, $E4, $CF, $D1, $A4
                dc.b $8F, $E1, $FD, $87, $E, $1C, $2D, 0
SpritesTiles:   dc.b 1, $2F, $80, 5, $14, $15, $E, $24, 6, $34, 4, $45, $B, $55, $A, $66
                dc.b $2F, $73, 0, $81, 6, $31, $17, $71, $28, $F5, $82, 5, $F, $16, $35, $28
                dc.b $F4, $83, 6, $2E, $18, $EB, $84, 5, $11, $16, $34, $28, $EE, $85, 4, 3
                dc.b $16, $30, $28, $EA, $86, 4, 2, $15, $13, $27, $6E, $38, $F2, $48, $EF, $87
                dc.b 8, $ED, $18, $F3, $88, 7, $72, $89, 5, $16, $17, $70, $8A, 5, $10, $17
                dc.b $73, $8B, 5, $12, $18, $F0, $8C, 6, $2A, $16, $36, $27, $74, $8D, 6, $33
                dc.b $8E, 6, $32, $17, $6F, $28, $F1, $8F, 6, $2B, $18, $EC, $28, $F6, $FF, 1
                dc.b $5C, $53, $F6, $2C, $FF, $D8, $B3, $F1, $E0, $F6, $87, $2E, $1C, $9B, $B7, $95
                dc.b $A1, $C9, $BC, $F1, $D1, $B9, $3C, $A2, $F6, $E5, $A9, $1B, $6B, $8F, 6, $D7
                dc.b $1E, 8, $FC, $4E, $CB, $79, $3D, $5C, $80, $A3, $DC, $F4, $C7, $55, $F1, $D5
                dc.b $38, $6A, $9C, $39, $41, $21, $6E, $5D, $A9, $1C, $7C, $D2, $24, $FE, $48, $5A
                dc.b $F2, $4B, $63, $AA, $5B, $1D, $50, $F5, $59, $3D, $5C, $80, 1, $7C, $53, $F6
                dc.b $2C, $FF, $D8, $B3, $FF, $62, $D0, $E5, $C3, $93, $76, $F2, $B4, $39, $37, $9B
                dc.b $F4, $4D, $74, $4D, $4B, $93, $6B, $8F, 6, $D7, $1E, 8, $F3, $C6, $CB, $2D
                dc.b $40, $F, $73, $D3, $1D, $57, $EA, $F4, $E3, $AA, $70, $E5, 4, $85, $B9, $76
                dc.b $A4, $5F, $E6, $91, $D5, $65, $AA, $ED, $8E, $A9, $6C, $75, $4C, $4D, $EB, $79
                dc.b 0, 0, $4D, $51, $FE, $AC, $FC, $6D, $C5, $B9, $3F, $D5, $B9, $7E, $C9, $A1
                dc.b $AE, $3C, $9B, $B7, $F3, $18, $C5, $3D, $62, $D8, $EA, $5C, $99, $E6, $FE, $C
                dc.b $F3, $2E, $2A, $D4, 0, $1E, $E7, $A6, $3A, $AF, $8E, $B6, $6C, $75, $E4, $9E
                dc.b $9C, $93, $1D, $60, $98, $FE, $63, $B5, $3D, $56, $5A, $E2, $96, $C1, $E9, $8C
                dc.b $DE, $8F, 0, 6, $B0, $A6, $A8, $FF, $56, $E5, $FB, $16, $E4, $FF, $56, $87
                dc.b $EC, $9B, $B7, $F6, $2D, $C7, $5C, $5B, $1F, $48, $A6, 5, $C9, $30, $E0, $93
                dc.b $E2, $BF, $46, $B0, 1, $1E, $EE, $49, $8E, $AB, $E2, $FE, $49, $8E, $BC, $93
                dc.b $D2, 9, $8F, $E6, $3B, $51, $FC, $57, $E9, $8D, $2C, $E2, $F4, $4B, $6A, $BC
                dc.b $48, $D6, $F0, 0, 0, 5, $F1, $47, $FA, $B5, $CF, $C6, $CF, $6E, $BE, $17
                dc.b $37, $5D, $A1, $73, $42, $EB, $42, $E6, $F3, $C7, $46, $F3, $EE, $4C, $5F, $85
                dc.b $EF, $5E, $2F, $B3, $7A, $F0, $6B, $B8, $F0, $47, $F1, $B2, $EE, $C5, $EA, $25
                dc.b $C4, $C8, 0, 0, $14, $7B, $9E, $98, $EA, $BB, $62, $FB, $93, $87, $5A, $42
                dc.b $DD, $69, $B, $5D, 4, $8E, $3E, $69, $87, $9A, $13, $F1, $B, $7E, $2A, $B7
                dc.b $AA, $5B, $8D, $C9, $C5, $EB, $7D, $CA, $2B, $CB, 0, $1C, $FE, $28, $FF, $56
                dc.b $BB, $1B, $3E, $CD, $77, $B, $AC, $D7, $5A, $17, $41, $AE, $B4, $2E, $83, $79
                dc.b $F7, $37, $6F, $ED, $13, $18, $DC, $6A, $2A, $92, $EA, $71, $6E, $BE, $2F, $4E
                dc.b $3A, $B5, $DE, $8A, $78, $76, $2F, $A3, $D3, $1D, $57, $6C, $5F, $72, $70, $EB
                dc.b $4E, $1D, $69, $C2, $E8, $24, $5F, $E7, $4B, $9C, $71, $F3, $7D, $CE, $B9, $F8
                dc.b $BF, $AE, $78, $FE, $A7, $1B, $A8, $4F, $C7, $F5, $38, $CD, $F8, $FE, $A7, $1A
                dc.b $47, $D3, $D6, $91, $85, $DF, $B2, $D2, $EE, $6F, $B9, $D1, 0, 0, $D7, 7
                dc.b $DC, $FC, $52, $E7, $E3, $66, $BB, $5E, $2D, $77, $A6, $2D, $77, $A5, $CD, $77
                dc.b $EC, $9A, $EF, $4E, $D4, $BB, $5E, $D5, $DD, $A8, $BD, $EA, $B9, $E9, $D7, $8B
                dc.b $D3, $D5, $EB, $D7, $15, $3F, $1B, $CD, $58, 0, 0, $18, $EA, $BE, $3A, $A6
                dc.b $37, $63, $67, $B7, $5F, $B, $9B, $AE, $D0, $B9, $BA, $ED, $B, $9B, $B7, $58
                dc.b $A7, $6E, $A5, $16, $D6, $69, $CA, $FE, $2A, $C7, $82, $F1, $E0, $BC, $6D, $8A
                dc.b $F8, $AB, $19, $85, $E0, 0, 0, $52, $E0, $FB, $9F, $8A, $5C, $FE, $2D, $76
                dc.b $B8, $D9, $AE, $F4, $C5, $AE, $F4, $B9, $AE, $FD, $93, $5D, $E9, $DA, $97, $6B
                dc.b $DA, $BB, $B5, $17, $BD, $5A, $AE, $E7, $E2, $B7, $DB, $15, $DC, $FC, $57, $D4
                dc.b 0, 0, 1, $8E, $AB, $E3, $AA, $63, $73, $EC, $F6, $EB, $E1, $73, $75, $DA
                dc.b $17, $37, $5D, $A1, $73, $76, $BE, $D0, $4E, $DD, $62, $9A, $CE, $2D, $CA, $FE
                dc.b $2A, $C6, $D8, $AF, $F5, $2B, $C6, $D8, $AF, $8A, $B1, $2B, $C9, $5E, $41, $DC
                dc.b $51, $FE, $AD, $73, $F1, $B6, $2D, $D7, $C2, $E6, $EB, $B4, $2E, $68, $5D, $68
                dc.b $5C, $DE, $6F, $D1, $BC, $FB, $91, $F7, $60, $A7, $E2, $BE, $36, $67, $F1, $E0
                dc.b $D7, $3F, $8D, $93, $4E, $29, $3E, $B5, $DC, $E7, $BA, $E4, $C7, $55, $DB, $17
                dc.b $DC, $9C, $3A, $D2, $16, $EB, $48, $5A, $E8, $24, $5F, $E6, $98, $79, $A1, $5C
                dc.b $F5, $BE, $FE, $2A, $B7, $17, $A7, $17, $DC, $98, $E8, $BB, $A6, $AB, $82, $71
                dc.b $47, $FA, $B5, $CF, $C6, $D8, $B7, $5F, $B, $9B, $AE, $D0, $B9, $A1, $75, $A1
                dc.b $73, $79, $E3, $A3, $79, $E9, 4, $C5, $F8, $2B, $8A, $F1, $E0, $98, $DD, $C1
                dc.b $1F, $76, $36, $4B, $B4, $7A, $E7, $70, $7D, $2E, $5E, $3A, $AE, $D8, $BE, $E4
                dc.b $E1, $D6, $90, $B7, $5A, $42, $D7, $41, $23, $8F, $9A, $61, $E6, $84, $FC, $57
                dc.b $8D, $F6, $C5, $56, $BB, $15, $E3, $73, $D7, $A5, $CB, $98, 0, $25, $C1, $F7
                dc.b $DC, $CF, $C6, $97, $3D, $CF, $E3, $D6, $F7, $3F, $D6, $E7, $B9, $FE, $B7, $3E
                dc.b $97, $6B, $EA, $FB, $9F, $C5, $F8, $BD, $B1, $B6, $3E, $8E, $8D, $DE, $AE, $D2
                dc.b $E5, $69, $7E, $E0, 3, $AE, $7F, $1D, $5C, $FC, $6D, $C7, $5A, $3F, $D6, $EC
                dc.b $6D, $E9, $8F, $5F, $B, $B5, $FD, $1D, $A1, $77, $A7, $5D, $A1, $76, $BE, $7A
                dc.b $C6, $9A, $F9, $EA, $51, $FE, $14, $C0, 0, $5F, $70, $7D, $F7, $2A, $E7, $AA
                dc.b $E7, $DC, $BB, $9F, $73, $E9, $AD, $2E, $7D, $DA, $F1, $7D, $CF, $76, $3F, $B2
                dc.b $6E, $3E, $98, $B8, $F8, $FA, $53, $42, $A7, $17, $D2, $24, $EE, $BC, $69, $12
                dc.b $6B, $80, $14, $B9, $FC, $75, $73, $F1, $B7, $1D, $68, $FF, $5B, $B1, $B7, $A6
                dc.b $3D, $7C, $2E, $D7, $F4, $76, $85, $DE, $9D, $76, $85, $DA, $F9, $EB, $1A, $6B
                dc.b $E7, $A9, $47, $1F, $D9, $4C, $A, $3E, $FC, $40, 0, 5, $E0, $B3, $B1, $AC
                dc.b $E0, $6B, $3D, $17, $84, $92, $26, $46, $DF, $B4, $36, $2E, $A8, $A7, $54, $55
                dc.b $3B, $CE, $F2, 0, $C, $15, $6C, $17, 8, $9A, $F4, $35, $C7, 5, $99, $1E
                dc.b $8C, $7F, $C4, $74, $7F, $6A, $4E, $8F, $ED, $5B, 2, $BC, $EF, $20, 0, $D
                dc.b $82, $CE, $C6, $B3, $81, $AC, $F4, $5E, $12, $59, $91, $A4, $7A, $92, $26, $51
                dc.b $4C, $A, $2A, $32, $BC, $80, 0, $60, $AB, $60, $B8, $44, $D7, $A1, $AE, $38
                dc.b $2C, $CB, 4, $FD, $AC, $5A, $3D, $51, $68, $99, $60, $C6, $47, $79, 0, 0
                dc.b 8, $6A, $C1, $58, $2B, 6, $8E, 4, $6D, $FB, $42, $6E, $E3, $26, $C3, $43
                dc.b $4F, $DA, $A8, $C9, $51, $3B, $E2, 0, $1D, $4B, $D2, $C6, $91, $B4, $D, $34
                dc.b $B1, $45, $B0, $28, $A6, $A, $D0, $D6, $71, $35, $E0, $A2, $17, $98, 0, 5
                dc.b $1A, $B0, $56, $A, $C1, $66, $46, $B8, $99, $21, $E8, $68, $7A, $1A, $CE, $26
                dc.b $B2, $32, $51, $80, 0, $A7, $52, $F4, $B1, $A4, $6D, 3, $4D, $2C, $46, $D8
                dc.b $14, $50, $C9, $47, $13, $59, $C4, $D6, $71, $51, 0, 0, 1, $46, $AC, $15
                dc.b $82, $B0, $BC, $D0, $E3, $82, $17, $72, $1E, $86, $B2, $C1, $3C, 8, $EF, $35
                dc.b $68, 0, $1D, $4B, $D2, $C6, $91, $B4, $D, $34, $B1, $26, 4, $71, $63, $25
                dc.b $1C, $4D, $7A, $1A, $F0, $51, $B, $CC, 0, 2, $8D, $58, $2B, 5, $61, $79
                dc.b $A7, $ED, $50, $FB, $90, $B4, $35, $F5, $28, $8D, $71, $39, $2A, $60, 1, $D4
                dc.b $BD, $2C, $69, $1B, $40, $D3, $4B, $12, $60, $47, $16, $32, $51, $C4, $D7, $A1
                dc.b $AF, 5, $10, 0, 0, 0, $51, $DE, $77, $92, $FA, $90, $FB, $90, $B4, $35
                dc.b $F5, $2A, $6B, $C0, $AF, $90, 0, $F, $DA, $A1, $E9, $63, $63, $8D, $A0, $6C
                dc.b $7A, $58, $A2, $E2, $C0, $90, $E2, $4B, $D0, $D7, $D4, $B2, $35, $4A, $FF, 0
                dc.b 0, $14, $FD, $AB, $61, $68, $E0, $E3, $B4, $34, $83, $8E, $36, $89, $1B, $B0
                dc.b $8F, $81, $B8, $8E, $24, $6E, $38, $E1, $12, $3A, $68, $7A, $61, $42, $FD, $A9
                dc.b $45, $C5, $81, $26, $14, $92, $CF, $49, 0, 3, $7E, $D5, $B0, $D3, 7, $1C
                dc.b $34, $81, $B8, $ED, $A5, $8D, $C7, $19, $14, $49, $8B, 2, $43, $D0, $D8, $FF
                dc.b $68, $74, $89, $1E, $86, $51, $71, $60, $48, $6E, $36, $D0, $BB, $AF, $AA, $B5
                dc.b $6D, $7E, $69, $9B, $B3, $5E, $74, $CD, $3F, $7C, $BF, $15, $F8, $D5, $7D, $40
                dc.b $53, $35, $66, $AF, $15, $EF, $56, $F0, 0, $D, $B2, $AA, $AE, $A7, $66, $EC
                dc.b $F6, $A6, $59, $D3, $34, $DF, $9A, $7E, $FB, $F3, $AE, $FE, $72, $6F, 0, 1
                dc.b $4C, $BD, $93, $F7, $CA, $AE, $A5, $57, $52, $AB, $A9, $55, $D4, $AA, $EA, $57
                dc.b $EF, $F2, $5F, $8A, $EB, $BE, $BB, $EB, $BE, $BB, $EB, $BE, $B0, 0, $E, $C9
                dc.b $59, $76, $2B, $2E, $C5, $D7, $97, $63, $57, $55, $79, $57, $95, $2B, $AA, $B7
                dc.b $65, $4A, $EA, $AD, $55, $80, 0, $77, $EF, $13, $6D, $E9, $B6, $F4, $DB, $7A
                dc.b $6D, $BD, $32, $AB, $7A, $EA, $DE, $BF, $6D, $95, $95, $79, $6C, $D9, $56, $EA
                dc.b $9B, $2A, $DD, $53, $65, $5D, $2A, $4F, $15, $E5, $7D, $60, 1, $56, $4B, $AA
                dc.b $9B, $D2, $A7, $57, $53, $55, $4A, $F2, $D9, $D9, $57, $E3, $B5, $3F, $9D, $D2
                dc.b $BF, $1E, $94, $AF, $7F, $46, $EC, $DE, 0, 1, $D9, $AF, $6A, $D2, $AA, $55
                dc.b $9A, $55, $4A, $B3, $4A, $A9, $56, $69, $D3, $35, $D5, $F9, $D4, $AB, $F5, $B9
                dc.b $54, $AA, $EA, $56, $55, $2B, $2A, $95, $95, $4A, $CA, $A5, $6F, $A9, $7E, $35
                dc.b 0, 3, $AA, $55, $79, $66, $95, $65, $5D, $4E, $DB, $2C, $F6, $CB, $6C, $B3
                dc.b $AA, $95, $78, $E7, $53, $AA, $A6, $59, $ED, $4D, $9D, $9D, $54, $D9, $2A, 0
                dc.b 1, $4F, $14, $FC, $EE, $CD, $FA, $D5, $F4, $A6, $6A, $CF, $25, $E7, $95, $69
                dc.b $FA, $DC, $93, $F7, $9E, $2B, $DB, $F3, $AA, $FD, $6B, $67, $4E, $8D, $96, $6A
                dc.b $AF, $2C, $D7, $97, $EB, $53, $F7, $80, 0, $AA, $BF, $3B, $92, $EA, $CE, $AC
                dc.b $AF, $AB, $2F, $CE, $E5, $F9, $DA, $7E, $B7, $2A, $F2, $CE, $95, $67, $56, $79
                dc.b $57, $93, $AA, $A5, $59, $E5, $9A, $EA, $FC, $E8, 0, 0, $AC, $FF, $78, $99
                dc.b $F4, $5E, $7B, $2F, $F5, $AE, $AF, $F9, $CD, $FC, $F0, $DF, $AD, $77, $4C, $E9
                dc.b $9B, $B6, $FD, $EB, $AA, $CD, $5F, $9D, $57, $EF, $AB, $6F, $DF, $80, $BF, $CE
                dc.b $AF, $37, $66, $99, $D3, $35, $7E, $76, $A5, $67, $B3, $65, $4C, $FA, $3A, $BC
                dc.b $B3, $FD, $E3, $AB, $CB, $F9, $AE, $AF, $2B, $EB, $CA, $FA, $C0, 2, $BA, $95
                dc.b $D9, $55, $F9, $DF, $92, $B2, $AD, $79, $56, $AC, $AB, $56, $55, $BA, $AA, $D7
                dc.b $57, $62, $F3, $BF, $2B, $EB, $CA, $FA, $F2, $55, $79, $2A, $BC, $80, 0, $52
                dc.b $BA, $95, $5D, $4D, $E3, $F9, $DD, $B7, $F6, $65, $9F, $66, $55, $D3, $B3, $27
                dc.b $56, $D5, $E4, $BA, $F7, $A5, $7B, $C0, 0, $3B, $35, $F6, $66, $95, $EF, $CD
                dc.b $2B, $CB, $B1, $3F, $7E, $9F, $BF, $5D, $5D, $8A, $D8, $76, $2B, $D9, $7E, $CB
                dc.b $F6, $5F, $B2, $EB, $A8, 0, 0, $F6, $A6, $6E, $FD, $FE, $6E, $AB, $DB, $3E
                dc.b $CA, $55, $FB, $FC, $AB, $A5, $5E, $DB, $EB, $75, $5F, $BF, $4E, $80, 0, 0
                dc.b $76, $6D, $B5, $33, $AD, $2A, $A6, $79, $25, $54, $CF, $24, $DB, $3C, $97, $56
                dc.b $79, $2B, $F3, $B9, $5F, $F9, $D5, $76, $67, $4A, $9B, $7E, $75, $52, $A7, $6F
                dc.b $CD, $D5, $3B, $7E, $7B, $36, $FC, $D7, $FA, $D0, 2, $B6, $5D, $54, $A9, $75
                dc.b $3B, $3A, $F3, $CA, $95, $53, $3C, $BB, $33, $76, $7E, $3D, $94, $CF, $F7, $D9
                dc.b $D2, $AC, $FC, $73, $A6, $D4, $FD, $6D, $36, $6F, $DE, 0, 0, $A5, $77, $D6
                dc.b $AD, $EA, $D9, $5B, $2B, $65, $65, $5A, $BC, $6F, $CA, $FD, $EA, $AF, $25, $57
                dc.b $92, $AB, $C9, $55, $E4, $AD, $E0, 0, $13, $7B, $78, $F6, $3B, $2E, $CC, $AB
                dc.b $76, $5D, $9B, $65, $4C, $BB, $3A, $3B, $2A, $FA, $26, $5B, $2B, $20, 0, $E
                dc.b $DE, $9E, $DB, $DA, $BE, $99, $35, $7D, $32, $6A, $FF, $7C, $D5, $F4, $C9, $AB
                dc.b $E9, $93, $7F, $3F, $7A, $B2, $F6, $4E, $95, $A7, $4A, $D3, $C6, $B4, $E9, $5A
                dc.b $74, $AD, $3F, $7E, 0, $A, $EC, $DE, $D5, $ED, $5E, $FA, $57, $56, $5B, $78
                dc.b $F4, $DF, $55, $79, $57, $B6, $FD, $AB, $A5, $79, $6D, $95, $55, $BA, $BE, $95
                dc.b $A5, $75, $56, 0, 0, $53, $35, $E5, $F9, $D6, $CF, $2E, $8D, $F9, $DF, $64
                dc.b $FD, $F2, $57, $E2, $BF, $61, $9D, $FF, $9D, $C9, $7D, $32, $CD, $BD, $BF, $3A
                dc.b $DF, $BE, $4F, $1A, $D3, $D8, 0, $15, $9D, $37, $A6, $59, $ED, $F9, $D7, $6F
                dc.b $AF, $6C, $E9, $FB, $EA, $F6, $CA, $BF, $DF, $57, $56, $55, $FF, $3B, $37, $57
                dc.b $FC, $EC, $DD, $D9, $90, 0, $E, $8B, $F6, $5D, $7B, $D7, $5E, $F5, $D7, $BD
                dc.b $75, $EF, $5D, $7B, $D7, $ED, $D1, $7F, $CF, $6D, $F5, $BA, $B7, $6F, $AD, $D5
                dc.b $BB, $7D, $6E, $AD, $DB, $FD, $9B, $7D, $6B, $F6, 0, $2B, $D9, $3B, $1D, $5B
                dc.b $56, $EE, $CA, $9D, $5D, $2B, $DF, $5D, $4E, $AF, $F7, $D5, $D5, $5F, $F7, $BB
                dc.b $3F, $BD, $5D, $2B, $FD, $F5, $6D, $5E, $FA, $D7, $D8, 0, $E, $C9, $5B, $D5
                dc.b $BD, $79, $EC, $BC, $F6, $5E, $7B, $2F, $3D, $95, $BC, $65, $7E, $57, $D5, $9A
                dc.b $AA, $CD, $55, $66, $AA, $B3, $56, $40, 0, 3, $B3, $F1, $6C, $F6, $DE, $EC
                dc.b $FF, $79, $95, $33, $FE, $66, $74, $CB, $F7, $99, $BB, $7E, $D9, $A6, $FC, $C0
                dc.b 0, 6, $CD, $5D, $8E, $AF, $F9, $CD, $5F, $EF, $92, $BF, $14, $AF, $C5, $3F
                dc.b $7E, 5, $6E, $FD, $6B, $B7, $E6, $EC, $DD, $BE, $B7, $66, $ED, $F5, $FE, $B5
                dc.b $DB, $EB, $5F, $B0, $B, $FD, $6A, $F3, $A6, $6B, $CE, $95, $E4, $99, $D7, $BE
                dc.b $B6, $AF, $C6, $BC, $DD, $FC, $EA, $DD, $5F, $F3, $9A, $BF, $E7, $37, $F3, $F2
                dc.b $BE, $B0, 0, 0, 5, $60, $BE, $A5, $9C, $60, $90, $38, $D9, $3F, $74, $DA
                dc.b $73, $37, $7F, $10, $DC, $5F, $B5, $8B, $7E, $D6, $2B, $2C, $16, $77, $90, 0
                dc.b $3B, 5, $75, $2C, $E0, $6B, $8D, $8D, $7F, $AA, $59, $F3, $8A, $1F, $ED, $1A
                dc.b $3D, $44, $D1, $EA, $49, $A8, $EF, $20, 0, $B, $C1, $7D, $4B, $38, $C1, $20
                dc.b $71, $B2, $7E, $E9, $F, $99, $B4, $7F, $6A, $D1, $EA, $8B, $60, $47, $15, $99
                dc.b $1A, $C8, 0, 3, $B0, $57, $52, $CE, 6, $B8, $D8, $D7, $FA, $A5, $9F, $35
                dc.b $F5, $45, $22, $47, $14, $89, $60, $84, $6A, $20, 0, 1, $46, $AC, $15, $82
                dc.b $B0, $68, $E0, $46, $DF, $B4, $26, $EE, $32, $6C, $34, $34, $FD, $AA, $8C, $95
                dc.b $13, $BE, $20, 1, $D4, $BE, $E3, $48, $FE, $A9, $34, $E7, $16, $C0, $B4, $6C
                dc.b $A, $29, $A1, $AC, $E2, $6B, $C1, $44, $2F, $30, 0, $A, $35, $60, $AC, $15
                dc.b $82, $CC, $8D, $71, $32, $43, $D0, $D0, $F4, $35, $9C, $4D, $64, $64, $A3, 0
                dc.b 1, $4E, $A5, $F7, $1A, $47, $F5, $49, $A7, $33, $6C, $B, $46, $39, $C5, $E
                dc.b $26, $B3, $89, $AC, $E2, $A2, 0, 0, 2, $8D, $58, $2B, 5, $61, $79, $A1
                dc.b $C7, 4, $2E, $E4, $3D, $D, $65, $82, $78, $11, $DE, $6A, $D0, 0, $3A, $97
                dc.b $DC, $69, $FB, $A4, $D3, $9A, $60, $47, $16, $32, $51, $C4, $D7, $A1, $AF, 5
                dc.b $10, $BC, $C0, 0, $28, $D5, $82, $B0, $56, $17, $9A, $7E, $D5, $F, $B9, $B
                dc.b $43, $5F, $52, $88, $D7, $13, $92, $A6, 0, $1D, $4B, $EE, $34, $FD, $D2, $69
                dc.b $CD, $30, $23, $8B, $19, $28, $E2, $6B, $D0, $D7, $82, $88, 0, 0, 0, $28
                dc.b $EF, $3B, $C9, $7D, $48, $7D, $C8, $5A, $1A, $FA, $95, $35, $E0, $57, $C8, 0
                dc.b 7, $ED, $50, $FF, $74, $C7, $A7, $36, $3E, $E2, $8B, $8B, 2, $43, $89, $2F
                dc.b $43, $5F, $52, $C8, $D5, $2B, $FC, 0, 0, $53, $F6, $AD, $86, $98, $3B, $FB
                dc.b $4E, $3E, $71, $E6, $EC, $23, $28, $9B, $88, $E3, $83, $8E, $38, $44, $8E, $9A
                dc.b $1E, $98, $50, $BF, $6A, $51, $71, $60, $49, $85, $24, $B3, $D2, $40, 0, $DF
                dc.b $B5, $6C, $34, $C1, $DF, $DA, $77, $3D, $39, $B8, $E3, $22, $89, $37, $ED, $50
                dc.b $F4, $36, $3F, $DA, $1D, $22, $47, $A1, $94, $5C, $58, $12, $1B, $8D, $B4, $2E
                dc.b $E0, $1D, $F9, $DF, $47, $7E, $B7, $F6, $4E, $DD, $AA, $4D, $EA, $20, 2, $FF
                dc.b $8E, $EF, $F3, $BB, $BD, $37, $28, $80, $B, $F4, $E0, $EF, $D9, $7E, $A5, $DA
                dc.b $EE, $47, $CD, $44, 0, 0, $52, $A, $28, $C1, $73, $38, $31, $4B, $73, $6E
                dc.b $B4, $18, $A4, $56, $83, $4F, $62, $42, $E8, $9E, $40, 0, 0, $68, $2A, 5
                dc.b 6, $F2, $83, $79, $41, $8A, $D0, $28, $31, $5A, $13, $83, $A4, $55, $4E, $E
                dc.b $FD, $E1, $41, $D0, $DD, 0, 0, 0, 8, $2A, $7C, $D3, $C9, $3C, $92, $70
                dc.b $B3, $6E, $85, $9A, $7B, $13, $4F, $A2, $79, 0, 0, 1, $A0, $A8, $14, $18
                dc.b $A0, $65, 6, $23, $9F, $37, $14, $2D, $38, $38, $A1, $62, $94, $1D, $22, $AA
                dc.b $70, $77, $EF, $A, $E, $86, $E8, 0, 0, $17, $C1, $45, $18, $2E, $67, 2
                dc.b $77, $F5, $9D, $BA, $D0, $27, $6E, $B4, 9, $D3, $D8, $A4, $C5, $FB, $C6, $96
                dc.b $E8, $36, $E8, $26, $C5, 4, $FD, $D0, 0, $34, $15, 2, $82, $6E, $82, $6E
                dc.b $82, $5A, 5, 4, $B4, $27, 6, $2A, $A7, 6, $E8, $50, $6D, $D0, 0, 0
                dc.b 0, $82, $88, $E0, $B9, $9C, $DB, $BD, $A7, $B, $13, $B7, $42, $C4, $E9, $EC
                dc.b $52, $74, $FF, $78, $DE, $50, $6D, $DC, $DB, $62, $82, $7E, $E8, 0, $1A, $A
                dc.b $81, $41, $21, $38, $26, $EE, $6D, $B, $4E, $D, $B, $4E, $C, $55, $4E, $D
                dc.b $D0, $A0, $DB, $A5, 6, $E7, $E1, 4, $84, $E0, $90, $A8, $A0, $90, $A8, $A0
                dc.b 0, 1, $64, $A9, $D0, $DA, $53, $91, $B7, $F5, $9D, $E1, $DF, $4D, $C7, $69
                dc.b $D2, $44, $76, $84, $E9, $BA, $D0, $9C, $3C, $3C, $B6, $EF, $E9, $2F, $2E, $6D
                dc.b $34, $96, $E4, $F0, $32, $42, $91, $1A, $4E, $44, $93, $92, $E6, $AD, $D8, 7
                dc.b $12, $8A, $4A, $9A, $BC, $15, $35, $14, $AF, $20, 1, $28, $A9, $24, $F0, $71
                dc.b $3A, $53, $69, $13, $88, $5E, $40, 0, $18, $95, $3A, $1B, $4A, $72, $37, $7F
                dc.b $9A, $9F, $AB, $FF, $B1, $1D, $A7, $E0, $47, $68, $7F, $5A, $D0, $9F, $EA, $FC
                dc.b $AA, $FE, $B6, $D4, $97, $97, $36, $9A, $78, $4D, $A4, $52, $32, $37, $4E, $58
                dc.b $13, $B7, $4A, $A6, $DC, $B9, $AB, $76, 0, $38, $AF, $2B, $E5, $79, $5E, $40
                dc.b 0, $52, $59, $38, $9A, $44, $D2, $29, $4E, $F2, $17, $90, 0, $42, $FA, $AF
                dc.b $A8, 0, 0, $C, $4A, $9D, $D, $A5, $39, $1B, $BF, $ED, $FA, $BF, $FB, $11
                dc.b $D8, $BF, $56, $47, $68, $7F, $5A, $D0, $9F, $EA, $FC, $A9, $FD, $6A, $9D, $2F
                dc.b $28, $24, $DC, $52, $29, $4D, $DE, $46, $4E, $DD, $2A, $8F, $FA, $D2, $A8, $E9
                dc.b $B9, $AA, $39, $AB, $76, 1, $8A, $F2, $BC, $AF, $28, $2B, $65, $6C, $A8, 0
                dc.b $15, $22, $91, $48, $A5, $35, $48, $AF, $21, $79, 0, 0, $A, $25, $4D, $72
                dc.b $9C, $9B, $BD, $C5, $FA, $B9, $BB, $BC, $DD, $FA, $B2, $3B, $3B, $BE, $CE, $2F
                dc.b $D5, $CD, $BB, $D2, $5B, $A4, $52, $74, $E9, $E5, $81, $53, $BC, $CA, $85, $E1
                dc.b $B9, $DE, $14, $DC, $A9, $12, $A4, $40, 0, 0, $71, $DE, $77, $CD, $5B, $97
                dc.b $69, $AE, $13, $5C, $27, 4, $9E, $C8, $5D, $10, $B9, $80, 0, 0, 4, $25
                dc.b $4A, $72, $29, $14, $A6, $B9, $19, $24, $B7, $21, $CD, $A6, 0, 0, $A, $12
                dc.b $A7, $43, $69, $4E, $46, $EF, $EB, $50, $BF, $57, $BA, $9D, $E7, $6A, $7E, $AC
                dc.b $8E, $D0, $A7, $7D, $A1, $42, $FD, $5E, $E7, $7F, $59, $A5, $DF, $27, $4D, $DB
                dc.b $8E, $6E, $9C, $88, $C9, $D3, $91, $93, $78, $19, $24, $A6, $B2, $C0, $2C, $AF
                dc.b $9A, $A6, $A9, $AA, $70, $59, $6C, $BE, $8B, $E6, 0, 0, 0, $10, $A4, $B9
                dc.b $6E, $49, $9D, $24, $ED, $C6, $E2, $95, $25, $35, $48, $D5, $22, 0, $5E, $4A
                dc.b $9A, $E5, $34, $F2, $62, $FD, $59, $37, $7B, $7E, $AC, $8D, $BB, $D8, $BF, $56
                dc.b $49, $E4, $B9, $4E, $F2, $74, $8A, $53, $3F, $2F, 9, $D0, $8E, $7E, $1F, $D6
                dc.b $95, 8, $E5, $34, $90, 0, 0, 1, $AA, $46, $AD, $CB, $F2, $43, $B4, $D2
                dc.b $D0, $9A, $5A, $13, $83, $6E, $D9, $A7, $D1, $A7, $CD, $A, $F9, $5E, $77, $95
                dc.b $E5, $52, $A6, 0, 1, $72, $51, $2C, $A4, $28, $4A, $98, 0, 0, $A2, $54
                dc.b $D7, $29, $C9, $BB, $DC, $5F, $AB, $9B, $BB, $CD, $DF, $AB, $23, $B3, $BB, $EC
                dc.b $E2, $FD, $5C, $DB, $BD, $25, $BA, $45, $26, $FE, $B4, $A7, $20, 0, $3B, $CE
                dc.b $F9, $AB, $72, $ED, $35, $C2, $6B, $84, $E0, $93, $D9, $B, $A2, $17, $30, 0
                dc.b 0, $28, $A4, 8, $4B, $75, $E4, $B9, $9A, $11, $CD, $D2, $28, $C8, 0, $1C
                dc.b $73, $94, $E3, $BB, $C2, $71, $9C, $9D, $B9, $53, $BC, $AA, 0, 0, 2, $8D
                dc.b $52, $39, $2E, $72, $4D, $C6, $92, $23, $B2, $4E, $D0, $49, $15, $A0, $93, $A8
                dc.b $90, $BA, $2C, $AA, $20, $A9, $AE, $53, $49, $1C, $89, $88, $CA, $44, $D5, $1C
                dc.b $A6, $B9, $4D, $53, $BC, $97, $33, 0, $50, $EF, $39, $2E, $53, $92, $4A, $72
                dc.b $26, $99, $EE, $74, $EC, $65, $27, $4E, $16, $9B, $A7, $B, $14, $9D, $22, $AB
                dc.b $73, $BF, $78, $4D, 2, $A8, $92, $6A, $DC, $BF, $24, $DD, $22, $6D, $D2, $9B
                dc.b $B7, $4A, $6E, $DD, $24, $91, $49, $52, $51, $F8, $11, $80, 3, $A4, $A9, $A1
                dc.b $4A, $68, $5B, $41, $B, $62, $5F, $EF, $3F, $AD, $E, $A9, $1E, $EA, $4B, $C8
                dc.b $CA, $5D, $E7, $FE, $63, $23, $EF, $39, $CB, $74, $8C, $83, $8D, $52, $35, $CC
                dc.b $D6, $50, $29, $21, $40, $BC, $3A, $B9, $F7, $D2, $7F, $AA, $29, $52, $45, $D
                dc.b $CE, $A8, $A1, $36, $E8, $52, $62, $D8, $97, $30, 0, 0, 9, $13, $A4, $B9
                dc.b $10, 6, $E2, $39, $50, $EA, $71, $80, 0, 0, $21, $5E, $6D, $53, $8A, $4D
                dc.b $DE, $B9, $4D, $BB, $DA, $A7, $4D, $45, $2B, $CD, $46, $40, 0, $16, $52, $24
                dc.b $9C, $A6, $C5, $54, $CC, $9D, $B4, $F, $75, $A, $A8, $1C, $CC, $A1, $38, $4C
                dc.b $CA, $13, $81, $19, $50, $AA, $86, 4, $ED, $A0, $64, $C5, $54, $D6, $52, $20
                dc.b 0, $12, $BE, $6A, $EF, $68, $16, 9, 9, $AE, $72, $5C, $E4, $B8, $16, 9
                dc.b $F, $26, $9A, $A4, 0, 0, 0, 0, $14, $3B, $C8, $E5, $43, $A8, $A5, $BA
                dc.b $46, $47, $DE, $7F, $E6, $32, $97, $79, $95, $25, $E4, $65, $D5, $23, $DD, $57
                dc.b $F5, $A0, $BE, $88, $5B, $12, $16, $D0, $42, $94, $D5, $3B, $E4, 0, 0, 0
                dc.b $2F, $92, $8A, $4B, $DC, $85, $22, $34, $99, $D9, $3C, $A, $C9, $BA, $A4, $29
                dc.b $6C, $B9, $D4, $29, $22, $93, $49, $A, $92, $25, $C8, $C9, $67, $35, $14, $AF
                dc.b $20, $A9, $80, 0, $27, $1A, $1C, $88, $D0, $BC, 9, $37, $1C, $9A, $C4, $76
                dc.b $26, $81, $5A, $13, $74, $A, $D0, $29, $38, $A4, $55, $4D, $DF, $CC, $93, $8A
                dc.b 5, $51, $34, $D5, $B9, $72, $DC, $92, $23, $24, $99, $92, $11, $CD, $37, $2C
                dc.b $A4, $A2, $3F, 2, $56, 9, $86, $98, $50, $F4, $E1, $A6, $11, $FD, $CC, $7A
                dc.b $A3, $C2, $38, $53, $FA, $A9, $A2, $B4, $5F, $ED, $58, $FF, $68, $6E, $38, $F0
                dc.b $89, $B8, $FF, $68, $6D, $FB, $50, 2, $1E, $86, $91, $E1, $15, $E8, 0, 1
                dc.b $7C, $15, $FB, $94, $E7, $FB, $94, $E7, $C1, $5C, $C0, 0, $E, $A, $FD, $CA
                dc.b $73, $FD, $CA, $73, $FD, $CA, $73, $E0, 0, 0, $E, 1, $39, $DF, $B, $E0
                dc.b $BE, $1D, $AB, $B5, $20, $9F, $A8, $5F, $23, $E4, $BF, $D4, $53, $F7, $29, $CF
                dc.b $F7, $2E, $85, $39, $FE, $E7, $B7, $85, $39, $F0, $85, $2C, $DC, $E9, $FA, $85
                dc.b $F2, $3E, $4B, $FD, $40, 1, $38, $2B, $F7, $29, $CF, $F7, $29, $CF, $82, $B9
                dc.b $80, $DC, $15, $FC, $96, $E7, $FC, $96, $FD, $57, 5, $73, 0, 1, $6B, $FF
                dc.b $72, $90, $FE, $CB, $BF, $55, $FB, $90, 0, 0, $58, $37, $EA, $AD, $7C, $2F
                dc.b $82, $F8, $76, $AE, $D4, $82, $7E, $A1, $7C, $8F, $92, $FF, $51, $4F, $DC, $A7
                dc.b $3F, $E4, $D2, $14, $FD, $57, $EA, $7B, $78, $3B, $F7, $54, $B2, $BF, $50, $BE
                dc.b $47, $C9, $7F, $A8, 1, $38, $2B, $F9, $2D, $FA, $AF, $DC, $A7, $3E, $A, $E6
                dc.b 0, 0, $A, $7F, $E7, $FF, $3F, $FA, 0, 0, 0, 0, 1, $FF, $9F, $FC
                dc.b $FF, $EA, $F8, $5F, 5, $F0, $ED, $5D, $A9, 4, $FD, $42, $F9, $1F, $25, $FE
                dc.b $A0, 0, 0, $A7, $FE, $7F, $F3, $FF, $AB, $5F, $B, $FB, $78, $2E, $14, $B2
                dc.b $BF, $50, $BE, $47, $C9, $7F, $A8, 0, 0, $13, $FF, $3F, $F9, $FF, $D0, 0
                dc.b 0, $3F, $EB, $17, $D1, $F4, $7D, $1F, $17, $C5, $F1, $7C, $5F, $17, $D1, $F4
                dc.b $7D, $1F, $17, $C5, $F1, $7C, $5F, $17, $D1, $F4, $7D, $1F, $17, $C5, $F1, $7C
                dc.b $5F, $17, $D1, $F4, $7D, $1F, $FF, $58, $DF, $1B, $E3, $7C, $6F, $8D, $F1, $17
                dc.b $C5, $F1, $7C, $5F, $DC, $FA, $3E, $8F, $8B, $B4, $7E, $89, $DC, 0, $D, $FF
                dc.b $58, $BE, $8F, $A3, $E8, $FE, $E7, $C5, $F1, $7D, $22, $FA, $3E, $8F, $6D, $1F
                dc.b $17, $C5, $A2, $FA, $3D, $7A, $3E, $2B, $D1, $F7, $C4, 0, 0, $1F, $F5, $A3
                dc.b $E2, $B8, $BE, $2B, $7D, $1F, $14, $7C, $5F, $A3, $3E, $8F, $A3, $E2, $E7, $C5
                dc.b $F1, $7C, $59, $F4, $D1, $BF, $68, 0, 0, 0, 0, $4D, $15, $DC, $BE, $E5
                dc.b $FE, $D0, 0, $BE, $E4, $FE, $23, $47, $1D, $31, $8B, $BF, $88, $DF, $C4, 0
                dc.b $27, $72, $44, $B4, $26, $FE, $B3, $A2, $5A, $13, $7F, $10, 0, $9F, $A8, $4E
                dc.b $4F, $FC, $C3, $DB, $FA, $4E, $E4, $FF, $CC, $3D, $BF, $90, 0, $4E, $E4, $8B
                dc.b $F4, $7B, $7F, $49, $D1, $7E, $8F, $6F, $E2, 0, $13, $B9, $23, $DB, $A7, $6B
                dc.b $7F, $5D, $D1, $ED, $D3, $B5, $BF, $88, $C0, 0
ScoresTiles:    dc.b $80, $53, $80, 3, 0, $14, 4, $25, $E, $35, $13, $45, $19, $55, $16, $66
                dc.b $34, $74, 5, $81, 5, $F, $16, $38, $82, 5, $17, $17, $73, $83, 5, $12
                dc.b $17, $74, $84, 5, $14, $85, 7, $75, $86, 5, $18, $87, 5, $15, $16, $37
                dc.b $26, $35, $38, $F3, $88, $27, $72, $38, $F4, $89, 8, $F0, $8A, 8, $F7, $8B
                dc.b 4, 6, $17, $76, $8D, 7, $77, $8E, 4, 8, $8F, 3, 1, $16, $36, $38
                dc.b $F5, $58, $F2, $78, $F1, $FF, $4F, $EF, 8, $1F, $CF, $42, $9B, $E6, $BA, $55
                dc.b $72, $6D, 3, $6F, $CC, $1F, $CF, $5B, $C7, $51, $AA, $55, $D5, $55, $75, $5D
                dc.b $54, $E4, $79, $11, $FE, $E1, $16, $2A, $AB, $A1, $58, $B7, $FF, $A0, $79, 2
                dc.b $3C, $E7, $BD, $B7, $D3, $54, $29, $A8, $80, $7D, $C, $69, $E3, $A8, $D5, $2A
                dc.b $EA, $AA, $BA, $AE, $AA, $72, $3C, $88, $FF, $70, $8B, $15, $55, $D0, $AC, $5B
                dc.b $FF, $D0, $3C, $81, $1E, $73, $DE, $DB, $DB, $79, $91, $BB, $A0, $1F, $43, $1A
                dc.b $78, $EA, $35, $4A, $BA, $AA, $AE, $AB, $AA, $9C, $8F, $22, $3F, $DC, $22, $C5
                dc.b $55, $74, $2B, $16, $FF, $F4, $F, $20, $5D, $BE, $6B, $6D, $F4, $AC, $C8, $DD
                dc.b $D0, $3F, $5F, $F9, $83, $1A, $78, $EA, $35, $4A, $BA, $AA, $AE, $AB, $AA, $9C
                dc.b $8F, $22, $3F, $DC, $22, $C5, $55, $74, $2B, $16, $FF, $F4, $F, $20, $47, $9E
                dc.b $75, $CE, $B3, $DE, $64, $6E, $E8, 7, $D0, $C6, $9E, $3A, $8D, $52, $AE, $AA
                dc.b $AB, $AA, $EA, $A7, $23, $C8, $8F, $F7, 8, $B1, $55, $5D, $A, $C5, $BF, $FD
                dc.b 3, $C8, $11, $E7, $9D, $ED, $BD, $B7, $71, $4D, $D2, 1, $F4, $31, $A7, $8E
                dc.b $A3, $54, $AB, $AA, $AA, $EA, $BA, $A9, $C8, $F2, $23, $FD, $C2, $2C, $55, $57
                dc.b $42, $B1, $68, $1F, $DE, $10, $3F, $9E, $85, $37, $CD, $74, $AA, $E4, $DA, 6
                dc.b $DF, $98, $3F, $9E, $B7, $8E, $A3, $54, $AB, $AA, $AA, $EA, $BA, $A9, $C8, $F2
                dc.b $39, $FD, $77, $A8, $84, $D4, $19, $D5, $57, $4A, $A1, $77, $22, $21, $22, $7F
                dc.b $BE, $1E, $40, $8F, $39, $EF, $6D, $F4, $D5, $A, $6A, $20, $1F, $43, $1A, $78
                dc.b $EA, $35, $4A, $BA, $AA, $AE, $AB, $AA, $9C, $8F, $23, $9F, $D7, $7A, $88, $4D
                dc.b $41, $9D, $55, $74, $AA, $17, $72, $22, $12, $27, $FB, $E1, $E4, 8, $F3, $9E
                dc.b $F6, $DE, $DB, $CC, $8D, $DD, 0, $FA, $18, $D3, $C7, $51, $AA, $55, $D5, $55
                dc.b $75, $5D, $54, $E4, $79, $1C, $FE, $BB, $D4, $42, $6A, $C, $EA, $AB, $A5, $50
                dc.b $BB, $91, $10, $91, $3F, $DF, $F, $20, $47, $9E, $75, $CE, $B3, $DE, $64, $6E
                dc.b $E8, 7, $D0, $C6, $9E, $3A, $8D, $52, $AE, $AA, $AB, $AA, $EA, $A7, $23, $C8
                dc.b $E7, $F5, $DE, $A2, $13, $50, $67, $55, $5D, $2A, $85, $DC, $88, $84, $FE, $72
                dc.b $AA, $AD, $8B, $6C, $E2, $FE, $BC, $10, $5F, $2E, $BA, $75, $F, 5, $F5, $90
                dc.b $AB, $DD, $2A, $89, $56, $74, $90, $A8, $2F, $A2, $51, $E9, $77, $F4, $78, $EA
                dc.b $2A, $7F, $3C, $6E, $9E, $F3, $C6, $8D, $EF, $A1, $B1, $7E, $48, $78, $84, $3F
                dc.b $A2, $11, $B0, $BC, $FF, $5E, $2F, $8B, $51, $3F, $9F, $D8, $FE, $8B, 5, $2E
                dc.b $94, $93, $D2, $FD, $2A, $85, $38, $14, $79, $F, $47, $C1, $48, $22, $93, $60
                dc.b $68, $CE, $64, $2C, $8D, $96, $14, $9F, $62, $F9, $B1, $F, $99, $E6, $F1, 0
                dc.b $BE, $4E, $82, $38, $C7, $54, $F5, $EC, $18, $34, $CE, $3B, $E3, $C0, $A5, $D2
                dc.b $92, $79, $17, $E9, $5C, $F0, $28, $F2, $EB, $F0, $50, $A5, $E, $71, $63, $D9
                dc.b $CD, $96, $14, $9F, $62, $F9, $B1, $B1, $7D, $DE, $20, $17, $5C, $41, $47, $DF
                dc.b 9, $B0, $FC, $A2, $30, $63, $FA, $B3, $8E, $F8, $F7, $29, $74, $A0, $79, $1F
                dc.b $A3, $AC, $9D, $C0, $7D, $5E, $52, $FD, $44, $14, $23, 7, $3F, $9D, $54, $3D
                dc.b $AD, $47, $7E, $BC, $5F, 2, $36, $7D, $DD, 9, $12, $E7, $98, $E2, $D0, $B0
                dc.b $C8, $59, $CC, $D, $19, $D0, $45, $26, $F4, $7C, $4F, $81, $48, $4B, $F4, $A8
                dc.b $84, $92, $52, $4E, $8F, $D1, $78, $4F, $F5, $F6, $F5, $EC, $20, $8E, $31, $D4
                dc.b $40, $22, $56, $89, $5D, $F3, $68, $E2, $7D, $A2, $CC, $3A, $83, $D9, $CC, $98
                dc.b $C9, $4A, $1C, $DF, $82, $EE, 5, $1E, $97, $E9, $51, 9, $24, $A4, $9D, $18
                dc.b $EF, $8F, 9, $B0, $63, $FA, $B4, $D8, $7E, $51, $20, $A3, $EF, $81, 0, $BD
                dc.b $2F, $38, $17, $7C, $DA, $1F, $9E, $D1, $66, $1D, $74, $61, $F9, $DC, $91, $83
                dc.b $9B, $F5, $10, $EE, 3, $EB, 9, $FA, $3A, $CA, $12, $49, $49, $C6, $3B, $E3
                dc.b $DE, $6C, $19, $74, $8C, $F8, $7B, $D2, $11, $8D, $25, $40, $5A, $89, $40, $F1
                dc.b $43, $62, $C, $83, $C3, $C3, $24, $85, $E4, $C9, $13, $A3, $A1, $E2, $E2, $8E
                dc.b $89, $D, $A7, $B, $A4, $1B, $42, $AD, $A0, $CF, $C3, $DE, $8F, $28, $D4, $95
                dc.b $13, $F5, $62, $81, $F7, $C0, $69, $F3, $A3, $48, $3D, $36, $61, $21, $C3, 6
                dc.b $84, $E8, $E6, $87, $89, $51, $3B, $44, $B2, $C2, $1F, $A1, $D2, $D, $A1, $55
                dc.b $55, $CC, $36, $9B, $1E, $65, $C7, $1B, $DC, $86, $15, $E9, $44, $64, $DF, 1
                dc.b $92, $41, $EE, $23, $A7, $39, $BC, $74, $C, $1F, $CF, $84, $7C, $83, $D0, $87
                dc.b $DF, $1D, $41, $4D, $92, $99, $FD, $5A, $A3, $68, $D6, $6D, $18, $AD, $98, $D9
                dc.b $97, $4D, $B2, $6F, $89, $9B, $D5, $72, $6F, $2A, $CD, $8E, $1F, $36, 6, $87
                dc.b $B4, $D8, $7E, $53, $6C, $DD, $E0, $A3, $F2, $58, $3C, $48, $3E, $89, $D3, $9C
                dc.b $91, $F7, $78, $90, $A3, $6C, $8F, $93, $9B, $60, $F2, $8C, $1B, $66, $9B, $23
                dc.b $2A, $AA, $AC, $FF, $57, $9A, $26, $C8, $47, $5C, $5D, $E0, $A3, $C4, $9E, $9C
                dc.b $73, $78, $61, $D0, $3E, $7C, $FA, 2, $E7, $89, $23, $6D, $FA, $E2, $8D, $62
                dc.b $CB, $62, $DA, $35, $9B, $46, $55, $55, $55, $56, $46, $9B, $6C, $C1, $90, $BC
                dc.b $6C, $CE, $93, $D3, $66, $A0, $90, $7D, $DE, $92, $E7, $D1, $28, $F1, $20, $F0
                dc.b $C7, $2F, $42, $1F, $7C, $ED, $FA, $47, $14, $69, $91, $43, $47, $6C, $1F, $77
                dc.b $14, $7C, $A6, $69, $C2, $E5, $BA, $9B, $33, $99, $19, $20, $D3, $66, $49, $3D
                dc.b $C5, $2E, $F1, $C2, $32, $3C, $4A, $E5, $94, $BB, $A0, $62, $1F, $A8, $67, $91
                dc.b $D0, $11, $D4, $1F, $CA, $F8, $23, $26, $CA, $AA, $AA, $AA, $AA, $41, $99, $42
                dc.b $9D, $90, $B0, $6F, $CA, $87, $86, $D, $FA, $19, 6, $2E, $78, $7B, 2, $E9
                dc.b $3D, $3F, $42, $1E, $1B, $E, $7A, $32, $74, $57, $82, $D8, $7F, $3D, $83, $1A
                dc.b $6C, $D3, $64, $60, $D1, $66, $8D, $D, $8F, $55, $B1, $96, $9E, $A, $E6, $46
                dc.b $9B, $6D, $42, $C3, $6E, $6F, $C3, $10, $F5, $E8, $8C, $8F, $76, $18, $3C, $7E
                dc.b $85, $1F, $27, $14, $8E, $FF, $AF, 5, $7C, $34, $91, $5B, $75, $36, $3A, $43
                dc.b $5A, $19, $46, $D9, $3C, $17, $1C, $74, $C1, $C, $F9, $24, $9E, $C1, $F4, $4A
                dc.b $3F, $C, $9D, $12, $4E, $97, $54, $81, $41, $2C, $65, $E8, $F2, $8C, $98, $D3
                dc.b $19, $2F, $C5, $8D, $D, $8B, $68, $CA, $AA, $AA, $B3, $2D, $B3, $88, $C5, $C1
                dc.b $73, $F1, $27, $CD, $F4, $E1, 8, $7D, $38, 4, $3C, $62, $41, $EE, $96, 4
                dc.b $A7, $2C, 9, $21, $78, $C4, $83, $CB, $51, $F4, $E2, $9F, $AB, $F5, $EC, $A3
                dc.b $F8, $C9, $8C, $E0, $63, $F8, $98, $4B, $BA, $F3, $B8, $BD, $AE, $AA, $EB, $E7
                dc.b $9C, $F9, $AF, $E9, $92, $E3, $1A, $61, $E6, $C6, $2C, $41, $CC, $84, $66, $91
                dc.b $29, $EF, $13, $A4, $92, $49, $49, $52, $27, $24, $EF, $39, $24, $A7, $49, $37
                dc.b $E3, $38, $99, $B5, $24, $7F, $3B, $99, $7E, $32, $EB, $3A, $DB, $9F, $E5, $59
                dc.b $2E, $B9, $BA, $F3, $5E, $6E, $C2, $E1, $D7, $9E, $17, $1A, $7E, $59, $C5, $3F
                dc.b $2D, $A6, $1D, $DE, $E7, $4E, $F7, $C3, $A5, $DF, $A5, $27, $E1, $5B, $56, $CF
                dc.b $FC, $65, $25, $47, $77, $32, $C9, $E9, $49, $C9, $54, $53, $3F, $95, $FD, $12
                dc.b $DD, $54, $5F, $3C, $E7, $CD, $7F, $4C, $97, $18, $D3, $F, $BD, $8E, $87, $4E
                dc.b $87, $34, $8E, $F3, $FC, $A4, $4B, $32, $CD, $25, $19, $90, $F0, $5C, $D6, $54
                dc.b $FC, $63, $E7, $49, $1E, $F6, $91, $D2, $4B, $9A, $E7, $F4, $5F, $95, $4B, $AE
                dc.b $6E, $BC, $D7, $9B, $B0, $B8, $75, $D6, $78, $D3, $F2, $D6, $FD, $33, $8A, $7E
                dc.b $59, $D1, $7D, $25, $CF, $31, $49, $56, $7D, $F4, $92, $49, $DC, $37, $E3, $29
                dc.b $63, $3F, $CE, $9C, $FE, $32, $F2, $55, $A4, $FA, $B7, $5E, $6B, $74, 0, 0
FlickyLogoTiles:dc.b $80, $39, $80, 3, 3, $14, $A, $25, $17, $35, $16, $45, $19, $55, $1A, $65
                dc.b $1B, $73, 0, $81, 3, 2, $17, $79, $27, $7B, $82, 4, 8, $83, 5, $18
                dc.b $17, $78, $84, 3, 1, $16, $3A, $27, $7A, $85, 6, $3B, $86, 4, 9, $87
                dc.b 5, $1C, $FF, $BF, $F1, $28, $E8, $B5, $CF, $D3, $16, $A5, $56, $1A, $95, $7C
                dc.b 1, $9C, 7, $3B, $80, 0, 3, $67, $3E, $37, $E3, $78, $19, $C3, $20, 0
                dc.b 5, $F1, $95, $30, $F1, $30, $5A, $9E, $4D, $FA, $F2, $FF, $89, $7E, $87, $FD
                dc.b $BF, $E7, $FE, $31, $81, $FF, $61, $7F, $E2, $3E, $80, $1A, $23, $FA, $91, $A8
                dc.b $3F, $D6, $8F, $F1, $CF, $F8, $FF, $ED, $1B, $87, $FE, $40, 0, 0, $11, $BF
                dc.b $40, $DA, $62, $8D, $8C, $67, $1B, $C6, $FA, $8C, $FE, $4A, $8E, $8D, $BD, 0
                dc.b 0, $C9, 7, $50, 6, $E0, $1D, $10, 0, 0, 0, $2B, $D5, $FA, $BF, $AB
                dc.b $FE, $5A, $29, $72, $7C, $18, $B6, 0, 0, 0, 0, 0, $F, 7, $78, $6A
                dc.b $55, $78, $2D, $4A, $B1, $6B, $9F, $A6, $AE, $87, $ED, 1, 0, 0, 0, 0
                dc.b 0, 8, $FE, $A5, $7E, $89, $C3, $EE, $7D, $49, $8F, $F1, $97, $FC, $36, $7F
                dc.b $8C, $79, $19, $FC, $93, $FF, $A0, 0, 0, 0, 0, 0, 0, $20, $EA, $37
                dc.b 0, $E8, $87, $FC, $4A, $37, $87, $D3, $5C, $93, $14, $A5, $61, $98, $B7, $80
                dc.b 0, 0, 0, 6, $F0, 0, $17, $52, $A8, $C1, $6B, $92, $62, $8D, $E1, $9A
                dc.b $FE, $20, $64, 0, 0, 0, 0, 0, 0, 1, $B2, 6, $8E, $7A, $56, $2D
                dc.b $4D, $CA, $FC, $BA, $A2, $A5, $5C, $B9, $59, $56, $45, $CA, $BF, $6D, $58, $C0
                dc.b 0, 0, $D0, $B1, $82, $E5, $5F, $BA, $56, $4C, $B9, $59, $2A, $56, $4A, $FC
                dc.b $BA, $B1, $6A, $73, $D2, $FE, $A3, $2B, $F4, $F0, $FA, $E7, $B3, $C8, $CE, $23
                dc.b $B8, $B7, $88, $ED, $A9, $E5, $62, $27, $8D, $73, $6B, $8A, $BF, $68, $A7, $AB
                dc.b $1F, $3A, $E8, 1, $A3, $D9, $B1, $BF, $ED, $17, $D, $BF, $2E, $9C, $F1, $F1
                dc.b $59, $4A, $AC, $45, $BC, $47, $76, $C4, $77, $1E, $7F, $2E, $79, $F, $F2, $FE
                dc.b $62, $BF, $E8, $19, 7, $50, $CE, $7B, $8D, $2D, $A8, $D7, 3, $39, $E8, 1
                dc.b $AE, $B4, $99, $CC, $ED, $46, $96, $FB, $8D, $43, $3A, $3A, $20, $5F, $F6, $95
                dc.b $D7, $9B, $96, $A4, $F7, $75, $2F, $E, $6C, $80, 0, 7, $80, 0, $1B, $C0
                dc.b 0, $5D, $4A, $C3, $96, $5A, $93, $DD, $CB, $F3, $9F, $EA, $68, $B3, $62, $A2
                dc.b $C5, $4D, $8A, $95, $72, $A5, $5C, $A9, $56, $52, $AB, $D, $4A, $AF, $E, $55
                dc.b $F1, $D2, $B1, $8C, $98, $1A, $30, $CA, $B1, $87, $2A, $F8, $2D, $4A, $AF, $14
                dc.b $A5, $56, $28, $A9, $59, $2A, $56, $4A, $95, $16, $2A, $59, $B1, $47, $45, $F5
                dc.b $93, $5D, $5F, $CC, $67, $F4, $F0, $C8, $BF, $8A, $35, $E0, $C5, $B0, $61, $9B
                dc.b $98, $66, $D0, $CE, $8E, $88, $D9, 7, $50, $CE, $4C, $33, $6C, $18, $66, $FE
                dc.b $C, $67, $C5, $11, $49, $E3, $33, $C3, $C, $D7, $6A, $19, $B7, $A0, $1F, $AB
                dc.b $17, $E6, $E5, $A9, $36, $53, 3, $78, 3, 2, $CA, $55, $88, $6A, $55, $88
                dc.b $6A, $72, $5A, $D1, 4, 0, 6, $7D, $5F, $AF, $74, $5A, $FD, $35, $D4, $FB
                dc.b $17, $53, $CF, $34, $5A, $7F, $96, $BF, $5E, $F3, $EB, $7E, $81, $B9, $73, $46
                dc.b $E9, $CC, 0, 3, $39, $8D, $CC, $33, $98, $DC, $B8, $D4, $94, $D6, $7F, $2F
                dc.b $2B, $4A, $56, $94, $F1, $5C, $BF, $33, $E6, $BA, $6A, $40, $55, $D3, $53, $47
                dc.b $DC, $AA, $5F, $96, $E2, $AC, $73, $CD, $F1, $BC, $45, $BD, $F7, $FB, $17, $F9
                dc.b $58, $FD, $37, $E5, $7F, $24, $7D, $FE, $4B, $A6, $76, $6D, $D5, $7B, $B2, $9E
                dc.b $1E, $43, $32, $AA, $3B, $81, $6C, 0, 0, $18, $17, $40, 1, $58, $43, $B8
                dc.b $22, $B1, $19, $C5, $77, 6, $F1, $9C, $57, $70, $6F, $1A, $87, $DC, $1B, $77
                dc.b 6, $DD, $C1, $CC, $1D, $11, $B0, 0
byte_1A196:     dc.b $22, 0
byte_1A198:     dc.b $22, 1
byte_1A19A:     dc.b $22, 2
byte_1A19C:     dc.b $22, 3
byte_1A19E:     dc.b $22, 4
byte_1A1A0:     dc.b 0, 0
word_1A1A2:     dc.w $222B, $222C, $222D, $222E, $222F, $2230, $2231, $2232
word_1A1B2:     dc.w $2233, $2234, $2235, $2236, $2237, $2238, $2239, $223A
word_1A1C2:     dc.w $223B, $223C, $223D, $223E, $223F, $2240, $2241, $2242
word_1A1D2:     dc.w $2243, $2244, $2245, $2246, $2247, $2248, $2249, $224A
word_1A1E2:     dc.w $224B, $224C, $224D, $224E, $224F, $2250, $2251, $2252
word_1A1F2:     dc.w $2253, $2205, $2205, $2205, $2254, $2255, $2256, $2257
word_1A202:     dc.w $2258, $2258, $2258, $2258, $2258, $2258, $2258, $2258
word_1A212:     dc.w $2259, $225A, $225B, $225C, $225D, $225E, $225F, $2260
word_1A222:     dc.w $2261, $2262, $2263, $2264, $2265, $2240, $2241, $2266
word_1A232:     dc.w $2267, $2268, $2269, $226A, $226B, $226C, $226D, $226E
word_1A242:     dc.w $226F, $2270, $2271, $2272, $2273, $2274, $2275, $2276
word_1A252:     dc.w $2277, $2277, $2277, $2277, $2278, $2279, $227A, $227B
word_1A262:     dc.w $29E, $29F, $2A0
word_1A268:     dc.w $2A1, $2A2, $2A3
word_1A26E:     dc.w $2A4, $2A5, $2A6
word_1A274:     dc.w $62A7, $62A8, $62A9, $62AA, $62AB, $62AC, $62AD, $62AE, $62AF
word_1A286:     dc.w $62B0, $62B1, $62B2, $62B3, $62B4, $62B5
word_1A292:     dc.w $629A, $629B, $629C, $629D
word_1A29A:     dc.w $627C, $627D, $627E, $627F, $6280, $6281
word_1A2A6:     dc.w $6282, $6283, $6284, $6285, $6286, $6287
word_1A2B2:     dc.w $6288, $6289, $628A, $628B, $628C, $628D
word_1A2BE:     dc.w $628E, $628F, $6290, $6291, $6292, $6293
word_1A2CA:     dc.w $6294, $6295, $6296, $6297, $6298, $6299
word_1A2D6:     dc.w $2200, $2215, $2216, $2217, $2218, $2217, $2216, $2217
word_1A2E6:     dc.w $2201, $2219, $221A, $221B, $221C, $221B, $221A, $221B
word_1A2F6:     dc.w $2202, $221D, $221E, $221F, $2220, $221F, $221E, $221F
word_1A306:     dc.w $2203, $2221, $2222, $2223, $2224, $2223, $2222, $2223
word_1A316:     dc.w $2204, $2225, $2226, $2227, $2228, $2227, $2226, $2227
word_1A326:     dc.w $2205, $2229, $2205, $2205, $222A, $2205, $2205, $2205
word_1A336:     dc.w $2B6, $2B7, $2B8, $2B9, $2BA, $2BB, $2BC, $2BD
                dc.w $2BE, $2BF, $2C0, $2C1, $2C2, $2C3, $2C4
word_1A354:     dc.w $2C5, $2C6, $2C7, $205, $2C8, $2C9, $2CA, $2CB
                dc.w $2CC, $2CD, $2CE, $2CF, $2D0, $2D1, $2D2, $2D3
word_1A374:     dc.w $205, $205, $2D4, $2D5, $2D6, $2D7, $2D8, $2D9
                dc.w $2DA, $2DB, $2DC, $2DD, $2DE, $205, $205
word_1A392:     dc.w $2DF, $2E0, $2E1, $205, $2E2, $2E3, $2E4, $205
                dc.w $2E5, $2E6, $2E7, $205, $205, $205, $205, $205
word_1A3B2:     dc.w $2E8, $2E9, $2EA, $205, $2EB, $2EC, $2ED, $205
                dc.w $2EE, $2EF, $2F0, $205, $205, $205, $205, $205
word_1A3D2:     dc.w $2F1, $2F2, $2F3, $2F4, $2F5, $2F6, $2F7, $2F8
                dc.w $2F9, $2FA, $205, $205, $205, $205, $205
word_1A3F0:     dc.w $2FB, $2FC, $2FD, $2FE, $2FF, $300, $301, $302
                dc.w $303, $304, $305, $306, $307, $308, $309, $30A
word_1A410:     dc.w $30B, $30C, $30D, $30E, $30F, $310, $311, $312
                dc.w $313, $314, $315, $316, $317, $318, $319
word_1A42E:     dc.w $31A, $31B, $31C, $31D, $31E, $31F, $320, $321
                dc.w $322, $323, $324, $325, $326, $327, $328, $329
word_1A44E:     dc.w $32A, $32A, $32A, 0, 0, 0, $32A, $32A
                dc.w $32A, $32A, $32A, $32A, $32A, $32A, 0
word_1A46C:     dc.w $632B, $632C, $632D, $632E, $632F, $6330, $6331, $6332, $6333
word_1A47E:     dc.w $6334, $6335, $6336, $6337, $6335, $6338, $6339, $6335, $633A
word_1A490:     dc.w $633B, $6205, $633C, $633D, $6205, $633E, $633F, $6205, $6340
word_1A4A2:     dc.w $6341, $6205, $6342, $6343, $6205, $6344, $6345, $6205, $6346
word_1A4B4:     dc.w $347, $348, $349, $34A, $34B, $34C, $34D, $34E, $34F, $351, $4350
word_1A4CA:     dc.w $8352, $8353, $8354, $8353
word_1A4D2:     dc.w $8355, $8356, $8353, 0, 0, $2A, $F8, 0, 0, $300, $F8
word_1A4E8:     dc.w 4, $F804, $6456, $F8F8
word_1A4F0:     dc.w 4, $F804, $7456, $F8F8
word_1A4F8:     dc.w 4, $F401, $6458, $FCFC
word_1A500:     dc.w 4, $F401, $6C58, $FCFC
word_1A508:     dc.w 4, $F401, $7458, $FCFC
word_1A510:     dc.w 4, $F401, $7C58, $FCFC
word_1A518:     dc.w 4, $F804, $645A, $F8F8
word_1A520:     dc.w 4, $F804, $745A, $F8F8
word_1A528:     dc.w 4, $F401, $645C, $FCFC
word_1A530:     dc.w 4, $F401, $6C5C, $FCFC
word_1A538:     dc.w 4, $F401, $745C, $FCFC
word_1A540:     dc.w 4, $F401, $7C5C, $FCFC
word_1A548:     dc.w 4, $F804, $645E, $F8F8
word_1A550:     dc.w 4, $F804, $745E, $F8F8
word_1A558:     dc.w 4, $F401, $6460, $FCFC
word_1A560:     dc.w 4, $F401, $6C60, $FCFC
word_1A568:     dc.w 4, $F401, $7460, $FCFC
word_1A570:     dc.w 4, $F401, $7C60, $FCFC
word_1A578:     dc.w 4, $F804, $6462, $F8F8
word_1A580:     dc.w 4, $F804, $7462, $F8F8
word_1A588:     dc.w 4, $F401, $6464, $FCFC
word_1A590:     dc.w 4, $F401, $6C64, $FCFC
word_1A598:     dc.w 4, $F401, $7464, $FCFC
word_1A5A0:     dc.w 4, $F401, $7C64, $FCFC
word_1A5A8:     dc.w 4, $F804, $6466, $F8F8
word_1A5B0:     dc.w 4, $F804, $7466, $F8F8
word_1A5B8:     dc.w 4, $F401, $6468, $FCFC
word_1A5C0:     dc.w 4, $F401, $6C68, $FCFC
word_1A5C8:     dc.w 4, $F401, $7468, $FCFC
word_1A5D0:     dc.w 4, $F401, $7C68, $FCFC
word_1A5D8:     dc.w 4, $F804, $646A, $F8F8
word_1A5E0:     dc.w 4, $F804, $746A, $F8F8
word_1A5E8:     dc.w 4, $F401, $646C, $FCFC
word_1A5F0:     dc.w 4, $F401, $6C6C, $FCFC
word_1A5F8:     dc.w 4, $F401, $746C, $FCFC
word_1A600:     dc.w 4, $F401, $7C6C, $FCFC
word_1A608:     dc.w 4, $F804, $646E, $F8F8
word_1A610:     dc.w 4, $F804, $746E, $F8F8
word_1A618:     dc.w 4, $F401, $6470, $FCFC
word_1A620:     dc.w 4, $F401, $6C70, $FCFC
word_1A628:     dc.w 4, $F401, $7470, $FCFC
word_1A630:     dc.w 4, $F401, $7C70, $FCFC
word_1A638:     dc.w 4, $F804, $6472, $F8F8
word_1A640:     dc.w 4, $F804, $7472, $F8F8
word_1A648:     dc.w 4, $F401, $6474, $FCFC
word_1A650:     dc.w 4, $F401, $6C74, $FCFC
word_1A658:     dc.w 4, $F401, $7474, $FCFC
word_1A660:     dc.w 4, $F401, $7C74, $FCFC
word_1A668:     dc.w 4, $F804, $6476, $F8F8
word_1A670:     dc.w 4, $F804, $7476, $F8F8
word_1A678:     dc.w 4, $F401, $6478, $FCFC
word_1A680:     dc.w 4, $F401, $6C78, $FCFC
word_1A688:     dc.w 4, $F401, $7478, $FCFC
word_1A690:     dc.w 4, $F401, $7C78, $FCFC
word_1A698:     dc.w 4, $F804, $647A, $F8F8
word_1A6A0:     dc.w 4, $F804, $747A, $F8F8
word_1A6A8:     dc.w 4, $F401, $647C, $FCFC
word_1A6B0:     dc.w 4, $F401, $6C7C, $FCFC
word_1A6B8:     dc.w 4, $F401, $747C, $FCFC
word_1A6C0:     dc.w 4, $F401, $7C7C, $FCFC
word_1A6C8:     dc.w 4, $F804, $647E, $F8F8
word_1A6D0:     dc.w 4, $F804, $747E, $F8F8
word_1A6D8:     dc.w 4, $F401, $6480, $FCFC
word_1A6E0:     dc.w 4, $F401, $6C80, $FCFC
word_1A6E8:     dc.w 4, $F401, $7480, $FCFC
word_1A6F0:     dc.w 4, $F401, $7C80, $FCFC
word_1A6F8:     dc.w 4, $F804, $6482, $F8F8
word_1A700:     dc.w 4, $F804, $7482, $F8F8
word_1A708:     dc.w 4, $F401, $6484, $FCFC
word_1A710:     dc.w 4, $F401, $6C84, $FCFC
word_1A718:     dc.w 4, $F401, $7484, $FCFC
word_1A720:     dc.w 4, $F401, $7C84, $FCFC
word_1A728:     dc.w 4, $F804, $6486, $F8F8
word_1A730:     dc.w 4, $F804, $7486, $F8F8
word_1A738:     dc.w 4, $F401, $6488, $FCFC
word_1A740:     dc.w 4, $F401, $6C88, $FCFC
word_1A748:     dc.w 4, $F401, $7488, $FCFC
word_1A750:     dc.w 4, $F401, $7C88, $FCFC
word_1A758:     dc.w 4, $F804, $648A, $F8F8
word_1A760:     dc.w 4, $F804, $748A, $F8F8
word_1A768:     dc.w 4, $F401, $648C, $FCFC
word_1A770:     dc.w 4, $F401, $6C8C, $FCFC
word_1A778:     dc.w 4, $F401, $748C, $FCFC
word_1A780:     dc.w 4, $F401, $7C8C, $FCFC
word_1A788:     dc.w 4, $F804, $648E, $F8F8
word_1A790:     dc.w 4, $F804, $748E, $F8F8
word_1A798:     dc.w 4, $F401, $6490, $FCFC
word_1A7A0:     dc.w 4, $F401, $6C90, $FCFC
word_1A7A8:     dc.w 4, $F401, $7490, $FCFC
word_1A7B0:     dc.w 4, $F401, $7C90, $FCFC
word_1A7B8:     dc.w 3, $F005, $4436, $F8F8
word_1A7C0:     dc.w 3, $F005, $443A, $F8F8
word_1A7C8:     dc.w 3, $F005, $4C36, $F8F8
word_1A7D0:     dc.w 3, $F005, $4C3A, $F8F8
word_1A7D8:     dc.w 6, $F005, $443E, $F8F8
word_1A7E0:     dc.w 6, $F005, $4442, $F8F8
word_1A7E8:     dc.w 6, $F005, $4446, $F8F8
word_1A7F0:     dc.w 6, $F005, $444A, $F8F8
word_1A7F8:     dc.w 6, $F005, $444E, $F8F8
word_1A800:     dc.w 6, $F001, $4452, $FCFC
word_1A808:     dc.w 6, $F001, $4454, $FCFC
word_1A810:     dc.w 6, $F001, $4C52, $FCFC
word_1A818:     dc.w 3, $F005, $4492, $F8F8
word_1A820:     dc.w 3, $F005, $4496, $F8F8
word_1A828:     dc.w 3, $F005, $4C92, $F8F8
word_1A830:     dc.w 3, $F005, $4C96, $F8F8
word_1A838:     dc.w 6, $F005, $449A, $F8F8
word_1A840:     dc.w 6, $F005, $449E, $F8F8
word_1A848:     dc.w 6, $F005, $44A2, $F8F8
word_1A850:     dc.w 6, $F005, $44A6, $F8F8
word_1A858:     dc.w 6, $F005, $44AA, $F8F8
word_1A860:     dc.w 6, $F001, $44AE, $FCFC
word_1A868:     dc.w 6, $F001, $44B0, $FCFC
word_1A870:     dc.w 6, $F001, $4CAE, $FCFC
word_1A878:     dc.w $FF, $F005, $4400, $F8F8
word_1A880:     dc.w $FF, $F005, $4404, $F8F8
byte_1A888:     dc.b 0, $FF, $F0, 5, $44, 8, $F8, $F8
word_1A890:     dc.w $FF, $F005, $440C, $F8F8
word_1A898:     dc.w 0, $E806, $4410, $F8F8
word_1A8A0:     dc.w 1, $F005, $4416, $F8F8
byte_1A8A8:     dc.b 0, 0
                dc.w $E806, $441A, $F8F8
byte_1A8B0:     dc.b 0, 0
                dc.w $E806, $4420, $F8F8
byte_1A8B8:     dc.b 0, 1
                dc.w $F005, $4426, $F8F8
byte_1A8C0:     dc.b 0, 1
                dc.w $F005, $442A, $F8F8
byte_1A8C8:     dc.b 0, 2
                dc.w $F005, $442E, $F8F8
word_1A8D0:     dc.w 2, $F005, $4432, $F8F8
word_1A8D8:     dc.w 7, $F800, $4B2, $FCFC
word_1A8E0:     dc.w 7, $F800, $4B3, $FCFC
word_1A8E8:     dc.w 7, $F800, $4B4, $FCFC
word_1A8F0:     dc.w 7, $F800, $686, $FCFC
word_1A8F8:     dc.w 8, $F005, $44B5, $F8F8
word_1A900:     dc.w 8, $F005, $44B9, $F8F8
word_1A908:     dc.w 8, $F005, $44BD, $F8F8
word_1A910:     dc.w 8, $F005, $44C1, $F8F8
word_1A918:     dc.w $105, $E802, $44C5, $FCFC, $F001, $44C8, $F404
word_1A926:     dc.w $205, $E802, $44CA, $FCFC, $F001, $44CD, $F404, $F000, $44CF, $4F4
word_1A93A:     dc.w $205, $E802, $44D0, $FCFC, $F000, $44D3, $4F4, $F800, $44D4, $F404
word_1A94E:     dc.w $105, $E806, $44D5, $FCF4, $F800, $44DB, $F404
word_1A95C:     dc.w $205, $E802, $44DC, $FCFC, $F001, $44DF, $4F4, $F800, $44E1, $F404
word_1A970:     dc.w $112, $EB06, $44E2, $FCF4, $FB00, $44E8, $F404
word_1A97E:     dc.w $212, $EB05, $44E9, $FCF4, $F301, $44ED, $F404, $FB00, $44EF, $FCFC
word_1A992:     dc.w $FF, $E806, $44F0, $F8F8
word_1A99A:     dc.w $2FF, $EE05, $44F6, $FAF6, $F600, $44FA, $F206, $FE00, $44FB, $FAFE
word_1A9AE:     dc.w $FF, $F409, $44FC, $F4F4
word_1A9B6:     dc.w $2FF, $E802, $4502, $FAFE, $F000, $54FA, $F206, $F001, $54F8, $2F6
word_1A9CA:     dc.w $FF, $EB06, $54F0, $F8F8
word_1A9D2:     dc.w $2FF, $E802, $4D02, $FEFA, $F001, $5CF8, $F602, $F000, $5CFA, $6F2
word_1A9E6:     dc.w $FF, $F409, $4CFC, $F4F4
word_1A9EE:     dc.w $2FF, $EE05, $4CF6, $F6FA, $F600, $4CFA, $6F2, $FE00, $4CFB, $FEFA
word_1AA02:     dc.w 5, $E806, $4505, $F8F8
word_1AA0A:     dc.w 5, $E806, $44F0, $F8F8
word_1AA12:     dc.w 5, $E806, $4D05, $F8F8
word_1AA1A:     dc.w $205, $DC02, $44CA, $FCFC, $E401, $44CD, $F404, $E400, $44CF, $4F4
word_1AA2E:     dc.w $205, $DE02, $44CA, $FCFC, $E601, $44CD, $F404, $E600, $44CF, $4F4
word_1AA42:     dc.w $205, $E402, $44CA, $FCFC, $EC01, $44CD, $F404, $EC00, $44CF, $4F4
word_1AA56:     dc.w $205, $E802, $44D0, $FCFC, $F000, $44D3, $4F4, $F800, $44D4, $F404
word_1AA6A:     dc.w $205, $EA02, $44D0, $FCFC, $F200, $44D3, $4F4, $FA00, $44D4, $F404
word_1AA7E:     dc.w $FF, $F800, $450B, $FCFC
word_1AA86:     dc.w $FF, $F800, $450C, $FCFC
word_1AA8E:     dc.w $FF, $F800, $450D, $FCFC
word_1AA96:     dc.w $110, $F008, $650E, $F0F8, $F808, $6511, $F8F0
word_1AAA4:     dc.w $110, $F008, $6514, $F0F8, $F808, $6517, $F8F0
word_1AAB2:     dc.w $10, $F00D, $651A, $F0F0
word_1AABA:     dc.w $110, $F008, $6D14, $F8F0, $F808, $6D17, $F0F8
word_1AAC8:     dc.w $110, $F008, $6D0E, $F8F0, $F808, $6D11, $F0F8
word_1AAD6:     dc.w $111, $F004, $522, $F8F8, $F800, $524, $F800
word_1AAE4:     dc.w $11, $F005, $525, $F8F8
word_1AAEC:     dc.w 0, $F300, $529, $FDFB
word_1AAF4:     dc.w 0, $F300, $52A, $FDFB
word_1AAFC:     dc.w 0, $F300, $52B, $FDFB
word_1AB04:     dc.w 0, $F300, $52B, $FDFB
word_1AB0C:     dc.w 0, $F300, $52C, $FDFB
word_1AB14:     dc.w 0, $F300, $52D, $FDFB
word_1AB1C:     dc.w 0, $F300, $52E, $FDFB
word_1AB24:     dc.w $FF, $F808, $640, $F4F4
byte_1AB2C:     dc.b 0, $FF, $F8, 8, 6, $43, $F4, $F4
word_1AB34:     dc.w $FF, $F808, $646, $F4F4
word_1AB3C:     dc.w $FF, $F808, $649, $F4F4
word_1AB44:     dc.w $FF, $F808, $64C, $F4F4
word_1AB4C:     dc.w $FF, $F808, $64F, $F4F4
word_1AB54:     dc.w $FF, $F808, $652, $F2F6
word_1AB5C:     dc.w $FF, $F808, $655, $F2F6
word_1AB64:     dc.w $FF, $F808, $658, $F2F6
word_1AB6C:     dc.w $FF, $F808, $65B, $F2F6
word_1AB74:     dc.w 9, $F001, $465E, $FCFC
word_1AB7C:     dc.w $A, $F804, $4660, $F8F8
word_1AB84:     dc.w $A, $F804, $4662, $F8F8
word_1AB8C:     dc.w $A, $F804, $4664, $F8F8
word_1AB94:     dc.w $B, 4, $4666, $F8F8
word_1AB9C:     dc.w $B, 4, $4668, $F8F8
word_1ABA4:     dc.w $B, 4, $466A, $F8F8
word_1ABAC:     dc.w $C, $F801, $466C, $F800
word_1ABB4:     dc.w $C, $F801, $466E, $F800
word_1ABBC:     dc.w $D, $F801, $566C, $F800
word_1ABC4:     dc.w $D, $F801, $566E, $F800
word_1ABCC:     dc.w $1FF, $F001, $4670, $F800, $F800, $4672, $F008
word_1ABDA:     dc.w $1FF, 4, $4673, $F000, $800, $4675, $F800
word_1ABE8:     dc.w $1FF, 4, $4676, $F0, $800, $5E70, $F8
word_1ABF6:     dc.w $1FF, $F001, $4678, $F8, $F800, $5E73, $8F0
word_1AC04:     dc.w $1FF, $F804, $467A, $F8F8, 0, $467C, $F8
word_1AC12:     dc.w $1FF, $F801, $467D, $F8, 0, $467F, $F800
word_1AC20:     dc.w $1FF, $F801, $5E7B, $F800, 0, $5E7A, $F8
word_1AC2E:     dc.w $1FF, $F804, $4680, $F8F8
                dc.w 0, $5E7D, $F800
word_1AC3C:     dc.w $E, $F801, $4682, $FCFC
word_1AC44:     dc.w $E, $F801, $4E82, $FCFC
word_1AC4C:     dc.w 9, $F001, $4684, $FCFC
word_1AC54:     dc.w $E, $F801, $5682, $FCFC
word_1AC5C:     dc.w $E, $F801, $5E82, $FCFC
word_1AC64:     dc.w $F, 1, $5684, $FCFC
word_1AC6C:     dc.w $1FF, $F604, $467A, $F6FA, $FE00, $467C, $FEFA
word_1AC7A:     dc.w $1FF, $F001, $467D, $FCFC, $F800, $467F, $F404
word_1AC88:     dc.w $1FF, $F001, $5E7B, $FCFC, $F800, $5E7A, $4F4
word_1AC96:     dc.w $1FF, $F304, $4680, $FBF5, $FB00, $5E7D, $FBFD
word_1ACA4:     dc.w $8FF
                dc.w 0, $8047, $F8
                dc.w 0, $8041, $8F0
                dc.w 0, $804D, $10E8
                dc.w 0, $8045, $18E0
                dc.w 0, $8020, $20D8
                dc.w 0, $804F, $28D0
                dc.w 0, $8056, $30C8
                dc.w 0, $8045, $38C0
                dc.w 0, $8052, $40B8
word_1ACDC:     dc.w $DFF
                dc.w 0, $8050, $C830
                dc.w 0, $8055, $D028
                dc.w 0, $8053, $D820
                dc.w 0, $8048, $E018
                dc.w 4, $8053, $F000
                dc.w 0, $8041, $F8
                dc.w 0, $8052, $8F0
                dc.w 0, $8054, $10E8
                dc.w 0, $8042, $20D8
                dc.w 0, $8055, $28D0
                dc.w 0, $8054, $30C8
                dc.w 0, $8054, $38C0
                dc.w 0, $804F, $40B8
                dc.w 0, $804E, $48B0
word_1AD32:     dc.w $4FF
                dc.w 0, $8050, $F8
                dc.w 0, $8041, $8F0
                dc.w 0, $8055, $10E8
                dc.w 0, $8053, $18E0
                dc.w 0, $8045, $20D8
word_1AD52:     dc.w $FF, $E00B, $6740, $F4F4
word_1AD5A:     dc.w $FF, $E80A, $674C, $F4F4
word_1AD62:     dc.w $FF, $E806, $6755, $F8F8
word_1AD6A:     dc.w $FF, $E80A, $675B, $F4F4
word_1AD72:     dc.w $FF, $E80A, $6764, $F4F4
word_1AD7A:     dc.w $FF, $E00B, $676D, $F4F4
word_1AD82:     dc.w $FF, $E806, $4687, $F8F8
word_1AD8A:     dc.w $FF, $E806, $468D, $F8F8
off_1AD92:      dc.w byte_1ADF2-sub_10000
                dc.w byte_1AE40-sub_10000
                dc.w byte_1AE40-sub_10000
                dc.w byte_1AE7C-sub_10000
                dc.w byte_1AEDC-sub_10000
                dc.w byte_1AF20-sub_10000
                dc.w byte_1AF20-sub_10000
                dc.w byte_1AF6C-sub_10000
                dc.w byte_1AFBE-sub_10000
                dc.w byte_1B012-sub_10000
                dc.w byte_1B012-sub_10000
                dc.w byte_1B070-sub_10000
                dc.w byte_1B0B0-sub_10000
                dc.w byte_1B108-sub_10000
                dc.w byte_1B108-sub_10000
                dc.w byte_1B152-sub_10000
                dc.w byte_1B1A0-sub_10000
                dc.w byte_1B1F8-sub_10000
                dc.w byte_1B1F8-sub_10000
                dc.w byte_1B242-sub_10000
                dc.w byte_1B2A4-sub_10000
                dc.w byte_1B2E8-sub_10000
                dc.w byte_1B2E8-sub_10000
                dc.w byte_1B346-sub_10000
                dc.w byte_1B3A2-sub_10000
                dc.w byte_1B3EE-sub_10000
                dc.w byte_1B3EE-sub_10000
                dc.w byte_1B43C-sub_10000
                dc.w byte_1B486-sub_10000
                dc.w byte_1B4C8-sub_10000
                dc.w byte_1B4C8-sub_10000
                dc.w byte_1B522-sub_10000
                dc.w byte_1B56C-sub_10000
                dc.w byte_1B5AE-sub_10000
                dc.w byte_1B5AE-sub_10000
                dc.w byte_1B602-sub_10000
                dc.w byte_1B66C-sub_10000
                dc.w byte_1B6C0-sub_10000
                dc.w byte_1B6C0-sub_10000
                dc.w byte_1B700-sub_10000
                dc.w byte_1B74E-sub_10000
                dc.w byte_1B7B4-sub_10000
                dc.w byte_1B7B4-sub_10000
                dc.w byte_1B81C-sub_10000
                dc.w byte_1B85E-sub_10000
                dc.w byte_1B8C8-sub_10000
                dc.w byte_1B8C8-sub_10000
                dc.w byte_1B91C-sub_10000
byte_1ADF2:     dc.b $40, $86, $14, $86, $4A, $8C, $4A, $86, $14, $86
                dc.b $4A, $8C, $4A, $86, $14, $86, $4A, $8C, $4A, $86
                dc.b $14, $86, 0, $F, $17, $F, $B, $F, 5, $13
                dc.b 3, 8, $1E, 6, $1E, $C, $1E, $12, 0, $12
                dc.b 0, $C, 0, 6, $E, $F, $10, $F, 1, 7
                dc.b 3, 0, $B, 6, $B, $C, $B, $12, $13, $12
                dc.b $13, $C, $13, 6, 6, $F, $F, $13, $15, $1F
                dc.b $12, $1F, $C, $C, 9, $12, 9, 0
byte_1AE40:     dc.b $7F, $44, $9A, $7F, $24, $8D, 6, $8D, $7F, $24
                dc.b $9A, $7F, 0, $F, 5, 7, 6, $16, $12, 6
                dc.b $10, 4, 9, $A, 9, $16, $18, $16, $1C, $A
                dc.b 0, 1, $E, $A, 9, 7, 9, $D, 9, $13
                dc.b $17, $13, $17, $D, $17, 7, 6, 0, 6, 6
                dc.b $A, 0, $15, $F, $16, $19, $A, $17, 3, 0
byte_1AE7C:     dc.b $7F, $41, $8D, 6, $8D, $7F, $21, $8D, 6, $8D
                dc.b $7F, $21, $8D, 6, $8D, $7F, 0, $F, $17, $1B
                dc.b 6, $16, $18, $14, 3, $13, 1, 4, 3, 4
                dc.b 7, 4, $1D, 4, $15, $A, $17, $A, $1B, $A
                dc.b $1D, $A, 7, $A, 9, $A, 7, $10, 1, $10
                dc.b 3, $10, $15, $10, $1B, $16, $1D, $16, 0, $16
                dc.b 3, $16, 5, $16, 0, 0, 5, 7, 5, $D
                dc.b 5, $13, $19, $13, $19, $D, $19, 7, 8, 7
                dc.b 3, 6, $A, 7, $10, 7, $16, $19, $16, $19
                dc.b $10, $1A, $A, $17, 3, 0
byte_1AEDC:     dc.b $7F, $D, $88, $70, $88, 8, $88, $64, $84, $18
                dc.b $84, $64, $88, 8, $88, $70, $88, 0, $F, 3
                dc.b 7, 8, $17, $10, 1, $16, 4, 6, $E, 8
                dc.b $E, $E, $12, $10, $12, 0, 0, 9, 9, 9
                dc.b $11, $F, $15, $15, $11, $15, 9, $1F, $D, 6
                dc.b 7, 3, 0, 9, 7, $D, $F, $10, $F, $A
                dc.b 5, $14, 2, $17, 5, $19, $15, 0
byte_1AF20:     dc.b 6, $C7, $7F, $3A, $86, 5, $C7, $8A, 5, $C7
                dc.b $84, $7F, $21, $C7, $8A, 5, $C7, $8A, $7F, $2B
                dc.b $C6, $8A, 5, $8B, $7F, 0, $F, 5, $1D, 6
                dc.b $15, $18, $C, $16, 4, $C, 4, $13, 4, 7
                dc.b $10, 9, $10, 0, 0, $1B, 7, 3, 7, 5
                dc.b $D, 5, $13, $19, $13, $18, $D, 6, $A, 4
                dc.b 3, $A, 9, $16, $12, $10, $12, $A, $18, 4
                dc.b 2, $1D, $10, $1A, $16, 0
byte_1AF6C:     dc.b $57, $C5, $86, $6D, $8C, 1, $87, $1F, $C4, $41
                dc.b $85, $1A, $81, 4, $C4, $26, $C7, $8B, $29, $84
                dc.b $17, $85, $60, $87, 5, $86, 4, $8A, 6, $C5
                dc.b $7F, 0, $F, 5, $1A, 2, $1A, $18, 1, 8
                dc.b 3, $D, $A, $F, $A, $16, $16, 1, 2, 5
                dc.b 0, $C, 7, $C, $D, $C, $13, $C, $19, $18
                dc.b $19, $18, $13, 6, 4, 3, 0, $16, 7, $A
                dc.b 7, $F, $E, $10, $D, $16, 2, $18, $B, $13
                dc.b 3, 0
byte_1AFBE:     dc.b $7F, 3, $CB, $8B, 4, $8C, $1F, $CA, $6A, $86
                dc.b 4, $CB, $85, $15, $CA, $75, $85, $10, $85, $7F
                dc.b 6, $8B, 6, $8B, $7F, 0, $F, $17, $1A, 4
                dc.b 7, $18, 4, 2, 6, 9, 2, $B, 2, 4
                dc.b $C, $A, $11, $15, $11, $1A, $C, 2, 6, 8
                dc.b $17, $17, 0, 9, 5, 9, $A, 9, $14, $15
                dc.b $14, $15, $A, $15, 5, 4, 7, 2, $17, 2
                dc.b 9, 8, $1F, $B, 4, $15, 8, $15, $E, 9
                dc.b $E, $F, $C, 0
byte_1B012:     dc.b $40, $84, $18, $C7, $83, 3, $C2, $20, $84, $24
                dc.b $88, $25, $83, $24, $84, $19, $83, 3, $C2, $20
                dc.b $84, $24, $88, $24, $84, $1F, $C8, 4, $84, $18
                dc.b $84, 3, $C2, $20, $84, $24, $88, $24, $83, $25
                dc.b $84, $18, $84, 0, $F, 4, 0, 8, $11, $18
                dc.b $D, $16, 3, 5, $E, $F, $F, $18, $10, 0
                dc.b 1, 7, $16, $F, $12, $F, $19, $1D, $15, $1D
                dc.b $F, $1D, 9, $1D, 3, 4, 6, 2, 5, 8
                dc.b 5, $E, $19, 2, 4, $19, $A, $15, $F, $F
                dc.b $16, $F, 9, 0
byte_1B070:     dc.b $43, $9A, $7F, 4, $8E, 4, $8E, $6E, $84, $7A
                dc.b $88, $7F, $17, $8C, 0, $F, $13, 2, $18, $19
                dc.b 7, $1C, $E, 1, $1A, $16, 1, $18, $13, 2
                dc.b 0, $10, 5, $D, 5, 3, 9, 3, $D, 3
                dc.b $11, 3, $15, 3, $19, 3, 4, $F, 1, 9
                dc.b 5, $15, 5, $F, 9, 4, 6, $F, 2, $13
                dc.b $1A, $14, $18, $E
byte_1B0B0:     dc.b $6A, $C3, $87, $1F, $C4, $E, $82, 4, $84, $12
                dc.b $84, $32, $84, $70, $84, $C, $C5, $83, $F, $C4
                dc.b $58, $84, 4, $84, 4, $84, 4, $84, $62, $82
                dc.b $1C, $82, $A, $8C, 0, $F, $13, $14, 7, 4
                dc.b $18, $1B, $16, 3, $1B, $D, $13, $D, $B, $D
                dc.b 1, 4, $15, 2, 0, $B, $18, 3, $B, 4
                dc.b $13, 8, $13, $10, $13, $15, $B, $15, $B, $10
                dc.b 4, 3, 2, $D, 2, $1D, 3, $18, 6, 4
                dc.b 2, $B, $C, $B, $12, $D, $19, $15
byte_1B108:     dc.b $6C, $88, $7F, $14, $86, 6, $86, $7F, $2A, $86
                dc.b $10, $86, $7F, $23, $83, $1A, $83, 0, $F, $17
                dc.b 9, 8, $1B, $E, $10, $11, 2, $16, 6, 4
                dc.b $C, 2, 6, $17, $15, $15, 3, $19, 4, $1B
                dc.b $A, 0, 4, $B, 9, 6, $F, 1, $15, $1D
                dc.b $15, $18, $F, $13, 9, 4, 0, 6, 4, $C
                dc.b 1, $12, $C, $11, 4, $13, $11, $1D, $12, $1C
                dc.b 7, $15, 6, 0
byte_1B152:     dc.b $68, $85, $B, $C3, $83, $10, $C2, $20, $8B, $68
                dc.b $84, 8, $89, 7, $84, $14, $CA, $7F, $14, $C6
                dc.b $87, 5, $87, $72, $86, $C, $88, 0, $F, 4
                dc.b $1A, 3, $C, $F, $1B, $16, 3, 2, $12, $17
                dc.b $D, $19, $D, 0, 1, 5, $A, $A, 4, $C
                dc.b $A, $E, $14, 6, $15, $15, $10, $19, 4, 4
                dc.b 4, 5, 3, $11, 9, 8, $17, 9, 4, $11
                dc.b $E, $10, $17, $17, $14, $A, $14, 0
byte_1B1A0:     dc.b $7F, 1, $82, $C, $84, $C, $82, $62, $84, 4
                dc.b $84, 4, $84, 4, $84, $68, $84, $C, $84, $68
                dc.b $84, 4, $84, 4, $84, 4, $84, $62, $82, $C
                dc.b $84, $C, $82, 0, $F, 3, 3, 8, $17, $18
                dc.b 9, $16, 4, $B, $E, $B, 6, $13, 6, $13
                dc.b $E, 0, 2, $16, 4, 0, $C, $C, 9, $A
                dc.b $11, 0, $15, $1E, $15, $14, $11, $12, 9, 4
                dc.b 8, 5, 7, $A, 6, $15, $F, $B, 4, $13
                dc.b $15, $17, 9, $1B, 5, $1D, $F, 0
byte_1B1F8:     dc.b $47, $C7, $85, 6, $86, $1F, $C6, $55, $84, $30
                dc.b $85, $12, $85, $7F, $25, $86, $10, $C7, $85, 9
                dc.b $C6, $7F, $21, $85, 6, $85, 0, $F, 5, $A
                dc.b 2, $14, $18, $1C, $16, 2, $1A, 6, 4, 6
                dc.b 0, 1, 0, $13, 7, 3, 9, 3, $B, 3
                dc.b $13, 3, $15, 3, $17, 3, 4, 0, $C, 3
                dc.b 6, $A, $F, 2, $14, 4, $F, $D, $14, $F
                dc.b $1A, $15, $1B, 5
byte_1B242:     dc.b $7F, 1, $8D, 6, $87, 5, $81, $7F, $21, $9A
                dc.b 5, $81, $C, $CA, $7F, $14, $86, 7, $8D, 5
                dc.b $81, $60, $8C, $12, $82, $32, $C2, $C2, $C2, $C2
                dc.b 0, $F, 9, 4, 4, $F, $18, $13, $14, 0
                dc.b 8, 8, 3, $E, 3, $18, 3, $1A, 8, $11
                dc.b $F, $17, $15, 5, $E, 4, 8, 5, $A, 8
                dc.b 7, $11, $1B, $B, $17, $E, 0, 2, 3, $11
                dc.b 5, $15, 5, 5, $17, 5, $17, $B, $17, $11
                dc.b 4, $A, 2, 4, 8, 8, $10, $E, $14, 4
                dc.b $1B, $15, $F, $E, $15, 8, $1C, 3
byte_1B2A4:     dc.b $4E, $84, $7A, $88, $75, $8E, $6F, $94, $7F, $A
                dc.b $9A, $7F, 0, $F, $17, $F, 6, $17, $18, 0
                dc.b $B, 0, 4, 2, $B, 7, 3, $15, 4, $17
                dc.b 7, 3, 1, 7, 5, 6, $1C, $D, $F, 7
                dc.b $F, $B, $D, $F, $11, $F, $13, $14, $B, $14
                dc.b 4, 4, $A, $A, 4, $C, $12, 8, $17, 4
                dc.b $15, $17, $12, $12, $15, 5, $1D, 9
byte_1B2E8:     dc.b $48, $85, 6, $C6, $84, 8, $82, $A, $C5, $11
                dc.b $82, $7F, 4, $85, $10, $85, $7F, $2C, $85, 6
                dc.b $C6, $84, 8, $84, 8, $C5, $F, $C6, $83, 3
                dc.b $C5, $69, $86, $11, $84, $10, $84, 0, $F, $17
                dc.b $1E, 3, 5, $18, $1C, $D, 0, 5, 0, $C
                dc.b 6, $C, 5, $13, 9, $17, $13, $D, 2, $F
                dc.b $E, $E, 3, 9, 3, 9, $F, $15, 3, $15
                dc.b $F, $1E, $10, $1F, 4, 4, $F, 3, 5, 4
                dc.b 9, $A, 7, $12, 4, $15, $B, $19, 5, $17
                dc.b $13, $1F, $D, 0
byte_1B346:     dc.b $6B, $C6, $82, 4, $D2, $82, $18, $D1, 6, $C5
                dc.b $73, $C6, $82, $A, $83, $1F, $C5, $6D, $C6, $82
                dc.b $10, $83, $1F, $C5, $67, $83, $16, $83, $2C, $83
                dc.b 6, $83, 0, $F, $17, $13, 3, 3, $18, $1E
                dc.b 4, 8, 8, 6, 5, $B, 2, $10, $1C, $10
                dc.b $19, $A, $16, 6, $14, $12, $A, $12, 1, 1
                dc.b 5, 0, $C, 4, 9, 9, 6, $E, $18, $E
                dc.b $15, 9, $12, 4, 4, 8, 3, 4, 8, $A
                dc.b $E, $1F, $E, 4, $14, $E, $F, $B, $16, 3
                dc.b $1A, 8
byte_1B3A2:     dc.b $62, $94, $1F, $C4, $4A, $8A, $C, $84, 4, $82
                dc.b $19, $C4, $4C, $C5, $92, $68, $85, $A, $8C, 6
                dc.b $C4, $60, $9B, $7F, 0, $F, 2, $F, $B, $F
                dc.b $18, $1E, $10, 4, $12, 9, $A, $11, $C, $11
                dc.b $C, 9, 0, 1, $1C, $B, $14, $C, $15, $C
                dc.b $16, $C, 3, $14, 4, $14, 5, $14, 4, 2
                dc.b $C, 8, 2, 9, $10, 9, $16, 4, $D, 8
                dc.b $1C, $C, $1C, 4, $14, $16
byte_1B3EE:     dc.b $D8, $60, $91, 4, $86, $1F, $D0, $55, $C5, $85
                dc.b $1F, $C8, $56, $C5, $83, $78, $C5, $83, 5, $84
                dc.b $6F, $84, 1, $8D, $7F, 0, $F, $17, 8, 3
                dc.b 6, $18, 2, $D, 4, $A, $D, 6, $11, $E
                dc.b 9, $13, 5, 1, 3, 9, 0, 1, 4, $A
                dc.b $14, $B, $14, $12, $10, $13, $10, $14, $10, 4
                dc.b $B, 9, 5, $D, 2, $15, $F, $10, 4, $13
                dc.b $C, $18, $B, $1D, $B, $19, 2, 0
byte_1B43C:     dc.b $64, $98, $64, $8D, 6, $8D, $64, $98, $64, $8D
                dc.b 6, $8D, $64, $98, $7F, 0, $F, 2, $F, $B
                dc.b $F, $18, $1C, $16, 8, $1E, $16, 0, $16, 0
                dc.b $D, 0, 5, $1E, 5, $1E, $D, $E, $11, $10
                dc.b $11, 0, 0, 9, 8, 9, $10, $15, $10, $14
                dc.b 8, $F, $C, $F, $14, 4, $B, 2, 9, $16
                dc.b $F, 8, $F, $10, 4, $15, $16, $1F, $14, $1F
                dc.b $C, $1F, 2, 0
byte_1B486:     dc.b $63, $D1, $97, $7F, $12, $94, $7F, 9, $91, $7F
                dc.b $2C, $99, $7F, 0, $F, 2, $15, 8, $D, $18
                dc.b $1A, $C, 5, 9, $B, $B, $11, $D, $11, $12
                dc.b $11, $14, $11, 0, 0, $C, 9, $C, $E, $C
                dc.b $14, $17, $14, $17, $E, $17, 9, 4, $11, $C
                dc.b 7, 9, 5, $F, $1F, $14, 4, $11, $11, $13
                dc.b $17, $1C, $F, $1D, 4, 0
byte_1B4C8:     dc.b $46, $C6, $85, $A, $C6, $85, $7F, 5, $C7, $85
                dc.b $A, $C7, $85, $7F, $35, $C6, $85, $A, $C6, $85
                dc.b $7F, 5, $C6, $85, $A, $C6, $85, $7F, 0, $F
                dc.b $17, 8, 2, $18, 2, $1E, $16, $A, $15, $10
                dc.b $17, $10, $1C, $B, $1E, $B, 5, $10, 7, $10
                dc.b $B, $B, $D, $B, $11, 5, $13, 5, 0, 0
                dc.b 4, 8, $E, $E, 5, $19, $15, $19, $14, 8
                dc.b $1E, $E, 4, 1, 3, 5, $D, $B, 8, 6
                dc.b $16, 4, $E, $13, $15, $E, $12, 2, $18, $16
byte_1B522:     dc.b $1F, $D8, $43, $CC, $88, 7, $89, $1F, $CB, $68
                dc.b $89, 5, $89, $7F, $2A, $89, 5, $89, $7F, $E
                dc.b $8F, $7F, 0, $F, $17, 7, 3, $F, $13, 1
                dc.b $12, 4, 4, $15, $A, $C, $13, $C, $19, $15
                dc.b 1, $14, 7, 0, 9, 9, 9, $F, 9, $14
                dc.b $13, $14, $13, $F, $13, 9, 4, $F, 3, 0
                dc.b 8, 3, $12, 5, $C, 4, $F, $D, $18, $C
                dc.b $1A, $14, $1D, 9
byte_1B56C:     dc.b $60, $8E, 4, $8E, $7F, $4F, $84, $7F, $4F, $8E
                dc.b 4, $8E, $7F, 0, $F, 9, $1A, 3, 4, $11
                dc.b 1, $B, 4, $B, $F, 9, $F, $13, $F, $15
                dc.b $F, 1, 4, $16, 0, 2, $19, 2, $12, 2
                dc.b 4, $1D, 4, $1D, $12, $1D, $19, 4, 6, 2
                dc.b 2, $E, 9, 9, 6, $15, 4, $18, 2, $14
                dc.b 9, $1C, $F, $18, $15, 0
byte_1B5AE:     dc.b $4A, $85, 3, $D3, $84, $17, $D2, $33, $CD, $84
                dc.b $13, $85, $1F, $CC, $2B, $84, 5, $84, $4C, $84
                dc.b $13, $84, $4C, $84, 5, $84, $4C, $84, $13, $84
                dc.b $4C, $84, 5, $84, 0, $F, $17, $1B, 5, 3
                dc.b $18, $10, $D, 4, 4, 9, 4, $F, $1B, $F
                dc.b $1B, 9, 0, 0, $B, 3, $B, 9, $B, $F
                dc.b $12, $F, $12, 9, $12, 3, 4, $B, 6, $B
                dc.b $12, 8, $C, $1F, $C, 4, $15, 6, $14, $12
                dc.b $17, $C, $10, $A
byte_1B602:     dc.b $60, $CF, $8E, 3, $8E, $67, $C4, $83, $B, $C4
                dc.b $83, $10, $C3, $E, $C3, $27, $86, 1, $82, 1
                dc.b $84, 3, $84, 1, $82, 1, $86, $67, $C4, $83
                dc.b $B, $C4, $83, $10, $C3, $E, $C3, $27, $86, 1
                dc.b $82, 1, $84, 3, $84, 1, $82, 1, $86, $60
                dc.b $87, $13, $C3, $85, 6, $C2, 0, $F, $17, $1C
                dc.b 3, 8, $18, 2, 8, 4, $C, 8, $C, $F
                dc.b $13, $F, $13, 8, 0, 0, $C, 4, $C, $B
                dc.b $C, $12, $13, $12, $13, $B, $13, 4, 4, $10
                dc.b 7, 3, 8, 3, $F, 9, $15, 4, $10, $F
                dc.b $15, $15, $1D, $F, $1D, 7
byte_1B66C:     dc.b $4C, $89, $1F, $C4, $51, $CC, $89, 5, $85, $1F
                dc.b $CB, $49, $83, $A, $84, 6, $85, $7F, $43, $85
                dc.b 1, $85, 8, $C4, $84, 1, $83, $E, $C3, $40
                dc.b $88, 0, $F, $13, $10, 2, $1E, $18, $F, $17
                dc.b 4, 8, $F, $A, $F, $14, $F, $16, $F, 1
                dc.b 0, $16, 0, 7, 7, 4, $12, 8, $12, $12
                dc.b 3, $1B, $B, $16, $12, 4, 9, 3, 0, 7
                dc.b 0, $F, 6, $16, 4, $B, $D, $16, $D, $19
                dc.b $16, $1B, 3, 0
byte_1B6C0:     dc.b $7F, $7F, $70, $84, $7F, $4F, $82, 6, $84, 8
                dc.b $84, 6, $82, $7F, 0, $F, $A, 9, $18, $15
                dc.b $12, $F, $10, 4, 3, $A, 5, $A, $19, $A
                dc.b $1B, $A, 0, 0, 9, $13, $15, $13, $1F, $13
                dc.b 4, $19, $F, $19, $1A, $19, 4, 3, $10, 7
                dc.b 9, $B, 7, $1F, 9, 4, $14, 7, $F, $13
                dc.b $18, 9, $1A, $10
byte_1B700:     dc.b $40, $89, 5, $92, $12, $D2, $4D, $8E, 8, $8A
                dc.b $D, $C4, $72, $8A, 9, $8D, $60, $8E, 9, $89
                dc.b $D, $C8, $72, $89, $A, $8D, 0, $F, $17, $B
                dc.b 6, $B, $F, $F, $E, 4, $17, 9, $19, 9
                dc.b $17, $12, $19, $12, 1, 3, $13, 0, $1A, $19
                dc.b $1A, $15, $1A, $10, $1A, $C, $1A, 7, $1A, 3
                dc.b 4, 6, 2, $A, $A, $F, $A, $14, $A, 4
                dc.b $E, 2, $A, $14, $F, $13, $14, $13
byte_1B74E:     dc.b $40, $83, 3, $85, 3, $85, 3, $85, 3, $82
                dc.b $62, $85, 3, $85, 3, $85, 3, $85, $61, $83
                dc.b 3, $85, 3, $85, 3, $85, 3, $82, $62, $85
                dc.b 3, $85, 3, $85, 3, $85, $61, $83, 3, $85
                dc.b 3, $85, 3, $85, 3, $82, $7F, 0, $F, $17
                dc.b 7, $A, $17, $A, $F, 9, 4, 3, $16, 5
                dc.b $16, $19, $16, $1B, $16, 2, 8, $17, $12, $17
                dc.b 0, $B, 7, $14, 7, $17, $B, 7, $B, $F
                dc.b $B, $F, $13, 4, 7, 2, 7, $D, 7, $16
                dc.b $C, $B, 4, $14, $B, $17, 2, $18, $E, $17
                dc.b $17, 0
byte_1B7B4:     dc.b $63, $84, 4, $84, 4, $84, 4, $84, 7, $C7
                dc.b 7, $C7, 7, $C7, 7, $C7, $7F, $22, $82, 5
                dc.b $83, 5, $83, 5, $83, 5, $81, 1, $C7, 7
                dc.b $C7, 7, $C7, 7, $C7, $7F, $29, $83, 5, $83
                dc.b 5, $83, 5, $83, 7, $C6, 7, $C6, 7, $C6
                dc.b 7, $C6, $7F, 0, $F, $17, $C, 3, $1C, 3
                dc.b $B, $A, 4, 0, 8, 2, 8, $10, 8, $12
                dc.b 8, 0, 0, 4, 4, $C, 4, $14, 4, $1C
                dc.b 4, $18, $19, 7, $19, 4, 1, $15, 6, $F
                dc.b $B, 8, 9, $16, 4, $E, $E, $16, $E, $1E
                dc.b $E, $19, $15, 0
byte_1B81C:     dc.b $6E, $84, $7F, $65, $86, $7F, $45, $88, $7F, 0
                dc.b $F, 2, 3, $11, $13, $18, 0, 6, 0, 7
                dc.b 4, $E, 7, $B, 9, 8, $16, 4, $19, $E
                dc.b $19, $17, $B, $13, 0, $D, 4, $D, 4, $D
                dc.b 4, $D, 4, $D, 4, $D, 4, 4, 6, $F
                dc.b 6, 6, $F, 7, $F, $D, 4, $F, $14, $1B
                dc.b $F, $17, 6, $1E, 6, 0
byte_1B85E:     dc.b $60, $82, $D, $C4, $82, $D, $C4, 1, $C3, $F
                dc.b $C3, $2E, $81, $F, $81, $56, $C4, $82, $D, $C4
                dc.b $82, $F, $C3, $F, $C3, $2E, $81, $F, $81, $35
                dc.b $85, $D, $82, $1D, $C4, 1, $C3, $3E, $81, $49
                dc.b $C4, $82, 7, $C4, $82, $15, $C3, 9, $C3, $34
                dc.b $81, 9, $81, 0, $F, $D, 8, 9, $1B, $18
                dc.b $1B, 4, 0, 5, 2, $B, 4, $16, $A, 6
                dc.b $13, 3, $19, 7, 0, 7, $A, $1F, 4, $1F
                dc.b $10, $E, $F, $11, $F, $17, $A, 4, 7, 5
                dc.b $A, $14, $1F, $C, $1F, $17, 4, $15, $14, $10
                dc.b $16, $F, 2, $18, 6, 0
byte_1B8C8:     dc.b $68, $C8, $8F, $1F, $C7, $77, $C6, $C6, $34, $C8
                dc.b $82, $10, $83, $1F, $C7, $31, $C8, $82, 2, $83
                dc.b $1F, $C7, $4E, $C4, $82, $16, $83, $1F, $C6, $2B
                dc.b $C4, $82, 4, $83, 1, $83, 0, $F, 2, 5
                dc.b $A, $19, $18, $F, 7, 0, 3, 2, 7, $19
                dc.b 3, $1A, 6, 0, $F, 9, $D, $E, $11, $E
                dc.b $11, $15, $14, $15, $A, $19, 4, 4, 3, $C
                dc.b 7, $F, $12, 8, $11, 4, $13, 7, $17, $11
                dc.b $1B, 3, $1F, $B
byte_1B91C:     dc.b 5, $C4, 5, $C4, 9, $C4, 5, $C4, $47, $C4
                dc.b $81, 7, $82, 5, $C4, $81, 7, $82, $F, $C3
                dc.b $F, $C3, $26, $89, 7, $89, $63, $85, 5, $C4
                dc.b $8C, 5, $C4, $83, 4, $C3, $11, $C3, $29, $84
                dc.b 7, $8B, 7, $83, $60, $8A, 5, $C3, $82, 5
                dc.b $C7, $88, 9, $C6, 7, $C2, $F, $C5, $82, 1
                dc.b $C5, $82, 8, $81, 8, $C3, $82, 1, $C5, $82
                dc.b 7, $C4, $1B, $C3, 2, $81, $13, $82, 2, $82
                dc.b $1B, $C2, 6, $81, $16, $82, 3, $82, 0, $F
                dc.b $17, $10, $A, 0, $11, $10, 4, 0, 0, 0
                dc.b $B, $B, $14, $B, $1E, $B, $1D, $12, 2, $12
                dc.b 0, $B, 4, 3, 3, $C, 3, 7, $B, $E
                dc.b $11, 4, $11, $11, $18, $B, $13, 3, $1C, 3
                dc.b 0, 0
;empty_block_2:  dc.b [$465F]$FF
                org $FFFF
byte_1FFFF:     dc.b $FF
