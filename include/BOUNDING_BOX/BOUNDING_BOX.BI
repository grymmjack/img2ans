''
' QB64_GJ_LIB
' GRYMMJACK'S BOUNDING BOX OBJECT
'
' A bounding box simply is a box with some styles, and it can be resized.
'
' @author Rick Christy <grymmjack@gmail.com>
'
$INCLUDEONCE

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
        pattern AS LONG
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
    idle       AS __STYLE
    over       AS __STYLE
    selected   AS __STYLE
    deselected AS __STYLE
    resizing   AS __STYLE
    moving     AS __STYLE
END TYPE

TYPE __BOX_STATUS
    ready          AS INTEGER
    visible        AS INTEGER
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
    status       AS __BOX_STATUS
    styles       AS __STYLE_STATES
    style        AS STRING
    pos          AS __POINT
    w            AS INTEGER
    h            AS INTEGER
    canvas       AS LONG
    clean_canvas AS LONG
END TYPE

DIM SHARED BBOX AS __BOUNDING_BOX
DIM SHARED BBOX_INIT AS __BOUNDING_BOX
BBOX_INIT.status.ready                   = FALSE
BBOX_INIT.status.visible                 = TRUE
BBOX_INIT.status.selected                = FALSE
BBOX_INIT.status.resizing                = FALSE
BBOX_INIT.status.resizing_left           = FALSE
BBOX_INIT.status.resizing_right          = FALSE
BBOX_INIT.status.resizing_top            = FALSE
BBOX_INIT.status.resizing_bot            = FALSE
BBOX_INIT.status.moving                  = FALSE
BBOX_INIT.status.moving_left             = FALSE
BBOX_INIT.status.moving_right            = FALSE
BBOX_INIT.status.moving_up               = FALSE
BBOX_INIT.status.moving_down             = FALSE
'colors
BBOX_INIT.styles.idle.fg                 = _RGB32(255, 255, 0)
BBOX_INIT.styles.over.fg                 = _RGB32(0, 255, 255)
BBOX_INIT.styles.selected.fg             = _RGB32(255, 0, 0)
BBOX_INIT.styles.resizing.fg             = _RGB32(255, 255, 0)
BBOX_INIT.styles.moving.fg               = _RGB32(255, 255, 0)
BBOX_INIT.styles.idle.border.fg          = _RGB32(255, 255, 0)
BBOX_INIT.styles.over.border.fg          = _RGB32(0, 255, 255)
BBOX_INIT.styles.selected.border.fg      = _RGB32(255, 0, 0)
BBOX_INIT.styles.deselected.border.fg    = _RGB32(255, 255, 0)
BBOX_INIT.styles.resizing.border.fg      = _RGB32(255, 255, 0)
BBOX_INIT.styles.moving.border.fg        = _RGB32(255, 255, 0)
'widths
BBOX_INIT.styles.idle.border.w           = 3
BBOX_INIT.styles.over.border.w           = 3
BBOX_INIT.styles.selected.border.w       = 3
BBOX_INIT.styles.deselected.border.w     = 3
BBOX_INIT.styles.resizing.border.w       = 3
BBOX_INIT.styles.moving.border.w         = 3
'patterns
BBOX_INIT.styles.idle.border.pattern       = &B0000111100001111
BBOX_INIT.styles.over.border.pattern       = &B0000111100001111
BBOX_INIT.styles.selected.border.pattern   = &B1100110011001100
BBOX_INIT.styles.deselected.border.pattern = &B0000111100001111
BBOX_INIT.styles.resizing.border.pattern   = &B1111000011110000
BBOX_INIT.styles.moving.border.pattern     = &B0101010101010101
'style
BBOX_INIT.style$ = "idle"
'position
BBOX_INIT.pos.x = 0
BBOX_INIT.pos.y = 0
'dimensions
BBOX_INIT.w = 128
BBOX_INIT.h = 128
'canvas
BBOX_INIT.canvas = 0
BBOX_INIT.clean_canvas = 0

'initialize the BBOX
BBOX.status = BBOX_INIT.status
BBOX.styles = BBOX_INIT.styles
BBOX.style$ = BBOX_INIT.style$
BBOX.pos = BBOX_INIT.pos
BBOX.w = BBOX_INIT.w
BBOX.h = BBOX_INIT.h
BBOX.canvas = BBOX_INIT.canvas
BBOX.clean_canvas = BBOX_INIT.clean_canvas

$IF GJ_LIB_NL = UNDEFINED THEN
    $LET GJ_LIB_NL = 1
    DIM SHARED GJ_LIB_NL AS STRING
    $IF WIN THEN
        GJ_LIB_NL$ = CHR$(13)
    $ELSE
        GJ_LIB_NL$ = CHR$(10)
    $END IF
$END IF