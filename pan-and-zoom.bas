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
CONST BOX_INIT_H = 50
CONST BOX_LINE_W = 10

CONST TARGET_WIN = 0
CONST TARGET_BOX = 1
CONST PAD = BOX_LINE_W

DIM SHARED AS SINGLE zoom, zoom_int
zoom! = 1.0
zoom_int! = 0.25

DIM AS STRING k
DIM SHARED AS LONG CANVAS1, CANVAS2, IMAGE, BOX
DIM SHARED AS INTEGER OFF_X, OFF_Y, OFF_MX, OFF_MY, OFF_MBX, OFF_MBY
DIM SHARED AS INTEGER OFF_XDIST, OFF_YDIST, OFF_XBDIST, OFF_YBDIST, nudge_amount
OFF_X = 0 : OFF_Y = 0
OFF_MX = 0 : OFF_MY = 0
OFF_MBX = 0 : OFF_MBY = 0
OFF_XDIST = 0 : OFF_YDIST = 0
OFF_XBDIST = 0 : OFF_YBDIST = 0
nudge_amount% = 1

DIM SHARED AS _BYTE mouse_b1, mouse_b2, mouse_b3, mouse_old_b1, mouse_old_b2, mouse_old_b3
DIM SHARED AS INTEGER mouse_w
DIM SHARED AS INTEGER mouse_x, mouse_y, mouse_old_x, mouse_old_y
DIM SHARED AS _UNSIGNED _BYTE mouse_w_up, mouse_w_down
DIM SHARED AS _UNSIGNED _BYTE FOCUS, OVER, TARGET, OVER_BOX
DIM SHARED AS _UNSIGNED _BYTE mouse_clicked_b1, mouse_clicked_b2, mouse_clicked_b3
DIM SHARED AS _UNSIGNED _BYTE mouse_moved, mouse_clicked, mouse_dragging
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_up, mouse_moved_down
DIM SHARED AS _UNSIGNED _BYTE mouse_moved_left, mouse_moved_right
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_up, mouse_dragging_down
DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_left, mouse_dragging_right
FOCUS~%% = WIN_HAS_FOCUS
OVER~%% = BOX_NONE
OVER_BOX~%% = FALSE

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
    ' _LIMIT 60

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
        CASE "+"
            change_zoom -zoom_int!
        CASE "-"
            change_zoom zoom_int!
        CASE "0"
            OFF_X% = 0
            OFF_Y% = 0
            box_off_x% = 0
            box_off_y% = 0
            box_x% = 0
            box_y% = 0
            box_w% = BOX_INIT_W
            box_h% = BOX_INIT_H
        CASE CHR$(0) + CHR$(72) 'up arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_Y% = OFF_Y% + nudge_amount%
                CASE TARGET_BOX
                    box_off_y% = box_off_y% - nudge_amount%
            END SELECT
        CASE CHR$(0) + CHR$(80) 'down arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_Y% = OFF_Y% - nudge_amount%
                CASE TARGET_BOX
                    box_off_y% = box_off_y% + nudge_amount%
            END SELECT
        CASE CHR$(0) + CHR$(75) 'right arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_X% = OFF_X% + nudge_amount%
                CASE TARGET_BOX
                    box_off_x% = box_off_x% - nudge_amount%
            END SELECT
        CASE CHR$(0) + CHR$(77) 'left arrow
            SELECT CASE TARGET~%%
                CASE TARGET_WIN
                    OFF_X% = OFF_X% - nudge_amount%
                CASE TARGET_BOX
                    box_off_x% = box_off_x% + nudge_amount%
            END SELECT
    END SELECT
    IF k$ <> "" THEN draw_output

    ' Mouse handling
    WHILE _MOUSEINPUT
        mouse_old_x%            = mouse_x%
        mouse_old_y%            = mouse_y%
        mouse_old_b1%%          = mouse_b1%%
        mouse_old_b2%%          = mouse_b2%%
        mouse_old_b3%%          = mouse_b3%%
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
        mouse_clicked_b1~%%     = mouse_old_b1%% AND mouse_b1_up~%%
        mouse_clicked_b2~%%     = mouse_old_b2%% AND mouse_b2_up~%%
        mouse_clicked_b3~%%     = mouse_old_b3%% AND mouse_b3_up~%%
        mouse_dragging~%%       = mouse_b1%% AND mouse_moved~%%
        mouse_dragging_up~%%    = mouse_dragging~%% AND mouse_moved_up~%%
        mouse_dragging_down~%%  = mouse_dragging~%% AND mouse_moved_down~%%
        mouse_dragging_left~%%  = mouse_dragging~%% AND mouse_moved_left~%%
        mouse_dragging_right~%% = mouse_dragging~%% AND mouse_moved_right~%%

        'Zoom stuff
        IF mouse_w_up~%% THEN
            change_zoom -zoom_int!
        ELSEIF mouse_w_down~%% THEN
            change_zoom zoom_int!
        END IF

        'Over stuff
        OVER~%% = BOX_NONE : OVER_BOX~%% = FALSE

        ' Over edges
        IF (_MOUSEX>= box_off_x%) AND (_MOUSEX<= (box_off_x% + PAD)) THEN OVER~%% = BOX_LEFT
        IF (_MOUSEX>= (box_off_x% + box_w% - PAD)) AND (_MOUSEX<= (box_off_x% + box_w%)) THEN OVER~%% = BOX_RIGHT
        IF (_MOUSEY >= box_off_y%) AND (_MOUSEY <= (box_off_y% + PAD)) THEN OVER~%% = BOX_TOP
        IF (_MOUSEY >= (box_off_y% + box_h% - PAD)) AND (_MOUSEY <= (box_off_y% + box_h%)) THEN OVER~%% = BOX_BOT
        IF ((_MOUSEX >= box_off_x%) AND (_MOUSEX <= (box_off_x% + box_w%))) _
        AND ((_MOUSEY >= box_off_y%) AND (_MOUSEY <= (box_off_y% + box_h%))) THEN OVER_BOX~%% = TRUE

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
                console.info "Not over box edges"
        END SELECT

        ' Capture mouse offset for drag
        IF _MOUSEBUTTON(1) = -1 THEN
            IF TARGET~%% = TARGET_BOX THEN
                IF OFF_MBX% = 0 AND OFF_MBY% = 0 THEN
                    OFF_MBX% = _MOUSEX + box_off_x%
                    OFF_MBY% = _MOUSEY + box_off_y%
                END IF
            ELSE
                IF OFF_MX% = 0 AND OFF_MY% = 0 THEN
                    OFF_MX% = _MOUSEX + OFF_X%
                    OFF_MY% = _MOUSEY + OFF_Y%
                END IF
            END IF
        END IF
        IF _MOUSEBUTTON(1) = 0 THEN ' Focus and target stuff
            console.warn "MOUSE B1 CLICKED"
            ' Check if clicking on bounding box
            IF OVER_BOX~%% THEN
                ' Clicked on box
                console.log "Clicked on box"
                FOCUS~%% = BOX_HAS_FOCUS
                TARGET~%% = TARGET_BOX
            ELSE
                ' Clicked on window
                console.log "Clicked on window"
                FOCUS~%% = WIN_HAS_FOCUS
                TARGET~%% = TARGET_WIN
            END IF
        ELSEIF mouse_dragging~%% THEN
            IF TARGET~%% = TARGET_WIN THEN
                ' Calculate x and y distance relative to mouse offset
                OFF_XDIST% = OFF_MX% - _MOUSEX
                OFF_YDIST% = OFF_MY% - _MOUSEY
                ' Set offset to distance
                OFF_X% = OFF_XDIST%
                OFF_Y% = OFF_YDIST%
            ELSEIF TARGET~%% = TARGET_BOX THEN
                ' Calculate x and y distance relative to mouse offset
                OFF_XBDIST% = OFF_MBX% - _MOUSEX
                OFF_YBDIST% = OFF_MBY% - _MOUSEY
                IF OVER~%% = BOX_RIGHT THEN
                    IF mouse_dragging_right~%% THEN
                        box_w% = box_w% + nudge_amount%
                    ELSEIF mouse_dragging_left~%% THEN
                        box_w% = box_w% - nudge_amount%
                    END IF
                ELSEIF OVER~%% = BOX_LEFT THEN
                    IF mouse_dragging_left~%% THEN
                        box_off_x% = box_off_x% - nudge_amount%
                        box_w% = box_w% + nudge_amount%
                    ELSEIF mouse_dragging_right~%% THEN
                        box_off_x% = box_off_x% + nudge_amount%
                        box_w% = box_w% + nudge_amount%
                    END IF
                ELSEIF OVER~%% = BOX_TOP THEN
                    IF mouse_dragging_down~%% THEN
                        box_h% = box_h% + nudge_amount%
                        box_off_y% = box_off_y% + nudge_amount%
                    ELSEIF mouse_dragging_up~%% THEN
                        box_h% = box_h% + nudge_amount%
                        box_off_y% = box_off_y% - nudge_amount%
                    END IF
                ELSEIF OVER~%% = BOX_BOT THEN
                    IF mouse_dragging_down~%% THEN
                        box_h% = box_h% + nudge_amount%
                    ELSEIF mouse_dragging_up~%% THEN
                        box_h% = box_h% - nudge_amount%
                    END IF
                ELSE
                    ' Set offset to distance
                    box_off_x% = OFF_XBDIST% * -1
                    box_off_y% = OFF_YBDIST% * -1
                END IF
            END IF
        ELSEIF mouse_b1_up~%% THEN ' Mouse up stuff
            ' console.warn "MOUSE B1 UP"
            ' Reset mouse offset
            OFF_MX%     = 0
            OFF_MY%     = 0
            OFF_MBX%    = 0
            OFF_MBY%    = 0
            ' OFF_XDIST%  = 0
            ' OFF_YDIST%  = 0
            ' OFF_XBDIST% = 0
            ' OFF_YBDIST% = 0
            ' Reset mouse
            ' mouse_b1%%          = 0
            ' mouse_b1_down~%%    = 0
            ' mouse_old_b1%%      = 0
            ' mouse_b1_clicked~%% = 0
            ' DO : LOOP UNTIL _MOUSEINPUT = 0 ' clear buffered mouse input
        END IF
        ' trace_mouse
        draw_output
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
' @param INTEGER thickness of line
'
SUB outline_image(img&, kolor&, thickness%)
    ' console.info "outline_image(" + _TRIM$(STR$(img&)) + ", " + _TRIM$(STR$(kolor&)) + ", " + _TRIM$(STR$(thickness%)) +  ")"
    DIM AS INTEGER i
    DIM AS LONG old_dest
    old_dest& = _DEST
    _DEST img&
    FOR i% = 0 TO thickness%
        LINE (i%, i%)-(_WIDTH(img&)-i%-1, _HEIGHT(img&)-i%-1), kolor&, B, &B0000111100001111
    NEXT i%
    _DEST old_dest&
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
    console.log "MOUSE_CLICKED_B1: " + _TRIM$(STR$(mouse_clicked_b1~%%))
    console.log "FOCUS: " + _TRIM$(STR$(FOCUS~%%)) + ", OVER: " + _TRIM$(STR$(OVER~%%)) + ", TARGET: " + _TRIM$(STR$(TARGET~%%))
    console.log "MOUSE_*: " + _TRIM$(STR$(mouse_x%)) + ", " + _TRIM$(STR$(mouse_y%))
    console.log "OFF_*: " + _TRIM$(STR$(OFF_X%)) + ", " + _TRIM$(STR$(OFF_Y%))
    console.log "OFF_M*: " + _TRIM$(STR$(OFF_MX%)) + ", " + _TRIM$(STR$(OFF_MY%))
    console.log "OFF_MB*: " + _TRIM$(STR$(OFF_MBX%)) + ", " + _TRIM$(STR$(OFF_MBY%))
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
    ' console.info "draw_output"
    BOX& = _NEWIMAGE(box_w%, box_h%, 32)
    _DEST CANVAS1& : CLS
    _PUTIMAGE (0, 0)-(WIN_W, WIN_H), _
        IMAGE&, _
        CANVAS1&, _
        (OFF_X%, OFF_Y%)-(INT(WIN_W * zoom!) + OFF_X%, INT(WIN_H * zoom!) + OFF_Y%)
    IF FOCUS~%% = WIN_HAS_FOCUS THEN
        outline_image CANVAS1&, _RGB32(255, 0, 0), BOX_LINE_W
        outline_image BOX&, _RGB32(255, 255, 0), BOX_LINE_W
    ELSEIF FOCUS~%% = BOX_HAS_FOCUS THEN
        outline_image BOX&, _RGB32(255, 0, 0), BOX_LINE_W
    END IF
    draw_bounding_box
    _DISPLAY
END SUB


''
' Draw bounding box
'
SUB draw_bounding_box
    ' console.info "draw_bounding_box"
    ' IF box_w% > WIN_W THEN box_w% = WIN_W
    ' IF box_h% > WIN_H THEN box_h% = WIN_H
    ' IF box_w% <= 0 THEN box_w% = 1
    ' IF box_h% <= 0 THEN box_h% = 1
    ' IF box_x% < 0 THEN box_x% = 0
    ' IF box_y% < 0 THEN box_y% = 0
    ' IF box_x% + box_w% > WIN_W THEN box_x% = WIN_W - box_x%
    ' IF box_y% + box_y% > WIN_H THEN box_y% = WIN_H - box_y%
    ' IF box_off_x% < 0 THEN box_off_x% = 0
    ' IF box_off_y% < 0 THEN box_off_y% = 0
    ' IF box_off_x% + box_off_w% > WIN_W THEN box_off_x% = WIN_W - box_off_x%
    ' IF box_off_y% + box_off_y% > WIN_H THEN box_off_y% = WIN_H - box_off_y%
    trace_box
    DIM AS LONG old_dest
    old_dest& = _DEST
    _DEST BOX&
    _PUTIMAGE (box_off_x%, box_off_y%), _
        BOX&, _
        CANVAS1&
    _DEST old_dest&
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BM'