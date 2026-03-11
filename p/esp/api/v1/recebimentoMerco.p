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

{utp/ut-api.i}
{utp/ut-api-action.i pi-recebimento  POST  /~* }



{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEFINE VARIABLE c-mensagem AS CHARACTER   NO-UNDO.


DEFINE TEMP-TABLE Recebimento NO-UNDO
   FIELD NR-NOTA    AS CHAR
   FIELD SERIE      AS CHAR
   FIELD CNPJ       AS CHAR
   FIELD XMLNota    AS CLOB.


define temp-table tt-param-int500 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.
    
    

def var cSerie  as char no-undo.
def var cNF     as char no-undo.
def var cEmit   as char no-undo.
def var cDest   as char no-undo.
def var cData   as char no-undo.

/* Definiá∆o temp-tables/vari†veis execuá∆o FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.

define temp-table tt-erros no-undo
       field identifi-msg                   as char format "x(60)"
       field cod-erro                       as int  format "99999"
       field desc-erro                      as char format "x(60)"
       field tabela                         as char format "x(20)"
       field l-erro                         as logical initial yes.
/* FIM - Definiá∆o temp-tables/vari†veis execuá∆o FT2200 */

DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.


function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    LOG-MANAGER:WRITE-MESSAGE("findTag _ " + pTag) NO-ERROR.

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagIni,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ))) NO-ERROR.
        IF index(pSource,cTagIni,pStart) < 0
        OR index(pSource,cTagFim,pStart) < 0 
        OR index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) < 0 THEN RETURN "".

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.


function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    if c-aux <> ? then return c-aux. else return "".
end.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-recebimento:  //KML


    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE l-ok-procfit AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE ResultObject AS JsonObject        NO-UNDO.
    DEFINE VARIABLE JsonParser   AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE FieldNames   AS CHARACTER         NO-UNDO EXTENT.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE lcxml          AS LONGCHAR     NO-UNDO.

    DEFINE VARIABLE xmlBase64           AS LONGCHAR     NO-UNDO.
    DEFINE VARIABLE xmlBase64Decoded    AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE h_int500a           AS HANDLE      NO-UNDO.
    DEFINE VARIABLE c-result            AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-statuscode        AS INTEGER     NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    log-manager:write-message("KML - entrou api recebimento") no-error.

    if not valid-handle (h_int500a)    then run intprg/int500a-get.p    persistent set h_int500a.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    
    TEMP-TABLE Recebimento:READ-JSON("longchar", lcPayload, "empty").
     
    FOR EACH Recebimento:

        bl_nota:
        DO TRANS ON ERROR UNDO, LEAVE:
            COPY-LOB FROM Recebimento.XMLNota TO xmlBase64 .
            xmlBase64Decoded = BASE64-DECODE(xmlBase64).
            COPY-LOB FROM xmlBase64Decoded TO  lcxml  .
            
            COPY-LOB FROM lcxml TO  Recebimento.XMLNota  .
    
            log-manager:write-message("KMLR - ANTES PROCESSA v2") no-error.
            log-manager:write-message("KMLR TAMANHO - " + STRING(LENGTH(lcxml)) ) no-error.
    
            //   COPY-LOB FROM lcxml TO FILE "xml1.xml" .
    
            RUN gera_ndd_entryintegration IN h_int500a (INPUT lcxml, 
                                                        OUTPUT c-result).
                                                        
            ASSIGN c-result = "Totvs - " + c-result.                                                        
    
            log-manager:write-message("KMLR - DEPOIS PROCESSA - " + c-result ) no-error.

            if lcxml matches "*CNPJ*" then do: 
                /* destinatario */
                assign cDest = string(findTag(lcxml,'CNPJ',index(lcxml,'CNPJ') + 25)) no-error.
            end.

            FIND FIRST ems2mult.estabelec NO-LOCK
                WHERE estabelec.cgc = cDest NO-ERROR.
                
            ASSIGN i-statuscode = 200.
			
            IF AVAIL estabelec and 
				(   estabelec.cod-estabel = "10001" OR 
                    estabelec.cod-estabel = "10004" OR
                    estabelec.cod-estabel = "10008")
                THEN DO:                      
                 
                ASSIGN l-ok-procfit = YES. // como n∆o sera integrado via api marca como ok
                ASSIGN c-result = "Totvs - XML Importado com sucesso" .  // apenas para reforáar que ele manter† a mensagem de retorno do int500 e n∆o da procfit


                // KML - colocar filtro por estabelecimento
            //    RUN pi-procfit (INPUT lcxml, OUTPUT l-ok-procfit, OUTPUT i-statuscode).


            END.
            ELSE DO:

             
            END.

            IF l-ok-procfit = NO THEN DO:
                UNDO, LEAVE bl_nota.
            END.
        END.
    END.      
    
 //   ASSIGN c-result = "teste".

    FIND FIRST Recebimento NO-LOCK NO-ERROR.
    
    jsonOutput = NEW JSONObject(). 
    
    log-manager:write-message("KML antes retorno json - i-statuscode- " + STRING(i-statuscode) + " c-result- " + c-result ) no-error.    
        
    IF i-statuscode <> 200 THEN
    DO:
    
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = c-result
               RowErrors.ErrorHelp = c-result
               RowErrors.ErrorSubType = "ERROR". 
                             
        IF CAN-FIND(FIRST RowErrors) THEN DO:
        
           oResponse = NEW JsonAPIResponse(jsonInput).
           oResponse:setHasNext(FALSE).
           oResponse:setStatus(i-statuscode).
           oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
           jsonOutput = oResponse:createJsonResponse().
        END.    
     END.
      
    ELSE DO:
    
        jsonOutput:ADD("message",c-result).
    END.
    
    FIND  FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cgc = recebimento.CNPJ NO-ERROR.
        
    log-manager:write-message("KML - antes IF AVAIL" + recebimento.CNPJ) no-error.    
        
    IF NOT AVAIL emitente THEN
    DO:
    
        ASSIGN i-statuscode = 400
               c-mensagem = "Emitente n∆o cadastrado na base de dados, n∆o foi possivel integraá∆o"  .
        
        RETURN "OK".
    END.
     
    log-manager:write-message("KML - antes int500-merco" + RECEBIMENTO.NR-NOTA ) no-error.
    log-manager:write-message("KML - antes int500-merco" + recebimento.CNPJ) no-error.
    log-manager:write-message("KML - antes int500-merco V1 ") no-error.
   
    EMPTY TEMP-TABLE tt-param-int500.
            create tt-param-int500.
            assign tt-param-int500.usuario         = c-seg-usuario
                   tt-param-int500.destino         = 3
                   tt-param-int500.arquivo         = "INT002brp.txt"
                   tt-param-int500.data-exec       = today
                   tt-param-int500.hora-exec       = time
                   tt-param-int500.classifica      = 1
                   tt-param-int500.dt-trans-ini    = date(cData)
                   tt-param-int500.dt-trans-fin    = DATE(cData)
                   tt-param-int500.i-nro-docto-ini = RECEBIMENTO.NR-NOTA 
                   tt-param-int500.i-nro-docto-fin = RECEBIMENTO.NR-NOTA
                   tt-param-int500.i-cod-emit-ini  = ems2mult.emitente.cod-emitente
                   tt-param-int500.i-cod-emit-fin  = ems2mult.emitente.cod-emitente.

    RAW-TRANSFER tt-param-int500 TO raw-param.

    RUN intprg/int500rp-merco.p(INPUT raw-param, INPUT TABLE tt-raw-digita).


    log-manager:write-message("KML - depois int500-merco - cnpj - " + cEmit) no-error.
    log-manager:write-message("KML - depois int500-merco - nota-fiscal - " + cNF) no-error.
    log-manager:write-message("KML - depois int500-merco - serie - " + cserie) no-error.
     
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE pi-procfit:
    DEFINE INPUT  PARAMETER pxml AS LONGCHAR.
    DEFINE OUTPUT PARAMETER p-ok AS LOGICAL     NO-UNDO.   
    DEFINE OUTPUT PARAMETER p-statuscode AS INTEGER     NO-UNDO. 
   
     log-manager:write-message("KML - dentro pi-procfit") no-error.
    /* tratar sÇrie */
    if  pXML matches "*serie*" then do:     
        assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
        if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
    end.
    
    if  pXML matches "*nNF*" then 
        assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nNF',1)),">>>9999999")) no-error.
    if pXML matches "*dhEmi*" then do:
        assign cData = substring(findTag(pXML,'dhEmi',1),1,10) 
               cData = entry(3,cData,"-") + "/" + entry(2,cData,"-")  + "/" + entry(1,cData,"-") no-error.
    end.
    
    if pXML matches "*CNPJ*" then do: 
        /* emitente do documento */
        assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
    
        /* destinatario */
        assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
    end.

    FIND  FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cgc = cEmit NO-ERROR.
        
    IF NOT AVAIL emitente THEN
    DO:
    
        ASSIGN p-statuscode = 400
               p-ok = NO
               c-mensagem = "Emitente n∆o cadastrado na base de dados, n∆o foi possivel integraá∆o"  .
        
        RETURN "OK".
    END.

    
    log-manager:write-message("KML - antes int500 ") no-error.
   
    EMPTY TEMP-TABLE tt-param-int500.
    create tt-param-int500.
    assign tt-param-int500.usuario         = c-seg-usuario
           tt-param-int500.destino         = 3
           tt-param-int500.arquivo         = "INT002brp.txt"
           tt-param-int500.data-exec       = today
           tt-param-int500.hora-exec       = time
           tt-param-int500.classifica      = 1
           tt-param-int500.dt-trans-ini    = date(cData)
           tt-param-int500.dt-trans-fin    = DATE(cData)
           tt-param-int500.i-nro-docto-ini = cNF 
           tt-param-int500.i-nro-docto-fin = cNF
           tt-param-int500.i-cod-emit-ini  = emitente.cod-emitente
           tt-param-int500.i-cod-emit-fin  = emitente.cod-emitente.

    RAW-TRANSFER tt-param-int500 TO raw-param.

    RUN intprg/int500rp-merco.p(INPUT raw-param, INPUT TABLE tt-raw-digita).


    log-manager:write-message("KML - depois int500 - cnpj - " + cEmit) no-error.
    log-manager:write-message("KML - depois int500 - nota-fiscal - " + cNF) no-error.
    log-manager:write-message("KML - depois int500 - serie - " + cserie) no-error.
   

    RETURN "OK".
END PROCEDURE.
