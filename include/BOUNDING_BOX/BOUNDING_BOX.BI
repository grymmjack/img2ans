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

TYPE __STYLE_STATES
    idle     AS __STYLE
    over     AS __STYLE
    selected AS __STYLE
    resizing AS __STYLE
    moving   AS __STYLE
END TYPE

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
    style  AS __STYLE_STATES
    pos    AS __POINT
    w      AS INTEGER
    h      AS INTEGER
END TYPE

DIM SHARED BBOX AS __BOUNDING_BOX
DIM SHARED BBOX_INIT AS __BOUNDING_BOX
BBOX_INIT.status.selected               = 0
BBOX_INIT.status.resizing               = 0
BBOX_INIT.status.resizing_left          = 0
BBOX_INIT.status.resizing_right         = 0
BBOX_INIT.status.resizing_top           = 0
BBOX_INIT.status.resizing_bot           = 0
BBOX_INIT.status.moving                 = 0
BBOX_INIT.status.moving_left            = 0
BBOX_INIT.status.moving_right           = 0
BBOX_INIT.status.moving_up              = 0
BBOX_INIT.status.moving_down            = 0
'colors
BBOX_INIT.style.idle.fg                 = _RGB32(255, 255, 0)
BBOX_INIT.style.over.fg                 = _RGB32(255, 255, 255)
BBOX_INIT.style.selected.fg             = _RGB32(255, 0, 0)
BBOX_INIT.style.resizing.fg             = _RGB32(255, 255, 0)
BBOX_INIT.style.moving.fg               = _RGB32(255, 255, 0)
BBOX_INIT.style.idle.border.fg          = _RGB32(255, 255, 0)
BBOX_INIT.style.over.border.fg          = _RGB32(255, 255, 255)
BBOX_INIT.style.selected.border.fg      = _RGB32(255, 0, 0)
BBOX_INIT.style.resizing.border.fg      = _RGB32(255, 255, 0)
BBOX_INIT.style.moving.border.fg        = _RGB32(255, 255, 0)
'widths
BBOX_INIT.style.idle.border.w           = 3
BBOX_INIT.style.over.border.w           = 3
BBOX_INIT.style.selected.border.w       = 3
BBOX_INIT.style.resizing.border.w       = 3
BBOX_INIT.style.moving.border.w         = 3
'patterns
BBOX_INIT.style.idle.border.pattern     = &B0000111100001111
BBOX_INIT.style.over.border.pattern     = &B0000111100001111
BBOX_INIT.style.selected.border.pattern = &B0000111100001111
BBOX_INIT.style.resizing.border.pattern = &B0000111100001111
BBOX_INIT.style.moving.border.pattern   = &B0000111100001111
'position
BBOX_INIT.pos.x = 0
BBOX_INIT.pos.y = 0
'dimensions
BBOX_INIT.w = 128
BBOX_INIT.h = 128

'initialize the BBOX
BBOX.status = BBOX_INIT.status
BBOX.style = BBOX_INIT.style
BBOX.pos = BBOX_INIT.pos
BBOX.w = BBOX_INIT.w
BBOX.h = BBOX_INIT.h