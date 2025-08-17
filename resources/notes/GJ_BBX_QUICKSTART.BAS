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
