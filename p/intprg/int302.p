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

DEFINE INPUT PARAMETER r-item  AS ROWID NO-UNDO.


//colocar run na procedure pfornec


RUN pFornecedores (INPUT r-item).
RUN pEnviaFornecHub.


PROCEDURE pEnviaFornecHub:

    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp AS JsonObject    NO-UNDO.
    DEF VAR         jsonBody  AS JsonArray     NO-UNDO.
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
           oURI:Path   = '/datasul/pub/fornecedores_produtos'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library. 
                                      
                                      
    FOR EACH produtos_fornecedores:
    
         oJson = NEW JsonObject().                            
         oJson:ADD("id", produtos_fornecedores.id).            
         oJson:ADD("origem", produtos_fornecedores.origem).         
         oJson:ADD("entidade_id",produtos_fornecedores.entidade_id).                          
         oJson:ADD("produto_id",produtos_fornecedores.produto_id).         
         oJson:ADD("sku_fornecedor", produtos_fornecedores.sku_fornecedor).                
         oJson:ADD("status",TRUE).                     
           
    END.
               
    jsonBody = NEW JsonArray(). 
    jsonBody:ADD(oJson).
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("produtos_fornecedores",jsonBody).         
    
    oJsonsaida:WriteFile("V:\includeMerco\envia_fornecec.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("V:\includeMerco\RetornoEnvioFornec.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pFornecedores:

    DEFINE INPUT PARAMETER r-produto  AS ROWID NO-UNDO.
 
 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
    
        FIND FIRST ems2mult.EMITENTE NO-LOCK
            WHERE ROWID(emitente) = r-produto NO-ERROR.
    
        FIND FIRST item-fornec NO-LOCK
            WHERE item-fornec.cod-emitente = emitente.cod-emitente NO-ERROR.
            
            
            //MESSAGE item-fornec.cod-emitente
                //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            IF AVAIL item-fornec THEN DO:
            
                CREATE produtos_fornecedores.
                ASSIGN produtos_fornecedores.id             = INT(item-fornec.it-codigo)
                       produtos_fornecedores.origem         = "Datasul"
                       produtos_fornecedores.entidade_id    = item-fornec.cod-emitente
                       produtos_fornecedores.produto_id     = INT(item-fornec.it-codigo) // Acredito que n∆o seja este e serve para de cima ''
                       produtos_fornecedores.sku_fornecedor = item-fornec.it-codigo // coloar + o cnpj? "emitente.item-fornec Œ enviar o cnpj do fornecedor"
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
