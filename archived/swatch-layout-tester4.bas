'best version so far

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

DIM SHARED AS LONG CANVAS, guide_pat
DIM SHARED AS INTEGER w, h, c, rows, cols, cell_w, cell_h, i, row, col, guide_opac
DIM SHARED AS INTEGER off_x, off_y, x1, y1, x2, y2, max_c, min_c, unused, cc
DIM SHARED AS INTEGER grid, y
DIM SHARED AS INTEGER rnd_r_bright, rnd_g_bright, rnd_b_bright, small_off, large_off
DIM SHARED AS INTEGER r_contrast, g_contrast, b_contrast
DIM SHARED AS INTEGER min_contrast, max_contrast
DIM SHARED AS INTEGER max_r_bright, max_g_bright, max_b_bright
DIM SHARED AS INTEGER min_r_bright, min_g_bright, min_b_bright
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
h         = 54
w         = 342
off_x     = 100
off_y     = 300
max_c     = 256
min_c     = 2

' reset the colors to sane values
reset_colors

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
            CASE "'"
                grid = NOT grid
                draw_output
            CASE "R"
                r_contrast = r_contrast + small_off
            CASE "r"
                r_contrast = r_contrast - small_off
            CASE "G"
                g_contrast = g_contrast + small_off
            CASE "g"
                g_contrast = g_contrast - small_off
            CASE "B"
                b_contrast = b_contrast + small_off
            CASE "b"
                b_contrast = b_contrast - small_off
            CASE "="
                rnd_r_bright = rnd_r_bright + small_off
                rnd_g_bright = rnd_g_bright + small_off
                rnd_b_bright = rnd_b_bright + small_off
            CASE "-"
                rnd_r_bright = rnd_r_bright - small_off
                rnd_g_bright = rnd_g_bright - small_off
                rnd_b_bright = rnd_b_bright - small_off
            CASE "+"
                r_contrast = r_contrast + small_off
                g_contrast = g_contrast + small_off
                b_contrast = b_contrast + small_off
            CASE "_"
                r_contrast = r_contrast - small_off
                g_contrast = g_contrast - small_off
                b_contrast = b_contrast - small_off
            CASE "0"
                reset_colors
        END SELECT

        IF rnd_r_bright > max_r_bright THEN rnd_r_bright = max_r_bright
        IF rnd_g_bright > max_g_bright THEN rnd_g_bright = max_g_bright
        IF rnd_b_bright > max_b_bright THEN rnd_b_bright = max_b_bright
        IF rnd_r_bright < min_r_bright THEN rnd_r_bright = min_r_bright
        IF rnd_g_bright < min_g_bright THEN rnd_g_bright = min_g_bright
        IF rnd_b_bright < min_b_bright THEN rnd_b_bright = min_b_bright

        IF r_contrast > max_contrast THEN r_contrast  = max_contrast
        IF g_contrast > max_contrast THEN g_contrast  = max_contrast
        IF b_contrast > max_contrast THEN b_contrast  = max_contrast
        IF r_contrast < min_contrast THEN r_contrast  = min_contrast
        IF g_contrast < min_contrast THEN g_contrast  = min_contrast
        IF b_contrast < min_contrast THEN b_contrast  = min_contrast

        draw_output
    END IF
LOOP


''
' Resets the colors :D
'
SUB reset_colors
    c             = 256
    cc            = 256
    r_contrast    = 255
    g_contrast    = 255
    b_contrast    = 255
    min_contrast  = 0
    max_contrast  = 255
    min_r_bright  = -255
    min_g_bright  = -255
    min_b_bright  = -255
    max_r_bright  = 255
    max_g_bright  = 255
    max_b_bright  = 255
    rnd_r_bright  = 0
    rnd_g_bright  = 0
    rnd_b_bright  = 0
    small_off     = 16
    large_off     = 32
END SUB


''
' Draw the output
'
SUB draw_output
    DIM AS LONG old_dest, img_w, img_h, tmp_img
    DIM AS INTEGER r, g, b
    old_dest = _DEST
    CLS, bg_color
    _PRINTMODE _KEEPBACKGROUND
    COLOR text_color

    'determine swatch layout
    rows    = whole_number_divisor(c)
    rows    = c / 32
    IF rows = 0 THEN rows = 2
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
    PRINT "Brightness R: " + _TRIM$(STR$(rnd_r_bright)), "G: " + _TRIM$(STR$(rnd_g_bright)), "B: " + _TRIM$(STR$(rnd_b_bright))
    PRINT "Contrast   R: " + _TRIM$(STR$(r_contrast)), "G: " + _TRIM$(STR$(g_contrast)), "B: " + _TRIM$(STR$(b_contrast))

    'draw commands
    PRINT
    COLOR cmd_color
    PRINT "The swatch grid should remain inside the guides."
    PRINT "The swatch grid does best effort to fill the space."
    PRINT
    PRINT "0 = RESET COLORS"
    PRINT "Set color count: 1=2, 2=4, 3=8, 4=16, 5=32, 6=64, 7=128, 8=256"
    PRINT "Adjust Brightness: - / = by " + _TRIM$(STR$(small_off)),
    PRINT "Adjust Contrast: _ / + by " + _TRIM$(STR$(small_off)),
    PRINT "Adjust Values: [rR]ed [gG]reen [bB]lue by " + _TRIM$(STR$(small_off))
    PRINT "a = add color, s = subtract color, ' = toggle grid, ESC = exit"

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
            r = INT(RND * r_contrast) + rnd_r_bright
            g = INT(RND * g_contrast) + rnd_g_bright
            b = INT(RND * b_contrast) + rnd_b_bright
            LINE (x1, y1)-(x2, y2), _RGB32(r, g, b), BF
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
