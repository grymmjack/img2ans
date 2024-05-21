$DEBUG
SCREEN _NEWIMAGE(800, 600, 32)
_TITLE "BBOX Mouse States Demo"

CONST TRUE = -1
CONST FALSE = NOT TRUE

CONST STATE_DESELECTED = 0
CONST STATE_OVER = 1
CONST STATE_SELECTED = 2
CONST STATE_MOVING = 3
CONST STATE_RESIZING = 4
CONST STATE_ZOOMING = 5

REDIM SHARED AS INTEGER _
    mouseX, mouseY, _
    mouseB, mouseOldB, _
    state, dragging, _
    dragStartX, dragStartY, _
    bboxX, bboxY, _
    bboxWidth, bboxHeight

BBOXMouseStates
SYSTEM

SUB BBOXMouseStates
    ' Initialize the bounding box
    bboxX = 200
    bboxY = 150
    bboxWidth = 200
    bboxHeight = 150

    ' Initial state
    state = STATE_DESELECTED

    DO
        _LIMIT 60
        CLS
        DO WHILE _MOUSEINPUT:
            mouseX = _MOUSEX
            mouseY = _MOUSEY
            mouseB = _MOUSEBUTTON(1)
        LOOP

        SELECT CASE state
            CASE STATE_DESELECTED
                IF MouseOverBBox(mouseX, mouseY, bboxX, bboxY, bboxWidth, bboxHeight) THEN
                    state = STATE_OVER
                END IF
            CASE STATE_OVER
                IF NOT MouseOverBBox(mouseX, mouseY, bboxX, bboxY, bboxWidth, bboxHeight) THEN
                    state = STATE_DESELECTED
                ELSEIF mouseB THEN
                    state = STATE_SELECTED
                END IF
            CASE STATE_SELECTED
                IF NOT mouseB AND NOT MouseOverBBox(mouseX, mouseY, bboxX, bboxY, bboxWidth, bboxHeight) THEN
                    state = STATE_DESELECTED
                ELSEIF mouseB THEN
                    dragging = TRUE
                    dragStartX = mouseX
                    dragStartY = mouseY
                    IF MouseOnEdge(mouseX, mouseY, bboxX, bboxY, bboxWidth, bboxHeight) THEN
                        state = STATE_RESIZING
                    ELSE
                        state = STATE_MOVING
                    END IF
                END IF
            CASE STATE_MOVING
                IF NOT mouseB THEN
                    state = STATE_SELECTED
                    dragging = FALSE
                ELSE
                    bboxX = bboxX + (mouseX - dragStartX)
                    bboxY = bboxY + (mouseY - dragStartY)
                    dragStartX = mouseX
                    dragStartY = mouseY
                END IF
            CASE STATE_RESIZING
                IF NOT mouseB THEN
                    state = STATE_SELECTED
                    dragging = FALSE
                ELSE
                    ' Handle resizing
                    IF mouseX < bboxX THEN bboxWidth = bboxWidth + (bboxX - mouseX): bboxX = mouseX
                    IF mouseX > bboxX + bboxWidth THEN bboxWidth = mouseX - bboxX
                    IF mouseY < bboxY THEN bboxHeight = bboxHeight + (bboxY - mouseY): bboxY = mouseY
                    IF mouseY > bboxY + bboxHeight THEN bboxHeight = mouseY - bboxY
                END IF
        END SELECT

        ' Draw the bounding box
        LINE (bboxX, bboxY)-(bboxX + bboxWidth, bboxY + bboxHeight), _RGB32(255, 0, 0), B

        ' Display current state
        SELECT CASE state
            CASE STATE_DESELECTED: PRINT "State: DESELECTED"
            CASE STATE_OVER: PRINT "State: OVER"
            CASE STATE_SELECTED: PRINT "State: SELECTED"
            CASE STATE_MOVING: PRINT "State: MOVING"
            CASE STATE_RESIZING: PRINT "State: RESIZING"
            CASE STATE_ZOOMING: PRINT "State: ZOOMING"
        END SELECT

        _DISPLAY

        mouseOldB = mouseB
    LOOP UNTIL INKEY$ = CHR$(27) ' Exit on ESC key
END SUB

FUNCTION MouseOverBBox (mx, my, bx, by, bw, bh)
    IF mx >= bx AND mx <= bx + bw AND my >= by AND my <= by + bh THEN
        MouseOverBBox = TRUE
    ELSE
        MouseOverBBox = FALSE
    END IF
END FUNCTION

FUNCTION MouseOnEdge (mx, my, bx, by, bw, bh)
    IF (mx >= bx AND mx <= bx + 5) OR (mx <= bx + bw AND mx >= bx + bw - 5) OR _
       (my >= by AND my <= by + 5) OR (my <= by + bh AND my >= by + bh - 5) THEN
        MouseOnEdge = TRUE
    ELSE
        MouseOnEdge = FALSE
    END IF
END FUNCTION
