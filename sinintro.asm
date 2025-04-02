****************************************************************************
* PHR CREW - The Sin Intro
*
* Coding:   Haegar
* Music:    Mark II
* Graphics: Haegar
* Text:     Haegar, Phil
*
* Disassembly: MnemoTroN/Spreadpoint in March 2025
*
* Fixes: Fully relocatable exe
*        Uses BSS hunk for bitplanes
****************************************************************************

BYTES_PER_LINE		equ	84
FONT_BYTES_PER_LINE	equ	126

	section	main,code

; Startup code by StingRay calls MAIN

	include	"startup.i"

; Obsolete code by using modern startup
;	move.l	#MAIN,$80.w
;	trap	#0
;	rts

MAIN:
;	move.w	#$2700,sr
;	movem.w	d0-d7/a0-a6,-(sp)

;	move.l	#$6C000,a0
;	move.l	#$7FFF0,a1
;lbC000026:
;	clr.l	(a0)+
;	cmp.l	a0,a1
;	bge	lbC000026

;Always clear your BSS hunks
	lea	copperlist2,a0
	move.w	#(BSS_SIZE/2)-1,d0
	moveq	#0,d1
clrloop:
	move.l	d1,(a0)+
	dbf	d0,clrloop

; Generate Copper list for scroller area
	lea	cop_scroller,a0
	move.l	#$CA07,d1
	move.l	#55,d0
lbC000040:
	move.w	d1,(a0)+
	move.w	#$FFFE,(a0)+
	move.w	#$184,(a0)+
	move.w	#$FFF,(a0)+
	add.w	#$100,d1
	dbra	d0,lbC000040

; Generate Copper list for logo area
	lea	cop_logo,a0
	move.l	#$4A07,d1
	move.l	#40,d0
lbC000068:
	move.w	d1,(a0)+
	move.w	#$FFFE,(a0)+
	move.w	#$184,(a0)+
	move.w	#$F0F,(a0)+
	move.w	#$182,(a0)+
	move.w	#$FF0,(a0)+
	add.w	#$100,d1
	dbra	d0,lbC000068

;MTN added: Set dynamic bitplane addresses
	move.l	#screenbuf,d0
	moveq	#$54,d1
	lea	cop_bplptr,a0
	moveq	#2,d7
setbpl:
	move.l	d0,d2
	move.w	d2,4(a0)
	swap	d2
	move.w	d2,(a0)
	addq.w	#8,a0
	add.l	d1,d0
	dbf	d7,setbpl

;Copy Copper list (Why?? It's not double-buffered)
	lea	copperlist1,a0
	move.l	#copperlist2,a1
	lea	copperlist_end,a2
lbC000098:
	move.l	(a0)+,(a1)+
	cmp.l	a0,a2
	bge	lbC000098

;Set bitplane pointers in copy of copper list. A bit weird way.
;Could've been set before copying.
	move.l	#copperlist2,a0
	move.l	#copperlist1,a1
	move.l	#cop_scroller,a2
	sub.l	a1,a2
	add.l	a2,a0
	move.l	a0,lbL000298

;MTN: Unused
;	move.l	#copperlist2,a0
;	move.l	#copperlist1,a1
;	move.l	#lbW001DAA,a2
;	sub.l	a1,a2
;	add.l	a2,a0
;	add.l	#2,a0
;	move.l	a0,lbL0004DC

	move.l	#copperlist2,a0
	move.l	#copperlist1,a1
	move.l	#cop_logo,a2
	sub.l	a1,a2
	add.l	a2,a0
	move.l	a0,cop_addr_logo

	move.l	#copperlist2,a0
	move.l	#copperlist1,a1
	move.l	#lbW001DA2,a2
	sub.l	a1,a2
	add.l	a2,a0
	move.l	a0,lbL0002A0

	move.w	#$0080,$DFF096
	move.l	#copperlist2,a0
	move.l	a0,$DFF080
	move.w	#$8080,$DFF096

;MTN: Removed flickering color on startup

;	move.l	#copperlist2,a0
;	move.l	#copperlist1,a1
;	move.l	#lbW001B92,a2
;	sub.l	a1,a2
;	add.l	a2,a0
;	add.l	#2,a0

;	move.w	#$FFFF,d0
;lbC000152:
;	move.w	d0,$DFF180
;	dbra	d0,lbC000152

;	move.w	#15,d0
;lbC000160:
;	move.w	d0,(a0)

;	move.w	#$4000,d1
;lbC000166:
;	dbra	d1,lbC000166
;	sub.w	#1,d0
;	cmp.w	#0,d0
;	bne	lbC000160

;Re-formats the logo from 2 to 3 bitplanes and from 80 bytes per line to 84
;for display
	move.l	#phr_logo,a0
	move.l	#screenbuf+90*BYTES_PER_LINE,a1	;$70D88
	moveq	#39,d2
	moveq	#BYTES_PER_LINE,d3
lbC000186:
	moveq	#1,d1
lbC00018A:
	moveq	#19,d0
lbC00018E:
	move.l	(a0)+,(a1)+
	dbra	d0,lbC00018E
	addq.l	#4,a1			;skip invisible area
	dbra	d1,lbC00018A
	add.l	d3,a1			;skip 3rd bitplane
	dbra	d2,lbC000186

;	move.l	#$74898,a0		;$74898
	move.l	#screenbuf+90*BYTES_PER_LINE*3,a0
	move.l	#text1,a1
	bsr	BlitText

;	move.l	#$74898,a0
;	add.l	#$13B0,a0		;$75C48
	move.l	#screenbuf+110*BYTES_PER_LINE*3,a0
	move.l	#text2,a1
	bsr	BlitText

;	move.l	#$74898,a0
;	add.l	#$2760,a0		;$76FF8
	move.l	#screenbuf+130*BYTES_PER_LINE*3,a0
	move.l	#text3,a1
	bsr	BlitText

	moveq	#55,d0
	lea	lbW00061A,a0
	move.l	lbL000298,a1
	addq.l	#6,a1
lbC0001FC:
	move.w	(a0)+,(a1)
	add.l	#8,a1
	dbra	d0,lbC0001FC

	jsr	mus_init

mainloop:
	cmp.b	#$FF,$DFF006
	bne	mainloop

	jsr	mus_play
	bsr	update_screen

	btst	#6,$BFE001
	bne	mainloop

;	move.w	#15,$DFF096
;	move.w	#$80,$DFF096
;	move.l	4,a6
;	move.l	#GfxName,a1
;	jsr	_LVOOldOpenLibrary(a6)
;	move.l	d0,a4
;	move.l	gb_copinit(a4),$DFF080
;	clr.w	$DFF088
;	move.w	#$8080,$DFF096
;	move.w	#$8020,$DFF096
;	move.l	4,a6
;	move.l	d0,a1
;	jsr	_LVOCloseLibrary(a6)
;	movem.w	(sp)+,d0-d7/a0-a6
;	move.w	#$2000,sr
;	rte
	rts

;GfxName:
;	dc.b	"graphics.library",0
;	even

lbL000298:	dc.l	0
cop_addr_logo:	dc.l	0
lbL0002A0:	dc.l	0

update_screen:
;MTN: Unnecessary movem
;	movem.w	d0-d7/a0-a6,-(sp)	;.w ???
	move.w	sine_offset,d0
	add.w	#2,d0
	cmp.w	#$200,d0
	ble	lbC0002BE
	move.w	#0,d0
lbC0002BE:
	move.w	d0,sine_offset

	lea	sinetab,a0
	move.l	#scrollbuf+2,a2
	move.w	#80,d2			;x blit offset
lbC0002D4:
	move.l	#screenbuf+170*BYTES_PER_LINE*3+2,a1	;$79758 = $6F000+$A758
	move.l	#scrollbuf+2,a2		;$6C000
	move.w	d2,d3
	ext.l	d3
	add.l	d3,a1
	add.l	d3,a2
	move.w	(a0,d0.w),d1
	asr.w	#3,d1			;div 8
	mulu	#3*BYTES_PER_LINE,d1
	ext.l	d1
	sub.l	d1,a1
	move.l	a1,lbL0006EC
	move.l	a2,lbL0006E8
	bsr	BlitCol
	add.w	#14,d0			;next sine step
	sub.w	#2,d2
	cmp.w	#-2,d2			;underrun of blit offset?
	bne	lbC0002D4

;Blit the two "bookends" on the left and right

	move.w	sine_offset,d0
	add.w	#$224,d0
	move.l	#screenbuf+170*BYTES_PER_LINE*3,a0	;$79758 = $6F000+$A758
	sub.l	#15*BYTES_PER_LINE,a0
	move.l	#sinetab,a1
	move.w	(a1,d0.w),d0
	asr.w	#3,d0
	mulu	#3*BYTES_PER_LINE,d0
	ext.l	d0
	sub.l	d0,a0
	move.l	a0,blitdest
	move.l	#fontdata,a0
;	sub.l	#4*FONT_BYTES_PER_LINE*3,a0		;1512, blank area for blit
	sub.l	#3*FONT_BYTES_PER_LINE*3,a0		;fix blanking on blit
	add.l	#12,a0					;Offset to "left" image in font
	move.l	a0,blitsrc
	clr.l	blitdestoffs
	bsr	blit_symbol

;	add.l	#3*FONT_BYTES_PER_LINE,a0		;378, fix blanking on blit
	add.l	#4,a0
	move.l	a0,blitsrc
	move.l	#76,blitdestoffs
	move.l	blitdest,a0
	add.l	#3*BYTES_PER_LINE,a0
	move.l	a0,blitdest
	bsr	blit_symbol

;Rotate the color table
	lea	lbW00061A,a0
	lea	lbW00061C,a1
	moveq	#64,d0
	move.w	lbW00061A,d1		;get first word
lbC0003B0:
	move.w	(a1)+,(a0)+
	dbra	d0,lbC0003B0
	move.w	d1,lbW00069C		;write to last word in table

;Copy colors to Copper list
	moveq	#40,d0
	lea	lbW00061A,a0
	move.l	cop_addr_logo,a1
	add.l	#6,a1
lbC0003D4:
	move.w	(a0)+,(a1)
	add.l	#12,a1
	dbra	d0,lbC0003D4

	moveq	#40,d0
	lea	lbW00061A,a0
	move.l	lbL0002A0,a1
	move.w	(a0),2(a1)
	move.w	4(a0),6(a1)
	move.w	(a0),$1E(a1)
	sub.l	#2,a1
lbC000406:
	move.w	(a0)+,(a1)
	sub.l	#12,a1
	dbra	d0,lbC000406

;Scroll the scroller and blit next character if necessary
	tst.w	scr_waitcnt
	beq	lbC000434
	move.w	scr_waitcnt,d0
	sub.w	#1,d0
	move.w	d0,scr_waitcnt
	cmp.w	#0,d0
	bne	scr_nonew
lbC000434:
	move.l	#fontdata,font_row_addr
	bsr	scr_blit
	sub.b	#1,lbB000DEA
	bne	scr_nonew
	bsr	blit2
	move.b	#4,lbB000DEA
lbC00045A:
	move.l	#scrolltext,a0
	add.l	scr_offset,a0
	clr.l	d0
	move.b	(a0),d0
	tst.b	d0
	bne	lbC00048E
	add.l	#1,a0
	move.b	(a0),d5
	ext.w	d5
	move.w	d5,scr_waitcnt
	add.l	#2,scr_offset
	bra	lbC00045A

lbC00048E:
	cmp.b	#$40,d0
	ble	lbC0004A8
	move.l	font_row_addr,d7
	add.l	#98*FONT_BYTES_PER_LINE-2,d7		;$303A
	move.l	d7,font_row_addr
lbC0004A8:
	sub.b	#$20,d0
	asl.w	#2,d0
	add.l	font_row_addr,d0
	move.l	d0,lbL001B3A
	addq.l	#1,scr_offset
	cmp.l	#scrolltext_end,a0
	blt	scr_nonew
	move.l	#0,scr_offset
scr_nonew:
;	movem.w	(sp)+,d0-d7/a0-a6
	rts

;	dc.w	0
;lbL0004DC:
;	dc.l	0

;MTN: Unused data
;	dc.w	0,0,0,$11,$11,$22
;	dc.w	$33,$55,$77,$99,$BB,$CC,$DD,$DD
;	dc.w	$EE,$0E,$DD,$DD,$CC,$BB,$99,$77
;	dc.w	$55,$33,$22,$11,$11,0,0

; Draws 20 characters of text at a1 from the font at the screen position in a0

BlitText:
	move.l	#0,d0
	clr.l	d1
charloop:
	clr.l	d1
	move.l	#fontdata,font_row_addr
	move.b	(a1,d0.l),d1
;MTN: Never read
;	move.l	d1,lbL000582
	cmp.b	#$40,d1				;character from second row?
	ble	firstrow
	move.l	font_row_addr,d7
	add.l	#98*FONT_BYTES_PER_LINE-2,d7	;org $303A
	move.l	d7,font_row_addr
firstrow:
	sub.b	#$20,d1
	asl.w	#2,d1
	add.l	font_row_addr,d1
	move.l	d1,blit4src
	move.l	a0,blit4dest
	bsr	blit4
	add.l	#4,a0
	addq.l	#1,d0
	cmp.l	#20,d0
	ble	charloop
	rts

;MTN: Never read
;lbL000582:	dc.l	0

blit4:
	move.l	blit4src,$DFF050
	move.l	blit4dest,$DFF054
	move.w	#$F8,$DFF064
	move.w	#$50,$DFF066
	move.w	#0,$DFF042
	move.l	#$FFFFFFFF,$DFF044
	move.w	#$9F0,$DFF040
	move.w	#$C02,$DFF058
	bsr	WaitBlit
	rts

blit4src:
	dc.l	0
blit4dest:
	dc.l	0
text1:
	dc.b	"      PRESENT       "
text2:
	dc.b	"   THE  SIN INTRO   "
text3:
	dc.b	"  MUSIX BY MARK II  "
;	dc.b	0,0,0,0
	even

lbW00061A:
	dc.w	$FD2
lbW00061C:
	dc.w	$DB0,$B90,$970,$750,$530,$55F,$77F,$99F
	dc.w	$BBF,$DDF,$FFF,$DBF,$CAF,$B9F,$A8F,$97F
	dc.w	$86F,$75F,$64F,$53F,$42F,$53F,$75F,$97F
	dc.w	$B9F,$DBF,$FDF,$FFF,$EEE,$DDD,$CCC,$BBB
	dc.w	$AAA,$999,$888,$777,$666,$555,$444,$854
	dc.w	$965,$A76,$B87,$C98,$DA9,$EBA,$FCB,$FDC
	dc.w	$BCF,$ABF,$9AF,$89F,$78F,$67F,$56F,$45F
	dc.w	$642,$753,$864,$975,$A86,$B97,$CA8,$DB9
lbW00069C:
	dc.w	$ECA

BlitCol:
	move.l	lbL0006E8,$DFF050
	move.l	lbL0006EC,$DFF054
	move.w	#$52,$DFF064
	move.w	#$52,$DFF066
	clr.w	$DFF042
	move.w	#$FFFF,$DFF044
	move.w	#$9F0,$DFF040
	move.w	#$18C1,$DFF058
	bsr	WaitBlit
	rts

sine_offset:
	dc.w	0
lbL0006E8:
	dc.l	0
lbL0006EC:
	dc.l	0

sinetab:
	dc.w	0,2,5,7,10,12,15,$12
	dc.w	$14,$17,$19,$1C,$1E,$21,$23,$26
	dc.w	$28,$2A,$2D,$2F,$31,$34,$36,$38
	dc.w	$3A,$3C,$3E,$41,$43,$45,$46,$48
	dc.w	$4A,$4C,$4E,$4F,$51,$53,$54,$56
	dc.w	$57,$59,$5A,$5B,$5D,$5E,$5F,$60
	dc.w	$61,$62,$63,$64,$64,$65,$66,$66
	dc.w	$67,$67,$68,$68,$68,$68,$68,$68
	dc.w	$68,$68,$68,$68,$68,$68,$67,$67
	dc.w	$66,$66,$65,$64,$64,$63,$62,$61
	dc.w	$60,$5F,$5E,$5D,$5B,$5A,$59,$57
	dc.w	$56,$54,$53,$51,$4F,$4E,$4C,$4A
	dc.w	$48,$46,$45,$43,$41,$3E,$3C,$3A
	dc.w	$38,$36,$34,$31,$2F,$2D,$2A,$28
	dc.w	$26,$23,$21,$1E,$1C,$19,$17,$14
	dc.w	$12,15,12,10,8,6,4,2
	dc.w	0,$FFFE,$FFFB,$FFF9,$FFF6,$FFF4,$FFF1,$FFEE
	dc.w	$FFEC,$FFE9,$FFE7,$FFE4,$FFE2,$FFDF,$FFDD,$FFDA
	dc.w	$FFD8,$FFD6,$FFD3,$FFD1,$FFCF,$FFCC,$FFCA,$FFC8
	dc.w	$FFC6,$FFC4,$FFC2,$FFBF,$FFBD,$FFBB,$FFBA,$FFB8
	dc.w	$FFB6,$FFB4,$FFB2,$FFB1,$FFAF,$FFAD,$FFAC,$FFAA
	dc.w	$FFA9,$FFA7,$FFA6,$FFA5,$FFA3,$FFA2,$FFA1,$FFA0
	dc.w	$FF9F,$FF9E,$FF9D,$FF9C,$FF9C,$FF9B,$FF9A,$FF9A
	dc.w	$FF99,$FF99,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98
	dc.w	$FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF99,$FF99
	dc.w	$FF9A,$FF9A,$FF9B,$FF9C,$FF9C,$FF9D,$FF9E,$FF9F
	dc.w	$FFA0,$FFA1,$FFA2,$FFA3,$FFA5,$FFA6,$FFA7,$FFA9
	dc.w	$FFAA,$FFAC,$FFAD,$FFAF,$FFB1,$FFB2,$FFB4,$FFB6
	dc.w	$FFB8,$FFBA,$FFBB,$FFBD,$FFBF,$FFC2,$FFC4,$FFC6
	dc.w	$FFC8,$FFCA,$FFCC,$FFCF,$FFD1,$FFD3,$FFD6,$FFD8
	dc.w	$FFDA,$FFDD,$FFDF,$FFE2,$FFE4,$FFE7,$FFE9,$FFEC
	dc.w	$FFEE,$FFF1,$FFF4,$FFF6,$FFF8,$FFFA,$FFFC,$FFFE
	dc.w	0,2,5,7,10,12,15,$12
	dc.w	$14,$17,$19,$1C,$1E,$21,$23,$26
	dc.w	$28,$2A,$2D,$2F,$31,$34,$36,$38
	dc.w	$3A,$3C,$3E,$41,$43,$45,$46,$48
	dc.w	$4A,$4C,$4E,$4F,$51,$53,$54,$56
	dc.w	$57,$59,$5A,$5B,$5D,$5E,$5F,$60
	dc.w	$61,$62,$63,$64,$64,$65,$66,$66
	dc.w	$67,$67,$68,$68,$68,$68,$68,$68
	dc.w	$68,$68,$68,$68,$68,$68,$67,$67
	dc.w	$66,$66,$65,$64,$64,$63,$62,$61
	dc.w	$60,$5F,$5E,$5D,$5B,$5A,$59,$57
	dc.w	$56,$54,$53,$51,$4F,$4E,$4C,$4A
	dc.w	$48,$46,$45,$43,$41,$3E,$3C,$3A
	dc.w	$38,$36,$34,$31,$2F,$2D,$2A,$28
	dc.w	$26,$23,$21,$1E,$1C,$19,$17,$14
	dc.w	$12,15,12,10,8,6,4,2
	dc.w	0,$FFFE,$FFFB,$FFF9,$FFF6,$FFF4,$FFF1,$FFEE
	dc.w	$FFEC,$FFE9,$FFE7,$FFE4,$FFE2,$FFDF,$FFDD,$FFDA
	dc.w	$FFD8,$FFD6,$FFD3,$FFD1,$FFCF,$FFCC,$FFCA,$FFC8
	dc.w	$FFC6,$FFC4,$FFC2,$FFBF,$FFBD,$FFBB,$FFBA,$FFB8
	dc.w	$FFB6,$FFB4,$FFB2,$FFB1,$FFAF,$FFAD,$FFAC,$FFAA
	dc.w	$FFA9,$FFA7,$FFA6,$FFA5,$FFA3,$FFA2,$FFA1,$FFA0
	dc.w	$FF9F,$FF9E,$FF9D,$FF9C,$FF9C,$FF9B,$FF9A,$FF9A
	dc.w	$FF99,$FF99,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98
	dc.w	$FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF99,$FF99
	dc.w	$FF9A,$FF9A,$FF9B,$FF9C,$FF9C,$FF9D,$FF9E,$FF9F
	dc.w	$FFA0,$FFA1,$FFA2,$FFA3,$FFA5,$FFA6,$FFA7,$FFA9
	dc.w	$FFAA,$FFAC,$FFAD,$FFAF,$FFB1,$FFB2,$FFB4,$FFB6
	dc.w	$FFB8,$FFBA,$FFBB,$FFBD,$FFBF,$FFC2,$FFC4,$FFC6
	dc.w	$FFC8,$FFCA,$FFCC,$FFCF,$FFD1,$FFD3,$FFD6,$FFD8
	dc.w	$FFDA,$FFDD,$FFDF,$FFE2,$FFE4,$FFE7,$FFE9,$FFEC
	dc.w	$FFEE,$FFF1,$FFF4,$FFF6,$FFF8,$FFFA,$FFFC,$FFFE
	dc.w	0,2,5,7,10,12,15,$12
	dc.w	$14,$17,$19,$1C,$1E,$21,$23,$26
	dc.w	$28,$2A,$2D,$2F,$31,$34,$36,$38
	dc.w	$3A,$3C,$3E,$41,$43,$45,$46,$48
	dc.w	$4A,$4C,$4E,$4F,$51,$53,$54,$56
	dc.w	$57,$59,$5A,$5B,$5D,$5E,$5F,$60
	dc.w	$61,$62,$63,$64,$64,$65,$66,$66
	dc.w	$67,$67,$68,$68,$68,$68,$68,$68
	dc.w	$68,$68,$68,$68,$68,$68,$67,$67
	dc.w	$66,$66,$65,$64,$64,$63,$62,$61
	dc.w	$60,$5F,$5E,$5D,$5B,$5A,$59,$57
	dc.w	$56,$54,$53,$51,$4F,$4E,$4C,$4A
	dc.w	$48,$46,$45,$43,$41,$3E,$3C,$3A
	dc.w	$38,$36,$34,$31,$2F,$2D,$2A,$28
	dc.w	$26,$23,$21,$1E,$1C,$19,$17,$14
	dc.w	$12,15,12,10,8,6,4,2
	dc.w	0,$FFFE,$FFFB,$FFF9,$FFF6,$FFF4,$FFF1,$FFEE
	dc.w	$FFEC,$FFE9,$FFE7,$FFE4,$FFE2,$FFDF,$FFDD,$FFDA
	dc.w	$FFD8,$FFD6,$FFD3,$FFD1,$FFCF,$FFCC,$FFCA,$FFC8
	dc.w	$FFC6,$FFC4,$FFC2,$FFBF,$FFBD,$FFBB,$FFBA,$FFB8
	dc.w	$FFB6,$FFB4,$FFB2,$FFB1,$FFAF,$FFAD,$FFAC,$FFAA
	dc.w	$FFA9,$FFA7,$FFA6,$FFA5,$FFA3,$FFA2,$FFA1,$FFA0
	dc.w	$FF9F,$FF9E,$FF9D,$FF9C,$FF9C,$FF9B,$FF9A,$FF9A
	dc.w	$FF99,$FF99,$FF98,$FF98,$FF98,$FF98,$FF98,$FF98
	dc.w	$FF98,$FF98,$FF98,$FF98,$FF98,$FF98,$FF99,$FF99
	dc.w	$FF9A,$FF9A,$FF9B,$FF9C,$FF9C,$FF9D,$FF9E,$FF9F
	dc.w	$FFA0,$FFA1,$FFA2,$FFA3,$FFA5,$FFA6,$FFA7,$FFA9
	dc.w	$FFAA,$FFAC,$FFAD,$FFAF,$FFB1,$FFB2,$FFB4,$FFB6
	dc.w	$FFB8,$FFBA,$FFBB,$FFBD,$FFBF,$FFC2,$FFC4,$FFC6
	dc.w	$FFC8,$FFCA,$FFCC,$FFCF,$FFD1,$FFD3,$FFD6,$FFD8
	dc.w	$FFDA,$FFDD,$FFDF,$FFE2,$FFE4,$FFE7,$FFE9,$FFEC
	dc.w	$FFEE,$FFF1,$FFF4,$FFF6,$FFF8,$FFFA,$FFFC,$FFFE

;Shift the scroller in the work bitplane
scr_blit:
	move.l	#scrollbuf+2,$DFF050
	move.l	#scrollbuf,$DFF054
	move.w	#0,$DFF064
	move.w	#0,$DFF066
	move.w	#0,$DFF042
	move.l	#$FFFFFFFF,$DFF044
	move.w	#$89F0,$DFF040
	move.w	#99<<6+40,$DFF058		;$18E8 99 lines, 80 bytes wide
	bsr	WaitBlit
	rts

blit2:
	move.l	lbL001B3A,$DFF050
	move.l	#scrollbuf+82,$DFF054		;Blit to right side of buffer
	move.w	#FONT_BYTES_PER_LINE-4,$DFF064
	move.w	#BYTES_PER_LINE-4,$DFF066
	move.w	#0,$DFF042
	move.l	#$FFFFFFFF,$DFF044
	move.w	#$9F0,$DFF040
	move.w	#99<<6+2,$DFF058		;$18C2 99 lines, 4 bytes wide
	bsr.s	WaitBlit
	rts

;	rts

blit_symbol:
	move.l	blitsrc,$DFF050
	move.l	blitdest,d1
	add.l	blitdestoffs,d1
	move.l	d1,$DFF054
	move.w	#FONT_BYTES_PER_LINE-4,$DFF064	;skip 122 bytes
	move.w	#BYTES_PER_LINE-4,$DFF066	;skip 80 bytes
	move.w	#0,$DFF042
	move.l	#$7FFFFFFF,$DFF044
	move.w	#$9F0,$DFF040
	move.w	#111<<6+2,$DFF058		;$1BC2 111 lines, 4 bytes wide
	bsr.s	WaitBlit
	rts

WaitBlit:
	btst	#6,$DFF002
	bne	WaitBlit
	rts

blitdestoffs:	dc.l	0
blitsrc:	dc.l	0
blitdest:	dc.l	0
lbB000DEA:	dc.b	8
	even
scr_offset:	dc.l	0

; Zero byte is a pause flag. The following value is the number of frames
; that the scroller will pause.

scrolltext:
	dc.b	"............................................"
	dc.b	"...........................PHR-CREW......."
	dc.b	0,78,0,78,0,78,0,78,0,78,0,78
	dc.b	"   PRESENT THEIR LATEST GREAT INTRO..."
	dc.b	"GRAPHIX, IDEA AND PERFOMANCE BY"
	dc.b	"      HAEGAR        "
	dc.b	0,64,0,64
	dc.b	"SOUND BY      MARK II       "
	dc.b	0,64,0,64
	dc.b	" AND THE BORING TEXT A FEW SECONDS LATER IS"
	dc.b	" FROM      !  P H R  !     "
	dc.b	0,78,0,78
	dc.b	"THE MANAGER OF THIS LITTLE CREW !       ALL"
	dc.b	" MEMBERS OF THE PHR-CREW ... IN ALPHABETICAL"
	dc.b	" ORDER   ...         HAEGAR    KOLAPSE    MR"
	dc.b	". SPACE    PHR    ZAXXON         NOW SOME WO"
	dc.b	"RDS OF WISDOM BY MARK II.... AND NOW... HERE"
	dc.b	" I COME!!... THE GREAT  MARK II ! MEMBER OF "
	dc.b	"QUADLITE. HAVE YOU READ THE MESSAGE OF THE G"
	dc.b	"REAT STAR FRONTIERS ! IN THE GAME ARKANOID ("
	dc.b	" ALWAYS REMBER...  HEHEHEHE.. ) DON""T YOU A"
	dc.b	"LSO THINK THAT THE SIN-SCROLLING IS QUITE NI"
	dc.b	"CE !!        THANX TO MARK II FOR HIS COMPLI"
	dc.b	"MENT...THE NEXT 2 HOURS OF THIS SCROLLTEXT B"
	dc.b	"ELONG TO PHR AND THE  GREETINGS..    HI HERE"
	dc.b	"""S PHR !! OK. LETS GREET SOME PEOPLE IN ALPH"
	dc.b	"ABETICAL ORDER...                      ALPHA"
	dc.b	" FLIGHT ( DOCTOR MABUSE AND SHUT BERLIN )   "
	dc.b	"AMIGA INDUSTRIES   AXXESS   BAD MOOD MEIKL  "
	dc.b	" BCA   BFBS   BITKILLERSOFT   BLIZZARDS   CR"
	dc.b	"USADER   DAMOCLES   DEFJAM   FAIRLIGHT   GUR"
	dc.b	"U MASTER   HAGAR   HEAVY BITS   HELLOWEEN ( "
	dc.b	"SKAR )   HIGH QUALITY CRACKINGS   ITD   MARI"
	dc.b	"ON B.   MEDITATION STOPPERS    MEGAFORCE    "
	dc.b	" POWERSLAVES     "
	dc.b	0,64,0,64
	dc.b	"PROPHETS AG   QUADLITE  ( ESPECIALLY      THE KNECHT !     "
	dc.b	0,46
	dc.b	" )   RISKY BUSINESS BOYS   ROM   SEVEN UP CREW   "
	dc.b	"SKYLINE   STAR FRONTIERS   TCG   TGM-CREW   TLC   TSK   "
	dc.b	"THE PROFESSIONALS   THE SYNDICATE   THE UNTOUCHABLES   "
	dc.b	"THE VISITER OF ACA   THE VISITORS   THE WAR FALCONS   "
	dc.b	"THE WIZZARDS  ( HELLO SNOOPY )   TNM CREW   "
	dc.b	"TRISTAR  ( OGM )   TSCHEKKO   VISION   WCS   "
	dc.b	"WEST COAST CRACKERS    "
	dc.b	"LAST AND LEAST SUPER HYPER STINKNORMAL GREETINGS TO        "
	dc.b	"......   CRACKMAN CREW  (     RUEPEL-ROGER     "
	dc.b	0,46
	dc.b	"AND     CLI-WIZZARD      "
	dc.b	0,46
	dc.b	"  ZEUS ! )                     PHR WANT TO "
	dc.b	"GREET   SUSI   WITH SPECIAL GREETINGS !!!!  "
	dc.b	"  ( MY CAT ! )     HAEGAR  GREETS HIS CAT .."
	dc.b	"  PEPSI  !    FUCKINGS TO  KAUSLER  ( MY ENG"
	dc.b	"LISH TEACHER ! )        MARK II   GREETS   C"
	dc.b	"OCA COLA    AND    BAHLSEN          HI MSD !"
	dc.b	"       "
	dc.b	0,20
	dc.b	"   FUCK OFF HEIMANN !!   (  MY  PHYSIX  TEAC"
	dc.b	"HER !  )          HI !          A REAL MAN W"
	dc.b	"ORKS AND LIVES ONLY FOR AMIGA !!    ME TOO !"
	dc.b	"!  TOMORROW I HAVE TO WRITE A PHYSIC TEST ! "
	dc.b	"BUT I SAID IN VIEW TO BE ABLE TO WRITE THE S"
	dc.b	"CROLL OF THIS FAMOUSE INTRO  ..... LUERK ! ."
	dc.b	"...      BUT NOW ..........................."
	dc.b	"..               THE END       FUCK MOUSEBUT"
	dc.b	"TON TO CONTINUE        ..... AND NOBODY NEED"
	dc.b	"S AN INTERRUPT       ICH MACH JETZT ZU .... "
	dc.b	"              ALSO ALLE KNECHTE MAUS PRUEGEL"
	dc.b	"N      ODER DIE MUSIK ZU ENDE HOEHREN  ( I M"
	dc.b	"AKE NOW CLOSE    SO YOU ALL KNIGHTS HAVE TO "
	dc.b	"HAMMER YOUR MOUSE OR TO LISTEN TO THE GREAT "
	dc.b	"MUSIC UNTIL IT STARTS FROM THE BEGINNING.)  "
	dc.b	"    SPAGETTI ALA MAJONESI CAUNTI ..... WO BL"
	dc.b	"EIBT DIE PIZZA !! AND NOW SOME GERMAN SLANG "
	dc.b	"...   HOB BOU   MACHS FENSTER ZOU           "
	dc.b	"CLOSE WINDOW !! .....................    AND"
	dc.b	" NOW THE SOURCE OF THIS INTRO .............."
	dc.b	".......     RUN NOFASTMEM      SHOW PIC     "
	dc.b	" SCROLL TUBE      FLACKER SCHRIFT      SCROL"
	dc.b	"L SCROLL      VERBIEG SCROLL      KNECHT PRO"
	dc.b	"ZESSOR      QUAEL COPPER      STREICHEL DENI"
	dc.b	"SE      FUCK PAULA      AUCH AGNAL      AEHH"
	dc.b	"H      AGNUS      MALTRETIERE RAMS      SCHU"
	dc.b	"ER FEUER ( LED )      PLAY THE 900 MB OF THE"
	dc.b	" DIGITIZED SOUND FROM THE 64 !      HACK TAS"
	dc.b	"TATUR      SCRATCH AND BREAK ON DISK       A"
	dc.b	"LLES ROGER, ROGER!!!.. .. . ...   ... ..  .."
	dc.b	" ... . .. .. . ... .. . .. ... .. ..     NA "
	dc.b	"KAPIERT...DIE GEMORSTE NACHRICHT!!!!........"
	dc.b	"......................."
scrolltext_end:
	dc.b	"."
	even

font_row_addr:	dc.l	0
lbL001B3A:	dc.l	fontdata
;		dc.l	0
scr_waitcnt:	dc.w	0

copperlist1:
	dc.w	$101,$FFFE
	dc.w	$8E,$2C89		;DIWSTRT VSTART=44/HSTART=137
	dc.w	$90,$50D9		;DIWSTOP VSTOP=336/HSTOP=437
	dc.w	$92,$3C			;60
	dc.w	$94,$D4			;212
	dc.w	$108,2*BYTES_PER_LINE+4	;BPL1MOD: skip 172 Bytes
	dc.w	$96,$20			;DMACON: Disable SPREN
	dc.w	$96,$8800		;DMACON: Enable ???
	dc.w	$10A,2*BYTES_PER_LINE+4	;BPL2MOD: skip 172 Bytes
	dc.w	$102,0			;BPLCON1
cop_bplptr	equ *+2
	dc.w	$E0,0			;Bitplane 0 at $6F000
	dc.w	$E2,0
	dc.w	$E4,0			;Bitplane 1 at $6F054
	dc.w	$E6,0
	dc.w	$E8,0			;Bitplane 2 at $6F0A8
	dc.w	$EA,0
lbW001B92:
	dc.w	$180,0
	dc.w	$182,$F00
	dc.w	$184,$F00
	dc.w	$186,0
	dc.w	$188,$CCC
	dc.w	$18A,$999
	dc.w	$18C,$777
	dc.w	$18E,$444
	dc.w	$100,$B200		;BPLCON0: HIRES,3BPL,COLOR
cop_logo:
	ds.w	246
lbW001DA2:
	dc.w	$182,$FFF
	dc.w	$188,15
;lbW001DAA:
	dc.w	$102,0			;BPLCON1
	dc.w	$C007,$FFFE
	dc.w	$102,0			;BPLCON1
	dc.w	$186,0
	dc.w	$188,$CCC
	dc.w	$182,$FFF
cop_scroller:
	ds.w	224
	dc.w	$FFFF,$FFFE
copperlist_end:
copsize	equ	*-copperlist1

;
; MUSIC PLAYER BY MARK II (Darius Zendeh)
;

mus_init:
	movem.l	(mus_registers),d0-d7/a0-a6
	jsr	mus_doinit
	rts

mus_play:
	movem.l	(mus_registers),d0-d7/a0-a6
	bsr	mus_doplay
	rts

;D7 contains an alternating 1/0 flag.
;On 1, the Paula registers are set
;On 0, the audio channels contained in d5 are disabled in DMACON
;The player is called every frame (PAL=50).
;This means the song steps are played at 25 frames per second.

mus_doplay:
	cmp.w	#0,d7
	beq	lbC0160FE
	move.w	#0,d7
	bra	lbC016112

lbC0160FE:
	move.w	#1,d7
	move.w	d5,$DFF096
lbC016108:
	movem.l	d0-d7/a0-a6,mus_registers
	rts

lbC016112:
	add.w	#8,a0			;next step in pattern
	move.w	(a0),d2
	sub.w	#$10,a1
	cmp.w	#$FFFF,d2		;pattern end?
	bne	lbC016148

	move.l	#mus_pattdata,a0
	add.w	#$10,a1
	move.w	(a1),d2
	cmp.w	#$FFFF,d2		;end song?
	beq	mus_doinit
	bra	lbC016148

mus_doinit:
	move.l	#mus_songdata,a1
	move.l	#mus_pattdata,a0
lbC016148:
	move.w	#3,d6
	move.w	#0,d5			;DMACON value
	move.w	#1,d4			;DMACON channel bit
	move.l	#$DFF0A0,a3
mus_chloop:
	move.w	(a1),d2			;pattern number
	move.w	2(a1),d3		;note offset
	mulu	#$102,d2		;pattern size plus the $FFFF flag
	move.w	d2,d0
	add.w	d0,a0
	move.w	(a0),d2			;instrument number
	mulu	#8,d2
	move.l	#mus_instr_table,a2
	add.w	d2,a2

	move.l	(a2),(a3)		;AUDxLC sample addr
	add.w	#6,a2
	add.w	#4,a3
	move.w	(a2),(a3)		;AUDxLEN sample length (words)
	add.w	#2,a3

	move.w	2(a0),d2		;note index
	add.w	d3,d2			;add note offset
	mulu	#2,d2
	move.l	#mus_period,a2
	add.w	d2,a2
	move.w	(a2),(a3)		;AUDxPER period
	add.w	#2,a3
	move.w	4(a0),(a3)		;AUDxVOL volume
	add.w	#8,a3			;advance to next audio base
	add.w	#4,a1
	move.w	6(a0),d2		;Channel enable flag
	sub.w	d0,a0
	cmp.w	#0,d2
	bne	mus_voiceon
	add.w	d4,d5
mus_voiceon:
	mulu	#2,d4
	dbra	d6,mus_chloop

	move.w	#$820F,$DFF096		;Enable all audio channels
	move.l	#$DFF0A0,a3
	bra	lbC016108

;Stores contents of D0-D7,A0-A6
mus_registers:	ds.l	15

; Sample addr and length
mus_instr_table:
	dc.l	mus_instr1,$64
	dc.l	mus_instr2,$266
	dc.l	mus_instr3,$5C3
	dc.l	mus_instr4,$6C2
	dc.l	mus_instr5,$2A7
	dc.l	mus_instr6,$A1A
	dc.l	mus_instr7,$1260

mus_period:
	dc.w	$3F8,$3C0,$38A,$358,$328,$2FA,$2D0,$2A6
	dc.w	$280,$25C,$23A,$21A,$1FC,$1E0,$1C5,$1AC
	dc.w	$194,$17D,$168,$153,$140,$12E,$11D,$10D
	dc.w	$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA
	dc.w	$A0,$97,$8F,$87,$6B

;
; "JOURNEY THROUGH GALAXY"
; by MARK II
;

;Defines the steps in the song.
;Each line holds 4 pattern numbers for the 4 Paula channels with their
;transpose value that gets added to the note index from the pattern.
;Song ends at $FFFF

mus_songdata:
	dc.w	8,0,0,0,0,0,0,0
	dc.w	9,0,0,0,0,0,0,0
	dc.w	10,0,0,0,0,0,0,0
	dc.w	11,0,0,0,0,0,0,0
	dc.w	8,0,0,0,0,0,0,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	7,0,0,0,3,0,0,0
	dc.w	8,0,4,0,2,0,12,0
	dc.w	9,0,4,0,0,0,5,0
	dc.w	10,0,4,0,12,0,2,0
	dc.w	11,0,4,0,5,0,0,0
	dc.w	8,0,4,0,2,0,12,0
	dc.w	9,0,4,0,0,0,5,0
	dc.w	10,0,4,0,12,0,2,0
	dc.w	11,0,4,0,1,0,0,0
	dc.w	8,0,4,0,5,12,0,0
	dc.w	9,0,4,0,5,5,0,0
	dc.w	10,0,4,0,5,7,0,0
	dc.w	11,0,4,0,5,0,0,0
	dc.w	8,0,4,0,2,0,12,0
	dc.w	9,0,4,0,0,0,5,0
	dc.w	10,0,4,0,$11,12,5,0
	dc.w	11,0,4,0,$12,12,1,0
	dc.w	8,0,4,0,$11,12,5,12
	dc.w	9,0,4,0,$12,12,5,5
	dc.w	10,0,4,0,$11,12,5,7
	dc.w	11,0,4,0,$12,12,5,0
	dc.w	8,0,4,0,5,0,$11,12
	dc.w	9,0,4,0,1,0,$12,12
	dc.w	10,0,4,0,5,12,$11,12
	dc.w	11,0,4,0,5,5,$12,12
	dc.w	8,0,4,0,5,7,$11,12
	dc.w	9,0,4,0,5,0,$12,12
	dc.w	10,0,4,0,2,0,12,0
	dc.w	11,0,4,0,0,0,5,0
	dc.w	8,0,4,0,12,0,2,0
	dc.w	9,0,4,0,1,0,6,0
	dc.w	10,0,4,0,5,12,0,0
	dc.w	11,0,4,0,5,5,7,0
	dc.w	8,0,4,0,5,7,0,0
	dc.w	9,0,4,0,5,0,6,0
	dc.w	10,0,4,0,2,0,12,0
	dc.w	11,0,4,0,6,0,5,0
	dc.w	8,0,4,0,7,0,5,0
	dc.w	9,0,4,0,6,0,5,0
	dc.w	10,0,4,0,$11,12,5,0
	dc.w	11,0,4,0,$12,12,1,0
	dc.w	8,0,4,0,$11,12,5,12
	dc.w	9,0,4,0,$12,12,5,5
	dc.w	10,0,4,0,13,0,5,7
	dc.w	11,0,4,0,14,0,5,0
	dc.w	8,0,4,0,15,0,5,0
	dc.w	9,0,4,0,$10,0,5,0
	dc.w	10,0,4,0,13,0,5,0
	dc.w	11,0,4,0,14,0,1,0
	dc.w	8,0,4,0,15,0,5,12
	dc.w	9,0,4,0,$10,0,5,5
	dc.w	10,0,4,0,13,0,5,7
	dc.w	11,0,4,0,14,0,5,0
	dc.w	8,0,4,0,15,0,5,0
	dc.w	9,0,4,0,$10,0,5,0
	dc.w	10,0,4,0,0,0,2,0
	dc.w	11,0,0,0,0,0,0,0
	dc.w	8,0,4,0,0,0,0,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	8,0,0,0,10,0,0,0
	dc.w	9,0,6,0,0,11,0,0
	dc.w	10,0,8,0,0,0,6,0
	dc.w	11,0,9,0,0,0,0,0
	dc.w	8,0,10,0,0,0,0,0
	dc.w	9,0,11,0,7,0,0,0
	dc.w	10,0,8,0,0,0,0,0
	dc.w	11,0,9,0,0,0,0,0
	dc.w	8,0,6,0,0,0,10,0
	dc.w	9,0,11,0,0,0,0,0
	dc.w	10,0,4,0,0,0,0,0
	dc.w	11,0,0,0,0,0,0,0
	dc.w	8,0,4,0,0,0,0,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	8,0,10,0,12,0,7,0
	dc.w	9,0,6,0,1,0,11,0
	dc.w	10,0,4,0,5,12,0,0
	dc.w	11,0,4,0,5,5,0,0
	dc.w	8,0,4,0,5,7,0,0
	dc.w	9,0,4,0,5,0,0,0
	dc.w	10,0,4,0,2,0,12,0
	dc.w	11,0,4,0,0,0,5,0
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,0,12,0,2,0
	dc.w	9,0,4,0,1,0,6,0
	dc.w	10,0,4,0,5,12,0,0
	dc.w	11,0,4,0,5,5,1,0
	dc.w	8,0,4,0,$11,12,5,12
	dc.w	9,0,4,0,$12,12,5,7
	dc.w	10,0,4,0,$11,12,5,7
	dc.w	11,0,4,0,$12,12,5,0
	dc.w	10,0,4,3,13,3,5,3
	dc.w	11,0,4,8,14,8,5,8
	dc.w	8,0,4,7,15,7,5,7
	dc.w	9,0,4,5,$10,5,5,5
	dc.w	10,0,4,0,13,0,5,0
	dc.w	11,0,4,0,14,0,1,0
	dc.w	8,0,4,0,15,0,5,12
	dc.w	9,0,4,0,$10,0,5,5
	dc.w	10,0,4,3,13,3,5,3
	dc.w	11,0,4,8,14,8,5,8
	dc.w	8,0,4,7,15,7,5,7
	dc.w	9,0,4,5,$10,5,5,5
	dc.w	10,0,4,0,13,0,5,0
	dc.w	11,0,4,0,14,0,1,0
	dc.w	8,0,4,0,15,0,5,12
	dc.w	9,0,4,0,$10,0,5,5
	dc.w	10,0,4,0,12,0,2,0
	dc.w	11,0,4,0,5,0,6,0
	dc.w	8,0,0,0,2,0,12,0
	dc.w	9,0,4,0,0,0,5,0
	dc.w	10,0,4,0,$11,12,5,0
	dc.w	11,0,4,0,$12,12,1,0
	dc.w	8,0,4,0,$11,12,5,12
	dc.w	9,0,4,0,$12,12,5,5
	dc.w	10,0,4,0,0,0,2,0
	dc.w	11,0,0,0,0,0,0,0
	dc.w	8,0,4,0,0,0,0,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	7,0,0,0,3,0,0,0
	dc.w	8,0,0,0,5,0,0,0
	dc.w	9,0,0,0,1,0,0,0
	dc.w	10,0,4,0,5,12,0,0
	dc.w	11,0,4,0,5,5,0,0
	dc.w	8,0,4,0,5,7,0,0
	dc.w	9,0,4,0,5,0,0,0
	dc.w	10,0,4,0,2,0,12,0
	dc.w	11,0,4,0,0,0,5,0
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,7,$17,0,5,7
	dc.w	9,0,4,8,$18,0,5,8
	dc.w	10,0,4,7,$17,0,5,7
	dc.w	11,0,4,8,$18,0,5,8
	dc.w	8,0,4,0,$15,12,5,0
	dc.w	9,0,4,0,$16,12,5,0
	dc.w	10,0,4,0,$15,12,5,0
	dc.w	11,0,4,0,$16,12,5,0
	dc.w	8,0,4,7,$19,0,5,7
	dc.w	9,0,4,8,$1A,0,5,8
	dc.w	10,0,4,7,$19,0,5,7
	dc.w	11,0,4,8,$1A,0,5,8
	dc.w	8,0,4,0,$11,12,5,0
	dc.w	9,0,4,0,$12,12,1,0
	dc.w	10,0,4,0,$11,12,5,12
	dc.w	11,0,4,0,$12,12,5,5
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,0,$13,0,5,12
	dc.w	9,0,4,0,$14,0,5,5
	dc.w	10,0,4,0,$13,0,5,7
	dc.w	11,0,4,0,$14,0,5,0
	dc.w	8,0,4,0,$15,0,5,0
	dc.w	9,0,4,0,$16,0,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,7,$17,0,5,7
	dc.w	9,0,4,8,$18,0,5,8
	dc.w	10,0,4,7,$17,0,5,7
	dc.w	11,0,4,8,$18,0,5,8
	dc.w	8,0,4,0,$15,12,5,0
	dc.w	9,0,4,0,$16,12,5,0
	dc.w	10,0,4,0,$15,12,5,0
	dc.w	11,0,4,0,$16,12,5,0
	dc.w	8,0,4,7,$19,0,5,7
	dc.w	9,0,4,8,$1A,0,5,8
	dc.w	10,0,4,7,$19,0,5,7
	dc.w	11,0,4,8,$1A,0,5,8
	dc.w	8,0,4,0,$15,12,5,0
	dc.w	9,0,4,0,$16,12,5,0
	dc.w	10,0,4,0,$15,0,5,0
	dc.w	11,0,4,0,$16,0,5,0
	dc.w	8,0,4,0,$11,12,5,0
	dc.w	9,0,4,0,$12,12,5,0
	dc.w	10,0,4,0,$11,12,5,0
	dc.w	11,0,4,0,$12,12,5,0
	dc.w	8,0,4,7,$17,0,5,7
	dc.w	9,0,4,8,$18,0,5,8
	dc.w	10,0,4,7,$17,0,5,7
	dc.w	11,0,4,8,$18,0,5,8
	dc.w	8,0,4,0,0,0,2,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	10,0,4,0,0,0,0,0
	dc.w	11,0,0,0,0,0,0,0
	dc.w	8,0,4,0,0,0,0,0
	dc.w	6,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	7,0,0,0,0,0,0,0
	dc.w	8,0,0,0,10,0,0,0
	dc.w	9,0,6,0,0,11,0,0
	dc.w	10,0,8,0,0,0,6,0
	dc.w	11,0,9,0,0,0,0,0
	dc.w	8,0,10,0,0,0,0,0
	dc.w	9,0,11,0,7,0,0,0
	dc.w	10,0,8,0,0,0,0,0
	dc.w	11,0,9,0,0,0,0,0
	dc.w	8,0,6,0,0,0,10,0
	dc.w	9,0,11,0,0,0,0,0
	dc.w	10,0,12,0,6,0,0,0
	dc.w	11,0,5,0,7,0,12,0
	dc.w	8,0,1,0,10,0,5,0
	dc.w	9,0,5,12,11,0,1,0
	dc.w	10,0,5,12,7,0,5,12
	dc.w	11,0,5,7,9,0,5,12
	dc.w	8,0,5,5,10,0,5,12
	dc.w	9,0,5,0,11,0,5,12
	dc.w	10,0,2,0,7,0,5,12
	dc.w	11,0,6,0,9,0,5,5
	dc.w	8,0,7,0,10,0,5,7
	dc.w	9,0,6,0,11,0,1,0
	dc.w	10,0,$11,12,7,0,5,12
	dc.w	11,0,$12,12,9,0,5,5
	dc.w	8,0,$11,12,6,0,5,7
	dc.w	9,0,$12,12,11,0,2,0
	dc.w	$FFFF

;Defines the patterns

;The patterns have 8 steps with each line having 4 entries for the 4 Paula channels:
;+00 WORD Instrument index
;+02 WORD Note index
;+04 WORD Volume
;+06 WORD Channel enable (>0)
;Pattern ends with $FFFF

mus_pattdata:
;Pattern 0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	$FFFF

;Pattern 1
	dc.w	5,15,$36,1,5,15,$36,1,5,$10,$36,1,5,$10,$36,1
	dc.w	5,$10,$36,1,5,$11,$36,1,5,$11,$36,1,5,$11,$36,1
	dc.w	5,$12,$36,1,5,$12,$36,1,5,$12,$36,1,5,$13,$36,1
	dc.w	5,$13,$36,1,5,$13,$36,1,5,$14,$36,1,5,$14,$36,1
	dc.w	5,$14,$36,1,5,$15,$36,1,5,$15,$36,1,5,$15,$36,1
	dc.w	5,$16,$36,1,5,$16,$36,1,5,$16,$36,1,5,$17,$36,1
	dc.w	5,$17,$36,1,5,$17,$36,1,5,$18,$36,1,5,$18,$36,1
	dc.w	5,$19,$36,1,5,$19,$36,1,5,$1A,$36,1,5,$1A,$36,1
	dc.w	$FFFF

;Pattern 2
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$34,1,5,15,$32,1,5,15,$30,1,5,15,$2E,1
	dc.w	5,15,$2C,1,5,15,$2A,1,5,15,$28,1,5,15,$26,1
	dc.w	5,15,$24,1,5,15,$22,1,5,15,$20,1,5,15,$1E,1
	dc.w	5,15,$1C,1,5,15,$1A,1,5,15,$18,1,5,15,$16,1
	dc.w	5,15,$14,1,5,15,$12,1,5,15,$10,1,5,15,14,1
	dc.w	5,15,12,1,5,15,10,1,5,15,8,1,5,15,6,1
	dc.w	5,15,4,1,5,15,2,1,5,15,0,1,5,15,0,1
	dc.w	$FFFF

;Pattern 3
	dc.w	5,3,0,1,5,3,2,1,5,4,4,1,5,4,6,1
	dc.w	5,5,8,1,5,5,10,1,5,6,12,1,5,6,14,1
	dc.w	5,7,$10,1,5,7,$12,1,5,8,$14,1,5,8,$16,1
	dc.w	5,9,$18,1,5,9,$1A,1,5,10,$1C,1,5,10,$1E,1
	dc.w	5,11,$20,1,5,11,$22,1,5,12,$24,1,5,12,$26,1
	dc.w	5,13,$28,1,5,13,$2A,1,5,14,$2C,1,5,14,$2E,1
	dc.w	5,15,$30,1,5,15,$32,1,5,15,$34,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	$FFFF

;Pattern 4
	dc.w	3,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	3,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	3,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	3,12,$2C,1,0,13,$2C,1,0,14,$2C,1,0,15,$2C,0
	dc.w	3,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	3,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	3,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,14,$2C,0
	dc.w	3,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$2C,0
	dc.w	$FFFF

;Pattern 5
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	$FFFF

;Pattern 6
	dc.w	2,$1B,4,1,0,$1B,4,0,2,$1B,8,1,0,$1B,8,0
	dc.w	2,$1B,12,1,0,$1B,12,0,2,$1B,$10,1,0,$1B,$10,0
	dc.w	2,$1B,$14,1,0,$1B,$14,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	2,$1B,$18,1,0,$1B,$18,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	2,$1B,$18,1,0,$1B,$18,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	2,$1B,$18,1,0,$1B,$18,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	2,$1B,$18,1,0,$1B,$18,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	2,$1B,$18,1,0,$1B,$18,0,2,$1B,$18,1,0,$1B,$18,0
	dc.w	$FFFF

;Pattern 7
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,1
	dc.w	0,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	$FFFF

;Pattern 8
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	6,$1B,14,1,0,$1B,14,0,0,$1B,$2C,0,0,$1B,$2C,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	$FFFF

;Pattern 9
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,$1B,4,1,0,$1B,4,0,2,$1B,14,1,0,$1B,$18,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	6,$1B,14,1,0,$1B,14,1,0,$1B,14,1,0,$1B,14,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	$FFFF

;Pattern 10
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	6,$1B,14,1,0,$1B,14,0,0,$1B,$2C,0,0,$1B,$2C,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	$FFFF

;Pattern 11
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	2,15,$40,1,0,15,$40,1,0,15,$40,1,0,15,$40,0
	dc.w	6,$1B,14,1,0,$1B,14,1,0,$1B,14,1,0,$1B,14,0
	dc.w	1,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,1,0,$1B,$2C,0
	dc.w	1,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,1,0,$1B,$40,0
	dc.w	$FFFF

;Pattern 12
	dc.w	5,15,0,1,5,15,2,1,5,15,4,1,5,15,6,1
	dc.w	5,15,8,1,5,15,10,1,5,15,12,1,5,15,14,1
	dc.w	5,15,$10,1,5,15,$12,1,5,15,$14,1,5,15,$16,1
	dc.w	5,15,$18,1,5,15,$1A,1,5,15,$1C,1,5,15,$1E,1
	dc.w	5,15,$20,1,5,15,$22,1,5,15,$24,1,5,15,$26,1
	dc.w	5,15,$28,1,5,15,$2A,1,5,15,$2C,1,5,15,$2E,1
	dc.w	5,15,$30,1,5,15,$32,1,5,15,$34,1,5,15,$36,1
	dc.w	5,15,$36,1,5,15,$36,1,5,15,$36,1,5,15,$36,1
	dc.w	$FFFF

;Pattern 13
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,9,$2C,1,0,10,$2C,1,0,11,$2C,1,0,12,$2C,1
	dc.w	0,13,$2C,1,0,14,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,1
	dc.w	0,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,13,$2C,1,0,14,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	$FFFF

;Pattern 14
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,1
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,13,$2C,1,0,14,$2C,1,0,15,$2C,1,0,15,$2C,1
	dc.w	0,$11,$2C,1,0,$10,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,12,$2C,1,0,13,$2C,1,0,14,$2C,1,0,15,$2C,1
	dc.w	0,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$2C,0
	dc.w	$FFFF

;Pattern 15
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,1
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,15,$2C,1,0,$11,$2C,1,0,15,$2C,1,0,$11,$2C,1
	dc.w	0,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$2C,0
	dc.w	$FFFF

;Pattern 16
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,1
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$2C,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$2C,0
	dc.w	4,$16,$2C,1,0,$16,$2C,1,0,$16,$2C,1,0,$16,$2C,0
	dc.w	4,6,$2C,1,0,7,$2C,1,0,8,$2C,1,0,8,$2C,0
	dc.w	4,15,$2C,1,0,14,$2C,1,0,13,$2C,1,0,13,$2C,0
	dc.w	4,$14,$2C,1,0,$14,$2C,1,0,$14,$2C,1,0,$14,$2C,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$2C,0
	dc.w	$FFFF

;Pattern 17
	dc.w	5,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	5,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	5,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	5,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	5,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	5,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	5,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	5,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	$FFFF

;Pattern 18
	dc.w	5,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	5,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	5,13,$2C,1,0,14,$2C,1,0,15,$2C,1,0,15,$26,1
	dc.w	0,15,$2C,1,0,15,$2C,0,0,15,$2C,1,0,15,$26,0
	dc.w	5,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	5,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	5,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	5,5,$2C,1,0,5,$2C,1,0,5,$2C,1,0,5,$26,0
	dc.w	$FFFF

;Pattern 19
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	$FFFF

;Pattern 20
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	$FFFF

;Pattern 21
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	$FFFF

;Pattern 22
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	$FFFF

;Pattern 23
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	$FFFF

;Pattern 24
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	$FFFF

;Pattern 25
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,8,$2C,1,0,8,$2C,1,0,8,$2C,1,0,8,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	$FFFF

;Pattern 26
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,10,$2C,1,0,10,$2C,1,0,10,$2C,1,0,10,$26,0
	dc.w	4,13,$2C,1,0,13,$2C,1,0,13,$2C,1,0,13,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,15,$2C,1,0,15,$2C,1,0,15,$2C,1,0,15,$26,0
	dc.w	0,3,$2C,1,0,3,$2C,1,0,3,$2C,1,0,3,$26,0
	dc.w	4,9,$2C,1,4,8,$2C,1,4,7,$2C,1,4,6,$26,1
	dc.w	4,5,$2C,1,4,4,$2C,1,4,3,$2C,1,4,3,$26,0
	dc.w	$FFFF

	section	chipdata,data_c

mus_instr1:	incbin	"data/instr1.raw"
mus_instr4:	incbin	"data/instr4.raw"
mus_instr3:	INCBIN	"data/instr3.raw"
mus_instr2:	INCBIN	"data/instr2.raw"
mus_instr5:	INCBIN	"data/instr5.raw"
mus_instr6:	INCBIN	"data/instr6.raw"
mus_instr7:	INCBIN	"data/instr7.raw"

phr_logo:	INCBIN	"data/phrlogo.raw"

; Blank area before and after the font
; This is used in blits to clear the area above and below characters when
; they move up and down

		ds.b	4*FONT_BYTES_PER_LINE*3
fontdata:	INCBIN	"data/font.raw"
		ds.b	11*FONT_BYTES_PER_LINE*3

;bitplane buffer???

	section chipbss,bss_c

copperlist2:	ds.b	copsize

; org $6C000
scrollbuf:	ds.b	111*BYTES_PER_LINE*3+2

; org $6F000
screenbuf:	ds.b	292*BYTES_PER_LINE*3

BSS_SIZE	equ	*-copperlist2
