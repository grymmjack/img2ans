''
' DEBUG BOUNDING BOX TEST
'
' Simple test to debug the rendering issue
'

OPTION _EXPLICIT

$CONSOLE
_CONSOLE ON

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

DIM SHARED canvas AS LONG
DIM my_bbox AS __ENHANCED_BOUNDING_BOX
DIM oldDest AS INTEGER
DIM k AS STRING

' Console setup
oldDest = _DEST
_DEST _CONSOLE
PRINT "=== DEBUG BOUNDING BOX TEST ==="
PRINT "Creating canvas..."
_DEST oldDest

' Setup
canvas = _NEWIMAGE(800, 600, 32)
SCREEN canvas

oldDest = _DEST
_DEST _CONSOLE
PRINT "Canvas created: 800x600"
PRINT "Initializing mouse..."
_DEST oldDest

MOUSE_init

oldDest = _DEST
_DEST _CONSOLE
PRINT "Mouse initialized"
PRINT "Creating bounding box at (200,150) size 300x200..."
_DEST oldDest

ENHANCED_BBOX_create my_bbox, canvas, 200, 150, 300, 200

oldDest = _DEST
_DEST _CONSOLE
PRINT "Bounding box created!"
PRINT "Initial state: "; my_bbox.current_state
PRINT "Visible: "; my_bbox.status.visible
PRINT "Ready: "; my_bbox.status.ready
PRINT "Position: "; my_bbox.pos.x; ","; my_bbox.pos.y
PRINT "Size: "; my_bbox.w; "x"; my_bbox.h
PRINT "Deselected border color: "; my_bbox.styles.deselected.border.fg
PRINT "Border width: "; my_bbox.styles.deselected.border.w
PRINT ""
PRINT "Drawing initial state..."
_DEST oldDest

' Clear screen and draw box
CLS , _RGB32(50, 50, 80)

' Draw a test rectangle to make sure LINE works
LINE (100, 100)-(150, 150), _RGB32(255, 255, 255), B

' Manually render the bounding box
ENHANCED_BBOX_render my_bbox

oldDest = _DEST
_DEST _CONSOLE
PRINT "Initial render complete"
PRINT "Press any key to continue, ESC to exit..."
_DEST oldDest

_DISPLAY

' Wait for keypress
DO
    k$ = INKEY$
    IF k$ <> "" THEN EXIT DO
    _LIMIT 30
LOOP

oldDest = _DEST
_DEST _CONSOLE
PRINT "Key pressed: "; ASC(k$); " ("; k$; ")"
_DEST oldDest

IF k$ = CHR$(27) THEN
    oldDest = _DEST
    _DEST _CONSOLE
    PRINT "ESC pressed - cleaning up..."
    _DEST oldDest
    
    ENHANCED_BBOX_cleanup my_bbox
    SYSTEM
END IF

' Now test mouse interaction
oldDest = _DEST
_DEST _CONSOLE
PRINT "Starting mouse interaction test..."
PRINT "Move mouse and click. ESC to exit."
_DEST oldDest

DO
    ' Update mouse
    MOUSE_update
    
    ' Clear and redraw
    CLS , _RGB32(50, 50, 80)
    LINE (100, 100)-(150, 150), _RGB32(255, 255, 255), B
    
    ' Process and render box
    DIM changed AS INTEGER
    changed = ENHANCED_BBOX_process_mouse(my_bbox, MOUSE)
    ENHANCED_BBOX_render my_bbox
    
    ' Show info
    COLOR _RGB32(255, 255, 255)
    PRINT "State: " + my_bbox.current_state
    PRINT "Mouse: " + STR$(MOUSE.new_state.pos.x) + "," + STR$(MOUSE.new_state.pos.y)
    
    IF changed THEN
        oldDest = _DEST
        _DEST _CONSOLE
        PRINT "State changed to: "; my_bbox.current_state
        _DEST oldDest
    END IF
    
    ' Handle keyboard
    k$ = INKEY$
    IF k$ = CHR$(27) THEN EXIT DO
    
    ' Mark mouse events processed
    IF MOUSE.has_events THEN MOUSE_fetched_events
    
    _DISPLAY
    _LIMIT 60
LOOP

oldDest = _DEST
_DEST _CONSOLE
PRINT "Exiting..."
_DEST oldDest

ENHANCED_BBOX_cleanup my_bbox
SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
