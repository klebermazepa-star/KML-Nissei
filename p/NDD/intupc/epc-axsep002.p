/********************************************************************************
** Programa: EPC-AXSEP002 - EPC Envio Nota Fiscal NDD
**
** Versao : 12 - 01/04/2016 - Alessandro V Baccin
**
********************************************************************************/

/* ------------------- Parametros da DBO -------------------------*/            
{include/i-epc200.i} 
{utp/ut-glob.i}


{method/dbotterr.i}

{int\wsinventti0000.i}

define input        param p-ind-event  as char          no-undo.
define input-output param table for tt-epc.

define buffer btt-epc for tt-epc.
define variable cProtocolo as char no-undo.
define variable cXML as longchar no-undo.
define variable r-rowid as rowid no-undo.
define variable i-id as integer no-undo.
define buffer bint_ndd_envio for int_ndd_envio.

DEF VAR c-job-ndd AS CHAR NO-UNDO.
DEF VAR i-job-ndd AS INT  NO-UNDO. 

DEF VAR c-xml AS LONGCHAR NO-UNDO.
DEF VAR c-url  AS CHAR NO-UNDO.

OUTPUT TO t:\axsep002.LOG APPEND.
FOR EACH btt-epc:
    DISPLAY 
        p-ind-event             FORMAT "X(25)"
        btt-epc.cod-event       FORMAT "X(25)"
        btt-epc.cod-parameter   FORMAT "X(25)"
        WITH WIDTH 300 STREAM-IO.
    DISPLAY PROGRAM-NAME(2) FORMAT "X(50)" LABEL "2".
    DISPLAY PROGRAM-NAME(3) FORMAT "X(50)" LABEL "3".
    DISPLAY PROGRAM-NAME(4) FORMAT "X(50)" LABEL "4".
END.

for first btt-epc where 
    btt-epc.cod-event     = "TrataNFeEspec":U and   
    btt-epc.cod-parameter = "Origem":U and
    btt-epc.val-parameter = "CANCELAMENTO":U:
    
    cXML = "".
    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "ConteudoNFe":U:
        cXML = tt-epc.val-parameter.    
    end.

    r-rowid = ?.
    for first tt-epc where 
        tt-epc.cod-event     = "TrataNFeEspec":U and   
        tt-epc.cod-parameter = "RowidNFe":U:
        r-rowid = to-rowid(tt-epc.val-parameter).
    end.
    for first nota-fiscal no-lock where 
        rowid(nota-fiscal) = r-rowid: 

        FIND FIRST es-param-integracao-estab
             WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
             AND   es-param-integracao-estab.empresa-integracao = 2
             NO-LOCK NO-ERROR.

        IF AVAIL es-param-integracao-estab THEN DO:

           IF nota-fiscal.dt-cancela <> ? THEN DO:

              RUN int\wsinventti0003.p  (input nota-fiscal.cod-estabel,
                                         input nota-fiscal.serie,      
                                         input nota-fiscal.nr-nota-fis,
                                         INPUT trim(nota-fiscal.desc-cancela),
                                         INPUT 110111,
                                         INPUT 1, 
                                         OUTPUT c-xml).
              IF c-xml <> "" THEN do:
              
                 FIND FIRST esp_integracao 
                      WHERE  esp_integracao.id_integracao = 1
                      NO-ERROR.
                 
                 FIND FIRST esp_servico_integracao
                      WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
                      AND  esp_servico_integracao.descricao = "CANCELAMENTO NFe"
                      NO-LOCK NO-ERROR.
                 
                 ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .
                 
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
                 
                 RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                            input nota-fiscal.serie,      
                                            input nota-fiscal.nr-nota-fis).
              END .  //c-xml <> ""
           END. 
        END. // inventi fim

        ELSE do:                                           
           /*tratamento XML NDD */
           if cXML <> "" then do:
               create int_ndd_envio.
               /*
               i-id = 1.
               for last bint_ndd_envio use-index id exclusive-lock:
                   assign i-id = bint_ndd_envio.id + 1.
               end.*/
           
               ASSIGN i-job-ndd = 1. /* Produ‡Æo */
               FIND FIRST estabelec WHERE
                          estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK NO-ERROR.
               IF AVAIL estabelec THEN DO:
                  IF estabelec.idi-tip-emis-nf-eletro = 2 THEN
                     ASSIGN i-job-ndd = 2. /* Homologa‡Æo */
                  IF estabelec.idi-tip-emis-nf-eletro = 3 THEN
                     ASSIGN i-job-ndd = 1. /* Produ‡Æo */
               END.
           
               ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
               IF i-job-ndd = 1 THEN DO:
                  IF nota-fiscal.cod-estabel <> "973" THEN
                     ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel.
                  ELSE 
                     ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
               END.
               IF i-job-ndd = 2 THEN DO:
                  IF nota-fiscal.cod-estabel <> "973" THEN
                     ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel.
                  ELSE 
                     ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
               END.
           
               assign /*int_ndd_envio.ID           = i-id*/
                      int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                      int_ndd_envio.JOB          = c-job-ndd 
                      int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                      int_ndd_envio.KIND         = 1 /* XML */.
               copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
           
               create tt-epc.
               assign tt-epc.cod-event     = "TrataNFeEspec":U
                      tt-epc.cod-parameter = "XMLEspec":U
                      tt-epc.val-parameter = "CancelaNota#" + cProtocolo.
           end.
        END. //ndd-fim
    end.
    if not avail nota-fiscal then do:
        create tt-epc.
        assign tt-epc.cod-event     = "TrataNFeEspec":U
               tt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
        for first cadast_msg no-lock where 
            cadast_msg.cdn_msg = 3084:
            assign tt-epc.val-parameter = "3084#" + cadast_msg.des_text_msg + "#" + cadast_msg.dsl_help_msg.
        end.
    end.
end. /* btt-epc */
OUTPUT CLOSE.
return "OK":U.

