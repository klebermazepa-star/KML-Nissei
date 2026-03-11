/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-re0103.p
**  
**  Objetivo: Criar botÆo no programa re0103 para chamar tela para parametriza‡Æo do 
**            diret¢rio de origem dos arquivos XML e diret¢rio destino dos arquivos 
**            processados. 
***************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

/*  MESSAGE p-ind-event              "p-ind-event  " skip  */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */
   
DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame          AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-bt-par-xml-re0103     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-botao-xml-re0103      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-tx-dif-impto-re0103   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-vl-dif-impto-re0103   AS WIDGET-HANDLE no-undo.

{utp/ut-glob.i}

IF p-ind-event  = "initialize" AND
   p-ind-object = "container"
THEN DO:
    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD.

    DO WHILE VALID-HANDLE(wh-frame):

        IF wh-frame:NAME = "bt-ok" THEN
           ASSIGN wh-bt-par-xml-re0103 = wh-frame.

        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.

    IF VALID-HANDLE (wh-bt-par-xml-re0103)
    THEN DO:

        CREATE BUTTON wh-botao-xml-re0103
        ASSIGN FRAME     = wh-bt-par-xml-re0103:FRAME
               LABEL     = "XML"
               FONT      = wh-bt-par-xml-re0103:FONT
               WIDTH     = wh-bt-par-xml-re0103:WIDTH
               HEIGHT    = wh-bt-par-xml-re0103:HEIGHT
               ROW       = wh-bt-par-xml-re0103:ROW
               COL       = wh-bt-par-xml-re0103:COL + 22
               FGCOLOR   = ?
               BGCOLOR   = ?
               TOOLTIP   = "Diret¢rio Arquivos XML"
               VISIBLE   = wh-bt-par-xml-re0103:VISIBLE
               SENSITIVE = YES
               TRIGGERS:
                   ON CHOOSE PERSISTENT RUN intprg/int002a.w.
               END TRIGGERS.

    END.

    create text wh-tx-dif-impto-re0103
    assign frame        = p-wgh-frame
           format       = "x(34)"
           width        = 34.00
           screen-value = "Diferen‡a Aceit vel Impostos (R$):"
           row          = 8 
           col          = 12.5
           visible      = yes.  

    CREATE FILL-IN wh-vl-dif-impto-re0103
    assign frame              = p-wgh-frame
           side-label-handle  = wh-tx-dif-impto-re0103:handle
           height             = 0.88
           DATA-TYPE          = "DECIMAL"
           format             = ">>9.99"
           width              = 8
           row                = 7.8 
           col                = 36.5
           visible            = YES
           SENSITIVE          = YES.



    FOR FIRST cst_param_estoq NO-LOCK:
        ASSIGN wh-vl-dif-impto-re0103:SCREEN-VALUE = STRING(cst_param_estoq.de_valor_dif_aceita_impto).
    END.
END.

IF p-ind-event = "DESTROY" 
THEN DO: 
    FOR FIRST cst_param_estoq EXCLUSIVE-LOCK:
    END.

    IF  NOT AVAIL cst_param_estoq
    THEN DO:
        CREATE cst_param_estoq.
    END.

    ASSIGN cst_param_estoq.de_valor_dif_aceita_impto = DEC(wh-vl-dif-impto-re0103:SCREEN-VALUE).

    ASSIGN wh-tx-dif-impto-re0103 = ?
           wh-vl-dif-impto-re0103 = ?.

    RELEASE cst_param_estoq.
END.

RETURN "OK".

