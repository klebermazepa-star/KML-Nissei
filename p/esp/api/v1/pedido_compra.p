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

DEFINE TEMP-TABLE pedido_compra  NO-UNDO
    //FIELD DATAst               AS INT
    FIELD id_pedido_datasul    AS INT
    FIELD origem               AS CHAR
    FIELD filial_id            AS INT
    FIELD filial_nome          AS CHAR
    FIELD numero_pedido_compra AS INT
    FIELD fornecedor_id        AS INT
    FIELD fornecedor_nome      AS CHAR
    FIELD transportadora_id    AS INT
    FIELD transportadora_nome  AS CHAR
    FIELD data_criacao         AS DATETIME
    FIELD login                AS CHAR
    FIELD observacoes          AS CHAR
    FIELD numero_seq_compra    AS CHAR
    FIELD data_chegada         AS DATE
    FIELD login_criador        AS CHAR
    FIELD login_aprovador      AS CHAR
    FIELD contato              AS CHAR
    FIELD data_alteracao       AS DATETIME
    FIELD data_cadastro        AS DATETIME
    FIELD valor_bruto          AS DEC
    FIELD motivo_cancelamento  AS CHAR
    FIELD data_liberacao       AS DATETIME
    FIELD saldo_financeiro     AS DEC
    FIELD valor_desconto_total AS DEC
    FIELD tipo_frete_id        AS INT
    FIELD tipo_frete_nome      AS CHAR
    FIELD tipo_cobranca        AS CHAR
    FIELD valor_frete          AS DEC
    FIELD valor_st             AS DEC
    .
    
DEFINE TEMP-TABLE itens  NO-UNDO
    //FIELD DATAst                 AS INT
    FIELD id                     AS INT
    FIELD produto_id             AS INT
    FIELD numero_seq_compra      AS CHAR
    FIELD valor_produto          AS DEC
    FIELD preco                  AS DEC
    FIELD quantidade_itens       AS INT
    FIELD saldo                  AS DEC
    FIELD ipi                    AS DEC
    FIELD icms                   AS DEC
    FIELD iss                    AS DEC
    FIELD valor_liquido          AS DEC
    FIELD valor_bruto            AS DEC
    FIELD valor_total            AS DEC
    FIELD validade               AS DATE
    FIELD unidade_medida_id      AS INT
    FIELD unidade_medida         AS CHAR
    FIELD valor_base_icms        AS DEC
    FIELD valor_icms             AS DEC
    FIELD taxa_icms              AS DEC
    FIELD valor_base_ipi         AS DEC
    FIELD valor_ipi              AS DEC
    FIELD taxa_ipi               AS DEC
    FIELD valor_base_iss         AS DEC
    FIELD valor_iss              AS DEC
    FIELD valor_iss_retido       AS DEC
    FIELD taxa_iss               AS DEC
    FIELD valor_base_st          AS DEC
    FIELD valor_frete            AS DEC
    FIELD valor_st               AS DEC
    FIELD taxa_st                AS DEC
    FIELD data_entrega           AS DATE
    FIELD descricao_cancelamento AS CHAR
    FIELD quantidade_cancelada   AS INT.
    
 
 DEF DATASET dspedidos FOR pedido_compra, itens
     DATA-RELATION r1 FOR pedido_compra, itens
        RELATION-FIELDS(numero_seq_compra,numero_seq_compra) NESTED.
    
DEFINE INPUT PARAMETER r-ped  AS ROWID NO-UNDO.

DEFINE VARIABLE transportador AS CHAR.


//colocar run na procedure pfornec


RUN pPedidoCompra (INPUT r-ped).
//RUN pPedidoCompra.
RUN pEnviaPedidoCompraHub.


PROCEDURE pEnviaPedidoCompraHub:

    DEFINE VARIABLE oJson      AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp  AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonRaiz  AS JsonObject    NO-UNDO. //novo
    DEFINE VARIABLE oPedidos   AS JsonArray     NO-UNDO. //novo
    DEF VAR         jsonObj    AS JsonObject    NO-UNDO.
    DEF VAR         jsonBody  AS JsonArray      NO-UNDO.
   // DEF VAR         jsonTeste AS JsonArray      NO-UNDO. //teste
    DEFINE VARIABLE oClient   AS IHttpClient    NO-UNDO.
    DEFINE VARIABLE oURI      AS URI            NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest   NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE         NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR         NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR   NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse  NO-UNDO.
    DEFINE VARIABLE c-token   AS CHARACTER      NO-UNDO.
    DEFINE VARIABLE oLib      AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    define variable vJsonAsString as CHAR no-undo.
    DEFINE VARIABLE myParser    AS ObjectModelParser NO-UNDO.


        
    RUN pGeraToken (OUTPUT c-token).
    
/*     MESSAGE c-token                               */
/*         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/datasul/pub/pedido_compra'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library. 
                                      
    //old - ASSIGN oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET dspedidos:HANDLE, NO).
    //old - oJson = oJson:getJsonObject("dspedidos").
    //old - oJson = oJson:GetJsonArray("pedido_compra"):GetJsonObject(1).
    //old - oJsonRaiz = oJsonRaiz:GetJsonObject("dspedidos").
    //old - oPedidos = oJsonRaiz:GetJsonArray("pedido_compra"). 
    
    //KML 20/01/2026 - envio correto do json 
    oJsonRaiz = JsonAPIUtils:convertTempTableToJsonObject(DATASET dspedidos:HANDLE, NO).
    
    IF oJsonRaiz:Has("dspedidos") THEN DO:
    oJsonRaiz = oJsonRaiz:GetJsonObject("dspedidos").

        IF oJsonRaiz:Has("pedido_compra") THEN DO:
            oPedidos = oJsonRaiz:GetJsonArray("pedido_compra").

            oJsonsaida = NEW JsonObject().
            oJsonsaida:Add("pedido_compra", oPedidos).
        END.
    END.

    //oJsonsaida = NEW JsonObject().
    //oJsonsaida:ADD("pedido_compra",oPedidos).
    
/*     MESSAGE "Teste 2"                             */
/*         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
    //oJsonsaida:ADD("itens",jsonBody).
    //oJsonsaida:ADD("itens",jsonTeste).
             
    
    oJsonsaida:WriteFile("U:\envia_pedidoCompra.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("U:\RetornoEnvioPedidoCompra.json") NO-ERROR.
    
    //MESSAGE oResponse:statuscode
    //    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

END PROCEDURE.

PROCEDURE pPedidoCompra:

    DEFINE INPUT PARAMETER r-pedido  AS ROWID NO-UNDO.
    
    
    //MESSAGE string(r-pedido)
        //VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
 
 // aqui seria o momento de realizar o find na tabela criada (trigger) (integra-item-fornec e colocar apenas o indice primario igual foi feito no BI)
    
    //FIND FIRST pedido-compr NO-LOCK 
        //WHERE pedido-compr.num-pedido = 282 NO-ERROR.
        
     FIND FIRST esp-alteracao-bi NO-LOCK  
          WHERE ROWID (esp-alteracao-bi) = r-pedido NO-ERROR.
          
     IF AVAIL esp-alteracao-bi THEN
     DO:
     
        FIND FIRST pedido-compr NO-LOCK
          WHERE pedido-compr.num-pedido = esp-alteracao-bi.num-pedido NO-ERROR.
          
         IF AVAIL pedido-compr THEN
         DO:
            
            FOR EACH ordem-compra NO-LOCK
                WHERE ordem-compra.num-pedido = pedido-compr.num-pedido :
            
                FOR EACH cotacao-item NO-LOCK
                    WHERE cotacao-item.numero-ordem = ordem-compra.numero-ordem:
                    
                        FIND FIRST ems2mult.emitente NO-LOCK
                            WHERE emitente.cod-emitente = ordem-compra.cod-emitente NO-ERROR.
                            
                        IF AVAIL emitente THEN
                        DO:
                        
                            FIND FIRST ems2mult.transporte NO-LOCK
                            WHERE transporte.cod-transp = pedido-compr.cod-transp NO-ERROR.
                            
                            IF AVAIL transporte THEN DO:
                            
                                ASSIGN transportador = transporte.nome.
                                
                            END.
                             
                            ELSE DO:
                            
                                ASSIGN transportador = "PADR«O".
      
                            END.
                            
                            FIND FIRST ems2mult.estabelec NO-LOCK
                                WHERE estabelec.cod-estabel = ordem-compra.cod-estabel NO-ERROR. 
                                    
                            CREATE pedido_compra.
                            ASSIGN pedido_compra.id_pedido_datasul      = int(ordem-compra.num-pedido)
                                   pedido_compra.origem                 = "Datasul"
                                   pedido_compra.filial_id              = int(ordem-compra.cod-estabel)
                                   pedido_compra.filial_nome            = estabelec.nome
                                   pedido_compra.numero_pedido_compra   = ordem-compra.num-pedido
                                   pedido_compra.fornecedor_id          = ordem-compra.cod-emitente
                                   pedido_compra.fornecedor_nome        = emitente.nome-emit //for each na emitente
                                   pedido_compra.transportadora_id      = pedido-compr.cod-transp
                                   pedido_compra.transportadora_nome    = transportador //for each na transportadora
                                   pedido_compra.data_criacao           = pedido-compr.data-pedido
                                   pedido_compra.login                  = pedido-compr.responsavel
                                   pedido_compra.observacoes            = pedido-compr.comentarios
                                   pedido_compra.numero_seq_compra      = string(pedido-compr.num-pedido)
                                   pedido_compra.data_chegada           = TODAY //data de entrega?
                                   pedido_compra.login_criador          = ordem-compra.requisitante
                                   pedido_compra.login_aprovador        = ordem-compra.cod-comprado
                                   pedido_compra.contato                = cotacao-item.contato //buscar no emitente
                                   pedido_compra.data_alteracao         = pedido-compr.dat-alt
                                   pedido_compra.data_cadastro          = pedido-compr.dat-criac
                                   pedido_compra.valor_bruto            = cotacao-item.preco-fornec //validar depois
                                   pedido_compra.motivo_cancelamento    = "" //ja vi mas n∆o lembro
                                   pedido_compra.data_liberacao         = pedido-compr.data-pedido //ja vi mas n∆o lembro tambem
                                   pedido_compra.saldo_financeiro       = 0 //buscar de onde?
                                   pedido_compra.valor_desconto_total   = cotacao-item.valor-descto
                                   pedido_compra.tipo_frete_id          = INT(cotacao-item.frete) //verificar fazer um if-else
                                   pedido_compra.tipo_frete_nome        = "" //fazer um if else pra mandar pagou ou a-pagar
                                   pedido_compra.tipo_cobranca          = "" // n sei tambem
                                   pedido_compra.valor_frete            = cotacao-item.valor-frete
                                   pedido_compra.valor_st               = 0.
                                   
                                   
                                   
/*                             MESSAGE "antes create itens"                  */
/*                                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
                                
                            create itens.
                            ASSIGN itens.id                     = ordem-compra.numero-ordem
                                   itens.produto_id             = int(ordem-compra.it-codigo) //pode dar problema com itens com letras
                                   itens.numero_seq_compra      = string(pedido-compr.num-pedido) //STRING(ordem-compra.numero-ordem)
                                   itens.valor_produto          = cotacao-item.preco-fornec
                                   itens.preco                  = cotacao-item.preco-fornec
                                   itens.quantidade_itens       = ordem-compra.qt-solic
                                   itens.saldo                  = 0 //n sei
                                   itens.ipi                    = cotacao-item.aliquota-ipi
                                   itens.icms                   = cotacao-item.aliquota-icm
                                   itens.iss                    = cotacao-item.aliquota-iss
                                   itens.valor_liquido          = cotacao-item.preco-fornec
                                   itens.valor_bruto            = cotacao-item.preco-fornec
                                   itens.valor_total            = cotacao-item.preco-fornec
                                   itens.validade               = ? //n sei
                                   itens.unidade_medida_id      = 0
                                   itens.unidade_medida         = cotacao-item.un
                                   itens.valor_base_icms        = cotacao-item.aliquota-icm
                                   itens.valor_icms             = 0
                                   itens.taxa_icms              = cotacao-item.aliquota-icm
                                   itens.valor_base_ipi         = 0
                                   itens.valor_ipi              = 0
                                   itens.taxa_ipi               = 0
                                   itens.valor_base_iss         = 0
                                   itens.valor_iss              = 0
                                   itens.valor_iss_retido       = 0
                                   itens.taxa_iss               = 0
                                   itens.valor_base_st          = 0
                                   itens.valor_frete            = ordem-compra.valor-frete
                                   itens.valor_st               = 0
                                   itens.taxa_st                = 0
                                   itens.data_entrega           = TODAY + 1 //data-pedido?
                                   itens.descricao_cancelamento = ""
                                   itens.quantidade_cancelada   = 0.
                            
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
