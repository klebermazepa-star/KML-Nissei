/******************************************************************************
 * Programa:  upc-apb710aa.p
 * Diretorio: upc
 * Objetivo:  UPC para exibir bot∆o fatura
 *
 * Autor: ResultPro
 * Data de Criaá∆o: 04/2016
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

/*criaá∆o de viewer dinamicamente*/
define new global shared var adm-broker-hdl as handle           no-undo.


assign  c-objeto    = entry(num-entries(p-wgh-object:private-data, '~/'), p-wgh-object:private-data, '~/').

/*
MESSAGE 'EVENTO' p-ind-event SKIP
        'OBJETO' p-ind-object SKIP
        'NOME OBJ' c-objeto SKIP
        'FRAME' p-wgh-frame SKIP
        'TABELA' p-cod-table SKIP
        'ROWID' STRING(p-row-table) SKIP VIEW-AS ALERT-BOX. */


def new global shared var v_cod_fornec_infor_apb710aa   as widget-handle    no-undo.
def new global shared var bt-transf-apb710aa            as widget-handle    no-undo.
def new global shared var bt-exporta-apb710             as widget-handle    no-undo.
def new global shared var v_rec_apb710aa                as recid            no-undo.

DEF NEW GLOBAL SHARED VAR fi-log_bord_ap_desc_dist      as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR fi-dec_bord_ap_desconto       as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR lb-log_bord_ap_desc_dist      as widget-handle    no-undo.
DEF NEW GLOBAL SHARED VAR lb-dec_bord_ap_desconto       as widget-handle    no-undo.  



def buffer b-item-bord for item_bord_ap.

if  p-ind-event  = 'INITIALIZE'         and
    p-ind-object = 'VIEWER'             then do:
    
    assign h_frame = p-wgh-frame:first-child. /*pegando o primeiro field-group*/
    assign h_frame = h_frame:first-child. /*pegando o primeiro campo do field-group*/

    do while h_frame <> ?:
        if h_frame:type <> "field-group" then do:
            if h_frame:name = 'bt_transfere'    then assign  bt-transf-apb710aa = h_frame.
            assign h_frame = h_frame:next-sibling.
        end.
        else do:
            assign h_frame = h_frame:first-child.
        end.
    end.
    
    create button bt-exporta-apb710
    assign  frame           = p-wgh-frame
            width           = bt-transf-apb710aa:width + 10
            height          = bt-transf-apb710aa:height
            row             = bt-transf-apb710aa:row + 2
            col             = bt-transf-apb710aa:col + 1
            label           = "Pagto Distribuidoras"
            sensitive       = yes
            visible         = yes
            tooltip         = 'Pagto Distribuidoras'
            triggers:
                on choose persistent run intupc/upc-apb710.w. 
            end triggers.
    
    /* bt-exporta-apb710:load-image('image/toolbar/im-param.bmp').
       bt-exporta-apb710:move-after-tab-item(bt-transf-apb710aa). */
    CREATE FILL-IN fi-log_bord_ap_desc_dist
    assign  frame           = p-wgh-frame
            width           = 4.00
            height          = 0.88
            row             = bt-transf-apb710aa:row + 3.60
            col             = bt-transf-apb710aa:col - 20
            sensitive       = NO
            visible         = YES
            tooltip         = 'Desc. Financ. Distribuidora'
            .

    CREATE FILL-IN fi-dec_bord_ap_desconto
    assign  frame           = p-wgh-frame
            width           = 8.00
            height          = 0.88
            row             = bt-transf-apb710aa:row + 3.60
            col             = bt-transf-apb710aa:COL - 7.2 
            sensitive       = NO
            visible         = YES
            tooltip         = 'Taxa Operacao'
            .

    CREATE TEXT lb-log_bord_ap_desc_dist
    ASSIGN FRAME           = fi-log_bord_ap_desc_dist:FRAME
           FORMAT          = "x(28)"
           WIDTH           = 19
           SCREEN-VALUE    = "Desc. Financ. Distribuidora:"
           ROW             = fi-log_bord_ap_desc_dist:ROW + 0.2
           COL             = fi-log_bord_ap_desc_dist:COL - 19
           FGCOLOR         = 0
           VISIBLE         = YES.

    CREATE TEXT lb-dec_bord_ap_desconto
    ASSIGN FRAME           = fi-dec_bord_ap_desconto:FRAME
           FORMAT          = "x(11)"
           WIDTH           = 8
           SCREEN-VALUE    = "Taxa Oper.:"
           ROW             = fi-dec_bord_ap_desconto:ROW + 0.2
           COL             = fi-dec_bord_ap_desconto:COL - 8
           FGCOLOR         = 0
           VISIBLE         = YES.    
end.

if  p-ind-event  = 'DISPLAY'            and
    p-ind-object = 'VIEWER'             then do:
        
    assign  v_rec_apb710aa              = p-row-table.

    FIND FIRST bord_ap NO-LOCK
         WHERE RECID(bord_ap) = p-row-table NO-ERROR.
    IF AVAIL bord_ap THEN DO:
        IF bord_ap.log_livre_2 THEN 
             ASSIGN fi-log_bord_ap_desc_dist:SCREEN-VALUE = "Sim":U.
        ELSE ASSIGN fi-log_bord_ap_desc_dist:SCREEN-VALUE = "N∆o":U.

        ASSIGN fi-dec_bord_ap_desconto:SCREEN-VALUE = STRING(bord_ap.val_livre_1,">9.99").
    END.

end.





