USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}
//{include/i_trddef.i}

// ==================================================================================================================================================================
DEF VAR jsonBody       AS JsonObject NO-UNDO.
DEF VAR jsonProdutos   AS JsonObject NO-UNDO.
DEF VAR jsonObj        AS JsonObject NO-UNDO.
DEF VAR jsonDetailEAN  AS JsonArray  NO-UNDO.
DEF VAR jsonDetailDUN  AS JsonArray  NO-UNDO.
DEF VAR jsonEspecific  AS JsonArray  NO-UNDO. 

DEF VAR EstaOK     AS LOGICAL.
DEF VAR Token      AS CHAR.
DEF VAR retornoAPI AS CHAR.
DEF VAR numero     AS INTEGER.
DEF VAR h-acomp    AS HANDLE NO-UNDO.
DEF VAR CNPJ_FAB   AS CHAR.
DEF VAR NOME_FAB   AS CHAR.
DEF VAR QUANTIDADE AS DEC.
DEF VAR PROFUNDIDADE AS DEC.
DEF VAR LARGURA      AS DEC.
DEF VAR ALTURA       AS DEC.
DEF VAR PESO_LIQUIDO AS DEC.
DEF VAR PESO_BRUTO   AS DEC.
DEF VAR TEMP_MIN     AS DEC.
DEF VAR TEMP_MAX     AS DEC.
DEF VAR PALLET       AS DEC.

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
    FIELD codItemInicial   AS CHAR
    FIELD codItemFinal     AS CHAR
    FIELD situacao         AS INTEGER. //0 = Todos, 1 = Somente alterados

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD ordem            AS INTEGER   FORMAT ">>>>9"
    FIELD exemplo          AS CHARACTER FORMAT "x(30)"
    INDEX id ordem.

DEFINE TEMP-TABLE tt-raw-digita
    FIELD raw-digita AS RAW.

DEF INPUT PARAM raw-param AS RAW NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-raw-digita.

CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

// ==================================================================================================================================================================

RUN utp/ut-acomp.r PERSISTENT SET h-acomp.

RUN pi-inicializar IN h-acomp (INPUT "Processando registros de Itens...").

OUTPUT TO VALUE(tt-param.arquivo) NO-CONVERT.

IF tt-param.situacao = 0 THEN DO:
   FOR EACH ITEM WHERE ITEM.it-codigo >= tt-param.codItemInicial
                   AND ITEM.it-codigo <= tt-param.codItemFinal
                   NO-LOCK:
                   
       FIND FIRST item-mat WHERE item-mat.it-codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
       IF NOT AVAIL item-mat THEN NEXT.
                   
       FIND FIRST integra-item WHERE integra-item.it-codigo = ITEM.it-codigo 
                                 AND integra-item.situacao  = 1
                                 NO-LOCK NO-ERROR.
                                 
       IF AVAIL integra-item THEN NEXT.
       
       numero = INTEGER(ITEM.it-codigo) NO-ERROR.
       IF ERROR-STATUS:ERROR THEN NEXT.
       
       RUN pi-acompanhar IN h-acomp (INPUT "Criando inegra‡Æo para o item " + item.it-codigo).
       
       CREATE integra-item.
       ASSIGN integra-item.it-codigo    = ITEM.it-codigo
              integra-item.dt-alteracao = NOW
              integra-item.situacao     = 1.
       
   END.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Obtendo Token...").

RUN getToken.

IF Token = "" THEN DO:
   PUT UNFORMAT retornoAPI.
   run pi-finalizar in h-acomp.
   RETURN.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Integrando itens...").

FOR EACH integra-item WHERE integra-item.situacao = 1 EXCLUSIVE-LOCK.
                        
    FIND FIRST ITEM WHERE ITEM.it-codigo = integra-item.it-codigo NO-LOCK NO-ERROR.
    IF NOT AVAIL ITEM THEN NEXT.
    
    FIND FIRST item-mat WHERE item-mat.it-codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
    IF NOT AVAIL item-mat THEN NEXT.

    numero = INTEGER(ITEM.it-codigo) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN NEXT.
    
    RUN pi-acompanhar IN h-acomp (INPUT "Integrando item " + item.it-codigo).
    
    PUT UNFORMAT "Item: " + item.it-codigo SKIP.
    
    RUN processarObjetosJSON. 
    RUN enviarJSON.
    
    ASSIGN integra-item.dt-alteracao       = NOW
           integra-item.retorno-integracao = retornoAPI.
    
    IF NOT EstaOK THEN ASSIGN integra-item.situacao = 3.
    ELSE ASSIGN integra-item.situacao = 2.
END.   
    
OUTPUT CLOSE.

run pi-finalizar in h-acomp.
h-acomp = ?.

// ==================================================================================================================================================================

PROCEDURE getToken.
    DEF VAR chHttp        AS COM-HANDLE        NO-UNDO .
    DEF VAR cHost         AS CHARACTER         NO-UNDO INIT "https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" .
    DEF VAR oJsonResponse AS JsonObject        NO-UNDO.
    DEF VAR myParser      AS ObjectModelParser NO-UNDO. 

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    //chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh").
    chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh"). 

    
    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).
    
    IF oJsonResponse:has("access_token") THEN DO: 
       EstaOK = TRUE.
       ASSIGN Token = oJsonResponse:GetCharacter("access_token").
    END.
    ELSE retornoAPI = STRING(oJsonResponse:getJsonText()).
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
           oURI:Path   = '/datasul/pub/produto'.
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.

    oRequest  = RequestBuilder:POST(oURI, jsonBody)
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + Token)
                :Request.
        
    oClient = ClientBuilder:Build():UsingLibrary(oLib):Client.
            
    oResponse = oClient:Execute(oRequest).
    
    oJsonResponse:WriteFile("u:\PRODUTOS_SAIDA " + STRING(TIME) + ".json") NO-ERROR.
    
    
    
    IF oResponse:statuscode >= 200 AND oResponse:statuscode < 300 THEN DO:
       PUT UNFORMAT "- JSON integrado com sucesso." SKIP(1).
       EstaOK = TRUE.
       retornoAPI = STRING(oResponse:Entity).
       IF retornoAPI MATCHES "*JsonObject*" THEN DO:
          oJsonResponse = CAST(oResponse:Entity, JsonObject).
          
          oJsonResponse:WriteFile("u:\PRODUTOS_RETORNO " + STRING(TIME) + ".json") NO-ERROR.
          
          retornoAPI = STRING(oJsonResponse:GetJsonText()).
       END.
    END.
    ELSE DO:
       PUT UNFORMAT "- JSON integrado com falha." SKIP(1).
       EstaOK = FALSE.
       oJsonResponse = CAST(oResponse:Entity, JsonObject).
       oJsonResponse:WriteFile("u:\PRODUTOS_RETORNO " + STRING(TIME) + ".json") NO-ERROR.
       
       retornoAPI = STRING(oJsonResponse:GetJsonText()).
    END.    
END PROCEDURE.

// ==================================================================================================================================================================

PROCEDURE processarObjetosJSON.
   jsonBody        = NEW JsonObject().
   jsonProdutos    = NEW JsonObject().
   jsonDetailEAN   = NEW JsonArray().
   jsonDetailDUN   = NEW JsonArray().
   jsonEspecific   = NEW JsonArray().
   
   FIND FIRST item-mat WHERE item-mat.it-codigo = ITEM.it-codigo NO-LOCK NO-ERROR.
   
   FOR EACH it-carac-tec NO-LOCK
        WHERE it-carac-tec.it-codigo = ITEM.it-codigo
        AND   (it-carac-tec.cd-comp    = "FAB"
        OR      it-carac-tec.cd-comp   = "CNPJ"
        OR      it-carac-tec.cd-comp   = "UCX"
        OR      it-carac-tec.cd-comp   = "ALT"
        OR      it-carac-tec.cd-comp   = "LAG"
        OR      it-carac-tec.cd-comp   = "PRO"
        OR      it-carac-tec.cd-comp   = "PLT"
        OR      it-carac-tec.cd-comp   = "PBT"
        OR      it-carac-tec.cd-comp   = "TMI"
        OR      it-carac-tec.cd-comp   = "TMA"
        OR      it-carac-tec.cd-comp   = "PLZ"):
          
            IF it-carac-tec.cd-comp = "FAB" AND it-carac-tec.observacao = " " THEN 
                ASSIGN NOME_FAB = "A DEFINIR".  
        
            ELSE IF it-carac-tec.cd-comp = "FAB"  AND it-carac-tec.observacao <> " "  THEN
                ASSIGN NOME_FAB = it-carac-tec.observacao.
                                        
            ELSE IF it-carac-tec.cd-comp   = "CNPJ" THEN  
                ASSIGN CNPJ_FAB = it-carac-tec.observacao.
                
            ELSE IF  it-carac-tec.cd-comp   = "UCX" THEN 
                ASSIGN QUANTIDADE = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "PRO" THEN 
                ASSIGN PROFUNDIDADE = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "LAG" THEN 
                ASSIGN LARGURA = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "ALT" THEN 
                ASSIGN ALTURA = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "PLT" THEN 
                ASSIGN PESO_LIQUIDO = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "PBT" THEN 
                ASSIGN PESO_BRUTO = it-carac-tec.vl-result.
                
            ELSE IF  it-carac-tec.cd-comp   = "TMI" THEN 
                ASSIGN TEMP_MIN = it-carac-tec.vl-result.  
                
            ELSE IF  it-carac-tec.cd-comp   = "TMA" THEN 
                ASSIGN TEMP_MAX = it-carac-tec.vl-result. 
                
            ELSE IF  it-carac-tec.cd-comp   = "PLZ" THEN 
                ASSIGN PALLET = it-carac-tec.vl-result.      
             
   
   END.
   
   IF NOT AVAIL item-mat THEN NEXT.
   
   jsonProdutos:ADD("id",INTEGER(ITEM.it-codigo)).
   jsonProdutos:ADD("origem","datasul").
   jsonProdutos:ADD("nome",ITEM.desc-item).
   jsonProdutos:ADD("descricao",ITEM.desc-item).
   jsonProdutos:ADD("descricao_reduzida",SUBSTRING(ITEM.desc-item,1,40)).
   jsonProdutos:ADD("unidade_medida",ITEM.un).
   jsonProdutos:ADD("embalagem_industria",QUANTIDADE).
   jsonProdutos:ADD("marca_id",0).         //TODO
   jsonProdutos:ADD("marca_nome","A DEFINIR"). //TODO
   jsonProdutos:ADD("fabricante_id",0).    //TODO
   jsonProdutos:ADD("fabricante_nome", NOME_FAB).  //TODO
   jsonProdutos:ADD("fabricante_cnpj",CNPJ_FAB).   //TODO
   jsonProdutos:ADD("unidade_id",0).           //TODO
   jsonProdutos:ADD("unidade_nome","Unidade"). //TODO
   jsonProdutos:ADD("ncm",ITEM.class-fiscal). //STRING(classif-fisc.cod-ncm)).
   jsonProdutos:ADD("peso_liquido",(PESO_LIQUIDO)).
   jsonProdutos:ADD("peso_bruto",(PESO_BRUTO)).
   jsonProdutos:ADD("fator_embalagem",(1)).
   jsonProdutos:ADD("temp_min",TEMP_MIN).
   jsonProdutos:ADD("temp_max",TEMP_MAX).
   jsonProdutos:ADD("situacao_produto",(IF ITEM.cod-obsoleto = 1 THEN 1 ELSE 2)).
   jsonProdutos:ADD("status",(IF ITEM.cod-obsoleto = 1 THEN TRUE ELSE FALSE)).
   jsonProdutos:ADD("qtd_pallet",(PALLET)).
   jsonProdutos:ADD("qtd_caixa",(QUANTIDADE)).
   jsonProdutos:ADD("altura",(ALTURA)).
   jsonProdutos:ADD("largura",(LARGURA)).
   jsonProdutos:ADD("profundidade",(PROFUNDIDADE)).
   jsonProdutos:ADD("peso",(PESO_LIQUIDO)).
   
   jsonObj = NEW JsonObject().
   jsonObj:ADD("ean",item-mat.cod-ean).
   jsonObj:ADD("quantidade",1). //TODO
   jsonDetailEAN:ADD(jsonObj).

   jsonObj = NEW JsonObject().
   jsonObj:ADD("dun"," "). //jsonObj:ADD("dun",item-mat.cod-ean). //Retirado por solicita‡Æo do Pedro   
   jsonObj:ADD("quantidade",1). //TODO 
   jsonDetailDUN:ADD(jsonObj).

   jsonObj = NEW JsonObject().
   jsonObj:ADD("id","0"). //TODO
   jsonObj:ADD("altura",(ALTURA)).
   jsonObj:ADD("largura",(LARGURA)).
   jsonObj:ADD("profundidade",(PROFUNDIDADE)).
   jsonObj:ADD("peso",(PESO_LIQUIDO)).
   jsonEspecific:ADD(jsonObj).

   jsonProdutos:ADD("EANs",jsonDetailEAN).
   jsonProdutos:ADD("DUNs",jsonDetailDUN). //Retirado por solicita‡Æo do Pedro
   jsonProdutos:ADD("especificacoes",jsonEspecific).
   jsonBody:ADD("produtos",jsonProdutos).
   
   PUT UNFORMAT "- Gerado objeto JSON" SKIP.
END PROCEDURE.

// ==================================================================================================================================================================
