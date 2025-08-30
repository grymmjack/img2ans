' Common declarations for image adjustment algorithms
' Include this in all adjustment test files

' Common constants
CONST SCREEN_W = 1400
CONST SCREEN_H = 900

' Common shared variables for parameters
DIM SHARED originalImage AS LONG
DIM SHARED adjustedImage AS LONG
DIM SHARED parameterIndex AS INTEGER
DIM SHARED parameters(0 TO 4) AS SINGLE
DIM SHARED parameterNames(0 TO 4) AS STRING
DIM SHARED parameterCount AS INTEGER
DIM SHARED parameterMins(0 TO 4) AS SINGLE
DIM SHARED parameterMaxs(0 TO 4) AS SINGLE
DIM SHARED parameterSteps(0 TO 4) AS SINGLE

' Forward declarations
DECLARE SUB CreateComplexTestImage ()
DECLARE SUB DrawUI (algorithmName AS STRING, algorithmInfo AS STRING)
DECLARE SUB HandleInput ()
DECLARE SUB DrawParameterControls (x AS INTEGER, y AS INTEGER)
DECLARE SUB DrawAlgorithmInfo (x AS INTEGER, y AS INTEGER, info AS STRING)
DECLARE SUB AdjustParameter (index AS INTEGER, direction AS INTEGER)
DECLARE SUB ResetParameters ()
DECLARE SUB InitializeGraphics (title AS STRING)

' HSV color conversion helpers
DECLARE SUB RGBtoHSV (r AS INTEGER, g AS INTEGER, b AS INTEGER, hue AS SINGLE, sat AS SINGLE, value AS SINGLE)
DECLARE SUB HSVtoRGB (hue AS SINGLE, sat AS SINGLE, value AS SINGLE, r AS INTEGER, g AS INTEGER, b AS INTEGER)

' Clean Image Adjustment API
DECLARE FUNCTION IMGADJ_Brightness& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
DECLARE FUNCTION IMGADJ_Contrast& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
DECLARE FUNCTION IMGADJ_Gamma& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
DECLARE FUNCTION IMGADJ_Saturation& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)
DECLARE FUNCTION IMGADJ_Hue& (sourceImg AS LONG, direction AS STRING, amount AS INTEGER)

' Utility functions
DECLARE FUNCTION IMGADJ_LoadTestImage& (imageType AS STRING)
DECLARE SUB IMGADJ_ShowComparison (originalImg AS LONG, adjustedImg AS LONG, title AS STRING)
