USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.

USING Progress.Lang.*.
USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.URI.
USING Progress.Json.ObjectModel.*.

USING com.totvs.framework.api.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}
//{include/i_trddef.i}

// ==================================================================================================================================================================

DEF VAR jsonBody       AS JsonObject NO-UNDO.
DEF VAR jsonPedidos    AS JsonObject NO-UNDO.
DEF VAR jsonItens      AS JsonObject NO-UNDO.
DEF VAR jsonItensArray AS JsonArray  NO-UNDO.


DEF VAR EstaOK     AS LOGICAL.
DEF VAR Token      AS CHAR.
DEF VAR retornoAPI AS CHAR.
DEF VAR numero     AS INTEGER.
DEF VAR h-acomp    AS HANDLE NO-UNDO.
DEF VAR Pedido_myask AS CHAR.
DEF VAR v-unit-item AS DEC.
DEF VAR v-unit-item-bruto AS DEC.
DEF VAR v-percentual-item AS DEC.
define variable v-percentual-pedido as DEC.
define variable v-percentual-calc as dec.
define variable v-percentual-calc-item as dec.
define variable v-desconto-pedido as dec.
define variable v-desconto-item as dec.
DEF VAR v-vl-liquido-item AS DEC.
DEF VAR v-vl-bruto-item   AS DEC.
DEF VAR v-vl-bruto        AS DEC.
DEF VAR v-vl-bruto-pedido AS DEC.
DEF VAR v-vl-bruto-total-item AS DEC.
DEF VAR v-vl-liquido          AS DEC.
DEF VAR v-vl-bruto-total      AS DEC.
DEFINE VARIABLE jsonTeste AS CHARACTER   NO-UNDO.
DEFINE VAR c-tipo AS INT.

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR FORMAT "x(35)":U
    FIELD usuario          AS CHAR FORMAT "x(12)":U
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    FIELD classifica       AS INTEGER
    FIELD desc-classifica  AS CHAR FORMAT "x(40)":U
    FIELD modelo           AS CHAR FORMAT "x(35)":U
    FIELD l-habilitaRtf    as LOG
    FIELD codPedidoInicial AS CHAR
    FIELD codPedidoFinal   AS CHAR
    FIELD situacao         AS INTEGER. //0 = Todos, 1 = Somente Alterados

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD ordem            AS INTEGER   FORMAT ">>>>9"
    FIELD exemplo          AS CHARACTER FORMAT "x(30)"
    INDEX id ordem.

DEFINE TEMP-TABLE tt-raw-digita
    FIELD raw-digita AS RAW.

DEF INPUT PARAM r-ped-venda AS ROWID NO-UNDO.
DEF INPUT PARAM c-status    AS CHAR NO-UNDO.

// ==================================================================================================================================================================

RUN utp/ut-acomp.r PERSISTENT SET h-acomp.

RUN pi-inicializar IN h-acomp (INPUT "Processando registros de pedidos...").

RUN pi-acompanhar IN h-acomp (INPUT "Obtendo Token...").

RUN getToken.

IF Token = "" THEN DO:
   PUT UNFORMAT retornoAPI.
   run pi-finalizar in h-acomp.
   RETURN.
END.   



RUN pi-acompanhar IN h-acomp (INPUT "Integrando pedido...").

RUN processarObjetosJSON.

FIND FIRST ped-venda NO-LOCK
    WHERE rowid(ped-venda) =  r-ped-venda NO-ERROR.

IF AVAIL ped-venda THEN
DO:
    FIND FIRST esp-modalidade-cross NO-LOCK
        WHERE esp-modalidade-cross.cod-ped-venda = ped-venda.nr-pedcli NO-ERROR.

    IF AVAIL esp-modalidade-cross THEN
    DO:

        IF esp-modalidade-cross.flag-cross  = NO THEN
        DO:
            
            RUN enviarJSON.
            
        END.
 
    END.
    ELSE DO:
    
        RUN enviarJSON.    
    
    END.
    
END.
    
 
OUTPUT CLOSE.

run pi-finalizar in h-acomp.
h-acomp = ?.

// ==================================================================================================================================================================

PROCEDURE getToken:

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
                                        //https://merco-prd-datahub-api-97903554824.us-east1.run.app/datasul/pub/pedido_venda
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
    
    
    ASSIGN Token =  oJsonResponse:GetCharacter("access_token").

END PROCEDURE.

// ==================================================================================================================================================================

PROCEDURE enviarJSON.
    DEF VAR oURI          AS URI                NO-UNDO.
    DEF VAR chHttp        AS COM-HANDLE         NO-UNDO .
    DEF VAR oJsonResponse AS JsonObject         NO-UNDO.
    DEF VAR myParser      AS ObjectModelParser  NO-UNDO. 
    DEF VAR oLib          AS IHttpClientLibrary NO-UNDO.
    DEF VAR oRequest      AS IHttpRequest       NO-UNDO.
    DEF VAR oResponse     AS IHttpResponse      NO-UNDO.
    DEF VAR oClient       AS IHttpClient        NO-UNDO.
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/datasul/pub/pedido_venda'.
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.
                                      
                                      
   LOG-MANAGER:WRITE-MESSAGE("KML JSON SAIDA") NO-ERROR.
                                   
   LOG-MANAGER:WRITE-MESSAGE("KML JSON - " + STRING(jsonPedidos:GetJsonText())) NO-ERROR.
   
                                    

    oRequest  = RequestBuilder:POST(oURI, jsonPedidos)
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + Token)
                :Request.
        
    oClient = ClientBuilder:Build():UsingLibrary(oLib):Client.
            
    oResponse = oClient:Execute(oRequest).
    
    
    .MESSAGE oResponse:statuscode 
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    IF oResponse:statuscode >= 200 AND oResponse:statuscode < 300 THEN DO:
       PUT UNFORMAT "- JSON integrado com sucesso." SKIP(1).
       EstaOK = TRUE.
       retornoAPI = STRING(oResponse:Entity).
       IF retornoAPI MATCHES "*JsonObject*" THEN DO:
          oJsonResponse = CAST(oResponse:Entity, JsonObject).
          
       //   oJsonResponse:WriteFile("u:\PEDIDOS_retorno " + STRING(TIME) + ".json") NO-ERROR.
    
          retornoAPI = STRING(oJsonResponse:GetJsonText()).
       END.
    END.
    ELSE DO:
       PUT UNFORMAT "- JSON integrado com falha." SKIP(1).
       EstaOK = FALSE.
       oJsonResponse = CAST(oResponse:Entity, JsonObject).
     //  oJsonResponse:WriteFile("u:\PEDIDOS_retorno " + STRING(TIME) + ".json") NO-ERROR.
    
       retornoAPI = STRING(oJsonResponse:GetJsonText()).
    END.    
END PROCEDURE.

// ==================================================================================================================================================================

PROCEDURE processarObjetosJSON:


    jsonPedidos     = NEW JsonObject().

   
    FOR LAST ped-venda NO-LOCK
        WHERE rowid(ped-venda) =  r-ped-venda
        :      
    
        LOG-MANAGER:WRITE-MESSAGE("KML Pedido encontrado - " + STRING(ped-venda.nr-pedcli)) NO-ERROR.
   
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cod-estabel = ped-venda.cod-estabel NO-ERROR.
                  
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.nome-abrev = ped-venda.nome-abrev NO-ERROR.
 
        IF AVAIL emitente THEN
            FIND first ext-emitente-nissei no-lock 
                    where ext-emitente-nissei.cod-emitente = emitente.cod-emitente NO-ERROR. 
            
            
        FIND FIRST ped-item 
            WHERE ped-item.nome-abrev   = ped-venda.nome-abrev
              AND ped-item.nr-pedcli    = ped-venda.nr-pedcli NO-LOCK NO-ERROR.   
        
        IF AVAIL ped-item THEN
        DO:
        
            IF ped-venda.tp-pedido = "2" THEN
            DO:
                ASSIGN c-tipo = 15.
                
            END.
            
            ELSE DO:
                c-tipo = 3. 
            END.
        
            LOG-MANAGER:WRITE-MESSAGE("KML ITEM encontrado - " + STRING(ped-venda.nr-pedcli)) NO-ERROR.
   
        
            ASSIGN pedido_myask = SUBSTRING(ped-venda.char-1, 100,10).
            
            v-percentual-pedido = ped-venda.val-pct-desconto-total / 100.
            v-percentual-calc   = 1 - v-percentual-pedido.
            v-vl-bruto-pedido   = dec(ped-venda.vl-tot-ped) / v-percentual-calc.
            v-desconto-pedido   = v-vl-bruto-pedido - ped-venda.vl-tot-ped.
  
                
            jsonPedidos:ADD("id_pedido_datasul",ped-venda.nr-pedcli).
            jsonPedidos:ADD("origem","datasul").
            jsonPedidos:ADD("filial_cnpj",estabelec.cgc).
            jsonPedidos:ADD("filial_id",estabelec.cod-estabel).
            jsonPedidos:ADD("data_emissao",ped-venda.dt-emissao).
            jsonPedidos:ADD("descricao_etapa",c-status).
            jsonPedidos:ADD("pedido_tipo",integer(3)).
            jsonPedidos:ADD("condicao_pagamento",ped-venda.cod-cond-pag).       
            jsonPedidos:ADD("obs",ped-venda.observacoes). 
            jsonPedidos:ADD("pedido_num",int(pedido_myask)). //era nr-pedido
            //jsonPedidos:ADD("TESTE_IN",c-tipo).
            jsonPedidos:ADD("valor_pedido",ROUND(ped-venda.vl-tot-ped, 2)).
            jsonPedidos:ADD("percentual_desconto",ROUND(ped-venda.val-pct-desconto-total, 2)). //des-pct-desconto-inform
            jsonPedidos:ADD("valor_desconto",ROUND(v-desconto-pedido, 2)).
            jsonPedidos:ADD("valor_bruto",ROUND(v-vl-bruto-pedido, 2)). 
            jsonPedidos:ADD("cliente_id",emitente.cgc).  
            jsonPedidos:ADD("entidade_tipo",1).          
            jsonPedidos:ADD("base_origem",0). 
            jsonPedidos:ADD("pedido_info",ped-venda.observacoes). 
            jsonPedidos:ADD("data_shelf_life", IF AVAIL ext-emitente-nissei THEN ext-emitente-nissei.shelflife ELSE 0). 
            jsonPedidos:ADD("codigo_etapa",1).
            jsonPedidos:ADD("data_etapa",string(year(ped-venda.dt-useralt), "9999") + "-" + string(MONTH(ped-venda.dt-useralt), "99") + "-" + string(DAY(ped-venda.dt-useralt), "99") + "T14:55:44.673Z").
            jsonPedidos:ADD("ordem_compra_id",ped-item.cod-ord-compra).   
            
        END.
        
    END.    
    
    
    jsonItensArray = NEW JsonArray().
    
    FIND FIRST ems2mult.transporte NO-LOCK
        WHERE  transporte.nome-abrev =  ped-venda.nome-transp NO-ERROR. 
    
    FOR EACH ped-item      NO-LOCK
        WHERE ped-item.nome-abrev   = ped-venda.nome-abrev
          AND ped-item.nr-pedcli    = ped-venda.nr-pedcli :
        
        v-percentual-item      = ped-item.val-pct-desconto-total / 100.
        v-percentual-calc-item = 1 - v-percentual-item.
        v-unit-item            = dec(ped-item.vl-preuni) / v-percentual-calc-item. // 
        v-vl-bruto             = ped-item.vl-preori * ped-item.qt-pedida. //v-unit-item. 
        v-vl-liquido           = ped-item.vl-preuni * ped-item.qt-pedida.  //vl-preuni
        //v-vl-bruto-total       = v-vl-bruto * ped-item.qt-pedida. 
        v-desconto-item        =   v-vl-bruto - v-vl-liquido. 
          
        LOG-MANAGER:WRITE-MESSAGE("KML Criando ITEM  - " + STRING(ped-item.it-codigo)) NO-ERROR.

    
        jsonItens = NEW JsonObject().
        jsonItens:ADD("sequencia_id", ped-item.nr-sequencia). // era / 10 "divido"
        jsonItens:ADD("id_pedido_datasul",ped-item.nr-pedcli).                                                       
        jsonItens:ADD("produto_id",ped-item.it-codigo).
        jsonItens:ADD("lote_id","0").
        jsonItens:ADD("lote","").
        jsonItens:ADD("lote_cdi",0).
        jsonItens:ADD("lote_quantidade_saida",0).
        jsonItens:ADD("documento_num",0).
        jsonItens:ADD("numero_fornecedor",string(emitente.cod-emitente)).
        jsonItens:ADD("data_validade", string(year(ped-item.dt-entrega), "9999") + "-" + string(MONTH(ped-item.dt-entrega), "99") + "-" + string(DAY(ped-item.dt-entrega), "99")).
        jsonItens:ADD("data_fabricacao",ped-item.data-1).
        jsonItens:ADD("quantidade",ped-item.qt-pedida).
        jsonItens:ADD("quantidade_convertida",ped-item.qt-pedida).
        jsonItens:ADD("quantidade_faturar",ped-item.qt-atendida).
        jsonItens:ADD("quantidade_reservada",ped-item.qt-alocada).
        jsonItens:ADD("tipo_embalagem",ped-item.des-un-medida).
        jsonItens:ADD("quantidade_original",ped-item.qt-pedida).
        jsonItens:ADD("valor_unitario",ROUND(ped-item.vl-preuni, 2)). //vl-preuni
        jsonItens:ADD("valor_desconto",ROUND(v-desconto-item / ped-item.qt-pedida, 2)). //jsonItens:ADD("valor_desconto",ROUND(v-vl-liquido - v-vl-bruto-total  / ped-item.qt-pedida , 2)).
        jsonItens:ADD("percentual_desconto",ped-item.val-pct-desconto-total). //NOVO //des-pct-desconto-inform
        jsonItens:ADD("valor_bruto",ROUND(ped-item.vl-preori, 2)). //NOVO
        jsonItens:ADD("valor_total_liquido",(v-vl-liquido)). //NOVO Quantidade ž valor unit rio l¡quido
        jsonItens:ADD("valor_total_bruto",(ped-item.vl-preori * ped-item.qt-pedida)). //NOVO Quantidade ž valor unit rio bruto	Calculado no envio
        jsonItens:ADD("valor_total_desconto",ROUND(v-desconto-item, 2)). //NOVO 
        jsonItens:ADD("observacao",ped-item.observacao).
        jsonItens:ADD("data_alteracao", string(year(ped-item.dt-useralt), "9999") + "-" + string(MONTH(ped-item.dt-useralt), "99") + "-" + string(DAY(ped-item.dt-useralt), "99")).
        jsonItens:ADD("valor_frete",ped-item.val-frete).
        jsonItens:ADD("data_entrega",string(year(ped-item.dt-entrega), "9999") + "-" + string(MONTH(ped-item.dt-entrega), "99") + "-" + string(DAY(ped-item.dt-entrega), "99")).
        jsonItens:ADD("cnpj_transportadora",IF AVAIL transporte THEN transporte.cgc ELSE "").
    
        jsonItensArray:ADD(jsonItens).
       
        
    END.
    
    v-vl-liquido           = 0.
    v-vl-bruto             = 0.
    v-vl-bruto-pedido      = 0.
    v-vl-bruto-total       = 0.
    v-percentual-pedido    = 0.
    v-percentual-calc      = 0.
    v-desconto-pedido      = 0.
    v-percentual-item      = 0.
    v-percentual-calc-item = 0.
    v-unit-item            = 0.             
    v-desconto-item        = 0.
    
    
    jsonPedidos:ADD("itens",jsonItensArray).
    
    LOG-MANAGER:WRITE-MESSAGE("KML FORMADO JSON - " + STRING(jsonPedidos:GetJsonText())) NO-ERROR.
    
    jsonPedidos:WRITE(jsonTeste) NO-ERROR.
    
    //Mostra o JSON em tela
    //MESSAGE jsonTeste
    //    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   
   
   // jsonPedidos:WriteFile("u:\PEDIDOS_ " + STRING(ped-item.nr-pedcli) + ".json") NO-ERROR.
    
   
    PUT UNFORMAT "- Gerado objeto JSON" SKIP.
   
END PROCEDURE.

// ==================================================================================================================================================================
