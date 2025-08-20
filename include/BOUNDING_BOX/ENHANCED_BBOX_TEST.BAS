''
' ENHANCED BOUNDING BOX TEST
'
' Comprehensive test program demonstrating the enhanced bounding box
' functionality with full state machine implementation.
'
' Features demonstrated:
' - Selection/Deselection
' - Mouse over effects
' - Drag to move
' - Resize from all edges and corners
' - Mouse wheel zoom
' - Proper state transitions per diagram
' - Visual feedback
'
' @author Rick Christy <grymmjack@gmail.com>
'

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

' Screen setup
DIM SHARED AS LONG CANVAS, INFO_PANEL
DIM SHARED AS INTEGER CANVAS_WIDTH, CANVAS_HEIGHT
DIM SHARED AS STRING keypress

CANVAS_WIDTH = 1200
CANVAS_HEIGHT = 800
CANVAS = _NEWIMAGE(CANVAS_WIDTH, CANVAS_HEIGHT, 32)
INFO_PANEL = _NEWIMAGE(400, CANVAS_HEIGHT, 32)

SCREEN CANVAS
_TITLE "Enhanced Bounding Box Test - State Machine Implementation"

' Initialize objects
DIM SHARED ebb AS __ENHANCED_BOUNDING_BOX
MOUSE_init

' Draw test background FIRST - before creating bounding box
CALL draw_test_background

' Create test bounding box - this captures the background with grid
ENHANCED_BBOX_create ebb, CANVAS, 300, 200, 400, 300

' Main loop
DO
    _LIMIT 60
    
    ' Handle mouse input
    MOUSE_update
    
    ' Process bounding box mouse interactions  
    IF ENHANCED_BBOX_process_mouse(ebb, MOUSE) THEN
        ' Box state changed, update display
        CALL draw_test_background
        _DISPLAY
    END IF
    
    ' Handle keyboard input
    keypress$ = LCASE$(INKEY$)
    IF keypress$ <> "" THEN CALL handle_keyboard
    
    ' Update info panel
    CALL update_info_panel
    
    ' Mark mouse events as processed
    IF MOUSE.has_events THEN MOUSE_fetched_events
    
    _DISPLAY
LOOP UNTIL keypress$ = CHR$(27) ' ESC to exit

' Cleanup - simple and safe
ENHANCED_BBOX_cleanup ebb
SYSTEM


''
' Draws the test background with grid and instructions
'
SUB draw_test_background
    DIM AS LONG old_dest, i
    old_dest = _DEST
    _DEST CANVAS
    
    ' Clear with dark background
    CLS , _RGB32(20, 20, 30)
    
    ' Draw grid
    FOR i = 0 TO CANVAS_WIDTH STEP 50
        LINE (i, 0)-(i, CANVAS_HEIGHT), _RGB32(40, 40, 50)
    NEXT i
    
    FOR i = 0 TO CANVAS_HEIGHT STEP 50
        LINE (0, i)-(CANVAS_WIDTH, i), _RGB32(40, 40, 50)
    NEXT i
    
    ' Draw title
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Enhanced Bounding Box - State Machine Test"
    _PRINTSTRING (10, 30), "Mouse: Hover/Click/Drag to interact | Wheel: Zoom | Keys: R=Reset, C=Center, ESC=Exit"
    
    ' Render bounding box directly
    ENHANCED_BBOX_render ebb
    
    _DEST old_dest
END SUB


''
' Handles keyboard input for additional controls
'
SUB handle_keyboard
    SELECT CASE keypress$
        CASE "r"
            ' Reset bounding box
            PRINT "Resetting bounding box"
            ENHANCED_BBOX_set_position ebb, 300, 200
            ENHANCED_BBOX_set_size ebb, 400, 300
            DIM result AS INTEGER
            result = ENHANCED_BBOX_set_state(ebb, ESTATE_DESELECTED)
            CALL draw_test_background
            
        CASE "c"
            ' Center bounding box
            PRINT "Centering bounding box"
            ENHANCED_BBOX_set_position ebb, (CANVAS_WIDTH - ebb.w) \ 2, (CANVAS_HEIGHT - ebb.h) \ 2
            CALL draw_test_background
            
        CASE "h"
            ' Toggle visibility
            IF ebb.status.visible THEN
                ENHANCED_BBOX_hide ebb
                PRINT "Hiding bounding box"
            ELSE
                ENHANCED_BBOX_show ebb
                PRINT "Showing bounding box"
            END IF
            
        CASE "1"
            ' Test state transition to DESELECTED
            DIM result1 AS INTEGER
            result1 = ENHANCED_BBOX_set_state(ebb, ESTATE_DESELECTED)
            ENHANCED_BBOX_render ebb
            
        CASE "2"
            ' Test state transition to OVER (if valid)
            DIM result2 AS INTEGER
            result2 = ENHANCED_BBOX_set_state(ebb, ESTATE_OVER)
            IF result2 THEN ENHANCED_BBOX_render ebb
            
        CASE "3"
            ' Test state transition to SELECTED (if valid)
            DIM result3 AS INTEGER
            result3 = ENHANCED_BBOX_set_state(ebb, ESTATE_SELECTED)
            IF result3 THEN ENHANCED_BBOX_render ebb
    END SELECT
END SUB


''
' Updates the information panel with current state
'
SUB update_info_panel
    DIM AS LONG old_dest, x1, y1, x2, y2
    old_dest = _DEST
    _DEST INFO_PANEL
    
    ' Clear info panel
    CLS , _RGB32(30, 30, 40)
    
    ' Display current state information
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "ENHANCED BOUNDING BOX"
    _PRINTSTRING (10, 30), "===================="
    
    COLOR _RGB32(255, 255, 0)
    _PRINTSTRING (10, 60), "Current State: " + ebb.current_state
    
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 90), "Position: " + STR$(ebb.pos.x) + ", " + STR$(ebb.pos.y)
    _PRINTSTRING (10, 110), "Size: " + STR$(ebb.w) + " x " + STR$(ebb.h)
    _PRINTSTRING (10, 130), "Zoom Level: " + STR$(ebb.status.zoom_level)
    
    ' Show selection coordinates
    ENHANCED_BBOX_get_selection ebb, x1, y1, x2, y2
    _PRINTSTRING (10, 160), "Selection Area:"
    _PRINTSTRING (10, 180), "  Top-Left: " + STR$(x1) + ", " + STR$(y1)
    _PRINTSTRING (10, 200), "  Bottom-Right: " + STR$(x2) + ", " + STR$(y2)
    
    ' Mouse information
    COLOR _RGB32(0, 255, 255)
    _PRINTSTRING (10, 230), "Mouse: " + STR$(MOUSE.new_state.pos.x) + ", " + STR$(MOUSE.new_state.pos.y)
    
    ' State flags
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 260), "State Flags:"
    IF ebb.status.deselected THEN _PRINTSTRING (15, 280), "DESELECTED"
    IF ebb.status.over THEN _PRINTSTRING (15, 300), "OVER"
    IF ebb.status.selected THEN _PRINTSTRING (15, 320), "SELECTED"
    IF ebb.status.zooming THEN _PRINTSTRING (15, 340), "ZOOMING"
    IF ebb.status.resizing THEN _PRINTSTRING (15, 360), "RESIZING"
    IF ebb.status.moving THEN _PRINTSTRING (15, 380), "MOVING"
    
    ' Resize flags if resizing
    IF ebb.status.resizing THEN
        COLOR _RGB32(0, 255, 0)
        _PRINTSTRING (10, 410), "Resize Flags:"
        IF ebb.status.resizing_left THEN _PRINTSTRING (15, 430), "LEFT"
        IF ebb.status.resizing_right THEN _PRINTSTRING (15, 450), "RIGHT"
        IF ebb.status.resizing_top THEN _PRINTSTRING (15, 470), "TOP"
        IF ebb.status.resizing_bottom THEN _PRINTSTRING (15, 490), "BOTTOM"
    END IF
    
    ' Instructions
    COLOR _RGB32(200, 200, 200)
    _PRINTSTRING (10, 530), "Controls:"
    _PRINTSTRING (10, 550), "Hover - Show OVER state"
    _PRINTSTRING (10, 570), "Click - SELECT/DESELECT"
    _PRINTSTRING (10, 590), "Drag edges - RESIZE"
    _PRINTSTRING (10, 610), "Drag inside - MOVE"
    _PRINTSTRING (10, 630), "Wheel - ZOOM"
    _PRINTSTRING (10, 650), "R - Reset, C - Center"
    _PRINTSTRING (10, 670), "H - Hide/Show"
    _PRINTSTRING (10, 690), "1/2/3 - Force states"
    _PRINTSTRING (10, 710), "ESC - Exit"
    
    ' Composite the info panel onto main canvas
    _DEST CANVAS
    _PUTIMAGE (CANVAS_WIDTH - 400, 0), INFO_PANEL, CANVAS
    
    _DEST old_dest
END SUB


'$INCLUDE:'../MOUSE/MOUSE.BM'  
'$INCLUDE:'./ENHANCED_BBOX.BM'
