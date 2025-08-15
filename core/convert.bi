$INCLUDEONCE
' core/convert.bi — orchestrates image→cells→ANSI (QB64-PE)

DECLARE FUNCTION ConvertImageToAnsi$ (srcImg AS LONG, cols AS INTEGER, rows AS INTEGER, _
    cellW AS INTEGER, cellH AS INTEGER, useHalfBlocks AS _BYTE, useICE AS _BYTE)
