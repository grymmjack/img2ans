' Ultra-Clean API Demo - Minimal brightness adjustment example
'$INCLUDE:'../core/adjustment_common.bi'

SCREEN _NEWIMAGE(600, 400, 32)
_TITLE "Ultra-Clean API Demo"

' Load image and apply adjustments with one-liner calls
DIM myImage AS LONG, adjusted AS LONG

myImage = IMGADJ_LoadTestImage&("simple")

' Ultra-clean API calls - exactly what you wanted!
adjusted = IMGADJ_Brightness&(myImage, "+", 50)
CALL IMGADJ_ShowComparison(myImage, adjusted, "Brightness +50")

SLEEP 2

_FREEIMAGE adjusted
adjusted = IMGADJ_Brightness&(myImage, "-", 30) 
CALL IMGADJ_ShowComparison(myImage, adjusted, "Brightness -30")

SLEEP 2

_FREEIMAGE adjusted
adjusted = IMGADJ_Contrast&(myImage, "+", 25)
CALL IMGADJ_ShowComparison(myImage, adjusted, "Contrast +25")

SLEEP 2

_FREEIMAGE adjusted
adjusted = IMGADJ_Gamma&(myImage, "+", 30)
CALL IMGADJ_ShowComparison(myImage, adjusted, "Gamma +30 (1.3)")

SLEEP 2

_FREEIMAGE adjusted
adjusted = IMGADJ_Saturation&(myImage, "+", 50)
CALL IMGADJ_ShowComparison(myImage, adjusted, "Saturation +50%")

SLEEP 2

' Chain multiple adjustments
_FREEIMAGE adjusted
adjusted = IMGADJ_Brightness&(myImage, "+", 20)
DIM temp AS LONG
temp = adjusted
adjusted = IMGADJ_Contrast&(temp, "+", 15)
_FREEIMAGE temp
CALL IMGADJ_ShowComparison(myImage, adjusted, "Brightness +20 + Contrast +15")

PRINT "Press any key to exit..."
SLEEP

_FREEIMAGE myImage
_FREEIMAGE adjusted
SYSTEM

'$INCLUDE:'../core/adjustment_common.bas'
