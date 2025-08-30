$INCLUDEONCE
' core/image_ops.bi — brightness / contrast / posterize / blur / glow (QB64‑PE)

' Brightness: -255..+255 (adds offset per channel, clamped 0..255)
' Contrast:   -100..+100 (%) — 0=unchanged; uses standard 259*(c+255)/(255*(259-c)) curve
' Posterize:  levels >= 2; snaps each channel to nearest step (e.g., 5 → step=51)
' Blur:       radius 1..15 pixels; uses adaptive sampling for performance
' Glow:       radius 1..10, intensity 10-100%; creates soft glow around bright areas

DECLARE SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)
DECLARE SUB AdjustImageInPlaceWithBlur (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER)
DECLARE SUB AdjustImageInPlaceWithGlow (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)
DECLARE SUB AdjustImageInPlaceFull (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)

' Lower-level building blocks (exposed if you want individual controls)
DECLARE SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
DECLARE SUB ApplyContrast (img AS LONG, pct AS INTEGER)
DECLARE SUB ApplyPosterize (img AS LONG, levels AS INTEGER)
DECLARE SUB ApplyBlur (img AS LONG, radius AS INTEGER)
DECLARE SUB ApplyGlow (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)

' Internal helper functions
DECLARE SUB ApplyGlowBlur (img AS LONG, radius AS INTEGER)
