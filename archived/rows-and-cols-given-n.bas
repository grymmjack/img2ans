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

DIM SHARED AS LONG CANVAS
CANVAS = _NEWIMAGE(1680, 1050, 32)
SCREEN CANVAS
DIM SHARED AS INTEGER w, h, c, rows, cols, cell_w, cell_h, i, row, col
DIM SHARED AS INTEGER off_x, off_y, x1, y1, x2, y2, max_c, min_c, shortfall

c = 2
h = 54
w = 342
off_x = 100
off_y = 300
max_c = 255
min_c = 2
draw_output
DO
    _LIMIT 60
    SELECT CASE INKEY$
        CASE CHR$(27)
            EXIT DO
        CASE "a", "A"
            c = c + 1
            IF c > max_c THEN c = max_c
            draw_output
        CASE "s", "S"
            c = c - 1
            IF c < min_c THEN c = min_c
            draw_output
    END SELECT
LOOP

SUB draw_output
    CLS, _RGB32(32, 32, 32)
    COLOR _RGB(255, 255, 255)
    rows = whole_number_divisor(c)
    rows = c / 32 + 1
    cols = c / rows
    shortfall = ABS((rows*cols) - c)
    cols = cols + shortfall
    cell_w = w / cols - 1
    cell_h = h / rows - 1
    _PRINTMODE _KEEPBACKGROUND
    PRINT "# Colors: " + _TRIM$(STR$(c)),,
    PRINT "Palette Dimensions: " + _TRIM$(STR$(h)) + "x" + _TRIM$(STR$(w))
    PRINT "Swatch Layout " + _TRIM$(STR$(rows)) + "x" + _TRIM$(STR$(cols)),
    PRINT "Swatch Dimensions: " + _TRIM$(STR$(cell_w)) + "x" + _TRIM$(STR$(cell_h))
    PRINT "Swatch Count: " + _TRIM$(STR$(rows*cols)), "Color Count Snap: " + _TRIM$(STR$(shortfall))
    PRINT "Swatches Unused: " + _TRIM$(STR$(rows*cols-c))
    PRINT
    COLOR _RGB(255, 255, 0) : PRINT "a = add color, s = subtract color"
    ' PRINT rows, cols, cell_w, cell_h

    FOR row=0 TO rows - 1
        FOR col=0 to cols - 1
            x1 = off_x + (col * cell_w)
            x2 = off_x + (col * cell_w) + cell_w
            y1 = off_y + (row * cell_h)
            y2 = off_y + (row * cell_h) + cell_h
            LINE (x1, y1)-(x2, y2), _RGB32(255, 255, 255), B
        NEXT col
    NEXT row
    LINE (0, off_y)-(_WIDTH(CANVAS), off_y), _RGBA32(255, 0, 0, 100)
    LINE (0, off_y + h - 1)-(_WIDTH(CANVAS), off_y + h - 1), _RGBA32(255, 0, 0, 100)
    LINE (off_x, 0)-(off_x,_HEIGHT(CANVAS)), _RGBA32(255, 0, 0, 100)
    LINE (off_x + w - 1, 0)-(off_x + w - 1, _HEIGHT(CANVAS)), _RGBA32(255, 0, 0, 100)
END SUB

FUNCTION whole_number_divisor&(n)
    DIM AS INTEGER i
    i = 2
    IF n > 0 AND i >= 1 THEN
        DO
            i = i - 1
        LOOP UNTIL n MOD i = 0
        whole_number_divisor = i
    END IF
END FUNCTION



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