''
' QB64_GJ_LIB
' GRYMMJACK'S MOUSE OBJECT
'
' A mouse object to simplify and reuse mouse stuff.
'
' @author Rick Christy <grymmjack@gmail.com>
'
' @depends QB64_GJ_LIB/_GJ_LIB_COMMON.BI
' @depends QB64_GJ_LIB/_GJ_LIB_COMMON.BM
' @depends ./MOUSE.BM
'
$INCLUDEONCE

$IF __POINT_INC = UNDEFINED THEN
$LET __POINT_INC = 1
    TYPE __POINT
        x AS INTEGER
        y AS INTEGER
    END TYPE
$END IF

TYPE __MOUSE_STATE
    pos   AS __POINT
    b1    AS INTEGER
    b2    AS INTEGER
    b3    AS INTEGER
    wheel AS INTEGER
    mov   AS __POINT
END TYPE

TYPE __MOUSE_STATUS
    ' changes
    x_changed      AS INTEGER
    y_changed      AS INTEGER
    mov_x_changed  AS INTEGER
    mov_y_changed  AS INTEGER
    b1_changed     AS INTEGER
    b2_changed     AS INTEGER
    b3_changed     AS INTEGER
    wheel_changed  AS INTEGER

    ' moving
    moving         AS INTEGER
    moving_left    AS INTEGER
    moving_right   AS INTEGER
    moving_up      AS INTEGER
    moving_down    AS INTEGER
    moving_x       AS INTEGER
    moving_y       AS INTEGER

    ' buttons
    b1_down        AS INTEGER
    b2_down        AS INTEGER
    b3_down        AS INTEGER
    b1_up          AS INTEGER
    b2_up          AS INTEGER
    b3_up          AS INTEGER
    b1_clicked     AS INTEGER
    b2_clicked     AS INTEGER
    b3_clicked     AS INTEGER

    ' wheel
    wheeling_up    AS INTEGER
    wheeling_down  AS INTEGER
    wheeling_stop  AS INTEGER

    ' dragging
    started_drag   AS INTEGER
    stopped_drag   AS INTEGER
    dragging_left  AS INTEGER
    dragging_right AS INTEGER
    dragging_up    AS INTEGER
    dragging_down  AS INTEGER
    drag_distance  AS __POINT
    did_drag       AS INTEGER
    is_dragging    AS INTEGER
END TYPE

TYPE __MOUSE
    has_events AS INTEGER
    new_state  AS __MOUSE_STATE
    old_state  AS __MOUSE_STATE
    drag_start AS __POINT
    drag_stop  AS __POINT
    status     AS __MOUSE_STATUS
END TYPE

DIM SHARED MOUSE AS __MOUSE
