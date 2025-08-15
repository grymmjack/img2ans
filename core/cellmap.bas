' core/cellmap.bas — choose glyph + fg/bg indices for a cell (QB64-PE)
'$INCLUDE:'palette.bi'
'$INCLUDE:'cellmap.bi'

SUB MeanRGBOfRect (srcImg AS LONG, sx AS INTEGER, sy AS INTEGER, w AS INTEGER, h AS INTEGER, _
    BYREF r AS INTEGER, BYREF g AS INTEGER, BYREF b AS INTEGER)

    ' Fallback implementation using POINT (OK to start; can be upgraded to _MEMIMAGE later)
    DIM px AS LONG, py AS LONG, c AS _UNSIGNED LONG
    DIM sumR AS _INTEGER64, sumG AS _INTEGER64, sumB AS _INTEGER64, n AS _INTEGER64
    sumR = 0: sumG = 0: sumB = 0: n = 0

    DIM oldSrc AS LONG: oldSrc = _SOURCE
    _SOURCE srcImg
    FOR py = sy TO sy + h - 1
        FOR px = sx TO sx + w - 1
            c = POINT(px, py)
            sumR = sumR + _RED32(c)
            sumG = sumG + _GREEN32(c)
            sumB = sumB + _BLUE32(c)
            n = n + 1
        NEXT
    NEXT
    _SOURCE oldSrc

    IF n > 0 THEN
        r = CINT(sumR \ n)
        g = CINT(sumG \ n)
        b = CINT(sumB \ n)
    ELSE
        r = 0: g = 0: b = 0
    END IF
END SUB

SUB CellToGlyphAndColors (srcImg AS LONG, xCell AS INTEGER, yCell AS INTEGER, _
    cellW AS INTEGER, cellH AS INTEGER, useHalfBlocks AS _BYTE, _
    BYREF glyph AS INTEGER, BYREF fgIdx AS INTEGER, BYREF bgIdx AS INTEGER)

    DIM sx AS INTEGER, sy AS INTEGER
    sx = xCell * cellW
    sy = yCell * cellH

    DIM tr AS INTEGER, tg AS INTEGER, tb AS INTEGER
    DIM br AS INTEGER, bg AS INTEGER, bb AS INTEGER
    DIM halfH AS INTEGER: halfH = cellH \ 2
    IF halfH <= 0 THEN halfH = 1

    ' Mean color of top half & bottom half
    CALL MeanRGBOfRect(srcImg, sx, sy, cellW, halfH, tr, tg, tb)
    CALL MeanRGBOfRect(srcImg, sx, sy + halfH, cellW, cellH - halfH, br, bg, bb)

    DIM tIdx AS INTEGER, bIdx AS INTEGER
    tIdx = NearestIndex(tr, tg, tb, 1)
    bIdx = NearestIndex(br, bg, bb, 1)

    IF useHalfBlocks = 0 OR tIdx = bIdx THEN
        glyph = GLYPH_FULL
        fgIdx = tIdx ' either half is fine; they are equal or we choose top
        bgIdx = tIdx ' neutralize BG to same to avoid seams
    ELSE
        ' Choose between ▀ (top=FG) vs ▄ (bottom=FG) based on error
        ' Compute which orientation reduces mismatch (simple heuristic)
        glyph = GLYPH_TOP
        fgIdx = tIdx
        bgIdx = bIdx
        ' (You can extend with an error check later)
    END IF
END SUB
