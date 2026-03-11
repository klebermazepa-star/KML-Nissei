/**********************************************************************        
*Programa.: wsinventti0002.p                                          * 
*Descricao: Envio de notas fiscais para a Inventi                     * 
*Autor....: Raimundo                                                  * 
*Data.....: 12/2022                                                   * 
**********************************************************************/
{int\wsinventti0000.i}
DEF INPUT PARAMETER p-rowid-nota-fiscal AS ROWID NO-UNDO.
DEFINE VARIABLE c-xml        AS CHARACTER   NO-UNDO.
DEF var c-url                AS CHAR      NO-UNDO.

define new global shared variable r-rowid-axsep037 as rowid no-undo.
define new global shared variable h-epc-axsep037 as handle no-undo.

DEF VAR c-xml-nota           AS LONGCHAR NO-UNDO.

def var cFileDocument as char no-undo.     
def var cCaminhoTMP   as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.

.MESSAGE "int002"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

FIND FIRST nota-fiscal
     WHERE ROWID(nota-fiscal) = p-rowid-nota-fiscal
     NO-LOCK NO-ERROR.

IF AVAIL nota-fiscal THEN DO:

    ASSIGN c-xml-nota = "".

   FIND FIRST esp_integracao 
        WHERE  esp_integracao.id_integracao = 1
        NO-ERROR.

   FIND FIRST esp_servico_integracao
        WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
        AND  esp_servico_integracao.descricao = "venda Nfe"
        NO-LOCK NO-ERROR.

   ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

   if  not valid-handle(h-epc-axsep037) THEN
       run adapters/xml/ep2/axsep037.p persistent set h-epc-axsep037.
    
   RUN PITransUpsert IN h-epc-axsep037 (input "upd":U,
                                        input  "InvoiceNFe":U,
                                        input  rowid(nota-fiscal),
                                        output table tt_log_erro).

   RUN pi-retornaXMLNFe IN h-epc-axsep037 (output c-xml-nota).

    IF  VALID-HANDLE(h-epc-axsep037) THEN DO:
        DELETE PROCEDURE h-epc-axsep037.
        ASSIGN h-epc-axsep037 = ?.
    END.
 
   
   IF c-xml-nota = '' THEN do:


       .MESSAGE "NÆo achou xml"
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

      FOR FIRST int_ndd_envio
          WHERE int_ndd_envio.cod_estabel =  nota-fiscal.cod-estabel 
          AND int_ndd_envio.serie       =  nota-fiscal.serie       
          AND int_ndd_envio.nr_nota_fis =  nota-fiscal.nr-nota-fis
          NO-LOCK BY ID DESC:
      
          copy-lob int_ndd_envio.DOCUMENTDATA to  c-xml-nota.
      END.
   END.

   .MESSAGE string(c-xml-nota) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE " XML nota 0002".
   //COPY-LOB c-xml-nota TO FILE 'c:\temp\nf-0000513.xml'.


   IF TRIM(c-xml-nota) <> "" THEN do:

       .MESSAGE "antes 001"
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       RUN int\wsinventti0001.p  (INPUT  c-url, 
                                  INPUT  c-xml-nota,
                                  OUTPUT v-retonro-integracao).

       .MESSAGE "antes 005" SKIP
               string(v-retonro-integracao)
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
      
       
      .MESSAGE STRING(v-retonro-integracao) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE 'retorno nf 0001'.
       IF v-retonro-integracao <> "" THEN do:
          RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                     INPUT ROWID(nota-fiscal)).
      
          
       END.
   END.

  
   
END.


   
