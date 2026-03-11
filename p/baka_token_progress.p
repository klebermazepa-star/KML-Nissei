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

RUN  pGeraToken-new.
//RUN  pGeraToken.



PROCEDURE pGeraToken-new:

    DEFINE VARIABLE p-token         AS CHAR                                 NO-UNDO.  
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
    
    oRequestBody = new String('username=datasul&password=kLEB3qJieSQK3YPEFKh').
                                    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/auth/token?username=datasul&password=kLEB3qJieSQK3YPEFKh'.    
           
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
    
    
    DISP p-token.

END PROCEDURE.
