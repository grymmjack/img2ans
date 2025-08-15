' core/image_ops.bas — brightness / contrast / posterize (QB64‑PE)
'$INCLUDE:'image_ops.bi'

' NOTE: This first pass uses POINT/PSET for clarity.
' Later, replace with _MEMIMAGE for 10–50× speed.

SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)
    IF brightness <> 0 THEN ApplyBrightness img, brightness
    IF contrastPct <> 0 THEN ApplyContrast img, contrastPct
    IF posterizeLevels > 1 THEN ApplyPosterize img, posterizeLevels
END SUB

SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + offset
            g = _GREEN32(c) + offset
            b = _BLUE32(c) + offset
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyContrast (img AS LONG, pct AS INTEGER)
    ' pct in -100..+100 ; clamp
    IF pct < -100 THEN pct = -100
    IF pct >  100 THEN pct =  100
    DIM f AS DOUBLE
    ' Standard contrast curve factor
    f = (259.0 * (pct + 255.0)) / (255.0 * (259.0 - pct))

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(f * (_RED32(c) - 128) + 128)
            g = CINT(f * (_GREEN32(c) - 128) + 128)
            b = CINT(f * (_BLUE32(c) - 128) + 128)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyPosterize (img AS LONG, levels AS INTEGER)
    ' Snap each channel to nearest step
    IF levels < 2 THEN EXIT SUB
    DIM stepv AS INTEGER
    stepv = 255 \ (levels - 1)
    IF stepv < 1 THEN stepv = 1

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER, q AS INTEGER
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            r = ((r + stepv \ 2) \ stepv) * stepv
            g = ((g + stepv \ 2) \ stepv) * stepv
            b = ((b + stepv \ 2) \ stepv) * stepv
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB
