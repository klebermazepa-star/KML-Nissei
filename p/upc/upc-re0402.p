/*************************************************************************
 Programa.: upc-re0402.p
 Autor....: Sensus Tecnologia
 Objetivo.: Desabilitar campo "Desatualiza Contas a Pagar" e manter marcado.
 Data.....: 27/08/2021
 Vers’o...: 2.01.00.000
*************************************************************************/

{utp/ut-glob.i}

/*********************** Defini‡Æo de Parametros *************************/
DEFINE INPUT PARAMETER p-ind-event                 AS CHARACTER      NO-UNDO.
DEFINE INPUT PARAMETER p-ind-object                AS CHARACTER      NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-object                AS HANDLE         NO-UNDO.
DEFINE INPUT PARAMETER p-wgh-frame                 AS WIDGET-HANDLE  NO-UNDO.
DEFINE INPUT PARAMETER p-cod-table                 AS CHARACTER      NO-UNDO.
DEFINE INPUT PARAMETER p-row-table                 AS ROWID          NO-UNDO.


/*********************** Defini‡Æo de Variaveis **************************/
DEF VAR c-char                   AS CHAR          NO-UNDO.
DEF VAR wh-objeto                AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child                AS WIDGET-HANDLE NO-UNDO.
/*************************************************************************/

ASSIGN c-char = ENTRY(NUM-ENTRIES(p-wgh-object:FILE-NAME,"~/"), p-wgh-object:FILE-NAME,"~/") NO-ERROR.

IF  p-ind-event  = "CHANGE-PAGE" 
AND p-ind-object = "CONTAINER" THEN DO:

    ASSIGN wh-objeto = p-wgh-frame:FIRST-CHILD.

    DO  WHILE VALID-HANDLE(wh-objeto):
        IF  wh-objeto:NAME = "l-desatualiza-ap" THEN DO:
            ASSIGN wh-objeto:SCREEN-VALUE = 'YES'
                   wh-objeto:SENSITIVE = NO.
        END.

        IF  wh-objeto:TYPE = "FIELD-GROUP" THEN
            ASSIGN wh-objeto = wh-objeto:FIRST-CHILD.
        ELSE
            ASSIGN wh-objeto = wh-objeto:NEXT-SIBLING.
    END.
END.

