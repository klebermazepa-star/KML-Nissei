DEF NEW GLOBAL SHARED VAR h_g_cod_estab_bord    as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR h_g_cod_portador      as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR h_g_num_bord_ap       as widget-handle    no-undo.

DEF NEW GLOBAL SHARED VAR h_cod_estab_bord    as CHARACTER    no-undo.  
DEF NEW GLOBAL SHARED VAR h_cod_portador      as CHARACTER    no-undo.  
DEF NEW GLOBAL SHARED VAR h_num_bord_ap       as INTEGER      no-undo.

ASSIGN h_cod_estab_bord = h_g_cod_estab_bord:SCREEN-VALUE  
       h_cod_portador   = h_g_cod_portador:SCREEN-VALUE  
       h_num_bord_ap    = INT(h_g_num_bord_ap:SCREEN-VALUE). 


RETURN "OK".
