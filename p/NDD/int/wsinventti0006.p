/**********************************************************************        
*Programa.: wsinventti0006.p                                          * 
*Descricao: Envio de notas fiscais para a Inventi                     * 
*Autor....: Raimundo                                                  * 
*Data.....: 12/2022                                                   * 
**********************************************************************/
{int\wsinventti0000.i}
DEF INPUT PARAMETER p-rowid-nota-fiscal AS ROWID NO-UNDO.
DEFINE VARIABLE c-xml        AS CHARACTER   NO-UNDO.
DEF var c-url                AS CHAR      NO-UNDO.

define new global shared variable r-rowid-axsep006 as rowid no-undo.
define new global shared variable h-epc-axsep006 as handle no-undo.

DEF VAR c-xml-nota           AS LONGCHAR NO-UNDO.

def var cFileDocument as char no-undo.     
def var cCaminhoTMP   as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.

FIND FIRST nota-fiscal
     WHERE ROWID(nota-fiscal) = p-rowid-nota-fiscal
     NO-LOCK NO-ERROR.

IF AVAIL nota-fiscal THEN DO:

   FIND FIRST esp_integracao 
        WHERE  esp_integracao.id_integracao = 1
        NO-ERROR.

   FIND FIRST esp_servico_integracao
        WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
        AND  esp_servico_integracao.descricao = "venda Nfe"
        NO-LOCK NO-ERROR.

   ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

   if  not valid-handle(h-epc-axsep006) then do:
       run adapters/xml/ep2/axsep006.p persistent set h-epc-axsep006.
    
       RUN PITransUpsert IN h-epc-axsep006 (input "upd":U,
                                            input  "InvoiceNFe":U,
                                            input  rowid(nota-fiscal),
                                            output table tt_log_erro).
   
       RUN pi-retornaXMLNFe IN h-epc-axsep006 (output c-xml-nota).
   
   
   
   END.
   
   IF c-xml-nota = '' THEN do:
      FOR FIRST int_ndd_envio
          WHERE int_ndd_envio.cod_estabel =  nota-fiscal.cod-estabel 
          AND   int_ndd_envio.serie       =  nota-fiscal.serie       
          AND   int_ndd_envio.nr_nota_fis =  nota-fiscal.nr-nota-fis
          NO-LOCK BY ID DESC:
      
          copy-lob int_ndd_envio.DOCUMENTDATA to  c-xml-nota.
      END.
   END.

   //MESSAGE string(c-xml-nota) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE " XML nota 0006".
   
   IF TRIM(c-xml-nota) <> "" THEN do:
       RUN int\wsinventti0001.p  (INPUT  c-url, 
                                  INPUT  c-xml-nota,
                                  OUTPUT v-retonro-integracao).
      
       
      //MESSAGE STRING(v-retonro-integracao) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE 'retorno nf 0001'.
       IF v-retonro-integracao <> "" THEN do:
          RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                INPUT ROWID(nota-fiscal)).
      
       END.
   END.

  
   
END.


   
