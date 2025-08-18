$INCLUDEONCE
' core/dither.bi — palette-based dithering (ordered & Floyd–Steinberg)
' Requires core/palette.bi (uses PalR/PalG/PalB and NearestIndex).

' Ordered dithering (Bayer 4x4 or 8x8). Amount 0..1 scales threshold effect.
DECLARE SUB ApplyOrderedPaletteDither (img AS LONG, useSRGB AS _BYTE, matrixSize AS INTEGER, amount AS SINGLE)

' Floyd–Steinberg error diffusion, optional serpentine scanning.
DECLARE SUB ApplyFloydSteinbergDither (img AS LONG, useSRGB AS _BYTE, serpentine AS _BYTE)
