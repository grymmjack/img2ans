# img2ans — Code Tour (from uploaded repo)

This is a quick, high-signal tour based on the ZIP you uploaded. It highlights where things live now and concrete next steps to wire up the full image→ANSI pipeline in the GUI.

## What’s here (top-level highlights)

- **IMG2ANS.BAS** — InForm‑PE GUI app (events, widgets, preview panes). Contains UI event stubs and some helper types (e.g., `Vector2LType`, `RectangleLType`, `MouseManagerType`).
- **IMG2ANS.BI** — Shared types and `$INCLUDE` dependencies (mouse, console/misc libs). Declares your `TYPE IMAGE` wrapper.
- **IMG2ANS.INI** — Config for external editors, recent directories, and the **palette list** of `.GPL` files.
- **include/**
  - **InForm-PE/** — GUI engine submodule.
  - **SAUCE/** — Reader/writer module scaffolding (`SAUCE.BAS`/`.BI`/`.BM`).
  - **MOUSE/**, **BOUNDING_BOX/**, **QB64_GJ_LIB/**, **RhoSigma-QB64Library/** — utility libs.
- **resources/palettes/** — Dozens of `.GPL` palette files (GIMP format), e.g., EGA, CGA, Amiga, C64, PICO‑8, etc.
- **archived/v0.1.1-tools/** — Earlier CLI tools (`IMG2ANS-25`, `IMG2ANS-50`, `*-RGB*`, `*-OPT*`, etc.). Note: large chunks are elided with `...` in the archive, so not all logic is visible in this ZIP.

## What’s *not yet wired* (based on this ZIP)

- The **core converter** (pixel → cell → glyph+FG/BG) doesn’t appear integrated into the GUI yet.
- The **ANSI writer** (SGR emission, iCE toggles, SAUCE append) is present in fragments, but the main loops are elided in archived tools and not yet present in the GUI source.

## Suggested module split (clean, testable)

1. **core/palette.bi|bas**
   - `LoadGimpPalette(path$) AS LONG` → returns count, fills arrays `PalR()`, `PalG()`, `PalB()`, `PalName$()`
   - `NearestIndex(r&, g&, b&) AS INTEGER` (weighted RGB or sRGB→linear)
2. **core/cellmap.bi|bas**
   - Constants for CP437 glyphs: `B = 219`, `FT = 223` (▀), `FB = 220` (▄), optional `░▒▓` etc.
   - `CellToGlyphAndColors(img&, xCell%, yCell%, cellW%, cellH%, useHalfBlocks AS _BYTE, BYREF glyph%, BYREF fgIdx%, BYREF bgIdx%)`
3. **core/ansi_writer.bi|bas**
   - Functions to emit SGR for **16‑color** mode (`30–37/40–47` and `90–97/100–107` if “iCE/bright bg” enabled).
   - Optional **truecolor** output (`38;2;r;g;b` / `48;2;r;g;b`), gated by a setting.
   - Line buffering: build one ANSI line per row for speed.
4. **core/sauce.bi|bas**
   - Thin wrapper over your `include/SAUCE` to write title/author/group, etc.
5. **core/convert.bi|bas**
   - `ConvertImageToAnsi(srcImg&, outAnsi$)` — orchestrates resample→cellmap→ansi_writer.

Then the GUI (IMG2ANS.BAS) simply calls `ConvertImageToAnsi` when the user hits **Process/Export**, and updates the right‑hand preview textbox with the ANSI text.

## Simple algorithm sketch (for `CellToGlyphAndColors`)

- For each cell:
  - Compute **mean color** of the **top half** and **bottom half**.
  - Quantize each mean to the selected palette (e.g., EGA16).
  - If both halves quantize to the **same index** → use `█` (full block) with that color as **foreground**, and a neutral background (or the same) to avoid color spill.
  - Else:
    - Prefer `▀` (top half FG, bottom BG) if that ordering yields lower error; otherwise `▄`.
- Build lines: set BG, FG SGR, then write the one‑char glyph for each cell.
- To reduce SGR spam, track the **current FG/BG** and only emit SGR when either changes.

## Dithering & quality options

- Start with **no dithering** (mean per half‑cell). It’s clean and fast.
- Add optional **ordered dithering** using `░▒▓` characters or **Floyd–Steinberg** on the *quantized means* (not raw pixels) to avoid noise.
- Provide a toggle for “**half‑blocks only**” vs “**include shading glyphs**” so artists can choose editability vs fidelity.

## Performance tips in QB64‑PE

- Use `_SOURCE` to set the src image, then prefer `_MEMIMAGE` / `_MEM` access to read pixel data in bulk.
- Avoid `POINT` in inner loops; batch read into arrays where possible.
- Use `_NEWIMAGE` + `_PUTIMAGE` to resize to `(cols*cellW, rows*cellH)` **once** before scanning cells.

## SAUCE metadata

- After writing `.ans` and appending 0x1A (EOF), call your `SAUCE` wrapper to attach metadata (title, author, group, date, tinfo for columns/rows, etc.).

---

If you want, I can drop a **starter `core/` module set** into this workspace that you can paste back into your repo and compile with QB64‑PE. Let me know the exact target: 80×25 or 80×50, EGA16 only or truecolor as well, and whether to support iCE bright backgrounds in the first pass.
