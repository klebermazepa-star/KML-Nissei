/************************************** *****************************************
**
**  PROGRAMA  :  epc-bodi135cancel
**  DATA      :  
**  AUTOR     :  Raimundo C. Soares - 
**  OBJETIVO  :  EPC no cancelamento da Nota Fiscal 
**  OBSERVACAO:  
**               
**  
******************************************************************************/

{utp/ut-glob.i}
{int\wsinventti0000.i}
{include/i-epc200.i bodi135cancel}

DEFINE INPUT PARAMETER p-ind-event   AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-epc.
DEF  VAR c-xml AS LONGCHAR NO-UNDO.
DEFINE BUFFER bf-nota-fiscal FOR nota-fiscal.
DEF var c-url                AS CHAR     NO-UNDO.

FIND FIRST tt-epc 
     WHERE tt-epc.cod-event = "Fim_CancelaNotaFiscal"
     AND  tt-epc.cod-param = "notafiscal-rowid" 
     NO-LOCK NO-ERROR.

IF AVAIL tt-epc THEN DO:

   FIND FIRST bf-nota-fiscal 
        WHERE ROWID(bf-nota-fiscal) = TO-ROWID(tt-epc.val-parameter) 
        NO-LOCK NO-ERROR.

   FIND FIRST es-param-integracao-estab
        WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
        AND   es-param-integracao-estab.empresa-integracao = 2
        NO-LOCK NO-ERROR.

   IF bf-nota-fiscal.dt-cancela <> ? AND AVAIL es-param-integracao-estab THEN DO:
      RUN int\wsinventti0003.p  (input bf-nota-fiscal.cod-estabel,
                                 input bf-nota-fiscal.serie,      
                                 input bf-nota-fiscal.nr-nota-fis,
                                 INPUT trim(bf-nota-fiscal.desc-cancela),
                                 INPUT 110111,
                                 INPUT 1, 
                                 OUTPUT c-xml).

      MESSAGE 1 SKIP STRING(c-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

      IF c-xml <> "" THEN do:

         FIND FIRST esp_integracao 
              WHERE  esp_integracao.id_integracao = 1
              NO-ERROR.
   
         FIND FIRST esp_servico_integracao
              WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
              AND  esp_servico_integracao.descricao = "CANCELAMENTO NFe"
              NO-LOCK NO-ERROR.

         ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

         //MESSAGE 2 SKIP c-url VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

         RUN int\wsinventti0001.p  (INPUT  c-url, 
                                    INPUT  c-xml,
                                    OUTPUT v-retonro-integracao).

         //MESSAGE 3 SKIP string(v-retonro-integracao) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

         IF v-retonro-integracao <> "" THEN do:
            EMPTY TEMP-TABLE tt-dados.
            RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                       ROWID(nota-fiscal)).
            
            FIND FIRST tt-dados NO-ERROR.
            IF AVAIL tt-dados THEN DO:
                .MESSAGE 4 SKIP TT-dados.codigo SKIP TT-dados.xmotivo SKIP 
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               RUN pi-trata-retorno (input nota-fiscal.cod-estabel,
                                     input nota-fiscal.serie,      
                                     input nota-fiscal.nr-nota-fis).
            
            END.
         END.
         
         RUN int\wsinventti0004.p  (input bf-nota-fiscal.cod-estabel,
                                    input bf-nota-fiscal.serie,      
                                    input bf-nota-fiscal.nr-nota-fis).
      END.  //c-xml <> ""
   END.  //bf-nota-fiscal.dt-cancela <> ?
END.
RETURN "OK".


