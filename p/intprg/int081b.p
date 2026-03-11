USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Core.*.
USING OpenEdge.Net.MultipartEntity.
USING OpenEdge.Net.MessagePart.
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder. 
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
    
DEFINE VARIABLE oClient     AS IHttpClient NO-UNDO.
DEFINE VARIABLE oRequest    AS IHttpRequest NO-UNDO. 
DEFINE VARIABLE oResponse   AS IHttpResponse NO-UNDO.
DEFINE VARIABLE oJsonObject AS JsonObject NO-UNDO.
DEFINE VARIABLE vURL      AS URI           NO-UNDO.
DEFINE VARIABLE JsonString  AS CHAR NO-UNDO.
DEFINE VARIABLE oLib        AS IHttpClientLibrary NO-UNDO.

DEF OUTPUT PARAMETER token     AS CHARACTER NO-UNDO.
DEF OUTPUT PARAMETER validade  AS DATETIME  NO-UNDO.

DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

FUNCTION getData RETURNS DATETIME(dataString AS CHAR) FORWARD.

EXTENT(cSSLProtocols) = 1.
EXTENT(cSSLCiphers) = 3.
// Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
ASSIGN cSSLProtocols[1] = 'TLSv1.2'
       cSSLCiphers[1]   = 'ECDHE-RSA-AES256-GCM-SHA384'
       cSSLCiphers[2]   = 'ECDHE-RSA-CHACHA20-POLY1305'
       cSSLCiphers[3]   = 'ECDHE-RSA-AES128-GCM-SHA256' .
                                             //https://api.totalfor.com.br/BcoTotApiNissei/nissei/pub/ba/token

ASSIGN vURL        = OpenEdge.Net.URI:Parse("https://api.totalfor.com.br")
       vURL:Path   = '/BcoTotApiNissei/nissei/pub/ba/token'.

oJsonObject = NEW JsonObject().
oJsonObject:ADD("perfil", "10").
oJsonObject:ADD("login","usernissei").
oJsonObject:ADD("senha", "4gTdFQ7B82wv").

 
ASSIGN oLib = ClientLibraryBuilder:Build()
                                  :SetSSLProtocols(cSSLProtocols)
                                  :SetSSLCiphers(cSSLCiphers)
                                  :sslVerifyHost(FALSE)
                                  :ServerNameIndicator(vURL:host)
                                  :library.
    
oRequest  = RequestBuilder:POST(vURL, oJsonObject )
            :AddHeader("Content-Type", "application/json")
            :REQUEST.                                      

ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
IF oResponse:StatusCode < 200 OR oResponse:StatusCode >= 300 THEN     DO:
    oJsonObject = CAST(oResponse:Entity, JsonObject).
    oJsonObject:WRITE(JsonString, true).
end.
ELSE  DO:
    oJsonObject = CAST(oResponse:Entity, JsonObject).
    ASSIGN token = oJsonObject:getCharacter("token")
           validade = getData(oJsonObject:getCharacter("validade")).

END.    
    
    
FUNCTION getData RETURNS DATETIME(dataString AS CHAR).
   DEF VAR data      AS INTEGER EXTENT 3.
   DEF VAR hora      AS INTEGER EXTENT 3.
   DEF VAR dataSaida AS DATETIME.
   DEF VAR valor     AS CHAR.

   valor = ENTRY(1,dataString," ").
   data[1] = INTEGER(ENTRY(1,valor,"-")).
   data[2] = INTEGER(ENTRY(2,valor,"-")).
   data[3] = INTEGER(ENTRY(3,valor,"-")).

   valor = ENTRY(2,dataString," ").
   hora[1] = INTEGER(ENTRY(1,valor,":")).
   hora[2] = INTEGER(ENTRY(2,valor,":")).
   hora[3] = INTEGER(ENTRY(3,valor,":")).

   dataSaida = DATETIME(data[2],data[3],data[1],hora[1],hora[2],hora[3]).

   RETURN dataSaida.
END FUNCTION.    
    
    
         
