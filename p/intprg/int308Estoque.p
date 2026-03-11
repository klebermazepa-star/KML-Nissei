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

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

{intprg/int301.i}  
//{utp/ut-glob.i}
//DEFINE INPUT PARAMETER r-produto  AS ROWID NO-UNDO.
DEFINE VARIABLE h-pdapi002  AS HANDLE NO-UNDO.
DEF VAR p-de-saldo AS DEC NO-UNDO. 
def var h-acomp    as handle no-undo.

//colocar run na procedure pfornec

/* recebimento de parƒmetros */
def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int308.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.
           
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

RUN pTabEstoque. //(INPUT r-produto). 



PROCEDURE pEnviaTabEstoqueHub:

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
           oURI:Path   = '/datasul/pub/estoques'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library. 
                                      
    FOR EACH tt-estoques:
    
        oJson = NEW JsonObject().                            
        oJson:ADD("produto_id",tt-estoques.produto_id).            
        oJson:ADD("local_id",tt-estoques.local_id).         
        oJson:ADD("local_desc",tt-estoques.local_desc).
        oJson:ADD("lote",tt-estoques.lote).
        oJson:ADD("saldo",tt-estoques.saldo).        
        oJson:ADD("saldo_reserva",tt-estoques.saldo_reserva).                                      
        oJson:ADD("filial_id",string(tt-estoques.local_id)).
        oJson:ADD("unidade_medida",tt-estoques.unidade_medida).
        oJson:ADD("origem",tt-estoques.origem). 
        oJson:ADD("status",TRUE).
        oJson:ADD("data_validade",tt-estoques.data_validade).
        //oJson:ADD("data_criacao",tt-estoques.data_criacao).
        //oJson:ADD("data_atualizacao",tt-estoques.data_atualizacao).
    END.
    
    jsonBody = NEW JsonArray(). 
    jsonBody:ADD(oJson).
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("estoques",jsonBody).         
    
    oJsonsaida:WriteFile("U:\KML\envioEstoque.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("U:\KML\RetornoEstoque.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pTabEstoque:

    FIND FIRST tt-param NO-LOCK NO-ERROR.

    //DEFINE INPUT PARAMETER r-tabela  AS ROWID NO-UNDO.

    //FIND FIRST esp-alteracao-bi NO-LOCK
        //WHERE ROWID(esp-alteracao-bi) = r-tabela NO-ERROR.

 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
   // 04/03/2026 corrigo o for each que estava "Where <> "" " causando lentidÆo por estar fora do indice.
   FOR EACH ITEM NO-LOCK:
    
        IF ITEM.it-codigo <> "" THEN
        DO:
        
            run pi-acompanhar in h-acomp (INPUT ITEM.it-codigo).
        
            FIND FIRST integra-item NO-LOCK 
                WHERE integra-item.it-codigo = ITEM.it-codigo NO-ERROR.
            
            IF AVAIL integra-item THEN
            DO:
            
                FOR EACH ems2mult.estabelec NO-LOCK:
                
                    IF estabelec.ep-codigo   = "10" THEN
                    DO:

                        FOR EACH saldo-estoq NO-LOCK
                            WHERE saldo-estoq.it-codigo   = ITEM.it-codigo 
                             AND  saldo-estoq.cod-estabel = estabelec.cod-estabel:

                                IF AVAIL saldo-estoq  THEN
                                DO:
                                
                                    FIND FIRST deposito NO-LOCK
                                        WHERE deposito.cod-depos = saldo-estoq.cod-depos NO-ERROR.
                                    
                                    RUN pdp/pdapi002.p persistent set h-pdapi002.    


                                    run pi-verifica-saldo IN h-pdapi002         (input  ITEM.it-codigo,
                                                                                 input  ITEM.cod-refer,
                                                                                 input  estabelec.cod-estabel,
                                                                                 input  TODAY,
                                                                                 output p-de-saldo).
                                                                                 
                                    CREATE tt-estoques.
                                    ASSIGN tt-estoques.produto_id       = int(saldo-estoq.it-codigo)  
                                           tt-estoques.local_id         = int(saldo-estoq.cod-estabel) // Validar o que deve ser enviado tambem, estabelecimento/deposito... possivelmente concatenar
                                           tt-estoques.local_desc       = deposito.nome //validar com Pedro o que deve ser enviado neste campo
                                           tt-estoques.lote             = saldo-estoq.lote
                                           tt-estoques.saldo            = saldo-estoq.qtidade-atu 
                                           tt-estoques.saldo_reserva    = p-de-saldo //saldo-estoq.qtidade-atu - saldo-estoq.qt-alocada  // resultado da API
                                           tt-estoques.unidade_medida   = ITEM.un
                                           //tt-estoques.id               = 0
                                           tt-estoques.origem           = "Datasul"
                                           tt-estoques.data_validade    = saldo-estoq.dt-vali-lote
                                           tt-estoques.data_criacao     = NOW
                                           tt-estoques.data_atualizacao = NOW
                                                       .
                                                       
                                    DELETE PROCEDURE h-pdapi002. 
                                    
                                    run pi-acompanhar in h-acomp (INPUT "Cod-estabel" + "-" + saldo-estoq.cod-estabel + "Item" + "-" + saldo-estoq.it-codigo).
                                   
                                    RUN pEnviaTabEstoqueHub.
                                      
                                END.
                        END.    
                    END.
                END.
            END.        
        END.
    END.
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

run pi-finalizar in h-acomp.
