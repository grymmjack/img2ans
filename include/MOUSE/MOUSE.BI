TYPE MOUSE_DEVICE
    l_down   AS _BYTE
    l_up     AS _BYTE
    r_down   AS _BYTE
    r_up     AS _BYTE
    m_down   AS _BYTE
    m_up     AS _BYTE
    w_raw    AS INTEGER
    w_up     AS _BYTE
    w_down   AS _BYTE
    x        AS INTEGER
    y        AS INTEGER
    old_x    AS INTEGER
    old_y    AS INTEGER
    dragging AS _BYTE
    dropping AS _BYTE
END TYPE

DIM SHARED MOUSE AS MOUSE_DEVICE