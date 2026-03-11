/*************************************************************************
**    Programa.:  UPC-CC0300A.P
**    Objetivo.:  UPC para cadastro de novos pedidos de compra
*************************************************************************/
{utp/ut-glob.i}

/*********************** Defini»’o de Par³metros *************************/
define input parameter p-ind-event          AS CHARACTER      NO-UNDO.
define input parameter p-ind-object         AS CHARACTER      NO-UNDO.
define input parameter p-wgh-object         AS HANDLE         NO-UNDO.
define input parameter p-wgh-frame          AS WIDGET-HANDLE  NO-UNDO.
define input parameter p-cod-table          AS CHARACTER      NO-UNDO.
define input parameter p-row-table          AS ROWID          NO-UNDO.


define new global shared variable Emergencial     as HANDLE        NO-UNDO.
define new global shared VARIABLE I-EMPRESA       AS INT           NO-UNDO.
FIND ems2mult.empresa NO-LOCK WHERE ems2mult.empresa.ep-codigo = i-ep-codigo-usuario NO-ERROR.
IF NOT AVAIL ems2mult.empresa THEN RETURN.

DEF NEW GLOBAL SHARED VAR i-ep-codigo-usuario  LIKE ems2mult.empresa.ep-codigo NO-UNDO.


.MESSAGE p-ind-event              "p-ind-event  " skip  
          p-ind-object             "p-ind-object " skip 
          p-wgh-object:FILE-NAME   "p-wgh-object " skip 
          p-wgh-frame:NAME         "p-wgh-frame  " skip 
          p-cod-table              "p-cod-table  " skip 
         string(p-row-table)      "p-row-table  "
         VIEW-AS ALERT-BOX INFO BUTTONS OK.         

IF  p-ind-event            = "AFTER-INITIALIZE"
AND p-ind-object           = "CONTAINER"
AND p-wgh-object:FILE-NAME = "ccp/cc0300a.w" THEN DO:


    
   
    .MESSAGE i-ep-codigo-usuario VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    IF i-ep-codigo-usuario = "1" THEN
    DO:
    
        run utils/findWidget.p('emergencial':u, 'toggle-box':u, p-wgh-frame,
        output Emergencial).

        ASSIGN Emergencial:SENSITIVE = NO.
        
    END.

    
       
END.




