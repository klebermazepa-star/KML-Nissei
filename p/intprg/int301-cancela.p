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

DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
DEFINE VARIABLE oJsonArray AS JsonArray    NO-UNDO.
DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
DEFINE VARIABLE oJsonResp AS JsonObject    NO-UNDO.
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


DEFINE TEMP-TABLE nota_fiscal NO-UNDO
    FIELD data          AS CHAR
    FIELD chave_acesso  AS CHAR
    FIELD observacao    AS CHAR
    FIELD numero        AS INT  
    FIELD serie         AS CHAR
    FIELD emitente_cnpj AS CHAR.
    
    
DEFINE INPUT PARAMETER p-rowid-nota AS ROWID NO-UNDO.    

FIND LAST nota-fiscal NO-LOCK 
    WHERE rowid(nota-fiscal) = p-rowid-nota NO-ERROR.
    
FIND FIRST estabelec NO-LOCK
    WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.


FIND FIRST emitente NO-LOCK
    WHERE emitente.cgc = estabelec.cgc NO-ERROR.

CREATE nota_fiscal.
ASSIGN nota_fiscal.data             = STRING(STRING(YEAR(nota-fiscal.dt-cancel), "9999") + "-" + STRING(MONTH(nota-fiscal.dt-cancel), "99") + "-" + STRING(DAY(nota-fiscal.dt-cancel), "99") + "T13:00:00.255Z")       
       nota_fiscal.chave_acesso     = nota-fiscal.cod-chave-aces-nf-eletro
       nota_fiscal.observacao       = "Nota fiscal cancelada"
       nota_fiscal.numero           = INT(nota-fiscal.nr-nota-fis)
       nota_fiscal.serie            = nota-fiscal.serie
       nota_fiscal.emitente_cnpj    = emitente.cgc.


RUN pGeraToken(OUTPUT c-token).


ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://datahub-api-production-97903554824.us-east1.run.app ") //https://datahub-api.nisseilabs.com.br //"https://dev-datahub-api.nisseilabs.com.br
       oURI:Path   = '/datasul/pub/cancelar_notafiscal'.

ASSIGN oLib = ClientLibraryBuilder:Build()
                                  :sslVerifyHost(FALSE)
                                  :ServerNameIndicator(oURI:host)
                                  :library.   
                                  
ASSIGN oJson = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE nota_fiscal:HANDLE, NO).

oJson = oJson:GetJsonArray("nota_fiscal"):GetJsonObject(1). 
oJsonArray = NEW JsonArray().                               
oJsonArray:ADD(oJson).  
oJsonsaida = NEW JsonObject().
oJsonsaida:ADD("nota_fiscal",oJsonArray).         

oJsonsaida:WriteFile("U:\envioNotaCANCELA.json") NO-ERROR. 
    
oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
            :AddHeader("Content-Type", "application/json")
            :AddHeader("Authorization","Bearer " + c-token)
            :REQUEST.  
            
ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
oJsonResp:WriteFile("U:\RetornoEnvioNotaCANCELA.json") NO-ERROR.
    
.MESSAGE oResponse:statuscode  SKIP
        oResponse:Entity
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.    


PROCEDURE pGeraToken:


    DEFINE OUTPUT PARAMETER p-token AS CHAR                                 NO-UNDO.  
    
    DEFINE VARIABLE chHttp          AS COM-HANDLE                           NO-UNDO.
    DEFINE VARIABLE oJson           AS JsonObject                           NO-UNDO.
    DEFINE VARIABLE oJsonResponse   AS JsonObject                           NO-UNDO.
    DEFINE VARIABLE myParser        AS ObjectModelParser NO-UNDO. 
    DEFINE VARIABLE oURI            AS URI           NO-UNDO.
    DEFINE VARIABLE oLib            AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE oRequest        AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE oResponse       AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oRequestBody    AS String NO-UNDO.        
    DEFINE VARIABLE cSSLProtocols   AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers     AS CHARACTER          NO-UNDO EXTENT.   
    
    oRequestBody = new String('username=datasul&password=lnb0uD8xbWLS1t'). //lnb0uD8xbWLS1t /Rrpj7DTkq%26Kt!%24
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://datahub-api-production-97903554824.us-east1.run.app") //https://datahub-api.nisseilabs.com.br //https://dev-datahub-api.nisseilabs.com.br
           oURI:Path   = '/auth/token?username=datasul&password=lnb0uD8xbWLS1t'.    
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.  

    oRequest  = RequestBuilder:POST(oURI , oRequestBody)
                :AddHeader("Content-Type", "application/x-www-form-urlencoded")
                :Request  .
                
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) .   
    
    oJsonResponse = CAST(oResponse:Entity, JsonObject) NO-ERROR.   
    
    ASSIGN p-token =  oJsonResponse:GetCharacter("access_token").

END PROCEDURE.
