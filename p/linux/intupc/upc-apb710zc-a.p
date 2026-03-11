/******************************************************************************
 * Programa:  upc-apb710zc.p
 * Diretorio: upc
 * Objetivo:  UPC para aplicar o desconto da Taxa Financeira
 *
 * Autor: ResultPro
 * Data de Cria‡Æo: 07/2017
 *
 ******************************************************************************/
/*componentes criados para capturar o handle do componente*/
def var h_frame                             as widget-handle    no-undo.
def var c-objeto                            as char             no-undo.

/*cria‡Æo de viewer dinamicamente*/
define new global shared var adm-broker-hdl as handle           no-undo.
define new global shared var g-wgh-object   as handle           no-undo.

def new global shared var h_val_pagto          as widget-handle    no-undo.
def new global shared var h_val_pagto_new      as widget-handle    no-undo.
def new global shared var h_v_cod_fornec_infor as widget-handle    no-undo.
def new global shared var h_val_desc_tit_ap    AS widget-handle    no-undo.
def new global shared var h_val_abat_tit_ap    as widget-handle    no-undo.


/* Variavel da recid da bord_ap */
def new global shared var v_rec_apb710aa                as recid            no-undo.

    ASSIGN h_val_pagto:SCREEN-VALUE = h_val_pagto_new:SCREEN-VALUE.

    APPLY "ENTRY" TO h_val_pagto.
    APPLY "LEAVE" TO h_val_pagto.

    ASSIGN h_val_pagto_new:SCREEN-VALUE = h_val_pagto:SCREEN-VALUE. 

    FIND FIRST bord_ap
         WHERE RECID(bord_ap) = v_rec_apb710aa NO-ERROR.
    IF AVAIL bord_ap AND bord_ap.log_livre_2 = YES THEN DO:

        FIND FIRST emitente
             WHERE emitente.cod-emitente = INT(h_v_cod_fornec_infor:SCREEN-VALUE) NO-ERROR.
        IF AVAIL emitente THEN DO:
            
            IF emitente.taxa-financ <> 0 THEN DO:
                ASSIGN  h_val_abat_tit_ap:SCREEN-VALUE = STRING(DEC(h_val_pagto:SCREEN-VALUE) * (emitente.taxa-financ / 100)).
            END.

            IF emitente.bonificacao <> 0 THEN DO:
                ASSIGN  h_val_desc_tit_ap:SCREEN-VALUE = STRING(DEC(h_val_pagto:SCREEN-VALUE) * (emitente.bonificacao / 100)).
            END.

        END.

    END.

RETURN "OK".
