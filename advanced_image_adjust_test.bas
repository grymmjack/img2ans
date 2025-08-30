' Advanced Image Adjustment Test with Multiple Techniques
$CONSOLE
_CONSOLE ON
PRINT "Advanced Image Adjustment Test Starting..."

' Include our core image operations
'$INCLUDE:'core/image_ops.bi'

' Forward declarations for our new functions
DECLARE SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
DECLARE SUB ApplyHueSaturation (img AS LONG, hueShift AS INTEGER, saturation AS SINGLE)
DECLARE SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
DECLARE SUB ApplyLevels (img AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
DECLARE SUB ApplyCurves (img AS LONG, curveType AS INTEGER)
DECLARE SUB ApplyChannelMixer (img AS LONG, redMix AS SINGLE, greenMix AS SINGLE, blueMix AS SINGLE)
DECLARE SUB ApplyThreshold (img AS LONG, threshold AS INTEGER, mode AS INTEGER)
DECLARE SUB ApplyInvert (img AS LONG)
DECLARE SUB ApplySepia (img AS LONG)
DECLARE SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
DECLARE SUB ApplyColorize (img AS LONG, hue AS INTEGER, saturation AS SINGLE)
DECLARE SUB ApplyVignette (img AS LONG, strength AS SINGLE)
DECLARE SUB ApplyFilmGrain (img AS LONG, amount AS INTEGER)
DECLARE SUB ApplyRetroEffect (img AS LONG, effectType AS INTEGER)

' Screen configuration
CONST SCREEN_W = 1400
CONST SCREEN_H = 900

DIM SHARED originalImage AS LONG
DIM SHARED adjustedImage AS LONG
DIM SHARED adjustmentMethod AS INTEGER
DIM SHARED parameterIndex AS INTEGER
DIM SHARED parameters(0 TO 4) AS SINGLE
DIM SHARED parameterNames(0 TO 4) AS STRING
DIM SHARED parameterCount AS INTEGER
DIM SHARED parameterMins(0 TO 4) AS SINGLE
DIM SHARED parameterMaxs(0 TO 4) AS SINGLE
DIM SHARED parameterSteps(0 TO 4) AS SINGLE

PRINT "Initializing..."
adjustmentMethod = 0
parameterIndex = 0
originalImage = 0
adjustedImage = 0

' Initialize default parameters
parameters(0) = 0  ' Brightness offset
parameters(1) = 0  ' Contrast percentage  
parameters(2) = 1  ' Gamma value
parameters(3) = 100 ' Saturation percentage
parameters(4) = 0  ' Hue shift

PRINT "Creating test image..."
CALL CreateComplexTestImage

PRINT "Setting up graphics screen..."
SCREEN _NEWIMAGE(SCREEN_W, SCREEN_H, 32)
_TITLE "Advanced Image Adjustment Test - SPACE: method, +/-: adjust, TAB: parameter"
_SCREENMOVE 50, 25

    CALL SetupMethodParameters(adjustmentMethod) ' Initialize parameters for first methodPRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  SPACE = next adjustment method"
PRINT "  +/- = adjust current parameter"
PRINT "  TAB = next parameter"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI
    CALL HandleInput
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)

PRINT "Cleaning up..."
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
PRINT "Program ended."
SYSTEM

' Core image operations (embedded for standalone functionality)
SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)
    IF brightness <> 0 THEN CALL ApplyBrightness(img, brightness)
    IF contrastPct <> 0 THEN CALL ApplyContrast(img, contrastPct)
    IF posterizeLevels > 1 THEN CALL ApplyPosterize(img, posterizeLevels)
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
    IF pct < -100 THEN pct = -100
    IF pct > 100 THEN pct = 100
    DIM f AS DOUBLE
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
    IF levels < 2 THEN EXIT SUB
    DIM stepv AS INTEGER
    stepv = 255 \ (levels - 1)
    IF stepv < 1 THEN stepv = 1

    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
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

' Smooth posterize with floating point levels for finer control
SUB ApplyPosterizeSmooth (img AS LONG, levels AS SINGLE)
    IF levels < 2.0 THEN EXIT SUB
    
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM rf AS SINGLE, gf AS SINGLE, bf AS SINGLE
    DIM stepSize AS SINGLE
    
    stepSize = 255.0 / (levels - 1.0)
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Convert to floating point and apply smooth posterization
            rf = r / 255.0
            gf = g / 255.0
            bf = b / 255.0
            
            ' Map to discrete levels with smooth interpolation
            rf = INT(rf * (levels - 1.0) + 0.5) / (levels - 1.0)
            gf = INT(gf * (levels - 1.0) + 0.5) / (levels - 1.0)
            bf = INT(bf * (levels - 1.0) + 0.5) / (levels - 1.0)
            
            ' Convert back to integer
            r = CINT(rf * 255.0)
            g = CINT(gf * 255.0)
            b = CINT(bf * 255.0)
            
            ' Clamp values
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            IF r < 0 THEN r = 0
            IF g < 0 THEN g = 0
            IF b < 0 THEN b = 0
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

' True color quantization - reduces image to specified number of total colors
SUB ApplyColorQuantization (img AS LONG, sourceImg AS LONG, numColors AS INTEGER)
    IF numColors < 2 OR numColors > 256 THEN EXIT SUB
    
    ' Dead simple posterize - just reduce each channel to fewer levels
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM oldSrc AS LONG: oldSrc = _SOURCE: _SOURCE img
    DIM oldDest AS LONG: oldDest = _DEST: _DEST img
    
    ' Calculate how many levels per channel based on color count
    DIM levels AS INTEGER
    IF numColors <= 8 THEN 
        levels = 2
    ELSEIF numColors <= 27 THEN 
        levels = 3
    ELSEIF numColors <= 64 THEN 
        levels = 4
    ELSEIF numColors <= 125 THEN 
        levels = 5
    ELSE 
        levels = 6
    END IF
    
    ' Process each pixel
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            DIM pixel AS _UNSIGNED LONG
            pixel = POINT(x, y)
            DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Simple level reduction
            DIM newR AS INTEGER, newG AS INTEGER, newB AS INTEGER
            newR = (r * (levels - 1)) \ 255
            newG = (g * (levels - 1)) \ 255  
            newB = (b * (levels - 1)) \ 255
            
            ' Scale back to 0-255
            newR = (newR * 255) \ (levels - 1)
            newG = (newG * 255) \ (levels - 1)
            newB = (newB * 255) \ (levels - 1)
            
            PSET (x, y), _RGB32(newR, newG, newB)
        NEXT
    NEXT
    _SOURCE oldSrc: _DEST oldDest
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
    PRINT "Test image created. Applying initial adjustments..."
    CALL ApplyAdjustments
END SUB

SUB DrawUI
    COLOR _RGB32(255, 255, 255)
    _PRINTSTRING (10, 10), "Advanced Image Adjustment Test - " + STR$(GetMethodCount%) + " adjustment techniques"
    
    _PRINTSTRING (10, 40), "Controls:"
    _PRINTSTRING (10, 60), "SPACE - Next method (" + STR$(adjustmentMethod + 1) + "/" + STR$(GetMethodCount%) + ")"
    _PRINTSTRING (10, 80), "BACKSPACE - Previous method"
    _PRINTSTRING (10, 100), "+/- - Adjust parameter"
    IF parameterCount > 1 THEN
        _PRINTSTRING (10, 120), "TAB - Next parameter (" + STR$(parameterIndex + 1) + "/" + STR$(parameterCount) + ")"
    ELSEIF parameterCount = 1 THEN
        _PRINTSTRING (10, 120), "TAB - (Only one parameter)"
    ELSE
        _PRINTSTRING (10, 120), "TAB - (No parameters for this method)"
    END IF
    _PRINTSTRING (10, 140), "R - Reset all parameters"
    _PRINTSTRING (10, 160), "ESC - Exit"
    
    _PRINTSTRING (10, 190), "Current Method: " + GetMethodName$(adjustmentMethod)
    IF parameterCount > 0 THEN
        _PRINTSTRING (10, 210), "Current Parameter: " + parameterNames(parameterIndex) + " = " + STR$(parameters(parameterIndex))
    ELSE
        _PRINTSTRING (10, 210), "No adjustable parameters for this method"
    END IF
    
    IF originalImage <> 0 THEN
        _PRINTSTRING (50, 230), "Original"
        _PUTIMAGE (50, 250)-(350, 550), originalImage
    END IF
    
    IF adjustedImage <> 0 THEN
        _PRINTSTRING (400, 230), "Adjusted"
        _PUTIMAGE (400, 250)-(700, 550), adjustedImage
    END IF
    
    CALL DrawParameterControls(750, 250)
    CALL DrawMethodInfo(50, 570)
END SUB

SUB DrawParameterControls(x AS INTEGER, y AS INTEGER)
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

SUB DrawMethodInfo(x AS INTEGER, y AS INTEGER)
    DIM info AS STRING
    info = GetMethodInfo$(adjustmentMethod)
    
    COLOR _RGB32(200, 200, 200)
    _PRINTSTRING (x, y), "Method Info:"
    
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
    DIM oldValue AS SINGLE, oldValue2 AS SINGLE
    k = INKEY$
    
    IF UCASE$(k) = " " THEN
        adjustmentMethod = adjustmentMethod + 1
        IF adjustmentMethod >= GetMethodCount% THEN adjustmentMethod = 0
        CALL SetupMethodParameters(adjustmentMethod)
        _DEST _CONSOLE
        PRINT "Switched to adjustment method:"; adjustmentMethod + 1; "(" + GetMethodName$(adjustmentMethod) + ")"
        _DEST 0
        CALL ApplyAdjustments
    ELSEIF k = CHR$(8) THEN ' BACKSPACE - Previous method
        adjustmentMethod = adjustmentMethod - 1
        IF adjustmentMethod < 0 THEN adjustmentMethod = GetMethodCount% - 1
        CALL SetupMethodParameters(adjustmentMethod)
        _DEST _CONSOLE
        PRINT "Switched to adjustment method:"; adjustmentMethod + 1; "(" + GetMethodName$(adjustmentMethod) + ")"
        _DEST 0
        CALL ApplyAdjustments
    ELSEIF k = "+" OR k = "=" THEN
        IF parameterCount > 0 THEN
            oldValue = parameters(parameterIndex)
            CALL AdjustParameter(parameterIndex, 1)
            ' Only reprocess if parameter actually changed
            IF parameters(parameterIndex) <> oldValue THEN
                CALL ApplyAdjustments
            END IF
        END IF
    ELSEIF k = "-" OR k = "_" THEN
        IF parameterCount > 0 THEN
            oldValue2 = parameters(parameterIndex)
            CALL AdjustParameter(parameterIndex, -1)
            ' Only reprocess if parameter actually changed
            IF parameters(parameterIndex) <> oldValue2 THEN
                CALL ApplyAdjustments
            END IF
        END IF
    ELSEIF k = CHR$(9) THEN ' TAB
        IF parameterCount > 1 THEN
            parameterIndex = parameterIndex + 1
            IF parameterIndex >= parameterCount THEN parameterIndex = 0
        END IF
    ELSEIF UCASE$(k) = "R" THEN
        CALL ResetParameters
        CALL ApplyAdjustments
    END IF
END SUB

SUB AdjustParameter(index AS INTEGER, direction AS INTEGER)
    IF index >= 0 AND index < parameterCount THEN
        parameters(index) = parameters(index) + direction * parameterSteps(index)
        IF parameters(index) < parameterMins(index) THEN parameters(index) = parameterMins(index)
        IF parameters(index) > parameterMaxs(index) THEN parameters(index) = parameterMaxs(index)
    END IF
END SUB

SUB ResetParameters
    FOR i = 0 TO 4
        SELECT CASE adjustmentMethod
            CASE 2 ' Gamma - default to 1.0 (100 in our scale)
                IF i = 0 THEN
                    parameters(i) = 100
                ELSE
                    parameters(i) = 0
                END IF
            CASE 4 ' Saturation - default to 100%
                IF i = 0 THEN
                    parameters(i) = 0 ' 0 means no change in saturation
                ELSE
                    parameters(i) = 0
                END IF
            CASE ELSE
                parameters(i) = 0
        END SELECT
    NEXT i
    _DEST _CONSOLE
    PRINT "Parameters reset to defaults"
    _DEST 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying adjustment method:"; adjustmentMethod + 1; "(" + GetMethodName$(adjustmentMethod) + ")"
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    SELECT CASE adjustmentMethod
        CASE 0 ' Basic adjustments - Brightness and Contrast
            CALL ApplyBrightness(adjustedImage, CINT(parameters(0)))
            CALL ApplyContrast(adjustedImage, CINT(parameters(1)))
        CASE 1 ' Gamma correction
            CALL ApplyGamma(adjustedImage, (parameters(0) / 100.0))
        CASE 2 ' Color balance
            CALL ApplyColorBalance(adjustedImage, CINT(parameters(0)), CINT(parameters(1)), CINT(parameters(2)))
        CASE 3 ' Hue/Saturation
            CALL ApplyHueSaturation(adjustedImage, CINT(parameters(0)), parameters(1) / 100.0)
        CASE 4 ' Levels
            CALL ApplyLevels(adjustedImage, 0, 255, CINT(parameters(0)), 255 + CINT(parameters(1)))
        CASE 5 ' Curves - S-curve (no parameters)
            CALL ApplyCurves(adjustedImage, 0)
        CASE 6 ' Threshold
            CALL ApplyThreshold(adjustedImage, 128 + CINT(parameters(0)), 0)
        CASE 7 ' Invert (no parameters)
            CALL ApplyInvert(adjustedImage)
        CASE 8 ' Sepia (no parameters)
            CALL ApplySepia(adjustedImage)
        CASE 9 ' Desaturate (grayscale) (no parameters)
            CALL ApplyDesaturate(adjustedImage, 0)
        CASE 10 ' Posterize
            IF parameters(0) >= 2 THEN
                ' Use true color quantization to specific number of colors
                CALL ApplyColorQuantization(adjustedImage, originalImage, CINT(parameters(0)))
            END IF
        CASE 11 ' Colorize
            CALL ApplyColorize(adjustedImage, CINT(parameters(0)), parameters(1) / 100.0)
        CASE 12 ' Vignette
            CALL ApplyVignette(adjustedImage, parameters(0) / 100.0)
        CASE 13 ' Film grain
            CALL ApplyFilmGrain(adjustedImage, CINT(parameters(0)))
        CASE 14 ' Retro effect
            CALL ApplyRetroEffect(adjustedImage, CINT(parameters(0)) MOD 4)
        CASE 15 ' Blur effect
            CALL ApplyBlurEffect(adjustedImage, CINT(parameters(0)))
        CASE 16 ' Pixelate effect
            CALL ApplyPixelateEffect(adjustedImage, CINT(parameters(0)))
        CASE 17 ' Glow effect
            CALL ApplyGlowEffect(adjustedImage, CINT(parameters(0)), CINT(parameters(1)))
    END SELECT
    
    _DEST _CONSOLE
    PRINT "Adjustments complete"
    _DEST 0
END SUB

FUNCTION GetMethodCount%
    GetMethodCount% = 18
END FUNCTION

SUB SetupMethodParameters (method AS INTEGER)
    SELECT CASE method
        CASE 0 ' Basic (Brightness/Contrast) - uses parameters(0) and parameters(1)
            parameterCount = 2
            parameterNames(0) = "Brightness"
            parameterMins(0) = -255
            parameterMaxs(0) = 255
            parameterSteps(0) = 5
            parameterNames(1) = "Contrast"
            parameterMins(1) = -100
            parameterMaxs(1) = 100
            parameterSteps(1) = 5
        CASE 1 ' Gamma Correction - uses parameters(2)
            parameterCount = 1
            parameterNames(0) = "Gamma"
            parameterMins(0) = 10
            parameterMaxs(0) = 300
            parameterSteps(0) = 10
        CASE 2 ' Color Balance - uses parameters(0), parameters(1), parameters(4)
            parameterCount = 3
            parameterNames(0) = "Red-Cyan"
            parameterMins(0) = -100
            parameterMaxs(0) = 100
            parameterSteps(0) = 5
            parameterNames(1) = "Green-Magenta"
            parameterMins(1) = -100
            parameterMaxs(1) = 100
            parameterSteps(1) = 5
            parameterNames(2) = "Blue-Yellow"
            parameterMins(2) = -100
            parameterMaxs(2) = 100
            parameterSteps(2) = 5
        CASE 3 ' Hue/Saturation - uses parameters(4) and parameters(3)
            parameterCount = 2
            parameterNames(0) = "Hue Shift"
            parameterMins(0) = -180
            parameterMaxs(0) = 180
            parameterSteps(0) = 10
            parameterNames(1) = "Saturation"
            parameterMins(1) = 0
            parameterMaxs(1) = 200
            parameterSteps(1) = 10
        CASE 4 ' Levels Adjustment - uses parameters(0) and parameters(1)
            parameterCount = 2
            parameterNames(0) = "Shadow Input"
            parameterMins(0) = -50
            parameterMaxs(0) = 50
            parameterSteps(0) = 5
            parameterNames(1) = "Highlight Input"
            parameterMins(1) = -50
            parameterMaxs(1) = 50
            parameterSteps(1) = 5
        CASE 5 ' Curves (S-Curve) - no parameters (hardcoded)
            parameterCount = 0
        CASE 6 ' Threshold - uses parameters(0)
            parameterCount = 1
            parameterNames(0) = "Threshold"
            parameterMins(0) = -100
            parameterMaxs(0) = 100
            parameterSteps(0) = 5
        CASE 7 ' Invert Colors - no parameters
            parameterCount = 0
        CASE 8 ' Sepia Tone - no parameters
            parameterCount = 0
        CASE 9 ' Desaturate (Grayscale) - no parameters
            parameterCount = 0
        CASE 10 ' Posterize - uses parameters(0)
            parameterCount = 1
            parameterNames(0) = "Total Colors"
            parameterMins(0) = 2
            parameterMaxs(0) = 256
            parameterSteps(0) = 1
        CASE 11 ' Colorize - uses parameters(4) and parameters(3)
            parameterCount = 2
            parameterNames(0) = "Hue"
            parameterMins(0) = 0
            parameterMaxs(0) = 360
            parameterSteps(0) = 10
            parameterNames(1) = "Saturation"
            parameterMins(1) = 0
            parameterMaxs(1) = 200
            parameterSteps(1) = 10
        CASE 12 ' Vignette Effect - uses parameters(2)
            parameterCount = 1
            parameterNames(0) = "Strength"
            parameterMins(0) = 0
            parameterMaxs(0) = 100
            parameterSteps(0) = 5
        CASE 13 ' Film Grain - uses parameters(0)
            parameterCount = 1
            parameterNames(0) = "Intensity"
            parameterMins(0) = 0
            parameterMaxs(0) = 100
            parameterSteps(0) = 5
        CASE 14 ' Retro Effects - uses parameters(0)
            parameterCount = 1
            parameterNames(0) = "Effect Type"
            parameterMins(0) = 0
            parameterMaxs(0) = 3
            parameterSteps(0) = 1
        CASE 15 ' Blur Effect
            parameterCount = 1
            parameterNames(0) = "Blur Radius"
            parameterMins(0) = 1
            parameterMaxs(0) = 15
            parameterSteps(0) = 1
        CASE 16 ' Pixelate Effect
            parameterCount = 1
            parameterNames(0) = "Pixel Size"
            parameterMins(0) = 1
            parameterMaxs(0) = 100
            parameterSteps(0) = 1
        CASE 17 ' Glow Effect
            parameterCount = 2
            parameterNames(0) = "Glow Radius"
            parameterMins(0) = 1
            parameterMaxs(0) = 10
            parameterSteps(0) = 1
            parameterNames(1) = "Glow Intensity"
            parameterMins(1) = 10
            parameterMaxs(1) = 100
            parameterSteps(1) = 5
        CASE ELSE
            parameterCount = 0
    END SELECT
    
    ' Reset parameter index if it's out of bounds
    IF parameterIndex >= parameterCount THEN parameterIndex = 0
END SUB

FUNCTION GetMethodName$(method AS INTEGER)
    SELECT CASE method
        CASE 0
            GetMethodName$ = "Basic (Brightness/Contrast)"
        CASE 1
            GetMethodName$ = "Gamma Correction"
        CASE 2
            GetMethodName$ = "Color Balance"
        CASE 3
            GetMethodName$ = "Hue/Saturation"
        CASE 4
            GetMethodName$ = "Levels Adjustment"
        CASE 5
            GetMethodName$ = "Curves (S-Curve)"
        CASE 6
            GetMethodName$ = "Threshold"
        CASE 7
            GetMethodName$ = "Invert Colors"
        CASE 8
            GetMethodName$ = "Sepia Tone"
        CASE 9
            GetMethodName$ = "Desaturate (Grayscale)"
        CASE 10
            GetMethodName$ = "Posterize"
        CASE 11
            GetMethodName$ = "Colorize"
        CASE 12
            GetMethodName$ = "Vignette Effect"
        CASE 13
            GetMethodName$ = "Film Grain"
        CASE 14
            GetMethodName$ = "Retro Effects"
        CASE 15
            GetMethodName$ = "Blur Effect"
        CASE 16
            GetMethodName$ = "Pixelate Effect"
        CASE 17
            GetMethodName$ = "Glow Effect"
        CASE ELSE
            GetMethodName$ = "Unknown Method"
    END SELECT
END FUNCTION

FUNCTION GetMethodInfo$(method AS INTEGER)
    SELECT CASE method
        CASE 0
            GetMethodInfo$ = "Basic brightness and contrast adjustments." + CHR$(10) + "Brightness adds/subtracts from all channels." + CHR$(10) + "Contrast expands/compresses the tonal range."
        CASE 1
            GetMethodInfo$ = "Gamma correction for display calibration." + CHR$(10) + "Values < 1.0 brighten midtones." + CHR$(10) + "Values > 1.0 darken midtones."
        CASE 2
            GetMethodInfo$ = "Independent RGB channel adjustment." + CHR$(10) + "Corrects color casts and white balance." + CHR$(10) + "Useful for temperature correction."
        CASE 3
            GetMethodInfo$ = "HSV-based hue and saturation control." + CHR$(10) + "Hue shift rotates colors around wheel." + CHR$(10) + "Saturation controls color intensity."
        CASE 4
            GetMethodInfo$ = "Input and output level mapping." + CHR$(10) + "Adjusts black/white points." + CHR$(10) + "Professional exposure correction."
        CASE 5
            GetMethodInfo$ = "S-curve for contrast enhancement." + CHR$(10) + "Increases midtone contrast." + CHR$(10) + "Popular in digital photography."
        CASE 6
            GetMethodInfo$ = "Binary threshold conversion." + CHR$(10) + "Converts to pure black/white." + CHR$(10) + "Useful for line art and logos."
        CASE 7
            GetMethodInfo$ = "Color inversion (negative effect)." + CHR$(10) + "Subtracts each channel from 255." + CHR$(10) + "Creates film negative look."
        CASE 8
            GetMethodInfo$ = "Vintage sepia tone effect." + CHR$(10) + "Converts to warm brown monochrome." + CHR$(10) + "Classic photography style."
        CASE 9
            GetMethodInfo$ = "Grayscale conversion methods." + CHR$(10) + "Removes color information." + CHR$(10) + "Preserves luminance values."
        CASE 10
            GetMethodInfo$ = "Reduces colors to specific levels." + CHR$(10) + "Creates banded, artistic effect." + CHR$(10) + "Popular in pop art and comics."
        CASE 11
            GetMethodInfo$ = "Applies single hue to grayscale." + CHR$(10) + "Creates tinted monochrome effect." + CHR$(10) + "Useful for mood and atmosphere."
        CASE 12
            GetMethodInfo$ = "Darkens image edges gradually." + CHR$(10) + "Creates lens vignetting effect." + CHR$(10) + "Draws focus to image center."
        CASE 13
            GetMethodInfo$ = "Adds realistic film grain texture." + CHR$(10) + "Simulates analog photography." + CHR$(10) + "Creates organic, vintage feel."
        CASE 14
            GetMethodInfo$ = "Various retro/vintage effects." + CHR$(10) + "Simulates different eras of photography." + CHR$(10) + "Includes fading, color shifts, etc."
        CASE ELSE
            GetMethodInfo$ = "No information available."
    END SELECT
END FUNCTION

' Advanced adjustment functions
SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM invGamma AS SINGLE
    invGamma = 1.0 / gamma
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
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
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c) + redShift
            g = _GREEN32(c) + greenShift
            b = _BLUE32(c) + blueShift
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyHueSaturation (img AS LONG, hueShift AS INTEGER, saturation AS SINGLE)
    DIM w AS LONG, imgHeight AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM hue AS SINGLE, sat AS SINGLE, value AS SINGLE
    
    w = _WIDTH(img): imgHeight = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO imgHeight - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Convert RGB to HSV
            CALL RGBtoHSV(r, g, b, hue, sat, value)
            
            ' Adjust hue and saturation
            hue = hue + hueShift
            IF hue < 0 THEN hue = hue + 360
            IF hue >= 360 THEN hue = hue - 360
            sat = sat * saturation
            IF sat > 1 THEN sat = 1
            IF sat < 0 THEN sat = 0
            
            ' Convert back to RGB
            CALL HSVtoRGB(hue, sat, value, r, g, b)
            
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyLevels (img AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM inputRange AS SINGLE, outputRange AS SINGLE
    
    inputRange = inputMax - inputMin
    outputRange = outputMax - outputMin
    IF inputRange <= 0 THEN inputRange = 1
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = CINT(outputMin + ((_RED32(c) - inputMin) / inputRange) * outputRange)
            g = CINT(outputMin + ((_GREEN32(c) - inputMin) / inputRange) * outputRange)
            b = CINT(outputMin + ((_BLUE32(c) - inputMin) / inputRange) * outputRange)
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyCurves (img AS LONG, curveType AS INTEGER)
    ' S-curve for contrast enhancement
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM curve AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Apply S-curve using sine function
            curve = (SIN((_RED32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            r = CINT(curve * 255)
            curve = (SIN((_GREEN32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            g = CINT(curve * 255)
            curve = (SIN((_BLUE32(c) / 255.0 - 0.5) * _PI) + 1) / 2
            b = CINT(curve * 255)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyThreshold (img AS LONG, threshold AS INTEGER, mode AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            gray = (_RED32(c) + _GREEN32(c) + _BLUE32(c)) \ 3
            IF gray > threshold THEN
                PSET (x, y), _RGB32(255, 255, 255)
            ELSE
                PSET (x, y), _RGB32(0, 0, 0)
            END IF
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyInvert (img AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            r = 255 - _RED32(c)
            g = 255 - _GREEN32(c)
            b = 255 - _BLUE32(c)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplySepia (img AS LONG)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Standard sepia conversion
            r = CINT(_RED32(c) * 0.393 + _GREEN32(c) * 0.769 + _BLUE32(c) * 0.189)
            g = CINT(_RED32(c) * 0.349 + _GREEN32(c) * 0.686 + _BLUE32(c) * 0.168)
            b = CINT(_RED32(c) * 0.272 + _GREEN32(c) * 0.534 + _BLUE32(c) * 0.131)
            IF r > 255 THEN r = 255
            IF g > 255 THEN g = 255
            IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM gray AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            ' Luminance-based grayscale
            gray = CINT(_RED32(c) * 0.299 + _GREEN32(c) * 0.587 + _BLUE32(c) * 0.114)
            PSET (x, y), _RGB32(gray, gray, gray)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyColorize (img AS LONG, hue AS INTEGER, saturation AS SINGLE)
    ' First desaturate, then apply color
    CALL ApplyDesaturate(img, 0)
    
    DIM w AS LONG, imgHeight AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER, gray AS INTEGER
    DIM hueVal AS SINGLE, satVal AS SINGLE, valueVal AS SINGLE
    
    w = _WIDTH(img): imgHeight = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO imgHeight - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            gray = _RED32(c) ' Already grayscale
            
            ' Convert to HSV and apply color
            hueVal = hue
            satVal = saturation
            valueVal = gray / 255.0
            
            CALL HSVtoRGB(hueVal, satVal, valueVal, r, g, b)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyVignette (img AS LONG, strength AS SINGLE)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM centerX AS SINGLE, centerY AS SINGLE, maxDist AS SINGLE, dist AS SINGLE, factor AS SINGLE
    
    w = _WIDTH(img): h = _HEIGHT(img)
    centerX = w / 2: centerY = h / 2
    maxDist = SQR(centerX * centerX + centerY * centerY)
    
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            dist = SQR((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY))
            factor = 1.0 - (dist / maxDist) * strength
            IF factor < 0 THEN factor = 0
            
            r = CINT(_RED32(c) * factor)
            g = CINT(_GREEN32(c) * factor)
            b = CINT(_BLUE32(c) * factor)
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyFilmGrain (img AS LONG, amount AS INTEGER)
    DIM w AS LONG, h AS LONG, x AS LONG, y AS LONG, c AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER, noise AS INTEGER
    
    w = _WIDTH(img): h = _HEIGHT(img)
    DIM old AS LONG: old = _SOURCE: _SOURCE img
    DIM oldW AS LONG: oldW = _DEST: _DEST img
    
    RANDOMIZE TIMER
    
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            c = POINT(x, y)
            noise = (RND * amount * 2) - amount
            r = _RED32(c) + noise
            g = _GREEN32(c) + noise
            b = _BLUE32(c) + noise
            IF r < 0 THEN r = 0 ELSE IF r > 255 THEN r = 255
            IF g < 0 THEN g = 0 ELSE IF g > 255 THEN g = 255
            IF b < 0 THEN b = 0 ELSE IF b > 255 THEN b = 255
            PSET (x, y), _RGB32(r, g, b)
        NEXT
    NEXT
    _SOURCE old: _DEST oldW
END SUB

SUB ApplyRetroEffect (img AS LONG, effectType AS INTEGER)
    SELECT CASE effectType
        CASE 0 ' Vintage fade
            CALL ApplyBrightness(img, 20)
            CALL ApplyContrast(img, -20)
            CALL ApplyColorBalance(img, 15, 5, -10)
        CASE 1 ' Warm nostalgic
            CALL ApplyColorBalance(img, 20, 10, -15)
            CALL ApplyGamma(img, 1.2)
        CASE 2 ' Cool retro
            CALL ApplyColorBalance(img, -10, 0, 20)
            CALL ApplyContrast(img, 15)
        CASE 3 ' High contrast vintage
            CALL ApplyContrast(img, 40)
            CALL ApplyPosterize(img, 8)
    END SELECT
END SUB

' Helper functions for HSV conversion
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

' Blur Effect - Applies a box blur with specified radius
SUB ApplyBlurEffect (img AS LONG, radius AS INTEGER)
    DIM tempImg AS LONG
    DIM x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG, count AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    tempImg = _COPYIMAGE(img, 32)
    _SOURCE tempImg
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sample surrounding pixels
            FOR dy = -radius TO radius
                FOR dx = -radius TO radius
                    IF x + dx >= 0 AND x + dx < _WIDTH(img) AND y + dy >= 0 AND y + dy < _HEIGHT(img) THEN
                        c = POINT(x + dx, y + dy)
                        r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
                        totalR = totalR + r
                        totalG = totalG + g
                        totalB = totalB + b
                        count = count + 1
                    END IF
                NEXT dx
            NEXT dy
            
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                PSET (x, y), _RGB32(r, g, b)
            END IF
        NEXT x
    NEXT y
    
    _FREEIMAGE tempImg
    _SOURCE oldSource
    _DEST oldDest
END SUB

' Pixelate Effect - Creates pixelated look with specified pixel size
SUB ApplyPixelateEffect (img AS LONG, pixelSize AS INTEGER)
    DIM x AS INTEGER, y AS INTEGER, px AS INTEGER, py AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG, count AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    _SOURCE img
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1 STEP pixelSize
        FOR x = 0 TO _WIDTH(img) - 1 STEP pixelSize
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            ' Sample the pixel block
            FOR py = y TO y + pixelSize - 1
                FOR px = x TO x + pixelSize - 1
                    IF px < _WIDTH(img) AND py < _HEIGHT(img) THEN
                        c = POINT(px, py)
                        r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
                        totalR = totalR + r
                        totalG = totalG + g
                        totalB = totalB + b
                        count = count + 1
                    END IF
                NEXT px
            NEXT py
            
            ' Calculate average color
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                
                ' Fill the entire pixel block with the average color
                FOR py = y TO y + pixelSize - 1
                    FOR px = x TO x + pixelSize - 1
                        IF px < _WIDTH(img) AND py < _HEIGHT(img) THEN
                            PSET (px, py), _RGB32(r, g, b)
                        END IF
                    NEXT px
                NEXT py
            END IF
        NEXT x
    NEXT y
    
    _SOURCE oldSource
    _DEST oldDest
END SUB

' Glow Effect - Adds a soft glow around bright areas
SUB ApplyGlowEffect (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)
    DIM tempImg AS LONG, glowImg AS LONG
    DIM x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM brightness AS SINGLE, glowAmount AS SINGLE
    DIM c AS _UNSIGNED LONG, gc AS _UNSIGNED LONG
    DIM gr AS INTEGER, gg AS INTEGER, gb AS INTEGER
    DIM finalR AS INTEGER, finalG AS INTEGER, finalB AS INTEGER
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    tempImg = _COPYIMAGE(img, 32)
    glowImg = _NEWIMAGE(_WIDTH(img), _HEIGHT(img), 32)
    
    ' First pass: Create glow map from bright areas
    _SOURCE tempImg
    _DEST glowImg
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Calculate brightness
            brightness = (r + g + b) / (3 * 255.0)
            
            ' Only bright areas contribute to glow
            IF brightness > 0.7 THEN
                glowAmount = (brightness - 0.7) / 0.3 ' Scale from 0.7-1.0 to 0.0-1.0
                gr = CINT(r * glowAmount)
                gg = CINT(g * glowAmount)
                gb = CINT(b * glowAmount)
                PSET (x, y), _RGB32(gr, gg, gb)
            ELSE
                PSET (x, y), _RGB32(0, 0, 0)
            END IF
        NEXT x
    NEXT y
    
    ' Second pass: Blur the glow map
    CALL ApplyBlurToImage(glowImg, glowRadius)
    
    ' Third pass: Combine original with glow
    _SOURCE tempImg
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            ' Get original pixel
            c = POINT(x, y)
            r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
            
            ' Get glow pixel
            _SOURCE glowImg
            gc = POINT(x, y)
            _SOURCE tempImg
            gr = _RED32(gc): gg = _GREEN32(gc): gb = _BLUE32(gc)
            
            ' Combine with intensity scaling
            finalR = r + CINT(gr * intensity / 100.0)
            finalG = g + CINT(gg * intensity / 100.0)
            finalB = b + CINT(gb * intensity / 100.0)
            
            ' Clamp values
            IF finalR > 255 THEN finalR = 255
            IF finalG > 255 THEN finalG = 255
            IF finalB > 255 THEN finalB = 255
            
            PSET (x, y), _RGB32(finalR, finalG, finalB)
        NEXT x
    NEXT y
    
    _FREEIMAGE tempImg
    _FREEIMAGE glowImg
    _SOURCE oldSource
    _DEST oldDest
END SUB

' Helper function for glow effect blur
SUB ApplyBlurToImage (img AS LONG, radius AS INTEGER)
    DIM tempImg AS LONG
    DIM x AS INTEGER, y AS INTEGER, dx AS INTEGER, dy AS INTEGER
    DIM totalR AS LONG, totalG AS LONG, totalB AS LONG, count AS INTEGER
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM oldSource AS LONG, oldDest AS LONG
    
    oldSource = _SOURCE
    oldDest = _DEST
    
    tempImg = _COPYIMAGE(img, 32)
    _SOURCE tempImg
    _DEST img
    
    FOR y = 0 TO _HEIGHT(img) - 1
        FOR x = 0 TO _WIDTH(img) - 1
            totalR = 0: totalG = 0: totalB = 0: count = 0
            
            FOR dy = -radius TO radius
                FOR dx = -radius TO radius
                    IF x + dx >= 0 AND x + dx < _WIDTH(img) AND y + dy >= 0 AND y + dy < _HEIGHT(img) THEN
                        c = POINT(x + dx, y + dy)
                        r = _RED32(c): g = _GREEN32(c): b = _BLUE32(c)
                        totalR = totalR + r
                        totalG = totalG + g
                        totalB = totalB + b
                        count = count + 1
                    END IF
                NEXT dx
            NEXT dy
            
            IF count > 0 THEN
                r = totalR \ count
                g = totalG \ count
                b = totalB \ count
                PSET (x, y), _RGB32(r, g, b)
            END IF
        NEXT x
    NEXT y
    
    _FREEIMAGE tempImg
    _SOURCE oldSource
    _DEST oldDest
END SUB
