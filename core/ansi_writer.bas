' core/ansi_writer.bas — build ANSI strings efficiently (QB64-PE)
'$INCLUDE:'ansi_writer.bi'
'$INCLUDE:'palette.bi'

SUB AnsiInit (BYREF st AS AnsiState, useICE AS _BYTE)
    st.curFG = -1: st.curBG = -1: st.useICE = useICE
END SUB

FUNCTION SgrFG$ (idx AS INTEGER)
    ' 0..7 normal, 8..15 bright
    DIM base AS STRING, n AS INTEGER
    n = idx MOD 16
    IF n < 8 THEN
        SgrFG$ = CHR$(27) + "[0;" + LTRIM$(STR$(30 + n)) + "m"
    ELSE
        SgrFG$ = CHR$(27) + "[1;" + LTRIM$(STR$(30 + (n - 8))) + "m"
    END IF
END FUNCTION

FUNCTION SgrBG$ (idx AS INTEGER, useICE AS _BYTE)
    DIM n AS INTEGER: n = idx MOD 16
    IF n < 8 THEN
        SgrBG$ = CHR$(27) + "[0;" + LTRIM$(STR$(40 + n)) + "m"
    ELSE
        IF useICE THEN
            ' iCE bright backgrounds (100..107 with bold? we force 1; to keep bright foreground state add separate FG)
            SgrBG$ = CHR$(27) + "[0;" + LTRIM$(STR$(100 + (n - 8))) + "m"
        ELSE
            ' Fallback: map bright bg to its dim counterpart to stay ANSI-safe
            SgrBG$ = CHR$(27) + "[0;" + LTRIM$(STR$(40 + (n - 8))) + "m"
        END IF
    END IF
END FUNCTION

SUB EmitCell (BYREF st AS AnsiState, glyph AS INTEGER, fgIdx AS INTEGER, bgIdx AS INTEGER, BYREF buf$)
    IF bgIdx <> st.curBG THEN
        buf$ = buf$ + SgrBG$(bgIdx, st.useICE)
        st.curBG = bgIdx
    END IF
    IF fgIdx <> st.curFG THEN
        buf$ = buf$ + SgrFG$(fgIdx)
        st.curFG = fgIdx
    END IF
    buf$ = buf$ + CHR$(glyph)
END SUB

SUB EmitReset (BYREF buf$)
    buf$ = buf$ + CHR$(27) + "[0m"
END SUB
