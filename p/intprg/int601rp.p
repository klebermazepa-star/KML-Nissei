/********************************************************************************
**
**  Programa: int601rp.p - Gera‡Æo de titulos ST para contas a pagar
**
********************************************************************************/                                                                

/* include de controle de versÆo */
{include/i-prgvrs.i INT601RP 2.00.00.000}  /*** 010000 ***/
//{cdp/cd0666.i}
{include/tt-edit.i}
{include/pi-edit.i}

DEF TEMP-TABLE tt-erro NO-UNDO
    FIELD cod-estabel  AS CHAR
    FIELD serie        AS CHAR
    FIELD nr-nota-fis  AS CHAR
    FIELD cd-erro      AS INT
    FIELD mensagem     AS CHAR FORMAT "X(300)"
    INDEX id IS PRIMARY cod-estabel serie nr-nota-fis.

DEF TEMP-TABLE tt-titulos NO-UNDO
    FIELD cod-estabel     AS CHAR
    FIELD serie           AS CHAR
    FIELD nr-nota-fis     AS CHAR
    FIELD cod_estab       AS CHAR
    FIELD cdn_fornecedor  AS INT
    FIELD cod_espec_docto AS CHAR
    FIELD cod_ser_docto   AS CHAR
    FIELD cod_tit_ap      AS CHAR
    FIELD cod_parcela     AS CHAR
    FIELD vl-tit          AS DEC
    INDEX id IS PRIMARY cod-estabel serie nr-nota-fis.

def new global shared var c-seg-usuario as char no-undo.

DEF BUFFER bf-estabelec-973 FOR estabelec.
DEF BUFFER bf-esp_param_unid_feder_tit_st FOR esp_param_unid_feder_tit_st.

DEF VAR h-acomp    AS HANDLE  NO-UNDO.

DEFINE VARIABLE dt-aux AS DATE        NO-UNDO.
DEFINE VARIABLE i-parcela AS INTEGER     NO-UNDO.

FUNCTION fnDtVencto RETURNS DATE (dt-emissao AS DATE):
    DEFINE VARIABLE i-mes AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-ano AS INTEGER     NO-UNDO.

    ASSIGN i-mes = MONTH(dt-emissao) + esp_param_unid_feder_tit_st.qtd_meses_fora_emissao
           i-ano = YEAR(dt-emissao).
    DO WHILE i-mes > 12:
        ASSIGN i-mes = i-mes - 12
               i-ano = i-ano + 1.
    END.

    RETURN DATE(i-mes,esp_param_unid_feder_tit_st.ind_dat_venc_imp,i-ano).
END FUNCTION.

/*** temp-tables apb900zg ***/
def temp-table tt_integr_apb_item_lote_impl_3  no-undo
    field ttv_rec_integr_apb_lote_impl     as recid     format ">>>>>>9"
    field tta_num_seq_refer                as integer   format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_fornecedor               as Integer   format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_emis_docto               as date      format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_dat_vencto_tit_ap            as date      format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date      format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date      format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_tit_ap                   as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor T­tulo" column-label "Valor T­tulo"
    field tta_val_desconto                 as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal   format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_num_dias_atraso              as integer   format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_juros_dia_atraso         as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal   format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal   format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap½lice Seguro" column-label "Apolice Seguro"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_num_id_tit_ap                as integer   format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer   format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_num_id_movto_cta_corren      as integer   format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_qtd_parc_tit_ap              as decimal   format ">>9" initial 1 label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_num_dias                     as integer   format ">>>>,>>9" label "Nœmero de Dias" column-label "Nœmero de Dias"
    field ttv_ind_vencto_previs            as character format "X(4)" initial "M¼s" label "Cÿlculo Vencimento" column-label "Cÿlculo Vencimento"
    field ttv_log_gerad                    as logical   format "Sim/N’o" initial no
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_val_cotac_indic_econ         as decimal   format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field ttv_num_ord_invest               as integer   format ">>>>>,>>9" initial 0 label "Ordem Investimento" column-label "Ordem Invest"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date      format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date      format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical   format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical   format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer   format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer   format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_integr_apb_item_lote     as recid     format ">>>>>>9"
    field ttv_val_1099                     as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 
    field tta_cod_tax_ident_number         as character format "x(15)" label "Tax Id Number" column-label "Tax Id Number"
    field tta_ind_tip_trans_1099           as character format "X(50)" initial "Rents" label "Tipo Transacao 1099" column-label "Tipo Transacao 1099"
    field ttv_ind_tip_cod_barra            as character format 'X(01)'
    field tta_cb4_tit_ap_bco_cobdor        as Character format 'x(50)' label 'Titulo Bco Cobrador' column-label 'Titulo Bco Cobrador'
    field tta_cod_tit_ap_bco_cobdor        as character format 'x(20)' label 'T­tulo Banco Cobdor' column-label 'T­tulo Banco Cobdor'
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending
    .

def temp-table tt_integr_apb_aprop_relacto_1 no-undo
    field ttv_rec_integr_apb_relacto_pend  as recid format ">>>>>>9"
    field ttv_cod_plano_ccusto             as character format "x(8)" label "Plano CCusto" column-label "Plano CCusto"
    field ttv_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field ttv_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field ttv_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    .


def new shared temp-table tt_integr_apb_abat_antecip_vouc no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abat_tit_ap              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatimento" column-label "Vl Abatimento"
    index tt_integr_apb_abat_antecip_vouc  is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_estab                    ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cdn_fornecedor               ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending.

def new shared temp-table tt_integr_apb_abat_prev_provis no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abat_tit_ap              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatimento" column-label "Vl Abatimento"
    index tt_integr_apb_abat_prev          is unique                                                                                                     
          ttv_rec_antecip_pef_pend         ascending
          tta_cod_estab                    ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cdn_fornecedor               ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_integr_apb_abat_prev_provis   is primary unique
          ttv_rec_integr_apb_item_lote     ascending        
          tta_cod_estab                    ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cdn_fornecedor               ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending.

def new shared temp-table tt_integr_apb_aprop_ctbl_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field ttv_rec_integr_apb_impto_pend    as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"             
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field ttv_cod_tip_fluxo_financ_ext     as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_ccusto_ext               as character format "x(8)" label "Centro Custo Externo" column-label "CCusto Externo"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg¢cio Externa" column-label "Unid Neg¢cio Externa"
    index tt_aprop_ctbl_pend_ap_integr_ant
          ttv_rec_antecip_pef_pend         ascending
          ttv_rec_integr_apb_impto_pend    ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_tip_fluxo_financ         ascending
    index tt_aprop_ctbl_pend_ap_integr_id
          ttv_rec_integr_apb_item_lote     ascending
          ttv_rec_integr_apb_impto_pend    ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_tip_fluxo_financ         ascending.

def new shared temp-table tt_integr_apb_aprop_relacto no-undo
    field ttv_rec_integr_apb_relacto_pend  as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_ind_tip_aprop_ctbl           as character format "x(30)" initial "Saldo" label "Tipo Aprop Ctbl" column-label "Tipo Aprop Ctbl"
    index tt_integr_apb_aprop_relacto      is primary unique
          ttv_rec_integr_apb_relacto_pend  ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending.

def new shared temp-table tt_integr_apb_impto_impl_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_ind_clas_impto               as character format "X(14)" initial "Retido" label "Classe Imposto" column-label "Classe Imposto"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tribut vel" column-label "Vl Rendto Tribut"
    field tta_val_deduc_inss               as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Dedu»’o Inss" column-label "Dedu»’o Inss"
    field tta_val_deduc_depend             as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Dedu»’o Dependentes" column-label "Dedu»’o Dependentes"
    field tta_val_deduc_pensao             as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Deducao Pens’o" column-label "Deducao Pens’o"
    field tta_val_outras_deduc_impto       as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Outras Dedu»„es" column-label "Outras Dedu»„es"
    field tta_val_base_liq_impto           as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Base L¡quida Imposto" column-label "Base L¡quida Imposto"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al­quota" column-label "Aliq"
    field tta_val_impto_ja_recolhid        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Imposto Jÿ Recolhido" column-label "Imposto Jÿ Recolhido"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_impto_indic_econ_impto   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Finalid Impto" column-label "Val Finalid Impto"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_cdn_fornec_favorec           as Integer format ">>>,>>>,>>9" initial 0 label "Fornec Favorecido" column-label "Fornec Favorecido"
    field tta_val_deduc_faixa_impto        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Deducao" column-label "Valor Dedu»’o"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa¡s Externo" column-label "Pa¡s Externo"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field ttv_cod_tip_fluxo_financ_ext     as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    index tt_impto_impl_pend_ap_integr     is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_pais                     ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
    index tt_impto_impl_pend_ap_integr_ant is unique
          ttv_rec_antecip_pef_pend         ascending
          tta_cod_pais                     ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending.

def new shared temp-table tt_integr_apb_item_lote_impl no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  EmissÆo" column-label "Dt EmissÆo"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_tit_ap                   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor T¡tulo" column-label "Valor T¡tulo"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap½lice Seguro" column-label "Apolice Seguro"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_qtd_parc_tit_ap              as decimal format ">>9" initial 1 label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_num_dias                     as integer format ">>>>,>>9" label "Nœmero de Dias" column-label "Nœmero de Dias"
    field ttv_ind_vencto_previs            as character format "X(4)" initial "M¬s" label "C lculo Vencimento" column-label "C lculo Vencimento"
    field ttv_log_gerad                    as logical format "Sim/N’o" initial no
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending.

def new shared temp-table tt_integr_apb_lote_impl no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_ind_origin_tit_ap            as character format "X(03)" initial "APB" label "Origem" column-label "Origem"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_val_tot_lote_impl_tit_ap     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total  Movimento" column-label "Total Movto"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_empresa_ext              as character format "x(3)" label "C¢digo Empresa Ext" column-label "C¢d Emp Ext"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    index tt_lote_impl_tit_ap_integr_id    is primary unique
          tta_cod_estab                    ascending
          tta_cod_refer                    ascending
          tta_cod_estab_ext                ascending.

def new shared temp-table tt_integr_apb_relacto_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_estab_tit_ap_pai         as character format "x(5)" label "Estab Tit Pai" column-label "Estab Tit Pai"
    field tta_num_id_tit_ap_pai            as integer format "9999999999" initial 0 label "Token" column-label "Token"
    field tta_val_relacto_tit_ap           as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_ind_motiv_acerto_val         as character format "X(12)" initial "Altera¯Êo" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    index tt_integr_apb_relacto_pend       is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_estab_tit_ap_pai         ascending
          tta_num_id_tit_ap_pai            ascending.

def new shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento".

def temp-table tt_integr_apb_item_lote_impl3v no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_tit_ap                   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor T¡tulo" column-label "Valor T¡tulo"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 INITIAL 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 INITIAL 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap½lice Seguro" column-label "Apolice Seguro"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto Tit AP" column-label "Id Tit AP"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_qtd_parc_tit_ap              as decimal format ">>9" initial 1 label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_num_dias                     as integer format ">>>>,>>9" label "Nœmero de Dias" column-label "Nœmero de Dias"
    field ttv_ind_vencto_previs            as character format "X(4)" initial "Mˆs" label "Cÿlculo Vencimento" column-label "Cÿlculo Vencimento"
    field ttv_log_gerad                    as logical format "Sim/N’o" initial no
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field ttv_num_ord_invest               as integer format ">>>>>,>>9" initial 0 label "Ordem Investimento" column-label "Ordem Invest"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_val_1099                     as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field tta_cod_tax_ident_number         as character format "x(15)" label "Tax Id Number" column-label "Tax Id Number"
    field tta_ind_tip_trans_1099           as character format "X(50)" initial "Rents" label "Tipo Transacao 1099" column-label "Tipo Transacao 1099"
    field ttv_ind_tip_cod_barra            as character format "X(01)"
    field tta_cb4_tit_ap_bco_cobdor        as Character format "x(50)" label "Titulo Bco Cobrador" column-label "Titulo Bco Cobrador"
    field tta_cod_tit_ap_bco_cobdor        as character format "x(20)" label "T¡tulo Banco Cobdor" column-label "T¡tulo Banco Cobdor"
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending.

def temp-table tt_params_generic_api no-undo
    field ttv_rec_id                       as recid format ">>>>>>9"
    field ttv_cod_tabela                   as character format "x(28)" label "Tabela" column-label "Tabela"
    field ttv_cod_campo                    as character format "x(25)" label "Campo" column-label "Campo"
    field ttv_cod_valor                    as character format "x(8)" label "Valor" column-label "Valor"
    index tt_idx_param_generic             is primary unique
          ttv_cod_tabela                   ascending
          ttv_rec_id                       ascending
          ttv_cod_campo                    ascending.

def new shared temp-table tt_integr_apb_relacto_pend_aux no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_log_nota_vincul              as logical format "Sim/N’o" initial yes.

def temp-table tt_integr_apb_aprop_relacto_2 no-undo
    field ttv_rec_integr_apb_relacto_pend  as recid format ">>>>>>9"
    field ttv_rec_integr_apb_aprop_relacto as recid format ">>>>>>9"
    field ttv_cod_plano_ccusto             as character format "x(8)" label "Plano CCusto" column-label "Plano CCusto"
    field ttv_cod_ccusto                   as character format "x(20)" label "Centro de Custo" column-label "Centro de Custo"
    field ttv_cod_unid_negoc               as character format "x(3)" label "Unid Neg«cio" column-label "Un Neg"
    field ttv_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    index tt_integr_apb_aprop_relacto_id   is primary unique
          ttv_rec_integr_apb_relacto_pend  ascending
          ttv_rec_integr_apb_aprop_relacto ascending.

def temp-table tt_docum_est_esoc_api no-undo
    field tta_cdd_num_docto_esoc           as Decimal format ">>>,>>>,>>>,>>>,>>9" decimals 0 initial 0 label "Documento eSocial" column-label "Docto eSoc"
    field ttv_num_origem                   as integer format "9" label "Origem" column-label "Origem"
    field tta_cod_layout                   as character format "x(8)" label "Layout" column-label "Layout"
    field tta_cod_id_xml                   as character format "x(30)" label "C«digo ID" column-label "ID XML"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa¯Êo" column-label "Dat Transac"
    field tta_cod_tit_ap                   as character format "x(10)" label "Tðtulo" column-label "Tðtulo"
    field ttv_cod_emitente                 as character format "x(8)" label "Cliente"
    field tta_cod_ser_docto                as character format "x(3)" label "Sýrie Documento" column-label "Sýrie"
    field tta_cod_docto                    as character format "x(19)" label "Nro. Documento" column-label "Nro. Documento"
    field tta_cod_espec_docto              as character format "x(3)" label "Espýcie Documento" column-label "Espýcie"
    field tta_cod_natur_operac             as character format "x(6)" label "Natureza Opera¯Êo" column-label "Natureza Opera¯Êo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_num_contrat_gfe              as integer format ">>>>>>>>9" initial 0 label "Nr Contrato" column-label "Nr Contrato"
    field tta_num_roman                    as integer format ">,>>>,>>9" initial 0 label "Romaneio" column-label "Romaneio"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequ¬ncia" column-label "NumSeq"
    field tta_ind_tip_obra                 as character format "X(65)" initial "Obra de Constru¯Êo Civil - Empreitada Total" label "Indicativo Obra" column-label "Indic Obra"
    field tta_val_brut                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Bruto" column-label "Bruto"
    field ttv_val_base_retenc              as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field tta_val_apurad                   as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Apurado" column-label "Vl Apurado"
    field tta_val_ret_subempr              as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Ret Subempreitada" column-label "Vl Rt Subemp"
    field tta_val_retid                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Reten¯Êo" column-label "Vl Reten¯Êo"
    field tta_val_adic                     as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Adicional" column-label "Vl Adicional"
    field tta_val_tot_retid                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Total Retido" column-label "Vl Tot Retid"
    field tta_cdd_num_cno                  as Decimal format ">>>>>>>>>>>9" decimals 0 initial 0 label "Nr Cadastro Nac Obra" column-label "Nr Cad Nac Obr"
    field tta_ind_tip_inscr_cno            as character format "X(10)" initial "CNPJ" label "Tipo Propriet rio" column-label "Tp Propr"
    field tta_cod_num_inscr_cno            as character format "x(19)" label "Propriet rio CNO" column-label "Prop CNO"
    field tta_val_serv_15                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi¯o 15" column-label "Vl Serv 15"
    field tta_val_serv_20                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi¯o 20" column-label "Vl Serv 20"
    field tta_val_serv_25                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi¯o 25" column-label "Vl Serv 25"
    field tta_cod_num_proces_judic         as character format "x(20)" label "Nr Processo Judicial" column-label "Nr Proc Jud"
    field tta_val_nao_retid                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor NÊo Retido" column-label "Vl NÊo Retid"
    field tta_val_mater_eqpto              as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Mat e Equipto" column-label "Vl Mat Eqpto"
    field tta_val_serv                     as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi¯o" column-label "Vl Servi¯o"
    field tta_val_deduc                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Dedu¯Êo" column-label "Vl Dedu¯Êo"
    field tta_val_base_cooperat            as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooperativa" column-label "Vl Base Coop"
    field tta_val_base_calc                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Base C lculo" column-label "Vl Base Calc"
    field tta_val_base_cooperat_15         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 15" column-label "Vl Bs Cp 15"
    field tta_val_base_cooperat_20         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 20" column-label "Vl Bs Cp 20"
    field tta_val_base_cooperat_25         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 25" column-label "Vl Bs Cp 25"
    field tta_ind_tip_inciden              as character format "X(25)" initial "Normal" label "Tipo Incid¬ncia" column-label "Tp Incid"
    field tta_ind_tip_aquis                as character format "X(65)" initial "Pessoa Fðsica ou Segurado Especial em Geral" label "Tipo Aquisi¯Êo" column-label "Tp Aquis"
    field tta_val_contrib_prev             as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Prev" column-label "Vl Contr Prv"
    field tta_val_contrib_financ           as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Financ" column-label "Vl Contr Fin"
    field tta_val_contrib_senar            as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Senar" column-label "Vl Ctr Senar"
    field tta_ind_tip_repas                as character format "X(40)" initial "Patrocðnio" label "Tipo Repasse" column-label "Tp Repasse"
    field tta_dat_repas                    as date format "99/99/9999" initial ? label "Dt Repasse" column-label "Dt Repasse"
    field tta_val_repas                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Repasse" column-label "Vl Repasse".

def temp-table tt_item_doc_est_esoc_api no-undo
    field tta_cdd_num_docto_esoc           as Decimal format ">>>,>>>,>>>,>>>,>>9" decimals 0 initial 0 label "Documento eSocial" column-label "Docto eSoc"
    field tta_num_seq_item                 as integer format ">>>>,>>9" initial 0 label "Nr Seq Item" column-label "Seq Item"
    field tta_cdn_serv_inss                as Integer format ">9" initial 0 label "Servi¯o INSS" column-label "Cod Serv INSS"
    field tta_val_brut                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Bruto" column-label "Bruto"
    field ttv_val_base_retenc              as decimal format "->>,>>>,>>>,>>9.99" decimals 2.

def temp-table tt_integr_apb_nota_pend_cart no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_contrat_cartcred         as character format "x(10)" label "Contrato Cart’o" column-label "Contrato Cart’o"
    field tta_cod_portad_cartcred          as character format "x(10)" label "Portador Cart’o" column-label "Portador Cart’o"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    index tt_idx_nota_pend_cart            is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_contrat_cartcred         ascending
          tta_cod_portad_cartcred          ascending.
/*** temp-tables apb900zg ***/

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    /*Alterado 15/02/2005 - tech1007 - Criado campo l¢gico para verificar se o RTF foi habilitado*/
    field l-habilitaRtf    as LOG
    /*Fim alteracao 15/02/2005*/
    FIELD cod-estabel-ini  AS CHAR
    FIELD cod-estabel-fim  AS CHAR
    FIELD estado-ini       AS CHAR
    FIELD estado-fim       AS CHAR
    FIELD dt-emis-nota-ini AS DATE
    FIELD dt-emis-nota-fim AS DATE
    FIELD lg-ult-dias      AS LOG
    FIELD ult-dias         AS INT.

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

IF tt-param.arquivo = "" THEN 
   ASSIGN tt-param.arquivo   = "int601.txt"
          tt-param.destino   = 3
          tt-param.data-exec = TODAY
          tt-param.hora-exec = TIME.

{include/i-rpvar.i}

FIND FIRST param-global NO-LOCK NO-ERROR.

IF tt-param.dt-emis-nota-ini = ? THEN DO:

    ASSIGN tt-param.dt-emis-nota-ini = TODAY - 5
           tt-param.dt-emis-nota-fim = TODAY.
END.

assign  c-programa 	    = "INT601RP"
	    c-versao	    = "2.00"
	    c-revisao	    = ".00.000"
        c-empresa       = param-global.grupo
	    c-sistema	    = "Espec¡fico"
	    c-titulo-relat  = "Gera‡Æo Titulos ST Conta a Pagar".

{include/i-rpout.i}
{include/i-rpcab.i}

VIEW FRAME f-cabec.
VIEW FRAME f-rodape.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Gera‡Æo Titulos ST Conta a Pagar").

EMPTY TEMP-TABLE tt_integr_apb_abat_antecip_vouc NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_abat_prev_provis  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_ctbl_pend   NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto     NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_impto_impl_pend   NO-ERROR. 
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl    NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_lote_impl         NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_relacto_pend      NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl_3  NO-ERROR.
EMPTY TEMP-TABLE tt_log_erros_atualiz            NO-ERROR.
EMPTY TEMP-TABLE tt_params_generic_api           NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_relacto_pend_aux  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_1   NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl3v  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_2   NO-ERROR.
EMPTY TEMP-TABLE tt_docum_est_esoc_api           NO-ERROR.
EMPTY TEMP-TABLE tt_item_doc_est_esoc_api        NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_nota_pend_cart    NO-ERROR.

FOR FIRST bf-estabelec-973 NO-LOCK
    WHERE bf-estabelec-973.cod-estabel = "973",
    EACH estabelec NO-LOCK
    WHERE estabelec.cod-estabel >= tt-param.cod-estabel-ini
    AND   estabelec.cod-estabel <= tt-param.cod-estabel-fim
    AND   estabelec.estado      >= tt-param.estado-ini
    AND   estabelec.estado      <= tt-param.estado-fim,
    FIRST bf-esp_param_unid_feder_tit_st NO-LOCK
    WHERE bf-esp_param_unid_feder_tit_st.pais    = estabelec.pais
    AND   bf-esp_param_unid_feder_tit_st.estado  = estabelec.estado:

    IF tt-param.lg-ult-dias THEN DO dt-aux = TODAY - tt-param.ult-dias TO TODAY:

        RUN pi-nota-fiscal.
    END.
    ELSE DO dt-aux = tt-param.dt-emis-nota-ini TO tt-param.dt-emis-nota-fim:

        RUN pi-nota-fiscal.
    END.
END.

EMPTY TEMP-TABLE tt_integr_apb_abat_antecip_vouc NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_abat_prev_provis  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_ctbl_pend   NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto     NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_impto_impl_pend   NO-ERROR. 
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl    NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_lote_impl         NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_relacto_pend      NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl_3  NO-ERROR.
EMPTY TEMP-TABLE tt_log_erros_atualiz            NO-ERROR.
EMPTY TEMP-TABLE tt_params_generic_api           NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_relacto_pend_aux  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_1   NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl3v  NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_2   NO-ERROR.
EMPTY TEMP-TABLE tt_docum_est_esoc_api           NO-ERROR.
EMPTY TEMP-TABLE tt_item_doc_est_esoc_api        NO-ERROR.
EMPTY TEMP-TABLE tt_integr_apb_nota_pend_cart    NO-ERROR.

PUT UNFORMATTED SKIP(2).

IF CAN-FIND(FIRST tt-erro) THEN DO:

    PUT UNFORMATTED "Estab"     AT 1
                    "S‚rie"     AT 7
                    "Documento" AT 13
                    "Erro"      AT 29 SKIP
                    "-----"     AT 1 
                    "-----"     AT 7 
                    "---------" AT 13
                    "----"      AT 29 SKIP.

    FOR EACH tt-erro:
        PUT UNFORMATTED tt-erro.cod-estabel   FORMAT "X(5)"     AT 1
                        tt-erro.serie         FORMAT "X(3)"     AT 7
                        tt-erro.nr-nota-fis   FORMAT "X(15)"    AT 13
                        tt-erro.cd-erro       FORMAT "999999"   AT 29.

        RUN pi-print-editor (INPUT tt-erro.mensagem, 95).

        FOR EACH tt-editor:
            PUT UNFORMATTED tt-editor.conteudo AT 37 SKIP.
        END.
    END.
END.

PUT UNFORMATTED SKIP(2).

IF CAN-FIND(FIRST tt-titulos) THEN DO:

    PUT UNFORMATTED "Documentos Gerados" AT 2 
                    "T¡tulo Gerado"      AT 52 SKIP
                    "Estab"              AT 1
                    "S‚rie"              AT 7
                    "Documento"          AT 13
                    "Estab"              AT 29
                    "Fornecedor"         AT 35
                    "Esp‚cie"            AT 46
                    "S‚rie"              AT 54
                    "T¡tulo"             AT 60
                    "Parcela"            AT 70 
                    "Valor T¡tulo"       AT 78 SKIP
                    "-----"              AT 1 
                    "-----"              AT 7 
                    "---------"          AT 13
                    "-----"              AT 29
                    "----------"         AT 35
                    "-------"            AT 46
                    "-----"              AT 54
                    "------"             AT 60
                    "-------"            AT 70 
                    "------------"       AT 78 SKIP.

    FOR EACH tt-titulos:
        PUT UNFORMATTED tt-titulos.cod-estabel     FORMAT "X(5)"              AT 1 
                        tt-titulos.serie           FORMAT "X(9)"              AT 7 
                        tt-titulos.nr-nota-fis     FORMAT "X(15)"             AT 13
                        tt-titulos.cod_estab       FORMAT "X(3)"              AT 29
                        tt-titulos.cdn_fornecedor  FORMAT "99999999"          AT 35
                        tt-titulos.cod_espec_docto FORMAT "X(2)"              AT 46
                        tt-titulos.cod_ser_docto   FORMAT "X(5)"              AT 54
                        tt-titulos.cod_tit_ap      FORMAT "X(9)"              AT 60
                        tt-titulos.cod_parcela     FORMAT "X(2)"              AT 70 
                        tt-titulos.vl-tit          FORMAT ">>,>>>,>>9.99<<<<" AT 78 SKIP.
    END.

END.

PROCEDURE pi-nota-fiscal:
    DEFINE VARIABLE l-first AS LOGICAL     NO-UNDO.

    .MESSAGE "dt-aux - " dt-aux SKIP
            bf-estabelec-973.cod-estabel  
            estabelec.cod-emitente        
            estabelec.cod-estabel
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    blk_nota_fiscal:
    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.dt-emis-nota = dt-aux
        AND   nota-fiscal.cod-estabel  = bf-estabelec-973.cod-estabel
        AND   nota-fiscal.cod-emitente = estabelec.cod-emitente
		AND   nota-fiscal.dt-cancel 	= ?
        AND   nota-fiscal.idi-sit-nf-eletro = 3 /* Somente autorizadas*/,
        FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao
        AND   natur-oper.transf       = YES:

        ASSIGN l-first   = YES
               i-parcela = 0.

        .MESSAGE nota-fiscal.nr-nota-fis
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        RUN pi-acompanhar IN h-acomp(INPUT "Documento: " + nota-fiscal.cod-estabel
                                            + "/"        + nota-fiscal.serie
                                            + "/"        + nota-fiscal.nr-nota-fis).

        FOR EACH esp_param_unid_feder_tit_st NO-LOCK
            WHERE esp_param_unid_feder_tit_st.pais    = estabelec.pais
            AND   esp_param_unid_feder_tit_st.estado  = estabelec.estado:

            IF l-first THEN DO:
                FIND LAST tit_ap USE-INDEX titap_id NO-LOCK
                     WHERE tit_ap.cod_estab        = estabelec.cod-estabel
                       AND tit_ap.cdn_fornecedor   = esp_param_unid_feder_tit_st.cdn_fornecedor
                       AND tit_ap.cod_espec_docto  = esp_param_unid_feder_tit_st.cod_espec_docto
                       AND tit_ap.cod_ser_docto    = nota-fiscal.serie
                       AND tit_ap.cod_tit_ap       = nota-fiscal.nr-nota-fis NO-ERROR.
                IF AVAIL tit_ap THEN DO:
            
                    CREATE tt-erro.
                    ASSIGN tt-erro.cod-estabel  = nota-fiscal.cod-estabel
                           tt-erro.serie        = nota-fiscal.serie      
                           tt-erro.nr-nota-fis  = nota-fiscal.nr-nota-fis
                           tt-erro.cd-erro      = 17006
                           tt-erro.mensagem     = "T¡tulo j  gerado!".
            
                    NEXT blk_nota_fiscal.
                END.
                ASSIGN l-first = NO.
            END.
    
            RUN pi-cria-titulo-ap.
    
        END.
    END.
END.


RUN pi-finalizar IN h-acomp.

{include/i-rpclo.i /*&STREAM="stream str-rp"*/}

RETURN "OK".

PROCEDURE pi-cria-titulo-ap:
    
    DEFINE VARIABLE c_CodRefer AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE v_hdl_aux  AS HANDLE      NO-UNDO.
    DEFINE VARIABLE de-vl-tit  AS DECIMAL     NO-UNDO.

    ASSIGN de-vl-tit = 0.

    FOR EACH it-nota-fisc NO-LOCK
        WHERE it-nota-fisc.cod-estabel = nota-fiscal.cod-estabel
        AND   it-nota-fisc.serie       = nota-fiscal.serie
        AND   it-nota-fisc.nr-nota-fis = nota-fiscal.nr-nota-fis,
        FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo  = it-nota-fisc.it-codigo
        AND   ITEM.fm-cod-com = esp_param_unid_feder_tit_st.fm-cod-com:

        ASSIGN de-vl-tit = de-vl-tit + it-nota-fisc.vl-icmsub-it.
    END.

    IF de-vl-tit = 0 THEN RETURN "OK".

    ASSIGN i-parcela = i-parcela + 1.

    RUN pi_retorna_sugestao_referencia (INPUT  esp_param_unid_feder_tit_st.cod_espec_docto,
                                        INPUT  TODAY,
                                        OUTPUT c_CodRefer,
                                        INPUT  "tit_ap",
                                        INPUT  STRING(estabelec.cod-estabel)).

    EMPTY TEMP-TABLE tt_integr_apb_abat_antecip_vouc NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_abat_prev_provis  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_aprop_ctbl_pend   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto     NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_impto_impl_pend   NO-ERROR. 
    EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl    NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_lote_impl         NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_relacto_pend      NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl_3  NO-ERROR.
    EMPTY TEMP-TABLE tt_log_erros_atualiz            NO-ERROR.
    EMPTY TEMP-TABLE tt_params_generic_api           NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_relacto_pend_aux  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_1   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl3v  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_aprop_relacto_2   NO-ERROR.
    EMPTY TEMP-TABLE tt_docum_est_esoc_api           NO-ERROR.
    EMPTY TEMP-TABLE tt_item_doc_est_esoc_api        NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_apb_nota_pend_cart    NO-ERROR.
    
    CREATE tt_integr_apb_lote_impl.
    ASSIGN tt_integr_apb_lote_impl.tta_cod_estab_ext            = estabelec.cod-estabel
           tt_integr_apb_lote_impl.tta_cod_refer                = c_CodRefer
           tt_integr_apb_lote_impl.tta_ind_origin_tit_ap        = "APB":U 
           tt_integr_apb_lote_impl.ttv_cod_empresa_ext          = ''
           tt_integr_apb_lote_impl.tta_dat_transacao            = nota-fiscal.dt-emis-nota
           tt_integr_apb_lote_impl.tta_cod_finalid_econ_ext     = "0":U 
           tt_integr_apb_lote_impl.tta_val_tot_lote_impl_tit_ap = de-vl-tit.
    
    CREATE tt_integr_apb_item_lote_impl_3.
    ASSIGN tt_integr_apb_item_lote_impl_3.ttv_rec_integr_apb_lote_impl  = RECID(tt_integr_apb_lote_impl)
           tt_integr_apb_item_lote_impl_3.ttv_rec_integr_apb_item_lote  = RECID(tt_integr_apb_item_lote_impl_3)
           tt_integr_apb_item_lote_impl_3.tta_num_seq_refer             = 1
           tt_integr_apb_item_lote_impl_3.tta_cdn_fornecedor            = esp_param_unid_feder_tit_st.cdn_fornecedor
           tt_integr_apb_item_lote_impl_3.tta_cod_espec_docto           = esp_param_unid_feder_tit_st.cod_espec_docto
           tt_integr_apb_item_lote_impl_3.tta_cod_ser_docto             = nota-fiscal.serie
           tt_integr_apb_item_lote_impl_3.tta_cod_tit_ap                = nota-fiscal.nr-nota-fis
           tt_integr_apb_item_lote_impl_3.tta_cod_parcela               = STRING(i-parcela,"99")
           tt_integr_apb_item_lote_impl_3.tta_dat_emis_docto            = nota-fiscal.dt-emis-nota
           tt_integr_apb_item_lote_impl_3.tta_dat_vencto_tit_ap         = fnDtVencto(nota-fiscal.dt-emis-nota)
           tt_integr_apb_item_lote_impl_3.tta_dat_prev_pagto            = fnDtVencto(nota-fiscal.dt-emis-nota)
           tt_integr_apb_item_lote_impl_3.tta_dat_desconto              = ?
           tt_integr_apb_item_lote_impl_3.tta_cod_finalid_econ_ext      = "0":U
           tt_integr_apb_item_lote_impl_3.tta_val_cotac_indic_econ      = 1
           tt_integr_apb_item_lote_impl_3.tta_val_desconto              = 0
           tt_integr_apb_item_lote_impl_3.tta_val_perc_desc             = 0
           tt_integr_apb_item_lote_impl_3.tta_num_dias_atraso           = 0
           tt_integr_apb_item_lote_impl_3.tta_val_juros_dia_atraso      = 0
           tt_integr_apb_item_lote_impl_3.tta_val_perc_juros_dia_atraso = 0
           tt_integr_apb_item_lote_impl_3.tta_val_perc_multa_atraso     = 0
           tt_integr_apb_item_lote_impl_3.tta_cod_portador              = '99999'
           tt_integr_apb_item_lote_impl_3.tta_cod_apol_seguro           = ""
           tt_integr_apb_item_lote_impl_3.tta_cod_seguradora            = ""
           tt_integr_apb_item_lote_impl_3.tta_cod_arrendador            = ""
           tt_integr_apb_item_lote_impl_3.tta_cod_contrat_leas          = ""
           tt_integr_apb_item_lote_impl_3.tta_des_text_histor           = "Nota Transferencia ST"
           tt_integr_apb_item_lote_impl_3.tta_cod_forma_pagto           = 'BOL'
           tt_integr_apb_item_lote_impl_3.tta_val_tit_ap                = de-vl-tit
        //   v_rec_item                                                   = RECID(tt_integr_apb_item_lote_impl_3)
        .
    
    CREATE tt_integr_apb_aprop_ctbl_pend.
    ASSIGN tt_integr_apb_aprop_ctbl_pend.ttv_rec_integr_apb_item_lote   = tt_integr_apb_item_lote_impl_3.ttv_rec_integr_apb_item_lote
           tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_cta_ctbl         = 'PADRAO'
           tt_integr_apb_aprop_ctbl_pend.tta_cod_cta_ctbl               = esp_param_unid_feder_tit_st.conta_contabil_dev
           tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_ccusto           = ''
           tt_integr_apb_aprop_ctbl_pend.tta_cod_ccusto                 = ''
           tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_negoc             = ''
           tt_integr_apb_aprop_ctbl_pend.ttv_cod_tip_fluxo_financ_ext   = ''
           tt_integr_apb_aprop_ctbl_pend.tta_val_aprop_ctbl             = de-vl-tit. 
    
    run prgfin/apb/apb900zg.py persistent set v_hdl_aux.
    
    EMPTY TEMP-TABLE tt_log_erros_atualiz.

    RUN pi_main_block_api_tit_ap_cria_6 IN v_hdl_aux (INPUT 6,
                                                      INPUT "EMS2",
                                                      INPUT-OUTPUT TABLE tt_integr_apb_item_lote_impl_3,
                                                      INPUT-OUTPUT TABLE tt_params_generic_api,
                                                      INPUT        TABLE tt_integr_apb_relacto_pend_aux,
                                                      INPUT        TABLE tt_integr_apb_aprop_relacto_1).

    IF VALID-HANDLE(v_hdl_aux) THEN
        DELETE PROCEDURE v_hdl_aux.

    IF CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:
        FOR EACH tt_log_erros_atualiz NO-LOCK:
            CREATE tt-erro.
            ASSIGN tt-erro.cod-estabel  = nota-fiscal.cod-estabel
                   tt-erro.serie        = nota-fiscal.serie      
                   tt-erro.nr-nota-fis  = nota-fiscal.nr-nota-fis
                   tt-erro.cd-erro      = tt_log_erros_atualiz.ttv_num_mensagem
                   tt-erro.mensagem     = tt_log_erros_atualiz.ttv_des_msg_erro + " - " + tt_log_erros_atualiz.ttv_des_msg_ajuda.
        END.
    END.
    ELSE DO:

        CREATE tt-titulos.
        ASSIGN tt-titulos.cod-estabel     = nota-fiscal.cod-estabel
               tt-titulos.serie           = nota-fiscal.serie      
               tt-titulos.nr-nota-fis     = nota-fiscal.nr-nota-fis
               tt-titulos.cod_estab       = estabelec.cod-estabel
               tt-titulos.cdn_fornecedor  = esp_param_unid_feder_tit_st.cdn_fornecedor
               tt-titulos.cod_espec_docto = esp_param_unid_feder_tit_st.cod_espec_docto
               tt-titulos.cod_ser_docto   = nota-fiscal.serie
               tt-titulos.cod_tit_ap      = nota-fiscal.nr-nota-fis
               tt-titulos.cod_parcela     = STRING(i-parcela,"99")
               tt-titulos.vl-tit          = de-vl-tit.
    END.


END PROCEDURE.

PROCEDURE pi_retorna_sugestao_referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/



    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def input param p_estabel
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/

    DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.
    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(p_ind_tip_atualiz,1,2)
                       + substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
/*                        + substring(v_des_dat,1,2) */
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + CAPS(chr(v_num_aux)).
    end.
    
    run pi_verifica_refer_unica_apb (Input p_estabel,
                                     Input p_cod_refer,
                                     Input p_cod_table,
                                     Input ?,
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.

    IF v_log_refer_uni = NO THEN
            run pi_retorna_sugestao_referencia (Input  "BP",
                                                Input  today,
                                                output p_cod_refer,
                                                Input  p_cod_table,
                                                input  p_estabel).

END PROCEDURE.

PROCEDURE pi_verifica_refer_unica_apb:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_movto_tit_ap
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/N’o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_antecip_pef_pend
        for antecip_pef_pend.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_impl_tit_ap
        for lote_impl_tit_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_pagto
        for lote_pagto.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_ap
        for movto_tit_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    assign p_log_refer_uni = yes.



    if  p_cod_table <> "antecip_pef_pend" /*l_antecip_pef_pend*/ 
    then do:
        find first b_antecip_pef_pend no-lock
             where b_antecip_pef_pend.cod_estab = p_cod_estab
               and b_antecip_pef_pend.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_antecip_pef_pend*/ no-error.
    end /* if */.
    if  avail b_antecip_pef_pend
    then do:
        assign p_log_refer_uni = no.
    end /* if */.
    else do:
        if  p_cod_table <> "lote_impl_tit_ap" /*l_lote_impl_tit_ap*/ 
        then do:
            find first b_lote_impl_tit_ap no-lock
                 where b_lote_impl_tit_ap.cod_estab = p_cod_estab
                   and b_lote_impl_tit_ap.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_lote_impl_tit_ap*/ no-error.
        end /* if */.
        if  avail b_lote_impl_tit_ap
        then do:
            assign p_log_refer_uni = no.
        end /* if */.
        else do:
            if  p_cod_table <> "lote_pagto" /*l_lote_pagto*/ 
            then do:
                find first b_lote_pagto no-lock
                     where b_lote_pagto.cod_estab_refer = p_cod_estab
                       and b_lote_pagto.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_lote_pagto*/ no-error.
            end /* if */.
            if  avail b_lote_pagto
            then do:
                assign p_log_refer_uni = no.
            end /* if */.
            else do:
                find first b_movto_tit_ap no-lock
                     where b_movto_tit_ap.cod_estab = p_cod_estab
                       and b_movto_tit_ap.cod_refer = p_cod_refer
                       and recid(b_movto_tit_ap) <> p_rec_movto_tit_ap /*cl_verifica_refer_uni_apb of b_movto_tit_ap*/ no-error.
                if  avail b_movto_tit_ap
                then do:
                    assign p_log_refer_uni = no.
                end /* if */.
            end /* else */.
        end /* else */.
    end /* else */.

    &if defined(BF_FIN_BCOS_HISTORICOS) &then
        if can-find(first his_movto_tit_ap_histor no-lock
                    where his_movto_tit_ap_histor.cod_estab = p_cod_estab
                      and his_movto_tit_ap_histor.cod_refer = p_cod_refer) then
            assign p_log_refer_uni = no.
    &endif
END PROCEDURE. /* pi_verifica_refer_unica_apb */
