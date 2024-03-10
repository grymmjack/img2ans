$NOPREFIX
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

'$INCLUDE:'/Users/gj/git/img2ans/include/`QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'/Users/gj/git/img2ans/include/MOUSE/MOUSE.BI'

DIM SHARED AS LONG CANVAS, MOUSEINFO, old_dest
CANVAS = _NEWIMAGE(1920, 1080, 32)
MOUSEINFO = _NEWIMAGE(500, 1080, 32)
SCREEN CANVAS

MOUSE_init
DO
    ' Mouse handling
    MOUSE_update
    MOUSE_refresh

    _LIMIT 60

    ' Keyboard handling
    DIM k AS STRING
    k$ = LCASE$(INKEY$)
    SELECT CASE k$
        CASE CHR$(27)
            EXIT DO
    END SELECT
    IF k$ <> "" OR MOUSE.has_events THEN 
        CLS
        PRINT MOUSE_dump("")
        _DISPLAY
    END IF
LOOP
SCREEN 0
_DEST 0
_FREEIMAGE CANVAS&
SYSTEM

'$INCLUDE:'/Users/gj/git/img2ans/include/MOUSE/MOUSE.BM'

''
' Log to console if DEBUGGING
' @param STRING msg message to send
'
SUB console.log(msg$)
    $IF DEBUGGING = TRUE THEN
        _ECHO msg$
    $END IF
    msg$ = ""
END SUB


''
' Log to console as info if DEBUGGING
' @param STRING msg message to send
'
SUB console.info(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;36m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB


''
' Log to console as warning if DEBUGGING
' @param STRING msg message to send
'
SUB console.warn(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;33m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB


''
' Log to console as error if DEBUGGING
' @param STRING msg message to send
'
SUB console.error(msg$)
    $IF DEBUGGING = TRUE THEN
        DIM AS STRING e
        e$ = CHR$(27)
        _ECHO e$ + "[1;31m" + msg$ + e$ + "[0m"
    $END IF
    msg$ = ""
END SUB


