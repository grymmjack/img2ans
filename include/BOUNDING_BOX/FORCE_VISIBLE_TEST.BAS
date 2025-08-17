''
' FORCE VISIBLE BOUNDING BOX TEST
' Simple test to ensure bounding box is definitely visible
'

OPTION _EXPLICIT

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./ENHANCED_BBOX.BI'

CONST CANVAS_WIDTH = 800
CONST CANVAS_HEIGHT = 600

DIM CANVAS AS LONG
DIM ebb AS __ENHANCED_BOUNDING_BOX
DIM keypress AS STRING

' Create the main canvas
CANVAS = _NEWIMAGE(CANVAS_WIDTH, CANVAS_HEIGHT, 32)
SCREEN CANVAS

' Set dark background so bright colors show up
CLS , _RGB32(20, 20, 40)

' Initialize Enhanced Bounding Box
ebb = ENHANCED_BBOX_INIT
ebb.canvas = CANVAS
ebb.pos.x = 200
ebb.pos.y = 150
ebb.w = 300
ebb.h = 200

' Force it to be visible and in deselected state
ebb.status.visible = TRUE
ebb.status.ready = TRUE  
ebb.current_state = ESTATE_DESELECTED

' Override colors to be EXTREMELY bright
ebb.styles.deselected.border.fg = _RGB32(255, 255, 255)  ' Pure white
ebb.styles.deselected.border.w = 5  ' Very thick
ebb.styles.deselected.border.pattern = &B1111111111111111  ' Solid

' Draw test markers first
LINE (50, 50)-(100, 100), _RGB32(255, 0, 0), B  ' Red test box
LINE (650, 450)-(700, 500), _RGB32(0, 255, 0), B  ' Green test box

' Draw instructions
COLOR _RGB32(255, 255, 255)
_PRINTSTRING (10, 10), "FORCE VISIBLE TEST - You should see:"
_PRINTSTRING (10, 30), "- Red box at top-left"
_PRINTSTRING (10, 50), "- Green box at bottom-right"  
_PRINTSTRING (10, 70), "- WHITE bounding box at 200,150 size 300x200"
_PRINTSTRING (10, 90), "- ESC to exit"

' Manually draw the bounding box using the same method as the render function
DIM AS INTEGER x1, y1, x2, y2, i
x1 = ebb.pos.x
y1 = ebb.pos.y
x2 = x1 + ebb.w
y2 = y1 + ebb.h

' Draw multiple thick lines to make it super visible
FOR i = 0 TO 4
    LINE (x1 - i, y1 - i)-(x2 + i, y2 + i), _RGB32(255, 255, 255), B
NEXT i

' Also call the actual render function
ENHANCED_BBOX_render ebb

_DISPLAY

' Main loop
DO
    _LIMIT 30
    
    keypress = INKEY$
    
LOOP UNTIL keypress = CHR$(27) ' ESC to exit

' Safe cleanup
_DEST 0
ENHANCED_BBOX_cleanup ebb
IF CANVAS <> 0 THEN _FREEIMAGE CANVAS
SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
