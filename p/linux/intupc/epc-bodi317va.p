/******************************************************************************************
**  Programa: epc-bodi317va.p
**   
**  Objetivo: Validar duplicaddes de notas faturadas  
******************************************************************************************/      
          
{include/i-epc200.i bodi317ef}
{utp/ut-glob.i}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 

DEF VAR c-nome-abrev  LIKE ped-venda.nome-abrev NO-UNDO.
DEF VAR c-nr-pedcli   LIKE ped-venda.nr-pedcli  NO-UNDO.

DEF BUFFER b-nota-fiscal FOR nota-fiscal. 

DEF VAR hBODI317va AS HANDLE NO-UNDO.

IF p-ind-event  = "unlock_Ped-Venda" 
THEN DO:

   find FIRST tt-epc where 
              tt-epc.cod-event     = p-ind-event AND 
              tt-epc.cod-parameter = "object-handle" NO-LOCK NO-ERROR.
   IF AVAIL tt-epc   
   THEN DO:
     ASSIGN hBODI317va = WIDGET-HANDLE(tt-epc.val-parameter). 
   END.
   
   find FIRST tt-epc where 
              tt-epc.cod-event     = p-ind-event AND 
              tt-epc.cod-parameter = "nome-abrev" NO-LOCK NO-ERROR.
   IF AVAIL tt-epc   
   THEN DO:
       ASSIGN c-nome-abrev = STRING(tt-epc.val-parameter).
   END.

   find FIRST tt-epc where 
              tt-epc.cod-event     = p-ind-event AND 
              tt-epc.cod-parameter = "nr-pedcli" NO-LOCK NO-ERROR.
   IF AVAIL tt-epc   
   THEN DO:
      ASSIGN c-nr-pedcli = STRING(tt-epc.val-parameter).
   END.
   
   FOR FIRST ped-venda NO-LOCK WHERE
             ped-venda.nome-abrev = c-nome-abrev AND 
             ped-venda.nr-pedcli  = c-nr-pedcli:

   END.
   IF AVAIL ped-venda 
   THEN DO:
  
         FIND FIRST wt-docto NO-LOCK WHERE 
                    wt-docto.nome-abrev =  ped-venda.nome-abrev AND 
                    wt-docto.nr-pedcli  =  ped-venda.nr-pedcli  AND 
                    wt-docto.usuario   <>  c-seg-usuario NO-ERROR.
         IF AVAIL wt-docto 
         THEN DO:
    
            RUN _insertErrorManual IN hBODI317va (INPUT 99999,
                                                  INPUT "EMS",
                                                  INPUT "ERROR",
                                                  INPUT "Pedido preparado para faturar pelo usu rio " + STRING(wt-docto.usuario),
                                                  INPUT "Verifique se outro usu rio est  tentando faturar o mesmo pedido.",
                                                  INPUT "").
            RETURN "NOK".
    
         END. 

   END.
   
END.

RETURN "OK".
     
