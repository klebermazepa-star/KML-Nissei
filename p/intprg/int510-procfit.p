USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.
USING Progress.Json.ObjectModel.*.
USING com.totvs.framework.api.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.


DEFINE VARIABLE c-mensagem AS CHARACTER   NO-UNDO.



DEF TEMP-TABLE tt-INT_DS_DOCTO_XML NO-UNDO SERIALIZE-NAME "INT_DS_DOCTO_XML"
    FIELD ARQUIVO        AS CHAR
    FIELD CFOP           AS INT
    FIELD CHNFE          AS CHAR
    FIELD CHNFT          AS CHAR
    FIELD CNPJ           AS CHAR
    FIELD CNPJ_DEST      AS CHAR
    FIELD COD_EMITENTE   AS INT
    FIELD COD_ESTAB      AS CHAR
    FIELD COD_USUARIO    AS CHAR 
    FIELD DEMI           AS DATE
    FIELD DESPESA_NOTA   AS DEC
    FIELD DT_ATUALIZA    AS DATE
    FIELD DT_TRANS       AS DATE
    FIELD EP_CODIGO      AS INT
    FIELD ESTAB_DE_OR    AS CHAR
    FIELD MODFRETE       AS INT
    FIELD NAT_OPERACAO   AS CHAR
    FIELD NNF            AS CHAR
    FIELD NUM_PEDIDO     AS INT
    FIELD OBSERVACAO     AS CHAR
    FIELD SERIE          AS CHAR
    FIELD SIT_RE         AS INT
    FIELD SITUACAO       AS INT
    FIELD TIPO_DOCTO     AS INT
    FIELD TIPO_ESTAB     AS INT
    FIELD TIPO_NOTA      AS INT
    FIELD TOT_DESCONTO   AS DEC
    FIELD VALOR_COFINS   AS DEC
    FIELD VALOR_FRETE    AS DEC
    FIELD VALOR_ICMS     AS DEC
    FIELD VALOR_ICMS_DES AS DEC
    FIELD VALOR_II       AS DEC
    FIELD VALOR_IPI      AS DEC
    FIELD VALOR_MERCAD   AS DEC
    FIELD VALOR_OUTRAS   AS DEC
    FIELD VALOR_PIS      AS DEC
    FIELD VALOR_SEGURO   AS DEC
    FIELD VALOR_ST       AS DEC
    FIELD VBC            AS DEC
    FIELD VBC_CST        AS DEC
    FIELD VNF            AS DEC
    FIELD VOLUME         AS CHAR
    FIELD XNOME          AS CHAR
    FIELD VALOR_GUIA_ST  AS DEC
    FIELD BASE_GUIA_ST   AS DEC
    FIELD PERC_RED_ICMS  AS DEC.


DEF TEMP-TABLE tt-INT_DS_IT_DOCTO_XML NO-UNDO SERIALIZE-NAME "INT_DS_IT_DOCTO_XML"
    FIELD ARQUIVO AS CHAR
    FIELD CENQ AS INT
    FIELD CFOP AS INT
    FIELD CNPJ AS CHAR
    FIELD COD_EMITENTE AS INT
    FIELD CST_COFINS AS INT
    FIELD CST_ICMS AS INT
    FIELD CST_IPI AS INT
    FIELD CST_PIS AS INT
    FIELD IT_CODIGO AS CHAR
    FIELD ITEM_DO_FORN AS CHAR
    FIELD LOTE AS CHAR
    FIELD MODBC AS INT
    FIELD MODBCST AS INT
    FIELD NARRATIVA AS CHAR
    FIELD NAT_OPERACAO AS CHAR
    FIELD NCM AS INT
    FIELD NNF AS CHAR
    FIELD NUM_PEDIDO AS INT
    FIELD NUMERO_ORDEM AS INT
    FIELD ORIG_ICMS AS INT
    FIELD PCOFINS AS DEC
    FIELD PICMS AS DEC
    FIELD PICMSST AS DEC
    FIELD PIPI AS DEC
    FIELD PMVAST AS DEC
    FIELD PPIS AS DEC
    FIELD QCOM AS DEC
    FIELD QCOM_FORN AS DEC
    FIELD QORDEM AS DEC
    FIELD SEQUENCIA AS INT
    FIELD SERIE AS CHAR
    FIELD SITUACAO AS INT
    FIELD TIPO_CONTR AS INT
    FIELD TIPO_NOTA AS INT
    FIELD UCOM AS CHAR
    FIELD UCOM_FORN AS CHAR
    FIELD VBC_COFINS AS DEC
    FIELD VBC_ICMS AS DEC
    FIELD VBC_IPI AS DEC
    FIELD VBC_PIS AS DEC
    FIELD VBCST AS DEC
    FIELD VBCSTRET AS DEC
    FIELD VCOFINS AS DEC
    FIELD VDESC AS DEC
    FIELD VICMS AS DEC
    FIELD VICMSST AS DEC
    FIELD VICMSSTRET AS DEC
    FIELD VIPI AS DEC
    FIELD VPIS AS DEC
    FIELD VPROD AS DEC
    FIELD VTOTTRIB AS DEC
    FIELD VUNCOM AS DEC
    FIELD XPROD AS CHAR
    FIELD VOUTRO AS DEC
    FIELD VICMSDESON AS DEC
    FIELD PREDBC AS DEC
    FIELD VPMC AS DEC
    FIELD VICMSSUBS AS DEC
    FIELD VALOR_FCP_ST_RET AS DEC.

DEFINE DATASET nfCD FOR tt-INT_DS_DOCTO_XML, tt-INT_DS_IT_DOCTO_XML
    DATA-RELATION r1 FOR tt-INT_DS_DOCTO_XML, tt-INT_DS_IT_DOCTO_XML
        RELATION-FIELDS(serie,serie,nNF,nNF,cod_emitente,cod_emitente,tipo_nota,tipo_nota) NESTED.
    


DEFINE VARIABLE c-token AS CHARACTER   NO-UNDO.
DEFINE VARIABLE p-ok AS LOGICAL     NO-UNDO.

DEFINE VARIABLE cEmit AS CHARACTER   NO-UNDO. 
DEFINE VARIABLE cSerie AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cNF AS CHARACTER   NO-UNDO.

DEFINE INPUT PARAMETER r-int-docto-xml AS ROWID NO-UNDO.

   
RUN pi-integra-cd (INPUT r-int-docto-xml,
                   OUTPUT p-ok).   

.MESSAGE p-ok SKIP
        c-mensagem
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    
PROCEDURE pi-integra-cd:


    DEFINE INPUT  PARAMETER r-nota-cd   AS ROWID     NO-UNDO.
    DEFINE OUTPUT PARAMETER p-ok        AS LOGICAL     NO-UNDO.
   

    DEFINE VARIABLE oJson        AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oClient      AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI         AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest     AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc      AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData        AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument    AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse    AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJsonRetorno AS JsonObject    NO-UNDO.
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

    p-ok = NO.

    IF c-token = "" THEN RUN pi-token.  // KML arrumar para pegar token automatico

    
    .MESSAGE "Antes envio nota CD " skip
            c-token
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 3.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
          // cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[2]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[3]   = 'ECDHE-RSA-CHACHA20-POLY1305' .
    
    //https://api.cosmospro.com.br/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=84d19f58-716a-4686-9531-8b167c2f1e1e
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://api.cosmospro.com.br")
           oURI:Path   = '/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=' + c-token.

           //   c
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :library.

    FOR FIRST INT_DS_DOCTO_XML NO-LOCK 
        WHERE rowid(INT_DS_DOCTO_XML) = r-nota-cd:
        
        .MESSAGE "achou nota"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        CREATE tt-INT_DS_DOCTO_XML.
        BUFFER-COPY INT_DS_DOCTO_XML TO tt-INT_DS_DOCTO_XML.
    
        FOR EACH INT_DS_IT_DOCTO_XML NO-LOCK
            WHERE INT_DS_IT_DOCTO_XML.serie        = INT_DS_DOCTO_XML.serie       
            AND   INT_DS_IT_DOCTO_XML.nNF          = INT_DS_DOCTO_XML.nNF         
            AND   INT_DS_IT_DOCTO_XML.cod_emitente = INT_DS_DOCTO_XML.cod_emitente
            AND   INT_DS_IT_DOCTO_XML.tipo_nota    = INT_DS_DOCTO_XML.tipo_nota   :
    
            CREATE tt-INT_DS_IT_DOCTO_XML.
            BUFFER-COPY INT_DS_IT_DOCTO_XML to tt-INT_DS_IT_DOCTO_XML.
        END.
    END.

    assign oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET nfCD:HANDLE, NO).
    oJson = oJson:getJsonObject("nfCD").

  //  oJson:WriteFile("/totvs/temp/envioCD.json") NO-ERROR.
                                      
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :Request
    .                                      
    
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
    .MESSAGE oResponse:statuscode
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-aux AS CHARACTER   NO-UNDO.
    
    ASSIGN c-retorno = STRING(oResponse:Entity) NO-ERROR.
    ASSIGN oJsonRetorno = CAST(oResponse:Entity, JsonObject) NO-ERROR.
    ASSIGN c-aux = "sucesso".
        
    ASSIGN p-ok = LOGICAL(ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,c-aux) + 10),'"')) NO-ERROR.
    IF p-ok = ? THEN p-ok = NO.

    ASSIGN c-mensagem = ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,"mensagem_processamento") + 25),'"') NO-ERROR.

        
    RETURN "OK".
END PROCEDURE.
   
    
    


PROCEDURE pi-token:

    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oMemptr   AS OpenEdge.Core.MEMPTR NO-UNDO.
    
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

  //  IF c-token = "" THEN RUN pi-token.
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 3.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
          // cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[2]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[3]   = 'ECDHE-RSA-CHACHA20-POLY1305' .
    
        ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://portal.cosmospro.com.br:9191")
               oURI:Path   = 'api/login/autenticar?api-version=1.0&Content-Type=application/json&Accept=application/json'.
    

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :library.
         
        ASSIGN oJson = NEW JsonObject().
        oJson:ADD("login","integracaodatasul").
        oJson:ADD("senha","@integracaonissei2023").
                                          
        oRequest  = RequestBuilder:POST(oURI, oJson )
                    :AddHeader("Content-Type", "application/json")
                    :Request.                                      

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
            
    oMemptr = CAST(oResponse:Entity, MEMPTR).

    c-token = replace(string(oMemptr:GetString(1)), '"', '').

    
    RETURN "OK".
END PROCEDURE.
