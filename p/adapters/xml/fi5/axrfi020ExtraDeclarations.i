def temp-table tt_import_movto_fluxo_cx no-undo
    field tta_num_fluxo_cx                 as integer format ">>>>>,>>9" initial 0 label "Fluxo Caixa" column-label "Fluxo Caixa"
    field tta_dat_movto_fluxo_cx           as date format "99/99/9999" initial ? label "Data Movimento" column-label "Data Movimento"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_ind_fluxo_movto_cx           as character format "X(3)" initial "ENT" label "Fluxo Movimento" column-label "Fluxo Movimento"
    field tta_ind_tip_movto_fluxo_cx       as character format "X(2)" initial "PR" label "Tipo Movimento" column-label "Tipo Movimento"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M¢dulo" column-label "M¢dulo"
    field tta_val_movto_fluxo_cx           as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movto" column-label "Valor Movto"
    field ttv_ind_erro_valid               as character format "X(08)" initial "NÆo"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico PadrÆo" column-label "Hist¢rico PadrÆo"
    field tta_des_histor_movto_fluxo_cx    as character format "x(2000)" label "Hist¢rico Movimento" column-label "Hist¢rico Movimento"
    field ttv_rec_movto_fluxo_cx           as recid format ">>>>>>9" initial ?
    .

def temp-table tt_import_movto_valid_cfl no-undo
    field ttv_rec_movto_fluxo_cx           as recid format ">>>>>>9" initial ?
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    .
