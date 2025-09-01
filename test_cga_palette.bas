''
' TEST CGA PALETTE - Display the CGA palette for verification
'
' This program displays the exact 16-color CGA palette that matches
' the PowerShell script and QB64PE CGA remap program.
'
' @author grymmjack
' @version 1.0
''

$CONSOLE

' CGA 16-color palette (exact order 0..15)
TYPE CGA_COLOR
    r AS INTEGER
    g AS INTEGER  
    b AS INTEGER
END TYPE

DIM CGA_PALETTE(0 TO 15) AS CGA_COLOR

' Initialize CGA palette (exact same as in tile_extractor)
CGA_PALETTE(0).r = 0:   CGA_PALETTE(0).g = 0:   CGA_PALETTE(0).b = 0     ' Black
CGA_PALETTE(1).r = 0:   CGA_PALETTE(1).g = 0:   CGA_PALETTE(1).b = 170   ' Blue  
CGA_PALETTE(2).r = 0:   CGA_PALETTE(2).g = 170: CGA_PALETTE(2).b = 0     ' Green
CGA_PALETTE(3).r = 0:   CGA_PALETTE(3).g = 170: CGA_PALETTE(3).b = 170   ' Cyan
CGA_PALETTE(4).r = 170: CGA_PALETTE(4).g = 0:   CGA_PALETTE(4).b = 0     ' Red
CGA_PALETTE(5).r = 170: CGA_PALETTE(5).g = 0:   CGA_PALETTE(5).b = 170   ' Magenta
CGA_PALETTE(6).r = 170: CGA_PALETTE(6).g = 85:  CGA_PALETTE(6).b = 0     ' Brown
CGA_PALETTE(7).r = 170: CGA_PALETTE(7).g = 170: CGA_PALETTE(7).b = 170   ' Light Gray
CGA_PALETTE(8).r = 85:  CGA_PALETTE(8).g = 85:  CGA_PALETTE(8).b = 85    ' Dark Gray
CGA_PALETTE(9).r = 85:  CGA_PALETTE(9).g = 85:  CGA_PALETTE(9).b = 255   ' Light Blue
CGA_PALETTE(10).r = 85: CGA_PALETTE(10).g = 255: CGA_PALETTE(10).b = 85  ' Light Green
CGA_PALETTE(11).r = 85: CGA_PALETTE(11).g = 255: CGA_PALETTE(11).b = 255 ' Light Cyan
CGA_PALETTE(12).r = 255: CGA_PALETTE(12).g = 85: CGA_PALETTE(12).b = 85  ' Light Red
CGA_PALETTE(13).r = 255: CGA_PALETTE(13).g = 85: CGA_PALETTE(13).b = 255 ' Light Magenta
CGA_PALETTE(14).r = 255: CGA_PALETTE(14).g = 255: CGA_PALETTE(14).b = 85 ' Yellow
CGA_PALETTE(15).r = 255: CGA_PALETTE(15).g = 255: CGA_PALETTE(15).b = 255 ' White

_ECHO "=== CGA 16-COLOR PALETTE TEST ==="
_ECHO ""
_ECHO "Index  RGB Values     Hex       Color Name"
_ECHO "-----  -----------    ------    -----------"

DIM i AS INTEGER
DIM hexR AS STRING, hexG AS STRING, hexB AS STRING

FOR i = 0 TO 15
    ' Convert to hex
    hexR = HEX$(CGA_PALETTE(i).r)
    hexG = HEX$(CGA_PALETTE(i).g)
    hexB = HEX$(CGA_PALETTE(i).b)
    
    ' Pad hex values
    IF LEN(hexR) = 1 THEN hexR = "0" + hexR
    IF LEN(hexG) = 1 THEN hexG = "0" + hexG
    IF LEN(hexB) = 1 THEN hexB = "0" + hexB
    
    DIM colorName AS STRING
    SELECT CASE i
        CASE 0: colorName = "Black"
        CASE 1: colorName = "Blue"
        CASE 2: colorName = "Green" 
        CASE 3: colorName = "Cyan"
        CASE 4: colorName = "Red"
        CASE 5: colorName = "Magenta"
        CASE 6: colorName = "Brown"
        CASE 7: colorName = "Light Gray"
        CASE 8: colorName = "Dark Gray"
        CASE 9: colorName = "Light Blue"
        CASE 10: colorName = "Light Green"
        CASE 11: colorName = "Light Cyan"
        CASE 12: colorName = "Light Red"
        CASE 13: colorName = "Light Magenta"
        CASE 14: colorName = "Yellow"
        CASE 15: colorName = "White"
    END SELECT
    
    DIM indexStr AS STRING
    indexStr = STR$(i)
    IF LEN(indexStr) = 2 THEN indexStr = " " + indexStr
    IF LEN(indexStr) = 3 THEN indexStr = indexStr
    
    DIM rgbStr AS STRING
    DIM rStr AS STRING, gStr AS STRING, bStr AS STRING
    rStr = STR$(CGA_PALETTE(i).r)
    gStr = STR$(CGA_PALETTE(i).g)
    bStr = STR$(CGA_PALETTE(i).b)
    IF LEN(rStr) = 2 THEN rStr = " " + rStr
    IF LEN(rStr) = 3 THEN rStr = " " + rStr
    IF LEN(gStr) = 2 THEN gStr = " " + gStr
    IF LEN(gStr) = 3 THEN gStr = " " + gStr
    IF LEN(bStr) = 2 THEN bStr = " " + bStr
    IF LEN(bStr) = 3 THEN bStr = " " + bStr
    
    rgbStr = rStr + "," + gStr + "," + bStr
    
    _ECHO indexStr + "   " + rgbStr + "    #" + hexR + hexG + hexB + "    " + colorName
NEXT i

_ECHO ""
_ECHO "This palette matches the PowerShell remap-cga.ps1 script exactly."

SYSTEM
