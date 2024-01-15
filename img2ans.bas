': This program uses
': InForm GUI engine for QB64-PE - v1.5.3
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

'$INCLUDE:'img2ans.bi'

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED ClearBT AS LONG
DIM SHARED ImagesToConvert AS LONG
DIM SHARED UseFilenameForTitleCB AS LONG
DIM SHARED pxFont80X50ModeRB AS LONG
DIM SHARED ExitBT AS LONG
DIM SHARED Sauce AS LONG
DIM SHARED IMG2ANS AS LONG
DIM SHARED IncludeSauceCB AS LONG
DIM SHARED ColorOptions AS LONG
DIM SHARED iCEColorsHighIntensityBGNoBlinCB AS LONG
DIM SHARED RGB24BitColorCB AS LONG
DIM SHARED FontOptions AS LONG
DIM SHARED pxFont80X25ModeRB AS LONG
DIM SHARED TitleTB AS LONG
DIM SHARED AuthorTB AS LONG
DIM SHARED GroupTB AS LONG
DIM SHARED CommentsTB AS LONG
DIM SHARED ConvertBT AS LONG
DIM SHARED ImagesList AS LONG
DIM SHARED BrowseBT AS LONG
DIM SHARED SauceRecordLB AS LONG
DIM SHARED TitleLB AS LONG
DIM SHARED AuthorLB AS LONG
DIM SHARED GroupLB AS LONG
DIM SHARED CommentsLB AS LONG
DIM SHARED IMG2ANSLB AS LONG

': External modules: ---------------------------------------------------------------
'$INCLUDE:'InForm\InForm.bi'
'$INCLUDE:'InForm\xp.uitheme'
'$INCLUDE:'img2ans.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad
    __UI_ValueChanged(UseFilenameForTitleCB&)   ' Update to reflect state
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
        CASE ClearBT
            ResetList ImagesList&
            REDIM ImageListFilenames(1 TO 1) AS STRING
            ToolTip(ImagesList&) = "Click Browse to select images to convert"

        CASE ImagesToConvert

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT
            SYSTEM

        CASE Sauce

        CASE IMG2ANS

        CASE IncludeSauceCB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT
            DIM stuff AS STRING
            stuff$ = GetImageFilesAsString$
            _MessageBox "Debug", "Images:\n\n" + stuff$, "info"

        CASE ImagesList
            UpdateImagesListToolTip

        CASE BrowseBT
            BrowseForImageFiles

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
        CASE ClearBT

        CASE ImagesToConvert

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE Sauce

        CASE IMG2ANS

        CASE IncludeSauceCB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

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
        CASE ClearBT

        CASE ImagesToConvert

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE Sauce

        CASE IMG2ANS

        CASE IncludeSauceCB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

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
        CASE ClearBT

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE IncludeSauceCB

        CASE ListBox1RB

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE ClearBT

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE IncludeSauceCB

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE ClearBT

        CASE ImagesToConvert

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE Sauce

        CASE IMG2ANS

        CASE IncludeSauceCB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

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
        CASE ClearBT

        CASE ImagesToConvert

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE Sauce

        CASE IMG2ANS

        CASE IncludeSauceCB

        CASE ColorOptions

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE FontOptions

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

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
        CASE ClearBT

        CASE UseFilenameForTitleCB

        CASE pxFont80X50ModeRB

        CASE ExitBT

        CASE IncludeSauceCB

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE pxFont80X25ModeRB

        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

        CASE ConvertBT

        CASE ImagesList

        CASE BrowseBT

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE TitleTB

        CASE AuthorTB

        CASE GroupTB

        CASE CommentsTB

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE UseFilenameForTitleCB
            IF Control(id&).Value THEN
                Control(TitleLB&).Hidden = True
                Control(TitleTB&).Hidden = True
            ELSE
                Control(TitleLB&).Hidden = False
                Control(TitleTB&).Hidden = False
            END IF

        CASE pxFont80X50ModeRB

        CASE IncludeSauceCB

        CASE iCEColorsHighIntensityBGNoBlinCB

        CASE RGB24BitColorCB

        CASE pxFont80X25ModeRB

        CASE ImagesList

    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'InForm/InForm.ui'
'$INCLUDE:'img2ans.bm'
