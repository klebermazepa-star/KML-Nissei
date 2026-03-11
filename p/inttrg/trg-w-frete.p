/****************************************************************************************************
**   Programa: trg-w-frete.p - Trigger de write para a tabela frete
**             Criar tabela de altera‡Æo para envio API
**   Data....: Dezembro/2024
**   KML Consultoria - Lohan Fazolin
*****************************************************************************************************/
DEF PARAM BUFFER b-modalid-frete  FOR ems2dis.modalid-frete.
DEF PARAM BUFFER b-old-modalid-frete FOR ems2dis.modalid-frete.
def new global shared var v_cdn_empres_usuar  LIKE ems2log.empresa.ep-codigo no-undo.  

  
    
FIND FIRST b-modalid-frete NO-LOCK NO-ERROR.

    IF AVAIL b-modalid-frete THEN
    DO:
    
         IF v_cdn_empres_usuar = "10" THEN DO:

            CREATE esp-envio-api.
            ASSIGN esp-envio-api.esp-cod-modalid-frete = b-modalid-frete.cod-modalid-frete.

            RUN intprg/int305frete.p (INPUT ROWID(esp-envio-api)). 
    END.
     
END.
