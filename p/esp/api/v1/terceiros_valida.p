/*Cyberbot api consultas notas terceiros desenvolvido por Mike*/

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-consulta POST /consulta/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEF TEMP-TABLE tt-consulta NO-UNDO
    FIELD estab  AS INTEGER
    FIELD nota   AS INTEGER
    FIELD serie  AS INTEGER.
       
    
FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.
END FUNCTION.
 

PROCEDURE pi-consulta:
    OUTPUT TO VALUE('X:\TEMP\cyber_log.txt') APPEND.
    //VALIDATORS
    DEFINE VARIABLE nota-processada AS LOGICAL NO-UNDO INITIAL FALSE.
    DEFINE VARIABLE ret             AS LOGICAL NO-UNDO INITIAL FALSE.
    DEFINE VARIABLE EMITENTE        AS INT     NO-UNDO.
            
    //BUFFERS
    DEFINE BUFFER buf-entrada     FOR int_ds_nota_entrada.
    DEFINE BUFFER buf-ret         FOR int_dp_nota_entrada_ret.
    DEFINE BUFFER buf-docum-est   FOR docum-est.
    DEFINE BUFFER buf-estabelec   FOR estabelec.
      
    DEF INPUT PARAM jsonInput AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE jsonAux        AS JsonObject           NO-UNDO.
    DEFINE VARIABLE itemsArray     AS JsonArray            NO-UNDO.
    DEFINE VARIABLE item           AS JsonObject           NO-UNDO.
    DEFINE VARIABLE i              AS INTEGER              NO-UNDO.
    
    
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    /* Converte o LONGCHAR para um objeto JSON */
    jsonAux = LongCharToJsonObject(lcPayload).

    /* Verifica se o JSON cont‚m o array "items" */
    IF jsonAux:HAS("items") THEN DO:
        itemsArray = jsonAux:GetJsonArray("items").

        /* Itera sobre cada objeto no array e adiciona … TEMP-TABLE */
        DO i = 1 TO NUM-ENTRIES(string(itemsArray)). 
            item = CAST(itemsArray:GetJsonObject(i), JsonObject).

            /* Cria um novo registro na TEMP-TABLE e insere os valores */
            CREATE tt-consulta.
            ASSIGN tt-consulta.estab = INTEGER(item:GetCharacter("estab"))
                   tt-consulta.nota  = INTEGER(item:GetCharacter("nota"))
                   tt-consulta.serie = INTEGER(item:GetCharacter("serie")). 
        END.
    END.

    /* Cria‡Æo do JSON de sa¡da */
    jsonOutput = NEW JsonObject().
    
   FOR EACH tt-consulta:
        
      FOR EACH buf-estabelec WHERE buf-estabelec.cod-estabel = string(tt-consulta.estab):
             
            FOR FIRST buf-entrada WHERE 
                buf-entrada.nen_serie_s        = string(tt-consulta.serie) AND
                buf-entrada.nen_notafiscal_n   = tt-consulta.nota      AND
                buf-entrada.tipo_nota          = 1                     AND 
                //buf-entrada.nen_conferida_n  < 2                     AND
                buf-entrada.tipo_nota = 1                              AND
                buf-entrada.nen_cnpj_destino_s = buf-estabelec.cgc
                NO-LOCK,
                FIRST buf-ret WHERE
                buf-ret.nen_cnpj_origem_s = buf-entrada.nen_cnpj_origem_s AND
                buf-ret.nen_notafiscal_n  = buf-entrada.nen_notafiscal_n  AND
                buf-ret.nen_serie_s       = buf-entrada.nen_serie_s:
                 
                ASSIGN nota-processada = TRUE.

                IF AVAIL buf-ret THEN DO:
                      
                    FOR EACH emitente WHERE emitente.cgc = buf-entrada.nen_cnpj_origem_s NO-LOCK.
                        ASSIGN EMITENTE = emitente.cod-emitente.
                          
                    END.
                    
                    IF buf-entrada.situacao = 2 AND buf-entrada.nen_conferida_n = 2 THEN DO:
                        
                        FOR EACH buf-docum-est WHERE
                            buf-docum-est.sit-atual     = 2 AND
                            buf-docum-est.nro-docto     = STRING(buf-entrada.nen_notafiscal_n, "9999999") AND
                            buf-docum-est.serie-docto   = buf-entrada.nen_serie_s AND        
                            buf-docum-est.cod-emitente  = EMITENTE    
                            NO-LOCK:
                                 
                            IF AVAIL buf-docum-est THEN DO: 
                            
                                IF buf-docum-est.sit-atual <> 2 OR buf-entrada.nen_conferida_n <> 2 THEN DO:
                                   EXPORT DELIMITER ";"
                                            STRING(buf-estabelec.cod-estabel) 
                                            STRING(buf-entrada.nen_cnpj_origem_s)      
                                            STRING(buf-entrada.nen_cnpj_destino_s)
                                            STRING(buf-entrada.nen_notafiscal_n)
                                            STRING(buf-entrada.nen_serie_s)
                                            STRING(buf-entrada.nen_conferida_n)
                                            STRING(buf-entrada.situacao)
                                            STRING(buf-entrada.dt_geracao)
                                            STRING(buf-entrada.nen_datamovimentacao_d) 
                                            STRING(buf-entrada.nen_dataemissao_d)
                                            "VERIFICAR".
                                END.
                                
                                ELSE DO:
                                 
                                 NEXT.
                                 
                                END.
                                
                            END.
                            
                            ELSE DO:               
                                    EXPORT DELIMITER ";"
                                            STRING(buf-estabelec.cod-estabel) 
                                            STRING(buf-entrada.nen_cnpj_origem_s)      
                                            STRING(buf-entrada.nen_cnpj_destino_s)
                                            STRING(buf-entrada.nen_notafiscal_n)
                                            STRING(buf-entrada.nen_serie_s)
                                            STRING(buf-entrada.nen_conferida_n)
                                            STRING(buf-entrada.situacao)
                                            STRING(buf-entrada.dt_geracao)
                                            STRING(buf-entrada.nen_datamovimentacao_d) 
                                            STRING(buf-entrada.nen_dataemissao_d)
                                            "N¶O CONSTA PROCESSADA NO RE0701 (DOCUM-EST)".         
                           END.

                        END. /* FOR EACH buf-docum-est */

                    END.
                    ELSE DO:
                        DISP buf-entrada.situacao
                             buf-entrada.nen_conferida_n.
                    END.
                END.
                ELSE DO:
                     EXPORT DELIMITER ";"
                            STRING(buf-estabelec.cod-estabel) 
                            STRING(buf-entrada.nen_cnpj_origem_s)      
                            STRING(buf-entrada.nen_cnpj_destino_s)
                            STRING(buf-entrada.nen_notafiscal_n)
                            STRING(buf-entrada.nen_serie_s)
                            STRING(buf-entrada.nen_conferida_n)
                            STRING(buf-entrada.situacao)
                            STRING(buf-entrada.dt_geracao)
                            STRING(buf-entrada.nen_datamovimentacao_d) 
                            STRING(buf-entrada.nen_dataemissao_d) 
                            "NAO ENCONTRADO INT_DP_NOTA_ENTRADA_RET".       
                            
                END.

            END. /* FOR FIRST buf-entrada */

            IF NOT nota-processada THEN DO:
               EXPORT DELIMITER ";"
                   STRING(tt-consulta.estab)
                   "NULL"
                   "NULL"
                    STRING(tt-consulta.nota)
                    STRING(tt-consulta.serie)
                    "NULL"
                    "NULL"
                    "NULL"
                    "NULL" 
                    "NULL"
                     "NAO ENCONTRADO INT_DS_NOTA_ENTRADA".
    
              
            END.

        END. /* FOR EACH buf-estabelec */
        
      END.  /* FOR EACH tt-consulta */

      
     jsonOutput:Add("retorno", "Acionado consulta...").

END PROCEDURE.  
