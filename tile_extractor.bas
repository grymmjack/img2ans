''
' CGA REMAP - Remap PNG files to 16-color CGA palette (like PowerShell remap-cga.ps1)
'
' This program takes an input directory and output directory,
' processes all PNG files in the input directory, and converts them to
' indexed PNG format using the exact 16-color CGA palette.
'
' Usage: cga_remap.exe <input_dir> <output_dir>
'
' @author grymmjack
' @version 2.0
' @description Remap PNG files to CGA 16-color palette
''

$CONSOLE

'$INCLUDE:'IMGADJ/IMGADJ.BI'
'$INCLUDE:'DUMP/DUMP.BI'
'$INCLUDE:'SYS/SYS.BI'
'$INCLUDE:'STRINGS/STRINGS.BI'

' CGA 16-color palette (exact order 0..15)
TYPE CGA_COLOR
    r AS INTEGER
    g AS INTEGER  
    b AS INTEGER
END TYPE

DIM SHARED CGA_PALETTE(0 TO 15) AS CGA_COLOR

DECLARE SUB InitCGAPalette
DECLARE FUNCTION GetCGAColor% (rval AS INTEGER, gval AS INTEGER, bval AS INTEGER)
DECLARE FUNCTION ConvertToCGA& (sourceImg AS LONG)
DECLARE SUB ProcessDirectory (inputDir AS STRING, outputDir AS STRING)
DECLARE FUNCTION GetFileExtension$ (filename AS STRING)

' Main program variables
DIM inputDir AS STRING
DIM outputDir AS STRING

' Initialize CGA palette
InitCGAPalette

' Get command line arguments
IF COMMAND$ = "" THEN
    _ECHO "=== CGA REMAP - Convert PNG files to 16-color CGA palette ==="
    _ECHO ""
    _ECHO "Usage: " + COMMAND$(0) + " <input_directory> <output_directory>"
    _ECHO ""
    _ECHO "This program processes all PNG files in the input directory"
    _ECHO "and converts them to indexed PNG format using the exact 16-color CGA palette."
    _ECHO ""
    _ECHO "Example: cga_remap.exe input_images output_images"
    _ECHO ""
    SYSTEM
END IF

' Parse command line arguments
DIM args AS STRING
DIM spacePos AS INTEGER
args = LTRIM$(RTRIM$(COMMAND$))

spacePos = INSTR(args, " ")
IF spacePos = 0 THEN
    _ECHO "ERROR: Both input and output directories must be specified!"
    _ECHO "Usage: " + COMMAND$(0) + " <input_directory> <output_directory>"
    SYSTEM
END IF

inputDir = LTRIM$(RTRIM$(LEFT$(args, spacePos - 1)))
outputDir = LTRIM$(RTRIM$(MID$(args, spacePos + 1)))

' Remove quotes if present
IF LEFT$(inputDir, 1) = CHR$(34) THEN inputDir = MID$(inputDir, 2)
IF RIGHT$(inputDir, 1) = CHR$(34) THEN inputDir = LEFT$(inputDir, LEN(inputDir) - 1)
IF LEFT$(outputDir, 1) = CHR$(34) THEN outputDir = MID$(outputDir, 2)
IF RIGHT$(outputDir, 1) = CHR$(34) THEN outputDir = LEFT$(outputDir, LEN(outputDir) - 1)

_ECHO "=== CGA REMAP - Convert PNG files to 16-color CGA palette ==="
_ECHO ""
_ECHO "Input directory:  " + inputDir
_ECHO "Output directory: " + outputDir
_ECHO ""

' Validate input directory
IF NOT _DIREXISTS(inputDir) THEN
    _ECHO "ERROR: Input directory '" + inputDir + "' does not exist!"
    SYSTEM
END IF

' Create output directory if it doesn't exist
IF NOT _DIREXISTS(outputDir) THEN
    MKDIR outputDir
    IF NOT _DIREXISTS(outputDir) THEN
        _ECHO "ERROR: Could not create output directory '" + outputDir + "'!"
        SYSTEM
    END IF
    _ECHO "Created output directory: " + outputDir
END IF

' Process all PNG files in the input directory
ProcessDirectory inputDir, outputDir

_ECHO ""
_ECHO "CGA remapping complete!"

SYSTEM

' Initialize CGA palette (exact 16-color CGA palette in order 0..15)
SUB InitCGAPalette
    ' CGA palette in desired index order (0..15) - matching PowerShell script
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
END SUB

' Find closest CGA color for given RGB values (no dithering - exact match)
FUNCTION GetCGAColor% (rval AS INTEGER, gval AS INTEGER, bval AS INTEGER)
    DIM bestIndex AS INTEGER
    DIM bestDistance AS LONG
    DIM distance AS LONG
    DIM i AS INTEGER
    
    bestDistance = 999999
    bestIndex = 0
    
    ' Find closest color in the 16-color CGA palette
    FOR i = 0 TO 15
        ' Calculate Euclidean distance in RGB space
        distance = (rval - CGA_PALETTE(i).r) ^ 2 + (gval - CGA_PALETTE(i).g) ^ 2 + (bval - CGA_PALETTE(i).b) ^ 2
        IF distance < bestDistance THEN
            bestDistance = distance
            bestIndex = i
        END IF
    NEXT i
    
    GetCGAColor% = bestIndex
END FUNCTION

' Convert image to CGA 16-color palette (indexed PNG)
FUNCTION ConvertToCGA& (sourceImg AS LONG)
    DIM newImg AS LONG
    DIM w AS INTEGER, h AS INTEGER
    DIM x AS INTEGER, y AS INTEGER
    DIM pixel AS _UNSIGNED LONG
    DIM r AS INTEGER, g AS INTEGER, b AS INTEGER
    DIM cgaIndex AS INTEGER
    DIM oldDest AS LONG
    DIM i AS INTEGER
    
    w = _WIDTH(sourceImg)
    h = _HEIGHT(sourceImg)
    
    ' Create a 256-color image and set up EXACTLY the 16 CGA colors
    newImg = _NEWIMAGE(w, h, 256)
    oldDest = _DEST
    
    ' Set the destination and configure the 16-color CGA palette
    _DEST newImg
    FOR i = 0 TO 15
        _PALETTECOLOR i, _RGB32(CGA_PALETTE(i).r, CGA_PALETTE(i).g, CGA_PALETTE(i).b)
    NEXT i
    
    ' Set all remaining palette entries to BLACK to force 16-color usage
    FOR i = 16 TO 255
        _PALETTECOLOR i, _RGB32(0, 0, 0)
    NEXT i
    
    _SOURCE sourceImg
    
    ' Process each pixel and force it to use ONLY CGA palette indexes 0-15
    FOR y = 0 TO h - 1
        FOR x = 0 TO w - 1
            pixel = POINT(x, y)
            
            ' Extract RGB components
            r = _RED32(pixel)
            g = _GREEN32(pixel)
            b = _BLUE32(pixel)
            
            ' Find closest color index (0-15 only)
            cgaIndex = GetCGAColor%(r, g, b)
            
            ' Set pixel using ONLY the 16-color palette index (0-15)
            ' This ensures the saved image uses exactly these 16 colors
            PSET (x, y), cgaIndex
        NEXT x
    NEXT y
    
    _DEST oldDest
    ConvertToCGA& = newImg
END FUNCTION

' Process all PNG files in a directory
SUB ProcessDirectory (inputDir AS STRING, outputDir AS STRING)
    DIM currentFile AS STRING
    DIM sourceImg AS LONG
    DIM cgaImg AS LONG
    DIM inputPath AS STRING
    DIM outputPath AS STRING
    DIM filesProcessed AS INTEGER
    
    filesProcessed = 0
    
    ' Get list of files in the directory
    ' Note: This is a simplified version - QB64PE doesn't have built-in directory listing
    ' In a real implementation, you might need to use SHELL commands or external tools
    
    _ECHO "Scanning directory for PNG files..."
    
    ' For now, let's process files by trying common names or asking user
    ' This is where you'd implement proper directory scanning
    
    ' Example implementation - you would replace this with actual directory scanning
    DIM testFiles(1 TO 100) AS STRING
    DIM fileCount AS INTEGER
    DIM i AS INTEGER
    
    ' Try to find PNG files by pattern (this is a simplified approach)
    ' In practice, you'd use SHELL DIR commands or QB64PE's file functions
    fileCount = 0
    
    ' Since QB64PE doesn't have built-in directory listing, we'll use a SHELL command
    ' to get the file list and parse it
    SHELL _HIDE "dir /B " + CHR$(34) + inputDir + "\*.png" + CHR$(34) + " > temp_filelist.txt"
    
    IF _FILEEXISTS("temp_filelist.txt") THEN
        OPEN "temp_filelist.txt" FOR INPUT AS #1
        DO UNTIL EOF(1)
            LINE INPUT #1, currentFile
            IF RTRIM$(LTRIM$(currentFile)) <> "" THEN
                fileCount = fileCount + 1
                testFiles(fileCount) = RTRIM$(LTRIM$(currentFile))
            END IF
        LOOP
        CLOSE #1
        KILL "temp_filelist.txt"
    END IF
    
    IF fileCount = 0 THEN
        _ECHO "No PNG files found in input directory."
        EXIT SUB
    END IF
    
    _ECHO "Found " + STR$(fileCount) + " PNG files to process:"
    _ECHO ""
    
    ' Process each file
    FOR i = 1 TO fileCount
        currentFile = testFiles(i)
        inputPath = inputDir + "\" + currentFile
        outputPath = outputDir + "\" + currentFile
        
        _ECHO "Processing: " + currentFile
        
        ' Load source image
        sourceImg = _LOADIMAGE(inputPath, 32)
        IF sourceImg = -1 THEN
            _ECHO "  ERROR: Could not load " + currentFile
        ELSE
            ' Convert to CGA format
            cgaImg = ConvertToCGA&(sourceImg)
            
            ' Save as PNG with CGA palette
            _SAVEIMAGE outputPath, cgaImg, "PNG"
            
            _ECHO "  Saved: " + outputPath + " (" + STR$(_WIDTH(cgaImg)) + "x" + STR$(_HEIGHT(cgaImg)) + ")"
            
            ' Clean up
            _FREEIMAGE sourceImg
            _FREEIMAGE cgaImg
            
            filesProcessed = filesProcessed + 1
        END IF
    NEXT i
    
    _ECHO ""
    _ECHO "Processed " + STR$(filesProcessed) + " files successfully."
END SUB

' Get file extension from filename
FUNCTION GetFileExtension$ (filename AS STRING)
    DIM i AS INTEGER
    DIM ext AS STRING
    
    FOR i = LEN(filename) TO 1 STEP -1
        IF MID$(filename, i, 1) = "." THEN
            ext = MID$(filename, i + 1)
            EXIT FOR
        END IF
    NEXT i
    
    GetFileExtension$ = UCASE$(ext)
END FUNCTION

'$INCLUDE:'IMGADJ/IMGADJ.BM'
'$INCLUDE:'DUMP/DUMP.BM'
'$INCLUDE:'SYS/SYS.BM'
'$INCLUDE:'STRINGS/STRINGS.BM'

