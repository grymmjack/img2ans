''
' IMG2ANS - IMG2ANS_BI (Include)
' 
' @depends IMG2ANS.BAS
' @depends include/MOUSE/MOUSE.BI
' @depends include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI
' @depends include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI
' @depends include/QB64_GJ_LIB/MISC/MISC.BI
'
$INCLUDEONCE
$RESIZE:OFF

'$DYNAMIC
OPTION _EXPLICIT
OPTION _EXPLICITARRAY

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

'KEY CONSTANTS
CONST KEY_ESCAPE&           = 27
CONST KEY_SPACE&            = 32
CONST KEY_ENTER&            = 13
CONST KEY_TAB&              = 9
CONST KEY_UP&               = 18432
CONST KEY_DOWN&             = 20480
CONST KEY_LEFT&             = 19200
CONST KEY_RIGHT&            = 19712
CONST KEY_PAUSE&            = 100019
CONST KEY_NUMLOCK&          = 100300
CONST KEY_CAPSLOCK&         = 100301
CONST KEY_SCROLLOCK&        = 100302
CONST KEY_RSHIFT&           = 100303
CONST KEY_LSHIFT&           = 100304
CONST KEY_RCTRL&            = 100305
CONST KEY_LCTRL&            = 100306
CONST KEY_RALT&             = 100307
CONST KEY_LALT&             = 100308
CONST KEY_RMETA&            = 100309 'Left 'Apple' key (macOS)
CONST KEY_LMETA&            = 100310 'Right 'Apple' key (macOS)
CONST KEY_LSUPER&           = 100311 'Left "Windows" key
CONST KEY_RSUPER&           = 100312 'Right "Windows"key
CONST KEY_MODE&             = 100313 '"AltGr" key
CONST KEY_COMPOSE&          = 100314
CONST KEY_HELP&             = 100315
CONST KEY_PRINT&            = 100316
CONST KEY_SYSREQ&           = 100317
CONST KEY_BREAK&            = 100318
CONST KEY_MENU&             = 100319
CONST KEY_POWER&            = 100320
CONST KEY_EURO&             = 100321
CONST KEY_UNDO&             = 100322
CONST KEY_KP0&              = 100256
CONST KEY_KP1&              = 100257
CONST KEY_KP2&              = 100258
CONST KEY_KP3&              = 100259
CONST KEY_KP4&              = 100260
CONST KEY_KP5&              = 100261
CONST KEY_KP6&              = 100262
CONST KEY_KP7&              = 100263
CONST KEY_KP8&              = 100264
CONST KEY_KP9&              = 100265
CONST KEY_KP_PERIOD&        = 100266
CONST KEY_KP_DIVIDE&        = 100267
CONST KEY_KP_MULTIPLY&      = 100268
CONST KEY_KP_MINUS&         = 100269
CONST KEY_KP_PLUS&          = 100270
CONST KEY_KP_ENTER&         = 100271
CONST KEY_KP_INSERT&        = 200000
CONST KEY_KP_END&           = 200001
CONST KEY_KP_DOWN&          = 200002
CONST KEY_KP_PAGE_DOWN&     = 200003
CONST KEY_KP_LEFT&          = 200004
CONST KEY_KP_MIDDLE&        = 200005
CONST KEY_KP_RIGHT&         = 200006
CONST KEY_KP_HOME&          = 200007
CONST KEY_KP_UP&            = 200008
CONST KEY_KP_PAGE_UP&       = 200009
CONST KEY_KP_DELETE&        = 200010
CONST KEY_SCROLL_LOCK_MODE& = 200011
CONST KEY_INSERT_MODE&      = 200012

'$INCLUDE:'include/MOUSE/MOUSE.BI'
'$INCLUDE:'include/BOUNDING_BOX/BOUNDING_BOX.BI'
'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'include/QB64_GJ_LIB/SYS/SYS.BI'
'$INCLUDE:'include/QB64_GJ_LIB/CONSOLE/CONSOLE.BI'
'$INCLUDE:'include/QB64_GJ_LIB/MISC/MISC.BI'
