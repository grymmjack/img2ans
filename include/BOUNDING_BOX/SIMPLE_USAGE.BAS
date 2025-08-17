''
' SIMPLE USAGE EXAMPLE
'
' This demonstrates how to easily integrate the Enhanced Bounding Box
' into any QB64PE project with minimal code.
'
' @author Rick Christy <grymmjack@gmail.com>
'

OPTION _EXPLICIT

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

' Setup
DIM SHARED canvas AS LONG
DIM my_bbox AS __ENHANCED_BOUNDING_BOX
DIM x1 AS INTEGER, y1 AS INTEGER, x2 AS INTEGER, y2 AS INTEGER

canvas = _NEWIMAGE(800, 600, 32)
SCREEN canvas

' Initialize mouse and create bounding box
MOUSE_init
ENHANCED_BBOX_create my_bbox, canvas, 200, 150, 300, 200

' Simple main loop
DO
    CLS , _RGB32(50, 50, 80)
    
    ' Update mouse
    MOUSE_update
    
    ' Process bounding box (this handles all the state machine logic)
    DIM bbox_changed AS INTEGER
    bbox_changed = ENHANCED_BBOX_process_mouse(my_bbox, MOUSE)
    
    ' Always render the bounding box after clearing screen
    ENHANCED_BBOX_render my_bbox
    
    ' Get the selection area (useful for cropping, etc.)
    ENHANCED_BBOX_get_selection my_bbox, x1, y1, x2, y2
    
    ' Display current selection coordinates
    COLOR _RGB32(255, 255, 255)
    PRINT "Selection Area: (" + STR$(x1) + "," + STR$(y1) + ") to (" + STR$(x2) + "," + STR$(y2) + ")"
    PRINT "Current State: " + my_bbox.current_state
    PRINT "Press ESC to exit"
    
    ' Mark mouse events as processed
    IF MOUSE.has_events THEN MOUSE_fetched_events
    
    _DISPLAY
LOOP UNTIL INKEY$ = CHR$(27)

' Cleanup
ENHANCED_BBOX_cleanup my_bbox
SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
