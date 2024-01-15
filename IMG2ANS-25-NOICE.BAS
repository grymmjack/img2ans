''
' TODO: Add Command Line processing support for multiple files. 
' IMG2ANS-25-NOICE
'
' CLI OPTIONS (WIP)
'
'   img2ans input-file {options} 
'   input-file1, (input-file2, input-file3, ...)
'
'   --output-colors     rgb     Output RGB codes
'   --output-colors     cga     Output CGA palette
'   --output-height     25      Use 9px font and half blocks
'   --output-height     50      Use 8px font and full blocks only
'   --no-ice                    Do not output iCE colors (high intensity bg)
'   --no-sauce                  Do not include sauce record in output
'   --verbose                   Show commands and processing
'   --sauce-title               Title for sauce
'   --sauce-author              Author for sauce
'   --sauce-group               Group for sauce
'   --sauce-comments            Comments for sauce
'   --sauce-date                YYYYMMDD Date for sauce
'
' Convert any QB64 supported image into ANSI block art
' (as long as the image is using EGA palette colors)
'
' This version will remove iCE colors.
'
' @author Rick Christy (grymmjack@gmail.com)
' @link https://youtube.com/grymmjack
' @version 0.1
'

'$INCLUDE:'../SAUCE/SAUCE.BI'

DIM AS LONG CANVAS, SRC_IMAGE
DIM AS INTEGER SRC_W, SRC_H, x, y, z, fz, bz, xx, yy
DIM AS STRING SRC_FILE, ans
DIM AS _UNSIGNED LONG c
CONST E  = 27  ' ESCAPE - The ANSI escape code
CONST B  = 219 '█ BLOCK CHARACTER - Full block foreground
CONST FT = 223 '▀ HALF BLOCK Top FG Bottom BG
CONST FB = 220 '▄ HALF BLOCK Top BG Bottom FG 

' Maps RGB32 _UNSIGNED LONG colors (from POINT(x,y)) to ANSI Escape Color Codes
TYPE ANSI_MAP
    RGBC    AS _UNSIGNED LONG
    FG_CODE AS STRING
    BG_CODE AS STRING 
END TYPE
DIM A(15) AS ANSI_MAP
' BLACK
A(0).FG_CODE$  = "0;30" : A(0).RGBC~&  = &HFF000000 : A(0).BG_CODE$ = "40"
' BLUE
A(1).FG_CODE$  = "0;34" : A(1).RGBC~&  = &HFF0000AA : A(1).BG_CODE$ = "44"
' GREEN
A(2).FG_CODE$  = "0;32" : A(2).RGBC~&  = &HFF00AA00 : A(2).BG_CODE$ = "42"
' CYAN
A(3).FG_CODE$  = "0;36" : A(3).RGBC~&  = &HFF00AAAA : A(3).BG_CODE$ = "46"
' RED
A(4).FG_CODE$  = "0;31" : A(4).RGBC~&  = &HFFAA0000 : A(4).BG_CODE$ = "41"
' PURPLE
A(5).FG_CODE$  = "0;35" : A(5).RGBC~&  = &HFFAA00AA : A(5).BG_CODE$ = "45"
' BROWN
A(6).FG_CODE$  = "0;33" : A(6).RGBC~&  = &HFFAA5500 : A(6).BG_CODE$ = "43"
' WHITE
A(7).FG_CODE$  = "0;37" : A(7).RGBC~&  = &HFFAAAAAA : A(7).BG_CODE$ = "47"
' BRIGHT BLACK
A(8).FG_CODE$  = "1;30" : A(8).RGBC~&  = &HFF555555 : A(8).BG_CODE$ = "5;40"
' BRIGHT BLUE
A(9).FG_CODE$  = "1;34" : A(9).RGBC~&  = &HFF5555FF : A(9).BG_CODE$ = "5;44"
' BRIGHT GREEN
A(10).FG_CODE$ = "1;32" : A(10).RGBC~& = &HFF55FF55 : A(10).BG_CODE$ = "5;42"
' BRIGHT CYAN
A(11).FG_CODE$ = "1;36" : A(11).RGBC~& = &HFF55FFFF : A(11).BG_CODE$ = "5;46"
' BRIGHT RED
A(12).FG_CODE$ = "1;31" : A(12).RGBC~& = &HFFFF5555 : A(12).BG_CODE$ = "5;41"
' BRIGHT PURPLE
A(13).FG_CODE$ = "1;35" : A(13).RGBC~& = &HFFFF55FF : A(13).BG_CODE$ = "5;45"
' BRIGHT YELLOW
A(14).FG_CODE$ = "1;33" : A(14).RGBC~& = &HFFFFFF55 : A(14).BG_CODE$ = "5;43"
' BRIGHT WHITE
A(15).FG_CODE$ = "1;37" : A(15).RGBC~& = &HFFFFFFFF : A(15).BG_CODE$ = "5;47"

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
DIM AS _UNSIGNED LONG rv, gv, bv
DIM AS STRING filename, char
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
            _SOURCE SRC_IMAGE& : _DEST CANVAS&
            _PUTIMAGE

            ' Parse the image into ansi color blocks
            ans$ = ""
            FOR y% = 0 TO SRC_H%
                IF (y% = 0) OR (y% MOD 2 = 0) THEN ' do every other row
                    FOR x% = 0 TO SRC_W% - 1
                        char$ = CHR$(FT) ' default to top 1/2 block
                        DIM AS _UNSIGNED LONG TopColor, BottomColor
                        ' Extract colors
                        TopColor~&    = POINT(x%, y%) ' top pixel
                        IF y%+1 < SRC_H% THEN
                            BottomColor~& = POINT(x%, y%+1) ' pixel under
                        ELSE
                            BottomColor~& = _RGB32(0, 0, 0)
                            TopColor~& = _RGB32(0, 0, 0)
                        END IF
                        DIM AS STRING FG_CODE, BG_CODE
                        ' Set defaults in case not found
                        FG_CODE$ = A(0).FG_CODE$
                        BG_CODE$ = A(0).BG_CODE$
                        FOR z% = 0 TO UBOUND(A) ' Get FG Color Code
                            IF TopColor~& = A(z%).RGBC~& THEN
                                FG_CODE$ = A(z%).FG_CODE$
                                fz% = z%
                                EXIT FOR
                            END IF            
                        NEXT z%
                        FOR z% = 0 TO UBOUND(A) ' Get BG Color Code
                            IF BottomColor~& = A(z%).RGBC~& THEN
                                BG_CODE$ = A(z%).BG_CODE$
                                bz% = z%
                                EXIT FOR
                            END IF            
                        NEXT z%

                        ' Check if iCE colors needed if not, make non-iCE
                        DIM ice AS _UNSIGNED _BYTE
                        ice~%% = 1
                        IF bz% > 7 AND fz% < 8 THEN ' bg and fg can swap
                            FG_CODE$ = A(bz%).FG_CODE$
                            BG_CODE$ = A(fz%).BG_CODE$
                            char$ = CHR$(FB) ' use bottom 1/2 block (swap)
                            ice~%% = 0
                        END IF
                        IF bz% > 7 AND bz% = fz% THEN ' bg in range and same fg
                            BG_CODE$ = A(0).BG_CODE$
                            char$ = CHR$(B)
                            ice~%% = 0
                        END IF
                        IF fz% = bz% THEN ' bg same as fg use block on black bg
                            FG_CODE$ = A(fz%).FG_CODE$
                            BG_CODE$ = A(0).BG_CODE$
                            char$ = CHR$(B)
                            ice~%% = 0
                        END IF
                        IF ice~%% = 1 THEN ' if ice is STILL on, remove it
                            IF bz% >= 8 THEN bz% = bz% - 8
                            IF bz% < 0 THEN bz% = 0
                            BG_CODE$ = A(bz%).BG_CODE$
                        END IF

                        ans$ = ans$ _
                            + CHR$(E) _
                            + "[0m" _
                            + CHR$(E) _
                            + "[" _
                            + FG_CODE$ _
                            + ";" _
                            + BG_CODE$ _
                            + "m" _
                            + char$
                    NEXT x%
                END IF
            NEXT y%

            SCREEN 0
            CLS

            ' Write the output.ans file
            PRINT ans$
            OPEN filename$ + "-25-noice.ans" FOR OUTPUT AS #1
            PRINT #1, ans$
            CLOSE #1

            OPEN filename$ + "-25-noice.ans" FOR APPEND AS #1
            PRINT #1, CHR$(&H1A) ' EOF
            CLOSE #1 

            OPEN filename$ + "-25-noice.ans" FOR BINARY AS #1
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
            SauceRecord.TInfo2~%    = SRC_H% \ 2
            SauceRecord.TInfo3~%    = 0
            SauceRecord.TInfo4~%    = 0
            SauceRecord.Comments~%% = 0
            SauceRecord.TFlags~%%   = 2 '8px iCE Color
            s$ = "IBM VGA"
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
