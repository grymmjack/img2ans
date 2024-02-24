$NOPREFIX
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
DIM SHARED AS LONG CANVAS, img, colors
REDIM SHARED AS _UNSIGNED LONG pal(0 TO 255)
CANVAS = _NEWIMAGE(1920, 1080, 32)
img    = _LOADIMAGE("../resources/images/All-Foodies-ANSI32.png", 32)
colors = _NEWIMAGE(301, 54, 32)
CALL get_pal_from_image32(img, pal())
CALL render_pal(colors, pal())
_DEST CANVAS
_PUTIMAGE (0, 0)-(_WIDTH(img), _HEIGHT(img)), img, CANVAS
cx = 250 : cy = 250
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
_FREEIMAGE colors
SYSTEM

SUB render_pal(img&, pal~&())
    DIM AS INTEGER i, ub, lb, total, cols, w, h
    DIM AS LONG old_dest
    lb = LBOUND(pal) : ub = UBOUND(pal)
    w = _WIDTH(img&) : h = _HEIGHT(img&)
    total = ub - lb
    cols = INT(w / total)
    old_dest = _DEST : _DEST img&
    CLS
    i=lb
    PSET (0, 0), 0
    WHILE i < total
        console.log "#:" + STR$(i) _
                  + "(" + _TRIM$(STR$(pal~&(i))) + ")" _
                  + ",R:" + STR$(_RED32(pal~&(i))) _
                  + "G:" + STR$(_GREEN32(pal~&(i))) _
                  + "B:" + STR$(_BLUE32(pal~&(i)))
        LINE (i*cols, 0)-(i*cols+cols+1, h+1), _RGB32(0, 0, 0), BF
        LINE (i*cols, 0)-(i*cols+cols, h), pal~&(i), BF
        i = i + 1
    WEND
    LINE (1, 1)-(w-1, h-1), _RGB32(255, 255, 255), B
    LINE (2, 2)-(w-2, h-2), _RGB32(0, 0, 0), B
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
