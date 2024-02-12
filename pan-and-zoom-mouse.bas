'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI'
'$INCLUDE:'include/MOUSE/MOUSE.BI'
'$INCLUDE:'include/BOUNDING_BOX/BOUNDING_BOX.BI'

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
CONST BOX_LINE_W = 2

CONST TARGET_WIN = 0
CONST TARGET_BOX = 1

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

' DIM SHARED AS _BYTE mouse_b1, mouse_b2, mouse_b3, mouse_old_b1, mouse_old_b2, mouse_old_b3
' DIM SHARED AS INTEGER mouse_w
DIM SHARED AS INTEGER PAD
' DIM SHARED AS INTEGER mouse_x, mouse_y, mouse_old_x, mouse_old_y
' DIM SHARED AS _UNSIGNED _BYTE mouse_w_up, mouse_w_down
DIM SHARED AS _UNSIGNED _BYTE FOCUS, OVER, TARGET, OVER_BOX
' DIM SHARED AS _UNSIGNED _BYTE mouse_clicked_b1, mouse_clicked_b2, mouse_clicked_b3
' DIM SHARED AS _UNSIGNED _BYTE mouse_moved, mouse_clicked, mouse_dragging
' DIM SHARED AS _UNSIGNED _BYTE mouse_moved_up, mouse_moved_down
' DIM SHARED AS _UNSIGNED _BYTE mouse_moved_left, mouse_moved_right
' DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_up, mouse_dragging_down
' DIM SHARED AS _UNSIGNED _BYTE mouse_dragging_left, mouse_dragging_right
PAD% = BOX_LINE_W
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

MOUSE_init
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
    MOUSE_update
    MOUSE_refresh

    'Zoom stuff
    IF MOUSE.status.wheeling_up THEN
        change_zoom -zoom_int!
    ELSEIF MOUSE.status.wheeling_down THEN
        change_zoom zoom_int!
    END IF

    'Over stuff
    OVER~%% = BOX_NONE : OVER_BOX~%% = FALSE
    box_over_calc
    SELECT CASE OVER~%%
        CASE BOX_LEFT
            console.box "Over box left edge", 12
        CASE BOX_RIGHT
            console.box "Over box right edge", 12
        CASE BOX_TOP
            console.box "Over box top edge", 12
        CASE BOX_BOT
            console.box "Over box bottom edge", 12
    END SELECT

    ' Capture mouse offset for drag
    IF MOUSE.status.b1_down THEN
        IF TARGET~%% = TARGET_BOX THEN
            IF OFF_MBX% = 0 AND OFF_MBY% = 0 THEN
                OFF_MBX% = MOUSE.new_state.pos.x + box_off_x%
                OFF_MBY% = MOUSE.new_state.pos.y + box_off_y%
            END IF
        ELSE
            IF OFF_MX% = 0 AND OFF_MY% = 0 THEN
                OFF_MX% = MOUSE.new_state.pos.x + OFF_X%
                OFF_MY% = MOUSE.new_state.pos.y + OFF_Y%
            END IF
        END IF
    END IF
    IF MOUSE.status.b1_clicked THEN ' Focus and target stuff
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
    ELSEIF MOUSE.status.started_drag THEN
        IF TARGET~%% = TARGET_WIN THEN
            ' Calculate x and y distance relative to mouse offset
            OFF_XDIST% = OFF_MX% - MOUSE.new_state.pos.x
            OFF_YDIST% = OFF_MY% - MOUSE.new_state.pos.y
            ' Set offset to distance
            OFF_X% = OFF_XDIST%
            OFF_Y% = OFF_YDIST%
        ELSEIF TARGET~%% = TARGET_BOX THEN
            ' Calculate x and y distance relative to mouse offset
            OFF_XBDIST% = OFF_MBX% - MOUSE.new_state.pos.x
            OFF_YBDIST% = OFF_MBY% - MOUSE.new_state.pos.y
            box_over_calc
            IF OVER~%% = BOX_RIGHT THEN
                IF MOUSE.status.dragging_right THEN
                    box_w% = box_w% + nudge_amount%
                ELSEIF MOUSE.status.dragging_left THEN
                    box_w% = box_w% - nudge_amount%
                END IF
            ELSEIF OVER~%% = BOX_LEFT THEN
                IF MOUSE.status.dragging_left THEN
                    box_off_x% = box_off_x% - nudge_amount%
                    box_w% = box_w% + nudge_amount%
                ELSEIF MOUSE.status.dragging_right THEN
                    box_off_x% = box_off_x% + nudge_amount%
                    box_w% = box_w% - nudge_amount%
                END IF
            ELSEIF OVER~%% = BOX_TOP THEN
                IF MOUSE.status.dragging_down THEN
                    box_off_y% = box_off_y% + nudge_amount%
                    box_h% = box_h% - nudge_amount%
                ELSEIF MOUSE.status.dragging_up THEN
                    box_off_y% = box_off_y% - nudge_amount%
                    box_h% = box_h% + nudge_amount%
                END IF
            ELSEIF OVER~%% = BOX_BOT THEN
                IF MOUSE.status.dragging_down THEN
                    box_h% = box_h% + nudge_amount%
                ELSEIF MOUSE.status.dragging_up THEN
                    box_h% = box_h% - nudge_amount%
                END IF
            ELSE
                ' Set offset to distance
                box_off_x% = OFF_XBDIST% * -1
                box_off_y% = OFF_YBDIST% * -1
            END IF
        END IF
    ' ELSEIF mouse_b1_up~%% THEN ' Mouse up stuff
        ' console.warn "MOUSE B1 UP"
        ' Reset mouse offset
        ' OFF_MX%     = 0
        ' OFF_MY%     = 0
        ' OFF_MBX%    = 0
        ' OFF_MBY%    = 0
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
LOOP
SCREEN 0
_DEST 0
_FREEIMAGE CANVAS1&
_FREEIMAGE CANVAS2&
_FREEIMAGE IMAGE&
_FREEIMAGE BOX&
SYSTEM 1


''
' Calculates the bounding box over states
'
SUB box_over_calc
    DIM AS INTEGER in_horiz, in_vert
    DIM AS INTEGER on_left_edge, on_right_edge, on_top_edge, on_bot_edge
    
    'left edge
    on_left_edge = (MOUSE.new_state.pos.x >= box_off_x% - PAD%) _
               AND (MOUSE.new_state.pos.x <= (box_off_x% + PAD%))
    IF on_left_edge THEN OVER~%% = BOX_LEFT
    
    'right edge
    on_right_edge = (MOUSE.new_state.pos.x >= (box_off_x% + box_w% - PAD%)) _
                AND (MOUSE.new_state.pos.x <= (box_off_x% + box_w%)) 
    IF on_right_edge THEN OVER~%% = BOX_RIGHT

    'top edge
    on_top_edge = (MOUSE.new_state.pos.y >= box_off_y% - PAD%) _
              AND (MOUSE.new_state.pos.y <= (box_off_y% + PAD%)) 
    IF on_top_edge THEN OVER~%% = BOX_TOP

    'bottom edge
    on_bot_edge = (MOUSE.new_state.pos.y >= (box_off_y% + box_h% - PAD%)) _
              AND (MOUSE.new_state.pos.y <= (box_off_y% + box_h%)) 
    IF on_bot_edge THEN OVER~%% = BOX_BOT

    'horizontal
    in_horiz = ((MOUSE.new_state.pos.x >= box_off_x% - PAD%) _
           AND (MOUSE.new_state.pos.x <= (box_off_x% + box_w% + PAD%)))

    'vertical
    in_vert = ((MOUSE.new_state.pos.y >= box_off_y% - PAD%) _
          AND (MOUSE.new_state.pos.y <= (box_off_y% + box_h% + PAD%)))

    'over box
    IF in_horiz AND in_vert THEN OVER_BOX~%% = TRUE
END SUB


''
' Outline an image
' @param LONG img to outline
' @param LONG kolor to outline in
' @param INTEGER thickness of line
' @param LONG pattern for line
'
SUB outline_image(img&, kolor&, thickness%, pattern&)
    ' console.info "outline_image(" + _TRIM$(STR$(img&)) + ", " + _TRIM$(STR$(kolor&)) + ", " + _TRIM$(STR$(thickness%)) +  ")"
    DIM AS INTEGER i
    DIM AS LONG old_dest
    old_dest& = _DEST
    _DEST img&
    FOR i% = 0 TO thickness%
        LINE (i%, i%)-(_WIDTH(img&)-i%-1, _HEIGHT(img&)-i%-1), kolor&, B, pattern&
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
    console.log "MOUSE.status.b1_clicked: " + _TRIM$(STR$(MOUSE.status.b1_clicked))
    console.log "FOCUS: " + _TRIM$(STR$(FOCUS~%%)) + ", OVER: " + _TRIM$(STR$(OVER~%%)) + ", TARGET: " + _TRIM$(STR$(TARGET~%%))
    console.log "MOUSE.new_state.pos*: " + _TRIM$(STR$(MOUSE.new_state.pos.x)) + ", " + _TRIM$(STR$(MOUSE.new_state.pos.y))
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
    console.log "PAD: " + _TRIM$(STR$(PAD%))
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
        outline_image CANVAS1&, _RGB32(255, 0, 0), BOX_LINE_W, &B0000111100001111
        outline_image BOX&, _RGB32(255, 255, 0), BOX_LINE_W, &B00000000111111111
    ELSEIF FOCUS~%% = BOX_HAS_FOCUS THEN
        outline_image BOX&, _RGB32(255, 0, 0), BOX_LINE_W, &B0000000011111111
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
    ' trace_box
    DIM AS LONG old_dest
    old_dest& = _DEST
    _DEST BOX&
    _PUTIMAGE (box_off_x%, box_off_y%), _
        BOX&, _
        CANVAS1&
    _DEST old_dest&
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BM'
'$INCLUDE:'include/MOUSE/MOUSE.BM'
'$INCLUDE:'include/BOUNDING_BOx/BOUNDING_BOx.BM'
