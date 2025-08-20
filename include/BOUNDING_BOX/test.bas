''
' Simple Enhanced Bounding Box Test
' Demonstrates basic usage of the enhanced bounding box system
'
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'ENHANCED_BBOX.BI'

' Screen and canvas setup
DIM SHARED AS LONG main_canvas
DIM SHARED AS INTEGER screen_width, screen_height
DIM SHARED my_bbox AS __ENHANCED_BOUNDING_BOX

PRINT "Starting Enhanced Bounding Box Test..."

screen_width = 800
screen_height = 600
main_canvas = _NEWIMAGE(screen_width, screen_height, 32)

PRINT "Created canvas: "; main_canvas; " Size: "; screen_width; "x"; screen_height

SCREEN main_canvas
_TITLE "Enhanced Bounding Box - Simple Test"

PRINT "Screen set, initializing mouse..."

' Initialize mouse system
MOUSE_init

PRINT "Mouse initialized, creating background..."

' Create a simple background
CLS , _RGB32(50, 50, 80)
LINE (0, 0)-(screen_width - 1, screen_height - 1), _RGB32(100, 100, 120), B

PRINT "Background created, creating bounding box..."

' Create the bounding box
ENHANCED_BBOX_create my_bbox, main_canvas, 100, 100, 200, 150

PRINT "Bounding box created, entering main loop..."
PRINT "Press ESC to exit, or wait 10 seconds for auto-exit"

DIM loop_counter AS INTEGER
loop_counter = 0

' Main loop
DO
    _LIMIT 60
    loop_counter = loop_counter + 1
    
    ' Update mouse
    MOUSE_update
    
    ' Process bounding box mouse interactions
    DIM state_changed AS INTEGER
    state_changed = ENHANCED_BBOX_process_mouse(my_bbox, MOUSE)
    
    ' Render the bounding box
    ENHANCED_BBOX_render my_bbox
    
    ' Auto-exit after 10 seconds for testing
    IF loop_counter > 600 THEN EXIT DO
    
    ' Handle ESC key to exit
    IF INKEY$ = CHR$(27) THEN EXIT DO
    
    ' Mark mouse events as processed
    IF MOUSE.has_events THEN MOUSE_fetched_events
    
    _DISPLAY
LOOP

PRINT "Exiting main loop, cleaning up..."

' Cleanup
ENHANCED_BBOX_cleanup my_bbox

PRINT "Cleanup complete, exiting..."
SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'ENHANCED_BBOX.BM'