
DEFINE TEMP-TABLE tt-tit_ap NO-UNDO
    FIELD cod_estab                 LIKE tit_ap.cod_estab         
    FIELD cod_espec_docto           LIKE tit_ap.cod_espec_docto   
    FIELD cod_ser_docto             LIKE tit_ap.cod_ser_docto     
    FIELD cod_tit_ap                LIKE tit_ap.cod_tit_ap       
    FIELD cod_parcela               LIKE tit_ap.cod_parcela  
    FIELD dat_emis_docto            LIKE tit_ap.dat_emis_docto
    FIELD dat_transacao             LIKE tit_ap.dat_transacao
    FIELD dat_vencto_tit_ap         LIKE tit_ap.dat_vencto_tit_ap
    FIELD val_origin_tit_ap         LIKE tit_ap.val_origin_tit_ap
    FIELD cod_imposto               LIKE imposto.cod_imposto
    FIELD cod_classif_impto         LIKE classif_impto.cod_classif_impto
    FIELD val_aliq_impto            LIKE compl_impto_retid_ap.val_aliq_impto
    FIELD cod_ativid_pessoa_jurid   LIKE pessoa_jurid_ativid.cod_ativid_pessoa_jurid
    FIELD cdn_fornecedor            LIKE tit_ap.cdn_fornecedor       
    FIELD nom_pessoa_fornec         LIKE ems5.fornecedor.nom_pessoa  
    
    FIELD log_gerado                LIKE cst_tit_ap_gerado.log_gerado
    FIELD cod_usuar_gera            LIKE cst_tit_ap_gerado.cod_usuar_gera
    FIELD dat_geracao               LIKE cst_tit_ap_gerado.dat_geracao
    FIELD hra_geracao                LIKE cst_tit_ap_gerado.hra_geracao
                
    FIELD val_base_liq_impto        LIKE compl_impto_retid_ap.val_base_liq_impto           
    FIELD cod_id_munic_jurid        LIKE pessoa_jurid.cod_id_munic_jurid
    FIELD cod_id_feder              LIKE pessoa_jurid.cod_id_feder
    FIELD nom_pessoa                LIKE pessoa_jurid.nom_pessoa
    FIELD cod_id_feder_fisic        LIKE pessoa_fisic.cod_id_feder
    FIELD cod_id_feder_estab        LIKE pessoa_jurid.cod_id_feder
    FIELD cod_id_munic_jurid_estab  LIKE pessoa_jurid.cod_id_munic_jurid
    FIELD nom_pessoa_estab          LIKE pessoa_jurid.nom_pessoa
    FIELD log_pessoa_jurid          AS LOGICAL INIT YES        
    FIELD cod_cart_bcia             LIKE tit_acr.cod_cart_bcia     
    FIELD cdn_fornec_matriz         LIKE pessoa_jurid.num_pessoa_jurid_matriz
    FIELD cod_grp_fornec            LIKE tit_ap.cod_grp_fornec
    FIELD num_id_tit_ap             LIKE tit_ap.num_id_tit_ap
    FIELD log_tit_ap_estordo        LIKE tit_ap.log_tit_ap_estordo
    FIELD val_sdo_tit_ap            LIKE tit_ap.val_sdo_tit_ap
    FIELD dat_prev_pagto            LIKE tit_ap.dat_prev_pagto
    FIELD alterado                  AS LOG INIT NO
    FIELD aparece                   AS LOG INIT YES
    INDEX key1 AS PRIMARY cod_estab cod_espec_docto cod_ser_docto cod_tit_ap cod_parcela
    INDEX key2 cod_espec_docto cod_ser_docto cod_tit_ap cod_parcela
	INDEX key3 cdn_fornecedor
    INDEX key4 cdn_fornec_matriz
    INDEX alterados alterado                    
    .

DEFINE TEMP-TABLE tt-sim-tit_ap NO-UNDO LIKE tt-tit_ap .

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR FORMAT "x(35)"
    FIELD usuario          AS CHAR FORMAT "x(12)"
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    .
