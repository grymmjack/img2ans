DEFINT

' DIM AS _UNSIGNED _BYTE b
' DIM AS _UNSIGNED INTEGER i
' DIM AS _UNSIGNED LONG l
' DIM AS SINGLE s
' DIM AS DOUBLE d
' DIM AS _INTEGER64 i64
' DIM AS _UNSIGNED _INTEGER64 ui64

b = 255
i = 65535
l = 1024000000
s = 1.21
d = 1.234567890
i64 = -9223372036854775808
ui64 = 1844674407370955161

PRINT "[" + n$(b) + "]"
PRINT "[" + n$(i) + "]"
PRINT "[" + n$(l) + "]"
PRINT "[" + n$(s) + "]"
PRINT "[" + n$(d) + "]"
PRINT "[" + n$(i64) + "]"
PRINT "[" + n$(ui64) + "]"

FUNCTION n$(value&&)
    n$ = _TRIM$(STR$(value&&))
END FUNCTION