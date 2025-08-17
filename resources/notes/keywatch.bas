' === QB64PE Keyboard Watcher: Arrows + Shift/Ctrl Down/Up ===
' ESC to quit

OPTION _EXPLICIT

' --- Key code setup ---
CONST KD_LSHIFT& = 100304
CONST KD_RSHIFT& = 100303
CONST KD_LCTRL&  = 100306
CONST KD_RCTRL&  = 100305

DIM KD_LEFT&, KD_RIGHT&, KD_UP&, KD_DOWN&
KD_LEFT&  = CVI(CHR$(0) + "K") ' Left arrow
KD_RIGHT& = CVI(CHR$(0) + "M") ' Right arrow
KD_UP&    = CVI(CHR$(0) + "H") ' Up arrow
KD_DOWN&  = CVI(CHR$(0) + "P") ' Down arrow

' --- State latches (0/1) ---
DIM sShiftNow%, sShiftPrev%
DIM sCtrlNow%,  sCtrlPrev%
DIM sLeftNow%,  sLeftPrev%
DIM sRightNow%, sRightPrev%
DIM sUpNow%,    sUpPrev%
DIM sDownNow%,  sDownPrev%

' --- Event buffer (ring) ---
CONST EV_MAX = 12
DIM SHARED ev$(1 TO EV_MAX)
DIM SHARED evHead AS INTEGER: evHead = 1

SCREEN 0
COLOR 15, 0
CLS
PRINT "Keyboard Watcher (QB64PE) - press ESC to quit"
PRINT "Hold arrows / Shift / Ctrl to see states update. Releases are logged."
PRINT STRING$(78, "-")

_LIMIT 120

DO
    ' --- Poll current states ---
    sShiftNow% = ( _KEYDOWN(KD_LSHIFT&) OR _KEYDOWN(KD_RSHIFT&) ) <> 0
    sCtrlNow%  = ( _KEYDOWN(KD_LCTRL&)  OR _KEYDOWN(KD_RCTRL&)  ) <> 0

    sLeftNow%  = ( _KEYDOWN(KD_LEFT&)  ) <> 0
    sRightNow% = ( _KEYDOWN(KD_RIGHT&) ) <> 0
    sUpNow%    = ( _KEYDOWN(KD_UP&)    ) <> 0
    sDownNow%  = ( _KEYDOWN(KD_DOWN&)  ) <> 0

    ' --- Detect transitions and log events ---
    IF sShiftNow% <> sShiftPrev% THEN
        IF sShiftNow% THEN AddLog "SHIFT DOWN" ELSE AddLog "SHIFT UP"
    END IF

    IF sCtrlNow% <> sCtrlPrev% THEN
        IF sCtrlNow% THEN AddLog "CTRL  DOWN" ELSE AddLog "CTRL  UP"
    END IF

    IF sLeftNow% <> sLeftPrev% THEN
        IF sLeftNow% THEN AddLog "LEFT  DOWN" ELSE AddLog "LEFT  UP"
    END IF
    IF sRightNow% <> sRightPrev% THEN
        IF sRightNow% THEN AddLog "RIGHT DOWN" ELSE AddLog "RIGHT UP"
    END IF
    IF sUpNow% <> sUpPrev% THEN
        IF sUpNow% THEN AddLog "UP    DOWN" ELSE AddLog "UP    UP"
    END IF
    IF sDownNow% <> sDownPrev% THEN
        IF sDownNow% THEN AddLog "DOWN  DOWN" ELSE AddLog "DOWN  UP"
    END IF

    ' --- Draw status panel ---
    COLOR 14: LOCATE 5, 2:  PRINT "Current States:"
    COLOR 10: LOCATE 6, 4:  PRINT "Shift:"; StateTxt$(sShiftNow%)
    COLOR 10: LOCATE 7, 4:  PRINT "Ctrl :"; StateTxt$(sCtrlNow%)
    COLOR 11: LOCATE 9, 4:  PRINT "Left :"; StateTxt$(sLeftNow%)
    COLOR 11: LOCATE 10, 4: PRINT "Right:"; StateTxt$(sRightNow%)
    COLOR 11: LOCATE 11, 4: PRINT "Up   :"; StateTxt$(sUpNow%)
    COLOR 11: LOCATE 12, 4: PRINT "Down :"; StateTxt$(sDownNow%)

    ' --- Draw event log ---
    COLOR 14: LOCATE 5, 30: PRINT "Events (latest first):"
    COLOR 7
    DIM i AS INTEGER, idx AS INTEGER, row AS INTEGER
    row = 6
    FOR i = 0 TO EV_MAX - 1
        idx = ((evHead - 2 - i + EV_MAX) MOD EV_MAX) + 1
        LOCATE row + i, 30: PRINT SPACE$(45);
        LOCATE row + i, 30: PRINT ev$(idx)
    NEXT

    ' --- Save prev states for next loop ---
    sShiftPrev% = sShiftNow%
    sCtrlPrev%  = sCtrlNow%
    sLeftPrev%  = sLeftNow%
    sRightPrev% = sRightNow%
    sUpPrev%    = sUpNow%
    sDownPrev%  = sDownNow%

    ' --- Exit ---
    IF INKEY$ = CHR$(27) THEN EXIT DO

LOOP

END

' --- Helpers ---
SUB AddLog (msg$)
    DIM t$
    t$ = Secs2$(TIMER) + "  " + msg$
    ev$(evHead) = t$
    evHead = evHead + 1: IF evHead > EV_MAX THEN evHead = 1
END SUB

FUNCTION StateTxt$ (b AS INTEGER)
    IF b THEN StateTxt$ = " DOWN " ELSE StateTxt$ = "  UP  "
END FUNCTION

FUNCTION Secs2$ (t AS DOUBLE)
    ' Format seconds as ###.## without USING$
    DIM whole AS LONG, hund AS LONG
    whole = INT(t)
    hund = INT((t - whole) * 100 + 0.5)
    IF hund = 100 THEN hund = 0: whole = whole + 1
    Secs2$ = LTRIM$(STR$(whole)) + "." + RIGHT$("0" + LTRIM$(STR$(hund)), 2)
END FUNCTION
