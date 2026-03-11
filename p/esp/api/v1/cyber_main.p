/* CyberBot.Script API VER 4.0, Desenvolvido por Mike, Eduardo e Luan */ 
/* RPA - Geraá∆o de notas de balanáo Lojas Prcfit>CyberBot>Progress4GL>int038rp.p */

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-cyber POST /cyberbot/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/
    
/* Definindo a temp-table tt-param */
define temp-table tt-param NO-UNDO
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          AS char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field dt-periodo-ini   as DATE format "99/99/9999"
    field dt-periodo-fim   as date format "99/99/9999"
    field cod-estabel-ini  as char format "x(03)"
    field cod-estabel-fim  as char format "x(03)"
    field pedido-ini       as integer format ">>>>>>>9"
    field pedido-fim       as integer format ">>>>>>>9"
    field txt-obs          as char format "X(300)"
    FIELD cancelar         AS LOGICAL.
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
    
def temp-table tt-raw-digita
    field raw-digita as raw.
    
DEFINE VARIABLE raw-param AS RAW NO-UNDO.

DEF TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedido     AS INTEGER
    FIELD estab      AS CHAR
    FIELD obs        AS CHAR FORMAT "X(300)"    .

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.
END FUNCTION.

PROCEDURE pi-cyber:

    DEF INPUT PARAM jsonInput       AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput     AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE oRequestParser  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload       AS LONGCHAR             NO-UNDO.
    
    DEFINE VARIABLE situacao_nf     AS CHARACTER NO-UNDO INITIAL "". 
    
    DEFINE BUFFER buf-pedido        FOR int_ds_pedido.
    DEFINE BUFFER buf-nota-fiscal   FOR nota-fiscal.
    
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).

    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
    
    DEFINE VARIABLE jsonAux   AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
                                            
    TEMP-TABLE tt-pedido:HANDLE:READ-JSON('JsonArray', jsonAux:GetJsonArray("ped")).

    jsonOutput = NEW JsonObject().

    FOR EACH tt-pedido: 
        
       /* :) Verifica se ja houve faturamento do Pedido '_' */  
        FOR EACH nota-fiscal NO-LOCK WHERE 
            nota-fiscal.cod-estabel = tt-pedido.estab AND
            nota-fiscal.nr-pedcli   = string(tt-pedido.pedido) AND
            nota-fiscal.serie = "1":
            
            ASSIGN situacao_nf = SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1).                                               
            
            jsonOutput:ADD("NF", nota-fiscal.nr-nota-fis).
            jsonOutput:ADD("Emissao", nota-fiscal.dt-emis-nota). 
            jsonOutput:ADD("Natureza", nota-fiscal.nat-operacao). 
            jsonOutput:ADD("OBS", nota-fiscal.observ-nota). 
            jsonOutput:ADD("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro). 
            jsonOutput:ADD("Situacao", situacao_nf). 
            jsonOutput:ADD("Valor_Nota", vl-tot-nota).
            jsonOutput:ADD("status", "1")       .

        END.
        
    IF NOT AVAIL nota-fiscal THEN DO: // Caso o pedido ja esteja faturado n∆o chame o int038.
    
        EMPTY TEMP-TABLE tt-param.
        CREATE tt-param.
                                                        
        ASSIGN
            tt-param.usuario         = c-seg-usuario
            tt-param.destino         = 3 
            tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "API_CYBER.TXT":U  //Diretorio de log                       
            tt-param.data-exec       = TODAY
            tt-param.hora-exec       = TIME
            tt-param.dt-periodo-ini  = TODAY - 30 //Pega os ultimos 30 dias
            tt-param.dt-periodo-fim  = TODAY
            tt-param.cod-estabel-ini = tt-pedido.estab
            tt-param.cod-estabel-fim = tt-pedido.estab
            tt-param.pedido-ini      = tt-pedido.pedido
            tt-param.pedido-fim      = tt-pedido.pedido
            tt-param.txt-obs         = tt-pedido.obs + " [RPA]"
            tt-param.cancelar        = FALSE.

            RAW-TRANSFER tt-param TO raw-param.

            RUN intprg/int038rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita) NO-ERROR. 
            
           
          FOR EACH int_ds_pedido EXCLUSIVE-LOCK WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedido:
          
             
             IF int_ds_pedido.situacao = 2 THEN DO:
                FOR EACH nota-fiscal NO-LOCK WHERE
                    nota-fiscal.cod-estabel = tt-pedido.estab AND
                    nota-fiscal.nr-pedcli   = string(tt-pedido.pedido) AND
                    nota-fiscal.serie       = "1":
                    
                     ASSIGN situacao_nf = SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1).
                     
                    jsonOutput:ADD("NF", nota-fiscal.nr-nota-fis).
                    jsonOutput:ADD("Emissao", nota-fiscal.dt-emis-nota). 
                    jsonOutput:ADD("Natureza", nota-fiscal.nat-operacao). 
                    jsonOutput:ADD("OBS", nota-fiscal.observ-nota). 
                    jsonOutput:ADD("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro). 
                    jsonOutput:ADD("Situacao", situacao_nf). 
                    jsonOutput:ADD("Valor_Nota", nota-fiscal.vl-tot-nota).
                    jsonOutput:ADD("status", "1").
                    
                    RETURN. 
                    
                END.  //END nota-fiscsr
                
            
                IF NOT AVAIL nota-fiscal THEN DO:
                          
                    ASSIGN int_ds_pedido.situacao = 1.
                    jsonOutput:ADD("Erro", "Sem retorno de Nota na tabela Nota-Fiscal").
                    jsonOutput:ADD("status", "0").
                    
                    RETURN.
                    
                END.
                
                RELEASE buf-nota-fiscal.
                
            END.   //end if int_ds_pedido = 2 
            ELSE DO:
             
                IF can-find (first nota-fiscal no-lock where
                             nota-fiscal.cod-estabel = tt-pedido.estab and 
                             nota-fiscal.nr-pedcli   = string(tt-pedido.pedido) AND
                             nota-fiscal.serie       = "1")
                     
                THEN DO: 
                    
                      RUN pi-consulta (INPUT tt-pedido.estab, INPUT string(tt-pedido.pedido)). 
                    
                END.
               
                ELSE DO:
                    
                     jsonOutput:ADD("Erro", "Pedido n∆o foi processado!").
                     jsonOutput:ADD("status", "0").
                     RETURN.
               END.
           END.     
            
        END. //end buf_pedido
        
        IF NOT AVAIL int_ds_pedido THEN DO:
         
            jsonOutput:ADD("Erro", "Pedido n∆o encontrado em int_ds_pedido, ap¢s execucao do int038.").
            jsonOutput:ADD("status", "0").
            RETURN.
            
         END.
    END.
END.

RETURN.

END PROCEDURE. 


PROCEDURE pi-consulta:

    DEFINE INPUT PARAMETER pedido AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER estab  AS CHAR NO-UNDO.
    DEFINE VARIABLE situacao AS CHAR NO-UNDO.

    FOR EACH nota-fiscal NO-LOCK WHERE
              nota-fiscal.cod-estabel = estab   AND
              nota-fiscal.nr-pedcli   = pedido  AND
              nota-fiscal.serie       = "1",
              FIRST int_ds_pedido NO-LOCK WHERE ped_codigo_n = INT(pedido).
              
              ASSIGN situacao = SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1).
              ASSIGN int_ds_pedido.situacao = 2.
              
              jsonOutput:ADD("NF", nota-fiscal.nr-nota-fis).
              jsonOutput:ADD("Emissao", nota-fiscal.dt-emis-nota). 
              jsonOutput:ADD("Natureza", nota-fiscal.nat-operacao). 
              jsonOutput:ADD("OBS", nota-fiscal.observ-nota). 
              jsonOutput:ADD("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro). 
              jsonOutput:ADD("Situacao", situacao). 
              jsonOutput:ADD("Valor_Nota", nota-fiscal.vl-tot-nota).
              jsonOutput:ADD("status", "1").  
    END.
    
RETURN. 
END PROCEDURE. 
   
