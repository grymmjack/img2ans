# QB64PE Compatibility Issues Journal

This document tracks syntax and compatibility issues encountered when working with QB64PE that differ from standard BASIC or other QB variants.

## Function Declaration Syntax Issues

### Issue 1: Function Return Type Declaration
**Problem**: Used standard BASIC `AS TYPE` syntax for function return types
```basic
FUNCTION NearestPaletteIndex(r AS INTEGER, g AS INTEGER, b AS INTEGER) AS INTEGER
```

**Error**: `Expected )` - QB64PE doesn't support `AS TYPE` for function return types

**Solution**: Use type sigils instead
```basic
FUNCTION NearestPaletteIndex%(r AS INTEGER, g AS INTEGER, b AS INTEGER)
```

**Type Sigils**:
- `%` = INTEGER
- `&` = LONG  
- `!` = SINGLE
- `#` = DOUBLE
- `$` = STRING

---

## Console Directive Issues

### Issue 2: Console Mode Directives
**Problem**: Used `$CONSOLE:OFF` which caused syntax errors

**Error**: `Syntax error - Caused by (or after):$ CONSOLE`

**Solutions**:
- `$CONSOLE` - Shows both console and graphics windows
- `$CONSOLE:ONLY` - Console mode only (no graphics)
- No directive - Graphics only

**Note**: `$CONSOLE:OFF` is not valid syntax

---

## Multi-Statement Line Issues

### Issue 3: Multiple IF Statements on One Line
**Problem**: Chained multiple IF-THEN statements with colons
```basic
IF r < 0 THEN r = 0: IF r > 255 THEN r = 255
```

**Error**: `THEN without IF`

**Solution**: Split into separate lines
```basic
IF r < 0 THEN r = 0
IF r > 255 THEN r = 255
```

**Rule**: Avoid complex multi-statement lines, especially with control structures

---

## Array Declaration Issues

### Issue 4: Multiple Array Declarations on One Line
**Problem**: Declaring multiple arrays with dimensions on one line
```basic
DIM er#(0 TO w) AS DOUBLE, eg#(0 TO w) AS DOUBLE, eb#(0 TO w) AS DOUBLE
```

**Error**: `DIM: Expected ,`

**Solution**: Declare arrays separately
```basic
DIM er(0 TO w) AS DOUBLE
DIM eg(0 TO w) AS DOUBLE  
DIM eb(0 TO w) AS DOUBLE
```

---

## Variable Declaration and Assignment Issues

### Issue 5: Multiple Variable Operations on One Line
**Problem**: Combining declarations and assignments with colons
```basic
DIM oldS AS LONG: oldS = _SOURCE: _SOURCE img
```

**Error**: Can cause parsing issues

**Solution**: Separate operations
```basic
DIM oldS AS LONG
oldS = _SOURCE
_SOURCE img
```

---

## String Function Issues

### Issue 6: Missing String Functions
**Problem**: Used `_WORD$()` function which doesn't exist in QB64PE
```basic
r = VAL(_TRIM$(_WORD$(line$, 1, " ")))
```

**Error**: Function not found

**Solution**: Implement custom string parsing using INSTR, MID$, etc.
```basic
pos1 = INSTR(line$, " ")
IF pos1 > 0 THEN r = VAL(LEFT$(line$, pos1 - 1))
```

---

## Include File Issues

### Issue 7: Module Include Dependencies
**Problem**: Including modules that reference undefined functions/variables

**Error**: `Subscript out of range` when arrays aren't properly initialized

**Solution**: 
- Ensure proper initialization order
- Use self-contained modules when possible
- Initialize SHARED arrays before use

---

## Best Practices Learned

1. **Keep it simple**: Avoid complex multi-statement lines
2. **One operation per line**: Especially for declarations and assignments  
3. **Use type sigils**: For function return types instead of AS clauses
4. **Initialize early**: Set up arrays and variables before use
5. **Test incrementally**: Build up complexity gradually
6. **Separate concerns**: Split complex operations into multiple lines
7. **Use standard functions**: Stick to well-documented QB64PE functions

---

## QB64PE-Specific Syntax Rules

1. Functions must use type sigils for return types, not AS clauses
2. Console directives: `$CONSOLE`, `$CONSOLE:ONLY` (not `$CONSOLE:OFF`)
3. Avoid chaining multiple control structures on one line
4. Array declarations should be separate when using dimensions
5. Variable assignments should be on separate lines from declarations
6. Some BASIC string functions may not be available (implement custom versions)

---

## Unsupported Keywords and Statements

### Keywords Not Supported in All QB64PE Versions

**Legacy Statement Issues**:
- `ALIAS` (only supported in DECLARE LIBRARY)
- `ANY`
- `BYVAL` (only supported in DECLARE LIBRARY) 
- `CALLS`
- `CDECL`
- `DATE$` (statement) - reading current DATE$ is supported
- `DECLARE` (non-BASIC statement)
- `DEF FN`, `EXIT DEF`, `END DEF` - must use actual FUNCTIONs instead
- `ERDEV`, `ERDEV$`
- `FILEATTR`
- `FRE`
- `IOCTL`, `IOCTL$`

**Device and Hardware Access**:
- `OPEN` with devices like `LPT:`, `CON:`, `KBRD:` (LPRINT and OPEN COM are supported)
- `ON PEN`, `PEN` (statement), `PEN` (function)
- `ON PLAY(n)`, `PLAY(n)` ON/OFF/STOP (PLAY music is supported)
- `ON UEVENT`, `UEVENT` (statement)
- `SETMEM`
- `SIGNAL`
- `TIME$` (statement) - reading current TIME$ is supported
- `TRON`, `TROFF`
- `WIDTH LPRINT` combined statement

### Platform-Specific Limitations (Linux/macOS)

**Desktop and Window Operations**:
- `_ACCEPTFILEDROP`, `_TOTALDROPPEDFILES`, `_DROPPEDFILE`, `_FINISHDROP`
- `_SCREENPRINT`
- `_SCREENCLICK`
- `_SCREENMOVE` (available in macOS, not Linux)
- `_WINDOWHASFOCUS` (available in Linux, not macOS)
- `_WINDOWHANDLE`
- `_CAPSLOCK`, `_NUMLOCK`, `_SCROLLLOCK` (statements and functions)

**Console Operations**:
- `_CONSOLETITLE`, `_CONSOLECURSOR`, `_CONSOLEFONT`
- `_CONSOLEINPUT`, `_CINP`

**Program Control**:
- `CHAIN`
- `RUN`

**Printing**:
- `LPRINT` (Linux/macOS)
- `_PRINTIMAGE`

**Hardware Access**:
- `OPEN COM` (Linux/macOS)
- `LOCK`, `UNLOCK` (file locking)

---

## Validation Checklist for MCP Server

When validating QB64PE code, check for:

- [ ] Function declarations using AS clauses instead of sigils
- [ ] Invalid console directives ($CONSOLE:OFF)
- [ ] Multiple IF statements on one line with colons
- [ ] Multiple array declarations with dimensions on one line  
- [ ] Complex multi-statement lines with declarations
- [ ] Usage of non-existent string functions (_WORD$, etc.)
- [ ] Uninitialized SHARED arrays in included modules
- [ ] **Legacy BASIC keywords** (DEF FN, TRON, TROFF, etc.)
- [ ] **Device access statements** (OPEN LPT:, PEN, etc.)
- [ ] **Platform-specific functions** on wrong platforms
- [ ] **Hardware access functions** (SETMEM, SIGNAL, etc.)
- [ ] **Unsupported PRINT combinations** (WIDTH LPRINT)

---

## Debugging and Error Handling in QB64PE

### Traditional Error Handling
QB64PE supports classic BASIC error handling:

```basic
' Enable error handling
ON ERROR GOTO ErrorHandler

' Your code here
OPEN "nonexistent.txt" FOR INPUT AS #1

' Normal program end
END

ErrorHandler:
    PRINT "Error"; ERR; "occurred"
    PRINT "Error description: "; _ERRORLINE
    RESUME NEXT  ' Continue after error
```

**Key Functions:**
- `ERR` - Returns the error code number (0 if no error)
- `RESUME` - Continue execution after handling error
- `RESUME NEXT` - Continue at statement after the error
- `RESUME lineNumber` - Continue at specific line

### Modern Assertion-Based Debugging
QB64PE includes assertion support for development testing:

```basic
' Enable assertions with console output
$ASSERTS:CONSOLE

' Test conditions during development
_ASSERT x > 0, "X must be positive"
_ASSERT LEN(filename$) > 0, "Filename cannot be empty"

' Assertions are removed in release builds
```

**Assertion Features:**
- `$ASSERTS:CONSOLE` - Shows detailed assertion messages in console
- `$ASSERTS:OFF` - Disables all assertions
- `_ASSERT condition, message$` - Stops execution if condition fails
- Assertions include line numbers and custom error messages

### Console Output for Debugging
Use console window alongside graphics for debugging information:

```basic
' Create console window for debugging
$CONSOLE

' Graphics program with debug output
SCREEN _NEWIMAGE(800, 600, 32)

' Switch output to console for debug messages
_DEST _CONSOLE
PRINT "Debug: Starting image processing..."
PRINT "Image size:"; img_width; "x"; img_height

' Switch back to graphics screen
_DEST 0
' Continue with graphics...
```

**Console Features:**
- `$CONSOLE` - Creates console window alongside graphics
- `$CONSOLE:ONLY` - Text-only mode, no graphics window
- `_DEST _CONSOLE` - Send PRINT output to console window  
- `_DEST 0` - Send output back to graphics screen
- `_CONSOLE ON/OFF` - Show/hide console at runtime

### Modern Logging System (QB64PE v4.0.0+)
QB64PE includes a built-in logging system:

```basic
' Log different types of messages
_LOGERROR "Critical error in image processing"
_LOGWARN "Warning: Using default palette"
_LOGINFO "Processing image: " + filename$
_LOGTRACE "Function called with parameter: " + STR$(value)
```

**Logging Features:**
- `_LOGERROR message$` - Log error with stack trace
- `_LOGWARN message$` - Log warning message
- `_LOGINFO message$` - Log informational message  
- `_LOGTRACE message$` - Log trace/debug message
- Automatic timestamps and stack traces
- Configurable log levels and output destinations

### Debugging Best Practices

1. **Use Console Output for Real-time Debugging:**
```basic
$CONSOLE
_DEST _CONSOLE
PRINT "Variable x ="; x; "at line"; _ERRORLINE
_DEST 0
```

2. **Validate Parameters with Assertions:**
```basic
$ASSERTS:CONSOLE
_ASSERT imgHandle < -1, "Invalid image handle"
_ASSERT paletteSize > 0, "Palette must have colors"
```

3. **Check Error Conditions:**
```basic
IF imgHandle >= -1 THEN
    PRINT "Error: Invalid image handle"
    END
END IF
```

4. **Use Structured Error Handling:**
```basic
ON ERROR GOTO ImageLoadError
imgHandle = _LOADIMAGE(filename$)
ON ERROR GOTO 0  ' Disable error handler

ImageLoadError:
    PRINT "Failed to load image:"; filename$
    RESUME NEXT
```

### Common Debugging Scenarios

**File Operations:**
```basic
ON ERROR GOTO FileError
OPEN filename$ FOR INPUT AS #1
' ... file operations
CLOSE #1
GOTO FileSuccess

FileError:
    _DEST _CONSOLE
    PRINT "File error"; ERR; "with file:"; filename$
    _DEST 0
    RESUME NEXT

FileSuccess:
```

**Memory/Image Validation:**
```basic
imgHandle = _LOADIMAGE(filename$)
IF imgHandle < -1 THEN
    _DEST _CONSOLE
    PRINT "Successfully loaded:"; filename$
    PRINT "Image size:"; _WIDTH(imgHandle); "x"; _HEIGHT(imgHandle)
    _DEST 0
ELSE
    _LOGERROR "Failed to load image: " + filename$
END IF
```

**Array Bounds Checking:**
```basic
$ASSERTS:CONSOLE
IF index < LBOUND(array) OR index > UBOUND(array) THEN
    _ASSERT 0, "Array index out of bounds: " + STR$(index)
END IF
```

### Error Codes and Handling Reference

**Common QB64PE Error Codes:**
- `52` - Bad file name or number
- `53` - File not found
- `55` - File already open
- `62` - Input past end of file
- `64` - Bad file name
- `70` - Permission denied
- `75` - Path/File access error
- `76` - Path not found

**Debugging Console Setup Pattern:**
```basic
' Standard debugging setup for graphics programs
$CONSOLE
_DEST _CONSOLE
PRINT "Program started at: "; TIME$
PRINT "QB64PE Version: "; _OS$
_DEST 0

' Your main program here
' ...

' Debug output when needed
_DEST _CONSOLE
PRINT "Debug checkpoint reached"
_DEST 0
```

---

*Last Updated: December 24, 2024*
*Note: This debugging guide covers both traditional BASIC error handling and modern QB64PE features*
