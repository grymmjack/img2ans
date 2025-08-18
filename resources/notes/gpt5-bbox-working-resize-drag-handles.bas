''
' GRYMMJACK'S Bounding BOX (BBOX) LIB FOR QB64
'
' This library provides a set of functions for creating and manipulating
' bounding boxes in QB64. This includes features like resizing, dragging,
' and handle management. 
'
' This library is designed to be easy to use and integrate into your QB64PE
' projects by configuring, updating, and drawing from your own internal loops.
'
' - Resizing is done by dragging the edges or corners of the bounding box. 
' - Selecting a handle will change the mouse cursor and resize.
' - Using arrow keys will move the box by 1px.
' - Holding SHIFT while using arrow keys will move the box by 10px.
' - Holding CTRL while using arrow keys will resize the box by 1px.
' - Holding CTRL + SHIFT while using arrow keys will resize the box by 10px.
'
' --- Public API prototypes ---
' SUB GJ_BBX_InitDefaults ()
' SUB GJ_BBX_InitWithConfig (cfg AS GJ_BBX_CFG)
' SUB GJ_BBX_InitBox (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
' SUB GJ_BBX_Update ()
' SUB GJ_BBX_Draw (showHUD AS INTEGER)
' SUB GJ_BBX_Tick (showHUD AS INTEGER)

' --- Internals prototypes ---
' SUB GJ_BBX_PollMouse (m AS GJ_BBX_MouseState, init AS INTEGER)
' FUNCTION GJ_BBX_PointInBox% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
' FUNCTION GJ_BBX_GetHoverHandle% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
' FUNCTION GJ_BBX_PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
' SUB GJ_BBX_ResizeFromHandle (b AS GJ_BBX_BBOX, m AS GJ_BBX_MouseState)
' SUB GJ_BBX_DrawHandles (b AS GJ_BBX_BBOX, hover AS INTEGER)

' @author Rick Christy <grymmjack@gmail.com>
' @ai Chat GPT 5 Thinking (planning and building outside vscode)
' @ai Claude Sonnet 4 (last mile refinement in copilot)
'

''
' BOUNDING BOX CONFIGURATION
' This type holds all configuration options for the bounding box.
' For colors you can use RGB, RGB32, RGBA, or RGBA32, or any _UNSIGNED LONG
' 
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
    KeyRepeatDelay       AS DOUBLE
    KeyRepeatRate        AS DOUBLE
END TYPE


''
' ENGINE CONSTANTS
'
CONST GJ_BBX_STATE_IDLE           = 0
CONST GJ_BBX_STATE_HOVER          = 1
CONST GJ_BBX_STATE_DRAG           = 2
CONST GJ_BBX_STATE_SELECTED       = 10
CONST GJ_BBX_STATE_SELECTED_HOVER = 11
CONST GJ_BBX_STATE_RESIZE_BASE    = 100
CONST GJ_BBX_HANDLE_NONE          = 0
CONST GJ_BBX_HANDLE_TL            = 1, GJ_BBX_HANDLE_T = 2, GJ_BBX_HANDLE_TR = 3
CONST GJ_BBX_HANDLE_L             = 4, GJ_BBX_HANDLE_R = 5
CONST GJ_BBX_HANDLE_BL            = 6, GJ_BBX_HANDLE_B = 7, GJ_BBX_HANDLE_BR = 8
CONST GJ_BBX_KEY_LEFT_CTRL        = 100306
CONST GJ_BBX_KEY_RIGHT_CTRL       = 100305
CONST GJ_BBX_KEY_RSHIFT           = 100303
CONST GJ_BBX_KEY_LSHIFT           = 100304


''
' ENGINE TYPES
'
TYPE GJ_BBX_MouseState
    x        AS INTEGER
    y        AS INTEGER
    dx       AS INTEGER
    dy       AS INTEGER
    held     AS INTEGER
    clicked  AS INTEGER
    released AS INTEGER
END TYPE

''
' BOUNDING BOX
'
TYPE GJ_BBX_BBOX
    x                AS INTEGER
    y                AS INTEGER
    w                AS INTEGER
    h                AS INTEGER
    state            AS INTEGER
    offsetX          AS INTEGER
    offsetY          AS INTEGER
    hoverHandle      AS INTEGER
    activeHandle     AS INTEGER
    selected         AS INTEGER
    wasClickedInside AS INTEGER
END TYPE

' SHARED STATE
DIM SHARED GJ_BBX_CFG AS GJ_BBX_CFG
DIM SHARED GJ_BBX_mouse AS GJ_BBX_MouseState
DIM SHARED GJ_BBX_box AS GJ_BBX_BBOX

' Arrow key constants (same as keywatch.bas)
DIM SHARED GJ_BBX_KEY_LEFT&, GJ_BBX_KEY_RIGHT&, GJ_BBX_KEY_UP&, GJ_BBX_KEY_DOWN&
GJ_BBX_KEY_LEFT&  = CVI(CHR$(0) + "K") ' Left arrow
GJ_BBX_KEY_RIGHT& = CVI(CHR$(0) + "M") ' Right arrow
GJ_BBX_KEY_UP&    = CVI(CHR$(0) + "H") ' Up arrow
GJ_BBX_KEY_DOWN&  = CVI(CHR$(0) + "P") ' Down arrow


' --------------------------- DEMO MAIN ---------------------------
' (Remove this block when you include the library in your own project.)

SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "QB64PE BBOX Library Demo - Arrows move, Ctrl+Arrows resize (Shift=10x)"
$RESIZE:ON
_DISPLAYORDER _SOFTWARE
_MOUSESHOW

GJ_BBX_InitDefaults

DO
    CLS
    GJ_BBX_Tick _TRUE  ' show HUD
    _DISPLAY
LOOP UNTIL _KEYHIT = 27
END


' --------------------------- IMPLEMENTATIONS ---------------------------

''
' Initialize the bounding box with defaults
' Use this block to customize your own bounding box with GJ_BBX_CFG
'
SUB GJ_BBX_InitDefaults
    ' Default config
    GJ_BBX_CFG.HandleHalfSize       = 6
    GJ_BBX_CFG.HandleFullSize       = GJ_BBX_CFG.HandleHalfSize * 2
    GJ_BBX_CFG.EdgeHalfSize         = 4
    GJ_BBX_CFG.EdgeFullSize         = GJ_BBX_CFG.EdgeHalfSize * 2
    GJ_BBX_CFG.HandleCornerSize     = GJ_BBX_CFG.HandleFullSize
    GJ_BBX_CFG.HandleEdgeSize       = GJ_BBX_CFG.EdgeFullSize
    GJ_BBX_CFG.DragEdgePadding      = 8
    GJ_BBX_CFG.MinBoxWidth          = 32
    GJ_BBX_CFG.MinBoxHeight         = 32

    GJ_BBX_CFG.colorIdle            = _RGB32(128, 128, 128)
    GJ_BBX_CFG.colorHoverOnly       = _RGB32(255, 255, 0)
    GJ_BBX_CFG.colorSelectedOnly    = _RGB32(255, 128, 0)
    GJ_BBX_CFG.colorSelectedHover   = _RGB32(255, 128, 0)
    GJ_BBX_CFG.colorDragging        = _RGB32(0, 255, 0)
    GJ_BBX_CFG.colorResizing        = _RGB32(255, 0, 255)

    GJ_BBX_CFG.HandleFillColor      = _RGBA32(255, 255, 255, 0)
    GJ_BBX_CFG.HandleHoverFillColor = _RGB32(255, 255, 255)
    GJ_BBX_CFG.HandleBorderColor    = _RGB32(255, 255, 255)

    GJ_BBX_CFG.KeyRepeatDelay       = 0.1
    GJ_BBX_CFG.KeyRepeatRate        = 0.05

    GJ_BBX_CFG.initX = 300
    GJ_BBX_CFG.initY = 200
    GJ_BBX_CFG.initW = 150
    GJ_BBX_CFG.initH = 100

    ' Initialize the bounding box
    GJ_BBX_InitBox _
        GJ_BBX_CFG.initX, _
        GJ_BBX_CFG.initY, _
        GJ_BBX_CFG.initW, _
        GJ_BBX_CFG.initH

    ' Poll the mouse state
    GJ_BBX_PollMouse GJ_BBX_mouse, _TRUE
END SUB

''
' Initialize with config passed in
' @param cfg GJ_BBX_CFG
'
SUB GJ_BBX_InitWithConfig (cfg AS GJ_BBX_CFG)
    GJ_BBX_CFG = cfg
    GJ_BBX_InitBox GJ_BBX_CFG.initX, GJ_BBX_CFG.initY, GJ_BBX_CFG.initW, GJ_BBX_CFG.initH
    GJ_BBX_PollMouse GJ_BBX_mouse, _TRUE
END SUB

''
' Initialize the bounding box
' @param x INTEGER x Position
' @param y INTEGER y Position
' @param w INTEGER Width
' @param h INTEGER Height
'
SUB GJ_BBX_InitBox (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
    GJ_BBX_box.x                = x
    GJ_BBX_box.y                = y
    GJ_BBX_box.w                = w
    GJ_BBX_box.h                = h
    GJ_BBX_box.state            = GJ_BBX_STATE_IDLE
    GJ_BBX_box.selected         = _FALSE
    GJ_BBX_box.hoverHandle      = GJ_BBX_HANDLE_NONE
    GJ_BBX_box.activeHandle     = GJ_BBX_HANDLE_NONE
    GJ_BBX_box.offsetX          = 0
    GJ_BBX_box.offsetY          = 0
    GJ_BBX_box.wasClickedInside = _FALSE
END SUB

''
' Update the bounding box state
' This is the main worker SUB and handles input and state changes
' This should be called from your own main loop
' 
SUB GJ_BBX_Update
    GJ_BBX_PollMouse GJ_BBX_mouse, _FALSE
    GJ_BBX_box.hoverHandle = GJ_BBX_GetHoverHandle%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box)

    IF GJ_BBX_box.state < GJ_BBX_STATE_RESIZE_BASE AND GJ_BBX_box.hoverHandle AND GJ_BBX_mouse.clicked THEN
        GJ_BBX_box.activeHandle = GJ_BBX_box.hoverHandle
        GJ_BBX_box.state = GJ_BBX_STATE_RESIZE_BASE + GJ_BBX_box.activeHandle
        GJ_BBX_box.selected = _TRUE
        GJ_BBX_box.wasClickedInside = _FALSE
    ELSEIF GJ_BBX_box.state < GJ_BBX_STATE_RESIZE_BASE AND GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) AND GJ_BBX_mouse.clicked THEN
        GJ_BBX_box.offsetX = GJ_BBX_mouse.x - GJ_BBX_box.x
        GJ_BBX_box.offsetY = GJ_BBX_mouse.y - GJ_BBX_box.y
        GJ_BBX_box.state = GJ_BBX_STATE_DRAG
        GJ_BBX_box.selected = _TRUE
        GJ_BBX_box.wasClickedInside = _TRUE
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
            GJ_BBX_box.selected = _TRUE
        END IF
    ELSE
        IF GJ_BBX_mouse.released THEN
            IF GJ_BBX_box.wasClickedInside THEN
                GJ_BBX_box.selected = _TRUE
                GJ_BBX_box.wasClickedInside = _FALSE
            ELSEIF NOT GJ_BBX_PointInBox%(GJ_BBX_mouse.x, GJ_BBX_mouse.y, GJ_BBX_box) THEN
                GJ_BBX_box.selected = _FALSE
                GJ_BBX_box.state = GJ_BBX_STATE_IDLE
                GJ_BBX_box.wasClickedInside = _FALSE
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
        DIM movement AS INTEGER
        DIM isCtrl AS INTEGER, isShift AS INTEGER
        
        ' Check modifier states
        isCtrl = (_KEYDOWN(GJ_BBX_KEY_LEFT_CTRL) OR _KEYDOWN(GJ_BBX_KEY_RIGHT_CTRL)) <> 0
        isShift = (_KEYDOWN(GJ_BBX_KEY_LSHIFT) OR _KEYDOWN(GJ_BBX_KEY_RSHIFT)) <> 0
        
        ' Set movement amount
        IF isShift THEN movement = 10 ELSE movement = 1
        
        ' Handle keyboard input using _KEYDOWN() with key repeat
        STATIC AS INTEGER lastLeft, lastRight, lastUp, lastDown
        STATIC AS DOUBLE leftTimer, rightTimer, upTimer, downTimer
        
        DIM AS INTEGER leftNow, rightNow, upNow, downNow
        DIM currentTime AS DOUBLE
        
        leftNow% = _KEYDOWN(GJ_BBX_KEY_LEFT&) <> 0
        rightNow% = _KEYDOWN(GJ_BBX_KEY_RIGHT&) <> 0
        upNow% = _KEYDOWN(GJ_BBX_KEY_UP&) <> 0
        downNow% = _KEYDOWN(GJ_BBX_KEY_DOWN&) <> 0
        currentTime# = TIMER
        
        ' LEFT KEY
        IF leftNow% THEN
            IF NOT lastLeft% THEN
                ' Key just pressed - immediate action
                leftTimer# = currentTime#
                IF isCtrl THEN
                    GJ_BBX_box.w = GJ_BBX_box.w - movement
                    IF GJ_BBX_box.w < GJ_BBX_CFG.MinBoxWidth THEN GJ_BBX_box.w = GJ_BBX_CFG.MinBoxWidth
                ELSE
                    GJ_BBX_box.x = GJ_BBX_box.x - movement
                END IF
            ELSEIF currentTime# - leftTimer# > GJ_BBX_CFG.KeyRepeatDelay THEN
                ' Key held down - check for repeat
                IF currentTime# - leftTimer# > GJ_BBX_CFG.KeyRepeatDelay + GJ_BBX_CFG.KeyRepeatRate THEN
                    leftTimer# = currentTime# - GJ_BBX_CFG.KeyRepeatDelay
                    IF isCtrl THEN
                        GJ_BBX_box.w = GJ_BBX_box.w - movement
                        IF GJ_BBX_box.w < GJ_BBX_CFG.MinBoxWidth THEN GJ_BBX_box.w = GJ_BBX_CFG.MinBoxWidth
                    ELSE
                        GJ_BBX_box.x = GJ_BBX_box.x - movement
                    END IF
                END IF
            END IF
        END IF
        
        ' RIGHT KEY
        IF rightNow% THEN
            IF NOT lastRight% THEN
                ' Key just pressed - immediate action
                rightTimer# = currentTime#
                IF isCtrl THEN
                    GJ_BBX_box.w = GJ_BBX_box.w + movement
                ELSE
                    GJ_BBX_box.x = GJ_BBX_box.x + movement
                END IF
            ELSEIF currentTime# - rightTimer# > GJ_BBX_CFG.KeyRepeatDelay THEN
                ' Key held down - check for repeat
                IF currentTime# - rightTimer# > GJ_BBX_CFG.KeyRepeatDelay + GJ_BBX_CFG.KeyRepeatRate THEN
                    rightTimer# = currentTime# - GJ_BBX_CFG.KeyRepeatDelay
                    IF isCtrl THEN
                        GJ_BBX_box.w = GJ_BBX_box.w + movement
                    ELSE
                        GJ_BBX_box.x = GJ_BBX_box.x + movement
                    END IF
                END IF
            END IF
        END IF
        
        ' UP KEY
        IF upNow% THEN
            IF NOT lastUp% THEN
                ' Key just pressed - immediate action
                upTimer# = currentTime#
                IF isCtrl THEN
                    GJ_BBX_box.h = GJ_BBX_box.h - movement
                    IF GJ_BBX_box.h < GJ_BBX_CFG.MinBoxHeight THEN GJ_BBX_box.h = GJ_BBX_CFG.MinBoxHeight
                ELSE
                    GJ_BBX_box.y = GJ_BBX_box.y - movement
                END IF
            ELSEIF currentTime# - upTimer# > GJ_BBX_CFG.KeyRepeatDelay THEN
                ' Key held down - check for repeat
                IF currentTime# - upTimer# > GJ_BBX_CFG.KeyRepeatDelay + GJ_BBX_CFG.KeyRepeatRate THEN
                    upTimer# = currentTime# - GJ_BBX_CFG.KeyRepeatDelay
                    IF isCtrl THEN
                        GJ_BBX_box.h = GJ_BBX_box.h - movement
                        IF GJ_BBX_box.h < GJ_BBX_CFG.MinBoxHeight THEN GJ_BBX_box.h = GJ_BBX_CFG.MinBoxHeight
                    ELSE
                        GJ_BBX_box.y = GJ_BBX_box.y - movement
                    END IF
                END IF
            END IF
        END IF
        
        ' DOWN KEY
        IF downNow% THEN
            IF NOT lastDown% THEN
                ' Key just pressed - immediate action
                downTimer# = currentTime#
                IF isCtrl THEN
                    GJ_BBX_box.h = GJ_BBX_box.h + movement
                ELSE
                    GJ_BBX_box.y = GJ_BBX_box.y + movement
                END IF
            ELSEIF currentTime# - downTimer# > GJ_BBX_CFG.KeyRepeatDelay THEN
                ' Key held down - check for repeat
                IF currentTime# - downTimer# > GJ_BBX_CFG.KeyRepeatDelay + GJ_BBX_CFG.KeyRepeatRate THEN
                    downTimer# = currentTime# - GJ_BBX_CFG.KeyRepeatDelay
                    IF isCtrl THEN
                        GJ_BBX_box.h = GJ_BBX_box.h + movement
                    ELSE
                        GJ_BBX_box.y = GJ_BBX_box.y + movement
                    END IF
                END IF
            END IF
        END IF
        
        ' Store current states for next frame
        lastLeft% = leftNow%
        lastRight% = rightNow%
        lastUp% = upNow%
        lastDown% = downNow%
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
            _MOUSESHOW "MOVE"
        CASE GJ_BBX_STATE_HOVER
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


''
' Draw the bounding box
' @param showHUD INTEGER Show the HUD debug information? (TRUE | FALSE)
'
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

    LINE (GJ_BBX_box.x, GJ_BBX_box.y)-(GJ_BBX_box.x + GJ_BBX_box.w, GJ_BBX_box.y + GJ_BBX_box.h), boxColor, B, &B0101010101010101
    GJ_BBX_DrawHandles GJ_BBX_box, GJ_BBX_box.hoverHandle

    IF showHUD THEN
        COLOR _RGB32(255, 255, 255)
        LOCATE 2, 2
        PRINT "State:"; GJ_BBX_box.state; "  HoverHandle:"; GJ_BBX_box.hoverHandle; "  Selected:"; GJ_BBX_box.selected
    END IF
END SUB


''
' This is a convenience SUB for updating and drawing the bounding box
' You can call this single SUB from your main loop
' @param showHUD INTEGER Show the HUD debug information? (TRUE | FALSE)
'
SUB GJ_BBX_Tick (showHUD AS INTEGER)
    GJ_BBX_Update
    GJ_BBX_Draw showHUD
END SUB


''
' Poll the mouse state
' @param m GJ_BBX_MouseState The mouse state to update
' @param init INTEGER Is this the initial poll? (TRUE | FALSE)
'
SUB GJ_BBX_PollMouse (m AS GJ_BBX_MouseState, init AS INTEGER)
    STATIC lastX AS INTEGER, lastY AS INTEGER, lastHeld AS INTEGER

    IF init THEN
        lastX = _MOUSEX: lastY = _MOUSEY: lastHeld = _MOUSEBUTTON(1)
        m.x = lastX: m.y = lastY: m.dx = 0: m.dy = 0
        m.held = lastHeld: m.clicked = _FALSE: m.released = _FALSE
        EXIT SUB
    END IF

    m.clicked = _FALSE: m.released = _FALSE

    WHILE _MOUSEINPUT
        m.x = _MOUSEX: m.y = _MOUSEY
        IF m.x <> lastX OR m.y <> lastY THEN
            m.dx = m.x - lastX: m.dy = m.y - lastY
            lastX = m.x: lastY = m.y
        END IF

        m.held = _MOUSEBUTTON(1)

        IF m.held = _TRUE AND lastHeld = _FALSE THEN m.clicked = _TRUE
        IF m.held = _FALSE AND lastHeld = _TRUE THEN m.released = _TRUE

        lastHeld = m.held
    WEND
END SUB


''
' Check if a point is inside a bounding box
' Used for mouse interaction and collision detection
' @param mx INTEGER The x-coordinate of the point
' @param my INTEGER The y-coordinate of the point
' @param b GJ_BBX_BBOX The bounding box to check against
' @return INTEGER (TRUE | FALSE)
'
FUNCTION GJ_BBX_PointInBox% (mx AS INTEGER, my AS INTEGER, b AS GJ_BBX_BBOX)
    GJ_BBX_PointInBox% = (mx >= b.x AND mx <= b.x + b.w AND my >= b.y AND my <= b.y + b.h)
END FUNCTION


''
' Get the hover handle for a point
' @param mx INTEGER The mouse x-coordinate of the point
' @param my INTEGER The mouse y-coordinate of the point
' @param b GJ_BBX_BBOX The bounding box to check against
' @return GJ_BBX_HANDLE_(TL|T|TR|L|R|BL|B|BR|NONE) handle that is hovered over
'
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


''
' Check if a point is inside a rectangle
' @param px INTEGER The x-coordinate of the point
' @param py INTEGER The y-coordinate of the point
' @param rx INTEGER The x-coordinate of the rectangle
' @param ry INTEGER The y-coordinate of the rectangle
' @param rw INTEGER The width of the rectangle
' @param rh INTEGER The height of the rectangle
' @return INTEGER (TRUE | FALSE)
'
FUNCTION GJ_BBX_PointInRect% (px AS INTEGER, py AS INTEGER, rx AS INTEGER, ry AS INTEGER, rw AS INTEGER, rh AS INTEGER)
    GJ_BBX_PointInRect% = (px >= rx AND px <= rx + rw AND py >= ry AND py <= ry + rh)
END FUNCTION


''
' Resize the bounding box from the active handle
' @param b GJ_BBX_BBOX The bounding box to resize
' @param m GJ_BBX_MouseState The current mouse state
'
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


''
' Draw the resize handles for a bounding box
' @param b GJ_BBX_BBOX The bounding box to draw handles for
' @param hover INTEGER The currently hovered handle
'        one of GJ_BBX_HANDLE_(TL|T|TR|L|R|BL|B|BR|NONE)
'
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
