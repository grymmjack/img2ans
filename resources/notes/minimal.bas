SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE Delta Tracker (Only on Movement)"
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

DIM lastX AS INTEGER, lastY AS INTEGER
DIM mx AS INTEGER, my AS INTEGER
DIM dx AS INTEGER, dy AS INTEGER

DO
    WHILE _MOUSEINPUT
        mx = _MOUSEX
        my = _MOUSEY

        IF mx <> lastX OR my <> lastY THEN
            dx = mx - lastX
            dy = my - lastY
            lastX = mx
            lastY = my
        END IF
    WEND

    CLS
    LOCATE 2, 2
    PRINT "Mouse X     :"; mx
    PRINT "Mouse Y     :"; my
    PRINT "Delta X     :"; dx
    PRINT "Delta Y     :"; dy
    PRINT "_MOUSEBUTTON(1):"; _MOUSEBUTTON(1)
    _DISPLAY
LOOP UNTIL _KEYHIT = 27
