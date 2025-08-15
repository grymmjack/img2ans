' core/sauce_wrap.bas — tiny wrapper; uses include/SAUCE if present
'$INCLUDE:'sauce_wrap.bi'

' NOTE: This expects you to have `$INCLUDE:'include/SAUCE/SAUCE.BI'` prior in your caller,
' so the SAUCE namespace is available. If not available, this will no-op.

SUB WriteSauceForAnsi (outPath$, title$, author$, group$, cols AS INTEGER, rows AS INTEGER)
    ON ERROR GOTO NoSauce
    ' Append EOF 0x1A if not present
    DIM h AS LONG: h = FREEFILE
    OPEN outPath$ FOR BINARY AS #h
    IF LOF(h) = 0 THEN CLOSE #h: EXIT SUB
    GET #h, LOF(h), CVL(0) ' touch
    CLOSE #h

    ' Initialize & write SAUCE
    SAUCE.InitPacket
    SaucePacket.Title$ = LEFT$(title$, 35)
    SaucePacket.Author$ = LEFT$(author$, 20)
    SaucePacket.Group$ = LEFT$(group$, 20)
    SaucePacket.DataType = 1     ' ASCII
    SaucePacket.FileType = 1     ' ANSi
    SaucePacket.TInfo1 = cols
    SaucePacket.TInfo2 = rows
    SAUCE.AppendRecord outPath$
    EXIT SUB
NoSauce:
    ' Silently ignore if SAUCE module isn't available
    RESUME Next_
Next_:
END SUB
