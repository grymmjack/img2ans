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
'$INCLUDE:'include/QB64_GJ_LIB/IMGADJ/IMGADJ.BI'

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
DIM SHARED AS LONG img_adjusted  ' Adjusted version of original image with all effects applied
DIM SHARED AS INTEGER cur_pal, cur_img, cur_scaler
DIM SHARED AS STRING k, img_file, pal_file, FONT_DIR, FONT_FILE
DIM SHARED AS _BYTE dithering_enabled
DIM SHARED AS INTEGER dither_method
DIM SHARED AS SINGLE zoom, zoom_adj, zoom_min, zoom_max
DIM SHARED AS SINGLE dither_amount

' Image adjustment parameters - these chain together
DIM SHARED AS INTEGER adj_brightness     ' -100 to +100
DIM SHARED AS INTEGER adj_contrast       ' -100 to +100  
DIM SHARED AS INTEGER adj_pixelate       ' 1 to 20 pixel size
DIM SHARED AS INTEGER adj_hue            ' -180 to +180 degrees
DIM SHARED AS INTEGER adj_threshold      ' 0 to 255
DIM SHARED AS INTEGER adj_posterize      ' 2 to 32 levels
DIM SHARED AS SINGLE adj_colorize_hue    ' 0 to 360 degrees
DIM SHARED AS SINGLE adj_colorize_sat    ' 0.0 to 1.0
DIM SHARED AS INTEGER adj_gamma          ' -100 to +100
DIM SHARED AS INTEGER adj_film_grain     ' 0 to 100
DIM SHARED AS _BYTE adj_invert           ' 0 = off, 1 = on
DIM SHARED AS INTEGER adj_levels_in_min  ' 0 to 255
DIM SHARED AS INTEGER adj_levels_in_max  ' 0 to 255  
DIM SHARED AS INTEGER adj_levels_out_min ' 0 to 255
DIM SHARED AS INTEGER adj_levels_out_max ' 0 to 255
DIM SHARED AS INTEGER adj_color_bal_r    ' -100 to +100
DIM SHARED AS INTEGER adj_color_bal_g    ' -100 to +100
DIM SHARED AS INTEGER adj_color_bal_b    ' -100 to +100
DIM SHARED AS _BYTE adj_needs_update     ' Flag to rebuild adjusted image
DIM SHARED pal_files(0) AS STRING
DIM SHARED img_files(0) AS STRING
DIM SHARED pal_files_sorted(0) AS STRING
DIM SHARED img_files_sorted(0) AS STRING

' Palette cache for faster lookups
DIM SHARED palette_cache_r(255) AS INTEGER
DIM SHARED palette_cache_g(255) AS INTEGER  
DIM SHARED palette_cache_b(255) AS INTEGER
DIM SHARED palette_cache_valid AS INTEGER
DIM SHARED palette_cache_dst AS LONG

DIM SHARED scalers(6) AS STRING
scalers$(0) = "ADAPTIVE"
scalers$(1) = "SXBR2"
scalers$(2) = "MMPX2"
scalers$(3) = "HQ2XA"
scalers$(4) = "HQ2XB"
scalers$(5) = "HQ3XA"
scalers$(6) = "HQ3XB"

cur_scaler% = 0

' Dithering is disabled by default
dithering_enabled = 0 ' 0 = OFF, 1 = ON
dither_method = 4     ' Default to Floyd-Steinberg (method 4)
dither_amount = 0.5   ' 0.0 = no dither, 1.0 = full dither, 0.5 = 50%

' Initialize image adjustments to default (no change) values
adj_brightness = 0
adj_contrast = 0
adj_pixelate = 1
adj_hue = 0
adj_threshold = 128
adj_posterize = 16
adj_colorize_hue = 0
adj_colorize_sat = 0
adj_gamma = 0
adj_film_grain = 0
adj_invert = 0
adj_levels_in_min = 0
adj_levels_in_max = 255
adj_levels_out_min = 0
adj_levels_out_max = 255
adj_color_bal_r = 0
adj_color_bal_g = 0
adj_color_bal_b = 0
adj_needs_update = _TRUE  ' Start with update needed

' Initialize the IMGADJ library
GJ_IMGADJ_Init

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
    CONST CANVAS_W&  = 2400
    CONST CANVAS_H&  = 1200
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

' Load the default image and palette
CALL files_to_array(_STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$ + "tests-external" + SLASH$, "*", img_files$())
CALL ARR_STR.sort(img_files$(), img_files_sorted$())
CALL files_to_array(_STARTDIR$ + SLASH$ + "resources" + SLASH$ + "palettes" + SLASH$, "*.GPL", pal_files$())
CALL ARR_STR.sort(pal_files$(), pal_files_sorted$())

' Try to find the default image in the sorted list, otherwise use first available
DIM default_img_path AS STRING
default_img_path = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "images" + SLASH$ + "tests-external" + SLASH$ + "08_creon.gif"
cur_img% = ARR_STR.find%(img_files_sorted$(), default_img_path)
IF cur_img% < 0 AND UBOUND(img_files_sorted$) >= 0 THEN cur_img% = 0

' Try to find the default palette in the sorted list, otherwise use first available
DIM default_pal_path AS STRING
default_pal_path = _STARTDIR$ + SLASH$ + "resources" + SLASH$ + "palettes" + SLASH$ + "EGA (16).GPL"
cur_pal% = ARR_STR.find%(pal_files_sorted$(), default_pal_path)
IF cur_pal% < 0 AND UBOUND(pal_files_sorted$) >= 0 THEN cur_pal% = 0

' Load initial image and palette
IF UBOUND(img_files_sorted$) >= 0 AND _FILEEXISTS(img_files_sorted$(cur_img%)) THEN
    IF dithering_enabled THEN
        img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
    ELSE
        img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
    END IF
    img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
    IF UBOUND(pal_files_sorted$) >= 0 THEN
        load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
    ELSE
        load_default_ega_palette img_pal
    END IF
END IF

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
        CASE "+"
            dither_amount = dither_amount + 0.1
            IF dither_amount > 2.0 THEN dither_amount = 2.0
            draw_output
        CASE "-"
            dither_amount = dither_amount - 0.1
            IF dither_amount < 0.0 THEN dither_amount = 0.0
            draw_output
        CASE "<", ","
            ' Previous dithering method (using < key, but , key for compatibility)
            IF k$ = "," THEN
                prev_scaler
                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF dithering_enabled THEN
                    img_orig = _LOADIMAGE(img_file$, 32)
                ELSE
                    img_orig = _LOADIMAGE(img_file$, 256, scalers$(cur_scaler%))
                END IF            
                draw_output
            ELSE
                dither_method = dither_method - 1
                IF dither_method < 0 THEN dither_method = GetDitherMethodCount% - 1
                draw_output
            END IF
        CASE ">", "."
            ' Next dithering method (using > key, but . key for compatibility)
            IF k$ = "." THEN
                next_scaler
                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF dithering_enabled THEN
                    img_orig = _LOADIMAGE(img_file$, 32)
                ELSE
                    img_orig = _LOADIMAGE(img_file$, 256, scalers$(cur_scaler%))
                END IF            
                draw_output
            ELSE
                dither_method = dither_method + 1
                IF dither_method >= GetDitherMethodCount% THEN dither_method = 0
                draw_output
            END IF
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
            IF UBOUND(pal_files_sorted$) >= 0 AND img_pal <> 0 THEN
                load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            END IF
            draw_output
        CASE CHR$(0) + CHR$(77) 'right arrow
            next_pal_file
            IF UBOUND(pal_files_sorted$) >= 0 AND img_pal <> 0 THEN
                load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
            END IF
            draw_output
        CASE CHR$(0) + CHR$(73) 'page up - prev image
            ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
            prev_img_file
            IF UBOUND(img_files_sorted$) >= 0 AND _FILEEXISTS(img_files_sorted$(cur_img%)) THEN
                ' IF img_orig <> 0 THEN _FREEIMAGE img_orig
                ' IF img_pal <> 0 THEN _FREEIMAGE img_pal
                ' IF img_adjusted <> 0 THEN _FREEIMAGE img_adjusted
                reset_adjustments
                IF dithering_enabled THEN
                    img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
                ELSE
                    img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                IF UBOUND(pal_files_sorted$) >= 0 THEN
                    load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
                ELSE
                    load_default_ega_palette img_pal
                END IF
            END IF
            draw_output
        CASE CHR$(0) + CHR$(81) 'page down - next image
            next_img_file
            IF UBOUND(img_files_sorted$) >= 0 AND _FILEEXISTS(img_files_sorted$(cur_img%)) THEN
                ' IF img_orig <> 0 THEN _FREEIMAGE img_orig
                ' IF img_pal <> 0 THEN _FREEIMAGE img_pal
                ' IF img_adjusted <> 0 THEN _FREEIMAGE img_adjusted
                reset_adjustments
                IF dithering_enabled THEN
                    img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
                ELSE
                    img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
                END IF
                img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                IF UBOUND(pal_files_sorted$) >= 0 THEN
                    load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
                ELSE
                    load_default_ega_palette img_pal
                END IF
            END IF
            draw_output
        CASE "r", "R":
            ' Reset all adjustments
            reset_adjustments
            draw_output
        CASE "b", "B":
            ' Adjust brightness
            DIM brightness_input AS STRING
            brightness_input = _INPUTBOX$("IMG2PAL", "Brightness (-100 to +100)", _TRIM$(STR$(adj_brightness)))
            IF LEN(brightness_input) <> 0 THEN
                DIM new_brightness AS INTEGER
                new_brightness = VAL(brightness_input)
                IF new_brightness >= -100 AND new_brightness <= 100 THEN
                    adj_brightness = new_brightness
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "c", "C":
            ' Adjust contrast
            DIM contrast_input AS STRING
            contrast_input = _INPUTBOX$("IMG2PAL", "Contrast (-100 to +100)", _TRIM$(STR$(adj_contrast)))
            IF LEN(contrast_input) <> 0 THEN
                DIM new_contrast AS INTEGER
                new_contrast = VAL(contrast_input)
                IF new_contrast >= -100 AND new_contrast <= 100 THEN
                    adj_contrast = new_contrast
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "x", "X":
            ' Adjust pixelate
            DIM pixelate_input AS STRING
            pixelate_input = _INPUTBOX$("IMG2PAL", "Pixelate Size (1 to 20)", _TRIM$(STR$(adj_pixelate)))
            IF LEN(pixelate_input) <> 0 THEN
                DIM new_pixelate AS INTEGER
                new_pixelate = VAL(pixelate_input)
                IF new_pixelate >= 1 AND new_pixelate <= 20 THEN
                    adj_pixelate = new_pixelate
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "u", "U":
            ' Adjust hue shift
            DIM hue_input AS STRING
            hue_input = _INPUTBOX$("IMG2PAL", "Hue Shift (-180 to +180 degrees)", _TRIM$(STR$(adj_hue)))
            IF LEN(hue_input) <> 0 THEN
                DIM new_hue AS INTEGER
                new_hue = VAL(hue_input)
                IF new_hue >= -180 AND new_hue <= 180 THEN
                    adj_hue = new_hue
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "z", "Z":
            ' Adjust colorize
            DIM colorize_input AS STRING
            colorize_input = _INPUTBOX$("IMG2PAL", "Colorize Hue (0 to 360 degrees)", _TRIM$(STR$(adj_colorize_hue)))
            IF LEN(colorize_input) <> 0 THEN
                DIM new_colorize_hue AS SINGLE
                new_colorize_hue = VAL(colorize_input)
                IF new_colorize_hue >= 0 AND new_colorize_hue <= 360 THEN
                    adj_colorize_hue = new_colorize_hue
                    ' Ask for saturation too
                    DIM colorize_sat_input AS STRING
                    colorize_sat_input = _INPUTBOX$("IMG2PAL", "Colorize Saturation (0.0 to 1.0)", _TRIM$(STR$(adj_colorize_sat)))
                    IF LEN(colorize_sat_input) <> 0 THEN
                        DIM new_colorize_sat AS SINGLE
                        new_colorize_sat = VAL(colorize_sat_input)
                        IF new_colorize_sat >= 0.0 AND new_colorize_sat <= 1.0 THEN
                            adj_colorize_sat = new_colorize_sat
                            adj_needs_update = _TRUE
                            draw_output
                        END IF
                    END IF
                END IF
            END IF
        CASE "t", "T":
            ' Adjust threshold
            DIM threshold_input AS STRING
            threshold_input = _INPUTBOX$("IMG2PAL", "Threshold (0 to 255)", _TRIM$(STR$(adj_threshold)))
            IF LEN(threshold_input) <> 0 THEN
                DIM new_threshold AS INTEGER
                new_threshold = VAL(threshold_input)
                IF new_threshold >= 0 AND new_threshold <= 255 THEN
                    adj_threshold = new_threshold
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "o", "O":
            ' Adjust posterize
            DIM posterize_input AS STRING
            posterize_input = _INPUTBOX$("IMG2PAL", "Posterize Levels (2 to 32)", _TRIM$(STR$(adj_posterize)))
            IF LEN(posterize_input) <> 0 THEN
                DIM new_posterize AS INTEGER
                new_posterize = VAL(posterize_input)
                IF new_posterize >= 2 AND new_posterize <= 32 THEN
                    adj_posterize = new_posterize
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "g", "G":
            ' Adjust gamma
            DIM gamma_input AS STRING
            gamma_input = _INPUTBOX$("IMG2PAL", "Gamma (-100 to +100)", _TRIM$(STR$(adj_gamma)))
            IF LEN(gamma_input) <> 0 THEN
                DIM new_gamma AS INTEGER
                new_gamma = VAL(gamma_input)
                IF new_gamma >= -100 AND new_gamma <= 100 THEN
                    adj_gamma = new_gamma
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "f", "F":
            ' Adjust film grain
            DIM grain_input AS STRING
            grain_input = _INPUTBOX$("IMG2PAL", "Film Grain (0 to 100)", _TRIM$(STR$(adj_film_grain)))
            IF LEN(grain_input) <> 0 THEN
                DIM new_grain AS INTEGER
                new_grain = VAL(grain_input)
                IF new_grain >= 0 AND new_grain <= 100 THEN
                    adj_film_grain = new_grain
                    adj_needs_update = _TRUE
                    draw_output
                END IF
            END IF
        CASE "i", "I":
            ' Toggle invert
            adj_invert = NOT adj_invert
            adj_needs_update = _TRUE
            draw_output
        CASE "v", "V":
            ' Adjust levels
            DIM levels_input AS STRING
            levels_input = _INPUTBOX$("IMG2PAL", "Levels Input Min (0 to 255)", _TRIM$(STR$(adj_levels_in_min)))
            IF LEN(levels_input) <> 0 THEN
                DIM new_levels_in_min AS INTEGER
                new_levels_in_min = VAL(levels_input)
                IF new_levels_in_min >= 0 AND new_levels_in_min <= 255 THEN
                    adj_levels_in_min = new_levels_in_min
                    ' Ask for input max
                    levels_input = _INPUTBOX$("IMG2PAL", "Levels Input Max (0 to 255)", _TRIM$(STR$(adj_levels_in_max)))
                    IF LEN(levels_input) <> 0 THEN
                        DIM new_levels_in_max AS INTEGER
                        new_levels_in_max = VAL(levels_input)
                        IF new_levels_in_max >= 0 AND new_levels_in_max <= 255 THEN
                            adj_levels_in_max = new_levels_in_max
                            ' Ask for output min
                            levels_input = _INPUTBOX$("IMG2PAL", "Levels Output Min (0 to 255)", _TRIM$(STR$(adj_levels_out_min)))
                            IF LEN(levels_input) <> 0 THEN
                                DIM new_levels_out_min AS INTEGER
                                new_levels_out_min = VAL(levels_input)
                                IF new_levels_out_min >= 0 AND new_levels_out_min <= 255 THEN
                                    adj_levels_out_min = new_levels_out_min
                                    ' Ask for output max
                                    levels_input = _INPUTBOX$("IMG2PAL", "Levels Output Max (0 to 255)", _TRIM$(STR$(adj_levels_out_max)))
                                    IF LEN(levels_input) <> 0 THEN
                                        DIM new_levels_out_max AS INTEGER
                                        new_levels_out_max = VAL(levels_input)
                                        IF new_levels_out_max >= 0 AND new_levels_out_max <= 255 THEN
                                            adj_levels_out_max = new_levels_out_max
                                            adj_needs_update = _TRUE
                                            draw_output
                                        END IF
                                    END IF
                                END IF
                            END IF
                        END IF
                    END IF
                END IF
            END IF
        CASE "n", "N":
            ' Adjust color balance
            DIM balance_input AS STRING
            balance_input = _INPUTBOX$("IMG2PAL", "Color Balance Red (-100 to +100)", _TRIM$(STR$(adj_color_bal_r)))
            IF LEN(balance_input) <> 0 THEN
                DIM new_bal_r AS INTEGER
                new_bal_r = VAL(balance_input)
                IF new_bal_r >= -100 AND new_bal_r <= 100 THEN
                    adj_color_bal_r = new_bal_r
                    ' Ask for green
                    balance_input = _INPUTBOX$("IMG2PAL", "Color Balance Green (-100 to +100)", _TRIM$(STR$(adj_color_bal_g)))
                    IF LEN(balance_input) <> 0 THEN
                        DIM new_bal_g AS INTEGER
                        new_bal_g = VAL(balance_input)
                        IF new_bal_g >= -100 AND new_bal_g <= 100 THEN
                            adj_color_bal_g = new_bal_g
                            ' Ask for blue
                            balance_input = _INPUTBOX$("IMG2PAL", "Color Balance Blue (-100 to +100)", _TRIM$(STR$(adj_color_bal_b)))
                            IF LEN(balance_input) <> 0 THEN
                                DIM new_bal_b AS INTEGER
                                new_bal_b = VAL(balance_input)
                                IF new_bal_b >= -100 AND new_bal_b <= 100 THEN
                                    adj_color_bal_b = new_bal_b
                                    adj_needs_update = _TRUE
                                    draw_output
                                END IF
                            END IF
                        END IF
                    END IF
                END IF
            END IF
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
                IF img_orig <> 0 THEN
                    _FREEIMAGE img_orig
                    img_orig = 0
                END IF

                IF img_pal <> 0 THEN
                    _FREEIMAGE img_pal
                    img_pal = 0
                END IF

                IF img_adjusted <> 0 THEN
                    ' _FREEIMAGE img_adjusted
                    img_adjusted = 0
                END IF

                reset_adjustments

                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF dithering_enabled THEN
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
            IF img_pal <> 0 THEN
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
            dithering_enabled = NOT dithering_enabled
            ' Always redraw to update the dither state, and reload image if one exists
            IF img_orig <> 0 AND UBOUND(img_files_sorted$) >= 0 THEN
                IF img_orig <> 0 THEN
                    _FREEIMAGE img_orig
                    img_orig = 0
                END IF
                IF img_pal <> 0 THEN
                    _FREEIMAGE img_pal
                    img_pal = 0
                END IF
                IF img_adjusted <> 0 THEN
                    ' _FREEIMAGE img_adjusted
                    img_adjusted = 0
                END IF
                reset_adjustments
                ' Convert the image to 8bpp with an adaptive palette using QB64-PE's native conversion features
                IF _FILEEXISTS(img_files_sorted$(cur_img%)) THEN
                    IF dithering_enabled THEN
                        img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 32)
                    ELSE
                        img_orig = _LOADIMAGE(img_files_sorted$(cur_img%), 256, scalers$(cur_scaler%))
                    END IF
                    img_pal = _NEWIMAGE(_WIDTH(img_orig), _HEIGHT(img_orig), 256)
                    IF UBOUND(pal_files_sorted$) >= 0 THEN
                        load_gpl_palette pal_files_sorted$(cur_pal%), img_pal
                    ELSE
                        load_default_ega_palette img_pal
                    END IF
                END IF
            END IF
            draw_output
        CASE "s":
            ' Save the image with the palette
            IF img_pal <> 0 THEN
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
            _MESSAGEBOX "IMG2PAL", "L=LOAD,P=PAL,D=DITH:ON/OFF,+/-=DITH AMT,<>=DITH METH,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER" + CHR$(13) + CHR$(10) + "ADJUSTMENTS: B=BRIGHTNESS,C=CONTRAST,X=PIXELATE,U=HUE,Z=COLORIZE,T=THRESHOLD,O=POSTERIZE" + CHR$(13) + CHR$(10) + "MORE ADJ: G=GAMMA,F=FILM GRAIN,I=INVERT,V=LEVELS,N=COLOR BALANCE,R=RESET ADJ,ESC=QUIT", "info"
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
        CASE "q", "Q":
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

IF img_orig <> 0 THEN _FREEIMAGE img_orig
IF img_pal <> 0 THEN _FREEIMAGE img_pal
IF img_adjusted <> 0 THEN _FREEIMAGE img_adjusted
SCREEN 0
_FREEIMAGE CANVAS
SYSTEM



''
' Reset all image adjustments to default values
'
SUB reset_adjustments
    adj_brightness = 0
    adj_contrast = 0
    adj_pixelate = 1
    adj_hue = 0
    adj_threshold = 128
    adj_posterize = 16
    adj_colorize_hue = 0
    adj_colorize_sat = 0
    adj_gamma = 0
    adj_film_grain = 0
    adj_invert = 0
    adj_levels_in_min = 0
    adj_levels_in_max = 255
    adj_levels_out_min = 0
    adj_levels_out_max = 255
    adj_color_bal_r = 0
    adj_color_bal_g = 0
    adj_color_bal_b = 0
    adj_needs_update = _TRUE
END SUB

''
' Apply all chained adjustments to create the adjusted image
' This rebuilds img_adjusted from img_orig with all current adjustment values
'
SUB apply_adjustments
    IF img_orig <> 0 THEN
        ' Free previous adjusted image if it exists
        ' IF img_adjusted <> 0 THEN _FREEIMAGE img_adjusted
        
        ' Start with a copy of the original
        img_adjusted = GJ_IMGADJ_CloneImage&(img_orig)
        
        ' Apply adjustments in order (each one modifies the result of the previous)
        
        ' 1. Brightness
        IF adj_brightness <> 0 THEN
            DIM temp_bright AS LONG
            IF adj_brightness > 0 THEN
                temp_bright = GJ_IMGADJ_Brightness(img_adjusted, "+", adj_brightness)
            ELSE
                temp_bright = GJ_IMGADJ_Brightness(img_adjusted, "-", ABS(adj_brightness))
            END IF
            IF temp_bright <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_bright
            END IF
        END IF
        
        ' 2. Contrast  
        IF adj_contrast <> 0 THEN
            DIM temp_contrast AS LONG
            IF adj_contrast > 0 THEN
                temp_contrast = GJ_IMGADJ_Contrast(img_adjusted, "+", adj_contrast)
            ELSE
                temp_contrast = GJ_IMGADJ_Contrast(img_adjusted, "-", ABS(adj_contrast))
            END IF
            IF temp_contrast <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_contrast
            END IF
        END IF
        
        ' 3. Hue shift
        IF adj_hue <> 0 THEN
            DIM temp_hue AS LONG
            IF adj_hue > 0 THEN
                temp_hue = GJ_IMGADJ_Hue(img_adjusted, "+", adj_hue)
            ELSE
                temp_hue = GJ_IMGADJ_Hue(img_adjusted, "-", ABS(adj_hue))
            END IF
            IF temp_hue <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_hue
            END IF
        END IF
        
        ' 4. Colorize (only if saturation > 0)
        IF adj_colorize_sat > 0 THEN
            DIM temp_colorize AS LONG
            temp_colorize = GJ_IMGADJ_Colorize(img_adjusted, adj_colorize_hue, adj_colorize_sat)
            IF temp_colorize <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_colorize
            END IF
        END IF
        
        ' 5. Threshold (only if not default value of 128)
        IF adj_threshold <> 128 THEN
            DIM temp_threshold AS LONG
            temp_threshold = GJ_IMGADJ_Threshold(img_adjusted, adj_threshold, GJ_IMGADJ_THRESHOLD_BINARY)
            IF temp_threshold <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_threshold
            END IF
        END IF
        
        ' 6. Posterize (only if not default value of 16)
        IF adj_posterize <> 16 THEN
            DIM temp_posterize AS LONG
            temp_posterize = GJ_IMGADJ_Posterize(img_adjusted, adj_posterize)
            IF temp_posterize <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_posterize
            END IF
        END IF
        
        ' 7. Gamma
        IF adj_gamma <> 0 THEN
            DIM temp_gamma AS LONG
            IF adj_gamma > 0 THEN
                temp_gamma = GJ_IMGADJ_Gamma(img_adjusted, "+", adj_gamma)
            ELSE
                temp_gamma = GJ_IMGADJ_Gamma(img_adjusted, "-", ABS(adj_gamma))
            END IF
            IF temp_gamma <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_gamma
            END IF
        END IF
        
        ' 8. Film Grain
        IF adj_film_grain > 0 THEN
            DIM temp_grain AS LONG
            temp_grain = GJ_IMGADJ_FilmGrain(img_adjusted, adj_film_grain)
            IF temp_grain <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_grain
            END IF
        END IF
        
        ' 9. Invert
        IF adj_invert THEN
            DIM temp_invert AS LONG
            temp_invert = GJ_IMGADJ_Invert(img_adjusted)
            IF temp_invert <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_invert
            END IF
        END IF
        
        ' 10. Levels
        IF adj_levels_in_min <> 0 OR adj_levels_in_max <> 255 OR adj_levels_out_min <> 0 OR adj_levels_out_max <> 255 THEN
            DIM temp_levels AS LONG
            temp_levels = GJ_IMGADJ_Levels(img_adjusted, adj_levels_in_min, adj_levels_in_max, adj_levels_out_min, adj_levels_out_max)
            IF temp_levels <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_levels
            END IF
        END IF
        
        ' 11. Color Balance
        IF adj_color_bal_r <> 0 OR adj_color_bal_g <> 0 OR adj_color_bal_b <> 0 THEN
            DIM temp_balance AS LONG
            temp_balance = GJ_IMGADJ_ColorBalance(img_adjusted, adj_color_bal_r, adj_color_bal_g, adj_color_bal_b)
            IF temp_balance <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_balance
            END IF
        END IF
        
        ' 12. Pixelate (only if > 1)
        IF adj_pixelate > 1 THEN
            DIM temp_pixelate AS LONG
            temp_pixelate = GJ_IMGADJ_Pixelate(img_adjusted, adj_pixelate)
            IF temp_pixelate <> 0 THEN
                ' _FREEIMAGE img_adjusted
                img_adjusted = temp_pixelate
            END IF
        END IF
        
        adj_needs_update = 0  ' Mark as up to date
    END IF
END SUB

''
' Upates the status with command help
' 
SUB update_status
    DIM AS STRING c, z, s
    c$ = "L=LOAD,"
    c$ = c$ + "P=PAL,"
    c$ = c$ + "UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX)"
    c$ = c$ + "D=DITH:" + _TRIM$(STR$(dithering_enabled))
    c$ = c$ + "PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT"
    z$ = "ZOOM=" + _TRIM$(STR$(zoom))
    s$ = "-SCALER=" +  scalers$(cur_scaler%)
    IF dithering_enabled THEN
        PRINT "L=LOAD,P=PAL,D=DITH:ON,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=OFF"
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")"
        PRINT "ADJ: [R]ESET [B]RIGHTNESS [C]ONTRAST PI[X]ELATE H[U]E SHIFT COLORI[Z]E [T]HRESHOLD P[O]STERIZE [G]AMMA [F]ILM GRAIN [I]NVERT LE[V]ELS  COL BALA[N]CE"        
        PRINT "VAL: B=" + _TRIM$(STR$(adj_brightness)) + " C=" + _TRIM$(STR$(adj_contrast)) + " H=" + _TRIM$(STR$(adj_hue)) + " P=" + _TRIM$(STR$(adj_pixelate)) + " T=" + _TRIM$(STR$(adj_threshold)) + " G=" + _TRIM$(STR$(adj_gamma)) + " F=" + _TRIM$(STR$(adj_film_grain)) + " I=" + _TRIM$(STR$(adj_invert))
    ELSE
        PRINT "L=LOAD,P=PAL,D=DITH:OFF,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,ESC=QUIT- ";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=" + scalers$(cur_scaler%)
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")" 
        PRINT "ADJ: [R]ESET [B]RIGHTNESS [C]ONTRAST PI[X]ELATE H[U]E SHIFT COLORI[Z]E [T]HRESHOLD P[O]STERIZE [G]AMMA [F]ILM GRAIN [I]NVERT LE[V]ELS  COL BALA[N]CE"        
        PRINT "VAL: B=" + _TRIM$(STR$(adj_brightness)) + " C=" + _TRIM$(STR$(adj_contrast)) + " H=" + _TRIM$(STR$(adj_hue)) + " P=" + _TRIM$(STR$(adj_pixelate)) + " T=" + _TRIM$(STR$(adj_threshold)) + " G=" + _TRIM$(STR$(adj_gamma)) + " F=" + _TRIM$(STR$(adj_film_grain)) + " I=" + _TRIM$(STR$(adj_invert))
    END IF
END SUB


SUB draw_output
    CLS
    COLOR _RGB32(255, 255, 255)
    IF dithering_enabled THEN
        PRINT "L=LOAD,P=PAL,D=DITH:ON,+/-=AMT,<>=METH,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,./,=-/+SCALER,R=RESET ADJ,ESC=QUIT";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-DITHER=" + _TRIM$(STR$(INT(dither_amount * 100))) + "%-METHOD=" + GetDitherMethodName$(dither_method)
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")"
        PRINT "ADJ: [R]ESET [B]RIGHTNESS [C]ONTRAST PI[X]ELATE H[U]E SHIFT COLORI[Z]E [T]HRESHOLD P[O]STERIZE [G]AMMA [F]ILM GRAIN [I]NVERT LE[V]ELS  COL BALA[N]CE"        
        PRINT "ADJ: B=" + _TRIM$(STR$(adj_brightness)) + " C=" + _TRIM$(STR$(adj_contrast)) + " H=" + _TRIM$(STR$(adj_hue)) + " P=" + _TRIM$(STR$(adj_pixelate)) + " T=" + _TRIM$(STR$(adj_threshold)) + " POST=" + _TRIM$(STR$(adj_posterize)) + " COL=" + _TRIM$(STR$(adj_colorize_hue)) + "/" + _TRIM$(STR$(adj_colorize_sat))
    ELSE
        PRINT "L=LOAD,P=PAL,D=DITH:OFF,UP/DN=ZOOM(+SHIFT=MORE,0=MIN,1,2,3,4=1|2|3|400%,9=MAX),PGUP|DN=-/+IMG,L|R=-/+PAL,R=RESET ADJ,ESC=QUIT";
        PRINT "ZOOM=" + _TRIM$(STR$(zoom)) + "-SCALER=" + scalers$(cur_scaler%)
        PRINT "IMAGE:" + img_files_sorted$(cur_img%) + "(" + _TRIM$(STR$(cur_img%)) + ")"
        PRINT "PAL:" + pal_files_sorted$(cur_pal%) + "(" + _TRIM$(STR$(cur_pal%)) + ")" 
        PRINT "ADJ: [R]ESET [B]RIGHTNESS [C]ONTRAST PI[X]ELATE H[U]E SHIFT COLORI[Z]E [T]HRESHOLD P[O]STERIZE [G]AMMA [F]ILM GRAIN [I]NVERT LE[V]ELS  COL BALA[N]CE"        
        PRINT "ADJ: B=" + _TRIM$(STR$(adj_brightness)) + " C=" + _TRIM$(STR$(adj_contrast)) + " H=" + _TRIM$(STR$(adj_hue)) + " P=" + _TRIM$(STR$(adj_pixelate)) + " T=" + _TRIM$(STR$(adj_threshold)) + " POST=" + _TRIM$(STR$(adj_posterize)) + " COL=" + _TRIM$(STR$(adj_colorize_hue)) + "/" + _TRIM$(STR$(adj_colorize_sat))
    END IF

    ' Apply adjustments if needed
    IF adj_needs_update AND img_orig <> 0 THEN
        apply_adjustments
    END IF

    ' Draw the images if they are loaded
    IF img_orig <> 0 THEN
        _ASSERT 1, "bh="+_TRIM$(STR$(_HEIGHT(img_orig)))
        _ASSERT 1, "bw="+_TRIM$(STR$(_WIDTH(img_orig)))
        DIM AS INTEGER dx1_orig, dy1_orig, dx2_orig, dy2_orig
        dx1_orig = 0
        dy1_orig = _FONTHEIGHT(FONTFACE&)*6  ' Make room for the extra line
        dx2_orig = INT((zoom * _WIDTH(img_orig)) + dx1_orig)
        dy2_orig = INT((zoom * _HEIGHT(img_orig)) + dy1_orig)
        _ASSERT 1, "(" _
            + _TRIM$(STR$(dx1_orig)) + "," _
            + _TRIM$(STR$(dy1_orig)) + ")-(" _
            + _TRIM$(STR$(dx2_orig)) + "," _ 
            + _TRIM$(STR$(dy2_orig)) + ")"
        
        ' Use adjusted image if available, otherwise original
        DIM source_img AS LONG
        IF img_adjusted <> 0 THEN
            source_img = img_adjusted
        ELSE
            source_img = img_orig
        END IF
        
        _PUTIMAGE (dx1_orig, dy1_orig)-(dx2_orig, dy2_orig), source_img

        ' Palletize the image only if everything is proper
        IF img_pal <> 0 THEN
            IF dithering_enabled THEN
                dither_palettize img_pal, source_img
            ELSE
                palettize img_pal, source_img
            END IF
            DIM AS INTEGER dx1_pal, dy1_pal, dx2_pal, dy2_pal
            dx1_pal = dx2_orig + IMG_PAL_SPACING&
            dy1_pal = _FONTHEIGHT(FONTFACE&)*6  ' Make room for the extra line
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
' Get the number of available dithering methods
'
FUNCTION GetDitherMethodCount%
    GetDitherMethodCount% = 15
END FUNCTION

''
' Get the name of a dithering method
'
FUNCTION GetDitherMethodName$(method AS INTEGER)
    SELECT CASE method
        CASE 0
            GetDitherMethodName$ = "No Dithering (Quantize Only)"
        CASE 1
            GetDitherMethodName$ = "Ordered Dither 2x2 (Bayer)"
        CASE 2
            GetDitherMethodName$ = "Ordered Dither 4x4 (Bayer)"
        CASE 3
            GetDitherMethodName$ = "Ordered Dither 8x8 (Bayer)"
        CASE 4
            GetDitherMethodName$ = "Floyd-Steinberg Error Diffusion"
        CASE 5
            GetDitherMethodName$ = "Jarvis-Judice-Ninke"
        CASE 6
            GetDitherMethodName$ = "Stucki Error Diffusion"
        CASE 7
            GetDitherMethodName$ = "Burkes Error Diffusion"
        CASE 8
            GetDitherMethodName$ = "Sierra Error Diffusion"
        CASE 9
            GetDitherMethodName$ = "Sierra Lite"
        CASE 10
            GetDitherMethodName$ = "Atkinson (Classic Mac)"
        CASE 11
            GetDitherMethodName$ = "Random Dithering"
        CASE 12
            GetDitherMethodName$ = "Blue Noise Dithering"
        CASE 13
            GetDitherMethodName$ = "Clustered Dot 4x4"
        CASE 14
            GetDitherMethodName$ = "Classic Halftone"
        CASE ELSE
            GetDitherMethodName$ = "Unknown Method"
    END SELECT
END FUNCTION

''
' Display progress at bottom of screen without interfering with images
'
SUB ShowProgress(message AS STRING, percent AS SINGLE)
    DIM oldDest AS LONG
    oldDest = _DEST
    _DEST CANVAS
    
    ' Calculate position at bottom of screen
    DIM progress_y AS INTEGER
    progress_y = _HEIGHT(CANVAS) - _FONTHEIGHT(FONTFACE&) - 10
    
    ' Clear the progress line area
    LINE (0, progress_y)-((_WIDTH(CANVAS)), _HEIGHT(CANVAS)), _RGB32(0, 0, 0), BF
    
    ' Display progress message
    COLOR _RGB32(255, 255, 0) ' Yellow for visibility
    _PRINTSTRING (10, progress_y), message + " " + _TRIM$(STR$(INT(percent))) + "%"
    
    _DEST oldDest
END SUB

''
' Clear progress display
'
SUB ClearProgress
    DIM oldDest AS LONG
    oldDest = _DEST
    _DEST CANVAS
    
    ' Calculate position at bottom of screen  
    DIM progress_y AS INTEGER
    progress_y = _HEIGHT(CANVAS) - _FONTHEIGHT(FONTFACE&) - 10
    
    ' Clear the progress line area
    LINE (0, progress_y)-((_WIDTH(CANVAS)), _HEIGHT(CANVAS)), _RGB32(0, 0, 0), BF
    
    _DEST oldDest
END SUB
SUB UpdatePaletteCache(dst AS LONG)
    DIM i AS INTEGER
    DIM palColor AS _UNSIGNED LONG
    
    FOR i = 0 TO 255
        palColor = _PALETTECOLOR(i, dst)
        palette_cache_r(i) = _RED32(palColor)
        palette_cache_g(i) = _GREEN32(palColor)
        palette_cache_b(i) = _BLUE32(palColor)
    NEXT
    
    palette_cache_valid = _TRUE
    palette_cache_dst = dst
    
    $IF NDEBUG = FALSE THEN
        _ASSERT 1, "Palette cache updated for image handle " + STR$(dst)
    $END IF
END SUB

''
' Find nearest palette color index (optimized with cache)
'
FUNCTION NearestPaletteIndex%(r AS INTEGER, g AS INTEGER, b AS INTEGER, dst AS LONG)
    DIM i AS INTEGER, bestI AS INTEGER
    DIM dr AS INTEGER, dg AS INTEGER, db AS INTEGER
    DIM dist AS LONG, bestDist AS LONG
    
    ' Update cache if needed
    IF NOT palette_cache_valid OR palette_cache_dst <> dst THEN
        UpdatePaletteCache dst
    END IF
    
    bestDist = 999999
    bestI = 0
    
    ' Check all 256 palette entries using cached values
    FOR i = 0 TO 255
        ' Only check non-transparent colors (or allow index 0)
        IF palette_cache_r(i) + palette_cache_g(i) + palette_cache_b(i) > 0 OR i = 0 THEN
            dr = r - palette_cache_r(i)
            dg = g - palette_cache_g(i)
            db = b - palette_cache_b(i)
            ' Use faster approximate distance for better performance
            dist = dr * dr + dg * dg + db * db
            IF dist < bestDist THEN
                bestDist = dist
                bestI = i
                ' Early exit if perfect match
                IF dist = 0 THEN EXIT FOR
            END IF
        END IF
    NEXT
    
    NearestPaletteIndex% = bestI
END FUNCTION

''
' Apply ordered dithering with a given matrix
'
SUB ApplyOrderedDitherMatrix(img AS LONG, dst AS LONG, matrix() AS INTEGER, matW AS INTEGER, matH AS INTEGER, maxVal AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM threshold AS SINGLE
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    ' Update palette cache if needed
    IF NOT palette_cache_valid OR palette_cache_dst <> dst THEN
        UpdatePaletteCache dst
    END IF
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            ' Proper ordered dithering formula: normalize matrix value and apply as threshold
            ' Matrix values should be normalized to [-0.5, 0.5] range
            threshold = ((matrix(x MOD matW, y MOD matH) / maxVal) - 0.5) * 64 * dither_amount
            
            r = r + threshold
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + threshold
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + threshold
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(CINT(r), CINT(g), CINT(b), dst)
            PSET (x, y), idx
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Apply Floyd-Steinberg error diffusion (optimized)
'
SUB ApplyFloydSteinberg(img AS LONG, dst AS LONG)
    CALL ApplyErrorDiffusion(img, dst, 0)
END SUB

''
' Apply other error diffusion algorithms (optimized but fixed)
'
SUB ApplyErrorDiffusion(img AS LONG, dst AS LONG, algorithm AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, idx AS INTEGER
    DIM r AS SINGLE, g AS SINGLE, b AS SINGLE
    DIM nr AS INTEGER, ng AS INTEGER, nb AS INTEGER
    DIM er AS SINGLE, eg AS SINGLE, eb AS SINGLE
    
    ' Use single precision error buffers for accuracy
    DIM rerr1(0 TO 300) AS SINGLE, gerr1(0 TO 300) AS SINGLE, berr1(0 TO 300) AS SINGLE
    DIM rerr2(0 TO 300) AS SINGLE, gerr2(0 TO 300) AS SINGLE, berr2(0 TO 300) AS SINGLE
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    
    ' Make sure arrays are big enough
    IF w > 300 THEN
        REDIM rerr1(0 TO w) AS SINGLE, gerr1(0 TO w) AS SINGLE, berr1(0 TO w) AS SINGLE
        REDIM rerr2(0 TO w) AS SINGLE, gerr2(0 TO w) AS SINGLE, berr2(0 TO w) AS SINGLE
    END IF
    
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    ' Update palette cache if needed (this is the main optimization)
    IF NOT palette_cache_valid OR palette_cache_dst <> dst THEN
        UpdatePaletteCache dst
    END IF
    
    ' Progress indication every 10% for large images
    DIM progress_step AS LONG
    progress_step = h \ 10
    IF progress_step < 1 THEN progress_step = 1
    
    ShowProgress "Processing diffusion...", 0
    
    FOR y = 0 TO h - 1
        ' Show progress for large images
        IF (y MOD progress_step) = 0 THEN
            ShowProgress "Processing diffusion...", (y / h) * 100
        END IF
        
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + rerr1(x)
            g = _GREEN32(c) + gerr1(x)
            b = _BLUE32(c) + berr1(x)
            
            ' Clamp values
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(CINT(r), CINT(g), CINT(b), dst)
            
            ' Get the actual palette color from cache (this is faster than _PALETTECOLOR)
            nr = palette_cache_r(idx)
            ng = palette_cache_g(idx)
            nb = palette_cache_b(idx)
            
            PSET (x, y), idx
            
            ' Calculate error with dither amount
            er = (r - nr) * dither_amount
            eg = (g - ng) * dither_amount
            eb = (b - nb) * dither_amount
            
            ' Distribute error based on algorithm
            SELECT CASE algorithm
                CASE 0 ' Floyd-Steinberg
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.4375 ' 7/16
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.4375
                        berr1(x + 1) = berr1(x + 1) + eb * 0.4375
                    END IF
                    IF y < h - 1 THEN
                        IF x > 0 THEN
                            rerr2(x - 1) = rerr2(x - 1) + er * 0.1875 ' 3/16
                            gerr2(x - 1) = gerr2(x - 1) + eg * 0.1875
                            berr2(x - 1) = berr2(x - 1) + eb * 0.1875
                        END IF
                        rerr2(x) = rerr2(x) + er * 0.3125 ' 5/16
                        gerr2(x) = gerr2(x) + eg * 0.3125
                        berr2(x) = berr2(x) + eb * 0.3125
                        IF x < w - 1 THEN
                            rerr2(x + 1) = rerr2(x + 1) + er * 0.0625 ' 1/16
                            gerr2(x + 1) = gerr2(x + 1) + eg * 0.0625
                            berr2(x + 1) = berr2(x + 1) + eb * 0.0625
                        END IF
                    END IF
                    
                CASE 1 ' Jarvis-Judice-Ninke (simplified)
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.146 ' 7/48
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.146
                        berr1(x + 1) = berr1(x + 1) + eb * 0.146
                    END IF
                    IF x < w - 2 THEN
                        rerr1(x + 2) = rerr1(x + 2) + er * 0.104 ' 5/48
                        gerr1(x + 2) = gerr1(x + 2) + eg * 0.104
                        berr1(x + 2) = berr1(x + 2) + eb * 0.104
                    END IF
                    ' Next row distribution (simplified)
                    IF y < h - 1 THEN
                        rerr2(x) = rerr2(x) + er * 0.146
                        gerr2(x) = gerr2(x) + eg * 0.146
                        berr2(x) = berr2(x) + eb * 0.146
                    END IF
                    
                CASE ELSE ' Default to Floyd-Steinberg
                    IF x < w - 1 THEN
                        rerr1(x + 1) = rerr1(x + 1) + er * 0.5
                        gerr1(x + 1) = gerr1(x + 1) + eg * 0.5
                        berr1(x + 1) = berr1(x + 1) + eb * 0.5
                    END IF
            END SELECT
        NEXT
        
        ' Swap error buffers (clear old buffer as we go)
        FOR x = 0 TO w
            rerr1(x) = rerr2(x): rerr2(x) = 0
            gerr1(x) = gerr2(x): gerr2(x) = 0
            berr1(x) = berr2(x): berr2(x) = 0
        NEXT
    NEXT
    
    ClearProgress
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Apply simple quantization (no dithering) - optimized
'
SUB ApplyQuantizeOnly(img AS LONG, dst AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    ' Update palette cache if needed
    IF NOT palette_cache_valid OR palette_cache_dst <> dst THEN
        UpdatePaletteCache dst
    END IF
    
    ShowProgress "Quantizing...", 0
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            idx = NearestPaletteIndex%(r, g, b, dst)
            PSET (x, y), idx
        NEXT
    NEXT
    
    ClearProgress
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Apply ordered dithering 2x2
'
SUB ApplyOrderedDither2x2(img AS LONG, dst AS LONG)
    DIM bayer(0 TO 1, 0 TO 1) AS INTEGER
    bayer(0, 0) = 0
    bayer(0, 1) = 2
    bayer(1, 0) = 3
    bayer(1, 1) = 1
    
    CALL ApplyOrderedDitherMatrix(img, dst, bayer(), 2, 2, 4)
END SUB

''
' Apply ordered dithering 4x4
'
SUB ApplyOrderedDither4x4(img AS LONG, dst AS LONG)
    DIM bayer(0 TO 3, 0 TO 3) AS INTEGER
    ' 4x4 Bayer matrix
    bayer(0, 0) = 0: bayer(0, 1) = 8: bayer(0, 2) = 2: bayer(0, 3) = 10
    bayer(1, 0) = 12: bayer(1, 1) = 4: bayer(1, 2) = 14: bayer(1, 3) = 6
    bayer(2, 0) = 3: bayer(2, 1) = 11: bayer(2, 2) = 1: bayer(2, 3) = 9
    bayer(3, 0) = 15: bayer(3, 1) = 7: bayer(3, 2) = 13: bayer(3, 3) = 5
    
    CALL ApplyOrderedDitherMatrix(img, dst, bayer(), 4, 4, 16)
END SUB

''
' Apply ordered dithering 8x8
'
SUB ApplyOrderedDither8x8(img AS LONG, dst AS LONG)
    DIM bayer(0 TO 7, 0 TO 7) AS INTEGER
    ' 8x8 Bayer matrix
    bayer(0, 0) = 0: bayer(0, 1) = 32: bayer(0, 2) = 8: bayer(0, 3) = 40: bayer(0, 4) = 2: bayer(0, 5) = 34: bayer(0, 6) = 10: bayer(0, 7) = 42
    bayer(1, 0) = 48: bayer(1, 1) = 16: bayer(1, 2) = 56: bayer(1, 3) = 24: bayer(1, 4) = 50: bayer(1, 5) = 18: bayer(1, 6) = 58: bayer(1, 7) = 26
    bayer(2, 0) = 12: bayer(2, 1) = 44: bayer(2, 2) = 4: bayer(2, 3) = 36: bayer(2, 4) = 14: bayer(2, 5) = 46: bayer(2, 6) = 6: bayer(2, 7) = 38
    bayer(3, 0) = 60: bayer(3, 1) = 28: bayer(3, 2) = 52: bayer(3, 3) = 20: bayer(3, 4) = 62: bayer(3, 5) = 30: bayer(3, 6) = 54: bayer(3, 7) = 22
    bayer(4, 0) = 3: bayer(4, 1) = 35: bayer(4, 2) = 11: bayer(4, 3) = 43: bayer(4, 4) = 1: bayer(4, 5) = 33: bayer(4, 6) = 9: bayer(4, 7) = 41
    bayer(5, 0) = 51: bayer(5, 1) = 19: bayer(5, 2) = 59: bayer(5, 3) = 27: bayer(5, 4) = 49: bayer(5, 5) = 17: bayer(5, 6) = 57: bayer(5, 7) = 25
    bayer(6, 0) = 15: bayer(6, 1) = 47: bayer(6, 2) = 7: bayer(6, 3) = 39: bayer(6, 4) = 13: bayer(6, 5) = 45: bayer(6, 6) = 5: bayer(6, 7) = 37
    bayer(7, 0) = 63: bayer(7, 1) = 31: bayer(7, 2) = 55: bayer(7, 3) = 23: bayer(7, 4) = 61: bayer(7, 5) = 29: bayer(7, 6) = 53: bayer(7, 7) = 21
    
    CALL ApplyOrderedDitherMatrix(img, dst, bayer(), 8, 8, 64)
END SUB

''
' Apply random dithering - optimized
'
SUB ApplyRandomDither(img AS LONG, dst AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM noise AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    ' Update palette cache if needed
    IF NOT palette_cache_valid OR palette_cache_dst <> dst THEN
        UpdatePaletteCache dst
    END IF
    
    RANDOMIZE TIMER
    
    ' Progress indication for large images
    DIM progress_step AS LONG
    progress_step = h \ 10
    IF progress_step < 1 THEN progress_step = 1
    
    ShowProgress "Random dithering...", 0
    
    FOR y = 0 TO h - 1
        IF (y MOD progress_step) = 0 THEN
            ShowProgress "Random dithering...", (y / h) * 100
        END IF
        
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            noise = (RND * 64 - 32) * dither_amount
            r = r + noise
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            g = g + noise
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            b = b + noise
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b, dst)
            PSET (x, y), idx
        NEXT
    NEXT
    
    ClearProgress
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Apply blue noise dithering (simplified)
'
SUB ApplyBlueNoiseDither(img AS LONG, dst AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM noise AS INTEGER
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            
            ' Simple blue noise approximation using coordinate-based hash
            noise = (((x * 1234 + y * 5678) MOD 127) - 64) * dither_amount
            r = r + noise
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            g = g + noise
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            b = b + noise
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            idx = NearestPaletteIndex%(r, g, b, dst)
            PSET (x, y), idx
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Apply clustered dot dithering
'
SUB ApplyClusteredDot4x4(img AS LONG, dst AS LONG)
    ' Clustered dot dithering (newspaper-style halftoning)
    DIM clustered(0 TO 3, 0 TO 3) AS INTEGER
    clustered(0, 0) = 12: clustered(0, 1) = 5: clustered(0, 2) = 6: clustered(0, 3) = 13
    clustered(1, 0) = 4: clustered(1, 1) = 0: clustered(1, 2) = 1: clustered(1, 3) = 7
    clustered(2, 0) = 11: clustered(2, 1) = 3: clustered(2, 2) = 2: clustered(2, 3) = 8
    clustered(3, 0) = 15: clustered(3, 1) = 10: clustered(3, 2) = 9: clustered(3, 3) = 14
    
    CALL ApplyOrderedDitherMatrix(img, dst, clustered(), 4, 4, 16)
END SUB

''
' Apply classic halftone dithering
'
SUB ApplyHalftoneClassic(img AS LONG, dst AS LONG)
    ' Classic halftone pattern using distance from center
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM c AS _UNSIGNED LONG, r AS INTEGER, g AS INTEGER, b AS INTEGER, idx AS INTEGER
    DIM gray AS INTEGER, threshold AS INTEGER
    DIM dx AS SINGLE, dy AS SINGLE, dist AS SINGLE
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    DIM oldS AS LONG: oldS = _SOURCE
    _SOURCE img
    DIM oldD AS LONG: oldD = _DEST
    _DEST dst
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c)
            g = _GREEN32(c)
            b = _BLUE32(c)
            gray = (r + g + b) \ 3
            
            ' Calculate distance from cell center in 8x8 grid
            dx = (x MOD 8) - 4
            dy = (y MOD 8) - 4
            dist = SQR(dx * dx + dy * dy)
            threshold = (dist / 5.66) * 255 ' 5.66 is max distance
            threshold = threshold * dither_amount
            
            IF gray > threshold THEN
                idx = NearestPaletteIndex%(255, 255, 255, dst) ' Use lightest color
            ELSE
                idx = NearestPaletteIndex%(0, 0, 0, dst) ' Use darkest color
            END IF
            
            PSET (x, y), idx
        NEXT
    NEXT
    
    _SOURCE oldS
    _DEST oldD
END SUB

''
' Multi-algorithm dithering palettize with controllable intensity
' @param LONG dst The destination image. This must be an 8bpp image with the palette already loaded
' @param LONG src The source image. This must be 32bpp or 8bpp
SUB dither_palettize (dst AS LONG, src AS LONG)
    _ASSERT dst <> 0, "dst not allocated!"
    _ASSERT src <> 0, "src not allocated!"
    _ASSERT _PIXELSIZE(src) = 4 OR _PIXELSIZE(src) = 1, "src pixel format is incorrect!"
    _ASSERT _PIXELSIZE(dst) = 1, "dst pixel format is incorrect!"

    DIM oldDst AS LONG: oldDst = _DEST
    DIM oldSrc AS LONG: oldSrc = _SOURCE

    ' Apply the selected dithering method
    SELECT CASE dither_method
        CASE 0
            CALL ApplyQuantizeOnly(src, dst)
        CASE 1
            CALL ApplyOrderedDither2x2(src, dst)
        CASE 2
            CALL ApplyOrderedDither4x4(src, dst)
        CASE 3
            CALL ApplyOrderedDither8x8(src, dst)
        CASE 4
            CALL ApplyErrorDiffusion(src, dst, 0) ' Floyd-Steinberg
        CASE 5
            CALL ApplyErrorDiffusion(src, dst, 1) ' Jarvis-Judice-Ninke
        CASE 6
            CALL ApplyErrorDiffusion(src, dst, 0) ' Stucki (using Floyd-Steinberg for now)
        CASE 7
            CALL ApplyErrorDiffusion(src, dst, 0) ' Burkes (using Floyd-Steinberg for now)
        CASE 8
            CALL ApplyErrorDiffusion(src, dst, 0) ' Sierra (using Floyd-Steinberg for now)
        CASE 9
            CALL ApplyErrorDiffusion(src, dst, 0) ' Sierra Lite (using Floyd-Steinberg for now)
        CASE 10
            CALL ApplyErrorDiffusion(src, dst, 0) ' Atkinson (using Floyd-Steinberg for now)
        CASE 11
            CALL ApplyRandomDither(src, dst)
        CASE 12
            CALL ApplyBlueNoiseDither(src, dst)
        CASE 13
            CALL ApplyClusteredDot4x4(src, dst)
        CASE 14
            CALL ApplyHalftoneClassic(src, dst)
        CASE ELSE
            CALL ApplyErrorDiffusion(src, dst, 0) ' Default to Floyd-Steinberg
    END SELECT

    _SOURCE oldSrc
    _DEST oldDst
END SUB



''
' Palletize src using the palette in dst. The resulting image is stored in dst
' @param LONG dst The destination image. This must be an 8bpp image with the palette already loaded
' @param LONG src The source image. This must be an 8bpp image with its own palette
'
SUB palettize (dst AS LONG, src AS LONG)
    _ASSERT dst <> 0, "dst not allocated!"
    _ASSERT src <> 0, "src not allocated!"
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
    _ASSERT dst <> 0, "dst not allocated!"
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

    ' Invalidate palette cache since we changed the palette
    palette_cache_valid = 0

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

    _ASSERT dst <> 0, "dst not allocated!"
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
    
    ' Invalidate palette cache since we changed the palette
    palette_cache_valid = 0

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
        ' Filter out directories and system files
        IF fn$ <> "./" AND fn$ <> "../" AND fn$ <> "." AND fn$ <> ".." AND fn$ <> ".DS_Store" AND LEN(fn$) > 0 THEN
            ' Only include files that have valid image extensions or are GPL files
            DIM ext AS STRING
            ext = UCASE$(RIGHT$(fn$, 4))
            IF INSTR(ext, ".JPG") OR INSTR(ext, ".PNG") OR INSTR(ext, ".GIF") OR INSTR(ext, ".BMP") OR INSTR(ext, ".TGA") OR INSTR(ext, ".PSD") OR INSTR(ext, ".PCX") OR INSTR(ext, ".SVG") OR INSTR(ext, ".QOI") OR INSTR(UCASE$(RIGHT$(fn$, 5)), ".JPEG") OR INSTR(ext, ".GPL") THEN
                ub& = UBOUND(arr$)
                arr$(ub&) = filepath$ + f$
                REDIM _PRESERVE arr(lb& TO ub& + 1) AS STRING
            END IF
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
    IF UBOUND(img_files_sorted$) >= 0 THEN
        cur_img% = cur_img% - 1
        IF cur_img% < 0 THEN cur_img% = UBOUND(img_files_sorted$)
        _ECHO "cur_img%=" + _TRIM$(STR$(cur_img%))
    END IF
END SUB


''
' Sets the image file to the next image file
' 
SUB next_img_file
    IF UBOUND(img_files_sorted$) >= 0 THEN
        cur_img% = cur_img% + 1
        IF cur_img% > UBOUND(img_files_sorted$) THEN cur_img% = 0
        _ECHO "cur_img%=" + _TRIM$(STR$(cur_img%))
    END IF
END SUB


''
' Sets the palette file to the previous palette file
' 
SUB prev_pal_file
    IF UBOUND(pal_files_sorted$) >= 0 THEN
        cur_pal% = cur_pal% - 1
        IF cur_pal% < 0 THEN cur_pal% = UBOUND(pal_files_sorted$)
        _ECHO "cur_pal%=" + _TRIM$(STR$(cur_pal%))
    END IF
END SUB


''
' Sets the palette file to the next palette file
' 
SUB next_pal_file
    IF UBOUND(pal_files_sorted$) >= 0 THEN
        cur_pal% = cur_pal% + 1
        IF cur_pal% > UBOUND(pal_files_sorted$) THEN cur_pal% = 0
        _ECHO "cur_pal%=" + _TRIM$(STR$(cur_pal%))
    END IF
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
'$INCLUDE:'include/QB64_GJ_LIB/IMGADJ/IMGADJ.BM'