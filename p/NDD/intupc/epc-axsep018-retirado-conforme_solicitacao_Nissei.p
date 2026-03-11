/********************************************************************************
** Programa: EPC-axsep018 - EPC Envio Carta Correá∆o 
**
** 
**
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}

define input        param p-ind-event  as char no-undo.
define input-output param table for tt-epc.
/*{xmlinc/xmlndd.i}*/
{int\wsinventti0000.i}

define new global shared variable r-rowid-axsep018 as rowid no-undo.
define new global shared variable h-epc-axsep018 as handle no-undo.
DEF  VAR c-xml AS LONGCHAR NO-UNDO.
DEF VAR c-url AS CHAR NO-UNDO.
def var hGenXML as handle no-undo.
def var cFile as char no-undo.
def var cFileDocument as char no-undo.
def var cFileXML as char no-undo.
def var cHeader as longchar no-undo.
def var cReturnValue as longchar no-undo.
def var cXML as longchar no-undo.
def var memptrXML as memptr no-undo.
DEF VAR iUltNSU AS INT NO-UNDO.
def var cProtocolo as char no-undo.
def var cChaveAcesso as char no-undo.
def var cData as char no-undo.
def var iId as integer no-undo.
def var hWebService as handle no-undo.
def var hWSPortaSoap as handle no-undo.
def var cCaminhoNDD as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.
def var cCaminhoTMP as char /*initial '\\192.168.200.250\totvs12\_custom_prod\NDD\'*/ no-undo.
def var cColdID as char initial /*'399' saidas */ '418' /* entradas HOMOLOGACAO */ no-undo.
def var cColdID-aux as char initial /*'399' saidas */ '418' /* entradas HOMOLOGACAO */ no-undo.
def var cUserNDD as char initial 'Nissei' no-undo.
def var cPwdNDD as char initial 'Nissei2015' no-undo.
def var cChildren as longchar no-undo.
def var cChildren-aux as longchar no-undo.
def var l-log as logical no-undo initial yes.
def var l-connected as logical no-undo.
def var l-aux as logical no-undo.
def var i-aux as integer no-undo.
def var l-okCold as logical no-undo.
DEF VAR i-tiposervico-consult-cold AS INT INITIAL 2 /** XML **/ NO-UNDO.
define stream str-log.

def var c-job-ndd as char no-undo.
def var i-job-ndd as int no-undo.
/* Variaveis e funá‰es para tratamento de XML - NDD Web */

DEFINE VARIABLE c-origem  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-replace AS CHARACTER   NO-UNDO.

define buffer btt-epc for tt-epc.

DEFINE TEMP-TABLE tt1_log_erro NO-UNDO
     FIELD ttv_num_cod_erro  AS INTEGER   INITIAL ?
     FIELD ttv_des_msg_ajuda AS CHARACTER INITIAL ?
     FIELD ttv_des_msg_erro  AS CHARACTER INITIAL ? .

for first tt-epc where 
    tt-epc.cod-event     = "TrataCCeEspec":U and   
    tt-epc.cod-parameter = "ConteudoCCe":U:

    cXML = "".
    cXML = tt-epc.val-parameter.

    ASSIGN cXML = REPLACE(cXML,"UTF-8","utf-16").

    ASSIGN c-replace = '<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'
                     + "<idLote>000000000000001</idLote>".

    ASSIGN cXML = REPLACE(cXML,"<Upsert>",c-replace).

    ASSIGN c-origem  = '<Evento versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
           c-replace = '<evento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'
           cXML      = REPLACE(cXML,c-origem,c-replace).

    ASSIGN cXML = REPLACE(cXML,"</Evento>","</evento>")
           cXML = REPLACE(cXML,"</Upsert>","</envEvento>").
end.

for first tt-epc 
    where  tt-epc.cod-event     = "TrataCCeEspec":U 
    and    tt-epc.cod-parameter = "RowidCCe":U:

    ASSIGN r-rowid-axsep018 = to-rowid(tt-epc.val-parameter).
    
    for first carta-correc-eletro  
        where rowid(carta-correc-eletro) = r-rowid-axsep018
        EXCLUSIVE-LOCK:

        
        for first nota-fiscal 
            where nota-fiscal.cod-estabel = carta-correc-eletro.cod-estab
            and nota-fiscal.serie       = carta-correc-eletro.cod-serie
            and nota-fiscal.nr-nota-fis = carta-correc-eletro.cod-nota-fis
            no-lock :

            FIND FIRST estabelec 
                 WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel 
                 NO-LOCK NO-ERROR.

            ASSIGN i-job-ndd = 1. /* Produá∆o */
                
            IF AVAIL estabelec THEN DO:
               IF estabelec.idi-tip-emis-nf-eletro = 2 THEN
                  ASSIGN i-job-ndd = 2. /* Homologaá∆o */
               IF estabelec.idi-tip-emis-nf-eletro = 3 THEN
                  ASSIGN i-job-ndd = 1. /* Produá∆o */
            END.

            ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".

            IF i-job-ndd = 1 THEN DO:
               ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel + "_EVT".
               
            END.

            IF i-job-ndd = 2 THEN DO:
               ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel + "_EVT".
               
            END.

            RUN int\wsinventti0003.p  (input nota-fiscal.cod-estabel,
                                       input nota-fiscal.serie,      
                                       input nota-fiscal.nr-nota-fis,
                                       INPUT trim(carta-correc-eletro.dsl-carta-correc-eletro),
                                       INPUT 110110,
                                       INPUT 2, 
                                       OUTPUT c-xml).


            //MESSAGE STRING( c-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "axep018".

            IF c-xml <> "" THEN do:
               if l-log then do: 
                   cFile = cCaminhoTMP + "eformsInserirDocumento" + "_" + c-seg-usuario + "_" +
                               string(today,"99-99-9999") + "_" + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
                   copy-lob cXML to FILE cFile.
               end.

               FIND FIRST esp_integracao 
                    WHERE  esp_integracao.id_integracao = 1
                    NO-ERROR.
   
               FIND FIRST esp_servico_integracao
                    WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
                    AND  esp_servico_integracao.descricao = "CARTA CORREÄ«O NFe"
                    NO-LOCK NO-ERROR.

               ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

               RUN int\wsinventti0001.p  (INPUT  c-url, 
                                          INPUT  c-xml,
                                          OUTPUT v-retonro-integracao).

               IF v-retonro-integracao <> "" THEN do:

                  ASSIGN carta-correc-eletro.dsl-xml-armaz = c-xml.
                  for last  int_ndd_envio                           
                      where int_ndd_envio.STATUSNUMBER = 0 /* A processar */     
                      and   int_ndd_envio.JOB          = c-job-ndd               
                      and   int_ndd_envio.DOCUMENTUSER = c-seg-usuario           
                      and   int_ndd_envio.KIND         = 6 /* XML Rvento */      
                      and   int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
                      and   int_ndd_envio.serie        = nota-fiscal.serie       
                      and   int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis 
                      and   int_ndd_envio.protocolo    = ""
                      exclusive-lock: end.

                  if not avail int_ndd_envio then do:
                      /* Base Progress n∆o tem trigger para incremento autom†tico */
                      iId = next-value(seq-int-ndd-envio).
                      create int_ndd_envio.
                      assign int_ndd_envio.ID           = iId /* base Progress */
                             int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                             int_ndd_envio.JOB          = c-job-ndd 
                             int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                             int_ndd_envio.KIND         = 6 /* XML Rvento */
                             int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
                             int_ndd_envio.serie        = nota-fiscal.serie 
                             int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis.
                  END.
                  copy-lob c-xml to int_ndd_envio.DOCUMENTDATA.

                  /* Guardar Protocolo para Consulta Posterior */
                  assign  int_ndd_envio.protocolo    = ""
                          int_ndd_envio.dt_envio     = today
                          int_ndd_envio.hr_envio     = time.

                  RELEASE int_ndd_envio.
                  run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                             nota-fiscal.serie,
                                             nota-fiscal.nr-nota-fis,
                                             "000000000000000").

                  EMPTY TEMP-TABLE tt-dados.
                  RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                             ROWID(nota-fiscal)).
                  
                  FIND FIRST tt-dados NO-ERROR.
                  IF AVAIL tt-dados THEN DO:
                     RUN pi-trata-retorno (input nota-fiscal.cod-estabel,
                                           input nota-fiscal.serie,      
                                           input nota-fiscal.nr-nota-fis).
                  END.
               END.
         
               RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                           input nota-fiscal.serie,      
                                           input nota-fiscal.nr-nota-fis).
            END.
    
            
            
            create btt-epc.
            assign btt-epc.cod-event     = "TrataCCeEspec":U
                   btt-epc.cod-parameter = "XMLEspec":U.
                   
        END.
    END. //for first carta-correc-eletro
    
    RELEASE carta-correc-eletro.

end.

return "OK".

