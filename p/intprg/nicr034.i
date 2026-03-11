//
// TEMP-TABLES API IMPLANTA€ÇO TITULO APB - APB900ZG
//

def temp-table tt_integr_apb_nota_pend_cart   NO-UNDO     
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_contrat_cartcred         as character format "x(10)" label "Contrato CartÆo" column-label "Contrato CartÆo"
    field tta_cod_portad_cartcred          as character format "x(10)" label "Portador CartÆo" column-label "Portador CartÆo"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_ap                   as character format "x(16)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    index tt_idx_nota_pend_cart            is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_contrat_cartcred         ascending
          tta_cod_portad_cartcred          ascending
    .

def temp-table tt_item_doc_est_esoc_api    NO-UNDO    
    field tta_cdd_num_docto_esoc           as Decimal format ">>>,>>>,>>>,>>>,>>9" decimals 0 initial 0 label "Documento eSocial" column-label "Docto eSoc"
    field tta_num_seq_item                 as integer format ">>>>,>>9" initial 0 label "Nr Seq Item" column-label "Seq Item"
    field tta_cdn_serv_inss                as Integer format ">9" initial 0 label "Servi‡o INSS" column-label "Cod Serv INSS"
    field tta_val_brut                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Bruto" column-label "Bruto"
    field ttv_val_base_retenc              as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    .
    
def temp-table tt_docum_est_esoc_api       NO-UNDO 
    field tta_cdd_num_docto_esoc           as Decimal format ">>>,>>>,>>>,>>>,>>9" decimals 0 initial 0 label "Documento eSocial" column-label "Docto eSoc"
    field ttv_num_origem                   as integer format "9" label "Origem" column-label "Origem"
    field tta_cod_layout                   as character format "x(8)" label "Layout" column-label "Layout"
    field tta_cod_id_xml                   as character format "x(30)" label "C¢digo ID" column-label "ID XML"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estabelecimento"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa‡Æo" column-label "Dat Transac"
    field tta_cod_tit_ap                   as character format "x(16)" label "T¡tulo" column-label "T¡tulo"
    field ttv_cod_emitente                 as character format "x(8)" label "fornec"
    field tta_cod_ser_docto                as character format "x(5)" label "S‚rie Documento" column-label "S²rie"
    field tta_cod_docto                    as character format "x(19)" label "Nro. Documento" column-label "Nro. Documento"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp‚cie"
    field tta_cod_natur_operac             as character format "x(6)" label "Natureza Opera‡Æo" column-label "Natureza Opera»’o"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_num_contrat_gfe              as integer format ">>>>>>>>9" initial 0 label "Nr Contrato" column-label "Nr Contrato"
    field tta_num_roman                    as integer format ">,>>>,>>9" initial 0 label "Romaneio" column-label "Romaneio"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "Num Seq"
    field tta_ind_tip_obra                 as character format "X(65)" initial "Obra de Constru‡Æo Civil - Empreitada Total" label "Indicativo Obra" column-label "Indic Obra"
    field tta_val_brut                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Bruto" column-label "Bruto"
    field ttv_val_base_retenc              as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field tta_val_apurad                   as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Apurado" column-label "Vl Apurado"
    field tta_val_ret_subempr              as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Ret Subempreitada" column-label "Vl Rt Subemp"
    field tta_val_retid                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Reten‡Æo" column-label "Vl Reten‡Æo"
    field tta_val_adic                     as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Adicional" column-label "Vl Adicional"
    field tta_val_tot_retid                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Total Retido" column-label "Vl Tot Retid"
    field tta_cdd_num_cno                  as Decimal format ">>>>>>>>>>>9" decimals 0 initial 0 label "Nr Cadastro Nac Obra" column-label "Nr Cad Nac Obr"
    field tta_ind_tip_inscr_cno            as character format "X(10)" initial "CNPJ" label "Tipo Proprietÿrio" column-label "Tp Propr"
    field tta_cod_num_inscr_cno            as character format "x(19)" label "Proprietÿrio CNO" column-label "Prop CNO"
    field tta_val_serv_15                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi»o 15" column-label "Vl Serv 15"
    field tta_val_serv_20                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi»o 20" column-label "Vl Serv 20"
    field tta_val_serv_25                  as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi»o 25" column-label "Vl Serv 25"
    field tta_cod_num_proces_judic         as character format "x(20)" label "Nr Processo Judicial" column-label "Nr Proc Jud"
    field tta_val_nao_retid                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor NÆo Retido" column-label "Vl N’o Retid"
    field tta_val_mater_eqpto              as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Mat e Equipto" column-label "Vl Mat Eqpto"
    field tta_val_serv                     as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Servi‡o" column-label "Vl Servi»o"
    field tta_val_deduc                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Dedu‡Æo" column-label "Vl Dedu»’o"
    field tta_val_base_cooperat            as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooperativa" column-label "Vl Base Coop"
    field tta_val_base_calc                as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Base Calculo" column-label "Vl Base Calc"
    field tta_val_base_cooperat_15         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 15" column-label "Vl Bs Cp 15"
    field tta_val_base_cooperat_20         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 20" column-label "Vl Bs Cp 20"
    field tta_val_base_cooperat_25         as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Base Cooper 25" column-label "Vl Bs Cp 25"
    field tta_ind_tip_inciden              as character format "X(25)" initial "Normal" label "Tipo Incidˆncia" column-label "Tp Incid"
    field tta_ind_tip_aquis                as character format "X(65)" initial "Pessoa F¡sica ou Segurado Especial em Geral" label "Tipo Aquisi‡Æo" column-label "Tp Aquis"
    field tta_val_contrib_prev             as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Prev" column-label "Vl Contr Prv"
    field tta_val_contrib_financ           as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Financ" column-label "Vl Contr Fin"
    field tta_val_contrib_senar            as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Contrib Senar" column-label "Vl Ctr Senar"
    field tta_ind_tip_repas                as character format "X(40)" initial "Patrocinio" label "Tipo Repasse" column-label "Tp Repasse"
    field tta_dat_repas                    as date format "99/99/9999" initial ? label "Dt Repasse" column-label "Dt Repasse"
    field tta_val_repas                    as decimal format ">>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Repasse" column-label "Vl Repasse"
    .
        
def temp-table tt_integr_apb_aprop_relacto_2  NO-UNDO       
    field ttv_rec_integr_apb_relacto_pend  as recid format ">>>>>>9"
    field ttv_rec_integr_apb_aprop_relacto as recid format ">>>>>>9"
    field ttv_cod_plano_ccusto             as character format "x(8)" label "Plano CCusto" column-label "Plano CCusto"
    field ttv_cod_ccusto                   as Character format "x(20)" label "Centro Custo" column-label "Centro Custo"
    field ttv_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field ttv_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    index tt_integr_apb_aprop_relacto_id   is primary unique
          ttv_rec_integr_apb_relacto_pend  ascending
          ttv_rec_integr_apb_aprop_relacto ascending
    .

def temp-table tt_params_generic_api      NO-UNDO  
    field ttv_rec_id                       as recid format ">>>>>>9"
    field ttv_cod_tabela                   as character format "x(28)" label "Tabela" column-label "Tabela"
    field ttv_cod_campo                    as character format "x(35)" label "Campo" column-label "Campo"
    field ttv_cod_valor                    as character format "x(8)" label "Valor" column-label "Valor"
    index tt_idx_param_generic             is primary unique
          ttv_cod_tabela                   ascending
          ttv_rec_id                       ascending
          ttv_cod_campo                    ascending
    .

def new shared temp-table tt_integr_apb_relacto_pend_aux  NO-UNDO       
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_log_nota_vincul              as logical format "Sim/NÆo" initial yes
    .

def NEW shared temp-table tt_integr_apb_abat_antecip_vouc no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(16)" label "T¡tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_val_abat_tit_ap              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatimento" column-label "Vl Abatimento"
    index tt_integr_apb_abat_antecip_vouc  is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_estab                    ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cdn_fornecedor               ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    .

def NEW shared temp-table tt_integr_apb_abat_prev_provis no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(16)" label "T¡tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
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
          tta_cod_parcela                  ascending
    .

DEF NEW shared temp-table tt_integr_apb_aprop_relacto no-undo
    field ttv_rec_integr_apb_relacto_pend  as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_ind_tip_aprop_ctbl           as character format "x(30)" initial "Saldo" label "Tipo Aprop Ctbl" column-label "Tipo Aprop Ctbl"
    index tt_integr_apb_aprop_relacto      is primary unique
          ttv_rec_integr_apb_relacto_pend  ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
    .

def NEW shared temp-table tt_integr_apb_impto_impl_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Estado" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imp"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Classifica»’o Imposto" column-label "Classif Imposto"
    field tta_ind_clas_impto               as character format "X(14)" initial "Retido" label "Classe Imposto" column-label "Classe Imposto"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_ap                   as character format "x(16)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributÿvel" column-label "Vl Rendto Tribut"
    field tta_val_deduc_inss               as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Dedu»’o Inss" column-label "Dedu»’o Inss"
    field tta_val_deduc_depend             as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Dedu»’o Dependentes" column-label "Dedu»’o Dependentes"
    field tta_val_deduc_pensao             as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Dedu»’o Pens’o" column-label "Dedu»’o Pens’o"
    field tta_val_outras_deduc_impto       as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Outras Dedu»„es" column-label "Outras Dedu»„es"
    field tta_val_base_liq_impto           as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Base L­quida Imposto" column-label "Base L­quida Imposto"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al­quota" column-label "Aliq"
    field tta_val_impto_ja_recolhid        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Imposto Jÿ Recolhido" column-label "Imposto Jÿ Recolhido"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_impto_indic_econ_impto   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Finalid Impto" column-label "Val Finalid Impto"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_cdn_fornec_favorec           as Integer format ">>>,>>>,>>9" initial 0 label "Fornec Favorecido" column-label "Fornec Favorecido"
    field tta_val_deduc_faixa_impto        as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Deducao" column-label "Valor Dedu»’o"
    field tta_num_id_tit_ap                as integer format "999999999" initial 0 label "Token T­t AP" column-label "Token T­t AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto T­t AP" column-label "Id T­t AP"
    field tta_num_id_movto_cta_corren      as integer format "999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
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
          tta_cod_classif_impto            ascending
    .

def NEW SHARED temp-table tt_integr_apb_item_lote_impl no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format ">>>>>>9"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_ap                   as character format "x(16)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_tit_ap                   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor T­tulo" column-label "Valor T­tulo"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Vl Juros"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap½lice Seguro" column-label "Apolice Seguro"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_num_id_tit_ap                as integer format "999999999" initial 0 label "Token T­t AP" column-label "Token T­t AP"
    field tta_num_id_movto_tit_ap          as integer format "9999999999" initial 0 label "Token Movto T­t AP" column-label "Id T­t AP"
    field tta_num_id_movto_cta_corren      as integer format "999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_qtd_parc_tit_ap              as decimal format ">>9" initial 1 label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_num_dias                     as integer format ">>>>,>>9" label "Nœmero de Dias" column-label "Nœmero de Dias"
    field ttv_ind_vencto_previs            as character format "X(4)" initial "M¼s" label "Cÿlculo Vencimento" column-label "Cÿlculo Vencimento"
    field ttv_log_gerad                    as logical format "Sim/N’o" initial no
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending
    .

def NEW shared temp-table tt_integr_apb_relacto_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field tta_cod_estab_tit_ap_pai         as character format "x(5)" label "Estab Tit Pai" column-label "Estab Tit Pai"
    field tta_num_id_tit_ap_pai            as integer format "999999999" initial 0 label "Token" column-label "Token"
    field tta_val_relacto_tit_ap           as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_ind_motiv_acerto_val         as character format "X(12)" initial "Altera»’o" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    index tt_integr_apb_relacto_pend       is primary unique
          ttv_rec_integr_apb_item_lote     ascending
          tta_cod_estab_tit_ap_pai         ascending
          tta_num_id_tit_ap_pai            ascending
    .

def temp-table tt_erro_aed no-undo
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero"
    field ttv_cod_desc_erro                as character format "x(8)"
    field ttv_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Sequ¼ncia"
    .

DEF NEW shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento"
    .

DEF NEW shared temp-table tt_integr_apb_aprop_ctbl_pend no-undo
    field ttv_rec_integr_apb_item_lote     as recid format ">>>>>>9"
    field ttv_rec_antecip_pef_pend         as recid format ">>>>>>9"
    field ttv_rec_integr_apb_impto_pend    as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(20)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Estado" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imp"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Classifica»’o Imposto" column-label "Classif Imposto"
    field ttv_cod_tip_fluxo_financ_ext     as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_ccusto_ext               as character format "x(8)" label "Centro Custo Externo" column-label "CCusto Externo"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg½cio Externa" column-label "Unid Neg½cio Externa"
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
          tta_cod_tip_fluxo_financ         ascending
    .

def NEW shared temp-table tt_integr_apb_lote_impl no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_ind_origin_tit_ap            as character format "X(03)" initial "APB" label "Origem" column-label "Origem"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_val_tot_lote_impl_tit_ap     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total  Movimento" column-label "Total Movto"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_empresa_ext              as character format "x(3)" label "C½digo Empresa Ext" column-label "C½d Emp Ext"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    index tt_lote_impl_tit_ap_integr_id    is primary unique
          tta_cod_estab                    ascending
          tta_cod_refer                    ascending
          tta_cod_estab_ext                ascending
    .

def temp-table tt_integr_apb_item_lote_impl3v no-undo
    field ttv_rec_integr_apb_lote_impl     as recid format '>>>>>>9'
    field tta_num_seq_refer                as integer format '>>>9' initial 0 label 'Sequ¼ncia' column-label 'Seq'
    field tta_cdn_fornecedor               as Integer format '>>>,>>>,>>9' initial 0 label 'Fornecedor' column-label 'Fornecedor'
    field tta_cod_espec_docto              as character format 'x(3)' label 'Esp²cie Documento' column-label 'Esp²cie'
    field tta_cod_ser_docto                as character format 'x(3)' label 'S²rie Documento' column-label 'S²rie'
    field tta_cod_tit_ap                   as character format 'x(10)' label 'T­tulo' column-label 'T­tulo'
    field tta_cod_parcela                  as character format 'x(02)' label 'Parcela' column-label 'Parc'
    field tta_dat_emis_docto               as date format '99/99/9999' initial today label 'Data  Emiss’o' column-label 'Dt Emiss’o'
    field tta_dat_vencto_tit_ap            as date format '99/99/9999' initial today label 'Data Vencimento' column-label 'Dt Vencto'
    field tta_dat_prev_pagto               as date format '99/99/9999' initial today label 'Data Prevista Pgto' column-label 'Dt Prev Pagto'
    field tta_dat_desconto                 as date format '99/99/9999' initial ? label 'Data Desconto' column-label 'Dt Descto'
    field tta_cod_indic_econ               as character format 'x(8)' label 'Moeda' column-label 'Moeda'
    field tta_val_tit_ap                   as decimal format '->>>,>>>,>>9.99' decimals 2 initial 0 label 'Valor T­tulo' column-label 'Valor T­tulo'
    field tta_val_desconto                 as decimal format '->>>,>>>,>>9.99' decimals 2 initial 0 label 'Valor Desconto' column-label 'Valor Desconto'
    field tta_val_perc_desc                as decimal format '>9.9999' decimals 4 initial 0 label 'Percentual Desconto' column-label 'Perc Descto'
    field tta_num_dias_atraso              as integer format '>9' initial 0 label 'Dias Atraso' column-label 'Dias Atr'
    field tta_val_juros_dia_atraso         as decimal format '->>>,>>>,>>9.99' decimals 2 initial 0 label 'Valor Juro' column-label 'Vl Juro'
    field tta_val_perc_juros_dia_atraso    as decimal format '>9.999999' decimals 6 initial 00.00 label 'Perc Jur Dia Atraso' column-label 'Perc Dia'
    field tta_val_perc_multa_atraso        as decimal format '>9.99' decimals 2 initial 00.00 label 'Perc Multa Atraso' column-label 'Multa Atr'
    field tta_cod_portador                 as character format 'x(5)' label 'Portador' column-label 'Portador'
    field tta_cod_apol_seguro              as character format 'x(12)' label 'Ap½lice Seguro' column-label 'Apolice Seguro'
    field tta_cod_seguradora               as character format 'x(8)' label 'Seguradora' column-label 'Seguradora'
    field tta_cod_arrendador               as character format 'x(6)' label 'Arrendador' column-label 'Arrendador'
    field tta_cod_contrat_leas             as character format 'x(12)' label 'Contrato Leasing' column-label 'Contr Leas'
    field tta_des_text_histor              as character format 'x(2000)' label 'Hist½rico' column-label 'Hist½rico'
    field tta_num_id_tit_ap                as integer format '9999999999' initial 0 label 'Token Tit AP' column-label 'Token Tit AP'
    field tta_num_id_movto_tit_ap          as integer format '9999999999' initial 0 label 'Token Movto Tit AP' column-label 'Id Tit AP'
    field tta_num_id_movto_cta_corren      as integer format '9999999999' initial 0 label 'ID Movto Conta' column-label 'ID Movto Conta'
    field ttv_qtd_parc_tit_ap              as decimal format '>>9' initial 1 label 'Quantidade Parcelas' column-label 'Quantidade Parcelas'
    field ttv_num_dias                     as integer format '>>>>,>>9' label 'Nœmero de Dias' column-label 'Nœmero de Dias'
    field ttv_ind_vencto_previs            as character format 'X(4)' initial 'M¼s' label 'Cÿlculo Vencimento' column-label 'Cÿlculo Vencimento'
    field ttv_log_gerad                    as logical format 'Sim/N’o' initial no
    field tta_cod_finalid_econ_ext         as character format 'x(8)' label 'Finalid Econ Externa' column-label 'Finalidade Externa'
    field tta_cod_portad_ext               as character format 'x(8)' label 'Portador Externo' column-label 'Portador Externo'
    field tta_cod_modalid_ext              as character format 'x(8)' label 'Modalidade Externa' column-label 'Modalidade Externa'
    field tta_cod_cart_bcia                as character format 'x(3)' label 'Carteira' column-label 'Carteira'
    field tta_cod_forma_pagto              as character format 'x(3)' label 'Forma Pagamento' column-label 'F Pagto'
    field tta_val_cotac_indic_econ         as decimal format '>>>>,>>9.9999999999' decimals 10 initial 0 label 'Cota»’o' column-label 'Cota»’o'
    field ttv_num_ord_invest               as integer format '>>>>>,>>9' initial 0 label 'Ordem Investimento' column-label 'Ordem Invest'
    field tta_cod_livre_1                  as character format 'x(100)' label 'Livre 1' column-label 'Livre 1'
    field tta_cod_livre_2                  as character format 'x(100)' label 'Livre 2' column-label 'Livre 2'
    field tta_dat_livre_1                  as date format '99/99/9999' initial ? label 'Livre 1' column-label 'Livre 1'
    field tta_dat_livre_2                  as date format '99/99/9999' initial ? label 'Livre 2' column-label 'Livre 2'
    field tta_log_livre_1                  as logical format 'Sim/N’o' initial no label 'Livre 1' column-label 'Livre 1'
    field tta_log_livre_2                  as logical format 'Sim/N’o' initial no label 'Livre 2' column-label 'Livre 2'
    field tta_num_livre_1                  as integer format '>>>>>9' initial 0 label 'Livre 1' column-label 'Livre 1'
    field tta_num_livre_2                  as integer format '>>>>>9' initial 0 label 'Livre 2' column-label 'Livre 2'
    field tta_val_livre_1                  as decimal format '>>>,>>>,>>9.9999' decimals 4 initial 0 label 'Livre 1' column-label 'Livre 1'
    field tta_val_livre_2                  as decimal format '>>>,>>>,>>9.9999' decimals 4 initial 0 label 'Livre 2' column-label 'Livre 2'
    field ttv_rec_integr_apb_item_lote     as recid format '>>>>>>9'
    field ttv_val_1099                     as decimal format '->>,>>>,>>>,>>9.99' decimals 2
    field tta_cod_tax_ident_number         as character format 'x(15)' label 'Tax Id Number' column-label 'Tax Id Number'
    field tta_ind_tip_trans_1099           as character format 'X(50)' initial 'Rents' label 'Tipo Transacao 1099' column-label 'Tipo Transacao 1099'
    field ttv_ind_tip_cod_barra            as character format 'X(01)'
    field tta_cb4_tit_ap_bco_cobdor        as Character format 'x(50)' label 'Titulo Bco Cobrador' column-label 'Titulo Bco Cobrador'
    field tta_cod_tit_ap_bco_cobdor        as character format 'x(20)' label 'T­tulo Banco Cobdor' column-label 'T­tulo Banco Cobdor'
    index tt_item_lote_impl_ap_integr_id   is primary unique
          ttv_rec_integr_apb_lote_impl     ascending
          tta_num_seq_refer                ascending
    .
