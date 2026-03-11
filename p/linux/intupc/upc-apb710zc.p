/******************************************************************************
 * Programa:  upc-apb710zd.p
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

define new global shared var g-wgh-object   as handle           no-undo.

def new global shared var h_val_pagto          as widget-handle    no-undo.
def new global shared var h_val_pagto_text     as widget-handle    no-undo.
def new global shared var h_val_pagto_new      as widget-handle    no-undo.
def new global shared var h_v_cod_fornec_infor as widget-handle    no-undo.
def new global shared var h_val_desc_tit_ap    AS widget-handle    no-undo.
def new global shared var h_val_abat_tit_ap    as widget-handle    no-undo.


assign  c-objeto    = entry(num-entries(p-wgh-object:private-data, '~/'), p-wgh-object:private-data, '~/').

/* MESSAGE 'EVENTO' p-ind-event SKIP                           */
/*         'OBJETO' p-ind-object SKIP                          */
/*         'NOME OBJ' c-objeto SKIP                            */
/*         'FRAME' p-wgh-frame SKIP                            */
/*         'TABELA' p-cod-table SKIP                           */
/*         'ROWID' STRING(p-row-table) SKIP VIEW-AS ALERT-BOX. */

IF p-ind-event  = "INITIALIZE" THEN DO:

    run utils\findWidget.p('val_pagto', 'fill-in', p-wgh-frame, output h_val_pagto).
    IF VALID-HANDLE(h_val_pagto) THEN DO:

        CREATE FILL-IN h_val_pagto_new
        ASSIGN  FRAME           = p-wgh-frame
                WIDTH           = h_val_pagto:WIDTH
                HEIGHT          = h_val_pagto:HEIGHT
                ROW             = h_val_pagto:ROW 
                COL             = h_val_pagto:COL
                SENSITIVE       = YES
                FORMAT          ="x(20)"
                VISIBLE         = YES
                TOOLTIP         = ''.
        ON 'LEAVE':U         OF h_val_pagto_new   PERSISTENT RUN intupc\upc-apb710zc-a.p.

        CREATE TEXT h_val_pagto_text
        ASSIGN FRAME           = h_val_pagto:FRAME
               FORMAT          = "x(11)"
               WIDTH           = 8
               SCREEN-VALUE    = "Val Pagto:"
               ROW             = h_val_pagto:ROW + 0.2
               COL             = h_val_pagto:COL - 8
               FGCOLOR         = 0
               VISIBLE         = YES.

        ASSIGN h_val_pagto:VISIBLE = NO.
        ASSIGN h_val_pagto_new:SCREEN-VALUE = "0,00".

        h_val_pagto_new:MOVE-AFTER-TAB-ITEM(h_val_pagto:HANDLE). 

    END.

    run utils\findWidget.p('v_cod_fornec_infor', 'fill-in', p-wgh-frame, output h_v_cod_fornec_infor).
    run utils\findWidget.p('val_desc_tit_ap',    'fill-in', p-wgh-frame, output h_val_desc_tit_ap).
    run utils\findWidget.p('val_abat_tit_ap',    'fill-in', p-wgh-frame, output h_val_abat_tit_ap).
    
END.

if  p-ind-event  = 'DISPLAY'            and
    p-ind-object = 'VIEWER'             then DO:

    FIND FIRST item_bord_ap NO-LOCK
         WHERE RECID(item_bord_ap) = p-row-table NO-ERROR.
    IF AVAIL item_bord_ap THEN DO:
        ASSIGN h_val_pagto_new:SCREEN-VALUE = STRING(h_val_pagto:SCREEN-VALUE).
    END.
    ELSE DO:
        ASSIGN h_val_pagto_new:SCREEN-VALUE = STRING(h_val_pagto:SCREEN-VALUE).
    END.

    ASSIGN h_val_pagto:VISIBLE = NO.

END.

if  p-ind-event  = 'ENABLE'      and
    p-ind-object = 'VIEWER'      then do:

    ASSIGN h_val_pagto:VISIBLE = NO.

END.


RETURN "OK".

/* ---------------------------
Mensagem
---------------------------
EVENTO DISPLAY 
OBJETO viewer 
NOME OBJ HLP=5 
FRAME 2456 
TABELA item_bord_ap 
ROWID 1790476 
---------------------------
OK   
---------------------------
 */
