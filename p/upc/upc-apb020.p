/*****************************************************************************
* Autor: Eduardo Barth
* Data : outubro/2022
*
* UPC dos programas: add_item_lote_impl_ap - apb704da.p
*                    mod_item_lote_impl_ap_base - apb704fb.p
*
* Registra informaçõess de pagamentos de tributos sem código de barras.
* Tais informações são enviadas via EDI para o pagamento Bradesco. 
******************************************************************************/

/* *** DEFINICAO DE PARAMETROS *** */
DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-rec-table  AS RECID.

DEFINE NEW GLOBAL SHARED VARIABLE wh-txt-tributo-sbarras AS HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE wh-tip-tributo-sbarras AS HANDLE NO-UNDO.

    
IF  p-ind-event  = "INITIALIZE"
AND p-ind-object = "viewer"      
THEN DO:
    IF VALID-HANDLE(wh-txt-tributo-sbarras) THEN DELETE WIDGET wh-txt-tributo-sbarras.
    IF VALID-HANDLE(wh-tip-tributo-sbarras) THEN DELETE WIDGET wh-tip-tributo-sbarras.

    CREATE COMBO-BOX wh-tip-tributo-sbarras
        ASSIGN 
           FRAME     = p-wgh-frame
           WIDTH     = 20
           ROW       = 10.00
           COL       = 52.57
           FONT      = ?
           VISIBLE   = YES
           SENSITIVE = YES
           INNER-LINES = 6
           LIST-ITEM-PAIRS = ",,DARF,DARF,GPS,GPS,GARE-SP,GARE-SP,FGTS,FGTS,IPTU,IPTU"
           TRIGGERS:
             ON F1 ANYWHERE
             DO:
                RUN utp/ut-msgs.p (INPUT 'show':U,
                   INPUT 17006,
                   INPUT 'Tributo Sem C¢digo de Barras~~Estes campos espec¡ficos foram criados para tratar o Pagamento Escritural Bradesco ' +
                         'para tributos SEM codigo de barras (GPS,DARF,GARE-SP) mais o FGTS e IPTU (com c¢digo de barras). Caso seja marcado, na inclusÆo de t¡tulos desta esp‚cie ' +
                         'ser  aberta uma tela adicional para digita‡Æo de dados desse tributo (todos exceto IPTU).').
             END.
           END TRIGGERS.

    CREATE TEXT wh-txt-tributo-sbarras
        ASSIGN 
           FRAME     = p-wgh-frame
           HEIGHT    = 1
           ROW       = 9.00
           COL       = 52.57
           FONT      = ?
           VISIBLE   = YES
           SENSITIVE = YES
           SCREEN-VALUE = "Guia de Tributo:":U
           FORMAT    = "X(30)"
           WIDTH-PIXELS = 180.
END.


IF  p-ind-event  = "DISPLAY"
THEN DO:
    FIND espec_docto_financ WHERE RECID(espec_docto_financ) = p-rec-table
            NO-LOCK NO-ERROR.
    IF VALID-HANDLE(wh-tip-tributo-sbarras)
    AND AVAIL espec_docto_financ THEN DO:
        FIND cst_espec_tributo
            WHERE cst_espec_tributo.cod_espec_docto = espec_docto_financ.cod_espec_docto
            NO-LOCK NO-ERROR.
        ASSIGN wh-tip-tributo-sbarras:SCREEN-VALUE = IF AVAIL cst_espec_tributo THEN cst_espec_tributo.tip_tributo ELSE " ".
    END.
END.


IF p-ind-event = "VALIDATE" THEN 
DO:
    FIND espec_docto_financ WHERE RECID(espec_docto_financ) = p-rec-table
        NO-LOCK NO-ERROR.

    IF VALID-HANDLE(wh-tip-tributo-sbarras)
    AND AVAIL espec_docto_financ THEN DO:
        FIND cst_espec_tributo
            WHERE cst_espec_tributo.cod_espec_docto = espec_docto_financ.cod_espec_docto
            EXCLUSIVE-LOCK NO-ERROR.
        IF  wh-tip-tributo-sbarras:SCREEN-VALUE = "" THEN DO:
            IF  AVAIL cst_espec_tributo THEN
                DELETE cst_espec_tributo.
        END.
        ELSE DO:
            IF NOT AVAIL cst_espec_tributo THEN DO:
                CREATE cst_espec_tributo.
                ASSIGN cst_espec_tributo.cod_espec_docto = espec_docto_financ.cod_espec_docto.
            END.
            ASSIGN cst_espec_tributo.tip_tributo = wh-tip-tributo-sbarras:SCREEN-VALUE.
        END.
    END.
END.

RETURN 'OK'.
