DO
    ' Keyboard handling
    DIM k AS STRING
    DIM AS INTEGER MMX, MMY, MW
    k$ = LCASE$(INKEY$)
    DO WHILE _MOUSEINPUT
        MMX = _MOUSEMOVEMENTX
        MMY = _MOUSEMOVEMENTY
        MW = _MOUSEWHEEL
        IF MMX <> 0 THEN
            LOCATE 1, 1 : PRINT SPACE$(50)
            LOCATE 1, 1 : PRINT "MMX:", MMX
        END IF
        IF MMY <> 0 THEN
            LOCATE 2, 1 : PRINT SPACE$(50)
            LOCATE 2, 1 : PRINT "MMY:", MMY
        END IF
        IF _MOUSEWHEEL <> 0 THEN
            LOCATE 3, 1 : PRINT SPACE$(50)
            LOCATE 3, 1 : PRINT "MW:", MW
        END IF
    LOOP
    IF k$ = CHR$(27) THEN EXIT DO
LOOP
SYSTEM