': This form was generated by
': InForm GUI engine for QB64-PE - v1.5.3
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2024) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------
$INCLUDEONCE
SUB __UI_LoadForm

    DIM __UI_NewID AS LONG, __UI_RegisterResult AS LONG

    'WINDOW
    __UI_NewID = __UI_NewControl(__UI_Type_Form, "IMG2ANS", 1308, 670, 0, 0, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "IMG2ANS"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 12)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CenteredWindow = True



    'H:HEADER
    __UI_NewID = __UI_NewControl(__UI_Type_Label, "H_IMG2ANSLB", 150, 28, 17, 10, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "IMG2ANS"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 16)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "H_VersionLB", 150, 23, 113, 10, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "V0.2"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "H_CodeIdeaLB", 150, 19, 1140, 10, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "CODE / IDEA BY:"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 10)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Align = __UI_Right
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "H_CodeIdeaAuthorLB", 150, 23, 1153, 25, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "Rick Christy (grymmjack)"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 10)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "H_LinksLB", 182, 20, 1120, 44, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "https://youtube.com/grymmjack"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 10)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle



    'SI:SOURCE IMAGE
    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SI_SourceImgLB", 150, 21, 17, 43, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "SOURCE IMAGE"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "SI_SourceImgBrowseButtonBT", 80, 23, 148, 43, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "&BROWSE"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "SI_SourceImgClearButtoNBT", 80, 23, 238, 43, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "&CLEAR"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "SI_SourceImgPB", 301, 217, 17, 78, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SI_SourceImgBrightnessLB", 100, 19, 17, 314, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "BRIGHTNESS"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "SI_SourceImgBrightnessSlider", 124, 40, 126, 314, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Max = 10
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Min = 0
    Control(__UI_NewID).Max = 100
    Control(__UI_NewID).Value = 50
    Control(__UI_NewID).Interval = 10

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "SI_SourceImgBrightnessTB", 50, 23, 268, 314, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "BRIGHTNESS VALUE"
    Text(__UI_NewID) = "50"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SI_SourceImgContrastLB", 100, 19, 17, 347, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "CONTRAST"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "SI_SourceImgContrastSlider", 124, 40, 126, 347, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Min = 0
    Control(__UI_NewID).Max = 100
    Control(__UI_NewID).Value = 50
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Interval = 10

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "SI_SourceImgContrastTB", 50, 23, 268, 347, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "CONTRAST VALUE"
    Text(__UI_NewID) = "50"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "SI_SourceImgPosterizeLB", 100, 19, 17, 384, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "POSTERIZE"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "SI_SourceImgPosterizeSlider", 124, 40, 126, 384, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Min = 0
    Control(__UI_NewID).Max = 100
    Control(__UI_NewID).Value = 0
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Interval = 10

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "SI_SourceImgPosterizeTB", 50, 23, 268, 384, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "POSTERIZE VALUE"
    Text(__UI_NewID) = "0"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1



    'DP:DESTINATION PALETTE
    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "DP_DestPalCB", 250, 23, 341, 43, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "&DESTINATION PALETTE"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "DP_DestPalPB", 301, 217, 341, 78, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = True
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_DropdownList, "DP_DestPalPalleteDL", 200, 23, 341, 316, 0)
    __UI_RegisterResult = 0
    'https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
    'https://en.wikipedia.org/wiki/List_of_color_palettes
    AddItem __UI_NewID, ""
    AddItem __UI_NewID, "EGA (16)"
    AddItem __UI_NewID, "CGA32 (32)"
    AddItem __UI_NewID, "CGA0-HIGH (4)"
    AddItem __UI_NewID, "CGA0-LOW (4)"
    AddItem __UI_NewID, "CGA1-HIGH (4)"
    AddItem __UI_NewID, "CGA1-LOW (4)"
    AddItem __UI_NewID, "CGA2-HIGH (4)"
    AddItem __UI_NewID, "CGA2-LOW (4)"
    AddItem __UI_NewID, "VGA (256)"
    AddItem __UI_NewID, "1BIT (2)"
    AddItem __UI_NewID, "2BIT (4)"
    AddItem __UI_NewID, "6BIT (64)"
    AddItem __UI_NewID, "AMSTRADCPC (26)"
    AddItem __UI_NewID, "ANSI32 (32)"
    AddItem __UI_NewID, "APPLE2-HIRES (6)"
    AddItem __UI_NewID, "APPLE2-LORES (16)"
    AddItem __UI_NewID, "ATARI2600 (128)"
    AddItem __UI_NewID, "ATARI-8BIT (256)"
    AddItem __UI_NewID, "BBCMICRO (16)"
    AddItem __UI_NewID, "BLOODMOON21 (9)"
    AddItem __UI_NewID, "C=64 (16)"
    AddItem __UI_NewID, "COLODORE (16)"
    AddItem __UI_NewID, "CYBERPUNK-NEONS (11)"
    AddItem __UI_NewID, "DAWNBRINGER-16 (16)"
    AddItem __UI_NewID, "DAWNBRINGER-32 (32)"
    AddItem __UI_NewID, "DAWNBRINGERS-8-COLOR (8)"
    AddItem __UI_NewID, "ENDESGA-16 (16)"
    AddItem __UI_NewID, "ENDESGA-32 (32)"
    AddItem __UI_NewID, "ENDESGA-36 (36)"
    AddItem __UI_NewID, "ENDESGA-64 (64)"
    AddItem __UI_NewID, "FAIRCHILD (8)"
    AddItem __UI_NewID, "GAMEBOY (4)"
    AddItem __UI_NewID, "GAMEBOY-BGB (4)"
    AddItem __UI_NewID, "HALLOWPUMPKIN (4)"
    AddItem __UI_NewID, "INK (5)"
    AddItem __UI_NewID, "INK-CRIMSON (10)"
    AddItem __UI_NewID, "INTELLIVISION (16)"
    AddItem __UI_NewID, "MS-WINDOWS (16)"
    AddItem __UI_NewID, "MSX (16)"
    AddItem __UI_NewID, "NES (55)"
    AddItem __UI_NewID, "PICO-8 (16)"
    AddItem __UI_NewID, "PICO-8-SECRET (32)"
    AddItem __UI_NewID, "PINEAPPLE-32 (32)"
    AddItem __UI_NewID, "QUAKE (244)"
    AddItem __UI_NewID, "SECAM (8)"
    AddItem __UI_NewID, "SEGA (64)"
    AddItem __UI_NewID, "SHOVEL-KNIGHT-NES (59)"
    AddItem __UI_NewID, "SYNTHEWAVE-CITY (8)"
    AddItem __UI_NewID, "TELETEXT (8)"
    AddItem __UI_NewID, "VINES-FLEXIBLE-LINEAR-RAMPS (38)"
    AddItem __UI_NewID, "ZXSPECTRUM (16)"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "DP_DestPalPalleteBrowseBT", 80, 23, 562, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "B&ROWSE"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "DP_DestPalPaletteColorsPB", 301, 54, 342, 353, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1



    'RC:RESIZE / CROP
    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "RC_ResizeCropCB", 250, 23, 666, 44, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "RESI&ZE / CROP"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "RC_ResizeCropPB", 301, 217, 666, 78, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "RC_ResizeCropWB", 50, 19, 670, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "WIDTH"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "RC_ResizeCropWTB", 50, 23, 725, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "WIDTH VALUE"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "RC_ResizeCropHLB", 50, 19, 670, 346, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "HEIGHT"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "RC_ResizeCropHTB", 50, 23, 725, 346, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "HEIGHT VALUE"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "RC_ResizeCropXLB", 20, 19, 798, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "X"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "RC_ResizeCropXTB", 50, 23, 815, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "X"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "RC_ResizeCrop80x25BT", 80, 23, 887, 316, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "80x25"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "RC_ResizeCrop80x50BT", 80, 23, 887, 346, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "80x50"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "RC_ResizeCrop132x100BT", 80, 23, 887, 376, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "132x100"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "RC_ResizeCropYLB", 20, 19, 798, 346, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "Y"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "RC_ResizeCropYTB", 50, 23, 815, 346, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "Y"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "RC_ResizeCropZoomLB", 30, 19, 670, 376, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "ZOOM"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TrackBar, "RC_ResizeCropZoomSlider", 142, 40, 725, 376, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).Max = 5
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Min = -5
    Control(__UI_NewID).Value = 0
    Control(__UI_NewID).Interval = 1



    'P:PREVIEW
    __UI_NewID = __UI_NewControl(__UI_Type_Label, "P_PreviewLB", 125, 23, 989, 44, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "PREVIEW"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_PictureBox, "P_PreviewPB", 301, 481, 989, 78, 0)
    __UI_RegisterResult = 0
    Control(__UI_NewID).Stretch = False
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Align = __UI_Center
    Control(__UI_NewID).VAlign = __UI_Middle
    Control(__UI_NewID).BorderSize = 1



    'S:SAUCE
    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "S_SauceFrame", 801, 121, 17, 438, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "SAUCE"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Value = 13
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "S_SauceTitleLB", 150, 23, 13, 25, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "TITLE"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "S_SauceTitleTB", 200, 23, 100, 25, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "TITLE"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "S_SauceAuthorLB", 150, 23, 13, 53, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "AUTHOR"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "S_SauceAuthorTB", 200, 23, 100, 53, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "AUTHOR"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "S_SauceGroupLB", 150, 23, 13, 81, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "GROUP"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "S_SauceGroupTB", 200, 23, 100, 81, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "GROUP"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "S_SauceCommentLB", 150, 23, 326, 25, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "COMMENT"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 14)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "S_SauceCommentTB", 210, 86, 413, 25, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "COMMENT"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "S_SauceFontSize8pxRB", 100, 23, 655, 25, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "8PX FONT"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Value = True

    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "S_SauceFontSize16pxRB", 100, 23, 655, 53, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "16PX FONT"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_CheckBox, "S_Sauce9pxWidthCB", 100, 23, 655, 81, __UI_GetID("S_SauceFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "9PX WIDTH"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "S_ColorsFrame", 138, 121, 829, 438, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "COLORS"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Value = 1
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "S_SauceiCEColorsRB", 100, 23, 23, 25, __UI_GetID("S_ColorsFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "iCE COLORS"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Value = True

    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "S_SauceRGBColorsRB", 100, 23, 23, 53, __UI_GetID("S_ColorsFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "RGB Colors"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True



    'E:EXPORT
    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "E_ExportToImgSrcDirRB", 300, 23, 17, 580, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "EXPORT TO IMAGE SOURCE DIRECTORY"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).Value = True

    __UI_NewID = __UI_NewControl(__UI_Type_RadioButton, "E_ExportToDirRB", 200, 23, 341, 580, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "EXPORT TO DIRECTORY"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "E_ExportToDirTB", 295, 23, 507, 580, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "EXPORT TO DIRECTORY"
    Text(__UI_NewID) = _STARTDIR$
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "E_ExportToDirBrowseButtonBT", 40, 23, 810, 580, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "..."
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True    

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "E_ExportAsFileLB", 83, 18, 907, 583, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "AS FILENAME"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

    __UI_NewID = __UI_NewControl(__UI_Type_TextBox, "E_ExportAsFileTB", 300, 23, 990, 580, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "AS FILENAME"
    Text(__UI_NewID) = ""
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).CanHaveFocus = True
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Button, "E_ExportBT", 300, 32, 989, 626, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "&EXPORT"
    Control(__UI_NewID).Font = SetFont("./include/InForm-PE/InForm/resources/NotoMono-Regular.ttf", 16)
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).CanHaveFocus = True



    'ST:STATUS
    __UI_NewID = __UI_NewControl(__UI_Type_Frame, "ST_StatusFrame", 950, 32, 17, 626, 0)
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "STATUS"
    Control(__UI_NewID).HasBorder = True
    Control(__UI_NewID).Value = 1
    Control(__UI_NewID).BorderSize = 1

    __UI_NewID = __UI_NewControl(__UI_Type_Label, "ST_StatusLB", 945, 23, 7, 6, __UI_GetID("ST_StatusFrame"))
    __UI_RegisterResult = 0
    SetCaption __UI_NewID, "READY"
    Control(__UI_NewID).HasBorder = False
    Control(__UI_NewID).VAlign = __UI_Middle

END SUB



SUB __UI_AssignIDs
    'WINDOW
    IMG2ANS = __UI_GetID("IMG2ANS")

    'H:HEADER
    H_IMG2ANSLB = __UI_GetID("H_IMG2ANSLB")
    H_VersionLB = __UI_GetID("H_VersionLB")
    H_CodeIdeaLB = __UI_GetID("H_CodeIdeaLB")
    H_CodeIdeaAuthorLB = __UI_GetID("H_CodeIdeaAuthorL")
    H_LinksLB = __UI_GetID("H_LinksLB")

    'SI:SOURCE IMAGE
    SI_SourceImgLB = __UI_GetID("SI_SourceImgLB")
    SI_SourceImgBrowseButtonBT = __UI_GetID("SI_SourceImgBrowseButtonBT")
    SI_SourceImgClearButtonBT = __UI_GetID("SI_SourceImgClearButtonBT")
    SI_SourceImgPB = __UI_GetID("SI_SourceImgPB")
    SI_SourceImgBrightnessLB = __UI_GetID("SI_SourceImgBrightnessLB")
    SI_SourceImgBrightnessSlider = __UI_GetID("SI_SourceImgBrightnessSlider")
    SI_SourceImgBrightnessTB = __UI_GetID("SI_SourceImgBrightnessTB")
    SI_SourceImgContrastLB = __UI_GetID("SI_SourceImgContrastLB")
    SI_SourceImgContrastSlider = __UI_GetID("SI_SourceImgContrastSlider")
    SI_SourceImgContrastTB = __UI_GetID("SI_SourceImgContrastTB")
    SI_SourceImgPosterizeLB = __UI_GetID("SI_SourceImgPosterizeLB")
    SI_SourceImgPosterizeSlider = __UI_GetID("SI_SourceImgPosterizeSlider")
    SI_SourceImgPosterizeTB = __UI_GetID("SI_SourceImgPosterizeTB")

    'DP:DESTINATION PALETTE
    DP_DestPalCB = __UI_GetID("DP_DestPalCB")
    DP_DestPalPB = __UI_GetID("DP_DestPalPB")
    DP_DestPalPalleteDL = __UI_GetID("DP_DestPalPalleteDL")
    DP_DestPalPalleteBrowseBT = __UI_GetID("DP_DestPalPalleteBrowseBT")
    DP_DestPalPaletteColorsPB = __UI_GetID("DP_DestPalPaletteColorsPB")

    'RC:RESIZE / CROP
    RC_ResizeCropCB = __UI_GetID("RC_ResizeCropCB")
    RC_ResizeCropPB = __UI_GetID("RC_ResizeCropPB")
    RC_ResizeCropXLB = __UI_GetID("RC_ResizeCropXLB")
    RC_ResizeCropXTB = __UI_GetID("RC_ResizeCropXTB")
    RC_ResizeCrop80x25BT = __UI_GetID("RC_ResizeCrop80x25BT")
    RC_ResizeCrop80x50BT = __UI_GetID("RC_ResizeCrop80x50BT")
    RC_ResizeCrop132x100BT = __UI_GetID("RC_ResizeCrop132x100BT")
    RC_ResizeCropYLB = __UI_GetID("RC_ResizeCropYLB")
    RC_ResizeCropYTB = __UI_GetID("RC_ResizeCropYTB")
    RC_ResizeCropWLB = __UI_GetID("RC_ResizeCropWLB")
    RC_ResizeCropWTB = __UI_GetID("RC_ResizeCropWTB")
    RC_ResizeCropHLB = __UI_GetID("RC_ResizeCropHLB")
    RC_ResizeCropHTB = __UI_GetID("RC_ResizeCropHTB")
    RC_ResizeCropZoomLB = __UI_GetID("RC_ResizeCropZoomLB")
    RC_ResizeCropZoomSlider = __UI_GetID("RC_ResizeCropZoomSlider")

    'P:PREVIEW
    P_PreviewLB = __UI_GetID("P_PreviewLB")
    P_PreviewPB = __UI_GetID("P_PreviewPB")

    'S:SAUCE
    S_SauceFrame = __UI_GetID("S_SauceFrame")
    S_SauceTitleLB = __UI_GetID("S_SauceTitleLB")
    S_SauceTitleTB = __UI_GetID("S_SauceTitleTB")
    S_SauceAuthorLB = __UI_GetID("S_SauceAuthorLB")
    S_SauceAuthorTB = __UI_GetID("S_SauceAuthorTB")
    S_SauceGroupLB = __UI_GetID("S_SauceGroupLB")
    S_SauceGroupTB = __UI_GetID("S_SauceGroupTB")
    S_SauceCommentLB = __UI_GetID("S_SauceCommentLB")
    S_SauceCommentTB = __UI_GetID("S_SauceCommentTB")
    S_SauceFontSize8pxRB = __UI_GetID("S_SauceFontSize8pxRB")
    S_SauceFontSize16pxRB = __UI_GetID("S_SauceFontSize16pxRB")
    S_Sauce9pxWidthCB = __UI_GetID("S_Sauce9pxWidthCB")
    S_ColorsFrame = __UI_GetID("S_ColorsFrame")
    S_SauceiCEColorsRB = __UI_GetID("S_SauceiCEColorsRB")
    S_SauceRGBColorsRB = __UI_GetID("S_SauceRGBColorsRB")

    'E:EXPORT
    E_ExportToImgSrcDirRB = __UI_GetID("E_ExportToImgSrcDirRB")
    E_ExportToDirRB = __UI_GetID("E_ExportToDirRB")
    E_ExportToDirTB = __UI_GetID("E_ExportToDirTB")
    E_ExportToDirBrowseButtonBT = __UI_GetID("E_ExportToDirBrowseButtonBT")    
    E_ExportAsFileLB = __UI_GetID("E_ExportAsFileLB")
    E_ExportAsFileTB = __UI_GetID("E_ExportAsFileTB")

    'ST:STATUS
    ST_StatusFrame = __UI_GetID("ST_StatusFrame")
    ST_StatusLB = __UI_GetID("ST_StatusLB")
END SUB
