': This program uses
': InForm GUI engine for QB64-PE - v1.5.3
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

_ALLOWFULLSCREEN _OFF

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
DIM SHARED RC_ResizeCrop80x25BT AS LONG
DIM SHARED RC_ResizeCrop80x50BT AS LONG
DIM SHARED RC_ResizeCrop132x100BT AS LONG
DIM SHARED RC_ResizeCropYLB AS LONG
DIM SHARED RC_ResizeCropYTB AS LONG
DIM SHARED RC_ResizeCropWLB AS LONG
DIM SHARED RC_ResizeCropWTB AS LONG
DIM SHARED RC_ResizeCropHLB AS LONG
DIM SHARED RC_ResizeCropHTB AS LONG
DIM SHARED RC_ResizeCropZoomLB AS LONG
DIM SHARED RC_ResizeCropZoomSlider AS LONG

'P:PREVIEW
DIM SHARED P_PreviewLB AS LONG
DIM SHARED P_PreviewPB AS LONG

'S:SAUCE
DIM SHARED S_SauceFrame AS LONG
DIM SHARED S_ColorsFrame AS LONG
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
DIM SHARED S_SauceiCEColorsRB AS LONG
DIM SHARED S_SauceRGBColorsRB AS LONG

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
'$INCLUDE:'include/SAUCE/SAUCE.BI'
'$INCLUDE:'core/palette.bi'
'$INCLUDE:'core/cellmap.bi'
'$INCLUDE:'core/ansi_writer.bi'
'$INCLUDE:'core/convert.bi'
'$INCLUDE:'core/sauce_wrap.bi'
'$INCLUDE:'include/InForm-PE/InForm/InForm.bi'
'$INCLUDE:'include/InForm-PE/InForm/xp.uitheme'
'$INCLUDE:'IMG2ANS.FRM'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad
    __UI_DefaultButtonID = SI_SourceImgBrowseButtonBT
    InitializeAppState
END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 60 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%

    ' An integer 2D vector
    TYPE Vector2LType
        x AS LONG
        y AS LONG
    END TYPE

    ' A 2D rectangle
    TYPE RectangleLType
        a AS Vector2LType ' left-top
        b AS Vector2LType ' right-bottom
    END TYPE

    ' This keeps all related stuff neatly considated
    TYPE MouseManagerType
        position AS Vector2LType ' mouse position
        leftButton AS _BYTE ' raw mouse left button
        rightButton AS _BYTE ' raw mouse right button
        leftButtonDown AS _BYTE ' mouse left button held down?
        rightButtonDown AS _BYTE ' mouse right button held down?
        leftClicked AS _BYTE ' If this is true mouseLeftButtonClickedRectangle is the rectangle where the click happened
        rightClicked AS _BYTE ' If this is true mouseRightButtonClickedRectangle is the rectangle where the click happened
        leftButtonClickedRectangle AS RectangleLType ' the rectangle where the mouse left button was clicked
        rightButtonClickedRectangle AS RectangleLType ' the rectangle where the mouse left button was clicked
        wheel AS LONG
    END TYPE

    ' These are a rectangle region the represent click event
    STATIC MouseManager AS MouseManagerType

    ' Mouse input loop
    IF __UI_HasInput THEN
        ' Mouse input handling (thanks @a740g!)
        IMOUSE_update

        ' Capture raw mouse position
        MouseManager.position.x = __UI_MouseLeft
        MouseManager.position.y = __UI_MouseTop

        ' Capture raw mouse button state
        MouseManager.leftButton = __UI_MouseButton1
        MouseManager.rightButton = __UI_MouseButton2

        ' Capure raw wheel info
        MouseManager.wheel = __UI_MouseWheel

        ' Check if the left button were previously held down and update the up position if released
        IF NOT MouseManager.leftButton AND MouseManager.leftButtonDown THEN
            MouseManager.leftButtonDown = FALSE
            MouseManager.leftButtonClickedRectangle.b = MouseManager.position
            MouseManager.leftClicked = TRUE
        END IF

        ' Check if the button were previously held down and update the up position if released
        IF NOT MouseManager.rightButton AND MouseManager.rightButtonDown THEN
            MouseManager.rightButtonDown = FALSE
            MouseManager.rightButtonClickedRectangle.b = MouseManager.position
            MouseManager.rightClicked = TRUE
        END IF

        ' Check if the mouse button was pressed and update the down position
        IF MouseManager.leftButton AND NOT MouseManager.leftButtonDown THEN
            MouseManager.leftButtonDown = TRUE
            MouseManager.leftButtonClickedRectangle.a = MouseManager.position
            MouseManager.leftClicked = FALSE
        END IF

        ' Check if the mouse button was pressed and update the down position
        IF MouseManager.rightButton AND NOT MouseManager.rightButtonDown THEN
            MouseManager.rightButtonDown = TRUE
            MouseManager.rightButtonClickedRectangle.a = MouseManager.position
            MouseManager.rightClicked = FALSE
        END IF

        ' Log the mouse action
        IF MouseManager.leftButtonDown THEN
            console.box "DRAGGING", 10
        END IF

        IF MouseManager.leftClicked THEN
            console.box "DROPPING", 12
            console.box "Rect = (" + _TRIM$(STR$(MouseManager.LeftButtonClickedRectangle.a.x)) + "," + _
                _TRIM$(STR$(MouseManager.LeftButtonClickedRectangle.a.y)) + ") - (" + _
                _TRIM$(STR$(MouseManager.LeftButtonClickedRectangle.b.x)) + "," + _
                _TRIM$(STR$(MouseManager.LeftButtonClickedRectangle.a.y)) + ")", 12

            MouseManager.leftClicked = FALSE ' consume the click event!
        END IF

        IF MouseManager.wheel <> 0 THEN
            console.box "MOUSEWHEEL=" + _TRIM$(STR$(MouseManager.wheel)), 3
        END IF
    END IF
END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    DIM pal$ AS STRING
    DIM exportDir$ AS STRING
    SELECT CASE id
        'H:HEADER
        CASE H_IMG2ANSLB
            open_url_in_browser "https://github.com/grymmjack/img2ans"
        CASE H_VersionLB
        CASE H_CodeIdeaLB
        CASE H_CodeIdeaAuthorLB
        CASE H_LinksLB
            open_url_in_browser "https://www.youtube.com/grymmjack"

        'SI:SOURCE IMAGE
        CASE SI_SourceImgLB
        CASE SI_SourceImgBrowseButtonBT 
            CALL LoadImageIntoPB( _
                SourceIMG, _
                SI_SourceImgPB, _
                _STARTDIR$ + "/resources/images/tests-external/" _
            )
        CASE SI_SourceImgClearButtonBT
            InitializeAppState
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
            ChangeDestPal
        CASE DP_DestPalPB
            SetImgFocus DP_DestPalPB
        CASE DP_DestPalPalleteDL
            ChangeDestPal
        CASE DP_DestPalPalleteBrowseBT
            pal$ = BrowseForGPLFile$(_STARTDIR$ + "/resources/palettes/")
            IF LEN(pal$) THEN LoadGPLFile pal$
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
        CASE RC_ResizeCrop80x25BT
            SetCropSize 80, 25
        CASE RC_ResizeCrop80x50BT
            SetCropSize 80, 50
        CASE RC_ResizeCrop132x100BT        
            SetCropSize 132, 100
 
        'P:PREVIEW
        CASE P_PreviewLB
        CASE P_PreviewPB
            SetImgFocus P_PreviewPB

        'S:SAUCE
        CASE S_SauceFrame
        CASE S_ColorsFrame
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportToDirBrowseButtonBT
            exportDir$ = BrowseForExportDir$(Text(E_ExportToDirTB))
            IF LEN(exportDir$) THEN
                Text(E_ExportToDirTB) = EnsureTrailingSlash$(exportDir$)
                AppSettings.outputDir$ = EnsureTrailingSlash$(exportDir$)
                Control(E_ExportToDirRB).Value = TRUE
            END IF
        CASE E_ExportAsFileLB
        CASE E_ExportAsFileTB
        CASE E_ExportBT
            PerformExport

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
        CASE S_ColorsFrame
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
        CASE S_ColorsFrame
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
            Control(SI_SourceImgBrightnessSlider).Value = clamp_int(INT(VAL(Text(id))), 0, 100)
        CASE SI_SourceImgContrastSlider
        CASE SI_SourceImgContrastTB
            Control(SI_SourceImgContrastSlider).Value = clamp_int(INT(VAL(Text(id))), 0, 100)
        CASE SI_SourceImgPosterizeSlider
        CASE SI_SourceImgPosterizeTB
            Control(SI_SourceImgPosterizeSlider).Value = clamp_int(INT(VAL(Text(id))), 0, 100)

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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
        CASE S_ColorsFrame
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
        CASE S_ColorsFrame
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

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
    console.box CHR$(__UI_KeyHit), 14
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
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB
        CASE E_ExportToDirTB
        CASE E_ExportAsFileTB

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    DIM newCols AS INTEGER
    DIM newRows AS INTEGER
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrightnessTB
            TextboxToSlider SI_SourceImgBrightnessTB, SI_SourceImgBrightnessSlider, 0, 100
        CASE SI_SourceImgContrastTB
            TextboxToSlider SI_SourceImgContrastTB, SI_SourceImgContrastSlider, 0, 100
        CASE SI_SourceImgPosterizeTB
            TextboxToSlider SI_SourceImgPosterizeTB, SI_SourceImgPosterizeSlider, 0, 100

        'RC:RESIZE / CROP
        CASE RC_ResizeCropXTB
        CASE RC_ResizeCropYTB
        CASE RC_ResizeCropWTB
            newCols = VAL(Text(RC_ResizeCropWTB))
            IF newCols <= 0 THEN newCols = 1
            AppSettings.cols = newCols
        CASE RC_ResizeCropHTB
            newRows = VAL(Text(RC_ResizeCropHTB))
            IF newRows <= 0 THEN newRows = 1
            AppSettings.rows = newRows

        'S:SAUCE
        CASE S_SauceTitleTB
        CASE S_SauceAuthorTB
        CASE S_SauceGroupTB
        CASE S_SauceCommentTB

        'E:EXPORT
        CASE E_ExportToDirTB
            AppSettings.outputDir$ = Text(E_ExportToDirTB)
        CASE E_ExportAsFileTB
            AppSettings.outputFile$ = Text(E_ExportAsFileTB)

    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        'SI:SOURCE IMAGE
        CASE SI_SourceImgBrightnessSlider
            SliderToTextbox SI_SourceImgBrightnessSlider, SI_SourceImgBrightnessTB
        CASE SI_SourceImgContrastSlider
            SliderToTextbox SI_SourceImgContrastSlider, SI_SourceImgContrastTB
        CASE SI_SourceImgPosterizeSlider
            SliderToTextbox SI_SourceImgPosterizeSlider, SI_SourceImgPosterizeTB

        'DP:DESTINATION PALETTE
        CASE DP_DestPalCB
            ChangeDestPal
        CASE DP_DestPalPalleteDL
            ChangeDestPal

        'RC:RESIZE / CROP
        CASE RC_ResizeCropCB

        'S:SAUCE
        CASE S_SauceFontSize8pxRB
        CASE S_SauceFontSize16pxRB
        CASE S_Sauce9pxWidthCB
        CASE S_SauceiCEColorsRB
        CASE S_SauceRGBColorsRB

        'E:EXPORT
        CASE E_ExportToImgSrcDirRB
        CASE E_ExportToDirRB

        'ST:STATUS
        CASE ST_StatusLB

    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'include/SAUCE/SAUCE.BAS'
'$INCLUDE:'core/palette.bas'
'$INCLUDE:'core/cellmap.bas'
'$INCLUDE:'core/ansi_writer.bas'
'$INCLUDE:'core/convert.bas'
'$INCLUDE:'core/sauce_wrap.bas'
'$INCLUDE:'include/InForm-PE/InForm/InForm.ui'
'$INCLUDE:'IMG2ANS.BM'
