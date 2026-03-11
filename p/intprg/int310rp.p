USING Progress.Lang.*.

USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.

USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.

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

DEF VAR jsonBody      AS JsonObject NO-UNDO.
DEF VAR jsonFornec   AS JsonObject NO-UNDO.
DEF VAR jsonFornecedores  AS JsonArray  NO-UNDO.

DEF VAR EstaOK     AS LOGICAL.
DEF VAR Token      AS CHAR.
DEF VAR retornoAPI AS CHAR.
DEF VAR h-acomp    AS HANDLE NO-UNDO.
DEFINE VARIABLE c-token   AS CHARACTER     NO-UNDO.

DEF BUFFER cidade FOR ems2dis.cidade.

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino            AS INTEGER
    FIELD arquivo            AS CHAR FORMAT "x(35)":U
    FIELD usuario            AS CHAR FORMAT "x(12)":U
    FIELD data-exec          AS DATE
    FIELD hora-exec          AS INTEGER
    FIELD classifica         AS INTEGER
    FIELD desc-classifica    AS CHAR FORMAT "x(40)":U
    FIELD modelo             AS CHAR FORMAT "x(35)":U
    FIELD l-habilitaRtf      as LOG
    FIELD Situacao           AS INTEGER //0 = Todos, 1 = Somente alterados
    FIELD Tipo               AS INTEGER //0 = Todos, 1 = Cliente, 2 = Forncededor
    FIELD CodClienteFinal    AS INTEGER
    FIELD CodClienteInicial  AS INTEGER
    FIELD DocFinal           AS CHAR
    FIELD DocInicial         AS CHAR
    FIELD GrupoFinal         AS INTEGER
    FIELD GrupoInicial       AS INTEGER
    FIELD NomeAbrevFinal     AS CHAR
    FIELD NomeAbrevInicial   AS CHAR.

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

RUN pi-inicializar IN h-acomp (INPUT "Processando registros de Fornecedores...").

OUTPUT TO VALUE(tt-param.arquivo) NO-CONVERT.

IF tt-param.situacao = 0 THEN DO:
   FOR EACH ems2mult.emitente WHERE emitente.cod-emitente >= tt-param.CodClienteInicial
                       AND emitente.cod-emitente <= tt-param.CodClienteFinal
                       AND emitente.nome-abrev   >= tt-param.NomeAbrevInicial
                       AND emitente.nome-abrev   <= tt-param.NomeAbrevFinal
                       AND emitente.cgc          >= tt-param.DocInicial
                       AND emitente.cgc          <= tt-param.DocFinal
                       AND (IF tt-param.tipo = 0 THEN TRUE ELSE (emitente.identific = tt-param.tipo OR emitente.identific = 3))
                       NO-LOCK:
                       
       FIND FIRST integra-fornecedor WHERE integra-fornecedor.cod-emitente = emitente.cod-emitente 
                                     AND integra-fornecedor.situacao  = 1
                                     NO-LOCK NO-ERROR.
                                 
       IF AVAIL integra-fornecedor THEN NEXT.
       
       RUN pi-acompanhar IN h-acomp (INPUT "Criando integra‡Æo para o emitente " + emitente.nome-abrev).
                       
       IF emitente.identific = 1 THEN DO: //Cliente
          IF (emitente.cod-gr-cli  >= tt-param.GrupoInicial AND emitente.cod-gr-cli  <= tt-param.GrupoFinal) = FALSE THEN NEXT.
       END.
       ELSE IF emitente.identific = 2 THEN DO: //Fornecedor
          IF (emitente.cod-gr-forn >= tt-param.GrupoInicial AND emitente.cod-gr-forn <= tt-param.GrupoFinal) = FALSE THEN NEXT.
       END.
       ELSE IF emitente.identific = 3 THEN DO: //Ambos
           IF (emitente.cod-gr-forn >= tt-param.GrupoInicial AND emitente.cod-gr-forn <= tt-param.GrupoFinal) = FALSE
          AND (emitente.cod-gr-cli  >= tt-param.GrupoInicial AND emitente.cod-gr-cli  <= tt-param.GrupoFinal) = FALSE THEN NEXT.
       END.
       
       CREATE integra-fornecedor.
       ASSIGN integra-fornecedor.cod-emitente = emitente.cod-emitente
              integra-fornecedor.nome-abrev   = emitente.nome-abrev
              integra-fornecedor.situacao     = 1.
       
   END.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Obtendo Token...").

RUN getToken.

IF Token = "" THEN DO:
   PUT UNFORMAT retornoAPI.
   run pi-finalizar in h-acomp.
   RETURN.
END. 

RUN pi-acompanhar IN h-acomp (INPUT "Integrando emitentes...").

FOR EACH integra-fornecedor WHERE integra-fornecedor.situacao = 1 EXCLUSIVE-LOCK.
                        
    FIND FIRST ems2mult.emitente WHERE emitente.cod-emitente = integra-fornecedor.cod-emitente NO-LOCK NO-ERROR.
    IF NOT AVAIL emitente THEN NEXT.
    
    RUN pi-acompanhar IN h-acomp (INPUT "Integrando emitente " + emitente.nome-abrev).
    
    PUT UNFORMAT "Emitente: " + emitente.nome-abrev + " (" + STRING(emitente.cod-emitente) + ")" SKIP.
    
    EstaOK = FALSE.
    RUN processarObjetosJSON. 
    IF EstaOK = TRUE THEN RUN enviarJSON.    
    
    //ASSIGN integra-fornecedor.nome-abrev         = NOW                 //colocar aqui o envio e o retorno.
           //integra-fornecedor.retorno-integracao = retornoAPI.
    
    IF NOT EstaOK THEN ASSIGN integra-fornecedor.situacao = 3.
    ELSE ASSIGN integra-fornecedor.situacao = 2.
    
END.  
    
OUTPUT CLOSE.

run pi-finalizar in h-acomp.
h-acomp = ?.

// ==================================================================================================================================================================

PROCEDURE getToken.
    DEF VAR chHttp        AS COM-HANDLE        NO-UNDO .
    DEF VAR cHost         AS CHARACTER         NO-UNDO INIT "https://datahub-api-production-97903554824.us-east1.run.app/auth/token".  //https://datahub-api.nisseilabs.com.br/auth/tokenvv
    DEF VAR oJsonResponse AS JsonObject        NO-UNDO.
    DEF VAR myParser      AS ObjectModelParser NO-UNDO. 
    
    .MESSAGE "DENTRO TOKEN"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    chHttp:SEND("username=datasul&password=lnb0uD8xbWLS1t").  

    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).
    
    IF oJsonResponse:has("access_token") THEN DO: 
       EstaOK = TRUE.
       ASSIGN Token = oJsonResponse:GetCharacter("access_token").
       //ASSIGN p-token = oJsonResponse:GetCharacter("access_token").
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
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://datahub-api-production-97903554824.us-east1.run.app") //https://datahub-api.nisseilabs.com.br
           oURI:Path   = '/datasul/pub/entidades'.
           
    .MESSAGE "EnviarJSon"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.

    oRequest  = RequestBuilder:POST(oURI, jsonBody)
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + Token)
                :Request.
                
    //jsonBody:WriteFile("U:\KML\Envio_fornec.json").
        
    oClient = ClientBuilder:Build():UsingLibrary(oLib):Client.
            
    oResponse = oClient:Execute(oRequest).
    
   
    
    .MESSAGE "NOVA" SKIP
            oResponse:statuscode  SKIP
            oResponse:Entity      
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    IF oResponse:statuscode >= 200 AND oResponse:statuscode < 300 THEN DO:
       PUT UNFORMAT "- JSON integrado com sucesso." SKIP(1).
       EstaOK = TRUE.
       retornoAPI = STRING(oResponse:Entity).
       
       IF retornoAPI MATCHES "*JsonObject*" THEN DO:
       
        oJsonResponse = CAST(oResponse:Entity, JsonObject).
        //oJsonResponse:WriteFile("U:\KML\Envio_fornec.json") NO-ERROR.
        retornoAPI = STRING(oJsonResponse:GetJsonText()).
       END.
       
       
       
    END.
    ELSE DO:
       PUT UNFORMAT "- JSON integrado com falha." SKIP(1).
       EstaOK = FALSE.
       oJsonResponse = CAST(oResponse:Entity, JsonObject).
       
       //oJsonResponse:WriteFile("U:\KML\Envio_fornec.json") NO-ERROR.
       
       retornoAPI = STRING(oJsonResponse:GetJsonText()).
       
       
    END.    
END PROCEDURE.

// ==================================================================================================================================================================

PROCEDURE processarObjetosJSON.
   DEF VAR email AS CHAR.
   
   jsonBody      = NEW JsonObject().
   jsonFornec    = NEW JsonObject().
   jsonFornecedores  = NEW JsonArray().
   
   FIND FIRST cidade WHERE cidade.cidade = ems2mult.emitente.cidade
                       AND cidade.estado = emitente.estado
                       AND cidade.pais   = emitente.pais
                       NO-LOCK NO-ERROR.
                       
   IF NOT AVAIL cidade THEN DO:
      EstaOK = FALSE.
      retornoAPI = "Cidade nÆo encontrada no cadastro de cidades".
      PUT UNFORMAT "- Cidade " + emitente.cidade + " nÆo encontrada no cadastro de cidades".
      RETURN.
   END.
   
   jsonFornec:ADD("codigo",emitente.cod-emitente). 
   jsonFornec:ADD("nome",(IF TRIM(emitente.nom-fantasia) <> "" THEN emitente.nom-fantasia ELSE emitente.nome-emit)). 
   jsonFornec:ADD("nome_abreviado",emitente.nome-abrev).
   jsonFornec:ADD("cnpj",emitente.cgc).
   jsonFornec:ADD("inscricao_estadual",emitente.ins-estadual).
   jsonFornec:ADD("cep",emitente.cep).
   jsonFornec:ADD("endereco",emitente.endereco).
   jsonFornec:ADD("bairro",emitente.bairro).
   jsonFornec:ADD("cidade",emitente.cidade).
   jsonFornec:ADD("estado",emitente.estado).
   
   email = emitente.e-mail.
   IF LENGTH(TRIM(email)) = 0 THEN email = "cliente@sem-email.com".
   jsonFornec:ADD("email",email).
   
   //jsonFornec:ADD("razao_social",emitente.nome-emit).
   
   IF NUM-ENTRIES(emitente.telefone[1],")") = 2 THEN DO:
       jsonFornec:ADD("telefone",TRIM(ENTRY(2,emitente.telefone[1],")"))).  
    END.
    ELSE DO:
       jsonFornec:ADD("telefone","").  
    END.
    
   
   jsonFornec:ADD("simples_nacional",IF SUBSTRING(emitente.char-1,133,1) = "S" THEN TRUE ELSE FALSE).
   jsonFornec:ADD("contribuinte_icms",IF emitente.contrib-icms = YES THEN TRUE ELSE FALSE).
   jsonFornec:ADD("aplica_ipi_base_icms_st",FALSE). //de onde pegar?.
   jsonFornec:ADD("aplica_ipi_base_icms_st_excecao",FALSE). //de onde pegar?.
   jsonFornec:ADD("emite_devolucao",FALSE).
   jsonFornec:ADD("exige_protocolo_devolucao",FALSE).
   jsonFornec:ADD("tipo_entidade_id",emitente.cod-gr-forn).
   jsonFornec:ADD("tipo_entidade","teste").
   jsonFornec:ADD("data_atualizacao", NOW).
   jsonFornec:ADD("status", TRUE).
      
   jsonFornecedores:ADD(jsonFornec).
   jsonBody:ADD("entidades",jsonFornecedores).
   
   PUT UNFORMAT "- Criado objeto JSON" SKIP.
   
   EstaOK = TRUE.
   
   
END PROCEDURE.

// ==================================================================================================================================================================
