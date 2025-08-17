' === QB64PE BBOX - Arrow Keys: Move & Resize ===

' --- [1] Constants & Types ---
CONST HANDLE_HALF_SIZE = 8
CONST HANDLE_FULL_SIZE = HANDLE_HALF_SIZE * 2
CONST EDGE_HALF_SIZE = 5
CONST EDGE_FULL_SIZE = EDGE_HALF_SIZE * 2

CONST HANDLE_CORNER_SIZE = HANDLE_FULL_SIZE
CONST HANDLE_EDGE_SIZE = EDGE_FULL_SIZE
CONST DRAG_EDGE_PADDING = 8
CONST MIN_BOX_WIDTH = 32
CONST MIN_BOX_HEIGHT = 32

CONST STATE_IDLE = 0
CONST STATE_HOVER = 1
CONST STATE_DRAG = 2
CONST STATE_SELECTED = 10
CONST STATE_SELECTED_HOVER = 11
CONST STATE_RESIZE_BASE = 100

CONST HANDLE_NONE = 0
CONST HANDLE_TL = 1, HANDLE_T = 2, HANDLE_TR = 3
CONST HANDLE_L  = 4,                HANDLE_R = 5
CONST HANDLE_BL = 6, HANDLE_B = 7, HANDLE_BR = 8

CONST KEY_LEFT = 19200
CONST KEY_RIGHT = 19712
CONST KEY_UP = 18432
CONST KEY_DOWN = 20480

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
    state AS INTEGER
    offsetX AS INTEGER
    offsetY AS INTEGER
    hoverHandle AS INTEGER
    activeHandle AS INTEGER
    selected AS INTEGER
    wasClickedInside AS INTEGER
END TYPE

' --- [2] Main ---
DIM mouse AS MouseState
DIM box AS BBOX
DIM boxColor AS _UNSIGNED LONG

DIM colorIdle AS _UNSIGNED LONG: colorIdle = _RGB32(128, 128, 128)
DIM colorHoverOnly AS _UNSIGNED LONG: colorHoverOnly = _RGB32(255, 255, 0)
DIM colorSelectedOnly AS _UNSIGNED LONG: colorSelectedOnly = _RGB32(0, 128, 255)
DIM colorSelectedHover AS _UNSIGNED LONG: colorSelectedHover = _RGB32(255, 128, 0)
DIM colorDragging AS _UNSIGNED LONG: colorDragging = _RGB32(0, 255, 0)
DIM colorResizing AS _UNSIGNED LONG: colorResizing = _RGB32(255, 0, 255)

box.x = 300
box.y = 200
box.w = 150
box.h = 100
box.state = STATE_IDLE
box.selected = 0

SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE BBOX - Arrows Move + Resize"
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

PollMouse mouse, 1

DO
    PollMouse mouse, 0
    box.hoverHandle = GetHoverHandle%(mouse.x, mouse.y, box)

    IF box.state < STATE_RESIZE_BASE AND box.hoverHandle AND mouse.clicked THEN
        box.activeHandle = box.hoverHandle
        box.state = STATE_RESIZE_BASE + box.activeHandle
        box.selected = -1
        box.wasClickedInside = 0
    ELSEIF box.state < STATE_RESIZE_BASE AND PointInBox%(mouse.x, mouse.y, box) AND mouse.clicked THEN
        box.offsetX = mouse.x - box.x
        box.offsetY = mouse.y - box.y
        box.state = STATE_DRAG
        box.selected = -1
        box.wasClickedInside = -1
    END IF

    IF box.state >= STATE_RESIZE_BASE THEN
        IF mouse.held THEN
            ResizeFromHandle box, mouse
            IF box.w < MIN_BOX_WIDTH THEN box.w = MIN_BOX_WIDTH
            IF box.h < MIN_BOX_HEIGHT THEN box.h = MIN_BOX_HEIGHT
        ELSE
            box.state = STATE_SELECTED
        END IF
    ELSEIF box.state = STATE_DRAG THEN
        IF mouse.held THEN
            box.x = mouse.x - box.offsetX
            box.y = mouse.y - box.offsetY
        ELSE
            box.state = STATE_SELECTED
            box.selected = -1
        END IF
    ELSE
        IF mouse.released THEN
            IF box.wasClickedInside THEN
                box.selected = -1
                box.wasClickedInside = 0
            ELSEIF NOT PointInBox%(mouse.x, mouse.y, box) THEN
                box.selected = 0
                box.state = STATE_IDLE
                box.wasClickedInside = 0
            END IF
        END IF

        IF box.selected THEN
            IF PointInBox%(mouse.x, mouse.y, box) THEN
                box.state = STATE_SELECTED_HOVER
            ELSE
                box.state = STATE_SELECTED
            END IF
        ELSE
            IF PointInBox%(mouse.x, mouse.y, box) THEN
                box.state = STATE_HOVER
            ELSE
                box.state = STATE_IDLE
            END IF
        END IF
    END IF

    IF box.selected THEN
        k$ = INKEY$
        IF LEN(k$) THEN
            kCode = ASC(k$)
            IF kCode = 0 OR kCode = 224 THEN
                kCode = ASC(RIGHT$(k$, 1)) + (ASC(LEFT$(k$, 1)) * 256)
                movement = 1
                IF _KEYDOWN(100304) OR _KEYDOWN(100305) THEN movement = 10

                IF _KEYDOWN(100306) OR _KEYDOWN(100307) THEN
                    SELECT CASE kCode
                        CASE KEY_LEFT:  box.w = box.w - movement
                        CASE KEY_RIGHT: box.w = box.w + movement
                        CASE KEY_UP:    box.h = box.h - movement
                        CASE KEY_DOWN:  box.h = box.h + movement
                    END SELECT
                    IF box.w < MIN_BOX_WIDTH THEN box.w = MIN_BOX_WIDTH
                    IF box.h < MIN_BOX_HEIGHT THEN box.h = MIN_BOX_HEIGHT
                ELSE
                    SELECT CASE kCode
                        CASE KEY_LEFT:  box.x = box.x - movement
                        CASE KEY_RIGHT: box.x = box.x + movement
                        CASE KEY_UP:    box.y = box.y - movement
                        CASE KEY_DOWN:  box.y = box.y + movement
                    END SELECT
                END IF
            END IF
        END IF
    END IF

    SELECT CASE box.state
        CASE STATE_DRAG
            boxColor = colorDragging
        CASE IS >= STATE_RESIZE_BASE
            boxColor = colorResizing
        CASE STATE_SELECTED_HOVER
            boxColor = colorSelectedHover
        CASE STATE_SELECTED
            boxColor = colorSelectedOnly
        CASE STATE_HOVER
            boxColor = colorHoverOnly
        CASE ELSE
            boxColor = colorIdle
    END SELECT

    CLS
    LINE (box.x, box.y)-(box.x + box.w, box.y + box.h), boxColor, B
    DrawHandles box, box.hoverHandle

    COLOR _RGB32(255, 255, 255)
    LOCATE 2, 2
    PRINT "State:"; box.state; " HoverHandle:"; box.hoverHandle; " Selected:"; box.selected
    _DISPLAY
LOOP UNTIL _KEYHIT = 27

END

SUB PollMouse (m AS MouseState, init AS INTEGER)
    STATIC lastX AS INTEGER, lastY AS INTEGER, lastHeld AS INTEGER

    IF init THEN
        lastX = _MOUSEX: lastY = _MOUSEY: lastHeld = _MOUSEBUTTON(1)
        m.x = lastX: m.y = lastY: m.dx = 0: m.dy = 0
        m.held = lastHeld: m.clicked = 0: m.released = 0
        EXIT SUB
    END IF

    m.clicked = 0: m.released = 0

    WHILE _MOUSEINPUT
        m.x = _MOUSEX: m.y = _MOUSEY
        IF m.x <> lastX OR m.y <> lastY THEN
            m.dx = m.x - lastX: m.dy = m.y - lastY
            lastX = m.x: lastY = m.y
        END IF

        m.held = _MOUSEBUTTON(1)

        IF m.held = -1 AND lastHeld = 0 THEN m.clicked = -1
        IF m.held = 0 AND lastHeld = -1 THEN m.released = -1

        lastHeld = m.held
    WEND
END SUB

FUNCTION PointInBox% (mx AS INTEGER, my AS INTEGER, b AS BBOX)
    PointInBox% = (mx >= b.x AND mx <= b.x + b.w AND my >= b.y AND my <= b.y + b.h)
END FUNCTION

FUNCTION GetHoverHandle% (mx AS INTEGER, my AS INTEGER, b AS BBOX)
    DIM cx AS INTEGER: cx = b.x + b.w \ 2
    DIM cy AS INTEGER: cy = b.y + b.h \ 2

    IF PointInRect(mx, my, b.x - HANDLE_HALF_SIZE, b.y - HANDLE_HALF_SIZE, HANDLE_FULL_SIZE, HANDLE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_TL: EXIT FUNCTION
    IF PointInRect(mx, my, cx - EDGE_HALF_SIZE, b.y - EDGE_HALF_SIZE, EDGE_FULL_SIZE, EDGE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_T: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - HANDLE_HALF_SIZE, b.y - HANDLE_HALF_SIZE, HANDLE_FULL_SIZE, HANDLE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_TR: EXIT FUNCTION
    IF PointInRect(mx, my, b.x - EDGE_HALF_SIZE, cy - EDGE_HALF_SIZE, EDGE_FULL_SIZE, EDGE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_L: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - EDGE_HALF_SIZE, cy - EDGE_HALF_SIZE, EDGE_FULL_SIZE, EDGE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_R: EXIT FUNCTION
    IF PointInRect(mx, my, b.x - HANDLE_HALF_SIZE, b.y + b.h - HANDLE_HALF_SIZE, HANDLE_FULL_SIZE, HANDLE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_BL: EXIT FUNCTION
    IF PointInRect(mx, my, cx - EDGE_HALF_SIZE, b.y + b.h - EDGE_HALF_SIZE, EDGE_FULL_SIZE, EDGE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_B: EXIT FUNCTION
    IF PointInRect(mx, my, b.x + b.w - HANDLE_HALF_SIZE, b.y + b.h - HANDLE_HALF_SIZE, HANDLE_FULL_SIZE, HANDLE_FULL_SIZE) THEN GetHoverHandle% = HANDLE_BR: EXIT FUNCTION

    GetHoverHandle% = HANDLE_NONE
END FUNCTION

FUNCTION PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
    PointInRect% = (px >= rx AND px <= rx + rw AND py >= ry AND py <= ry + rh)
END FUNCTION

SUB ResizeFromHandle (b AS BBOX, m AS MouseState)
    SELECT CASE b.activeHandle
        CASE HANDLE_TL
            b.w = b.w + (b.x - m.x): b.h = b.h + (b.y - m.y)
            b.x = m.x: b.y = m.y
        CASE HANDLE_T
            b.h = b.h + (b.y - m.y): b.y = m.y
        CASE HANDLE_TR
            b.w = m.x - b.x: b.h = b.h + (b.y - m.y): b.y = m.y
        CASE HANDLE_L
            b.w = b.w + (b.x - m.x): b.x = m.x
        CASE HANDLE_R
            b.w = m.x - b.x
        CASE HANDLE_BL
            b.w = b.w + (b.x - m.x): b.h = m.y - b.y: b.x = m.x
        CASE HANDLE_B
            b.h = m.y - b.y
        CASE HANDLE_BR
            b.w = m.x - b.x: b.h = m.y - b.y
    END SELECT
END SUB

SUB DrawHandles (b AS BBOX, hover AS INTEGER)
    DIM cx AS INTEGER: cx = b.x + b.w \ 2
    DIM cy AS INTEGER: cy = b.y + b.h \ 2
    DIM c AS _UNSIGNED LONG: c = _RGB32(255, 255, 255)

    LINE (b.x - HANDLE_HALF_SIZE, b.y - HANDLE_HALF_SIZE)-(b.x + HANDLE_HALF_SIZE, b.y + HANDLE_HALF_SIZE), c, B
    LINE (b.x + b.w - HANDLE_HALF_SIZE, b.y - HANDLE_HALF_SIZE)-(b.x + b.w + HANDLE_HALF_SIZE, b.y + HANDLE_HALF_SIZE), c, B
    LINE (b.x - HANDLE_HALF_SIZE, b.y + b.h - HANDLE_HALF_SIZE)-(b.x + HANDLE_HALF_SIZE, b.y + b.h + HANDLE_HALF_SIZE), c, B
    LINE (b.x + b.w - HANDLE_HALF_SIZE, b.y + b.h - HANDLE_HALF_SIZE)-(b.x + b.w + HANDLE_HALF_SIZE, b.y + b.h + HANDLE_HALF_SIZE), c, B

    LINE (cx - EDGE_HALF_SIZE, b.y - EDGE_HALF_SIZE)-(cx + EDGE_HALF_SIZE, b.y + EDGE_HALF_SIZE), c, B
    LINE (b.x - EDGE_HALF_SIZE, cy - EDGE_HALF_SIZE)-(b.x + EDGE_HALF_SIZE, cy + EDGE_HALF_SIZE), c, B
    LINE (cx - EDGE_HALF_SIZE, b.y + b.h - EDGE_HALF_SIZE)-(cx + EDGE_HALF_SIZE, b.y + b.h + EDGE_HALF_SIZE), c, B
    LINE (b.x + b.w - EDGE_HALF_SIZE, cy - EDGE_HALF_SIZE)-(b.x + b.w + EDGE_HALF_SIZE, cy + EDGE_HALF_SIZE), c, B
END SUB
