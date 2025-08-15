$INCLUDEONCE
' core/ansi_writer.bi — build ANSI strings efficiently (QB64-PE)

TYPE AnsiState
    curFG AS INTEGER
    curBG AS INTEGER
    useICE AS _BYTE ' allow bright backgrounds
END TYPE

DECLARE SUB AnsiInit (BYREF st AS AnsiState, useICE AS _BYTE)
DECLARE FUNCTION SgrFG$ (idx AS INTEGER)
DECLARE FUNCTION SgrBG$ (idx AS INTEGER, useICE AS _BYTE)
DECLARE SUB EmitCell (BYREF st AS AnsiState, glyph AS INTEGER, fgIdx AS INTEGER, bgIdx AS INTEGER, BYREF buf$)
DECLARE SUB EmitReset (BYREF buf$)
