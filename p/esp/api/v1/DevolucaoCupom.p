//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-devolucao  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE nota_fiscal  NO-UNDO
    FIELD venda_id                      AS INT
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
    FIELD venda_id                 AS INT
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
    FIELD venda_id              AS INT
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
    
DEF TEMP-TABLE TT-NOTA-DEVOLUCAO  NO-UNDO  
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

DEF DATASET DScupom FOR nota_fiscal, itens , condicao_pagamento
    DATA-RELATION r1 FOR nota_fiscal, itens
        RELATION-FIELDS(VENDA_ID,Venda_id) NESTED
    DATA-RELATION r2 FOR nota_fiscal, condicao_pagamento
        RELATION-FIELDS(venda_id,venda_id) NESTED.

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

PROCEDURE pi-gera-devolucao:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    log-manager:write-message("KML - entrou procedure Devolucao") no-error.
        
    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).


    //MESSAGE string(jsonAux:GetJsonArray("CUPOM-FISCAL"):getJsonText())
        //VIEW-AS ALERT-BOX INFO BUTTONS OK.

    DATASET DScupom:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    jsonOutput = NEW JSONObject().
    
    FOR FIRST nota_fiscal:
    
        FIND FIRST estabelec NO-LOCK
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
                        
        CREATE tt-nota-devolucao.
        ASSIGN tt-nota-devolucao.chave_acesso                  = nota_fiscal.chave_acesso                  
               tt-nota-devolucao.versao                        = nota_fiscal.versao                        
               tt-nota-devolucao.especie                       = nota_fiscal.especie                       
               tt-nota-devolucao.modelo                        = nota_fiscal.modelo                        
               tt-nota-devolucao.numero                        = nota_fiscal.numero                        
               tt-nota-devolucao.serie                         = nota_fiscal.serie                         
               tt-nota-devolucao.data_emissao                  = nota_fiscal.data_emissao                  
               tt-nota-devolucao.pedido_id                     = nota_fiscal.pedido_id                     
               tt-nota-devolucao.tipo_pedido                   = nota_fiscal.tipo_pedido                   
               tt-nota-devolucao.tipo_nota                     = nota_fiscal.tipo_nota                     
               tt-nota-devolucao.situacao                      = nota_fiscal.situacao                      
               tt-nota-devolucao.emitente_cnpj                 = nota_fiscal.emitente_cnpj                 
               tt-nota-devolucao.destinatario_cnpj             = nota_fiscal.destinatario_cnpj             
               tt-nota-devolucao.transportadora_cnpj           = nota_fiscal.transportadora_cnpj           
               tt-nota-devolucao.transportadora_veiculo_placa  = nota_fiscal.transportadora_veiculo_placa  
               tt-nota-devolucao.transportadora_veiculo_estado = nota_fiscal.transportadora_veiculo_estado 
               tt-nota-devolucao.transportadora_reboque_placa  = nota_fiscal.transportadora_reboque_placa  
               tt-nota-devolucao.transportadora_reboque_estado = nota_fiscal.transportadora_reboque_estado 
               tt-nota-devolucao.observacao                    = nota_fiscal.observacao                     
               tt-nota-devolucao.nota_fiscal_origem            = nota_fiscal.nota_fiscal_origem             
               tt-nota-devolucao.serie_origem                  = nota_fiscal.serie_origem                  
               tt-nota-devolucao.tipo_ambiente_nfe             = nota_fiscal.tipo_ambiente_nfe             
               tt-nota-devolucao.protocolo                     = nota_fiscal.protocolo                     
               tt-nota-devolucao.cfop                          = nota_fiscal.cfop                          
               tt-nota-devolucao.quantidade                    = nota_fiscal.quantidade                    
               tt-nota-devolucao.valor_desconto                = nota_fiscal.valor_desconto                
               tt-nota-devolucao.valor_base_icms               = nota_fiscal.valor_base_icms               
               tt-nota-devolucao.valor_icms                    = nota_fiscal.valor_icms                    
               tt-nota-devolucao.valor_base_diferido           = nota_fiscal.valor_base_diferido           
               tt-nota-devolucao.valor_base_isenta             = nota_fiscal.valor_base_isenta             
               tt-nota-devolucao.valor_base_ipi                = nota_fiscal.valor_base_ipi                
               tt-nota-devolucao.valor_ipi                     = nota_fiscal.valor_ipi                     
               tt-nota-devolucao.valor_base_st                 = nota_fiscal.valor_base_st                 
               tt-nota-devolucao.valor_icms_st                 = nota_fiscal.valor_icms_st                 
               tt-nota-devolucao.valor_total_produtos          = nota_fiscal.valor_total_produtos          
               tt-nota-devolucao.peso_bruto                    = nota_fiscal.peso_bruto                    
               tt-nota-devolucao.peso_liquido                  = nota_fiscal.peso_liquido                  
               tt-nota-devolucao.valor_frete                   = nota_fiscal.valor_frete                   
               tt-nota-devolucao.valor_seguro                  = nota_fiscal.valor_seguro                  
               tt-nota-devolucao.valor_embalagem               = nota_fiscal.valor_embalagem               
               tt-nota-devolucao.valor_outras_despesas         = nota_fiscal.valor_outras_despesas         
               tt-nota-devolucao.volumes_marca                 = nota_fiscal.volumes_marca                 
               tt-nota-devolucao.volumes_quantidade            = nota_fiscal.volumes_quantidade            
               tt-nota-devolucao.modalidade_frete              = nota_fiscal.modalidade_frete              
               tt-nota-devolucao.data_cancelamento             = nota_fiscal.data_cancelamento.             
        
              
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
               tt-itens.valor_modbc_icms         = itens.valor_modbc_icms         
               tt-itens.valor_modb_cst           = itens.valor_modb_cst           
               tt-itens.valor_modb_ipi           = itens.valor_modb_ipi           
               tt-itens.valor_icms_substituto    = itens.valor_icms_substituto    
               tt-itens.valor_base_cst_ret       = itens.valor_base_cst_ret       
               tt-itens.valor_icms_ret           = itens.valor_icms_ret.           
                      
    END.
    
    FOR FIRST condicao_pagamento:
        
    
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
    
        FOR EACH tt-nota-devolucao:
        
            FIND FIRST int_dp_nota_devolucao NO-LOCK 
                 WHERE int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s = tt-nota-devolucao.destinatario_cnpj //era tt-nota-devolucao.emitente_cnpj
                 AND   int_dp_nota_devolucao.ndv_notafiscal_n          = tt-nota-devolucao.numero
                 AND   int_dp_nota_devolucao.ndv_serie_s               = tt-nota-devolucao.serie NO-ERROR.
                 
            IF AVAIL int_dp_nota_devolucao   THEN
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

                UNDO for_notas, LEAVE for_notas.
            END.
        
            CREATE int_dp_nota_devolucao.
            ASSIGN int_dp_nota_devolucao.tipo_movto                = ? 
                   int_dp_nota_devolucao.dt_geracao                = tt-nota-devolucao.data_emissao
                   //int_dp_nota_devolucao.hr_geracao                = 
                   int_dp_nota_devolucao.situacao                  = 1
                   int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s = tt-nota-devolucao.destinatario_cnpj //era tt-nota-devolucao.emitente_cnpj  07/10/2025
                   int_dp_nota_devolucao.ndv_cnpjfilialorigem_s    = tt-nota-devolucao.emitente_cnpj  
                   int_dp_nota_devolucao.ndv_notafiscal_n          = tt-nota-devolucao.numero //Datasul ir  emitir?
                   int_dp_nota_devolucao.ndv_serie_s               = tt-nota-devolucao.serie //Datasul ir  emitir?
                   int_dp_nota_devolucao.ndv_dataemissao_d         = tt-nota-devolucao.data_emissao
                   int_dp_nota_devolucao.ndv_cfop_n                = tt-nota-devolucao.cfop 
                   int_dp_nota_devolucao.ndv_quantidade_n          = tt-nota-devolucao.quantidade
                   int_dp_nota_devolucao.ndv_desconto_n            = tt-nota-devolucao.valor_desconto
                   int_dp_nota_devolucao.ndv_baseicms_n            = tt-nota-devolucao.valor_base_icms      
                   int_dp_nota_devolucao.ndv_valoricms_n           = tt-nota-devolucao.valor_icms           
                   int_dp_nota_devolucao.ndv_basediferido_n        = tt-nota-devolucao.valor_base_diferido  
                   int_dp_nota_devolucao.ndv_baseisenta_n          = tt-nota-devolucao.valor_base_isenta    
                   int_dp_nota_devolucao.ndv_baseipi_n             = tt-nota-devolucao.valor_base_ipi       
                   int_dp_nota_devolucao.ndv_valoripi_n            = tt-nota-devolucao.valor_ipi            
                   int_dp_nota_devolucao.ndv_basest_n              = tt-nota-devolucao.valor_base_st        
                   int_dp_nota_devolucao.ndv_icmsst_n              = tt-nota-devolucao.valor_icms_st        
                   int_dp_nota_devolucao.ndv_valortotalprodutos_n  = tt-nota-devolucao.valor_total_produtos 
                   int_dp_nota_devolucao.ndv_observacao_s          = tt-nota-devolucao.observacao
                   int_dp_nota_devolucao.ndv_cpf_cliente           = tt-nota-devolucao.destinatario_cnpj //era tt-nota-devolucao.emitente_cnpj // ONDE? // fazer for each na nota origem pra descobrir o cpf cliente...
                   int_dp_nota_devolucao.ndv_chaveacesso_s         = tt-nota-devolucao.chave_acesso // Chave origem origem ou devolu‡Æo?
                   int_dp_nota_devolucao.ndv_notaorigem_n          = tt-nota-devolucao.nota_fiscal_origem
                   int_dp_nota_devolucao.ndv_serieorigem_s         = tt-nota-devolucao.serie_origem      
                   int_dp_nota_devolucao.ndv_cupom_ecf_origem_s    = "" // CPF-CUPOM?
                   int_dp_nota_devolucao.ndv_tipoambientenfe_n     = tt-nota-devolucao.tipo_ambiente_nfe
                   int_dp_nota_devolucao.ndv_protocolonfe_s        = tt-nota-devolucao.protocolo
                   int_dp_nota_devolucao.ndv_datacancelamento_d    = tt-nota-devolucao.data_cancelamento.
                   
                   RELEASE int_dp_nota_devolucao.
                   
            FOR EACH tt-itens: // Fazer find ou for para buscar int_dp_nota_devolucao   
                
                CREATE int_dp_nota_devolucao_item.
                ASSIGN int_dp_nota_devolucao_item.ndv_cnpjfilialdevolucao_s   = tt-nota-devolucao.destinatario_cnpj //era tt-nota-devolucao.emitente_cnpj
                       int_dp_nota_devolucao_item.ndv_notafiscal_n            = tt-nota-devolucao.numero // S¢ pra testar
                       int_dp_nota_devolucao_item.ndv_serie_s                 = tt-nota-devolucao.serie      //mesma coisa 
                       int_dp_nota_devolucao_item.ndp_sequencia_n             = tt-itens.sequencia
                       int_dp_nota_devolucao_item.ndp_produto_n               = tt-itens.produto
                       int_dp_nota_devolucao_item.ndp_lote_s                  = tt-itens.lote
                       int_dp_nota_devolucao_item.ndp_quantidade_n            = tt-itens.quantidade
                       int_dp_nota_devolucao_item.ndp_cfop_n                  = tt-itens.cfop
                       int_dp_nota_devolucao_item.ndp_ncm_s                   = tt-itens.ncm                    
                       int_dp_nota_devolucao_item.ndp_baseicms_n              = tt-itens.valor_base_icm             
                       int_dp_nota_devolucao_item.ndp_valoricms_n             = tt-itens.valor_icms        
                       int_dp_nota_devolucao_item.ndp_basediferido_n          = tt-itens.valor_base_diferido       
                       int_dp_nota_devolucao_item.ndp_baseisenta_n            = tt-itens.valor_base_isenta               
                       int_dp_nota_devolucao_item.ndp_baseipi_n               = tt-itens.valor_base_ipi         
                       int_dp_nota_devolucao_item.ndp_valoripi_n              = tt-itens.valor_ipi    
                       int_dp_nota_devolucao_item.ndp_icmsst_n                = tt-itens.valor_icms_st     
                       int_dp_nota_devolucao_item.ndp_basest_n                = tt-itens.valor_base_st              
                       int_dp_nota_devolucao_item.ndp_valorliquido_n          = tt-itens.valor_liquido          
                       int_dp_nota_devolucao_item.ndp_valortotalproduto_n     = tt-itens.valor_total_produto          
                       int_dp_nota_devolucao_item.ndp_percentualicms_n        = tt-itens.valor_aliquota_icms            
                       int_dp_nota_devolucao_item.ndp_percentualipi_n         = tt-itens.valor_aliquota_ipi        
                       int_dp_nota_devolucao_item.ndp_percentualpis_n         = tt-itens.valor_aliquota_pis     
                       int_dp_nota_devolucao_item.ndp_percentualcofins_n      = tt-itens.valor_aliquota_cofins  
                       int_dp_nota_devolucao_item.ndp_datavalidade_d          = tt-itens.data_validade          
                       int_dp_nota_devolucao_item.ndp_cstbpis_s               = tt-itens.valor_cstb_pis
                       int_dp_nota_devolucao_item.ndp_cstbcofins_s            = tt-itens.valor_cstb_cofin          
                       int_dp_nota_devolucao_item.ndp_basepis_n               = tt-itens.valor_base_pis          
                       int_dp_nota_devolucao_item.ndp_valorpis_n              = tt-itens.valor_pis               
                       int_dp_nota_devolucao_item.ndp_basecofins_n            = tt-itens.valor_base_cofins          
                       int_dp_nota_devolucao_item.ndp_valorcofins_n           = tt-itens.valor_cofins            
                       int_dp_nota_devolucao_item.ndp_peso_n                  = tt-itens.peso_liquido       
                       int_dp_nota_devolucao_item.ndp_csta_icms_n             = tt-itens.valor_modbc_icms          
                       int_dp_nota_devolucao_item.ndp_cstb_icms_n             = tt-itens.valor_modb_cst     
                       int_dp_nota_devolucao_item.ndp_redutorbaseicms_n       = tt-itens.valor_redutor_base_icms      
                       int_dp_nota_devolucao_item.ndp_sequenciaorigem_n       = tt-itens.sequencia_origem           
                       int_dp_nota_devolucao_item.ndp_cstbipi_n               = tt-itens.valor_cst_ipi           
                       int_dp_nota_devolucao_item.ndp_modbcicms_n             = tt-itens.valor_frete            
                       int_dp_nota_devolucao_item.ndp_modbcst_n               = tt-itens.valor_modb_cst 
                       int_dp_nota_devolucao_item.ndp_modbipi_n               = tt-itens.valor_modb_ipi.                
                       
                FOR EACH tt-condicao_pagamento:
                
                    FOR EACH int_dp_nota_devolucao NO-LOCK 
                        WHERE int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s = tt-nota-devolucao.destinatario_cnpj //era tt-nota-devolucao.emitente_cnpj
                        AND   int_dp_nota_devolucao.ndv_notafiscal_n          = tt-nota-devolucao.numero
                        AND   int_dp_nota_devolucao.ndv_serie_s               = tt-nota-devolucao.serie:
                        
                        log-manager:write-message("KML - DENTRO CREATE DEVOL" + int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s) no-error.
                        log-manager:write-message("KML - DENTRO CREATE CONDIPAG" + tt-condicao_pagamento.CONDICAO_PAGAMENTO) no-error.
                   
                        CREATE int_dp_nota_devolucao_cond.
                        ASSIGN int_dp_nota_devolucao_cond.ndv_cnpjfilialdevolucao_s  = int_dp_nota_devolucao.ndv_cnpjfilialdevolucao_s
                               int_dp_nota_devolucao_cond.ndv_notafiscal_n           = int_dp_nota_devolucao.ndv_notafiscal_n
                               int_dp_nota_devolucao_cond.ndv_serie_s                = int_dp_nota_devolucao.ndv_serie_s
                               int_dp_nota_devolucao_cond.ndc_sequencia_n            = ? // fazer if para criar sequencia diferente
                               int_dp_nota_devolucao_cond.ndc_condipag_s             =  tt-condicao_pagamento.CONDICAO_PAGAMENTO
                               int_dp_nota_devolucao_cond.ndc_valor_n                = int_dp_nota_devolucao.ndv_valortotalprodutos_n.
                               
                
                    END.
                END.                                                             
            END.                                                           
        END.

        run intprg/int227HUBrp.p (INPUT TABLE tt-nota-devolucao,      //tt-nota-devolucao para executar o int227 isolado por nota
                                  OUTPUT TABLE tt-erros).


        jsonOutput = NEW JSONObject().
        FOR FIRST tt-erros:

            IF tt-erros.l-erro = NO THEN // no caso vou usar NO sem erro kk
            DO:
                jsonOutput:ADD("CNPJ-ORIGEM",tt-erros.CNPJDEV).
                //jsonOutput:ADD("serie"      ,tt-erros.NumeroNota).
                jsonOutput:ADD("nr-nota-fis",tt-erros.NumeroNota).
                //jsonOutput:ADD("chave-acesso",tt-erros.chave-acesso).
                jsonOutput:ADD("NotaDEvol",tt-erros.numeroDev).
                jsonOutput:ADD("Informa‡Æo",tt-erros.desc-erro).

            END.
            ELSE DO:

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
                 
                   UNDO for_notas, LEAVE for_notas.
                END.
            END.
        END.
        
        

        IF NOT CAN-FIND(FIRST nota_fiscal) THEN DO:

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Erro na integra‡Æo de cupom devolu‡Æo"
                   RowErrors.ErrorHelp = "Erro na integra‡Æo de cupom devolu‡Æo"
                   RowErrors.ErrorSubType = "ERROR".

            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
               
            END.
        UNDO for_notas, LEAVE for_notas.    
        END. 
    END.
    
    RETURN "OK".
   
    
END PROCEDURE.
