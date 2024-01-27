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

' Set this to FALSE to enable debugging output to the console
$LET NDEBUG = TRUE

$IF NDEBUG = FALSE THEN
        $DEBUG
        $CONSOLE
        $ASSERTS:CONSOLE
$END IF

'Setup screen
DIM CANVAS AS LONG
CANVAS = _NEWIMAGE(3000, 1080, 32)
SCREEN CANVAS

DIM AS LONG img_orig, img_pal
DIM AS STRING k, img_file, pal_file
DIM AS _BYTE no_dithering

DO
    k$ = INKEY$
    SELECT CASE LCASE$(k$)
        CASE CHR$(27)
            EXIT DO

        CASE "l"
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
                    img_orig = _LOADIMAGE(img_file$, 256, "adaptive")
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                load_default_ega_palette img_pal
            END IF

        CASE "p"
            ' Only allow to load a palette if the main image is loaded
            IF img_pal < -1 THEN
                ' Choose a palette file with dialog
                pal_file$ = _OPENFILEDIALOG$( _
                    "Choose a GPL (GIMP) palette", _
                    , _
                    "*.gpl|*.GPL", _
                    "GPL (GIMP) Palette", _
                    0 _
                )
                IF LEN(pal_file$) <> 0 THEN
                    load_gpl_palette pal_file$, img_pal
                END IF
            END IF

        CASE "d"
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
                    img_orig = _LOADIMAGE(img_file$, 32)
                ELSE
                    img_orig = _LOADIMAGE(img_file$, 256, "adaptive")
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                load_default_ega_palette img_pal
            END IF
    END SELECT

    CLS
    COLOR _RGB32(255, 255, 255)
    IF no_dithering THEN
        PRINT "L=LOAD IMAGE, P=LOAD PALETTE, D=DITHERING ESC=QUIT"
    ELSE
        PRINT "L=LOAD IMAGE, P=LOAD PALETTE, D=NO DITHERING ESC=QUIT"
    END IF

    ' Draw the images if they are loaded
    IF img_orig < -1 THEN
        _PUTIMAGE (0, 16), img_orig

        ' Palletize the image only if everything is proper
        IF img_pal < -1 THEN
            palettize img_pal, img_orig

            _PUTIMAGE (_WIDTH(img_orig) + 10, 16), img_pal
        END IF
    END IF

    SLEEP
LOOP

IF img_orig < -1 THEN _FREEIMAGE img_orig
IF img_pal < -1 THEN _FREEIMAGE img_pal
SCREEN 0
_FREEIMAGE CANVAS
SYSTEM



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
            _ECHO "Clearing dst palette..."
    $END IF

    ' Clear the palette
    DIM i AS LONG: FOR i = 0 TO 255
        _PALETTECOLOR i, &HFF000000~&, dst
    NEXT i

    $IF NDEBUG = FALSE THEN
            _ECHO "Loading default palette..."
    $END IF

    ' Load our palette
    RESTORE default_ega_palette
    FOR i = 0 TO 15
        DIM AS STRING * 2 r, g, b
        READ r, g, b

        _PALETTECOLOR i, _RGB32(VAL("&h" + r), VAL("&h" + g), VAL("&h" + b)), dst

        $IF NDEBUG = FALSE THEN
                _ECHO "Color" + STR$(i) + "=" + STR$(VAL("&h" + r)) + "," + STR$(VAL("&h" + g)) + "," + STR$(VAL("&h" + b))
        $END IF
    NEXT i

    $IF NDEBUG = FALSE THEN
            _ECHO "Done!"
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

    DIM fh AS LONG: fh = FREEFILE
    OPEN gpl_file$ FOR INPUT AS fh

    ' Read the header
    DIM lin AS STRING: LINE INPUT #fh, lin

    IF lin = "GIMP Palette" THEN
        $IF NDEBUG = FALSE THEN
                _ECHO "Clearing dst palette..."
        $END IF

        ' Clear the palette
        DIM i AS LONG: FOR i = 0 TO 255
            _PALETTECOLOR i, &HFF000000~&, dst
        NEXT i

        DIM c AS LONG

        $IF NDEBUG = FALSE THEN
                _ECHO "Loading palette from " + gpl_file + "..."
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
                            _ECHO "Parsing text: " + lin
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
                                    _ECHO "Color" + STR$(c) + "=" + STR$(clr(0)) + "," + STR$(clr(1)) + "," + STR$(clr(2))
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
                _ECHO "Done!"
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
