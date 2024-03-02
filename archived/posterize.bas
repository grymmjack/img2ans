'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

$IF DEBUGGING = UNDEFINED THEN
    $LET DEBUGGING = TRUE
$END IF
$IF DEBUGGING = TRUE THEN
    $DEBUG
    $CONSOLE
    $ASSERTS:CONSOLE
    _CONSOLE ON
$END IF
$IF FALSE = UNDEFINED AND TRUE = UNDEFINED THEN
    $LET TRUE = TRUE
    CONST FALSE = 0 : CONST TRUE = NOT FALSE
$END IF
$IF WIN THEN
    CONST SLASH$ = "\"
$ELSE
    CONST SLASH$ = "/"
$END IF

DIM AS INTEGER cx, cy
DIM SHARED AS LONG CANVAS, img, img2, colors
REDIM SHARED AS _UNSIGNED LONG pal(0 TO 255)
REDIM SHARED AS _UNSIGNED LONG spal(0 TO 255)
CANVAS = _NEWIMAGE(1600, 900, 32)
DIM AS STRING img_file
img_file$ = _OPENFILEDIALOG$( _
    "Choose an image", _
    _STARTDIR$ + "/resources/images/tests-external/", _
    "*.jpg|*.jpeg|*.png|*.tga|*.bmp|*.psd|*.gif|*.pcx|*.svg|*.qoi" _
    + "*.JPG|*.JPEG|*.PNG|*.TGA|*.BMP|*.PSD|*.GIF|*.PCX|*.SVG|*.QOI", _
    "Image Files", _
    0 _
)

' SXBR2: Applies the Super-xBR 2x pixel scaler on the image.
' MMPX2: Applies the MMPX Style-Preserving 2x pixel scaler on the image.
' HQ2XA: Applies the High Quality Cartoon 2x pixel scaler on the image.
' HQ2XB: Applies the High Quality Complex 2x pixel scaler on the image.
' HQ3XA: Applies the High Quality Cartoon 3x pixel scaler on the image.
' HQ3XB: Applies the High Quality Complex 3x pixel scaler on the image.
' img2    = _LOADIMAGE(img_file$, 32, "HQ3XB")

img2    = _LOADIMAGE(img_file$, 32)
colors = _NEWIMAGE(301, 54, 32)

'preset 1 posterize 8 colors
' img = ExtractBitfields(img2, &B10000000, 1, "ARGB", -1, -1, -1, -1, -1)
' img = AddConstant(img, &HFF5A5A5A, -1, -1, -1, -1, -1)
' img = ModifyContrast(img, 0.66, -1, -1, -1, -1, -1)

'preset 2 posterize - 40 colors
img = ExtractBitfields(img2, &B11000000, 1, "ARGB", -1, -1, -1, -1, -1)
img = AddConstant(img, &HFF333333, -1, -1, -1, -1, -1)
img = ModifyContrast(img, 0.5, -1, -1, -1, -1, -1)

'preset 3 posterize - 135 colors
' img = ExtractBitfields(img2, &B11100000, 1, "ARGB", -1, -1, -1, -1, -1)
' img = AddConstant(img, &HFF222222, -1, -1, -1, -1, -1)
' img = ModifyContrast(img, 0.5, -1, -1, -1, -1, -1)


CALL get_pal_from_image32(img, pal())
ARR_ULONG.copy pal(), spal()
ARR_ULONG.sort pal(), spal()
CALL render_pal(colors, spal())
_DEST CANVAS
_PUTIMAGE (0, 0)-(_WIDTH(img), _HEIGHT(img)), img, CANVAS
cx = 0 : cy = 0
_PUTIMAGE (cx, cy)-(cx+_WIDTH(colors), cy+_HEIGHT(colors)), _
    colors, _
    CANVAS, _
    (0, 0)-(_WIDTH(colors), _HEIGHT(colors))
SCREEN CANVAS

SLEEP
SCREEN 0
_DEST 0
_FREEIMAGE CANVAS
_FREEIMAGE img
_FREEIMAGE img2
_FREEIMAGE colors
SYSTEM

SUB render_pal(img&, pal~&())
    DIM AS INTEGER i, ub, lb, total, cols, w, h
    DIM AS LONG old_dest
    lb = LBOUND(pal) : ub = UBOUND(pal)
    w = _WIDTH(img&) : h = _HEIGHT(img&)
    total = ub - lb
    cols = INT(w / total)
    cols = cols - 1
    old_dest = _DEST : _DEST img&
    CLS
    i=lb
    PSET (0, 0), 0
    WHILE i <= total
        console.log "#:" + STR$(i) + " > " _
                  + "(" + _TRIM$(STR$(pal~&(i))) + ")" _
                  + " R:" + STR$(_RED32(pal~&(i))) _
                  + " G:" + STR$(_GREEN32(pal~&(i))) _
                  + " B:" + STR$(_BLUE32(pal~&(i)))
        LINE (i*cols+i, 0)-(i*cols+cols+1+i, h+1), _RGB32(0, 0, 0), BF
        LINE (i*cols+i+1, 0)-(i*cols+cols+i+1, h), pal~&(i), BF
        i = i + 1
    WEND
    LINE (0, 0)-(w-1, h-1), _RGB32(255, 255, 255), B
    LINE (1, 1)-(w-2, h-2), _RGB32(0, 0, 0), B
    _DEST old_dest
END SUB

SUB get_pal_from_image32(img&, pal~&())
    DIM AS INTEGER w, h, i, x, y
    DIM AS LONG old_dest
    DIM AS _UNSIGNED LONG old_pt, new_pt
    _SOURCE img&
    old_dest = _DEST : _DEST img&
    w = _WIDTH(img&) : h = _HEIGHT(img&)
    i = 0
    FOR y = 0 TO h
        FOR x = 0 TO w
            new_pt = POINT(x, y)
            IF new_pt <> old_pt THEN
                IF NOT ARR_ULONG.in(pal~&(), new_pt) THEN
                    pal~&(i) = new_pt
                    console.log "new color(" + _TRIM$(STR$(i)) + "): " _
                                + _TRIM$(STR$(new_pt))
                    IF i < 255 THEN
                        old_pt = new_pt
                        i = i + 1
                        console.log "x=" + _TRIM$(STR$(x)) _
                                + ", y=" + _TRIM$(STR$(y))
                        ' PSET (x, y), _RGB32(255, 0, 0)
                    END IF
                END IF
            END IF
            IF i >= 255 THEN
                console.warn "255 colors retrieved"
                EXIT SUB
            END IF
        NEXT x
    NEXT y
    REDIM _PRESERVE pal(0 TO i) AS _UNSIGNED LONG
    _DEST old_dest
END SUB


''
' Log to console if DEBUGGING
' @param STRING msg message to send
'
SUB console.log(msg$)
    $IF DEBUGGING = TRUE THEN
        _ECHO msg$
    $END IF
    msg$ = ""
END SUB


''
' Log to console as info if DEBUGGING
' @param STRING msg message to send
'
SUB console.info(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;36m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB


''
' Log to console as warning if DEBUGGING
' @param STRING msg message to send
'
SUB console.warn(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;33m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB


''
' Log to console as error if DEBUGGING
' @param STRING msg message to send
'
SUB console.error(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;31m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB

'$INCLUDE:'../include/QB64_GJ_LIB/ARR/ARR_ULONG.BAS'
'$INCLUDE:'../include/RhoSigma-QB64Library/QB64Library/IMG-Support/imageprocess.bm'
