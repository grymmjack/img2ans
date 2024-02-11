'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI'

CONST MIN_ZOOM = 0.25!
CONST MAX_ZOOM = 5.00!

CONST WIN_H = 800%
CONST WIN_W = 600%
CONST IMG_W = 1310%
CONST IMG_H = 704%
CONST KEY_RSHIFT& = 100303
CONST KEY_LSHIFT& = 100304

DIM SHARED AS SINGLE zoom, zoom_int
zoom! = 1.0
zoom_int! = 0.25

DIM AS STRING k
DIM SHARED AS LONG CANVAS1, CANVAS2, IMAGE
DIM SHARED AS INTEGER OFF_X, OFF_Y, OFF_MX, OFF_MY, OFF_XDIST, OFF_YDIST, nudge_amount
OFF_X = 0 : OFF_Y = 0 : nudge_amount% = 1

DIM SHARED AS INTEGER mouse_w
DIM SHARED AS _UNSIGNED _BYTE mouse_w_up, mouse_w_down

DIM SHARED AS _BYTE mouse_b1, mouse_b2, mouse_b3
DIM SHARED AS INTEGER mouse_x, mouse_y, mouse_old_x, mouse_old_y
DIM SHARED AS _UNSIGNED _BYTE mouse_moved, mouse_clicked, mouse_dragging
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_up, mouse_moved_down
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_left, mouse_moved_right
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_up, mouse_dragging_down
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_left, mouse_dragging_right

CANVAS1& = _NEWIMAGE(WIN_W, WIN_H, 32) : CANVAS2& = _NEWIMAGE(IMG_W, IMG_H, 32)
_DEST CANVAS1&
SCREEN CANVAS1&
IMAGE& = _LOADIMAGE(_STARTDIR$ + "/resources/images/progress5.png")

draw_output
DO
    _LIMIT 60

    ' Keyboard handling
    k$ = INKEY$
    IF _KEYDOWN(KEY_LSHIFT&) OR _KEYDOWN(KEY_RSHIFT&) THEN 
        nudge_amount% = 10
    ELSE
        nudge_amount% = 1
    END IF
    SELECT CASE k$    
        CASE CHR$(27)
            EXIT DO
        CASE "1"
            zoom! = 1.0
            draw_output
        CASE "+"
            change_zoom -zoom_int!
            draw_output
        CASE "-"
            change_zoom zoom_int!
            draw_output
        CASE "0"
            OFF_X% = 0
            OFF_Y% = 0
            draw_output
        CASE CHR$(0) + CHR$(72) 'up arrow
            OFF_Y% = OFF_Y% + nudge_amount%
            draw_output
        CASE CHR$(0) + CHR$(80) 'down arrow
            OFF_Y% = OFF_Y% - nudge_amount%
            draw_output
        CASE CHR$(0) + CHR$(75) 'right arrow
            OFF_X% = OFF_X% + nudge_amount%
            draw_output
        CASE CHR$(0) + CHR$(77) 'left arrow
            OFF_X% = OFF_X% - nudge_amount%
            draw_output
    END SELECT

    ' Mouse handling
    WHILE _MOUSEINPUT
        mouse_old_x%            = mouse_x%
        mouse_old_y%            = mouse_y%
        mouse_x%                = _MOUSEX
        mouse_y%                = _MOUSEY
        mouse_w%                = _MOUSEWHEEL
        mouse_w_up~%%           = _MOUSEWHEEL = -1
        mouse_w_down~%%         = _MOUSEWHEEL = 1
        mouse_b1%%              = _MOUSEBUTTON(1) ' left
        mouse_b2%%              = _MOUSEBUTTON(2) ' right
        mouse_b3%%              = _MOUSEBUTTON(3) ' middle
        mouse_b1_down~%%        = mouse_b1%% = -1
        mouse_b1_up~%%          = mouse_b1%% = 0
        mouse_b2_down~%%        = mouse_b2%% = -1
        mouse_b2_up~%%          = mouse_b2%% = 0
        mouse_b3_down~%%        = mouse_b3%% = -1
        mouse_b3_up~%%          = mouse_b3%% = 0
        mouse_moved~%%          = mouse_old_x% <> mouse_x% OR mouse_old_y% <> mouse_y%
        mouse_moved_up~%%       = mouse_old_y% > mouse_y%
        mouse_moved_down~%%     = mouse_old_y% < mouse_y%
        mouse_moved_left~%%     = mouse_old_x% > mouse_x%
        mouse_moved_right~%%    = mouse_old_x% < mouse_x%
        mouse_clicked~%%        = mouse_b1%% OR mouse_b2%% OR mouse_b3%%
        mouse_dragging~%%       = mouse_b1%% AND mouse_moved~%%
        mouse_dragging_up~%%    = mouse_dragging~%% AND mouse_moved_up~%%
        mouse_dragging_down~%%  = mouse_dragging~%% AND mouse_moved_down~%%
        mouse_dragging_left~%%  = mouse_dragging~%% AND mouse_moved_left~%%
        mouse_dragging_right~%% = mouse_dragging~%% AND mouse_moved_right~%%

        'Zoom stuff
        IF mouse_w_up~%% THEN
            change_zoom -zoom_int!
            draw_output
        ELSEIF mouse_w_down~%% THEN
            change_zoom zoom_int!
            draw_output
        END IF

        'Drag stuff
        IF mouse_b1_down~%% THEN
            ' Capture mouse offset for drag
            IF OFF_MX% = 0 AND OFF_MY% = 0 THEN
                OFF_MX% = OFF_X% + mouse_x%
                OFF_MY% = OFF_Y% + mouse_y%
            END IF
        ELSE
            ' Reset mouse offset
            OFF_MX% = 0
            OFF_MY% = 0
        END IF
        IF mouse_dragging~%% THEN
            ' Calculate x and y distance relative to mouse offset
            OFF_XDIST% = OFF_MX% - mouse_x%
            OFF_YDIST% = OFF_MY% - mouse_y%
            ' Set offset to distance
            OFF_X% = OFF_XDIST%
            OFF_Y% = OFF_YDIST%
            draw_output
            trace_mouse
        END IF
    WEND 
LOOP
SYSTEM 1



''
' Change zoom 
' @param SINGLE amount to adjust zoom by
'
SUB change_zoom(amount!)
    console.info "change_zoom(" + _TRIM$(STR$(amount!)) + ")"
    zoom! = zoom! + amount!
    IF zoom! < MIN_ZOOM THEN zoom! = MIN_ZOOM
    IF zoom! > MAX_ZOOM THEN zoom! = MAX_ZOOM
END SUB



''
' Trace the mouse with console
'
SUB trace_mouse
    console.log "MOUSE_*: " + _TRIM$(STR$(mouse_x%)) + ", " + _TRIM$(STR$(mouse_y%))
    console.log "OFF_*: " + _TRIM$(STR$(OFF_X%)) + ", " + _TRIM$(STR$(OFF_Y%))
    console.log "OFF_M*: " + _TRIM$(STR$(OFF_MX%)) + ", " + _TRIM$(STR$(OFF_MY%))
    console.log "OFF_*DIST: " + _TRIM$(STR$(OFF_XDIST%)) + ", " + _TRIM$(STR$(OFF_YDIST%))
END SUB


''
' Draw the output
'
SUB draw_output
    console.info "draw_output"
    _DEST CANVAS1& : CLS
    _PUTIMAGE (0, 0)-(WIN_W, WIN_H), _
        IMAGE&, _
        CANVAS1&, _
        (OFF_X%, OFF_Y%)-(INT(WIN_W * zoom!) + OFF_X%, INT(WIN_H * zoom!) + OFF_Y%)
    _DISPLAY
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BM'