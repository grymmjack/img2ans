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
 
CONST MENU_CLOSED = 0
CONST MENU_OPEN = 1
 
REDIM SHARED AS INTEGER _
    mouseX, mouseY, _
    mouseB, mouseOldB, _
    state, dragging, _
    dragStartX, dragStartY, _
    bboxX, bboxY, _
    bboxWidth, bboxHeight, _
    resizeDirection, _
    topBoxX, topBoxY, _
    topBoxWidth, topBoxHeight, _
    menuState
 
BBOXMouseStates
SYSTEM
 
SUB BBOXMouseStates
    ' Αρχικοποίηση του πρώτου κουτιού
    bboxX = 200
    bboxY = 150
    bboxWidth = 200
    bboxHeight = 150
 
    ' Αρχικοποίηση του δεύτερου κουτιού (πάνω κουτί)
    topBoxX = bboxX
    topBoxY = bboxY - 30 ' Τοποθέτηση πάνω από το πρώτο κουτί
    topBoxWidth = bboxWidth
    topBoxHeight = 30
 
    ' Αρχική κατάσταση
    state = STATE_DESELECTED
    menuState = MENU_CLOSED
 
    DO
        _LIMIT 60
        CLS
        DO WHILE _MOUSEINPUT
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
                    resizeDirection = MouseResizeDirection(mouseX, mouseY, bboxX, bboxY, bboxWidth, bboxHeight)
                    IF resizeDirection <> 0 THEN
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
                    ' Διαχείριση αλλαγής μεγέθους
                    IF resizeDirection AND 1 THEN ' Αριστερή πλευρά
                        IF mouseX < bboxX + bboxWidth THEN
                            bboxWidth = bboxWidth + (bboxX - mouseX)
                            bboxX = mouseX
                        END IF
                    END IF
                    IF resizeDirection AND 2 THEN ' Δεξιά πλευρά
                        IF mouseX > bboxX THEN
                            bboxWidth = mouseX - bboxX
                        END IF
                    END IF
                    IF resizeDirection AND 4 THEN ' Άνω πλευρά
                        IF mouseY < bboxY + bboxHeight THEN
                            bboxHeight = bboxHeight + (bboxY - mouseY)
                            bboxY = mouseY
                        END IF
                    END IF
                    IF resizeDirection AND 8 THEN ' Κάτω πλευρά
                        IF mouseY > bboxY THEN
                            bboxHeight = mouseY - bboxY
                        END IF
                    END IF
                END IF
        END SELECT
 
        ' Ενημέρωση του πάνω κουτιού για να ακολουθεί το πρώτο κουτί
        topBoxX = bboxX
        topBoxY = bboxY - topBoxHeight
        topBoxWidth = bboxWidth
 
        ' Σχεδίαση του πρώτου κουτιού με πιο χοντρό περίγραμμα
        DrawThickBox bboxX, bboxY, bboxWidth, bboxHeight, 3
 
        ' Σχεδίαση του πάνω κουτιού με πιο χοντρό περίγραμμα
        DrawThickBox topBoxX, topBoxY, topBoxWidth, topBoxHeight, 3
 
        ' Σχεδίαση εικονιδίου μενού
        DrawMenuIcon topBoxX, topBoxY
 
        ' Διαχείριση κατάστασης μενού
        IF mouseB AND MouseOverMenuIcon(mouseX, mouseY, topBoxX, topBoxY) THEN
            IF menuState = MENU_CLOSED THEN
                menuState = MENU_OPEN
            ELSE
                menuState = MENU_CLOSED
            END IF
        END IF
 
        ' Σχεδίαση μενού αν είναι ανοιχτό
        IF menuState = MENU_OPEN THEN
            DrawMenu topBoxX, topBoxY
        END IF
 
        ' Σχεδίαση εικονιδίου κλεισίματος
        DrawCloseIcon topBoxX + topBoxWidth - 25, topBoxY
 
        ' Διαχείριση κλικ επάνω στο εικονίδιο κλεισίματος
        IF mouseB AND MouseOverCloseIcon(mouseX, mouseY, topBoxX + topBoxWidth - 25, topBoxY) THEN
            state = STATE_DESELECTED
            menuState = MENU_CLOSED
            SYSTEM
        END IF
 
        ' Εμφάνιση της τρέχουσας κατάστασης
        SELECT CASE state
            CASE STATE_DESELECTED: PRINT "Κατάσταση: DESELECTED"
            CASE STATE_OVER: PRINT "Κατάσταση: OVER"
            CASE STATE_SELECTED: PRINT "Κατάσταση: SELECTED"
            CASE STATE_MOVING: PRINT "Κατάσταση: MOVING"
            CASE STATE_RESIZING: PRINT "Κατάσταση: RESIZING"
            CASE STATE_ZOOMING: PRINT "Κατάσταση: ZOOMING"
        END SELECT
 
        _DISPLAY
 
        mouseOldB = mouseB
    LOOP UNTIL INKEY$ = CHR$(27) ' Έξοδος με το πλήκτρο ESC
END SUB
 
FUNCTION MouseOverBBox (mx, my, bx, by, bw, bh)
    IF mx >= bx AND mx <= bx + bw AND my >= by AND my <= by + bh THEN
        MouseOverBBox = TRUE
    ELSE
        MouseOverBBox = FALSE
    END IF
END FUNCTION
 
FUNCTION MouseResizeDirection (mx, my, bx, by, bw, bh)
    DIM direction AS INTEGER
    direction = 0
    IF mx >= bx AND mx <= bx + 5 THEN direction = direction OR 1 ' Αριστερά
    IF mx >= bx + bw - 5 AND mx <= bx + bw THEN direction = direction OR 2 ' Δεξιά
    IF my >= by AND my <= by + 5 THEN direction = direction OR 4 ' Πάνω
    IF my >= by + bh - 5 AND my <= by + bh THEN direction = direction OR 8 ' Κάτω
    MouseResizeDirection = direction
END FUNCTION
 
SUB DrawCloseIcon (x, y)
    LINE (x + 5, y + 5)-(x + 25, y + 25), _RGB32(255, 0, 0), B
    LINE (x + 10, y + 10)-(x + 20, y + 20), _RGB32(255, 255, 255)
    LINE (x + 10, y + 20)-(x + 20, y + 10), _RGB32(255, 255, 255)
END SUB
 
FUNCTION MouseOverCloseIcon (mx, my, x, y)
    IF mx >= x + 5 AND mx <= x + 25 AND my >= y + 5 AND my <= y + 25 THEN
        MouseOverCloseIcon = TRUE
    ELSE
        MouseOverCloseIcon = FALSE
    END IF
END FUNCTION
 
SUB DrawThickBox (bx, by, bw, bh, thickness)
    FOR i = 0 TO thickness - 1
        LINE (bx - i, by - i)-(bx + bw + i, by + bh - 3 + i), _RGB32(255, 0, 0), B
    NEXT
END SUB
 
SUB DrawMenuIcon (bw, bh)
    LINE (bw + 5, bh + 5)-(bw + 25, bh + 25), _RGB32(0, 255, 0), B
    LINE (bw + 10, bh + 10)-(bw + 20, bh + 10), _RGB32(255, 255, 255)
    LINE (bw + 10, bh + 15)-(bw + 20, bh + 15), _RGB32(255, 255, 255)
    LINE (bw + 10, bh + 20)-(bw + 20, bh + 20), _RGB32(255, 255, 255)
END SUB
 
FUNCTION MouseOverMenuIcon (mx, my, bw, bh)
    IF mx >= bw + 5 AND mx <= bw + 25 AND my >= bh + 5 AND my <= bh + 25 THEN
        MouseOverMenuIcon = TRUE
    ELSE
        MouseOverMenuIcon = FALSE
    END IF
END FUNCTION
 
SUB DrawMenu (bw, bh)
    LINE (bw + 5, bh + 30)-(bw + 105, bh + 130), _RGB32(0, 0, 255), B
    PRINT "Menu item 1"
    PRINT "Menu item 2"
    PRINT "Menu item 3"
END SUB