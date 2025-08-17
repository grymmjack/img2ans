' === QB64PE-Compatible MouseState Poller (No OPTIONAL) ===

TYPE MouseState
    x AS INTEGER
    y AS INTEGER
    dx AS INTEGER
    dy AS INTEGER
    held AS INTEGER
    clicked AS INTEGER
    released AS INTEGER
END TYPE

DIM mouse AS MouseState

SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE PollMouse Module (Fixed)"
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

' Initialize last known state
PollMouse mouse, 1 ' ← init = 1

DO
    PollMouse mouse, 0 ' ← normal use

    CLS
    COLOR _RGB32(255, 255, 255)
    LOCATE 2, 2
    PRINT "Mouse X     :"; mouse.x
    PRINT "Mouse Y     :"; mouse.y
    PRINT "Delta X     :"; mouse.dx
    PRINT "Delta Y     :"; mouse.dy
    PRINT "Held        :"; mouse.held
    PRINT "Clicked     :"; mouse.clicked
    PRINT "Released    :"; mouse.released

    _DISPLAY
LOOP UNTIL _KEYHIT = 27
END

SUB PollMouse (m AS MouseState, initFlag AS INTEGER)
    STATIC lastX AS INTEGER
    STATIC lastY AS INTEGER
    STATIC lastHeld AS INTEGER

    IF initFlag THEN
        lastX = _MOUSEX
        lastY = _MOUSEY
        lastHeld = _MOUSEBUTTON(1)
        m.x = lastX
        m.y = lastY
        m.dx = 0
        m.dy = 0
        m.held = lastHeld
        m.clicked = 0
        m.released = 0
        EXIT SUB
    END IF

    m.clicked = 0
    m.released = 0

    WHILE _MOUSEINPUT
        m.x = _MOUSEX
        m.y = _MOUSEY

        IF m.x <> lastX OR m.y <> lastY THEN
            m.dx = m.x - lastX
            m.dy = m.y - lastY
            lastX = m.x
            lastY = m.y
        END IF

        m.held = _MOUSEBUTTON(1)

        IF m.held = -1 AND lastHeld = 0 THEN
            m.clicked = -1
        ELSEIF m.held = 0 AND lastHeld = -1 THEN
            m.released = -1
        END IF

        lastHeld = m.held
    WEND
END SUB
