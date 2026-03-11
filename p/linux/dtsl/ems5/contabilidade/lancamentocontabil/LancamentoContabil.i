def temp-table tt_integr_lote_ctbl_1 no-undo 
    field tta_cod_modul_dtsul              as character format "x(3)" label "M½dulo" column-label "M½dulo" 
    field tta_num_lote_ctbl                as integer format ">>>,>>>,>>9" initial 1 label "Lote Contÿbil" column-label "Lote Contÿbil" 
    field tta_des_lote_ctbl                as character format "x(40)" label "Descri»’o Lote" column-label "Descri»’o Lote" 
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa" 
    field tta_dat_lote_ctbl                as date format "99/99/9999" initial today label "Data Lote Contÿbil" column-label "Data Lote Contÿbil" 
    field ttv_ind_erro_valid               as character format "X(08)" initial "N’o" 
    field tta_log_integr_ctbl_online       as logical format "Sim/N’o" initial no label "Integra»’o Online" column-label "Integr Online" 
    field ttv_rec_integr_lote_ctbl         as recid format ">>>>>>9" 
    index tt_recid                         
          ttv_rec_integr_lote_ctbl         ascending. 

def temp-table tt_integr_lancto_ctbl_1 no-undo 
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cenÿrio Contÿbil" column-label "Cenÿrio Contÿbil" 
    field tta_log_lancto_conver            as logical format "Sim/N’o" initial no label "Lan»amento Convers’o" column-label "Lan»to Conv" 
    field tta_log_lancto_apurac_restdo     as logical format "Sim/N’o" initial no label "Lan»amento Apura»’o" column-label "Lancto Apura»’o" 
    field tta_cod_rat_ctbl                 as character format "x(8)" label "Rateio Contÿbil" column-label "Rateio" 
    field ttv_rec_integr_lote_ctbl         as recid format ">>>>>>9"
    field tta_num_lancto_ctbl              as integer format ">>,>>>,>>9" initial 10 label "Lan»amento Contÿbil" column-label "Lan»amento Contÿbil" 
    field ttv_ind_erro_valid               as character format "X(08)" initial "N’o"
    field tta_dat_lancto_ctbl              as date format "99/99/9999" initial ? label "Data Lan»amento" column-label "Data Lan»to" 
    field ttv_rec_integr_lancto_ctbl       as recid format ">>>>>>9"
    index tt_id                            is primary unique
          ttv_rec_integr_lote_ctbl         ascending
          tta_num_lancto_ctbl              ascending
    index tt_recid
          ttv_rec_integr_lancto_ctbl       ascending. 

def temp-table tt_integr_item_lancto_ctbl_1 no-undo 
    field ttv_rec_integr_lancto_ctbl       as recid format ">>>>>>9" 
    field tta_num_seq_lancto_ctbl          as integer format ">>>>9" initial 0 label "Sequ¼ncia Lan»to" column-label "Sequ¼ncia Lan»to" 
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza" 
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas" 
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil" 
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo" 
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab" 
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg" 
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o" 
    field tta_des_histor_lancto_ctbl       as character format "x(2000)" label "Hist½rico Contÿbil" column-label "Hist½rico Contÿbil" 
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie" 
    field tta_dat_docto                    as date format "99/99/9999" initial ? label "Data Documento" column-label "Data Documento" 
    field tta_des_docto                    as character format "x(25)" label "Nœmero Documento" column-label "Nœmero Documento" 
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem" 
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda" 
    field tta_dat_lancto_ctbl              as date format "99/99/9999" initial ? label "Data Lan»amento" column-label "Data Lan»to" 
    field tta_qtd_unid_lancto_ctbl         as decimal format ">>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade" column-label "Quantidade" 
    field tta_val_lancto_ctbl              as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Lan»amento" column-label "Valor Lan»amento" 
    field tta_num_seq_lancto_ctbl_cpart    as integer format ">>>9" initial 0 label "Sequ¼ncia CPartida" column-label "Sequ¼ncia CP" 
    field ttv_ind_erro_valid               as character format "X(08)" initial "N’o" 
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo" 
    field tta_cod_proj_financ              as character format "x(20)" label "Projeto" column-label "Projeto" 
    field ttv_rec_integr_item_lancto_ctbl  as recid format ">>>>>>9" 
    index tt_id                            is primary unique 
          ttv_rec_integr_lancto_ctbl       ascending 
          tta_num_seq_lancto_ctbl          ascending 
    index tt_recid                         
          ttv_rec_integr_item_lancto_ctbl  ascending. 

def temp-table tt_integr_aprop_lancto_ctbl_1 no-undo 
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade" 
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg" 
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo" 
    field tta_qtd_unid_lancto_ctbl         as decimal format ">>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade" column-label "Quantidade" 
    field tta_val_lancto_ctbl              as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Lan»amento" column-label "Valor Lan»amento" 
    field tta_num_id_aprop_lancto_ctbl     as integer format "9999999999" initial 0 label "Apropriacao Lan»to" column-label "Apropriacao Lan»to" 
    field ttv_rec_integr_item_lancto_ctbl  as recid format ">>>>>>9" 
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota»’o" column-label "Data Cota»’o" 
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o" 
    field ttv_ind_erro_valid               as character format "X(08)" initial "N’o" 
    field tta_ind_orig_val_lancto_ctbl     as character format "X(10)" initial "Informado" label "Origem Valor" column-label "Origem Valor" 
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo" 
    field ttv_rec_integr_aprop_lancto_ctbl as recid format ">>>>>>9" 
    index tt_id                            is primary unique 
          ttv_rec_integr_item_lancto_ctbl  ascending 
          tta_cod_finalid_econ             ascending 
          tta_cod_unid_negoc               ascending 
          tta_cod_plano_ccusto             ascending 
          tta_cod_ccusto                   ascending 
    index tt_recid                         
          ttv_rec_integr_aprop_lancto_ctbl ascending. 

def temp-table tt_integr_ctbl_valid_1 no-undo 
    field ttv_rec_integr_ctbl              as recid format ">>>>>>9" 
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem" 
    field ttv_ind_pos_erro                 as character format "X(08)" label "Posi»’o" 
    index tt_id                            is primary unique 
          ttv_rec_integr_ctbl              ascending 
          ttv_num_mensagem                 ascending.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia".
