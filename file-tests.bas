'$DYNAMIC
'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BI'
$CONSOLE:ONLY
_CONSOLE ON

OPTION _EXPLICIT
REDIM file_list(0) AS STRING
REDIM sorted_file_list(0) AS STRING
DIM fs_root AS STRING
DIM i AS INTEGER
fs_root$ = _FULLPATH$(".") + "resources/images/tests-external/"

CALL files_to_array(fs_root$, file_list$())
PRINT DUMP.string_array$(file_list$(), "file_list")

CALL ARR_STR.sort(file_list$(), sorted_file_list$())
PRINT DUMP.string_array$(sorted_file_list$(), "sorted_file_list")

' TODO: FIX the unused first index in the sort stuff.

' PRINT "TOTAL FILES:", UBOUND(sorted_file_list$) - LBOUND(sorted_file_list$)
' PRINT "sorted_file_list$(0) = " + sorted_file_list$(0)


''
' Returns all the files found in filepath as an array of strings
' @param STRING filepath$ Path, and spec (wildcards OK) to include files from
' @param STRING ARRAY arr$() Array to populate with filenames
'
SUB files_to_array(filepath$, arr$())
    DIM f AS STRING
    DIM ub AS LONG
    f$ = _FILES$(filepath$)
    DO WHILE LEN(f$) > 0
        IF _
            _TRIM$(f$) <> "" AND _
            _TRIM$(f$) <> "./" AND _
            _TRIM$(f$) <> "../" AND _
            _TRIM$(f$) <> ".DS_Store" THEN
            ub& = UBOUND(arr$)
            arr$(ub&) = filepath$ + f$
            REDIM _PRESERVE arr(ub& + 1) AS STRING
        END IF
        f$ = _FILES$
    LOOP
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BM'
