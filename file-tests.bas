OPTION _EXPLICIT
'$DYNAMIC

'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BI'

REDIM file_list(0) AS STRING
REDIM sorted_file_list(0) AS STRING
DIM fs_root AS STRING

$CONSOLE:ONLY
_CONSOLE ON

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
    DIM AS STRING f, fn
    DIM AS LONG lb, ub
    f$ = _FILES$(filepath$)
    lb& = LBOUND(arr$)
    DO WHILE LEN(f$) > 0
        fn$ = _TRIM$(f$)
        IF fn$ <> "./" AND fn$ <> "../" AND fn$ <> ".DS_Store" THEN
            ub& = UBOUND(arr$)
            arr$(ub&) = filepath$ + f$
            REDIM _PRESERVE arr(lb& TO ub& + 1) AS STRING
        END IF
        f$ = _FILES$
    LOOP
    REDIM _PRESERVE arr(ub&) AS STRING
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/_GJ_LIB.BM'
