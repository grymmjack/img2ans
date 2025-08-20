' DITHERING USAGE (after brightness/contrast/posterize, before ConvertImageToAnsi$)
' '$INCLUDE:'dither.bi'
' '$INCLUDE:'dither.bas'
'
' Ordered 4x4 (amount 0..1)
CALL ApplyOrderedPaletteDither(scaled&, 1, 4, 0.6)
'
' Ordered 8x8 (finer)
' CALL ApplyOrderedPaletteDither(scaled&, 1, 8, 0.5)
'
' Floyd–Steinberg (serpentine scanning = TRUE)
' CALL ApplyFloydSteinbergDither(scaled&, 1, -1)
