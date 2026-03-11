/********************************************************************************
** Programa: EPC-axsep018 - EPC Envio Carta Correá∆o NDD
**
** Versao : 01 - 31/10/2016 - Sz Soluá‰es
**
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}


define input        param p-ind-event  as char no-undo.
define input-output param table for tt-epc.

define new global shared variable r-rowid-axsep018 as rowid no-undo.
define new global shared variable h-epc-axsep018 as handle no-undo.

/* Variaveis e funá‰es para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

DEFINE VARIABLE c-origem  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-replace AS CHARACTER   NO-UNDO.

define buffer btt-epc for tt-epc.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
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

for first tt-epc where 
    tt-epc.cod-event     = "TrataCCeEspec":U and   
    tt-epc.cod-parameter = "RowidCCe":U:
    r-rowid-axsep018 = to-rowid(tt-epc.val-parameter).
    
    for first carta-correc-eletro EXCLUSIVE-LOCK 
        where rowid(carta-correc-eletro) = r-rowid-axsep018:
        
        for first nota-fiscal no-lock 
            where nota-fiscal.cod-estabel = carta-correc-eletro.cod-estab
              and nota-fiscal.serie       = carta-correc-eletro.cod-serie
              and nota-fiscal.nr-nota-fis = carta-correc-eletro.cod-nota-fis:

            if not can-find (first int_ndd_envio USE-INDEX nota WHERE
                                   int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND 
                                   int_ndd_envio.serie       = nota-fiscal.serie       AND
                                   int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis AND
                                   int_ndd_envio.dt_envio    = today AND
                                   int_ndd_envio.hr_envio   >= TIME - 60) and cXML <> "" then do:

                ASSIGN i-job-ndd = 1. /* Produá∆o */
                FIND FIRST estabelec WHERE
                           estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK NO-ERROR.
                IF AVAIL estabelec THEN DO:
                   IF estabelec.idi-tip-emis-nf-eletro = 2 THEN
                      ASSIGN i-job-ndd = 2. /* Homologaá∆o */
                   IF estabelec.idi-tip-emis-nf-eletro = 3 THEN
                      ASSIGN i-job-ndd = 1. /* Produá∆o */
                END.

                ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".
                IF i-job-ndd = 1 THEN DO:
                   /*IF nota-fiscal.cod-estabel <> "973" THEN*/
                      ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel + "_EVT".
                   /*ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".*/
                END.
                IF i-job-ndd = 2 THEN DO:
                   /*IF nota-fiscal.cod-estabel <> "973" THEN*/
                      ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel + "_EVT".
                   /*ELSE 
                      ASSIGN c-job-ndd = nota-fiscal.cod-estabel + "_EVT".*/
                END.

                if l-log then do: 
                    cFile = cCaminhoTMP + "eformsInserirDocumento" + "_" + c-seg-usuario + "_" +
                                string(today,"99-99-9999") + "_" + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
                    copy-lob cXML to FILE cFile.
                end.

                /* Carrega API auxiliar processamento de XML */
                if not valid-handle(hGenXML) then 
                {xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

                /* Gera Header do envio para NDD */
                run pi-geraHeaderInserirDocumentoNDD ("6" /* Evento */, output cHeader).
                if l-log then do: 
                    cFile = cCaminhoTMP + "eformsInserirHeader" + "_" + c-seg-usuario + "_" +
                                string(today,"99-99-9999") + "_" + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
                    copy-lob cHeader to FILE cFile.
                end.
                
                /* envio p/ WebService */
                run pi-conectaWebServer (input 'WSInserirDocumento.wsdl',
                                         input 'WSInserirDocumento',
                                         input nota-fiscal.cod-estabel,
                                         output l-connected).
                if l-connected then do:
                    run WSInserirDocumentoSoap set hWSPortaSoap on hWebService.

                    run InserirDocumento in hWSPortaSoap(input  cHeader, 
                                                         input  cXML, 
                                                         output cReturnValue).

                    if l-log then do:
                        cFile = cCaminhoTMP + "eformsInserirRetorno" + "_" + c-seg-usuario + "_" +
                                string(today,"99-99-9999") + "_" + replace(string(time,"HH:MM:SS"),':','_') + ".xml".
                        copy-lob cReturnValue to FILE cFile.
                    end.

                    /* Trata Retorno do WebService */
                    run reset in hGenXML.
                    run loadXMLFromLongChar in hGenXML (cReturnValue).
                    run loadValue in hGenXML ("protocolo", 1, output cReturnValue).

                    if cReturnValue = ? or cReturnValue = "0" then do:
                        cMensagem = "".
                        cCodigoErro = "".
                        run loadValue in hGenXML ("codigo", 4, output cReturnValue) .
                        cCodigoErro = OnlyNumbers(string(cReturnValue)).
                        run loadValue in hGenXML ("mensagem", 4, output cReturnValue) .
                        cMensagem = PrintChar(string(cReturnValue)).
                        run loadValue in hGenXML ("observacao", 4, output cReturnValue) .
                        cMensagem = cMensagem + "-" + PrintChar(string(cReturnValue)).
                        run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                                   nota-fiscal.serie,
                                                   nota-fiscal.nr-nota-fis,
                                                   "000000000000000").
                    end.
                    else do:
                        for last int_ndd_envio exclusive-lock where
                            int_ndd_envio.STATUSNUMBER = 0 /* A processar */ and
                            int_ndd_envio.JOB          = c-job-ndd           and
                            int_ndd_envio.DOCUMENTUSER = c-seg-usuario       and
                            int_ndd_envio.KIND         = 6 /* XML Rvento */      and
                            int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel and
                            int_ndd_envio.serie        = nota-fiscal.serie       and
                            int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis and
                            int_ndd_envio.protocolo    = "": end.
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
                        end.
                        copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
                        /* Guardar Protocolo para Consulta Posterior */
                        assign  int_ndd_envio.protocolo    = cReturnValue
                                int_ndd_envio.dt_envio     = today
                                int_ndd_envio.hr_envio     = time.
                        run pi-consultarProtocolo.
                    end. /* protocolo inserido com sucesso */
                    release int_ndd_envio.
                    run pi-LimpaObjetos.
                end. /* conected */
                else do:
                    cCodigoErro = '9999'. cMensagem = "WebService NDD n∆o conectado".
                    create btt-epc.
                    assign btt-epc.cod-event     = "TrataCCeEspec":U
                           btt-epc.cod-parameter = "GeraTT_LOG_ERRO":U.
                    assign btt-epc.val-parameter = trim(cCodigoErro + "-" + cMensagem).
                    run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                               nota-fiscal.serie,
                                               nota-fiscal.nr-nota-fis,
                                               "000000000000000").
                end.

                ASSIGN carta-correc-eletro.dsl-xml-armaz = cXML.

                release int_ndd_envio.
             
                create btt-epc.
                assign btt-epc.cod-event     = "TrataCCeEspec":U
                       btt-epc.cod-parameter = "XMLEspec":U.
                       
            end.
        end.
    end.
    RELEASE carta-correc-eletro.

end.

return "OK".

