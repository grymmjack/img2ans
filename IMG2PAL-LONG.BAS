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
'$DYNAMIC
' $CONSOLE
' _CONSOLE ON

'EGA palette is easy to use in hex color value format
DIM EGA(0 TO 15) AS _UNSIGNED LONG
EGA~&(0)  = &HFF000000
EGA~&(1)  = &HFF0000AA
EGA~&(2)  = &HFF00AA00
EGA~&(3)  = &HFF00AAAA
EGA~&(4)  = &HFFAA0000
EGA~&(5)  = &HFFAA00AA
EGA~&(6)  = &HFFAA5500
EGA~&(7)  = &HFFAAAAAA
EGA~&(8)  = &HFF555555
EGA~&(9)  = &HFF5555FF
EGA~&(10) = &HFF55FF55
EGA~&(11) = &HFF55FFFF
EGA~&(12) = &HFFFF5555
EGA~&(13) = &HFFFF55FF
EGA~&(14) = &HFFFFFF55
EGA~&(15) = &HFFFFFFFF
'0 = RED, 1 = GREEN, 2 = BLUE, 3 = ALPHA
REDIM SHARED indexedColors(0 TO 15, 0 TO 2) AS LONG

'Setup screen
DIM SHARED CANVAS AS LONG
CANVAS& = _NEWIMAGE(3000, 1080, 32)
_DEST CANVAS&
SCREEN CANVAS&

' Populate indexedColors from EGA array and display indexes and components
' By default
DIM i AS INTEGER
FOR i% = LBOUND(EGA~&) TO UBOUND(EGA~&)
    CALL hex_to_rgb(EGA~&(), indexedColors&(), i%)
NEXT i%

DIM SHARED AS LONG img_orig, img_pal
DIM SHARED AS _UNSIGNED _BYTE orig, palettized
DIM AS STRING k, img_file, pal_file

orig~%% = 0 : palettized~%% = 0

_DEST CANVAS&
COLOR _RGB32(255, 255, 255)
PRINT "L=LOAD IMAGE, P=LOAD PALETTE, ESC=QUIT"

DO:
    _LIMIT 30
    k$ = INKEY$
    IF k$ = CHR$(27) THEN END
    SELECT CASE LCASE$(k$)
        CASE "l":
            ' Choose an image file with dialog
            img_file$ = _OPENFILEDIALOG$( _
                "Choose an image", _
                , _
                "*.jpg|*.jpeg|*.png|*.tga|*.bmp|*.psd|*.gif|*.pcx|*.svg|*.qoi" _
                + "*.JPG|*.JPEG|*.PNG|*.TGA|*.BMP|*.PSD|*.GIF|*.PCX|*.SVG|*.QOI", _
                "Image Files", _
                0 _
            )
            IF img_file$ <> "" THEN
                img_orig& = _LOADIMAGE(img_file$, 32)
                img_pal& = _COPYIMAGE(img_orig&, 32)
                display_original
            END IF
        CASE "p":
            ' Choose a palette file with dialog
            pal_file$ = _OPENFILEDIALOG$( _
                "Choose a GPL (GIMP) palette", _
                , _
                "*.gpl|*.GPL", _
                "GPL (GIMP) Palette", _
                0 _
            )
            IF pal_file$ <> "" THEN
                CALL load_gpl_palette_to_array(pal_file$, indexedColors&())
            END IF
    END SELECT
    display_original
    display_paletted
    COLOR _RGB32(255, 255, 255)
    PRINT "L=LOAD IMAGE, P=LOAD PALETTE, ESC=QUIT"
    SLEEP
    CLS
LOOP

SCREEN 0
_FREEIMAGE img_orig&
_FREEIMAGE img_pal&
_FREEIMAGE CANVAS&
SYSTEM



''
' Displays the original image
'
SUB display_original()
    orig~%% = 1
    _DEST CANVAS
    _PUTIMAGE (0, 16), img_orig&
END SUB



''
' Displays the paletted image
' and palletizes it if not already done so.
SUB display_paletted()
    orig~%% = 0
    IF paletted~%% = 0 THEN
        palettize
    END IF
    _DEST CANVAS
    _PUTIMAGE (_WIDTH(img_orig&) + 10, 16), img_pal&
END SUB



''
' Palletize an image using indexedColors~%%
'
SUB palettize
    _SOURCE img_orig&
    _DEST img_pal&
    CLS
    DIM AS INTEGER w, h, y, x, closest
    DIM AS LONG cr, cg, cb
    w% = _WIDTH(img_orig&)
    h% = _HEIGHT(img_orig&)
    FOR y%=0 TO h%
        FOR x%=0 TO w%
            cr& = _RED32(POINT(x%, y%))
            cg& = _GREEN32(POINT(x%, y%))
            cb& = _BLUE32(POINT(x%, y%))
            closest% = closest_color_index%(cr&, cg&, cb&, indexedColors&())
            PSET(x%, y%), _RGB32( _
                indexedColors&(closest%, 0), _
                indexedColors&(closest%, 1), _
                indexedColors&(closest%, 2) _
            )
        NEXT x%
    NEXT y%
    paletted~%% = 1
END SUB



''
' Creates a _RGB32 color from a passed in hex color string
'
' @param STRING hexColor 
' @return _UNSIGNED LONG _RGB32 color
'
FUNCTION RGBHEX~&(hexColor$)
    RGBHEX~& = _RGB32( _
        VAL("&H" + LEFT$(hexColor$, 2)), _
        VAL("&H" + MID$(hexColor$, 3, 2)), _
        VAL("&H" + RIGHT$(hexColor$, 2)) _
    )
END FUNCTION



''
' Populates a destionation multidimensional palette array using hex color values
' 
' @param ARRAY _UNSIGNED LONG src_pal source palette of hex color values
' @param ARRAY _UNSIGNED _BYTE dest_pal destination palette for components
' @param INTEGER idx Index of arrays to work on
'
SUB hex_to_rgb(src_pal&(), dest_pal&(), idx%)
    DIM c AS LONG
    c& = src_pal&(idx%)
    dest_pal&(idx%, 0) = _RED32(c&)
    dest_pal&(idx%, 1) = _GREEN32(c&)
    dest_pal&(idx%, 2) = _BLUE32(c&)
END SUB



''
' Finds closest color index in palette for passed in RGB color
'
' Ported from gd's gdImageColorClosestAlpha function here:
' https://github.com/libgd/libgd/blob/58d25665be1c146e7284f253fa679e8256afa6cb/src/gd.c#L460
'
' @param INTEGER r Red component of color to match
' @param INTEGER g Green component of color to match
' @param INTEGER b Blue component of color to match
' @param INTEGER a Alpha component of color to match
' @param ARRAY _UNSIGNED _BYTE pal Palette to search for matches in
' @return INTEGER index of the closest color in palette to passed in RGB color
'
FUNCTION closest_color_index%(r&, g&, b&, pal&())
    DIM AS INTEGER i, found, first
    DIM AS LONG rr, gg, bb
    DIM AS SINGLE dist, mindist
    dist! = 0 : mindist! = 0 : first% = 1
    FOR i% = LBOUND(pal&) TO UBOUND(pal&)
        rr& = pal&(i%, 0) - r&
        gg& = pal&(i%, 1) - g&
        bb& = pal&(i%, 2) - b&
        dist! = rr& * rr& + gg& * gg& + bb& * bb&
        IF first% OR (dist! < mindist!) THEN
            mindist! = dist!
            found% = i%
            first% = 0
        END IF
    NEXT i%
    closest_color_index% = found%
END FUNCTION



''
' Loads a GPL color palette into a 2 dimensional RGB array
' @param STRING gpl_file Filename of GPL palette to load
' @param ARRAY _UNSIGNED _BYTE pal to load RGB components into (must be REDIMable)
' 
SUB load_gpl_palette_to_array(gpl_file$, pal&())
    DIM AS LONG fh
    DIM AS INTEGER i, count, pal_cols
    DIM AS STRING lin, pal_name, pal_cmnt, r, g, b
    DIM c(0 TO 255, 0 TO 2) AS LONG
    fh& = FREEFILE 
    OPEN gpl_file$ FOR INPUT AS #fh&
        LINE INPUT #fh&, lin$
        IF lin$ <> "GIMP Palette" THEN ' Invalid GPL file
            PRINT "GIMP Palette invalid!"
            EXIT SUB
        ELSE ' Valid GPL file
            ' Read name, columns and comments
            LINE INPUT #fh&, lin$
            ' PRINT lin$
            pal_name$ = MID$(lin$, LEN("Name: "))
            LINE INPUT #fh&, lin$
            pal_cols% = VAL(MID$(lin$, LEN("Columns: ")))
            LINE INPUT #fh&, lin$
            pal_cmnt$ = MID$(lin$, LEN("# "))
            
            ' Clear color array
            REDIM pal(0 TO 255, 0 TO 2) AS LONG

            ' Get colors
            i% = 0 : count% = 0
            DO:
                LINE INPUT #fh&, lin$
                r$ = _TRIM$(MID$(lin$, 0, 4)) ' Red value
                g$ = _TRIM$(MID$(lin$, 5, 4)) ' Green value
                b$ = _TRIM$(MID$(lin$, 9, 4)) ' Blue value
                ' PRINT "COLOR #"; i%,
                ' PRINT "R:";r$,"G:";g$,"B:";b$
                ' Add color to palette array
                c&(i%, 0) = VAL(r$)
                c&(i%, 1) = VAL(g$)
                c&(i%, 2) = VAL(b$)
                i% = i% + 1
            LOOP UNTIL EOF(fh&)
            
            ' Put colors in array
            count% = i%
            REDIM pal(0 TO count%, 0 TO 2) AS LONG
            FOR i%=0 TO count% 
                pal&(i%, 0) = c&(i%, 0)
                pal&(i%, 1) = c&(i%, 1)
                pal&(i%, 2) = c&(i%, 2)
            NEXT i%
        END IF
    CLOSE fh&
END SUB