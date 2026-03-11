/****************************************************************************************************
**   Programa: trg-w-cond-pag.p - Trigger de write para a tabela cond-pagto
**             Criar tabela de altera‡Æo para envio API
**   Data....: Dezembro/2024
**   KML Consultoria - Lohan Fazolin
*****************************************************************************************************/
DEF PARAM BUFFER b-cond-pagto  FOR ems2log.cond-pagto.
DEF PARAM BUFFER b-old-cond-pagto FOR ems2log.cond-pagto. 
def new global shared var v_cdn_empres_usuar  LIKE ems2log.empresa.ep-codigo no-undo.  
    
FIND FIRST ems2log.cond-pagto NO-LOCK NO-ERROR.

    IF v_cdn_empres_usuar = "10" THEN DO:
        
         IF AVAIL b-cond-pagto THEN DO:
            
            CREATE esp-envio-api.
            ASSIGN esp-envio-api.cod-cond-pag-esp = cond-pagto.cod-cond-pag.
                   
            RUN intprg/int306CondPgt.p (INPUT ROWID(esp-envio-api)).
    END.
END.
