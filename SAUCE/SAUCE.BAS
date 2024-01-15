''
' Sauce Reader (this will eventually also be a QB64_GJ_LIB module)
'
' This module works using 2 shared UDTs: 
'   SauceRecord - The actual sauce record structure fetched as BINARY with GET
'   SaucePacket - The filled in packet of sauce with friendly names and vars
'
' USAGE:
'   '$INCLUDE:'./SAUCE.BI'
'   SAUCE.InitPacket
'   SAUCE.GetRecord F$
'   IF SauceRecord.ID$ = "SAUCE" THEN
'       SAUCE.FillPacket
'       SAUCE.PrintPacket
'   ELSE
'       PRINT "Invalid or no Sauce header found."
'   END IF
'   '$INCLUDE:'./SAUCE.BM'
' 
' @see https://github.com/grymmjack/sauce
' @author Rick Christy <grymmjack@gmail.com>
'
'$INCLUDE:'SAUCE.BI'

' Choose an image file with dialog
DIM file_exts(1 TO 6) AS STRING
file_exts$(1) = ""
file_exts$(2) = ""
file_exts$(3) = ""
file_exts$(4) = ""
file_exts$(5) = ""
file_exts$(6) = ""
' bitmap types
file_exts$(1) = file_exts$(1) + "*.jpg|*.png|*.tga|*.bmp|*.psd|*.gif|"
file_exts$(1) = file_exts$(1) + "*.hdr|*.pic|*.pnm|*.pcx|*.svg|*.qoi|"
' character types
file_exts$(2) = file_exts$(2) + "*.asc|*.ans|*.rip|*.avt|*.html|"
file_exts$(2) = file_exts$(2) + "*.xb|*.xbin|*.bin|*.tnd|"
' source types
file_exts$(3) = file_exts$(3) + "*.c|*.h|*.cpp|*.bas|*.bi|*.bm|*.pas|"
file_exts$(3) = file_exts$(3) + "*.py|*.js|*.ts|*.rb|*.rs|"
file_exts$(3) = file_exts$(3) + "*.json|*.yml|*.yaml|*.toml|*.css|*.md|"
' video bitmap types
file_exts$(4) = file_exts$(4) + "*.fli|*.flc|*.gl|*.dl|*.avi|"
' vector types
file_exts$(5) = file_exts$(5) + "*.dxf|*.dwg|*.wpg|*.3ds|"
' audio types
file_exts$(6) = file_exts$(6) + "*.mod|*.669|*.stm|*.s3m|*.mtm|"
file_exts$(6) = file_exts$(6) + "*.far|*.ult|*.amf|*.dmf|*.okt|*.rol|*.cmf|"
file_exts$(6) = file_exts$(6) + "*.voc|*.wav|*.smp|*.pat|*.xm|*.it|*.hsc|*.mid"
DIM file_extensions AS STRING
file_extensions$ = ""
file_extensions$ = file_extensions$ + file_exts$(1) + file_exts$(2)
file_extensions$ = file_extensions$ + file_exts$(3) + file_exts$(4)
file_extensions$ = file_extensions$ + file_exts$(5) + file_exts$(6)

F$ = _OPENFILEDIALOG$( _
    "Choose a scene file", _
    , _
    file_extensions$, _
    "Scene Files", _
    -1 _
)
IF F$ = "" THEN SYSTEM ' image is required...

SAUCE.InitPacket
SAUCE.GetRecord F$
IF SauceRecord.ID$ = "SAUCE" THEN
    SAUCE.FillPacket
    SAUCE.PrintPacket
ELSE
    PRINT "Invalid or no Sauce header found."
END IF
SLEEP
SYSTEM

'$INCLUDE:'SAUCE.BM'
