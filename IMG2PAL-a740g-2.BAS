''
' IMG2PAL
'
' Converts any QB64 supported image to a fixed color palette by calculating
' the closest Euclidean Distance matching indexed color to RGB components.
'
' EGA is currently used to support conversion of pixel art with IMG2ANS, but
' I will also support loading .PAL files for indexed palettes besides EGA.
'
' @author Rick Christy <grymmjack@gmail.com>
'
' @see https://en.wikipedia.org/wiki/Euclidean_distance
' @see https://stackoverflow.com/questions/57862060/finding-the-closest-indexed-color-value-to-the-current-color-in-javascript-p5
' @see https://github.com/libgd/libgd/blob/58d25665be1c146e7284f253fa679e8256afa6cb/src/gd.c#L460
'
' @version 0.1
'

OPTION _EXPLICIT
'$DYNAMIC

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

'0 = RED, 1 = GREEN, 2 = BLUE
REDIM SHARED indexedColors(0 TO 15, 0 TO 2) AS _UNSIGNED _BYTE

'Setup screen
DIM CANVAS AS LONG
CANVAS& = _NEWIMAGE(3000, 1080, 32)
SCREEN CANVAS&

'Load default EGA palette to indexedColors
CALL load_default_ega_palette

DIM SHARED AS LONG img_orig, img_pal
DIM AS STRING k, img_file, pal_file

DO:
    CLS

    COLOR _RGB32(255, 255, 255)
    PRINT "L=LOAD IMAGE, P=LOAD PALETTE, ESC=QUIT"

    k$ = INKEY$
    SELECT CASE LCASE$(k$)
        CASE CHR$(27):
            EXIT DO

        CASE "l":
            IF img_orig& < -1 THEN
                _FREEIMAGE img_orig&
                img_orig& = 0
            END IF

            IF img_pal& < -1 THEN
                _FREEIMAGE img_pal&
                img_pal& = 0
            END IF

            ' Choose an image file with dialog
            img_file$ = _OPENFILEDIALOG$( _
                "Choose an image", _
                , _
                "*.jpg|*.jpeg|*.png|*.tga|*.bmp|*.psd|*.gif|*.pcx|*.svg|*.qoi" _
                + "*.JPG|*.JPEG|*.PNG|*.TGA|*.BMP|*.PSD|*.GIF|*.PCX|*.SVG|*.QOI", _
                "Image Files", _
                0 _
            )
            IF LEN(img_file$) <> 0 THEN
                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                img_orig& = _LOADIMAGE(img_file$, 256, "adaptive")
            END IF

        CASE "p":
            IF img_pal& < -1 THEN
                _FREEIMAGE img_pal&
                img_pal& = 0
            END IF

            ' Choose a palette file with dialog
            pal_file$ = _OPENFILEDIALOG$( _
                "Choose a GPL (GIMP) palette", _
                , _
                "*.gpl|*.GPL", _
                "GPL (GIMP) Palette", _
                0 _
            )
            IF LEN(pal_file$) <> 0 THEN
                CALL load_gpl_palette_to_array(pal_file$)
            END IF
    END SELECT

    display_original
    display_paletted

    SLEEP
LOOP

IF img_orig& < -1 THEN _FREEIMAGE img_orig&
IF img_pal& < -1 THEN _FREEIMAGE img_pal&
SCREEN 0
_FREEIMAGE CANVAS&
SYSTEM



''
' Displays the original image
'
SUB display_original ()
    IF img_orig < -1 THEN
        _PUTIMAGE (0, 16), img_orig&
    END IF
END SUB



''
' Displays the paletted image
' and palletizes it if not already done so.
SUB display_paletted ()
    IF img_orig& < -1 THEN
        palettize
        _PUTIMAGE (_WIDTH(img_orig&) + 10, 16), img_pal&
    END IF
END SUB



''
' Palletize an image using indexedColors~%%
'
SUB palettize
    IF img_pal& = 0 AND img_orig& < -1 THEN
        img_pal& = _NEWIMAGE(_WIDTH(img_orig&), _HEIGHT(img_orig&), 256)
        IF img_pal& < -1 THEN
            ' Clear the palette
            DIM i AS LONG: FOR i = 0 TO 255
                _PALETTECOLOR i, &HFF000000~&, img_pal&
            NEXT i

            ' Load our palette
            FOR i = LBOUND(indexedColors, 1) TO UBOUND(indexedColors, 1)
                _PALETTECOLOR i, _RGB32(indexedColors(i, 0), indexedColors(i, 1), indexedColors(i, 2)), img_pal&
            NEXT i

            ' Set the destination image
            DIM oldDst AS LONG: oldDst = _DEST
            _DEST img_pal&

            ' Set the source image
            DIM oldSrc AS LONG: oldSrc = _SOURCE
            _SOURCE img_orig&

            ' Calculate image limits just once
            DIM maxX AS LONG: maxX = _WIDTH(img_orig&) - 1
            DIM maxY AS LONG: maxY = _HEIGHT(img_orig&) - 1

            ' Remap and write the pixels to img_pal&
            DIM y AS LONG: FOR y = 0 TO maxY
                DIM x AS LONG: FOR x = 0 TO maxX
                    DIM pc AS _UNSIGNED _BYTE: pc = POINT(x, y)
                    PSET (x, y), _RGB(_RED(pc, img_orig&), _GREEN(pc, img_orig&), _BLUE(pc, img_orig&), img_pal&)
                NEXT x
            NEXT y

            ' Restore destination and source
            _SOURCE oldSrc
            _DEST oldDst
        END IF
    END IF
END SUB



''
' Loads the default EGA palette
'
SUB load_default_ega_palette
    RESTORE default_ega_palette
    DIM c AS LONG: FOR c = 0 TO 15
        DIM AS STRING * 2 r, g, b
        READ r, g, b

        indexedColors(c, 0) = VAL("&h" + r)
        indexedColors(c, 1) = VAL("&h" + g)
        indexedColors(c, 2) = VAL("&h" + b)
    NEXT c
END SUB



''
' Loads a GPL color palette into a 2 dimensional RGB array
' @param STRING gpl_file Filename of GPL palette to load
'
SUB load_gpl_palette_to_array (gpl_file$)
    DIM fh AS LONG: fh = FREEFILE
    OPEN gpl_file$ FOR INPUT AS fh

    ' Read the header
    DIM lin AS STRING: LINE INPUT #fh, lin

    IF lin = "GIMP Palette" THEN
        ' Clear color array
        DIM colors(0 TO 255, 0 TO 2) AS _UNSIGNED _BYTE

        DIM c AS LONG

        WHILE NOT EOF(fh)
            LINE INPUT #fh, lin

            ' Skip comments and other junk
            IF INSTR("0123456789", LEFT$(lin, 1)) > 0 THEN
                ' Parse and read the 3 color components
                DIM comp AS LONG: comp = 0
                DIM i AS LONG: FOR i = 1 TO LEN(lin)
                    DIM char AS _UNSIGNED _BYTE: char = ASC(lin, i)
                    DIM lastChar AS _UNSIGNED _BYTE

                    IF char >= 48 AND char <= 57 THEN
                        colors(c, comp) = colors(c, comp) * 10 + char - 48
                    ELSE
                        ' Move to the next component only if the we are fresh out of a successful component read
                        IF lastChar >= 48 AND lastChar <= 57 THEN comp = comp + 1
                    END IF

                    IF comp > 2 THEN EXIT FOR ' bail if we have all 3 components

                    lastChar = char
                NEXT i

                c = c + 1
            END IF
        WEND

        ' Resize colors array and copy the colors
        IF c > 0 THEN
            REDIM indexedColors(0 TO c - 1, 0 TO 2) AS _UNSIGNED _BYTE
            i = 0
            WHILE i < c
                indexedColors(i, 0) = colors(i, 0)
                indexedColors(i, 1) = colors(i, 1)
                indexedColors(i, 2) = colors(i, 2)
                i = i + 1
            WEND
        ELSE
            _MESSAGEBOX "IMG2PAL", "Corrupt GIMP Palette!", "warning"
        END IF
    ELSE
        _MESSAGEBOX "IMG2PAL", "Not a GIMP Palette!", "warning"
    END IF

    CLOSE fh&
END SUB
