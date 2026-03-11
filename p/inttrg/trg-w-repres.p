/****************************************************************************************************
**   Programa: trg-w-repres.p - Trigger de write para a tabela representante
**             Criar tabela de altera‡Æo para envio API
**   Data....: Dezembro/2024
**   KML Consultoria - Lohan Fazolin
*****************************************************************************************************/
DEF PARAM BUFFER b-representante  FOR representante.
DEF PARAM BUFFER b-old-representante FOR representante. 
def new global shared var v_cdn_empres_usuar  LIKE ems2log.empresa.ep-codigo no-undo.  
  
    
FIND FIRST representante NO-LOCK NO-ERROR.

IF v_cdn_empres_usuar = "10" THEN DO:

     IF AVAIL b-representante THEN DO:
        
        CREATE esp-envio-api.
        ASSIGN esp-envio-api.num_pessoa_repres = representante.num_pessoa.
               
        RUN intprg/int304Rep.p (INPUT ROWID(esp-envio-api)).
    
     END.

END.
