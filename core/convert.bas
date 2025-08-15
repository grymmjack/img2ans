' core/convert.bas — orchestrates image→cells→ANSI (QB64-PE)
'$INCLUDE:'palette.bi'
'$INCLUDE:'cellmap.bi'
'$INCLUDE:'ansi_writer.bi'
'$INCLUDE:'convert.bi'

FUNCTION ConvertImageToAnsi$ (srcImg AS LONG, cols AS INTEGER, rows AS INTEGER, _
    cellW AS INTEGER, cellH AS INTEGER, useHalfBlocks AS _BYTE, useICE AS _BYTE)

    DIM buf$, y AS INTEGER, x AS INTEGER
    DIM glyph AS INTEGER, fgIdx AS INTEGER, bgIdx AS INTEGER
    DIM st AS AnsiState
    CALL AnsiInit(st, useICE)

    ' Safety guard
    IF PalCount <= 0 THEN
        ConvertImageToAnsi$ = "" ' no palette loaded
        EXIT FUNCTION
    END IF

    FOR y = 0 TO rows - 1
        DIM line$ : line$ = ""
        st.curFG = -1: st.curBG = -1 ' reset at each line to ensure clean attrs
        FOR x = 0 TO cols - 1
            CALL CellToGlyphAndColors(srcImg, x, y, cellW, cellH, useHalfBlocks, glyph, fgIdx, bgIdx)
            CALL EmitCell(st, glyph, fgIdx, bgIdx, line$)
        NEXT
        CALL EmitReset(line$)
        buf$ = buf$ + line$ + CHR$(13) + CHR$(10)
    NEXT

    ConvertImageToAnsi$ = buf$
END FUNCTION
