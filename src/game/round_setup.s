; Round init, tileset and palette loading.
; ROM $012656-$012A93.

Game_InitRound:
                bsr.w   Sys_InitTitleScreen  ; was: sub_12656
                lea     (word_16DE8).l,a5
                jsr     unk_FFFBBA
                clr.l   (dword_FFD888).w
                clr.b   (byte_FFD88D).w
                rts

; Short delay before round based on round mod 4
Game_PreRoundDelay:
                move.w  #$20,(word_FFFFC0).w  ; was: sub_1266E
                move.b  (word_FFD82C+1).w,d0
                andi.b  #3,d0
                cmpi.b  #3,d0
                bne.s   loc_12688
                move.w  #$28,(word_FFFFC0).w

loc_12688:
                jsr     unk_FFFB6C
                rts

; Loads level tileset based on round number
Level_LoadTileset:
                moveq   #$18,d7  ; was: sub_1268E
                bsr.w   Math_ModuloLower
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
                bsr.w   Math_ModuloUpper
                subq.b  #1,d0
                lsr.w   #2,d0
                lsl.w   #2,d0
                lea     off_12788(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD810).w
                moveq   #$F,d7
                bsr.w   Math_ModuloUpper
                subq.b  #1,d0
                lsl.w   #2,d0
                lea     off_127E8(pc),a0
                move.l  (a0,d0.w),d1
                move.l  d1,(dword_FFD828).w
                move.l  #word_1A274,(dword_FFD81C).w
                move.l  #word_1A292,(dword_FFD820).w
                move.l  #word_1A286,(dword_FFD824).w
                rts

off_12728:      dc.l    byte_1A196
                dc.l    byte_1A198
                dc.l    byte_1A19A
                dc.l    byte_1A19C
                dc.l    byte_1A19E
                dc.l    byte_1A1A0
off_12740:      dc.l    word_1A2D6
                dc.l    word_1A2E6
                dc.l    word_1A2F6
                dc.l    word_1A306
                dc.l    word_1A316
                dc.l    word_1A326
off_12758:      dc.l    word_1A1A2
                dc.l    word_1A1B2
                dc.l    word_1A1C2
                dc.l    word_1A1D2
                dc.l    word_1A1E2
                dc.l    word_1A1F2
off_12770:      dc.l    word_1A202
                dc.l    word_1A212
                dc.l    word_1A222
                dc.l    word_1A232
                dc.l    word_1A242
                dc.l    word_1A252
off_12788:      dc.l    word_1A29A
                dc.l    word_1A2A6
                dc.l    word_1A2B2
                dc.l    word_1A2BE
                dc.l    word_1A2CA
                dc.l    word_1A29A
                dc.l    word_1A2A6
                dc.l    word_1A2B2
                dc.l    word_1A29A
                dc.l    word_1A2A6
                dc.l    word_1A2B2
                dc.l    word_1A29A
off_127B8:      dc.l    word_1A336
                dc.l    word_1A336
                dc.l    word_1A374
                dc.l    word_1A3D2
                dc.l    word_1A44E
                dc.l    word_1A410
off_127D0:      dc.l    word_1A354
                dc.l    word_1A354
                dc.l    word_1A392
                dc.l    word_1A3B2
                dc.l    word_1A3F0
                dc.l    word_1A42E
off_127E8:      dc.l    word_1A4E8
                dc.l    word_1A518
                dc.l    word_1A548
                dc.l    word_1A578
                dc.l    word_1A5A8
                dc.l    word_1A5D8
                dc.l    word_1A608
                dc.l    word_1A638
                dc.l    word_1A668
                dc.l    word_1A698
                dc.l    word_1A6C8
                dc.l    word_1A6F8
                dc.l    word_1A728
                dc.l    word_1A758
                dc.l    word_1A788
; Loads level palette based on round number
Level_LoadPalette:
                moveq   #$30,d7  ; was: sub_12824
                bsr.w   Math_ModuloLower
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
                bsr.w   Math_ModuloUpper
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

off_12866:      dc.w    word_1287E-Sys_GameEntryPoint
                dc.w    word_1289E-Sys_GameEntryPoint
                dc.w    word_128BE-Sys_GameEntryPoint
                dc.w    word_128DE-Sys_GameEntryPoint
                dc.w    word_128FE-Sys_GameEntryPoint
                dc.w    word_1291E-Sys_GameEntryPoint
                dc.w    word_1293E-Sys_GameEntryPoint
                dc.w    word_1295E-Sys_GameEntryPoint
                dc.w    word_1297E-Sys_GameEntryPoint
                dc.w    word_1299E-Sys_GameEntryPoint
                dc.w    word_129BE-Sys_GameEntryPoint
                dc.w    word_129DE-Sys_GameEntryPoint
word_1287E:     dc.w    0, 6, $E, $CC4, $4AA, $6EE, $64, $64, $A2, $A2, $6EE, $8C, $8EE, $AE, $6E, $4CA
word_1289E:     dc.w    0, $68, $2AA, $4A, $EA8, $444, $C86, $CCC, $EA8, $AAA, 0, $A4, $AC, $C6, $62, $A8
word_128BE:     dc.w    0, $EE, $46C, $E28, $A0A, $C2A, $A8A, $E4E, $ACA, $64A, $CAC, $888, $EEE, $AAA, $444, $888
word_128DE:     dc.w    0, $A86, $C, $AAA, $464, $4A, $242, $8A, 0, $420, $864, $C6E, $CCE, $E8E, $A0E, $CAE
word_128FE:     dc.w    0, $E00, $E60, $AAA, $286, $2CA, $44, $A8, 0, 0, 0, $CC, $EEE, $EE, $86, $8EE
word_1291E:     dc.w    0, $62E, $EC0, $E00, $EE, $AEE, $66, $CA, 0, 0, 0, $888, $EEE, $AAA, $444, $888
word_1293E:     dc.w    0, 6, $E, $CC4, $4A8, $6EE, $AAA, $8CC, $CCC, $AEE, 0, $C2, $EEE, $E6, $A0, $4CA
word_1295E:     dc.w    0, $48, $8E, $4E, $4E4, $444, $8A, $AA2, $AE, $882, 0, $8E, $EE, $28E, $2A, $AA
word_1297E:     dc.w    0, $6A, $EE, $E0, $AE, $E0, $86, $68, $8A, $66, $AC, $888, $EEE, $AAA, $444, $888
word_1299E:     dc.w    0, $EAE, $E6E, $E48, $C06, $4A, $8A, $4E, 0, $44, 0, $AA, $6CC, $CC, $66, $A8
word_129BE:     dc.w    0, $E00, $E60, $AAA, $666, $A6E, 0, 0, $4AE, 6, 2, $EE0, $EEE, $EE6, $E60, $EEA
word_129DE:     dc.w    0, $62E, $EC0, $E00, $EE, $AEE, 0, 0, $4AE, $A, 2, $A6C, $EE6, $C8E, $406, $EEC
off_129FE:      dc.w    word_12A1C-Sys_GameEntryPoint
                dc.w    word_12A24-Sys_GameEntryPoint
                dc.w    word_12A2C-Sys_GameEntryPoint
                dc.w    word_12A34-Sys_GameEntryPoint
                dc.w    word_12A3C-Sys_GameEntryPoint
                dc.w    word_12A44-Sys_GameEntryPoint
                dc.w    word_12A4C-Sys_GameEntryPoint
                dc.w    word_12A54-Sys_GameEntryPoint
                dc.w    word_12A5C-Sys_GameEntryPoint
                dc.w    word_12A64-Sys_GameEntryPoint
                dc.w    word_12A6C-Sys_GameEntryPoint
                dc.w    word_12A74-Sys_GameEntryPoint
                dc.w    word_12A7C-Sys_GameEntryPoint
                dc.w    word_12A84-Sys_GameEntryPoint
                dc.w    word_12A8C-Sys_GameEntryPoint
word_12A1C:     dc.w    $EE, $60, $48, $4E
word_12A24:     dc.w    $EE, $40, $A, $6A
word_12A2C:     dc.w    $EEE, $666, $EE0, $E44
word_12A34:     dc.w    $AA, $8EE, $CC, $E
word_12A3C:     dc.w    $AC, $EC, $8EE, $666
word_12A44:     dc.w    $8EE, $AAA, $CCA, $8C2
word_12A4C:     dc.w    $EE, 0, $28E, $E
word_12A54:     dc.w    $A, 0, $EE, $22E
word_12A5C:     dc.w    $444, $AAA, $EEE, $20E
word_12A64:     dc.w    $EEE, $AAA, $4A, $8C
word_12A6C:     dc.w    $EEE, 0, $E, $CAE
word_12A74:     dc.w    $88E, 0, $2C, $A
word_12A7C:     dc.w    $EEE, 0, $E22, $600
word_12A84:     dc.w    $EEE, $666, $40C, $A8E
word_12A8C:     dc.w    $EEE, $222, $AAA, $666
; Main game round entry: init level and start play
