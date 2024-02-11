'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI'

CONST WIN_H = 800%
CONST WIN_W = 600%
CONST IMG_W = 1310%
CONST IMG_H = 704%
CONST KEY_RSHIFT& = 100303
CONST KEY_LSHIFT& = 100304

DIM AS STRING k
DIM SHARED AS LONG CANVAS1, CANVAS2, IMAGE
DIM SHARED AS INTEGER OFF_X, OFF_Y, nudge_amount
OFF_X = 0 : OFF_Y = 0 : nudge_amount% = 1

DIM SHARED AS INTEGER mouse_w
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
        mouse_b1%%              = _MOUSEBUTTON(1) ' left
        mouse_b2%%              = _MOUSEBUTTON(2) ' right
        mouse_b3%%              = _MOUSEBUTTON(3) ' middle
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
        IF mouse_dragging~%% THEN
            IF mouse_x% < OFF_X% THEN
                OFF_X% = OFF_X% - mouse_x%
            ELSE
                OFF_X% = OFF_X% + mouse_x%
            END IF
            IF mouse_y% < OFF_Y% THEN
                OFF_Y% = OFF_Y% - mouse_y%
            ELSE
                OFF_Y% = OFF_Y% + mouse_y%
            END IF
            draw_output
            ' IF _KEYDOWN(KEY_LSHIFT&) OR _KEYDOWN(KEY_RSHIFT&) THEN 
            '     nudge_amount% = 4
            ' ELSE
            '     nudge_amount% = 2
            ' END IF
            ' IF mouse_dragging_up~%%  THEN
            '     OFF_Y% = OFF_Y% + nudge_amount%
            '     draw_output
            ' END IF
            ' IF mouse_dragging_down~%%  THEN
            '     OFF_Y% = OFF_Y% - nudge_amount%
            '     draw_output
            ' END IF
            ' IF mouse_dragging_left~%%  THEN
            '     OFF_X% = OFF_X% + nudge_amount%
            '     draw_output
            ' END IF
            ' IF mouse_dragging_right~%%  THEN
            '     OFF_X% = OFF_X% - nudge_amount%
            '     draw_output
            ' END IF
        END IF
        console.log _TRIM$(STR$(mouse_x%)) + ", " + _TRIM$(STR$(mouse_y%))
        console.log _TRIM$(STR$(OFF_X%)) + ", " + _TRIM$(STR$(OFF_Y%))
    WEND
 
LOOP
SYSTEM 1


''
' Draw the output
'
SUB draw_output
    _DEST CANVAS1& : CLS
    _PUTIMAGE (0, 0)-(WIN_W, WIN_H), IMAGE&, CANVAS1&, (OFF_X%, OFF_Y%)-(WIN_W+OFF_X%, WIN_H+OFF_Y%)
    _DISPLAY
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BM'