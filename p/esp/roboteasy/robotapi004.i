//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
// ATEN€ÇO
// ATUALIZAR A VERSÇO NO INCLUDE robotapi004.i
// - roboteasy\robotapi004.p
// - roboteasy\api\v1\restapiborderoap.p
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

DEF VAR c-versao-api AS CHAR INITIAL "21" NO-UNDO. 

//IF  LOG-MANAGER:LOGGING-LEVEL > 2 THEN
//    LOG-MANAGER:WRITE-MESSAGE("#log# - {1} - versÆo: " + c-versao-api, "CD7070") NO-ERROR.

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

DEF TEMP-TABLE tt_bordero NO-UNDO SERIALIZE-NAME "bordero"
    FIELD cod_estab                LIKE bord_ap.cod_estab                 SERIALIZE-NAME "codEstab"
    FIELD cod_empresa              LIKE bord_ap.cod_empresa               SERIALIZE-NAME "codEmpresa"
    FIELD cod_portador             LIKE bord_ap.cod_portador              SERIALIZE-NAME "codPortador"
    FIELD num_bord_ap              LIKE bord_ap.num_bord_ap               SERIALIZE-NAME "numBordAp"
    FIELD dat_transacao            LIKE bord_ap.dat_transacao             SERIALIZE-NAME "datTransacao"
    FIELD ind_tip_bord_ap          LIKE bord_ap.ind_tip_bord_ap           SERIALIZE-NAME "indTipBordAp"
    FIELD val_tot_lote_pagto_efetd LIKE bord_ap.val_tot_lote_pagto_efetd  SERIALIZE-NAME "valTotLotePagto"
    FIELD cod_indic_econ           LIKE bord_ap.cod_indic_econ            SERIALIZE-NAME "codIndicEcon"
    FIELD cod_msg_inic             LIKE bord_ap.cod_msg_inic              SERIALIZE-NAME "codMsgInic"
    FIELD cod_msg_fim              LIKE bord_ap.cod_msg_fim               SERIALIZE-NAME "codMsgFim"
    FIELD log_bxa_estab_tit_ap     LIKE bord_ap.log_bxa_estab_tit_ap      SERIALIZE-NAME "logBxaEstab"
    FIELD log_vincul_autom         LIKE bord_ap.log_vincul_autom          SERIALIZE-NAME "logVinculAutom"
    FIELD log_bord_gps             LIKE bord_ap.log_bord_gps              SERIALIZE-NAME "logBordGps"            
    FIELD log_bord_darf            LIKE bord_ap.log_bord_darf             SERIALIZE-NAME "logBordDarf"            
    FIELD log_bord_ap_escrit       LIKE bord_ap.log_bord_ap_escrit        SERIALIZE-NAME "logBordEscrit"            
    FIELD cod_usuar_pagto          LIKE bord_ap.cod_usuar_pagto           SERIALIZE-NAME "codUsuarPagto"
    FIELD cod_finalid_econ         LIKE bord_ap.cod_finalid_econ          SERIALIZE-NAME "codFinalidEcon"
    FIELD cod_refer                LIKE bord_ap.cod_refer                 SERIALIZE-NAME "codRefer"
    FIELD ind_sit_bord_ap          LIKE bord_ap.ind_sit_bord_ap           SERIALIZE-NAME "indSitBordAp"
    FIELD val_tot_lote_pagto_infor LIKE bord_ap.val_tot_lote_pagto_infor  SERIALIZE-NAME "valTotLotePagtoInfor"
    FIELD log_envio_pagto_escrit_edi AS LOGICAL  SERIALIZE-NAME "logPagtoEscrituralEDI"
    INDEX idx1 cod_estab num_bord_ap cod_portador cod_empresa.


DEFINE TEMP-TABLE tt_param NO-UNDO SERIALIZE-NAME "param"
    FIELD cod_estab                     AS CHARACTER	 INITIAL ? SERIALIZE-NAME "codEstab"	
    FIELD cod_empresa                   AS CHARACTER     INITIAL ? SERIALIZE-NAME "codEmpresa"
    FIELD cod_portador                  AS CHARACTER     INITIAL ? SERIALIZE-NAME "codPortador"
    FIELD num_bord_ap                   AS INTEGER       INITIAL ? SERIALIZE-NAME "numBordAp"
    FIELD ind_tip_docto_prepar_pagto    AS CHARACTER     INITIAL ? SERIALIZE-NAME "indTipDoctoPreparPagto"    
            // Ambos (default qdo nÆo informado)
            // T¡tulo
            // Antecipa‡Æo/PEF
    FIELD ind_liber_pagto_dat           AS CHARACTER     INITIAL ? SERIALIZE-NAME "indLiberPagtoDat"
            // Previs Pagto (default qdo nÆo informado)
            // Vencimento
            // Desconto
    FIELD dat_inicio              		AS DATE          INITIAL ? SERIALIZE-NAME "datInicio"
    FIELD dat_fim                 		AS DATE          INITIAL ? SERIALIZE-NAME "datFim"
    FIELD cod_estab_ini                 AS CHARACTER     INITIAL ? SERIALIZE-NAME "codEstabIni"
    FIELD cod_estab_fim                 AS CHARACTER     INITIAL ? SERIALIZE-NAME "codEstabFim"
    FIELD cdn_fornecedor_ini      		AS INTEGER       INITIAL ? SERIALIZE-NAME "cdnFornecedorIni"
    FIELD cdn_fornecedor_fim      		AS INTEGER       INITIAL ? SERIALIZE-NAME "cdnFornecedorFim"
    FIELD cod_espec_docto_ini           AS CHARACTER     INITIAL ? SERIALIZE-NAME "codEspecDoctoIni"
    FIELD cod_espec_docto_fim           AS CHARACTER     INITIAL ? SERIALIZE-NAME "codEspecDoctoFim"
    FIELD cod_forma_pagto_ini           AS CHARACTER     INITIAL ? SERIALIZE-NAME "codFormaPagtoIni"
    FIELD cod_forma_pagto_fim           AS CHARACTER     INITIAL ? SERIALIZE-NAME "codFormaPagtoFim"
    FIELD cod_indic_econ_ini            AS CHARACTER     INITIAL ? SERIALIZE-NAME "codIndicEconIni"
    FIELD cod_indic_econ_fim            AS CHARACTER     INITIAL ? SERIALIZE-NAME "codIndicEconFim"
    FIELD cod_portador_ini              AS CHARACTER     INITIAL ? SERIALIZE-NAME "codPortadorIni"
    FIELD cod_portador_fim              AS CHARACTER     INITIAL ? SERIALIZE-NAME "codPortadorFim"
    FIELD ind_pagto_liber               AS CHARACTER     INITIAL ? SERIALIZE-NAME "indPagtoLiber"
    FIELD val_cotac_indic_econ    		AS DECIMAL       INITIAL ? SERIALIZE-NAME "valCotacIndicEcon"
    FIELD dat_cotac_indic_econ    		AS DATE          INITIAL ? SERIALIZE-NAME "datCotacIndicEcon"
    FIELD log_atualiza_dat_pagto        AS LOGICAL       INITIAL ? SERIALIZE-NAME "logAtualizaDatPagto"
    FIELD ind_forma_pagto               AS CHARACTER     INITIAL ? SERIALIZE-NAME "indFormaPagto"
    FIELD cod_forma_pagto               AS CHARACTER     INITIAL ? SERIALIZE-NAME "codFormaPagto"
    FIELD ind_favorec_cheq              AS CHARACTER     INITIAL ? SERIALIZE-NAME "indFavorecCheq"
    FIELD log_gerac_autom         		AS LOGICAL       INITIAL ? SERIALIZE-NAME "logGeracAutom"
    FIELD cod_histor_padr               AS CHARACTER     INITIAL ? SERIALIZE-NAME "codHistorPadr"
    FIELD log_consid_fatur_cta    		AS LOGICAL       INITIAL ? SERIALIZE-NAME "logConsidFaturCta"
    FIELD log_assume_chave_pix_pref     AS LOGICAL       INITIAL ? SERIALIZE-NAME "logAssumeChavePixPref"
    FIELD log_pix_sem_chave             AS LOGICAL       INITIAL ? SERIALIZE-NAME "logPixSemChave"
    FIELD log-processo                  AS CHAR          INITIAL ? SERIALIZE-NAME "logProcesso"
    FIELD zerar-total-informado         AS LOGICAL      INITIAL ? SERIALIZE-NAME "zerarTotalInformado"
    FIELD zerar-total-vinculado         AS LOGICAL      INITIAL ? SERIALIZE-NAME "zerarTotalVinculado"
    FIELD alterar-status-impresso       AS LOGICAL      INITIAL ? SERIALIZE-NAME "alterarStatusImpresso"
.

DEF TEMP-TABLE tt_titulos_bord  NO-UNDO SERIALIZE-NAME "titulosBordero"
    FIELD ind_sit_prepar_liber             AS CHARACTER FORMAT "x(3)"             SERIALIZE-NAME "indSitPreparLiber"
    FIELD cod_estab                        AS CHARACTER FORMAT "X(3)"             SERIALIZE-NAME "codEstab"
    FIELD cdn_fornecedor                   AS INTEGER   FORMAT ">>>>>>>>9"        SERIALIZE-NAME "cdnFornecedor"
    FIELD nom_abrev                        AS CHARACTER FORMAT "X(15)"            SERIALIZE-NAME "nomAbrev"
    FIELD cod_espec_docto                  AS CHARACTER FORMAT "X(3)"             SERIALIZE-NAME "codEspecDocto"
    FIELD cod_ser_docto                    AS CHARACTER FORMAT "X(3)"             SERIALIZE-NAME "codSerDocto"
    FIELD cod_tit_ap                       AS CHARACTER FORMAT "X(10)"            SERIALIZE-NAME "codTitAp"
    FIELD cod_parcela                      AS CHARACTER FORMAT "X(2)"             SERIALIZE-NAME "codParcela"
    FIELD dat_prev_pagto                   AS DATE      FORMAT "99/99/9999"       SERIALIZE-NAME "datPrevPagto"
    FIELD val_sdo_tit_ap                   AS DECIMAL   FORMAT "->>>,>>>,>>9.99"  SERIALIZE-NAME "valSdoTitAp"
    FIELD dat_vencto_tit_ap                AS DATE      FORMAT "99/99/9999"       SERIALIZE-NAME "datVectoTitAp"
    FIELD cod_indic_econ                   AS CHARACTER FORMAT "X(8)"             SERIALIZE-NAME "codIndicEcon"
    FIELD cod_refer_antecip_pef            AS CHARACTER FORMAT "X(10)"            SERIALIZE-NAME "codReferAntecipPef"
    FIELD val_pagto_moe                    AS DECIMAL   FORMAT "->>>,>>>,>>9.99"  SERIALIZE-NAME "valPagtoMoe"
    FIELD dat_emis_docto                   AS DATE      FORMAT "99/99/9999"       SERIALIZE-NAME "datEmisDocto"
    FIELD dat_desconto                     AS DATE      FORMAT "99/99/9999"       SERIALIZE-NAME "datDesconto"
    FIELD cod_forma_pagto                  AS CHARACTER FORMAT "X(3)"             SERIALIZE-NAME "codFormaPagto"
    FIELD cod_refer                        AS CHARACTER FORMAT "X(10)"            SERIALIZE-NAME "codRefer"
    FIELD cod_banco                        AS CHARACTER FORMAT "X(8)"             SERIALIZE-NAME "codBanco"
    FIELD cod_agenc_bcia_digito            AS CHARACTER FORMAT "X(13)"            SERIALIZE-NAME "codAgencBciaDigito"
    FIELD cod_cta_corren_bco_digito        AS CHARACTER FORMAT "X(23)"            SERIALIZE-NAME "codCtaCorrenBcoDigito"
    FIELD log_mostra_tit                   AS LOGICAL   FORMAT "Sim/NÆo"          SERIALIZE-NAME "logMostraTit"
    FIELD num_seq_pagto_tit_ap             AS INTEGER   FORMAT ">>>>>>>>9"        SERIALIZE-NAME "numSeqPagtoTitAp"
    FIELD val_cotac_indic_econ             AS DECIMAL   FORMAT "->>>,>>>,>>9.99"  SERIALIZE-NAME "valCotacIndicEcon"
    FIELD cod_barras_pagto                 AS CHARACTER                           SERIALIZE-NAME "codBarrasPagto"
    FIELD ind_sit_item_bord_ap             AS CHARACTER                           SERIALIZE-NAME "indSitItemBordAp"
    FIELD val_pagto                        AS DECIMAL   FORMAT "->>>,>>>,>>9.99"  SERIALIZE-NAME "valPagto"
    FIELD rec_tit_ap                       AS RECID                               SERIALIZE-NAME "recTitAp"
    FIELD rec_proces_pagto                 AS RECID                               SERIALIZE-NAME "recProcesPagto"
    FIELD log_possui_antecip_forn          AS LOGICAL                             SERIALIZE-NAME "logPossuiAntecipForn"
    FIELD log_possui_antecip_matriz_filial AS LOGICAL                             SERIALIZE-NAME "logPossuiAntecipMatrizFilial"
    .

DEFINE TEMP-TABLE tt-retorno NO-UNDO SERIALIZE-NAME "retorno" // LIKE tt_param
    FIELD versao-api   AS CHAR
    FIELD cod-status   AS INT
    FIELD desc-retorno AS CHAR
    FIELD chave-reg    AS CHAR.

DEF BUFFER b-tt-retorno FOR tt-retorno.
