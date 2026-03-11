&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

USING Progress.Json.*.
USING Progress.Json.ObjectModel.*.
USING com.totvs.framework.api.*.
USING Progress.Lang.Object.

USING OpenEdge.Core.WidgetHandle.
USING OpenEdge.Core.String.
USING OpenEdge.Core.*.
USING OpenEdge.Core.Collections.IStringStringMap.
USING OpenEdge.Core.Collections.StringStringMap.

USING OpenEdge.Net.HTTP.IHttpClientLibrary.
USING OpenEdge.Net.HTTP.ConfigBuilder.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.Credentials.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.ResponseBuilder.
USING OpenEdge.Net.HTTP.Cookie.
USING OpenEdge.Net.HTTP.CookieJarBuilder.
USING OpenEdge.Net.HTTP.ICookieJar.
USING OpenEdge.Net.HTTP.IHttpResponse.

USING OpenEdge.Net.URI.

{method/dbotterr.i}

DEF TEMP-TABLE ttHeader NO-UNDO
    FIELD Seq   AS i
    FIELD Chave AS c
    FIELD Valor AS c
    INDEX i Seq.

DEF BUFFER bf-api-log FOR es-api-log.
DEF BUFFER bf-api-aux FOR es-api-aux.

DEF VAR client      AS COM-HANDLE NO-UNDO.
DEF VAR lcEnvio     AS LONGCHAR   NO-UNDO.
DEF VAR cLongJson   AS LONGCHAR   NO-UNDO.
DEF VAR i           AS i          NO-UNDO.
DEF VAR c-endereco  AS c          NO-UNDO.

DEF VAR iErro       AS i          NO-UNDO.

DEF VAR cArquivoRec AS c          NO-UNDO.

ASSIGN 
   cArquivoRec = SESSION:TEMP-DIRECTORY 
               + "RECAPI-"
               + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(STRING(NOW),":","")," ",""),",",""),"-",""),"/","")
               + STRING(RANDOM(1,1000),"9999")
               + ".tmp".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-chamada-1 Include 
FUNCTION fc-chamada-1 RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-chamada-2 Include 
FUNCTION fc-chamada-2 RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-chamada-3 Include 
FUNCTION fc-chamada-3 RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-chamada-4 Include 
FUNCTION fc-chamada-4 RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-oauth-1 Include 
FUNCTION fc-oauth-1 RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Include
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: INCLUDE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Include 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-request Include 
PROCEDURE pi-cria-request :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-las-api-log FOR es-api-log.
   DEF BUFFER bf-new-api-log FOR es-api-log.

   DEF  INPUT PARAM cIDAplicacao LIKE es-api-log.id-aplicacao NO-UNDO.
   DEF  INPUT PARAM cIDCodigo    LIKE es-api-log.id-codigo    NO-UNDO.
   DEF  INPUT PARAM cURI         AS c                         NO-UNDO.
   DEF  INPUT PARAM cCod         AS c                         NO-UNDO.
   DEF  INPUT PARAM cJson        AS c                         NO-UNDO.
   DEF OUTPUT PARAM rwRec        AS ROWID                     NO-UNDO.

   FIND LAST bf-las-api-log NO-LOCK
       WHERE bf-las-api-log.id-api-log > 0
       NO-ERROR.
   CREATE bf-new-api-log.
   ASSIGN
      bf-new-api-log.seqexec        = es-api-log.seqexec     
      bf-new-api-log.id-aplicacao   = es-api-log.id-aplicacao
      bf-new-api-log.id-codigo      = es-api-log.id-codigo   
      bf-new-api-log.id-URI         = cURI
      bf-new-api-log.dh-request     = NOW
      bf-new-api-log.flg-processado = NO
      bf-new-api-log.Origem         = "REQUEST"
      bf-new-api-log.aux            = cCod
      bf-new-api-log.cJSON          = cJson
      .

   IF NOT AVAIL bf-las-api-log 
   THEN ASSIGN
      bf-new-api-log.id-api-log = 1.
   ELSE ASSIGN
      bf-new-api-log.id-api-log = bf-las-api-log.id-api-log + 1.

   ASSIGN
      rwRec = ROWID(bf-new-api-log).

   RELEASE bf-new-api-log.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-exec-request Include 
PROCEDURE pi-exec-request :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF INPUT PARAM h-acomp AS HANDLE NO-UNDO.
   DEF INPUT PARAM iExec   AS i      NO-UNDO.
   DEF INPUT PARAM rwRec   AS ROWID  NO-UNDO.

   FOR FIRST es-api-log NO-LOCK
       WHERE ROWID(es-api-log)      = rwREc,
       FIRST es-api-URI NO-LOCK
          OF es-api-log
       WHERE es-api-URI.ativo       = YES
         AND es-api-URI.flg-batch   = NO,
       FIRST es-api-empresa NO-LOCK
          OF es-api-log
       WHERE es-api-empresa.ativo   = YES,
       FIRST es-api-aplicacao NO-LOCK
          OF es-api-log
       WHERE es-api-aplicacao.ativo = YES:
      RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                              iExec,
                                              ROWID(es-api-log)).
      RETURN RETURN-VALUE.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-input-api-headers Include 
PROCEDURE pi-input-api-headers :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF INPUT PARAM jsonInput      AS JsonObject           NO-UNDO.
   DEF         VAR jsonOutput     AS JsonObject           NO-UNDO.
   DEF         VAR lcOutput       AS LONGCHAR             NO-UNDO.
   DEF         VAR oHeaders       AS JsonObject           NO-UNDO.
   DEF         VAR oQueryParams   AS JsonObject           NO-UNDO.
   DEF         VAR oRequestParser AS JsonAPIRequestParser NO-UNDO.

   oRequestParser = NEW JsonAPIRequestParser(JsonInput).

   ASSIGN 
      oHeaders     = oRequestParser:getHeaders()
      oQueryParams = oRequestParser:getQueryParams().

   IF oHeaders:Has("content-type")
   THEN ASSIGN 
      es-api-log.envio-content-type = oHeaders:GetCharacter("content-type") 
      NO-ERROR.  

   oHeaders:WRITE (INPUT-OUTPUT lcOutput, INPUT YES, INPUT "UTF-8").
   ASSIGN
      es-api-log.envio-headers = lcOutput.

   oQueryParams:WRITE (INPUT-OUTPUT lcOutput, INPUT YES, INPUT "UTF-8").
   ASSIGN
      es-api-log.envio-params  = lcOutput.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-input-erro Include 
PROCEDURE pi-input-erro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF INPUT PARAM rw-registro AS ROWID NO-UNDO.
   DEF BUFFER bf-api-log FOR es-api-log.
   DEF BUFFER bf-api-aux FOR es-api-aux.
   IF  TEMP-TABLE RowErrors:HAS-RECORDS
   THEN DO:
      FIND FIRST bf-api-log NO-LOCK
           WHERE ROWID(bf-api-log) = rw-registro 
           NO-ERROR.
      FOR EACH RowErrors:
         FIND LAST bf-api-aux NO-LOCK
             WHERE bf-api-aux.id-api-log = bf-api-log.id-api-log
               AND bf-api-aux.Seq        > 0
             NO-ERROR.
         CREATE es-api-aux.
         ASSIGN
            es-api-aux.id-api-log = bf-api-log.id-api-log
            es-api-aux.Seq        = (IF AVAIL bf-api-aux
                                     THEN bf-api-aux.seq + 1
                                     ELSE 1)
            es-api-aux.Tipo       = "RowErrors"
            es-api-aux.dh-exec    = NOW.
         RAW-TRANSFER RowErrors TO es-api-aux.raw-aux.
      END.
   END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-term-request Include 
PROCEDURE pi-term-request :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piErro Include 
PROCEDURE piErro :
DEF INPUT PARAM cErrorDescription AS c NO-UNDO.
    DEF INPUT PARAM cErrorHelp        AS c NO-UNDO.
    CREATE RowErrors.
    ASSIGN
        iErro            = iErro + 1
        ErrorSequence    = iErro
        ErrorNumber      = 17006
        ErrorType        = "Error"
        ErrorDescription = cErrorDescription
        ErrorHelp        = cErrorHelp       .
    MESSAGE  "** ERR " cErrorDescription + " " + cErrorHelp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piHeader Include 
PROCEDURE piHeader :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF INPUT PARAM iSeq   AS i NO-UNDO.
   DEF INPUT PARAM cChave AS c NO-UNDO.
   DEF INPUT PARAM cValor AS c NO-UNDO.
   CREATE ttHeader.
   ASSIGN
      ttHeader.Seq   = iSeq  
      ttHeader.Chave = cChave
      ttHeader.Valor = cValor
      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-chamada-1 Include 
FUNCTION fc-chamada-1 RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  Chamada JSON com classes do Progress
    Notes:  
------------------------------------------------------------------------------*/
   DEF VAR JsonString     AS LONGCHAR                      NO-UNDO.
   DEF VAR oRequest       as IHttpRequest                  NO-UNDO.
   DEF VAR oResponse      as IHttpResponse                 NO-UNDO.
   DEF VAR oJsonObject    AS JsonObject                    NO-UNDO.
   DEF VAR oJsonEntity    AS JsonArray                     NO-UNDO.
   DEF VAR oClient        AS IHttpClient                   NO-UNDO.
   DEF VAR myLongchar     AS LONGCHAR                      NO-UNDO.
   DEF VAR myParser       AS ObjectModelParser             NO-UNDO.
   DEF VAR Json           AS JsonObject                    NO-UNDO.

   DEF VAR i-header       AS i                             NO-UNDO.
   DEF VAR cChave         AS c EXTENT 3                    NO-UNDO.
   DEF VAR cValor         AS c EXTENT 3                    NO-UNDO.

   PUT UNFORMATTED SKIP(2) ">> Chamada 1".

   IF es-api-log.cJSON > ""
   THEN DO:
      CLIPBOARD:VALUE = es-api-log.cJSON.
   
      myLongchar = es-api-log.cJSON.
      myLongchar = CODEPAGE-CONVERT(myLongchar, "UTF-8":U).
   
      ASSIGN
         es-api-log.cl-envio = myLongchar.
   
      myParser = NEW ObjectModelParser().
   
      Json = CAST(myParser:Parse(myLongchar), JsonObject).
   END.

   FOR EACH ttHeader
         BY ttHeader.Seq:
      ASSIGN
         i-header         = i-header + 1
         cChave[i-header] = ttHeader.Chave
         cValor[i-header] = ttHeader.Valor.
      IF i-header = 3
      THEN LEAVE.
   END.

   IF es-api-URI.metodo = "POST" 
   THEN DO: 
      IF i-header = 0
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, Json)
                                  :ContentType('application/json')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 1
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, Json)
                                  :AddHeader(cChave[1],cValor[1])
                                  :ContentType('application/json')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 2
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, Json)
                                  :AddHeader(cChave[1],cValor[1])
                                  :AddHeader(cChave[2],cValor[2])
                                  :ContentType('application/json')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 3
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, Json)
                                  :AddHeader(cChave[1],cValor[1])
                                  :AddHeader(cChave[2],cValor[2])
                                  :AddHeader(cChave[3],cValor[3])
                                  :ContentType('application/json')
                                  :AcceptJson()
                                  :Request.
      END.
   END.

   IF es-api-URI.metodo = "PUT" 
   THEN DO:
      oRequest = RequestBuilder:PUT(c-endereco, Json)
                               :ContentType('application/json')
                               :AcceptJson()
                               :Request.
   END.

   IF es-api-URI.metodo = "DELETE" 
   THEN DO:
      oRequest = RequestBuilder:DELETE(c-endereco)
//                               :ContentType('application/json')
                               :AcceptJson()
                               :Request.
   END.

   oResponse = ClientBuilder:Build():Client:EXECUTE(oRequest) NO-ERROR.

   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
   END.

   /*
   MESSAGE 
       oResponse:StatusCode SKIP
       oResponse:StatusReason SKIP
       oResponse:ContentLength SKIP
       oResponse:ContentType SKIP
//       oResponse:HEADER
       oResponse:Entity
       VIEW-AS ALERT-BOX.
   */

   CASE TRUE:
       WHEN TYPE-OF(oResponse:Entity, JsonArray) 
       THEN DO:
          //MESSAGE 11 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //oJsonEntity = CAST(oResponse:Entity, JsonArray).                
          //oJsonObject:ADD("retorno",oJsonEntity).
          //JsonString = string(oJsonObject:getJsonText()).
       END.
       WHEN TYPE-OF(oResponse:Entity, JsonObject) 
       THEN DO:
          //MESSAGE 12 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          oJsonObject = CAST(oResponse:Entity, JsonObject). 
          JsonString = STRING(oJsonObject:getJsonText()).
          //oJsonObject = CAST(oResponse:Entity, JsonObject). 
          //JsonString = STRING(oJsonObject:getJsonText()).
       END.
       WHEN TYPE-OF(oResponse:Entity, String) 
       THEN DO:
          //MESSAGE 14 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       END.
       WHEN TYPE-OF(oResponse:Entity, JsonConstruct) 
       THEN DO:
          //MESSAGE 15 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //CAST(oResponse:Entity, JsonConstruct):WriteFile('c:\ob1\temp\entity.json', true).
       END.
       WHEN TYPE-OF(oResponse:Entity, String) 
       THEN DO:
          //MESSAGE 16 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, String):Value.
       END.
       WHEN TYPE-OF(oResponse:Entity, Memptr) 
       THEN DO:
          //MESSAGE 15 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, Memptr):GetString(1).
       END.
       WHEN TYPE-OF(oResponse:Entity, ByteBucket) 
       THEN DO:
          //MESSAGE 16 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, ByteBucket):GetString().
       END.
       OTHERWISE  DO:
           //MESSAGE 17 //oResponse:Entity:ToString() VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
           //lcHTML = oResponse:Entity:ToString().
       END.
   END CASE.

   /*
   IF INDEX(JsonString,'"Status":false') > 0 
   THEN DO:
      IF LOOKUP("Description",JsonString,'"') > 0 
      THEN RUN piErro (ENTRY(LOOKUP("Description",JsonString,'"') + 2,JsonString,'"'),"").
   END.
   */

   COPY-LOB JsonString TO es-api-log.cl-retorno.

   MESSAGE "***" STRING(JsonString).

   IF oResponse:StatusCode >= 300
   THEN DO:
      RUN piErro ("Ocorreram erros no envio - " + 
                  STRING(oResponse:statusCode)  + 
                  " - " + 
                  STRING(oResponse:StatusReason) + 
                  STRING(JsonString)
                  ,"").
   END.


   ASSIGN
//      es-api-log.retorno-headers      = oResponse:
      es-api-log.retorno-content-type = oResponse:ContentType 
      es-api-log.cod-retorno          = STRING(oResponse:StatusCode)
      es-api-log.dh-retorno           = NOW.

   RETURN es-api-log.cod-retorno.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-chamada-2 Include 
FUNCTION fc-chamada-2 RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  Chamada JSON com DLL Windows
    Notes:  
------------------------------------------------------------------------------*/
   DEFINE VARIABLE myLongchar  AS LONGCHAR          NO-UNDO.
   DEFINE VARIABLE myParser    AS ObjectModelParser NO-UNDO.
   DEFINE VARIABLE Json        AS JsonObject        NO-UNDO.
   DEF    VAR      cArqJson    AS c                 NO-UNDO.

   PUT UNFORMATTED SKIP(2) ">> Chamada 2" SKIP.

   CREATE "Msxml2.ServerXMLHTTP.6.0" client.

   IF es-api-log.cJSON > ""
   THEN DO:
      PUT UNFORMATTED "Envio >> " es-api-log.cJSON SKIP.

      myLongchar = es-api-log.cJSON.
      myLongchar = CODEPAGE-CONVERT(myLongchar, "UTF-8":U).
    
      myParser = NEW ObjectModelParser().
    
      Json = CAST(myParser:Parse(myLongchar), JsonObject).
    
      ASSIGN
         cArqJson = SESSION:TEMP-DIRECTORY 
                  + "send-json-" 
                  + "-"
                  + STRING(TIME)
                  + ".json".
    
      CAST(myParser:Parse(mylongchar),JsonObject):WriteFile(cArqJson, TRUE).
      COPY-LOB FILE cArqJson TO lcEnvio.
      OS-DELETE cArqJson.
      ASSIGN
         es-api-log.cl-envio = lcEnvio.
   END.

   client:OPEN(es-api-URI.metodo, c-endereco, FALSE) NO-ERROR.
   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         /*
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
         */
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
      STOP.
   END.

   FOR EACH ttHeader:
      client:SetRequestHeader (ttHeader.Chave, ttHeader.Valor).
      IF es-api-log.envio-headers = ""
      THEN ASSIGN
         es-api-log.retorno-headers = ttHeader.Chave
                                    + ": "
                                    + ttHeader.Valor.
      ELSE ASSIGN
         es-api-log.retorno-headers = chr(13)
                                    + ttHeader.Chave
                                    + ": "
                                    + ttHeader.Valor.
   END.

   ASSIGN
      es-api-log.envio-content-type = "application/json"
      es-api-log.end-envio          = c-endereco.
   

   IF es-api-log.cJSON > ""
   THEN DO:
      client:SetRequestHeader ("Content-Type", es-api-log.envio-content-type).
      client:SEND(lcEnvio) NO-ERROR. /**/
   END.
   ELSE client:SEND NO-ERROR. /**/
 
   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         /*
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
         */
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
      STOP.
   END.


   /*
   MESSAGE 
      'endereco'              c-endereco                               SKIP(1)
      'getAllResponseHeaders' client:getAllResponseHeaders             SKIP(1)
      'getResponseHeader'     client:getResponseHeader("Content-Type") SKIP(1)
      'ResponseBody  '        client:ResponseBody                      SKIP(1)
      'ResponseText  '        client:ResponseText                      SKIP(1)
      'Responsexml   '        client:ResponseXml                       SKIP(1)
      'responseStream'        client:responseStream                    SKIP(1)
      'STATUS        '        client:STATUS                            SKIP
       VIEW-AS ALERT-BOX TITLE "retorno".
   */

   IF client:getResponseHeader("Content-Type") = "application/pdf" 
   THEN COPY-LOB client:ResponseBody TO cLongJson CONVERT TARGET CODEPAGE 'UTF-8' NO-ERROR.
   ELSE DO:
      IF client:ResponseText <> "" AND client:ResponseText <>  ? 
      THEN DO:
         ASSIGN 
            cLongJson = CODEPAGE-CONVERT(cLongJson, "UTF-8":U)
            cLongJson = client:ResponseText
            
            .
         COPY-LOB cLongJson TO es-api-log.cl-retorno.
      END.
   END.

   COPY-LOB cLongJson TO es-api-log.cl-retorno.

   PUT UNFORMATTED                                                          SKIP(2)
      'Retorno'                                                             SKIP(1)
      'endereco               >> ' c-endereco                               SKIP(1)
      'getAllResponseHeaders  >> '                                          SKIP
                                   client:getAllResponseHeaders             SKIP(1)
      'getResponseHeader      >> ' client:getResponseHeader("Content-Type") SKIP(1)
      //'ResponseBody           >> ' client:ResponseBody                      SKIP(1)
      'ResponseText           >> ' client:ResponseText                      SKIP(1)
       SKIP(1)
       STRING(cLongJson)
       SKIP(1)
      'Responsexml            >> ' client:ResponseXml                       SKIP(1)
      'responseStream         >> ' client:responseStream                    SKIP(1)
      'STATUS                 >> ' client:STATUS                            SKIP(1).

 
   ASSIGN
      es-api-log.retorno-headers      = client:getAllResponseHeaders
      es-api-log.retorno-content-type = client:getResponseHeader("Content-Type") 

      es-api-log.cod-retorno          = client:STATUS
      es-api-log.dh-retorno           = NOW.
 
   RETURN es-api-log.cod-retorno.

END.




/*
   CREATE "Msxml2.ServerXMLHTTP.6.0" client.

   client:OPEN(es-api-URI.metodo, c-endereco, FALSE) NO-ERROR.

   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
      END.
      STOP.
   END.

   FOR EACH ttHeader:
      client:SetRequestHeader (ttHeader.Chave, ttHeader.Valor).
   END.
 
   client:SetRequestHeader ("Content-Type", "application/json").
   client:SEND(lcEnvio) NO-ERROR. /**/
 
   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
      END.
      STOP.
   END.

   /*
   MESSAGE 'Matches  '    client:ResponseText  MATCHES "*PDF*" SKIP(1)
           'getAllResponseHeaders' client:getAllResponseHeaders SKIP(1)
           'getResponseHeader' client:getResponseHeader("Content-Type") SKIP(1)
           'ResponseBody  '    client:ResponseBody   SKIP(1)
           'ResponseText  '    client:ResponseText   SKIP(1)
           'Responsexml   '    client:ResponseXml    SKIP(1)
           'responseStream'    client:responseStream SKIP(1)
           'STATUS        '    client:STATUS         SKIP
            VIEW-AS ALERT-BOX TITLE "retorno".
   */

   IF client:getResponseHeader("Content-Type") = "application/pdf" 
   THEN COPY-LOB client:ResponseBody TO cLongJson CONVERT TARGET CODEPAGE 'UTF-8' NO-ERROR.
   ELSE DO:
      IF client:ResponseText <> "" AND client:ResponseText <>  ? 
      THEN DO:
         ASSIGN 
            cLongJson = client:ResponseText
            cLongJson = CODEPAGE-CONVERT(cLongJson, "UTF-8":U)
            .
         COPY-LOB cLongJson TO es-api-log.cl-retorno.
      END.
   END.

   ASSIGN
      //es-api-log.retorno-headers      = client:getAllResponseHeaders
      //es-api-log.retorno-content-type = client:getResponseHeader("Content-Type") 

      es-api-log.cod-retorno          = client:STATUS
      es-api-log.dh-retorno           = NOW.

   MESSAGE "***" STRING(cLongJson).

   RETURN es-api-log.cod-retorno.


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-chamada-3 Include 
FUNCTION fc-chamada-3 RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  Chamada XML com classes do Progress
    Notes:  
------------------------------------------------------------------------------*/
   DEF VAR JsonString     AS LONGCHAR                      NO-UNDO.
   DEF VAR oRequest       as IHttpRequest                  NO-UNDO.
   DEF VAR oResponse      as IHttpResponse                 NO-UNDO.
   DEF VAR oJsonObject    AS JsonObject                    NO-UNDO.
   DEF VAR myLongchar     AS LONGCHAR                      NO-UNDO.
   DEF VAR hXmlDoc        AS HANDLE                        NO-UNDO.

   DEF VAR mData          AS MEMPTR                        NO-UNDO.
   DEF VAR oDocument      AS CLASS MEMPTR                  NO-UNDO.
   DEF VAR i-header       AS i                             NO-UNDO.
   DEF VAR cChave         AS c EXTENT 3                    NO-UNDO.
   DEF VAR cValor         AS c EXTENT 3                    NO-UNDO.

   PUT UNFORMATTED SKIP(2) ">> Chamada 3".

   IF es-api-log.cJSON > ""
   THEN DO:
      CLIPBOARD:VALUE = es-api-log.cJSON.
      myLongchar = es-api-log.cJSON.
      myLongchar = CODEPAGE-CONVERT(myLongchar, "UTF-8":U).
      ASSIGN
         es-api-log.cl-envio = myLongchar.
      CREATE X-DOCUMENT hXmlDoc.
      hXmlDoc:LOAD("LONGCHAR", myLongchar, FALSE).
      hXmlDoc:SAVE('MEMPTR', mData).
      oDocument = NEW MEMPTR(mData).
   END.

   FOR EACH ttHeader
         BY ttHeader.Seq:
      ASSIGN
         i-header         = i-header + 1
         cChave[i-header] = ttHeader.Chave
         cValor[i-header] = ttHeader.Valor.
      IF i-header = 3
      THEN LEAVE.
   END.

   IF es-api-URI.metodo = "POST" 
   THEN DO: 
      IF i-header = 0
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, oDocument)
                                  :ContentType('application/xml')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 1
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, oDocument)
                                  :AddHeader(cChave[1],cValor[1])
                                  :ContentType('application/xml')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 2
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, oDocument)
                                  :AddHeader(cChave[1],cValor[1])
                                  :AddHeader(cChave[2],cValor[2])
                                  :ContentType('application/xml')
                                  :AcceptJson()
                                  :Request.
      END.
      IF i-header = 3
      THEN DO:
         oRequest = RequestBuilder:Post(c-endereco, oDocument)
                                  :AddHeader(cChave[1],cValor[1])
                                  :AddHeader(cChave[2],cValor[2])
                                  :AddHeader(cChave[3],cValor[3])
                                  :ContentType('application/xml')
                                  :AcceptJson()
                                  :Request.
      END.
   END.

   IF es-api-URI.metodo = "PUT" 
   THEN DO:
      oRequest = RequestBuilder:PUT(c-endereco, oDocument)
                               :ContentType('application/xml')
                               :AcceptJson()
                               :Request.
   END.

   IF es-api-URI.metodo = "DELETE" 
   THEN DO:
      oRequest = RequestBuilder:DELETE(c-endereco)
//                               :ContentType('application/xml')
                               :AcceptJson()
                               :Request.
   END.

   oResponse = ClientBuilder:Build():Client:EXECUTE(oRequest) NO-ERROR.

   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
   END.

   /*
   MESSAGE 
       oResponse:StatusCode SKIP
       oResponse:StatusReason SKIP
       oResponse:ContentLength SKIP
       oResponse:ContentType SKIP
//       oResponse:HEADER
       oResponse:Entity
       VIEW-AS ALERT-BOX.
   */

   CASE TRUE:
       WHEN TYPE-OF(oResponse:Entity, JsonArray) 
       THEN DO:
          //MESSAGE 11 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //oJsonEntity = CAST(oResponse:Entity, JsonArray).                
          //oJsonObject:ADD("retorno",oJsonEntity).
          //JsonString = string(oJsonObject:getJsonText()).
       END.
       WHEN TYPE-OF(oResponse:Entity, JsonObject) 
       THEN DO:
          //MESSAGE 12 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          oJsonObject = CAST(oResponse:Entity, JsonObject). 
          JsonString = STRING(oJsonObject:getJsonText()).
          //oJsonObject = CAST(oResponse:Entity, JsonObject). 
          //JsonString = STRING(oJsonObject:getJsonText()).
       END.
       WHEN TYPE-OF(oResponse:Entity, String) 
       THEN DO:
          //MESSAGE 14 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
       END.
       WHEN TYPE-OF(oResponse:Entity, JsonConstruct) 
       THEN DO:
          //MESSAGE 15 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //CAST(oResponse:Entity, JsonConstruct):WriteFile('c:\ob1\temp\entity.json', true).
       END.
       WHEN TYPE-OF(oResponse:Entity, String) 
       THEN DO:
          //MESSAGE 16 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, String):Value.
       END.
       WHEN TYPE-OF(oResponse:Entity, Memptr) 
       THEN DO:
          //MESSAGE 15 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, Memptr):GetString(1).
       END.
       WHEN TYPE-OF(oResponse:Entity, ByteBucket) 
       THEN DO:
          //MESSAGE 16 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          //lcHTML = cast(oResponse:Entity, ByteBucket):GetString().
       END.
       OTHERWISE  DO:
           //MESSAGE 17 //oResponse:Entity:ToString() VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
           //lcHTML = oResponse:Entity:ToString().
       END.
   END CASE.

   /*
   IF INDEX(JsonString,'"Status":false') > 0 
   THEN DO:
      IF LOOKUP("Description",JsonString,'"') > 0 
      THEN RUN piErro (ENTRY(LOOKUP("Description",JsonString,'"') + 2,JsonString,'"'),"").
   END.
   */

   COPY-LOB JsonString TO es-api-log.cl-retorno.

   IF oResponse:StatusCode >= 300
   THEN DO:
      RUN piErro ("Ocorreram erros no envio - " + 
                  STRING(oResponse:statusCode)  + 
                  " - " + 
                  STRING(oResponse:StatusReason) + 
                  STRING(JsonString)
                  ,"").
   END.


   ASSIGN
//      es-api-log.retorno-headers      = oResponse:
      es-api-log.retorno-content-type = oResponse:ContentType 
      es-api-log.cod-retorno          = STRING(oResponse:StatusCode)
      es-api-log.dh-retorno           = NOW.

   RETURN es-api-log.cod-retorno.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-chamada-4 Include 
FUNCTION fc-chamada-4 RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  Chamada XML com DLL Windows
    Notes:  
------------------------------------------------------------------------------*/
   DEFINE VARIABLE myLongchar  AS LONGCHAR          NO-UNDO.

   PUT UNFORMATTED SKIP(2) ">> Chamada 4" SKIP.

   CREATE "Msxml2.ServerXMLHTTP.6.0" client.

   IF es-api-log.cJSON > ""
   THEN DO:
      //PUT UNFORMATTED "Envio >> " es-api-log.cJSON SKIP.
      myLongchar = es-api-log.cJSON.
      myLongchar = CODEPAGE-CONVERT(myLongchar, "UTF-8":U).
      ASSIGN
         es-api-log.cl-envio = es-api-log.cJSON.
   END.
   ELSE DO:
       myLongchar = es-api-log.cl-envio.
       myLongchar = CODEPAGE-CONVERT(myLongchar, "UTF-8":U).
   END.

   client:OPEN(es-api-URI.metodo, c-endereco, FALSE) NO-ERROR.
   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         /*
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
         */
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
      STOP.
   END.

   FOR EACH ttHeader:
      client:SetRequestHeader (ttHeader.Chave, ttHeader.Valor).
      IF es-api-log.envio-headers = ""
      THEN ASSIGN
         es-api-log.retorno-headers = ttHeader.Chave
                                    + ": "
                                    + ttHeader.Valor.
      ELSE ASSIGN
         es-api-log.retorno-headers = chr(13)
                                    + ttHeader.Chave
                                    + ": "
                                    + ttHeader.Valor.
   END.

   ASSIGN
      es-api-log.envio-content-type = "application/xml"
      es-api-log.end-envio          = c-endereco.

   IF myLongchar > ""
   THEN DO:
      client:SetRequestHeader ("Content-Type", es-api-log.envio-content-type).
      client:setTimeouts(15000,15000,15000,15000).
      client:SEND(myLongchar) NO-ERROR. /**/
   END.
   ELSE client:SEND NO-ERROR. /**/
 
   IF ERROR-STATUS:ERROR = YES 
   THEN DO:
      DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
         /*
         MESSAGE 
            "** Erro " 
            ERROR-STATUS:ERROR 
            " - "      
            ERROR-STATUS:GET-MESSAGE(i).
         */
         RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
      END.
      STOP.
   END.

   /*
   MESSAGE 
      'endereco'              c-endereco                               SKIP(1)
      'getAllResponseHeaders' client:getAllResponseHeaders             SKIP(1)
      'getResponseHeader'     client:getResponseHeader("Content-Type") SKIP(1)
      'ResponseBody  '        client:ResponseBody                      SKIP(1)
      'ResponseText  '        client:ResponseText                      SKIP(1)
      'Responsexml   '        client:ResponseXml                       SKIP(1)
      'responseStream'        client:responseStream                    SKIP(1)
      'STATUS        '        client:STATUS                            SKIP
       VIEW-AS ALERT-BOX TITLE "retorno".
   */

   IF client:getResponseHeader("Content-Type") = "application/pdf" 
   THEN COPY-LOB client:ResponseBody TO cLongJson CONVERT TARGET CODEPAGE 'UTF-8' NO-ERROR.
   ELSE DO:
      IF client:ResponseText <> "" AND client:ResponseText <>  ? 
      THEN DO:
         ASSIGN 
            cLongJson = CODEPAGE-CONVERT(cLongJson, "UTF-8":U)
            cLongJson = client:ResponseText
            .
         COPY-LOB cLongJson TO es-api-log.cl-retorno.
      END.
   END.

   //COPY-LOB cLongJson TO es-api-log.cl-retorno.

   PUT UNFORMATTED                                                          SKIP(2)
      'Retorno'                                                             SKIP(1)
      'endereco               >> ' c-endereco                               SKIP(1)
      //'getAllResponseHeaders  >> ' client:getAllResponseHeaders             SKIP(1)
      'getResponseHeader      >> ' client:getResponseHeader("Content-Type") SKIP(1)
      //'ResponseBody           >> ' client:ResponseBody                      SKIP(1)
      /*
       'ResponseText           >> ' client:ResponseText                      SKIP(1)
       SKIP(1)
       STRING(cLongJson)
       SKIP(1)
      'Responsexml            >> ' client:ResponseXml                       SKIP(1)
      'responseStream         >> ' client:responseStream                    SKIP(1)
      */
      'STATUS                 >> ' client:STATUS                            SKIP(1).

 
   ASSIGN
      es-api-log.retorno-headers      = client:getAllResponseHeaders
      NO-ERROR.

   ASSIGN
      es-api-log.retorno-content-type = client:getResponseHeader("Content-Type") 
      NO-ERROR.

   ASSIGN
      es-api-log.cod-retorno          = client:STATUS
      es-api-log.dh-retorno           = NOW.
   
   RETURN es-api-log.cod-retorno.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-oauth-1 Include 
FUNCTION fc-oauth-1 RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEF BUFFER bf-es-api-token FOR es-api-token.

  DEF VAR oClient      AS IHttpClient      NO-UNDO.
  DEF VAR oReq         AS IHttpRequest     NO-UNDO.
  DEF VAR oResponse    AS IHttpResponse    NO-UNDO.
  DEF VAR oCJ          AS ICookieJar       NO-UNDO.
  DEF VAR oForm        AS IStringStringMap NO-UNDO.
  DEF VAR oJson        AS JsonObject       NO-UNDO.
  DEF VAR jsonReq      AS c                NO-UNDO.
                                           
  DEF VAR oRequestBody AS String           NO-UNDO.
  DEF VAR oEntity      AS OBJECT           NO-UNDO.
                                           
  DEF VAR lcAux        AS LONGCHAR         NO-UNDO.
  DEF VAR cToken       AS c                NO-UNDO.
  DEF VAR cType        AS c                NO-UNDO.
  DEF VAR iExpires     AS i                NO-UNDO.

  DEF VAR JsonString   AS LONGCHAR         NO-UNDO.
  DEF VAR oJsonObject  AS JsonObject       NO-UNDO.


  /* Cookie [JAR] - This will handle cookies automatically for all next requests */

  oCJ = CookieJarBuilder:Build():CookieJar.
  oClient = ClientBuilder:Build()
                         :KeepCookies(oCJ)
                         :Client.
  
  // Here it could be more tasks to run before "Get the TOKEN" step...................
  
  //===================================================================================   
  
  // Get the TOKEN

  oForm = NEW StringStringMap().

  // Set my specific authentication details

  FOR EACH ttHeader
        BY ttHeader.seq:
     oForm:Put(ttHeader.Chave,ttHeader.Valor).
  END.

  //oForm:Put('client_id','3c5b5b73-2374-4b67-a603-96254ad40715').
  //oForm:Put('client_secret','227e61fd-0dbf-4e91-9c66-f2a7efa10741').
  //oForm:Put('grant_type','client_credentials').
  //oForm:Put('client_assertion_type','urn:ietf:params:oauth:client-assertion-type:jwt-bearer').
  //oForm:Put('client_assertion','eyJhbGciOiJIUzI1NiIsInR5c ..... 7CsACl1TryT8Wc').  // value from https://jwt.io/

  oReq = RequestBuilder:POST(c-endereco, oForm)
                       :ContentType('application/x-www-form-urlencoded') 
                       :Request.       

  oResponse = oClient:Execute(oReq) NO-ERROR.

  IF ERROR-STATUS:ERROR = YES 
  THEN DO:
     DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
        RUN piErro (ERROR-STATUS:GET-MESSAGE(i),"").
     END.
  END.


  IF TYPE-OF(oResponse:Entity, JsonObject) 
  THEN DO:
     ASSIGN 
        oJson    = CAST(oResponse:Entity, JsonObject)
        lcAux    = oJson:GetJsonText("access_token")
        cToken   = STRING(lcAux)
        lcAux    = oJson:GetJsonText("token_type")
        cType    = STRING(lcAux)
        lcAux    = oJson:GetJsonText("expires_in")
        iExpires = INTEGER(lcAux)
        .
     oJsonObject = CAST(oResponse:Entity, JsonObject). 
     JsonString = STRING(oJsonObject:getJsonText()).

  END.

  CREATE es-api-token.

  FIND LAST bf-es-api-token NO-LOCK
      WHERE bf-es-api-token.id-api-token > 0
      NO-ERROR.
  IF AVAIL bf-es-api-token
  THEN ASSIGN
     es-api-token.id-api-token = bf-es-api-token.id-api-token + 1.
  ELSE ASSIGN
     es-api-token.id-api-token = 1.

  IF AVAIL es-api-log
  THEN ASSIGN
     es-api-token.id-api-log = es-api-log.id-api-log.

  ASSIGN
     es-api-token.Type       = cType
     es-api-token.Token      = cToken
     es-api-token.Expires    = iExpires

     es-api-token.dh-request = NOW
     es-api-token.dh-expires = NOW + iExpires * 1000
     .


  /* 
    {
     "access_token":"Nvamn9S8tvyDI7E1ax2qBE4dQS5NPuGL2dWCB8Bt6uQNKpLB95Yy7s",
     "token_type":"Bearer",
     "expires_in":3600,
     "scope":"READ WRITE"
     }
  */

  COPY-LOB JsonString TO es-api-log.cl-retorno.

  MESSAGE "***" STRING(JsonString).

  IF oResponse:StatusCode >= 300
  THEN DO:
     RUN piErro ("Ocorreram erros no envio - " + 
                 STRING(oResponse:statusCode)  + 
                 " - " + 
                 STRING(oResponse:StatusReason) + 
                 STRING(JsonString)
                 ,"").
  END.


  ASSIGN
//      es-api-log.retorno-headers      = oResponse:
     es-api-log.retorno-content-type = oResponse:ContentType 
     es-api-log.cod-retorno          = STRING(oResponse:StatusCode)
     es-api-log.dh-retorno           = NOW.

  RETURN es-api-log.cod-retorno.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

