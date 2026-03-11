/****************************************************************************************************
**   Programa: trg-w-cidade.p - Trigger de write para a tabela Cidade
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/
DEF PARAM BUFFER b-cidade     FOR ems2dis.cidade.
DEF PARAM BUFFER b-old-cidade FOR ems2dis.cidade. 
def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.  
    
 FIND FIRST b-cidade NO-ERROR.
 
 IF AVAIL b-cidade THEN
 DO:
 
   /* CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "cidade"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cidade = b-cidade.cidade
           esp-alteracao-bi.estado = b-cidade.estado
           esp-alteracao-bi.pais = b-cidade.pais.
           
    IF v_cdn_empres_usuar = "10" THEN DO:
        
         RUN intprg/int303Cid.p (INPUT ROWID(esp-alteracao-bi)).  
    END.
          */
 END.
