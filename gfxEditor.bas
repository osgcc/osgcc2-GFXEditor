DECLARE SUB RightClick ()
DECLARE SUB LeftClick ()
DECLARE SUB DrawHud ()
DECLARE SUB InitColorInfo ()
DECLARE SUB InitScreenInfo ()
DECLARE SUB InitSpecificObjects ()
DECLARE SUB mouse (Funk AS INTEGER)
DECLARE SUB SetPalette1 ()
DECLARE SUB UpdatePaletteGradient (pal() AS LONG, colour AS ANY)
DECLARE FUNCTION getGridX! ()
DECLARE FUNCTION getGridY! ()
DECLARE SUB NewImage ()
DECLARE SUB SaveImage ()
DECLARE SUB ImageInfo ()
DECLARE SUB LoadImage ()

'Version: 08.410
'Programmer: Sour Swinger
'Web Site: blog.sourswinger.name
'Contact: soursw@gmail.com
'Donations appreciated.  Please contact if interested.

'*******************************************************************************
'------------------------------------TYPES--------------------------------------
'*******************************************************************************

'=================================DESCRIPTIVE===================================
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

TYPE ScreenInfoType
	height AS INTEGER
	with AS INTEGER
	mode AS INTEGER
END TYPE

TYPE SizeType
	height AS INTEGER
	with AS INTEGER
	x AS INTEGER
	y AS INTEGER
END TYPE

'==================================BASE OBJECTS=================================
TYPE PanelType
	col AS INTEGER
	col2 AS INTEGER
	size AS SizeType
END TYPE

'===============================SPECIFIC OBJECTS================================



'*******************************************************************************
'-----------------------------------GLOBALS-------------------------------------
'*******************************************************************************
COMMON SHARED mseButton AS INTEGER
COMMON SHARED mseXLoc AS INTEGER
COMMON SHARED mseYLoc AS INTEGER

DIM SHARED colour AS ColorType
DIM SHARED file AS STRING
DIM SHARED flip AS INTEGER
REDIM SHARED image(129) AS INTEGER
DIM SHARED imageHeight AS INTEGER
DIM SHARED imageWith AS INTEGER
DIM SHARED pal(0 TO 255) AS LONG
DIM SHARED pCol AS INTEGER
DIM SHARED pnlColor AS PanelType
DIM SHARED pnlPaint AS PanelType
DIM SHARED pnlThumb AS PanelType
DIM SHARED screenInfo AS ScreenInfoType
'*******************************************************************************
'-------------------------------MAIN VARIABLES----------------------------------
'*******************************************************************************
DIM fRS AS SINGLE       'Frame Rate Start
DIM fPS AS SINGLE       'Frames Per Second
DIM keyboard AS STRING

'*******************************************************************************
'---------------------------------INITIAL SETUP---------------------------------
'*******************************************************************************
CALL InitScreenInfo
flip = 0
imageWith = 16
imageHeight = 16
pCol = 1

SCREEN screenInfo.mode

CALL mouse(1)   'Show Mouse
CALL InitSpecificObjects
CALL SetPalette1

fRS = TIMER
fPS = 1 / 30    'Equates to 30 FPS

PALETTE USING pal
CALL DrawHud

'*******************************************************************************
'-----------------------------------MAIN LOOP-----------------------------------
'*******************************************************************************
DO
	CALL mouse(3)   'Read mouse
	IF (mseButton > 0) THEN
		CALL mouse(2)   'Hide mouse
		CALL mouse(3)   'Read mouse
		SELECT CASE mseButton
			CASE 1: 'Left button
				CALL LeftClick
			CASE 2: 'Right button
				CALL RightClick
			CASE 3: 'Both buttons
		END SELECT
	END IF
	CALL mouse(1)   'show mouse
	
	keyboard = INKEY$
	SELECT CASE keyboard
		CASE "-"
			pCol = pCol - 1
			IF pCol < 0 THEN pCol = 0
			
		CASE "="
			pCol = pCol + 1
			IF pCol > 254 THEN pCol = 254
		CASE "f"
			IF flip = 1 THEN
				flip = 0
			ELSE
				flip = 1
			END IF
		CASE "i"
			CALL ImageInfo
		CASE "l"
			CALL LoadImage
		CASE "n"
			CALL NewImage
		CASE "s"
			CALL SaveImage
	END SELECT
	 
	IF (TIMER - fRS > fPS) THEN     'Redraws needed screen elements
		CALL DrawHud
		CALL UpdatePaletteGradient(pal(), colour)

		fRS = TIMER
	END IF
LOOP UNTIL keyboard = CHR$(27)

END

'*******************************************************************************
'-----------------------------SUBROUTINES-FUNCTIONS-----------------------------
'*******************************************************************************
SUB DrawHud
	DIM col AS INTEGER
	DIM with AS INTEGER

	IF flip = 0 THEN
		col = 0
		FOR x = 0 TO 8
			FOR y = 0 TO 14
				LINE (pnlColor.size.x + (x * pnlColor.col), pnlColor.size.y + (y * pnlColor.col))-(pnlColor.size.x + (x * pnlColor.col) + pnlColor.col2, pnlColor.size.y + (y * pnlColor.col) + pnlColor.col2), col, BF
				col = col + 1
			NEXT y
		NEXT x
	ELSE
		col = 135
		FOR x = 1 TO 8
			FOR y = 0 TO 14
				LINE (pnlColor.size.x + (x * pnlColor.col), pnlColor.size.y + (y * pnlColor.col))-(pnlColor.size.x + (x * pnlColor.col) + pnlColor.col2, pnlColor.size.y + (y * pnlColor.col) + pnlColor.col2), col, BF
				col = col + 1
			NEXT y
		NEXT x
	END IF
			 
	FOR x = pnlPaint.size.x TO (pnlThumb.size.with - 1) * getGridX STEP getGridX
		FOR y = pnlPaint.size.y TO (pnlThumb.size.height - 1) * getGridY STEP getGridY
			LINE (x, y)-(x + getGridX, y + getGridY), pnlPaint.col, B
		NEXT y
	NEXT x
END SUB

FUNCTION getGridX
	IF (pnlColor.size.with > imageWith) THEN
		
		getGridX = (screenInfo.with \ (pnlColor.size.with))
	ELSE
		getGridX = (screenInfo.with \ (imageWith + 1) - 1)
	END IF
								 
END FUNCTION

FUNCTION getGridY
	getGridY = (screenInfo.height \ imageHeight)
END FUNCTION

SUB ImageInfo
	CLS
	PRINT "You selected Image Info"
	PRINT "File Name: "; file
	PRINT "Image Width: "; imageWith
	PRINT "Image Height: "; imageHeight
	PRINT
	PRINT "Press any key to continue..."
	SLEEP
	CLS
	CALL DrawHud
	with = image(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO image(1) - 1
			DEF SEG = VARSEG(image(0))
			col = PEEK(VARPTR(image(2)) + i + with * j)
			DEF SEG
			
			PAINT (pnlPaint.size.x + i * getGridX + getGridX \ 2, pnlPaint.size.y + j * getGridY + getGridY \ 2), col, pnlPaint.col
			PSET (pnlThumb.size.x + i, pnlThumb.size.y + j), col
		NEXT j
	NEXT i

END SUB

'-------------------------------------------------------------------------------
SUB InitScreenInfo
	screenInfo.mode = 13
	screenInfo.with = 320
	screenInfo.height = 200
END SUB

'-------------------------------------------------------------------------------
SUB InitSpecificObjects
	REDIM image(imageHeight * imageWith \ 2 + 1) AS INTEGER
	pnlColor.col = 5
	pnlColor.col2 = 3
	pnlColor.size.with = 9 * pnlColor.col
	pnlColor.size.height = 15 * pnlColor.col
	pnlColor.size.x = screenInfo.with - pnlColor.size.with
	pnlColor.size.y = screenInfo.height - pnlColor.size.height
	pnlThumb.size.with = imageWith
	pnlThumb.size.height = imageHeight
	pnlThumb.size.x = screenInfo.with - pnlThumb.size.with - 1
	pnlThumb.size.y = 0
	pnlPaint.col = 14
	pnlPaint.size.with = pnlThumb.size.with * getGridX
	pnlPaint.size.height = pnlThumb.size.height * getGridY
	pnlPaint.size.x = 0
	pnlPaint.size.y = 0
END SUB

SUB LeftClick
	DIM x AS INTEGER
	DIM y AS INTEGER

	IF (mseXLoc >= pnlThumb.size.x OR mseXLoc >= pnlColor.size.x) THEN
		IF NOT (POINT(mseXLoc, mseYLoc) = 0 OR POINT(mseXLoc, mseYLoc) = pnlPaint.col) THEN
			pCol = POINT(mseXLoc, mseYLoc)
		END IF
	ELSEIF (mseXLoc <= pnlPaint.size.with AND mseYLoc <= pnlPaint.size.height) THEN
		IF NOT POINT(mseXLoc, mseYLoc) = pnlPaint.col THEN
			PAINT (mseXLoc, mseYLoc), pCol, pnlPaint.col
			x = mseXLoc \ getGridX
			y = mseYLoc \ getGridY
			PSET (pnlThumb.size.x + x, pnlThumb.size.y + y), pCol
			GET (pnlThumb.size.x, pnlThumb.size.y)-(pnlThumb.size.x + pnlThumb.size.with - 1, pnlThumb.size.y + pnlThumb.size.height - 1), image
		END IF
	END IF
END SUB

SUB LoadImage
	DIM yn AS STRING
	DIM cont AS INTEGER
	DIM with AS INTEGER
	DIM i AS INTEGER
	DIM j AS INTEGER

	cont = 0
	CLS
	PRINT "YOU SELECTED LOAD IMAGE"
	PRINT
	DO
		PRINT "Save Existing Image";
		INPUT yn
		SELECT CASE yn
			CASE "y"
				CALL SaveImage
				cont = 0
			CASE "n"
				PRINT "Enter file name:";
				INPUT file
				cont = 0
			CASE "c"
				CLS
				EXIT SUB
			CASE ELSE
				PRINT "wrong input"
				cont = 1
		END SELECT
	LOOP WHILE cont = 1
			 
	CLS

	'First loaded for image width and height
	REDIM image(2) AS INTEGER
	DEF SEG = VARSEG(image(0))
	BLOAD file, 0
	DEF SEG
	imageWith = image(0) \ 8
	imageHeight = image(1)
	CALL InitSpecificObjects
	CALL DrawHud
			 
	'Reloaded to properly store image in correct sized array
	DEF SEG = VARSEG(image(0))
	BLOAD file, 0
	DEF SEG
	with = image(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO image(1) - 1
			DEF SEG = VARSEG(image(0))
			col = PEEK(VARPTR(image(2)) + i + with * j)
			DEF SEG
			
			PAINT (pnlPaint.size.x + i * getGridX + getGridX \ 2, pnlPaint.size.y + j * getGridY + getGridY \ 2), col, pnlPaint.col
			PSET (pnlThumb.size.x + i, pnlThumb.size.y + j), col
		NEXT j
	NEXT i
END SUB

'-------------------------------------------------------------------------------
SUB mouse (Funk AS INTEGER)
	POKE 100, 184: POKE 101, Funk: POKE 102, 0
	POKE 103, 205: POKE 104, 51: POKE 105, 137
	POKE 106, 30: POKE 107, 170: POKE 108, 10
	POKE 109, 137: POKE 110, 14: POKE 111, 187
	POKE 112, 11: POKE 113, 137: POKE 114, 22
	POKE 115, 204: POKE 116, 12: POKE 117, 203

	CALL Absolute(100)

	mseButton = PEEK(&HAAA)
	mseXLoc = (PEEK(&HBBB) + PEEK(&HBBC) * 256) \ 2
	mseYLoc = PEEK(&HCCC) + PEEK(&HCCD) * 256
END SUB

SUB NewImage
	DIM yn AS STRING
	DIM num AS INTEGER
	DIM cont AS INTEGER
	DIM temp AS INTEGER
	cont = 0
			 
	CLS
	PRINT "YOU SELECTED NEW IMAGE"
	PRINT
	DO
		PRINT "Save Existing Image";
		INPUT yn
		SELECT CASE yn
			CASE "y"
				CALL SaveImage
				cont = 0
			CASE "n"
				cont = 0
			CASE "c"
				CLS
				EXIT SUB
			CASE ELSE
				PRINT "wrong input"
				cont = 1
		END SELECT
	LOOP WHILE cont = 1
	DO
		PRINT "Width";
		INPUT num
		SELECT CASE num
			CASE IS > 72
				PRINT "Exceeds max limit of 72"
				cont = 1
			CASE -1
				CLS
				EXIT SUB
			CASE IS < 1
				PRINT "Exceeds min limit of 1"
				cont = 1
			CASE ELSE
				temp = imageWith
				imageWith = num
				cont = 0
		END SELECT
	LOOP WHILE cont = 1
	DO
		PRINT "Height";
		INPUT num
		SELECT CASE num
			CASE IS > 64
				PRINT "Exceeds max limit of 64"
				cont = 1
			CASE -1
				CLS
				imageWith = temp
				EXIT SUB
			CASE IS < 1
				PRINT "Exceeds min limit of 1"
				cont = 1
			CASE ELSE
				imageHeight = num
				cont = 0
		END SELECT
	LOOP WHILE cont = 1
	CLS
	CALL InitSpecificObjects
	CALL DrawHud
END SUB

SUB RightClick
	IF (mseXLoc <= pnlPaint.size.with + getGridX AND mseYLoc <= pnlPaint.size.height + getGridY) THEN
		IF NOT POINT(mseXLoc, mseYLoc) = pnlPaint.col THEN
			PAINT (mseXLoc, mseYLoc), 0, pnlPaint.col
			x = mseXLoc \ getGridX
			y = mseYLoc \ getGridY
			PSET (pnlThumb.size.x + x, pnlThumb.size.y + y), 0
		END IF
	END IF
END SUB

SUB SaveImage
	DIM yorn AS STRING
	
	CLS
	PRINT "YOU SELECTED SAVE IMAGE"
	PRINT
	IF file = "" THEN
		PRINT "File name";
		INPUT file
	END IF
			
	PRINT "Save as " + file
	INPUT yorn
	SELECT CASE yorn
		CASE "n"
			file = ""
			CALL SaveImage
		CASE "y"
			DEF SEG = VARSEG(image(0))
			BSAVE file, 0, (imageHeight * imageWith \ 2 + 2) * 2
			DEF SEG
		CASE "c"
			EXIT SUB
	END SELECT
	CLS
	CALL DrawHud
	with = image(0) \ 8
	FOR i = 0 TO with - 1
		FOR j = 0 TO image(1) - 1
			DEF SEG = VARSEG(image(0))
			col = PEEK(VARPTR(image(2)) + i + with * j)
			DEF SEG
			 
			PAINT (pnlPaint.size.x + i * getGridX + getGridX \ 2, pnlPaint.size.y + j * getGridY + getGridY \ 2), col, pnlPaint.col
			PSET (pnlThumb.size.x + i, pnlThumb.size.y + j), col
		NEXT j
	NEXT i
END SUB

'-------------------------------------------------------------------------------
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

SUB SetPalette2
	DIM index AS INTEGER
	DIM a AS INTEGER

	'pal() = red + (256 * green) + (65536 * blue)

	index = 0
	colour.custom = index
	pal(index) = 0
	index = index + 1
	pal(index) = 63 + (256 * 63) + (65536 * 63)
	index = index + 1
	index = 15
			 
	'GREYS - .5 red, .5 green, .5 blue
	colour.grey = index
	FOR a = 52 TO 4 STEP -8
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

SUB UpdatePaletteGradient (pal() AS LONG, colour AS ColorType)
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

