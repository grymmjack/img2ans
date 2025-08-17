' === QB64PE BBOX with Resize Handles and Corners ===

' --- [1] Types ---
CONST MARGIN = 6
CONST HANDLE_SIZE = 6

CONST HANDLE_NONE = 0
CONST HANDLE_TL = 1, HANDLE_T = 2, HANDLE_TR = 3
CONST HANDLE_L  = 4,                HANDLE_R = 5
CONST HANDLE_BL = 6, HANDLE_B = 7, HANDLE_BR = 8

TYPE MouseState
    x AS INTEGER
    y AS INTEGER
    dx AS INTEGER
    dy AS INTEGER
    held AS INTEGER
    clicked AS INTEGER
    released AS INTEGER
END TYPE

TYPE BBOX
    x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
    state AS INTEGER ' 0=idle, 1=hover, 2=drag, 100+=resizing from handle
    offsetX AS INTEGER
    offsetY AS INTEGER
    hoverHandle AS INTEGER
    activeHandle AS INTEGER
END TYPE

' --- [3] Main ---
DIM mouse AS MouseState
DIM box AS BBOX
DIM boxColor AS _UNSIGNED LONG

box.x = 300
box.y = 200
box.w = 150
box.h = 100
box.state = 0
box.hoverHandle = 0

SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE BBOX - Resize Handles"
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

PollMouse mouse, 1

DO
    PollMouse mouse, 0

    box.hoverHandle = GetHoverHandle%(mouse.x, mouse.y, box)

    ' === FSM ===
    SELECT CASE box.state
        CASE 0 ' idle
            IF PointInBox%(mouse.x, mouse.y, box) THEN
                box.state = 1 ' hover
            ELSEIF box.hoverHandle THEN
                ' stay idle, just highlight handle
            END IF

        CASE 1 ' hover
            IF NOT PointInBox%(mouse.x, mouse.y, box) THEN
                IF box.hoverHandle = 0 THEN
                    box.state = 0
                END IF
            ELSEIF mouse.clicked THEN
                box.offsetX = mouse.x - box.x
                box.offsetY = mouse.y - box.y
                box.state = 2 ' dragging
            END IF

        CASE 2 ' dragging
            IF mouse.held THEN
                box.x = mouse.x - box.offsetX
                box.y = mouse.y - box.offsetY
            ELSE
                box.state = 1
            END IF

        CASE IS >= 100 ' resizing from handle
            IF mouse.held THEN
                ResizeFromHandle box, mouse
                ' Clamp min size
                IF box.w < 20 THEN box.w = 20
                IF box.h < 20 THEN box.h = 20
            ELSE
                box.state = 0
            END IF
    END SELECT

    ' === Start resize if clicked on handle ===
    IF box.state < 100 AND box.hoverHandle AND mouse.clicked THEN
        box.activeHandle = box.hoverHandle
        box.state = 100 + box.activeHandle
    END IF

    ' === DRAW ===
    CLS

    SELECT CASE box.state
        CASE 0
            IF box.hoverHandle THEN
                boxColor = _RGB32(255, 255, 0) ' edge/corner hover
            ELSE
                boxColor = _RGB32(128, 128, 128)
            END IF
        CASE 1: boxColor = _RGB32(64, 128, 255)
        CASE 2: boxColor = _RGB32(0, 255, 0)
        CASE IS >= 100: boxColor = _RGB32(255, 0, 255)
    END SELECT

    ' Draw box
    LINE (box.x, box.y)-(box.x + box.w, box.y + box.h), boxColor, B

    ' Draw resize handles
    DrawHandles box, box.hoverHandle

    ' Status text
    COLOR _RGB32(255, 255, 255)
    LOCATE 2, 2
    PRINT "State:"; box.state; " HoverHandle:"; box.hoverHandle
    _DISPLAY
LOOP UNTIL _KEYHIT = 27

END

' --- [2] Subs and Functions ---
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

FUNCTION PointInBox% (mx AS INTEGER, my AS INTEGER, b AS BBOX)
    IF mx >= b.x AND mx <= b.x + b.w AND my >= b.y AND my <= b.y + b.h THEN
        PointInBox% = -1
    ELSE
        PointInBox% = 0
    END IF
END FUNCTION

FUNCTION GetHoverHandle% (mx AS INTEGER, my AS INTEGER, b AS BBOX)
    DIM cx AS INTEGER, cy AS INTEGER

    cx = b.x + b.w \ 2
    cy = b.y + b.h \ 2

    IF PointInRect(mx, my, b.x - MARGIN, b.y - MARGIN, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_TL: EXIT FUNCTION
    IF PointInRect(mx, my, cx - HANDLE_SIZE \ 2, b.y - MARGIN, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_T: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - HANDLE_SIZE \ 2, b.y - MARGIN, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_TR: EXIT FUNCTION

    IF PointInRect(mx, my, b.x - MARGIN, cy - HANDLE_SIZE \ 2, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_L: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - HANDLE_SIZE \ 2, cy - HANDLE_SIZE \ 2, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_R: EXIT FUNCTION

    IF PointInRect(mx, my, b.x - MARGIN, b.y + b.h - HANDLE_SIZE \ 2, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_BL: EXIT FUNCTION
    IF PointInRect(mx, my, cx - HANDLE_SIZE \ 2, b.y + b.h - HANDLE_SIZE \ 2, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_B: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - HANDLE_SIZE \ 2, b.y + b.h - HANDLE_SIZE \ 2, HANDLE_SIZE, HANDLE_SIZE) THEN GetHoverHandle% = HANDLE_BR: EXIT FUNCTION

    GetHoverHandle% = HANDLE_NONE
END FUNCTION

FUNCTION PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
    IF px >= rx AND px <= rx + rw AND py >= ry AND py <= ry + rh THEN
        PointInRect% = -1
    ELSE
        PointInRect% = 0
    END IF
END FUNCTION

SUB DrawHandles (b AS BBOX, hover AS INTEGER)
    DIM cx AS INTEGER, cy AS INTEGER
    DIM c AS _UNSIGNED LONG

    cx = b.x + b.w \ 2
    cy = b.y + b.h \ 2

    c = _RGB32(255, 255, 255)
    IF hover THEN c = _RGB32(255, 255, 0)

    LINE (b.x - MARGIN, b.y - MARGIN)-(b.x - MARGIN + HANDLE_SIZE, b.y - MARGIN + HANDLE_SIZE), c, B ' TL
    LINE (cx - HANDLE_SIZE \ 2, b.y - MARGIN)-(cx + HANDLE_SIZE \ 2, b.y - MARGIN + HANDLE_SIZE), c, B ' T
    LINE (b.x + b.w - HANDLE_SIZE \ 2, b.y - MARGIN)-(b.x + b.w + HANDLE_SIZE \ 2, b.y - MARGIN + HANDLE_SIZE), c, B ' TR

    LINE (b.x - MARGIN, cy - HANDLE_SIZE \ 2)-(b.x - MARGIN + HANDLE_SIZE, cy + HANDLE_SIZE \ 2), c, B ' L
    LINE (b.x + b.w - HANDLE_SIZE \ 2, cy - HANDLE_SIZE \ 2)-(b.x + b.w + HANDLE_SIZE \ 2, cy + HANDLE_SIZE \ 2), c, B ' R

    LINE (b.x - MARGIN, b.y + b.h - HANDLE_SIZE \ 2)-(b.x - MARGIN + HANDLE_SIZE, b.y + b.h + HANDLE_SIZE \ 2), c, B ' BL
    LINE (cx - HANDLE_SIZE \ 2, b.y + b.h - HANDLE_SIZE \ 2)-(cx + HANDLE_SIZE \ 2, b.y + b.h + HANDLE_SIZE \ 2), c, B ' B
    LINE (b.x + b.w - HANDLE_SIZE \ 2, b.y + b.h - HANDLE_SIZE \ 2)-(b.x + b.w + HANDLE_SIZE \ 2, b.y + b.h + HANDLE_SIZE \ 2), c, B ' BR
END SUB

SUB ResizeFromHandle (b AS BBOX, m AS MouseState)
    SELECT CASE b.activeHandle
        CASE HANDLE_TL
            b.w = b.w + (b.x - m.x)
            b.h = b.h + (b.y - m.y)
            b.x = m.x
            b.y = m.y
        CASE HANDLE_T
            b.h = b.h + (b.y - m.y)
            b.y = m.y
        CASE HANDLE_TR
            b.w = m.x - b.x
            b.h = b.h + (b.y - m.y)
            b.y = m.y
        CASE HANDLE_L
            b.w = b.w + (b.x - m.x)
            b.x = m.x
        CASE HANDLE_R
            b.w = m.x - b.x
        CASE HANDLE_BL
            b.w = b.w + (b.x - m.x)
            b.h = m.y - b.y
            b.x = m.x
        CASE HANDLE_B
            b.h = m.y - b.y
        CASE HANDLE_BR
            b.w = m.x - b.x
            b.h = m.y - b.y
    END SELECT
END SUB
