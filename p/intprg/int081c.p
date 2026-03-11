USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Core.*.
USING OpenEdge.Net.MultipartEntity.
USING OpenEdge.Net.MessagePart.
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder. 
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.

DEF INPUT  PARAMETER token      AS CHARACTER NO-UNDO.
DEF INPUT  PARAMETER jsonSaida  AS JsonObject.
DEF OUTPUT PARAMETER mensagem   AS CHARACTER NO-UNDO.

RUN Requisicao.

PROCEDURE Requisicao:

    DEFINE VARIABLE oClient     AS IHttpClient NO-UNDO.
    DEFINE VARIABLE oRequest    AS IHttpRequest NO-UNDO. 
    DEFINE VARIABLE oResponse   AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJsonObject AS JsonObject NO-UNDO.
    DEFINE VARIABLE vURL        AS URI           NO-UNDO.
    DEFINE VARIABLE JsonString  AS CHAR NO-UNDO.
    DEFINE VARIABLE oLib        AS IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.
   
    EXTENT(cSSLProtocols) = 1.
    EXTENT(cSSLCiphers) = 3.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[2]   = 'ECDHE-RSA-CHACHA20-POLY1305'
           cSSLCiphers[3]   = 'ECDHE-RSA-AES128-GCM-SHA256' .   
   
    ASSIGN vURL        = OpenEdge.Net.URI:Parse("https://api.totalfor.com.br")
           vURL:Path   = '/BcoTotApiNissei/nissei/pub/fi/fidoc/v110'.   
   
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(vURL:host)
                                      :library.
        
    oRequest  = RequestBuilder:POST(vURL, jsonSaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization",'Bearer ' + token)
                :REQUEST.                                      

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
        
   .MESSAGE oResponse:StatusCode
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       
   IF oResponse:StatusCode < 200 OR oResponse:StatusCode >= 300 THEN     DO:
       oJsonObject = CAST(oResponse:Entity, JsonObject).
       mensagem = oJsonObject:getCharacter("token").

   end.
   ELSE  DO:
       oJsonObject = CAST(oResponse:Entity, JsonObject).
       mensagem = oJsonObject:getCharacter("mensagem").
   
   END.
END PROCEDURE.
