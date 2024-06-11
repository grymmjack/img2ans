OPTION _EXPLICIT
$RESIZE:ON

$LET DEBUGGING = TRUE

$IF GJ_LIB_NL = UNDEFINED THEN
    $LET GJ_LIB_NL = 1
    DIM SHARED GJ_LIB_NL AS STRING
    $IF WIN THEN
        GJ_LIB_NL$ = CHR$(13)
    $ELSE
        GJ_LIB_NL$ = CHR$(10)
    $END IF
$END IF

$IF FALSE = UNDEFINED AND TRUE = UNDEFINED THEN
    $LET TRUE = TRUE
    CONST FALSE = 0 : CONST TRUE = NOT FALSE
$END IF

CONST VIEWPORT_UPDATE_RATE! = 1
CONST VIEWPORT_INIT_DELAY!  = 0.01
CONST VIEWPORT_MOVE_RATE!   = 0.01

TYPE VIEWPORT
    canvas       AS LONG
    canvas_mode  AS LONG
    max_w        AS LONG
    max_h        AS LONG
    cur_w        AS LONG
    cur_h        AS LONG
    orig_w       AS LONG
    orig_h       AS LONG
    can_resize   AS INTEGER
    can_fs       AS INTEGER
    can_move     AS INTEGER
    was_resized  AS INTEGER
    was_moved    AS INTEGER
    wants_fs     AS INTEGER
    fs_mode      AS INTEGER
    is_fs        AS INTEGER
    orig_left    AS INTEGER
    orig_top     AS INTEGER
    pos_left     AS INTEGER
    pos_top      AS INTEGER
    initialized  AS INTEGER
    init_timer   AS INTEGER
    update_timer AS INTEGER
    update_ticks AS LONG
    move_timer   AS INTEGER
END TYPE
DIM SHARED THE_VIEWPORT AS VIEWPORT

CALL VIEWPORT.init(THE_VIEWPORT, FALSE, 1024, 768, 32, FALSE, FALSE, FALSE, 0, 0)

DIM k AS STRING
DO
    _LIMIT 30

    k$ = INKEY$ : IF k$ = CHR$(27) THEN SYSTEM

    IF _RESIZE = TRUE AND THE_VIEWPORT.update_ticks& > 1 AND THE_VIEWPORT.initialized% = TRUE THEN
        IF THE_VIEWPORT.can_resize% = TRUE THEN
            CALL VIEWPORT.was_resized(THE_VIEWPORT, _RESIZEWIDTH, _RESIZEHEIGHT)
        END IF
    END IF
LOOP

VIEWPORT.shutdown

SYSTEM


SUB draw_output()
    CLS
    PRINT VIEWPORT.dump$(THE_VIEWPORT, "THE_VIEWPORT")
END SUB


SUB VIEWPORT.init(vp AS VIEWPORT, fs%, w&, h&, mode&, can_r%, can_fs%, can_m%, pos_l%, pos_t%)
    ECH0 "VIEWPORT.init()"
    vp.max_w&       = _DESKTOPWIDTH
    vp.max_h&       = _DESKTOPHEIGHT
    vp.cur_w&       = _WIDTH
    vp.cur_w&       = _HEIGHT
    vp.fs_mode%     = _FULLSCREEN
    vp.orig_w&      = w&
    vp.orig_h&      = h&
    vp.pos_left%    = pos_l%
    vp.pos_top%     = pos_t%
    vp.orig_left%   = pos_l%
    vp.orig_top%    = pos_t%
    vp.can_resize%  = can_r%
    vp.can_fs%      = can_fs%
    vp.can_move%    = can_m%
    vp.was_resized% = FALSE
    vp.was_moved%   = FALSE
    vp.wants_fs%    = fs%
    vp.canvas_mode& = mode&

    IF vp.can_fs% = FALSE THEN
        _ALLOWFULLSCREEN _OFF
    END IF

    IF vp.can_resize% = FALSE THEN
        _RESIZE OFF
    END IF

    ' Initialization timer
    vp.init_timer% = _FREETIMER
    ON TIMER(vp.init_timer%, VIEWPORT_INIT_DELAY!) VIEWPORT.initialized
    ECH0 "VIEWPORT.init() - ON TIMER init_timer - 1, VIEWPORT.initialized"
    TIMER(vp.init_timer%) ON
    ECH0 "VIEWPORT.init() - TIMER ON - init_timer"

    ' Update timer
    vp.update_ticks& = 0
    vp.update_timer% = _FREETIMER
    ON TIMER(vp.update_timer%, VIEWPORT_UPDATE_RATE!) VIEWPORT.update
    ECH0 "VIEWPORT.init() - ON TIMER update_timer - 1, VIEWPORT.update"
    TIMER(vp.update_timer%) ON
    ECH0 "VIEWPORT.init() - TIMER ON - update_timer"

    ' Move timer
    vp.move_timer% = _FREETIMER
    ON TIMER(vp.move_timer%, VIEWPORT_MOVE_RATE!) VIEWPORT.check_can_move
    ECH0 "VIEWPORT.init() - ON TIMER move_timer - 1, VIEWPORT.check_can_move"
    TIMER(vp.move_timer%) ON
    ECH0 "VIEWPORT.init() - TIMER ON - move_timer"
END SUB


SUB VIEWPORT.shutdown
    SCREEN 0
    IF THE_VIEWPORT.canvas& <> 0 THEN
        _FREEIMAGE THE_VIEWPORT.canvas&
    END IF
    TIMER(THE_VIEWPORT.update_timer%) OFF
    TIMER(THE_VIEWPORT.update_timer%) FREE
    TIMER(THE_VIEWPORT.move_timer%) OFF
    TIMER(THE_VIEWPORT.move_timer%) FREE
END SUB


SUB VIEWPORT.setup_screen(vp AS VIEWPORT, w&, h&, mode&)
    ECH0 "VIEWPORT.setup_screen(w:" + ns$(w&) + ", h:" + ns$(h&) + ", mode:" + ns$(mode&) + ")"

    SCREEN 0

    IF vp.canvas& <> 0 THEN
        _FREEIMAGE vp.canvas&
    END IF
    vp.canvas& = _NEWIMAGE(w&, h&, mode&)

    SCREEN vp.canvas&

    IF vp.wants_fs% = TRUE THEN
        ECH0 "REQUESTING FULLSCREEN"
        IF vp.can_fs% = TRUE THEN
            ECH0 "REQUESTING FULLSCREEN - OK: CAN FS"
            IF vp.is_fs% = FALSE THEN 
                ECH0 "REQUESTING FULLSCREEN - OK!"
                _FULLSCREEN
            END IF
        ELSE
            ECH0 "REQUEST FOR FULLSCREEN DENIED"
        END IF
    END IF
END SUB


SUB VIEWPORT.initialized()
    ECH0 "VIEWPORT.initialized()"
    TIMER(THE_VIEWPORT.init_timer%) OFF
    ECH0 "VIEWPORT.initialized() - TIMER OFF"
    TIMER(THE_VIEWPORT.init_timer%) FREE
    ECH0 "VIEWPORT.initialized() - TIMER FREE"

    IF THE_VIEWPORT.pos_top% <> _SCREENY OR THE_VIEWPORT.pos_left% <> _SCREENX THEN
        CALL VIEWPORT.move(THE_VIEWPORT, THE_VIEWPORT.pos_left%, THE_VIEWPORT.pos_top%)
    END IF

    IF _WIDTH <> THE_VIEWPORT.orig_w& OR _HEIGHT <> THE_VIEWPORT.orig_h& THEN
        CALL VIEWPORT.resize(THE_VIEWPORT, THE_VIEWPORT.orig_w&, THE_VIEWPORT.orig_h&)        
    END IF
    THE_VIEWPORT.initialized% = TRUE
    CALL VIEWPORT.setup_screen(THE_VIEWPORT, THE_VIEWPORT.orig_w&, THE_VIEWPORT.orig_h&, THE_VIEWPORT.canvas_mode&)
END SUB


SUB VIEWPORT.update
    ECH0 "VIEWPORT.update()"
    THE_VIEWPORT.update_ticks& = THE_VIEWPORT.update_ticks& + 1
    THE_VIEWPORT.fs_mode%  = _FULLSCREEN
    THE_VIEWPORT.is_fs%    = (THE_VIEWPORT.fs_mode% > 0)
    THE_VIEWPORT.pos_left% = _SCREENX
    THE_VIEWPORT.pos_top%  = _SCREENY
    THE_VIEWPORT.cur_w&    = _WIDTH
    THE_VIEWPORT.cur_h&    = _HEIGHT
    VIEWPORT.check_was_moved
    draw_output
END SUB


SUB VIEWPORT.resize(vp AS VIEWPORT, w&, h&)
    ECH0 "VIEWPORT.resize(w: " + ns$(w&) + ", h:" + ns$(h&) + ")"
    IF vp.update_timer% > 2 AND vp.is_fs% = FALSE THEN
        CALL VIEWPORT.setup_screen(vp, w&, h&, vp.canvas_mode&)
    END IF
END SUB


SUB VIEWPORT.was_resized(vp AS VIEWPORT, w&, h&)
    ECH0 "VIEWPORT.was_resized(w: " + ns$(w&) + ", h: " + ns$(h&) + ")"
    IF vp.orig_w& <> w& OR vp.orig_h& <> h& THEN
        vp.was_resized% = TRUE
    END IF
END SUB


SUB VIEWPORT.move(vp AS VIEWPORT, pos_l%, pos_t%)
    ECH0 "VIEWPORT.move(l: " + ns$(pos_l%) + ", t: " + ns$(pos_t%) + ")"
    $IF LINUX THEN
        ECH0 "VIEWPORT.move is not supported in LINUX (no _SCREENMOVE)"
        EXIT SUB
    $ENDIF
    IF vp.is_fs% = FALSE THEN
        _SCREENMOVE pos_l%, pos_t%
        vp.pos_left% = pos_l%
        vp.pos_top%  = pos_t%
    END IF
END SUB


SUB VIEWPORT.check_can_move
    ' ECH0 "VIEWPORT.check_can_move()"
    IF THE_VIEWPORT.is_fs% = FALSE THEN
        IF THE_VIEWPORT.can_move% = FALSE THEN
            IF THE_VIEWPORT.was_moved% = TRUE THEN
                ECH0 "VIEWPORT.check_can_move() - CANNOT MOVE, REPOSITIONING"
                CALL VIEWPORT.move(THE_VIEWPORT, THE_VIEWPORT.orig_top%, THE_VIEWPORT.orig_left%)
                THE_VIEWPORT.was_moved% = FALSE
            END IF
        END IF
    END IF
END SUB


SUB VIEWPORT.check_was_moved
    ECH0 "VIEWPORT.check_was_moved(" + ns$(THE_VIEWPORT.update_ticks&) + ")"
    IF THE_VIEWPORT.initialized% AND THE_VIEWPORT.update_ticks& > VIEWPORT_INIT_DELAY! THEN
        IF THE_VIEWPORT.orig_top% <> _SCREENY OR _
           THE_VIEWPORT.orig_left% <> _SCREENX THEN
                THE_VIEWPORT.was_moved% = TRUE
        END IF
    END IF
END SUB


FUNCTION VIEWPORT.dump$(vp AS VIEWPORT, label$)
    ECH0 "VIEWPORT.dump(" + label$ + ")"
    DIM AS STRING r
    r$ = GJ_LIB_NL$ + "VIEWPORT: " + label$ + " {" + GJ_LIB_NL$
    r$ = r$ + "  max_w: " + ns$(vp.max_w&) + GJ_LIB_NL$
    r$ = r$ + "  max_h: " + ns$(vp.max_h&) + GJ_LIB_NL$
    r$ = r$ + "  cur_w: " + ns$(vp.cur_w&) + GJ_LIB_NL$
    r$ = r$ + "  cur_h: " + ns$(vp.cur_h&) + GJ_LIB_NL$
    r$ = r$ + "  orig_w: " + ns$(vp.orig_w&) + GJ_LIB_NL$
    r$ = r$ + "  orig_h: " + ns$(vp.orig_h&) + GJ_LIB_NL$
    r$ = r$ + "  can_resize: " + nb$(vp.can_resize%) + GJ_LIB_NL$
    r$ = r$ + "  can_fs: " + nb$(vp.can_fs%) + GJ_LIB_NL$
    r$ = r$ + "  can_move: " + nb$(vp.can_move%) + GJ_LIB_NL$
    r$ = r$ + "  was_resized: " + nb$(vp.was_resized%) + GJ_LIB_NL$
    r$ = r$ + "  was_moved: " + nb$(vp.was_moved%) + GJ_LIB_NL$
    r$ = r$ + "  wants_fs: " + nb$(vp.wants_fs%) + GJ_LIB_NL$
    r$ = r$ + "  fs_mode: " + ns$(vp.fs_mode%) + GJ_LIB_NL$
    r$ = r$ + "  is_fs: " + nb$(vp.is_fs%) + GJ_LIB_NL$
    r$ = r$ + "  orig_left: " + ns$(vp.orig_left%) + GJ_LIB_NL$
    r$ = r$ + "  orig_top: " + ns$(vp.orig_top%) + GJ_LIB_NL$
    r$ = r$ + "  pos_left: " + ns$(vp.pos_left%) + GJ_LIB_NL$
    r$ = r$ + "  pos_top: " + ns$(vp.pos_top%) + GJ_LIB_NL$
    r$ = r$ + "  initialized: " + nb$(vp.initialized%) + GJ_LIB_NL$
    r$ = r$ + "  init_timer: " + ns$(vp.init_timer%) + GJ_LIB_NL$
    r$ = r$ + "  update_timer: " + ns$(vp.update_timer%) + GJ_LIB_NL$
    r$ = r$ + "  update_ticks: " + ns$(vp.update_ticks&) + GJ_LIB_NL$
    r$ = r$ + "}"
    VIEWPORT.dump$ = r$
END FUNCTION


FUNCTION ns$(num)
    ns$ = _TRIM$(STR$(num))
END FUNCTION


FUNCTION nb$(bool)
    IF bool = TRUE THEN nb$ = "TRUE"
    IF bool = FALSE THEN nb$ = "FALSE"
END FUNCTION


SUB ECH0(s$)
    $IF DEBUGGING THEN
        $CONSOLE
        _ECHO s$
    $ENDIF
END SUB