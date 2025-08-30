' Common functions for image adjustment algorithms
' Implementation file for adjustment_common.bi

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
        parameters(i) = 0 ' Default to 0 for most parameters
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
    
    ' Apply brightness adjustment
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM oldSrc AS LONG, oldDest AS LONG
    
    oldSrc = _SOURCE: oldDest = _DEST
    _SOURCE resultImg: _DEST resultImg
    
    w = _WIDTH(resultImg): h = _HEIGHT(resultImg)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + offset
            g = _GREEN32(c) + offset
            b = _BLUE32(c) + offset
            
            ' Clamp values to 0-255 range
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _SOURCE oldSrc: _DEST oldDest
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
    
    ' Apply contrast adjustment
    DIM f AS DOUBLE
    f = (259.0 * (pct + 255.0)) / (255.0 * (259.0 - pct))
    
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM oldSrc AS LONG, oldDest AS LONG
    
    oldSrc = _SOURCE: oldDest = _DEST
    _SOURCE resultImg: _DEST resultImg
    
    w = _WIDTH(resultImg): h = _HEIGHT(resultImg)
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
    
    _SOURCE oldSrc: _DEST oldDest
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
    
    ' Apply gamma correction
    DIM invGamma AS SINGLE
    invGamma = 1.0 / gamma
    
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM oldSrc AS LONG, oldDest AS LONG
    
    oldSrc = _SOURCE: oldDest = _DEST
    _SOURCE resultImg: _DEST resultImg
    
    w = _WIDTH(resultImg): h = _HEIGHT(resultImg)
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(255 * ((_RED32(c) / 255.0) ^ invGamma))
            g = CINT(255 * ((_GREEN32(c) / 255.0) ^ invGamma))
            b = CINT(255 * ((_BLUE32(c) / 255.0) ^ invGamma))
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    
    _SOURCE oldSrc: _DEST oldDest
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
