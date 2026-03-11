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
DEFINE INPUT PARAMETER r-frete  AS ROWID NO-UNDO.

//colocar run na procedure pfornec
RUN pfretes (INPUT r-frete). 
RUN pEnviaFreteHub.


PROCEDURE  pEnviaFreteHub:

    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp AS JsonObject    NO-UNDO.
    DEF VAR         jsonBody  AS JsonObject     NO-UNDO.
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
           oURI:Path   = '/datasul/pub/frete'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library. 
                                   
    FOR EACH tt-fretes:

        oJson = NEW JsonObject().                            
        oJson:ADD("id",tt-fretes.id).            
        oJson:ADD("origem",tt-fretes.origem).         
        oJson:ADD("modalidade_id",tt-fretes.modalidade_id ).                          
        oJson:ADD("modalidade_nome",tt-fretes.modalidade_nome). 
        oJson:ADD("status",TRUE).

    END.
                                      
    //jsonBody = NEW JsonArray().
    //jsonBody = NEW JsonObject().
    //sonBody:ADD("fretes",oJson).
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("fretes",oJson).
    
    //n∆o esquecer de mudar abaixo depois para OJsonSaida e lembrar que a variavel n∆o esta ARRAY e sim Object
    
    oJson:WriteFile("V:\includeMerco\enviofretes.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJson)
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("/mnt/shares/TEMP/RetornoEnviofretes.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pfretes:

    DEFINE INPUT PARAMETER r-modalid  AS ROWID NO-UNDO.

    FIND FIRST esp-envio-api NO-LOCK
        WHERE ROWID(esp-envio-api) = r-modalid NO-ERROR.

 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
    
        FIND FIRST ems2dis.modalid-frete NO-LOCK
            WHERE modalid-frete.cod-modalid-frete = esp-envio-api.esp-cod-modalid-frete  NO-ERROR.
            
            IF AVAIL modalid-frete THEN DO:
               
                CREATE tt-fretes.
                ASSIGN tt-fretes.id                   = INT(modalid-frete.cod-modalid-frete) // Seria isso igual aos outros?  
                       tt-fretes.origem               = "Datasul"
                       tt-fretes.modalidade_id        = INT(modalid-frete.cod-modalid-frete) // n∆o tenho certeza se seria aqui...
                       tt-fretes.modalidade_nome      = modalid-frete.des-modalid-frete
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
