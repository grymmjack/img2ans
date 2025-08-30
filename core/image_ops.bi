$INCLUDEONCE
' core/image_ops.bi — Comprehensive Image Adjustment Library (QB64‑PE)
' Ultra-fast _MEMIMAGE-based algorithms with advanced optimizations

' CORE ADJUSTMENTS (Basic Image Operations)
' Brightness: -255..+255 (adds offset per channel, clamped 0..255)
' Contrast:   -100..+100 (%) — 0=unchanged; uses standard 259*(c+255)/(255*(259-c)) curve
' Gamma:      0.1..3.0 — Uses pre-calculated lookup tables for maximum speed
' Posterize:  levels >= 2; snaps each channel to nearest step (e.g., 5 → step=51)

' EFFECTS (Creative Image Operations)
' Blur:       radius 1..15 pixels; uses adaptive sampling for performance
' Glow:       radius 1..10, intensity 10-100%; creates soft glow around bright areas
' Film Grain: amount 0-100; realistic grain with position-based pseudo-random noise
' Vignette:   strength 0.0-1.0; darkens edges using optimized squared distance

' COLOR ADJUSTMENTS (Advanced Color Operations)
' Hue/Saturation: hue shift -180..+180 degrees, saturation 0.0-2.0
' Color Balance: independent red/green/blue shifts -100..+100
' Levels: input/output min/max 0-255; uses lookup tables for speed
' Curves: Various curve types for tone adjustment
' Colorize: Converts to grayscale then applies hue/saturation

' UTILITY EFFECTS (Simple Operations)
' Invert: Inverts all color channels
' Sepia: Classic sepia tone effect
' Desaturate: Converts to grayscale using various methods
' Threshold: Black/white conversion with adjustable threshold
' Pixelate: Creates pixelated effect with adjustable block size

' COMPOSITE ADJUSTMENT FUNCTIONS
DECLARE SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)
DECLARE SUB AdjustImageInPlaceWithBlur (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER)
DECLARE SUB AdjustImageInPlaceWithGlow (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)
DECLARE SUB AdjustImageInPlaceFull (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER, blurRadius AS INTEGER, glowRadius AS INTEGER, glowIntensity AS INTEGER)

' CORE ADJUSTMENT FUNCTIONS (Basic Operations)
DECLARE SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
DECLARE SUB ApplyContrast (img AS LONG, pct AS INTEGER)
DECLARE SUB ApplyGamma (img AS LONG, gamma AS SINGLE)
DECLARE SUB ApplyPosterize (img AS LONG, levels AS INTEGER)

' EFFECT FUNCTIONS (Creative Operations)
DECLARE SUB ApplyBlur (img AS LONG, radius AS INTEGER)
DECLARE SUB ApplyGlow (img AS LONG, glowRadius AS INTEGER, intensity AS INTEGER)
DECLARE SUB ApplyFilmGrain (img AS LONG, amount AS INTEGER)
DECLARE SUB ApplyVignette (img AS LONG, strength AS SINGLE)

' COLOR ADJUSTMENT FUNCTIONS (Advanced Color Operations)
DECLARE SUB ApplyHueSaturation (img AS LONG, hueShift AS INTEGER, saturation AS SINGLE)
DECLARE SUB ApplyColorBalance (img AS LONG, redShift AS INTEGER, greenShift AS INTEGER, blueShift AS INTEGER)
DECLARE SUB ApplyLevels (img AS LONG, inputMin AS INTEGER, inputMax AS INTEGER, outputMin AS INTEGER, outputMax AS INTEGER)
DECLARE SUB ApplyCurves (img AS LONG, curveType AS INTEGER)
DECLARE SUB ApplyColorize (img AS LONG, hue AS INTEGER, saturation AS SINGLE)

' UTILITY EFFECT FUNCTIONS (Simple Operations)
DECLARE SUB ApplyInvert (img AS LONG)
DECLARE SUB ApplySepia (img AS LONG)
DECLARE SUB ApplyDesaturate (img AS LONG, method AS INTEGER)
DECLARE SUB ApplyThreshold (img AS LONG, threshold AS INTEGER, mode AS INTEGER)
DECLARE SUB ApplyPixelate (img AS LONG, pixelSize AS INTEGER)

' INTERNAL HELPER FUNCTIONS
DECLARE SUB ApplyGlowBlur (img AS LONG, radius AS INTEGER)
