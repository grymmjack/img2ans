# Enhanced Bounding Box for QB64PE

A comprehensive, reusable bounding box implementation that follows a complete state machine design. This provides Gimp-like selection box functionality for QB64PE applications.

## Features

- **Complete State Machine**: Implements the exact state transitions shown in your diagram
- **Multiple Interaction Modes**:
  - Selection/Deselection with visual feedback
  - Mouse hover effects
  - Drag-to-move functionality
  - Resize from all 8 points (4 edges + 4 corners)
  - Mouse wheel zoom in/out
- **Visual Feedback**: Different border styles and colors for each state
- **Bounds Checking**: Prevents moving/resizing outside canvas area
- **Size Constraints**: Configurable min/max width and height
- **Clean API**: Easy to integrate into any project

## State Machine Implementation

The implementation follows your provided diagram exactly:

```
DESELECTED ←→ OVER ←→ SELECTED
    ↑         ↓         ↓
    └─── ZOOMING     RESIZING
                      MOVING
```

### State Transitions

- **DESELECTED → OVER**: Mouse moves over the box
- **OVER → DESELECTED**: Mouse moves away from box  
- **OVER → SELECTED**: Left click on box
- **OVER → ZOOMING**: Mouse wheel while over box
- **SELECTED → DESELECTED**: Left click outside box
- **SELECTED → RESIZING**: Drag from edge/corner
- **SELECTED → MOVING**: Drag from inside box
- **ZOOMING → OVER**: Stop mouse wheel movement
- **RESIZING → SELECTED**: Stop dragging
- **MOVING → SELECTED**: Stop dragging

## Files

- `ENHANCED_BBOX.BI` - Type definitions and constants
- `ENHANCED_BBOX.BM` - Complete implementation
- `ENHANCED_BBOX_TEST.BAS` - Comprehensive test program
- `SIMPLE_USAGE.BAS` - Minimal integration example

## Quick Start

### 1. Include the Files

```qb64pe
'$INCLUDE:'path/to/ENHANCED_BBOX.BI'
```

At the end of your program:
```qb64pe
'$INCLUDE:'path/to/ENHANCED_BBOX.BM'
```

### 2. Basic Usage

```qb64pe
' Create bounding box
DIM my_bbox AS __ENHANCED_BOUNDING_BOX
ENHANCED_BBOX_create my_bbox, canvas_handle, x, y, width, height

' In your main loop:
ENHANCED_BBOX_process_mouse my_bbox, MOUSE

' Get selection coordinates:
ENHANCED_BBOX_get_selection my_bbox, x1, y1, x2, y2
```

## API Reference

### Core Functions

#### `ENHANCED_BBOX_create(ebb, canvas, x, y, w, h)`
Creates and initializes a new enhanced bounding box.
- `ebb` - The bounding box structure
- `canvas` - Image handle to draw on
- `x, y` - Initial position  
- `w, h` - Initial size

#### `ENHANCED_BBOX_process_mouse(ebb, mouse) AS INTEGER`
Processes all mouse interactions. Returns TRUE if state changed.
- `ebb` - The bounding box structure
- `mouse` - Mouse state structure
- Returns: TRUE if visual update needed

#### `ENHANCED_BBOX_get_selection(ebb, x1, y1, x2, y2)`
Gets the current selection rectangle coordinates.
- `ebb` - The bounding box structure
- `x1, y1` - Output: top-left corner
- `x2, y2` - Output: bottom-right corner

### Utility Functions

#### `ENHANCED_BBOX_set_position(ebb, x, y)`
Manually sets the position of the bounding box.

#### `ENHANCED_BBOX_set_size(ebb, w, h)`
Manually sets the size with constraint checking.

#### `ENHANCED_BBOX_show(ebb)` / `ENHANCED_BBOX_hide(ebb)`
Show or hide the bounding box.

#### `ENHANCED_BBOX_update_canvas(ebb)`
Updates the clean canvas backup (call when background changes).

#### `ENHANCED_BBOX_cleanup(ebb)`
Frees allocated resources.

### State Management

#### `ENHANCED_BBOX_set_state(ebb, state$) AS INTEGER`
Manually set state (with validation). States:
- `"deselected"` - Default inactive state
- `"over"` - Mouse hovering over box
- `"selected"` - Box is selected
- `"zooming"` - Currently zooming with mouse wheel
- `"resizing"` - Currently resizing via drag
- `"moving"` - Currently moving via drag

## Configuration

### Default Colors
- **Deselected**: Gray dashed border
- **Over**: Cyan solid border  
- **Selected**: Red with selection handles
- **Zooming**: Yellow thick border
- **Resizing**: Blue border
- **Moving**: Green border

### Size Constraints
Default constraints can be modified:
```qb64pe
ebb.min_w = 50  ' Minimum width
ebb.min_h = 50  ' Minimum height  
ebb.max_w = 1024 ' Maximum width
ebb.max_h = 768  ' Maximum height
```

### Edge Tolerance
Resize handle sensitivity:
```qb64pe
ebb.status.edge_tolerance = 8  ' Pixels from edge to trigger resize
```

## Examples

### Image Cropping Application
```qb64pe
' Load an image
image = _LOADIMAGE("photo.jpg")
SCREEN image

' Create selection box
DIM crop_box AS __ENHANCED_BOUNDING_BOX
ENHANCED_BBOX_create crop_box, image, 50, 50, 200, 150

' Main loop
DO
    MOUSE_update
    ENHANCED_BBOX_process_mouse crop_box, MOUSE
    
    ' Check if user wants to crop
    IF INKEY$ = CHR$(13) THEN ' Enter key
        ENHANCED_BBOX_get_selection crop_box, x1, y1, x2, y2
        ' Crop the image using x1,y1,x2,y2 coordinates
        cropped = _NEWIMAGE(x2-x1, y2-y1, 32)
        _PUTIMAGE (0,0), image, cropped, (x1,y1)-(x2,y2)
    END IF
LOOP UNTIL INKEY$ = CHR$(27)
```

### Multi-Box Selection
```qb64pe
' Create multiple selection boxes
DIM boxes(1 TO 3) AS __ENHANCED_BOUNDING_BOX
FOR i = 1 TO 3
    ENHANCED_BBOX_create boxes(i), canvas, i*150, 100, 100, 80
NEXT i

' Process all boxes
FOR i = 1 TO 3
    ENHANCED_BBOX_process_mouse boxes(i), MOUSE
NEXT i
```

## Dependencies

Requires the following modules:
- `MOUSE.BI` / `MOUSE.BM` - Mouse handling
- `QB64_GJ_LIB/_GJ_LIB_COMMON.BI` - Common utilities
- `CONSOLE.BI` / `CONSOLE.BM` - Debug output (optional)

## Testing

Run `ENHANCED_BBOX_TEST.BAS` for a comprehensive demonstration of all features:

```bash
qb64pe -x ENHANCED_BBOX_TEST.BAS
./ENHANCED_BBOX_TEST
```

The test program shows:
- Real-time state monitoring
- All interaction modes
- Visual feedback
- Current selection coordinates
- Keyboard shortcuts for testing

## Integration Tips

1. **Call `ENHANCED_BBOX_process_mouse` once per frame** in your main loop
2. **Update canvas backup** when your background changes with `ENHANCED_BBOX_update_canvas`
3. **Check return value** of `ENHANCED_BBOX_process_mouse` to know when to redraw
4. **Use `ENHANCED_BBOX_get_selection`** to get coordinates for cropping/processing
5. **Always call `ENHANCED_BBOX_cleanup`** before ending your program

## Performance Notes

- The bounding box maintains a clean canvas backup for efficient redrawing
- State changes only trigger renders when necessary
- Mouse cursor updates happen automatically
- Bounds checking prevents invalid operations

## Customization

The system is designed to be easily customizable:

- Modify colors in the initialization section of `ENHANCED_BBOX.BI`
- Adjust border patterns for different visual effects
- Change edge tolerance for resize sensitivity
- Add custom state validation logic
- Extend with additional states if needed

This Enhanced Bounding Box provides a solid foundation for any application requiring interactive selection rectangles with professional-grade user experience.
