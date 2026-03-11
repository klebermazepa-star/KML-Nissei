USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

USING OpenEdge.Net.HTTP.*.
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
DEFINE INPUT PARAMETER r-documento  AS ROWID NO-UNDO.

//colocar run na procedure pfornec
RUN pCidades (INPUT r-documento). 
RUN pEnviaCidHub.


PROCEDURE pEnviaCidHub:

    DEFINE VARIABLE oJson      AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp  AS JsonObject    NO-UNDO.
    DEF VAR         jsonDetail AS JsonArray     NO-UNDO.
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
           oURI:Path   = '/datasul/pub/cidades'.

    
                                    
     
     
    FOR EACH tt-cidades:
                                                 
        oJson = NEW JsonObject().                            
        oJson:ADD("cidade",tt-cidades.cidade).            
        oJson:ADD("estado_id",tt-cidades.estado).         
        oJson:ADD("cep",tt-cidades.cep).                          
        oJson:ADD("pais_id",tt-cidades.pais_id). 
        oJson:ADD("pais_descricao",tt-cidades.pais_descricao).
        oJson:ADD("ibge_id",tt-cidades.ibge_id ). 
        oJson:ADD("origem","datasul").                
        oJson:ADD("status",TRUE).                     
        oJson:ADD("data_criacao",tt-cidades.data_criacao). //string(cidades.data_criacao)).              
        oJson:ADD("data_atualizacao",tt-cidades.data_atualizacao). //STRING(cidades.data_atualizacao)).          
     
     
     
        jsonBody = NEW JsonArray(). 
        jsonBody:ADD(oJson).
     
        oJsonsaida = NEW JsonObject().
        oJsonsaida:ADD("cidades",jsonBody).         
        
        oJsonsaida:WriteFile("V:\includeMerco\envioCidade.json") NO-ERROR.
                
        ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.    
        
        oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                    :AddHeader("Content-Type", "application/json")
                    :AddHeader("Authorization","Bearer " + c-token)
                    :Request
        . 
 
            
        ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
       
        oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
        
        oJsonResp:WriteFile("/mnt/shares/TEMP/RetornoEnvioCidade.json") NO-ERROR.
        
    /*     MESSAGE oResponse:statuscode                  */
    /*         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
    
    END.

END PROCEDURE.

PROCEDURE pCidades:

    DEFINE INPUT PARAMETER r-cidade    AS ROWID no-undo.

 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
        //FIND LAST esp-alteracao-bi
              //WHERE rowid(esp-alteracao-bi) = r-cidade NO-ERROR.
              
        //IF AVAIL esp-alteracao-bi  THEN
        //DO:
            
            FOR FIRST ems2dis.cidade 
                WHERE ROWID(cidade) = r-cidade NO-LOCK:
            
                IF AVAIL cidade THEN DO:
                
                    CREATE tt-cidades.
                    ASSIGN tt-cidades.cidade           = cidade.cidade
                           tt-cidades.estado_id        = cidade.estado
                           tt-cidades.cep              = ""
                           tt-cidades.pais_id          = 0 //INT(cidade.pais) // verificar pois ‚ char em campo inteiro 
                           tt-cidades.pais_descricao   = cidade.pais 
                           tt-cidades.ibge_id          = cidade.cdn-munpio-ibge
                           tt-cidades.origem           = "Datasul"
                           tt-cidades.data_criacao     = NOW
                           tt-cidades.data_atualizacao = NOW.

                END.
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
