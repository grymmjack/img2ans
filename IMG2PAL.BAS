''
' IMG2PAL
'
' Converts any QB64 supported image to a fixed color palette
'
' EGA is currently used to support conversion of pixel art with IMG2ANS, but
' I will also support loading .GPL files for indexed palettes besides EGA.
'
' @author Rick Christy <grymmjack@gmail.com> - original crappy version :) 
' @author Samuel Gomes <a740g@github> - QB64PE _RGB conversion, GPL loader fixes
'
' @version 0.1
'

'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BI'

$CONSOLE
_CONSOLE ON

OPTION _EXPLICIT
'$DYNAMIC

' Set this to FALSE to enable debugging output to the console
$LET NDEBUG = FALSE

$IF NDEBUG = FALSE THEN
    ' $DEBUG
    $CONSOLE
    $ASSERTS:CONSOLE
$END IF

CONST KEY_RSHIFT&      = 100303
CONST KEY_LSHIFT&      = 100304
CONST IMG_PAL_SPACING& = 2
CONST PROG_VERSION$    = "1.0"
CONST FONT_STYLE$      = "MONOSPACE"

DIM SHARED AS LONG img_orig, img_pal
DIM SHARED AS INTEGER cur_pal, cur_img, cur_scaler
DIM SHARED AS STRING k, img_file, pal_file, FONT_DIR, FONT_FILE
DIM SHARED AS _BYTE no_dithering
DIM SHARED AS SINGLE zoom, zoom_adj, zoom_min, zoom_max
DIM SHARED pal_files(0) AS STRING
DIM SHARED img_files(0) AS STRING
DIM SHARED pal_files_sorted(0) AS STRING
DIM SHARED img_files_sorted(0) AS STRING

DIM SHARED scalers(6) AS STRING
scalers$(0) = "ADAPTIVE"
scalers$(1) = "SXBR2"
scalers$(2) = "MMPX2"
scalers$(3) = "HQ2XA"
scalers$(4) = "HQ2XB"
scalers$(5) = "HQ3XA"
scalers$(6) = "HQ3XB"
cur_scaler% = 0

' default image/pal
img_files$(0) = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$ + "tests-external" + SLASH$ + "08_creon.gif"
img_files_sorted$(0) = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$ + "tests-external" + SLASH$ + "08_creon.gif"
cur_img% = 0
pal_files$(0) = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "palettes" + SLASH$ + "EGA (16).GPL"
pal_files_sorted$(0) = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "palettes" + SLASH$ + "EGA (16).GPL"
cur_pal% = 0

$IF MAC THEN
    FONT_DIR$ = ENVIRON$("HOME") + "/Library/Fonts"
    CONST FONT_SIZE& = 16
    CONST CANVAS_W&  = 1280
    CONST CANVAS_H&  = 960
$ELSEIF LINUX THEN
    FONT_DIR$ = ENVIRON$("HOME") + "/.fonts"
    CONST FONT_SIZE& = 24
    CONST CANVAS_W&  = 1920
    CONST CANVAS_H&  = 1080
$ELSEIF WIN THEN
    FONT_DIR$ = ENVIRON$("HOMEPATH") + "\AppData\Local\Microsoft\Windows\Fonts"
    CONST FONT_SIZE& = 24
    CONST CANVAS_W&  = 1920
    CONST CANVAS_H&  = 1080
$END IF
' FONT_FILE$ = FONT_DIR$ + "/MorePerfectDOSVGANF-4.ttf"
FONT_FILE$ = FONT_DIR$ + "/BerkeleyMonoNerdFont-Regular.ttf"

$VERSIONINFO:CompanyName="grymmjack"
$VERSIONINFO:FILEVERSION#=1,0,0,0
$VERSIONINFO:PRODUCTVERSION#=1,0,0,0
$VERSIONINFO:FileDescription="IMG2PAL Converts images to custom GPL palettes"

_TITLE "IMG2PAL v" + PROG_VERSION$

'Setup screen
DIM SHARED CANVAS AS LONG
DIM SHARED FONTFACE AS LONG
CANVAS = _NEWIMAGE(CANVAS_W&, CANVAS_H&, 32)
SCREEN CANVAS
_SCREENMOVE 0, 0
FONTFACE& = _LOADFONT(FONT_FILE$, FONT_SIZE&, FONT_STYLE$)
_FONT FONTFACE&
' _FULLSCREEN _SQUAREPIXELS

cur_img% = 0
cur_pal% = 0

zoom = 0.1
IF _DESKTOPWIDTH >= _WIDTH(CANVAS&) THEN
    zoom = 1.0
END IF
zoom_adj = 0.1
zoom_min = 0.1
zoom_max = 10.0

draw_output

DO
    _LIMIT 30
    k$ = INKEY$
    IF _KEYDOWN(KEY_LSHIFT&) OR _KEYDOWN(KEY_RSHIFT&) THEN 
        zoom_adj = 0.5
    ELSE
        zoom_adj = 0.1
    END IF
    SELECT CASE k$
        CASE CHR$(27)
            EXIT DO
        CASE "1"
            zoom = 1
            draw_output
        CASE "2"
            zoom = 2
            draw_output
        CASE "3"
            zoom = 3
            draw_output
        CASE "4"
            zoom = 4
            draw_output
        CASE "0"
            zoom = zoom_min
            draw_output
        CASE "9"
            zoom = zoom_max
            draw_output
        CASE ","
            prev_scaler
            ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
            IF no_dithering THEN
                img_orig = _LOADIMAGE(img_file$, 32)
            ELSE
                img_orig = _LOADIMAGE(img_file$, 256, scalers$(cur_scaler%))
            END IF            
            draw_output
        CASE "."
            next_scaler
            ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
            IF no_dithering THEN
                img_orig = _LOADIMAGE(img_file$, 32)
            ELSE
                img_orig = _LOADIMAGE(img_file$, 256, scalers$(cur_scaler%))
            END IF            
            draw_output
        CASE CHR$(0) + CHR$(72) 'up arrow
            _ASSERT 1, "Up"
            zoom = zoom + zoom_adj
            IF (zoom > zoom_max) THEN zoom = zoom_max
            draw_output
        CASE CHR$(0) + CHR$(80) 'down arrow
            _ASSERT 1, "Down"
            zoom = zoom - zoom_adj
            IF (zoom < zoom_min) THEN zoom = zoom_min
            draw_output
        CASE CHR$(0) + CHR$(75) 'left arrow
            prev_pal_file
            load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            draw_output
        CASE CHR$(0) + CHR$(77) 'right arrow
            next_pal_file
            load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            draw_output
        CASE CHR$(0) + CHR$(73) 'page up - prev image
            ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
            prev_img_file
            IF no_dithering THEN
                img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
            ELSE
                img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
            END IF
            img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
            load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            draw_output
        CASE CHR$(0) + CHR$(81) 'page down - next image
            next_img_file
            IF no_dithering THEN
                img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
            ELSE
                img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
            END IF
            img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
            load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            draw_output
        CASE "l", "L":
            ' Choose an image file with dialog
            img_file$ = _OPENFILEDIALOG$( _
                "Choose an image", _
                _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$ + "tests-external" + SLASH$, _
                "*.jpg|*.jpeg|*.png|*.tga|*.bmp|*.psd|*.gif|*.pcx|*.svg|*.qoi" _
                + "*.JPG|*.JPEG|*.PNG|*.TGA|*.BMP|*.PSD|*.GIF|*.PCX|*.SVG|*.QOI", _
                "Image Files", _
                0 _
            )
            IF LEN(img_file$) <> 0 THEN
                IF img_orig < -1 THEN
                    _FREEIMAGE img_orig
                    img_orig = 0
                END IF

                IF img_pal < -1 THEN
                    _FREEIMAGE img_pal
                    img_pal = 0
                END IF

                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF no_dithering THEN
                    img_orig = _LOADIMAGE(img_file$, 32)
                ELSE
                    img_orig = _LOADIMAGE(img_file$, 256, scalers$(cur_scaler%))
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                load_default_ega_palette img_pal
                REDIM img_files(0) AS STRING
                REDIM img_files_sorted(0) AS STRING
                CALL files_to_array(LEFT$(img_file$, _INSTRREV(img_file$, SLASH$)), "*", img_files$())
                CALL ARR_STR.sort(img_files$(), img_files_sorted$())
                cur_img% = ARR_STR.find%(img_files_sorted$(), img_file$)
                _ECHO _TRIM$(STR$(cur_img%))
                draw_output
            END IF

        CASE "p", "P":
            ' Only allow to load a palette if the main image is loaded
            IF img_pal < -1 THEN
                ' Choose a palette file with dialog
                pal_file$ = _OPENFILEDIALOG$( _
                    "Choose a GPL (GIMP) palette", _
                    _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "palettes" + SLASH$, _
                    "*.gpl|*.GPL", _
                    "GPL (GIMP) Palette", _
                    0 _
                )
                IF LEN(pal_file$) <> 0 THEN
                    load_gpl_palette pal_file$, img_pal
                    REDIM pal_files(0) AS STRING
                    REDIM pal_files_sorted(0) AS STRING
                    CALL files_to_array(LEFT$(pal_file$, _INSTRREV(pal_file$, SLASH$)), "*.GPL", pal_files$())
                    CALL ARR_STR.sort(pal_files$(), pal_files_sorted$())
                    cur_pal% = ARR_STR.find%(pal_files_sorted$(), pal_file$)
                    _ECHO _TRIM$(STR$(cur_pal%))
                END IF
                draw_output
            END IF

        CASE "d", "D":
            no_dithering = NOT no_dithering

            IF LEN(img_file$) <> 0 THEN
                IF img_orig < -1 THEN
                    _FREEIMAGE img_orig
                    img_orig = 0
                END IF

                IF img_pal < -1 THEN
                    _FREEIMAGE img_pal
                    img_pal = 0
                END IF

                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF no_dithering THEN
                    img_orig = _LOADIMAGE(img_files_sorted$(clamp%(0, UBOUND(img_files_sorted$), cur_img% - 1)), 32)
                ELSE
                    img_orig = _LOADIMAGE(img_files_sorted$(clamp%(0, UBOUND(img_files_sorted$), cur_img% - 1)), 256, scalers$(cur_scaler%))
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                load_default_ega_palette img_pal
                draw_output
            END IF
        CASE "s":
            ' Save the image with the palette
            IF img_pal < -1 THEN
                DIM AS STRING save_file
                save_file$ = _SAVEFILEDIALOG$( _
                    "Save the image with the palette", _
                    _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$, _
                    "*.png|*.PNG", _
                    "PNG Image" _
                )
                IF LEN(save_file$) <> 0 THEN
                    _SAVEIMAGE save_file$, img_pal
                    _MESSAGEBOX "IMG2PAL", "Image saved as " + save_file$, "info"
                END IF
            END IF
        CASE "a":
            ' About
            _MESSAGEBOX "IMG2PAL", "IMG2PAL v" + PROG_VERSION$
        CASE "h":
            ' Help
            _MESSAGEBOX "IMG2PAL", "L=LOAD,P=PAL,D=DITH:ON,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT-", "info"
        CASE "j":
            ' Jump to a specific image
            DIM AS STRING jump_to
            jump_to$ = _INPUTBOX$("IMG2PAL", "Jump to image number", "0")
            IF LEN(jump_to$) <> 0 THEN
                cur_img% = VAL(jump_to$)
                IF cur_img% < 0 THEN cur_img% = 0
                IF cur_img% > UBOUND(img_files_sorted$) THEN cur_img% = UBOUND(img_files_sorted$)
                draw_output
            END IF
        CASE "l":
            ' Jump to a specific palette
            jump_to$ = _INPUTBOX$("IMG2PAL", "Jump to palette number", "0")
            IF LEN(jump_to$) <> 0 THEN
                cur_pal% = VAL(jump_to$)
                IF cur_pal% < 0 THEN cur_pal% = 0
                IF cur_pal% > UBOUND(pal_files_sorted$) THEN cur_pal% = UBOUND(pal_files_sorted$)
                draw_output
            END IF
    END SELECT
LOOP

IF img_orig < -1 THEN _FREEIMAGE img_orig
IF img_pal < -1 THEN _FREEIMAGE img_pal
SCREEN 0
_FREEIMAGE CANVAS
SYSTEM



''
' Upates the status with command help
' 
SUB update_status
    DIM AS STRING c, z, s, i, p
    c$ = "L=LOAD,"
    c$ = c$ + "P=PAL,"
    c$ = c$ + "UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX)"
    c$ = c$ + "D=DITH:" + _TRIM$(STR$(no_dithering))
    c$ = c$ + "PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT"
    z$ = "ZOOM=" + _TRIM$(STR$(zoom))
    s$ = "-SCALER=" +  scalers$(cur_scaler%)
    IF no_dithering THEN
        PRINT "L=LOAD,P=PAL,D=DITH:ON,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=OFF"
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")"
    ELSE
        PRINT "L=LOAD,P=PAL,D=DITH:OFF,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=" + scalers$(cur_scaler%)
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")" 
    END IF
END SUB


SUB draw_output
    CLS
    COLOR _RGB32(255, 255, 255)
    IF no_dithering THEN
        PRINT "L=LOAD,P=PAL,D=DITH:ON,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=OFF"
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")"
    ELSE
        PRINT "L=LOAD,P=PAL,D=DITH:OFF,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=" + scalers$(cur_scaler%)
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")" 
    END IF

    ' Draw the images if they are loaded
    IF img_orig < -1 THEN
        _ASSERT 1, "bh="+_TRIM$(STR$(_HEIGHT(img_orig)))
        _ASSERT 1, "bw="+_TRIM$(STR$(_WIDTH(img_orig)))
        DIM AS INTEGER dx1_orig, dy1_orig, dx2_orig, dy2_orig
        dx1_orig = 0
        dy1_orig = _FONTHEIGHT(FONTFACE&)*4
        dx2_orig = INT((zoom * _WIDTH(img_orig)) + dx1_orig)
        dy2_orig = INT((zoom * _HEIGHT(img_orig)) + dy1_orig)
        _ASSERT 1, "(" _
            + _TRIM$(STR$(dx1_orig)) + "," _
            + _TRIM$(STR$(dy1_orig)) + ")-(" _
            + _TRIM$(STR$(dx2_orig)) + "," _ 
            + _TRIM$(STR$(dy2_orig)) + ")"
        _PUTIMAGE (dx1_orig, dy1_orig)-(dx2_orig, dy2_orig), img_orig

        ' Palletize the image only if everything is proper
        IF img_pal < -1 THEN
            palettize img_pal, img_orig
            DIM AS INTEGER dx1_pal, dy1_pal, dx2_pal, dy2_pal
            dx1_pal = dx2_orig + IMG_PAL_SPACING&
            dy1_pal = _FONTHEIGHT(FONTFACE&)*4
            dx2_pal = INT((zoom * _WIDTH(img_orig)) + dx1_pal)
            dy2_pal = INT((zoom * _HEIGHT(img_orig)) + dy1_pal)
        _ASSERT 1, "(" _
            + _TRIM$(STR$(dx1_pal)) + "," _
            + _TRIM$(STR$(dy1_pal)) + ")-(" _
            + _TRIM$(STR$(dx2_pal)) + "," _ 
            + _TRIM$(STR$(dy2_pal)) + ")"
            _PUTIMAGE (dx1_pal, dy1_pal)-(dx2_pal, dy2_pal), img_pal
        END IF
        _ASSERT 1, "ah="+_TRIM$(STR$(_HEIGHT(img_orig)))
        _ASSERT 1, "aw="+_TRIM$(STR$(_WIDTH(img_orig)))
    END IF
    _ASSERT 1, "ZOOM=" + _TRIM$(STR$(zoom))
END SUB



''
' Palletize src using the palette in dst. The resulting image is stored in dst
' @param LONG dst The destination image. This must be an 8bpp image with the palette already loaded
' @param LONG src The source image. This must be an 8bpp image with its own palette
'
SUB palettize (dst AS LONG, src AS LONG)
    _ASSERT dst < -1, "dst not allocated!"
    _ASSERT src < -1, "src not allocated!"
    _ASSERT _PIXELSIZE(src) = 4 OR _PIXELSIZE(src) = 1, "src pixel format is incorrect!"
    _ASSERT _PIXELSIZE(dst) = 1, "dst pixel format is incorrect!"

    ' Set the destination image
    DIM oldDst AS LONG: oldDst = _DEST
    _DEST dst

    ' Set the source image
    DIM oldSrc AS LONG: oldSrc = _SOURCE
    _SOURCE src

    ' Calculate image limits just once
    DIM maxX AS LONG: maxX = _WIDTH(src) - 1
    DIM maxY AS LONG: maxY = _HEIGHT(src) - 1

    DIM AS LONG x, y

    ' Remap and write the pixels to img_pal
    IF _PIXELSIZE(src) = 4 THEN
        FOR y = 0 TO maxY
            FOR x = 0 TO maxX
                DIM pc32 AS _UNSIGNED LONG: pc32 = POINT(x, y)
                PSET (x, y), _RGB(_RED32(pc32), _GREEN32(pc32), _BLUE32(pc32), dst)
            NEXT x
        NEXT y

    ELSE
        FOR y = 0 TO maxY
            FOR x = 0 TO maxX
                DIM pc AS _UNSIGNED _BYTE: pc = POINT(x, y)
                PSET (x, y), _RGB(_RED(pc, src), _GREEN(pc, src), _BLUE(pc, src), dst)
            NEXT x
        NEXT y
    END IF

    ' Restore destination and source
    _SOURCE oldSrc
    _DEST oldDst
END SUB



''
' Loads the default EGA palette
' @param LONG dst The destination image. This must be an 8bpp image where the palette is loaded
'
SUB load_default_ega_palette (dst AS LONG)
    _ASSERT dst < -1, "dst not allocated!"
    _ASSERT _PIXELSIZE(dst) = 1, "dst pixel format is incorrect!"

    $IF NDEBUG = FALSE THEN
            _ASSERT 1, "Clearing dst palette..."
    $END IF

    ' Clear the palette
    DIM i AS LONG: FOR i = 0 TO 255
        _PALETTECOLOR i, &HFF000000~&, dst
    NEXT i

    $IF NDEBUG = FALSE THEN
            _ASSERT 1, "Loading default palette..."
    $END IF

    ' Load our palette
    RESTORE default_ega_palette
    FOR i = 0 TO 15
        DIM AS STRING * 2 r, g, b
        READ r, g, b

        _PALETTECOLOR i, _RGB32(VAL("&h" + r), VAL("&h" + g), VAL("&h" + b)), dst

        $IF NDEBUG = FALSE THEN
            _ASSERT 1, "Color" + STR$(i) + "=" + STR$(VAL("&h" + r)) + "," + STR$(VAL("&h" + g)) + "," + STR$(VAL("&h" + b))
        $END IF
    NEXT i

    $IF NDEBUG = FALSE THEN
            _ASSERT 1, "Done!"
    $END IF

    'EGA palette is easy to use in hex color value format
    default_ega_palette:
    DATA 00,00,00
    DATA 00,00,AA
    DATA 00,AA,00
    DATA 00,AA,AA
    DATA AA,00,00
    DATA AA,00,AA
    DATA AA,55,00
    DATA AA,AA,AA
    DATA 55,55,55
    DATA 55,55,FF
    DATA 55,FF,55
    DATA 55,FF,FF
    DATA FF,55,55
    DATA FF,55,FF
    DATA FF,FF,55
    DATA FF,FF,FF
END SUB



''
' Loads a GPL color palette into a 2 dimensional RGB array
' @param STRING gpl_file Filename of GPL palette to load
' @param LONG dst The destination image. This must be an 8bpp image where the palette is loaded
'
SUB load_gpl_palette (gpl_file AS STRING, dst AS LONG)

    _ASSERT dst < -1, "dst not allocated!"
    _ASSERT _PIXELSIZE(dst) = 1, "dst pixel format is incorrect!"
    _ASSERT _FILEEXISTS(gpl_file), gpl_file + " not found!"
    PRINT DUMP.string$(gpl_file, "gpl_file")

    DIM fh AS LONG: fh = FREEFILE
    OPEN gpl_file$ FOR INPUT AS fh

    ' Read the header
    DIM lin AS STRING: LINE INPUT #fh, lin

    IF lin = "GIMP Palette" THEN
        $IF NDEBUG = FALSE THEN
                _ASSERT 1, "Clearing dst palette..."
        $END IF

        ' Clear the palette
        DIM i AS LONG: FOR i = 0 TO 255
            _PALETTECOLOR i, &HFF000000~&, dst
        NEXT i

        DIM c AS LONG

        $IF NDEBUG = FALSE THEN
                _ASSERT 1, "Loading palette from " + gpl_file + "..."
        $END IF

        WHILE NOT EOF(fh)
            LINE INPUT #fh, lin
            lin = LTRIM$(lin) ' trim leading spaces

            ' Proceed only if we have something to process
            IF LEN(lin) <> 0 THEN
                DIM char AS _UNSIGNED _BYTE: char = ASC(lin, 1) ' fetch the first character

                ' Skip comments and other junk (i.e. first character is not a digit)
                IF char >= 48 AND char <= 57 THEN
                    $IF NDEBUG = FALSE THEN
                            _ASSERT 1, "Parsing text: " + lin
                    $END IF

                    ' Parse and read the 3 color components
                    DIM comp AS LONG: comp = 0
                    DIM lastChar AS _UNSIGNED _BYTE: lastChar = 0
                    REDIM clr(0 TO 2) AS _UNSIGNED LONG

                    FOR i = 1 TO LEN(lin)
                        char = ASC(lin, i)

                        IF char >= 48 AND char <= 57 THEN
                            clr(comp) = clr(comp) * 10 + (char - 48)
                        ELSE
                            ' Move to the next component only if the we are fresh out of a successful component read
                            IF lastChar >= 48 AND lastChar <= 57 THEN comp = comp + 1
                        END IF

                        ' Set the color and bail if we have all 3 components
                        IF comp > 2 OR (comp > 1 AND i = LEN(lin)) THEN
                            _PALETTECOLOR c, _RGB32(clr(0), clr(1), clr(2)), dst

                            $IF NDEBUG = FALSE THEN
                                    _ASSERT 1, "Color" + STR$(c) + "=" + STR$(clr(0)) + "," + STR$(clr(1)) + "," + STR$(clr(2))
                            $END IF

                            c = c + 1

                            EXIT FOR
                        END IF

                        lastChar = char
                    NEXT i
                END IF
            END IF
        WEND

        $IF NDEBUG = FALSE THEN
                _ASSERT 1, "Done!"
        $END IF

        ' load the default palette if no color was loaded
        IF c < 1 THEN
            _MESSAGEBOX "IMG2PAL", "Corrupt GIMP Palette!", "warning"
            load_default_ega_palette dst
        END IF
    ELSE
        _MESSAGEBOX "IMG2PAL", "Not a GIMP Palette!", "warning"
    END IF

    CLOSE fh
END SUB


''
' Returns all the files found in filepath as an array of strings
' @param STRING filepath$ Path to include files from
' @param STRING mask$ File mask to search against (wildcards OK) to include 
' @param STRING ARRAY arr$() Array to populate with filenames
'
SUB files_to_array(filepath$, mask$, arr$())
    DIM AS STRING f, fn
    DIM AS LONG lb, ub
    f$ = _FILES$(filepath$ + mask$)
    lb& = LBOUND(arr$)
    DO WHILE LEN(f$) > 0
        fn$ = _TRIM$(f$)
        IF fn$ <> "./" AND fn$ <> "../" AND fn$ <> ".DS_Store" THEN
            ub& = UBOUND(arr$)
            arr$(ub&) = filepath$ + f$
            REDIM _PRESERVE arr(lb& TO ub& + 1) AS STRING
        END IF
        f$ = _FILES$
    LOOP
    REDIM _PRESERVE arr(lb& TO ub&) AS STRING
    DIM old_dest AS LONG
    old_dest& = _DEST
    _DEST _CONSOLE
    PRINT DUMP.string$(filepath$, "filepath")
    PRINT DUMP.string_array$(arr$(), "files_to_array")
    _DEST old_dest&
END SUB


''
' Sets the scaler to the previous scaler
' 
SUB prev_scaler
    cur_scaler% = clamp%(LBOUND(scalers$), UBOUND(scalers$), cur_scaler% - 1)
    _ECHO "cur_scaler%=" + _TRIM$(STR$(cur_scaler%))
END SUB


''
' Sets the scaler to the next scaler
' 
SUB next_scaler
    cur_scaler% = clamp%(LBOUND(scalers$), UBOUND(scalers$), cur_scaler% + 1)
    _ECHO "cur_scaler%=" + _TRIM$(STR$(cur_scaler%))
END SUB


''
' Sets the image file to the previous image file
' 
SUB prev_img_file
    cur_img% = clamp%(LBOUND(img_files_sorted$), UBOUND(img_files_sorted$), cur_img% - 1)
    _ECHO "cur_img%=" + _TRIM$(STR$(cur_img%))
END SUB


''
' Sets the image file to the previous image file
' 
SUB next_img_file
    cur_img% = clamp%(LBOUND(img_files_sorted$), UBOUND(img_files_sorted$), cur_img% + 1)
    _ECHO "cur_img%=" + _TRIM$(STR$(cur_img%))
END SUB


''
' Sets the palette file to the previous palette file
' 
SUB prev_pal_file
    cur_pal% = clamp%(LBOUND(pal_files_sorted$), UBOUND(pal_files_sorted$), cur_pal% - 1)
    _ECHO "cur_pal%=" + _TRIM$(STR$(cur_pal%))
END SUB


''
' Sets the palette file to the previous palette file
' 
SUB next_pal_file
    cur_pal% = clamp%(LBOUND(pal_files_sorted$), UBOUND(pal_files_sorted$), cur_pal% + 1)
    _ECHO "cur_pal%=" + _TRIM$(STR$(cur_pal%))
END SUB


''
' Clamps an integer between min and max
' @param INTEGER min Minimum value allowed
' @param INTEGER max Maximum value allowed
' @param INTEGER value Value passed in to check
' @return INTEGER value clamped
'
FUNCTION clamp%(min%, max%, value%)
    _ECHO "min%=" + _TRIM$(STR$(min%)) + _
        ", max%=" + _TRIM$(STR$(max%)) + _
        ", value%=" + _TRIM$(STR$(value%))
    IF value% > max% THEN value% = max%
    IF value% < min% THEN value% = min%
    _ECHO "return value%=" + _TRIM$(STR$(value%))
    clamp% = value%
END FUNCTION



'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BM'