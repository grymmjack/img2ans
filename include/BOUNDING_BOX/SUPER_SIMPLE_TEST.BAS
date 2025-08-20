''
' SUPER SIMPLE BOUNDING BOX TEST - Just draw a visible box
'

OPTION _EXPLICIT

'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'  
'$INCLUDE:'./ENHANCED_BBOX.BI'

DIM canvas AS LONG
DIM my_bbox AS __ENHANCED_BOUNDING_BOX

' Create canvas
canvas = _NEWIMAGE(800, 600, 32)
SCREEN canvas

' Set dark background
CLS , _RGB32(20, 20, 30)

' Draw a test white rectangle to make sure LINE works
LINE (50, 50)-(100, 100), _RGB32(255, 255, 255), B
LINE (150, 50)-(200, 100), _RGB32(255, 0, 0), B

' Draw text
COLOR _RGB32(255, 255, 255)
_PRINTSTRING (10, 10), "Test - You should see 2 white/red rectangles above"
_PRINTSTRING (10, 30), "and a light gray bounding box at 300,200"

' Manually set up bounding box with bright colors
my_bbox = ENHANCED_BBOX_INIT
my_bbox.pos.x = 300
my_bbox.pos.y = 200  
my_bbox.w = 200
my_bbox.h = 150
my_bbox.canvas = canvas
my_bbox.status.visible = TRUE
my_bbox.status.ready = TRUE
my_bbox.current_state = ESTATE_DESELECTED

' Force bright color
my_bbox.styles.deselected.border.fg = _RGB32(255, 255, 255)  ' Pure white
my_bbox.styles.deselected.border.w = 3
my_bbox.styles.deselected.border.pattern = &B1111111111111111  ' Solid

' Manually draw the box
DIM AS INTEGER x1, y1, x2, y2, i
x1 = my_bbox.pos.x
y1 = my_bbox.pos.y
x2 = x1 + my_bbox.w
y2 = y1 + my_bbox.h

' Draw with thick white border
FOR i = 0 TO 2
    LINE (x1 + i, y1 + i)-(x2 - i, y2 - i), _RGB32(255, 255, 255), B
NEXT i

_PRINTSTRING (10, 50), "Manual box drawn at " + STR$(x1) + "," + STR$(y1) + " size " + STR$(my_bbox.w) + "x" + STR$(my_bbox.h)

_DISPLAY

' Wait for keypress
DO
    _LIMIT 30
LOOP UNTIL INKEY$ <> ""

SYSTEM

'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./ENHANCED_BBOX.BM'
