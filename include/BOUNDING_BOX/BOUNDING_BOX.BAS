''
' QB64_GJ_LIB
' GRYMMJACK'S BOUNDING BOX OBJECT
'
' A bounding box simply is a box with some styles, and it can be resized.
'
' @author Rick Christy <grymmjack@gmail.com>
'
' @depends QB64_GJ_LIB/_GJ_LIB_COMMON.BI
' @depends QB64_GJ_LIB/CONSOLE/CONSOLE.BI
' @depends QB64_GJ_LIB/CONSOLE/CONSOLE.BM
' @depends ../MOUSE/MOUSE.BI
' @depends ../MOUSE/MOUSE.BM
' @depends ./BOUNDING_BOX.BI
' @depends ./BOUNDING_BOX.BM
'

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY
'$INCLUDE:'../QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../QB64_GJ_LIB/DUMP/DUMP.BI'
'$INCLUDE:'../QB64_GJ_LIB/CONSOLE/CONSOLE.BI'
'$INCLUDE:'../MOUSE/MOUSE.BI'
'$INCLUDE:'./BOUNDING_BOX.BI'

DIM AS LONG CANVAS
CANVAS = _NEWIMAGE(1920, 1080, 32)
SCREEN CANVAS
PRINT BBOX_dump(BBOX, "test")
' PRINT BBOX_dump_style(BBOX, "", "idle")
' PRINT BBOX_dump_style(BBOX, "", "over")
' PRINT BBOX_dump_style(BBOX, "", "selected")
' PRINT BBOX_dump_style(BBOX, "", "resizing")
' PRINT BBOX_dump_style(BBOX, "", "moving")

BBOX_draw BBOX, CANVAS, 50, 25, 50, 100
SLEEP
BBOX_set_style_state BBOX, "selected"
SLEEP
BBOX_set_style_state BBOX, "over"
SLEEP
BBOX_set_style_state BBOX, "resizing"
SLEEP
BBOX_set_style_state BBOX, "moving"

'$INCLUDE:'../QB64_GJ_LIB/DUMP/DUMP.BM'
'$INCLUDE:'../QB64_GJ_LIB/CONSOLE/CONSOLE.BM'
'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./BOUNDING_BOX.BM'
