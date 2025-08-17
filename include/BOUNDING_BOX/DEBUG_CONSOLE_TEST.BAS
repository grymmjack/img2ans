''
' ENHANCED BOUNDING BOX TEST - DEBUG VERSION WITH CONSOLE OUTPUT
' Test program for the enhanced bounding box functionality.
'

OPTION _EXPLICIT

$CONSOLE
_CONSOLE ON

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

CONST CANVAS_WIDTH = 800
CONST CANVAS_HEIGHT = 600

DIM CANVAS AS LONG
DIM INFO_PANEL AS LONG
DIM ebb AS __ENHANCED_BOUNDING_BOX
DIM keypress AS STRING

PRINT "=== ENHANCED BBOX DEBUG TEST ==="
PRINT "Creating images..."

' Create the main canvas
CANVAS = _NEWIMAGE(CANVAS_WIDTH, CANVAS_HEIGHT, 32)
INFO_PANEL = _NEWIMAGE(400, CANVAS_HEIGHT, 32)

IF CANVAS <= 0 OR INFO_PANEL <= 0 THEN
    PRINT "ERROR: Failed to create images"
    PRINT "CANVAS = "; CANVAS
    PRINT "INFO_PANEL = "; INFO_PANEL
    SYSTEM
END IF

PRINT "Images created successfully"
PRINT "CANVAS = "; CANVAS
PRINT "INFO_PANEL = "; INFO_PANEL

' Set up screen
SCREEN _NEWIMAGE(CANVAS_WIDTH + 400, CANVAS_HEIGHT, 32)

' Initialize Enhanced Bounding Box
ebb = ENHANCED_BBOX_INIT
ebb.canvas = CANVAS
ebb.pos.x = 200
ebb.pos.y = 150
ebb.w = 300
ebb.h = 200

PRINT "Setting up enhanced bbox..."
ENHANCED_BBOX_setup ebb

IF NOT ebb.status.ready THEN
    PRINT "ERROR: Enhanced bbox setup failed!"
    SYSTEM
END IF

PRINT "Enhanced bbox ready! Starting main loop..."
PRINT "Current state: "; ebb.current_state
PRINT "Colors - Deselected: "; ebb.styles.deselected.border.fg
PRINT "Colors - Over: "; ebb.styles.over.border.fg  
PRINT "Colors - Selected: "; ebb.styles.selected.border.fg

' Main loop
DO
    _LIMIT 60
    
    ' Process mouse
    MOUSE_setup
    IF ENHANCED_BBOX_process_mouse(ebb) THEN
        PRINT "State changed to: "; ebb.current_state
    END IF
    
    ' Clear canvas
    _DEST CANVAS
    CLS , _RGB32(40, 40, 60)  ' Dark blue background
    
    ' Draw grid
    drawTestGrid CANVAS
    
    ' Render bounding box
    ENHANCED_BBOX_render ebb
    
    ' Force draw a test rectangle to make sure LINE works
    LINE (50, 50)-(150, 100), _RGB32(255, 255, 0), B  ' Yellow test box
    
    _DEST 0
    _PUTIMAGE (0, 0), CANVAS
    
    ' Draw info panel
    _DEST INFO_PANEL
    CLS , _RGB32(20, 20, 30)
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Enhanced Bounding Box Test"
    _PRINTSTRING (10, 30), "State: " + STR$(ebb.current_state)
    _PRINTSTRING (10, 50), "Position: " + STR$(ebb.pos.x) + "," + STR$(ebb.pos.y)
    _PRINTSTRING (10, 70), "Size: " + STR$(ebb.w) + "x" + STR$(ebb.h)
    _PRINTSTRING (10, 90), "Mouse: " + STR$(_MOUSEX) + "," + STR$(_MOUSEY)
    
    _DEST 0
    _PUTIMAGE (CANVAS_WIDTH, 0), INFO_PANEL
    
    _DISPLAY
    
    keypress = INKEY$
    
LOOP UNTIL keypress = CHR$(27) ' ESC to exit

PRINT "Exiting... cleaning up"

' Safe cleanup
PRINT "Cleaning up enhanced bbox..."
ENHANCED_BBOX_cleanup ebb

PRINT "Freeing images..."
PRINT "CANVAS valid? "; (CANVAS > 0)
PRINT "INFO_PANEL valid? "; (INFO_PANEL > 0)

' Simple cleanup without _WIDTH check
IF CANVAS > 0 THEN 
    PRINT "Freeing CANVAS..."
    _FREEIMAGE CANVAS
    CANVAS = 0
END IF

IF INFO_PANEL > 0 THEN
    PRINT "Freeing INFO_PANEL..." 
    _FREEIMAGE INFO_PANEL
    INFO_PANEL = 0
END IF

PRINT "Cleanup complete. Exiting."
SYSTEM


''
' Draws the test background with grid and instructions
'
SUB drawTestGrid (canvas_handle AS LONG)
    DIM AS INTEGER x, y
    DIM old_dest AS LONG
    
    old_dest = _DEST
    _DEST canvas_handle
    
    ' Draw grid lines
    FOR x = 0 TO CANVAS_WIDTH STEP 50
        LINE (x, 0)-(x, CANVAS_HEIGHT), _RGB32(60, 60, 80)
    NEXT x
    
    FOR y = 0 TO CANVAS_HEIGHT STEP 50
        LINE (0, y)-(CANVAS_WIDTH, y), _RGB32(60, 60, 80)
    NEXT y
    
    ' Draw instructions
    COLOR _RGB32(200, 200, 200)
    _PRINTSTRING (10, 10), "Enhanced Bounding Box Test"
    _PRINTSTRING (10, 30), "Move mouse to interact with bounding box"
    _PRINTSTRING (10, 50), "ESC to exit"
    
    _DEST old_dest
END SUB

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
