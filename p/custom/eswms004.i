DEFINE TEMP-TABLE nota_fiscal  NO-UNDO
    FIELD pedido_id         AS INT
    FIELD nota_id           AS INT
    FIELD chave_acesso       AS CHAR
    FIELD versao            AS CHAR
    FIELD especie           AS CHAR
    FIELD modelo            AS CHAR
    FIELD numero            AS INT
    FIELD serie             AS CHAR
    FIELD data_emissao      AS CHAR
    FIELD tipo_pedido       AS INT
    FIELD tipo_nota         AS CHAR
    FIELD situacao          AS CHAR
    FIELD emitente_cnpj     AS CHAR
    FIELD destinatario_cnpj AS CHAR
    FIELD transportadora_cnpj   AS CHAR
    FIELD transportadora_veiculo_placa  AS CHAR
    FIELD transportadora_veiculo_estado AS CHAR
    FIELD transportadora_reboque_placa  AS CHAR
    FIELD transportadora_reboque_estado AS CHAR
    FIELD observacao                    AS CHAR
    FIELD nota_fiscal_origem            AS INT
    FIELD serie_origem                  AS CHAR
    FIELD chave_acesso_origem           AS CHAR
    FIELD tipo_ambiente_nfe             AS INT
    FIELD protocolo                     AS CHAR
    FIELD cfop                          AS INT
    FIELD quantidade                    AS DEC
    FIELD valor_total_nota              AS DEC
    FIELD valor_desconto                AS DEC
    FIELD valor_base_icms               AS DEC
    FIELD valor_icms                    AS DEC
    FIELD valor_base_diferido           AS DEC
    FIELD valor_base_isenta             AS DEC
    FIELD valor_base_ipi                AS DEC
    FIELD valor_ipi                     AS DEC
    FIELD valor_base_st                 AS DEC
    FIELD valor_icms_st                 AS DEC
    FIELD valor_total_produtos          AS DEC
    FIELD peso_bruto                    AS DEC
    FIELD peso_liquido                  AS DEC
    FIELD valor_frete                   AS DEC
    FIELD valor_seguro                  AS DEC
    FIELD valor_embalagem               AS DEC
    FIELD valor_outras_despesas         AS DEC
    FIELD volumes_marca                 AS CHAR
    FIELD volumes_quantidade            AS INT
    FIELD modalidade_frete              AS INT
    FIELD data_cancelamento             AS DATE
    FIELD data_autorizacao              AS CHAR
    FIELD destinatario_nome             AS CHAR
    FIELD destinatario_logradouro       AS CHAR
    FIELD destinatario_numero           AS CHAR
    FIELD destinatario_complemento      AS CHAR
    FIELD destinatario_bairro           AS CHAR
    FIELD destinatario_cidade           AS CHAR
    FIELD destinatario_estado           AS CHAR
    FIELD destinatario_pais             AS CHAR
    FIELD destinatario_cep              AS CHAR
    FIELD destinatario_referencia       AS CHAR
    FIELD destinatario_ddd_fone         AS CHAR
    FIELD destinatario_fone             AS CHAR
    FIELD destinatario_email            AS CHAR
    FIELD data_entrega                  AS CHAR.
    
    
DEFINE TEMP-TABLE itens NO-UNDO
    FIELD pedido_id             AS INT    
    FIELD sequencia             AS INT
    FIELD produto               AS INT
    FIELD caixa                 AS INT
    FIELD volume                AS CHAR
    FIELD lote                  AS CHAR
    FIELD quantidade            AS DEC
    FIELD cfop                  AS INT
    FIELD ncm                   AS CHAR
    FIELD valor_bruto           AS DEC
    FIELD valor_desconto        AS DEC
    FIELD valor_base_icms       AS DEC
    FIELD valor_icms            AS DEC
    FIELD valor_base_diferido   AS DEC
    FIELD valor_base_isenta     AS DEC
    FIELD valor_base_ipi        AS DEC
    FIELD valor_ipi             AS DEC
    FIELD valor_icms_st         AS DEC
    FIELD valor_base_st         AS DEC
    FIELD valor_liquido         AS DEC
    FIELD valor_total_produto   AS DEC
    FIELD valor_aliquota_icms   AS DEC
    FIELD valor_aliquota_ipi    AS DEC
    FIELD valor_aliquota_pis    AS DEC
    FIELD valor_aliquota_cofins AS DEC
    FIELD data_validade         AS CHAR
    FIELD valor_despesa         AS DEC
    FIELD valor_tributos        AS DEC
    FIELD valor_cstb_pis        AS CHAR
    FIELD valor_cstb_cofins     AS CHAR
    FIELD valor_base_pis        AS DEC
    FIELD valor_pis             AS DEC
    FIELD valor_base_cofins     AS DEC
    FIELD valor_cofins          AS DEC
    FIELD valor_redutor_base_icms   AS DEC
    FIELD sequencia_origem      AS INT
    FIELD peso_bruto            AS DEC
    FIELD peso_liquido          AS DEC
    FIELD valor_frete           AS DEC
    FIELD valor_seguro          AS DEC
    FIELD valor_embalagem       AS DEC
    FIELD valor_outras_despesas AS DEC
    FIELD valor_cst_ipi         AS DEC
    FIELD valor_modbc_icms      AS DEC
    FIELD valor_modb_cst        AS DEC
    FIELD valor_modb_ipi        AS DEC
    FIELD valor_icms_substituto AS DEC
    FIELD valor_base_cst_ret    AS DEC
    FIELD valor_icms_ret        AS DEC
    FIELD ean                   AS CHAR.
    
    
    
DEFINE TEMP-TABLE condicao_pagamento NO-UNDO
    FIELD pedido_id             AS INT
    FIELD parcela               AS CHAR
    FIELD condicao_pagamento    AS CHAR
    FIELD vencimento            AS DATE
    FIELD adm_id                AS CHAR
    FIELD nsu                   AS CHAR
    FIELD autorizacao           AS CHAR
    FIELD adm_taxa              AS DEC
    FIELD valor                 AS DEC
    FIELD adquirente_id         AS CHAR
    FIELD origem_pagamento      AS CHAR
    FIELD convenio              AS CHAR.
    
    
DEF DATASET dsnotas FOR nota_fiscal, itens, condicao_pagamento
    DATA-RELATION r1 FOR nota_fiscal, itens
        RELATION-FIELDS(pedido_id,pedido_id) NESTED
    DATA-RELATION r2 FOR nota_fiscal, condicao_pagamento
        RELATION-FIELDS(pedido_id,pedido_id) NESTED.    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
