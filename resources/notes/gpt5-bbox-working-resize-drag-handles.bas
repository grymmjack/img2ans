' === QB64PE BBOX - Move & Resize (Library-style; Update/Draw from your loop) ===
' Namespaced GJ_BBX_*; filled, colorized handles; init + update + draw API.

' --------------------------- Declarations ---------------------------

' Config record
TYPE GJ_BBX_CFG
    HandleHalfSize       AS INTEGER
    HandleFullSize       AS INTEGER
    EdgeHalfSize         AS INTEGER
    EdgeFullSize         AS INTEGER
    HandleCornerSize     AS INTEGER
    HandleEdgeSize       AS INTEGER
    DragEdgePadding      AS INTEGER
    MinBoxWidth          AS INTEGER
    MinBoxHeight         AS INTEGER
    colorIdle            AS _UNSIGNED LONG
    colorHoverOnly       AS _UNSIGNED LONG
    colorSelectedOnly    AS _UNSIGNED LONG
    colorSelectedHover   AS _UNSIGNED LONG
    colorDragging        AS _UNSIGNED LONG
    colorResizing        AS _UNSIGNED LONG
    HandleFillColor      AS _UNSIGNED LONG
    HandleHoverFillColor AS _UNSIGNED LONG
    HandleBorderColor    AS _UNSIGNED LONG
    initX                AS INTEGER
    initY                AS INTEGER
    initW                AS INTEGER
    initH                AS INTEGER
END TYPE

' Engine constants
CONST GJ_BBX_STATE_IDLE = 0
CONST GJ_BBX_STATE_HOVER = 1
CONST GJ_BBX_STATE_DRAG = 2
CONST GJ_BBX_STATE_SELECTED = 10
CONST GJ_BBX_STATE_SELECTED_HOVER = 11
CONST GJ_BBX_STATE_RESIZE_BASE = 100

CONST GJ_BBX_HANDLE_NONE = 0
CONST GJ_BBX_HANDLE_TL = 1, GJ_BBX_HANDLE_T = 2, GJ_BBX_HANDLE_TR = 3
CONST GJ_BBX_HANDLE_L = 4,  GJ_BBX_HANDLE_R = 5
CONST GJ_BBX_HANDLE_BL = 6, GJ_BBX_HANDLE_B = 7, GJ_BBX_HANDLE_BR = 8

' Extended key codes (arrow + ctrl-arrow)
CONST GJ_BBX_KEY_LEFT = 19200
CONST GJ_BBX_KEY_RIGHT = 19712
CONST GJ_BBX_KEY_UP = 18432
CONST GJ_BBX_KEY_DOWN = 20480
CONST GJ_BBX_KEY_CTRL_LEFT = 115 * 256
CONST GJ_BBX_KEY_CTRL_RIGHT = 116 * 256
CONST GJ_BBX_KEY_CTRL_UP = 141 * 256
CONST GJ_BBX_KEY_CTRL_DOWN = 145 * 256

' Engine types
TYPE GJ_BBX_MouseState
    x AS INTEGER
    y AS INTEGER
    dx AS INTEGER
    dy AS INTEGER
    held AS INTEGER
    clicked AS INTEGER
    released AS INTEGER
END TYPE

TYPE GJ_BBX_BBOX
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

' Shared state
DIM SHARED GJ_BBX_CFG AS GJ_BBX_CFG
DIM SHARED GJ_BBX_mouse AS GJ_BBX_MouseState
DIM SHARED GJ_BBX_box AS GJ_BBX_BBOX

' --- Public API prototypes ---
DECLARE SUB GJ_BBX_InitDefaults ()
DECLARE SUB GJ_BBX_InitWithConfig (cfg AS GJ_BBX_CFG)
DECLARE SUB GJ_BBX_InitBox (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
DECLARE SUB GJ_BBX_Update ()
DECLARE SUB GJ_BBX_Draw (showHUD AS INTEGER)
DECLARE SUB GJ_BBX_Tick (showHUD AS INTEGER)

' --- Internals prototypes ---
DECLARE SUB GJ_BBX_PollMouse (m AS GJ_BBX_MouseState, init AS INTEGER)
DECLARE FUNCTION GJ_BBX_PointInBox% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
DECLARE FUNCTION GJ_BBX_GetHoverHandle% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
DECLARE FUNCTION GJ_BBX_PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
DECLARE SUB GJ_BBX_ResizeFromHandle (b AS GJ_BBX_BBOX, m AS GJ_BBX_MouseState)
DECLARE SUB GJ_BBX_DrawHandles (b AS GJ_BBX_BBOX, hover AS INTEGER)

' --------------------------- Demo main ---------------------------
' (Remove this block when you include the library in your own project.)

SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE BBOX Library Demo - Arrows move, Ctrl+Arrows resize (Shift=10x)"
$RESIZE:ON
_DISPLAYORDER _SOFTWARE
_MOUSESHOW

GJ_BBX_InitDefaults

DO
    CLS
    GJ_BBX_Tick -1  ' show HUD
    _DISPLAY
LOOP UNTIL _KEYHIT = 27
END

' --------------------------- Implementations ---------------------------

SUB GJ_BBX_InitDefaults
    ' default config
    GJ_BBX_CFG.HandleHalfSize = 16
    GJ_BBX_CFG.HandleFullSize = GJ_BBX_CFG.HandleHalfSize * 2
    GJ_BBX_CFG.EdgeHalfSize = 10
    GJ_BBX_CFG.EdgeFullSize = GJ_BBX_CFG.EdgeHalfSize * 2
    GJ_BBX_CFG.HandleCornerSize = GJ_BBX_CFG.HandleFullSize
    GJ_BBX_CFG.HandleEdgeSize = GJ_BBX_CFG.EdgeFullSize
    GJ_BBX_CFG.DragEdgePadding = 8
    GJ_BBX_CFG.MinBoxWidth = 32
    GJ_BBX_CFG.MinBoxHeight = 32

    GJ_BBX_CFG.colorIdle = _RGB32(128, 128, 128)
    GJ_BBX_CFG.colorHoverOnly = _RGB32(255, 255, 0)
    GJ_BBX_CFG.colorSelectedOnly = _RGB32(0, 128, 255)
    GJ_BBX_CFG.colorSelectedHover = _RGB32(255, 128, 0)
    GJ_BBX_CFG.colorDragging = _RGB32(0, 255, 0)
    GJ_BBX_CFG.colorResizing = _RGB32(255, 0, 255)

    GJ_BBX_CFG.HandleFillColor = _RGB32(255, 255, 255)
    GJ_BBX_CFG.HandleHoverFillColor = _RGB32(255, 255, 0)
    GJ_BBX_CFG.HandleBorderColor = _RGB32(0, 0, 0)

    GJ_BBX_CFG.initX = 300
    GJ_BBX_CFG.initY = 200
    GJ_BBX_CFG.initW = 150
    GJ_BBX_CFG.initH = 100

    GJ_BBX_InitBox GJ_BBX_CFG.initX, GJ_BBX_CFG.initY, GJ_BBX_CFG.initW, GJ_BBX_CFG.initH
    GJ_BBX_PollMouse GJ_BBX_mouse, 1
END SUB

SUB GJ_BBX_InitWithConfig (cfg AS GJ_BBX_CFG)
    GJ_BBX_CFG = cfg
    GJ_BBX_InitBox GJ_BBX_CFG.initX, GJ_BBX_CFG.initY, GJ_BBX_CFG.initW, GJ_BBX_CFG.initH
    GJ_BBX_PollMouse GJ_BBX_mouse, 1
END SUB

SUB GJ_BBX_InitBox (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
    GJ_BBX_box.x = x
    GJ_BBX_box.y = y
    GJ_BBX_box.w = w
    GJ_BBX_box.h = h
    GJ_BBX_box.state = GJ_BBX_STATE_IDLE
    GJ_BBX_box.selected = 0
    GJ_BBX_box.hoverHandle = 0
    GJ_BBX_box.activeHandle = 0
    GJ_BBX_box.offsetX = 0
    GJ_BBX_box.offsetY = 0
    GJ_BBX_box.wasClickedInside = 0
END SUB

SUB GJ_BBX_Update
    DIM k AS STRING
    DIM keyCode AS INTEGER
    DIM movement AS INTEGER
    DIM did AS INTEGER

    GJ_BBX_PollMouse GJ_BBX_mouse, 0
    GJ_BBX_box.hoverHandle = GJ_BBX_GetHoverHandle%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box)

    IF GJ_BBX_box.state < GJ_BBX_STATE_RESIZE_BASE AND GJ_BBX_box.hoverHandle AND GJ_BBX_mouse.clicked THEN
        GJ_BBX_box.activeHandle = GJ_BBX_box.hoverHandle
        GJ_BBX_box.state = GJ_BBX_STATE_RESIZE_BASE + GJ_BBX_box.activeHandle
        GJ_BBX_box.selected = -1
        GJ_BBX_box.wasClickedInside = 0
    ELSEIF GJ_BBX_box.state < GJ_BBX_STATE_RESIZE_BASE AND GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) AND GJ_BBX_mouse.clicked THEN
        GJ_BBX_box.offsetX = GJ_BBX_mouse.x - GJ_BBX_box.x
        GJ_BBX_box.offsetY = GJ_BBX_mouse.y - GJ_BBX_box.y
        GJ_BBX_box.state = GJ_BBX_STATE_DRAG
        GJ_BBX_box.selected = -1
        GJ_BBX_box.wasClickedInside = -1
    END IF

    IF GJ_BBX_box.state >= GJ_BBX_STATE_RESIZE_BASE THEN
        IF GJ_BBX_mouse.held THEN
            GJ_BBX_ResizeFromHandle GJ_BBX_box, GJ_BBX_mouse
            IF GJ_BBX_box.w < GJ_BBX_CFG.MinBoxWidth THEN GJ_BBX_box.w = GJ_BBX_CFG.MinBoxWidth
            IF GJ_BBX_box.h < GJ_BBX_CFG.MinBoxHeight THEN GJ_BBX_box.h = GJ_BBX_CFG.MinBoxHeight
        ELSE
            GJ_BBX_box.state = GJ_BBX_STATE_SELECTED
        END IF
    ELSEIF GJ_BBX_box.state = GJ_BBX_STATE_DRAG THEN
        IF GJ_BBX_mouse.held THEN
            GJ_BBX_box.x = GJ_BBX_mouse.x - GJ_BBX_box.offsetX
            GJ_BBX_box.y = GJ_BBX_mouse.y - GJ_BBX_box.offsetY
        ELSE
            GJ_BBX_box.state = GJ_BBX_STATE_SELECTED
            GJ_BBX_box.selected = -1
        END IF
    ELSE
        IF GJ_BBX_mouse.released THEN
            IF GJ_BBX_box.wasClickedInside THEN
                GJ_BBX_box.selected = -1
                GJ_BBX_box.wasClickedInside = 0
            ELSEIF NOT GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) THEN
                GJ_BBX_box.selected = 0
                GJ_BBX_box.state = GJ_BBX_STATE_IDLE
                GJ_BBX_box.wasClickedInside = 0
            END IF
        END IF

        IF GJ_BBX_box.selected THEN
            IF GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) THEN
                GJ_BBX_box.state = GJ_BBX_STATE_SELECTED_HOVER
            ELSE
                GJ_BBX_box.state = GJ_BBX_STATE_SELECTED
            END IF
        ELSE
            IF GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) THEN
                GJ_BBX_box.state = GJ_BBX_STATE_HOVER
            ELSE
                GJ_BBX_box.state = GJ_BBX_STATE_IDLE
            END IF
        END IF
    END IF

    ' Keyboard: arrows move; Ctrl+arrows resize; Shift speeds up
    IF GJ_BBX_box.selected THEN
        k = INKEY$
        IF LEN(k) THEN
            keyCode = ASC(k)
            IF keyCode = 0 OR keyCode = 224 THEN
                keyCode = ASC(RIGHT$(k, 1)) * 256

                movement = 1
                IF _KEYDOWN(100304) OR _KEYDOWN(100303) THEN movement = 10 ' Shift

                IF _KEYDOWN(100306) OR _KEYDOWN(100305) THEN
                    movement = 1
                    IF _KEYDOWN(100304) OR _KEYDOWN(100303) THEN movement = 10

                    did = 0
                    SELECT CASE keyCode
                        CASE GJ_BBX_KEY_LEFT,  GJ_BBX_KEY_CTRL_LEFT:   GJ_BBX_box.w = GJ_BBX_box.w - movement: did = -1
                        CASE GJ_BBX_KEY_RIGHT, GJ_BBX_KEY_CTRL_RIGHT:  GJ_BBX_box.w = GJ_BBX_box.w + movement: did = -1
                        CASE GJ_BBX_KEY_UP,    GJ_BBX_KEY_CTRL_UP:     GJ_BBX_box.h = GJ_BBX_box.h - movement: did = -1
                        CASE GJ_BBX_KEY_DOWN,  GJ_BBX_KEY_CTRL_DOWN:   GJ_BBX_box.h = GJ_BBX_box.h + movement: did = -1
                    END SELECT

                    IF did THEN
                        IF GJ_BBX_box.w < GJ_BBX_CFG.MinBoxWidth THEN GJ_BBX_box.w = GJ_BBX_CFG.MinBoxWidth
                        IF GJ_BBX_box.h < GJ_BBX_CFG.MinBoxHeight THEN GJ_BBX_box.h = GJ_BBX_CFG.MinBoxHeight
                    END IF
                ELSE
                    SELECT CASE keyCode
                        CASE GJ_BBX_KEY_LEFT:  GJ_BBX_box.x = GJ_BBX_box.x - movement
                        CASE GJ_BBX_KEY_RIGHT: GJ_BBX_box.x = GJ_BBX_box.x + movement
                        CASE GJ_BBX_KEY_UP:    GJ_BBX_box.y = GJ_BBX_box.y - movement
                        CASE GJ_BBX_KEY_DOWN:  GJ_BBX_box.y = GJ_BBX_box.y + movement
                    END SELECT
                END IF
            END IF
        END IF
    END IF

    ' Cursor feedback
    SELECT CASE GJ_BBX_box.state
        CASE IS >= GJ_BBX_STATE_RESIZE_BASE
            SELECT CASE GJ_BBX_box.activeHandle
                CASE GJ_BBX_HANDLE_TL, GJ_BBX_HANDLE_TR, GJ_BBX_HANDLE_BL, GJ_BBX_HANDLE_BR
                    _MOUSESHOW "CROSSHAIR"
                CASE GJ_BBX_HANDLE_L, GJ_BBX_HANDLE_R
                    _MOUSESHOW "HORIZONTAL"
                CASE GJ_BBX_HANDLE_T, GJ_BBX_HANDLE_B
                    _MOUSESHOW "VERTICAL"
            END SELECT
        CASE GJ_BBX_STATE_DRAG
            _MOUSESHOW "CROSSHAIR"
        CASE ELSE
            SELECT CASE GJ_BBX_box.hoverHandle
                CASE GJ_BBX_HANDLE_TL, GJ_BBX_HANDLE_TR, GJ_BBX_HANDLE_BL, GJ_BBX_HANDLE_BR
                    _MOUSESHOW "CROSSHAIR"
                CASE GJ_BBX_HANDLE_L, GJ_BBX_HANDLE_R
                    _MOUSESHOW "HORIZONTAL"
                CASE GJ_BBX_HANDLE_T, GJ_BBX_HANDLE_B
                    _MOUSESHOW "VERTICAL"
                CASE ELSE
                    _MOUSESHOW "DEFAULT"
            END SELECT
    END SELECT
END SUB

SUB GJ_BBX_Draw (showHUD AS INTEGER)
    DIM boxColor AS _UNSIGNED LONG

    SELECT CASE GJ_BBX_box.state
        CASE GJ_BBX_STATE_DRAG: boxColor = GJ_BBX_CFG.colorDragging
        CASE IS >= GJ_BBX_STATE_RESIZE_BASE: boxColor = GJ_BBX_CFG.colorResizing
        CASE GJ_BBX_STATE_SELECTED_HOVER: boxColor = GJ_BBX_CFG.colorSelectedHover
        CASE GJ_BBX_STATE_SELECTED: boxColor = GJ_BBX_CFG.colorSelectedOnly
        CASE GJ_BBX_STATE_HOVER: boxColor = GJ_BBX_CFG.colorHoverOnly
        CASE ELSE: boxColor = GJ_BBX_CFG.colorIdle
    END SELECT

    LINE (GJ_BBX_box.x, GJ_BBX_box.y)-(GJ_BBX_box.x + GJ_BBX_box.w, GJ_BBX_box.y + GJ_BBX_box.h), boxColor, B
    GJ_BBX_DrawHandles GJ_BBX_box, GJ_BBX_box.hoverHandle

    IF showHUD THEN
        COLOR _RGB32(255, 255, 255)
        LOCATE 2, 2
        PRINT "State:"; GJ_BBX_box.state; "  HoverHandle:"; GJ_BBX_box.hoverHandle; "  Selected:"; GJ_BBX_box.selected
    END IF
END SUB

SUB GJ_BBX_Tick (showHUD AS INTEGER)
    GJ_BBX_Update
    GJ_BBX_Draw showHUD
END SUB

SUB GJ_BBX_PollMouse (m AS GJ_BBX_MouseState, init AS INTEGER)
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

FUNCTION GJ_BBX_PointInBox% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
    GJ_BBX_PointInBox% = (mx >= b.x AND mx <= b.x + b.w AND my >= b.y AND my <= b.y + b.h)
END FUNCTION

FUNCTION GJ_BBX_GetHoverHandle% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
    DIM cx AS INTEGER: cx = b.x + b.w \ 2
    DIM cy AS INTEGER: cy = b.y + b.h \ 2

    IF GJ_BBX_PointInRect%(mx, my, b.x - GJ_BBX_CFG.HandleHalfSize, b.y - GJ_BBX_CFG.HandleHalfSize, GJ_BBX_CFG.HandleFullSize, GJ_BBX_CFG.HandleFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_TL: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, cx - GJ_BBX_CFG.EdgeHalfSize, b.y - GJ_BBX_CFG.EdgeHalfSize, GJ_BBX_CFG.EdgeFullSize, GJ_BBX_CFG.EdgeFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_T: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, b.x + b.w - GJ_BBX_CFG.HandleHalfSize, b.y - GJ_BBX_CFG.HandleHalfSize, GJ_BBX_CFG.HandleFullSize, GJ_BBX_CFG.HandleFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_TR: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, b.x - GJ_BBX_CFG.EdgeHalfSize, cy - GJ_BBX_CFG.EdgeHalfSize, GJ_BBX_CFG.EdgeFullSize, GJ_BBX_CFG.EdgeFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_L: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, b.x + b.w - GJ_BBX_CFG.EdgeHalfSize, cy - GJ_BBX_CFG.EdgeHalfSize, GJ_BBX_CFG.EdgeFullSize, GJ_BBX_CFG.EdgeFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_R: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, b.x - GJ_BBX_CFG.HandleHalfSize, b.y + b.h - GJ_BBX_CFG.HandleHalfSize, GJ_BBX_CFG.HandleFullSize, GJ_BBX_CFG.HandleFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_BL: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, cx - GJ_BBX_CFG.EdgeHalfSize, b.y + b.h - GJ_BBX_CFG.EdgeHalfSize, GJ_BBX_CFG.EdgeFullSize, GJ_BBX_CFG.EdgeFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_B: EXIT FUNCTION
    IF GJ_BBX_PointInRect%(mx, my, b.x + b.w - GJ_BBX_CFG.HandleHalfSize, b.y + b.h - GJ_BBX_CFG.HandleHalfSize, GJ_BBX_CFG.HandleFullSize, GJ_BBX_CFG.HandleFullSize) THEN GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_BR: EXIT FUNCTION

    GJ_BBX_GetHoverHandle% = GJ_BBX_HANDLE_NONE
END FUNCTION

FUNCTION GJ_BBX_PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
    GJ_BBX_PointInRect% = (px >= rx AND px <= rx + rw AND py >= ry AND py <= ry + rh)
END FUNCTION

SUB GJ_BBX_ResizeFromHandle (b AS GJ_BBX_BBOX, m AS GJ_BBX_MouseState)
    SELECT CASE b.activeHandle
        CASE GJ_BBX_HANDLE_TL
            b.w = b.w + (b.x - m.x): b.h = b.h + (b.y - m.y)
            b.x = m.x: b.y = m.y
        CASE GJ_BBX_HANDLE_T
            b.h = b.h + (b.y - m.y): b.y = m.y
        CASE GJ_BBX_HANDLE_TR
            b.w = m.x - b.x: b.h = b.h + (b.y - m.y): b.y = m.y
        CASE GJ_BBX_HANDLE_L
            b.w = b.w + (b.x - m.x): b.x = m.x
        CASE GJ_BBX_HANDLE_R
            b.w = m.x - b.x
        CASE GJ_BBX_HANDLE_BL
            b.w = b.w + (b.x - m.x): b.h = m.y - b.y: b.x = m.x
        CASE GJ_BBX_HANDLE_B
            b.h = m.y - b.y
        CASE GJ_BBX_HANDLE_BR
            b.w = m.x - b.x: b.h = m.y - b.y
    END SELECT
END SUB

SUB GJ_BBX_DrawHandles (b AS GJ_BBX_BBOX, hover AS INTEGER)
    DIM cx AS INTEGER: cx = b.x + b.w \ 2
    DIM cy AS INTEGER: cy = b.y + b.h \ 2

    DIM hh AS INTEGER: hh = GJ_BBX_CFG.HandleHalfSize
    DIM eh AS INTEGER: eh = GJ_BBX_CFG.EdgeHalfSize

    DIM cFill AS _UNSIGNED LONG, cBorder AS _UNSIGNED LONG
    cBorder = GJ_BBX_CFG.HandleBorderColor

    DIM x1 AS INTEGER, y1 AS INTEGER, x2 AS INTEGER, y2 AS INTEGER, isH AS INTEGER

    ' ---- TL ----
    x1 = b.x - hh: y1 = b.y - hh: x2 = b.x + hh - 1: y2 = b.y + hh - 1
    isH = (hover = GJ_BBX_HANDLE_TL): GOSUB DrawOne
    ' ---- T ----
    x1 = cx - eh: y1 = b.y - eh: x2 = cx + eh - 1: y2 = b.y + eh - 1
    isH = (hover = GJ_BBX_HANDLE_T): GOSUB DrawOne
    ' ---- TR ----
    x1 = b.x + b.w - hh: y1 = b.y - hh: x2 = b.x + b.w + hh - 1: y2 = b.y + hh - 1
    isH = (hover = GJ_BBX_HANDLE_TR): GOSUB DrawOne
    ' ---- L ----
    x1 = b.x - eh: y1 = cy - eh: x2 = b.x + eh - 1: y2 = cy + eh - 1
    isH = (hover = GJ_BBX_HANDLE_L): GOSUB DrawOne
    ' ---- R ----
    x1 = b.x + b.w - eh: y1 = cy - eh: x2 = b.x + b.w + eh - 1: y2 = cy + eh - 1
    isH = (hover = GJ_BBX_HANDLE_R): GOSUB DrawOne
    ' ---- BL ----
    x1 = b.x - hh: y1 = b.y + b.h - hh: x2 = b.x + hh - 1: y2 = b.y + b.h + hh - 1
    isH = (hover = GJ_BBX_HANDLE_BL): GOSUB DrawOne
    ' ---- B ----
    x1 = cx - eh: y1 = b.y + b.h - eh: x2 = cx + eh - 1: y2 = b.y + b.h + eh - 1
    isH = (hover = GJ_BBX_HANDLE_B): GOSUB DrawOne
    ' ---- BR ----
    x1 = b.x + b.w - hh: y1 = b.y + b.h - hh: x2 = b.x + b.w + hh - 1: y2 = b.y + b.h + hh - 1
    isH = (hover = GJ_BBX_HANDLE_BR): GOSUB DrawOne

    EXIT SUB

DrawOne:
    IF isH THEN
        cFill = GJ_BBX_CFG.HandleHoverFillColor
    ELSE
        cFill = GJ_BBX_CFG.HandleFillColor
    END IF
    LINE (x1, y1)-(x2, y2), cFill, BF
    LINE (x1, y1)-(x2, y2), cBorder, B
RETURN
END SUB
