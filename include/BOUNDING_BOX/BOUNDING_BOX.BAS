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
BBOX_create BBOX, CANVAS, 50, 25, 50, 100
DIM AS STRING k
MOUSE_init
DO
    ' Mouse handling
    MOUSE_update
    MOUSE_refresh

    _LIMIT 60

    ' Keyboard handling
    k$ = LCASE$(INKEY$)
    SELECT CASE k$
        CASE CHR$(27)
            EXIT DO
        CASE "h"
            CONSOLE.log "hide"
            BBOX_hide BBOX
        CASE "s"
            CONSOLE.log "show"
            BBOX_show BBOX
    END SELECT
    IF k$ <> "" OR MOUSE.has_events THEN 
        draw_output
    END IF
LOOP
SCREEN 0
_DEST 0
_FREEIMAGE CANVAS&
SYSTEM


''
' Draw the output :D
'
SUB draw_output
    DIM AS INTEGER over
    over% = BBOX_point_over(BBOX, MOUSE.new_state.pos.x, MOUSE.new_state.pos.y)
    IF over% THEN
        BBOX_set_style_state BBOX, "over"
        IF MOUSE.status.b1_clicked THEN
            BBOX_toggle_selected BBOX
        END IF
    ELSE
        BBOX_set_style_state BBOX, "idle"
    END IF
    BBOX_render BBOX
END SUB


'$INCLUDE:'../QB64_GJ_LIB/DUMP/DUMP.BM'
'$INCLUDE:'../QB64_GJ_LIB/CONSOLE/CONSOLE.BM'
'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./BOUNDING_BOX.BM'
