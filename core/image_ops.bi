$INCLUDEONCE
' core/image_ops.bi — brightness / contrast / posterize (QB64‑PE)

' Brightness: -255..+255 (adds offset per channel, clamped 0..255)
' Contrast:   -100..+100 (%) — 0=unchanged; uses standard 259*(c+255)/(255*(259-c)) curve
' Posterize:  levels >= 2; snaps each channel to nearest step (e.g., 5 → step=51)

DECLARE SUB AdjustImageInPlace (img AS LONG, brightness AS INTEGER, contrastPct AS INTEGER, posterizeLevels AS INTEGER)

' Lower-level building blocks (exposed if you want individual controls)
DECLARE SUB ApplyBrightness (img AS LONG, offset AS INTEGER)
DECLARE SUB ApplyContrast (img AS LONG, pct AS INTEGER)
DECLARE SUB ApplyPosterize (img AS LONG, levels AS INTEGER)
