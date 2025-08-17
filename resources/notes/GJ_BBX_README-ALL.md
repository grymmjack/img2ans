
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
````

---

## Quick Start

```basic
' setup your screen first
SCREEN _NEWIMAGE(800, 600, 32)
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

' initialize with built-in defaults
GJ_BBX_InitDefaults

DO
    CLS
    ' Update input & state, then draw the bbox
    GJ_BBX_Update
    GJ_BBX_Draw 0      ' pass -1 to show the HUD text; 0 to hide
    _DISPLAY
LOOP UNTIL _KEYHIT = 27
```

---

## Custom Config (override defaults)

```basic
DIM cfg AS GJ_BBX_CFG

' --- sizes ---
cfg.HandleHalfSize = 16
cfg.HandleFullSize = cfg.HandleHalfSize * 2
cfg.EdgeHalfSize   = 10
cfg.EdgeFullSize   = cfg.EdgeHalfSize * 2
cfg.HandleCornerSize = cfg.HandleFullSize
cfg.HandleEdgeSize   = cfg.EdgeFullSize
cfg.MinBoxWidth = 32
cfg.MinBoxHeight = 32
cfg.DragEdgePadding = 8

' --- colors ---
cfg.colorIdle          = _RGB32(128,128,128)
cfg.colorHoverOnly     = _RGB32(255,255,  0)
cfg.colorSelectedOnly  = _RGB32(  0,128,255)
cfg.colorSelectedHover = _RGB32(255,128,  0)
cfg.colorDragging      = _RGB32(  0,255,  0)
cfg.colorResizing      = _RGB32(255,  0,255)

' handle colors
cfg.HandleFillColor       = _RGB32(255,255,255)
cfg.HandleHoverFillColor  = _RGB32(255,255,  0)
cfg.HandleBorderColor     = _RGB32(  0,  0,  0)

' initial rectangle
cfg.initX = 300: cfg.initY = 200
cfg.initW = 150: cfg.initH = 100

' apply
GJ_BBX_InitWithConfig cfg
```

---

## Controls

**Mouse**

* Hover corner/edge → matching resize cursor
* Click handle → drag to resize
* Click inside box → drag to move
* Release → selects the box
* Click outside → deselects the box

**Keyboard** (when selected)

* **Arrows** → move (1 px)
* **Shift + Arrows** → move (10 px)
* **Ctrl + Arrows** → resize (1 px; 10 px with Shift)

---

## API Reference

### Initialization

```basic
SUB GJ_BBX_InitDefaults
```

Sets sensible defaults into the shared `GJ_BBX_CFG`, creates the initial box, and primes the mouse.

```basic
SUB GJ_BBX_InitWithConfig (cfg AS GJ_BBX_CFG)
```

Copies your `cfg` into the shared config, creates the initial box from `cfg.init*`, and primes the mouse.

```basic
SUB GJ_BBX_InitBox (x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
```

Directly set the current box rectangle and reset widget state.

### Per-frame

```basic
SUB GJ_BBX_Update
```

Polls mouse/keyboard, updates hover/drag/resize/selection, enforces min W/H.

```basic
SUB GJ_BBX_Draw (showHUD AS INTEGER)
```

Renders the box (state-colored outline) and the **filled** handles.
If `showHUD` is non-zero, prints debug (state, hovered handle, selection).

```basic
SUB GJ_BBX_Tick (showHUD AS INTEGER)
```

Convenience: `Update` then `Draw`.

---

## Types

```basic
TYPE GJ_BBX_CFG
    HandleHalfSize, HandleFullSize        AS INTEGER
    EdgeHalfSize,   EdgeFullSize          AS INTEGER
    HandleCornerSize, HandleEdgeSize      AS INTEGER
    DragEdgePadding                       AS INTEGER
    MinBoxWidth, MinBoxHeight             AS INTEGER
    colorIdle, colorHoverOnly             AS _UNSIGNED LONG
    colorSelectedOnly, colorSelectedHover AS _UNSIGNED LONG
    colorDragging, colorResizing          AS _UNSIGNED LONG
    HandleFillColor                       AS _UNSIGNED LONG
    HandleHoverFillColor                  AS _UNSIGNED LONG
    HandleBorderColor                     AS _UNSIGNED LONG
    initX, initY, initW, initH            AS INTEGER
END TYPE
```

```basic
TYPE GJ_BBX_BBOX
    x, y, w, h          AS INTEGER
    state               AS INTEGER
    offsetX, offsetY    AS INTEGER
    hoverHandle         AS INTEGER
    activeHandle        AS INTEGER
    selected            AS INTEGER
    wasClickedInside    AS INTEGER
END TYPE
```

```basic
TYPE GJ_BBX_MouseState
    x, y, dx, dy            AS INTEGER
    held, clicked, released AS INTEGER
END TYPE
```

---

## Constants

**States**

```basic
CONST GJ_BBX_STATE_IDLE = 0
CONST GJ_BBX_STATE_HOVER = 1
CONST GJ_BBX_STATE_DRAG = 2
CONST GJ_BBX_STATE_SELECTED = 10
CONST GJ_BBX_STATE_SELECTED_HOVER = 11
CONST GJ_BBX_STATE_RESIZE_BASE = 100
```

**Handles**

```basic
CONST GJ_BBX_HANDLE_NONE = 0
CONST GJ_BBX_HANDLE_TL = 1, GJ_BBX_HANDLE_T = 2, GJ_BBX_HANDLE_TR = 3
CONST GJ_BBX_HANDLE_L  = 4, GJ_BBX_HANDLE_R = 5
CONST GJ_BBX_HANDLE_BL = 6, GJ_BBX_HANDLE_B = 7, GJ_BBX_HANDLE_BR = 8
```

**Key codes** (extended)

```basic
CONST GJ_BBX_KEY_LEFT       = 19200
CONST GJ_BBX_KEY_RIGHT      = 19712
CONST GJ_BBX_KEY_UP         = 18432
CONST GJ_BBX_KEY_DOWN       = 20480
CONST GJ_BBX_KEY_CTRL_LEFT  = 115 * 256
CONST GJ_BBX_KEY_CTRL_RIGHT = 116 * 256
CONST GJ_BBX_KEY_CTRL_UP    = 141 * 256
CONST GJ_BBX_KEY_CTRL_DOWN  = 145 * 256
```

---

## Integration Notes

* **Order matters** in single-file programs:

  1. `TYPE`s / `CONST`s / `DECLARE`s
  2. Your **main** code (screen setup, init, loop)
  3. `SUB`/`FUNCTION` implementations
* Prefer the `.bi/.bm` split to keep main readable.
* `GJ_BBX_CFG`, `GJ_BBX_box`, and `GJ_BBX_mouse` are declared as `DIM SHARED` in the module—don’t re-declare elsewhere.
* Handles are **filled** (`LINE ..., BF`) with optional 1-px borders.
* Min width/height enforced during mouse **and** keyboard resize.

---

## Example Minimal Main (no HUD)

```basic
$INCLUDE: "GJ_BBX.bi"

SCREEN _NEWIMAGE(1024, 768, 32)
$RESIZE:ON
_MOUSESHOW
_DISPLAYORDER _SOFTWARE

GJ_BBX_InitDefaults

DO
    CLS
    GJ_BBX_Update
    GJ_BBX_Draw 0
    _DISPLAY
LOOP UNTIL _KEYHIT = 27

$INCLUDE: "GJ_BBX.bm"
```

---

## Troubleshooting

* **“Statement cannot be placed between SUB/FUNCTIONs”**
  Ensure your main statements aren’t between implementations. Use the ordering above or `.bi/.bm`.

* **Handles look 1-px**
  Confirm you’re on the filled-handle version (`BF`) and that `HandleHalfSize` / `EdgeHalfSize` > 0.

* **Config not taking effect**
  Call `GJ_BBX_InitDefaults` or `GJ_BBX_InitWithConfig` after screen setup and before the loop. The module already uses `DIM SHARED` for the config.

---

## License

Use the same license as the rest of **QB64\_GJ\_LIB**. If none specified, consider MIT.

---

## Changelog

* **v1.0.0**

  * Namespaced `GJ_BBX_*`
  * Library-style API (`Init*`, `Update`, `Draw`, `Tick`)
  * **Filled**, colorized handles (normal/hover/border)
  * Mouse drag + 8 resize handles
  * Keyboard move/resize with Shift multiplier

