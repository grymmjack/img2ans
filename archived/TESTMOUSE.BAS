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



'$INCLUDE:'../include/QB64_GJ_LIB/_GJ_LIB_COMMON.BI'
'$INCLUDE:'../include/MOUSE/MOUSE.BI'

SCREEN 0

MOUSE_init
DO
    ' Mouse handling
    MOUSE_update

    ' _LIMIT 60
    IF MOUSE.new_state.mov.x <> 0 THEN
        LOCATE 1, 1 : PRINT SPACE$(50)
        LOCATE 1, 1 : PRINT "MMX:", MOUSE.new_state.mov.x
    END IF
    IF MOUSE.new_state.mov.y <> 0 THEN
        LOCATE 2, 1 : PRINT SPACE$(50)
        LOCATE 2, 1 : PRINT "MMY:", MOUSE.new_state.mov.y
    END IF
    IF MOUSE.new_state.wheel <> 0 THEN
        LOCATE 3, 1 : PRINT SPACE$(50)
        LOCATE 3, 1 : PRINT "MW:", MOUSE.new_state.wheel
    END IF
  
    ' Keyboard handling
    DIM k AS STRING
    k$ = LCASE$(INKEY$)
    IF k$ = CHR$(27) THEN EXIT DO
LOOP
SYSTEM

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


'$INCLUDE:'../include/MOUSE/MOUSE.BM'
