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

BBOX_create BBOX, CANVAS, 500, 500, 500, 500
PRINT BBOX_dump(BBOX, "test")
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
            BBOX_update_canvas BBOX, CANVAS 'call this when canvas changes
        CASE "c"
            CONSOLE.log "clear and reset"
            CLS
            PRINT BBOX_dump(BBOX, "test")
            BBOX_update_canvas BBOX, CANVAS 'call this when canvas changes
        CASE "p"
            CONSOLE.log "set position"
            BBOX_set_pos BBOX, 100, 100
    END SELECT
    IF k$ <> "" OR MOUSE.has_events THEN 
        CONSOLE.log MOUSE_dump("")
        CLS
        PRINT BBOX_dump(BBOX, "test")
        BBOX_update_canvas BBOX, CANVAS 'call this when canvas changes
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
    DIM edge AS STRING
    ' mouse is over box
    IF BBOX_point_over(BBOX, MOUSE.new_state.pos.x, MOUSE.new_state.pos.y) THEN
        'select and deselect
        IF MOUSE.status.b1_clicked THEN
            IF BBOX.status.selected THEN 'deselect if clicking when selected
                BBOX_deselect BBOX
            ELSE
                BBOX_select BBOX 'select if clicking on box while deselected
            END IF
        END IF
        'mouse stopped dragging, re-select as state
        IF MOUSE.status.did_drag AND MOUSE.status.stopped_drag THEN 
            CONSOLE.error "Stopped dragging"
            BBOX_select BBOX
        END IF

        'box selected and resizing
        IF BBOX.status.selected THEN 'box selected
            IF MOUSE.status.is_dragging THEN 'mouse started dragging
                CONSOLE.error "Dragging"
                IF BBOX.status.resizing THEN 'box resizing
                    IF BBOX.status.resizing_right THEN 'resizing right
                        IF MOUSE.status.moving_right THEN
                            BBOX_resize_right BBOX, _
                                1 * (MOUSE.status.drag_distance.x \ 2 + 1)
                        ELSEIF MOUSE.status.moving_left THEN
                            BBOX_resize_right BBOX, _
                                -1 * (MOUSE.status.drag_distance.x \ 2 - 1)
                        END IF
                    END IF
                    IF BBOX.status.resizing_left THEN
                        BBOX_resize_left BBOX, MOUSE.new_state.mov.x
                    END IF
                    IF BBOX.status.resizing_top THEN
                        BBOX_resize_top BBOX, MOUSE.new_state.mov.y
                    END IF
                    IF BBOX.status.resizing_bot THEN
                        BBOX_resize_bot BBOX, MOUSE.new_state.mov.y
                    END IF
                    IF MOUSE.status.b1_up THEN
                        BBOX_select BBOX
                    END IF
                END IF
            END IF

            'update mouse cursor
            edge$ = BBOX_point_on_edge( _
                BBOX, MOUSE.new_state.pos.x, MOUSE.new_state.pos.y _
            )
            IF edge$ <> "" THEN 'mouse over an edge
                SELECT CASE edge$
                    CASE "top left"
                        _MOUSESHOW "TOPLEFT_BOTTOMRIGHT"
                    CASE "bot right"
                        _MOUSESHOW "TOPLEFT_BOTTOMRIGHT"
                    CASE "top right"
                        _MOUSESHOW "TOPRIGHT_BOTTOMLEFT"
                    CASE "bot left"
                        _MOUSESHOW "TOPRIGHT_BOTTOMLEFT"
                    CASE "left"
                        _MOUSESHOW "HORIZONTAL"
                    CASE "right"
                        _MOUSESHOW "HORIZONTAL"
                        IF MOUSE.status.b1_down THEN
                            BBOX_resize_right BBOX, MOUSE.new_state.mov.x
                        END IF
                    CASE "top"
                        _MOUSESHOW "VERTICAL"
                    CASE "bot"
                        _MOUSESHOW "VERTICAL"
                END SELECT
            ELSE 'not over any edge default cursor
                _MOUSESHOW "DEFAULT"
            END IF
        ELSE 'box is deselected
            res = BBOX_set_style(BBOX, "over") 'mouse is over and deselected
            _MOUSESHOW "DEFAULT"
            BBOX_render BBOX
        END IF
    ELSE 'mouse not over box
        IF MOUSE.status.b1_clicked THEN 'deselect if clicking away from box
            IF BBOX.status.selected THEN
                BBOX_deselect BBOX
            END IF
        END IF
        res = BBOX_set_style(BBOX, "idle") 'mouse not over update to idle
        _MOUSESHOW "DEFAULT"
        BBOX_render BBOX
    END IF
    _DISPLAY
END SUB


'$INCLUDE:'../QB64_GJ_LIB/DUMP/DUMP.BM'
'$INCLUDE:'../QB64_GJ_LIB/CONSOLE/CONSOLE.BM'
'$INCLUDE:'../MOUSE/MOUSE.BM'
'$INCLUDE:'./BOUNDING_BOX.BM'
