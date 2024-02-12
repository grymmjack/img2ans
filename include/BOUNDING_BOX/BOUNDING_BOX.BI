$IF __POINT_INC = UNDEFINED THEN
$LET __POINT_INC = 1
    TYPE __POINT
        x AS INTEGER
        y AS INTEGER
    END TYPE
$END IF

$IF __BORDER_INC = UNDEFINED THEN
$LET __BORDER_INC = 1
    TYPE __BORDER
        fg      AS _UNSIGNED LONG
        w       AS INTEGER
        pattern AS _UNSIGNED LONG
    END TYPE
$END IF

$IF __STYLE_INC = UNDEFINED THEN
$LET __STYLE_INC = 1
    TYPE __STYLE
        fg     AS _UNSIGNED LONG
        bg     AS _UNSIGNED LONG
        border AS __BORDER
    END TYPE
$END IF

TYPE __BOX_STATUS
    selected       AS INTEGER
    resizing       AS INTEGER
    resizing_left  AS INTEGER
    resizing_right AS INTEGER
    resizing_top   AS INTEGER
    resizing_bot   AS INTEGER
    moving         AS INTEGER
    moving_left    AS INTEGER
    moving_right   AS INTEGER
    moving_up      AS INTEGER
    moving_down    AS INTEGER
END TYPE

TYPE __BOUNDING_BOX
    status AS __BOX_STATUS
    style  AS __STYLE
    pos    AS __POINT
    w      AS INTEGER
    h      AS INTEGER
END TYPE

DIM SHARED BBOX AS __BOUNDING_BOX
