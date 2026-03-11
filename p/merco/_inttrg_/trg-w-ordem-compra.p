/****************************************************************************************************
**   Programa: trg-w-ordem-compra.p - Trigger de write para a tabela it-nota-fisc
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-ordem-compra		FOR ems2log.ordem-compra.
DEF PARAM BUFFER b-old-ordem-compra	FOR ems2log.ordem-compra. 
def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.  

//MESSAGE "entrou ordem-compra"
    //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF v_cdn_empres_usuar = "10" THEN DO:    
    
    FIND FIRST b-ordem-compra NO-ERROR.

    IF AVAIL b-ordem-compra THEN
    DO:

        CREATE esp-alteracao-bi.
        ASSIGN esp-alteracao-bi.tabela = "ordem-compra"
               esp-alteracao-bi.dt-alteracao = TODAY
               esp-alteracao-bi.num-pedido = b-ordem-compra.num-pedido
               esp-alteracao-bi.situacao = string(b-ordem-compra.situacao)
           .
           
         FIND FIRST esp-alteracao-bi NO-LOCK
            WHERE esp-alteracao-bi.tabela = "ordem-compra"
            AND   esp-alteracao-bi.dt-alteracao = TODAY
            AND   esp-alteracao-bi.num-pedido = b-ordem-compra.num-pedido
            AND   esp-alteracao-bi.situacao = "2" NO-ERROR.
            
            IF AVAIL esp-alteracao-bi  THEN 
            DO:
            
                RUN esp/api/v1/pedido_compra.p (INPUT ROWID(esp-alteracao-bi)).
                
            END.
    END. 
END.
