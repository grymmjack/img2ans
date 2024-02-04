': This program uses
': InForm GUI engine for QB64-PE - v1.5.3
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
'WINDOW
DIM SHARED IMG2ANS AS LONG

'H:HEADER
DIM SHARED H_IMG2ANSLB AS LONG
DIM SHARED H_VersionLB AS LONG
DIM SHARED H_CodeIdeaLB AS LONG
DIM SHARED H_CodeIdeaAuthorLB AS LONG
DIM SHARED H_LinksLB AS LONG

'SI:SOURCE IMAGE
DIM SHARED SI_SourceImgLB AS LONG
DIM SHARED SI_SourceImgBrowseButtonBT AS LONG
DIM SHARED SI_SourceImgClearButtonBT AS LONG
DIM SHARED SI_SourceImgPB AS LONG
DIM SHARED SI_SourceImgBrightnessLB AS LONG
DIM SHARED SI_SourceImgBrightnessSlider AS LONG
DIM SHARED SI_SourceImgBrightnessTB AS LONG
DIM SHARED SI_SourceImgContrastLB AS LONG
DIM SHARED SI_SourceImgContrastSlider AS LONG
DIM SHARED SI_SourceImgContrastTB AS LONG
DIM SHARED SI_SourceImgPosterizeLB AS LONG
DIM SHARED SI_SourceImgPosterizeSlider AS LONG
DIM SHARED SI_SourceImgPosterizeTB AS LONG

'DP:DESTINATION PALETTE
DIM SHARED DP_DestPalCB AS LONG
DIM SHARED DP_DestPalPB AS LONG
DIM SHARED DP_DestPalPalleteDL AS LONG
DIM SHARED DP_DestPalPalleteBrowseBT AS LONG
DIM SHARED DP_DestPalPaletteColorsPB AS LONG

'RC:RESIZE / CROP
DIM SHARED RC_ResizeCropCB AS LONG
DIM SHARED RC_ResizeCropPB AS LONG
DIM SHARED RC_ResizeCropXLB AS LONG
DIM SHARED RC_ResizeCropXTB AS LONG
DIM SHARED RC_ResizeCropYLB AS LONG
DIM SHARED RC_ResizeCropYTB AS LONG
DIM SHARED RC_ResizeCropWLB AS LONG
DIM SHARED RC_ResizeCropWTB AS LONG
DIM SHARED RC_ResizeCropHLB AS LONG
DIM SHARED RC_ResizeCropHTB AS LONG

'P:PREVIEW
DIM SHARED P_PreviewLB AS LONG
DIM SHARED P_PreviewPB AS LONG

'S:SAUCE
DIM SHARED S_SauceFrame AS LONG
DIM SHARED S_SauceTitleLB AS LONG
DIM SHARED S_SauceTitleTB AS LONG
DIM SHARED S_SauceAuthorLB AS LONG
DIM SHARED S_SauceAuthorTB AS LONG
DIM SHARED S_SauceGroupLB AS LONG
DIM SHARED S_SauceGroupTB AS LONG
DIM SHARED S_SauceCommentLB AS LONG
DIM SHARED S_SauceCommentTB AS LONG
DIM SHARED S_SauceFontSize8pxRB AS LONG
DIM SHARED S_SauceFontSize16pxRB AS LONG
DIM SHARED S_Sauce9pxWidthCB AS LONG
DIM SHARED S_SauceiCEColorsCB AS LONG
DIM SHARED S_SauceRGBColorsCB AS LONG

'E:EXPORT
DIM SHARED E_ExportToImgSrcDirRB AS LONG
DIM SHARED E_ExportToDirRB AS LONG
DIM SHARED E_ExportToDirTB AS LONG
DIM SHARED E_ExportToDirBrowseButtonBT AS LONG
DIM SHARED E_ExportAsFileLB AS LONG
DIM SHARED E_ExportAsFileTB AS LONG
DIM SHARED E_ExportBT AS LONG

'ST:STATUS
DIM SHARED ST_StatusFrame AS LONG
DIM SHARED ST_StatusLB AS LONG

': External modules: ---------------------------------------------------------------
'$INCLUDE:'IMG2ANS.BI'
'$INCLUDE:'include/InForm-PE/InForm/InForm.bi'
'$INCLUDE:'include/InForm-PE/InForm/xp.uitheme'
'$INCLUDE:'IMG2ANS.FRM'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad
    __UI_DefaultButtonID = SI_SourceImgBrowseButtonBT
END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 60 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%
    _LIMIT 60
    SetFrameRate 60

    ' Mouse input loop
    IF __UI_HasInput%% THEN
        ' Update mouse properties from InForm-PE READ-ONLY
        IMOUSE_update

        ' Log the mouse action
        IF SourceIMG.has_mouse%% THEN
            IF MOUSE.dragging%% = TRUE THEN
                console.box "DRAGGING", BRIGHT_GREEN
            END IF
            IF MOUSE.dropping%% THEN
                console.box "DROPPING", BRIGHT_RED
            END IF
            IF MOUSE.w_up%% OR MOUSE.w_down%% THEN
                console.box "MOUSEWHEEL=" + _TRIM$(STR$(MOUSE.w_raw%)), CYAN
            END IF
        END IF


    END If

END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT 
            CALL LoadImageIntoPB(SourceIMG, SI_SourceImgPB)
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgPB
            SetImgFocus SI_SourceImgPB
        CASE SI_SourceImgBrightnessLB
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastLB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeLB
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPB
            SetImgFocus DP_DestPalPB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropPB
            SetImgFocus RC_ResizeCropPB
        CASE RC_ResizeCropXLB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYLB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWLB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHLB
        CASE RC_ResizeCropHTB

        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB
            SetImgFocus P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_SauceTitleLB
        CASE S_SauceTitleTB
        CASE S_SauceAuthorLB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupLB
        CASE S_SauceGroupTB
        CASE S_SauceCommentLB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgPB
            CALL console.log("Entering SourceImg")
            SourceIMG.has_mouse%% = TRUE
        CASE SI_SourceImgBrightnessLB
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastLB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeLB
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropPB
        CASE RC_ResizeCropXLB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYLB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWLB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHLB
        CASE RC_ResizeCropHTB

        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_SauceTitleLB
        CASE S_SauceTitleTB
        CASE S_SauceAuthorLB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupLB
        CASE S_SauceGroupTB
        CASE S_SauceCommentLB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgPB
            CALL console.log("Leaving SourceImg")
            SourceIMG.has_mouse%% = FALSE
        CASE SI_SourceImgBrightnessLB
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastLB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeLB
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropPB
        CASE RC_ResizeCropXLB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYLB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWLB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHLB
        CASE RC_ResizeCropHTB

        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_SauceTitleLB
        CASE S_SauceTitleTB
        CASE S_SauceAuthorLB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupLB
        CASE S_SauceGroupTB
        CASE S_SauceCommentLB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeSlider

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHTB

        'S:SAUCE
        CASE S_SauceTitleTB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupTB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeSlider

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHTB

        'S:SAUCE
        CASE S_SauceTitleTB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupTB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgPB
            CALL console.log("MOUSEDOWN on SourceImg")
        CASE SI_SourceImgBrightnessLB
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastLB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeLB
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropPB
        CASE RC_ResizeCropXLB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYLB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWLB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHLB
        CASE RC_ResizeCropHTB

        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_SauceTitleLB
        CASE S_SauceTitleTB
        CASE S_SauceAuthorLB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupLB
        CASE S_SauceGroupTB
        CASE S_SauceCommentLB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgPB
            CALL console.log("MOUSEUP on SourceImg")
        CASE SI_SourceImgBrightnessLB
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastLB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeLB
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropPB
        CASE RC_ResizeCropXLB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYLB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWLB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHLB
        CASE RC_ResizeCropHTB

        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_SauceTitleLB
        CASE S_SauceTitleTB
        CASE S_SauceAuthorLB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupLB
        CASE S_SauceGroupTB
        CASE S_SauceCommentLB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT        

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrowseButtonBT
        CASE SI_SourceImgClearButtonBT
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeSlider

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPalleteDL
        CASE DP_DestPalPalleteBrowseBT
        CASE DP_DestPalPaletteColorsPB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHTB

        'S:SAUCE
        CASE S_SauceTitleTB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupTB
        CASE S_SauceCommentTB
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportAsFileTB

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastTB

        'RC:RESIZE / CROP
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWTB
        CASE RC_ResizeCropHTB

        'S:SAUCE
        CASE S_SauceTitleTB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupTB
        CASE S_SauceCommentTB

        'E:EXPORT
        CASE E_ExportToDirTB
        CASE E_ExportAsFileTB

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrightnessSlider
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgPosterizeSlider

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
        CASE DP_DestPalPalleteDL

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB

        'S:SAUCE
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsCB
        CASE S_SauceRGBColorsCB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB

        'ST:STATUS
        CASE ST_StatusFrame
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'include/InForm-PE/InForm/InForm.ui'
'$INCLUDE:'IMG2ANS.BM'
