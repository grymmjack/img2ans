''
' TODO: Add Command Line processing support for multiple files. 
' IMG2ANS-25-RGB
'
' Convert any QB64 supported image into ANSI block art
'
' This version exports RGB color codes. So it can take any image as input!
'
' @author Rick Christy (grymmjack@gmail.com)
' @link https://youtube.com/grymmjack
' @version 0.1
'

'$INCLUDE:'../SAUCE/SAUCE.BI'

DIM AS LONG CANVAS, SRC_IMAGE
DIM AS INTEGER SRC_W, SRC_H, x, y, z, xx, yy
DIM AS STRING SRC_FILE, ans
DIM AS _UNSIGNED LONG c
CONST E  = 27  ' ESCAPE - The ANSI escape code
CONST B  = 219 '█ BLOCK CHARACTER - Full block foreground
CONST FT = 223 '▀ HALF BLOCK Top FG Bottom BG

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
            FOR y% = 0 TO SRC_H%
                IF (y% = 0) OR (y% MOD 2 = 0) THEN
                    FOR x% = 0 TO SRC_W% - 1
                        DIM AS _UNSIGNED LONG TopColor, BottomColor
                        DIM AS STRING FG_CODE, BG_CODE
                        DIM AS STRING bR, bG, bB, fR, fG, fB
                        TopColor~& = POINT(x%, y%) ' top pixel
                        IF y%+1 < SRC_H% THEN
                            BottomColor~& = POINT(x%, y%+1) ' pixel under
                        ELSE
                            BottomColor~& = _RGB32(0, 0, 0)
                            TopColor~& = _RGB32(0, 0, 0)
                        END IF

                        ' Extract RGB values from each color
                        bR$ = _TRIM$(STR$(_RED32(BottomColor~&)))
                        bG$ = _TRIM$(STR$(_GREEN32(BottomColor~&)))
                        bB$ = _TRIM$(STR$(_BLUE32(BottomColor~&)))
                        fR$ = _TRIM$(STR$(_RED32(TopColor~&)))
                        fG$ = _TRIM$(STR$(_GREEN32(TopColor~&)))
                        fB$ = _TRIM$(STR$(_BLUE32(TopColor~&)))

                        ' Create the code strings
                        FG_CODE$ = "[1;" _
                                 + fR$ + ";" _
                                 + fG$ + ";" _
                                 + fB$ + "t"

                        BG_CODE$ = "[0;" _
                                 + bR$ + ";" _
                                 + bG$ + ";" _
                                 + bB$ + "t"

                        ' Create ansi escape sequences strings
                        ans$ = ans$ _
                            + CHR$(E) _
                            + FG_CODE$ _
                            + CHR$(E) _
                            + BG_CODE$ _
                            + CHR$(FT)
                    NEXT x%
                END IF
            NEXT y%

            SCREEN 0
            CLS

            ' Write the output.ans file
            PRINT ans$
            OPEN filename$ + "-25-RGB.ans" FOR OUTPUT AS #1
            PRINT #1, ans$
            CLOSE #1

            OPEN filename$ + "-25-RGB.ans" FOR APPEND AS #1
            PRINT #1, CHR$(&H1A) ' EOF
            CLOSE #1 

            OPEN filename$ + "-25-RGB.ans" FOR BINARY AS #1
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
            SauceRecord.TFlags~%%   = 3 '8px iCE Color
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
