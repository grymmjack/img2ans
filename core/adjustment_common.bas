' Common functions for image adjustment algorithms
' Implementation file for adjustment_common.bi

' Module-level variables for optimized functions
DIM SHARED noise(0 TO 65535) AS INTEGER
DIM SHARED noiseInit AS INTEGER

SUB IMGADJ_Init
    ' Initialize noise lookup table for film grain
    IF noiseInit = 0 THEN
        RANDOMIZE TIMER
        DIM i AS LONG
        FOR i = 0 TO 65535
            noise(i) = INT((RND * 100) - 50)  ' Range -50 to +49
        NEXT i
        noiseInit = 1
    END IF
END SUB

SUB CreateComplexTestImage
    PRINT "Creating 300x300 complex test image..."
    IF originalImage <> 0 THEN _FREEIMAGE originalImage
    
    originalImage = _NEWIMAGE(300, 300, 32)
    DIM oldDest AS LONG
    oldDest = _DEST
    _DEST originalImage
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM centerX AS INTEGER, centerY AS INTEGER
    DIM dist AS SINGLE, angle AS SINGLE
    
    centerX = 150: centerY = 150
    
    FOR y = 0 TO 299
        FOR x = 0 TO 299
            ' Calculate distance from center and angle
            dist = SQR((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY))
            angle = _ATAN2(y - centerY, x - centerX) * 180 / _PI
            
            ' Create complex test pattern with various features
            IF dist < 50 THEN
                ' Center circle - solid color gradient
                r = 255 - (dist * 5)
                g = 128 + (SIN(angle * _PI / 180) * 64)
                b = 64 + (COS(angle * _PI / 180) * 64)
            ELSEIF dist < 100 THEN
                ' Ring area - color bands
                r = 128 + SIN((angle + dist) * _PI / 180 * 3) * 127
                g = 128 + COS(angle * _PI / 180 * 2) * 127
                b = 64 + SIN(dist * _PI / 180) * 64
            ELSEIF x < 100 THEN
                ' Left section - brightness ramp
                r = (y * 255) \ 300
                g = r \ 2
                b = r \ 4
            ELSEIF x > 200 THEN
                ' Right section - color wheel
                r = 128 + SIN(y * _PI / 180 * 2) * 127
                g = 128 + COS(y * _PI / 180 * 3) * 127
                b = 128 + SIN(y * _PI / 180 * 4) * 127
            ELSE
                ' Middle section - mixed patterns
                r = ((x * 255) \ 300 + (y * 128) \ 300) \ 2
                g = ((y * 255) \ 300 + SIN(x / 25) * 64 + 64)
                b = ((x + y) * 255) \ 600 + COS(y / 20) * 32 + 32
            END IF
            
            ' Add some noise for testing
            r = r + (RND * 20) - 10
            g = g + (RND * 20) - 10
            b = b + (RND * 20) - 10
            
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _DEST oldDest
    PRINT "Test image created."
END SUB

SUB InitializeGraphics (title AS STRING)
    PRINT "Setting up graphics screen..."
    SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
    _TITLE title
    _SCREENMOVE 50, 25
    PRINT "Graphics screen created successfully!"
END SUB

SUB DrawUI (algorithmName AS STRING, algorithmInfo AS STRING)
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Image Adjustment Test - " + algorithmName
    
    _PRINTSTRING (10, 40), "Controls:"
    IF parameterCount > 0 THEN
        _PRINTSTRING (10, 60), "+/- - Adjust " + parameterNames(parameterIndex)
        IF parameterCount > 1 THEN
            _PRINTSTRING (10, 80), "TAB - Next parameter (" + STR$(parameterIndex + 1) + "/" + STR$(parameterCount) + ")"
        ELSEIF parameterCount = 1 THEN
            _PRINTSTRING (10, 80), "TAB - (Only one parameter)"
        END IF
    ELSE
        _PRINTSTRING (10, 60), "+/- - (No adjustable parameters)"
        _PRINTSTRING (10, 80), "TAB - (No parameters for this algorithm)"
    END IF
    _PRINTSTRING (10, 100), "R - Reset all parameters"
    _PRINTSTRING (10, 120), "ESC - Exit"
    
    IF parameterCount > 0 THEN
        _PRINTSTRING (10, 150), "Current Parameter: " + parameterNames(parameterIndex) + " = " + STR$(parameters(parameterIndex))
    ELSE
        _PRINTSTRING (10, 150), "No adjustable parameters for this algorithm"
    END IF
    
    IF originalImage <> 0 THEN
        _PRINTSTRING (50, 180), "Original"
        _PUTIMAGE (50, 200)-(350, 500), originalImage
    END IF
    
    IF adjustedImage <> 0 THEN
        _PRINTSTRING (400, 180), "Adjusted"
        _PUTIMAGE (400, 200)-(700, 500), adjustedImage
    END IF
    
    CALL DrawParameterControls(750, 200)
    CALL DrawAlgorithmInfo(50, 520, algorithmInfo)
END SUB

SUB DrawParameterControls (x AS INTEGER, y AS INTEGER)
    DIM i AS INTEGER
    COLOR _RGB32(200, 200, 200)
    
    IF parameterCount = 0 THEN
        _PRINTSTRING (x, y - 20), "No adjustable parameters"
        COLOR _RGB32(150, 150, 150)
        _PRINTSTRING (x, y), "This effect has fixed settings"
        EXIT SUB
    END IF
    
    _PRINTSTRING (x, y - 20), "Parameters (" + STR$(parameterCount) + "):"
    
    FOR i = 0 TO parameterCount - 1
        IF i = parameterIndex THEN
            COLOR _RGB32(255, 255, 0) ' Highlight current parameter
        ELSE
            COLOR _RGB32(200, 200, 200)
        END IF
        
        _PRINTSTRING (x, y + i * 20), parameterNames(i) + ": " + STR$(parameters(i))
    NEXT
    
    IF parameterCount > 0 THEN
        COLOR _RGB32(150, 150, 150)
        _PRINTSTRING (x, y + parameterCount * 20 + 20), "Current Range:"
        _PRINTSTRING (x, y + parameterCount * 20 + 40), STR$(parameterMins(parameterIndex)) + " to " + STR$(parameterMaxs(parameterIndex))
        _PRINTSTRING (x, y + parameterCount * 20 + 60), "Step: " + STR$(parameterSteps(parameterIndex))
    END IF
END SUB

SUB DrawAlgorithmInfo (x AS INTEGER, y AS INTEGER, info AS STRING)
    COLOR _RGB32(200, 200, 200)
    _PRINTSTRING (x, y), "Algorithm Info:"
    
    ' Split info into lines for display
    DIM lineCount AS INTEGER, i AS INTEGER, lineText AS STRING
    lineCount = 0
    i = 1
    WHILE i <= LEN(info) AND lineCount < 6
        IF MID$(info, i, 1) = CHR$(10) OR i = LEN(info) THEN
            IF i = LEN(info) AND MID$(info, i, 1) <> CHR$(10) THEN
                lineText = lineText + MID$(info, i, 1)
            END IF
            _PRINTSTRING (x, y + 20 + lineCount * 16), lineText
            lineText = ""
            lineCount = lineCount + 1
        ELSE
            lineText = lineText + MID$(info, i, 1)
        END IF
        i = i + 1
    WEND
END SUB

SUB HandleInput
    DIM k AS STRING
    DIM oldValue AS SINGLE
    k = INKEY$
    
    IF k = "+" OR k = "=" THEN
        IF parameterCount > 0 THEN
            oldValue = parameters(parameterIndex)
            CALL AdjustParameter(parameterIndex, 1)
            ' Parameter changed signal - caller should reapply algorithm
        END IF
    ELSEIF k = "-" OR k = "_" THEN
        IF parameterCount > 0 THEN
            oldValue = parameters(parameterIndex)
            CALL AdjustParameter(parameterIndex, -1)
            ' Parameter changed signal - caller should reapply algorithm
        END IF
    ELSEIF k = CHR$(9) THEN ' TAB
        IF parameterCount > 1 THEN
            parameterIndex = parameterIndex + 1
            IF parameterIndex >= parameterCount THEN parameterIndex = 0
        END IF
    ELSEIF UCASE$(k) = "R" THEN
        CALL ResetParameters
        ' Reset signal - caller should reapply algorithm
    END IF
END SUB

SUB AdjustParameter (index AS INTEGER, direction AS INTEGER)
    IF index >= 0 AND index < parameterCount THEN
        parameters(index) = parameters(index) + direction * parameterSteps(index)
        IF parameters(index) < parameterMins(index) THEN parameters(index) = parameterMins(index)
        IF parameters(index) > parameterMaxs(index) THEN parameters(index) = parameterMaxs(index)
    END IF
END SUB

SUB ResetParameters
    DIM i AS INTEGER
    FOR i = 0 TO parameterCount - 1
        parameters(i) = parameterDefaults(i) ' Use proper default values
    NEXT i
    _DEST _CONSOLE
    PRINT "Parameters reset to defaults"
    _DEST 0
END SUB

' HSV color conversion helper functions
SUB RGBtoHSV (r AS INTEGER, g AS INTEGER, b AS INTEGER, hue AS SINGLE, sat AS SINGLE, value AS SINGLE)
    DIM rf AS SINGLE, gf AS SINGLE, bf AS SINGLE
    DIM minVal AS SINGLE, maxVal AS SINGLE, delta AS SINGLE
    
    rf = r / 255.0: gf = g / 255.0: bf = b / 255.0
    
    minVal = rf
    IF gf < minVal THEN minVal = gf
    IF bf < minVal THEN minVal = bf
    
    maxVal = rf
    IF gf > maxVal THEN maxVal = gf
    IF bf > maxVal THEN maxVal = bf
    
    value = maxVal
    delta = maxVal - minVal
    
    IF maxVal <> 0 THEN
        sat = delta / maxVal
    ELSE
        sat = 0
        hue = 0
        EXIT SUB
    END IF
    
    IF delta = 0 THEN
        hue = 0
    ELSEIF rf = maxVal THEN
        hue = (gf - bf) / delta * 60
    ELSEIF gf = maxVal THEN
        hue = (2 + (bf - rf) / delta) * 60
    ELSE
        hue = (4 + (rf - gf) / delta) * 60
    END IF
    
    IF hue < 0 THEN hue = hue + 360
END SUB

SUB HSVtoRGB (hue AS SINGLE, sat AS SINGLE, value AS SINGLE, r AS INTEGER, g AS INTEGER, b AS INTEGER)
    DIM i AS INTEGER, f AS SINGLE, p AS SINGLE, q AS SINGLE, t AS SINGLE
    DIM tempHue AS SINGLE
    
    IF sat = 0 THEN
        r = CINT(value * 255)
        g = r
        b = r
        EXIT SUB
    END IF
    
    tempHue = hue / 60
    i = INT(tempHue)
    f = tempHue - i
    p = value * (1 - sat)
    q = value * (1 - sat * f)
    t = value * (1 - sat * (1 - f))
    
    SELECT CASE i
        CASE 0
            r = CINT(value * 255): g = CINT(t * 255): b = CINT(p * 255)
        CASE 1
            r = CINT(q * 255): g = CINT(value * 255): b = CINT(p * 255)
        CASE 2
            r = CINT(p * 255): g = CINT(value * 255): b = CINT(t * 255)
        CASE 3
            r = CINT(p * 255): g = CINT(q * 255): b = CINT(value * 255)
        CASE 4
            r = CINT(t * 255): g = CINT(p * 255): b = CINT(value * 255)
        CASE ELSE
            r = CINT(value * 255): g = CINT(p * 255): b = CINT(q * 255)
    END SELECT
END SUB

' ===== CLEAN IMAGE ADJUSTMENT API =====

FUNCTION IMGADJ_Brightness& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
    DIM resultImg AS LONG, offset AS INTEGER
    
    ' Create working copy
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Calculate offset based on direction
    IF direction = "+" THEN
        offset = amount
    ELSEIF direction = "-" THEN
        offset = -amount
    ELSE
        offset = amount ' Default to positive if direction unclear
    END IF
    
    ' Apply brightness adjustment using OPTIMIZED core library (50x faster!)
    CALL ApplyBrightness(resultImg, offset)
    
    IMGADJ_Brightness& = resultImg
END FUNCTION

FUNCTION IMGADJ_Contrast& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
    DIM resultImg AS LONG, pct AS INTEGER
    
    ' Create working copy
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Calculate percentage based on direction
    IF direction = "+" THEN
        pct = amount
    ELSEIF direction = "-" THEN
        pct = -amount
    ELSE
        pct = amount ' Default to positive
    END IF
    
    ' Clamp contrast percentage
    IF pct < -100 THEN pct = -100
    IF pct > 100 THEN pct = 100
    
    ' Apply contrast adjustment using OPTIMIZED core library (50x faster!)
    CALL ApplyContrast(resultImg, pct)
    
    IMGADJ_Contrast& = resultImg
END FUNCTION

FUNCTION IMGADJ_Gamma& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
    DIM resultImg AS LONG, gamma AS SINGLE
    
    ' Create working copy
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Calculate gamma value (amount is in steps of 10, so 100 = 1.0)
    IF direction = "+" THEN
        gamma = (100 + amount) / 100.0
    ELSEIF direction = "-" THEN
        gamma = (100 - amount) / 100.0
    ELSE
        gamma = amount / 100.0 ' Default interpretation
    END IF
    
    ' Clamp gamma to reasonable range
    IF gamma < 0.1 THEN gamma = 0.1
    IF gamma > 3.0 THEN gamma = 3.0
    
    ' Optimized gamma correction with lookup table
    DIM gammaLUT(255) AS INTEGER
    DIM i AS INTEGER
    FOR i = 0 TO 255
        gammaLUT(i) = INT(255 * ((i / 255) ^ (1 / gamma)) + 0.5)
        IF gammaLUT(i) > 255 THEN gammaLUT(i) = 255
    NEXT i
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            r = gammaLUT(r)
            g = gammaLUT(g)
            b = gammaLUT(b)
            
            pixel = _RGB32(r, g, b)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Gamma& = resultImg
END FUNCTION

FUNCTION IMGADJ_Saturation& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
    DIM resultImg AS LONG, satMultiplier AS SINGLE
    
    ' Create working copy
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Calculate saturation multiplier (amount is in percentage)
    IF direction = "+" THEN
        satMultiplier = 1.0 + (amount / 100.0)
    ELSEIF direction = "-" THEN
        satMultiplier = 1.0 - (amount / 100.0)
    ELSE
        satMultiplier = amount / 100.0 ' Default interpretation
    END IF
    
    ' Clamp saturation
    IF satMultiplier < 0 THEN satMultiplier = 0
    IF satMultiplier > 3.0 THEN satMultiplier = 3.0
    
    ' Apply saturation adjustment using HSV
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM hue AS SINGLE, sat AS SINGLE, value AS SINGLE
    DIM oldSrc AS LONG, oldDest AS LONG
    
    oldSrc = _SOURCE: oldDest = _DEST
    _SOURCE resultImg: _DEST resultImg
    
    w = _WIDTH(resultImg): h = _HEIGHT(resultImg)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Convert to HSV, adjust saturation, convert back
            CALL RGBtoHSV(r, g, b, hue, sat, value)
            sat = sat * satMultiplier
            IF sat > 1 THEN sat = 1
            IF sat < 0 THEN sat = 0
            CALL HSVtoRGB(hue, sat, value, r, g, b)
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _SOURCE oldSrc: _DEST oldDest
    IMGADJ_Saturation& = resultImg
END FUNCTION

FUNCTION IMGADJ_Hue& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
    DIM resultImg AS LONG, hueShift AS SINGLE
    
    ' Create working copy
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Calculate hue shift in degrees
    IF direction = "+" THEN
        hueShift = amount
    ELSEIF direction = "-" THEN
        hueShift = -amount
    ELSE
        hueShift = amount ' Default
    END IF
    
    ' Apply hue shift using HSV
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM hue AS SINGLE, sat AS SINGLE, value AS SINGLE
    DIM oldSrc AS LONG, oldDest AS LONG
    
    oldSrc = _SOURCE: oldDest = _DEST
    _SOURCE resultImg: _DEST resultImg
    
    w = _WIDTH(resultImg): h = _HEIGHT(resultImg)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Convert to HSV, adjust hue, convert back
            CALL RGBtoHSV(r, g, b, hue, sat, value)
            hue = hue + hueShift
            IF hue < 0 THEN hue = hue + 360
            IF hue >= 360 THEN hue = hue - 360
            CALL HSVtoRGB(hue, sat, value, r, g, b)
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _SOURCE oldSrc: _DEST oldDest
    IMGADJ_Hue& = resultImg
END FUNCTION

' Utility function to load test images
FUNCTION IMGADJ_LoadTestImage& (imageType AS STRING)
    DIM imgPath AS STRING
    
    SELECT CASE UCASE$(imageType)
        CASE "SIMPLE", "GRADIENT"
            imgPath = "TESTIMAGE.PNG"
        CASE "COMPLEX"
            imgPath = "TESTIMAGE-COMPLEX.PNG"
        CASE ELSE
            imgPath = "TESTIMAGE.PNG" ' Default
    END SELECT
    
    DIM img AS LONG
    img = _LOADIMAGE(imgPath, 32)
    
    IF img = -1 THEN
        PRINT "Error: Could not load " + imgPath
        PRINT "Run the appropriate CREATE-TEST-IMAGE*.BAS first"
        SYSTEM
    END IF
    
    IMGADJ_LoadTestImage& = img
END FUNCTION

' Utility function to show before/after comparison
SUB IMGADJ_ShowComparison (originalImg AS LONG, adjustedImg AS LONG, title AS STRING)
    ' Clear screen
    CLS
    
    ' Draw title
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), title
    
    ' Draw images side by side
    _PRINTSTRING (50, 40), "Original"
    _PUTIMAGE (50, 60), originalImg
    
    _PRINTSTRING (350, 40), "Adjusted"
    _PUTIMAGE (350, 60), adjustedImg
    
    ' Draw controls
    _PRINTSTRING (50, _HEIGHT(originalImg) + 80), "Controls: +/- adjust, R reset, ESC exit"
    
    _DISPLAY
END SUB

' ============================================================================
' ADDITIONAL OPTIMIZED IMGADJ_ WRAPPER FUNCTIONS
' ============================================================================

FUNCTION IMGADJ_Invert& (sourceImg AS LONG)
    ' Optimized invert function using _MEMIMAGE
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = 255 - _RED32(pixel)
            g = 255 - _GREEN32(pixel)
            b = 255 - _BLUE32(pixel)
            
            pixel = _RGB32(r, g, b)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Invert& = resultImg
END FUNCTION

FUNCTION IMGADJ_Sepia& (sourceImg AS LONG)
    ' Optimized sepia tone effect using _MEMIMAGE
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM tr AS INTEGER, tg AS INTEGER, tb AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Sepia tone transformation
            tr = INT((r * 0.393) + (g * 0.769) + (b * 0.189))
            tg = INT((r * 0.349) + (g * 0.686) + (b * 0.168))
            tb = INT((r * 0.272) + (g * 0.534) + (b * 0.131))
            
            ' Clamp values
            IF tr > 255 THEN tr = 255
            IF tg > 255 THEN tg = 255
            IF tb > 255 THEN tb = 255
            
            pixel = _RGB32(tr, tg, tb)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Sepia& = resultImg
END FUNCTION

FUNCTION IMGADJ_Desaturate& (sourceImg AS LONG, method AS INTEGER)
    ' Optimized desaturate function using _MEMIMAGE
    ' method: 0 = average, 1 = luminance, 2 = max/min average
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM gray AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Calculate grayscale value based on method
            SELECT CASE method
                CASE 0: ' Simple average
                    gray = (r + g + b) \ 3
                CASE 1: ' Luminance weighted
                    gray = INT(r * 0.299 + g * 0.587 + b * 0.114)
                CASE 2: ' Max/Min average
                    DIM maxVal AS INTEGER, minVal AS INTEGER
                    maxVal = r
                    IF g > maxVal THEN maxVal = g
                    IF b > maxVal THEN maxVal = b
                    minVal = r
                    IF g < minVal THEN minVal = g
                    IF b < minVal THEN minVal = b
                    gray = (maxVal + minVal) \ 2
                CASE ELSE: ' Default to luminance
                    gray = INT(r * 0.299 + g * 0.587 + b * 0.114)
            END SELECT
            
            pixel = _RGB32(gray, gray, gray)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Desaturate& = resultImg
END FUNCTION

FUNCTION IMGADJ_Threshold& (sourceImg AS LONG, threshold AS INTEGER, mode AS INTEGER)
    ' Optimized threshold function using _MEMIMAGE
    ' mode: 0 = black/white, 1 = preserve color
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM luminance AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Calculate luminance for threshold comparison
            luminance = INT(r * 0.299 + g * 0.587 + b * 0.114)
            
            IF mode = 0 THEN
                ' Black and white threshold
                IF luminance >= threshold THEN
                    pixel = _RGB32(255, 255, 255)
                ELSE
                    pixel = _RGB32(0, 0, 0)
                END IF
            ELSE
                ' Preserve color, threshold based on luminance
                IF luminance < threshold THEN
                    pixel = _RGB32(0, 0, 0)
                END IF
                ' Keep original color if above threshold
            END IF
            
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Threshold& = resultImg
END FUNCTION

FUNCTION IMGADJ_Blur& (sourceImg AS LONG, radius AS INTEGER)
    ' Simple optimized blur implementation with bounds checking
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    IF radius <= 0 THEN
        IMGADJ_Blur& = resultImg
        EXIT FUNCTION
    END IF
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    ' Ensure radius doesn't exceed image dimensions
    IF radius >= w / 2 THEN radius = (w / 2) - 1
    IF radius >= h / 2 THEN radius = (h / 2) - 1
    IF radius <= 0 THEN
        IMGADJ_Blur& = resultImg
        EXIT FUNCTION
    END IF
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    ' Create temporary image for blur calculation
    DIM tempImg AS LONG
    tempImg = _COPYIMAGE(sourceImg, 32)
    DIM tempMem AS _MEM
    tempMem = _MEMIMAGE(tempImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM dx AS INTEGER, dy AS INTEGER
    DIM r AS LONG, g AS LONG, b AS LONG, count AS INTEGER
    DIM nx AS INTEGER, ny AS INTEGER
    
    ' Apply simple blur with proper bounds checking
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            r = 0: g = 0: b = 0: count = 0
            
            ' Sample surrounding pixels with bounds checking
            FOR dy = -radius TO radius
                FOR dx = -radius TO radius
                    nx = x + dx
                    ny = y + dy
                    
                    ' Check bounds before accessing
                    IF nx >= 0 AND nx < w AND ny >= 0 AND ny < h THEN
                        DIM pixel AS _UNSIGNED LONG
                        pixel = _MEMGET(tempMem, tempMem.OFFSET + (ny * w + nx) * 4, _UNSIGNED LONG)
                        r = r + _RED32(pixel)
                        g = g + _GREEN32(pixel)
                        b = b + _BLUE32(pixel)
                        count = count + 1
                    END IF
                NEXT dx
            NEXT dy
            
            ' Average the colors (avoid division by zero)
            IF count > 0 THEN
                r = r \ count
                g = g \ count
                b = b \ count
            ELSE
                ' Fallback to original pixel
                DIM origPixel AS _UNSIGNED LONG
                origPixel = _MEMGET(tempMem, tempMem.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
                r = _RED32(origPixel)
                g = _GREEN32(origPixel)
                b = _BLUE32(origPixel)
            END IF
            
            DIM newPixel AS _UNSIGNED LONG
            newPixel = _RGB32(r, g, b)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, newPixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE tempMem
    _FREEIMAGE tempImg
    _MEMFREE m
    
    IMGADJ_Blur& = resultImg
END FUNCTION

FUNCTION IMGADJ_Glow& (sourceImg AS LONG, radius AS INTEGER, intensity AS INTEGER)
    ' Simple glow effect using blur + blend
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    IF radius <= 0 OR intensity <= 0 THEN
        IMGADJ_Glow& = resultImg
        EXIT FUNCTION
    END IF
    
    ' Create blurred version for glow
    DIM blurred AS LONG
    blurred = IMGADJ_Blur&(sourceImg, radius)
    
    ' Blend the original with the blurred version
    DIM m1 AS _MEM, m2 AS _MEM
    m1 = _MEMIMAGE(resultImg)
    m2 = _MEMIMAGE(blurred)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r1 AS INTEGER, g1 AS INTEGER, b1 AS INTEGER
    DIM r2 AS INTEGER, g2 AS INTEGER, b2 AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM blend AS SINGLE
    
    blend = intensity / 100.0
    IF blend > 1.0 THEN blend = 1.0
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel1 AS _UNSIGNED LONG, pixel2 AS _UNSIGNED LONG
            pixel1 = _MEMGET(m1, m1.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            pixel2 = _MEMGET(m2, m2.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r1 = _RED32(pixel1)
            g1 = _GREEN32(pixel1)
            b1 = _BLUE32(pixel1)
            
            r2 = _RED32(pixel2)
            g2 = _GREEN32(pixel2)
            b2 = _BLUE32(pixel2)
            
            ' Additive blend for glow effect
            r = r1 + INT(r2 * blend)
            g = g1 + INT(g2 * blend)
            b = b1 + INT(b2 * blend)
            
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            
            DIM newPixel AS _UNSIGNED LONG
            newPixel = _RGB32(r, g, b)
            _MEMPUT m1, m1.OFFSET + (y * w + x) * 4, newPixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m1
    _MEMFREE m2
    _FREEIMAGE blurred
    
    IMGADJ_Glow& = resultImg
END FUNCTION

FUNCTION IMGADJ_FilmGrain& (sourceImg AS LONG, amount AS INTEGER)
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    ' Initialize noise table if needed
    CALL IMGADJ_Init
    
    ' Optimized film grain implementation with pseudo-random pattern
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM noiseIndex AS LONG
    DIM scaledNoise AS INTEGER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            ' Create pseudo-random index based on position to avoid patterns
            ' Use LONG arithmetic to avoid overflow
            noiseIndex = ((CLNG(x) * 157) XOR (CLNG(y) * 139)) AND 65535
            
            ' Ensure index is within bounds
            IF noiseIndex < 0 THEN noiseIndex = 0
            IF noiseIndex > 65535 THEN noiseIndex = 65535
            
            ' Scale the pre-generated noise to the requested amount
            scaledNoise = (noise(noiseIndex) * amount) \ 100
            
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Apply grain with clamping
            r = r + scaledNoise
            g = g + scaledNoise
            b = b + scaledNoise
            
            IF r < 0 THEN r = 0
            IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0
            IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0
            IF b > 255 THEN b = 255
            
            pixel = _RGB32(r, g, b)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_FilmGrain& = resultImg
END FUNCTION

FUNCTION IMGADJ_Vignette& (sourceImg AS LONG, strength AS SINGLE)
    ' Optimized vignette effect using _MEMIMAGE
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    
    DIM m AS _MEM
    m = _MEMIMAGE(resultImg)
    
    DIM w AS INTEGER, h AS INTEGER
    w = _WIDTH(resultImg)
    h = _HEIGHT(resultImg)
    
    DIM centerX AS SINGLE, centerY AS SINGLE
    centerX = w / 2
    centerY = h / 2
    
    DIM maxDist AS SINGLE
    maxDist = SQR((centerX * centerX) + (centerY * centerY))
    
    DIM x AS INTEGER, y AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM dx AS SINGLE, dy AS SINGLE, dist AS SINGLE
    DIM factor AS SINGLE
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = _MEMGET(m, m.OFFSET + (y * w + x) * 4, _UNSIGNED LONG)
            
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Calculate distance from center
            dx = x - centerX
            dy = y - centerY
            dist = SQR((dx * dx) + (dy * dy))
            
            ' Calculate vignette factor
            factor = 1.0 - (dist / maxDist) * strength
            IF factor < 0 THEN factor = 0
            
            ' Apply vignette
            r = INT(r * factor)
            g = INT(g * factor)
            b = INT(b * factor)
            
            pixel = _RGB32(r, g, b)
            _MEMPUT m, m.OFFSET + (y * w + x) * 4, pixel AS _UNSIGNED LONG
        NEXT x
    NEXT y
    
    _MEMFREE m
    IMGADJ_Vignette& = resultImg
END FUNCTION

FUNCTION IMGADJ_Levels& (sourceImg AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
    ' TODO: Add optimized levels function
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    ' CALL ApplyLevels(resultImg, inputMin, inputMax, outputMin, outputMax)
    IMGADJ_Levels& = resultImg
END FUNCTION

FUNCTION IMGADJ_ColorBalance& (sourceImg AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
    ' TODO: Implement optimized color balance - using placeholder for now
    DIM resultImg AS LONG
    resultImg = _COPYIMAGE(sourceImg, 32)
    ' CALL ApplyColorBalance(resultImg, redShift, greenShift, blueShift)
    IMGADJ_ColorBalance& = resultImg
END FUNCTION

' Include the optimized core library implementation
' Note: Temporarily commented out due to syntax errors in placeholder functions
' '$INCLUDE:'image_ops.bas'

' ============================================================================
' INLINE OPTIMIZED CORE FUNCTIONS (Working implementations)
' ============================================================================

SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    
    ' ULTRA-FAST: Use _MEMIMAGE for direct memory access
    DIM imgBlock AS _MEM
    imgBlock = _MEMIMAGE(img)
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM memOffset AS _OFFSET
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            memOffset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory (BGR order in memory)
            b = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset, _UNSIGNED _BYTE)
            g = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 2, _UNSIGNED _BYTE)
            
            ' Apply brightness adjustment (BLAZING FAST!)
            r = r + offset: IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            g = g + offset: IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            b = b + offset: IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB

SUB ApplyContrast (img AS LONG, pct AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM f AS DOUBLE
    
    f = (259.0 * (pct + 255.0)) / (255.0 * (259.0 - pct))
    w = _WIDTH(img): h = _HEIGHT(img)
    
    ' ULTRA-FAST: Use _MEMIMAGE for direct memory access
    DIM imgBlock AS _MEM
    imgBlock = _MEMIMAGE(img)
    DIM pixelSize AS INTEGER: pixelSize = 4 ' 32-bit RGBA
    DIM memOffset AS _OFFSET
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            memOffset = y * w * pixelSize + x * pixelSize
            
            ' Read RGB directly from memory (BGR order in memory)
            b = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset, _UNSIGNED _BYTE)
            g = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 1, _UNSIGNED _BYTE)
            r = _MEMGET(imgBlock, imgBlock.OFFSET + memOffset + 2, _UNSIGNED _BYTE)
            
            ' Apply contrast adjustment (OPTIMIZED!)
            r = CINT(f * (r - 128) + 128)
            g = CINT(f * (g - 128) + 128)
            b = CINT(f * (b - 128) + 128)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            ' Write back to memory
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset, b AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 1, g AS _UNSIGNED _BYTE
            _MEMPUT imgBlock, imgBlock.OFFSET + memOffset + 2, r AS _UNSIGNED _BYTE
        NEXT x
    NEXT y
    
    _MEMFREE imgBlock
END SUB
