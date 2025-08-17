# GJ_BBX — Bounding-Box UI (Phoenix Edition)

Drop-in, namespaced **bounding box** widget for QB64 Phoenix Edition.  
Click/drag to move, resize via 8 handles, and use **arrow keys** (with Ctrl/Shift modifiers) for precise keyboard control.  
Designed to embed cleanly in any project with zero variable collisions.

---

## Features

- 🔒 **Safe to include**: all symbols are namespaced `GJ_BBX_*`
- 🖱️ Mouse: hover handles, drag box, resize via 8 handles (corners + edges)
- ⌨️ Keyboard:
  - Arrows → move
  - **Ctrl + Arrows** → resize
  - **Shift** → 10× step
- 🟨 **Filled** (not 1-px) handles with configurable normal/hover/border colors
- ⚙️ Central **config struct** (`GJ_BBX_CFG`) for sizes, colors, mins, and initial rect
- 🧩 Call-from-your-loop API: `Init*`, `Update`, `Draw` (or use `Tick` convenience)

---

## Requirements

- **QB64 Phoenix Edition (QB64PE)**
- 32-bit or 64-bit build
- Uses only standard QB64PE keywords

---

## Files / Layout

This widget ships as a single module. You can keep it as one file or split into `.bi/.bm`:

- **Single-file module**: put declarations at the top, your `Main`, then implementations.
- **Optional split**:
  - `GJ_BBX.bi` — `TYPE`s, `CONST`s, `DECLARE`s, `DIM SHARED` state
  - `GJ_BBX.bm` — all `SUB`/`FUNCTION` bodies

Include style:

```basic
$INCLUDE: "GJ_BBX.bi"
' ... your main program ...
$INCLUDE: "GJ_BBX.bm"
