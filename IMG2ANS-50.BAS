''
' TODO: Add Command Line processing support for multiple files. 
' IMG2ANS-50
'
' Convert any QB64 supported image into ANSI block art
' (as long as the image is using EGA palette colors)
'
' This version saves as a IBM VGA50 8px Font lossless.
'
' @author Rick Christy (grymmjack@gmail.com)
' @link https://youtube.com/grymmjack
' @version 0.1
'

'$INCLUDE:'../SAUCE/SAUCE.BI'

DIM AS LONG CANVAS, SRC_IMAGE
DIM AS INTEGER SRC_W, SRC_H, x, y, z
DIM AS STRING SRC_FILE, ans
DIM AS _UNSIGNED LONG c
CONST E = 27  ' ESCAPE - The ANSI escape code
CONST B = 219 ' BLOCK CHARACTER - Full block foreground

' Maps RGB32 _UNSIGNED LONG colors (from POINT(x,y)) to ANSI Escape Color Codes
TYPE ANSI_MAP
    RGBC AS _UNSIGNED LONG
    CODE AS STRING
END TYPE
DIM ANSI_MAP(15) AS ANSI_MAP
' BLACK
ANSI_MAP(0).CODE$  = CHR$(E)+"[0;30m" : ANSI_MAP(0).RGBC~&  = &HFF000000
' BLUE
ANSI_MAP(1).CODE$  = CHR$(E)+"[0;34m" : ANSI_MAP(1).RGBC~&  = &HFF0000AA
' GREEN
ANSI_MAP(2).CODE$  = CHR$(E)+"[0;32m" : ANSI_MAP(2).RGBC~&  = &HFF00AA00
' CYAN
ANSI_MAP(3).CODE$  = CHR$(E)+"[0;36m" : ANSI_MAP(3).RGBC~&  = &HFF00AAAA
' RED
ANSI_MAP(4).CODE$  = CHR$(E)+"[0;31m" : ANSI_MAP(4).RGBC~&  = &HFFAA0000
' PURPLE
ANSI_MAP(5).CODE$  = CHR$(E)+"[0;35m" : ANSI_MAP(5).RGBC~&  = &HFFAA00AA
' BROWN
ANSI_MAP(6).CODE$  = CHR$(E)+"[0;33m" : ANSI_MAP(6).RGBC~&  = &HFFAA5500
' WHITE
ANSI_MAP(7).CODE$  = CHR$(E)+"[0;37m" : ANSI_MAP(7).RGBC~&  = &HFFAAAAAA
' BRIGHT BLACK
ANSI_MAP(8).CODE$  = CHR$(E)+"[1;30m" : ANSI_MAP(8).RGBC~&  = &HFF555555
' BRIGHT BLUE
ANSI_MAP(9).CODE$  = CHR$(E)+"[1;34m" : ANSI_MAP(9).RGBC~&  = &HFF5555FF
' BRIGHT GREEN
ANSI_MAP(10).CODE$ = CHR$(E)+"[1;32m" : ANSI_MAP(10).RGBC~& = &HFF55FF55
' BRIGHT CYAN
ANSI_MAP(11).CODE$ = CHR$(E)+"[1;36m" : ANSI_MAP(11).RGBC~& = &HFF55FFFF
' BRIGHT RED
ANSI_MAP(12).CODE$ = CHR$(E)+"[1;31m" : ANSI_MAP(12).RGBC~& = &HFFFF5555
' BRIGHT PURPLE
ANSI_MAP(13).CODE$ = CHR$(E)+"[1;35m" : ANSI_MAP(13).RGBC~& = &HFFFF55FF
' BRIGHT YELLOW
ANSI_MAP(14).CODE$ = CHR$(E)+"[1;33m" : ANSI_MAP(14).RGBC~& = &HFFFFFF55
' BRIGHT WHITE
ANSI_MAP(15).CODE$ = CHR$(E)+"[1;37m" : ANSI_MAP(15).RGBC~& = &HFFFFFFFF

' Choose an image file with dialog
SRC_FILE$ = _OPENFILEDIALOG$( _
    "Choose an image", _
    , _
    "*.jpg|*.jpeg|*.png|*.tga|*.bmp|*.psd|*.gif|*.pcx|*.svg|*.qoi", _
    "Image Files", _
    -1 _
)
IF SRC_FILE$ = "" THEN SYSTEM ' image is required...

SRC_FILE$ = SRC_FILE$ + "|"

DIM AS INTEGER i, l, ch
DIM AS STRING filename
l% = LEN(SRC_FILE$)

FOR i%=0 TO l%
    IF i%+1 <= l% THEN ' At end of file list, do nothing
        ch% = ASC(SRC_FILE$, i%+1)
        IF CHR$(ch%) = "|" THEN ' File found
            ' Load the image into the canvas at the same size
            SRC_IMAGE& = _LOADIMAGE(filename$, 32) 
            SRC_W% = _WIDTH(SRC_IMAGE&) : SRC_H% = _HEIGHT(SRC_IMAGE&)
            CANVAS& = _NEWIMAGE(SRC_W%, SRC_H%, 32)
            SCREEN CANVAS&
            _SOURCE SRC_IMAGE& : _DEST CANVAS& : _PUTIMAGE

            ' Parse the image into ansi color blocks
            ans$ = ""
            FOR y% = 0 TO SRC_H% - 1
                ans$ = ans$ + CHR$(E) + "[0m" ' reset on each line
                FOR x% = 0 TO SRC_W% - 1
                    c~& = POINT(x%, y%)
                    FOR z% = 0 TO UBOUND(ANSI_MAP)
                        IF c~& = ANSI_MAP(z%).RGBC~& THEN
                            ans$ = ans$ + ANSI_MAP(z%).CODE$ + CHR$(B)
                            EXIT FOR
                        END IF            
                    NEXT z%
                NEXT x%
                ans$ = ans$ + CHR$(E) + "[0m" ' reset on each line

            NEXT y%

            SCREEN 0
            CLS

            ' Write the output.ans file
            PRINT ans$
            OPEN filename$ + "-50.ans" FOR OUTPUT AS #1
            PRINT #1, ans$
            CLOSE #1

            OPEN filename$ + "-50.ans" FOR APPEND AS #1
            PRINT #1, CHR$(&H1A) ' EOF
            CLOSE #1 

            OPEN filename$ + "-50.ans" FOR BINARY AS #1
            SEEK #1, LOF(1)
            SAUCE.InitPacket
            SauceRecord.ID$         = "SAUCE"
            SauceRecord.Version$    = "00"
            DIM slash AS STRING
            slash$ = "/" : IF _OS$ = "WINDOWS" THEN slash$ = "\"            
            s$ = MID$(filename$, _INSTRREV(filename$, slash$) + 1)
            MID$(SauceRecord.Title$, 1, LEN(s$)) = s$
            s$ = "grymmjack"
            MID$(SauceRecord.Author$, 1, LEN(s$)) = s$
            s$ = "MiSTiGRiS"
            MID$(SauceRecord.Group$, 1, LEN(s$)) = s$
            s$ = "20231231"
            MID$(SauceRecord.Date$, 1, LEN(s$)) = s$
            SauceRecord.FileSize~&  = LOF(1)-1
            SauceRecord.DataType~%% = 1
            SauceRecord.FileType~%% = 1
            SauceRecord.TInfo1~%    = SRC_W%
            SauceRecord.TInfo2~%    = SRC_H%
            SauceRecord.TInfo3~%    = 0
            SauceRecord.TInfo4~%    = 0
            SauceRecord.Comments~%% = 0
            SauceRecord.TFlags~%%   = 3 '8px iCE Color
            s$ = "IBM VGA50"
            MID$(SauceRecord.TInfoS$, 1, LEN(s$)) = s$
            SAUCE.FillPacket
            PUT #1, LOF(1)-1, SauceRecord
            CLOSE #1

            filename$ = ""
        ELSE ' Not at end of filename yet concat...
            filename$ = filename$ + CHR$(ch%)
        END IF
    END IF
NEXT i%

' Clean up
_FREEIMAGE SRC_IMAGE&
_FREEIMAGE CANVAS&

'$INCLUDE:'../SAUCE/SAUCE.BM'
