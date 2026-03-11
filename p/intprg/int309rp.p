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

{include/i-prgvrs.i INT309 2.11.00.000}
/***********************************************************************
**  Programa..: intprg/int309rp.P
**  Descricao.: Carlos Daniel (KML)
************************************************************************/

/****************************  Definitions  ****************************/
{include/i-rpvar.i}

/*---- Defini‡Æo da tabela temporaria ----*/ 
DEFINE TEMP-TABLE ITENS NO-UNDO 
    FIELD cd_produto        AS CHAR
    FIELD ncm               AS CHAR
    FIELD cest              AS CHAR
    FIELD origem            AS CHAR
    FIELD cfop              AS CHAR
    FIELD cst_icms          AS CHAR
    FIELD cst_cofins        AS CHAR
    FIELD pcofins           AS DEC
    FIELD cst_pis           AS CHAR
    FIELD perc_icms         AS DEC
    FIELD perc_pis          AS DEC
    FIELD perc_cofins       AS DEC
    FIELD cbnef             AS DEC
    FIELD vlr_pmc           AS DEC
    FIELD perc_reducao      AS DEC
    FIELD perc_icms_st      AS DEC
    FIELD perc_pfcp_st      AS dec
    FIELD uf_origem         AS CHAR
    FIELD uf_destino        AS CHAR
    FIELD origem_mercadoria AS INT
    FIELD mva               AS DEC
    FIELD vlr_pauta         AS DEC.
    
DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR FORMAT "x(35)":U
    FIELD usuario          as CHAR FORMAT "x(12)":U
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    FIELD classifica       AS INTEGER
    FIELD desc-classifica  AS CHAR FORMAT "x(40)":U
    FIELD modelo           AS CHAR FORMAT "x(35)":U
    FIELD l-habilitaRtf    as LOG
    FIELD item-ini AS CHAR
    FIELD item-fim AS CHAR
    .

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD ordem            AS INTEGER   FORMAT ">>>>9":U
    FIELD exemplo          AS CHARACTER FORMAT "x(30)":U
    index id ordem.
    
DEFINE TEMP-TABLE tt-raw-digita
    FIELD raw-digita	AS RAW
    .              
/****************************  Frames       ****************************/

DEFINE INPUT PARAMETER raw-param AS RAW NO-UNDO.
DEFINE INPUT PARAMETER TABLE FOR tt-raw-digita.

CREATE tt-param.
RAW-TRANSFER raw-param to tt-param.

FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER tt-raw-digita.raw-digita TO tt-digita.
END. 

DEFINE VARIABLE h-acomp      AS HANDLE NO-UNDO.

DEFINE VARIABLE i-status-code   AS INT   NO-UNDO.
DEFINE VARIABLE c-msg-erro      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-access        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-retorno       AS CHARACTER   NO-UNDO.

/* ***************************  Main Block  *************************** */
DO ON STOP UNDO, LEAVE:
    {include/i-rpcab.i}
    {include/i-rpout.i &pagesize="0"}

    RUN utp/ut-acomp.p PERSISTENT SET h-acomp.  
    RUN pi-inicializar IN h-acomp (INPUT "Buscando dados...").

    FIND FIRST tt-param.

    RUN pi-autenticacao(OUTPUT i-status-code,
                        OUTPUT c-msg-erro,
                        OUTPUT c-access).
                     
    IF i-status-code = 200 THEN
        RUN pi-cria-temp-table-tributos.
        
END.

PROCEDURE pi-cria-temp-table-tributos:

    FOR EACH int_dp_item_fiscal
        WHERE int_dp_item_fiscal.produto >= tt-param.item-ini
        AND   int_dp_item_fiscal.produto <= tt-param.item-fim
        BREAK BY int_dp_item_fiscal.produto 
              BY int_dp_item_fiscal.estado_origem 
              BY int_dp_item_fiscal.estado_destino:  
              
        RUN pi-acompanhar IN h-acomp (INPUT "Criando Item: " + int_dp_item_fiscal.produto ).
        
        IF LAST-OF(int_dp_item_fiscal.estado_destino) THEN DO: 
        
            FIND FIRST item-uf NO-LOCK
                WHERE item-uf.it-codigo         = int_dp_item_fiscal.produto
                  AND item-uf.estado            = int_dp_item_fiscal.estado_destino 
                  AND item-uf.cod-estado-orig   = int_dp_item_fiscal.estado_origem  NO-ERROR.
        
            CREATE itens.
            ASSIGN itens.cd_produto        = int_dp_item_fiscal.produto    
                   itens.ncm               = int_dp_item_fiscal.ncm   
                   itens.cest              = string(int_dp_item_fiscal.cest)   
                   itens.origem            = string(int_dp_item_fiscal.origem)
                   itens.cfop              = if AVAIL item-uf THEN "5403" ELSE "5102"
                   itens.cst_icms          = ""   // NÆo encontrado    
                   itens.cst_cofins        = IF int_dp_item_fiscal.cst_cofins = ? THEN "0" ELSE string(int_dp_item_fiscal.cst_cofins)   
                   itens.pcofins           = int_dp_item_fiscal.cofins     
                   itens.cst_pis           = IF int_dp_item_fiscal.cst_pis = ? THEN "0" ELSE string(int_dp_item_fiscal.cst_pis)  
                   itens.perc_icms         = int_dp_item_fiscal.venda_icms   
                   itens.perc_pis          = int_dp_item_fiscal.pis           
                   itens.perc_cofins       = int_dp_item_fiscal.cofins         
                   itens.cbnef             = 0  //Nao encontrado                 
                   itens.vlr_pmc           = 0  // NÆo encontrado  
                   itens.origem_mercadoria = 0
                   itens.perc_reducao      = int_dp_item_fiscal.venda_red_base_icms     
                   itens.perc_icms_st      = int_dp_item_fiscal.aliq_int_uf_dest   
                   itens.perc_pfcp_st      = 0  // NÆo encontrado                                       .
                   itens.uf_origem         = int_dp_item_fiscal.estado_origem    
                   itens.uf_destino        = int_dp_item_fiscal.estado_destino  
                   itens.origem_mercadoria = int_dp_item_fiscal.origem
                   itens.mva               = int_dp_item_fiscal.aliq_int_uf_dest
                   itens.vlr_pauta         = int_dp_item_fiscal.pauta
                   .
            
        END.
        
        IF LAST-OF (int_dp_item_fiscal.produto) THEN DO:
        
            RUN pi-envia-tributos(INPUT c-access ,
                      OUTPUT c-retorno,
                      OUTPUT i-status-code).    

            PUT "Cod item - " + int_dp_item_fiscal.produto + 
                "  Status integracao - " + string(i-status-code) + 
                "  Mensagem - " + c-retorno FORMAT "x(1000)"
                SKIP.
        
            EMPTY TEMP-TABLE itens.
            
        END.
    END.   
    
    RUN pi-finalizar IN h-acomp.

END PROCEDURE.     

PROCEDURE pi-envia-tributos:

    DEFINE INPUT PARAMETER c-chave-acesso   AS CHAR   NO-UNDO.
    DEFINE OUTPUT PARAMETER c-descricao      AS CHAR   NO-UNDO.
    DEFINE OUTPUT PARAMETER p-status-code    AS INTEGER   NO-UNDO.

    DEFINE VARIABLE oJson        AS JsonObject     NO-UNDO.
    DEFINE VARIABLE oJsonResponse AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oURI         AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest     AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE oLib         AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE oResponse    AS IHttpResponse NO-UNDO.

    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://api.nisseilabs.com.br")
           oURI:Path   = '/produto/item/tributacao'.    

    assign oJson = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE ITENS:HANDLE, NO).
 //   oJson = oJson:getJsonObject("itens").
    
    oJson:WriteFile("u:\json-tributos.json") NO-ERROR.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                  :sslVerifyHost(FALSE)
                  :ServerNameIndicator(oURI:host)
                  :library.
                                      
                                      
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization",'Bearer ' + c-chave-acesso)
                :REQUEST.                                      

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).

    oJsonResponse = CAST(oResponse:Entity, JsonObject) NO-ERROR.      
    
    ASSIGN p-status-code = oResponse:statuscode.
    
    .MESSAGE p-status-code
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    IF p-status-code  = 200 THEN DO:             
        ASSIGN c-descricao = oJsonResponse:GetCharacter("descricao").
        
    END.
    ELSE DO:
        assign c-descricao = "NÆo foi possivel enviar tributos com o venda +".                
    END.    
    

END PROCEDURE.

PROCEDURE pi-autenticacao:

    DEFINE OUTPUT PARAMETER p-status-code   AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER c-mensagem      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER c-chave-acesso  AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE oJson        AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResponse AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oURI         AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest     AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE oLib         AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE oResponse    AS IHttpResponse NO-UNDO.


    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://hapi.nisseilabs.com.br")
           oURI:Path   = '/login'.


    oJson = NEW JsonObject () .
    oJson:Add ("username", "datasul") .
    oJson:Add ("password", "e9a2f8c6-6939-484d-8d55-bdda2f189951") .

    oJson:WriteFile("u:\loginvendamais.json") NO-ERROR.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                   //   :SetSSLProtocols(cSSLProtocols)
                                   //   :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.
                                      
                                      
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :REQUEST.                                      

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).

    oJsonResponse = CAST(oResponse:Entity, JsonObject) NO-ERROR.
    
    ASSIGN p-status-code = oResponse:statuscode.

    IF p-status-code  = 200 THEN DO:             
        ASSIGN c-chave-acesso = oJsonResponse:GetCharacter("access").
        
    END.
    ELSE DO:
        ASSIGN c-mensagem = "Nao foi possivel enviar autentica‡Æo com o venda +".                
    END.
END PROCEDURE.
