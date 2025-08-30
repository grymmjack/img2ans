' Clean Brightness Test - Using new IMGADJ API
$CONSOLE
_CONSOLE ON

'$INCLUDE:'../core/adjustment_common.bi'

PRINT "Clean Brightness Test - Loading image..."

' Setup graphics screen
SCREEN _NEWIMAGE(600, 400, 32)
_TITLE "Clean Brightness Test - Press +/- to adjust, ESC to exit"

' Load test image using the new API
DIM sourceImage AS LONG, workingImage AS LONG
sourceImage = IMGADJ_LoadTestImage&("simple")

DIM brightness AS INTEGER
brightness = 0

PRINT "Controls:"
PRINT "  + = increase brightness"
PRINT "  - = decrease brightness" 
PRINT "  R = reset to original"
PRINT "  ESC = exit"
PRINT "Switch to graphics window!"

DO
    ' Apply brightness adjustment using clean API
    IF workingImage <> 0 THEN _FREEIMAGE workingImage
    
    IF brightness <> 0 THEN
        IF brightness > 0 THEN
            workingImage = IMGADJ_Brightness&(sourceImage, "+", brightness)
        ELSE
            workingImage = IMGADJ_Brightness&(sourceImage, "-", ABS(brightness))
        END IF
    ELSE
        workingImage = _COPYIMAGE(sourceImage, 32)
    END IF
    
    ' Show comparison using clean API
    CALL IMGADJ_ShowComparison(sourceImage, workingImage, "Clean Brightness Test - Brightness: " + STR$(brightness))
    
    ' Handle input
    k$ = INKEY$
    IF k$ <> "" THEN
        SELECT CASE k$
            CASE "+"
                brightness = brightness + 10
                IF brightness > 255 THEN brightness = 255
            CASE "-"
                brightness = brightness - 10
                IF brightness < -255 THEN brightness = -255
            CASE "r", "R"
                brightness = 0
            CASE CHR$(27) ' ESC
                EXIT DO
        END SELECT
    END IF
    
    _LIMIT 30
LOOP

' Cleanup
_FREEIMAGE sourceImage
IF workingImage <> 0 THEN _FREEIMAGE workingImage
PRINT "Program ended."
SYSTEM

'$INCLUDE:'../core/adjustment_common.bas'
