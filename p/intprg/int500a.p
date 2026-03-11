USING System.*.
USING System.Net.WebRequest.
USING System.Net.HttpWebRequest.
USING System.Security.Cryptography.X509Certificates.X509Certificate2.
USING System.Security.Cryptography.CryptographicException.
USING System.Net.WebException.
USING System.Exception.
USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

//{intprg/int-rpw.i}

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):    

    DEFINE VARIABLE jsonOutput AS JsonObject NO-UNDO.
    DEFINE VARIABLE objParse AS ObjectModelParser NO-UNDO.

    IF jsonChar EQ ? OR jsonChar EQ '' THEN RETURN jsonOutput.

    jsonOutput = NEW JsonObject().
    objParse   = NEW ObjectModelParser().
    jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    LOG-MANAGER:WRITE-MESSAGE("findTag _ " + pTag) NO-ERROR.

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagIni,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ))) NO-ERROR.
        IF index(pSource,cTagIni,pStart) < 0
        OR index(pSource,cTagFim,pStart) < 0 
        OR index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) < 0 THEN RETURN "".

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.


function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    if c-aux <> ? then return c-aux. else return "".
end.

define temp-table ttHttpRequestHeaders no-undo
    field headerName  as character
    field headerValue as character.


DEF TEMP-TABLE NotaDestinada NO-UNDO 
    field ChaveNFe            as char 
    field Serie               as char 
    field NumeroNotaFiscal    as char 
    field CNPJEmissor         as char 
    field xNome               as char 
    field IE                  as char 
    field dEmi                as char 
    field tpNF                as char 
    field vNF                 as char 
    field digVal              as char 
    field dhRecbto            as char 
    field SituacaoNFe         as char 
    field SituacaoConfirmacao as char 
    field SituacaoXMLNFe      as char 
    field CNPJDestinatario    as char .

DEF TEMP-TABLE tt-xml NO-UNDO
    FIELD id-pai            AS INT  FORMAT ">>>>>>>>9"
    FIELD id-filho          AS INT  FORMAT ">>>>>>>>9"
    FIELD node-pai          AS CHAR FORMAT "x(20)"
    FIELD node-filho        AS CHAR FORMAT "x(20)"
    FIELD node-filho-seq    AS INT
    FIELD conteudo          AS CHAR FORMAT "x(200)"
    INDEX idx IS PRIMARY UNIQUE
        id-pai
        id-filho
        node-filho-seq.


DEFINE VARIABLE newRequest        AS CLASS System.Net.HttpWebRequest. 
DEFINE VARIABLE response          AS CLASS System.Net.HttpWebResponse.
DEFINE VARIABLE respException     AS CLASS System.Net.HttpWebResponse.
DEFINE VARIABLE certificate       AS CLASS System.Security.Cryptography.X509Certificates.X509Certificate2.
DEFINE VARIABLE responseStream    AS CLASS System.IO.Stream.
DEFINE VARIABLE streamXml         AS CLASS System.IO.Stream.
DEFINE VARIABLE streamReader      AS CLASS System.IO.StreamReader.
DEFINE VARIABLE ByteArrayXml      AS "System.Byte[]":U.
DEFINE VARIABLE textEncoding      AS System.Text.Encoding NO-UNDO.
DEFINE VARIABLE cPasswordDecode   AS CHARACTER            NO-UNDO.
DEFINE VARIABLE cContentType      AS CHARACTER            NO-UNDO.
DEFINE VARIABLE cMsg              AS CHARACTER            NO-UNDO.

DEFINE VARIABLE cHost            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cCertifFile      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cSetToken        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cXCSRFToken      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE lcResult         AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE lcxml            AS LONGCHAR    NO-UNDO.

DEFINE VARIABLE c-diretorio-dest AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-numero-due     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE l-okCold AS LOGICAL     NO-UNDO.
DEFINE VARIABLE i-qtd-notas AS INTEGER     NO-UNDO.
DEFINE VARIABLE i-aux AS INTEGER     NO-UNDO.

ASSIGN cHost            = "https://nissei.inventti.app".

DEF VAR h-acomp    AS HANDLE  NO-UNDO. 
run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integra‡Æo Inventti * L}
run pi-inicializar in h-acomp (input return-value).

DEFINE VARIABLE i-pagina AS INTEGER     NO-UNDO.


FOR EACH estabelec NO-LOCK:

    FIND FIRST es-param-int-nfe-entrada OF estabelec EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAIL es-param-int-nfe-entrada THEN DO:
        CREATE es-param-int-nfe-entrada. 
        ASSIGN es-param-int-nfe-entrada.cod-estabel   = estabelec.cod-estabel
               es-param-int-nfe-entrada.data-emissao  = 01/21/2023
               es-param-int-nfe-entrada.pagina        = 1
               es-param-int-nfe-entrada.qtd-registros = 0.
    END.

    ASSIGN i-qtd-notas  = 100.

    DO WHILE i-qtd-notas = 100:

        RUN pi-acompanhar IN h-acomp(INPUT "Estab: " + estabelec.cod-estabel + ' Pagina: ' + string(es-param-int-nfe-entrada.pagina)).  
    
        ASSIGN lcResult = "".
        
        EMPTY TEMP-TABLE ttHttpRequestHeaders.
        CREATE ttHttpRequestHeaders.
        ASSIGN ttHttpRequestHeaders.headerName  = "Role-Type"
               ttHttpRequestHeaders.headerValue = "IMPEXP".
    
        RUN pi-request(INPUT "nfe/api/destinadas/Obter",
                       INPUT "POST",
                       INPUT "application/xml",
                       INPUT "<RecepcionarNotasDestinadas>
                                <CNPJDestinatario>" + estabelec.cgc + "</CNPJDestinatario> 
                                <DataEmissaoInicial>2023-01-21T00:00:00</DataEmissaoInicial>
                                <Pagina>" + string(es-param-int-nfe-entrada.pagina) + "</Pagina>
                            </RecepcionarNotasDestinadas>
                            ",
                       OUTPUT lcResult).
    
     //   COPY-LOB lcResult TO FILE ("c:\temp\kleber\notas" + string(i-pagina) + ".xml").
    
        run pi-abre-xml(input lcResult, input NO, output l-okCold, OUTPUT i-qtd-notas).
   

        ASSIGN es-param-int-nfe-entrada.qtd-registros = i-qtd-notas.
        IF i-qtd-notas = 100 THEN
            ASSIGN es-param-int-nfe-entrada.pagina        = es-param-int-nfe-entrada.pagina + 1.

        
        IF es-param-int-nfe-entrada.pagina > 36 THEN LEAVE.
    
    
    END.

END.

PROCEDURE pi-request:
    DEFINE INPUT  PARAMETER pcEndPoint       AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER pcMethod         AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER pcContentType    AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER plcBody          AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER plcRequestResult AS LONGCHAR    NO-UNDO.

    DO ON ERROR UNDO, THROW:
        ASSIGN newRequest =  CAST(System.Net.WebRequest:CREATE(cHost + "/":U + pcEndPoint), System.Net.HttpWebRequest)
               newRequest:METHOD = pcMethod.
        IF pcContentType <> "":U THEN
            ASSIGN newRequest:ContentType = pcContentType.

        IF length(plcBody,"RAW":U) > 0 THEN DO:
            ASSIGN textEncoding             = System.Text.ASCIIEncoding:utf8  /*Seta encoding*/
                   ByteArrayXml             = textEncoding:GetBytes(plcBody)  /*Transforma XML para array de bytes*/
                   newRequest:ContentLength = ByteArrayXml:Length             /*Seta tamanho*/
                   streamXML                = newRequest:GetRequestStream().  /*Seta instancia da requisicao para o stream*/
    
            streamXML:Write(ByteArrayXml,0,ByteArrayXml:Length). /*Seta xml do corpo da requisicao*/
            streamXML:Close().
        END.

     
        ASSIGN response = cast(newRequest:GetResponse(), System.Net.HttpWebResponse).
        IF response <> ? THEN DO:

            ASSIGN responseStream   = response:GetResponseStream()
                   streamReader     = NEW System.IO.StreamReader(responseStream)
                   plcRequestResult = streamReader:ReadToEnd().
    
            IF trim(response:StatusCode:ToString()) = "OK":U THEN DO:
                ASSIGN cSetToken   = response:GetResponseHeader("cSetToken":U)
                       cXCSRFToken = response:GetResponseHeader("X-CSRF-Token":U).

            END.
            response:Close(). 
        END.

        CATCH argMsg AS ArgumentException:
            ASSIGN plcRequestResult = argMsg:Message.
    
        END CATCH.
    

        CATCH errorMsg AS WebException:
           
            ASSIGN respException = cast(errorMsg:Response, System.Net.HttpWebResponse)
                   responseStream   = respException:GetResponseStream()
                   streamReader     = NEW System.IO.StreamReader(responseStream)
                   plcRequestResult = streamReader:ReadToEnd() NO-ERROR.
                  
            IF ERROR-STATUS:ERROR THEN DO:
                 ASSIGN plcRequestResult = "Verifique_se_os_dados_para_a_conex?o_foram_informados_corretamente_para_o_estabelecimento".
            END.
            ELSE DO:
                IF respException:GetResponseHeader("Content-Type") MATCHES "*json*":U THEN
                    ASSIGN cContentType = "JSON":U.
                ELSE IF respException:GetResponseHeader("Content-Type") MATCHES "*xml*":U THEN
                        ASSIGN cContentType = "XML":U.
            END.
            
            RETURN "NOK":U.
        END CATCH.

    END.


    RETURN "OK":U.
END PROCEDURE.


procedure pi-abre-xml: 

    define input parameter pXML as longchar no-undo.
    define input parameter pGrava as logical no-undo.
    define output parameter pok as logical initial no no-undo.
    DEFINE OUTPUT PARAMETER qtd-notas AS INT NO-UNDO.
    DEFINE VARIABLE hDoc           AS HANDLE      NO-UNDO.
    DEFINE VARIABLE lc-xml         AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE hRoot         AS HANDLE      NO-UNDO.

    def var cChave AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE TT-XML.


    if  pXML matches "*QuantidadeNotasDestinadas*" then do:           
        assign qtd-notas = int(string(findTag(pXML,'QuantidadeNotasDestinadas',1))) no-error.

    end.

    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF  hRoot.
      
    hDoc:LOAD("longchar",pXML,FALSE) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN 
        RETURN "ERROR-01".
      
    hDoc:GET-DOCUMENT-ELEMENT(hRoot). 

    EMPTY TEMP-TABLE NotaDestinada.
    hDoc:encoding = "utf-8".
    hDoc:LOAD("longchar", pXML, FALSE) no-error. 
    
    hDoc:GET-DOCUMENT-ELEMENT(hRoot) NO-ERROR.
    
    RUN pi-busca-filho(INPUT hRoot,
                       INPUT 1,
                       INPUT 1).
    
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.

    FOR EACH TT-XML
        WHERE tt-xml.node-pai = "NotaDestinada"
        :

     //   DISP tt-xml WITH WIDTH 320.

        IF tt-xml.node-filho = "ChaveNFe"  THEN DO:

            FIND FIRST notadestinada 
                WHERE NotaDestinada.ChaveNFe = tt-xml.conteudo NO-ERROR.

            IF NOT AVAIL NotaDestinada THEN DO:
            
                CREATE NotaDestinada.
                ASSIGN NotaDestinada.ChaveNFe = tt-xml.conteudo.
            END.

        END.

        IF tt-xml.node-filho = "Serie"  THEN DO:
            ASSIGN NotaDestinada.serie = tt-xml.conteudo.

        END.
        IF tt-xml.node-filho = "NumeroNotaFiscal"  THEN DO:
            ASSIGN NotaDestinada.NumeroNotaFiscal = tt-xml.conteudo.
        END.
        IF tt-xml.node-filho = "CNPJEmissor"  THEN DO:
            ASSIGN NotaDestinada.CNPJEmissor = tt-xml.conteudo.
        END.
        IF tt-xml.node-filho = "CNPJDestinatario"  THEN DO:
            ASSIGN NotaDestinada.CNPJDestinatario = tt-xml.conteudo.
        END.

    END.

    FOR EACH notadestinada:


        FIND FIRST NDD_ENTRYINTEGRATION NO-LOCK
            WHERE NDD_ENTRYINTEGRATION.KIND           = 0             
              AND NDD_ENTRYINTEGRATION.SERIE          = int64(NotaDestinada.serie) 
              AND NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(NotaDestinada.NumeroNotaFiscal)    
              AND NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(NotaDestinada.CNPJEmissor)  
              AND NDD_ENTRYINTEGRATION.CNPJDEST       = int64(NotaDestinada.CNPJDestinatario) NO-ERROR.

        IF AVAIL NDD_ENTRYINTEGRATION THEN NEXT.
      
        i-aux = i-aux + 1.

        cChave = "<RecuperarXMLNota>
                  <NFe Chave='" + notadestinada.chaveNFE + "'/>
                  </RecuperarXMLNota> 
                 ".

        RUN pi-request(INPUT "nfe/api/xml/RecepcionarRecuperarXMLNotaRecebimento",
               INPUT "POST",
               INPUT "application/xml",
               INPUT cChave,
               OUTPUT lcResult).

        lcXml = findTag(lcResult,'XmlNota',1).

       // COPY-LOB lcResult TO FILE ("C:\TEMP\Kleber\download-inventti\notas" + STRING(i-aux) + ".xml").

        RUN pi-retiraTag(INPUT-OUTPUT lcXml).

     //   COPY-LOB lcXml TO FILE ("C:\TEMP\Kleber\download-inventti\notas_convertida" + STRING(i-aux) + ".xml").

        RUN gera_ndd_entryintegration( INPUT lcXml).

    END.

end. 


PROCEDURE pi-retiraTag :

    DEFINE INPUT-OUTPUT PARAMETER pc-xml AS LONGCHAR.

    ASSIGN pc-xml = REPLACE(pc-xml, "<![CDATA[", '').
    ASSIGN pc-xml = REPLACE(pc-xml, "]]>", '').

              
END PROCEDURE.


PROCEDURE pi-busca-filho :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT PARAM p-pai       AS HANDLE   NO-UNDO.
    DEF INPUT PARAM p-nivel     AS INT      NO-UNDO.
    DEF INPUT PARAM p-filho-seq AS INT      NO-UNDO.

    DEF VAR i           AS INT      NO-UNDO.
    DEF VAR h-node      AS HANDLE   NO-UNDO.
    DEF VAR l-ok        AS LOGICAL  NO-UNDO.

    CREATE X-NODEREF h-node.

    REPEAT i = 1 TO p-pai:NUM-CHILDREN:

        l-ok = p-pai:GET-CHILD(h-node,i).

        IF NOT l-ok THEN 
            LEAVE.

        CASE h-node:SUBTYPE:

            WHEN "ELEMENT" THEN DO: /* registra n”s */

                CREATE tt-xml.
                ASSIGN tt-xml.id-pai         = p-pai:UNIQUE-ID
                       tt-xml.id-filho       = h-node:UNIQUE-ID
                       tt-xml.node-pai       = p-pai:NAME
                       tt-xml.node-filho     = h-node:NAME
                       tt-xml.node-filho-seq = i.

                /* verifica se n” possui filhos */
                IF h-node:NUM-CHILDREN > 0 THEN
                    RUN pi-busca-filho(INPUT h-node,
                                       INPUT p-nivel + 1,
                                       INPUT i).

            END. /* WHEN "ELEMENT" */

            WHEN "TEXT" THEN DO: /* busca n” correspondente ao valor */
            
                FIND tt-xml WHERE
                    tt-xml.id-filho       = p-pai:UNIQUE-ID AND
                    tt-xml.node-filho-seq = p-filho-seq     NO-ERROR.
    
                IF AVAIL tt-xml AND
                   h-node:NODE-VALUE <> "" THEN
                    ASSIGN tt-xml.conteudo = h-node:NODE-VALUE.

            END. /* WHEN "TEXT" */

        END CASE. /* CASE h-node:SUBTYPE */

    END. /* REPEAT i = 1 TO p-pai:NUM-CHILDREN */

    DELETE OBJECT h-node.

END PROCEDURE.

PROCEDURE gera_ndd_entryintegration:

    DEFINE INPUT PARAMETER pxml AS LONGCHAR.

    def var cSerie  as char no-undo.
    def var cNF     as char no-undo.
    def var cEmit   as char no-undo.
    def var cDest   as char no-undo.
    def var cData   as char no-undo.
    DEF VAR icont   AS INT NO-UNDO.
    
    DEFINE VARIABLE hDoc AS HANDLE   NO-UNDO.
    
    CREATE X-DOCUMENT hDoc.
    
 /*   hDoc:LOAD("file", "C:\TEMP\Kleber\763e438fe032da8f1ec1c46a32cd6ce3.xml" ,FALSE).
    hdoc:SAVE("LONGCHAR",pxml).*/
    
    /* tratar s‚rie */
    if  pXML matches "*serie*" then do:     
        assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
        if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
    end.
    
    if  pXML matches "*nNF*" then 
        assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nNF',1)),">>>9999999")) no-error.
    if pXML matches "*dhEmi*" then do:
        assign cData = substring(findTag(pXML,'dhEmi',1),1,10) 
               cData = entry(3,cData,"-") + "/" + entry(2,cData,"-")  + "/" + entry(1,cData,"-") no-error.
    end.
    
    if pXML matches "*CNPJ*" then do: 
        /* emitente do documento */
        assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
    
        /* destinatario */
        assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
    end.

    for first NDD_ENTRYINTEGRATION EXCLUSIVE where 
              NDD_ENTRYINTEGRATION.KIND           = 0             and
              NDD_ENTRYINTEGRATION.SERIE          = int64(cSerie) and
              NDD_ENTRYINTEGRATION.DOCUMENTNUMBER = int64(cNF)    and
              NDD_ENTRYINTEGRATION.CNPJEMIT       = int64(cEmit)  and
              NDD_ENTRYINTEGRATION.CNPJDEST       = int64(cDest):


       /* MESSAGE "ja existe" SKIP
                "Status: " NDD_ENTRYINTEGRATION.STATUS_
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        ASSIGN NDD_ENTRYINTEGRATION.STATUS_ = 0.*/
    end.
    if not avail NDD_ENTRYINTEGRATION then do:
       for last NDD_ENTRYINTEGRATION exclusive-lock use-index id:
            assign iCont = NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID + 1.
        end.
        create  NDD_ENTRYINTEGRATION.
        assign  NDD_ENTRYINTEGRATION.ENTRYINTEGRATIONID = iCont
                NDD_ENTRYINTEGRATION.STATUS_            = 0
                NDD_ENTRYINTEGRATION.KIND               = 0
                NDD_ENTRYINTEGRATION.EMISSIONDATE       = datetime(cData)
                NDD_ENTRYINTEGRATION.CNPJEMIT           = int64(cEmit)
                NDD_ENTRYINTEGRATION.CNPJDEST           = int64(cDest)
                NDD_ENTRYINTEGRATION.SERIE              = int64(cSerie)
                NDD_ENTRYINTEGRATION.DOCUMENTNUMBER     = int64(cNF).
        copy-lob pXML to NDD_ENTRYINTEGRATION.DOCUMENTDATA.
    END.


END PROCEDURE.








