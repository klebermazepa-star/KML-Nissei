/**********************************************************************        
*Programa.: wsinventti0004.p                                          * 
*Descricao: Consulta de notas fiscais para a Inventi                  * 
*Autor....: Raimundo C. Soares                                        * 
*Data.....: 12/2022                                                   * 
**********************************************************************/
{int\wsinventti0000.i}

DEF INPUT PARAMETER p-cod-estabel    like  nota-fiscal.cod-estabel no-undo. 
DEF INPUT PARAMETER p-serie          like  nota-fiscal.serie       no-undo. 
DEF INPUT PARAMETER p-nr-nota-fisc   like  nota-fiscal.nr-nota-fis no-undo. 

DEF BUFFER bint_ndd_envio FOR int_ndd_envio.
DEF VAR c-justificatica      AS CHAR     NO-UNDO.
DEF VAR p-enveto             AS CHAR     NO-UNDO.
DEF VAR p-xml                AS LONGCHAR NO-UNDO.   
DEF VAR i-tipo               AS INT      NO-UNDO.    
DEF var c-url                AS CHAR     NO-UNDO.
DEFINE VARIABLE mem-aux AS MEMPTR      NO-UNDO.
DEFINE VARIABLE lc-aux  AS LONGCHAR    NO-UNDO.

ASSIGN c-justificatica = ''
       p-enveto        = ''
       i-tipo          = 4.
        
FIND FIRST nota-fiscal 
     WHERE nota-fiscal.cod-estabel =  p-cod-estabel  //"017"
     AND   nota-fiscal.serie       =  p-serie        //'1'
     AND   nota-fiscal.nr-nota-fis =  p-nr-nota-fisc //'0004138'
     NO-LOCK NO-ERROR.

.MESSAGE "int004"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF AVAIL nota-fiscal THEN do:

    .MESSAGE "antes 003"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   RUN int\wsinventti0003.p  (INPUT  nota-fiscal.cod-estabel,   
                              INPUT  nota-fiscal.serie,         
                              INPUT  nota-fiscal.nr-nota-fis,   
                              INPUT  p-enveto,                  
                              INPUT  c-justificatica,
                              INPUT i-tipo ,
                              OUTPUT p-xml). 

   //MESSAGE   STRING(p-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "wsinventti0004 ".
   FIND FIRST esp_integracao 
        WHERE  esp_integracao.id_integracao = 1
        NO-ERROR.
   
   FIND FIRST esp_servico_integracao
        WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
        AND   esp_servico_integracao.descricao = "CONSULTA NFe"
        NO-LOCK NO-ERROR.
       
   ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

   //MESSAGE c-url VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   //MESSAGE STRING(p-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "XML consulta".

   //v-retonro-integracao = ?.
   RUN int\wsinventti0001.p  (INPUT  c-url, 
                              INPUT  p-xml,
                              OUTPUT v-retonro-integracao).

  
   //MESSAGE STRING(v-retonro-integracao) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE 'Retorno Iventti'.

   
   IF v-retonro-integracao <> '' THEN do:
      //COPY-LOB v-retonro-integracao TO  FILE "C:\temp\retonro-nf-0004167.xml".
      RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                INPUT ROWID(nota-fiscal)).
   END.
END.



