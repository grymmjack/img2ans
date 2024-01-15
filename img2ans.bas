': This program uses
': InForm GUI engine for QB64-PE - v1.5.3
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED SauceRecord AS LONG
DIM SHARED SauceRecordCB AS LONG
DIM SHARED ListBox1RB AS LONG
DIM SHARED ColorOptions AS LONG
DIM SHARED iCEColorsHighIntensityBGNoBlinkCB AS LONG
DIM SHARED RGB24BitColorCB AS LONG
DIM SHARED FontOptions AS LONG
DIM SHARED radioFontSize AS LONG
DIM SHARED pxFont80X25ModeRB AS LONG
DIM SHARED ListBox12 AS LONG
DIM SHARED CheckBox1 AS LONG
DIM SHARED TitleTB AS LONG
DIM SHARED AuthorTB AS LONG
DIM SHARED GroupTB AS LONG
DIM SHARED TextBox1 AS LONG
DIM SHARED ConvertBT AS LONG
DIM SHARED ListBox1 AS LONG
DIM SHARED ImagesToConvertLB AS LONG
DIM SHARED BrowseBT AS LONG
DIM SHARED SauceRecordLB AS LONG
DIM SHARED TitleLB AS LONG
DIM SHARED AuthorLB AS LONG
DIM SHARED GroupLB AS LONG
DIM SHARED CommentsLB AS LONG
DIM SHARED IMG2ANSLB AS LONG
DIM SHARED IMG2ANS AS LONG

': External modules: ---------------------------------------------------------------
'$INCLUDE:'InForm\InForm.bi'
'$INCLUDE:'InForm\xp.uitheme'
'$INCLUDE:'img2ans.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad

END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 60 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%

END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    SELECT CASE id
        CASE SauceRecord

        CASE SauceRecordCB

        CASE ListBox1RB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE ListBox12

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE ImagesToConvertLB

        CASE BrowseBT

        CASE SauceRecordLB

        CASE TitleLB

        CASE AuthorLB

        CASE GroupLB

        CASE CommentsLB

        CASE IMG2ANSLB

        CASE IMG2ANS

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE SauceRecord

        CASE SauceRecordCB

        CASE ListBox1RB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE ListBox12

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE ImagesToConvertLB

        CASE BrowseBT

        CASE SauceRecordLB

        CASE TitleLB

        CASE AuthorLB

        CASE GroupLB

        CASE CommentsLB

        CASE IMG2ANSLB

        CASE IMG2ANS

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE SauceRecord

        CASE SauceRecordCB

        CASE ListBox1RB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE ListBox12

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE ImagesToConvertLB

        CASE BrowseBT

        CASE SauceRecordLB

        CASE TitleLB

        CASE AuthorLB

        CASE GroupLB

        CASE CommentsLB

        CASE IMG2ANSLB

        CASE IMG2ANS

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE SauceRecordCB

        CASE ListBox1RB

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE SauceRecordCB

        CASE ListBox1RB

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE SauceRecord

        CASE SauceRecordCB

        CASE ListBox1RB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE ListBox12

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE ImagesToConvertLB

        CASE BrowseBT

        CASE SauceRecordLB

        CASE TitleLB

        CASE AuthorLB

        CASE GroupLB

        CASE CommentsLB

        CASE IMG2ANSLB

        CASE IMG2ANS

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE SauceRecord

        CASE SauceRecordCB

        CASE ListBox1RB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE ListBox12

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE ImagesToConvertLB

        CASE BrowseBT

        CASE SauceRecordLB

        CASE TitleLB

        CASE AuthorLB

        CASE GroupLB

        CASE CommentsLB

        CASE IMG2ANSLB

        CASE IMG2ANS

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        CASE SauceRecordCB

        CASE ListBox1RB

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE CheckBox1

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

        CASE ConvertBT

        CASE ListBox1

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE TextBox1

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE SauceRecordCB

        CASE ListBox1RB

        CASE iCEColorsHighIntensityBGNoBlinkCB

        CASE RGB24BitColorCB

        CASE radioFontSize

        CASE pxFont80X25ModeRB

        CASE CheckBox1

        CASE ListBox1

    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'InForm/InForm.ui'
