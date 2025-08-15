# img2ans — Core Module Integration HOWTO (QB64‑PE)

These `core/` files give you a clean separation so the GUI only orchestrates.
They assume **16‑color palettes** (e.g., EGA) loaded from `.GPL` and produce
ANSI using █ ▀ ▄ (half‑block) mapping.

## Files

- `core/palette.bi|bas` — load `.GPL` palettes, nearest color lookup.
- `core/cellmap.bi|bas` — decide glyph + FG/BG per cell using top/bottom means.
- `core/ansi_writer.bi|bas` — emit compact SGR sequences; optional iCE bright BG.
- `core/sauce_wrap.bi|bas` — helper to append SAUCE (if `include/SAUCE` is present).
- `core/convert.bi|bas` — loops over cells, builds the final ANSI string.

## Minimal usage (non‑GUI)

```basic
'$INCLUDE:'core/palette.bi'
'$INCLUDE:'core/palette.bas'
'$INCLUDE:'core/cellmap.bi'
'$INCLUDE:'core/cellmap.bas'
'$INCLUDE:'core/ansi_writer.bi'
'$INCLUDE:'core/ansi_writer.bas'
'$INCLUDE:'core/convert.bi'
'$INCLUDE:'core/convert.bas'
'$INCLUDE:'include/SAUCE/SAUCE.BI' ' optional
'$INCLUDE:'include/SAUCE/SAUCE.BAS' ' optional

DIM img&, cols%, rows%, cw%, ch%, useHB AS _BYTE, useICE AS _BYTE
cols% = 80: rows% = 25: cw% = 8: ch% = 16
useHB = -1: useICE = 0

IF LoadGimpPalette("resources/palettes/EGA.GPL") = 0 THEN PRINT "Failed to load palette": SYSTEM

' Load & pre-scale the image to cols*cw by rows*ch
img& = _LOADIMAGE("input.png", 32)
DIM scaled&: scaled& = _NEWIMAGE(cols% * cw%, rows% * ch%, 32)
_PUTIMAGE , img&, scaled&

DIM ansi$ : ansi$ = ConvertImageToAnsi$(scaled&, cols%, rows%, cw%, ch%, useHB, useICE)

' Write file + SAUCE (optional)
OPEN "output.ans" FOR OUTPUT AS #1: PRINT #1, ansi$: CLOSE #1
' Append EOF & SAUCE
OPEN "output.ans" FOR APPEND AS #1: PRINT #1, CHR$(&H1A); : CLOSE #1
WriteSauceForAnsi "output.ans", "IMG2ANS", "grymmjack", "img2ans", cols%, rows%
```

## Hooking into the GUI (IMG2ANS.BAS)

1. Add includes near the top (after your other includes):
```basic
'$INCLUDE:'core/palette.bi'
'$INCLUDE:'core/palette.bas'
'$INCLUDE:'core/cellmap.bi'
'$INCLUDE:'core/cellmap.bas'
'$INCLUDE:'core/ansi_writer.bi'
'$INCLUDE:'core/ansi_writer.bas'
'$INCLUDE:'core/convert.bi'
'$INCLUDE:'core/convert.bas'
'$INCLUDE:'include/SAUCE/SAUCE.BI' ' optional
'$INCLUDE:'include/SAUCE/SAUCE.BAS' ' optional
```

2. When the user selects a palette in your GUI, call:
```basic
IF LoadGimpPalette(selectedPalPath$) = 0 THEN
    ' show error
END IF
```

3. When the user hits **Process/Export**:
```basic
' Assume you already computed cols%, rows%, cw%, ch% and flags useHB/useICE
DIM src& ' your source image
' Pre-scale once
DIM scaled&: scaled& = _NEWIMAGE(cols% * cw%, rows% * ch%, 32)
_PUTIMAGE , src&, scaled&

DIM ansi$ : ansi$ = ConvertImageToAnsi$(scaled&, cols%, rows%, cw%, ch%, useHB, useICE)

' Show in preview textbox (right panel)
UI_SetText TXT_AnsiPreview, ansi$

' Save
OPEN outPath$ FOR OUTPUT AS #1: PRINT #1, ansi$: CLOSE #1
OPEN outPath$ FOR APPEND AS #1: PRINT #1, CHR$(&H1A); : CLOSE #1
WriteSauceForAnsi outPath$, title$, author$, group$, cols%, rows%
```

## Next quality steps
- Switch `MeanRGBOfRect` to `_MEMIMAGE` for a 10–50× speedup.
- Add dithering toggle (ordered 4×4 matrix works well).
- Consider  double-wide VGA (9×16 glyphs) handling, if you need exact CP437 width.
