USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
DEFINE VARIABLE EstaOK      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE Token       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE retornoAPI  AS CHARACTER   NO-UNDO.
  
  
  
    DEF VAR chHttp        AS COM-HANDLE        NO-UNDO .
    DEF VAR cHost         AS CHARACTER         NO-UNDO INIT "https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" .
    DEF VAR oJsonResponse AS JsonObject        NO-UNDO.
    DEF VAR myParser      AS ObjectModelParser NO-UNDO. 

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh").   

    
    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).
    
    IF oJsonResponse:has("access_token") THEN DO: 
       EstaOK = TRUE.
       ASSIGN Token = oJsonResponse:GetCharacter("access_token").
    END.
    ELSE retornoAPI = STRING(oJsonResponse:getJsonText()).
    
    
    DISP Token FORMAT "x(50)".
