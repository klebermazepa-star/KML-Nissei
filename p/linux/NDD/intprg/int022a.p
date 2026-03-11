/********************************************************************************
** Programa: int022a - Conex∆o E leitura WebServer NDD
**
** Versao : 12 - 30/08/2018 - Alessandro V Baccin
**
********************************************************************************/
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

/* consultar protocolos pendentes de retorno e assinalar flag para consulta status SEFAZ */
for each bint_ndd_envio no-lock where 
    bint_ndd_envio.STATUSNUMBER = 0 and
    bint_ndd_envio.protocolo <> "" and
    bint_ndd_envio.protocolo <> ?:
    
    c-job-ndd = bint_ndd_envio.JOB.
    find int_ndd_envio where 
        rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
    if avail int_ndd_envio then do:
        for each nota-fiscal 
            fields (cod-estabel serie nr-nota-fis 
                    &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then 
                    cod-chave-aces-nf-eletro idi-forma-emis-nf-eletro 
                    &endif
                    dt-emis-nota char-2 nat-operacao) 
            no-lock where
            nota-fiscal.cod-estabel = bint_ndd_envio.cod_estabel and
            nota-fiscal.serie       = bint_ndd_envio.serie and
            nota-fiscal.nr-nota-fis = bint_ndd_envio.nr_nota_fis:
    
            run pi-consultarProtocolo.
        end.
        run pi-desconectaWebServer.
    end.
end.
pause 1 no-message.

/* consultar status SEFAZ dos protocolos retornados  */
for each bint_ndd_envio no-lock where 
    bint_ndd_envio.STATUSNUMBER = 1 and
    bint_ndd_envio.protocolo <> "" and
    bint_ndd_envio.protocolo <> ?:

    c-job-ndd = bint_ndd_envio.JOB.
    find int_ndd_envio where 
        rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
    if avail int_ndd_envio then do:
        for each nota-fiscal 
            fields (cod-estabel serie nr-nota-fis 
                    &if "{&BF_DIS_VERSAO_EMS}" >= "2.07" &then 
                    cod-chave-aces-nf-eletro idi-forma-emis-nf-eletro 
                    &endif
                    dt-emis-nota char-2 nat-operacao) 
            no-lock where 
            nota-fiscal.cod-estabel = bint_ndd_envio.cod_estabel and
            nota-fiscal.serie       = bint_ndd_envio.serie and
            nota-fiscal.nr-nota-fis = bint_ndd_envio.nr_nota_fis:
        
            run pi-consultarStatus.
        end.
        run pi-desconectaWebServer.
    end.
end.
pause 1 no-message.
if valid-handle(hGenXML) then delete object hGenXML no-error.
