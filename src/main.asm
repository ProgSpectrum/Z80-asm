; ZX Spectrum 48K - Hello World
; Build: build.bat  |  Run: run.bat

	DEVICE	ZXSPECTRUM48
	ORG	#8000

start:
	ld	a, 2          ; screen channel
	call	#1601         ; CHAN_OPEN (ROM)
	ld	hl, message
print_loop:
	ld	a, (hl)
	and	a
	jr	z, print_done
	rst	#10           ; ROM: print character in A
	inc	hl
	jr	print_loop
print_done:
	jr	print_done    ; stay here

message:
	DEFM	"Hello, Spectrum 48K!", 0

code_length	=	$-start

	INCLUDE	"lib/TapLib.asm"
	MakeTape ZXSPECTRUM48, "bin/program.tap", "program", start, code_length, start
