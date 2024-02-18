CONST __MOUSEBUTTON_DOWN = -1
CONST __MOUSEBUTTON_UP   = 0
CONST __MOUSEWHEEL_UP    = -1
CONST __MOUSEWHEEL_DOWN  = 1
CONST __MOUSEWHEEL_STOP  = 0

TYPE __POINT
    x AS INTEGER
    y AS INTEGER
END TYPE

TYPE __MOUSE_STATE
    pos   AS __POINT
    b1    AS INTEGER
    b2    AS INTEGER
    b3    AS INTEGER
    wheel AS INTEGER
END TYPE

TYPE __MOUSE_STATUS
    ' changes
    x_changed       AS INTEGER
    y_changed       AS INTEGER
    b1_changed      AS INTEGER
    b2_changed      AS INTEGER
    b3_changed      AS INTEGER
    wheel_changed   AS INTEGER

    ' moving
    moving          AS INTEGER
    moving_left     AS INTEGER
    moving_right    AS INTEGER
    moving_up       AS INTEGER
    moving_down     AS INTEGER

    ' buttons
    b1_down         AS INTEGER
    b2_down         AS INTEGER
    b3_down         AS INTEGER
    b1_up           AS INTEGER
    b2_up           AS INTEGER
    b3_up           AS INTEGER
    b1_clicked      AS INTEGER
    b2_clicked      AS INTEGER
    b3_clicked      AS INTEGER

    ' wheel
    wheeling_up     AS INTEGER
    wheeling_down   AS INTEGER
    wheeling_stop   AS INTEGER

    ' dragging
    starting_drag   AS INTEGER
    stopping_drag   AS INTEGER
    dragging_left   AS INTEGER
    dragging_right  AS INTEGER
    dragging_up     AS INTEGER
    dragging_down   AS INTEGER
    drag_distance   AS __POINT
END TYPE

TYPE __MOUSE
    has_events AS INTEGER
    new_state  AS __MOUSE_STATE
    old_state  AS __MOUSE_STATE
    drag_start AS __POINT
    drag_stop  AS __POINT
    status     AS __MOUSE_STATUS
END TYPE

DIM SHARED MOUSE AS __MOUSE : MOUSE_init
SCREEN _NEWIMAGE(1920, 1080, 32)

DO
    DO WHILE _MOUSEINPUT : LOOP : MOUSE_update : MOUSE_refresh
    IF MOUSE_dragged THEN
        PRINT "DRAGGING DISTANCE: ", MOUSE.status.drag_distance.x, MOUSE.status.drag_distance.y
    END IF
    IF MOUSE.status.b1_clicked THEN
        PRINT "FINAL DRAG DISTANCE: ", MOUSE.status.drag_distance.x, MOUSE.status.drag_distance.y
    END IF
    k$ = INKEY$
    IF k$ = CHR$(27) THEN EXIT DO
    _LIMIT 30
LOOP
SYSTEM


''
' Initialize the mouse
'
SUB MOUSE_init
    MOUSE.status.stopping_drag = 0
    MOUSE.status.starting_drag = 0
END SUB


''
' Checks if the mouse has been dragged
' @return INTEGER -1 if dragged 0 if not
'
FUNCTION MOUSE_dragged%
    MOUSE_dragged = MOUSE.status.b1_down AND (MOUSE.status.drag_distance.x <> 0 OR MOUSE.status.drag_distance.y <> 0)
END FUNCTION


''
' Update the mouse states
'
SUB MOUSE_update
    ' track old state
    MOUSE.old_state.pos.x = MOUSE.new_state.pos.x
    MOUSE.old_state.pos.y = MOUSE.new_state.pos.y
    MOUSE.old_state.b1    = MOUSE.new_state.b1
    MOUSE.old_state.b2    = MOUSE.new_state.b2
    MOUSE.old_state.b3    = MOUSE.new_state.b3
    MOUSE.old_state.wheel = MOUSE.new_state.wheel

    ' track new state
    MOUSE.new_state.pos.x = _MOUSEX
    MOUSE.new_state.pos.y = _MOUSEY
    MOUSE.new_state.b1    = _MOUSEBUTTON(1)
    MOUSE.new_state.b2    = _MOUSEBUTTON(2)
    MOUSE.new_state.b3    = _MOUSEBUTTON(3)
    MOUSE.new_state.wheel = _MOUSEWHEEL
END SUB


''
' Refresh mouse status
'
SUB MOUSE_refresh
    ' set status
    ' changes
    MOUSE.status.x_changed      = MOUSE.old_state.pos.x <> MOUSE.new_state.pos.x
    MOUSE.status.y_changed      = MOUSE.old_state.pos.y <> MOUSE.new_state.pos.y
    MOUSE.status.b1_changed     = MOUSE.old_state.b1 <> MOUSE.new_state.b1
    MOUSE.status.b2_changed     = MOUSE.old_state.b2 <> MOUSE.new_state.b2
    MOUSE.status.b3_changed     = MOUSE.old_state.b3 <> MOUSE.new_state.b3
    MOUSE.status.wheel_changed  = MOUSE.old_state.wheel <> MOUSE.new_state.wheel

    ' moving
    MOUSE.status.moving         = MOUSE.status.x_changed OR MOUSE.status.y_changed
    MOUSE.status.moving_left    = MOUSE.new_state.pos.x < MOUSE.old_state.pos.x
    MOUSE.status.moving_right   = MOUSE.new_state.pos.x > MOUSE.old_state.pos.x
    MOUSE.status.moving_up      = MOUSE.new_state.pos.y < MOUSE.old_state.pos.y
    MOUSE.status.moving_down    = MOUSE.new_state.pos.y > MOUSE.old_state.pos.y

    ' buttons
    MOUSE.status.b1_down        = MOUSE.new_state.b1 = __MOUSEBUTTON_DOWN
    MOUSE.status.b2_down        = MOUSE.new_state.b2 = __MOUSEBUTTON_DOWN
    MOUSE.status.b3_down        = MOUSE.new_state.b3 = __MOUSEBUTTON_DOWN
    MOUSE.status.b1_up          = MOUSE.new_state.b1 = __MOUSEBUTTON_UP
    MOUSE.status.b2_up          = MOUSE.new_state.b2 = __MOUSEBUTTON_UP
    MOUSE.status.b3_up          = MOUSE.new_state.b3 = __MOUSEBUTTON_UP
    MOUSE.status.b1_clicked     = MOUSE.old_state.b1 = __MOUSEBUTTON_DOWN AND MOUSE.new_state.b1 = __MOUSEBUTTON_UP
    MOUSE.status.b2_clicked     = MOUSE.old_state.b2 = __MOUSEBUTTON_DOWN AND MOUSE.new_state.b2 = __MOUSEBUTTON_UP
    MOUSE.status.b3_clicked     = MOUSE.old_state.b3 = __MOUSEBUTTON_DOWN AND MOUSE.new_state.b3 = __MOUSEBUTTON_UP

    ' wheel
    MOUSE.status.wheeling_up    = MOUSE.new_state.wheel = __MOUSEWHEEL_UP
    MOUSE.status.wheeling_down  = MOUSE.new_state.wheel = __MOUSEWHEEL_DOWN
    MOUSE.status.wheeling_stop  = MOUSE.new_state.wheel = __MOUSEWHEEL_STOP

    ' dragging and dropping
    MOUSE.status.dragging_left  = MOUSE.status.b1_down AND MOUSE.status.moving_left
    MOUSE.status.dragging_right = MOUSE.status.b1_down AND MOUSE.status.moving_right
    MOUSE.status.dragging_up    = MOUSE.status.b1_down AND MOUSE.status.moving_up
    MOUSE.status.dragging_down  = MOUSE.status.b1_down AND MOUSE.status.moving_down

    IF MOUSE.status.b1_down AND NOT MOUSE.status.starting_drag THEN
        PRINT "DRAG: STARTING"
        MOUSE.status.starting_drag = -1
        MOUSE.status.stopping_drag = 0
        MOUSE.drag_start.x = MOUSE.new_state.pos.x
        MOUSE.drag_start.y = MOUSE.new_state.pos.y
    ELSEIF MOUSE.status.b1_up AND NOT MOUSE.status.stopping_drag THEN
        PRINT "DRAG: STOPPING"
        MOUSE.status.stopping_drag = -1
        MOUSE.status.starting_drag = 0
        MOUSE.drag_stop.x = MOUSE.new_state.pos.x
        MOUSE.drag_stop.y = MOUSE.new_state.pos.y
        MOUSE.status.drag_distance.x = MOUSE.drag_stop.x - MOUSE.drag_start.x
        MOUSE.status.drag_distance.y = MOUSE.drag_stop.y - MOUSE.drag_start.y
    END IF
    MOUSE.status.drag_distance.x = MOUSE.new_state.pos.x - MOUSE.drag_start.x
    MOUSE.status.drag_distance.y = MOUSE.new_state.pos.y - MOUSE.drag_start.y
END SUB
