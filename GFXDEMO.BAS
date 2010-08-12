DECLARE SUB initStart ()
DECLARE SUB UpdatePaletteGradient ()
DECLARE SUB SetPalette1 ()
DECLARE SUB LoadGFX (file AS STRING, gFX() AS INTEGER)
DECLARE SUB ShowGFX ()
DECLARE SUB PutGFX (x AS INTEGER, y AS INTEGER, gFX() AS INTEGER)

'Version: 08.410
'Programmer: Sour Swinger
'Web Site: blog.sourswinger.name
'Contact: soursw@gmail.com
'Donations appreciated.  Please contact if interested.

TYPE ColorType
	custom AS INTEGER
	grey AS INTEGER
	red AS INTEGER
	orange AS INTEGER
	brown AS INTEGER
	yellow AS INTEGER
	chartruese AS INTEGER
	green AS INTEGER
	springGreen AS INTEGER
	cyan AS INTEGER
	azure AS INTEGER
	blue AS INTEGER
	purple AS INTEGER
	magenta AS INTEGER
	fuchsia AS INTEGER
	gradient AS INTEGER
	blink AS INTEGER
	reserved AS INTEGER
END TYPE

CONST c16x16 = 129      'Width * Height + 1


REDIM box1(c16x16) AS INTEGER
REDIM box2(c16x16) AS INTEGER
REDIM path1(c16x16) AS INTEGER
REDIM person1(c16x16) AS INTEGER

REDIM SHARED scr(32001) AS INTEGER

DIM SHARED colour AS ColorType
DIM SHARED pal(0 TO 255) AS LONG

DIM file
DIM fRS AS SINGLE
DIM fPS AS SINGLE
DIM keyboard AS STRING

SCREEN 13

CALL SetPalette1
CALL initStart

fRS = TIMER
fPS = 1 / 30

PALETTE USING pal

DO
	keyboard = INKEY$
	SELECT CASE keyboard
		CASE "l"
			CALL LoadGFX("box1.gfx", box1())
			CALL LoadGFX("box2.gfx", box2())
			CALL LoadGFX("stone1.gfx", path1())
			CALL LoadGFX("person1.gfx", person1())
		CASE "p"
			PutGFX 0, 0, box1()
			PutGFX 0, 16, box1()
			PutGFX 0, 32, box1()
			PutGFX 0, 48, box1()
			PutGFX 0, 64, box1()
			PutGFX 32, 0, box2()
			PutGFX 32, 16, box2()
			PutGFX 32, 32, box2()
			PutGFX 32, 48, box2()
			PutGFX 32, 64, box2()
			PutGFX 16, 0, path1()
			PutGFX 16, 16, path1()
			PutGFX 16, 32, path1()
			PutGFX 16, 48, path1()
			PutGFX 16, 64, path1()
			PutGFX 16, 32, person1()
	END SELECT

	IF (TIMER - fRS > fPS) THEN
		CALL UpdatePaletteGradient
		CALL ShowGFX

		fRS = TIMER
	END IF
LOOP UNTIL keyboard = CHR$(27)

SUB initStart
	scr(0) = 2560
	scr(1) = 200
END SUB

SUB LoadGFX (file AS STRING, gFX() AS INTEGER)
      
	DEF SEG = VARSEG(gFX(0))
	BLOAD file, 0
	DEF SEG

END SUB

SUB PutGFX (x AS INTEGER, y AS INTEGER, gFX() AS INTEGER)
	DIM col AS INTEGER
	DIM i AS INTEGER
	DIM j AS INTEGER
	DIM with AS INTEGER
	
	with = gFX(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO gFX(1) - 1
			DEF SEG = VARSEG(gFX(0))
			col = PEEK(VARPTR(gFX(2)) + i + with * j)
			DEF SEG
			IF NOT (col = 0) THEN
				IF ((x + i) < 320) AND ((y + j) < 200) THEN
					DEF SEG = VARSEG(scr(0))
					POKE VARPTR(scr(2)) + x + i + 320& * (y + j), col
					DEF SEG
				END IF
			END IF
		NEXT j
	NEXT i
END SUB

SUB SetPalette1
	DIM index AS INTEGER
	DIM a AS INTEGER

	'pal() = red + (256 * green) + (65536 * blue)

	index = 0
	colour.custom = index
	pal(index) = 0
	index = index + 1
	pal(index) = 63 + (256 * 63) + (65536 * 63)
	index = index + 1
	index = 14
	pal(index) = 63 + (256 * 63) + (65536 * 63)
	index = 15
	
	'GREYS - .5 red, .5 green, .5 blue
	colour.grey = index
	FOR a = 60 TO 4 STEP -4
		pal(index) = a + (256 * a) + (65536 * a)
		index = index + 1
	NEXT a

	'REDS - 1 red
	colour.red = index
	FOR a = 52 TO 4 STEP -8
	   pal(index) = 63 + (256 * a) + (65536 * a)
	   index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
	   pal(index) = a + (256 * 0) + (65536 * 0)
		index = index + 1
	NEXT a

	'ORANGES - 1 red, .5 green
	colour.orange = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * (a \ 2 + 31)) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * (a \ 2)) + (65536 * 0)
		index = index + 1
	NEXT a

	'BROWNS - .6 red, .3 green
	colour.brown = index
	pal(index) = 63 + (256 * 56) + (65536 * 49)
	index = index + 1
	pal(index) = 60 + (256 * 51) + (65536 * 42)
	index = index + 1
	pal(index) = 57 + (256 * 46) + (65536 * 35)
	index = index + 1
	pal(index) = 54 + (256 * 41) + (65536 * 28)
	index = index + 1
	pal(index) = 51 + (256 * 36) + (65536 * 21)
	index = index + 1
	pal(index) = 48 + (256 * 31) + (65536 * 14)
	index = index + 1
	pal(index) = 45 + (256 * 26) + (65536 * 7)
	index = index + 1
	pal(index) = 42 + (256 * 21) + (65536 * 0)
	index = index + 1
	pal(index) = 36 + (256 * 17) + (65536 * 0)
	index = index + 1
	pal(index) = 30 + (256 * 15) + (65536 * 0)
	index = index + 1
	pal(index) = 25 + (256 * 12) + (65536 * 0)
	index = index + 1
	pal(index) = 19 + (256 * 10) + (65536 * 0)
	index = index + 1
	pal(index) = 14 + (256 * 7) + (65536 * 0)
	index = index + 1
	pal(index) = 8 + (256 * 5) + (65536 * 0)
	index = index + 1
	pal(index) = 3 + (256 * 2) + (65536 * 0)
	index = index + 1


	'YELLOWS - 1 red, 1 green
	colour.yellow = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'CHARTRUESE - .5 red, 1 green
	colour.chartruese = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = ((a \ 2) + 31) + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = (a \ 2) + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'GREENS - 1 green
	colour.green = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * 63) + (65536 * a)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * 0)
		index = index + 1
	NEXT a

	'SPRING GREEN - 1 green, .5 blue
	colour.springGreen = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * 63) + (65536 * ((a \ 2) + 31))
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * (a \ 2))
		index = index + 1
	NEXT a

	'CYANS - 1 green, 1 blue
	colour.cyan = index
	FOR a = 52 TO 4 STEP -8
	       pal(index) = a + (256 * 63) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * a) + (65536 * a)
		index = index + 1
	NEXT a

	'AZURE - .5 green, 1 blue
	colour.azure = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * ((a \ 2) + 31)) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * (a \ 2)) + (65536 * a)
		index = index + 1
	NEXT a

	'BLUES - 1 blue
	colour.blue = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = a + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = 0 + (256 * 0) + (65536 * a)
		index = index + 1
	NEXT a

	'PURPLES - .5 red, 1 blue
	colour.purple = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = (a \ 2 + 31) + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = (a \ 2) + (0) + (65536 * a)
		index = index + 1
	NEXT a

	'MAGENTAS - 1 red, 1 blue
	colour.magenta = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * a) + (65536 * 63)
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * 0) + (65536 * a)
		index = index + 1
	NEXT a

	'FUCHSIA -> 1 red, .5 blue
	colour.fuchsia = index
	FOR a = 52 TO 4 STEP -8
		pal(index) = 63 + (256 * a) + (65536 * ((a \ 2) + 31))
		index = index + 1
	NEXT a
	FOR a = 60 TO 4 STEP -8
		pal(index) = a + (256 * 0) + (65536 * (a \ 2))
		index = index + 1
	NEXT a

	colour.gradient = index
	index = index + 15
	colour.blink = index
	index = index + 15
	colour.reserved = index

	'MOUSE COLOR
	index = 255
	pal(index) = 63 + (256 * 63) + (65536 * 63)
END SUB

SUB ShowGFX
	PUT (0, 0), scr, PSET
END SUB

SUB UpdatePaletteGradient
	STATIC switch AS INTEGER
	STATIC index AS INTEGER

	index = index + switch
	IF (index > 12) THEN
		switch = -1
	ELSEIF (index < 3) THEN
		switch = 1
	END IF

	PALETTE 2, pal(ABS(switch) + switch + 1)
	PALETTE 225, pal(colour.grey + index)
	PALETTE 226, pal(colour.red + index)
	PALETTE 227, pal(colour.orange + index)
	PALETTE 228, pal(colour.brown + index)
	PALETTE 229, pal(colour.chartruese + index)
	PALETTE 230, pal(colour.green + index)
	PALETTE 231, pal(colour.springGreen + index)
	PALETTE 232, pal(colour.cyan + index)
	PALETTE 233, pal(colour.azure + index)
	PALETTE 234, pal(colour.blue + index)
	PALETTE 235, pal(colour.purple + index)
	PALETTE 236, pal(colour.magenta + index)
	PALETTE 237, pal(colour.fuchsia + index)

	PALETTE 238, pal(index * 15 + 2)
	PALETTE 239, pal(index * 15 + 12)

	IF (switch = -1) THEN
		PALETTE 240, pal(colour.grey + 7)
		PALETTE 241, pal(colour.red + 7)
		PALETTE 242, pal(colour.orange + 7)
		PALETTE 243, pal(colour.brown + 7)
		PALETTE 244, pal(colour.chartruese + 7)
		PALETTE 245, pal(colour.green + 7)
		PALETTE 246, pal(colour.springGreen + 7)
		PALETTE 247, pal(colour.cyan + 7)
		PALETTE 248, pal(colour.azure + 7)
		PALETTE 249, pal(colour.blue + 7)
		PALETTE 250, pal(colour.purple + 7)
		PALETTE 251, pal(colour.magenta + 7)
		PALETTE 252, pal(colour.fuchsia + 7)
		PALETTE 253, pal(index * 15 + 2)
		PALETTE 254, pal(index * 15 + 12)
	ELSE
		PALETTE 240, pal(0)
		PALETTE 241, pal(0)
		PALETTE 242, pal(0)
		PALETTE 243, pal(0)
		PALETTE 244, pal(0)
		PALETTE 245, pal(0)
		PALETTE 246, pal(0)
		PALETTE 247, pal(0)
		PALETTE 248, pal(0)
		PALETTE 249, pal(0)
		PALETTE 250, pal(0)
		PALETTE 251, pal(0)
		PALETTE 252, pal(0)
		PALETTE 253, pal(0)
		PALETTE 254, pal(0)
	END IF
	SELECT CASE pCol
		CASE 254
			IF switch = -1 THEN
				PALETTE 255, pal(index * 15 + 12)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE 253
			IF switch = -1 THEN
				PALETTE 255, pal(index * 15 + 2)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE IS >= 240
			IF switch = -1 THEN
				PALETTE 255, pal((((pCol MOD 15) + 1) * 15) + 7)
			ELSE
				PALETTE 255, pal(1)
			END IF
		CASE 239
			PALETTE 255, pal(index * 15 + 2)
	       
		CASE 238
			PALETTE 255, pal(index * 15 + 12)
		CASE IS >= 225
			PALETTE 255, pal((((pCol MOD 15) + 1) * 15) + index)
		CASE 2
			IF switch = -1 THEN
				PALETTE 255, pal(1)
			ELSE
				PALETTE 255, pal(29)
			END IF
		CASE ELSE
			PALETTE 255, pal(pCol)
	END SELECT
END SUB

