/******************************************************************************
 * Programa:  upc-apb711zd.p
 * Diretorio: upc
 * Objetivo:  UPC para aplicar o desconto da Taxa Financeira
 *
 * Autor: ResultPro
 * Data de Cria‡Æo: 07/2017
 *
 ******************************************************************************/
define input  param p-ind-event             as char             no-undo.
define input  param p-ind-object            as char             no-undo.
define input  param p-wgh-object            as handle           no-undo.
define input  param p-wgh-frame             as widget-handle    no-undo.
define input  param p-cod-table             as character        no-undo.
define input  param p-row-table             as recid            no-undo.

/*componentes criados para capturar o handle do componente*/
def var h_frame                             as widget-handle    no-undo.
def var c-objeto                            as char             no-undo.

/*cria‡Æo de viewer dinamicamente*/
define new global shared var adm-broker-hdl as handle           no-undo.

def new global shared var h_val_pagto          as widget-handle    no-undo.
def new global shared var h_v_cod_fornec_infor as widget-handle    no-undo.
def new global shared var h_val_desc_tit_ap    AS widget-handle    no-undo.
def new global shared var h_val_abat_tit_ap    as widget-handle    no-undo.

/* Variavel da recid da bord_ap */
def new global shared var v_rec_apb710aa                as recid            no-undo.


assign  c-objeto    = entry(num-entries(p-wgh-object:private-data, '~/'), p-wgh-object:private-data, '~/').


/* MESSAGE 'EVENTO' p-ind-event SKIP                           */
/*         'OBJETO' p-ind-object SKIP                          */
/*         'NOME OBJ' c-objeto SKIP                            */
/*         'FRAME' p-wgh-frame SKIP                            */
/*         'TABELA' p-cod-table SKIP                           */
/*         'ROWID' STRING(p-row-table) SKIP VIEW-AS ALERT-BOX. */


IF p-ind-event  = "ITEM BORDERO" AND
   p-ind-object = "VIEWER" THEN DO:

    FIND FIRST bord_ap
         WHERE RECID(bord_ap) = v_rec_apb710aa NO-ERROR.
    IF AVAIL bord_ap AND bord_ap.log_livre_2 = YES THEN DO:

        FIND FIRST item_bord_ap EXCLUSIVE-LOCK
             WHERE RECID(item_bord_ap) = p-row-table NO-ERROR.
        IF AVAIL item_bord_ap THEN DO:
    
            FIND FIRST emitente
                 WHERE emitente.cod-emitente = item_bord_ap.cdn_fornecedor NO-ERROR.
            IF AVAIL emitente THEN DO:
                
                IF emitente.taxa-financ <> 0 THEN DO:
                    ASSIGN  item_bord_ap.val_abat_tit_ap = item_bord_ap.val_pagto * (emitente.taxa-financ / 100).
                END.
    
                IF emitente.bonificacao <> 0 THEN DO:
                    ASSIGN  item_bord_ap.val_desc_tit_ap = item_bord_ap.val_pagto  * (emitente.bonificacao / 100).
                END.
    
            END.
        END.
    END.
END.

                                                                                              



RETURN "OK".
