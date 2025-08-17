DIM cfg AS GJ_BBX_CFG

' --- sizes ---
cfg.HandleHalfSize = 16
cfg.HandleFullSize = cfg.HandleHalfSize * 2
cfg.EdgeHalfSize   = 10
cfg.EdgeFullSize   = cfg.EdgeHalfSize * 2
cfg.HandleCornerSize = cfg.HandleFullSize
cfg.HandleEdgeSize   = cfg.EdgeFullSize
cfg.MinBoxWidth = 32
cfg.MinBoxHeight = 32
cfg.DragEdgePadding = 8

' --- colors ---
cfg.colorIdle          = _RGB32(128,128,128)
cfg.colorHoverOnly     = _RGB32(255,255,  0)
cfg.colorSelectedOnly  = _RGB32(  0,128,255)
cfg.colorSelectedHover = _RGB32(255,128,  0)
cfg.colorDragging      = _RGB32(  0,255,  0)
cfg.colorResizing      = _RGB32(255,  0,255)

' handle colors
cfg.HandleFillColor       = _RGB32(255,255,255)
cfg.HandleHoverFillColor  = _RGB32(255,255,  0)
cfg.HandleBorderColor     = _RGB32(  0,  0,  0)

' initial rectangle
cfg.initX = 300: cfg.initY = 200
cfg.initW = 150: cfg.initH = 100

' apply
GJ_BBX_InitWithConfig cfg
