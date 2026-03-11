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
DEFINE INPUT PARAMETER r-cond-pag  AS ROWID NO-UNDO.

//colocar run na procedure pfornec
RUN pPagto (INPUT r-cond-pag). 
RUN pEnviaPagtoHub.


PROCEDURE  pEnviaPagtoHub:

    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
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


        
    RUN pGeraToken (OUTPUT c-token).
    
    //MESSAGE c-token
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/datasul/pub/condicao_pagamento'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.
                                      
    FOR EACH condicao_pagamento:
    
        oJson = NEW JsonObject().                            
        oJson:ADD("id",condicao_pagamento.ID).
        oJson:ADD("status",TRUE).
        oJson:ADD("condicao_pagamento",condicao_pagamento.condicao_pagamento). //condicao_pagamento.condicao_pagamento).         
        oJson:ADD("origem",condicao_pagamento.origem ).                          
        oJson:ADD("data_criacao",condicao_pagamento.data_criacao).        
        oJson:ADD("data_atualizacao",condicao_pagamento.data_atualizacao). 
      
    END.
                                      
    //n esquecer de alterar oJson por oJsonsaida
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("condicao_pagamento",oJson).         
    
    oJson:WriteFile("V:\includeMerco\enviofcondicao_pagamento.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("/mnt/shares/TEMP/RetornoEnviocondicao_pagamento.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pPagto:
    
    DEFINE INPUT PARAMETER r-codigo  AS ROWID NO-UNDO.
    
    FIND LAST esp-envio-api
         WHERE rowid(esp-envio-api) = r-codigo NO-ERROR.

 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
    
        FIND FIRST ems2mult.cond-pagto NO-LOCK 
            WHERE cond-pagto.cod-cond-pag = esp-envio-api.cod-cond-pag-esp NO-ERROR. 
            
            IF AVAIL cond-pagto THEN DO:
               
                CREATE condicao_pagamento.
                ASSIGN condicao_pagamento.id                  = cond-pagto.cod-cond-pag // Seria isso igual aos outros?  
                       condicao_pagamento.condicao_pagamento  = string(cond-pagto.descricao) // n∆o tenho certeza se seria aqui... // cod-cond-pag
                       condicao_pagamento.origem              = "Datasul"
                       condicao_pagamento.data_criacao        = NOW
                       condicao_pagamento.data_atualizacao    = NOW
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
