'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI'

CONST MIN_ZOOM = 0.25!
CONST MAX_ZOOM = 5.00!

CONST WIN_H = 800%
CONST WIN_W = 600%
CONST IMG_W = 1310%
CONST IMG_H = 704%
CONST KEY_RSHIFT& = 100303&
CONST KEY_LSHIFT& = 100304&

CONST WIN_HAS_FOCUS = 0
CONST BOX_HAS_FOCUS = 1

CONST BOX_NONE = -1
CONST BOX_LEFT = 0
CONST BOX_RIGHT = 1
CONST BOX_TOP = 2
CONST BOX_BOT = 3
CONST BOX_INIT_W = 80
CONST BOX_INTI_H = 50

CONST TARGET_WIN = 0%%
CONST TARGET_BOX = 1%%
CONST PAD = 3%%

DIM SHARED AS SINGLE zoom, zoom_int
zoom! = 1.0
zoom_int! = 0.25

DIM AS STRING k
DIM SHARED AS LONG CANVAS1, CANVAS2, IMAGE, BOX
DIM SHARED AS INTEGER OFF_X, OFF_Y, OFF_MX, OFF_MY, OFF_XDIST, OFF_YDIST, nudge_amount
OFF_X = 0 : OFF_Y = 0 : nudge_amount% = 1

DIM SHARED AS INTEGER mouse_w
DIM SHARED AS _UNSIGNED _BYTE mouse_w_up, mouse_w_down

DIM SHARED AS _UNSIGNED _BYTE FOCUS, OVER, TARGET
DIM SHARED AS _BYTE mouse_b1, mouse_b2, mouse_b3
DIM SHARED AS INTEGER mouse_x, mouse_y, mouse_old_x, mouse_old_y
DIM SHARED AS _UNSIGNED _BYTE mouse_moved, mouse_clicked, mouse_dragging
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_up, mouse_moved_down
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_left, mouse_moved_right
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_up, mouse_dragging_down
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_left, mouse_dragging_right
FOCUS~%% = WIN_HAS_FOCUS
OVER~%% = BOX_NONE

'bounding box
DIM SHARED AS INTEGER box_x, box_y, box_w, box_h, box_off_x, box_off_y
box_x% = 0 : box_y% = 0 : box_w% = BOX_INIT_W : box_h% = BOX_INIT_H
BOX& = _NEWIMAGE(box_w%, box_h%, 32)
_CLEARCOLOR _RGB32(0, 0, 0), BOX&

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
            box_off_x% = 0
            box_off_y% = 0
            box_x% = 0
            box_y% = 0
            box_w% = BOX_INIT_W
            box_h% = BOX_INIT_H
            draw_output
        CASE CHR$(0) + CHR$(72) 'up arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_Y% = OFF_Y% + nudge_amount%
                CASE TARGET_BOX
                    box_off_y% = box_off_y% - nudge_amount%
            END SELECT
            draw_output
        CASE CHR$(0) + CHR$(80) 'down arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_Y% = OFF_Y% - nudge_amount%
                CASE TARGET_BOX
                    box_off_y% = box_off_y% + nudge_amount%
            END SELECT
            draw_output
        CASE CHR$(0) + CHR$(75) 'right arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_X% = OFF_X% + nudge_amount%
                CASE TARGET_BOX
                    box_off_x% = box_off_x% + nudge_amount%
            END SELECT
            draw_output
        CASE CHR$(0) + CHR$(77) 'left arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_X% = OFF_X% - nudge_amount%
                CASE TARGET_BOX
                    box_off_x% = box_off_x% - nudge_amount%
            END SELECT
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

        'Over stuff
        OVER~%% = BOX_NONE
        IF (mouse_x% >= (box_x% - PAD)) AND (mouse_x% <= (box_x% + PAD)) THEN OVER~%% = BOX_LEFT
        IF (mouse_x% >= (box_x% - PAD) + box_w%) AND (mouse_x% <= (box_x% + box_w% + PAD)) THEN OVER~%% = BOX_RIGHT
        IF (mouse_y% >= (box_y% - PAD)) AND (mouse_y% <= (box_y% + PAD)) THEN OVER~%% = BOX_TOP
        IF (mouse_y% >= (box_y% - PAD) + box_h%) AND (mouse_y% <= (box_y% + box_h% + PAD)) THEN OVER~%% = BOX_BOT
        SELECT EVERYCASE OVER~%%
            CASE BOX_LEFT
                console.info "Over box left edge"
            CASE BOX_RIGHT
                console.info "Over box right edge"
            CASE BOX_TOP
                console.info "Over box top edge"
            CASE BOX_BOT
                console.info "Over box bottom edge"
            CASE BOX_NONE
            CASE ELSE
                ' console.info "Not over box edges"
        END SELECT

        'Drag stuff
        IF mouse_b1_down~%% THEN
            ' Capture mouse offset for drag
            IF OFF_MX% = 0 AND OFF_MY% = 0 THEN
                OFF_MX% = OFF_X% + mouse_x%
                OFF_MY% = OFF_Y% + mouse_y%
            END IF

            ' Check if clicking on bounding box
            IF (mouse_x% >= box_x% AND mouse_x% <= box_x% + box_w%) _
           AND (mouse_y% >= box_y% AND mouse_y% <= box_y% + box_h%) THEN
                ' Clicked on box
                console.log "Clicked on box"
                FOCUS~%% = BOX_HAS_FOCUS
                TARGET~%% = TARGET_BOX
                draw_output
            ELSE
                ' Clicked on window
                console.log "Clicked on window"
                FOCUS~%% = WIN_HAS_FOCUS
                TARGET~%% = TARGET_WIN
                draw_output
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
            IF OVER~%% = BOX_RIGHT OR OVER~%% = BOX_LEFT THEN
                box_w% = box_w% + OFF_XDIST%
            END IF
            IF OVER~%% = BOX_TOP OR OVER~%% = BOX_BOT THEN
                box_h% = box_h% + OFF_YDIST%
            END IF
            draw_output
        END IF
        ' trace_mouse
    WEND 
LOOP
SCREEN 0
_DEST 0
_FREEIMAGE CANVAS1&
_FREEIMAGE CANVAS2&
_FREEIMAGE IMAGE&
_FREEIMAGE BOX&
SYSTEM 1


''
' Outline an image
' @param LONG img to outline
' @param LONG kolor to outline in
'
SUB outline_image(img&, kolor&)    
    LINE (0, 0)-(_WIDTH(img&)-1, _HEIGHT(img&)-1), kolor&, B
END SUB



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
    console.log "FOCUS: " + _TRIM$(STR$(FOCUS~%%)) + ", OVER: " + _TRIM$(STR$(OVER~%%)) + ", TARGET: " + _TRIM$(STR$(TARGET~%%))
    console.log "MOUSE_*: " + _TRIM$(STR$(mouse_x%)) + ", " + _TRIM$(STR$(mouse_y%))
    console.log "OFF_*: " + _TRIM$(STR$(OFF_X%)) + ", " + _TRIM$(STR$(OFF_Y%))
    console.log "OFF_M*: " + _TRIM$(STR$(OFF_MX%)) + ", " + _TRIM$(STR$(OFF_MY%))
    console.log "OFF_*DIST: " + _TRIM$(STR$(OFF_XDIST%)) + ", " + _TRIM$(STR$(OFF_YDIST%))
END SUB


'' 
' Trace the bounding box with console
'
SUB trace_box
    console.log "FOCUS: " + _TRIM$(STR$(FOCUS~%%)) + ", OVER: " + _TRIM$(STR$(OVER~%%)) + ", TARGET: " + _TRIM$(STR$(TARGET~%%))
    console.log "box_x: " + _TRIM$(STR$(box_x%)) + ", box_y: " + _TRIM$(STR$(box_y%))
    console.log "box_w: " + _TRIM$(STR$(box_w%)) + ", box_h: " + _TRIM$(STR$(box_h%))
    console.log "box_off_x: " + _TRIM$(STR$(box_off_x%)) + ", box_off_y: " + _TRIM$(STR$(box_off_y%))
END SUB


''
' Draw the output
'
SUB draw_output
    console.info "draw_output"
    _DEST CANVAS1& : CLS
    IF TARGET~%% = TARGET_WIN THEN
        console.info "DRAW TARGET = WIN"
        'draw moved window
        _PUTIMAGE (0, 0)-(WIN_W, WIN_H), _
            IMAGE&, _
            CANVAS1&, _
            (OFF_X%, OFF_Y%)-(INT(WIN_W * zoom!) + OFF_X%, INT(WIN_H * zoom!) + OFF_Y%)
    ELSEIF TARGET~%% = TARGET_BOX THEN
        console.info "DRAW TARGET = BOX"
        'draw unmoved window
        _PUTIMAGE (0, 0)-(WIN_W, WIN_H), _
            IMAGE&, _
            CANVAS1&, _
            (0, 0)-(INT(WIN_W * zoom!), INT(WIN_H * zoom!))
        ' box_x% = box_x% + box_off_x%
        ' box_y% = box_y% + box_off_y%
    END IF
    IF FOCUS~%% = WIN_HAS_FOCUS THEN
        outline_image CANVAS1&, _RGB32(255, 0, 0)
        outline_image BOX&, _RGB32(255, 255, 0)
    ELSEIF FOCUS~%% = BOX_HAS_FOCUS THEN
        outline_image BOX&, _RGB32(255, 0, 0)
    END IF
    draw_bounding_box
    _DISPLAY
END SUB


''
' Draw bounding box
'
SUB draw_bounding_box
    console.info "draw_bounding_box"
    IF box_w% > WIN_W THEN box_w% = WIN_W
    IF box_h% > WIN_H THEN box_h% = WIN_H
    IF box_w% <= 0 THEN box_w% = 1
    IF box_h% <= 0 THEN box_h% = 1
    IF box_x% < 0 THEN box_x% = 0
    IF box_y% < 0 THEN box_y% = 0
    IF box_x% + box_w% > WIN_W THEN box_x% = WIN_W - box_x%
    IF box_y% + box_y% > WIN_H THEN box_y% = WIN_H - box_y%
    trace_box
    _PUTIMAGE (0, 0)-(box_w%, box_h%), _
        BOX&, _
        CANVAS1&, _
        (box_off_x%, box_off_y%)
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BM'