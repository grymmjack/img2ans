$INCLUDEONCE
' core/palette.bi — palette loading & nearest-color lookup (QB64-PE)

' Public state
DIM SHARED PalCount AS INTEGER
DIM SHARED PalR() AS INTEGER, PalG() AS INTEGER, PalB() AS INTEGER
DIM SHARED PalName$

DECLARE FUNCTION LoadGimpPalette%% (path$)
DECLARE FUNCTION NearestIndex%% (r AS INTEGER, g AS INTEGER, b AS INTEGER, _
                                 useSRGB AS _BYTE)
