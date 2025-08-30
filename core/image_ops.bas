' core/image_ops.bas — brightness / contrast / posterize / blur / glow (QB64‑PE)
'$INCLUDE:'image_ops.bi'

' NOTE: Blur uses adaptive sampling, Glow uses _MEMIMAGE for maximum performance

SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)
    IF brightness <> 0 THEN ApplyBrightness img, brightness
    IF contrastPct <> 0 THEN ApplyContrast img, contrastPct
    IF posterizeLevels > 1 THEN ApplyPosterize img, posterizeLevels
END SUB

SUB AdjustImageInPlaceWithBlur (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER)
    IF brightness <> 0 THEN ApplyBrightness img, brightness
    IF contrastPct <> 0 THEN ApplyContrast img, contrastPct
    IF posterizeLevels > 1 THEN ApplyPosterize img, posterizeLevels
    IF blurRadius > 0 THEN ApplyBlur img, blurRadius
END SUB

SUB AdjustImageInPlaceWithGlow (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)
    IF brightness <> 0 THEN ApplyBrightness img, brightness
    IF contrastPct <> 0 THEN ApplyContrast img, contrastPct
    IF posterizeLevels > 1 THEN ApplyPosterize img, posterizeLevels
    IF glowRadius > 0 AND glowIntensity > 0 THEN ApplyGlow img, glowRadius, glowIntensity
END SUB

SUB AdjustImageInPlaceFull (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)
    IF brightness <> 0 THEN ApplyBrightness img, brightness
    IF contrastPct <> 0 THEN ApplyContrast img, contrastPct
    IF posterizeLevels > 1 THEN ApplyPosterize img, posterizeLevels
    IF blurRadius > 0 THEN ApplyBlur img, blurRadius
    IF glowRadius > 0 AND glowIntensity > 0 THEN ApplyGlow img, glowRadius, glowIntensity
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

' Optimized Blur Effect - Uses adaptive sampling for better performance
' Radius 1-15: Uses progressively coarser sampling for larger radii
SUB ApplyBlur (img AS LONG, radius AS INTEGER)
    DIM tempImg AS LONG
    DIM bx AS LONG, by AS LONG, bdx AS INTEGER, bdy AS INTEGER
    DIM btotalR AS LONG, btotalG AS LONG, btotalB AS LONG, bcount AS INTEGER
    DIM br AS INTEGER, bg AS INTEGER, bb AS INTEGER
    DIM bc AS _UNSIGNED LONG
    DIM boldSource AS LONG, boldDest AS LONG
    DIM bw AS LONG, bh AS LONG
    DIM bstep AS INTEGER
    
    IF radius <= 0 THEN EXIT SUB
    IF radius > 15 THEN radius = 15  ' Clamp maximum radius
    
    boldSource = _SOURCE
    boldDest = _DEST
    
    bw = _WIDTH(img)
    bh = _HEIGHT(img)
    
    ' Use optimized sampling - skip pixels for larger radii
    bstep = 1
    IF radius > 5 THEN bstep = 2
    IF radius > 10 THEN bstep = 3
    
    tempImg = _COPYIMAGE(img, 32)
    _SOURCE tempImg
    _DEST img
    
    FOR by = 0 TO bh - 1
        FOR bx = 0 TO bw - 1
            btotalR = 0: btotalG = 0: btotalB = 0: bcount = 0
            
            ' Sample surrounding pixels with optimized step
            FOR bdy = -radius TO radius STEP bstep
                FOR bdx = -radius TO radius STEP bstep
                    IF bx + bdx >= 0 AND bx + bdx < bw AND by + bdy >= 0 AND by + bdy < bh THEN
                        bc = POINT(bx + bdx, by + bdy)
                        br = _RED32(bc): bg = _GREEN32(bc): bb = _BLUE32(bc)
                        btotalR = btotalR + br
                        btotalG = btotalG + bg
                        btotalB = btotalB + bb
                        bcount = bcount + 1
                    END IF
                NEXT bdx
            NEXT bdy
            
            IF bcount > 0 THEN
                br = btotalR \ bcount
                bg = btotalG \ bcount
                bb = btotalB \ bcount
                PSET (bx, by), _RGB32(br, bg, bb)
            END IF
        NEXT bx
    NEXT by
    
    _FREEIMAGE tempImg
    _SOURCE boldSource
    _DEST boldDest
END SUB

' HIGHLY OPTIMIZED Glow Effect - Uses _MEMIMAGE for maximum performance
' Creates soft glow around bright areas using separable blur and memory operations
SUB ApplyGlow (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)
    DIM tempImg AS LONG, glowImg AS LONG
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM brightness AS SINGLE, glowAmount AS SINGLE
    DIM gr AS INTEGER, gg AS INTEGER, gb AS INTEGER
    DIM finalR AS INTEGER, finalG AS INTEGER, finalB AS INTEGER
    DIM oldSource AS LONG, oldDest AS LONG
    DIM w AS INTEGER, h AS INTEGER
    
    IF glowRadius <= 0 OR intensity <= 0 THEN EXIT SUB
    IF glowRadius > 10 THEN glowRadius = 10  ' Clamp maximum radius
    IF intensity > 100 THEN intensity = 100  ' Clamp maximum intensity
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    
    tempImg = _COPYIMAGE(img, 32)
    glowImg = _NEWIMAGE(w, h, 32)
    
    ' OPTIMIZED: Use _MEMIMAGE for direct pixel access instead of POINT/PSET
    DIM sourceBlock AS _MEM, glowBlock AS _MEM, destBlock AS _MEM
    sourceBlock = _MEMIMAGE(tempImg)
    glowBlock = _MEMIMAGE(glowImg)
    destBlock = _MEMIMAGE(img)
    
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM offset AS _OFFSET
    
    ' First pass: Create glow map from bright areas (MUCH FASTER with _MEMIMAGE)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            offset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory
            b = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset, _UNSIGNED _BYTE)
            g = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 2, _UNSIGNED _BYTE)
            
            ' Calculate brightness
            brightness = (r + g + b) / (3 * 255.0)
            
            ' Only bright areas contribute to glow
            IF brightness > 0.7 THEN
                glowAmount = (brightness - 0.7) / 0.3
                gr = CINT(r * glowAmount)
                gg = CINT(g * glowAmount)
                gb = CINT(b * glowAmount)
            ELSE
                gr = 0: gg = 0: gb = 0
            END IF
            
            ' Write directly to glow image memory
            _MEMPUT glowBlock, glowBlock.OFFSET + offset, gb AS _UNSIGNED _BYTE
            _MEMPUT glowBlock, glowBlock.OFFSET + offset + 1, gg AS _UNSIGNED _BYTE
            _MEMPUT glowBlock, glowBlock.OFFSET + offset + 2, gr AS _UNSIGNED _BYTE
            _MEMPUT glowBlock, glowBlock.OFFSET + offset + 3, 255 AS _UNSIGNED _BYTE ' Alpha
        NEXT x
    NEXT y
    
    _MEMFREE sourceBlock
    _MEMFREE glowBlock
    
    ' Second pass: Apply optimized separable blur to glow image
    CALL ApplyGlowBlur(glowImg, glowRadius)
    
    ' Third pass: Combine original with glow (OPTIMIZED)
    sourceBlock = _MEMIMAGE(tempImg)
    glowBlock = _MEMIMAGE(glowImg)
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            offset = y * w * pixelSize + x * pixelSize
            
            ' Read original pixel
            b = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset, _UNSIGNED _BYTE)
            g = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 2, _UNSIGNED _BYTE)
            
            ' Read glow pixel
            gb = _MEMGET(glowBlock, glowBlock.OFFSET + offset, _UNSIGNED _BYTE)
            gg = _MEMGET(glowBlock, glowBlock.OFFSET + offset + 1, _UNSIGNED _BYTE)
            gr = _MEMGET(glowBlock, glowBlock.OFFSET + offset + 2, _UNSIGNED _BYTE)
            
            ' Combine with intensity scaling
            finalR = r + CINT(gr * intensity / 100.0)
            finalG = g + CINT(gg * intensity / 100.0)
            finalB = b + CINT(gb * intensity / 100.0)
            
            ' Clamp values
            IF finalR > 255 THEN finalR = 255
            IF finalG > 255 THEN finalG = 255
            IF finalB > 255 THEN finalB = 255
            
            ' Write final result
            _MEMPUT destBlock, destBlock.OFFSET + offset, finalB AS _UNSIGNED _BYTE
            _MEMPUT destBlock, destBlock.OFFSET + offset + 1, finalG AS _UNSIGNED _BYTE
            _MEMPUT destBlock, destBlock.OFFSET + offset + 2, finalR AS _UNSIGNED _BYTE
            _MEMPUT destBlock, destBlock.OFFSET + offset + 3, 255 AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE sourceBlock
    _MEMFREE glowBlock
    _MEMFREE destBlock
    
    _FREEIMAGE tempImg
    _FREEIMAGE glowImg
    _SOURCE oldSource
    _DEST oldDest
END SUB

' OPTIMIZED separable blur for glow effect using _MEMIMAGE
SUB ApplyGlowBlur (img AS LONG, radius AS INTEGER)
    IF radius <= 0 THEN EXIT SUB
    
    DIM tempImg AS LONG
    DIM w AS INTEGER, h AS INTEGER
    DIM x AS INTEGER, y AS INTEGER
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    w = _WIDTH(img)
    h = _HEIGHT(img)
    tempImg = _NEWIMAGE(w, h, 32)
    
    ' Use _MEMIMAGE for fastest pixel access
    DIM sourceBlock AS _MEM, tempBlock AS _MEM
    sourceBlock = _MEMIMAGE(img)
    tempBlock = _MEMIMAGE(tempImg)
    
    DIM pixelSize AS INTEGER: pixelSize = 4
    DIM offset AS _OFFSET, tempOffset AS _OFFSET
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG
    DIM dx AS INTEGER, dy AS INTEGER, count AS INTEGER
    
    ' Horizontal pass (blur rows)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sum pixels in horizontal kernel
            FOR dx = -radius TO radius
                IF x + dx >= 0 AND x + dx < w THEN
                    offset = y * w * pixelSize + (x + dx) * pixelSize
                    b = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset, _UNSIGNED _BYTE)
                    g = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 1, _UNSIGNED _BYTE)
                    r = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 2, _UNSIGNED _BYTE)
                    totalR = totalR + r
                    totalG = totalG + g
                    totalB = totalB + b
                    count = count + 1
                END IF
            NEXT dx
            
            ' Write averaged pixel to temp image
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                tempOffset = y * w * pixelSize + x * pixelSize
                _MEMPUT tempBlock, tempBlock.OFFSET + tempOffset, b AS _UNSIGNED _BYTE
                _MEMPUT tempBlock, tempBlock.OFFSET + tempOffset + 1, g AS _UNSIGNED _BYTE
                _MEMPUT tempBlock, tempBlock.OFFSET + tempOffset + 2, r AS _UNSIGNED _BYTE
                _MEMPUT tempBlock, tempBlock.OFFSET + tempOffset + 3, 255 AS _UNSIGNED _BYTE
            END IF
        NEXT x
    NEXT y
    
    _MEMFREE sourceBlock
    _MEMFREE tempBlock
    
    ' Vertical pass (blur columns) - from temp back to original
    sourceBlock = _MEMIMAGE(tempImg)
    DIM destBlock AS _MEM
    destBlock = _MEMIMAGE(img)
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sum pixels in vertical kernel
            FOR dy = -radius TO radius
                IF y + dy >= 0 AND y + dy < h THEN
                    offset = (y + dy) * w * pixelSize + x * pixelSize
                    b = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset, _UNSIGNED _BYTE)
                    g = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 1, _UNSIGNED _BYTE)
                    r = _MEMGET(sourceBlock, sourceBlock.OFFSET + offset + 2, _UNSIGNED _BYTE)
                    totalR = totalR + r
                    totalG = totalG + g
                    totalB = totalB + b
                    count = count + 1
                END IF
            NEXT dy
            
            ' Write final blurred pixel
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                tempOffset = y * w * pixelSize + x * pixelSize
                _MEMPUT destBlock, destBlock.OFFSET + tempOffset, b AS _UNSIGNED _BYTE
                _MEMPUT destBlock, destBlock.OFFSET + tempOffset + 1, g AS _UNSIGNED _BYTE
                _MEMPUT destBlock, destBlock.OFFSET + tempOffset + 2, r AS _UNSIGNED _BYTE
                _MEMPUT destBlock, destBlock.OFFSET + tempOffset + 3, 255 AS _UNSIGNED _BYTE
            END IF
        NEXT x
    NEXT y
    
    _MEMFREE sourceBlock
    _MEMFREE destBlock
    _FREEIMAGE tempImg
    _SOURCE oldSource
    _DEST oldDest
END SUB
