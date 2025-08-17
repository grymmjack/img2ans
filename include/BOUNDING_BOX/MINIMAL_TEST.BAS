''
' MINIMAL TEST - Enhanced Bounding Box with Console Output
'

OPTION _EXPLICIT

$CONSOLE
_CONSOLE ON

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

' Setup
DIM SHARED canvas AS LONG
DIM my_bbox AS __ENHANCED_BOUNDING_BOX
DIM x1 AS INTEGER, y1 AS INTEGER, x2 AS INTEGER, y2 AS INTEGER
DIM oldDest AS INTEGER

canvas = _NEWIMAGE(800, 600, 32)
SCREEN canvas

' Console output
oldDest = _DEST
_DEST _CONSOLE
PRINT "Enhanced Bounding Box Test Starting..."
PRINT "Canvas created: 800x600"
_DEST oldDest

' Initialize mouse and create bounding box
MOUSE_init

oldDest = _DEST
_DEST _CONSOLE
PRINT "Mouse initialized"
_DEST oldDest

ENHANCED_BBOX_create my_bbox, canvas, 200, 150, 300, 200

oldDest = _DEST
_DEST _CONSOLE
PRINT "Bounding box created at (200,150) size 300x200"
PRINT "Current state: "; my_bbox.current_state
PRINT "Press ESC to exit, any other key to get selection coordinates"
_DEST oldDest

' Simple test loop
DIM k AS STRING
DIM bbox_changed AS INTEGER
DIM loop_count AS INTEGER

loop_count = 0

DO
    loop_count = loop_count + 1
    
    CLS , _RGB32(50, 50, 80)
    
    ' Update mouse
    MOUSE_update
    
    ' Process bounding box
    bbox_changed = ENHANCED_BBOX_process_mouse(my_bbox, MOUSE)
    
    ' Always render the box after clearing screen
    ENHANCED_BBOX_render my_bbox
    
    ' Get current selection
    ENHANCED_BBOX_get_selection my_bbox, x1, y1, x2, y2
    
    ' Display info on screen
    COLOR _RGB32(255, 255, 255)
    PRINT "Enhanced Bounding Box Test"
    PRINT "Loop: " + STR$(loop_count)
    PRINT "State: " + my_bbox.current_state
    PRINT "Selection: (" + STR$(x1) + "," + STR$(y1) + ") to (" + STR$(x2) + "," + STR$(y2) + ")"
    PRINT "Press ESC to exit"
    
    ' Handle keyboard
    k$ = INKEY$
    IF k$ <> "" AND k$ <> CHR$(27) THEN
        oldDest = _DEST
        _DEST _CONSOLE
        PRINT "Selection coordinates: ("; x1; ","; y1; ") to ("; x2; ","; y2; ")"
        PRINT "Box state: "; my_bbox.current_state
        PRINT "Box position: "; my_bbox.pos.x; ","; my_bbox.pos.y
        PRINT "Box size: "; my_bbox.w; "x"; my_bbox.h
        _DEST oldDest
    END IF
    
    ' Mark mouse events as processed
    IF MOUSE.has_events THEN MOUSE_fetched_events
    
    _DISPLAY
    _LIMIT 60
    
LOOP UNTIL k$ = CHR$(27)

oldDest = _DEST
_DEST _CONSOLE
PRINT "Test completed. Final state: "; my_bbox.current_state
_DEST oldDest

' Cleanup
ENHANCED_BBOX_cleanup my_bbox
SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
