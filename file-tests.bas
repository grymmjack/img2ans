$Debug
'$DYNAMIC

OPTION _EXPLICIT
REDIM SHARED file_list(0) AS STRING
REDIM SHARED sorted_file_list(0) AS STRING
DIM fs_root AS STRING
DIM i AS INTEGER
fs_root$ = _FULLPATH$(".") + "resources/images/tests-external/"
WIDTH 160, 100

CALL files_to_array(fs_root$, file_list$())
CALL ARR_STR.sort(file_list$(), sorted_file_list$())
' TODO: FIX the unused first index in the sort stuff.

PRINT "TOTAL FILES:", UBOUND(sorted_file_list$) - LBOUND(sorted_file_list$)
FOR i%=LBOUND(sorted_file_list$) TO UBOUND(sorted_file_list$)
    PRINT "sorted_file_list$(" + _TRIM$(STR$(i%)) + ") = " + sorted_file_list$(i%)
    IF i% MOD 25 = 0 THEN SLEEP 'pause every 25 files
NEXT i%
PRINT "sorted_file_list$(0) = " + sorted_file_list$(0)


''
' Returns all the files found in filepath as an array of strings
' @param STRING filepath$ Path, and spec (wildcards OK) to include files from
' @param STRING ARRAY arr$() Array to populate with filenames
'
SUB files_to_array(filepath$, arr$())
    DIM f AS STRING
    f$ = _FILES$(filepath$)
    DO WHILE LEN(f$) > 0
        IF _TRIM$(f$) <> "./" AND _TRIM$(f$) <> "../" AND _TRIM$(f$) <> ".DS_Store" THEN
            arr$(UBOUND(arr$)) = filepath$ + f$
            REDIM _PRESERVE arr(UBOUND(arr$) + 1) AS STRING
        END IF
        f$ = _FILES$
    LOOP
END SUB

'$INCLUDE:'include/QB64_GJ_LIB/ARR/ARR_STR.BAS'
