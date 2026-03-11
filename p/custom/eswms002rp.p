USING Progress.Json.ObjectModel.*.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}
//{include/i_trddef.i}

// ==================================================================================================================================================================

DEF VAR jsonBody      AS JsonObject NO-UNDO.
DEF VAR jsonCliente   AS JsonObject NO-UNDO.
DEF VAR jsonClientes  AS JsonArray  NO-UNDO.

DEF VAR EstaOK     AS LOGICAL.
DEF VAR Token      AS CHAR.
DEF VAR retornoAPI AS CHAR.
DEF VAR h-acomp    AS HANDLE NO-UNDO.

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

RUN pi-inicializar IN h-acomp (INPUT "Processando registros de Clientes/Fornecedores...").

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
                       
       FIND FIRST integra-emitente WHERE integra-emitente.cod-emitente = emitente.cod-emitente 
                                     AND integra-emitente.situacao  = 1
                                     NO-LOCK NO-ERROR.
                                 
       IF AVAIL integra-emitente THEN NEXT.
       
       RUN pi-acompanhar IN h-acomp (INPUT "Criando inegra‡Æo para o emitente " + emitente.nome-abrev).
                       
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
       
       CREATE integra-emitente.
       ASSIGN integra-emitente.cod-emitente = emitente.cod-emitente
              integra-emitente.dt-alteracao       = NOW
              integra-emitente.situacao  = 1.
       
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

FOR EACH integra-emitente WHERE integra-emitente.situacao = 1 EXCLUSIVE-LOCK.
                        
    FIND FIRST ems2mult.emitente WHERE emitente.cod-emitente = integra-emitente.cod-emitente NO-LOCK NO-ERROR.
    IF NOT AVAIL emitente THEN NEXT.
    
    RUN pi-acompanhar IN h-acomp (INPUT "Integrando emitente " + emitente.nome-abrev).
    
    PUT UNFORMAT "Emitente: " + emitente.nome-abrev + " (" + STRING(emitente.cod-emitente) + ")" SKIP.
    
    EstaOK = FALSE.
    RUN processarObjetosJSON. 
    IF EstaOK = TRUE THEN RUN enviarJSON.    
    
    ASSIGN integra-emitente.dt-alteracao       = NOW
           integra-emitente.retorno-integracao = retornoAPI.
    
    IF NOT EstaOK THEN ASSIGN integra-emitente.situacao = 3.
    ELSE ASSIGN integra-emitente.situacao = 2.
    
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
           oURI:Path   = '/datasul/pub/entidades'.
           
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
    
    IF oResponse:statuscode >= 200 AND oResponse:statuscode < 300 THEN DO:
       PUT UNFORMAT "- JSON integrado com sucesso." SKIP(1).
       EstaOK = TRUE.
       retornoAPI = STRING(oResponse:Entity).
       /*oJsonResponse = CAST(oResponse:Entity, JsonObject).
       retornoAPI = STRING(oJsonResponse:GetJsonText("detail")).*/
    END.
    ELSE DO:
       PUT UNFORMAT "- JSON integrado com falha." SKIP(1).
       EstaOK = FALSE.
       oJsonResponse = CAST(oResponse:Entity, JsonObject).
       retornoAPI = STRING(oJsonResponse:GetJsonText()).
    END.    
END PROCEDURE.

// ==================================================================================================================================================================

PROCEDURE processarObjetosJSON.
   DEF VAR email AS CHAR.
   
   jsonBody      = NEW JsonObject().
   jsonCliente   = NEW JsonObject().
   jsonClientes  = NEW JsonArray().
   
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
   
   jsonCliente:ADD("id",emitente.cod-emitente). 
   jsonCliente:ADD("origem","datasul"). 
   jsonCliente:ADD("codigo",STRING(emitente.cod-emitente)).
   jsonCliente:ADD("entidade_tipo_id",(IF emitente.identific = 1 THEN "C" ELSE IF emitente.identific = 2 THEN "F" ELSE "A")).
   jsonCliente:ADD("base_origem",1).
   jsonCliente:ADD("tipo",(IF emitente.natureza = 1 THEN "PF" ELSE "PJ")).
   jsonCliente:ADD("classificacao_id",(IF emitente.natureza = 1 THEN 2 ELSE 4)).
   jsonCliente:ADD("cpf_cnpj",emitente.cgc).
   jsonCliente:ADD("cgc",emitente.cgc).
   jsonCliente:ADD("nome_fantasia",(IF TRIM(emitente.nom-fantasia) <> "" THEN emitente.nom-fantasia ELSE emitente.nome-emit)).
   jsonCliente:ADD("razao_social",emitente.nome-emit).

   IF NUM-ENTRIES(emitente.telefone[1],")") = 2 THEN DO:
       jsonCliente:ADD("ddd_fone1",REPLACE(ENTRY(1,emitente.telefone[1],")"),"(","")).
       jsonCliente:ADD("telefone1",TRIM(ENTRY(2,emitente.telefone[1],")"))).  
    END.
    ELSE DO:
       jsonCliente:ADD("ddd_fone1","").
       jsonCliente:ADD("telefone1","").  
    END.
   
   jsonCliente:ADD("inscricao_estadual",emitente.ins-estadual).
   jsonCliente:ADD("cidade_id",0). //emitente.cidade).
   jsonCliente:ADD("cidade_nome",emitente.cidade).
   jsonCliente:ADD("cod_ibge",cidade.cdn-munpio-ibge).
   jsonCliente:ADD("estado_sigla",emitente.estado).
   jsonCliente:ADD("endereco_logradouro",emitente.endereco).
   jsonCliente:ADD("endereco_bairro",emitente.bairro).
   jsonCliente:ADD("endereco_numero",0).
   jsonCliente:ADD("endereco_cep",emitente.cep).
   jsonCliente:ADD("pais",emitente.pais).
   jsonCliente:ADD("tipo_endereco","énico").
   jsonCliente:ADD("tipo_cliente_id",0).    //TODO
   jsonCliente:ADD("tipo_cliente_nome",""). //TODO
   jsonCliente:ADD("regiao_id",0).          //TODO
   jsonCliente:ADD("regiao_nome","").       //TODO
   jsonCliente:ADD("representante_id",emitente.cod-rep).
   jsonCliente:ADD("is_consumidor",FALSE).          //TODO
   jsonCliente:ADD("is_simples_nacional","N").    //TODO
   
   email = emitente.e-mail.
   IF LENGTH(TRIM(email)) = 0 THEN email = "cliente@sem-email.com".
   
   jsonCliente:ADD("email_financeiro",email).
   jsonCliente:ADD("email_conta",email).
   jsonCliente:ADD("email_direcao",email).
   jsonCliente:ADD("status",(IF emitente.ind-sit-emit = 1 THEN TRUE ELSE FALSE)).
   jsonCliente:ADD("data_cadastro",NOW).
   jsonCliente:ADD("data_atualizacao",NOW).
   
   jsonClientes:ADD(jsonCliente).
   jsonBody:ADD("clientes_fornecedores",jsonClientes).
   
   PUT UNFORMAT "- Criado objeto JSON" SKIP.
   
   EstaOK = TRUE.
END PROCEDURE.

// ==================================================================================================================================================================
