def temp-table tt_integr_apb_lote_fatura_3 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_ind_origin_tit_ap            as character format "X(03)" initial "APB" label "Origem" column-label "Origem"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_val_tot_lote_impl_tit_ap     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total  Movimento" column-label "Total Movto"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_empresa_ext              as character format "x(3)" label "C¢digo Empresa Ext" column-label "C¢d Emp Ext"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field ttv_log_atualiza_refer_apb       as logical format "Sim/N∆o" initial yes label "Atualiza Referància" column-label "Atualiza Referància"
    field ttv_log_elimina_lote             as logical format "Sim/N∆o" initial no
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_num_fatur_ap                 as integer format ">>>>,>>>,>>9" initial 0 label "N£mero  Fatura" column-label "Num Fatura"
    field tta_qtd_parcela                  as decimal format "->9" decimals 0 initial 0 label "Qtd Parcelas" column-label "Qtd Parc"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_cod_histor_padr_dupl         as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field ttv_ind_matriz_fornec            as character format "X(08)"
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field ttv_log_vinc_impto_auto          as logical format "Sim/N∆o" initial no label "PIS/COFINS/CSLL Auto"
    field ttv_log_fatur_emis_darf          as logical format "Sim/N∆o" initial NO label "Fatur Emis DARF" column-label "Fatur Emis DARF"
    field ttv_log_fornec_dif               as logical format "Sim/N∆o" initial no 
    index tt_lote_impl_tit_ap_integr_id    is primary unique
          tta_cod_estab                    ascending
          tta_cod_refer                    ascending
          tta_cod_estab_ext                ascending
    .

def temp-table tt_integr_apb_item_lote_fatura no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_tit_ap                   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor T°tulo" column-label "Valor T°tulo"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap¢lice Seguro" column-label "Apolice Seguro"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_qtd_parc_tit_ap              as decimal format ">>9" initial 1 label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_num_dias                     as integer format ">>>>,>>9" label "N£mero de Dias" column-label "N£mero de Dias"
    field ttv_ind_vencto_previs            as character format "X(4)" initial "Màs" label "C†lculo Vencimento" column-label "C†lculo Vencimento"
    field ttv_log_gerad                    as logical format "Sim/N∆o" initial no
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
    field ttv_num_ord_invest               as integer format ">>>>>,>>9" initial 0 label "Ordem Investimento" column-label "Ordem Invest"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_val_1099                     as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field tta_cod_tax_ident_number         as character format "x(15)" label "Tax Id Number" column-label "Tax Id Number"
    field tta_ind_tip_trans_1099           as character format "X(50)" initial "Rents" label "Tipo Transacao 1099" column-label "Tipo Transacao 1099"
    index tt_integr_apb_fatura_nf          is unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_cdn_fornecedor               ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending
    .

def temp-table tt_integr_apb_relacto_fatura no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field tta_cod_estab_tit_ap_pai         as character format "x(3)" label "Estab Tit Pai" column-label "Estab Tit Pai"
    field tta_cdn_fornec_pai               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor Pai" column-label "Fornecedor Pai"
    field tta_cod_espec_docto_nf           as character format "x(8)" label "Especie Nota Fiscal" column-label "Especie Nota Fiscal"
    field tta_cod_ser_docto_nf             as character format "x(8)" label "Serie Nota Fiscal" column-label "Serie Nota Fiscal"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parc_nf                  as character format "x(8)" label "Parcela Nota fiscal" column-label "Parcela Nota fiscal"
    field tta_ind_motiv_acerto_val         as character format "X(12)" initial "Alteraá∆o" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    field ttv_log_bxo_estab_tit            as logical format "Sim/N∆o" initial no
    index tt_integr_apb_relacto_fatura       is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_cod_estab_tit_ap_pai         ascending
          tta_cdn_fornec_pai               ascending
          tta_cod_espec_docto_nf           ascending
          tta_cod_ser_docto_nf             ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parc_nf                  ascending
    .

def temp-table tt_integr_apb_impto_impl_pend5 no-undo
    field ttv_rec_integr_apb_item_lote    as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend        as recid format ">>>>>>9"
    field tta_cod_pais                    as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac            as character format "x(3)" label "Estado" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imp"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Classificaá∆o Imposto" column-label "Classif Imposto"
    field tta_ind_clas_impto              as character format "X(14)" initial "Retido" label "Classe Imposto" column-label "Classe Imposto"
    field tta_cod_plano_cta_ctbl          as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tribut†vel" column-label "Vl Rendto Tribut"
    field tta_val_deduc_inss              as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Deduá∆o Inss" column-label "Deduá∆o Inss"
    field tta_val_deduc_depend            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Deduá∆o Dependentes" column-label "Deduá∆o Dependentes"
    field tta_val_deduc_pensao            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Deduá∆o Pens∆o" column-label "Deduá∆o Pens∆o"
    field tta_val_outras_deduc_impto      as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Outras Deduá‰es" column-label "Outras Deduá‰es"
    field tta_val_base_liq_impto          as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Base L°quida Imposto" column-label "Base L°quida Imposto"
    field tta_val_aliq_impto              as decimal format ">9.9999" decimals 4 initial 0.00 label "Al°quota" column-label "Aliq"
    field tta_val_impto_ja_recolhid        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Imposto J† Recolhido" column-label "Imposto J† Recolhido"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_cod_indic_econ              as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_impto_indic_econ_impto  as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Finalid Impto" column-label "Val Finalid Impto"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_cdn_fornec_favorec          as Integer format ">>>,>>>,>>9" initial 0 label "Fornec Favorecido" column-label "Fornec Favorecido"
    field tta_val_deduc_faixa_impto        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Deducao" column-label "Valor Deduá∆o"
    field tta_num_id_tit_ap                as integer format "999999999" initial 0 label "Token T°t AP" column-label "Token T°t AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto T°t AP" column-label "Id T°t AP"
    field tta_num_id_movto_cta_corren      as integer format "999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_pais_ext                as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_cta_ctbl_ext            as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext        as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field ttv_cod_tip_fluxo_financ_ext    as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_alimen_deduc_inss        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Aliment Ded INSS" column-label "Vl Alim INSS"
    field tta_val_eqpto_deduc_inss        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Equipto Ded INSS" column-label "Vl Eqto INSS"
    field tta_val_transp_deduc_inss        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Transp Ded INSS" column-label "Vl Trsp INSS"
    field tta_val_nao_retid                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor N∆o Retido" column-label "Vl N∆o Retid"
    field tta_cod_process_judic            as character format "x(21)" label "Nr Processo Judicial" column-label "Nr Proc Judic"
    field ttv_rec_integr_apb_impto_pend    as recid format ">>>>>>9"
    index tt_impto_impl_pend_ap_integr    is primary unique
          ttv_rec_integr_apb_item_lote    ascending
          tta_cod_pais                    ascending
          tta_cod_unid_federac            ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
    index tt_impto_impl_pend_ap_integr_ant is unique
          ttv_rec_antecip_pef_pend        ascending
          tta_cod_pais                    ascending
          tta_cod_unid_federac            ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
    .

def temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento"
    .

def temp-table tt_params_generic_api no-undo
    field ttv_rec_id                       as recid format ">>>>>>9"
    field ttv_cod_tabela                   as character format "x(28)" label "Tabela" column-label "Tabela"
    field ttv_cod_campo                    as character format "x(25)" label "Campo" column-label "Campo"
    field ttv_cod_valor                    as character format "x(8)" label "Valor" column-label "Valor"
    index tt_idx_param_generic             is primary unique
          ttv_cod_tabela                   ascending
          ttv_rec_id                       ascending
          ttv_cod_campo                    ascending.
/****************************************************************************************************/
DEF BUFFER b_tit_ap_nota FOR tit_ap.
def var v_hdl_apb925za as handle no-undo.
def var v_num_prox_seq as int no-undo.
DEF VAR v_data_baixa   AS DATE NO-UNDO.

EMPTY TEMP-TABLE tt_integr_apb_lote_fatura_3.
EMPTY TEMP-TABLE tt_integr_apb_relacto_fatura.
EMPTY TEMP-TABLE tt_integr_apb_item_lote_fatura.
EMPTY TEMP-TABLE tt_integr_apb_impto_impl_pend5.
EMPTY TEMP-TABLE tt_log_erros_atualiz.
EMPTY TEMP-TABLE tt_params_generic_api.


// Procura a £ltima referància criada no formato padr∆o "SUBS000001"
for each estabelecimento no-lock,
    LAST movto_tit_ap no-lock
    where movto_tit_ap.cod_estab = estabelecimento.cod_estab
    and   movto_tit_ap.cod_refer begins "SUBS0"
    by movto_tit_ap.cod_refer descending:
    
    assign error-status:error = NO.
    assign v_num_prox_seq = int(substr(movto_tit_ap.cod_refer,5,6)) NO-ERROR.
    if  error-status:ERROR
    or  v_num_prox_seq = ?
    or  v_num_prox_seq = 0 then
        next.
end.

.MESSAGE "sequencia1" SKIP v_num_prox_seq SKIP "SUBS" + string(v_num_prox_seq,"999999")
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
assign v_num_prox_seq = v_num_prox_seq + 10.    


DEFINE INPUT PARAMETER p_cod_estab      AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER p_num_id_tit_ap  AS INT NO-UNDO.

// Nota que ser† baixada por substituiá∆o
FIND b_tit_ap_nota
    WHERE b_tit_ap_nota.cod_estab       = p_cod_estab
    AND   b_tit_ap_nota.num_id_tit_ap   = p_num_id_tit_ap
    NO-LOCK.
    
FIND FIRST ems5.fornecedor NO-LOCK
    WHERE fornecedor.cdn_fornecedor = b_tit_ap_nota.cdn_fornecedor NO-ERROR.
    
IF AVAIL fornecedor  THEN
    FIND LAST fatur_ap no-lock
        where fatur_ap.num_pessoa   = fornecedor.num_pessoa NO-ERROR.
          
          
// Capa do lote
ASSIGN v_data_baixa = TODAY.
create tt_integr_apb_lote_fatura_3.
assign  tt_integr_apb_lote_fatura_3.tta_cod_estab                   = b_tit_ap_nota.cod_estab          
        tt_integr_apb_lote_fatura_3.tta_cod_refer                   = "SUBS" + string(v_num_prox_seq,"999999")
        tt_integr_apb_lote_fatura_3.tta_cod_espec_docto             = "TS"
        tt_integr_apb_lote_fatura_3.tta_dat_transacao               = v_data_baixa
        tt_integr_apb_lote_fatura_3.tta_ind_origin_tit_ap           = "APB"
        tt_integr_apb_lote_fatura_3.tta_cod_estab_ext               = ""
        tt_integr_apb_lote_fatura_3.tta_val_tot_lote_impl_tit_ap    = b_tit_ap_nota.val_sdo_tit_ap
        tt_integr_apb_lote_fatura_3.tta_cod_empresa                 = b_tit_ap_nota.cod_empresa
        tt_integr_apb_lote_fatura_3.ttv_cod_empresa_ext             = ""
        tt_integr_apb_lote_fatura_3.tta_cod_finalid_econ_ext        = ""
        tt_integr_apb_lote_fatura_3.tta_cod_indic_econ              = b_tit_ap_nota.cod_indic_econ
        tt_integr_apb_lote_fatura_3.ttv_log_atualiza_refer_apb      = YES
        tt_integr_apb_lote_fatura_3.ttv_log_elimina_lote            = YES
        tt_integr_apb_lote_fatura_3.tta_cdn_fornecedor              = b_tit_ap_nota.cdn_fornecedor
        tt_integr_apb_lote_fatura_3.tta_num_fatur_ap                = IF AVAIL fatur_ap THEN fatur_ap.num_fatur_ap + 1 ELSE 1 
        tt_integr_apb_lote_fatura_3.tta_qtd_parcela                 = 1 // qtd de duplicatas que ser∆o implantadas
        //tt_integr_apb_lote_fatura_3.tta_cod_histor_padr             = ""
        //tt_integr_apb_lote_fatura_3.tta_cod_histor_padr_dupl        = ""
        tt_integr_apb_lote_fatura_3.ttv_ind_matriz_fornec           = "Todos"
        tt_integr_apb_lote_fatura_3.ttv_rec_integr_apb_lote_impl    = RECID(tt_integr_apb_lote_fatura_3)
        tt_integr_apb_lote_fatura_3.ttv_log_vinc_impto_auto         = NO // aqui n∆o estamos tratando impostos!
        tt_integr_apb_lote_fatura_3.ttv_log_fatur_emis_darf         = NO
        tt_integr_apb_lote_fatura_3.ttv_log_fornec_dif              = NO
        .

// Nota (que ser† baixada)        
CREATE tt_integr_apb_relacto_fatura.
ASSIGN  tt_integr_apb_relacto_fatura.ttv_rec_integr_apb_lote_impl = RECID(tt_integr_apb_lote_fatura_3)
        tt_integr_apb_relacto_fatura.tta_cod_estab_tit_ap_pai     = b_tit_ap_nota.cod_estab
        tt_integr_apb_relacto_fatura.tta_cdn_fornec_pai           = b_tit_ap_nota.cdn_fornecedor 
        tt_integr_apb_relacto_fatura.tta_cod_espec_docto_nf       = b_tit_ap_nota.cod_espec_docto  
        tt_integr_apb_relacto_fatura.tta_cod_ser_docto_nf         = b_tit_ap_nota.cod_ser_docto
        tt_integr_apb_relacto_fatura.tta_cod_tit_ap               = b_tit_ap_nota.cod_tit_ap     
        tt_integr_apb_relacto_fatura.tta_cod_parc_nf              = b_tit_ap_nota.cod_parcela    
        //tt_integr_apb_relacto_fatura.tta_ind_motiv_acerto_val    
        tt_integr_apb_relacto_fatura.ttv_log_bxo_estab_tit        = YES // Baixar no estabelecimento do titulo?
        .
    
    .MESSAGE "teste"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
// Duplicata (que ser† implantada)        
CREATE tt_integr_apb_item_lote_fatura.
ASSIGN  tt_integr_apb_item_lote_fatura.ttv_rec_integr_apb_lote_impl = RECID(tt_integr_apb_lote_fatura_3)
        tt_integr_apb_item_lote_fatura.tta_num_seq_refer            = 1 // incrementar a cada registro
        tt_integr_apb_item_lote_fatura.tta_cdn_fornecedor           = b_tit_ap_nota.cdn_fornecedor
        tt_integr_apb_item_lote_fatura.tta_cod_ser_docto            = b_tit_ap_nota.cod_parcela
        tt_integr_apb_item_lote_fatura.tta_cod_tit_ap               = b_tit_ap_nota.cod_tit_ap
        tt_integr_apb_item_lote_fatura.tta_cod_parcela              = b_tit_ap_nota.cod_parcela 
        tt_integr_apb_item_lote_fatura.tta_dat_emis_docto           = b_tit_ap_nota.dat_emis_docto   
        tt_integr_apb_item_lote_fatura.tta_dat_vencto_tit_ap        = b_tit_ap_nota.dat_vencto_tit_ap
        tt_integr_apb_item_lote_fatura.tta_dat_prev_pagto           = b_tit_ap_nota.dat_prev_pagto   
        tt_integr_apb_item_lote_fatura.tta_dat_desconto             = b_tit_ap_nota.dat_desconto
        tt_integr_apb_item_lote_fatura.tta_cod_indic_econ           = b_tit_ap_nota.cod_indic_econ
        tt_integr_apb_item_lote_fatura.tta_val_tit_ap               = b_tit_ap_nota.val_sdo_tit_ap
        //tt_integr_apb_item_lote_fatura.tta_val_desconto             = b_tit_ap_nota.val_desconto
        tt_integr_apb_item_lote_fatura.tta_val_perc_desc            = b_tit_ap_nota.val_perc_desc
        tt_integr_apb_item_lote_fatura.tta_num_dias_atraso          = b_tit_ap_nota.num_dias_atraso
        //tt_integr_apb_item_lote_fatura.tta_val_juros_dia_atraso      = b_tit_ap_nota.val_juros_dia_atraso     
        tt_integr_apb_item_lote_fatura.tta_val_perc_juros_dia_atraso = b_tit_ap_nota.val_perc_juros_dia_atraso
        tt_integr_apb_item_lote_fatura.tta_val_perc_multa_atraso     = b_tit_ap_nota.val_perc_multa_atraso    
        tt_integr_apb_item_lote_fatura.tta_cod_portador              = b_tit_ap_nota.cod_portador             
        //tt_integr_apb_item_lote_fatura.tta_cod_apol_seguro           = 
        //tt_integr_apb_item_lote_fatura.tta_cod_seguradora            =
        //tt_integr_apb_item_lote_fatura.tta_cod_arrendador            =
        //tt_integr_apb_item_lote_fatura.tta_cod_contrat_leas          =
        tt_integr_apb_item_lote_fatura.tta_des_text_histor           = "Texto hist¢rico da duplicata implantada"
        //tt_integr_apb_item_lote_fatura.tta_num_id_tit_ap             =
        //tt_integr_apb_item_lote_fatura.tta_num_id_movto_tit_ap       =
        //tt_integr_apb_item_lote_fatura.tta_num_id_movto_cta_corren   =
        //tt_integr_apb_item_lote_fatura.ttv_qtd_parc_tit_ap           = 
        //tt_integr_apb_item_lote_fatura.ttv_num_dias                  =
        //tt_integr_apb_item_lote_fatura.ttv_ind_vencto_previs         =
        //tt_integr_apb_item_lote_fatura.ttv_log_gerad                 =
        //tt_integr_apb_item_lote_fatura.tta_cod_finalid_econ_ext      =
        //tt_integr_apb_item_lote_fatura.tta_cod_portad_ext            =
        //tt_integr_apb_item_lote_fatura.tta_cod_modalid_ext           =
        //tt_integr_apb_item_lote_fatura.tta_cod_cart_bcia             =
        tt_integr_apb_item_lote_fatura.tta_cod_forma_pagto           = b_tit_ap_nota.cod_forma_pagto
        //tt_integr_apb_item_lote_fatura.tta_val_cotac_indic_econ      =
        //tt_integr_apb_item_lote_fatura.ttv_num_ord_invest            =
        tt_integr_apb_item_lote_fatura.ttv_rec_integr_apb_item_lote  = RECID(tt_integr_apb_item_lote_fatura)
        //tt_integr_apb_item_lote_fatura.ttv_val_1099                  =
        //tt_integr_apb_item_lote_fatura.tta_cod_tax_ident_number      =
        //tt_integr_apb_item_lote_fatura.tta_ind_tip_trans_1099        =
        .

RELEASE tt_integr_apb_lote_fatura_3.
RELEASE tt_integr_apb_relacto_fatura.
RELEASE tt_integr_apb_item_lote_fatura.
RELEASE tt_integr_apb_impto_impl_pend5.
RELEASE tt_log_erros_atualiz.
RELEASE tt_params_generic_api.
        
run prgfin/apb/apb925za.py persistent set v_hdl_apb925za.

run pi_main_code_apb925za_05 in v_hdl_apb925za 
        (Input 5,
        Input table tt_integr_apb_lote_fatura_3,
        INPUT table tt_integr_apb_item_lote_fatura,
        Input table tt_integr_apb_relacto_fatura,
        Input table tt_integr_apb_impto_impl_pend5,
        input-output table tt_log_erros_atualiz,
        input-output table tt_params_generic_api).
DELETE PROCEDURE v_hdl_apb925za.

FOR EACH tt_log_erros_atualiz:
    MESSAGE "Operaá∆o cancelada - lote n∆o foi gerado" SKIP(1)
            "MSG:"   tt_log_erros_atualiz.ttv_num_mensagem   SKIP
            "ERRO:"  tt_log_erros_atualiz.ttv_des_msg_erro   SKIP
            "AJUDA:" tt_log_erros_atualiz.ttv_des_msg_ajuda
            VIEW-AS ALERT-BOX INFORMATION.
END.

// Localiza Duplicata gerada
FIND FIRST tt_integr_apb_lote_fatura_3 NO-ERROR.
FIND FIRST tt_integr_apb_item_lote_fatura NO-ERROR.
FIND tit_ap
    WHERE tit_ap.cod_Estab       = tt_integr_apb_lote_fatura_3.tta_cod_estab
    AND   tit_ap.cod_espec_docto = tt_integr_apb_lote_fatura_3.tta_cod_espec_docto
    AND   tit_ap.cdn_fornecedor  = tt_integr_apb_item_lote_fatura.tta_cdn_fornecedor
    AND   tit_ap.cod_ser_docto   = tt_integr_apb_item_lote_fatura.tta_cod_ser_docto 
    AND   tit_ap.cod_tit_ap      = tt_integr_apb_item_lote_fatura.tta_cod_tit_ap    
    AND   tit_ap.cod_parcela     = tt_integr_apb_item_lote_fatura.tta_cod_parcela   
    NO-LOCK NO-ERROR.
IF  NOT AVAIL tit_ap THEN DO:
    MESSAGE "Houve algum erro - A duplicata n∆o foi gerada." VIEW-AS ALERT-BOX INFORMATION.
    RETURN.
END.
MESSAGE "Sucesso!" VIEW-AS ALERT-BOX INFORMATION.

// OBS:
// - Existe um programa Consultas / Fatura do Contas a Pagar - no menu TOTVS
// - Existe um programa Tarefas / Estornar Substituiá∆o Nota por Duplicata - no menu TOTVS
