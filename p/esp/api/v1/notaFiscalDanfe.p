
{cdp/cdcfgdis.i}
{include/i-epc200.i} 
{utp/ut-glob.i}
{method/dbotterr.i}

DEFINE VARIABLE c-xml   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-danfe AS CHARACTER   NO-UNDO.

DEFINE INPUT  PARAMETER p-tipo        AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER p-cod-estabel AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER p-serie       AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER p-nr-nota-fis AS CHARACTER   NO-UNDO.
DEFINE OUTPUT PARAMETER p-arquivo     AS CHARACTER   NO-UNDO.



DEFINE VARIABLE i-tiposervico-consult-cold-ant AS INTEGER     NO-UNDO.
DEFINE VARIABLE cUserNDD-aux AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cPwdNDD-aux  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mem-aux AS MEMPTR      NO-UNDO.
DEFINE VARIABLE lc-aux  AS LONGCHAR    NO-UNDO.

//{intprg/int-rpw.i}

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

DEFINE VARIABLE contador AS INTEGER     NO-UNDO.

/* consultar status SEFAZ dos protocolos retornados  */
FOR FIRST nota-fiscal
    WHERE nota-fiscal.cod-estabel = p-cod-estabel
    AND   nota-fiscal.serie       = p-serie      
    AND   nota-fiscal.nr-nota-fis = p-nr-nota-fis:

    for each bint_ndd_envio no-lock 
        WHERE bint_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
          AND bint_ndd_envio.serie        = nota-fiscal.serie       
          AND bint_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis:

        ASSIGN c-job-ndd = int_ndd_envio.JOB.
        find int_ndd_envio where 
            rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
        if avail int_ndd_envio then 
            run pi-consultarProtocolo.
                    
        run pi-desconectaWebServer.
        
    END.

    for each bint_ndd_envio no-lock
        WHERE bint_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
          AND bint_ndd_envio.serie        = nota-fiscal.serie       
          AND bint_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis:
    
        ASSIGN c-job-ndd = bint_ndd_envio.JOB.
        find int_ndd_envio where 
            rowid(int_ndd_envio) = rowid(bint_ndd_envio) exclusive-lock no-error no-wait.
        if avail int_ndd_envio then do:

            run pi-consultarStatus (int_ndd_envio.kind).

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
            
            run pi-desconectaWebServer.
        end.
    end.


    ASSIGN cColdID = "107".
    RUN pi-altera-tiposervico-consult-cold (INPUT p-tipo). /** XML **/
    RUN pi-ConsultarColdSincrono (INPUT nota-fiscal.cod-chave-aces-nf-eletro).
    RUN pi-retorna-document (OUTPUT p-arquivo).

END.

run pi-desconectaWebServer.

if valid-handle(hGenXML) then delete object hGenXML no-error.
