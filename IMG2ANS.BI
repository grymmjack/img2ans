''
' IMG2ANS - IMG2ANS_BI (Include)
' 
' @depends IMG2ANS.BAS
' @depends include/MOUSE/MOUSE.BI
'
$IF IMG2ANS_BI = UNDEFINED THEN
    $LET IMG2ANS_BI = TRUE
$END IF



'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY
$IF DEBUGGING = UNDEFINED THEN
    $LET DEBUGGING = TRUE
$END IF
$IF DEBUGGING = TRUE THEN
    $DEBUG
    $CONSOLE
    $ASSERTS:CONSOLE
    _CONSOLE ON
$END IF
$IF FALSE = UNDEFINED AND TRUE = UNDEFINED THEN
    $LET TRUE = TRUE
    CONST FALSE = 0 : CONST TRUE = NOT FALSE
$END IF
$IF WIN THEN
    CONST SLASH$ = "\"
$ELSE
    CONST SLASH$ = "/"
$END IF 

TYPE IMAGE
    ID        AS LONG
    handle    AS LONG
    file_name AS STRING
    file_path AS STRING
    file_ext  AS STRING
    src_w     AS INTEGER
    src_h     AS INTEGER
    src_x     AS INTEGER
    src_y     AS INTEGER
    dst_w     AS INTEGER
    dst_h     AS INTEGER
    dst_x     AS INTEGER
    dst_y     AS INTEGER
    x_offset  AS INTEGER
    y_offset  AS INTEGER
    has_mouse AS _BYTE
    has_focus AS _BYTE
    zoom      AS SINGLE
END TYPE

DIM SHARED AS IMAGE _
    SourceIMG, _
    DestPalIMG, _
    ResizeCropIMG, _
    PreviewIMG, _
    FinalIMG

'$INCLUDE:'./include/MOUSE/MOUSE.BI'
'$INCLUDE:'./include/QB64_GJ_LIB/STRINGS/STRINGS.BI'