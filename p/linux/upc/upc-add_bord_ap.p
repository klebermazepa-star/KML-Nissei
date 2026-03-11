define input param p-ind-event  as character     no-undo.
define input param p-ind-object as character     no-undo.
define input param p-wgh-object as handle        no-undo.
define input param p-wgh-frame  as widget-handle no-undo.
define input param p-cod-table  as character     no-undo.
define input param p-row-table  as recid         no-undo.

define variable codPortador     as widget-handle no-undo.
define variable fcod_portador   as widget-handle no-undo.
define variable btZoomPortador  as widget-handle no-undo.
define variable fbtZoomPortador as widget-handle no-undo.

DEFINE VARIABLE h_log_bord_ap_escrit        AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_log_bord_ap_desc_dist     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_val_tot_lote_pagto_efetd  AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_val_desconto              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_lb_val_desconto           AS WIDGET-HANDLE NO-UNDO.

DEFINE BUFFER b_bord_ap FOR bord_ap.

/* message ' p-ind-event   '  p-ind-event     skip */
/*         ' p-ind-object  '  p-ind-object    skip */
/*         ' p-wgh-object  '  p-wgh-object    skip */
/*         ' p-wgh-frame   '  p-wgh-frame     skip */
/*         ' p-cod-table   '  p-cod-table     skip */
/*         ' p-row-table   '  p-row-table     skip */
/*         ' transaction() '  transaction .        */

IF p-ind-event  = "INITIALIZE" THEN DO:
    
    run utils\findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).
    if valid-handle(fcod_portador) then return.
    
    run utils\findWidget.p('cod_portador', 'fill-in', p-wgh-frame, output codPortador).
    if valid-handle(codPortador) then do:
        create fill-in fcod_portador
            assign                                                                    
                frame       = codPortador:frame                                   
                width       = codPortador:width                                    
                height      = codPortador:height                                   
                row         = codPortador:row                                      
                col         = codPortador:col        
                bgcolor     = codPortador:bgcolor
                sensitive   = true                                                    
                visible     = true
                name        = 'fcod_portador'                                              
                tooltip     = codPortador:tooltip
                help        = codPortador:help
                triggers:                                                             
                  on leave persistent run upc/upc-add_bord_ap-evt.p(p-wgh-frame).
                  on entry persistent run upc/upc-add_bord_ap-evt2.p(p-wgh-frame).
                end triggers.                                                         
            
            fcod_portador:move-after-tab-item (codPortador).
            codPortador:tab-stop = no.
            codPortador:visible = no.
            codPortador:sensitive = no.


    end.
    
    run utils\findWidget.p('bt_zoo_64301', 'button', p-wgh-frame, output btZoomPortador).
    if valid-handle(btZoomPortador) then do:
        create button fbtZoomPortador
            assign                                                                    
                frame       = btZoomPortador:frame                                   
                width       = btZoomPortador:width                                    
                height      = btZoomPortador:height                                   
                row         = btZoomPortador:row                                      
                col         = btZoomPortador:col                                  
                sensitive   = true                                                    
                visible     = true                                                    
                name        = 'fbt_zoo_64301'                                              
                tooltip     = btZoomPortador:tooltip
                help        = btZoomPortador:help
                triggers:                                                             
                  on choose persistent run upc/upc-add_bord_ap-evt3.p(p-wgh-frame).
                end triggers.                                                         
            
            fbtZoomPortador:move-after-tab-item (btZoomPortador).
            btZoomPortador:tab-stop = no.
            fbtZoomPortador:load-image(btZoomPortador:image).
            btZoomPortador:sensitive = no.
            btZoomPortador:visible = no.
            
    end.

    /* INICIO - SM de Parametro para Desconto Distribuidora */
    run utils\findWidget.p('log_bord_ap_escrit', 'TOGGLE-BOX', p-wgh-frame, output h_log_bord_ap_escrit).
    IF     VALID-HANDLE(h_log_bord_ap_escrit)    AND 
       NOT VALID-HANDLE(h_log_bord_ap_desc_dist) THEN DO:

        CREATE TOGGLE-BOX h_log_bord_ap_desc_dist
            assign                                                                    
                frame       = h_log_bord_ap_escrit:FRAME 
                width       = h_log_bord_ap_escrit:WIDTH + 10                                   
                height      = h_log_bord_ap_escrit:HEIGHT                                   
                row         = h_log_bord_ap_escrit:ROW                                      
                col         = h_log_bord_ap_escrit:COL + 20   
/*                 bgcolor     = h_log_bord_ap_escrit:bgcolor */
                sensitive   = true                                                    
                visible     = true
                name        = 'log_bord_ap_desc_dist'
                LABEL       = "Desconto Financ. Distribuidora"
                tooltip     = ""
                help        = "Desconto Financ. Distribuidora"
                .                                                        
            
            h_log_bord_ap_desc_dist:move-after-tab-item (h_log_bord_ap_escrit).
    END.
    /* FIM    - SM de Parametro para Desconto Distribuidora */

    /* INICIO - SM Desconto Bordero */
    RUN utils\findWidget.p('val_tot_lote_pagto_efetd', 'FILL-IN', p-wgh-frame, output h_val_tot_lote_pagto_efetd).
    IF     VALID-HANDLE(h_val_tot_lote_pagto_efetd) AND
       NOT VALID-HANDLE(h_val_desconto)             THEN DO:

        CREATE FILL-IN h_val_desconto
            assign                                                                    
                frame       = h_val_tot_lote_pagto_efetd:frame                                   
                width       = h_val_tot_lote_pagto_efetd:width - 14                                   
                height      = h_val_tot_lote_pagto_efetd:HEIGHT                                  
                row         = h_val_tot_lote_pagto_efetd:row                                      
                col         = h_val_tot_lote_pagto_efetd:col + 40      
                bgcolor     = h_val_tot_lote_pagto_efetd:bgcolor
/*                 FORMAT      = ">9,99" */
                sensitive   = true     
/*                 DECIMALS    = 2 */
                visible     = true
                name        = 'val_desconto'                                              
                tooltip     = "Taxa Oper."
                help        = "Taxa Oper."
            .

    CREATE TEXT h_lb_val_desconto
    ASSIGN FRAME           = h_val_desconto:FRAME
           FORMAT          = "x(14)"
           WIDTH           = 12
           SCREEN-VALUE    = "Taxa Operacao:"
           ROW             = h_val_desconto:ROW + 0.2
           COL             = h_val_desconto:COL - 12
           FGCOLOR         = 0
           VISIBLE         = YES.  

        ASSIGN h_val_desconto:SCREEN-VALUE = "0,00".

    END.
    /* FIM    - SM Desconto Bordero */
    
end.

if p-ind-event = 'ENABLE' then do:
    run utils/findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).
    if valid-handle(fcod_portador) then
        assign fcod_portador:screen-value = ''.
end.

IF p-ind-event = 'ASSIGN' THEN DO:

    RUN utils/findWidget.p('log_bord_ap_desc_dist', 'TOGGLE-BOX', p-wgh-frame, OUTPUT h_log_bord_ap_desc_dist).
    IF VALID-HANDLE(h_log_bord_ap_desc_dist) THEN DO:

        FIND FIRST b_bord_ap NO-LOCK
             WHERE RECID(b_bord_ap) = p-row-table NO-ERROR.
        IF AVAIL b_bord_ap THEN DO:
            ASSIGN b_bord_ap.log_livre_2 = h_log_bord_ap_desc_dist:CHECKED.
        END.
    END.

    RUN utils/findWidget.p('val_desconto', 'FILL-IN', p-wgh-frame, OUTPUT h_val_desconto).
    IF VALID-HANDLE(h_val_desconto) THEN DO:

        FIND FIRST b_bord_ap NO-LOCK
             WHERE RECID(b_bord_ap) = p-row-table NO-ERROR.
        IF AVAIL b_bord_ap THEN DO:
            ASSIGN b_bord_ap.val_livre_1 = DEC(h_val_desconto:SCREEN-VALUE) NO-ERROR.
        END.
    END.

END.


/**/
RETURN "OK":U .
