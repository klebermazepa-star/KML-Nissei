/*******************************************************************************************************
** 14/04/2024 - Rafael Andrade - Criaá∆o desta UPC de aprovaá∆o do documento 7 (Pedido de compra)
********************************************************************************************************/ 
{include/i-prgvrs.i mla_doc7_aprova 2.00.00.001 } /*** 010003 ***/       

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
   {include/i-license-manager.i mla_doc7_aprova MML}
&ENDIF


 /**  Programa executado pelo MLA0301 - Aprovaá∆o Pendàncias
 ***  Pedidos de Compras - EMS
 ***
 ***  Ir† verificar se existem outras pendàncias para o pedido de compra.
 ***  Caso n∆o existam, ir† passar o estado para aprovada (1).
 **/

DEF INPUT PARAMETER p-rowid-mla-doc-pend-aprov AS ROWID   NO-UNDO.
DEF INPUT PARAMETER p-cod-usuar-aprov          AS CHAR    NO-UNDO.
DEF INPUT PARAMETER p-gera-proxima-pend        AS LOGICAL NO-UNDO. //Essa vari†vel n∆o Ç confi†vel, vem TRUE se Ç a £ltima aprovaá∆o, e FALSE se haver† novas aprovaá‰es pro mesmo documento, ou seja, vem ao contr†rio da l¢gica do nome

DEF BUFFER b-mla-doc-pend-aprov FOR mla-doc-pend-aprov.

DEF VAR EstaOK  AS LOGICAL.
DEF VAR ProgAPI AS HANDLE.

/*MESSAGE 111 SKIP "mla_doc7_aprova"
   SKIP "p-rowid-mla-doc-pend-aprov: " + STRING(p-rowid-mla-doc-pend-aprov)
   SKIP "p-cod-usuar-aprov: " + p-cod-usuar-aprov
   SKIP "p-gera-proxima-pend: " + (IF p-gera-proxima-pend = TRUE THEN "SIM" ELSE "N«O")
   VIEW-AS ALERT-BOX.*/
   
FIND FIRST mla-doc-pend-aprov WHERE ROWID(mla-doc-pend-aprov) = p-rowid-mla-doc-pend-aprov NO-LOCK NO-ERROR.
   
// Verifica se tem novas pendàncias
FIND FIRST b-mla-doc-pend-aprov where b-mla-doc-pend-aprov.ep-codigo     = mla-doc-pend-aprov.ep-codigo   
                                  AND b-mla-doc-pend-aprov.cod-estabel   = mla-doc-pend-aprov.cod-estabel 
                                  AND b-mla-doc-pend-aprov.cod-tip-doc   = mla-doc-pend-aprov.cod-tip-doc 
                                  AND b-mla-doc-pend-aprov.chave-doc     = mla-doc-pend-aprov.chave-doc   
                                  AND (b-mla-doc-pend-aprov.ind-situacao = 1 OR b-mla-doc-pend-aprov.ind-situacao  = 3) 
                                  AND b-mla-doc-pend-aprov.historico     = no
                                  NO-LOCK NO-ERROR.

//N∆o tem mais pendàncias                                  
IF NOT AVAIL b-mla-doc-pend-aprov THEN DO: 

   IF SEARCH("lapepc/mla_upc_procedures.r") = ? THEN DO:
      MESSAGE "N∆o encontrado o programa 'lapepc/mla_upc_procedures.r'"
              VIEW-AS ALERT-BOX.
      RETURN "NOK".
   END.

   RUN lapepc/mla_upc_procedures.p PERSISTENT SET ProgAPI.
   
   RUN gerarDocumEstPedVenda IN ProgAPI(INPUT p-cod-usuar-aprov,
                                        INPUT INTEGER(mla-doc-pend-aprov.chave-doc),
                                        OUTPUT EstaOK).
                     
   IF NOT EstaOK THEN RETURN "NOK".
   
END.
