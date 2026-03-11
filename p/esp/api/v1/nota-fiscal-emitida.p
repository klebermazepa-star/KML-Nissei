//USING Progress.Json.ObjectModel.*.
//USING Progress.Json.ObjectModel.*.
//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-nota-fiscal-emitida  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE nota_fiscal  NO-UNDO
    FIELD chave_acesso                  AS CHARACTER 
    FIELD versao                        AS CHARACTER 
    FIELD especie                       AS CHARACTER 
    FIELD modelo                        AS CHARACTER 
    FIELD numero                        AS INTEGER   
    FIELD serie                         AS CHARACTER 
    FIELD data_emissao                  AS DATETIME  
    FIELD pedido_id                     AS INTEGER   
    FIELD tipo_pedido                   AS INTEGER   
    FIELD tipo_nota                     AS CHAR   
    FIELD situacao                      AS CHARACTER 
    FIELD emitente_cnpj                 AS CHARACTER   
    FIELD destinatario_cnpj             AS CHARACTER   
    FIELD transportadora_cnpj           AS CHARACTER   
    FIELD transportadora_veiculo_placa  AS CHARACTER 
    FIELD transportadora_veiculo_estado AS CHARACTER
    FIELD transportadora_reboque_placa  AS CHARACTER 
    FIELD transportadora_reboque_estado AS CHARACTER
    FIELD observacao                    AS CHARACTER 
    FIELD nota_fiscal_origem            AS INTEGER   
    FIELD serie_origem                  AS CHARACTER 
    FIELD tipo_ambiente_nfe             AS INTEGER   
    FIELD protocolo                     AS CHARACTER 
    FIELD cfop                          AS INTEGER   
    FIELD quantidade                    AS DECIMAL   
    FIELD valor_desconto                AS DECIMAL   
    FIELD valor_base_icms               AS DECIMAL   
    FIELD valor_icms                    AS DECIMAL   
    FIELD valor_base_diferido           AS DECIMAL   
    FIELD valor_base_isenta             AS DECIMAL   
    FIELD valor_base_ipi                AS DECIMAL   
    FIELD valor_ipi                     AS DECIMAL   
    FIELD valor_base_st                 AS DECIMAL   
    FIELD valor_icms_st                 AS DECIMAL   
    FIELD valor_total_produtos          AS DECIMAL   
    FIELD peso_bruto                    AS DECIMAL   
    FIELD peso_liquido                  AS DECIMAL   
    FIELD valor_frete                   AS DECIMAL   
    FIELD valor_seguro                  AS DECIMAL   
    FIELD valor_embalagem               AS DECIMAL   
    FIELD valor_outras_despesas         AS DECIMAL   
    FIELD volumes_marca                 AS CHARACTER 
    FIELD volumes_quantidade            AS INTEGER   
    FIELD modalidade_frete              AS INTEGER   
    FIELD data_cancelamento             AS DATETIME  
    .                                   
                                        
                                        
DEF TEMP-TABLE itens NO-UNDO
    FIELD pedido_id                 AS INT
    FIELD sequencia                AS INTEGER      
    FIELD produto                  AS INTEGER    
    FIELD caixa                    AS INTEGER    
    FIELD lote                     AS CHARACTER    
    FIELD quantidade               AS DECIMAL      
    FIELD cfop                     AS INTEGER      
    FIELD ncm                      AS CHARACTER    
    FIELD valor_bruto              AS DECIMAL      
    FIELD valor_desconto           AS DECIMAL      
    FIELD valor_base_icms          AS DECIMAL      
    FIELD valor_icms               AS DECIMAL      
    FIELD valor_base_diferido      AS DECIMAL      
    FIELD valor_base_isenta        AS DECIMAL      
    FIELD valor_base_ipi           AS DECIMAL      
    FIELD valor_ipi                AS DECIMAL      
    FIELD valor_icms_st            AS DECIMAL      
    FIELD valor_base_st            AS DECIMAL      
    FIELD valor_liquido            AS DECIMAL      
    FIELD valor_total_produto      AS DECIMAL      
    FIELD valor_aliquota_icms      AS DECIMAL      
    FIELD valor_aliquota_ipi       AS DECIMAL      
    FIELD valor_aliquota_pis       AS DECIMAL      
    FIELD valor_aliquota_cofins    AS DECIMAL      
    FIELD data_validade            AS DATE         
    FIELD valor_despesa            AS DECIMAL      
    FIELD valor_tributos           AS DECIMAL
    FIELD valor_cstb_icms          AS CHAR
    FIELD valor_cstb_pis           AS CHARACTER    
    FIELD valor_cstb_cofins        AS CHARACTER    
    FIELD valor_base_pis           AS DECIMAL      
    FIELD valor_pis                AS DECIMAL      
    FIELD valor_base_cofins        AS DECIMAL      
    FIELD valor_cofins             AS DECIMAL      
    FIELD valor_redutor_base_icms  AS DECIMAL      
    FIELD sequencia_origem         AS INTEGER      
    FIELD peso_bruto               AS DECIMAL      
    FIELD peso_liquido             AS DECIMAL      
    FIELD valor_frete              AS DECIMAL      
    FIELD valor_seguro             AS DECIMAL      
    FIELD valor_embalagem          AS DECIMAL      
    FIELD valor_outras_despesas    AS DECIMAL      
    FIELD valor_cst_ipi            AS DECIMAL      
    FIELD valor_modbc_icms         AS DECIMAL      
    FIELD valor_modb_cst           AS DECIMAL      
    FIELD valor_modb_ipi           AS DECIMAL      
    FIELD valor_icms_substituto    AS DECIMAL      
    FIELD valor_base_cst_ret       AS DECIMAL      
    FIELD valor_icms_ret           AS DECIMAL      
.
  

DEF TEMP-TABLE condicao_pagamento NO-UNDO
    FIELD pedido_id              AS INT
    FIELD PARCELA               AS CHAR
    FIELD CONDICAO_PAGAMENTO    AS CHAR
    FIELD vencimento            AS DATE    
    FIELD ADM_ID                AS CHAR
    FIELD ADQUIRENTE_ID         AS CHAR
    FIELD NSU                   AS CHAR
    FIELD AUTORIZACAO           AS CHAR
    FIELD adm_taxa              AS DEC
    FIELD valor                 AS DEC
    FIELD origem_pagamento      AS CHAR
    FIELD CONVENIO              AS CHAR.
    
DEF TEMP-TABLE TT-NOTA-FISCAL-EMITIDA  NO-UNDO  
    FIELD chave_acesso                  AS CHARACTER 
    FIELD versao                        AS CHARACTER 
    FIELD especie                       AS CHARACTER 
    FIELD modelo                        AS CHARACTER 
    FIELD numero                        AS INTEGER   
    FIELD serie                         AS CHARACTER 
    FIELD data_emissao                  AS DATETIME  
    FIELD pedido_id                     AS INTEGER   
    FIELD tipo_pedido                   AS INTEGER   
    FIELD tipo_nota                     AS CHAR   
    FIELD situacao                      AS CHARACTER 
    FIELD emitente_cnpj                 AS CHARACTER   
    FIELD destinatario_cnpj             AS CHARACTER   
    FIELD transportadora_cnpj           AS CHARACTER   
    FIELD transportadora_veiculo_placa  AS CHARACTER 
    FIELD transportadora_veiculo_estado AS CHARACTER
    FIELD transportadora_reboque_placa  AS CHARACTER 
    FIELD transportadora_reboque_estado AS CHARACTER
    FIELD observacao                    AS CHARACTER 
    FIELD nota_fiscal_origem            AS INTEGER   
    FIELD serie_origem                  AS CHARACTER 
    FIELD tipo_ambiente_nfe             AS INTEGER   
    FIELD protocolo                     AS CHARACTER 
    FIELD cfop                          AS INTEGER   
    FIELD quantidade                    AS DECIMAL   
    FIELD valor_desconto                AS DECIMAL   
    FIELD valor_base_icms               AS DECIMAL   
    FIELD valor_icms                    AS DECIMAL   
    FIELD valor_base_diferido           AS DECIMAL   
    FIELD valor_base_isenta             AS DECIMAL   
    FIELD valor_base_ipi                AS DECIMAL   
    FIELD valor_ipi                     AS DECIMAL   
    FIELD valor_base_st                 AS DECIMAL   
    FIELD valor_icms_st                 AS DECIMAL   
    FIELD valor_total_produtos          AS DECIMAL   
    FIELD peso_bruto                    AS DECIMAL   
    FIELD peso_liquido                  AS DECIMAL   
    FIELD valor_frete                   AS DECIMAL   
    FIELD valor_seguro                  AS DECIMAL   
    FIELD valor_embalagem               AS DECIMAL   
    FIELD valor_outras_despesas         AS DECIMAL   
    FIELD volumes_marca                 AS CHARACTER 
    FIELD volumes_quantidade            AS INTEGER   
    FIELD modalidade_frete              AS INTEGER   
    FIELD data_cancelamento             AS DATETIME  
    . 
    
DEF TEMP-TABLE tt-itens NO-UNDO
    FIELD pedido_id                AS INTEGER
    FIELD sequencia                AS INTEGER      
    FIELD produto                  AS INTEGER    
    FIELD caixa                    AS INTEGER    
    FIELD lote                     AS CHARACTER    
    FIELD quantidade               AS DECIMAL      
    FIELD cfop                     AS INTEGER      
    FIELD ncm                      AS CHARACTER    
    FIELD valor_bruto              AS DECIMAL      
    FIELD valor_desconto           AS DECIMAL      
    FIELD valor_base_icms          AS DECIMAL      
    FIELD valor_icms               AS DECIMAL      
    FIELD valor_base_diferido      AS DECIMAL      
    FIELD valor_base_isenta        AS DECIMAL      
    FIELD valor_base_ipi           AS DECIMAL      
    FIELD valor_ipi                AS DECIMAL      
    FIELD valor_icms_st            AS DECIMAL      
    FIELD valor_base_st            AS DECIMAL      
    FIELD valor_liquido            AS DECIMAL      
    FIELD valor_total_produto      AS DECIMAL      
    FIELD valor_aliquota_icms      AS DECIMAL      
    FIELD valor_aliquota_ipi       AS DECIMAL      
    FIELD valor_aliquota_pis       AS DECIMAL      
    FIELD valor_aliquota_cofins    AS DECIMAL      
    FIELD data_validade            AS DATE         
    FIELD valor_despesa            AS DECIMAL      
    FIELD valor_tributos           AS DECIMAL
    FIELD valor_cstb_icms          AS CHAR
    FIELD valor_cstb_pis           AS CHARACTER    
    FIELD valor_cstb_cofins        AS CHARACTER    
    FIELD valor_base_pis           AS DECIMAL      
    FIELD valor_pis                AS DECIMAL      
    FIELD valor_base_cofins        AS DECIMAL      
    FIELD valor_cofins             AS DECIMAL      
    FIELD valor_redutor_base_icms  AS DECIMAL      
    FIELD sequencia_origem         AS INTEGER      
    FIELD peso_bruto               AS DECIMAL      
    FIELD peso_liquido             AS DECIMAL      
    FIELD valor_frete              AS DECIMAL      
    FIELD valor_seguro             AS DECIMAL      
    FIELD valor_embalagem          AS DECIMAL      
    FIELD valor_outras_despesas    AS DECIMAL      
    FIELD valor_cst_ipi            AS DECIMAL      
    FIELD valor_modbc_icms         AS DECIMAL      
    FIELD valor_modb_cst           AS DECIMAL      
    FIELD valor_modb_ipi           AS DECIMAL      
    FIELD valor_icms_substituto    AS DECIMAL      
    FIELD valor_base_cst_ret       AS DECIMAL      
    FIELD valor_icms_ret           AS DECIMAL      
.
  

DEF TEMP-TABLE tt-condicao_pagamento NO-UNDO
    FIELD pedido_id             AS CHAR
    FIELD PARCELA               AS CHAR
    FIELD CONDICAO_PAGAMENTO    AS CHAR
    FIELD vencimento            AS DATE    
    FIELD ADM_ID                AS CHAR
    FIELD ADQUIRENTE_ID         AS CHAR
    FIELD NSU                   AS CHAR
    FIELD AUTORIZACAO           AS CHAR
    FIELD adm_taxa              AS DEC
    FIELD valor                 AS DEC
    FIELD origem_pagamento      AS CHAR
    FIELD CONVENIO              AS CHAR.    
    
    
def temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    FIELD r-int_ds_nota_loja    AS ROWID.
    
DEFINE VARIABLE i-status AS INTEGER   NO-UNDO.
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.   
DEFINE VARIABLE r-int-ds-nota-loja AS ROWID       NO-UNDO.
DEFINE VARIABLE d-id-sequencial    AS INT         NO-UNDO.
DEFINE VARIABLE dup-id-sequencial  AS CHAR         NO-UNDO.

/* Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.

define temp-table tt-erros no-undo
       FIELD CNPJDEV                      AS CHAR
       FIELD NumeroNota                   as char format "x(60)"
       field numeroDev                       as int  format "99999"
       FIELD DATADEV                        AS DATE
       field desc-erro                      as char format "x(60)"
       field tabela                         as char format "x(20)"
       FIELD situacao                       AS INT
       field l-erro                         as logical initial yes.
/* FIM - Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */

DEF DATASET DSNotas FOR nota_fiscal, itens , condicao_pagamento
    DATA-RELATION r1 FOR nota_fiscal, itens
        RELATION-FIELDS(pedido_ID,pedido_id) NESTED
    DATA-RELATION r2 FOR nota_fiscal, condicao_pagamento
        RELATION-FIELDS(pedido_id,pedido_id) NESTED.

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

FUNCTION FndeParaCondPagto RETURNS CHAR (INPUT p-cond-pagto AS CHAR):

    CASE p-cond-pagto:
        WHEN "dinheiro"  THEN RETURN "01".
        WHEN "cartao"   THEN RETURN "02".
        WHEN "pix "     THEN RETURN "01".
        WHEN "convenio"  THEN RETURN "01".
        WHEN "credito"  THEN RETURN "02" .
        WHEN "valecredito"  THEN RETURN "01".
        



    END CASE.

    RETURN "NOK".
END FUNCTION.

PROCEDURE pi-nota-fiscal-emitida:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    log-manager:write-message("KML - entrou procedure Notas fiscais") no-error.
        
    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).


    //MESSAGE string(jsonAux:GetJsonArray("CUPOM-FISCAL"):getJsonText())
        //VIEW-AS ALERT-BOX INFO BUTTONS OK.

    DATASET DSNotas:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    jsonOutput = NEW JSONObject().
    
    FOR FIRST nota_fiscal:
       
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cgc = nota_fiscal.emitente_cnpj NO-ERROR.
            
        log-manager:write-message("KML - Antes IF AVAIL ESTABELEC" + estabelec.cgc ) no-error.    
            
            IF NOT AVAIL estabelec THEN
            DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = 17001
                       RowErrors.ErrorDescription = "ESTABELECIMENTO INEXISTENTE"
                       RowErrors.ErrorHelp = "ESTABELECIMENTO INEXISTENTE"
                       RowErrors.ErrorSubType = "ERROR".
                    
                                   
                    IF CAN-FIND(FIRST RowErrors) THEN DO:
                    
                        oResponse = NEW JsonAPIResponse(jsonInput).
                        oResponse:setHasNext(FALSE).
                        oResponse:setStatus(400).
                        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                        jsonOutput = oResponse:createJsonResponse().
                    END.                       

            RETURN "NOK".
            END.
                        
            CREATE TT-NOTA-FISCAL-EMITIDA.
            ASSIGN TT-NOTA-FISCAL-EMITIDA.chave_acesso                  = nota_fiscal.chave_acesso                  
                   TT-NOTA-FISCAL-EMITIDA.versao                        = nota_fiscal.versao                        
                   TT-NOTA-FISCAL-EMITIDA.especie                       = nota_fiscal.especie                       
                   TT-NOTA-FISCAL-EMITIDA.modelo                        = nota_fiscal.modelo                        
                   TT-NOTA-FISCAL-EMITIDA.numero                        = nota_fiscal.numero                        
                   TT-NOTA-FISCAL-EMITIDA.serie                         = nota_fiscal.serie                         
                   TT-NOTA-FISCAL-EMITIDA.data_emissao                  = nota_fiscal.data_emissao                  
                   TT-NOTA-FISCAL-EMITIDA.pedido_id                     = nota_fiscal.pedido_id                     
                   TT-NOTA-FISCAL-EMITIDA.tipo_pedido                   = nota_fiscal.tipo_pedido                   
                   TT-NOTA-FISCAL-EMITIDA.tipo_nota                     = nota_fiscal.tipo_nota                     
                   TT-NOTA-FISCAL-EMITIDA.situacao                      = nota_fiscal.situacao                      
                   TT-NOTA-FISCAL-EMITIDA.emitente_cnpj                 = nota_fiscal.emitente_cnpj                 
                   TT-NOTA-FISCAL-EMITIDA.destinatario_cnpj             = nota_fiscal.destinatario_cnpj             
                   TT-NOTA-FISCAL-EMITIDA.transportadora_cnpj           = nota_fiscal.transportadora_cnpj           
                   TT-NOTA-FISCAL-EMITIDA.transportadora_veiculo_placa  = nota_fiscal.transportadora_veiculo_placa  
                   TT-NOTA-FISCAL-EMITIDA.transportadora_veiculo_estado = nota_fiscal.transportadora_veiculo_estado 
                   TT-NOTA-FISCAL-EMITIDA.transportadora_reboque_placa  = nota_fiscal.transportadora_reboque_placa  
                   TT-NOTA-FISCAL-EMITIDA.transportadora_reboque_estado = nota_fiscal.transportadora_reboque_estado 
                   TT-NOTA-FISCAL-EMITIDA.observacao                    = nota_fiscal.observacao                     
                   TT-NOTA-FISCAL-EMITIDA.nota_fiscal_origem            = nota_fiscal.nota_fiscal_origem             
                   TT-NOTA-FISCAL-EMITIDA.serie_origem                  = nota_fiscal.serie_origem                  
                   TT-NOTA-FISCAL-EMITIDA.tipo_ambiente_nfe             = nota_fiscal.tipo_ambiente_nfe             
                   TT-NOTA-FISCAL-EMITIDA.protocolo                     = nota_fiscal.protocolo                     
                   TT-NOTA-FISCAL-EMITIDA.cfop                          = nota_fiscal.cfop                          
                   TT-NOTA-FISCAL-EMITIDA.quantidade                    = nota_fiscal.quantidade                    
                   TT-NOTA-FISCAL-EMITIDA.valor_desconto                = nota_fiscal.valor_desconto                
                   TT-NOTA-FISCAL-EMITIDA.valor_base_icms               = nota_fiscal.valor_base_icms               
                   TT-NOTA-FISCAL-EMITIDA.valor_icms                    = nota_fiscal.valor_icms                    
                   TT-NOTA-FISCAL-EMITIDA.valor_base_diferido           = nota_fiscal.valor_base_diferido           
                   TT-NOTA-FISCAL-EMITIDA.valor_base_isenta             = nota_fiscal.valor_base_isenta             
                   TT-NOTA-FISCAL-EMITIDA.valor_base_ipi                = nota_fiscal.valor_base_ipi                
                   TT-NOTA-FISCAL-EMITIDA.valor_ipi                     = nota_fiscal.valor_ipi                     
                   TT-NOTA-FISCAL-EMITIDA.valor_base_st                 = nota_fiscal.valor_base_st                 
                   TT-NOTA-FISCAL-EMITIDA.valor_icms_st                 = nota_fiscal.valor_icms_st                 
                   TT-NOTA-FISCAL-EMITIDA.valor_total_produtos          = nota_fiscal.valor_total_produtos          
                   TT-NOTA-FISCAL-EMITIDA.peso_bruto                    = nota_fiscal.peso_bruto                    
                   TT-NOTA-FISCAL-EMITIDA.peso_liquido                  = nota_fiscal.peso_liquido                  
                   TT-NOTA-FISCAL-EMITIDA.valor_frete                   = nota_fiscal.valor_frete                   
                   TT-NOTA-FISCAL-EMITIDA.valor_seguro                  = nota_fiscal.valor_seguro                  
                   TT-NOTA-FISCAL-EMITIDA.valor_embalagem               = nota_fiscal.valor_embalagem               
                   TT-NOTA-FISCAL-EMITIDA.valor_outras_despesas         = nota_fiscal.valor_outras_despesas         
                   TT-NOTA-FISCAL-EMITIDA.volumes_marca                 = nota_fiscal.volumes_marca                 
                   TT-NOTA-FISCAL-EMITIDA.volumes_quantidade            = nota_fiscal.volumes_quantidade            
                   TT-NOTA-FISCAL-EMITIDA.modalidade_frete              = nota_fiscal.modalidade_frete              
                   TT-NOTA-FISCAL-EMITIDA.data_cancelamento             = nota_fiscal.data_cancelamento.             
        
              
    END.
    
    FOR EACH itens:
        
        CREATE tt-itens.
        ASSIGN tt-itens.sequencia                = itens.sequencia                
               tt-itens.produto                  = itens.produto                  
               tt-itens.caixa                    = itens.caixa                    
               tt-itens.lote                     = itens.lote                     
               tt-itens.quantidade               = itens.quantidade               
               tt-itens.cfop                     = itens.cfop                     
               tt-itens.ncm                      = itens.ncm                      
               tt-itens.valor_bruto              = itens.valor_bruto              
               tt-itens.valor_desconto           = itens.valor_desconto           
               tt-itens.valor_base_icms          = itens.valor_base_icms          
               tt-itens.valor_icms               = itens.valor_icms               
               tt-itens.valor_base_diferido      = itens.valor_base_diferido      
               tt-itens.valor_base_isenta        = itens.valor_base_isenta        
               tt-itens.valor_base_ipi           = itens.valor_base_ipi           
               tt-itens.valor_ipi                = itens.valor_ipi                
               tt-itens.valor_icms_st            = itens.valor_icms_st            
               tt-itens.valor_base_st            = itens.valor_base_st            
               tt-itens.valor_liquido            = itens.valor_liquido            
               tt-itens.valor_total_produto      = itens.valor_total_produto      
               tt-itens.valor_aliquota_icms      = itens.valor_aliquota_icms      
               tt-itens.valor_aliquota_ipi       = itens.valor_aliquota_ipi       
               tt-itens.valor_aliquota_pis       = itens.valor_aliquota_pis       
               tt-itens.valor_aliquota_cofins    = itens.valor_aliquota_cofins    
               tt-itens.data_validade            = itens.data_validade            
               tt-itens.valor_despesa            = itens.valor_despesa            
               tt-itens.valor_tributos           = itens.valor_tributos           
               tt-itens.valor_cstb_pis           = itens.valor_cstb_pis           
               tt-itens.valor_cstb_cofins        = itens.valor_cstb_cofins        
               tt-itens.valor_base_pis           = itens.valor_base_pis           
               tt-itens.valor_pis                = itens.valor_pis                
               tt-itens.valor_base_cofins        = itens.valor_base_cofins        
               tt-itens.valor_cofins             = itens.valor_cofins             
               tt-itens.valor_redutor_base_icms  = itens.valor_redutor_base_icms  
               tt-itens.sequencia_origem         = itens.sequencia_origem         
               tt-itens.peso_bruto               = itens.peso_bruto               
               tt-itens.peso_liquido             = itens.peso_liquido             
               tt-itens.valor_frete              = itens.valor_frete              
               tt-itens.valor_seguro             = itens.valor_seguro             
               tt-itens.valor_embalagem          = itens.valor_embalagem          
               tt-itens.valor_outras_despesas    = itens.valor_outras_despesas    
               tt-itens.valor_cst_ipi            = itens.valor_cst_ipi
               tt-itens.valor_cstb_icms          = itens.valor_cstb_icms
               tt-itens.valor_modbc_icms         = itens.valor_modbc_icms         
               tt-itens.valor_modb_cst           = itens.valor_modb_cst           
               tt-itens.valor_modb_ipi           = itens.valor_modb_ipi
               tt-itens.valor_icms_substituto    = itens.valor_icms_substituto    
               tt-itens.valor_base_cst_ret       = itens.valor_base_cst_ret       
               tt-itens.valor_icms_ret           = itens.valor_icms_ret.           
                      
    END.
    
    FOR EACH condicao_pagamento:
    
        CREATE tt-condicao_pagamento.                   
        ASSIGN tt-condicao_pagamento.PARCELA            = condicao_pagamento.PARCELA           
               tt-condicao_pagamento.CONDICAO_PAGAMENTO = FndeParaCondPagto(condicao_pagamento.CONDICAO_PAGAMENTO)
               tt-condicao_pagamento.vencimento         = condicao_pagamento.vencimento        
               tt-condicao_pagamento.ADM_ID             = condicao_pagamento.ADM_ID            
               tt-condicao_pagamento.ADQUIRENTE_ID      = condicao_pagamento.ADQUIRENTE_ID     
               tt-condicao_pagamento.NSU                = condicao_pagamento.NSU               
               tt-condicao_pagamento.AUTORIZACAO        = condicao_pagamento.AUTORIZACAO       
               tt-condicao_pagamento.adm_taxa           = condicao_pagamento.adm_taxa
               tt-condicao_pagamento.valor              = condicao_pagamento.valor
               tt-condicao_pagamento.origem_pagamento   = condicao_pagamento.origem_pagamento  
               tt-condicao_pagamento.CONVENIO           = condicao_pagamento.CONVENIO.          
              
    END.
    
    for_notas:
    DO TRANS ON ERROR UNDO, LEAVE:
     
        FOR EACH TT-NOTA-FISCAL-EMITIDA:
    
            find first int_ds_tipo_pedido no-lock
                where int_ds_tipo_pedido.tp_pedido = string(TT-NOTA-FISCAL-EMITIDA.tipo_pedido) no-error. 

            IF not AVAIL int_ds_tipo_pedido  THEN
            DO:
 
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = 17001
                       RowErrors.ErrorDescription = "Tipo de Pedido inexistente no int115"
                       RowErrors.ErrorHelp = "Tipo de Pedido inexistente no int115"
                       RowErrors.ErrorSubType = "ERROR".
                    
                                   
                    IF CAN-FIND(FIRST RowErrors) THEN DO:

                        oResponse = NEW JsonAPIResponse(jsonInput).
                        oResponse:setHasNext(FALSE).
                        oResponse:setStatus(400).
                        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                        jsonOutput = oResponse:createJsonResponse().
                    END.   
            END.
                  
         
            IF TT-NOTA-FISCAL-EMITIDA.pedido_id <> ? 
            AND TT-NOTA-FISCAL-EMITIDA.pedido_id <> 0 THEN DO:
 
                FIND FIRST int_ds_pedido NO-LOCK
                WHERE int_ds_pedido.ped_codigo_n = TT-NOTA-FISCAL-EMITIDA.pedido_id NO-ERROR.

                IF AVAIL int_ds_pedido  THEN
                DO:

                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17001
                           RowErrors.ErrorDescription = "Pedido ja existe na base"
                           RowErrors.ErrorHelp = "Pedido ja existe na base"
                           RowErrors.ErrorSubType = "ERROR".


                        IF CAN-FIND(FIRST RowErrors) THEN DO:

                            oResponse = NEW JsonAPIResponse(jsonInput).
                            oResponse:setHasNext(FALSE).
                            oResponse:setStatus(400).
                            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                            jsonOutput = oResponse:createJsonResponse().
                        END.

                        log-manager:write-message("KML - Antes undo 0") no-error.        
                        UNDO for_notas, LEAVE for_notas.
                END.
               
                CREATE INT_DS_PEDIDO.
                ASSIGN int_ds_pedido.situacao              = 2
                       int_ds_pedido.ped_codigo_n          = TT-NOTA-FISCAL-EMITIDA.pedido_id     
                       int_ds_pedido.dt_geracao            = TT-NOTA-FISCAL-EMITIDA.data_emissao
                       int_ds_pedido.ped_data_d            = TT-NOTA-FISCAL-EMITIDA.data_emissao
                       int_ds_pedido.ped_dataentrega_d     = TT-NOTA-FISCAL-EMITIDA.data_emissao
                       int_ds_pedido.ped_cnpj_origem_s     = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                       int_ds_pedido.ped_cnpj_destino_s    = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                       int_ds_pedido.ped_quantidade_n      = ?
                       int_ds_pedido.ped_valortotalbruto_n = ?
                       int_ds_pedido.ped_tipopedido_n      = TT-NOTA-FISCAL-EMITIDA.tipo_pedido
                       int_ds_pedido.envio_status          = 2.
         

                FOR EACH tt-itens:
                    
                    CREATE int_ds_pedido_produto.
                    ASSIGN int_ds_pedido_produto.ped_codigo_n     = TT-NOTA-FISCAL-EMITIDA.pedido_id
                           int_ds_pedido_produto.ppr_produto_n    = tt-itens.produto
                           int_ds_pedido_produto.ppr_quantidade_n = tt-itens.quantidade
                           int_ds_pedido_produto.ppr_valorbruto_n = ?
                           int_ds_pedido_produto.ppr_percentualdesconto_n = ?
                           int_ds_pedido_produto.ppr_valorliquido_n       = ?
                           int_ds_pedido_produto.ppr_descricaocompl_s     = ?
                           int_ds_pedido_produto.nen_notafiscal_n         = ?
                           int_ds_pedido_produto.nen_serie                = ?
                           int_ds_pedido_produto.nep_sequencia_n          = 0.
                     
                    CREATE int_ds_pedido_retorno.
                    ASSIGN int_ds_pedido_retorno.ped_codigo_n         = TT-NOTA-FISCAL-EMITIDA.pedido_id
                           int_ds_pedido_retorno.ppr_produto_n        = tt-itens.produto
                           int_ds_pedido_retorno.rpp_caixa_n          = tt-itens.caixa  
                           //int_ds_pedido_retorno.rpp_validade_d       = tt-itens.lote 
                           int_ds_pedido_retorno.rpp_quantidade_n     = tt-itens.quantidade
                           //int_ds_pedido_retorno.rpp_qtd_inventario_n = tt-pedido-item.quantidade_inventario
                       .
                             
                      
                    END.
            // END?           
            END.

                

            FIND FIRST int_dp_nota_saida NO-LOCK 
                WHERE int_dp_nota_saida.nsa_cnpj_origem_s         = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                AND   int_dp_nota_saida.nsa_notafiscal_n          = TT-NOTA-FISCAL-EMITIDA.numero
                AND   int_dp_nota_saida.nsa_serie_s               = TT-NOTA-FISCAL-EMITIDA.serie NO-ERROR.

            IF AVAIL int_dp_nota_saida   THEN
            DO:
            
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = 17001
                       RowErrors.ErrorDescription = "Registro j  existe na tabela!"
                       RowErrors.ErrorHelp = "Registro j  existe na tabela!"
                       RowErrors.ErrorSubType = "ERROR".
                    
                                   
                    IF CAN-FIND(FIRST RowErrors) THEN DO:

                        oResponse = NEW JsonAPIResponse(jsonInput).
                        oResponse:setHasNext(FALSE).
                        oResponse:setStatus(400).
                        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                        jsonOutput = oResponse:createJsonResponse().
                    END.                       

                    log-manager:write-message("KML - Antes undo 1") no-error.         
                    UNDO for_notas, LEAVE for_notas.       
            
            //RETURN "NOK".
            END.
                
            FOR LAST int_dp_nota_saida NO-LOCK:
                ASSIGN d-id-sequencial = int_dp_nota_saida.ID_SEQUENCIAL + 1.
            END.

            CREATE int_dp_nota_saida.
            ASSIGN int_dp_nota_saida.tipo_movto                 = 1 
                   int_dp_nota_saida.dt_geracao                 = TT-NOTA-FISCAL-EMITIDA.data_emissao
                   //int_dp_nota_saida.hr_geracao                = 
                   int_dp_nota_saida.situacao                   = 1
                   int_dp_nota_saida.nsa_cnpj_origem_s          = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                   int_dp_nota_saida.nsa_cnpj_destino_s         = TT-NOTA-FISCAL-EMITIDA.destinatario_cnpj
                   int_dp_nota_saida.nsa_notafiscal_n           = TT-NOTA-FISCAL-EMITIDA.numero //Datasul ir  emitir?
                   int_dp_nota_saida.nsa_serie_s                = TT-NOTA-FISCAL-EMITIDA.serie //Datasul ir  emitir?
                   int_dp_nota_saida.nsa_dataemissao_d          = TT-NOTA-FISCAL-EMITIDA.data_emissao
                   int_dp_nota_saida.nsa_cfop_n                 = TT-NOTA-FISCAL-EMITIDA.cfop 
                   int_dp_nota_saida.nsa_quantidade_n           = TT-NOTA-FISCAL-EMITIDA.quantidade
                   int_dp_nota_saida.nsa_desconto_n             = TT-NOTA-FISCAL-EMITIDA.valor_desconto
                   int_dp_nota_saida.nsa_baseicms_n             = TT-NOTA-FISCAL-EMITIDA.valor_base_icms      
                   int_dp_nota_saida.nsa_valoricms_n            = TT-NOTA-FISCAL-EMITIDA.valor_icms           
                   int_dp_nota_saida.nsa_basediferido_n         = TT-NOTA-FISCAL-EMITIDA.valor_base_diferido  
                   int_dp_nota_saida.nsa_baseisenta_n           = TT-NOTA-FISCAL-EMITIDA.valor_base_isenta    
                   int_dp_nota_saida.nsa_baseipi_n              = TT-NOTA-FISCAL-EMITIDA.valor_base_ipi       
                   int_dp_nota_saida.nsa_valoripi_n             = TT-NOTA-FISCAL-EMITIDA.valor_ipi            
                   int_dp_nota_saida.nsa_basest_n               = TT-NOTA-FISCAL-EMITIDA.valor_base_st        
                   int_dp_nota_saida.nsa_icmsst_n               = TT-NOTA-FISCAL-EMITIDA.valor_icms_st        
                   int_dp_nota_saida.nsa_valortotalprodutos_n   = TT-NOTA-FISCAL-EMITIDA.valor_total_produtos 
                   int_dp_nota_saida.nsa_cnpj_transportadora_s  = TT-NOTA-FISCAL-EMITIDA.transportadora_cnpj
                   int_dp_nota_saida.nsa_placaveiculo_s         = TT-NOTA-FISCAL-EMITIDA.transportadora_veiculo_placa
                   int_dp_nota_saida.nsa_estadoveiculo_s        = TT-NOTA-FISCAL-EMITIDA.transportadora_veiculo_estado
                   int_dp_nota_saida.nsa_placareboque_s         = TT-NOTA-FISCAL-EMITIDA.transportadora_reboque_placa
                   int_dp_nota_saida.nsa_estadoreboque_s        = TT-NOTA-FISCAL-EMITIDA.transportadora_reboque_estado
                   int_dp_nota_saida.nsa_observacao_s           = TT-NOTA-FISCAL-EMITIDA.observacao
                   int_dp_nota_saida.nsa_chaveacesso_s          = TT-NOTA-FISCAL-EMITIDA.chave_acesso //TT-NOTA-FISCAL-EMITIDA.tipo_ambiente_nfe
                   int_dp_nota_saida.ped_tipopedido_n           = TT-NOTA-FISCAL-EMITIDA.tipo_pedido
                   int_dp_nota_saida.nen_notafiscalorigem_n     = TT-NOTA-FISCAL-EMITIDA.nota_fiscal_origem
                   int_dp_nota_saida.nen_serieorigem_s          = TT-NOTA-FISCAL-EMITIDA.serie_origem
                   int_dp_nota_saida.nsa_tipoambientenfe_n      = TT-NOTA-FISCAL-EMITIDA.tipo_ambiente_nfe
                   int_dp_nota_saida.nsa_protocolonfe_s         = TT-NOTA-FISCAL-EMITIDA.protocolo
                   int_dp_nota_saida.nsa_pesobruto_n            = TT-NOTA-FISCAL-EMITIDA.peso_bruto  
                   int_dp_nota_saida.nsa_pesoliquido_n          = TT-NOTA-FISCAL-EMITIDA.peso_liquido
                   int_dp_nota_saida.nsa_valorfrete_n           = TT-NOTA-FISCAL-EMITIDA.valor_frete          
                   int_dp_nota_saida.nsa_valorseguro_n          = TT-NOTA-FISCAL-EMITIDA.valor_seguro         
                   int_dp_nota_saida.nsa_valorembalagem_n       = TT-NOTA-FISCAL-EMITIDA.valor_embalagem      
                   int_dp_nota_saida.nsa_valoroutrasdesp_n      = TT-NOTA-FISCAL-EMITIDA.valor_outras_despesas
                   int_dp_nota_saida.nsa_marcavolumes_s         = TT-NOTA-FISCAL-EMITIDA.volumes_marca      
                   int_dp_nota_saida.nsa_quantvolumes_n         = TT-NOTA-FISCAL-EMITIDA.volumes_quantidade 
                   int_dp_nota_saida.nsa_modalidadefrete_n      = TT-NOTA-FISCAL-EMITIDA.modalidade_frete   
                   int_dp_nota_saida.nsa_datacancelamento_d     = TT-NOTA-FISCAL-EMITIDA.data_cancelamento
                   int_dp_nota_saida.nsa_datacupomorigem_ecf    = ?
                   int_dp_nota_saida.nsa_modelocupom_s          = TT-NOTA-FISCAL-EMITIDA.modelo
                   int_dp_nota_saida.nsa_numeroserieecf_s       = string(TT-NOTA-FISCAL-EMITIDA.serie_origem)
                   int_dp_nota_saida.nsa_caixaecf_s             = ?
                   int_dp_nota_saida.nsa_cupomorigem_s          = string(TT-NOTA-FISCAL-EMITIDA.nota_fiscal_origem)
                   int_dp_nota_saida.ped_codigo_n               = TT-NOTA-FISCAL-EMITIDA.pedido_id
                   int_dp_nota_saida.ENVIO_DATA_HORA            = TT-NOTA-FISCAL-EMITIDA.data_emissao
                   int_dp_nota_saida.ENVIO_ERRO                 = ""
                   int_dp_nota_saida.ENVIO_STATUS               = 04
                   int_dp_nota_saida.ID_SEQUENCIAL              = d-id-sequencial //456180 //criar um for last
                   int_dp_nota_saida.retorno_validacao          = "".
            
            
            IF TT-NOTA-FISCAL-EMITIDA.tipo_pedido = 48  THEN DO:

                ASSIGN int_dp_nota_saida.nen_notafiscalorigem_n     = ?
                       int_dp_nota_saida.nen_serieorigem_s          = ?.
            END.

            


            RELEASE int_dp_nota_saida.

            FOR EACH tt-itens: // Fazer find ou for para buscar int_dp_nota_devolucao   

                log-manager:write-message("KML - CSTB -" + tt-itens.valor_cstb_icms) no-error. 
                
                CREATE int_dp_nota_saida_item.
                ASSIGN int_dp_nota_saida_item.nsa_cnpj_origem_s          = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                       int_dp_nota_saida_item.nsa_notafiscal_n           = TT-NOTA-FISCAL-EMITIDA.numero // S¢ pra testar
                       int_dp_nota_saida_item.nsa_serie_s                = TT-NOTA-FISCAL-EMITIDA.serie      //mesma coisa 
                       int_dp_nota_saida_item.nsi_sequencia_n            = tt-itens.sequencia                
                       int_dp_nota_saida_item.nsi_produto_n              = tt-itens.produto                  
                       int_dp_nota_saida_item.nsi_caixa_n                = tt-itens.caixa                    
                       int_dp_nota_saida_item.nsi_lote_s                 = tt-itens.lote                     
                       int_dp_nota_saida_item.nsi_quantidade_n           = tt-itens.quantidade               
                       int_dp_nota_saida_item.nsi_cfop_n                 = tt-itens.cfop                     
                       int_dp_nota_saida_item.nsi_ncm_s                  = tt-itens.ncm                      
                       int_dp_nota_saida_item.nsi_valorbruto_n           = tt-itens.valor_bruto              
                       int_dp_nota_saida_item.nsi_desconto_n             = tt-itens.valor_desconto           
                       int_dp_nota_saida_item.nsi_baseicms_n             = tt-itens.valor_base_icms               
                       int_dp_nota_saida_item.nsi_valoricms_n            = tt-itens.valor_icms               
                       int_dp_nota_saida_item.nsi_basediferido_n         = tt-itens.valor_base_diferido      
                       int_dp_nota_saida_item.nsi_baseisenta_n           = tt-itens.valor_base_isenta        
                       int_dp_nota_saida_item.nsi_baseipi_n              = tt-itens.valor_base_ipi           
                       int_dp_nota_saida_item.nsi_valoripi_n             = tt-itens.valor_ipi                
                       int_dp_nota_saida_item.nsi_icmsst_n               = tt-itens.valor_icms_st              
                       int_dp_nota_saida_item.nsi_basest_n               = tt-itens.valor_base_st                
                       int_dp_nota_saida_item.nsi_valorliquido_n         = tt-itens.valor_liquido            
                       int_dp_nota_saida_item.nsi_valortotalproduto_n    = tt-itens.valor_total_produto      
                       int_dp_nota_saida_item.nsi_percentualicms_n       = tt-itens.valor_aliquota_icms      
                       int_dp_nota_saida_item.nsi_percentualipi_n        = tt-itens.valor_aliquota_ipi       
                       int_dp_nota_saida_item.nsi_percentualpis_n        = tt-itens.valor_aliquota_pis       
                       int_dp_nota_saida_item.nsi_percentualcofins_n     = tt-itens.valor_aliquota_cofins    
                       int_dp_nota_saida_item.nsi_datavalidade_d         = tt-itens.data_validade            
                       int_dp_nota_saida_item.nsi_valordespesa_n         = tt-itens.valor_despesa            
                       int_dp_nota_saida_item.nsi_valortributos_n        = tt-itens.valor_tributos           
                       int_dp_nota_saida_item.nsi_cstbpis_s              = tt-itens.valor_cstb_pis           
                       int_dp_nota_saida_item.nsi_cstbcofins_s           = tt-itens.valor_cstb_cofins        
                       int_dp_nota_saida_item.nsi_basepis_n              = tt-itens.valor_base_pis           
                       int_dp_nota_saida_item.nsi_valorpis_n             = tt-itens.valor_pis                
                       int_dp_nota_saida_item.nsi_basecofins_n           = tt-itens.valor_base_cofins          
                       int_dp_nota_saida_item.nsi_valorcofins_n          = tt-itens.valor_cofins             
                       int_dp_nota_saida_item.nsi_csta_n                 = ?
                       int_dp_nota_saida_item.nsi_cstb_n                 = int(tt-itens.valor_cstb_icms)        
                       int_dp_nota_saida_item.nsi_redutorbaseicms_n      = tt-itens.valor_redutor_base_icms  
                       int_dp_nota_saida_item.nep_sequenciaorigem_n      = tt-itens.sequencia_origem         
                       int_dp_nota_saida_item.nsi_pesobruto_n            = tt-itens.peso_bruto             
                       int_dp_nota_saida_item.nsi_pesoliquido_n          = tt-itens.peso_liquido           
                       int_dp_nota_saida_item.nsi_valorfrete_n           = tt-itens.valor_frete            
                       int_dp_nota_saida_item.nsi_valorseguro_n          = tt-itens.valor_seguro           
                       int_dp_nota_saida_item.nsi_valorembalagem_n       = tt-itens.valor_embalagem        
                       int_dp_nota_saida_item.nsi_valoroutrasdesp_n      = tt-itens.valor_outras_despesas  
                       int_dp_nota_saida_item.nsi_cstbipi_n              = tt-itens.valor_cst_ipi          
                       int_dp_nota_saida_item.nsi_modbcicms_n            = tt-itens.valor_modbc_icms       
                       int_dp_nota_saida_item.nsi_modbcst_n              = tt-itens.valor_modb_cst         
                       int_dp_nota_saida_item.nsi_modbipi_n              = tt-itens.valor_modb_ipi         
                       int_dp_nota_saida_item.vICMSSubstituto            = tt-itens.valor_icms_substituto  
                       int_dp_nota_saida_item.vBCSTRet                   = tt-itens.valor_base_cst_ret   
                       int_dp_nota_saida_item.vICMSSRet                  = tt-itens.valor_icms_ret       
                   .
                   
                RELEASE int_dp_nota_saida_item. 
                                                                         
                FOR EACH tt-condicao_pagamento:
               
                    IF tt-condicao_pagamento.valor <> 0 AND TT-NOTA-FISCAL-EMITIDA.tipo_pedido <> 15 AND TT-NOTA-FISCAL-EMITIDA.tipo_pedido <> 20 AND TT-NOTA-FISCAL-EMITIDA.tipo_pedido <> 22 AND TT-NOTA-FISCAL-EMITIDA.tipo_pedido <> 23 THEN DO:
                       
                        CREATE int_dp_nota_saida_dup.
                        ASSIGN int_dp_nota_saida_dup.nsa_cnpj_origem_s    = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj
                               int_dp_nota_saida_dup.nsa_notafiscal_n     = TT-NOTA-FISCAL-EMITIDA.numero
                               int_dp_nota_saida_dup.nsa_serie_s          = TT-NOTA-FISCAL-EMITIDA.serie
                               int_dp_nota_saida_dup.nsa_duplicata_s      = "001" // fazer if para criar sequencia diferente
                               int_dp_nota_saida_dup.nsa_vencimento_d     = TODAY + 30
                               int_dp_nota_saida_dup.nsa_valorduplicata_n = TT-NOTA-FISCAL-EMITIDA.valor_total_produtos
                           .

                        RELEASE int_dp_nota_saida_dup.
                        
                        
                    END.


        /*                 FOR EACH int_dp_nota_saida NO-LOCK                                                   */
        /*                     WHERE int_dp_nota_saida.nsa_cnpj_origem_s = TT-NOTA-FISCAL-EMITIDA.emitente_cnpj */
        /*                     AND   int_dp_nota_saida.nsa_notafiscal_n  = TT-NOTA-FISCAL-EMITIDA.numero        */
        /*                     AND   int_dp_nota_saida.nsa_serie_s       = TT-NOTA-FISCAL-EMITIDA.serie:        */

                            //log-manager:write-message("KML - DENTRO CREATE DEVOL" + int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s) no-error.
                            //log-manager:write-message("KML - DENTRO CREATE CONDIPAG" + tt-condicao_pagamento.CONDICAO_PAGAMENTO) no-error.



                       
                       
    
            
                END.                                                                                                                         
            END.
        END.    

        run intprg/int217HUBrp.p (INPUT TABLE TT-NOTA-FISCAL-EMITIDA,      //tt-nota-devolucao para executar o int217 isolado por nota
                                  OUTPUT TABLE tt-erros).


        jsonOutput = NEW JSONObject().
        FIND FIRST tt-erros NO-LOCK NO-ERROR.
          

        IF tt-erros.l-erro = YES THEN // no caso vou usar NO sem erro kk
        DO:
        
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = tt-erros.desc-erro
                   RowErrors.ErrorHelp = tt-erros.desc-erro
                   RowErrors.ErrorSubType = "ERROR".

                IF CAN-FIND(FIRST RowErrors) THEN DO:
                   oResponse = NEW JsonAPIResponse(jsonInput).
                   oResponse:setHasNext(FALSE).
                   oResponse:setStatus(400).
                   oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                   jsonOutput = oResponse:createJsonResponse().  
        
                END.
        
                log-manager:write-message("KML - Antes undo 2") no-error.    
                UNDO for_notas, LEAVE for_notas. 
        END.
        
        ELSE DO:
        
            jsonOutput:ADD("CNPJ-ORIGEM",tt-erros.CNPJDEV).
            //jsonOutput:ADD("serie"      ,tt-erros.NumeroNota).
            jsonOutput:ADD("nr-nota-fis",tt-erros.NumeroNota).
            //jsonOutput:ADD("chave-acesso",tt-erros.chave-acesso).
            //jsonOutput:ADD("NotaDEvol",tt-erros.numeroDev).
            jsonOutput:ADD("Informa‡Æo",tt-erros.desc-erro).    
           
        END.
    END.
//END.    

    IF NOT CAN-FIND(FIRST nota_fiscal) THEN DO:        

        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Erro na integra‡Æo de nota fiscal"
               RowErrors.ErrorHelp = "Erro na integra‡Æo de nota fiscal"
               RowErrors.ErrorSubType = "ERROR".
               
        

            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
               
             
            END.
    END.

    RETURN "OK".
    
END PROCEDURE.
