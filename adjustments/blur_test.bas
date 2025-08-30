' Blur Effect Test
' Standalone test for blur effect algorithm
$CONSOLE
_CONSOLE ON
PRINT "Blur Effect Test Starting..."

' Include our common framework
'$INCLUDE:'../core/adjustment_common.bi'

' Algorithm-specific forward declarations
DECLARE SUB ApplyBlurEffect (img AS LONG, radius AS INTEGER)
DECLARE SUB ApplyAdjustments ()
DECLARE SUB SetupParameters ()

PRINT "Initializing..."
parameterIndex = 0
originalImage = 0
adjustedImage = 0

PRINT "Setting up algorithm parameters..."
CALL SetupParameters

PRINT "Creating test image..."
CALL CreateComplexTestImage

PRINT "Initializing graphics..."
CALL InitializeGraphics("Blur Effect Test - +/-: adjust, R: reset, ESC: exit")

PRINT "Graphics screen created successfully!"
PRINT "Starting main loop - switch to graphics window!"
PRINT "Controls:"
PRINT "  +/- = adjust blur radius"
PRINT "  R = reset parameters"
PRINT "  ESC = exit"

' Apply initial adjustments
CALL ApplyAdjustments

DO
    _DEST 0 ' Graphics screen
    CLS
    CALL DrawUI("Blur Effect", "Applies a box blur with specified radius." + CHR$(10) + "Softens edges and reduces detail." + CHR$(10) + "Useful for depth of field effects." + CHR$(10) + "Range: 1-15 pixel radius")
    
    ' Store old parameter value to detect changes
    DIM oldRadius AS SINGLE
    oldRadius = parameters(0)
    
    CALL HandleInput
    
    ' Reapply adjustments if parameter changed
    IF parameters(0) <> oldRadius THEN
        CALL ApplyAdjustments
    END IF
    
    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYDOWN(27)

PRINT "Cleaning up..."
IF originalImage <> 0 THEN _FREEIMAGE originalImage
IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
PRINT "Program ended."
SYSTEM

SUB SetupParameters
    ' Setup blur parameter
    parameterCount = 1
    
    ' Blur radius parameter
    parameterNames(0) = "Blur Radius"
    parameterMins(0) = 1
    parameterMaxs(0) = 15
    parameterSteps(0) = 1
    parameters(0) = 3  ' Default to 3 pixel radius
    
    parameterIndex = 0
END SUB

SUB ApplyAdjustments
    _DEST _CONSOLE
    PRINT "Applying blur: radius="; parameters(0)
    _DEST 0
    
    IF originalImage = 0 THEN 
        _DEST _CONSOLE
        PRINT "No original image!"
        _DEST 0
        EXIT SUB
    END IF
    
    IF adjustedImage <> 0 THEN _FREEIMAGE adjustedImage
    adjustedImage = _COPYIMAGE(originalImage, 32)
    
    ' Apply blur effect
    CALL ApplyBlurEffect(adjustedImage, CINT(parameters(0)))
    
    _DEST _CONSOLE
    PRINT "Blur complete"
    _DEST 0
END SUB

' Optimized Blur Effect - Uses reduced sampling for better performance
SUB ApplyBlurEffect (img AS LONG, radius AS INTEGER)
    DIM tempImg AS LONG
    DIM bx AS INTEGER, by AS INTEGER, bdx AS INTEGER, bdy AS INTEGER
    DIM btotalR AS LONG, btotalG AS LONG, btotalB AS LONG, bcount AS INTEGER
    DIM br AS INTEGER, bg AS INTEGER, bb AS INTEGER
    DIM bc AS _UNSIGNED LONG
    DIM boldSource AS LONG, boldDest AS LONG
    DIM bw AS INTEGER, bh AS INTEGER
    DIM bstep AS INTEGER
    
    IF radius <= 0 THEN EXIT SUB
    
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

'$INCLUDE:'../core/adjustment_common.bas'
