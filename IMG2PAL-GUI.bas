': This program uses
': InForm GUI engine for QB64-PE - v1.5.7
': Fellippe Heitor, (2016 - 2022) - @FellippeHeitor
': Samuel Gomes, (2023 - 2025) - @a740g
': https://github.com/a740g/InForm-PE
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED ZoomMenu AS LONG
DIM SHARED ScanLinesMenu4 AS LONG
DIM SHARED ScanLinesMenuIncreaseOpacity AS LONG
DIM SHARED ScanLinesMenuDecreaseOpacity AS LONG
DIM SHARED ZoomMenuZoomIn AS LONG
DIM SHARED ZoomMenuZoomOut AS LONG
DIM SHARED ZoomMenu2 AS LONG
DIM SHARED ZoomMenuMinimum AS LONG
DIM SHARED ZoomMenu100 AS LONG
DIM SHARED ZoomMenu200 AS LONG
DIM SHARED ZoomMenu300 AS LONG
DIM SHARED ZoomMenu400 AS LONG
DIM SHARED ZoomMenuMaximum AS LONG
DIM SHARED RandomizeMenuImagePalette AS LONG
DIM SHARED RandomizeMenuImage AS LONG
DIM SHARED RandomizeMenuPalette AS LONG
DIM SHARED RandomizeMenuPreset AS LONG
DIM SHARED HelpMenuAbout AS LONG
DIM SHARED HelpMenuCheatSheet AS LONG
DIM SHARED ScanLinesMenu AS LONG
DIM SHARED ScalersMenuAdaptive AS LONG
DIM SHARED ScalersMenuSXBR2 AS LONG
DIM SHARED ScalersMenuMMPX2 AS LONG
DIM SHARED ScalersMenuHQ2XA AS LONG
DIM SHARED ScalersMenuHQ2XB AS LONG
DIM SHARED ScalersMenuHQ3XA AS LONG
DIM SHARED ScalersMenuHQ3XB AS LONG
DIM SHARED ScanLinesMenuEnabled AS LONG
DIM SHARED ScanLinesMenu2 AS LONG
DIM SHARED ScanLinesMenuVertical AS LONG
DIM SHARED ScanLinesMenuHorizontal AS LONG
DIM SHARED ScanLinesMenu3 AS LONG
DIM SHARED ScanLinesMenuIncreaseSize AS LONG
DIM SHARED ScanLinesMenuDecreaseSize AS LONG
DIM SHARED MenuItem100 AS LONG
DIM SHARED DitheringMenuSierraLite AS LONG
DIM SHARED DitheringMenuAtkinsonClassicMac AS LONG
DIM SHARED DitheringMenuRandomDithering AS LONG
DIM SHARED DitheringMenuBlueNoiseDithering AS LONG
DIM SHARED DitheringMenuClusteredDot4X4 AS LONG
DIM SHARED DitheringMenuClassicHalftone AS LONG
DIM SHARED DitheringMenuFalseFloydSteinberg AS LONG
DIM SHARED DitheringMenuFanErrorDiffusion AS LONG
DIM SHARED DitheringMenuStevensonArce AS LONG
DIM SHARED DitheringMenuTwoRowSierra AS LONG
DIM SHARED DitheringMenuShiauFan AS LONG
DIM SHARED DitheringMenuOrdered16X16Bayer AS LONG
DIM SHARED DitheringMenuInterleavedGradientNoise AS LONG
DIM SHARED DitheringMenuSpiralDithering AS LONG
DIM SHARED DitheringMenuPatternCrosshatch AS LONG
DIM SHARED DitheringMenuPatternDots AS LONG
DIM SHARED DitheringMenuPatternLines AS LONG
DIM SHARED DitheringMenuPatternMesh AS LONG
DIM SHARED DitheringMenuPatternCustom AS LONG
DIM SHARED DitheringMenuPatternFromFile AS LONG
DIM SHARED ScalersMenuNone AS LONG
DIM SHARED ScalersMenu2 AS LONG
DIM SHARED MenuItem86 AS LONG
DIM SHARED ImageMenuLoadImage AS LONG
DIM SHARED PaletteMenuLoadPalette AS LONG
DIM SHARED ImageMenuSaveImage AS LONG
DIM SHARED ImageMenu2 AS LONG
DIM SHARED ImageMenuPreviousImage AS LONG
DIM SHARED ImageMenuNextImage AS LONG
DIM SHARED ImageMenu3 AS LONG
DIM SHARED ImageMenuRandomImage AS LONG
DIM SHARED PaletteMenu2 AS LONG
DIM SHARED PaletteMenuPreviousPalette AS LONG
DIM SHARED PaletteMenuNextPalette AS LONG
DIM SHARED PaletteMenu3 AS LONG
DIM SHARED PaletteMenuRandomPalette AS LONG
DIM SHARED AdjustmentMenuResetAllAdjustments AS LONG
DIM SHARED AdjustmentMenu2 AS LONG
DIM SHARED AdjustmentMenuBrightness AS LONG
DIM SHARED AdjustmentMenuContrast AS LONG
DIM SHARED AdjustmentMenuIgnoreBlack AS LONG
DIM SHARED AdjustmentMenu3 AS LONG
DIM SHARED AdjustmentMenuHue AS LONG
DIM SHARED AdjustmentMenuSaturation AS LONG
DIM SHARED AdjustmentMenuPixelation AS LONG
DIM SHARED AdjustmentMenuColorize AS LONG
DIM SHARED AdjustmentMenuThreshold AS LONG
DIM SHARED AdjustmentMenuPosterize AS LONG
DIM SHARED AdjustmentMenuGamma AS LONG
DIM SHARED AdjustmentMenuFilmGrain AS LONG
DIM SHARED AdjustmentMenuInvert AS LONG
DIM SHARED AdjustmentMenuLevels AS LONG
DIM SHARED AdjustmentMenuColorBalance AS LONG
DIM SHARED DitheringMenuEnableDithering AS LONG
DIM SHARED DitheringMenu2 AS LONG
DIM SHARED DitheringMenuIncreaseDitheringAmount AS LONG
DIM SHARED DitheringMenuDecreaseDitheringAmount AS LONG
DIM SHARED DitheringMenu3 AS LONG
DIM SHARED DitheringMenuNextDitherMethod AS LONG
DIM SHARED DitheringMenuPreviousDitherMethod AS LONG
DIM SHARED DitheringMenu4 AS LONG
DIM SHARED DitheringMenuQuantizeOnly AS LONG
DIM SHARED DitheringMenuOrderedDither2X2Bayer AS LONG
DIM SHARED DitheringMenuOrderedDither4X4Bayer AS LONG
DIM SHARED DitheringMenuOrderedDither8X8Bayer AS LONG
DIM SHARED DitheringMenuFloydSteinbergErrorDiffusio AS LONG
DIM SHARED DitheringMenuJarvisJudiceNinke AS LONG
DIM SHARED DitheringMenuStuckiErrorDiffusion AS LONG
DIM SHARED DitheringMenuBurkesErrorDiffusion AS LONG
DIM SHARED DitheringMenuSierraErrorDiffusion AS LONG
DIM SHARED SierraLite AS LONG
DIM SHARED PresetMenuLoadPreset AS LONG
DIM SHARED PresetMenuSavePreset AS LONG
DIM SHARED PresetMenuOverwriteCurrentPreset AS LONG
DIM SHARED PresetMenu2 AS LONG
DIM SHARED PresetMenuPreviousPreset AS LONG
DIM SHARED PresetMenuNextPreset AS LONG
DIM SHARED PresetMenu3 AS LONG
DIM SHARED PresetMenuRandomPreset AS LONG
DIM SHARED IMG2PAL AS LONG
DIM SHARED FileMenu AS LONG
DIM SHARED FileMenuLoadImage AS LONG
DIM SHARED PresetMenu AS LONG
DIM SHARED ImageMenu AS LONG
DIM SHARED MenuItem2 AS LONG
DIM SHARED MenuItem3 AS LONG
DIM SHARED PaletteMenu AS LONG
DIM SHARED MenuItem4 AS LONG
DIM SHARED AdjustmentMenu AS LONG
DIM SHARED DitheringMenu AS LONG
DIM SHARED ScalersMenu AS LONG
DIM SHARED ViewMenu AS LONG
DIM SHARED RandomizeMenu AS LONG
DIM SHARED HelpMenu AS LONG
DIM SHARED FileMenuLoadPalette AS LONG
DIM SHARED FileMenuLoadPreset AS LONG
DIM SHARED FileMenu2 AS LONG
DIM SHARED FileMenuSaveImage AS LONG
DIM SHARED FileMenuSavePreset AS LONG
DIM SHARED FileMenu3 AS LONG
DIM SHARED FileMenuQuit AS LONG

': External modules: ---------------------------------------------------------------
'$INCLUDE:'include/InForm-PE/InForm/InForm.bi'
'$INCLUDE:'include/InForm-PE/InForm/extensions/GIFPlay.bi'
'$INCLUDE:'include/InForm-PE/InForm/xp.uitheme'
'$INCLUDE:'IMG2PAL-GUI.frm'
'$INCLUDE:'include/InForm-PE/InForm/extensions/GIFPlay.bas'

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
        CASE ZoomMenu

        CASE ScanLinesMenu4

        CASE ScanLinesMenuIncreaseOpacity

        CASE ScanLinesMenuDecreaseOpacity

        CASE ZoomMenuZoomIn

        CASE ZoomMenuZoomOut

        CASE ZoomMenu2

        CASE ZoomMenuMinimum

        CASE ZoomMenu100

        CASE ZoomMenu200

        CASE ZoomMenu300

        CASE ZoomMenu400

        CASE ZoomMenuMaximum

        CASE RandomizeMenuImagePalette

        CASE RandomizeMenuImage

        CASE RandomizeMenuPalette

        CASE RandomizeMenuPreset

        CASE HelpMenuAbout

        CASE HelpMenuCheatSheet

        CASE ScanLinesMenu

        CASE ScalersMenuAdaptive

        CASE ScalersMenuSXBR2

        CASE ScalersMenuMMPX2

        CASE ScalersMenuHQ2XA

        CASE ScalersMenuHQ2XB

        CASE ScalersMenuHQ3XA

        CASE ScalersMenuHQ3XB

        CASE ScanLinesMenuEnabled

        CASE ScanLinesMenu2

        CASE ScanLinesMenuVertical

        CASE ScanLinesMenuHorizontal

        CASE ScanLinesMenu3

        CASE ScanLinesMenuIncreaseSize

        CASE ScanLinesMenuDecreaseSize

        CASE MenuItem100

        CASE DitheringMenuSierraLite

        CASE DitheringMenuAtkinsonClassicMac

        CASE DitheringMenuRandomDithering

        CASE DitheringMenuBlueNoiseDithering

        CASE DitheringMenuClusteredDot4X4

        CASE DitheringMenuClassicHalftone

        CASE DitheringMenuFalseFloydSteinberg

        CASE DitheringMenuFanErrorDiffusion

        CASE DitheringMenuStevensonArce

        CASE DitheringMenuTwoRowSierra

        CASE DitheringMenuShiauFan

        CASE DitheringMenuOrdered16X16Bayer

        CASE DitheringMenuInterleavedGradientNoise

        CASE DitheringMenuSpiralDithering

        CASE DitheringMenuPatternCrosshatch

        CASE DitheringMenuPatternDots

        CASE DitheringMenuPatternLines

        CASE DitheringMenuPatternMesh

        CASE DitheringMenuPatternCustom

        CASE DitheringMenuPatternFromFile

        CASE ScalersMenuNone

        CASE ScalersMenu2

        CASE MenuItem86

        CASE ImageMenuLoadImage

        CASE PaletteMenuLoadPalette

        CASE ImageMenuSaveImage

        CASE ImageMenu2

        CASE ImageMenuPreviousImage

        CASE ImageMenuNextImage

        CASE ImageMenu3

        CASE ImageMenuRandomImage

        CASE PaletteMenu2

        CASE PaletteMenuPreviousPalette

        CASE PaletteMenuNextPalette

        CASE PaletteMenu3

        CASE PaletteMenuRandomPalette

        CASE AdjustmentMenuResetAllAdjustments

        CASE AdjustmentMenu2

        CASE AdjustmentMenuBrightness

        CASE AdjustmentMenuContrast

        CASE AdjustmentMenuIgnoreBlack

        CASE AdjustmentMenu3

        CASE AdjustmentMenuHue

        CASE AdjustmentMenuSaturation

        CASE AdjustmentMenuPixelation

        CASE AdjustmentMenuColorize

        CASE AdjustmentMenuThreshold

        CASE AdjustmentMenuPosterize

        CASE AdjustmentMenuGamma

        CASE AdjustmentMenuFilmGrain

        CASE AdjustmentMenuInvert

        CASE AdjustmentMenuLevels

        CASE AdjustmentMenuColorBalance

        CASE DitheringMenuEnableDithering

        CASE DitheringMenu2

        CASE DitheringMenuIncreaseDitheringAmount

        CASE DitheringMenuDecreaseDitheringAmount

        CASE DitheringMenu3

        CASE DitheringMenuNextDitherMethod

        CASE DitheringMenuPreviousDitherMethod

        CASE DitheringMenu4

        CASE DitheringMenuQuantizeOnly

        CASE DitheringMenuOrderedDither2X2Bayer

        CASE DitheringMenuOrderedDither4X4Bayer

        CASE DitheringMenuOrderedDither8X8Bayer

        CASE DitheringMenuFloydSteinbergErrorDiffusio

        CASE DitheringMenuJarvisJudiceNinke

        CASE DitheringMenuStuckiErrorDiffusion

        CASE DitheringMenuBurkesErrorDiffusion

        CASE DitheringMenuSierraErrorDiffusion

        CASE SierraLite

        CASE PresetMenuLoadPreset

        CASE PresetMenuSavePreset

        CASE PresetMenuOverwriteCurrentPreset

        CASE PresetMenu2

        CASE PresetMenuPreviousPreset

        CASE PresetMenuNextPreset

        CASE PresetMenu3

        CASE PresetMenuRandomPreset

        CASE IMG2PAL

        CASE FileMenu

        CASE FileMenuLoadImage

        CASE PresetMenu

        CASE ImageMenu

        CASE MenuItem2

        CASE MenuItem3

        CASE PaletteMenu

        CASE MenuItem4

        CASE AdjustmentMenu

        CASE DitheringMenu

        CASE ScalersMenu

        CASE ViewMenu

        CASE RandomizeMenu

        CASE HelpMenu

        CASE FileMenuLoadPalette

        CASE FileMenuLoadPreset

        CASE FileMenu2

        CASE FileMenuSaveImage

        CASE FileMenuSavePreset

        CASE FileMenu3

        CASE FileMenuQuit

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE ZoomMenu

        CASE ScanLinesMenu4

        CASE ScanLinesMenuIncreaseOpacity

        CASE ScanLinesMenuDecreaseOpacity

        CASE ZoomMenuZoomIn

        CASE ZoomMenuZoomOut

        CASE ZoomMenu2

        CASE ZoomMenuMinimum

        CASE ZoomMenu100

        CASE ZoomMenu200

        CASE ZoomMenu300

        CASE ZoomMenu400

        CASE ZoomMenuMaximum

        CASE RandomizeMenuImagePalette

        CASE RandomizeMenuImage

        CASE RandomizeMenuPalette

        CASE RandomizeMenuPreset

        CASE HelpMenuAbout

        CASE HelpMenuCheatSheet

        CASE ScanLinesMenu

        CASE ScalersMenuAdaptive

        CASE ScalersMenuSXBR2

        CASE ScalersMenuMMPX2

        CASE ScalersMenuHQ2XA

        CASE ScalersMenuHQ2XB

        CASE ScalersMenuHQ3XA

        CASE ScalersMenuHQ3XB

        CASE ScanLinesMenuEnabled

        CASE ScanLinesMenu2

        CASE ScanLinesMenuVertical

        CASE ScanLinesMenuHorizontal

        CASE ScanLinesMenu3

        CASE ScanLinesMenuIncreaseSize

        CASE ScanLinesMenuDecreaseSize

        CASE MenuItem100

        CASE DitheringMenuSierraLite

        CASE DitheringMenuAtkinsonClassicMac

        CASE DitheringMenuRandomDithering

        CASE DitheringMenuBlueNoiseDithering

        CASE DitheringMenuClusteredDot4X4

        CASE DitheringMenuClassicHalftone

        CASE DitheringMenuFalseFloydSteinberg

        CASE DitheringMenuFanErrorDiffusion

        CASE DitheringMenuStevensonArce

        CASE DitheringMenuTwoRowSierra

        CASE DitheringMenuShiauFan

        CASE DitheringMenuOrdered16X16Bayer

        CASE DitheringMenuInterleavedGradientNoise

        CASE DitheringMenuSpiralDithering

        CASE DitheringMenuPatternCrosshatch

        CASE DitheringMenuPatternDots

        CASE DitheringMenuPatternLines

        CASE DitheringMenuPatternMesh

        CASE DitheringMenuPatternCustom

        CASE DitheringMenuPatternFromFile

        CASE ScalersMenuNone

        CASE ScalersMenu2

        CASE MenuItem86

        CASE ImageMenuLoadImage

        CASE PaletteMenuLoadPalette

        CASE ImageMenuSaveImage

        CASE ImageMenu2

        CASE ImageMenuPreviousImage

        CASE ImageMenuNextImage

        CASE ImageMenu3

        CASE ImageMenuRandomImage

        CASE PaletteMenu2

        CASE PaletteMenuPreviousPalette

        CASE PaletteMenuNextPalette

        CASE PaletteMenu3

        CASE PaletteMenuRandomPalette

        CASE AdjustmentMenuResetAllAdjustments

        CASE AdjustmentMenu2

        CASE AdjustmentMenuBrightness

        CASE AdjustmentMenuContrast

        CASE AdjustmentMenuIgnoreBlack

        CASE AdjustmentMenu3

        CASE AdjustmentMenuHue

        CASE AdjustmentMenuSaturation

        CASE AdjustmentMenuPixelation

        CASE AdjustmentMenuColorize

        CASE AdjustmentMenuThreshold

        CASE AdjustmentMenuPosterize

        CASE AdjustmentMenuGamma

        CASE AdjustmentMenuFilmGrain

        CASE AdjustmentMenuInvert

        CASE AdjustmentMenuLevels

        CASE AdjustmentMenuColorBalance

        CASE DitheringMenuEnableDithering

        CASE DitheringMenu2

        CASE DitheringMenuIncreaseDitheringAmount

        CASE DitheringMenuDecreaseDitheringAmount

        CASE DitheringMenu3

        CASE DitheringMenuNextDitherMethod

        CASE DitheringMenuPreviousDitherMethod

        CASE DitheringMenu4

        CASE DitheringMenuQuantizeOnly

        CASE DitheringMenuOrderedDither2X2Bayer

        CASE DitheringMenuOrderedDither4X4Bayer

        CASE DitheringMenuOrderedDither8X8Bayer

        CASE DitheringMenuFloydSteinbergErrorDiffusio

        CASE DitheringMenuJarvisJudiceNinke

        CASE DitheringMenuStuckiErrorDiffusion

        CASE DitheringMenuBurkesErrorDiffusion

        CASE DitheringMenuSierraErrorDiffusion

        CASE SierraLite

        CASE PresetMenuLoadPreset

        CASE PresetMenuSavePreset

        CASE PresetMenuOverwriteCurrentPreset

        CASE PresetMenu2

        CASE PresetMenuPreviousPreset

        CASE PresetMenuNextPreset

        CASE PresetMenu3

        CASE PresetMenuRandomPreset

        CASE IMG2PAL

        CASE FileMenu

        CASE FileMenuLoadImage

        CASE PresetMenu

        CASE ImageMenu

        CASE MenuItem2

        CASE MenuItem3

        CASE PaletteMenu

        CASE MenuItem4

        CASE AdjustmentMenu

        CASE DitheringMenu

        CASE ScalersMenu

        CASE ViewMenu

        CASE RandomizeMenu

        CASE HelpMenu

        CASE FileMenuLoadPalette

        CASE FileMenuLoadPreset

        CASE FileMenu2

        CASE FileMenuSaveImage

        CASE FileMenuSavePreset

        CASE FileMenu3

        CASE FileMenuQuit

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE ZoomMenu

        CASE ScanLinesMenu4

        CASE ScanLinesMenuIncreaseOpacity

        CASE ScanLinesMenuDecreaseOpacity

        CASE ZoomMenuZoomIn

        CASE ZoomMenuZoomOut

        CASE ZoomMenu2

        CASE ZoomMenuMinimum

        CASE ZoomMenu100

        CASE ZoomMenu200

        CASE ZoomMenu300

        CASE ZoomMenu400

        CASE ZoomMenuMaximum

        CASE RandomizeMenuImagePalette

        CASE RandomizeMenuImage

        CASE RandomizeMenuPalette

        CASE RandomizeMenuPreset

        CASE HelpMenuAbout

        CASE HelpMenuCheatSheet

        CASE ScanLinesMenu

        CASE ScalersMenuAdaptive

        CASE ScalersMenuSXBR2

        CASE ScalersMenuMMPX2

        CASE ScalersMenuHQ2XA

        CASE ScalersMenuHQ2XB

        CASE ScalersMenuHQ3XA

        CASE ScalersMenuHQ3XB

        CASE ScanLinesMenuEnabled

        CASE ScanLinesMenu2

        CASE ScanLinesMenuVertical

        CASE ScanLinesMenuHorizontal

        CASE ScanLinesMenu3

        CASE ScanLinesMenuIncreaseSize

        CASE ScanLinesMenuDecreaseSize

        CASE MenuItem100

        CASE DitheringMenuSierraLite

        CASE DitheringMenuAtkinsonClassicMac

        CASE DitheringMenuRandomDithering

        CASE DitheringMenuBlueNoiseDithering

        CASE DitheringMenuClusteredDot4X4

        CASE DitheringMenuClassicHalftone

        CASE DitheringMenuFalseFloydSteinberg

        CASE DitheringMenuFanErrorDiffusion

        CASE DitheringMenuStevensonArce

        CASE DitheringMenuTwoRowSierra

        CASE DitheringMenuShiauFan

        CASE DitheringMenuOrdered16X16Bayer

        CASE DitheringMenuInterleavedGradientNoise

        CASE DitheringMenuSpiralDithering

        CASE DitheringMenuPatternCrosshatch

        CASE DitheringMenuPatternDots

        CASE DitheringMenuPatternLines

        CASE DitheringMenuPatternMesh

        CASE DitheringMenuPatternCustom

        CASE DitheringMenuPatternFromFile

        CASE ScalersMenuNone

        CASE ScalersMenu2

        CASE MenuItem86

        CASE ImageMenuLoadImage

        CASE PaletteMenuLoadPalette

        CASE ImageMenuSaveImage

        CASE ImageMenu2

        CASE ImageMenuPreviousImage

        CASE ImageMenuNextImage

        CASE ImageMenu3

        CASE ImageMenuRandomImage

        CASE PaletteMenu2

        CASE PaletteMenuPreviousPalette

        CASE PaletteMenuNextPalette

        CASE PaletteMenu3

        CASE PaletteMenuRandomPalette

        CASE AdjustmentMenuResetAllAdjustments

        CASE AdjustmentMenu2

        CASE AdjustmentMenuBrightness

        CASE AdjustmentMenuContrast

        CASE AdjustmentMenuIgnoreBlack

        CASE AdjustmentMenu3

        CASE AdjustmentMenuHue

        CASE AdjustmentMenuSaturation

        CASE AdjustmentMenuPixelation

        CASE AdjustmentMenuColorize

        CASE AdjustmentMenuThreshold

        CASE AdjustmentMenuPosterize

        CASE AdjustmentMenuGamma

        CASE AdjustmentMenuFilmGrain

        CASE AdjustmentMenuInvert

        CASE AdjustmentMenuLevels

        CASE AdjustmentMenuColorBalance

        CASE DitheringMenuEnableDithering

        CASE DitheringMenu2

        CASE DitheringMenuIncreaseDitheringAmount

        CASE DitheringMenuDecreaseDitheringAmount

        CASE DitheringMenu3

        CASE DitheringMenuNextDitherMethod

        CASE DitheringMenuPreviousDitherMethod

        CASE DitheringMenu4

        CASE DitheringMenuQuantizeOnly

        CASE DitheringMenuOrderedDither2X2Bayer

        CASE DitheringMenuOrderedDither4X4Bayer

        CASE DitheringMenuOrderedDither8X8Bayer

        CASE DitheringMenuFloydSteinbergErrorDiffusio

        CASE DitheringMenuJarvisJudiceNinke

        CASE DitheringMenuStuckiErrorDiffusion

        CASE DitheringMenuBurkesErrorDiffusion

        CASE DitheringMenuSierraErrorDiffusion

        CASE SierraLite

        CASE PresetMenuLoadPreset

        CASE PresetMenuSavePreset

        CASE PresetMenuOverwriteCurrentPreset

        CASE PresetMenu2

        CASE PresetMenuPreviousPreset

        CASE PresetMenuNextPreset

        CASE PresetMenu3

        CASE PresetMenuRandomPreset

        CASE IMG2PAL

        CASE FileMenu

        CASE FileMenuLoadImage

        CASE PresetMenu

        CASE ImageMenu

        CASE MenuItem2

        CASE MenuItem3

        CASE PaletteMenu

        CASE MenuItem4

        CASE AdjustmentMenu

        CASE DitheringMenu

        CASE ScalersMenu

        CASE ViewMenu

        CASE RandomizeMenu

        CASE HelpMenu

        CASE FileMenuLoadPalette

        CASE FileMenuLoadPreset

        CASE FileMenu2

        CASE FileMenuSaveImage

        CASE FileMenuSavePreset

        CASE FileMenu3

        CASE FileMenuQuit

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE ZoomMenu

        CASE ScanLinesMenu4

        CASE ScanLinesMenuIncreaseOpacity

        CASE ScanLinesMenuDecreaseOpacity

        CASE ZoomMenuZoomIn

        CASE ZoomMenuZoomOut

        CASE ZoomMenu2

        CASE ZoomMenuMinimum

        CASE ZoomMenu100

        CASE ZoomMenu200

        CASE ZoomMenu300

        CASE ZoomMenu400

        CASE ZoomMenuMaximum

        CASE RandomizeMenuImagePalette

        CASE RandomizeMenuImage

        CASE RandomizeMenuPalette

        CASE RandomizeMenuPreset

        CASE HelpMenuAbout

        CASE HelpMenuCheatSheet

        CASE ScanLinesMenu

        CASE ScalersMenuAdaptive

        CASE ScalersMenuSXBR2

        CASE ScalersMenuMMPX2

        CASE ScalersMenuHQ2XA

        CASE ScalersMenuHQ2XB

        CASE ScalersMenuHQ3XA

        CASE ScalersMenuHQ3XB

        CASE ScanLinesMenuEnabled

        CASE ScanLinesMenu2

        CASE ScanLinesMenuVertical

        CASE ScanLinesMenuHorizontal

        CASE ScanLinesMenu3

        CASE ScanLinesMenuIncreaseSize

        CASE ScanLinesMenuDecreaseSize

        CASE MenuItem100

        CASE DitheringMenuSierraLite

        CASE DitheringMenuAtkinsonClassicMac

        CASE DitheringMenuRandomDithering

        CASE DitheringMenuBlueNoiseDithering

        CASE DitheringMenuClusteredDot4X4

        CASE DitheringMenuClassicHalftone

        CASE DitheringMenuFalseFloydSteinberg

        CASE DitheringMenuFanErrorDiffusion

        CASE DitheringMenuStevensonArce

        CASE DitheringMenuTwoRowSierra

        CASE DitheringMenuShiauFan

        CASE DitheringMenuOrdered16X16Bayer

        CASE DitheringMenuInterleavedGradientNoise

        CASE DitheringMenuSpiralDithering

        CASE DitheringMenuPatternCrosshatch

        CASE DitheringMenuPatternDots

        CASE DitheringMenuPatternLines

        CASE DitheringMenuPatternMesh

        CASE DitheringMenuPatternCustom

        CASE DitheringMenuPatternFromFile

        CASE ScalersMenuNone

        CASE ScalersMenu2

        CASE MenuItem86

        CASE ImageMenuLoadImage

        CASE PaletteMenuLoadPalette

        CASE ImageMenuSaveImage

        CASE ImageMenu2

        CASE ImageMenuPreviousImage

        CASE ImageMenuNextImage

        CASE ImageMenu3

        CASE ImageMenuRandomImage

        CASE PaletteMenu2

        CASE PaletteMenuPreviousPalette

        CASE PaletteMenuNextPalette

        CASE PaletteMenu3

        CASE PaletteMenuRandomPalette

        CASE AdjustmentMenuResetAllAdjustments

        CASE AdjustmentMenu2

        CASE AdjustmentMenuBrightness

        CASE AdjustmentMenuContrast

        CASE AdjustmentMenuIgnoreBlack

        CASE AdjustmentMenu3

        CASE AdjustmentMenuHue

        CASE AdjustmentMenuSaturation

        CASE AdjustmentMenuPixelation

        CASE AdjustmentMenuColorize

        CASE AdjustmentMenuThreshold

        CASE AdjustmentMenuPosterize

        CASE AdjustmentMenuGamma

        CASE AdjustmentMenuFilmGrain

        CASE AdjustmentMenuInvert

        CASE AdjustmentMenuLevels

        CASE AdjustmentMenuColorBalance

        CASE DitheringMenuEnableDithering

        CASE DitheringMenu2

        CASE DitheringMenuIncreaseDitheringAmount

        CASE DitheringMenuDecreaseDitheringAmount

        CASE DitheringMenu3

        CASE DitheringMenuNextDitherMethod

        CASE DitheringMenuPreviousDitherMethod

        CASE DitheringMenu4

        CASE DitheringMenuQuantizeOnly

        CASE DitheringMenuOrderedDither2X2Bayer

        CASE DitheringMenuOrderedDither4X4Bayer

        CASE DitheringMenuOrderedDither8X8Bayer

        CASE DitheringMenuFloydSteinbergErrorDiffusio

        CASE DitheringMenuJarvisJudiceNinke

        CASE DitheringMenuStuckiErrorDiffusion

        CASE DitheringMenuBurkesErrorDiffusion

        CASE DitheringMenuSierraErrorDiffusion

        CASE SierraLite

        CASE PresetMenuLoadPreset

        CASE PresetMenuSavePreset

        CASE PresetMenuOverwriteCurrentPreset

        CASE PresetMenu2

        CASE PresetMenuPreviousPreset

        CASE PresetMenuNextPreset

        CASE PresetMenu3

        CASE PresetMenuRandomPreset

        CASE IMG2PAL

        CASE FileMenu

        CASE FileMenuLoadImage

        CASE PresetMenu

        CASE ImageMenu

        CASE MenuItem2

        CASE MenuItem3

        CASE PaletteMenu

        CASE MenuItem4

        CASE AdjustmentMenu

        CASE DitheringMenu

        CASE ScalersMenu

        CASE ViewMenu

        CASE RandomizeMenu

        CASE HelpMenu

        CASE FileMenuLoadPalette

        CASE FileMenuLoadPreset

        CASE FileMenu2

        CASE FileMenuSaveImage

        CASE FileMenuSavePreset

        CASE FileMenu3

        CASE FileMenuQuit

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE ZoomMenu

        CASE ScanLinesMenu4

        CASE ScanLinesMenuIncreaseOpacity

        CASE ScanLinesMenuDecreaseOpacity

        CASE ZoomMenuZoomIn

        CASE ZoomMenuZoomOut

        CASE ZoomMenu2

        CASE ZoomMenuMinimum

        CASE ZoomMenu100

        CASE ZoomMenu200

        CASE ZoomMenu300

        CASE ZoomMenu400

        CASE ZoomMenuMaximum

        CASE RandomizeMenuImagePalette

        CASE RandomizeMenuImage

        CASE RandomizeMenuPalette

        CASE RandomizeMenuPreset

        CASE HelpMenuAbout

        CASE HelpMenuCheatSheet

        CASE ScanLinesMenu

        CASE ScalersMenuAdaptive

        CASE ScalersMenuSXBR2

        CASE ScalersMenuMMPX2

        CASE ScalersMenuHQ2XA

        CASE ScalersMenuHQ2XB

        CASE ScalersMenuHQ3XA

        CASE ScalersMenuHQ3XB

        CASE ScanLinesMenuEnabled

        CASE ScanLinesMenu2

        CASE ScanLinesMenuVertical

        CASE ScanLinesMenuHorizontal

        CASE ScanLinesMenu3

        CASE ScanLinesMenuIncreaseSize

        CASE ScanLinesMenuDecreaseSize

        CASE MenuItem100

        CASE DitheringMenuSierraLite

        CASE DitheringMenuAtkinsonClassicMac

        CASE DitheringMenuRandomDithering

        CASE DitheringMenuBlueNoiseDithering

        CASE DitheringMenuClusteredDot4X4

        CASE DitheringMenuClassicHalftone

        CASE DitheringMenuFalseFloydSteinberg

        CASE DitheringMenuFanErrorDiffusion

        CASE DitheringMenuStevensonArce

        CASE DitheringMenuTwoRowSierra

        CASE DitheringMenuShiauFan

        CASE DitheringMenuOrdered16X16Bayer

        CASE DitheringMenuInterleavedGradientNoise

        CASE DitheringMenuSpiralDithering

        CASE DitheringMenuPatternCrosshatch

        CASE DitheringMenuPatternDots

        CASE DitheringMenuPatternLines

        CASE DitheringMenuPatternMesh

        CASE DitheringMenuPatternCustom

        CASE DitheringMenuPatternFromFile

        CASE ScalersMenuNone

        CASE ScalersMenu2

        CASE MenuItem86

        CASE ImageMenuLoadImage

        CASE PaletteMenuLoadPalette

        CASE ImageMenuSaveImage

        CASE ImageMenu2

        CASE ImageMenuPreviousImage

        CASE ImageMenuNextImage

        CASE ImageMenu3

        CASE ImageMenuRandomImage

        CASE PaletteMenu2

        CASE PaletteMenuPreviousPalette

        CASE PaletteMenuNextPalette

        CASE PaletteMenu3

        CASE PaletteMenuRandomPalette

        CASE AdjustmentMenuResetAllAdjustments

        CASE AdjustmentMenu2

        CASE AdjustmentMenuBrightness

        CASE AdjustmentMenuContrast

        CASE AdjustmentMenuIgnoreBlack

        CASE AdjustmentMenu3

        CASE AdjustmentMenuHue

        CASE AdjustmentMenuSaturation

        CASE AdjustmentMenuPixelation

        CASE AdjustmentMenuColorize

        CASE AdjustmentMenuThreshold

        CASE AdjustmentMenuPosterize

        CASE AdjustmentMenuGamma

        CASE AdjustmentMenuFilmGrain

        CASE AdjustmentMenuInvert

        CASE AdjustmentMenuLevels

        CASE AdjustmentMenuColorBalance

        CASE DitheringMenuEnableDithering

        CASE DitheringMenu2

        CASE DitheringMenuIncreaseDitheringAmount

        CASE DitheringMenuDecreaseDitheringAmount

        CASE DitheringMenu3

        CASE DitheringMenuNextDitherMethod

        CASE DitheringMenuPreviousDitherMethod

        CASE DitheringMenu4

        CASE DitheringMenuQuantizeOnly

        CASE DitheringMenuOrderedDither2X2Bayer

        CASE DitheringMenuOrderedDither4X4Bayer

        CASE DitheringMenuOrderedDither8X8Bayer

        CASE DitheringMenuFloydSteinbergErrorDiffusio

        CASE DitheringMenuJarvisJudiceNinke

        CASE DitheringMenuStuckiErrorDiffusion

        CASE DitheringMenuBurkesErrorDiffusion

        CASE DitheringMenuSierraErrorDiffusion

        CASE SierraLite

        CASE PresetMenuLoadPreset

        CASE PresetMenuSavePreset

        CASE PresetMenuOverwriteCurrentPreset

        CASE PresetMenu2

        CASE PresetMenuPreviousPreset

        CASE PresetMenuNextPreset

        CASE PresetMenu3

        CASE PresetMenuRandomPreset

        CASE IMG2PAL

        CASE FileMenu

        CASE FileMenuLoadImage

        CASE PresetMenu

        CASE ImageMenu

        CASE MenuItem2

        CASE MenuItem3

        CASE PaletteMenu

        CASE MenuItem4

        CASE AdjustmentMenu

        CASE DitheringMenu

        CASE ScalersMenu

        CASE ViewMenu

        CASE RandomizeMenu

        CASE HelpMenu

        CASE FileMenuLoadPalette

        CASE FileMenuLoadPreset

        CASE FileMenu2

        CASE FileMenuSaveImage

        CASE FileMenuSavePreset

        CASE FileMenu3

        CASE FileMenuQuit

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_FormResized

END SUB

'$INCLUDE:'include/InForm-PE/InForm/InForm.ui'
