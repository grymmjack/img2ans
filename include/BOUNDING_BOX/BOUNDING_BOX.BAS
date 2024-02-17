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

DIM SHARED AS LONG CANVAS
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
        CASE "m"
            CONSOLE.log "macro move and update"
            CLS
            PRINT "STUFF IS HAPPENING"
            PRINT BBOX_dump(BBOX, "test 2 - macro")
            BBOX_update_canvas BBOX, CANVAS
        CASE "c"
            CONSOLE.log "clear and reset"
            CLS
            PRINT BBOX_dump(BBOX, "test")
            BBOX_update_canvas BBOX, CANVAS
        CASE "p"
            CONSOLE.log "set position"
            BBOX_set_pos BBOX, 100, 100
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
    DIM res AS INTEGER
    IF BBOX_point_over(BBOX, MOUSE.new_state.pos.x, MOUSE.new_state.pos.y) THEN
        IF MOUSE.status.b1_clicked THEN
            IF BBOX.status.selected THEN
                BBOX_deselect BBOX
            ELSE
                BBOX_select BBOX
            END IF
        ELSE
            res = BBOX_set_style(BBOX, "over")
        END IF
    ELSE
        res = BBOX_set_style(BBOX, "idle")
    END IF
    BBOX_render BBOX
    _DISPLAY
END SUB


'$INCLUDE:'../QB64_GJ_LIB/DUMP/DUMP.BM'
'$INCLUDE:'../QB64_GJ_LIB/CONSOLE/CONSOLE.BM'
'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./BOUNDING_BOX.BM'
