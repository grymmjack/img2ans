'best version so far

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

DIM SHARED AS LONG CANVAS, guide_pat
DIM SHARED AS INTEGER w, h, c, rows, cols, cell_w, cell_h, i, row, col, guide_opac
DIM SHARED AS INTEGER off_x, off_y, x1, y1, x2, y2, max_c, min_c, unused, cc
DIM SHARED AS INTEGER grid, y
DIM SHARED AS _UNSIGNED LONG bg_color, text_color, guide_color, cmd_color
DIM SHARED AS _UNSIGNED LONG bg_swatch_color, fg_swatch_color, empty_swatch_color
DIM SHARED AS STRING k
_TITLE "IMG2ANS Swatch Layout Tester"
CANVAS = _NEWIMAGE(800, 600, 32) : SCREEN CANVAS

'setup colors
guide_opac         = 50
bg_swatch_color    = _RGB32(0, 0, 0)
fg_swatch_color    = _RGBA32(0, 0, 0, 255)
empty_swatch_color = _RGB32(0, 0, 0)
bg_color           = _RGB32(25, 50, 200)
text_color         = _RGB32(255, 255, 255)
guide_color        = _RGBA32(255, 100, 100, guide_opac)
cmd_color          = _RGB32(255, 255, 0)

'setup IMG2ANS emulation vars
guide_pat = &B0110011001100110
grid      = -1
c         = 2
cc        = 2
h         = 54
w         = 342
off_x     = 100
off_y     = 300
max_c     = 256
min_c     = 2

'main loop
draw_output
_DISPLAY
DO
    _LIMIT 60
    k$ = INKEY$
    IF k$ <> "" THEN
        SELECT CASE k$
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
            CASE "1","2","3","4","5","6","7","8"
                cc = ASC(k$)-48 
                c = 2 ^ cc
                grid = -1
                draw_output
            CASE "g"
                grid = NOT grid
                draw_output
        END SELECT
    END IF
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
    rows    = whole_number_divisor(c)
    rows    = c / 32
    IF rows = 0 THEN rows = 1
    cols    = c / rows
    unused  = ABS(c - (rows * cols))    
    cols = cols + unused
    unused  = ABS(c - (rows * cols))    
    IF cols = unused THEN
        rows = rows - 1
        unused = 0
    END IF
    cell_w  = (w / cols) - 2
    cell_h  = (h / rows) - 2
    img_w   = cell_w * cols
    img_h   = cell_h * rows
    tmp_img = _NEWIMAGE(img_w, img_h, 32)

    'draw stats
    PRINT "# Colors: " + _TRIM$(STR$(c)),,,
    PRINT "Palette Dimensions: " + _TRIM$(STR$(w)) + " x " + _TRIM$(STR$(h))
    PRINT "Swatch Layout " + _TRIM$(STR$(cols)) + " x " + _TRIM$(STR$(rows)),,
    PRINT "Swatch Dimensions: " + _TRIM$(STR$(cell_w)) + " x " + _TRIM$(STR$(cell_h))
    PRINT "Swatch Count: " + _TRIM$(STR$(rows*cols)),, "Unused slots: " + _TRIM$(STR$(unused))

    'draw commands
    PRINT
    COLOR cmd_color
    PRINT "The swatch grid should remain inside the guides."
    PRINT "The swatch grid does best effort to fill the space."
    PRINT
    PRINT "Set color count: 1=2, 2=4, 3=8, 4=16, 5=32, 6=64, 7=128, 8=256, 9=512"
    PRINT "a = add color, s = subtract color, g = toggle grid, ESC = exit"

    'grid toggle via opacity
    IF grid THEN
        fg_swatch_color = _RGBA32( _
            _RED32(fg_swatch_color), _
            _GREEN32(fg_swatch_color), _
            _BLUE32(fg_swatch_color), _
            255 _
        )
    ELSE
        fg_swatch_color = _RGBA32( _
            _RED32(fg_swatch_color), _
            _GREEN32(fg_swatch_color), _
            _BLUE32(fg_swatch_color), _
            0 _
        )
    END IF

    'draw swatches
    _DEST tmp_img
    FOR row=0 TO rows - 1
        FOR col=0 to cols - 1
            x1 = (cell_w * col)
            x2 = (cell_w * col) + cell_w
            y1 = (cell_h * row)
            y2 = (cell_h * row) + cell_h
            LINE (x1, y1)-(x2, y2), _RGB32(INT(RND*255), INT(RND*255), INT(RND*255)), BF
            LINE (x1, y1)-(x2-1, y2-1), fg_swatch_color, B
        NEXT col
    NEXT row
    'draw blanks
    IF unused > 0 THEN
        y = row + 1
        x1 = (cell_w * cols) - (cell_w * ABS(c - (rows * cols)))
        x2 = w
        y1 = (cell_h * row) - cell_h
        y2 = h
        LINE (x1, y1)-(x2, y2), empty_swatch_color, BF
    END IF

    'render swatches to canvas
    _PUTIMAGE (off_x, off_y)-(off_x+w, off_y+h), tmp_img, CANVAS,, _SMOOTH

    'draw guides on top
    _DEST old_dest    
    LINE (0, off_y)-(_WIDTH(CANVAS), off_y), guide_color,, guide_pat 'top
    LINE (0, off_y + h)-(_WIDTH(CANVAS), off_y + h), guide_color,, guide_pat 'bot
    LINE (off_x, 0)-(off_x,_HEIGHT(CANVAS)), guide_color,, guide_pat 'left
    LINE (off_x + w, 0)-(off_x + w, _HEIGHT(CANVAS)), guide_color,, guide_pat 'right    
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
    i = 1
    IF n > 0 THEN
        DO
            i = i + 1
        LOOP UNTIL n MOD i = 0
        whole_number_divisor = i
    END IF
END FUNCTION
