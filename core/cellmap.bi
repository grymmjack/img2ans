$INCLUDEONCE
' core/cellmap.bi — choose glyph + fg/bg indices for a cell (QB64-PE)

CONST GLYPH_FULL = 219 ' █ full block
CONST GLYPH_TOP  = 223 ' ▀ top half (FG top, BG bottom)
CONST GLYPH_BOT  = 220 ' ▄ bottom half (BG top, FG bottom)

DECLARE SUB CellToGlyphAndColors (srcImg AS LONG, xCell AS INTEGER, yCell AS INTEGER, _
    cellW AS INTEGER, cellH AS INTEGER, useHalfBlocks AS _BYTE, _
    BYREF glyph AS INTEGER, BYREF fgIdx AS INTEGER, BYREF bgIdx AS INTEGER)

DECLARE SUB MeanRGBOfRect (srcImg AS LONG, sx AS INTEGER, sy AS INTEGER, w AS INTEGER, h AS INTEGER, _
    BYREF r AS INTEGER, BYREF g AS INTEGER, BYREF b AS INTEGER)
