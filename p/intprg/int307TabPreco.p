USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.


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


{intprg/int301.i}    
DEFINE INPUT PARAMETER r-preco  AS ROWID NO-UNDO.

//colocar run na procedure pfornec
RUN pTabPreco (INPUT r-preco). 
RUN pEnviaTabPrecoHub.


PROCEDURE pEnviaTabPrecoHub:

    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp AS JsonObject    NO-UNDO.
    DEF VAR         jsonBody   AS JsonArray     NO-UNDO.
    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE c-token   AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE oLib      AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    define variable vJsonAsString as CHAR no-undo.
    DEFINE VARIABLE myParser    AS ObjectModelParser NO-UNDO.


        
    RUN pGeraToken (OUTPUT c-token).
    
    //MESSAGE c-token
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/datasul/pub/produto_preco'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library. 
                                      
    FOR EACH tt-produtos_precos:
    
        oJson = NEW JsonObject().                            
        oJson:ADD("id",tt-produtos_precos.id).            
        oJson:ADD("origem",tt-produtos_precos.origem).         
        oJson:ADD("tabela_preco_id",tt-produtos_precos.tabela_preco_id).                          
        oJson:ADD("tabela_preco_nome",tt-produtos_precos.tabela_preco_nome).        
        oJson:ADD("preco",tt-produtos_precos.preco).                                      
        oJson:ADD("data_criacao",tt-produtos_precos.data_criacao). //produtos_precos.data_criacao             
        oJson:ADD("data_atualizacao",tt-produtos_precos.data_atualizacao). //produtos_precos.data_atualizacao
        oJson:ADD("status",TRUE).
        oJson:ADD("produto_id",tt-produtos_precos.produto_id).
     
    END.
    
    jsonBody = NEW JsonArray(). 
    jsonBody:ADD(oJson).
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("produtos_precos",jsonBody).         
    
    oJsonsaida:WriteFile("/mnt/shares/TEMP/enviofTabPreco.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("/mnt/shares/TEMP/RetornoEnvioTabPreco.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pTabPreco:

    DEFINE INPUT PARAMETER r-tabela  AS ROWID NO-UNDO.

    FIND FIRST esp-alteracao-bi NO-LOCK
        WHERE ROWID(esp-alteracao-bi) = r-tabela NO-ERROR.

 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
    
        FIND FIRST ems2dis.preco-item NO-LOCK
            WHERE preco-item.nr-tabpre = esp-alteracao-bi.nr-tabpre NO-ERROR.  
            
            IF AVAIL preco-item THEN DO:
               
                CREATE tt-produtos_precos.
                ASSIGN tt-produtos_precos.ID                = INT(preco-item.it-codigo) // Seria isso igual aos outros?  
                       tt-produtos_precos.origem            = "Datasul"
                       tt-produtos_precos.tabela_preco_id   = preco-item.preco-venda // n∆o tenho certeza se seria aqui...
                       tt-produtos_precos.tabela_preco_nome = preco-item.nr-tabpre         
                       tt-produtos_precos.preco             = preco-item.preco-venda 
                       tt-produtos_precos.data_criacao      = NOW
                       tt-produtos_precos.data_atualizacao  = NOW
                       tt-produtos_precos.produto_id        = INT(preco-item.it-codigo)
                       .
                       

            END.
        //END.

END PROCEDURE.




PROCEDURE pGeraToken:

    DEFINE OUTPUT PARAMETER p-token AS CHAR NO-UNDO.

    DEF VAR chHttp              AS COM-HANDLE NO-UNDO .
    DEF VAR cHost               AS CHARACTER NO-UNDO INIT "https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" .
    DEFINE VARIABLE oJsonResponse AS JsonObject    NO-UNDO.
    DEFINE VARIABLE myParser AS ObjectModelParser NO-UNDO. 

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh").   

    
    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).
    
    ASSIGN p-token =  oJsonResponse:GetCharacter("access_token").

END PROCEDURE.
