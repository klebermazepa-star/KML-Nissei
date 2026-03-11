/**********************************************************************        
*Programa.: wsinventti0001.p                                          * 
*Descricao: Envia as informar‡äes para a Inventti                     * 
*Autor....: Raimundo                                                  * 
*Data.....: 12/2022                                                   * 
**********************************************************************/
DEF INPUT  PARAMETER p-url                AS CHAR      NO-UNDO.
DEF INPUT  PARAMETER p-longchar           AS LONGCHAR  NO-UNDO.
DEF OUTPUT PARAMETER p-retonro-integracao AS LONGCHAR  NO-UNDO.

{utp/ut-glob.i} 

DEFINE VARIABLE v-retorno   AS LONGCHAR   NO-UNDO.
DEFINE VARIABLE cSourceType AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cReadMode   AS CHARACTER  NO-UNDO INITIAL "EMPTY".
DEFINE VARIABLE hDSet       AS HANDLE     NO-UNDO.
DEFINE VARIABLE httRetorno  AS HANDLE     NO-UNDO.
DEFINE VARIABLE lRetOK      AS LOGICAL    NO-UNDO.
DEFINE VARIABLE client      AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE c-texto     AS  LONGCHAR NO-UNDO.

//MESSAGE p-url VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "URL".

FIND FIRST esp_integracao 
     WHERE  esp_integracao.id_integracao = 2
     NO-ERROR.

CREATE "Msxml2.ServerXMLHTTP.6.0" client.
client:OPEN("post", esp_integracao.URL, FALSE).
client:setOption(2,"13056"). /*"SXH_SERV_CERT_IGNORE_ALL_SERVER_ERRORS" ignora o erro do certificado*/

client:SetRequestHeader ("Content-Type", "text/xml; charset=utf-8").
client:SetRequestHeader ("x-api-key", "fc85592e-3dc4-4b37-b27a-cc7b86a7f557").
client:SetRequestHeader ("SOAPAction", p-url).
//client:SetRequestHeader ("incluir-resposta-protocolada", "TRUE")    .

client:Send(p-longchar) . /**/

IF client:ResponseText <> "" AND client:ResponseText <>  ? THEN do:
   ASSIGN p-retonro-integracao =  client:ResponseText 
          v-retorno            =  client:ResponseText .
END.
ELSE DO:
  ASSIGN c-texto  = "Erro no processo de integracao com a Iventti".
         p-longchar  = c-texto.
END.

RELEASE OBJECT client.




