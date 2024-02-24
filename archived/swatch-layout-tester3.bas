'best version so far

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

DIM SHARED AS LONG CANVAS
DIM SHARED AS INTEGER w, h, c, rows, cols, cell_w, cell_h, i, row, col, guide_opac
DIM SHARED AS INTEGER off_x, off_y, x1, y1, x2, y2, max_c, min_c, shortfall
DIM SHARED AS _UNSIGNED LONG bg_color, text_color, guide_color, cmd_color
DIM SHARED AS _UNSIGNED LONG bg_swatch_color, fg_swatch_color
_TITLE "IMG2ANS Swatch Layout Tester"
CANVAS = _NEWIMAGE(800, 600, 32) : SCREEN CANVAS

'setup colors
guide_opac = 0
bg_swatch_color = _RGB32(0, 0, 0)
fg_swatch_color = _RGB32(255, 255, 255)
bg_color = _RGB32(25, 50, 200)
text_color = _RGB32(255, 255, 255)
guide_color = _RGBA32(0, 255, 100, guide_opac)
cmd_color = _RGB32(255, 255, 0)

'setup IMG2ANS emulation vars
c = 2
h = 54
w = 342
off_x = 100
off_y = 300
max_c = 255
min_c = 2

'main loop
draw_output
_DISPLAY
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


''
' Draw the output
'
SUB draw_output
    DIM AS LONG old_dest, img_w, img_h, tmp_img
    old_dest = _DEST
    CLS, bg_color
    _PRINTMODE _KEEPBACKGROUND
    COLOR text_color

    'determine swatch layout
    rows = whole_number_divisor(c)
    rows = c / 32 + 1
    cols = c / rows
    shortfall = ABS((rows*cols) - c)
    cols = cols + shortfall
    cell_w = w / cols - 1
    cell_h = h / rows - 1
    img_w = cell_w * cols
    img_h = cell_h * rows
    tmp_img = _NEWIMAGE(img_w, img_h, 32)

    'draw stats
    PRINT "# Colors: " + _TRIM$(STR$(c)),,
    PRINT "Palette Dimensions: " + _TRIM$(STR$(w)) + " x " + _TRIM$(STR$(h))
    PRINT "Swatch Layout " + _TRIM$(STR$(cols)) + " x " + _TRIM$(STR$(rows)),
    PRINT "Swatch Dimensions: " + _TRIM$(STR$(cell_w)) + " x " + _TRIM$(STR$(cell_h))
    PRINT "Swatch Count: " + _TRIM$(STR$(rows*cols)), "Color Count Snap: " + _TRIM$(STR$(shortfall))
    PRINT "Swatches Unused: " + _TRIM$(STR$(rows*cols-c))

    'draw commands
    PRINT
    COLOR cmd_color
    PRINT "The swatch grid should remain inside the guides."
    PRINT "The swatch grid does best effort to fill the space."
    PRINT
    PRINT "a = add color, s = subtract color, ESC = exit"

    'draw swatches
    _DEST tmp_img
    CLS
    FOR row=0 TO rows - 1
        FOR col=0 to cols - 1
            x1 = 0 + (col * cell_w)
            x2 = 0 + (col * cell_w) + cell_w
            y1 = 0 + (row * cell_h)
            y2 = 0 + (row * cell_h) + cell_h
            LINE (x1, y1)-(x2, y2), _RGB32(INT(RND*255), INT(RND*255), INT(RND*255)), BF
            ' LINE (x1, y1)-(x2, y2), fg_swatch_color, B
        NEXT col
    NEXT row

    'draw guides
    _DEST old_dest    
    LINE (0, off_y)-(_WIDTH(CANVAS), off_y), guide_color 'top
    LINE (0, off_y + h - 1)-(_WIDTH(CANVAS), off_y + h - 1), guide_color 'bot
    LINE (off_x, 0)-(off_x,_HEIGHT(CANVAS)), guide_color 'left
    LINE (off_x + w - 1, 0)-(off_x + w - 1, _HEIGHT(CANVAS)), guide_color 'right
    _PUTIMAGE (off_x, off_y)-(off_x+w, off_y+h), tmp_img, CANVAS,, _SMOOTH
    _FREEIMAGE tmp_img
    _DISPLAY
END SUB


''
' Return the first whole number that evenly divideds into a number
' @param INT TYPE n number to get divisor for
' @return INT TYPE whole number
'
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
