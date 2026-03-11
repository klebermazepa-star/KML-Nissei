//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-nota-saida  POST  /geraSaidaLoja/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

    
DEFINE TEMP-TABLE SAIDA_LOJA NO-UNDO
    FIELD tipo_movto                  AS INTEGER
    FIELD dt_geracao                  AS DATE
    FIELD hr_geracao                  AS CHARACTER
    FIELD situacao                    AS INTEGER
    FIELD nsa_cnpj_origem_s           AS CHARACTER
    FIELD nsa_cnpj_destino_s          AS CHARACTER
    FIELD nsa_notafiscal_n            AS INTEGER
    FIELD nsa_serie_s                 AS CHARACTER
    FIELD nsa_dataemissao_d           AS DATE
    FIELD nsa_cfop_n                  AS INTEGER
    FIELD nsa_quantidade_n            AS DECIMAL
    FIELD nsa_desconto_n              AS DECIMAL
    FIELD nsa_baseicms_n              AS DECIMAL
    FIELD nsa_valoricms_n             AS DECIMAL
    FIELD nsa_basediferido_n          AS DECIMAL
    FIELD nsa_baseisenta_n            AS DECIMAL
    FIELD nsa_baseipi_n               AS DECIMAL
    FIELD nsa_valoripi_n              AS DECIMAL
    FIELD nsa_basest_n                AS DECIMAL
    FIELD nsa_icmsst_n                AS DECIMAL
    FIELD nsa_valortotalprodutos_n    AS DECIMAL
    FIELD nsa_cnpj_transportadora_s   AS CHARACTER
    FIELD nsa_placaveiculo_s          AS CHARACTER
    FIELD nsa_estadoveiculo_s         AS CHARACTER
    FIELD nsa_placareboque_s          AS CHARACTER
    FIELD nsa_estadoreboque_s         AS CHARACTER
    FIELD nsa_observacao_s            AS CHARACTER
    FIELD nsa_chaveacesso_s           AS CHARACTER
    FIELD ped_tipopedido_n            AS INTEGER
    FIELD nen_notafiscalorigem_n      AS INTEGER
    FIELD nen_serieorigem_s           AS CHARACTER
    FIELD nsa_tipoambientenfe_n       AS INTEGER
    FIELD nsa_protocolonfe_s          AS CHARACTER
    FIELD nsa_pesobruto_n             AS DECIMAL
    FIELD nsa_pesoliquido_n           AS DECIMAL
    FIELD nsa_valorfrete_n            AS DECIMAL
    FIELD nsa_valorseguro_n           AS DECIMAL
    FIELD nsa_valorembalagem_n        AS DECIMAL
    FIELD nsa_valoroutrasdesp_n       AS DECIMAL
    FIELD nsa_marcavolumes_s          AS CHARACTER
    FIELD nsa_quantvolumes_n          AS INTEGER
    FIELD nsa_modalidadefrete_n       AS INTEGER
    FIELD nsa_datacancelamento_d      AS DATE
    FIELD nsa_datacupomorigem_ecf     AS DATE
    FIELD nsa_modelocupom_s           AS CHARACTER
    FIELD nsa_numeroserieecf_s        AS CHARACTER
    FIELD nsa_caixaecf_s              AS CHARACTER
    FIELD nsa_cupomorigem_s           AS CHARACTER
    FIELD ped_codigo_n                AS INTEGER
    FIELD ENVIO_DATA_HORA             AS DATETIME
    FIELD ENVIO_ERRO                  AS CHARACTER
    FIELD ENVIO_STATUS                AS INTEGER
    FIELD ID_SEQUENCIAL               AS INTEGER
    FIELD retorno_validacao           AS CHARACTER.

/* Definiá∆o temp-tables/vari†veis execuá∆o FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino           AS INTEGER
    FIELD arquivo           AS CHARACTER FORMAT "x(35)"
    FIELD usuario           AS CHARACTER FORMAT "x(12)"
    FIELD data-exec         AS DATE
    FIELD hora-exec         AS INTEGER
    FIELD cod-estabel       LIKE nota-fiscal.cod-estabel
    FIELD serie             LIKE nota-fiscal.serie
    FIELD nr-nota-fis       LIKE nota-fiscal.nr-nota-fis
    FIELD dt-cancela        LIKE nota-fiscal.dt-cancela
    FIELD desc-cancela      LIKE nota-fiscal.desc-cancela
    FIELD arquivo-estoq     AS CHARACTER
    FIELD reabre-resumo     AS LOGICAL
    FIELD cancela-titulos   AS LOGICAL
    FIELD imprime-ajuda     AS LOGICAL
    FIELD l-valida-dt-saida AS LOGICAL
    FIELD elimina-nota-nfse AS LOGICAL.

define temp-table tt-erros no-undo
       field identifi-msg                   as char format "x(60)"
       field cod-erro                       as int  format "99999"
       field desc-erro                      as char format "x(60)"
       field tabela                         as char format "x(20)"
       field l-erro                         as logical initial yes.

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

PROCEDURE pi-gera-nota-saida:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
        
    TEMP-TABLE SAIDA_LOJA:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("SAIDA_LOJA")).
        
     jsonOutput = NEW JSONObject().
     
      FOR FIRST saida_loja:        
            log-manager:write-message("KML - antes API - saida_loja.nsa_notafiscal_n - " + string(saida_loja.nsa_notafiscal_n)) no-error.
            log-manager:write-message("KML - antes API - saida_loja.nsa_cnpj_origem_s - " + saida_loja.nsa_cnpj_origem_s) no-error.
            log-manager:write-message("KML - antes API - saida_loja.nsa_serie_s - " + saida_loja.nsa_serie_s) no-error.
            log-manager:write-message("kml" + string(ERROR-STATUS:ERROR)).
            log-manager:write-message("kml" + ERROR-STATUS:GET-MESSAGE(1)).
                 
             FIND FIRST int_dp_nota_saida NO-LOCK
                 WHERE int_dp_nota_saida.nsa_notafiscal    = saida_loja.nsa_notafiscal
                 AND   int_dp_nota_saida.nsa_cnpj_origem_s = saida_loja.nsa_cnpj_origem_s
                 AND   int_dp_nota_saida.nsa_serie_s       = saida_loja.nsa_serie_s NO-ERROR.
                 
                 log-manager:write-message("KML - 2 antes API") no-error.
                 log-manager:write-message("KML - 2 antes API - int_dp_nota_saidat.cnpj-loja - " + int_dp_nota_saida.nsa_cnpj_origem_s) no-error.
                       
                //FOR FIRST saida_loja:
                   IF AVAIL int_dp_nota_saida  THEN DO:   
                    jsonOutput:ADD("tipo_movto",int_dp_nota_saida.nsa_cnpj_destino_s).
                    jsonOutput:ADD("Validaá∆o","TESTE!").
                    END.       
          
        
/*                     ELSE DO:                                                                       */
/*                                                                                                    */
/*                     CREATE int_dp_nota_entrada_ret.                                                */
/*                     ASSIGN int_dp_nota_entrada_ret.nen_notafiscal_n  = INT(nota.nen_notafiscal_n)  */
/*                            int_dp_nota_entrada_ret.nen_cnpj_origem_s = nota.nen_cnpj_origem_s      */
/*                            int_dp_nota_entrada_ret.nen_serie_s       = nota.nen_serie_s            */
/*                            int_dp_nota_entrada_ret.situacao          = 1.                          */
/*                                                                                                    */
/*                     jsonOutput:ADD("situacao"  ,int_dp_nota_entrada_ret.situacao).                 */
/*                     jsonOutput:ADD("nen_cnpj_origem_s",int_dp_nota_entrada_ret.nen_cnpj_origem_s). */
/*                     jsonOutput:ADD("nen_notafiscal_n" ,int_dp_nota_entrada_ret.nen_notafiscal).    */
/*                     jsonOutput:ADD("Retorno", "Nota Criada com sucesso").                          */
/*                                                                                                    */
/*                     //jsonOutput:ADD("ERRO", "Nota n∆o encontrada").                               */
/*                     RETURN "OK".                                                                   */
/*                     END.                                                                           */
                     
      END.

    IF NOT CAN-FIND(FIRST saida_loja) THEN
        jsonOutput:ADD("ERRO","Erro na execuá∆o da rotina! 2").

    RETURN "OK".
END PROCEDURE.
