/***************************************************************************************
**  Programa....:   upc-pd4000a.p
**  Autor.......:   Carlos Daniel (KML) 
**  Cadastrar em:   PD4000A               
*/

DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE        NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-row-table  AS ROWID         NO-UNDO.

DEFINE VARIABLE c-objeto    AS CHARACTER NO-UNDO.

DEF NEW GLOBAL SHARED VARIABLE c-seg-usuario AS CHARACTER NO-UNDO.

DEF NEW GLOBAL SHARED VAR wgh-nr-pedcli      AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-nome-abrev     AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wgh-fill           AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-btOK-orig       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-btOK            AS WIDGET-HANDLE NO-UNDO.

DEF                   VAR h-pd4000a        AS HANDLE         NO-UNDO.


IF p-wgh-object <> ? THEN 
    ASSIGN c-objeto = ENTRY(NUM-ENTRIES(p-wgh-object:FILE-NAME,'/'),
                                        p-wgh-object:FILE-NAME,'/').

/* if c-seg-usuario = "reynaldo" then do:                   */
/*    MESSAGE "p-ind-event : "  p-ind-event  skip           */
/*             "p-ind-object: " p-ind-object skip           */
/*             "p-wgh-object: " p-wgh-object:FILE-NAME SKIP */
/*             "p-wgh-frame: "  p-wgh-frame  SKIP           */
/*             "Tabela: "       p-cod-table  skip           */
/*             "c-objeto: " c-objeto                        */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK.               */
/* end.                                                     */

IF p-ind-event  = "after-initialize"   THEN DO:
    IF NOT VALID-HANDLE(h-pd4000a) THEN
        RUN upc\upc-pd4000a.p PERSISTENT SET h-pd4000a (INPUT '':U        ,
                                                        INPUT '':U        ,
                                                        INPUT p-wgh-object,
                                                        INPUT p-wgh-frame ,
                                                        INPUT '':U        ,
                                                        INPUT p-row-table). 

    ASSIGN wgh-fill = p-wgh-frame:FIRST-CHILD
           wgh-fill = wgh-fill   :FIRST-CHILD.
           
    DO WHILE VALID-HANDLE(wgh-fill):
        IF wgh-fill:TYPE = "button" THEN DO:
            IF wgh-fill:NAME = "btOK" THEN
                ASSIGN wh-btOK-orig = wgh-fill.
        END.
        
        ASSIGN wgh-fill = wgh-fill:NEXT-SIBLING.
    END.

    IF NOT VALID-HANDLE(wh-btOK) AND VALID-HANDLE(wh-btOK-orig) THEN DO:
        CREATE BUTTON wh-btOK
        ASSIGN
            FRAME     = p-wgh-frame
            WIDTH     = wh-btOK-orig:width
            HEIGHT    = wh-btOK-orig:height
            ROW       = wh-btOK-orig:row
            LABEL     = wh-btOK-orig:LABEL
            COL       = wh-btOK-orig:COL
            SENSITIVE = wh-btOK-orig:sensitive
            VISIBLE   = wh-btOK-orig:visible
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN pi-choose-OK IN h-pd4000a(wh-btOK-orig:HANDLE).
            END TRIGGERS.
    END.
END.

RETURN.

/*=========================================================================================================================*/
 PROCEDURE pi-choose-OK:
    DEF INPUT PARAMETER p-handle-ok AS HANDLE NO-UNDO.

    DEFINE BUFFER bf-ped-venda FOR ped-venda.
    
    IF NOT VALID-HANDLE(h-pd4000a) THEN
        RUN upc\upc-pd4000a.p PERSISTENT SET h-pd4000a (INPUT '':U        ,
                                                        INPUT '':U        ,
                                                        INPUT p-wgh-object,
                                                        INPUT p-wgh-frame ,
                                                        INPUT '':U        ,
                                                        INPUT p-row-table). 

    FOR FIRST bf-ped-venda EXCLUSIVE-LOCK
        WHERE bf-ped-venda.nome-abrev = wgh-nome-abrev:SCREEN-VALUE
        AND   bf-ped-venda.nr-pedcli  = wgh-nr-pedcli:SCREEN-VALUE:
        
        ASSIGN bf-ped-venda.completo = YES.
    END.
    RELEASE bf-ped-venda.
    
    APPLY "choose" TO p-handle-ok.
 END.  /* pi-choose-OK */ 
