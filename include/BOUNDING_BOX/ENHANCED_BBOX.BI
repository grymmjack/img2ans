''
' QB64_GJ_LIB
' ENHANCED BOUNDING BOX OBJECT
'
' A comprehensive bounding box with full state machine implementation
' following the provided state diagram. Supports selection, deselection,
' moving, resizing from all edges/corners, and zooming.
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

' Enhanced state machine types
TYPE __ENHANCED_STYLE_STATES
    deselected AS __STYLE
    over       AS __STYLE
    selected   AS __STYLE
    zooming    AS __STYLE
    resizing   AS __STYLE
    moving     AS __STYLE
END TYPE

' Enhanced status tracking all possible states
TYPE __ENHANCED_BOX_STATUS
    ' Core states from diagram
    deselected     AS INTEGER
    over           AS INTEGER
    selected       AS INTEGER
    zooming        AS INTEGER
    resizing       AS INTEGER
    moving         AS INTEGER
    
    ' System states
    ready          AS INTEGER
    visible        AS INTEGER
    
    ' Resize edge tracking
    resizing_left      AS INTEGER
    resizing_right     AS INTEGER
    resizing_top       AS INTEGER
    resizing_bottom    AS INTEGER
    resizing_top_left  AS INTEGER
    resizing_top_right AS INTEGER
    resizing_bot_left  AS INTEGER
    resizing_bot_right AS INTEGER
    
    ' Move direction tracking
    moving_up      AS INTEGER
    moving_down    AS INTEGER
    moving_left    AS INTEGER
    moving_right   AS INTEGER
    
    ' Zoom tracking
    zoom_in        AS INTEGER
    zoom_out       AS INTEGER
    zoom_level     AS SINGLE
    
    ' Edge detection helpers
    cursor_on_edge AS STRING * 20
    edge_tolerance AS INTEGER
END TYPE

' Enhanced bounding box structure
TYPE __ENHANCED_BOUNDING_BOX
    status         AS __ENHANCED_BOX_STATUS
    styles         AS __ENHANCED_STYLE_STATES
    current_state  AS STRING * 12
    pos            AS __POINT
    w              AS INTEGER
    h              AS INTEGER
    min_w          AS INTEGER
    min_h          AS INTEGER
    max_w          AS INTEGER
    max_h          AS INTEGER
    canvas         AS LONG
    canvas_w       AS INTEGER
    canvas_h       AS INTEGER
    clean_canvas   AS LONG
    
    ' Drag operation tracking
    drag_start_pos AS __POINT
    drag_start_size AS __POINT
    drag_offset    AS __POINT
END TYPE

' State constants for cleaner code
CONST ESTATE_DESELECTED = "deselected"
CONST ESTATE_OVER = "over" 
CONST ESTATE_SELECTED = "selected"
CONST ESTATE_ZOOMING = "zooming"
CONST ESTATE_RESIZING = "resizing"
CONST ESTATE_MOVING = "moving"

' Default initialization structure
DIM SHARED ENHANCED_BBOX_INIT AS __ENHANCED_BOUNDING_BOX

' Initialize default values
ENHANCED_BBOX_INIT.status.ready = _FALSE
ENHANCED_BBOX_INIT.status.visible = _TRUE
ENHANCED_BBOX_INIT.status.deselected = _TRUE
ENHANCED_BBOX_INIT.status.edge_tolerance = 8
ENHANCED_BBOX_INIT.status.zoom_level = 1.0
ENHANCED_BBOX_INIT.current_state = ESTATE_DESELECTED

' Default colors and styles
ENHANCED_BBOX_INIT.styles.deselected.border.fg = _RGB32(200, 200, 200)
ENHANCED_BBOX_INIT.styles.over.border.fg = _RGB32(0, 255, 255)
ENHANCED_BBOX_INIT.styles.selected.border.fg = _RGB32(255, 0, 0)
ENHANCED_BBOX_INIT.styles.zooming.border.fg = _RGB32(255, 255, 0)
ENHANCED_BBOX_INIT.styles.resizing.border.fg = _RGB32(0, 128, 255)
ENHANCED_BBOX_INIT.styles.moving.border.fg = _RGB32(0, 255, 0)

' Border widths
ENHANCED_BBOX_INIT.styles.deselected.border.w = 2
ENHANCED_BBOX_INIT.styles.over.border.w = 3
ENHANCED_BBOX_INIT.styles.selected.border.w = 2
ENHANCED_BBOX_INIT.styles.zooming.border.w = 4
ENHANCED_BBOX_INIT.styles.resizing.border.w = 3
ENHANCED_BBOX_INIT.styles.moving.border.w = 2

' Border patterns
ENHANCED_BBOX_INIT.styles.deselected.border.pattern = &B1010101010101010
ENHANCED_BBOX_INIT.styles.over.border.pattern = &B1111111111111111
ENHANCED_BBOX_INIT.styles.selected.border.pattern = &B1111000011110000
ENHANCED_BBOX_INIT.styles.zooming.border.pattern = &B1100110011001100
ENHANCED_BBOX_INIT.styles.resizing.border.pattern = &B1111100011111000
ENHANCED_BBOX_INIT.styles.moving.border.pattern = &B1010010110100101

' Default size constraints
ENHANCED_BBOX_INIT.min_w = 20
ENHANCED_BBOX_INIT.min_h = 20
ENHANCED_BBOX_INIT.max_w = 2048
ENHANCED_BBOX_INIT.max_h = 2048

' Position and size defaults
ENHANCED_BBOX_INIT.pos.x = 100
ENHANCED_BBOX_INIT.pos.y = 100
ENHANCED_BBOX_INIT.w = 200
ENHANCED_BBOX_INIT.h = 150

$IF GJ_LIB_NL = UNDEFINED THEN
    $LET GJ_LIB_NL = 1
    DIM SHARED GJ_LIB_NL AS STRING
    $IF WIN THEN
        GJ_LIB_NL$ = CHR$(13)
    $ELSE
        GJ_LIB_NL$ = CHR$(10)
    $END IF
$END IF
