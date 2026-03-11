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

DEFINE VARIABLE c-xml   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-danfe AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-tiposervico-consult-cold-ant AS INTEGER     NO-UNDO.
DEFINE VARIABLE cUserNDD-aux AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPwdNDD-aux  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mem-aux AS MEMPTR      NO-UNDO.
DEFINE VARIABLE lc-aux  AS LONGCHAR    NO-UNDO.


def VAR h-acomp     AS HANDLE   NO-UNDO.


{intprg/int-rpw.i}

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

/* consultar protocolos pendentes de retorno e assinalar flag para consulta status SEFAZ */

DEFINE VARIABLE contador AS INTEGER     NO-UNDO.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp("Integraá∆o NDD").

//DO WHILE contador < 30:
    for EACH bint_ndd_envio no-lock where 
        bint_ndd_envio.STATUSNUMBER = 0 and
        bint_ndd_envio.protocolo <> ""  and
        bint_ndd_envio.protocolo <> ?:
        
        /*
        if  bint_ndd_envio.dt_envio = today and
            bint_ndd_envio.hr_envio > (time - 5) then next.
        */
     //   IF contador > 10 THEN NEXT.

        RUN pi-acompanhar IN h-acomp ("Buscando protocolo... " + string(bint_ndd_envio.nr_nota_fis)).

    
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
        ASSIGN contador = contador + 1.
    end.
//END.
pause 1 no-message.

ASSIGN contador = 0.

/* consultar status SEFAZ dos protocolos retornados  */
for each bint_ndd_envio no-lock where 
    bint_ndd_envio.STATUSNUMBER = 1 and
    bint_ndd_envio.protocolo <> "" and
    bint_ndd_envio.protocolo <> ?:

    ASSIGN contador = contador + 1.

  //  IF contador > 10 THEN NEXT.

    RUN pi-acompanhar IN h-acomp ("Buscando Autorizaá∆o... " + string(bint_ndd_envio.nr_nota_fis)).

    c-job-ndd = bint_ndd_envio.JOB.
    find int_ndd_envio where 
        rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
    if avail int_ndd_envio then do:
        for each nota-fiscal no-lock where 
            nota-fiscal.cod-estabel = bint_ndd_envio.cod_estabel and
            nota-fiscal.serie       = bint_ndd_envio.serie          and
            nota-fiscal.nr-nota-fis = bint_ndd_envio.nr_nota_fis:

            ASSIGN c-xml = ""
                   c-danfe = "".
        
            run pi-consultarStatus (int_ndd_envio.kind).

          //  IF nota-fiscal.idi-sit-nf-eletro = 3 THEN DO:
            
                IF NOT CAN-FIND(FIRST ext-nota-fiscal
                                WHERE ext-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                                AND   ext-nota-fiscal.serie       = nota-fiscal.serie      
                                AND   ext-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis) THEN DO:
    
                    FOR FIRST int_ds_natur_oper NO-LOCK
                        WHERE int_ds_natur_oper.nat_operacao        = nota-fiscal.nat-operacao 
                        AND   int_ds_natur_oper.log_baixa_danfe_xml = YES:
                        
                        ASSIGN cColdID-aux  = cColdID
                               cUserNDD-aux = cUserNDD
                               cPwdNDD-aux  = cPwdNDD 
                               cColdID      = "371"
                               cUserNDD     = "Ndd_Nissei"
                               cPwdNDD      = "Ndd_Nissei"
                               i-tiposervico-consult-cold-ant = i-tiposervico-consult-cold.
    
                        RUN pi-altera-tiposervico-consult-cold (INPUT 4). /** XML **/
                        RUN pi-ConsultarColdSincrono (INPUT nota-fiscal.cod-chave-aces-nf-eletro).
                        RUN pi-retorna-document (OUTPUT c-xml).
        
                        RUN pi-altera-tiposervico-consult-cold (INPUT 0). /** DANFE **/
                        RUN pi-ConsultarColdSincrono (INPUT nota-fiscal.cod-chave-aces-nf-eletro).
                        RUN pi-retorna-document (OUTPUT c-danfe).
        
                        RUN pi-altera-tiposervico-consult-cold (INPUT i-tiposervico-consult-cold-ant). /** Retorna para o default **/
                        ASSIGN cColdID  = cColdID-aux
                               cUserNDD = cUserNDD-aux
                               cPwdNDD  = cPwdNDD-aux .
        
                        IF c-xml   <> "" 
                        OR c-danfe <> "" THEN DO:
                            FOR FIRST ext-nota-fiscal-danfe EXCLUSIVE-LOCK
                                WHERE ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
                                AND   ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
                                AND   ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis: END.
                            IF NOT AVAIL ext-nota-fiscal-danfe THEN DO:
                                CREATE ext-nota-fiscal-danfe.
                                ASSIGN ext-nota-fiscal-danfe.cod-estabel = nota-fiscal.cod-estabel
                                       ext-nota-fiscal-danfe.serie       = nota-fiscal.serie      
                                       ext-nota-fiscal-danfe.nr-nota-fis = nota-fiscal.nr-nota-fis.
                            END.
    
                            IF c-xml   <> "" THEN COPY-LOB FROM FILE c-xml   TO ext-nota-fiscal-danfe.doc-xml.
                            IF c-danfe <> "" THEN DO:
                                COPY-LOB FROM FILE c-danfe TO mem-aux.
                                lc-aux = BASE64-ENCODE(mem-aux).
    
                                COPY-LOB lc-aux TO ext-nota-fiscal-danfe.doc-danfe.
    
                            END.
    
                        END.
                    END.
                END.
         //   END.
        end.
        run pi-desconectaWebServer.
    end.
end.

RUN pi-finalizar IN h-acomp.

pause 1 no-message.
if valid-handle(hGenXML) then delete object hGenXML no-error.



