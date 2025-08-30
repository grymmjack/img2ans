_TITLE "Emoji Display in QB64PE"
SCREEN _NEWIMAGE(800, 300, 32)

' Load a Unicode TTF font (use one that supports emojis, like Segoe UI Emoji)
emojiFont& = _LOADFONT("C:\\Users\\grymmjack\\AppData\\Local\\Microsoft\\Windows\\Fonts\\NotoEmoji-Regular.ttf", 48)
' emojiFont& = _LOADFONT("C:\\WINDOWS\\FONTS\\seguiemj.ttf", 48) ' Make sure this TTF file is present
_FONT emojiFont&

' Emoji Unicode character string
emoji$ = "A" + CHR$(10) + CHR$(13) + "😀😁😂🤖🐍🚀💻🧠B" + CHR$(10) + CHR$(13)


' Use _UPRINTSTRING to render Unicode emoji string
_PRINTMODE _KEEPBACKGROUND
_UPRINTSTRING (10, 10), emoji$, 800,8, emojiFont&, 0
_UPRINTSTRING (50, 50), STR$(EM_LOVE_LETTER), 800, 8, emojiFont&, 0

' Keep the window open
DO: 
    _LIMIT 1: 
LOOP UNTIL _KEYDOWN(27) 
SYSTEM