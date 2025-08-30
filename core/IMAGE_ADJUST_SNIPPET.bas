' Example usage in your pipeline (after scaling, before ConvertImageToAnsi$):
' '$INCLUDE:'core/image_ops.bi'
' '$INCLUDE:'core/image_ops.bas'
'
' DIM brightness%: brightness% = 20          ' -255..+255
' DIM contrast%:   contrast%   = 15          ' -100..+100
' DIM levels%:     levels%     = 5           ' posterize buckets (e.g., 5 → step 51)
' DIM blurRadius%: blurRadius% = 3           ' 1..15 pixels (optional)
' DIM glowRadius%: glowRadius% = 5           ' 1..10 pixels (optional)
' DIM glowIntensity%: glowIntensity% = 50    ' 10..100% (optional)
' 
' ' Basic adjustments (no blur/glow):
' CALL AdjustImageInPlace(scaled&, brightness%, contrast%, levels%)
'
' ' Extended adjustments (with blur):
' CALL AdjustImageInPlaceWithBlur(scaled&, brightness%, contrast%, levels%, blurRadius%)
'
' ' Extended adjustments (with glow):
' CALL AdjustImageInPlaceWithGlow(scaled&, brightness%, contrast%, levels%, glowRadius%, glowIntensity%)
'
' ' All adjustments (with blur and glow):
' CALL AdjustImageInPlaceFull(scaled&, brightness%, contrast%, levels%, blurRadius%, glowRadius%, glowIntensity%)
'
' ' Individual effects:
' CALL ApplyBrightness(scaled&, brightness%)
' CALL ApplyContrast(scaled&, contrast%)
' CALL ApplyPosterize(scaled&, levels%)
' CALL ApplyBlur(scaled&, blurRadius%)
' CALL ApplyGlow(scaled&, glowRadius%, glowIntensity%)
