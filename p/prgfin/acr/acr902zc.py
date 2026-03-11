/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: api_integr_acr_renegoc_3
** Descricao.............: Aplication Program Interface
** Versao................:  1.00.00.104
** Procedimento..........: utl_integr_acr_renegoc
** Nome Externo..........: prgfin/acr/acr902zc.py
** Data Geracao..........: 05/11/2015 - 09:49:53
** Criado por............: its0042
** Criado em.............: 03/01/2005 16:25:56
** Alterado por..........: olbermann
** Alterado em...........: 14/10/2015 15:24:39
** Gerado por............: jeffersonsil
*****************************************************************************/
DEFINE BUFFER cliente          FOR ems5.cliente.
DEFINE BUFFER espec_docto      FOR ems5.espec_docto.
DEFINE BUFFER portador         FOR ems5.portador.
DEFINE BUFFER banco            FOR ems5.banco.
DEFINE BUFFER pais             FOR ems5.pais.
DEFINE BUFFER unid_organ       FOR ems5.unid_organ.
DEFINE BUFFER segur_unid_organ FOR ems5.segur_unid_organ.

/*-- Filtro Multi-idioma Aplicado --*/
DEFINE VARIABLE h_facelift AS HANDLE      NO-UNDO.

def var c-versao-prg as char initial " 1.00.00.104":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.104[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/i_fcldef.i}
{include/i_trddef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i api_integr_acr_renegoc_3 ACR}
&ENDIF

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=37":U.
/*************************************  *************************************/

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_cdn_cliente no-undo
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    index tt_id                            is primary unique
          tta_cdn_cliente                  ascending
    .

def temp-table tt_cdn_fornecedor no-undo
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    index tt_id                            is primary unique
          tta_cdn_fornecedor               ascending
    .

def temp-table tt_cliente_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_grp_clien                as character format "x(4)" label "Grupo Cliente" column-label "Grupo Cliente"
    field tta_cod_tip_clien                as character format "x(8)" label "Tipo Cliente" column-label "Tipo Cliente"
    field tta_dat_impl_clien               as date format "99/99/9999" initial ? label "Implantaá∆o Cliente" column-label "Implantaá∆o Cliente"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field ttv_ind_pessoa                   as character format "X(08)" initial "Jur°dica" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    index tt_cliente_empr_pessoa          
          tta_cod_empresa                  ascending
          tta_num_pessoa                   ascending
    index tt_cliente_grp_clien            
          tta_cod_grp_clien                ascending
    index tt_cliente_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    index tt_cliente_nom_abrev             is unique
          tta_cod_empresa                  ascending
          tta_nom_abrev                    ascending
    .

def temp-table tt_cliente_integr_j no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_grp_clien                as character format "x(4)" label "Grupo Cliente" column-label "Grupo Cliente"
    field tta_cod_tip_clien                as character format "x(8)" label "Tipo Cliente" column-label "Tipo Cliente"
    field tta_dat_impl_clien               as date format "99/99/9999" initial ? label "Implantaá∆o Cliente" column-label "Implantaá∆o Cliente"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field ttv_ind_pessoa                   as character format "X(08)" initial "Jur°dica" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_ind_tip_pessoa_ems2          as character format "X(12)" column-label "Tip Pessoa EMS2"
    index tt_cliente_empr_pessoa          
          tta_cod_empresa                  ascending
          tta_num_pessoa                   ascending
    index tt_cliente_grp_clien            
          tta_cod_grp_clien                ascending
    index tt_cliente_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    index tt_cliente_nom_abrev             is unique
          tta_cod_empresa                  ascending
          tta_nom_abrev                    ascending
    .

def temp-table tt_clien_analis_cr_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_tip_clien                as character format "x(8)" label "Tipo Cliente" column-label "Tipo Cliente"
    field tta_cod_clas_risco_clien         as character format "x(8)" label "Classe Risco" column-label "Classe Risco"
    field tta_log_neces_acompto_spc        as logical format "Sim/N∆o" initial no label "Neces Acomp SPC" column-label "Neces Acomp SPC"
    field tta_ind_sit_cr                   as character format "X(15)" label "Situaá∆o" column-label "Situaá∆o"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_clien_unico                   is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    .

def temp-table tt_clien_financ_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field ttv_cod_portad_prefer_ext        as character format "x(8)" label "Portad Prefer" column-label "Portad Prefer"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field ttv_cod_portad_prefer            as character format "x(5)" label "Portador Preferenc" column-label "Port Preferenc"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D°gito Cta Corrente" column-label "D°gito Cta Corrente"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_classif_msg_cobr         as character format "x(8)" label "Classif Msg Cobr" column-label "Classif Msg Cobr"
    field tta_cod_instruc_bcia_1_acr       as character format "x(4)" label "Instruá∆o Bcia 1" column-label "Instruá∆o 1"
    field tta_cod_instruc_bcia_2_acr       as character format "x(4)" label "Instruá∆o Bcia 2" column-label "Instruá∆o 2"
    field tta_log_habilit_emis_boleto      as logical format "Sim/N∆o" initial no label "Emitir Boleto" column-label "Emitir Boleto"
    field tta_log_habilit_gera_avdeb       as logical format "Sim/N∆o" initial no label "Gerar AD" column-label "Gerar AD"
    field tta_log_retenc_impto             as logical format "Sim/N∆o" initial no label "RetÇm Imposto" column-label "RetÇm Imposto"
    field tta_log_habilit_db_autom         as logical format "Sim/N∆o" initial no label "DÇbito Auto" column-label "DÇbito Auto"
    field tta_num_tit_acr_aber             as integer format ">>>>,>>9" initial 0 label "Quant Tit  Aberto" column-label "Qtd Tit Abert"
    field tta_dat_ult_impl_tit_acr         as date format "99/99/9999" initial ? label "Èltima Implantaá∆o" column-label "Èltima Implantaá∆o"
    field tta_dat_ult_liquidac_tit_acr     as date format "99/99/9999" initial ? label "Ultima Liquidaá∆o" column-label "Ultima Liquidaá∆o"
    field tta_dat_maior_tit_acr            as date format "99/99/9999" initial ? label "Data Maior T°tulo" column-label "Data Maior T°tulo"
    field tta_dat_maior_acum_tit_acr       as date format "99/99/9999" initial ? label "Data Maior Acum" column-label "Data Maior Acum"
    field tta_val_ult_impl_tit_acr         as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Ultimo Tit" column-label "Valor Ultimo Tit"
    field tta_val_maior_tit_acr            as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior T°tulo" column-label "Vl Maior T°tulo"
    field tta_val_maior_acum_tit_acr       as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Ac£mulo" column-label "Vl Maior Ac£mulo"
    field tta_ind_sit_clien_perda_dedut    as character format "X(21)" initial "Normal" label "Situaá∆o Cliente" column-label "Sit Cliente"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_log_neces_acompto_spc        as logical format "Sim/N∆o" initial no label "Neces Acomp SPC" column-label "Neces Acomp SPC"
    index tt_clnfnnc_classif_msg          
          tta_cod_classif_msg_cobr         ascending
    index tt_clnfnnc_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    index tt_clnfnnc_portador             
          tta_cod_portad_ext               ascending
    index tt_clnfnnc_rprsntnt             
          tta_cod_empresa                  ascending
          tta_cdn_repres                   ascending
    .

def temp-table tt_clien_financ_integr_e no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field ttv_cod_portad_prefer_ext        as character format "x(8)" label "Portad Prefer" column-label "Portad Prefer"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field ttv_cod_portad_prefer            as character format "x(5)" label "Portador Preferenc" column-label "Port Preferenc"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D°gito Cta Corrente" column-label "D°gito Cta Corrente"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_classif_msg_cobr         as character format "x(8)" label "Classif Msg Cobr" column-label "Classif Msg Cobr"
    field tta_cod_instruc_bcia_1_acr       as character format "x(4)" label "Instruá∆o Bcia 1" column-label "Instruá∆o 1"
    field tta_cod_instruc_bcia_2_acr       as character format "x(4)" label "Instruá∆o Bcia 2" column-label "Instruá∆o 2"
    field tta_log_habilit_emis_boleto      as logical format "Sim/N∆o" initial no label "Emitir Boleto" column-label "Emitir Boleto"
    field tta_log_habilit_gera_avdeb       as logical format "Sim/N∆o" initial no label "Gerar AD" column-label "Gerar AD"
    field tta_log_retenc_impto             as logical format "Sim/N∆o" initial no label "RetÇm Imposto" column-label "RetÇm Imposto"
    field tta_log_habilit_db_autom         as logical format "Sim/N∆o" initial no label "DÇbito Auto" column-label "DÇbito Auto"
    field tta_num_tit_acr_aber             as integer format ">>>>,>>9" initial 0 label "Quant Tit  Aberto" column-label "Qtd Tit Abert"
    field tta_dat_ult_impl_tit_acr         as date format "99/99/9999" initial ? label "Èltima Implantaá∆o" column-label "Èltima Implantaá∆o"
    field tta_dat_ult_liquidac_tit_acr     as date format "99/99/9999" initial ? label "Ultima Liquidaá∆o" column-label "Ultima Liquidaá∆o"
    field tta_dat_maior_tit_acr            as date format "99/99/9999" initial ? label "Data Maior T°tulo" column-label "Data Maior T°tulo"
    field tta_dat_maior_acum_tit_acr       as date format "99/99/9999" initial ? label "Data Maior Acum" column-label "Data Maior Acum"
    field tta_val_ult_impl_tit_acr         as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Ultimo Tit" column-label "Valor Ultimo Tit"
    field tta_val_maior_tit_acr            as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior T°tulo" column-label "Vl Maior T°tulo"
    field tta_val_maior_acum_tit_acr       as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Ac£mulo" column-label "Vl Maior Ac£mulo"
    field tta_ind_sit_clien_perda_dedut    as character format "X(21)" initial "Normal" label "Situaá∆o Cliente" column-label "Sit Cliente"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_log_neces_acompto_spc        as logical format "Sim/N∆o" initial no label "Neces Acomp SPC" column-label "Neces Acomp SPC"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_log_utiliz_verba             as logical format "Sim/N∆o" initial no label "Utiliza Verba de Pub" column-label "Utiliza Verba de Pub"
    field tta_val_perc_verba               as decimal format ">>>9.99" decimals 2 initial 0 label "Percentual Verba de" column-label "Percentual Verba de"
    field tta_val_min_avdeb                as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor M°nimo" column-label "Valor M°nimo"
    field tta_log_calc_multa               as logical format "Sim/N∆o" initial no label "Calcula Multa" column-label "Calcula Multa"
    field tta_num_dias_atraso_avdeb        as integer format "999" initial 0 label "Dias Atraso" column-label "Dias Atraso"
    field tta_cod_digito_agenc_bcia        as character format "x(2)" label "D°gito Ag Bcia" column-label "Dig Ag"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_cart_bcia_prefer         as character format "x(3)" label "Carteira Preferencia" column-label "Carteira Preferencia"
    index tt_clnfnnc_classif_msg          
          tta_cod_classif_msg_cobr         ascending
    index tt_clnfnnc_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    index tt_clnfnnc_portador             
          tta_cod_portad_ext               ascending
    index tt_clnfnnc_rprsntnt             
          tta_cod_empresa                  ascending
          tta_cdn_repres                   ascending
    .

def temp-table tt_contato_integr_e no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_telef_contat             as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal_contat             as character format "x(07)" label "Ramal" column-label "Ramal"
    field tta_cod_fax_contat               as character format "x(20)" label "Fax" column-label "Fax"
    field tta_cod_ramal_fax_contat         as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_modem_contat             as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem_contat       as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail_contat            as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_ind_priorid_envio_docto      as character format "x(10)" initial "e-Mail/Fax" label "Prioridade Envio" column-label "Prioridade Envio"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_nom_ender_text               as character format "x(2000)" label "Endereco Compl." column-label "Endereco Compl."
    index tt_contato_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_nom_abrev_contat             ascending
          tta_cdn_cliente                  ascending
          tta_cdn_fornecedor               ascending
    index tt_contato_pssfsca              
          tta_num_pessoa_fisic             ascending
    .

def temp-table tt_contat_clas_integr no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_cod_clas_contat              as character format "x(8)" label "Classe Contato" column-label "Classe"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_cnttclsa_clas_contat         
          tta_cod_clas_contat              ascending
    index tt_cnttclsa_id                   is primary unique
          tta_num_pessoa_jurid             ascending
          tta_nom_abrev_contat             ascending
          tta_cod_clas_contat              ascending
    index tt_cnttclsa_pessoa_classe       
          tta_num_pessoa_jurid             ascending
          tta_cod_clas_contat              ascending
    .

def new shared temp-table tt_dat_correc no-undo
    field ttv_dat_correc                   as date format "99/99/9999" initial today label "Data Correá∆o" column-label "Data Correá∆o"
    .

def temp-table tt_ender_entreg_integr no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_cod_ender_entreg             as character format "x(15)" label "Endereáo Entrega" column-label "Endereáo Entrega"
    field tta_nom_ender_entreg             as character format "x(40)" label "Nome Endereáo Entreg" column-label "Nome Endereáo Entreg"
    field tta_nom_bairro_entreg            as character format "x(20)" label "Bairro Entrega" column-label "Bairro Entrega"
    field tta_nom_cidad_entreg             as character format "x(32)" label "Cidade Entrega" column-label "Cidade Entrega"
    field tta_nom_condad_entreg            as character format "x(30)" label "Condado Entrega" column-label "Condado Entrega"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac_entreg      as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field tta_cod_cep_entreg               as character format "x(20)" label "CEP Entrega" column-label "CEP Entrega"
    field tta_cod_cx_post_entreg           as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_ndrntrga_id                   is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_ender_entreg             ascending
    index tt_ndrntrga_pais                
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac_entreg      ascending
    .

def temp-table tt_ender_entreg_integr_e no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_cod_ender_entreg             as character format "x(15)" label "Endereáo Entrega" column-label "Endereáo Entrega"
    field tta_nom_ender_entreg             as character format "x(40)" label "Nome Endereáo Entreg" column-label "Nome Endereáo Entreg"
    field tta_nom_bairro_entreg            as character format "x(20)" label "Bairro Entrega" column-label "Bairro Entrega"
    field tta_nom_cidad_entreg             as character format "x(32)" label "Cidade Entrega" column-label "Cidade Entrega"
    field tta_nom_condad_entreg            as character format "x(30)" label "Condado Entrega" column-label "Condado Entrega"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac_entreg      as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field tta_cod_cep_entreg               as character format "x(20)" label "CEP Entrega" column-label "CEP Entrega"
    field tta_cod_cx_post_entreg           as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_nom_ender_entreg_text        as character format "x(2000)" label "End Entrega Compl." column-label "End Entrega Compl."
    index tt_ndrntrga_id                   is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_ender_entreg             ascending
    index tt_ndrntrga_pais                
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac_entreg      ascending
    .

def new shared temp-table tt_erros_cotac_cta_cmcmm no-undo
    field ttv_num_msg_erro                 as integer format ">>>>>>9" label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_cod_indic_econ_base          as character format "x(8)" label "Moeda Base" column-label "Moeda Base"
    field ttv_cod_indic_econ_idx           as character format "x(8)" label "Moeda ÷ndice" column-label "Moeda ÷ndice"
    field ttv_dat_cotac_indic_econ         as date format "99/99/9999" initial today label "Data Cotaá∆o" column-label "Data Cotaá∆o"
    field ttv_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field ttv_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    .

def temp-table tt_espec_vdr_db no-undo
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    index tt_unico                         is primary unique
          tta_cod_espec_docto              ascending
    .

def temp-table tt_estrut_clien_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_clien_pai                as Integer format ">>>,>>>,>>9" initial 0 label "Cliente Pai" column-label "Cliente Pai"
    field tta_cdn_clien_filho              as Integer format ">>>,>>>,>>9" initial 0 label "Cliente Filho" column-label "Cliente Filho"
    field tta_log_dados_financ_tip_pai     as logical format "Sim/N∆o" initial no label "Armazena Valor" column-label "Armazena Valor"
    field tta_num_seq_estrut_clien         as integer format ">>>,>>9" initial 0 label "Sequància" column-label "Sequància"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_estrtcln_clien_filho         
          tta_cod_empresa                  ascending
          tta_cdn_clien_filho              ascending
    index tt_estrtcln_id                   is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_clien_pai                ascending
          tta_cdn_clien_filho              ascending
          tta_num_seq_estrut_clien         ascending
    .

def temp-table tt_estrut_fornec_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornec_pai               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor Pai" column-label "Fornecedor Pai"
    field tta_cdn_fornec_filho             as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor Filho" column-label "Fornecedor Filho"
    field tta_log_dados_financ_tip_pai     as logical format "Sim/N∆o" initial no label "Armazena Valor" column-label "Armazena Valor"
    field tta_num_seq_estrut_fornec        as integer format ">>>,>>9" initial 0 label "Sequencia" column-label "Sequencia"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_strtfrn_fornec_filho         
          tta_cod_empresa                  ascending
          tta_cdn_fornec_filho             ascending
    index tt_strtfrn_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornec_pai               ascending
          tta_cdn_fornec_filho             ascending
          tta_num_seq_estrut_fornec        ascending
    .

def temp-table tt_exec_rpc no-undo
    field ttv_cod_aplicat_dtsul_corren     as character format "x(3)"
    field ttv_cod_ccusto_corren            as character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field ttv_cod_dwb_user                 as character format "x(21)" label "Usu†rio" column-label "Usu†rio"
    field ttv_cod_empres_usuar             as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_estab_usuar              as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field ttv_cod_funcao_negoc_empres      as character format "x(50)"
    field ttv_cod_grp_usuar_lst            as character format "x(3)" label "Grupo Usu†rios" column-label "Grupo"
    field ttv_cod_idiom_usuar              as character format "x(8)" label "Idioma" column-label "Idioma"
    field ttv_cod_modul_dtsul_corren       as character format "x(3)" label "M¢dulo Corrente" column-label "M¢dulo Corrente"
    field ttv_cod_modul_dtsul_empres       as character format "x(100)"
    field ttv_cod_pais_empres_usuar        as character format "x(3)" label "Pa°s Empresa Usu†rio" column-label "Pa°s"
    field ttv_cod_plano_ccusto_corren      as character format "x(8)" label "Plano CCusto" column-label "Plano CCusto"
    field ttv_cod_unid_negoc_usuar         as character format "x(3)" label "Unidade Neg¢cio" column-label "Unid Neg¢cio"
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usu†rio Corrente" column-label "Usu†rio Corrente"
    field ttv_cod_usuar_corren_criptog     as character format "x(16)"
    field ttv_num_ped_exec_corren          as integer format ">>>>9"
    field ttv_cod_livre                    as character format "x(2000)"
    .

def temp-table tt_fornecedor_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_grp_fornec               as character format "x(4)" label "Grupo Fornecedor" column-label "Grp Fornec"
    field tta_cod_tip_fornec               as character format "x(8)" label "Tipo Fornecedor" column-label "Tipo Fornec"
    field tta_dat_impl_fornec              as date format "99/99/9999" initial today label "Data Implantaá∆o" column-label "Data Implantaá∆o"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field ttv_ind_pessoa                   as character format "X(08)" initial "Jur°dica" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_frncdr_empr_pessoa           
          tta_cod_empresa                  ascending
          tta_num_pessoa                   ascending
    index tt_frncdr_grp_fornec            
          tta_cod_grp_fornec               ascending
    index tt_frncdr_id                     is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornecedor               ascending
    index tt_frncdr_nom_abrev              is unique
          tta_cod_empresa                  ascending
          tta_nom_abrev                    ascending
    .

def temp-table tt_fornec_financ_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D°gito Cta Corrente" column-label "D°gito Cta Corrente"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_digito_agenc_bcia        as character format "x(2)" label "D°gito Ag Bcia" column-label "Dig Ag"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_ind_tratam_vencto_sab        as character format "X(08)" initial "Prorroga" label "Vencimento Sabado" column-label "Vencto Sab"
    field tta_ind_tratam_vencto_dom        as character format "X(08)" initial "Prorroga" label "Vencimento Domingo" column-label "Vencto Dom"
    field tta_ind_tratam_vencto_fer        as character format "X(08)" initial "Prorroga" label "Vencimento Feriado" column-label "Vencto Feriado"
    field tta_ind_pagto_juros_fornec_ap    as character format "X(08)" label "Juros" column-label "Juros"
    field tta_ind_tip_fornecto             as character format "X(08)" label "Tipo Fornecimento" column-label "Fornecto"
    field tta_ind_armaz_val_pagto          as character format "X(12)" initial "N∆o Armazena" label "Armazena Valor Pagto" column-label "Armazena Valor Pagto"
    field tta_log_fornec_serv_export       as logical format "Sim/N∆o" initial no label "Fornec Exportaá∆o" column-label "Fornec Export"
    field tta_log_pagto_bloqdo             as logical format "Sim/N∆o" initial no label "Bloqueia Pagamento" column-label "Pagto Bloqdo"
    field tta_log_retenc_impto             as logical format "Sim/N∆o" initial no label "RetÇm Imposto" column-label "RetÇm Imposto"
    field tta_dat_ult_impl_tit_ap          as date format "99/99/9999" initial ? label "Data Ultima Impl" column-label "Dt Ult Impl"
    field tta_dat_ult_pagto                as date format "99/99/9999" initial ? label "Data Èltimo Pagto" column-label "Data Èltimo Pagto"
    field tta_dat_impl_maior_tit_ap        as date format "99/99/9999" initial ? label "Dt Impl Maior Tit" column-label "Dt Maior Tit"
    field tta_num_antecip_aber             as integer format ">>>>9" initial 0 label "Quant Antec  Aberto" column-label "Qtd Antec"
    field tta_num_tit_ap_aber              as integer format ">>>>9" initial 0 label "Quant Tit  Aberto" column-label "Qtd Tit Abert"
    field tta_val_tit_ap_maior_val         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Tit Impl" column-label "Valor Maior T°tulo"
    field tta_val_tit_ap_maior_val_aber    as decimal format "->>>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Tit  Aberto" column-label "Maior Vl Aberto"
    field tta_val_sdo_antecip_aber         as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Antec Aberto" column-label "Sdo Antecip Aberto"
    field tta_val_sdo_tit_ap_aber          as decimal format "->>>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Tit   Aberto" column-label "Sdo Tit Aberto"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    index tt_frncfnnc_forma_pagto         
          tta_cod_forma_pagto              ascending
    index tt_frncfnnc_id                   is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornecedor               ascending
    index tt_frncfnnc_portador            
          tta_cod_portad_ext               ascending
    .

def temp-table tt_fornec_financ_integr_e no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D°gito Cta Corrente" column-label "D°gito Cta Corrente"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_digito_agenc_bcia        as character format "x(2)" label "D°gito Ag Bcia" column-label "Dig Ag"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_ind_tratam_vencto_sab        as character format "X(08)" initial "Prorroga" label "Vencimento Sabado" column-label "Vencto Sab"
    field tta_ind_tratam_vencto_dom        as character format "X(08)" initial "Prorroga" label "Vencimento Domingo" column-label "Vencto Dom"
    field tta_ind_tratam_vencto_fer        as character format "X(08)" initial "Prorroga" label "Vencimento Feriado" column-label "Vencto Feriado"
    field tta_ind_pagto_juros_fornec_ap    as character format "X(08)" label "Juros" column-label "Juros"
    field tta_ind_tip_fornecto             as character format "X(08)" label "Tipo Fornecimento" column-label "Fornecto"
    field tta_ind_armaz_val_pagto          as character format "X(12)" initial "N∆o Armazena" label "Armazena Valor Pagto" column-label "Armazena Valor Pagto"
    field tta_log_fornec_serv_export       as logical format "Sim/N∆o" initial no label "Fornec Exportaá∆o" column-label "Fornec Export"
    field tta_log_pagto_bloqdo             as logical format "Sim/N∆o" initial no label "Bloqueia Pagamento" column-label "Pagto Bloqdo"
    field tta_log_retenc_impto             as logical format "Sim/N∆o" initial no label "RetÇm Imposto" column-label "RetÇm Imposto"
    field tta_dat_ult_impl_tit_ap          as date format "99/99/9999" initial ? label "Data Ultima Impl" column-label "Dt Ult Impl"
    field tta_dat_ult_pagto                as date format "99/99/9999" initial ? label "Data Èltimo Pagto" column-label "Data Èltimo Pagto"
    field tta_dat_impl_maior_tit_ap        as date format "99/99/9999" initial ? label "Dt Impl Maior Tit" column-label "Dt Maior Tit"
    field tta_num_antecip_aber             as integer format ">>>>9" initial 0 label "Quant Antec  Aberto" column-label "Qtd Antec"
    field tta_num_tit_ap_aber              as integer format ">>>>9" initial 0 label "Quant Tit  Aberto" column-label "Qtd Tit Abert"
    field tta_val_tit_ap_maior_val         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Tit Impl" column-label "Valor Maior T°tulo"
    field tta_val_tit_ap_maior_val_aber    as decimal format "->>>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Maior Tit  Aberto" column-label "Maior Vl Aberto"
    field tta_val_sdo_antecip_aber         as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Antec Aberto" column-label "Sdo Antecip Aberto"
    field tta_val_sdo_tit_ap_aber          as decimal format "->>>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Tit   Aberto" column-label "Sdo Tit Aberto"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_num_rendto_tribut            as integer format ">>9" initial 0 label "Rendto Tribut†vel" column-label "Rendto Tribut†vel"
    field tta_log_vencto_dia_nao_util      as logical format "Sim/N∆o" initial no label "Vencto Igual Dt Flx" column-label "Vencto Igual Dt Flx"
    field tta_val_percent_bonif            as decimal format ">>9.99" decimals 2 initial 0 label "Perc Bonificaá∆o" column-label "Perc Bonificaá∆o"
    field tta_log_indic_rendto             as logical format "Sim/N∆o" initial no label "Ind Rendimento" column-label "Ind Rendimento"
    field tta_num_dias_compcao             as integer format ">>9" initial 0 label "Dias Compensaá∆o" column-label "Dias Compensaá∆o"
    field tta_cod_tax_ident_number         as character format "x(15)" label "Tax Id Number" column-label "Tax Id Number"
    field tta_ind_tip_trans_1099           as character format "X(50)" initial "Rents" label "Tipo Transacao 1099" column-label "Tipo Transacao 1099"
    index tt_frncfnnc_forma_pagto         
          tta_cod_forma_pagto              ascending
    index tt_frncfnnc_id                   is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornecedor               ascending
    index tt_frncfnnc_portador            
          tta_cod_portad_ext               ascending
    .

def temp-table tt_histor_clien_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_num_seq_histor_clien         as integer format ">>>>,>>9" initial 0 label "Sequencia" column-label "Sequencia"
    field tta_des_abrev_histor_clien       as character format "x(40)" label "Abrev Hist¢rico" column-label "Abrev Hist¢rico"
    field tta_des_histor_clien             as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_hstrcln_id                    is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
          tta_num_seq_histor_clien         ascending
    .

def temp-table tt_histor_fornec_integr no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_num_seq_histor_fornec        as integer format ">>>>,>>9" initial 0 label "Sequencia" column-label "Sequencia"
    field tta_des_abrev_histor_fornec      as character format "x(40)" label "Abrev Hist¢rico" column-label "Abrev Hist¢rico"
    field tta_des_histor_fornec            as character format "x(40)" label "Hist¢rico Fornecedor" column-label "Hist¢rico Fornecedor"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_hstrfrna_id                   is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornecedor               ascending
          tta_num_seq_histor_fornec        ascending
    .

def temp-table tt_idiom_contat_integr no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_cod_idioma                   as character format "x(8)" label "Idioma" column-label "Idioma"
    field tta_log_idiom_princ              as logical format "Sim/N∆o" initial no label "Principal" column-label "Principal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_dmcntta_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_nom_abrev_contat             ascending
          tta_cod_idioma                   ascending
    index tt_dmcntta_idioma               
          tta_cod_idioma                   ascending
    .

def temp-table tt_idiom_pf_integr no-undo
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_cod_idioma                   as character format "x(8)" label "Idioma" column-label "Idioma"
    field tta_log_idiom_princ              as logical format "Sim/N∆o" initial no label "Principal" column-label "Principal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_dmpssfs_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_idioma                   ascending
    index tt_dmpssfs_idioma               
          tta_cod_idioma                   ascending
    .

def temp-table tt_integr_acr_fiador_renegoc no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequància" column-label "NumSeq"
    field tta_ind_testem_fiador            as character format "X(08)" label "Testem/Fiador" column-label "Testem/Fiador"
    field tta_ind_tip_pessoa               as character format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field ttv_rec_pessoa_fisic_jurid       as recid format ">>>>>>9"
    index tt_rec_renegoc_id               
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_fiador_reneg_old no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequància" column-label "NumSeq"
    field tta_ind_testem_fiador            as character format "X(08)" label "Testem/Fiador" column-label "Testem/Fiador"
    field tta_ind_tip_pessoa               as character format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field ttv_rec_pessoa_fisic_jurid       as recid format ">>>>>>9"
    index tt_rec_renegoc_id               
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_item_lote_impl_7 no-undo
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condiá∆o Cobranáa" column-label "Cond Cobranáa"
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquidaá∆o" column-label "Prev Liquidaá∆o"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calc Comis" column-label "Base Calc Comis"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D°gito Cta Corrente" column-label "D°gito Cta Corrente"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Banc†ria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Banc†ria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L°quido" column-label "Vl L°quido"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo EspÇcie" column-label "Tipo EspÇcie"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condiá∆o Pagamento" column-label "Condiá∆o Pagamento"
    field ttv_cdn_agenc_fp                 as Integer format ">>>9" label "Agància"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situaá∆o T°tulo" column-label "Situaá∆o T°tulo"
    field tta_log_liquidac_autom           as logical format "Sim/N∆o" initial no label "Liquidac Autom†tica" column-label "Liquidac Autom†tica"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_admdra_cartao_cr         as character format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character format "x(20)" label "C¢digo Cart∆o" column-label "C¢digo Cart∆o"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validade Cart∆o" column-label "Validade Cart∆o"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C¢d PrÇ-Autorizaá∆o" column-label "C¢d PrÇ-Autorizaá∆o"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_conces_telef             as character format "x(5)" label "Concession†ria" column-label "Concession†ria"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "Sim/N∆o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_log_db_autom                 as logical format "Sim/N∆o" initial no label "DÇbito Autom†tico" column-label "DÇbito Autom†tico"
    field tta_log_destinac_cobr            as logical format "Sim/N∆o" initial no label "Destin Cobranáa" column-label "Destin Cobranáa"
    field tta_ind_sit_bcia_tit_acr         as character format "X(12)" initial "Liberado" label "Sit Banc†ria" column-label "Sit Banc†ria"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num T°tulo Banco" column-label "Num T°tulo Banco"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Agància Cobranáa" column-label "Agància Cobr"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobranáa" column-label "Obs Cobranáa"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo C†lculo Juros" column-label "Tipo C†lculo Juros"
    field ttv_cod_comprov_vda              as character format "x(12)" label "Comprovante Venda" column-label "Comprovante Venda"
    field ttv_num_parc_cartcred            as integer format ">9" label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_cod_autoriz_bco_emissor      as character format "x(6)" label "Codigo Autorizaá∆o" column-label "Codigo Autorizaá∆o"
    field ttv_cod_lote_origin              as character format "x(7)" label "Lote Orig Venda" column-label "Lote Orig Venda"
    field ttv_cod_estab_vendor             as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_num_planilha_vendor          as integer format ">>>,>>>,>>9" initial 0 label "Planilha Vendor" column-label "Planilha Vendor"
    field ttv_cod_cond_pagto_vendor        as character format "x(3)" initial "0" label "Condiá∆o Pagto" column-label "Condiá∆o Pagto"
    field ttv_val_cotac_tax_vendor_clien   as decimal format ">>9.9999999999" decimals 10 label "Taxa Vendor Cliente" column-label "Taxa Vendor Cliente"
    field ttv_dat_base_fechto_vendor       as date format "99/99/9999" initial today label "Data Base" column-label "Data Base"
    field ttv_qti_dias_carenc_fechto       as Integer format "->>9" label "Dias Carància" column-label "Dias Carància"
    field ttv_log_assume_tax_bco           as logical format "Sim/N∆o" initial no label "Assume Taxa Banco" column-label "Assume Taxa Banco"
    field ttv_log_vendor                   as logical format "Sim/N∆o" initial no
    field ttv_cod_estab_portad             as character format "x(8)"
    field tta_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    field ttv_val_cr_pis                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito PIS" column-label "Vl Cred PIS/PASEP"
    field ttv_val_cr_cofins                as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito COFINS" column-label "Credito COFINS"
    field ttv_val_cr_csll                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito CSLL" column-label "Credito CSLL"
    field tta_cod_indic_econ_desemb        as character format "x(8)" label "Moeda Desembolso" column-label "Moeda Desembolso"
    field tta_val_base_calc_impto          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calculo Impto" column-label "Base Calculo Impto"
    field tta_log_retenc_impto_impl        as logical format "Sim/N∆o" initial no label "Ret Imposto Impl" column-label "Ret Imposto Impl"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending
    .

def temp-table tt_integr_acr_item_renegoc no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_cod_estab_tit_acr            as character format "x(8)" label "Estab T°tulo ACR" column-label "Estab T°tulo ACR"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    index tt_rec_index                    
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_item_renegoc_new no-undo
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquidaá∆o" column-label "Prev Liquidaá∆o"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field ttv_rec_renegoc_acr_novo         as recid format ">>>>>>9"
    field ttv_val_cr_pis                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito PIS" column-label "Vl Cred PIS/PASEP"
    field ttv_val_cr_cofins                as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito COFINS" column-label "Credito COFINS"
    field ttv_val_cr_csll                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CrÇdito CSLL" column-label "Credito CSLL"
    field tta_val_base_calc_impto          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calculo Impto" column-label "Base Calculo Impto"
    field tta_log_retenc_impto_impl        as logical format "Sim/N∆o" initial no label "Ret Imposto Impl" column-label "Ret Imposto Impl"
    field tta_log_val_fix_parc             as logical format "Sim/N∆o" initial no label "Fixa Valor Parcela" column-label "Fixa Valor Parcela"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    .

def temp-table tt_integr_acr_item_renegoc_old no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_cod_estab_tit_acr            as character format "x(8)" label "Estab T°tulo ACR" column-label "Estab T°tulo ACR"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_dat_novo_vencto_tit_acr      as date format "99/99/9999" initial ? label "Novo Vencimento" column-label "Novo Vencimento"
    field tta_val_juros_renegoc_tit_acr    as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_multa_renegoc_tit_acr    as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Multa" column-label "Valor Multa"
    field tta_val_juros_renegoc_calcul     as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Calculado" column-label "Juros Calc"
    field tta_val_multa_renegoc_calcul     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Calculada" column-label "Multa Calcul"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    index tt_rec_index                    
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_item_reneg_old2 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_cod_estab_tit_acr            as character format "x(8)" label "Estab T°tulo ACR" column-label "Estab T°tulo ACR"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_dat_novo_vencto_tit_acr      as date format "99/99/9999" initial ? label "Novo Vencimento" column-label "Novo Vencimento"
    field tta_val_juros_renegoc_tit_acr    as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_multa_renegoc_tit_acr    as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Multa" column-label "Valor Multa"
    field tta_val_juros_renegoc_calcul     as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Calculado" column-label "Juros Calc"
    field tta_val_multa_renegoc_calcul     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Calculada" column-label "Multa Calcul"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    index tt_rec_index                    
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_renegoc no-undo
    field tta_cod_estab                    as Character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field ttv_log_atualiza_renegoc         as logical format "Sim/N∆o" initial no
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_qtd_parc_renegoc             as decimal format ">9" initial 1 label "Qtd Parcelas" column-label "Qtd Parcelas"
    field tta_ind_vencto_renegoc           as character format "X(10)" initial "Di†ria" label "Periodicidade Vencto" column-label "Vencimento"
    field tta_num_dias_vencto_renegoc      as integer format ">9" initial 0 label "Dias Vencimentto" column-label "Dias Vencimento"
    field tta_num_dia_mes_base_vencto      as integer format ">9" initial 0 label "Dia Base Vencto" column-label "Dia Base Ven"
    field tta_dat_primei_vencto_renegoc    as date format "99/99/9999" initial ? label "Primeiro Vencto" column-label "Primeiro Vencto"
    field tta_log_juros_param_estab_reaj   as logical format "Sim/N∆o" initial yes label "Consid Juros Padr∆o" column-label "Juros Pad"
    field tta_cod_indic_econ_reaj_renegoc  as character format "x(8)" label "Ind Reajuste" column-label "÷ndice Reaj"
    field tta_val_perc_reaj_renegoc        as decimal format ">>9.99" decimals 2 initial 0 label "Reajuste" column-label "Reaj"
    field tta_val_acresc_parc              as decimal format ">>9.99" decimals 2 initial 0 label "Acrescimo Parcela" column-label "Acrescimo Parcela"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo C†lculo Juros" column-label "Tipo C†lculo Juros"
    field tta_log_soma_movto_cobr          as logical format "Sim/N∆o" initial no label "Soma Movtos Cobr" column-label "Soma Movtos Cobr"
    field ttv_log_bxo_estab_tit_2          as logical format "Sim/N∆o" initial no label "Liq no Estab T°tulo" column-label "Liq no Estab T°tulo"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field tta_cod_cond_cobr                as character format "x(8)" label "Condiá∆o Cobranáa" column-label "Cond Cobranáa"
    .

def temp-table tt_integr_acr_renegoc_old no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condiá∆o Pagamento" column-label "Condiá∆o Pagamento"
    field tta_val_renegoc_cobr_acr         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_num_id_renegoc_cobr_acr      as integer format ">>>>,>>9" initial 0 label "Id Renegociaá∆o" column-label "Id Reneg"
    field tta_val_perc_juros_renegoc       as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Perc Juros" column-label "Perc Juros"
    field tta_ind_tip_renegoc_acr          as character format "X(15)" initial "Prorroga" label "Tipo Renegociaá∆o" column-label "Tipo Renegociaá∆o"
    field tta_log_renegoc_acr_estordo      as logical format "Sim/N∆o" initial no label "Reneg Estornada" column-label "Renegoc Estornada"
    field tta_cod_indic_econ_val_pres      as character format "x(8)" label "÷ndice Reajuste" column-label "÷ndice Reaj"
    field tta_val_perc_val_pres            as decimal format ">>9.99" decimals 2 initial 0 label "%" column-label "%"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_log_livre_1                  as logical format "Sim/N∆o" initial no label "Livre 1" column-label "Livre 1"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_2                  as logical format "Sim/N∆o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_log_consid_juros_renegoc     as logical format "Sim/N∆o" initial yes label "Considera Juros" column-label "Consid Juros"
    field tta_log_consid_multa_renegoc     as logical format "Sim/N∆o" initial yes label "Considera Multa" column-label "Considera Multa"
    field tta_log_consid_abat_renegoc      as logical format "Sim/N∆o" initial no label "Considera Abatimento" column-label "Consid Abatimento"
    field tta_log_consid_desc_renegoc      as logical format "Sim/N∆o" initial no label "Considera Desconto" column-label "Consid Desconto"
    field tta_val_perc_reaj_renegoc        as decimal format ">>9.99" decimals 2 initial 0 label "Reajuste" column-label "Reaj"
    field tta_val_juros_renegoc_calcul     as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Calculado" column-label "Juros Calc"
    field tta_val_juros_renegoc_infor      as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Informado" column-label "Juros Inform"
    field tta_val_multa_renegoc_calcul     as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Calculada" column-label "Multa Calcul"
    field tta_val_multa_renegoc_infor      as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Informada" column-label "Multa Informada"
    field tta_val_tot_reaj_renegoc         as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Reajuste" column-label "Total Reajuste"
    field tta_val_tot_ajust_renegoc        as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Ajuste" column-label "Total Ajuste"
    field tta_ind_sit_renegoc_acr          as character format "X(10)" initial "Pendente" label "Situaá∆o" column-label "Situaá∆o"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_ind_base_calc_reaj           as character format "X(17)" initial "Principal" label "Base Calculo" column-label "Base Calculo"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_qtd_parc_renegoc             as decimal format ">9" initial 1 label "Qtd Parcelas" column-label "Qtd Parcelas"
    field tta_ind_vencto_renegoc           as character format "X(10)" initial "Di†ria" label "Periodicidade Vencto" column-label "Vencimento"
    field tta_num_dia_mes_base_vencto      as integer format ">9" initial 0 label "Dia Base Vencto" column-label "Dia Base Ven"
    field tta_num_dias_vencto_renegoc      as integer format ">9" initial 0 label "Dias Vencimentto" column-label "Dias Vencimento"
    field tta_cod_indic_econ_reaj_renegoc  as character format "x(8)" label "Ind Reajuste" column-label "÷ndice Reaj"
    field tta_dat_primei_vencto_renegoc    as date format "99/99/9999" initial ? label "Primeiro Vencto" column-label "Primeiro Vencto"
    field tta_ind_calc_juros_desc          as character format "X(08)" label "Calculo Juros" column-label "Calculo Juros"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condiá∆o Cobranáa" column-label "Cond Cobranáa"
    field tta_log_juros_param_estab_reaj   as logical format "Sim/N∆o" initial yes label "Consid Juros Padr∆o" column-label "Juros Pad"
    field ttv_rec_renegoc_acr              as recid format ">>>>>>9" initial ?
    field ttv_log_atualiza_salario_admit   as logical format "Sim/N∆o" initial No
    field ttv_log_atualiza_renegoc         as logical format "Sim/N∆o" initial no
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usu†rio Corrente" column-label "Usu†rio Corrente"
    field tta_log_soma_movto_cobr          as logical format "Sim/N∆o" initial no label "Soma Movtos Cobr" column-label "Soma Movtos Cobr"
    field tta_val_acresc_parc              as decimal format ">>9.99" decimals 2 initial 0 label "Acrescimo Parcela" column-label "Acrescimo Parcela"
    index tt_rngccr_id                     is primary unique
          tta_cod_estab                    ascending
          tta_num_renegoc_cobr_acr         ascending
    .

def new shared temp-table tt_item_lote_impl_tit_acr         like item_lote_impl_tit_acr
&if "{&emsfin_version}" >= "5.01" &then
    use-index itmltmpa_id                  as primary
&endif
&if "{&emsfin_version}" >= "5.01" &then
    use-index itmltmpa_titulo             
&endif
    .

def new shared temp-table tt_item_renegoc_acr         like item_renegoc_acr
    .

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    .

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "SeqÅància" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistància" column-label "Inconsistància"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    index tt_id                           
          ttv_num_seq                      ascending
          ttv_num_cod_erro                 ascending
    .

def new shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento"
    .

def temp-table tt_log_erros_renegoc no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_num_seq_item_renegoc_acr     as integer format ">>>>,>>9" initial 0 label "Sequància Item" column-label "Sequància Item"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_fiador                   as character format "x(8)" label "Fiador" column-label "Fiador"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_num_mensagem                 as integer format ">>,>>>,>>9" initial 0 label "Mensagem" column-label "Mensagem"
    field ttv_des_msg                      as character format "x(40)"
    field ttv_des_help                     as character format "x(40)" label "Ajuda" column-label "Ajuda"
    index tt_num_mensagem                  is primary
          tta_num_mensagem                 ascending
    .

def temp-table tt_log_erros_renegoc_acr no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegociaá∆o"
    field tta_num_seq_item_renegoc_acr     as integer format ">>>>,>>9" initial 0 label "Sequància Item" column-label "Sequància Item"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_fiador                   as character format "x(8)" label "Fiador" column-label "Fiador"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_num_mensagem                 as integer format ">>,>>>,>>9" initial 0 label "Mensagem" column-label "Mensagem"
    field ttv_des_msg                      as character format "x(40)"
    .

def new shared temp-table tt_param_correc_val no-undo
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field ttv_val_cotac_fasb_emis          as decimal format ">>>>,>>9.9999999999" decimals 10
    field tta_val_prev_cotac_fasb          as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Previs Fasb" column-label "Cotac Previs Fasb"
    field tta_val_cotac_cm_emis            as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Cm Emiss" column-label "Cotac Cm Emiss"
    field ttv_val_cotac_fasb_emis_antecip  as decimal format ">>>>,>>9.9999999999" decimals 10
    field ttv_val_cotac_cm_emis_antecip    as decimal format ">>>>,>>9.9999999999" decimals 10
    field ttv_val_movto                    as decimal format "->,>>>,>>>,>>9.99" decimals 2 label "Movimento" column-label "Valor Movto"
    field ttv_val_movto_antecip            as decimal format ">>>>>,>>>,>>9.99" decimals 2
    field ttv_val_sdo_base                 as decimal format "->>>>,>>>,>>>,>>9.99" decimals 2 label "Saldo Base"
    .

def temp-table tt_ped_vda_tit_acr_pend no-undo like ped_vda_tit_acr_pend
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cod_ped_vda                  as character format "x(12)" label "Pedido Venda" column-label "Pedido Venda"
    field tta_cod_ped_vda_repres           as character format "x(12)" label "Pedido Repres" column-label "Pedido Repres"
    field tta_val_perc_particip_ped_vda    as decimal format ">>9.99" decimals 2 initial 0 label "Particip Ped Vda" column-label "Particip"
    field tta_des_ped_vda                  as character format "x(40)" label "Pedido Venda" column-label "Pedido Venda"
    field tta_val_sdo_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo T°tulo" column-label "Saldo T°tulo"
    index tt_ped_vda                       is primary unique
          tta_cod_estab                    ascending
          tta_num_seq_refer                ascending
          tta_cod_ped_vda                  ascending
          tta_cod_ped_vda_repres           ascending
          tta_val_perc_particip_ped_vda    ascending
    .

def temp-table tt_pessoa_estrangeira no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    index tt_id                            is primary unique
          tta_cdn_fornecedor               ascending
          tta_num_pessoa_jurid             ascending
    .

def temp-table tt_pessoa_fisic_integr no-undo
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_fisic           as character format "x(20)" initial ? label "ID Estadual F°sica" column-label "ID Estadual F°sica"
    field tta_cod_orgao_emis_id_estad      as character format "x(10)" label "‡rg∆o Emissor" column-label "‡rg∆o Emissor"
    field tta_cod_unid_federac_emis_estad  as character format "x(3)" label "Estado Emiss∆o" column-label "UF Emis"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal                    as character format "x(7)" label "Ramal" column-label "Ramal"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_dat_nasc_pessoa_fisic        as date format "99/99/9999" initial ? label "Nascimento" column-label "Data Nasc"
    field ttv_cod_pais_ext_nasc            as character format "x(20)" label "Pa°s Ext Nascimento" column-label "Pa°s Ext Nascimento"
    field ttv_cod_pais_nasc                as character format "x(3)" label "Pa°s Nascimento" column-label "Pa°s Nasc"
    field tta_cod_unid_federac_nasc        as character format "x(3)" label "Estado Nascimento" column-label "UF Nasc"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_nom_mae_pessoa               as character format "x(40)" label "M∆e Pessoa" column-label "M∆e Pes"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    index tt_pssfsca_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssfsca_identpes             
          tta_nom_pessoa                   ascending
          tta_cod_id_estad_fisic           ascending
          tta_cod_unid_federac_emis_estad  ascending
          tta_dat_nasc_pessoa_fisic        ascending
          tta_nom_mae_pessoa               ascending
    index tt_pssfsca_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssfsca_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_fisic_integr_old no-undo
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_fisic           as character format "x(20)" initial ? label "ID Estadual F°sica" column-label "ID Estadual F°sica"
    field tta_cod_orgao_emis_id_estad      as character format "x(10)" label "‡rg∆o Emissor" column-label "‡rg∆o Emissor"
    field tta_cod_unid_federac_emis_estad  as character format "x(3)" label "Estado Emiss∆o" column-label "UF Emis"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal                    as character format "x(7)" label "Ramal" column-label "Ramal"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_dat_nasc_pessoa_fisic        as date format "99/99/9999" initial ? label "Nascimento" column-label "Data Nasc"
    field ttv_cod_pais_ext_nasc            as character format "x(20)" label "Pa°s Ext Nascimento" column-label "Pa°s Ext Nascimento"
    field ttv_cod_pais_nasc                as character format "x(3)" label "Pa°s Nascimento" column-label "Pa°s Nasc"
    field tta_cod_unid_federac_nasc        as character format "x(3)" label "Estado Nascimento" column-label "UF Nasc"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_nom_mae_pessoa               as character format "x(40)" label "M∆e Pessoa" column-label "M∆e Pes"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    index tt_pssfsca_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssfsca_identpes             
          tta_nom_pessoa                   ascending
          tta_cod_id_estad_fisic           ascending
          tta_cod_unid_federac_emis_estad  ascending
          tta_dat_nasc_pessoa_fisic        ascending
          tta_nom_mae_pessoa               ascending
    index tt_pssfsca_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssfsca_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_jurid_integr no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_jurid           as character format "x(20)" initial ? label "ID Estadual" column-label "ID Estadual"
    field tta_cod_id_munic_jurid           as character format "x(20)" initial ? label "ID Municipal" column-label "ID Municipal"
    field tta_cod_id_previd_social         as character format "x(20)" label "Id Previdància" column-label "Id Previdància"
    field tta_log_fins_lucrat              as logical format "Sim/N∆o" initial yes label "Fins Lucrativos" column-label "Fins Lucrativos"
    field tta_num_pessoa_jurid_matriz      as integer format ">>>,>>>,>>9" initial 0 label "Matriz" column-label "Matriz"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_ind_tip_pessoa_jurid         as character format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_ind_tip_capit_pessoa_jurid   as character format "X(13)" label "Tipo Capital" column-label "Tipo Capital"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_num_pessoa_jurid_cobr        as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica Cobr" column-label "Pessoa Jur°dica Cobr"
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_cob             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_num_pessoa_jurid_pagto       as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jurid Pagto" column-label "Pessoa Jurid Pagto"
    field tta_nom_ender_pagto              as character format "x(40)" label "Endereáo Pagamento" column-label "Endereáo Pagamento"
    field tta_nom_ender_compl_pagto        as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_pagto             as character format "x(20)" label "Bairro Pagamento" column-label "Bairro Pagamento"
    field tta_nom_cidad_pagto              as character format "x(32)" label "Cidade Pagamento" column-label "Cidade Pagamento"
    field tta_nom_condad_pagto             as character format "x(32)" label "Condado Pagamento" column-label "Condado Pagamento"
    field tta_cod_unid_federac_pagto       as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_pag             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_pagto               as character format "x(3)" label "Pa°s Pagamento" column-label "Pa°s Pagamento"
    field tta_cod_cep_pagto                as character format "x(20)" label "CEP Pagamento" column-label "CEP Pagamento"
    field tta_cod_cx_post_pagto            as character format "x(20)" label "Caixa Postal Pagamen" column-label "Caixa Postal Pagamen"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    index tt_pssjrda_cobranca             
          tta_num_pessoa_jurid_cobr        ascending
    index tt_pssjrda_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssjrda_id_previd_social     
          tta_cod_pais_ext                 ascending
          tta_cod_id_previd_social         ascending
    index tt_pssjrda_matriz               
          tta_num_pessoa_jurid_matriz      ascending
    index tt_pssjrda_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssjrda_pagto                
          tta_num_pessoa_jurid_pagto       ascending
    index tt_pssjrda_razao_social         
          tta_nom_pessoa                   ascending
    index tt_pssjrda_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_jurid_integr_old_2 no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_jurid           as character format "x(20)" initial ? label "ID Estadual" column-label "ID Estadual"
    field tta_cod_id_munic_jurid           as character format "x(20)" initial ? label "ID Municipal" column-label "ID Municipal"
    field tta_cod_id_previd_social         as character format "x(20)" label "Id Previdància" column-label "Id Previdància"
    field tta_log_fins_lucrat              as logical format "Sim/N∆o" initial yes label "Fins Lucrativos" column-label "Fins Lucrativos"
    field tta_num_pessoa_jurid_matriz      as integer format ">>>,>>>,>>9" initial 0 label "Matriz" column-label "Matriz"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_ind_tip_pessoa_jurid         as character format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_ind_tip_capit_pessoa_jurid   as character format "X(13)" label "Tipo Capital" column-label "Tipo Capital"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_num_pessoa_jurid_cobr        as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica Cobr" column-label "Pessoa Jur°dica Cobr"
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_cob             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_num_pessoa_jurid_pagto       as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jurid Pagto" column-label "Pessoa Jurid Pagto"
    field tta_nom_ender_pagto              as character format "x(40)" label "Endereáo Pagamento" column-label "Endereáo Pagamento"
    field tta_nom_ender_compl_pagto        as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_pagto             as character format "x(20)" label "Bairro Pagamento" column-label "Bairro Pagamento"
    field tta_nom_cidad_pagto              as character format "x(32)" label "Cidade Pagamento" column-label "Cidade Pagamento"
    field tta_nom_condad_pagto             as character format "x(32)" label "Condado Pagamento" column-label "Condado Pagamento"
    field tta_cod_unid_federac_pagto       as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_pag             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_pagto               as character format "x(3)" label "Pa°s Pagamento" column-label "Pa°s Pagamento"
    field tta_cod_cep_pagto                as character format "x(20)" label "CEP Pagamento" column-label "CEP Pagamento"
    field tta_cod_cx_post_pagto            as character format "x(20)" label "Caixa Postal Pagamen" column-label "Caixa Postal Pagamen"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    field ttv_cod_num_ender                as character format "x(06)"
    field ttv_cod_num_ender_cobr           as character format "x(06)"
    field ttv_cod_num_ender_pagto          as character format "x(06)"
    index tt_pssjrda_cobranca             
          tta_num_pessoa_jurid_cobr        ascending
    index tt_pssjrda_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssjrda_id_previd_social     
          tta_cod_pais_ext                 ascending
          tta_cod_id_previd_social         ascending
    index tt_pssjrda_matriz               
          tta_num_pessoa_jurid_matriz      ascending
    index tt_pssjrda_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssjrda_pagto                
          tta_num_pessoa_jurid_pagto       ascending
    index tt_pssjrda_razao_social         
          tta_nom_pessoa                   ascending
    index tt_pssjrda_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pj_ativid_integr_i no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_cod_ativid_pessoa_jurid      as character format "x(8)" label "Atividade" column-label "Atividade"
    field tta_log_ativid_pessoa_princ      as logical format "Sim/N∆o" initial no label "Atividade Principal" column-label "Principal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_cdn_clien_fornec             as Integer format ">>>,>>9" initial 0 column-label "Codigo Cli\Fornc"
    index tt_pssjrdtv_atividade           
          tta_cod_ativid_pessoa_jurid      ascending
    index tt_pssjrdtv_id                   is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_ativid_pessoa_jurid      ascending
          ttv_cdn_clien_fornec             ascending
    .

def temp-table tt_pj_ramo_negoc_integr_j no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_cod_ramo_negoc               as character format "x(8)" label "Ramo Neg¢cio" column-label "Ramo Neg¢cio"
    field tta_log_ramo_negoc_princ         as logical format "Sim/N∆o" initial no label "Ramo Negoc Principal" column-label "Principal"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_cdn_clien_fornec             as Integer format ">>>,>>9" initial 0 column-label "Codigo Cli\Fornc"
    index tt_pssjrdm_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_ramo_negoc               ascending
          ttv_cdn_clien_fornec             ascending
    index tt_pssjrdrm_ramo_negoc          
          tta_cod_ramo_negoc               ascending
    .

def temp-table tt_porte_pj_integr no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_dat_porte_pessoa_jurid       as date format "99/99/9999" initial ? label "Data Porte" column-label "Data Porte"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_vendas                   as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vendas" column-label "Vendas"
    field tta_val_patrim_liq               as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Patrimìnio L°quido" column-label "Patrimìnio L°quido"
    field tta_val_lucro_liq                as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Lucro L°quido" column-label "Lucro L°quido"
    field tta_val_capit_giro_proprio       as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Capital Giro Pr¢prio" column-label "Capital Giro Pr¢prio"
    field tta_val_endivto_geral            as decimal format ">>9.99" decimals 2 initial 0 label "Endividamento Geral" column-label "Endividamento Geral"
    field tta_val_endivto_longo_praz       as decimal format ">>9.99" decimals 2 initial 0 label "Endividamento Longo" column-label "Endividamento Longo"
    field tta_val_vendas_func              as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Vendas Funcion†rio" column-label "Vendas Funcion†rio"
    field tta_qtd_funcionario              as decimal format ">>>,>>9" initial 0 label "Qtd Funcion†rios" column-label "Qtd Funcion†rios"
    field tta_cod_classif_pessoa_jurid     as character format "x(8)" label "Classificaá∆o" column-label "Classificaá∆o"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    index tt_prtpssjr_id                   is primary unique
          tta_num_pessoa_jurid             ascending
          tta_dat_porte_pessoa_jurid       ascending
    index tt_prtpssjr_indic_econ          
          tta_cod_indic_econ               ascending
    .

def temp-table tt_repres_tit_acr no-undo like repres_tit_acr
    .

def temp-table tt_repres_tit_acr_comis_ext no-undo
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field ttv_ind_tip_comis_ext            as character format "X(15)" initial "Nenhum" label "Tipo de Comiss∆o" column-label "Tipo de Comiss∆o"
    field ttv_ind_liber_pagto_comis        as character format "X(20)" initial "Nenhum" label "Lib Pagto Comis" column-label "Lib Comis"
    field ttv_ind_sit_comis_ext            as character format "X(10)" initial "Nenhum" label "Sit Comis Ext" column-label "Sit Comis Ext"
    index tt_cdn_repres                   
          tta_cdn_repres                   ascending
    .

def temp-table tt_retorno_clien_fornec no-undo
    field ttv_cod_parameters               as character format "x(256)"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    field ttv_cod_parameters_clien         as character format "x(2000)"
    field ttv_cod_parameters_fornec        as character format "x(2000)"
    field ttv_log_envdo                    as logical format "Sim/N∆o" initial no
    field ttv_cod_parameters_clien_financ  as character format "x(2000)"
    field ttv_cod_parameters_fornec_financ as character format "x(2000)"
    field ttv_cod_parameters_pessoa_fisic  as character format "x(2000)"
    field ttv_cod_parameters_pessoa_jurid  as character format "x(2000)"
    field ttv_cod_parameters_estrut_clien  as character format "x(2000)"
    field ttv_cod_parameters_estrut_fornec as character format "x(2000)"
    field ttv_cod_parameters_contat        as character format "x(2000)"
    field ttv_cod_parameters_repres        as character format "x(2000)"
    field ttv_cod_parameters_ender_entreg  as character format "x(2000)"
    field ttv_cod_parameters_pessoa_ativid as character format "x(2000)"
    field ttv_cod_parameters_ramo_negoc    as character format "x(2000)"
    field ttv_cod_parameters_porte_pessoa  as character format "x(2000)"
    field ttv_cod_parameters_idiom_pessoa  as character format "x(2000)"
    field ttv_cod_parameters_clas_contat   as character format "x(2000)"
    field ttv_cod_parameters_idiom_contat  as character format "x(2000)"
    field ttv_cod_parameters_telef         as character format "x(2000)"
    field ttv_cod_parameters_telef_pessoa  as character format "x(2000)"
    field ttv_cod_parameters_histor_clien  as character format "x(4000)"
    field ttv_cod_parameters_histor_fornec as character format "x(4000)"
    .

def temp-table tt_telef_pessoa_integr no-undo
    field tta_cod_telef_sem_edic           as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_des_telefone                 as character format "x(40)" label "Descriá∆o Telefone" column-label "Descriá∆o Telefone"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    index tt_tlfpss_id                     is primary unique
          tta_cod_telef_sem_edic           ascending
          tta_num_pessoa                   ascending
          tta_cdn_cliente                  ascending
          tta_cdn_fornecedor               ascending
    index tt_tlfpss_pessoa                 is unique
          tta_num_pessoa                   ascending
          tta_cod_telef_sem_edic           ascending
    .

def temp-table tt_xml_input_output no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_des_conteudo_aux             as character format "x(40)"
    field ttv_num_seq_1                    as integer format ">>>,>>9"
    .



/********************** Temporary Table Definition End **********************/

/************************** Buffer Definition Begin *************************/

&if "{&emsuni_version}" >= "5.01" &then
def buffer b_cliente
    for ems5.cliente.
&endif
&if "{&emsuni_version}" >= "5.01" &then
def buffer b_cliente_pesquisa
    for ems5.cliente.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_empresa
    for ems5.empresa.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_fornecedor_matriz
    for ems5.fornecedor.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_fornecedor_pesquisa
    for ems5.fornecedor.
&endif
&if "{&emsuni_version}" >= "5.00" &then
def buffer b_histor_fornec
    for histor_fornec.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_item_renegoc_acr
    for item_renegoc_acr.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_item_renegoc_acr_verif
    for item_renegoc_acr.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_pessoa_fisic
    for pessoa_fisic.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_pessoa_jurid
    for pessoa_jurid.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_pessoa_jurid_filial
    for pessoa_jurid.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_renegoc_acr
    for renegoc_acr.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_renegoc_acr_integr
    for renegoc_acr.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_renegoc_acr_validar
    for renegoc_acr.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_tit_acr_renegoc
    for tit_acr.
&endif


/*************************** Buffer Definition End **************************/

/************************* Variable Definition Begin ************************/

def var v_cdn_cliente
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente"
    no-undo.
def var v_cdn_cont
    as Integer
    format ">>>,>>9":U
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def var v_cod_arquivo
    as character
    format "x(60)":U
    no-undo.
def var v_cod_cart_bcia
    as character
    format "x(3)":U
    label "Carteira"
    column-label "Carteira"
    no-undo.
def var v_cod_cart_bcia_prefer
    as character
    format "x(3)":U
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_digito_calcul
    as character
    format "x(2)":U
    no-undo.
def var v_cod_digito_id_feder
    as character
    format "x(2)":U
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu†rio"
    column-label "Usu†rio"
    no-undo.
def var v_cod_empresa
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def var v_cod_empresa_xml
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def var v_cod_empres_integr
    as character
    format "x(3)":U
    label "Empresa Integraá∆o"
    column-label "Emp Integraá∆o"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_finalid_econ
    as character
    format "x(10)":U
    label "Finalidade Econìmica"
    column-label "Finalidade Econìmica"
    no-undo.
def var v_cod_format_agenc_bcia
    as character
    format "x(10)":U
    label "Formato Agància"
    column-label "Formato Agància"
    no-undo.
def var v_cod_format_cep
    as character
    format "x(8)":U
    no-undo.
def var v_cod_format_cta_corren
    as character
    format "x(20)":U
    label "Formato Conta"
    column-label "Formato Conta"
    no-undo.
def var v_cod_format_id_estad_fisic
    as character
    format "x(20)":U
    label "Formato ID Est"
    column-label "Formato ID Est Fisic"
    no-undo.
def var v_cod_format_id_feder_fisic
    as character
    format "x(20)":U
    label "Formato ID Fed"
    column-label "Formato ID Fed Fisic"
    no-undo.
def var v_cod_format_id_feder_jurid
    as character
    format "x(20)":U
    label "Formato ID Fed"
    column-label "Format ID Fed Jurid"
    no-undo.
def var v_cod_format_id_previd_jurid
    as character
    format "x(20)":U
    label "Formato ID Previd"
    column-label "Formato Previd"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usu†rios"
    column-label "Grupo"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def var v_cod_id_estad_fisic
    as character
    format "x(20)":U
    label "ID Estadual F°sica"
    column-label "ID Estadual F°sica"
    no-undo.
def var v_cod_id_feder
    as character
    format "x(20)":U
    label "Fornecedor"
    column-label "ID Federal"
    no-undo.
def var v_cod_id_feder_fisic_aux
    as character
    format "x(20)":U
    no-undo.
def var v_cod_id_feder_jurid_aux
    as character
    format "x(20)":U
    no-undo.
def var v_cod_id_previd_social
    as character
    format "x(20)":U
    label "Id Previdància"
    column-label "Id Previdància"
    no-undo.
def new global shared var v_cod_modul_dtsul_corren
    as character
    format "x(3)":U
    label "M¢dulo Corrente"
    column-label "M¢dulo Corrente"
    no-undo.
def new global shared var v_cod_modul_dtsul_empres
    as character
    format "x(100)":U
    no-undo.
def var v_cod_moeda
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Moeda"
    no-undo.
def var v_cod_num_ender
    as character
    format "x(06)":U
    no-undo.
def var v_cod_operador
    as character
    format "x(8)":U
    label "Operador"
    column-label "Operador"
    no-undo.
def var v_cod_pais
    as character
    format "x(3)":U
    label "Pa°s"
    column-label "Pa°s"
    no-undo.
def var v_cod_pais_cobr
    as character
    format "x(3)":U
    label "Pa°s Cobranáa"
    column-label "Pa°s Cobranáa"
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def var v_cod_pais_nasc
    as character
    format "x(3)":U
    label "Pa°s Nascimento"
    column-label "Pa°s Nasc"
    no-undo.
def var v_cod_pais_pagto
    as character
    format "x(3)":U
    label "Pa°s Pagamento"
    column-label "Pa°s Pagamento"
    no-undo.
def var v_cod_parameters
    as character
    format "x(256)":U
    no-undo.
def var v_cod_parameters_clas_contat
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_clien
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_clien_financ
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_contat
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_ender_entreg
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_estrut_clien
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_estrut_fornec
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_fornec
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_fornec_financ
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_histor_clien
    as character
    format "x(4000)":U
    no-undo.
def var v_cod_parameters_histor_fornec
    as character
    format "x(4000)":U
    no-undo.
def var v_cod_parameters_idiom_contat
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_idiom_pessoa
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_pessoa_ativid
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_pessoa_fisic
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_pessoa_jurid
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_porte_pessoa
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_ramo_negoc
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_telef
    as character
    format "x(2000)":U
    no-undo.
def var v_cod_parameters_telef_pessoa
    as character
    format "x(2000)":U
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def var v_cod_portador
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador"
    no-undo.
def var v_cod_portad_prefer
    as character
    format "x(5)":U
    label "Portador Preferenc"
    column-label "Port Preferenc"
    no-undo.
def var v_cod_portad_trad
    as character
    format "x(5)":U
    label "C¢digo Portador"
    column-label "Cod Port"
    no-undo.
def var v_cod_return
    as character
    format "x(40)":U
    no-undo.
def var v_cod_tip_fluxo_financ
    as character
    format "x(12)":U
    label "Tipo Fluxo Financ"
    column-label "Tipo Fluxo Financ"
    no-undo.
def new global shared var v_cod_unid_negoc_usuar
    as character
    format "x(3)":U
    view-as combo-box
    &if "{&FNC_MULTI_IDIOMA}" = "YES" &then
    list-item-pairs "",""
    &else
    list-items ""
    &endif
    inner-lines 5
    bgcolor 15 font 2
    label "Unidade Neg¢cio"
    column-label "Unid Neg¢cio"
    no-undo.
def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu†rio Corrente"
    column-label "Usu†rio Corrente"
    no-undo.
def var v_cod_usuar_corren_ant
    as character
    format "x(12)":U
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_cod_versao
    as character
    format "x(8)":U
    no-undo.
def var v_des_ajuda
    as character
    format "x(50)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 50 by 3
    bgcolor 15 font 2
    label "Ajuda"
    column-label "Ajuda"
    no-undo.
def var v_des_comis
    as character
    format "x(40)":U
    no-undo.
def var v_des_compl
    as character
    format "x(50)":U
    no-undo.
def var v_des_empresa
    as character
    format "x(40)":U
    no-undo.
def var v_des_mensagem
    as character
    format "x(50)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 50 by 4
    bgcolor 15 font 2
    label "Mensagem"
    column-label "Mensagem"
    no-undo.
def var v_des_nom_abrev_fiador_renegoc
    as character
    format "x(40)":U
    no-undo.
def var v_des_orig_msg
    as character
    format "x(40)":U
    label "Origem Mensagem"
    column-label "Origem Mensagem"
    no-undo.
def var v_des_permissao
    as character
    format "x(40)":U
    no-undo.
def new global shared var v_hdl_api_centraliz_acr_vdr
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_hdl_aux
    as Handle
    format ">>>>>>9":U
    no-undo.
def new global shared var v_hdl_eai
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_hdl_funcao_padr
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_ind_bloq_ender_fisc
    as character
    format "X(08)":U
    view-as radio-set Vertical
    radio-buttons "Valida", "Valida", "N∆o Valida", "N∆o Valida", "Bloqueia", "Bloqueia"
     /*l_valida*/ /*l_valida*/ /*l_nao_valida*/ /*l_nao_valida*/ /*l_bloqueia*/ /*l_bloqueia*/
    bgcolor 8 
    label "Bloqueio Endereáo"
    column-label "Bloqueio Endereáo"
    no-undo.
def var v_log_achou_prog
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_acum_matriz
    as logical
    format "Sim/N∆o"
    initial no
    label "Acumula Por Matriz"
    column-label "Acumula Por Matriz"
    no-undo.
def var v_log_altera_portad
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_atualizado
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_atualiza_renegoc
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_bxo_estab
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_compl_histor
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_connect
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_connect_ems2_ok
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_control_id_feder
    as logical
    format "Sim/N∆o"
    initial no
    label "Controla ID Feder"
    column-label "Controla ID Feder"
    no-undo.
def var v_log_cr_cofins_modif
    as logical
    format "Sim/N∆o"
    initial no
    label "Credita COFINS"
    column-label "Credita COFINS"
    no-undo.
def var v_log_cta_fornec
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_ems2
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_error_renegoc_acr
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_erro_gerad
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_erro_impto
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_existe
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_export_table
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_funcao_base_tribut
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_funcao_export_natur_pessoa
    as logical
    format "Sim/N∆o"
    initial no
    label "Export Natur Pessoa"
    column-label "Export Natur Pessoa"
    no-undo.
def var v_log_funcao_tip_calc_juros
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_func_control_comis_renegoc
    as logical
    format "Sim/N∆o"
    initial no
    label "Control Comis Renego"
    column-label "Control Comis Renego"
    no-undo.
def var v_log_func_valid_dat_inic_movto
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_handle
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_inclusao
    as logical
    format "Sim/N∆o"
    initial ?
    label "Inclui"
    column-label "Inclui"
    no-undo.
def var v_log_inform_financ
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_integr_ems2
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Integra EMS2"
    no-undo.
def var v_log_method
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_modul_vendor
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_obs_contat
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_pessoa_fisic_cobr
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_pessoa_jurid_lote
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_refer_uni
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_repeat
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_replic_nom_abrev
    as logical
    format "Sim/N∆o"
    initial NO
    no-undo.
def var v_log_repres
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_retenc_impto_impl
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Impl. com Retená∆o"
    column-label "Impl. com Retená∆o"
    no-undo.
def var v_log_return_epc
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_rpc
    as logical
    format "Sim/N∆o"
    initial no
    label "RPC"
    column-label "RPC"
    no-undo.
def var v_log_tit_acr_unico
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_utiliza_mbh
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_valid_alter_cofins
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_valid_format_cep
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_nom_abrev
    as character
    format "x(15)":U
    label "Nome Abreviado"
    column-label "Nome Abrev"
    no-undo.
def var v_nom_ender_compl
    as character
    format "x(10)":U
    no-undo.
def var v_nom_lograd
    as character
    format "x(30)":U
    label "Logradouro"
    no-undo.
def var v_nom_pessoa
    as character
    format "x(40)":U
    label "Nome"
    column-label "Nome"
    no-undo.
def var v_nom_table_epc
    as character
    format "x(30)":U
    no-undo.
def var v_num_cont_prefer
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont_tit_acr
    as integer
    format ">,>>>,>>9":U
    initial 0
    label "T°tulos ACR Lidos"
    no-undo.
def var v_num_count_1
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_dias_vencto_renegoc
    as integer
    format ">9":U
    label "Dias Vencimentto"
    column-label "Dias Vencimento"
    no-undo.
def var v_num_digito_calcul_1
    as integer
    format "9":U
    no-undo.
def var v_num_digito_calcul_2
    as integer
    format "9":U
    no-undo.
def var v_num_erro
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_ident
    as integer
    format "99":U
    initial 0
    no-undo.
def var v_num_msg
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_multiplic_digito
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_natur
    as integer
    format ">>>>,>>9":U
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_pessoa
    as integer
    format ">>>,>>>,>>9":U
    label "Pessoa"
    column-label "Pessoa"
    no-undo.
def var v_num_pessoa_2
    as integer
    format ">>>,>>>,>>9":U
    label "Pessoa"
    column-label "Pessoa"
    no-undo.
def var v_num_pessoa_aux
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_pessoa_elimina
    as integer
    format ">>>,>>>,>>9":U
    no-undo.
def var v_num_pessoa_fiador_renegoc
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_renegoc_cobr_acr
    as integer
    format ">>>>,>>9":U
    label "Num. Renegoc"
    column-label "Renegociaá∆o"
    no-undo.
def var v_num_seq
    as integer
    format ">>>,>>9":U
    label "SeqÅància"
    column-label "Seq"
    no-undo.
def var v_rec_cliente
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_fornecedor
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_id_clien_fornec
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_ped_vda_tit_acr_pend
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_renegoc_acr
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_restdo_digito
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_sdo_liquidac
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_sdo_tit_acr_integr
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_soma_digito
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    label "Total Geral"
    column-label "Total Geral"
    no-undo.
def var v_val_tot_base_calc
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Base C†lculo"
    column-label "Total Base C†lculo"
    no-undo.
def var v_val_tot_comprtdo
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_cr_cofins
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_cr_csll
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_cr_pis
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_renegoc_tit_acr
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_tit_acr
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total T°tulos"
    column-label "Total"
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_servid_rpc
    as widget-handle
    format ">>>>>>9":U
    label "Handle RPC"
    column-label "Handle RPC"
    no-undo.
def var v_ind_espec_docto                as character       no-undo. /*local*/
def var v_log_funcao_clien               as logical         no-undo. /*local*/
def var v_log_valid_pessoa               as logical         no-undo. /*local*/
def var v_val_acum_perc                  as decimal         no-undo. /*local*/
def var v_val_maior_perc                 as decimal         no-undo. /*local*/


/************************** Variable Definition End *************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i api_integr_acr_renegoc_3}


def new global shared var v_cod_arq
    as char  
    format 'x(60)'
    no-undo.
def new global shared var v_cod_tip_prog
    as character
    format 'x(8)'
    no-undo.

def stream s-arq.

if  v_cod_arq <> '' and v_cod_arq <> ?
then do:
    run pi_version_extract ('api_integr_acr_renegoc_3':U, 'prgfin/acr/acr902zc.py':U, '1.00.00.104':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

/* --- Definiá‰es de Vari†veis para lista de imp†cto --- */
def var p_num_vers_integr_api     as integer   format '>>>>,>>9' no-undo.
def var p_cod_matriz_trad_org_ext as character format 'x(8)'     no-undo.


/* Begin_Include: i_def_temps_evol */
def temp-table tt_pessoa_fisic_integr_old_1 no-undo
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_fisic           as character format "x(20)" initial ? label "ID Estadual F°sica" column-label "ID Estadual F°sica"
    field tta_cod_orgao_emis_id_estad      as character format "x(10)" label "‡rg∆o Emissor" column-label "‡rg∆o Emissor"
    field tta_cod_unid_federac_emis_estad  as character format "x(3)" label "Estado Emiss∆o" column-label "UF Emis"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal                    as character format "x(7)" label "Ramal" column-label "Ramal"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_dat_nasc_pessoa_fisic        as date format "99/99/9999" initial ? label "Nascimento" column-label "Data Nasc"
    field ttv_cod_pais_ext_nasc            as character format "x(20)" label "Pa°s Ext Nascimento" column-label "Pa°s Ext Nascimento"
    field ttv_cod_pais_nasc                as character format "x(3)" label "Pa°s Nascimento" column-label "Pa°s Nasc"
    field tta_cod_unid_federac_nasc        as character format "x(3)" label "Estado Nascimento" column-label "UF Nasc"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_nom_mae_pessoa               as character format "x(40)" label "M∆e Pessoa" column-label "M∆e Pes"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    index tt_pssfsca_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssfsca_identpes             
          tta_nom_pessoa                   ascending
          tta_cod_id_estad_fisic           ascending
          tta_cod_unid_federac_emis_estad  ascending
          tta_dat_nasc_pessoa_fisic        ascending
          tta_nom_mae_pessoa               ascending
    index tt_pssfsca_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssfsca_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_jurid_integr_old no-undo
    field tta_num_pessoa_jurid             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica" column-label "Pessoa Jur°dica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_jurid           as character format "x(20)" initial ? label "ID Estadual" column-label "ID Estadual"
    field tta_cod_id_munic_jurid           as character format "x(20)" initial ? label "ID Municipal" column-label "ID Municipal"
    field tta_cod_id_previd_social         as character format "x(20)" label "Id Previdància" column-label "Id Previdància"
    field tta_log_fins_lucrat              as logical format "Sim/N∆o" initial yes label "Fins Lucrativos" column-label "Fins Lucrativos"
    field tta_num_pessoa_jurid_matriz      as integer format ">>>,>>>,>>9" initial 0 label "Matriz" column-label "Matriz"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_ind_tip_pessoa_jurid         as character format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_ind_tip_capit_pessoa_jurid   as character format "X(13)" label "Tipo Capital" column-label "Tipo Capital"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field tta_num_pessoa_jurid_cobr        as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jur°dica Cobr" column-label "Pessoa Jur°dica Cobr"
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_cob             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_num_pessoa_jurid_pagto       as integer format ">>>,>>>,>>9" initial 0 label "Pessoa Jurid Pagto" column-label "Pessoa Jurid Pagto"
    field tta_nom_ender_pagto              as character format "x(40)" label "Endereáo Pagamento" column-label "Endereáo Pagamento"
    field tta_nom_ender_compl_pagto        as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_pagto             as character format "x(20)" label "Bairro Pagamento" column-label "Bairro Pagamento"
    field tta_nom_cidad_pagto              as character format "x(32)" label "Cidade Pagamento" column-label "Cidade Pagamento"
    field tta_nom_condad_pagto             as character format "x(32)" label "Condado Pagamento" column-label "Condado Pagamento"
    field tta_cod_unid_federac_pagto       as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field ttv_cod_pais_ext_pag             as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field ttv_cod_pais_pagto               as character format "x(3)" label "Pa°s Pagamento" column-label "Pa°s Pagamento"
    field tta_cod_cep_pagto                as character format "x(20)" label "CEP Pagamento" column-label "CEP Pagamento"
    field tta_cod_cx_post_pagto            as character format "x(20)" label "Caixa Postal Pagamen" column-label "Caixa Postal Pagamen"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    index tt_pssjrda_cobranca             
          tta_num_pessoa_jurid_cobr        ascending
    index tt_pssjrda_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssjrda_id_previd_social     
          tta_cod_pais_ext                 ascending
          tta_cod_id_previd_social         ascending
    index tt_pssjrda_matriz               
          tta_num_pessoa_jurid_matriz      ascending
    index tt_pssjrda_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssjrda_pagto                
          tta_num_pessoa_jurid_pagto       ascending
    index tt_pssjrda_razao_social         
          tta_nom_pessoa                   ascending
    index tt_pssjrda_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_fisic_integr_old_2 no-undo
    field tta_num_pessoa_fisic             as integer format ">>>,>>>,>>9" initial 0 label "Pessoa F°sica" column-label "Pessoa F°sica"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_fisic           as character format "x(20)" initial ? label "ID Estadual F°sica" column-label "ID Estadual F°sica"
    field tta_cod_orgao_emis_id_estad      as character format "x(10)" label "‡rg∆o Emissor" column-label "‡rg∆o Emissor"
    field tta_cod_unid_federac_emis_estad  as character format "x(3)" label "Estado Emiss∆o" column-label "UF Emis"
    field tta_nom_endereco                 as character format "x(40)" label "Endereáo" column-label "Endereáo"
    field tta_nom_ender_compl              as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federaá∆o" column-label "UF"
    field tta_cod_cep                      as character format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal                    as character format "x(7)" label "Ramal" column-label "Ramal"
    field tta_cod_fax                      as character format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_dat_nasc_pessoa_fisic        as date format "99/99/9999" initial ? label "Nascimento" column-label "Data Nasc"
    field ttv_cod_pais_ext_nasc            as character format "x(20)" label "Pa°s Ext Nascimento" column-label "Pa°s Ext Nascimento"
    field ttv_cod_pais_nasc                as character format "x(3)" label "Pa°s Nascimento" column-label "Pa°s Nasc"
    field tta_cod_unid_federac_nasc        as character format "x(3)" label "Estado Nascimento" column-label "UF Nasc"
    field tta_des_anot_tab                 as character format "x(2000)" label "Anotaá∆o Tabela" column-label "Anotaá∆o Tabela"
    field tta_nom_mae_pessoa               as character format "x(40)" label "M∆e Pessoa" column-label "M∆e Pes"
    field tta_cod_imagem                   as character format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9" column-label "Tipo  Operaá∆o"
    field ttv_rec_fiador_renegoc           as recid format ">>>>>>9" initial ?
    field tta_nom_ender_cobr               as character format "x(40)" label "Endereáo Cobranáa" column-label "Endereáo Cobranáa"
    field tta_nom_ender_compl_cobr         as character format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character format "x(20)" label "Bairro Cobranáa" column-label "Bairro Cobranáa"
    field tta_nom_cidad_cobr               as character format "x(32)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    field tta_nom_condad_cobr              as character format "x(32)" label "Condado Cobranáa" column-label "Condado Cobranáa"
    field tta_cod_unid_federac_cobr        as character format "x(3)" label "Unidade Federaá∆o" column-label "Unidade Federaá∆o"
    field tta_cod_cep_cobr                 as character format "x(20)" label "CEP Cobranáa" column-label "CEP Cobranáa"
    field tta_cod_cx_post_cobr             as character format "x(20)" label "Caixa Postal Cobraná" column-label "Caixa Postal Cobraná"
    field tta_cod_pais_cobr                as character format "x(3)" label "Pa°s Cobranáa" column-label "Pa°s Cobranáa"
    field ttv_cod_num_ender                as character format "x(06)"
    field ttv_cod_num_ender_cobr           as character format "x(06)"
    index tt_pssfsca_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssfsca_identpes             
          tta_nom_pessoa                   ascending
          tta_cod_id_estad_fisic           ascending
          tta_cod_unid_federac_emis_estad  ascending
          tta_dat_nasc_pessoa_fisic        ascending
          tta_nom_mae_pessoa               ascending
    index tt_pssfsca_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssfsca_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .
/* End_Include: i_def_temps_evol */



/* Begin_Include: i_definicao_apenas_tt_fornecedor_integr_k */
def temp-table tt_fornecedor_integr_k no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_grp_fornec               as character format "x(4)" label "Grupo Fornecedor" column-label "Grp Fornec"
    field tta_cod_tip_fornec               as character format "x(8)" label "Tipo Fornecedor" column-label "Tipo Fornec"
    field tta_dat_impl_fornec              as date format "99/99/9999" initial today label "Data Implantaá∆o" column-label "Data Implantaá∆o"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa°s Externo" column-label "Pa°s Externo"
    field tta_cod_pais                     as character format "x(3)" label "Pa°s" column-label "Pa°s"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field ttv_ind_pessoa                   as character format "X(08)" initial "Jur°dica" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_log_ems_20_atlzdo            as logical format "Sim/N∆o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer format ">9"
    field ttv_ind_tip_pessoa_ems2          as character format "X(12)"
    field tta_log_cr_pis                   as logical format "Sim/N∆o" initial no label "Credita PIS" column-label "Credita PIS"
    field tta_log_control_inss             as logical format "Sim/N∆o" initial no label "Controla Limite INSS" column-label "Contr Lim INSS"
    field tta_log_cr_cofins                as logical format "Sim/N∆o" initial no label "Credita COFINS" column-label "Credita COFINS"
    field tta_log_retenc_impto_pagto       as logical format "Sim/N∆o" initial no label "RetÇm no Pagto" column-label "RetÇm no Pagto"
    index tt_frncdr_empr_pessoa           
          tta_cod_empresa                  ascending
          tta_num_pessoa                   ascending
    index tt_frncdr_grp_fornec            
          tta_cod_grp_fornec               ascending
    index tt_frncdr_id                     is primary unique
          tta_cod_empresa                  ascending
          tta_cdn_fornecedor               ascending
    index tt_frncdr_nom_abrev              is unique
          tta_cod_empresa                  ascending
          tta_nom_abrev                    ascending
    .    
/* End_Include: i_definicao_apenas_tt_fornecedor_integr_k */


/* Begin_Include: i_verify_program_epc_custom */
define variable v_nom_prog_upc    as character     no-undo init ''.
define variable v_nom_prog_appc   as character     no-undo init ''.
&if '{&emsbas_version}' > '5.00' &then
define variable v_nom_prog_dpc    as character     no-undo init ''.
&endif

define temp-table tt_epc no-undo
    field cod_event        as character
    field cod_parameter    as character
    field val_parameter    as character
    index id is primary cod_parameter cod_event ascending.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "api_integr_acr_renegoc_3":U
    no-lock no-error.
if  avail prog_dtsul then do:
    if  prog_dtsul.nom_prog_upc <> ''
    and prog_dtsul.nom_prog_upc <> ? then
        assign v_nom_prog_upc = prog_dtsul.nom_prog_upc.
    if  prog_dtsul.nom_prog_appc <> ''
    and prog_dtsul.nom_prog_appc <> ? then
        assign v_nom_prog_appc = prog_dtsul.nom_prog_appc.
&if '{&emsbas_version}' > '5.00' &then
    if  prog_dtsul.nom_prog_dpc <> ''
    and prog_dtsul.nom_prog_dpc <> ? then
        assign v_nom_prog_dpc = prog_dtsul.nom_prog_dpc.
&endif
end.

/* End_Include: i_verify_program_epc_custom */


/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'api_integr_acr_renegoc_3' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'api_integr_acr_renegoc_3'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */


/* Begin_Include: i_exec_define_rpc */
FUNCTION rpc_exec         RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_server       RETURNS handle    (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_program      RETURNS character (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_tip_exec     RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_exec_set     RETURNS logical   (input p_cod_program as character, 
                                             input p_log_value as logical)     in v_wgh_servid_rpc.

/* End_Include: i_exec_define_rpc */


run prgint/utb/utb922za.py persistent set v_hdl_funcao_padr /* prg_fnc_funcoes_padrao*/.

function getDefinedFunction return logical   (input spp as character) in v_hdl_funcao_padr.
function getEntryField      return character (input p_num_posicao as integer, input p_cod_campo as character, input p_cod_separador as character) in v_hdl_funcao_padr.
function setEntryField      return character (input p_num_posicao as integer, input p_cod_campo as character, input p_cod_separador as character, input p_cod_valor as character) in v_hdl_funcao_padr.

assign v_log_inform_financ = no
       v_log_func_valid_dat_inic_movto = &IF DEFINED(BF_FIN_VALID_DAT_INIC) &THEN YES &ELSE GetDefinedFunction('SPP_VALID_DAT_INIC_MOVTO':U) &ENDIF
       v_log_bxo_estab                 = &IF DEFINED(BF_FIN_BAIXA_ESTAB_TIT) &THEN YES &ELSE GetDefinedFunction('SPP_BAIXA_ESTAB_TIT':U) &ENDIF
       v_log_funcao_tip_calc_juros     = &IF DEFINED(bf_fin_tip_calc_juros) &THEN YES &ELSE GetDefinedFunction('spp_tip_calc_juros':U) &ENDIF.


/* Begin_Include: i_exec_mbh900za */
/* ** Samuel - FUT35209 
     Manter o c¢digo abaixo no fonte - Alteraá∆o por Demanda - MBH ***/

&if defined(BF_FIN_BCOS_HISTORICOS) &then
assign v_log_utiliza_mbh = no.
if can-find(first param_utiliz_produt
            where param_utiliz_produt.cod_empresa = v_cod_empres_usuar
            and   param_utiliz_produt.cod_modul_dtsul = "MBH" no-lock) then do:
   assign v_log_utiliza_mbh = yes.
end.
&endif
/* End_Include: i_exec_mbh900za */



/* Begin_Include: i_log_exec_prog_dtsul_fim */
if v_rec_log <> ? then do transaction:
    find log_exec_prog_dtsul where recid(log_exec_prog_dtsul) = v_rec_log exclusive-lock no-error.
    if  avail log_exec_prog_dtsul
    then do:
        assign log_exec_prog_dtsul.dat_fim_exec_prog_dtsul = today
               log_exec_prog_dtsul.hra_fim_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    end /* if */.
    release log_exec_prog_dtsul.
end.

/* End_Include: i_log_exec_prog_dtsul_fim */


if  v_cod_arq <> "" and v_cod_arq <> ?
then do:
    assign v_cod_arquivo = session:temp-directory + 'dump_integr_acr_renegoc/'
           v_log_export_table = yes.
    os-delete value(v_cod_arquivo) recursive.
    run adecomm/_oscpath.p(input v_cod_arquivo,
                           output v_num_erro).

    output stream s-arq to value(v_cod_arq) append.

    put stream s-arq unformatted
        '*** Gerado os arquivos abaixo no diretorio: ' + v_cod_arquivo  at 4 skip
        '        -> tt_integr_acr_renegoc.d'          skip
        '        -> tt_integr_acr_item_renegoc.d'     skip
        '        -> tt_integr_acr_item_renegoc_new.d' skip
        '        -> tt_integr_acr_fiador_renegoc.d'   skip
        '        -> tt_log_erros_renegoc.d'           skip.

    output stream s-arq close.
end.

return.


/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_version_extract
** Descricao.............: pi_version_extract
** Criado por............: jaison
** Criado em.............: 31/07/1998 09:33:22
** Alterado por..........: tech14020
** Alterado em...........: 12/06/2006 09:09:21
*****************************************************************************/
PROCEDURE pi_version_extract:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_program
        as character
        format "x(08)"
        no-undo.
    def Input param p_cod_program_ext
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_version
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_program_type
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_event_dic
        as character
        format "x(20)":U
        label "Evento"
        column-label "Evento"
        no-undo.
    def var v_cod_tabela
        as character
        format "x(28)":U
        label "Tabela"
        column-label "Tabela"
        no-undo.


    /************************** Variable Definition End *************************/

    if  can-do(v_cod_tip_prog, p_cod_program_type)
    then do:
        if p_cod_program_type = 'dic' then 
           assign p_cod_program_ext = replace(p_cod_program_ext, 'database/', '').

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            p_cod_program            at 1 
            p_cod_program_ext        at 43 
            p_cod_version            at 69 
            today                    at 84 format "99/99/99"
            string(time, 'HH:MM:SS') at 94 skip.

        if  p_cod_program_type = 'pro' then do:
            &if '{&emsbas_version}' > '1.00' &then
            find prog_dtsul 
                where prog_dtsul.cod_prog_dtsul = p_cod_program 
                no-lock no-error.
            if  avail prog_dtsul
            then do:
                &if '{&emsbas_version}' > '5.00' &then
                    if  prog_dtsul.nom_prog_dpc <> '' then
                        put stream s-arq 'DPC : ' at 5 prog_dtsul.nom_prog_dpc  at 15 skip.
                &endif
                if  prog_dtsul.nom_prog_appc <> '' then
                    put stream s-arq 'APPC: ' at 5 prog_dtsul.nom_prog_appc at 15 skip.
                if  prog_dtsul.nom_prog_upc <> '' then
                    put stream s-arq 'UPC : ' at 5 prog_dtsul.nom_prog_upc  at 15 skip.
            end /* if */.
            &endif
        end.

        if  p_cod_program_type = 'dic' then do:
            &if '{&emsbas_version}' > '1.00' &then
            assign v_cod_event_dic = ENTRY(1,p_cod_program ,'/':U)
                   v_cod_tabela    = ENTRY(2,p_cod_program ,'/':U). /* FO 1100.980 */
            find tab_dic_dtsul 
                where tab_dic_dtsul.cod_tab_dic_dtsul = v_cod_tabela 
                no-lock no-error.
            if  avail tab_dic_dtsul
            then do:
                &if '{&emsbas_version}' > '5.00' &then
                    if  tab_dic_dtsul.nom_prog_dpc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                        put stream s-arq 'DPC-DELETE : ' at 5 tab_dic_dtsul.nom_prog_dpc_gat_delete  at 25 skip.
                &endif
                if  tab_dic_dtsul.nom_prog_appc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                    put stream s-arq 'APPC-DELETE: ' at 5 tab_dic_dtsul.nom_prog_appc_gat_delete at 25 skip.
                if  tab_dic_dtsul.nom_prog_upc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                    put stream s-arq 'UPC-DELETE : ' at 5 tab_dic_dtsul.nom_prog_upc_gat_delete  at 25 skip.
                &if '{&emsbas_version}' > '5.00' &then
                    if  tab_dic_dtsul.nom_prog_dpc_gat_write <> '' and v_cod_event_dic = 'Write':U then
                        put stream s-arq 'DPC-WRITE : ' at 5 tab_dic_dtsul.nom_prog_dpc_gat_write  at 25 skip.
                &endif
                if  tab_dic_dtsul.nom_prog_appc_gat_write <> '' and v_cod_event_dic = 'Write':U then
                    put stream s-arq 'APPC-WRITE: ' at 5 tab_dic_dtsul.nom_prog_appc_gat_write at 25 skip.
                if  tab_dic_dtsul.nom_prog_upc_gat_write <> '' and v_cod_event_dic = 'Write':U  then
                    put stream s-arq 'UPC-WRITE : ' at 5 tab_dic_dtsul.nom_prog_upc_gat_write  at 25 skip.
            end /* if */.
            &endif
        end.

        output stream s-arq close.
    end /* if */.

END PROCEDURE. /* pi_version_extract */
/*****************************************************************************
** Procedure Interna.....: pi_vld_acr_cria_renegoc
** Descricao.............: pi_vld_acr_cria_renegoc
** Criado por............: bre17230
** Criado em.............: 09/07/1998 19:26:41
** Alterado por..........: fut12235_3
** Alterado em...........: 01/07/2010 09:18:35
*****************************************************************************/
PROCEDURE pi_vld_acr_cria_renegoc:

    /************************* Variable Definition Begin ************************/

    def var v_cod_parameters
        as character
        format "x(256)":U
        no-undo.
    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_log_refer_uni
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_num_count
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    if  tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr = ?
    then do:
        run pi_vld_campo_renegoc(input "N£mero da Renegociaá∆o" /*l_numero_da_renegociacao*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_cdn_repres = ?
    then do:
        run pi_vld_campo_renegoc(input "C¢digo do Representante" /*l_codigo_do_representante*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_qtd_parc_renegoc = ?
    then do:
        run pi_vld_campo_renegoc(input "Quantidade Parc. Renegociaá∆o" /*l_quant_parc_renegoc*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc = ?
    then do:
        run pi_vld_campo_renegoc(input "Primeiro Vencto Renegociaá∆o" /*l_primeiro_vencto_renegoc*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_log_juros_param_estab_reaj = ?
    then do:
        run pi_vld_campo_renegoc(input "Considera Juros Padr∆o" /*l_considera_juros_padrao*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_val_perc_reaj_renegoc = ?
    then do:
        run pi_vld_campo_renegoc(input "Perc Reajuste Renegociaá∆o" /*l_perc_reajuste_renegoc*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_val_acresc_parc = ?
    then do:
        run pi_vld_campo_renegoc(input "Valor Acresc Parcela" /*l_valor_acresc_parcela*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_cod_ser_docto = ?
    then do:
        run pi_vld_campo_renegoc(input "SÇrie do Documento" /*l_serie_documento*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_cod_tit_acr = ?
    then do:
        run pi_vld_campo_renegoc(input "C¢digo do T°tulo" /*l_codigo_titulo*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  tt_integr_acr_renegoc.tta_cod_cond_cobr = ?
    then do:
        run pi_vld_campo_renegoc(input "C¢digo Condiá∆o de Cobranáa" /*l_codigo_cond_br*/ ).
        return "NOK" /*l_nok*/ .
    end /* if */.

    for each  tt_integr_acr_item_renegoc_new
        where tt_integr_acr_item_renegoc_new.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:

       if  tt_integr_acr_item_renegoc_new.tta_dat_vencto_tit_acr = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Data Vencimento do T°tulo" /*l_dat_vencto_tit*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_dat_prev_liquidac = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Data Previs∆o de Liquidaá∆o" /*l_dat_prev_liquidac*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_dat_emis_docto = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Data de Emiss∆o do Documento" /*l_data_emissao_documento*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_val_tit_acr = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Valor do t°tulo" /*l_val_titulo*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_log_retenc_impto_impl = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Retená∆o Imposto Implantaá∆o" /*l_retenc_imposto_impl*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_log_val_fix_parc = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Fixa Valor Parcela" /*l_fixa_vl_parc*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

       if  tt_integr_acr_item_renegoc_new.tta_cod_parcela = ?
       then do:
           run pi_vld_campo_item_renegoc(input "Data Vencimento do T°tulo" /*l_dat_vencto_tit*/ ).
           return "NOK" /*l_nok*/ .
       end /* if */.

    end.

    find first estabelecimento no-lock
         where estabelecimento.cod_estab = tt_integr_acr_renegoc.tta_cod_estab no-error.
    if  not avail estabelecimento then do:
        assign v_cod_parameters = "Estabelecimento" /*l_estabelecimento*/  + ",,,,,,,,".
        run pi_integr_acr_renegoc_erros(1284,
                                        tt_integr_acr_renegoc.tta_cod_estab,
                                        tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        "","","","","","","","",
                                        v_cod_parameters).
        return "NOK" /*l_nok*/ .
    end.
    /* --- Valida Estabelecimento ---*/
    run pi_validar_estab (Input v_cod_empres_usuar,
                          Input tt_integr_acr_renegoc.tta_cod_estab,
                          Input tt_integr_acr_renegoc.tta_dat_transacao,
                          output v_cod_return) /*pi_validar_estab*/.
    case v_cod_return:
        when "Unidade Organizacional" /*l_unid_organ*/  then do:        
            run pi_integr_acr_renegoc_erros(347,
                                            tt_integr_acr_renegoc.tta_cod_estab,
                                            tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        end.
        when "Empresa" /*l_empresa*/  then do:
            run pi_integr_acr_renegoc_erros(512,
                                            tt_integr_acr_renegoc.tta_cod_estab,
                                            tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        end.
        when "Usu†rio" /*l_usuario*/  then do:
            assign v_cod_parameters =  tt_integr_acr_renegoc.tta_cod_estab + ",,,,,,,,".
            run pi_integr_acr_renegoc_erros(348, 
                                            tt_integr_acr_renegoc.tta_cod_estab,
                                            tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            "","","","","","","","",
                                            v_cod_parameters).
            return "NOK" /*l_nok*/ .
        end.
    end.

    if  tt_integr_acr_renegoc.tta_cod_refer = "" or  tt_integr_acr_renegoc.tta_cod_refer = ?
    then do:
        run pi_integr_acr_renegoc_erros(288,
                                        tt_integr_acr_renegoc.tta_cod_estab,
                                        tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        "","","","","","","","","").
        return "NOK" /*l_nok*/ .
    end.

    find renegoc_acr no-lock
         where renegoc_acr.cod_estab             = tt_integr_acr_renegoc.tta_cod_estab
         and   renegoc_acr.num_renegoc_cobr_acr  = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr 
         no-error.
    if avail renegoc_acr then do:
       /* ** para considerar corretamente os parametros,
            deve ser separados por virgulas (9 paramentros). ***/
       assign v_cod_parameters = "Renegociaá∆o" /*l_renegociacao*/  + ",,,,,,,,".
       run pi_integr_acr_renegoc_erros(1,
                                       tt_integr_acr_renegoc.tta_cod_estab,
                                       tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                       "","","","","","","","",
                                       v_cod_parameters).
       return "NOK" /*l_nok*/ .
    end.
    else do:

        &if defined (BF_FIN_BCOS_HISTORICOS) &then
            if  v_log_utiliza_mbh
            and can-find (his_renegoc_acr
                          where his_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
                          and   his_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr)
            then do:

                assign v_cod_parameters = "Renegociaá∆o" /*l_renegociacao*/  + ",,,,,,,,".
                run pi_integr_acr_renegoc_erros (Input 14154,
                                                 Input tt_integr_acr_renegoc.tta_cod_estab,
                                                 Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input v_cod_parameters) /*pi_integr_acr_renegoc_erros*/.
                return "NOK" /*l_nok*/ .
            end.
        &endif    

        run pi_valida_infor_renegoc_acr /*pi_valida_infor_renegoc_acr*/.
        if return-value = "NOK" /*l_nok*/  then
           return "NOK" /*l_nok*/ .

        create renegoc_acr.    
        assign renegoc_acr.cod_empresa                   = v_cod_empres_usuar
               renegoc_acr.cod_estab                     = tt_integr_acr_renegoc.tta_cod_estab
               renegoc_acr.num_renegoc_cobr_acr          = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
               renegoc_acr.cod_refer                     = tt_integr_acr_renegoc.tta_cod_refer.

        /* --- Verifica Referància Ènica ---*/
        run pi_verifica_refer_unica_acr (Input renegoc_acr.cod_estab,
                                         Input renegoc_acr.cod_refer,
                                         Input "renegoc_acr" /*l_renegoc_acr*/,
                                         Input recid(renegoc_acr),
                                         output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.
        if  v_log_refer_uni = no
        then do:
            run pi_integr_acr_renegoc_erros(3019,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            delete renegoc_acr.
            return "NOK" /*l_nok*/ .
        end.

        if  avail renegoc_acr
        then do:
            assign renegoc_acr.cdn_cliente                   = tt_integr_acr_renegoc.tta_cdn_cliente
                   renegoc_acr.dat_transacao                 = tt_integr_acr_renegoc.tta_dat_transacao               
                   renegoc_acr.val_renegoc_cobr_acr          = 0 /* Este valor est† sendo recalculado tt_integr_acr_renegoc.tta_val_renegoc_cobr_acr */
                   renegoc_acr.ind_tip_renegoc_acr           = "Substituiá∆o" /*l_substituicao*/ 
                   renegoc_acr.log_consid_juros_renegoc      = no
                   renegoc_acr.log_consid_multa_renegoc      = no

                   renegoc_acr.ind_sit_renegoc_acr           = "Pendente" /*l_pendent*/ 
                   renegoc_acr.cod_espec_docto               = tt_integr_acr_renegoc.tta_cod_espec_docto
                   renegoc_acr.cod_ser_docto                 = tt_integr_acr_renegoc.tta_cod_ser_docto
                   renegoc_acr.cod_tit_acr                   = tt_integr_acr_renegoc.tta_cod_tit_acr

                   renegoc_acr.cod_portador                  = tt_integr_acr_renegoc.tta_cod_portador
                   renegoc_acr.cod_cart_bcia                 = tt_integr_acr_renegoc.tta_cod_cart_bcia
                   renegoc_acr.cod_indic_econ                = tt_integr_acr_renegoc.tta_cod_indic_econ
                   renegoc_acr.cdn_repres                    = tt_integr_acr_renegoc.tta_cdn_repres

                   renegoc_acr.val_tit_acr                   = 0 /* Este valor est† sendo incrementado na pi que cria item_renegoc_acr tt_integr_acr_renegoc.tta_val_tit_acr */
                   renegoc_acr.qtd_parc_renegoc              = tt_integr_acr_renegoc.tta_qtd_parc_renegoc
                   renegoc_acr.ind_vencto_renegoc            = tt_integr_acr_renegoc.tta_ind_vencto_renegoc
                   renegoc_acr.num_dia_mes_base_vencto       = tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto
                   renegoc_acr.num_dias_vencto_renegoc       = tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc               
                   renegoc_acr.dat_primei_vencto_renegoc     = tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc
                   renegoc_acr.ind_calc_juros_desc           = ""
                   renegoc_acr.log_juros_param_estab_reaj    = tt_integr_acr_renegoc.tta_log_juros_param_estab_reaj
                   renegoc_acr.cod_cond_cobr                 = tt_integr_acr_renegoc.tta_cod_cond_cobr 
                   renegoc_acr.ind_tip_calc_juros            = tt_integr_acr_renegoc.tta_ind_tip_calc_juros
                   v_rec_renegoc_acr                         = recid(renegoc_acr).

            if  renegoc_acr.log_juros_param_estab_reaj = yes
            then do:
                run pi_retorna_parametro_acr (Input renegoc_acr.cod_estab,
                                              Input renegoc_acr.dat_transacao) /*pi_retorna_parametro_acr*/.
                assign renegoc_acr.val_perc_reaj_renegoc       = if avail param_estab_acr then param_estab_acr.val_perc_juros_acr else 0
                       renegoc_acr.cod_indic_econ_reaj_renegoc = "" /*l_*/ .
            end /* if */.
            else do:
                assign renegoc_acr.cod_indic_econ_reaj_renegoc = tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc.

                if  tt_integr_acr_renegoc.tta_cod_cond_cobr <> "" /*l_*/ 
                then do:
                    find first cond_cobr_acr no-lock
                         where cond_cobr_acr.cod_estab     = renegoc_acr.cod_estab 
                           and cond_cobr_acr.cod_cond_cobr = renegoc_acr.cod_cond_cobr no-error.
                    assign renegoc_acr.val_perc_reaj_renegoc = if avail cond_cobr_acr then cond_cobr_acr.val_perc_juros_acr else 0.
                end /* if */.
                else
                    assign renegoc_acr.val_perc_reaj_renegoc = tt_integr_acr_renegoc.tta_val_perc_reaj_renegoc.
            end /* else */.

            &if '{&emsuni_version}' > '5.01' &then           
                assign renegoc_acr.log_soma_movto_cobr     = tt_integr_acr_renegoc.tta_log_soma_movto_cobr           
                       renegoc_acr.num_dias_vencto_renegoc = tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc           
                       renegoc_acr.val_acresc_parc         = tt_integr_acr_renegoc.tta_val_acresc_parc.
            &else
                assign renegoc_acr.log_livre_1 = tt_integr_acr_renegoc.tta_log_soma_movto_cobr           
                       renegoc_acr.num_livre_1 = tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc
                       renegoc_acr.val_livre_1 = tt_integr_acr_renegoc.tta_val_acresc_parc.
            &endif 

            assign v_log_bxo_estab = yes.
            if v_log_bxo_estab then do:
                &if '{&emsfin_version}' >= '5.06' &then
                    ASSIGN renegoc_acr.log_bxa_estab_tit_acr = yes.
                &else 
                    &if '{&emsfin_version}' >= '5.04' &then
                    ASSIGN renegoc_acr.log_livre_2 = yes.
                    &endif
                &endif
            end.


        end /* if */.
    end. 

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_vld_acr_cria_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_vld_renegoc_acr_substituicao
** Descricao.............: pi_vld_renegoc_acr_substituicao
** Criado por............: Rafael
** Criado em.............: 06/05/1998 09:56:11
** Alterado por..........: fut12235_3
** Alterado em...........: 06/07/2010 11:53:34
*****************************************************************************/
PROCEDURE pi_vld_renegoc_acr_substituicao:

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_log_aces_permit
        as logical
        format "Sim/N∆o"
        initial yes
        label "Acesso Permitido"
        no-undo.
    def var v_log_return
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.


    /************************** Variable Definition End *************************/

    /* ** Neste ponto ser† tratado apenas o programa on-line (prgfin/acr/acr748ca) ***/
    /* ** Para a API precisa ser validado antes desta procedure                    ***/
    find first estabelecimento
         where estabelecimento.cod_estab = renegoc_acr.cod_estab no-lock no-error.
    if  not avail estabelecimento
    then do:
        &if '{&frame_aux}' <> "" &then
            /* &1 inexistente ! */
            run pi_messages (input "show",
                             input 1284,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "Estabelecimento" /*l_estabelecimento*/ , "Estabelecimentos" /*l_estabelecimentos*/)) /*msg_1284*/.
            return error.
        &endif
    end /* if */.

    run pi_retorna_parametro_acr (Input renegoc_acr.cod_estab,
                                  Input renegoc_acr.dat_transacao) /*pi_retorna_parametro_acr*/.
    if  return-value = "NOK" /*l_nok*/ 
    then do:
        &if '{&frame_aux}' <> "" &then
            /* ParÉmetros Estabelecimento ACR n∆o cadastrados ! */
            run pi_messages (input "show",
                             input 744,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                renegoc_acr.cod_estab,renegoc_acr.dat_transacao)) /*msg_744*/.
            return error.
        &else
            run pi_integr_acr_renegoc_erros(744,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        &endif
    end.
    /* Validaá∆o da data inicial de movimentos no ACR*/
    if v_log_func_valid_dat_inic_movto then do:
        if avail param_estab_acr then do:
            if renegoc_acr.dat_transacao < param_estab_acr.dat_inic_movimen then do:
                &if '{&frame_aux}' <> "" &then
                    /* Data &1 n∆o pode ser menor que a data in°cio &2 ! */
                    run pi_messages (input "show",
                                     input 18389,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        renegoc_acr.dat_transacao,                     param_estab_acr.dat_inic_movimen)) /*msg_18389*/.
                    return error.
                &else
                    assign v_cod_parameters =  string(renegoc_acr.dat_transacao) + "," + string(param_estab_acr.dat_inic_movimen) + ",,,,,,,".
                    run pi_integr_acr_renegoc_erros(18389, renegoc_acr.cod_estab, renegoc_acr.num_renegoc_cobr_acr, "","","","","","","","", v_cod_parameters).
                    return "NOK" /*l_nok*/ .
                &endif
            end.    
        end.
    end.
    /* Valida ParÉmetros do Empresa ACR */
    find last param_empres_acr no-lock
         where param_empres_acr.cod_empresa = v_cod_empres_usuar
         no-error.
    if  not avail param_empres_acr
    then do:
        &if '{&frame_aux}' <> "" &then
            /* ParÉmetros da Empresa ACR n∆o Cadastrado ! */
            run pi_messages (input "show",
                             input 3721,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_cod_empres_usuar)) /*msg_3721*/.
            return error.
        &else
            run pi_integr_acr_renegoc_erros(3721,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        &endif
    end.
    /* --- Valida utilizaá∆o do M¢dulo ---*/
    run pi_verifica_utiliz_modulo (Input v_cod_empres_usuar,
                                   Input "ACR" /*l_acr*/,
                                   output v_log_return) /*pi_verifica_utiliz_modulo*/.
    if  v_log_return = no
    then do:
        &if '{&frame_aux}' <> "" &then
            /* Empresa: &1 n∆o possui m¢dulo: &2 ! */
            run pi_messages (input "show",
                             input 491,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_cod_empres_usuar, "ACR" /*l_acr*/)) /*msg_491*/.
            return error.
        &else
            assign v_cod_parameters =  v_cod_empres_usuar + "," + "ACR" /*l_acr*/  + ",,,,,,,".
            run pi_integr_acr_renegoc_erros(491,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","",
                                            v_cod_parameters).
            return "NOK" /*l_nok*/ .
        &endif
    end.
    else do:
        run pi_verificar_segur_modul_dtsul (Input "ACR" /*l_acr*/,
                                            Input v_cod_usuar_corren,
                                            output v_log_aces_permit) /*pi_verificar_segur_modul_dtsul*/.
        if  v_log_aces_permit = no then do:
            &if '{&frame_aux}' <> "" &then
                /* Usu†rio sem permiss∆o para acessar o m¢dulo ! */
                run pi_messages (input "show",
                                 input 495,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_495*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(495,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "","","","","","","","","").
                return "NOK" /*l_nok*/ .
            &endif    
        end.
    end.

    /* ** Neste ponto ser† tratado apenas o programa on-line (prgfin/acr/acr748ca) ***/
    /* ** Para a API precisa ser validado antes desta procedure                    ***/
    /* --- Valida Estabelecimento ---*/
    run pi_validar_estab (Input v_cod_empres_usuar,
                          Input renegoc_acr.cod_estab,
                          Input renegoc_acr.dat_transacao,
                          output v_cod_return) /* pi_validar_estab*/.
    case v_cod_return:
        when "Unidade Organizacional" /*l_unid_organ*/  then do:
            &if '{&frame_aux}' <> "" &then
                /* Estabelecimento n∆o habilitado como Unidade Organizacional ! */
                run pi_messages (input "show",
                                 input 347,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_347*/.
                return error.            
            &endif    
        end.
        when "Empresa" /*l_empresa*/  then do:
            &if '{&frame_aux}' <> "" &then
                /* Empresa do Estabelecimento Diferente da Empresa do Usu†rio ! */
                run pi_messages (input "show",
                                 input 512,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_512*/.
                return error.
            &endif    
        end.
        when "Usu†rio" /*l_usuario*/  then do:
            &if '{&frame_aux}' <> "" &then
                /* Usu†rio sem permiss∆o para acessar o estabelecimento &1 ! */
                run pi_messages (input "show",
                                 input 348,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_348*/.
                return error.
            &endif    
        end.
    end.

    /* --- Verifica se o Usu†rio corrente est† apto a alterar Vencimento ---*/
    run pi_validar_usuar_estab_acr (Input renegoc_acr.cod_estab,
                                    Input "Data Vencto" /*l_data_vencto*/,
                                    output v_cod_return) /*pi_validar_usuar_estab_acr*/.

    if v_cod_return = "no" /*l_no*/  
    or v_cod_return = '3018' then
        assign v_des_permissao = "Alterar Vencimento" /*l_alterar_vencimento*/ .




    case v_cod_return:
        when "no" /*l_no*/  then do:
            &if '{&frame_aux}' <> "" &then
                /* Usu†rio &1 n∆o possui permiss∆o para &2 ! */
                run pi_messages (input "show",
                                 input 701,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                   v_cod_usuar_corren, v_des_permissao)) /*msg_701*/.
                return error.
            &else
                assign v_cod_parameters =  v_cod_usuar_corren + "," + v_des_permissao + ",,,,,,,".
                run pi_integr_acr_renegoc_erros(701,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "","","","","","","","",
                                                v_cod_parameters).
                return "NOK" /*l_nok*/ .
            &endif
        end.
        when "3018" then do:
            &if '{&frame_aux}' <> "" &then
                /* Usu†rio Financeiro Inexistente ! */
                run pi_messages (input "show",
                                 input 3018,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_3018*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(3018,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "","","","","","","","","").
                return "NOK" /*l_nok*/ .
            &endif
        end.
    end.

    if  renegoc_acr.num_renegoc_cobr_acr = 0
    then do:
        &if '{&frame_aux}' <> "" &then
            /* N£mero da Renegociaá∆o deve ser maior que zero ! */
            run pi_messages (input "show",
                             input 5166,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_5166*/.
            assign v_wgh_focus = renegoc_acr.num_renegoc_cobr_acr:handle in frame .
            return error.
        &else
            run pi_integr_acr_renegoc_erros(5166,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        &endif
    end.

    /* ** Neste ponto ser† tratado apenas o programa on-line (prgfin/acr/acr748ca) ***/
    /* ** Para a API precisa ser validado antes desta procedure                    ***/
    if  renegoc_acr.cod_refer = "" 
    or  renegoc_acr.cod_refer = ?
    then do:
        &if '{&frame_aux}' <> "" &then
            /* Referància N∆o Informada ! */
            run pi_messages (input "show",
                             input 288,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "Renegociaá∆o" /*l_renegociacao*/)) /*msg_288*/.
            return error.
        &endif
    end /* if */.

    /* --- Verifica Referància Ènica ---*/
    run pi_verifica_refer_unica_acr (Input renegoc_acr.cod_estab,
                                     Input renegoc_acr.cod_refer,
                                     Input "renegoc_acr" /*l_renegoc_acr*/,
                                     Input recid(renegoc_acr),
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.
    if  v_log_refer_uni = no
    then do:
        &if '{&frame_aux}' <> "" &then
            /* Referància deve ser £nica ! */
            run pi_messages (input "show",
                             input 3019,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_3019*/.
            run pi_retorna_sugestao_referencia (Input "R" /*l_rural_mrh*/,
                                                Input today,
                                                output v_cod_refer) /*pi_retorna_sugestao_referencia*/.
            assign renegoc_acr.cod_refer:screen-value in frame f_adp_01_renegoc_acr_substituicao = v_cod_refer.    
            return error.        
        &endif
    end /* if */.

    &if defined (BF_FIN_BCOS_HISTORICOS) &then
        if  v_log_utiliza_mbh
        and can-find (his_renegoc_acr
                      where his_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
                      and   his_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr)
        then do:

          &if '{&frame_aux}' <> "" &then
            /* Renegociaá∆o j† existe nos Hist¢ricos ! */
            run pi_messages (input "show",
                             input 14154,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_14154*/.
            return error.
          &else
            run pi_integr_acr_renegoc_erros (Input 14154,
                                             Input renegoc_acr.cod_estab,
                                             Input renegoc_acr.num_renegoc_cobr_acr,
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "",
                                             Input "") /*pi_integr_acr_renegoc_erros*/.
            return "NOK" /*l_nok*/ .
          &endif
        end.
    &endif

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_vld_renegoc_acr_substituicao */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_utiliz_modulo
** Descricao.............: pi_verifica_utiliz_modulo
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: Menna
** Alterado em...........: 06/05/1999 10:32:29
*****************************************************************************/
PROCEDURE pi_verifica_utiliz_modulo:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.
    def output param p_log_param_utiliz_produt_val
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    if  p_cod_empresa = "" then
        assign p_log_param_utiliz_produt_val = can-find(first param_utiliz_produt
                                                       where param_utiliz_produt.cod_modul_dtsul = p_cod_modul_dtsul /*cl_verifica_modulo of param_utiliz_produt*/).
    else do:
       if  p_cod_empresa = v_cod_empres_usuar then
           assign p_log_param_utiliz_produt_val = can-do(v_cod_modul_dtsul_empres,p_cod_modul_dtsul).
       else
           assign p_log_param_utiliz_produt_val = can-find(first param_utiliz_produt
                                                          where param_utiliz_produt.cod_empresa = p_cod_empresa
                                                            and param_utiliz_produt.cod_modul_dtsul = p_cod_modul_dtsul
    &if "{&emsuni_version}" >= "5.01" &then
                                                          use-index prmtlzcm_modulo
    &endif
                                                           /*cl_verifica_utiliz_modul of param_utiliz_produt*/).
    end.

END PROCEDURE. /* pi_verifica_utiliz_modulo */
/*****************************************************************************
** Procedure Interna.....: pi_validar_estab
** Descricao.............: pi_validar_estab
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: src12337
** Alterado em...........: 23/03/2001 08:01:00
*****************************************************************************/
PROCEDURE pi_validar_estab:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find unid_organ no-lock
         where unid_organ.cod_unid_organ = p_cod_estab /*cl_estab of unid_organ*/ no-error.
    if  avail unid_organ
    then do:
        if  p_dat_transacao <> ? and
           (p_dat_transacao < unid_organ.dat_inic_valid or
            p_dat_transacao > unid_organ.dat_fim_valid)
        then do:
            assign p_cod_return = "Unidade Organizacional" /*l_unid_organ*/ .
            return.
        end /* if */.
    end /* if */.
    else do:
        assign p_cod_return = "Unidade Organizacional" /*l_unid_organ*/ .
        return.
    end /* else */.
    if  p_cod_empresa <> ?
    then do:
        find estabelecimento no-lock
             where estabelecimento.cod_estab = p_cod_estab /*cl_param_estab of estabelecimento*/ no-error.
        if  avail estabelecimento and
            estabelecimento.cod_empresa <> p_cod_empresa
        then do:
            assign p_cod_return = "Empresa" /*l_empresa*/ .
            return.
        end /* if */.
    end /* if */.
    if  can-find(segur_unid_organ
            where segur_unid_organ.cod_unid_organ = p_cod_estab
              and segur_unid_organ.cod_grp_usuar = '*' /*cl_valid_estab_todos_usuarios of segur_unid_organ*/)
            then do:
        /* todos os usu†rio podem acessar */
       assign p_cod_return = "".
       return.
    end /* if */.
    contr_block:
    for
       each usuar_grp_usuar no-lock
       where usuar_grp_usuar.cod_usuario = v_cod_usuar_corren
    &if "{&emsbas_version}" >= "5.01" &then
       use-index srgrpsr_usuario
    &endif
        /*cl_grupos_do_usuario of usuar_grp_usuar*/:
       find first segur_unid_organ no-lock
            where segur_unid_organ.cod_unid_organ = p_cod_estab
              and segur_unid_organ.cod_grp_usuar = usuar_grp_usuar.cod_grp_usuar /*cl_valida_estab of segur_unid_organ*/ no-error.
       if  avail segur_unid_organ
       then do:
          assign p_cod_return = "".
          return.
       end /* if */.
    end /* for contr_block */.
    assign p_cod_return = "Usu†rio" /*l_usuario*/ .

END PROCEDURE. /* pi_validar_estab */
/*****************************************************************************
** Procedure Interna.....: pi_validar_usuar_estab_acr
** Descricao.............: pi_validar_usuar_estab_acr
** Criado por............: Claudia
** Criado em.............: 13/08/1996 11:01:11
** Alterado por..........: Claudia
** Alterado em...........: 03/07/1997 13:56:20
*****************************************************************************/
PROCEDURE pi_validar_usuar_estab_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_ind_tip_usuar
        as character
        format "X(08)"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_seq
        as integer
        format ">>>,>>9":U
        label "SeqÅància"
        column-label "Seq"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_cod_return = "".
    find usuar_financ_estab_acr no-lock
         where usuar_financ_estab_acr.cod_usuario = v_cod_usuar_corren
           and usuar_financ_estab_acr.cod_estab = p_cod_estab /*cl_validar_usuar_financ_estab_acr of usuar_financ_estab_acr*/ no-error.

    if  avail usuar_financ_estab_acr
    then do:
        teste_usuar:
        do v_num_seq = 1 to num-entries(p_ind_tip_usuar):
            if  v_num_seq <> 1
            then do:
                assign p_cod_return = p_cod_return + ",".
            end /* if */.

            /* case_block: */
            case entry(v_num_seq, p_ind_tip_usuar):
                when "Implantaá∆o" /*l_implantacao*/ then
                    if  usuar_financ_estab_acr.log_habilit_impl_tit_acr = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Liquidaá∆o" /*l_liquidacao*/ then
                    if  usuar_financ_estab_acr.log_habilit_liquidac_acr = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Gera Aviso DÇbito" /*l_gera_avdeb*/ then
                    if  usuar_financ_estab_acr.log_habilit_gera_avdeb = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Juros" /*l_juros*/ then
                    if  usuar_financ_estab_acr.log_habilit_alter_juros = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Data Vencto" /*l_data_vencto*/ then
                    if  usuar_financ_estab_acr.log_habilit_alter_vencto = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Saldo" /*l_saldo*/ then
                    if  usuar_financ_estab_acr.log_habilit_alter_sdo = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Cancelamento" /*l_cancelamento*/ then
                    if  usuar_financ_estab_acr.log_habilit_cancel_tit_acr = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Estorno" /*l_estorno*/ then
                    if  usuar_financ_estab_acr.log_habilit_estorn_tit_acr = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Destinaá∆o" /*l_destinacao*/ then
                    if  usuar_financ_estab_acr.log_habilit_manut_destinac = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Gera Baixa Bco" /*l_gera_baixa_bco*/ then
                    if  usuar_financ_estab_acr.log_habilit_gerac_ocor_bcia = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
            end /* case case_block */.
        end /* do teste_usuar */.
    end /* if */.
    else do:
        assign p_cod_return = "3018".
    end /* else */.

END PROCEDURE. /* pi_validar_usuar_estab_acr */
/*****************************************************************************
** Procedure Interna.....: pi_verificar_segur_modul_dtsul
** Descricao.............: pi_verificar_segur_modul_dtsul
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut12235_2
** Alterado em...........: 01/07/2009 14:13:06
*****************************************************************************/
PROCEDURE pi_verificar_segur_modul_dtsul:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_usuario
        as character
        format "x(12)"
        no-undo.
    def output param p_log_aces_permit
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    &if '{&emsbas_version}' < '5.07' &then
    find first modul_dtsul_segur no-lock
         where modul_dtsul_segur.cod_modul_dtsul = p_cod_modul_dtsul
           and modul_dtsul_segur.cod_grp_usuar   = "*" no-error.
    if avail modul_dtsul_segur then do:
        assign p_log_aces_permit = yes.
        return.
    end.

    usuar_grp_usuar_block:
    for each usuar_grp_usuar no-lock
     where usuar_grp_usuar.cod_usuario = p_cod_usuario /*cl_p_cod_usuario of usuar_grp_usuar*/:
        find modul_dtsul_segur no-lock
             where modul_dtsul_segur.cod_modul_dtsul = p_cod_modul_dtsul
               and modul_dtsul_segur.cod_grp_usuar = usuar_grp_usuar.cod_grp_usuar /*cl_verifica_segur_modul_dtsul of modul_dtsul_segur*/ no-error.
        if  avail modul_dtsul_segur
        then do:
            leave usuar_grp_usuar_block.
        end /* if */.
    end /* for usuar_grp_usuar_block */.
    assign p_log_aces_permit = avail usuar_grp_usuar.
    &else
    assign p_log_aces_permit = yes.
    &endif.
END PROCEDURE. /* pi_verificar_segur_modul_dtsul */
/*****************************************************************************
** Procedure Interna.....: pi_integr_acr_renegoc_erros
** Descricao.............: pi_integr_acr_renegoc_erros
** Criado por............: bre17230
** Criado em.............: 10/07/1998 08:02:03
** Alterado por..........: fut12201
** Alterado em...........: 26/08/2009 14:43:46
*****************************************************************************/
PROCEDURE pi_integr_acr_renegoc_erros:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_mensagem
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_num_renegoc_cobr_acr
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_num_seq_item_renegoc_acr
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_cdn_cliente
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_tit_acr
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
        no-undo.
    def Input param p_cod_fiador
        as character
        format "x(8)"
        no-undo.
    def Input param p_num_pessoa
        as integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_parameters
        as character
        format "x(256)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_mensagem
        as character
        format "x(50)":U
        view-as editor max-chars 2000 scrollbar-vertical
        size 50 by 4
        bgcolor 15 font 2
        label "Mensagem"
        column-label "Mensagem"
        no-undo.
    def var v_num_mensagem
        as integer
        format ">>>>,>>9":U
        label "N£mero"
        column-label "N£mero Mensagem"
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_num_mensagem            = p_num_mensagem
           v_log_error_renegoc_acr   = yes. 
    run pi_messages (input "msg",
                     input v_num_mensagem,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
    assign v_des_mensagem = return-value /*msg_v_num_mensagem*/.

    /* ** A condiá∆o abaixo Ç necess†ria, pois quando o parametro (p_cod_parameters) est† sem as virgulas
         apresenta erros  ***/
    if  p_cod_parameters = ""
    then do:
        assign p_cod_parameters = ",,,,,,,,".
    end /* if */.

    create tt_log_erros_renegoc.
    assign tt_log_erros_renegoc.tta_cod_estab                = p_cod_estab
           tt_log_erros_renegoc.tta_num_renegoc_cobr_acr     = p_num_renegoc_cobr_acr
           tt_log_erros_renegoc.tta_num_seq_item_renegoc_acr = p_num_seq_item_renegoc_acr
           tt_log_erros_renegoc.tta_cdn_cliente              = p_cdn_cliente
           tt_log_erros_renegoc.tta_cod_espec_docto          = p_cod_espec_docto
           tt_log_erros_renegoc.tta_cod_ser_docto            = p_cod_ser_docto
           tt_log_erros_renegoc.tta_cod_tit_acr              = p_cod_tit_acr
           tt_log_erros_renegoc.tta_cod_parcela              = P_cod_parcela
           tt_log_erros_renegoc.tta_cod_fiador               = p_cod_fiador
           tt_log_erros_renegoc.tta_num_pessoa               = p_num_pessoa
           tt_log_erros_renegoc.tta_num_mensagem             = p_num_mensagem 
           tt_log_erros_renegoc.ttv_des_msg                  = substitute( v_des_mensagem, 
                                                                               entry( 1, p_cod_parameters ), 
                                                                               entry( 2, p_cod_parameters ), 
                                                                               entry( 3, p_cod_parameters ), 
                                                                               entry( 4, p_cod_parameters ), 
                                                                               entry( 5, p_cod_parameters ), 
                                                                               entry( 6, p_cod_parameters ), 
                                                                               entry( 7, p_cod_parameters ), 
                                                                               entry( 8, p_cod_parameters ), 
                                                                               entry( 9, p_cod_parameters )).


        run pi_messages (input "help",
                         input v_num_mensagem,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign v_des_mensagem = return-value /*msg_v_num_mensagem*/.
        assign tt_log_erros_renegoc.ttv_des_help = substitute(v_des_mensagem, entry(1, p_cod_parameters), entry(2, p_cod_parameters), entry(3, p_cod_parameters), entry(4, p_cod_parameters), entry(5, p_cod_parameters), entry(6, p_cod_parameters), entry(7, p_cod_parameters), entry(8, p_cod_parameters), entry(9, p_cod_parameters)).


END PROCEDURE. /* pi_integr_acr_renegoc_erros */
/*****************************************************************************
** Procedure Interna.....: pi_vld_acr_cria_item_renegoc
** Descricao.............: pi_vld_acr_cria_item_renegoc
** Criado por............: bre17230
** Criado em.............: 14/07/1998 10:50:43
** Alterado por..........: fut31947
** Alterado em...........: 28/09/2009 16:06:29
*****************************************************************************/
PROCEDURE pi_vld_acr_cria_item_renegoc:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_renegoc_acr_integr
        for item_renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_seq
        as integer
        format ">>>,>>9":U
        label "SeqÅància"
        column-label "Seq"
        no-undo.


    /************************** Variable Definition End *************************/

    /* ** O find para este (if avail) est† sendo executado no programa que chama a pi. ***/
    if (avail tit_acr) then do:
        find last b_item_renegoc_acr_integr no-lock
            where b_item_renegoc_acr_integr.cod_estab            = renegoc_acr.cod_estab
            and   b_item_renegoc_acr_integr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
            no-error.
        if  avail b_item_renegoc_acr_integr then
            assign v_num_seq = b_item_renegoc_acr_integr.num_seq_item_renegoc_acr + 10.
        else
            assign v_num_seq = 10.


        create item_renegoc_acr.
        assign item_renegoc_acr.cod_estab                 = renegoc_acr.cod_estab
               item_renegoc_acr.cod_estab_tit_acr         = tit_acr.cod_estab        
               item_renegoc_acr.num_renegoc_cobr_acr      = tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr
               item_renegoc_acr.num_seq_item_renegoc_acr  = v_num_seq
               item_renegoc_acr.num_id_tit_acr            = tt_integr_acr_item_renegoc.tta_num_id_tit_acr
               item_renegoc_acr.cod_motiv_movto_tit_acr   = tt_integr_acr_item_renegoc.tta_cod_motiv_movto_tit_acr
               item_renegoc_acr.des_text_histor           = tt_integr_acr_item_renegoc.tta_des_text_histor
               renegoc_acr.val_tit_acr                    = renegoc_acr.val_tit_acr + v_val_sdo_tit_acr_integr.
        release b_item_renegoc_acr_integr.
        release item_renegoc_acr.

    end.  /* if avail tit_acr */
END PROCEDURE. /* pi_vld_acr_cria_item_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_vld_renegoc_acr_subst_novos
** Descricao.............: pi_vld_renegoc_acr_subst_novos
** Criado por............: Rafael
** Criado em.............: 08/05/1998 13:55:36
** Alterado por..........: fut31947
** Alterado em...........: 18/09/2009 16:15:39
*****************************************************************************/
PROCEDURE pi_vld_renegoc_acr_subst_novos:

    /************************ Parameter Definition Begin ************************/

    def Input param p_log_valid_tit_unico_acr
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_espec_docto_financ_acr
        for espec_docto_financ_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_acr
        for tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ
        as character
        format "x(10)":U
        label "Finalidade Econìmica"
        column-label "Finalidade Econìmica"
        no-undo.
    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_num_count
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    run pi_retornar_finalid_indic_econ (Input renegoc_acr.cod_indic_econ,
                                        Input renegoc_acr.dat_transacao,
                                        output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ*/.

    find espec_docto
        where espec_docto.cod_espec_docto = renegoc_acr.cod_espec_docto no-lock no-error.
    if  not avail espec_docto then do:
        &if '{&frame_aux}' <> "" &then
            /* &1 inexistente ! */
            run pi_messages (input "show",
                             input 1284,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "EspÇcie Documento", "EspÇcies Documento")) /*msg_1284*/.
            return error.
        &else
            assign v_cod_parameters = "EspÇcie Documento" /*l_especie_documento*/  + "," + "EspÇcie Documento" /*l_especie_documento*/  + ",,,,,,,,".
            run pi_integr_acr_renegoc_erros(1284,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","",
                                            v_cod_parameters).
            return error.
        &endif
    end.
    else do:

         /* Begin_Include: i_verificar_especie_documento_tit_novo */
             if  v_ind_espec_docto = "Aviso DÇbito" /*l_aviso_debito*/  then do:
                 if  espec_docto.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/ 
                 and espec_docto.ind_tip_espec_docto <> "Normal" /*l_normal*/  then do:
                     &if '{&frame_aux}' <> "" &then
                         /* EspÇcie Documento inv†lida para geraá∆o de novos t°tulos ! */
                         run pi_messages (input "show",
                                          input 8506,
                                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8506*/.
                         return error.
                     &else
                         run pi_integr_acr_renegoc_erros(8506,
                                                         renegoc_acr.cod_estab,
                                                         renegoc_acr.num_renegoc_cobr_acr,
                                                         "",
                                                         renegoc_acr.cdn_cliente,
                                                         renegoc_acr.cod_espec_docto,
                                                         renegoc_acr.cod_ser_docto,
                                                         renegoc_acr.cod_tit_acr,
                                                         renegoc_acr.cod_parcela,
                                                         "","","").
                     &endif
                 end.
             end.
             else do:
                 if  espec_docto.ind_tip_espec_docto <> "Normal" /*l_normal*/  then do:
                    &if '{&frame_aux}' <> "" &then
                        /* EspÇcie Documento inv†lida para geraá∆o de novos t°tulos ! */
                        run pi_messages (input "show",
                                         input 8506,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8506*/.
                        return error.
                    &else
                        run pi_integr_acr_renegoc_erros(8506,
                                                        renegoc_acr.cod_estab,
                                                        renegoc_acr.num_renegoc_cobr_acr,
                                                        "",
                                                        renegoc_acr.cdn_cliente,
                                                        renegoc_acr.cod_espec_docto,
                                                        renegoc_acr.cod_ser_docto,
                                                        renegoc_acr.cod_tit_acr,
                                                        renegoc_acr.cod_parcela,
                                                        "","","").
                    &endif
                 end.  
             end.   
         /* End_Include: i_verificar_especie_documento_tit_novo */

    end.

    find espec_docto_financ_acr
        where espec_docto_financ_acr.cod_espec_docto = renegoc_acr.cod_espec_docto no-lock no-error.
    if  not avail espec_docto_financ_acr then do:
        &if '{&frame_aux}' <> "" &then
            /* EspÇcie Docto Financeira para AD Inexistente ! */
            run pi_messages (input "show",
                             input 427,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_427*/.
            return error.
        &else
            run pi_integr_acr_renegoc_erros(427,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","","").
        &endif
    end.

    /* ==> MODULO VENDOR <== */
    /* *** Validaá‰es Vendor ***/
    if  v_log_modul_vendor then do:
        if  can-find(first cart_bcia
                     where cart_bcia.cod_cart_bcia = renegoc_acr.cod_cart_bcia 
                     and   cart_bcia.ind_tip_cart_bcia = "Vendor" /*l_Vendor*/ )  then do:
            /* Tipo Carteira Vendor n∆o poder† ser utilizada pelo T°tulo ! */
            &if '{&frame_aux}' <> "" &then
               /* Tipo Carteira Vendor n∆o poder† ser utilizada pelo T°tulo ! */
               run pi_messages (input "show",
                                input 12157,
                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                  renegoc_acr.cod_cart_bcia)) /*msg_12157*/.
               return error.
            &else
                assign v_cod_parameters = renegoc_acr.cod_cart_bcia + ",,,,,,,,".        
                run pi_integr_acr_renegoc_erros(12157,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","",
                                                v_cod_parameters).
            &endif
        end.

        find first tt_espec_vdr_db
             where tt_espec_vdr_db.tta_cod_espec_docto = renegoc_acr.cod_espec_docto
             no-error.

        if  avail tt_espec_vdr_db then do:

            for each b_item_renegoc_acr
                fields(b_item_renegoc_acr.cod_estab
                       b_item_renegoc_acr.num_renegoc_cobr_acr
                       b_item_renegoc_acr.num_id_tit_acr)
                where b_item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
                and   b_item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr        
                no-lock :

                for first b_tit_acr
                    fields(b_tit_acr.cod_estab
                           b_tit_acr.num_id_tit_acr
                           b_tit_acr.cod_espec_docto
                           b_tit_acr.ind_tip_espec_docto)
                    where b_tit_acr.cod_estab      = b_item_renegoc_acr.cod_estab
                    and   b_tit_acr.num_id_tit_acr = b_item_renegoc_acr.num_id_tit_acr:

                    find first tt_espec_vdr_db
                         where tt_espec_vdr_db.tta_cod_espec_docto =  b_tit_acr.cod_espec_docto
                         no-error.

                    if  not avail tt_espec_vdr_db then do:
                        &if '{&frame_aux}' <> "" &then
                           /* N∆o Ç poss°vel renegociar t°tulos do tipo &1 ! */
                           run pi_messages (input "show",
                                            input 12343,
                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                              "Vendor DÇbito" /*l_vendor_debito*/ ,b_tit_acr.ind_tip_espec_docto)) /*msg_12343*/.
                           return error.
                        &else
                            assign v_cod_parameters = "Vendor DÇbito" /*l_vendor_debito*/  + "," + b_tit_acr.ind_tip_espec_docto + ",,,,,,,".
                            run pi_integr_acr_renegoc_erros(12343,
                                                            renegoc_acr.cod_estab,
                                                            renegoc_acr.num_renegoc_cobr_acr,
                                                            "",
                                                            renegoc_acr.cdn_cliente,
                                                            renegoc_acr.cod_espec_docto,
                                                            renegoc_acr.cod_ser_docto,
                                                            renegoc_acr.cod_tit_acr,
                                                            renegoc_acr.cod_parcela,
                                                            "","",
                                                            v_cod_parameters).
                        &endif
                    end.
                end.
            end.
        end.
    end.

    for each  item_renegoc_acr no-lock
        where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
          and item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr:
        find b_tit_acr no-lock
             where b_tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
               and b_tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr 
             no-error.
        find b_espec_docto_financ_acr
             where b_espec_docto_financ_acr.cod_espec_docto = b_tit_acr.cod_espec_docto 
             no-lock no-error.

        if not avail b_espec_docto_financ_acr 
        then do:
             &if '{&frame_aux}' <> "" &then
                /* EspÇcie Docto Financeiro ACR inexistente ! */
                run pi_messages (input "show",
                                 input 8483,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8483*/.
                return error.
             &else
                run pi_integr_acr_renegoc_erros(8483,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                b_tit_acr.cdn_cliente,
                                                b_tit_acr.cod_espec_docto,
                                                b_tit_acr.cod_ser_docto,
                                                b_tit_acr.cod_tit_acr,
                                                b_tit_acr.cod_parcela,
                                                "","","").
             &endif
        end.

        if b_espec_docto_financ_acr.log_ctbz_aprop_ctbl <> espec_docto_financ_acr.log_ctbz_aprop_ctbl
        then do:
             &if '{&frame_aux}' <> "" &then
                /* EspÇcies cont†beis s¢ podem gerar titulos que contabilizem ! */
                run pi_messages (input "show",
                                 input 8043,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8043*/.
                return error.
             &else
                run pi_integr_acr_renegoc_erros(8043,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","","").
             &endif
        end.
    end.

    find ser_fisc_nota
        where ser_fisc_nota.cod_ser_fisc_nota = renegoc_acr.cod_ser_docto no-lock no-error.
    if  not avail ser_fisc_nota then do:
        &if '{&frame_aux}' <> "" &then
            /* &1 inexistente ! */
            run pi_messages (input "show",
                             input 1284,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "SÇrie Fiscal", "SÇrie Fiscal")) /*msg_1284*/.
            return error.
        &else
            assign v_cod_parameters = "SÇrie Fiscal" /*l_ser_fiscal*/  + ",,,,,,,,".
            run pi_integr_acr_renegoc_erros(1284,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","",
                                            v_cod_parameters).
        &endif
    end.

    run pi_validar_portador_acr (Input renegoc_acr.cod_portador,
                                 Input renegoc_acr.cod_estab,
                                 Input renegoc_acr.cod_indic_econ,
                                 Input renegoc_acr.cod_cart_bcia,
                                 Input renegoc_acr.dat_transacao,
                                 output v_cod_return) /*pi_validar_portador_acr*/.
    if  entry(1,v_cod_return) <> "OK" /*l_ok*/  then do:
        case entry(1,v_cod_return):
            when "506" then do: 
                &if '{&frame_aux}' <> "" &then
                    /* Portador Inexistente ! */
                    run pi_messages (input "show",
                                     input 506,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_506*/.
                    return error.
                &else
                    run pi_integr_acr_renegoc_erros(506,
                                                    renegoc_acr.cod_estab,
                                                    renegoc_acr.num_renegoc_cobr_acr,
                                                    "",
                                                    renegoc_acr.cdn_cliente,
                                                    renegoc_acr.cod_espec_docto,
                                                    renegoc_acr.cod_ser_docto,
                                                    renegoc_acr.cod_tit_acr,
                                                    renegoc_acr.cod_parcela,
                                                    "","","").
                &endif            
            end.
            when "775" then do:
                &if '{&frame_aux}' <> "" &then
                    /* Portador &1 n∆o vinculado ao estabelecimento &2 ! */
                    run pi_messages (input "show",
                                     input 775,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        renegoc_acr.cod_portador, renegoc_acr.cod_estab)) /*msg_775*/.
                    return error.            
                &else
                    assign v_cod_parameters = renegoc_acr.cod_portador + "," + renegoc_acr.cod_estab + ",,,,,,,".
                    run pi_integr_acr_renegoc_erros(775,
                                                    renegoc_acr.cod_estab,
                                                    renegoc_acr.num_renegoc_cobr_acr,
                                                    "",
                                                    renegoc_acr.cdn_cliente,
                                                    renegoc_acr.cod_espec_docto,
                                                    renegoc_acr.cod_ser_docto,
                                                    renegoc_acr.cod_tit_acr,
                                                    renegoc_acr.cod_parcela,
                                                    "","",
                                                    v_cod_parameters).
                &endif            
            end.
            when "3054" then do:
                &if '{&frame_aux}' <> "" &then
                    /* Finalidade Econìmica / Carteira incorreta para o Portador ! */
                    run pi_messages (input "show",
                                     input 3054,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        v_cod_finalid_econ, renegoc_acr.cod_cart_bcia, renegoc_acr.cod_portador, renegoc_acr.cod_estab)) /*msg_3054*/.
                    return error.            
                &else
                    assign v_cod_parameters = v_cod_finalid_econ + "," + renegoc_acr.cod_cart_bcia + "," + renegoc_acr.cod_portador + "," + renegoc_acr.cod_estab + ",,,,,,,".
                    run pi_integr_acr_renegoc_erros(3054,
                                                    renegoc_acr.cod_estab,
                                                    renegoc_acr.num_renegoc_cobr_acr,
                                                    "",
                                                    renegoc_acr.cdn_cliente,
                                                    renegoc_acr.cod_espec_docto,
                                                    renegoc_acr.cod_ser_docto,
                                                    renegoc_acr.cod_tit_acr,
                                                    renegoc_acr.cod_parcela,
                                                    "","",v_cod_parameters).
                &endif            
            end.
        end.
    end.
    find portad_bco no-lock
        where portad_bco.cod_modul_dtsul  = "ACR" /*l_acr*/ 
        and   portad_bco.cod_estab        = renegoc_acr.cod_estab
        and   portad_bco.cod_portador     = renegoc_acr.cod_portador
        and   portad_bco.cod_cart_bcia    = renegoc_acr.cod_cart_bcia
        and   portad_bco.cod_finalid_econ = v_cod_finalid_econ
        no-error.
    if  not avail portad_bco then do:
        &if '{&frame_aux}' <> "" &then
            /* Portador Banco Inexistente ! */
            run pi_messages (input "show",
                             input 3499,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                renegoc_acr.cod_portador,                           "ACR" /*l_acr*/ ,                           renegoc_acr.cod_estab,                           renegoc_acr.cod_cart_bcia,                           v_cod_finalid_econ)) /*msg_3499*/.
            return error.
        &else
            assign v_cod_parameters = renegoc_acr.cod_portador + "," + "ACR" /*l_acr*/  + "," + renegoc_acr.cod_estab + "," + renegoc_acr.cod_cart_bcia + "," + v_cod_finalid_econ + ",,,,,,,".
            run pi_integr_acr_renegoc_erros(3499,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","",v_cod_parameters).
        &endif
    end.

    /* retirado em 14/01 por gilmar para atender a FO 527.392, visando
    possibilitar manter a data de vencto do t°tulo antigo.
    if renegoc_acr.dat_primei_vencto_renegoc < renegoc_acr.dat_transacao then do:
        &if '{&frame_aux}' <> "" &then
            @cx_message(8323, renegoc_acr.dat_transacao, renegoc_acr.dat_primei_vencto_renegoc).
            return error.
        &else
            assign v_cod_parameters = string(renegoc_acr.dat_transacao) + "," + string(renegoc_acr.dat_primei_vencto_renegoc) + ",,,,,,,".
            run pi_integr_acr_renegoc_erros(8323,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","",v_cod_parameters).
        &endif
    end.
    */

    if  renegoc_acr.cdn_repres <> 0
    and renegoc_acr.cdn_repres <> ? then do:
        find representante
            where representante.cod_empresa = renegoc_acr.cod_empresa
            and   representante.cdn_repres  = renegoc_acr.cdn_repres no-lock no-error.
        if  not avail representante then do:
            &if '{&frame_aux}' <> "" &then
                /* &1 inexistente ! */
                run pi_messages (input "show",
                                 input 1284,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    "Representante", "Representantes")) /*msg_1284*/.
                return error.
            &else
                assign v_cod_parameters = "Representante" /*l_representante*/  + ",,,,,,,,".        
                run pi_integr_acr_renegoc_erros(1284,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","",
                                                v_cod_parameters).
            &endif
        end.
    end.

    if  renegoc_acr.cod_cond_cobr <> "" then do:
        find cond_cobr_acr no-lock
             where cond_cobr_acr.cod_estab       = renegoc_acr.cod_estab
               and cond_cobr_acr.cod_cond_cobr   = renegoc_acr.cod_cond_cobr
               and cond_cobr_acr.dat_inic_valid <= renegoc_acr.dat_transacao
               and cond_cobr_acr.dat_fim_valid  >  renegoc_acr.dat_transacao
             no-error.
        if  not avail cond_cobr_acr then do:
            &if '{&frame_aux}' <> "" &then
                /* Condiá∆o de Cobranáa incorreta para Data de Emiss∆o ! */
                run pi_messages (input "show",
                                 input 52,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_52*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(52,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","","").
            &endif
        end.
        find compl_cond_cobr_acr no-lock
             where compl_cond_cobr_acr.cod_estab                 = renegoc_acr.cod_estab
             and   compl_cond_cobr_acr.cod_cond_cobr             = renegoc_acr.cod_cond_cobr
             and   compl_cond_cobr_acr.num_seq_cond_cobr_acr     = cond_cobr_acr.num_seq_cond_cobr_acr
             and   compl_cond_cobr_acr.log_cond_cobr_acr_padr    = yes
             no-error.
        if  not avail compl_cond_cobr_acr then do:
            &if '{&frame_aux}' <> "" &then
                /* N∆o existe Condiá∆o de Cobranáa Padr∆o. */
                run pi_messages (input "show",
                                 input 5220,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    renegoc_acr.cod_estab,                                renegoc_acr.cod_cond_cobr)) /*msg_5220*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(5220,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","","").
            &endif

        end.
    end.

    if  renegoc_acr.qtd_parc_renegoc = 0 then do:
        &if '{&frame_aux}' <> "" &then
            /* Quantidade de Parcelas deve ser maior que zero ! */
            run pi_messages (input "show",
                             input 4954,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4954*/.
            return error.
        &else
            run pi_integr_acr_renegoc_erros(4954,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            renegoc_acr.cod_espec_docto,
                                            renegoc_acr.cod_ser_docto,
                                            renegoc_acr.cod_tit_acr,
                                            renegoc_acr.cod_parcela,
                                            "","","").
        &endif
    end.

    if  renegoc_acr.ind_vencto_renegoc = "Nr Dias" /*l_nr_dias*/  then do:

        &if '{&emsuni_version}' > '5.01' &then
            assign v_num_dias_vencto_renegoc = renegoc_acr.num_dias_vencto_renegoc.

        &else
            assign v_num_dias_vencto_renegoc = renegoc_acr.num_livre_1.

        &endif

        if v_num_dias_vencto_renegoc <= 0 then do:
            &if '{&frame_aux}' <> "" &then
                /* Nro. de Dias deve ser Informado ! */
                run pi_messages (input "show",
                                 input 6091,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_6091*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(6091,
                                                renegoc_acr.cod_estab,
                                                renegoc_acr.num_renegoc_cobr_acr,
                                                "",
                                                renegoc_acr.cdn_cliente,
                                                renegoc_acr.cod_espec_docto,
                                                renegoc_acr.cod_ser_docto,
                                                renegoc_acr.cod_tit_acr,
                                                renegoc_acr.cod_parcela,
                                                "","","").
            &endif
        end.
    end.

    if(v_log_error_renegoc_acr = no) then do:
       assign v_log_repres = no.
       repres:
       for each item_renegoc_acr no-lock
           where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
           and   item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr:

           find tit_acr no-lock
               where tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
               and   tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr
               no-error.

           if  avail tit_acr then do:

               if  tit_acr.cdn_repres = 0 then do:
                   assign v_log_repres = ?.
                   next repres.
               end.

               if  tit_acr.cdn_repres = renegoc_acr.cdn_repres then do:
                   assign v_log_repres = yes.
                   leave repres.
               end.
               else
                   assign v_log_repres = no.
           end.
       end.

       if v_log_repres = no 
       or (v_log_repres = ? and renegoc_acr.cdn_repres <> 0) then do:
          &if '{&frame_aux}' <> "" &then
              /* Representante Inv†lido para o novo T°tulo ! */
              run pi_messages (input "show",
                               input 7767,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_7767*/.
              return error.
          &else
              run pi_integr_acr_renegoc_erros(7767,
                                              renegoc_acr.cod_estab,
                                              renegoc_acr.num_renegoc_cobr_acr,
                                              "",
                                              renegoc_acr.cdn_cliente,
                                              renegoc_acr.cod_espec_docto,
                                              renegoc_acr.cod_ser_docto,
                                              renegoc_acr.cod_tit_acr,
                                              renegoc_acr.cod_parcela,
                                              "","","").
           &endif
       end.
    end.
    /* **
    @if(v_log_integr_mec and v_cod_moeda = @%(l_estrangeira))
        @if(can-find(first tt_item_lote_impl_tit_acr_br
            where tt_item_lote_impl_tit_acr_br.tta_cod_proces_export = ''))
            @cx_message(12168).
            return error.
        end.
    end.
    ****/
END PROCEDURE. /* pi_vld_renegoc_acr_subst_novos */
/*****************************************************************************
** Procedure Interna.....: pi_verificar_titulo_unico_acr
** Descricao.............: pi_verificar_titulo_unico_acr
** Criado por............: Creuz
** Criado em.............: 20/08/1996 13:38:38
** Alterado por..........: its0105
** Alterado em...........: 08/08/2005 11:16:24
*****************************************************************************/
PROCEDURE pi_verificar_titulo_unico_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
        as character
        format "x(3)"
        no-undo.
    def input param p_cod_tit_acr
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
        no-undo.
    def Input param p_rec_item_lote_impl_tit_acr
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_tit_acr_unico
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_impl_tit_acr
        for item_lote_impl_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_renegoc_acr
        for renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    assign p_log_tit_acr_unico = yes.

    if  can-find(first b_item_lote_impl_tit_acr
                 where b_item_lote_impl_tit_acr.cod_estab       = p_cod_estab
                   and b_item_lote_impl_tit_acr.cod_espec_docto = p_cod_espec_docto
                   and b_item_lote_impl_tit_acr.cod_ser_docto   = p_cod_ser_docto
                   and b_item_lote_impl_tit_acr.cod_tit_acr     = p_cod_tit_acr
                   and b_item_lote_impl_tit_acr.cod_parcela     = p_cod_parcela
                   and recid(b_item_lote_impl_tit_acr)         <> p_rec_item_lote_impl_tit_acr
                 use-index itmltmpa_titulo) then
        assign p_log_tit_acr_unico = no.

    if  p_log_tit_acr_unico = yes
    and can-find(first tit_acr
                 where tit_acr.cod_estab       = p_cod_estab
                   and tit_acr.cod_espec_docto = p_cod_espec_docto
                   and tit_acr.cod_ser_docto   = p_cod_ser_docto
                   and tit_acr.cod_tit_acr     = p_cod_tit_acr
                   and tit_acr.cod_parcela     = p_cod_parcela) then
        assign p_log_tit_acr_unico = no.

    if  p_log_tit_acr_unico = yes
    and can-find(first tit_acr_cobr_especial 
                 where tit_acr_cobr_especial.cod_estab       = p_cod_estab 
                   and tit_acr_cobr_especial.cod_espec_docto = p_cod_espec_docto 
                   and tit_acr_cobr_especial.cod_ser_docto   = p_cod_ser_docto 
                   and tit_acr_cobr_especial.cod_tit_acr     = p_cod_tit_acr 
                   and tit_acr_cobr_especial.cod_parcela     = p_cod_parcela) then
        assign p_log_tit_acr_unico = no. 

    &if defined (BF_FIN_BCOS_HISTORICOS) &then
        if  v_log_utiliza_mbh
        and can-find (his_tit_acr_histor no-lock
                      where his_tit_acr_histor.cod_estab       = p_cod_estab
                      and   his_tit_acr_histor.cod_espec_docto = p_cod_espec_docto
                      and   his_tit_acr_histor.cod_ser_docto   = p_cod_ser_docto
                      and   his_tit_acr_histor.cod_tit_acr     = p_cod_tit_acr
                      and   his_tit_acr_histor.cod_parcela     = p_cod_parcela)
        then do:

            assign p_log_tit_acr_unico = no.
        end.
    &endif
END PROCEDURE. /* pi_verificar_titulo_unico_acr */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_finalid_indic_econ
** Descricao.............: pi_retornar_finalid_indic_econ
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut40518
** Alterado em...........: 08/07/2010 10:52:38
*****************************************************************************/
PROCEDURE pi_retornar_finalid_indic_econ:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/



    /* alteracao sob demanda - atividade 195864*/
     find first histor_finalid_econ no-lock
        where histor_finalid_econ.cod_indic_econ          = p_cod_indic_econ
        and   histor_finalid_econ.dat_inic_valid_finalid <= p_dat_transacao
        and   histor_finalid_econ.dat_fim_valid_finalid  > p_dat_transacao no-error.

        if avail histor_finalid_econ then
           assign p_cod_finalid_econ = histor_finalid_econ.cod_finalid_econ.


END PROCEDURE. /* pi_retornar_finalid_indic_econ */
/*****************************************************************************
** Procedure Interna.....: pi_validar_portador_acr
** Descricao.............: pi_validar_portador_acr
** Criado por............: Claudia
** Criado em.............: 20/08/1996 16:26:07
** Alterado por..........: lucas
** Alterado em...........: 19/02/1999 08:50:40
*****************************************************************************/
PROCEDURE pi_validar_portador_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_cart_bcia
        as character
        format "x(3)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ
        as character
        format "x(10)":U
        label "Finalidade Econìmica"
        column-label "Finalidade Econìmica"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_cod_return = "OK" /*l_ok*/ .

    find portador no-lock
         where portador.cod_portador = p_cod_portador /*cl_param of portador*/ no-error.
    if  not avail portador
    then do:
        assign p_cod_return = "506".
        return.
    end /* if */.
    else do:
        find portad_estab no-lock
             where portad_estab.cod_estab = p_cod_estab
               and portad_estab.cod_portador = p_cod_portador /*cl_param of portad_estab*/ no-error.
        if  not avail portad_estab
        then do:
            assign p_cod_return = "775".
            return.
        end /* if */.
        else do:
            run pi_retornar_finalid_indic_econ (Input p_cod_indic_econ,
                                                Input p_dat_transacao,
                                                output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ*/.
            find portad_finalid_econ no-lock
                 where portad_finalid_econ.cod_estab = p_cod_estab
                   and portad_finalid_econ.cod_portador = p_cod_portador
                   and portad_finalid_econ.cod_finalid_econ = v_cod_finalid_econ
                   and portad_finalid_econ.cod_cart_bcia = p_cod_cart_bcia /*cl_valida_portador_acr of portad_finalid_econ*/ no-error.
            if  not avail portad_finalid_econ
            then do:
                assign p_cod_return = "3054".
                return.
            end /* if */.
        end /* else */.
    end /* else */.

END PROCEDURE. /* pi_validar_portador_acr */
/*****************************************************************************
** Procedure Interna.....: pi_vld_acr_cria_item_lote_impl_renegoc
** Descricao.............: pi_vld_acr_cria_item_lote_impl_renegoc
** Criado por............: bre17230
** Criado em.............: 17/07/1998 15:02:26
** Alterado por..........: fut12235
** Alterado em...........: 02/06/2010 09:20:28
*****************************************************************************/
PROCEDURE pi_vld_acr_cria_item_lote_impl_renegoc:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_impl_tit_acr
        for item_lote_impl_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_seq_item_lote_impl
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_aux                        as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    find item_lote_impl_tit_acr no-lock
        where item_lote_impl_tit_acr.cod_estab       = tit_acr.cod_estab
        and   item_lote_impl_tit_acr.cod_espec_docto = tit_acr.cod_espec_docto
        and   item_lote_impl_tit_acr.cod_ser_docto   = tit_acr.cod_ser_docto
        and   item_lote_impl_tit_acr.cod_tit_acr     = tit_acr.cod_tit_acr
        and   item_lote_impl_tit_acr.cod_parcela     = tit_acr.cod_parcela
        no-error.
    if avail item_lote_impl_tit_acr then do:
        &if '{&frame_aux}' <> "" &then
            /* &1 j† existente ! */
            run pi_messages (input "show",
                             input 1,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "T°tulo" /*l_titulo*/)) /*msg_1*/.
            return error.
        &else
            assign v_cod_parameters = "T°tulo" /*l_titulo*/  + ",,,,,,,,".
            run pi_integr_acr_renegoc_erros(1,
                                            tit_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "",
                                            renegoc_acr.cdn_cliente,
                                            tit_acr.cod_espec_docto,
                                            tit_acr.cod_ser_docto,
                                            tit_acr.cod_tit_acr,
                                            tit_acr.cod_parcela,
                                            "","",
                                            v_cod_parameters).
         &endif
    end.
    else do:
        find last b_item_lote_impl_tit_acr no-lock
            where b_item_lote_impl_tit_acr.cod_estab = renegoc_acr.cod_estab
            and   b_item_lote_impl_tit_acr.cod_refer = renegoc_acr.cod_refer
            no-error.           
        if avail b_item_lote_impl_tit_acr then do:
            assign v_num_seq_item_lote_impl = b_item_lote_impl_tit_acr.num_seq_refer + 10.
        end.
        else do:
            assign v_num_seq_item_lote_impl = 10.
        end.

        assign v_val_acum_perc  = 0
               v_val_maior_perc = 0.

        create  b_item_lote_impl_tit_acr.
        assign  b_item_lote_impl_tit_acr.cod_empresa               = renegoc_acr.cod_empresa
                b_item_lote_impl_tit_acr.cod_estab                 = renegoc_acr.cod_estab
                b_item_lote_impl_tit_acr.cod_refer                 = renegoc_acr.cod_refer
                b_item_lote_impl_tit_acr.num_seq_refer             = v_num_seq_item_lote_impl
                b_item_lote_impl_tit_acr.num_renegoc_cobr_acr      = renegoc_acr.num_renegoc_cobr_acr
                b_item_lote_impl_tit_acr.cdn_cliente               = renegoc_acr.cdn_cliente
                b_item_lote_impl_tit_acr.cod_espec_docto           = renegoc_acr.cod_espec_docto
                b_item_lote_impl_tit_acr.cod_ser_docto             = renegoc_acr.cod_ser_docto
                b_item_lote_impl_tit_acr.cod_tit_acr               = tt_integr_acr_item_renegoc_new.tta_cod_tit_acr
                b_item_lote_impl_tit_acr.cod_parcela               = tt_integr_acr_item_renegoc_new.tta_cod_parcela
                b_item_lote_impl_tit_acr.cod_indic_econ            = renegoc_acr.cod_indic_econ
                b_item_lote_impl_tit_acr.cod_portador              = renegoc_acr.cod_portador
                b_item_lote_impl_tit_acr.cod_cart_bcia             = renegoc_acr.cod_cart_bcia
                b_item_lote_impl_tit_acr.cod_cond_cobr             = renegoc_acr.cod_cond_cobr
                b_item_lote_impl_tit_acr.cod_motiv_movto_tit_acr   = "" /* N∆o Ç utilizado no on-line */
                b_item_lote_impl_tit_acr.cod_histor_padr           = tt_integr_acr_item_renegoc_new.tta_cod_histor_padr
                b_item_lote_impl_tit_acr.des_text_histor           = tt_integr_acr_item_renegoc_new.tta_des_text_histor
                b_item_lote_impl_tit_acr.dat_vencto_tit_acr        = tt_integr_acr_item_renegoc_new.tta_dat_vencto_tit_acr
                b_item_lote_impl_tit_acr.dat_prev_liquidac         = tt_integr_acr_item_renegoc_new.tta_dat_prev_liquidac
                b_item_lote_impl_tit_acr.dat_desconto              = ?
                b_item_lote_impl_tit_acr.dat_emis_docto            = tt_integr_acr_item_renegoc_new.tta_dat_emis_docto
                b_item_lote_impl_tit_acr.val_tit_acr               = tt_integr_acr_item_renegoc_new.tta_val_tit_acr
                b_item_lote_impl_tit_acr.cdn_repres                = renegoc_acr.cdn_repres
                b_item_lote_impl_tit_acr.val_liq_tit_acr           = tt_integr_acr_item_renegoc_new.tta_val_tit_acr
                b_item_lote_impl_tit_acr.val_desconto              = 0
                b_item_lote_impl_tit_acr.val_perc_desc             = 0
                b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso = 0
                b_item_lote_impl_tit_acr.val_perc_multa_atraso     = 0
                b_item_lote_impl_tit_acr.ind_tip_espec_docto       = "Normal" /*l_normal*/ 
                b_item_lote_impl_tit_acr.ind_sit_tit_acr           = "Normal" /*l_normal*/ 
                b_item_lote_impl_tit_acr.log_val_fix_parc          = tt_integr_acr_item_renegoc_new.tta_log_val_fix_parc.
        &if '{&EMSFIN_VERSION}' >= '5.06' &THEN
            assign  b_item_lote_impl_tit_acr.cod_proces_export         = tt_integr_acr_item_renegoc_new.tta_cod_proces_export. 
        &ELSE
            find first param_integr_ems no-lock
                 where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
            if  avail param_integr_ems
              and v_num_natur = 3 
              and v_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  then do:

                assign b_item_lote_impl_tit_acr.cod_livre_1 = SetEntryField(6, 
                                                                            b_item_lote_impl_tit_acr.cod_livre_1, 
                                                                            chr(24), 
                                                                            tt_integr_acr_item_renegoc_new.tta_cod_proces_export).
            end.
        &ENDIF

        /* ** Cria novos valores de PIS/COFINS/CSLL ***/
        if v_cod_pais_empres_usuar = "BRA" /*l_bra*/  then do:
            &if '{&EMSFIN_VERSION}' >= '5.06' &THEN
                assign b_item_lote_impl_tit_acr.val_cr_pis            = tt_integr_acr_item_renegoc_new.ttv_val_cr_pis
                       b_item_lote_impl_tit_acr.val_cr_cofins         = tt_integr_acr_item_renegoc_new.ttv_val_cr_cofins
                       b_item_lote_impl_tit_acr.val_cr_csll           = tt_integr_acr_item_renegoc_new.ttv_val_cr_csll
                       b_item_lote_impl_tit_acr.val_base_calc_impto   = tt_integr_acr_item_renegoc_new.tta_val_base_calc_impto
                       b_item_lote_impl_tit_acr.log_retenc_impto_impl = tt_integr_acr_item_renegoc_new.tta_log_retenc_impto_impl.
            &ELSE
                if tt_integr_acr_item_renegoc_new.ttv_val_cr_pis    > 0.00 or
                   tt_integr_acr_item_renegoc_new.ttv_val_cr_cofins > 0.00 or
                   tt_integr_acr_item_renegoc_new.ttv_val_cr_csll   > 0.00 or
                   tt_integr_acr_item_renegoc_new.tta_val_base_calc_impto > 0.00 then do: 
                    create tab_livre_emsfin.
                    assign tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                           tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                           tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                                 + chr(24) 
                                                                 + b_item_lote_impl_tit_acr.cod_refer
                           tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer)
                           tab_livre_emsfin.cod_livre_1          = string(tt_integr_acr_item_renegoc_new.ttv_val_cr_pis)          + chr(24)
                                                                 + string(tt_integr_acr_item_renegoc_new.ttv_val_cr_cofins)       + chr(24)
                                                                 + string(tt_integr_acr_item_renegoc_new.ttv_val_cr_csll)         + chr(24)
                                                                 + string(tt_integr_acr_item_renegoc_new.tta_val_base_calc_impto) + chr(24)
                                                                 + string(tt_integr_acr_item_renegoc_new.tta_log_retenc_impto_impl).
                End.
            &ENDIF 
        end. 

        find first cond_cobr_acr no-lock
             where cond_cobr_acr.cod_estab     = renegoc_acr.cod_estab 
               and cond_cobr_acr.cod_cond_cobr = renegoc_acr.cod_cond_cobr no-error.
        if avail cond_cobr_acr 
        then do:
            assign b_item_lote_impl_tit_acr.val_perc_multa_atraso     = cond_cobr_acr.val_perc_multa_cond_cobr
                   b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso = cond_cobr_acr.val_perc_juros_acr / 30
                   b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr = cond_cobr_acr.qtd_dias_carenc_multa_acr
                   b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr = cond_cobr_acr.qtd_dias_carenc_juros_acr.
        end.
        else do:    
             run pi_retorna_parametro_acr (Input renegoc_acr.cod_estab,
                                           Input renegoc_acr.dat_transacao) /* pi_retorna_parametro_acr*/.
             if avail param_estab_acr then 
                assign b_item_lote_impl_tit_acr.val_perc_multa_atraso     = param_estab_acr.val_perc_multa_acr
                       b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso = param_estab_acr.val_perc_juros_acr / 30
                       b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr = param_estab_acr.qtd_dias_carenc_multa_acr
                       b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr = param_estab_acr.qtd_dias_carenc_juros_acr.
        end.   

        /* Atualizando o atributo cod_livre_1 com todos os separadores poss°veis */
        /* Posteriormente ser† atualizado apenas a "entrada" em quest∆o          */
        /* N∆o sendo necess†rio a gravaá∆o do separador chr(24)                  */
        if  num-entries(b_item_lote_impl_tit_acr.cod_livre_1, chr(24)) < 4 then do:
            do v_num_aux = num-entries(b_item_lote_impl_tit_acr.cod_livre_1, chr(24)) + 1 to 4:
                assign b_item_lote_impl_tit_acr.cod_livre_1 = b_item_lote_impl_tit_acr.cod_livre_1 + chr(24).
            end.
        end.

        assign v_val_tot = v_val_tot + b_item_lote_impl_tit_acr.val_tit_acr.

        /* cria os pedidos de venda dos t°tulos antigos para o novo t°tulos ou novos t°tulos */
        for each tt_ped_vda_tit_acr_pend no-lock:
            create ped_vda_tit_acr_pend.
            assign ped_vda_tit_acr_pend.cod_estab                 = b_item_lote_impl_tit_acr.cod_estab
                   ped_vda_tit_acr_pend.cod_refer                 = b_item_lote_impl_tit_acr.cod_refer
                   ped_vda_tit_acr_pend.num_seq_refer             = b_item_lote_impl_tit_acr.num_seq_refer
                   ped_vda_tit_acr_pend.cod_ped_vda               = tt_ped_vda_tit_acr_pend.tta_cod_ped_vda
                   ped_vda_tit_acr_pend.cod_ped_vda_repres        = tt_ped_vda_tit_acr_pend.tta_cod_ped_vda_repres
                   ped_vda_tit_acr_pend.val_perc_particip_ped_vda = (tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr * 100 ) / v_val_tot_renegoc_tit_acr
                   ped_vda_tit_acr_pend.des_ped_vda               = tt_ped_vda_tit_acr_pend.tta_des_ped_vda.
            assign v_val_acum_perc = v_val_acum_perc + ped_vda_tit_acr_pend.val_perc_particip_ped_vda.
            if ped_vda_tit_acr_pend.val_perc_particip_ped_vda > v_val_maior_perc then 
               assign v_val_maior_perc           = ped_vda_tit_acr_pend.val_perc_particip_ped_vda
                      v_rec_ped_vda_tit_acr_pend = recid(ped_vda_tit_acr_pend).
        end.
        if v_val_acum_perc > 100 then do:
           find ped_vda_tit_acr_pend exclusive-lock
                where recid(ped_vda_tit_acr_pend) = v_rec_ped_vda_tit_acr_pend no-error.
           if avail ped_vda_tit_acr_pend then
              /* Ç usada a mesma vari†vel do acumulador porque ela n∆o Ç mais utilizada, e a cada nova execuá∆o ela tambÇm Ç zerada */
              assign v_val_maior_perc                               = (v_val_acum_perc - 100)
                     ped_vda_tit_acr_pend.val_perc_particip_ped_vda = ped_vda_tit_acr_pend.val_perc_particip_ped_vda - v_val_maior_perc.
        end.
    end.     
END PROCEDURE. /* pi_vld_acr_cria_item_lote_impl_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_refer_unica_acr
** Descricao.............: pi_verifica_refer_unica_acr
** Criado por............: Claudia
** Criado em.............: 14/08/1996 09:34:38
** Alterado por..........: its0105
** Alterado em...........: 23/08/2005 17:52:01
*****************************************************************************/
PROCEDURE pi_verifica_refer_unica_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.02" &then
    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_operac_financ_acr
        for operac_financ_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_renegoc_acr
        for renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "Operaá∆o financeira" /*l_operacao_financ*/  then do:
        find first b_operac_financ_acr no-lock
             where b_operac_financ_acr.cod_estab               = p_cod_estab
               and b_operac_financ_acr.cod_movto_operac_financ = p_cod_refer
               and recid( b_operac_financ_acr )               <> p_rec_tabela
             use-index oprcfnna_id no-error.
        if  avail b_operac_financ_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.

    &if defined (BF_FIN_BCOS_HISTORICOS) &then
        if  v_log_utiliza_mbh
        and can-find (his_movto_tit_acr_histor no-lock
                      where his_movto_tit_acr_histor.cod_estab = p_cod_estab
                      and   his_movto_tit_acr_histor.cod_refer = p_cod_refer)
        then do:

            assign p_log_refer_uni = no.
        end.
    &endif
END PROCEDURE. /* pi_verifica_refer_unica_acr */
/*****************************************************************************
** Procedure Interna.....: pi_vld_acr_cria_fiador_renegoc
** Descricao.............: pi_vld_acr_cria_fiador_renegoc
** Criado por............: bre17230
** Criado em.............: 22/07/1998 08:51:38
** Alterado por..........: fut31947
** Alterado em...........: 30/09/2009 11:38:19
*****************************************************************************/
PROCEDURE pi_vld_acr_cria_fiador_renegoc:

    /************************* Variable Definition Begin ************************/

    def var v_num_seq_fiador_renegoc
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    if tt_integr_acr_fiador_renegoc.tta_ind_testem_fiador <> "Fiador" /*l_fiador*/  and
       tt_integr_acr_fiador_renegoc.tta_ind_testem_fiador <> "Testemunha" /*l_testemunha*/  then do:
       run pi_integr_acr_renegoc_erros (Input 20128,
                                        Input tt_integr_acr_renegoc.tta_cod_estab,
                                        Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "") /*pi_integr_acr_renegoc_erros*/.
    end.

    find last fiador_renegoc no-lock
        where fiador_renegoc.cod_estab            = tt_integr_acr_renegoc.tta_cod_estab
        and   fiador_renegoc.num_renegoc_cobr_acr = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
        no-error.
    if avail fiador_renegoc then do:
        assign v_num_seq_fiador_renegoc = fiador_renegoc.num_seq + 1.
    end.
    else do:
        assign v_num_seq_fiador_renegoc = 1.
    end.
    create fiador_renegoc.
    assign fiador_renegoc.cod_estab            = tt_integr_acr_renegoc.tta_cod_estab
           fiador_renegoc.num_renegoc_cobr_acr = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
           fiador_renegoc.num_seq              = v_num_seq_fiador_renegoc
           fiador_renegoc.ind_testem_fiador    = tt_integr_acr_fiador_renegoc.tta_ind_testem_fiador
           fiador_renegoc.ind_tip_pessoa       = tt_integr_acr_fiador_renegoc.tta_ind_tip_pessoa
           fiador_renegoc.num_pessoa           = v_num_pessoa_fiador_renegoc
           fiador_renegoc.nom_abrev            = v_des_nom_abrev_fiador_renegoc.

END PROCEDURE. /* pi_vld_acr_cria_fiador_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_criticar_atualizacao_renegoc_subst_acr
** Descricao.............: pi_criticar_atualizacao_renegoc_subst_acr
** Criado por............: Rafael
** Criado em.............: 09/06/1998 08:11:48
** Alterado por..........: rafaelposse
** Alterado em...........: 16/10/2014 08:44:45
*****************************************************************************/
PROCEDURE pi_criticar_atualizacao_renegoc_subst_acr:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsuni_version}" >= "5.00" &then
    def buffer b_espec_docto_renegoc
        for ems5.espec_docto.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_val_tit_acr
        for val_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_cod_return_error
        as character
        format "x(8)":U
        no-undo.
    def var v_dsl_message
        as Character
        format "x(15000)":U
        view-as editor max-chars 15000 scrollbar-vertical
        size 90 by 1
        bgcolor 15 font 2
        no-undo.
    def var v_log_erro
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_log_dat_trans                  as logical         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    run pi_retornar_finalid_indic_econ (Input renegoc_acr.cod_indic_econ,
                                        Input renegoc_acr.dat_transacao,
                                        output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ*/.

    find first item_renegoc_acr no-lock
        where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
        and   item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
        no-error.

    if  not avail item_renegoc_acr then do:
        create tt_log_erros_atualiz.
        assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
               tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
               tt_log_erros_atualiz.tta_num_seq_refer   = 0
               tt_log_erros_atualiz.ttv_num_mensagem    = 5771
               tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
               tt_log_erros_atualiz.ttv_num_relacto     = 0.
        run pi_messages (input "msg",
                         input tt_log_erros_atualiz.ttv_num_mensagem,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
        run pi_messages (input "help",
                         input tt_log_erros_atualiz.ttv_num_mensagem,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
    end.
    else do:
        find cliente
            where cliente.cod_empresa = renegoc_acr.cod_empresa
            and   cliente.cdn_cliente = renegoc_acr.cdn_cliente
            no-lock no-error.

        find first item_renegoc_acr no-lock
            where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
            and   item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr.

        find tit_acr no-lock
            where tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
            and   tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr no-error.

        find b_espec_docto_renegoc no-lock
            where b_espec_docto_renegoc.cod_espec_docto = renegoc_acr.cod_espec_docto no-error.

        find espec_docto_financ_acr no-lock
            where espec_docto_financ_acr.cod_espec_docto = tit_acr.cod_espec_docto no-error.

        if  espec_docto_financ_acr.log_ctbz_aprop_ctbl
        and b_espec_docto_renegoc.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/  then do:

            find first cta_grp_clien
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
                and   cta_grp_clien.ind_finalid_ctbl    = "Transit¢ria de Substituiá∆o" /*l_transitoria_substituicao*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao
                no-lock no-error.
            if  not avail cta_grp_clien then do:
                find first cta_grp_clien
                    where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                    and   cta_grp_clien.cod_espec_docto     = ""
                    and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                    and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                    and   cta_grp_clien.ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                    and   cta_grp_clien.ind_finalid_ctbl    = "Transit¢ria de Substituiá∆o" /*l_transitoria_substituicao*/ 
                    and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                    and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao
                    no-lock no-error.
            end.

            if  not avail cta_grp_clien then do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                       tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                       tt_log_erros_atualiz.tta_num_seq_refer   = 0
                       tt_log_erros_atualiz.ttv_num_mensagem    = 53
                       tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                       tt_log_erros_atualiz.ttv_num_relacto     = 0.
                run pi_messages (input "msg",
                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                run pi_messages (input "help",
                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Transit¢ria de Substituiá∆o" /*l_transitoria_substituicao*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                       tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Transit¢ria de Substituiá∆o" /*l_transitoria_substituicao*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
            end.
        end.

        /* ** Utilizada para Armezenar os C¢digos de Representantes ***/
        assign v_dsl_message = "" /*l_*/ .

        /* Deletar dados da tt_repres_tit_acr_comis_ext*/
        for each tt_repres_tit_acr_comis_ext:
           delete tt_repres_tit_acr_comis_ext.
        end.

        for each tt_repres_tit_acr:
            delete tt_repres_tit_acr. 
        end.


        for each item_renegoc_acr no-lock
            where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
            and   item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr: 

            find tit_acr no-lock
                where tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
                and   tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr no-error.

            /* ***
            Conferencia dos dados 'Comissao Ags Externos' dos Representantes.
            ****/

            if avail tit_acr then do:
                for each repres_tit_acr  no-lock
                where repres_tit_acr.cod_estab      = tit_acr.cod_estab
                and   repres_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:

                    find first tt_repres_tit_acr_comis_ext 
                    where tt_repres_tit_acr_comis_ext.tta_cdn_repres = repres_tit_acr.cdn_repres no-lock no-error.

                    if avail tt_repres_tit_acr_comis_ext then do:                       

                        assign v_des_comis = "".

                        &if '{&emsfin_version}' >= '5.06' &then
                            if  tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> repres_tit_acr.ind_tip_comis_ext 
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> "Nenhum" /*l_nenhum*/  
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> "" 
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> ? then
                                assign v_des_comis = "Tipo Comiss∆o Externa" /*l_tipo_comissao_ext*/ .
                            else
                            if tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis <> repres_tit_acr.ind_liber_pagto_comis then
                                assign v_des_comis = "Liberaá∆o Pagto Comiss∆o" /*l_liber_pagto_comis*/ .
                            else
                            if tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext <> repres_tit_acr.ind_sit_comis_ext then
                                assign v_des_comis = "Situaá∆o Comiss∆o Externa" /*l_sit_comis_ext*/ .
                        &else
                            if  GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10)) <> ""
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10))
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> "Nenhum" /*l_nenhum*/  
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> "" 
                            and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> ? then
                                assign v_des_comis = "Tipo Comiss∆o Externa" /*l_tipo_comissao_ext*/ .
                            else
                            if tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis <> GetEntryField(3,repres_tit_acr.cod_livre_1,chr(10)) then
                                assign v_des_comis = "Liberaá∆o Pagto Comiss∆o" /*l_liber_pagto_comis*/ .
                            else
                            if tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext <> GetEntryField(4,repres_tit_acr.cod_livre_1,chr(10)) then
                                assign v_des_comis = "Situaá∆o Comiss∆o Externa" /*l_sit_comis_ext*/ .
                        &endif

                        if v_des_comis <> "" then do:
                            create tt_log_erros_atualiz.
                            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                   tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                   tt_log_erros_atualiz.ttv_num_mensagem    = 17908
                                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                   tt_log_erros_atualiz.ttv_num_relacto     = 0.

                            run pi_messages (input 'msg',
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                               string(tt_repres_tit_acr_comis_ext.tta_cdn_repres),
                                                               v_des_comis)).

                            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value.
                            assign tt_log_erros_atualiz.ttv_des_msg_erro = substitute(tt_log_erros_atualiz.ttv_des_msg_erro,string(tt_repres_tit_acr_comis_ext.tta_cdn_repres),string(v_des_comis)).

                            run pi_messages (input 'help',
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value.
                        end.                
                    end.
                    else do:
                        create tt_repres_tit_acr_comis_ext.
                        assign tt_repres_tit_acr_comis_ext.tta_cdn_repres = repres_tit_acr.cdn_repres.                       
                        &if '{&emsfin_version}' >= '5.06' &then
                            assign tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext     = repres_tit_acr.ind_tip_comis_ext
                                   tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis = repres_tit_acr.ind_liber_pagto_comis
                                   tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext     = repres_tit_acr.ind_sit_comis_ext.
                        &else
                            assign tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext     = GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10))
                                   tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis = GetEntryField(3,repres_tit_acr.cod_livre_1,chr(10))
                                   tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext     = GetEntryField(4,repres_tit_acr.cod_livre_1,chr(10)).
                        &endif                                  
                    end.           
                end.                   
            end.

            /* ** VERIFICA SE N«O EXISTEM MOVIMENTOS POSTERIORES AO DA DATA DE TRANSAÄ«O INFORMADA ***/
            find first movto_tit_acr no-lock
                     where movto_tit_acr.cod_estab             = tit_acr.cod_estab
                     and movto_tit_acr.num_id_tit_acr          = tit_acr.num_id_tit_acr
                     and movto_tit_acr.dat_transacao           > renegoc_acr.dat_transacao
                     and movto_tit_acr.log_ctbz_aprop_ctbl     = yes
                     and movto_tit_acr.log_movto_estordo       = no 
                     and not movto_tit_acr.ind_trans_acr begins "Estorno" /*l_estorno*/  use-index mvtttcr_id no-error.

            if  avail movto_tit_acr then
                assign v_log_dat_trans = yes.

            find b_espec_docto_renegoc no-lock
                where b_espec_docto_renegoc.cod_espec_docto = renegoc_acr.cod_espec_docto no-error.

            find espec_docto no-lock
                where espec_docto.cod_espec_docto = tit_acr.cod_espec_docto no-error.

            find espec_docto_financ_acr no-lock
                where espec_docto_financ_acr.cod_espec_docto = tit_acr.cod_espec_docto no-error.

            if  espec_docto_financ_acr.log_ctbz_aprop_ctbl
            and b_espec_docto_renegoc.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/  then do:
                run pi_criticar_atualizacao_renegoc_subst_acr_3 /*pi_criticar_atualizacao_renegoc_subst_acr_3*/.

                if tit_acr.log_tit_acr_cobr_bcia = yes then do:
                    find first portador no-lock
                        where portador.cod_portador = tit_acr.cod_portador no-error.
                    if avail portador then do:
                        find first banco no-lock
                             where banco.cod_banco = portador.cod_banco no-error.
                        if  avail banco then do:
                            find first ocor_bcia_bco no-lock
                                where  ocor_bcia_bco.cod_banco               = banco.cod_banco
                                and    ocor_bcia_bco.cod_modul_dtsul         = "ACR" /*l_acr*/ 
                                and    ocor_bcia_bco.ind_ocor_bcia_remes_ret = "Remessa" /*l_Remessa*/ 
                                and    ocor_bcia_bco.ind_tip_ocor_bcia       = "Pedido de Baixa" /*l_Pedido_de_Baixa*/ 
                                no-error.
                            if  not avail ocor_bcia_bco
                            then do:
                                create tt_log_erros_atualiz.
                                assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                       tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                       tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                       tt_log_erros_atualiz.ttv_num_mensagem    = 7514
                                       tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                       tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                run pi_messages (input "msg",
                                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                run pi_messages (input "help",
                                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, "Pedido de Baixa" /*l_Pedido_de_Baixa*/ , banco.cod_banco).
                            end. 
                        end.       
                    end.
                end.
                /* --- Validaá∆o para Transferància de Estabelecimento ---*/
                if  renegoc_acr.cod_estab <> tit_acr.cod_estab then do:


                    /* Begin_Include: i_pi_criticar_atualizacao_renegoc_subst_acr */
                    for each b_val_tit_acr no-lock
                       where b_val_tit_acr.cod_estab        = tit_acr.cod_estab
                         and b_val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
                         and b_val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
                    break by b_val_tit_acr.cod_unid_negoc:
                       if  last-of (b_val_tit_acr.cod_unid_negoc)
                       then do:

                           run pi_validar_unid_negoc (Input renegoc_acr.cod_estab,
                                                      Input b_val_tit_acr.cod_unid_negoc,
                                                      Input renegoc_acr.dat_transacao,
                                                      output v_cod_return_error) /*pi_validar_unid_negoc*/.
                           if  v_cod_return_error <> "" /*l_*/ 
                           then do:

                               case v_cod_return_error:
                                   when "Estabelecimento" /*l_estabelecimento*/  then do:

                                      create tt_log_erros_atualiz.
                                      assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                             tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                             tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                             tt_log_erros_atualiz.ttv_num_mensagem    = 686
                                             tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                             tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                      run pi_messages (input "msg",
                                                       input tt_log_erros_atualiz.ttv_num_mensagem,
                                                       input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                      assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                      run pi_messages (input "help",
                                                       input tt_log_erros_atualiz.ttv_num_mensagem,
                                                       input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                      assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                      assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, val_tit_acr.cod_unid_negoc, tit_acr.cod_estab).
                                   end.
                                   when "Data" /*l_data*/  then do:

                                       create tt_log_erros_atualiz.
                                       assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                              tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                              tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                              tt_log_erros_atualiz.ttv_num_mensagem    = 617
                                              tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                              tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                       run pi_messages (input "msg",
                                                        input tt_log_erros_atualiz.ttv_num_mensagem,
                                                        input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                       assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                       run pi_messages (input "help",
                                                        input tt_log_erros_atualiz.ttv_num_mensagem,
                                                        input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                       assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                       assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, b_val_tit_acr.cod_unid_negoc).
                                   end.
                                   when "Usu†rio" /*l_usuario*/  then do:

                                       create tt_log_erros_atualiz.
                                       assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                              tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                              tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                              tt_log_erros_atualiz.ttv_num_mensagem    = 683
                                              tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                              tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                       run pi_messages (input "msg",
                                                        input tt_log_erros_atualiz.ttv_num_mensagem,
                                                        input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                       assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                       run pi_messages (input "help",
                                                        input tt_log_erros_atualiz.ttv_num_mensagem,
                                                        input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                       assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                       assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, b_val_tit_acr.cod_unid_negoc).
                                   end.
                               end.
                               assign v_log_erro = yes.
                           end /* if */.
                           if  v_log_erro = no
                           then do:

                               run pi_validar_unid_negoc (Input tit_acr.cod_estab,
                                                          Input b_val_tit_acr.cod_unid_negoc,
                                                          Input renegoc_acr.dat_transacao,
                                                          output v_cod_return_error) /*pi_validar_unid_negoc*/.

                               if  v_cod_return_error <> "" /*l_*/ 
                               then do:

                                   case v_cod_return_error:
                                       when "Estabelecimento" /*l_estabelecimento*/  then do:

                                          create tt_log_erros_atualiz.
                                          assign tt_log_erros_atualiz.tta_cod_estab       = tit_acr.cod_estab
                                                 tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                                 tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                                 tt_log_erros_atualiz.ttv_num_mensagem    = 686
                                                 tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                                 tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                          run pi_messages (input "msg",
                                                           input tt_log_erros_atualiz.ttv_num_mensagem,
                                                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                          assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                          run pi_messages (input "help",
                                                           input tt_log_erros_atualiz.ttv_num_mensagem,
                                                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, val_tit_acr.cod_unid_negoc, tit_acr.cod_estab).
                                       end.
                                       when "Data" /*l_data*/  then do:

                                           create tt_log_erros_atualiz.
                                           assign tt_log_erros_atualiz.tta_cod_estab       = tit_acr.cod_estab
                                                  tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                                  tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                                  tt_log_erros_atualiz.ttv_num_mensagem    = 617
                                                  tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                                  tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                           run pi_messages (input "msg",
                                                            input tt_log_erros_atualiz.ttv_num_mensagem,
                                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                           assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                           run pi_messages (input "help",
                                                            input tt_log_erros_atualiz.ttv_num_mensagem,
                                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                           assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                           assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, b_val_tit_acr.cod_unid_negoc).
                                       end.
                                       when "Usu†rio" /*l_usuario*/  then do:

                                           create tt_log_erros_atualiz.
                                           assign tt_log_erros_atualiz.tta_cod_estab       = tit_acr.cod_estab
                                                  tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                                  tt_log_erros_atualiz.tta_num_seq_refer   = 0
                                                  tt_log_erros_atualiz.ttv_num_mensagem    = 683
                                                  tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                                  tt_log_erros_atualiz.ttv_num_relacto     = 0.
                                           run pi_messages (input "msg",
                                                            input tt_log_erros_atualiz.ttv_num_mensagem,
                                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                           assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                           run pi_messages (input "help",
                                                            input tt_log_erros_atualiz.ttv_num_mensagem,
                                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                           assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                                           assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, b_val_tit_acr.cod_unid_negoc).
                                       end.
                                   end /* case error_block */.
                               end /* if */.
                           end /* if */.
                       end /* if */.
                    end.
                    /* End_Include: i_pi_criticar_atualizacao_renegoc_subst_acr */


                    find first cta_grp_clien no-lock 
                        where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                        and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
                        and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                        and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                        and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
                        and   cta_grp_clien.ind_finalid_ctbl    = "Transit¢ria de Transferància" /*l_transitoria_transferencia*/ 
                        and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                        and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
                    if  not avail cta_grp_clien then do:
                        find first cta_grp_clien no-lock 
                            where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                            and   cta_grp_clien.cod_espec_docto     = ""
                            and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                            and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                            and   cta_grp_clien.ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                            and   cta_grp_clien.ind_finalid_ctbl    = "Transit¢ria de Transferància" /*l_transitoria_transferencia*/ 
                            and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                            and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
                    end.
                    if  not avail cta_grp_clien
                    &if '{&emsfin_version}' >= '5.06' &then
                    and not renegoc_acr.log_bxa_estab_tit_acr
                    &else
                        &if '{&emsfin_version}' >= '5.04' &then
                        and not renegoc_acr.log_livre_2
                        &endif
                    &endif
                    then do:
                        create tt_log_erros_atualiz.
                        assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                               tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                               tt_log_erros_atualiz.tta_num_seq_refer   = 0
                               tt_log_erros_atualiz.ttv_num_mensagem    = 53
                               tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                               tt_log_erros_atualiz.ttv_num_relacto     = 0.
                        run pi_messages (input "msg",
                                         input tt_log_erros_atualiz.ttv_num_mensagem,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                        assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                        run pi_messages (input "help",
                                         input tt_log_erros_atualiz.ttv_num_mensagem,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                        assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Transit¢ria de Transferància" /*l_transitoria_transferencia*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                               tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Transit¢ria de Transferància" /*l_transitoria_transferencia*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
                    end.
                end.
            end.

            if can-find (first repres_tit_acr
                         where repres_tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
                         and   repres_tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr)
            then do:
                find first param_estab_comis no-lock
                    where param_estab_comis.cod_empresa    =  renegoc_acr.cod_empresa
                    and   param_estab_comis.dat_inic_valid <= renegoc_acr.dat_transacao
                    and   param_estab_comis.dat_fim_valid  >= renegoc_acr.dat_transacao
                    &IF DEFINED(BF_FIN_COMIS_REPRES) &THEN
                        &if '{&emsfin_version}' >= '5.08' &then
                        and   param_estab_comis.log_reg_ativ = yes
                        &endif
                    &ENDIF
                    no-error.
                if avail param_estab_comis then do:
                    &if '{&emsfin_version}' >= "5.02" &then
                        if not can-find(first finalid_econ
                            where finalid_econ.cod_finalid_econ = param_estab_comis.cod_finalid_econ)
                        then do:
                            create tt_log_erros_atualiz.
                            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                   tt_log_erros_atualiz.ttv_num_mensagem    = 8711
                                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
                            run pi_messages (input "msg",
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                            run pi_messages (input "help",
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                            assign tt_log_erros_atualiz.ttv_des_msg_erro = substitute(tt_log_erros_atualiz.ttv_des_msg_erro,param_estab_comis.cod_comis_vda_estab).
                            return.
                        end.
                    &else
                        if not can-find(first finalid_econ
                            where finalid_econ.cod_finalid_econ = param_estab_comis.cod_livre_1)
                        then do:
                            create tt_log_erros_atualiz.
                            assign tt_log_erros_atualiz.tta_cod_estab 	= renegoc_acr.cod_estab
                                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                                   tt_log_erros_atualiz.ttv_num_mensagem    = 8711
                                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
                            run pi_messages (input "msg",
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                            run pi_messages (input "help",
                                             input tt_log_erros_atualiz.ttv_num_mensagem,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                            assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro,param_estab_comis.cod_comis_vda_estab).
                            return.
                        end.            
                    &endif
                    /* ** Funá∆o de Controle de Comiss∆o na Renegociaá∆o ***/
                    if  v_log_func_control_comis_renegoc then do:
                        &IF DEFINED(BF_FIN_CONT_COMIS_REN) &THEN 
                        if param_estab_comis.log_mantem_perc_comis then do:
                        &ELSE
                        if param_estab_comis.num_livre_1 = 1 then do:
                        &ENDIF 
                            for each  repres_tit_acr
                               where repres_tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
                               and   repres_tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr
                               no-lock:                           
                               find first tt_repres_tit_acr
                                    where tt_repres_tit_acr.cdn_repres = repres_tit_acr.cdn_repres
                                    no-error.
                               if not avail tt_repres_tit_acr then do:
                                  create tt_repres_tit_acr.
                                  assign tt_repres_tit_acr.cdn_repres             = repres_tit_acr.cdn_repres
                                         tt_repres_tit_acr.val_perc_comis_repres  = repres_tit_acr.val_perc_comis_repres.
                               end.
                               else do:
                                  /* *** Caso seja realizado o controle de comiss∆o na Renegociaá∆o, n∆o poder† haver um mesmo representante 
                                        em dois t°tulos como percentuais diferentes ****/
                                  if tt_repres_tit_acr.val_perc_comis_repres  <> repres_tit_acr.val_perc_comis_repres then do:
                                     if v_dsl_message = "" /*l_*/  then 
                                        assign v_dsl_message = string(repres_tit_acr.cdn_repres).
                                     else
                                        assign v_dsl_message = v_dsl_message + ', ' + string(repres_tit_acr.cdn_repres).
                                  end. 
                               end.
                           end.
                        end. /* ** if param_estab_comis ***/
                    end.
                end.
                else do: 
                    create tt_log_erros_atualiz.
                    assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                           tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                           tt_log_erros_atualiz.ttv_num_mensagem    = 340
                           tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                           tt_log_erros_atualiz.ttv_num_relacto     = 0.
                    run pi_messages (input "msg",
                                     input tt_log_erros_atualiz.ttv_num_mensagem,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                    run pi_messages (input "help",
                                     input tt_log_erros_atualiz.ttv_num_mensagem,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,renegoc_acr.cod_empresa,renegoc_acr.dat_transacao).
                    return.
                end.
            end.    
        end.

        /* ** Funá∆o de Controle de Comiss∆o na Renegociaá∆o ***/
        /* *** Caso seja realizado o controle de comiss∆o na Renegociaá∆o, n∆o poder† haver um mesmo representante 
              em dois t°tulos como percentuais diferentes ****/
        if  v_log_func_control_comis_renegoc
        and v_dsl_message <> "" /*l_*/  then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                   tt_log_erros_atualiz.tta_num_seq_refer   = 0
                   tt_log_erros_atualiz.ttv_num_mensagem    = 14128
                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
            run pi_messages (input "msg",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            run pi_messages (input "help",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,v_dsl_message).
            return.
        end.
        if v_log_dat_trans then do:
           create tt_log_erros_atualiz.
           assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                  tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                  tt_log_erros_atualiz.tta_num_seq_refer   = 0
                  tt_log_erros_atualiz.ttv_num_mensagem    = 8991
                  tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                  tt_log_erros_atualiz.ttv_num_relacto     = 0.
           run pi_messages (input "msg",
                            input tt_log_erros_atualiz.ttv_num_mensagem,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
           assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
           run pi_messages (input "help",
                            input tt_log_erros_atualiz.ttv_num_mensagem,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
           assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
        end.   
    end.

    run pi_criticar_atualizacao_renegoc_subst_acr_2 /*pi_criticar_atualizacao_renegoc_subst_acr_2*/.

    return "OK" /*l_ok*/ .

END PROCEDURE. /* pi_criticar_atualizacao_renegoc_subst_acr */
/*****************************************************************************
** Procedure Interna.....: pi_criticar_atualizacao_renegoc_subst_acr_2
** Descricao.............: pi_criticar_atualizacao_renegoc_subst_acr_2
** Criado por............: Claudia
** Criado em.............: 13/07/1998 18:49:37
** Alterado por..........: fut35058
** Alterado em...........: 25/10/2005 12:56:41
*****************************************************************************/
PROCEDURE pi_criticar_atualizacao_renegoc_subst_acr_2:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsuni_version}" >= "5.00" &then
    def buffer b_espec_docto_renegoc
        for ems5.espec_docto.
    &endif


    /*************************** Buffer Definition End **************************/

    find first item_lote_impl_tit_acr no-lock
        where item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
        and   item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
        no-error.
    if  not avail item_lote_impl_tit_acr then do:
        create tt_log_erros_atualiz.
        assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
               tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
               tt_log_erros_atualiz.tta_num_seq_refer   = 0
               tt_log_erros_atualiz.ttv_num_mensagem    = 5773
               tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
               tt_log_erros_atualiz.ttv_num_relacto     = 0.
        run pi_messages (input "msg",
                         input tt_log_erros_atualiz.ttv_num_mensagem,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
        run pi_messages (input "help",
                         input tt_log_erros_atualiz.ttv_num_mensagem,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
    end.
    else do:
        find b_espec_docto_renegoc no-lock
            where b_espec_docto_renegoc.cod_espec_docto = renegoc_acr.cod_espec_docto no-error.

        find espec_docto_financ_acr no-lock
            where espec_docto_financ_acr.cod_espec_docto = renegoc_acr.cod_espec_docto no-error.

        if  espec_docto_financ_acr.log_ctbz_aprop_ctbl
        and b_espec_docto_renegoc.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/  then do:

            find first cta_grp_clien no-lock
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = renegoc_acr.cod_espec_docto
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
                and   cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
            if  not avail cta_grp_clien then do:
                find first cta_grp_clien
                    where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                    and   cta_grp_clien.cod_espec_docto     = ""
                    and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                    and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                    and   cta_grp_clien.ind_tip_espec_docto = b_espec_docto_renegoc.ind_tip_espec_docto
                    and   cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/ 
                    and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                    and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao
                    no-lock no-error.
            end.

            if  not avail cta_grp_clien then do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                       tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                       tt_log_erros_atualiz.tta_num_seq_refer   = 0
                       tt_log_erros_atualiz.ttv_num_mensagem    = 53
                       tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                       tt_log_erros_atualiz.ttv_num_relacto     = 0.
                run pi_messages (input "msg",
                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                run pi_messages (input "help",
                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
                assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, renegoc_acr.cod_espec_docto, cliente.cod_grp_clien, "Saldo" /*l_saldo*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                       tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, renegoc_acr.cod_espec_docto, cliente.cod_grp_clien, "Saldo" /*l_saldo*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
            end.
        end.
    end.     
END PROCEDURE. /* pi_criticar_atualizacao_renegoc_subst_acr_2 */
/*****************************************************************************
** Procedure Interna.....: pi_criticar_atualizacao_renegoc_subst_acr_3
** Descricao.............: pi_criticar_atualizacao_renegoc_subst_acr_3
** Criado por............: Klug
** Criado em.............: 18/11/1998 15:44:35
** Alterado por..........: fut35058
** Alterado em...........: 30/09/2005 08:43:47
*****************************************************************************/
PROCEDURE pi_criticar_atualizacao_renegoc_subst_acr_3:

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    if  tit_acr.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/  then do:
        if  tit_acr.ind_sit_tit_acr = "Perdas Dedut" /*l_perdas_dedut*/ 
        then do:
            find cta_grp_clien no-lock
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
                and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_finalid_ctbl    = "Perdas Dedut°veis" /*l_perdas_dedutiveis*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
            if  not avail cta_grp_clien
            then do:
                find cta_grp_clien no-lock
                    where cta_grp_clien.cod_empresa       = v_cod_empres_usuar
                    and cta_grp_clien.cod_espec_docto     = ""
                    and cta_grp_clien.ind_tip_espec_docto = espec_docto.ind_tip_espec_docto
                    and cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                    and cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                    and cta_grp_clien.ind_finalid_ctbl    = "Perdas Dedut°veis" /*l_perdas_dedutiveis*/ 
                    and cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                    and cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
            end /* if */.
        end /* if */.
        else do:
            find first cta_grp_clien no-lock
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
                and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
            if  not avail cta_grp_clien then do:
                find first cta_grp_clien no-lock
                    where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                    and   cta_grp_clien.cod_espec_docto     = ""
                    and   cta_grp_clien.ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                    and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                    and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                    and   cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/ 
                    and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                    and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
            end.
        end /* else */.

        if  not avail cta_grp_clien then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                   tt_log_erros_atualiz.tta_num_seq_refer   = 0
                   tt_log_erros_atualiz.ttv_num_mensagem    = 53
                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
            run pi_messages (input "msg",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            run pi_messages (input "help",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Saldo" /*l_saldo*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                   tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Saldo" /*l_saldo*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
        end.
    end.

    if  tit_acr.ind_tip_espec_docto = "Aviso DÇbito" /*l_aviso_debito*/ 
    or  renegoc_acr.val_tit_acr < renegoc_acr.val_renegoc_cobr_acr then do:
        find first cta_grp_clien no-lock
            where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
            and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
            and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
            and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
            and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
            and   cta_grp_clien.ind_finalid_ctbl    = "Juros" /*l_juros*/ 
            and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
            and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
        if  not avail cta_grp_clien then do:
            find first cta_grp_clien no-lock
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = ""
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                and   cta_grp_clien.ind_finalid_ctbl    = "Juros" /*l_juros*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
        end.

        if  not avail cta_grp_clien then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                   tt_log_erros_atualiz.tta_num_seq_refer   = 0
                   tt_log_erros_atualiz.ttv_num_mensagem    = 53
                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
            run pi_messages (input "msg",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            run pi_messages (input "help",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Juros" /*l_juros*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                   tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Juros" /*l_juros*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
        end.
    end.

    if  renegoc_acr.val_tit_acr > renegoc_acr.val_renegoc_cobr_acr then do:
        find first cta_grp_clien no-lock
            where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
            and   cta_grp_clien.cod_espec_docto     = tit_acr.cod_espec_docto
            and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
            and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
            and   cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/ 
            and   cta_grp_clien.ind_finalid_ctbl    = "Desconto" /*l_desconto*/ 
            and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
            and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
        if  not avail cta_grp_clien then do:
            find first cta_grp_clien no-lock
                where cta_grp_clien.cod_empresa         = v_cod_empres_usuar
                and   cta_grp_clien.cod_espec_docto     = ""
                and   cta_grp_clien.cod_grp_clien       = cliente.cod_grp_clien
                and   cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ
                and   cta_grp_clien.ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                and   cta_grp_clien.ind_finalid_ctbl    = "Desconto" /*l_desconto*/ 
                and   cta_grp_clien.dat_inic_valid     <= renegoc_acr.dat_transacao
                and   cta_grp_clien.dat_fim_valid      >= renegoc_acr.dat_transacao no-error.
        end.

        if  not avail cta_grp_clien then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab       = renegoc_acr.cod_estab
                   tt_log_erros_atualiz.tta_cod_refer       = string(renegoc_acr.num_renegoc_cobr_acr)
                   tt_log_erros_atualiz.tta_num_seq_refer   = 0
                   tt_log_erros_atualiz.ttv_num_mensagem    = 53
                   tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                   tt_log_erros_atualiz.ttv_num_relacto     = 0.
            run pi_messages (input "msg",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            run pi_messages (input "help",
                             input tt_log_erros_atualiz.ttv_num_mensagem,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_tt_log_erros_atualiz.ttv_num_mensagem*/.
            assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Desconto" /*l_desconto*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao)
                   tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, v_cod_empres_usuar, tit_acr.cod_espec_docto, cliente.cod_grp_clien, "Desconto" /*l_desconto*/ , v_cod_finalid_econ, renegoc_acr.dat_transacao).
        end.
    end.

END PROCEDURE. /* pi_criticar_atualizacao_renegoc_subst_acr_3 */
/*****************************************************************************
** Procedure Interna.....: pi_controlar_renegoc_acr_subst_atualiza
** Descricao.............: pi_controlar_renegoc_acr_subst_atualiza
** Criado por............: Rafael
** Criado em.............: 25/06/1998 07:54:10
** Alterado por..........: Barth
** Alterado em...........: 09/08/1999 09:10:34
*****************************************************************************/
PROCEDURE pi_controlar_renegoc_acr_subst_atualiza:

    for each tt_exec_rpc:
        delete tt_exec_rpc.
    end.

    create  tt_exec_rpc.
    assign  tt_exec_rpc.ttv_cod_aplicat_dtsul_corren  = v_cod_aplicat_dtsul_corren 
            tt_exec_rpc.ttv_cod_ccusto_corren         = v_cod_ccusto_corren
            tt_exec_rpc.ttv_cod_dwb_user              = v_cod_dwb_user
            tt_exec_rpc.ttv_cod_empres_usuar          = v_cod_empres_usuar
            tt_exec_rpc.ttv_cod_estab_usuar           = v_cod_estab_usuar 
            tt_exec_rpc.ttv_cod_funcao_negoc_empres   = v_cod_funcao_negoc_empres
            tt_exec_rpc.ttv_cod_grp_usuar_lst         = v_cod_grp_usuar_lst
            tt_exec_rpc.ttv_cod_idiom_usuar           = v_cod_idiom_usuar
            tt_exec_rpc.ttv_cod_modul_dtsul_corren    = v_cod_modul_dtsul_corren
            tt_exec_rpc.ttv_cod_modul_dtsul_empres    = v_cod_modul_dtsul_empres
            tt_exec_rpc.ttv_cod_pais_empres_usuar     = v_cod_pais_empres_usuar
            tt_exec_rpc.ttv_cod_plano_ccusto_corren   = v_cod_plano_ccusto_corren
            tt_exec_rpc.ttv_cod_unid_negoc_usuar      = v_cod_unid_negoc_usuar
            tt_exec_rpc.ttv_cod_usuar_corren          = v_cod_usuar_corren
            tt_exec_rpc.ttv_cod_usuar_corren_criptog  = v_cod_usuar_corren_criptog
            tt_exec_rpc.ttv_num_ped_exec_corren       = v_num_ped_exec_corren 
            tt_exec_rpc.ttv_cod_livre                 = "".

    assign v_log_method = session:set-wait-state('general')
           v_rec_renegoc_acr = recid(renegoc_acr).           

    if  "api_integr_acr_renegoc_3":U = "bas_renegoc_acr_substituicao":U then do:

        /* Begin_Include: i_exec_program_rpc2 */
        &if '{&emsbas_version}' > '1.00' &then

           /* Begin_Include: i_exec_initialize_rpc */
           if  not valid-handle(v_wgh_servid_rpc)
           or v_wgh_servid_rpc:type <> 'procedure':U
           or v_wgh_servid_rpc:file-name <> 'prgtec/btb/btb008za.py':U
           then do:
               run prgtec/btb/btb008za.py persistent set v_wgh_servid_rpc (input 1).
           end /* if */.

           run pi_connect in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U, "", yes).
           /* End_Include: i_exec_initialize_rpc */

           if  rpc_exec("api_controlar_renegoc_acr_subst_atz":U)
           then do:

               /* Begin_Include: i_exec_dispatch_rpc */
               rpc_exec_set("api_controlar_renegoc_acr_subst_atz":U,yes).
               rpc_block:
               repeat while rpc_exec("api_controlar_renegoc_acr_subst_atz":U) on stop undo rpc_block, retry rpc_block:
                   if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) = ?
                   then do: 
                      leave rpc_block.        
                   end /* if */.
                   if  retry
                   then do:
                       run pi_status_error in v_wgh_servid_rpc.
                       next rpc_block.
                   end /* if */.
                   if  rpc_tip_exec("api_controlar_renegoc_acr_subst_atz":U)
                   then do:
                       run pi_check_server in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U).
                       if  return-value = 'yes'
                       then do:
                           if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) <> ?
                           then do:
                               if  'input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz' = '""'
                               then do:
                                   &if '""' = '""' &then
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct no-error.
                                   &else
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct no-error.
                                   &endif
                               end /* if */.
                               else do:
                                   &if '""' = '""' &then
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                                   &else
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                                   &endif
                               end /* else */.
                           end /* if */.    
                       end /* if */.
                       else do:
                           next rpc_block.
                       end /* else */.
                   end /* if */.
                   else do:
                       if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) <> ?
                       then do: 
                           if  'input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz' = '""'
                           then do:
                               &if '""' = '""' &then 
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) no-error.
                               &else
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" no-error.
                               &endif
                           end /* if */.
                           else do:
                               &if '""' = '""' &then 
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                               &else
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                               &endif
                           end /* else */.
                       end /* if */.        
                   end /* else */.

                   run pi_status_error in v_wgh_servid_rpc.
               end /* repeat rpc_block */.
               /* End_Include: i_exec_dispatch_rpc */

           end /* if */.

           /* Begin_Include: i_exec_destroy_rpc */
           run pi_destroy_rpc in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U).

           &if '""' <> '""' &then
               if  valid-handle("") then
                   delete procedure "".
           &endif

           if  valid-handle(v_wgh_servid_rpc) then
               delete procedure v_wgh_servid_rpc.

           /* End_Include: i_exec_destroy_rpc */

        &endif.



        /* End_Include: i_exec_destroy_rpc */

    end.
    else do:

        /* Begin_Include: i_exec_program_rpc2 */
        &if '{&emsbas_version}' > '1.00' &then

           /* Begin_Include: i_exec_initialize_rpc */
           if  not valid-handle(v_wgh_servid_rpc)
           or v_wgh_servid_rpc:type <> 'procedure':U
           or v_wgh_servid_rpc:file-name <> 'prgtec/btb/btb008za.py':U
           then do:
               run prgtec/btb/btb008za.py persistent set v_wgh_servid_rpc (input 1).
           end /* if */.

           run pi_connect in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U, "", no).
           /* End_Include: i_exec_initialize_rpc */

           if  rpc_exec("api_controlar_renegoc_acr_subst_atz":U)
           then do:

               /* Begin_Include: i_exec_dispatch_rpc */
               rpc_exec_set("api_controlar_renegoc_acr_subst_atz":U,yes).
               rpc_block:
               repeat while rpc_exec("api_controlar_renegoc_acr_subst_atz":U) on stop undo rpc_block, retry rpc_block:
                   if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) = ?
                   then do: 
                      leave rpc_block.        
                   end /* if */.
                   if  retry
                   then do:
                       run pi_status_error in v_wgh_servid_rpc.
                       next rpc_block.
                   end /* if */.
                   if  rpc_tip_exec("api_controlar_renegoc_acr_subst_atz":U)
                   then do:
                       run pi_check_server in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U).
                       if  return-value = 'yes'
                       then do:
                           if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) <> ?
                           then do:
                               if  'input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz' = '""'
                               then do:
                                   &if '""' = '""' &then
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct no-error.
                                   &else
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct no-error.
                                   &endif
                               end /* if */.
                               else do:
                                   &if '""' = '""' &then
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                                   &else
                                       run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" on rpc_server("api_controlar_renegoc_acr_subst_atz":U) transaction distinct (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                                   &endif
                               end /* else */.
                           end /* if */.    
                       end /* if */.
                       else do:
                           next rpc_block.
                       end /* else */.
                   end /* if */.
                   else do:
                       if  rpc_program("api_controlar_renegoc_acr_subst_atz":U) <> ?
                       then do: 
                           if  'input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz' = '""'
                           then do:
                               &if '""' = '""' &then 
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) no-error.
                               &else
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" no-error.
                               &endif
                           end /* if */.
                           else do:
                               &if '""' = '""' &then 
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                               &else
                                   run value(rpc_program("api_controlar_renegoc_acr_subst_atz":U)) persistent set "" (input 1, input table tt_exec_rpc, input v_rec_renegoc_acr, output table tt_log_erros_atualiz) no-error.
                               &endif
                           end /* else */.
                       end /* if */.        
                   end /* else */.

                   run pi_status_error in v_wgh_servid_rpc.
               end /* repeat rpc_block */.
               /* End_Include: i_exec_dispatch_rpc */

           end /* if */.

           /* Begin_Include: i_exec_destroy_rpc */
           run pi_destroy_rpc in v_wgh_servid_rpc ("api_controlar_renegoc_acr_subst_atz":U).

           &if '""' <> '""' &then
               if  valid-handle("") then
                   delete procedure "".
           &endif

           if  valid-handle(v_wgh_servid_rpc) then
               delete procedure v_wgh_servid_rpc.

           /* End_Include: i_exec_destroy_rpc */

        &endif.



        /* End_Include: i_exec_destroy_rpc */

    end.

    assign v_log_method = session:set-wait-state('').           

END PROCEDURE. /* pi_controlar_renegoc_acr_subst_atualiza */
/*****************************************************************************
** Procedure Interna.....: pi_validar_unid_negoc
** Descricao.............: pi_validar_unid_negoc
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut41675_3
** Alterado em...........: 27/04/2011 10:01:17
*****************************************************************************/
PROCEDURE pi_validar_unid_negoc:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_unid_negoc
        as character
        format "x(3)"
        no-undo.
    def Input param p_dat_refer_ent
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_return                     as logical         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign p_cod_return = "".
    &IF DEFINED(BF_FIN_VALIDA_FUNCAO) = 0 &THEN
    find estabelecimento no-lock
         where estabelecimento.cod_estab = p_cod_estab /*cl_param_estab of estabelecimento*/ no-error.

    find first param_utiliz_produt no-lock
         where param_utiliz_produt.cod_empresa = estabelecimento.cod_empresa
           and param_utiliz_produt.cod_modul_dtsul = ''
           and param_utiliz_produt.cod_funcao_negoc = 'BU' /*cl_verifica_unid_negoc of param_utiliz_produt*/ no-error.
    if  avail param_utiliz_produt
    then do:
    &ENDIF
        find estab_unid_negoc no-lock
             where estab_unid_negoc.cod_estab = p_cod_estab
               and estab_unid_negoc.cod_unid_negoc = p_cod_unid_negoc /*cl_valida_unid_negoc of estab_unid_negoc*/ no-error.
        if  avail estab_unid_negoc
        then do:
            if  p_dat_refer_ent <> ? and
               (estab_unid_negoc.dat_inic_valid > p_dat_refer_ent or
                estab_unid_negoc.dat_fim_valid  < p_dat_refer_ent)
            then do:
                 assign p_cod_return = "Data" /*l_data*/ .
                 return.
            end /* if */.
            run pi_verifica_segur_unid_negoc (Input p_cod_unid_negoc,
                                              output v_log_return) /*pi_verifica_segur_unid_negoc*/.
            if v_log_return = yes 
            then do:
               assign p_cod_return = "".
               return.
            end /* if */.

            assign p_cod_return = "Usu†rio" /*l_usuario*/ .
        end /* if */.
        else do:
            assign p_cod_return = "Estabelecimento" /*l_estabelecimento*/ .
        end /* else */.
    &IF DEFINED(BF_FIN_VALIDA_FUNCAO) = 0 &THEN
    end /* if */.
    &ENDIF

END PROCEDURE. /* pi_validar_unid_negoc */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_segur_unid_negoc
** Descricao.............: pi_verifica_segur_unid_negoc
** Criado por............: Henke
** Criado em.............: 06/02/1996 13:59:16
** Alterado por..........: fut12161
** Alterado em...........: 04/09/2007 15:23:10
*****************************************************************************/
PROCEDURE pi_verifica_segur_unid_negoc:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_unid_negoc
        as character
        format "x(3)"
        no-undo.
    def output param p_log_return
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_log_return = no.
    /* default Ç n∆o ter permiss∆o */

    if  can-find(segur_unid_negoc
        where segur_unid_negoc.cod_unid_negoc = p_cod_unid_negoc
          and segur_unid_negoc.cod_grp_usuar = "*" /*l_**/ )
    then do:
        assign p_log_return = yes.
        return.
        /* tem permiss∆o*/
    end.
    FOR EACH segur_unid_negoc
        WHERE  segur_unid_negoc.cod_unid_negoc = p_cod_unid_negoc NO-LOCK.
        IF CAN-FIND(FIRST usuar_grp_usuar
                    WHERE usuar_grp_usuar.cod_grp_usuar = segur_unid_negoc.cod_grp_usuar
                    AND   usuar_grp_usuar.cod_usuario   = v_cod_usuar_corren) THEN DO:
            assign p_log_return = yes.
            return.
        END.
    END.
END PROCEDURE. /* pi_verifica_segur_unid_negoc */
/*****************************************************************************
** Procedure Interna.....: pi_verificar_sdo_tit_acr_integr
** Descricao.............: pi_verificar_sdo_tit_acr_integr
** Criado por............: bre18791
** Criado em.............: 23/08/1999 11:53:42
** Alterado por..........: fut40552
** Alterado em...........: 22/04/2008 17:59:41
*****************************************************************************/
PROCEDURE pi_verificar_sdo_tit_acr_integr:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_renegoc_acr
        for item_renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_erro
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_val_sdo_tit_acr
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        label "Valor Saldo"
        column-label "Valor Saldo"
        no-undo.


    /************************** Variable Definition End *************************/

    if tit_acr.ind_tip_cobr_acr = "Especial" /*l_especial*/  then return "next" /*l_next*/ .

    for each  b_item_renegoc_acr no-lock
        where b_item_renegoc_acr.cod_estab_tit_acr = tit_acr.cod_estab
        and   b_item_renegoc_acr.num_id_tit_acr    = tit_acr.num_id_tit_acr:
        if  can-find( first renegoc_acr no-lock
            where renegoc_acr.cod_estab            = b_item_renegoc_acr.cod_estab
            and   renegoc_acr.num_renegoc_cobr_acr = b_item_renegoc_acr.num_renegoc_cobr_acr
            and   renegoc_acr.ind_sit_renegoc_acr  = "Pendente" /*l_pendent*/ ) then
            return "next" /*l_next*/ .
    end.

    if  renegoc_acr.ind_tip_renegoc = "Substituiá∆o" /*l_substituicao*/ 
    then do:
        run pi_validar_unid_negoc_estab_dest_acr (Input tit_acr.cod_estab,
                                                  Input renegoc_acr.cod_estab,
                                                  Input tit_acr.num_id_tit_acr,
                                                  Input renegoc_acr.dat_transacao,
                                                  output v_log_erro) /*pi_validar_unid_negoc_estab_dest_acr*/.
        if  v_log_erro then
            return "next" /*l_next*/ .
    end /* if */.

    if renegoc_acr.cod_indic_econ <> tit_acr.cod_indic_econ then
       run pi_integr_acr_renegoc_erros(8911,
                                    renegoc_acr.cod_estab,
                                    renegoc_acr.num_renegoc_cobr_acr,
                                    "",
                                    tit_acr.cdn_cliente,
                                    tit_acr.cod_espec_docto,
                                    tit_acr.cod_ser_docto,
                                    tit_acr.cod_tit_acr,
                                    tit_acr.cod_parcela,
                                    "","","").

    assign v_val_sdo_tit_acr = 0.

    if  tit_acr.log_tit_acr_estordo   = no 
    and tit_acr.val_sdo_tit_acr       > 0 then do:
        find cart_bcia no-lock
            where cart_bcia.cod_cart_bcia = tit_acr.cod_cart_bcia no-error.

        if  cart_bcia.ind_tip_cart_bcia = "Portador" /*l_portador*/  
        or  cart_bcia.ind_tip_cart_bcia = "Carteira" /*l_carteira*/  
        or  cart_bcia.ind_tip_cart_bcia = "Judicial" /*l_judicial*/  
        or  cart_bcia.ind_tip_cart_bcia = "Representante" /*l_representante*/  
        or  cart_bcia.ind_tip_cart_bcia = "Cobrador" /*l_cobrador*/  
        or  cart_bcia.ind_tip_cart_bcia = "Cauá∆o" /*l_caucao*/ 
        then do:
            run pi_verificar_sdo_compr /*pi_verificar_sdo_compr*/.
            assign v_val_sdo_tit_acr        = tit_acr.val_sdo_tit_acr - v_val_tot_comprtdo
                   v_val_sdo_tit_acr_integr = v_val_sdo_tit_acr.
        end.
    end.

    if  v_val_tot_comprtdo <> 0 then do:
        run pi_integr_acr_renegoc_erros(8368,
                                        renegoc_acr.cod_estab,
                                        renegoc_acr.num_renegoc_cobr_acr,
                                        "",
                                        tit_acr.cdn_cliente,
                                        tit_acr.cod_espec_docto,
                                        tit_acr.cod_ser_docto,
                                        tit_acr.cod_tit_acr,
                                        tit_acr.cod_parcela,
                                        "","","").
        return "next" /*l_next*/ .
    end.
END PROCEDURE. /* pi_verificar_sdo_tit_acr_integr */
/*****************************************************************************
** Procedure Interna.....: pi_verificar_sdo_compr
** Descricao.............: pi_verificar_sdo_compr
** Criado por............: Claudia
** Criado em.............: 04/11/1996 16:50:37
** Alterado por..........: Marciop
** Alterado em...........: 10/06/1999 16:00:30
*****************************************************************************/
PROCEDURE pi_verificar_sdo_compr:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_abat_antecip_acr
        for abat_antecip_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_abat_prev_acr
        for abat_prev_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_liquidac_acr
        for item_lote_liquidac_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_renegoc_acr
        for item_renegoc_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_relacto_pend_tit_acr
        for relacto_pend_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_renegoc_acr
        for renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /* --- OBSERVAÄ«O: O registro corrente n∆o ser† considerado no valor do saldo comprometido ---*/

    assign v_val_tot_comprtdo = 0.
    if  tit_acr.ind_tip_espec_docto = "Previs∆o" /*l_previsao*/ 
    then do:
        calculo:
        for each b_abat_prev_acr 
            fields (cod_estab cod_espec_docto cod_ser_docto 
                    cod_tit_acr cod_parcela ind_tip_refer_acr 
                    cod_estab_refer cod_refer num_seq_refer 
                    val_abtdo_prev_orig)
            no-lock
            where b_abat_prev_acr.cod_estab       = tit_acr.cod_estab
            and   b_abat_prev_acr.cod_espec_docto = tit_acr.cod_espec_docto
            and   b_abat_prev_acr.cod_ser_docto   = tit_acr.cod_ser_docto
            and   b_abat_prev_acr.cod_tit_acr     = tit_acr.cod_tit_acr
            and   b_abat_prev_acr.cod_parcela     = tit_acr.cod_parcela:
            if (avail abat_prev_acr
            and recid(b_abat_prev_acr) <> recid(abat_prev_acr)) 
            or  not avail abat_prev_acr then do:
                if  b_abat_prev_acr.ind_tip_refer_acr = "Liquidaá∆o" /*l_liquidacao*/  then do:
                    find b_item_lote_liquidac_acr no-lock
                         where b_item_lote_liquidac_acr.cod_estab_refer = b_abat_prev_acr.cod_estab_refer
                           and b_item_lote_liquidac_acr.cod_refer = b_abat_prev_acr.cod_refer
                           and b_item_lote_liquidac_acr.num_seq_refer = b_abat_prev_acr.num_seq_refer
                          no-error.
                    if  avail b_item_lote_liquidac_acr
                    and b_item_lote_liquidac_acr.ind_sit_item_lote_liquidac <> "Estornado" /*l_estornado*/ 
                    and b_item_lote_liquidac_acr.ind_sit_item_lote_liquidac <> "Baixado" /*l_baixado*/  then
                        assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_abat_prev_acr.val_abtdo_prev_orig.
                end.
                else
                    assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_abat_prev_acr.val_abtdo_prev_orig.
            end.
        end /* for calculo */.
    end /* if */.
    else do:
        if  tit_acr.ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
        then do:
            calculo:
            for each b_abat_antecip_acr 
                fields (cod_estab cod_espec_docto cod_ser_docto
                        cod_tit_acr cod_parcela ind_tip_refer_acr
                        cod_estab_refer cod_refer num_seq_refer
                        val_abtdo_antecip_orig)
                no-lock
                where b_abat_antecip_acr.cod_estab       = tit_acr.cod_estab
                and   b_abat_antecip_acr.cod_espec_docto = tit_acr.cod_espec_docto
                and   b_abat_antecip_acr.cod_ser_docto   = tit_acr.cod_ser_docto
                and   b_abat_antecip_acr.cod_tit_acr     = tit_acr.cod_tit_acr
                and   b_abat_antecip_acr.cod_parcela     = tit_acr.cod_parcela:
                if  (avail abat_antecip_acr
                and recid(b_abat_antecip_acr) <> recid(abat_antecip_acr))
                or  not avail abat_antecip_acr then do:
                    if  b_abat_antecip_acr.ind_tip_refer_acr = "Liquidaá∆o" /*l_liquidacao*/  then do:
                        find b_item_lote_liquidac_acr no-lock
                             where b_item_lote_liquidac_acr.cod_estab_refer = b_abat_antecip_acr.cod_estab_refer
                               and b_item_lote_liquidac_acr.cod_refer = b_abat_antecip_acr.cod_refer
                               and b_item_lote_liquidac_acr.num_seq_refer = b_abat_antecip_acr.num_seq_refer
                              no-error.
                        if  avail b_item_lote_liquidac_acr
                        and b_item_lote_liquidac_acr.ind_sit_item_lote_liquidac <> "Estornado" /*l_estornado*/ 
                        and b_item_lote_liquidac_acr.ind_sit_item_lote_liquidac <> "Baixado" /*l_baixado*/  then
                            assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_abat_antecip_acr.val_abtdo_antecip_orig.
                    end.
                    else
                        assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_abat_antecip_acr.val_abtdo_antecip_orig.
                end.
            end /* for calculo */.
        end /* if */.
        else do:
            liquidac:
            for each b_item_lote_liquidac_acr 
                fields (cod_estab cod_espec_docto cod_ser_docto
                        cod_tit_acr cod_parcela val_liquidac_orig)
                use-index itmltlqd_tit_acr no-lock
                where b_item_lote_liquidac_acr.cod_estab       = tit_acr.cod_estab
                and   b_item_lote_liquidac_acr.cod_espec_docto = tit_acr.cod_espec_docto
                and   b_item_lote_liquidac_acr.cod_ser_docto   = tit_acr.cod_ser_docto
                and   b_item_lote_liquidac_acr.cod_tit_acr     = tit_acr.cod_tit_acr
                and   b_item_lote_liquidac_acr.cod_parcela     = tit_acr.cod_parcela:
                if  (avail item_lote_liquidac_acr
                and recid(b_item_lote_liquidac_acr) <> recid(item_lote_liquidac_acr))
                or  not avail item_lote_liquidac_acr then
                    assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_item_lote_liquidac_acr.val_liquidac_orig.
            end /* for liquidac */.

            relacto:
            for each b_relacto_pend_tit_acr 
                fields (cod_estab_tit_acr_pai num_id_tit_acr_pai val_relacto_tit_acr)
                use-index rlctpnda_tit_acr no-lock
                where b_relacto_pend_tit_acr.cod_estab_tit_acr_pai = tit_acr.cod_estab
                and   b_relacto_pend_tit_acr.num_id_tit_acr_pai    = tit_acr.num_id_tit_acr:
                if (avail relacto_pend_tit_acr
                and recid(b_relacto_pend_tit_acr) <> recid(relacto_pend_tit_acr))
                or  not avail relacto_pend_tit_acr then
                    assign v_val_tot_comprtdo = v_val_tot_comprtdo + b_relacto_pend_tit_acr.val_relacto_tit_acr.
            end /* for relacto */.

            for each b_item_renegoc_acr no-lock
                where b_item_renegoc_acr.cod_estab_tit_acr    = tit_acr.cod_estab
                and   b_item_renegoc_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                &if '{&emsfin_version}' >= "5.03" &then use-index itmrngcc_tit_acr &endif,
                first b_renegoc_acr no-lock
                   where b_renegoc_acr.cod_estab               = b_item_renegoc_acr.cod_estab
                   and   b_renegoc_acr.num_renegoc_cobr_acr    = b_item_renegoc_acr.num_renegoc_cobr_acr
                   and   b_renegoc_acr.ind_sit_renegoc_acr    <> "Atualizado" /*l_atualizado*/ :

                if (avail item_renegoc_acr and recid(b_item_renegoc_acr) <> recid(item_renegoc_acr))
                or (not avail item_renegoc_acr) then 
                   assign v_val_tot_comprtdo = v_val_tot_comprtdo + tit_acr.val_sdo_tit_acr.
            end.
        end /* else */.
    end /* else */.
END PROCEDURE. /* pi_verificar_sdo_compr */
/*****************************************************************************
** Procedure Interna.....: pi_retorna_parametro_acr
** Descricao.............: pi_retorna_parametro_acr
** Criado por............: bre17906
** Criado em.............: 20/04/1999 08:29:23
** Alterado por..........: bre17906
** Alterado em...........: 09/09/1999 10:32:27
*****************************************************************************/
PROCEDURE pi_retorna_parametro_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    find last param_estab_acr no-lock
         where param_estab_acr.cod_estab = p_cod_estab
           and param_estab_acr.dat_inic_valid <= p_dat_refer
           and param_estab_acr.dat_fim_valid >= p_dat_refer
    &if "{&emsfin_version}" >= "5.01" &then
         use-index prmstbcr_data
    &endif
          /*cl_param_estab_acr of param_estab_acr*/ no-error.
    if avail param_estab_acr
       then  return "OK" /*l_ok*/ .
       else  return "NOK" /*l_nok*/ .
END PROCEDURE. /* pi_retorna_parametro_acr */
/*****************************************************************************
** Procedure Interna.....: pi_for_each_tt_integr_acr_item_lote_impl
** Descricao.............: pi_for_each_tt_integr_acr_item_lote_impl
** Criado por............: bre18490
** Criado em.............: 17/01/2000 13:32:16
** Alterado por..........: fut31947
** Alterado em...........: 30/09/2009 16:45:59
*****************************************************************************/
PROCEDURE pi_for_each_tt_integr_acr_item_lote_impl:

    assign v_num_cont_tit_acr = 0.
    for each tt_integr_acr_item_renegoc_new
        where tt_integr_acr_item_renegoc_new.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:
        find first b_tit_acr_renegoc no-lock
            where b_tit_acr_renegoc.cod_estab       = tt_integr_acr_renegoc.tta_cod_estab
            and   b_tit_acr_renegoc.cod_espec_docto = tt_integr_acr_renegoc.tta_cod_espec_docto
            and   b_tit_acr_renegoc.cod_ser_docto   = tt_integr_acr_renegoc.tta_cod_ser_docto
            and   b_tit_acr_renegoc.cod_tit_acr     = tt_integr_acr_item_renegoc_new.tta_cod_tit_acr
            and   b_tit_acr_renegoc.cod_parcela     = tt_integr_acr_item_renegoc_new.tta_cod_parcela no-error.
        if  avail b_tit_acr_renegoc then 
            run pi_integr_acr_renegoc_erros(3940,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","").

        if  tt_integr_acr_item_renegoc_new.tta_dat_emis_docto > tt_integr_acr_renegoc.tta_dat_transacao then
            run pi_integr_acr_renegoc_erros(9225,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","").

        if  tt_integr_acr_item_renegoc_new.tta_dat_emis_docto > tt_integr_acr_item_renegoc_new.tta_dat_vencto_tit_acr then
            run pi_integr_acr_renegoc_erros(9420,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","").    

        if tt_integr_acr_item_renegoc_new.tta_val_tit_acr = 0 then do:
            run pi_integr_acr_renegoc_erros(10311,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","").    
        end.

        if  v_cod_pais_empres_usuar = "BRA" /*l_bra*/ 
        then do:
            run pi_vld_impto_item_lote_impl /*pi_vld_impto_item_lote_impl*/.
            if v_log_erro_impto then leave.
        end /* if */.

        assign v_num_cont_tit_acr = v_num_cont_tit_acr + 1.

        run pi_vld_renegoc_acr_subst_novos(yes).

        if (v_log_error_renegoc_acr = no) then do:
            run pi_verificar_titulo_unico_acr (Input renegoc_acr.cod_estab,
                                               Input tt_integr_acr_renegoc.tta_cod_espec_docto,
                                               Input tt_integr_acr_renegoc.tta_cod_ser_docto,
                                               input tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,
                                               Input tt_integr_acr_item_renegoc_new.tta_cod_parcela,
                                               Input ?,
                                               output v_log_tit_acr_unico) /* pi_verificar_titulo_unico_acr*/.
            if  not v_log_tit_acr_unico
            then do:
                &if '{&frame_aux}' <> "" &then
                    /* T°tulo j† existente no Contas a Receber ! */
                    run pi_messages (input "show",
                                     input 778,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        renegoc_acr.cod_estab, tt_integr_acr_renegoc.tta_cod_espec_docto, tt_integr_acr_renegoc.tta_cod_ser_docto,                                  tt_integr_acr_item_renegoc_new.tta_cod_tit_acr, tt_integr_acr_item_renegoc_new.tta_cod_parcela)) /*msg_778*/).
                    return error.
                &else
                    assign v_cod_parameters = renegoc_acr.cod_estab + "," + 
                                              tt_integr_acr_renegoc.tta_cod_espec_docto + "," +
                                              tt_integr_acr_renegoc.tta_cod_ser_docto + "," +
                                              tt_integr_acr_item_renegoc_new.tta_cod_tit_acr + "," +
                                              tt_integr_acr_item_renegoc_new.tta_cod_parcela + ",,,,,,,,".
                    run pi_integr_acr_renegoc_erros(778,
                                                    renegoc_acr.cod_estab,
                                                    renegoc_acr.num_renegoc_cobr_acr,
                                                    "",
                                                    renegoc_acr.cdn_cliente,
                                                    renegoc_acr.cod_espec_docto,
                                                    renegoc_acr.cod_ser_docto,
                                                    renegoc_acr.cod_tit_acr,
                                                    renegoc_acr.cod_parcela,
                                                    "","",
                                                    v_cod_parameters).
                &endif
            end.

            run pi_vld_acr_cria_item_lote_impl_renegoc.
        end.
    end.
END PROCEDURE. /* pi_for_each_tt_integr_acr_item_lote_impl */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_vendor
** Descricao.............: pi_verifica_vendor
** Criado por............: bre19062
** Criado em.............: 15/09/2002 17:37:36
** Alterado por..........: bre19062
** Alterado em...........: 15/09/2002 17:38:53
*****************************************************************************/
PROCEDURE pi_verifica_vendor:


    /* Begin_Include: i_vrf_modul_vendor */
    /* ==> MODULO VENDOR <== */
    /* alteraá∆o por demanda, favor manter a alteraá∆o abaixo*/
    /* Verifica liberaªío do mΩdulo Vendor */
    assign v_log_modul_vendor = no.
    &IF '{&emsfin_version}' >= '5.05'  AND '{&emsfin_version}' <= '5.06'   &THEN 
        run prgfin/acr/acr930za.py (output v_log_modul_vendor) /* prg_fnc_verifica_liberacao_vendor*/.
    &ELSE
        Assign v_log_modul_vendor = Yes.
    &ENDIF
    /* End_Include: i_vrf_modul_vendor */

END PROCEDURE. /* pi_verifica_vendor */
/*****************************************************************************
** Procedure Interna.....: pi_integr_acr_renegoc_erros_help
** Descricao.............: pi_integr_acr_renegoc_erros_help
** Criado por............: fut12197
** Criado em.............: 10/11/2004 09:15:52
** Alterado por..........: fut12235
** Alterado em...........: 26/10/2009 13:55:30
*****************************************************************************/
PROCEDURE pi_integr_acr_renegoc_erros_help:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_mensagem
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_num_renegoc_cobr_acr
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_num_seq_item_renegoc_acr
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_cdn_cliente
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_tit_acr
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
        no-undo.
    def Input param p_cod_fiador
        as character
        format "x(8)"
        no-undo.
    def Input param p_num_pessoa
        as integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_parameters
        as character
        format "x(256)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_mensagem
        as character
        format "x(50)":U
        view-as editor max-chars 2000 scrollbar-vertical
        size 50 by 4
        bgcolor 15 font 2
        label "Mensagem"
        column-label "Mensagem"
        no-undo.
    def var v_num_mensagem
        as integer
        format ">>>>,>>9":U
        label "N£mero"
        column-label "N£mero Mensagem"
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_num_mensagem            = p_num_mensagem
           v_log_error_renegoc_acr   = yes. 
    run pi_messages (input "help",
                     input v_num_mensagem,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
    assign v_des_mensagem = return-value /*msg_v_num_mensagem*/.

    /* ** A condiá∆o abaixo Ç necess†ria, pois quando o parametro (p_cod_parameters) est† sem as virgulas
         apresenta erros  ***/
    if  p_cod_parameters = ""
    then do:
        assign p_cod_parameters = ",,,,,,,,".
    end /* if */.

    create tt_log_erros_renegoc.
    assign tt_log_erros_renegoc.tta_cod_estab                = p_cod_estab
           tt_log_erros_renegoc.tta_num_renegoc_cobr_acr     = p_num_renegoc_cobr_acr
           tt_log_erros_renegoc.tta_num_seq_item_renegoc_acr = p_num_seq_item_renegoc_acr
           tt_log_erros_renegoc.tta_cdn_cliente              = p_cdn_cliente
           tt_log_erros_renegoc.tta_cod_espec_docto          = p_cod_espec_docto
           tt_log_erros_renegoc.tta_cod_ser_docto            = p_cod_ser_docto
           tt_log_erros_renegoc.tta_cod_tit_acr              = p_cod_tit_acr
           tt_log_erros_renegoc.tta_cod_parcela              = P_cod_parcela
           tt_log_erros_renegoc.tta_cod_fiador               = p_cod_fiador
           tt_log_erros_renegoc.tta_num_pessoa               = p_num_pessoa
           tt_log_erros_renegoc.tta_num_mensagem             = p_num_mensagem 
           tt_log_erros_renegoc.ttv_des_msg                  = substitute( v_des_mensagem, 
                                                                               entry( 1, p_cod_parameters ), 
                                                                               entry( 2, p_cod_parameters ), 
                                                                               entry( 3, p_cod_parameters ), 
                                                                               entry( 4, p_cod_parameters ), 
                                                                               entry( 5, p_cod_parameters ), 
                                                                               entry( 6, p_cod_parameters ), 
                                                                               entry( 7, p_cod_parameters ), 
                                                                               entry( 8, p_cod_parameters ), 
                                                                               entry( 9, p_cod_parameters )).

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_integr_acr_renegoc_erros_help */
/*****************************************************************************
** Procedure Interna.....: pi_vld_impto_item_lote_impl
** Descricao.............: pi_vld_impto_item_lote_impl
** Criado por............: its0042
** Criado em.............: 06/01/2005 11:22:35
** Alterado por..........: fut31947
** Alterado em...........: 30/09/2009 16:46:38
*****************************************************************************/
PROCEDURE pi_vld_impto_item_lote_impl:

    /************************** Buffer Definition Begin *************************/

    def buffer btt_integr_acr_item_renegoc
        for tt_integr_acr_item_renegoc.
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_acr
        for tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_ret_impl_subst             as logical         no-undo. /*local*/
    def var v_log_tit_difer                  as logical         no-undo. /*local*/


    /************************** Variable Definition End *************************/


    /* --- Valida se exite itens com retená∆o e sem retená∆o no mesmo lote --- */
    assign v_log_retenc_impto_impl = tt_integr_acr_item_renegoc_new.tta_log_retenc_impto_impl
           v_log_erro_impto = no.

    if  v_log_retenc_impto_impl
    then do:
        /* --- Valor da base de c†lculo deve ser informado --- */
        if  tt_integr_acr_item_renegoc_new.tta_val_base_calc_impto = 0
        then do:
            assign v_log_erro_impto = yes.
            run pi_integr_acr_renegoc_erros(13750,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","").        
        end /* if */.

        /* --- Valida se foi informado pelo menos um imposto --- */ 
        if  tt_integr_acr_item_renegoc_new.ttv_val_cr_pis          = 0
        and tt_integr_acr_item_renegoc_new.ttv_val_cr_cofins       = 0
        and tt_integr_acr_item_renegoc_new.ttv_val_cr_csll         = 0
        then do:
            assign v_log_erro_impto = yes.
            run pi_integr_acr_renegoc_erros(13740,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","","Implantaá∆o" /*l_implantacao*/   + ",,,,,,,,").
        end /* if */.
    end /* if */.


    for each btt_integr_acr_item_renegoc
        break by btt_integr_acr_item_renegoc.tta_num_id_tit_acr:
        find first b_tit_acr 
             where b_tit_acr.cod_estab       = btt_integr_acr_item_renegoc.tta_cod_estab 
             and   b_tit_acr.num_id_tit_acr  = btt_integr_acr_item_renegoc.tta_num_id_tit_acr no-lock no-error.
        if  avail b_tit_acr
        then do:
            assign v_log_tit_difer = no.
            &if '{&emsfin_version}' >= '5.06' &then
                if first(btt_integr_acr_item_renegoc.tta_num_id_tit_acr) then
                    assign v_log_ret_impl_subst = b_tit_acr.log_retenc_impto_impl.
                else
                    if v_log_ret_impl_subst <> b_tit_acr.log_retenc_impto_impl then
                        assign v_log_tit_difer = yes.
            &else
                find first tab_livre_emsfin
                     where tab_livre_emsfin.cod_modul_dtsul      = "ACR" /*l_acr*/  
                     and   tab_livre_emsfin.cod_tab_dic_dtsul    = "tit_acr_impto_cr" /*l_tit_acr_impto_cr*/  
                     and   tab_livre_emsfin.cod_compon_1_idx_tab = b_tit_acr.cod_estab
                     and   tab_livre_emsfin.cod_compon_2_idx_tab = string(b_tit_acr.num_id_tit_acr) no-lock no-error.
                if  avail tab_livre_emsfin and num-entries(tab_livre_emsfin.cod_livre_1,chr(24)) >= 5
                then do:
                    if first(btt_integr_acr_item_renegoc.tta_num_id_tit_acr) then
                        assign v_log_ret_impl_subst = entry(5,tab_livre_emsfin.cod_livre_1,chr(24)) = "yes" /*l_yes*/ .
                    else
                        if (    v_log_ret_impl_subst and (entry(5,tab_livre_emsfin.cod_livre_1,chr(24)) <> "yes" /*l_yes*/ ))
                        or (not v_log_ret_impl_subst and (entry(5,tab_livre_emsfin.cod_livre_1,chr(24))  = "yes" /*l_yes*/ )) then
                            assign v_log_tit_difer = yes.
                end /* if */.
            &endif
            if  v_log_tit_difer
            then do:
                assign v_log_erro_impto = yes.
                run pi_integr_acr_renegoc_erros(13751,tt_integr_acr_renegoc.tta_cod_estab,"","","",tt_integr_acr_renegoc.tta_cod_espec_docto,tt_integr_acr_renegoc.tta_cod_ser_docto,tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,tt_integr_acr_item_renegoc_new.tta_cod_parcela,"","",""). 
                leave.
            end /* if */.
        end /* if */.
    end.    


END PROCEDURE. /* pi_vld_impto_item_lote_impl */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_3
** Descricao.............: pi_main_code_api_integr_acr_renegoc_3
** Criado por............: its0042
** Criado em.............: 28/01/2005 11:44:11
** Alterado por..........: fut31947
** Alterado em...........: 21/09/2009 09:34:40
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_3:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_vers_integr_api_i
        as integer
        format ">>>>,>>9"
        no-undo.
    def input-output param table 
        for tt_integr_acr_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_lote_impl_7.
    def input-output param table 
        for tt_integr_acr_fiador_reneg_old.
    def Input param table 
        for tt_pessoa_fisic_integr_old.
    def Input param table 
        for tt_pessoa_jurid_integr_old.
    def Input param p_cod_matriz_trad_org_ext_i
        as character
        format "x(8)"
        no-undo.
    def output param table 
        for tt_log_erros_renegoc_Acr.


    /************************* Parameter Definition End *************************/

    for each tt_pessoa_fisic_integr_old:
        create tt_pessoa_fisic_integr_old_1.
        buffer-copy tt_pessoa_fisic_integr_old to tt_pessoa_fisic_integr_old_1.
    end.

    run pi_main_code_api_integr_acr_renegoc_4 (input        p_num_vers_integr_api_i,
                                               input-output table tt_integr_acr_renegoc_old,
                                               input-output table tt_integr_acr_item_renegoc_old,
                                               input-output table tt_integr_acr_item_lote_impl_7,
                                               input-output table tt_integr_acr_fiador_reneg_old,
                                               input        table tt_pessoa_fisic_integr_old_1,
                                               input        table tt_pessoa_jurid_integr_old,
                                               input        p_cod_matriz_trad_org_ext_i,
                                               output       table tt_log_erros_renegoc_Acr).
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_3 */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_4
** Descricao.............: pi_main_code_api_integr_acr_renegoc_4
** Criado por............: its0123
** Criado em.............: 01/12/2006 15:48:19
** Alterado por..........: fut31947
** Alterado em...........: 21/09/2009 09:35:02
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_4:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_vers_integr_api_i
        as integer
        format ">>>>,>>9"
        no-undo.
    def input-output param table 
        for tt_integr_acr_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_lote_impl_7.
    def input-output param table 
        for tt_integr_acr_fiador_reneg_old.
    def Input param table 
        for tt_pessoa_fisic_integr_old_1.
    def Input param table 
        for tt_pessoa_jurid_integr_old.
    def Input param p_cod_matriz_trad_org_ext_i
        as character
        format "x(8)"
        no-undo.
    def output param table 
        for tt_log_erros_renegoc_Acr.


    /************************* Parameter Definition End *************************/

    for each tt_pessoa_fisic_integr_old_1:
        create tt_pessoa_fisic_integr.
        buffer-copy tt_pessoa_fisic_integr_old_1 to tt_pessoa_fisic_integr_old_2.
    end.

    for each tt_pessoa_jurid_integr_old:
        create tt_pessoa_jurid_integr.
        buffer-copy tt_pessoa_jurid_integr_old to tt_pessoa_jurid_integr_old_2.
    end.

    run pi_main_code_api_integr_acr_renegoc_5 (input        p_num_vers_integr_api_i,
                                               input-output table tt_integr_acr_renegoc_old,
                                               input-output table tt_integr_acr_item_renegoc_old,
                                               input-output table tt_integr_acr_item_lote_impl_7,
                                               input-output table tt_integr_acr_fiador_reneg_old,
                                               input        table tt_pessoa_fisic_integr_old_2,
                                               input        table tt_pessoa_jurid_integr_old_2,
                                               input        p_cod_matriz_trad_org_ext_i,
                                               output       table tt_log_erros_renegoc_Acr).
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_4 */
/*****************************************************************************
** Procedure Interna.....: pi_confere_dados_comissao
** Descricao.............: pi_confere_dados_comissao
** Criado por............: fut35183
** Criado em.............: 29/12/2005 08:39:16
** Alterado por..........: fut12235_3
** Alterado em...........: 01/07/2010 10:07:37
*****************************************************************************/
PROCEDURE pi_confere_dados_comissao:

    for each repres_tit_acr  no-lock
    where repres_tit_acr.cod_estab      = tit_acr.cod_estab
    and   repres_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:

        find first tt_repres_tit_acr_comis_ext 
        where tt_repres_tit_acr_comis_ext.tta_cdn_repres = repres_tit_acr.cdn_repres no-lock no-error.

        assign v_des_comis = "".

        if avail tt_repres_tit_acr_comis_ext then do:                       
            &if '{&emsfin_version}' >= '5.06' &then
                if  tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> repres_tit_acr.ind_tip_comis_ext 
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> "Nenhum" /*l_nenhum*/  
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> ""
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext <> ? then                           
                    assign v_des_comis = "Tipo Comiss∆o Externa" /*l_tipo_comissao_ext*/ .
                else
                    if  tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis <> repres_tit_acr.ind_liber_pagto_comis then
                        assign v_des_comis = "Liberaá∆o Pagto Comiss∆o" /*l_liber_pagto_comis*/ .
                    else
                        if  tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext <> repres_tit_acr.ind_sit_comis_ext then
                            assign v_des_comis = "Situaá∆o Comiss∆o Externa" /*l_sit_comis_ext*/ .
            &else
                if  GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10)) <> ""
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10))
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> "Nenhum" /*l_nenhum*/  
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> "" 
                and tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext   <> ? then                               
                    assign v_des_comis = "Tipo Comiss∆o Externa" /*l_tipo_comissao_ext*/ .
                else
                if tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis <> GetEntryField(3,repres_tit_acr.cod_livre_1,chr(10)) then
                    assign v_des_comis = "Liberaá∆o Pagto Comiss∆o" /*l_liber_pagto_comis*/ .
                else
                if tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext <> GetEntryField(4,repres_tit_acr.cod_livre_1,chr(10)) then
                    assign v_des_comis = "Situaá∆o Comiss∆o Externa" /*l_sit_comis_ext*/ .
            &endif
            if v_des_comis <> "" then do:
                &if '{&frame_aux}' <> "" &then
                    run pi_messages (input 'show',
                                     input 17908,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        tt_repres_tit_acr_comis_ext.tta_cdn_repres,
                                                        v_des_comis)) /* msg_744*/.
                    return "NOK" /*l_nok*/ .
                &else
                    assign v_des_comis = " " + v_des_comis + "/" + "Repres" /*l_repres*/  + ".: ".
                           v_cod_parameters = v_des_comis + string(tt_repres_tit_acr_comis_ext.tta_cdn_repres) + ",,,,,,,,".
                    run pi_integr_acr_renegoc_erros(17910,
                                                    tit_acr.cod_estab,
                                                    tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                    "",
                                                    tt_integr_acr_renegoc.tta_cdn_cliente,
                                                    tit_acr.cod_espec_docto,
                                                    tit_acr.cod_ser_docto,
                                                    tit_acr.cod_tit_acr,
                                                    tit_acr.cod_parcela, 
                                                    "",
                                                    "",
                                                    v_cod_parameters).
                    return "NOK" /*l_nok*/ .
                 &endif      
            end.                         
        end.
        else do:
            create tt_repres_tit_acr_comis_ext.
            assign tt_repres_tit_acr_comis_ext.tta_cdn_repres = repres_tit_acr.cdn_repres.                       
            &if '{&emsfin_version}' >= '5.06' &then
                assign tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext     = repres_tit_acr.ind_tip_comis_ext
                       tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis = repres_tit_acr.ind_liber_pagto_comis
                       tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext     = repres_tit_acr.ind_sit_comis_ext.
            &else
                assign tt_repres_tit_acr_comis_ext.ttv_ind_tip_comis_ext     = GetEntryField(2,repres_tit_acr.cod_livre_1,chr(10))
                       tt_repres_tit_acr_comis_ext.ttv_ind_liber_pagto_comis = GetEntryField(3,repres_tit_acr.cod_livre_1,chr(10))
                       tt_repres_tit_acr_comis_ext.ttv_ind_sit_comis_ext     = GetEntryField(4,repres_tit_acr.cod_livre_1,chr(10)).
            &endif                                  
        end. 
    end.            

    return "OK" /*l_ok*/ .  
END PROCEDURE. /* pi_confere_dados_comissao */
/*****************************************************************************
** Procedure Interna.....: pi_verificar_cliente_estrangeiro
** Descricao.............: pi_verificar_cliente_estrangeiro
** Criado por............: fut12178
** Criado em.............: 10/09/2002 09:51:34
** Alterado por..........: fut12178
** Alterado em...........: 11/10/2002 09:31:05
*****************************************************************************/
PROCEDURE pi_verificar_cliente_estrangeiro:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empres_usuar
        as character
        format "x(3)"
        no-undo.
    def Input param p_cdn_cliente
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_estab_usuar
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_emis
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_moeda
        as character
        format "x(8)"
        no-undo.
    def output param p_num_natur
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_indic_econ
        as character
        format "x(8)":U
        label "Moeda"
        column-label "Moeda"
        no-undo.


    /************************** Variable Definition End *************************/

    find cliente no-lock
        where cliente.cod_empresa = p_cod_empres_usuar
        and   cliente.cdn_cliente = p_cdn_cliente no-error.
    if  avail cliente then do:
        if  cliente.num_pessoa modulo 2 = 0 then do:
            find first pessoa_fisic no-lock
                where pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa no-error.
            if  avail pessoa_fisic then do:
                find estabelecimento no-lock
                    where estabelecimento.cod_estab = p_cod_estab_usuar no-error.
                if  avail estabelecimento then do:
                    if  estabelecimento.cod_pais <> pessoa_fisic.cod_pais then do:
                        assign p_num_natur = 3.
                        find pais no-lock
                            where pais.cod_pais = estabelecimento.cod_pais no-error.
                        if  avail pais then do:
                            find first histor_finalid_econ NO-LOCK
                                where histor_finalid_econ.cod_finalid_econ = pais.cod_finalid_econ_pais
                                and   histor_finalid_econ.dat_inic_valid_finalid <= p_dat_emis
                                and   histor_finalid_econ.dat_fim_valid_finalid  >  p_dat_emis
                                &if '{&emsuni_version}' >= '5.01' &then
                                     use-index hstrfnld_id
                                &endif
                                no-error.
                            if  avail histor_finalid_econ then do:
                                assign v_cod_indic_econ = histor_finalid_econ.cod_indic_econ.              
                                if  v_cod_indic_econ <> p_cod_indic_econ then
                                    assign p_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  .
                            end.
                        end.
                    end.
                end.
            end.
        end.
        else do:
            find first pessoa_jurid no-lock
                where pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa no-error.
            if  avail pessoa_jurid then do:
                find estabelecimento no-lock
                    where estabelecimento.cod_estab = p_cod_estab_usuar no-error.
                if  avail estabelecimento then do:
                    if  estabelecimento.cod_pais <> pessoa_jurid.cod_pais then do:
                        assign p_num_natur = 3.
                        find pais where pais.cod_pais = estabelecimento.cod_pais no-lock no-error.
                        if  avail pais then do:
                            find first histor_finalid_econ NO-LOCK
                                where histor_finalid_econ.cod_finalid_econ = pais.cod_finalid_econ_pais
                                and   histor_finalid_econ.dat_inic_valid_finalid <= p_dat_emis
                                and   histor_finalid_econ.dat_fim_valid_finalid  >  p_dat_emis
                                &if '{&emsuni_version}' >= '5.01' &then
                                     use-index hstrfnld_id
                                &endif
                                no-error.
                            if  avail histor_finalid_econ then do:
                                assign v_cod_indic_econ = histor_finalid_econ.cod_indic_econ.              
                                if  v_cod_indic_econ <> p_cod_indic_econ then
                                    assign p_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  .
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_verificar_cliente_estrangeiro */
/*****************************************************************************
** Procedure Interna.....: pi_valida_integracao_cambio
** Descricao.............: pi_valida_integracao_cambio
** Criado por............: fut40552
** Criado em.............: 02/07/2007 14:24:44
** Alterado por..........: fut12235
** Alterado em...........: 21/01/2008 09:54:58
*****************************************************************************/
PROCEDURE pi_valida_integracao_cambio:

    /************************ Parameter Definition Begin ************************/

    def output param table 
        for tt_log_erros.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_empresa
        as character
        format "x(3)":U
        label "Empresa"
        column-label "Empresa"
        no-undo.
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    def var v_cod_estab
        as character
        format "x(3)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    def var v_cod_estab
        as Character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    def var v_cod_estab_aux
        as character
        format "x(3)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    def var v_cod_estab_aux
        as Character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    def var v_cod_refer
        as character
        format "x(10)":U
        label "Referància"
        column-label "Referància"
        no-undo.
    def var v_dat_refer
        as date
        format "99/99/9999":U
        initial today
        label "Data Referància"
        column-label "Data Refer"
        no-undo.


    /************************** Variable Definition End *************************/

     find cliente no-lock
         where cliente.cod_empresa = tit_acr.cod_empresa
           and cliente.cdn_cliente = tit_acr.cdn_cliente no-error.
     if  avail cliente then do:
         run pi_verificar_cliente_estrangeiro(input tit_acr.cod_empresa,
                                              input tit_acr.cdn_cliente,
                                              input tit_acr.cod_estab,
                                              input tit_acr.cod_indic_econ,
                                              input tit_acr.dat_emis_docto,
                                              output v_cod_moeda,
                                              output v_num_natur).
     end.

     if  v_num_natur = 3 and
         v_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  then do:

         for each tt_xml_input_output:
             delete tt_xml_input_output.
         end.

         for each tt_log_erros exclusive-lock:
             delete tt_log_erros.
         end.

        create  tt_xml_input_output.
        assign  tt_xml_input_output.ttv_cod_label = 'Funá∆o':U /* l_funcao*/
                tt_xml_input_output.ttv_des_conteudo = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/ 
                tt_xml_input_output.ttv_num_seq_1 = 1.

        create  tt_xml_input_output.
        assign  tt_xml_input_output.ttv_cod_label = 'Produto':U /* l_produto*/
                tt_xml_input_output.ttv_des_conteudo = "EMS 2" /*l_ems2*/     
                tt_xml_input_output.ttv_num_seq_1 = 1.

        create  tt_xml_input_output.
        assign  tt_xml_input_output.ttv_cod_label = 'Empresa':U /* l_empresa*/ 
                tt_xml_input_output.ttv_des_conteudo = tit_acr.cod_empresa
                tt_xml_input_output.ttv_num_seq_1 = 1.

        create  tt_xml_input_output.
        assign  tt_xml_input_output.ttv_cod_label = 'Estabel':U /* l_estabel*/
                tt_xml_input_output.ttv_des_conteudo = tit_acr.cod_estab
                tt_xml_input_output.ttv_num_seq_1 = 1.


        RUN prgint/utb/utb786za.py (INPUT-OUTPUT table tt_xml_input_output,
                                    OUTPUT table tt_log_erros).

        find first tt_log_erros where tt_log_erros.ttv_num_cod_erro <> 0 no-error.
        if avail tt_log_erros then 
           return "NOK" /*l_nok*/ .

        for each tt_xml_input_output break by tt_xml_input_output.ttv_num_seq_1:
            if tt_xml_input_output.ttv_cod_label = 'Empresa':U /* l_empresa*/ then
               ASSIGN v_cod_empresa  =  tt_xml_input_output.ttv_des_conteudo_aux.

            if tt_xml_input_output.ttv_cod_label = 'Estabel':U /* l_estabel*/ THEN
               ASSIGN v_cod_estab    =  tt_xml_input_output.ttv_des_conteudo_aux.
        end.  

        if  search("prgint/utb/utb720za.r") = ? and search("prgint/utb/utb720za.py") = ? then do:
            if  v_cod_dwb_user begins 'es_' then
                return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb720za.py".
            else do:
                message getStrTrans("Programa execut†vel n∆o foi encontrado:", "ACR") /*l_programa_nao_encontrado*/  "prgint/utb/utb720za.py"
                       view-as alert-box error buttons ok.
                return.
            end.
        end.
        else
            run prgint/utb/utb720za.py (Input 1,
                                    Input "On-Line" /*l_online*/,
                                    output v_log_connect_ems2_ok,
                                    output v_log_connect) /*prg_fnc_conecta_bases_externas*/.
        if  v_log_connect         = no
            and v_log_connect_ems2_ok = no then do:
            if  search("prgint/utb/utb720za.r") = ? and search("prgint/utb/utb720za.py") = ? then do:
                if  v_cod_dwb_user begins 'es_' then
                    return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb720za.py".
                else do:
                    message getStrTrans("Programa execut†vel n∆o foi encontrado:", "ACR") /*l_programa_nao_encontrado*/  "prgint/utb/utb720za.py"
                           view-as alert-box error buttons ok.
                    return.
                end.
            end.
            else
                run prgint/utb/utb720za.py (Input 2,
                                        Input "On-Line" /*l_online*/,
                                        output v_log_connect_ems2_ok,
                                        output v_log_connect) /*prg_fnc_conecta_bases_externas*/.
            return "NOK" /*l_nok*/ .
        end.

        run adbo/boad347.p persistent set v_hdl_aux.

        run pi-vld-cancela-titulo-cr in v_hdl_aux (input v_cod_empresa, 
                                                   input v_cod_estab,
                                                   input tit_acr.cod_espec_docto,
                                                   input tit_acr.cod_ser_docto,
                                                   input tit_acr.cod_tit_acr,
                                                   input tit_acr.cod_parcela,
                                                   output v_cod_estab_aux,
                                                   output v_cod_refer,
                                                   output v_dat_refer).

        run pi-busca-saldo-contrato in v_hdl_aux  (input v_cod_empresa, 
                                                   input v_cod_estab,
                                                   input tit_acr.cod_espec_docto,
                                                   input tit_acr.cod_ser_docto,
                                                   input tit_acr.cod_tit_acr,
                                                   input tit_acr.cod_parcela,
                                                   output v_val_sdo_liquidac).                                               


        if valid-handle(v_hdl_aux) then
            delete procedure v_hdl_aux.

        if  search("prgint/utb/utb720za.r") = ? and search("prgint/utb/utb720za.py") = ? then do:
            if  v_cod_dwb_user begins 'es_' then
                return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb720za.py".
            else do:
                message getStrTrans("Programa execut†vel n∆o foi encontrado:", "ACR") /*l_programa_nao_encontrado*/  "prgint/utb/utb720za.py"
                       view-as alert-box error buttons ok.
                return.
            end.
        end.
        else
            run prgint/utb/utb720za.py (Input 2,
                                    Input "On-Line" /*l_online*/,
                                    output v_log_connect_ems2_ok,
                                    output v_log_connect) /*prg_fnc_conecta_bases_externas*/.

        if  v_cod_refer <> "" 
        and v_val_sdo_liquidac <> 0 then do:
            assign v_cod_parameters = tit_acr.cod_estab + "," + tit_acr.cod_espec_docto + "," + tit_acr.cod_ser_docto + "," +
                                      "," + tit_acr.cod_tit_acr + "," + tit_acr.cod_parcela + ",,,,".
            &if '{&frame_aux}' <> "" &then
                /* Titulo est† vinculado a um contrato de cÉmbio ! */
                run pi_messages (input "show",
                                 input 12890,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                   tit_acr.cod_estab, tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela)) /*msg_12890*/.
                return error.
            &else
                run pi_integr_acr_renegoc_erros(12890,tt_integr_acr_item_renegoc.tta_cod_estab,tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr,
                                                "",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,
                                                tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).

            &endif
        end.
     end.

     return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_valida_integracao_cambio */
/*****************************************************************************
** Procedure Interna.....: pi_export_table_integr_acr_renegoc
** Descricao.............: pi_export_table_integr_acr_renegoc
** Criado por............: fut40552_2
** Criado em.............: 26/11/2007 11:49:44
** Alterado por..........: fut12235_3
** Alterado em...........: 28/01/2010 15:44:07
*****************************************************************************/
PROCEDURE pi_export_table_integr_acr_renegoc:

    output to value(v_cod_arquivo + 'tt_integr_acr_Renegoc.d').
    for each tt_integr_acr_Renegoc:
        export tt_integr_acr_Renegoc.
    end.
    output close.

    output to value(v_cod_arquivo + 'tt_integr_acr_item_renegoc.d').
    for each tt_integr_acr_item_renegoc:
        export tt_integr_acr_item_renegoc.
    end.
    output close.

    output to value(v_cod_arquivo + 'tt_integr_acr_item_renegoc_new.d').
    for each tt_integr_acr_item_renegoc_new:
        export tt_integr_acr_item_renegoc_new.
    end.
    output close.

    output to value(v_cod_arquivo + 'tt_integr_acr_fiador_renegoc.d').
    for each tt_integr_acr_fiador_renegoc:
        export tt_integr_acr_fiador_renegoc.
    end.
    output close.

    output to value(v_cod_arquivo + 'tt_log_erros_renegoc').
    for each tt_log_erros_renegoc:
        export tt_log_erros_renegoc.
    end.
    output close.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_export_table_integr_acr_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_5
** Descricao.............: pi_main_code_api_integr_acr_renegoc_5
** Criado por............: fut1236_2
** Criado em.............: 02/04/2007 13:36:02
** Alterado por..........: fut31947
** Alterado em...........: 21/09/2009 09:35:23
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_5:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_vers_integr_api_i
        as integer
        format ">>>>,>>9"
        no-undo.
    def input-output param table 
        for tt_integr_acr_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_lote_impl_7.
    def input-output param table 
        for tt_integr_acr_fiador_reneg_old.
    def Input param table 
        for tt_pessoa_fisic_integr_old_2.
    def Input param table 
        for tt_pessoa_jurid_integr_old_2.
    def Input param p_cod_matriz_trad_org_ext_i
        as character
        format "x(8)"
        no-undo.
    def output param table 
        for tt_log_erros_renegoc_Acr.


    /************************* Parameter Definition End *************************/

    for each tt_pessoa_fisic_integr_old_2:
        create tt_pessoa_fisic_integr.
        buffer-copy tt_pessoa_fisic_integr_old_2 to tt_pessoa_fisic_integr.
    end.

    for each tt_pessoa_jurid_integr_old_2:
        create tt_pessoa_jurid_integr.
        buffer-copy tt_pessoa_jurid_integr_old_2 to tt_pessoa_jurid_integr.
    end.

    run pi_main_code_api_integr_acr_renegoc_6 (input        p_num_vers_integr_api_i,
                                               input-output table tt_integr_acr_renegoc_old,
                                               input-output table tt_integr_acr_item_renegoc_old,
                                               input-output table tt_integr_acr_item_lote_impl_7,
                                               input-output table tt_integr_acr_fiador_reneg_old,
                                               input        table tt_pessoa_fisic_integr,
                                               input        table tt_pessoa_jurid_integr,
                                               input        p_cod_matriz_trad_org_ext_i,
                                               output       table tt_log_erros_renegoc_Acr).
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_5 */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_6
** Descricao.............: pi_main_code_api_integr_acr_renegoc_6
** Criado por............: fut31947
** Criado em.............: 18/12/2007 17:11:48
** Alterado por..........: fut31947
** Alterado em...........: 05/10/2009 11:51:43
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_6:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_vers_integr_api_i
        as integer
        format ">>>>,>>9"
        no-undo.
    def input-output param table 
        for tt_integr_acr_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_lote_impl_7.
    def input-output param table 
        for tt_integr_acr_fiador_reneg_old.
    def Input param table 
        for tt_pessoa_fisic_integr.
    def Input param table 
        for tt_pessoa_jurid_integr.
    def Input param p_cod_matriz_trad_org_ext_i
        as character
        format "x(8)"
        no-undo.
    def output param table 
        for tt_log_erros_renegoc_Acr.


    /************************* Parameter Definition End *************************/

    for each tt_integr_acr_item_renegoc_old:
        create tt_integr_acr_item_reneg_old2.
        buffer-copy tt_integr_acr_item_renegoc_old to tt_integr_acr_item_reneg_old2.
    end.

    run pi_main_code_api_integr_acr_renegoc_7 (input        p_num_vers_integr_api_i,
                                               input-output table tt_integr_acr_renegoc_old,
                                               input-output table tt_integr_acr_item_reneg_old2,
                                               input-output table tt_integr_acr_item_lote_impl_7,
                                               input-output table tt_integr_acr_fiador_reneg_old,
                                               input        table tt_pessoa_fisic_integr,
                                               input        table tt_pessoa_jurid_integr,
                                               input        p_cod_matriz_trad_org_ext_i,
                                               output       table tt_log_erros_renegoc_Acr).
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_6 */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_7
** Descricao.............: pi_main_code_api_integr_acr_renegoc_7
** Criado por............: fut36015_2
** Criado em.............: 28/02/2008 09:37:24
** Alterado por..........: fut43117
** Alterado em...........: 21/01/2010 10:38:59
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_7:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_vers_integr_api_i
        as integer
        format ">>>>,>>9"
        no-undo.
    def input-output param table 
        for tt_integr_acr_renegoc_old.
    def input-output param table 
        for tt_integr_acr_item_reneg_old2.
    def input-output param table 
        for tt_integr_acr_item_lote_impl_7.
    def input-output param table 
        for tt_integr_acr_fiador_reneg_old.
    def Input param table 
        for tt_pessoa_fisic_integr.
    def Input param table 
        for tt_pessoa_jurid_integr.
    def Input param p_cod_matriz_trad_org_ext_i
        as character
        format "x(8)"
        no-undo.
    def output param table 
        for tt_log_erros_renegoc_Acr.


    /************************* Parameter Definition End *************************/

    for each tt_integr_acr_fiador_reneg_old:
        create tt_integr_acr_fiador_renegoc.
        buffer-copy tt_integr_acr_fiador_reneg_old to tt_integr_acr_fiador_renegoc.
    end.

    for each tt_integr_acr_renegoc_old:
        create tt_integr_acr_renegoc.
        buffer-copy tt_integr_acr_renegoc_old to tt_integr_acr_renegoc.
    end.

    for each tt_integr_acr_item_reneg_old2:
        create tt_integr_acr_item_renegoc.
        buffer-copy tt_integr_acr_item_reneg_old2 to tt_integr_acr_item_renegoc.
    end.

    for each tt_integr_acr_item_lote_impl_7:
        create tt_integr_acr_item_renegoc_new.
        assign tt_integr_acr_item_renegoc_new.ttv_rec_renegoc_acr       = tt_integr_acr_item_lote_impl_7.ttv_rec_lote_impl_tit_acr
               tt_integr_acr_item_renegoc_new.tta_num_seq_refer         = tt_integr_acr_item_lote_impl_7.tta_num_seq_refer
               tt_integr_acr_item_renegoc_new.tta_cod_tit_acr           = tt_integr_acr_item_lote_impl_7.tta_cod_tit_acr
               tt_integr_acr_item_renegoc_new.tta_cod_parcela           = tt_integr_acr_item_lote_impl_7.tta_cod_parcela
               tt_integr_acr_item_renegoc_new.tta_dat_vencto_tit_acr    = tt_integr_acr_item_lote_impl_7.tta_dat_vencto_tit_acr
               tt_integr_acr_item_renegoc_new.tta_dat_prev_liquidac     = tt_integr_acr_item_lote_impl_7.tta_dat_prev_liquidac
               tt_integr_acr_item_renegoc_new.tta_dat_emis_docto        = tt_integr_acr_item_lote_impl_7.tta_dat_emis_docto
               tt_integr_acr_item_renegoc_new.tta_val_tit_acr           = tt_integr_acr_item_lote_impl_7.tta_val_tit_acr
               tt_integr_acr_item_renegoc_new.ttv_val_cr_pis            = tt_integr_acr_item_lote_impl_7.ttv_val_cr_pis
               tt_integr_acr_item_renegoc_new.ttv_val_cr_cofins         = tt_integr_acr_item_lote_impl_7.ttv_val_cr_cofins
               tt_integr_acr_item_renegoc_new.ttv_val_cr_csll           = tt_integr_acr_item_lote_impl_7.ttv_val_cr_csll
               tt_integr_acr_item_renegoc_new.tta_val_base_calc_impto   = tt_integr_acr_item_lote_impl_7.tta_val_base_calc_impto
               tt_integr_acr_item_renegoc_new.tta_log_retenc_impto_impl = tt_integr_acr_item_lote_impl_7.tta_log_retenc_impto_impl
               tt_integr_acr_item_renegoc_new.tta_log_val_fix_parc      = no
               tt_integr_acr_item_renegoc_new.tta_cod_histor_padr       = tt_integr_acr_item_lote_impl_7.tta_cod_histor_padr
               tt_integr_acr_item_renegoc_new.tta_des_text_histor       = tt_integr_acr_item_lote_impl_7.tta_des_text_histor
               tt_integr_acr_item_renegoc_new.ttv_rec_renegoc_acr_novo  = recid(tt_integr_acr_item_renegoc_new)
               tt_integr_acr_item_renegoc_new.tta_cod_proces_export     = tt_integr_acr_item_lote_impl_7.tta_cod_proces_export.
    end.


    run pi_main_code_api_integr_acr_renegoc_8 (input table tt_integr_acr_Renegoc,
                                               input table tt_integr_acr_item_renegoc,
                                               input table tt_integr_acr_item_renegoc_new,
                                               input table tt_integr_acr_fiador_renegoc,
                                               output       table tt_log_erros_renegoc).

    for each tt_log_erros_renegoc:
       create tt_log_erros_renegoc_acr.
       buffer-copy tt_log_erros_renegoc to tt_log_erros_renegoc_acr.
    end.
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_7 */
/*****************************************************************************
** Procedure Interna.....: pi_main_code_api_integr_acr_renegoc_8
** Descricao.............: pi_main_code_api_integr_acr_renegoc_8
** Criado por............: fut12201
** Criado em.............: 19/08/2009 10:16:57
** Alterado por..........: fut43120
** Alterado em...........: 28/09/2010 17:39:52
*****************************************************************************/
PROCEDURE pi_main_code_api_integr_acr_renegoc_8:

    /************************ Parameter Definition Begin ************************/

    def Input param table 
        for tt_integr_acr_Renegoc.
    def Input param table 
        for tt_integr_acr_item_renegoc.
    def Input param table 
        for tt_integr_acr_item_renegoc_new.
    def Input param table 
        for tt_integr_acr_fiador_renegoc.
    def output param table 
        for tt_log_erros_renegoc.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer btt_integr_acr_fiador_renegoc
        for tt_integr_acr_fiador_renegoc.
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_cart_bcia
        for cart_bcia.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_tit_acr_estordo
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        label "Estornados"
        column-label "Estornados"
        no-undo.
    def var v_num_cont_aux
        as integer
        format ">9":U
        no-undo.
    def var v_log_verfdor_aux                as logical         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_main_code_api_integr_acr_renegoc_7 */
    if v_log_export_table then
        run pi_export_table_integr_acr_renegoc.

    /* Tratamento feito para quando o n£mero da renegociaá∆o Ç = 0 (Zero)*/
    for each tt_integr_acr_Renegoc
       where tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr = 0: 

       find last renegoc_acr use-index rngccr_id
           where renegoc_acr.cod_estab = tt_integr_acr_Renegoc.tta_cod_estab
            no-lock no-error.
       if avail renegoc_acr then do:
           assign v_num_cont = 1
                  v_log_verfdor_aux = no.
           if renegoc_acr.num_renegoc_cobr_acr = 9999999 then do:
               REPEAT WHILE v_num_cont <= 9999999:
                   find first renegoc_acr no-lock
                       where renegoc_acr.cod_estab = tt_integr_acr_Renegoc.tta_cod_estab
                         and renegoc_acr.num_renegoc_cobr_acr = v_num_cont no-error.
                   if not avail renegoc_acr then do:     
                       assign v_num_renegoc_cobr_acr = v_num_cont
                              v_log_verfdor_aux      = yes.
                       leave.
                   end.
                   assign v_num_cont = v_num_cont + 1.
               END.
               if v_log_verfdor_aux = no then do:
                   run pi_integr_acr_renegoc_erros(19310,"","","","","","","","","","","").
                   return "NOK" /*l_nok*/ .
               end.
           end.   
           else
               assign v_num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr + 1.
       end.
       else
          assign v_num_renegoc_cobr_acr = 1.

       for each tt_integr_acr_item_renegoc
          where tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr = 0:
            assign tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr = v_num_renegoc_cobr_acr.
       end.

       assign tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr = v_num_renegoc_cobr_acr.
    end.

    run pi_verifica_vendor /*pi_verifica_vendor*/.

    if  v_log_modul_vendor
    then do:

        /* Begin_Include: i_instanciar_api_centraliz_integr_acr_vdr */
        /* ==> MODULO VENDOR <== */
        /* CASO O M‡DULO VENDOR ESTEJA ATIVO, SETA COMO PERSIST“NTE SUA EXECUÄ«O */
        if  v_log_modul_vendor
        then do:
           if  not valid-handle( v_hdl_api_centraliz_acr_vdr )
           then do:
              run prgfin/vdr/vdr916zc.py persistent set v_hdl_api_centraliz_acr_vdr (Input 1) /*prg_API_CENTRALIZA_INTEGR_ACR_VDR*/.
              ASSIGN v_log_handle = YES.
           end.
        end.
        /* End_Include: i_instanciar_api_centraliz_integr_acr_vdr */

        run pi_retorna_tt_espec_vdr_db in  v_hdl_api_centraliz_acr_vdr (output table tt_espec_vdr_db) /*pi_retorna_tt_espec_vdr_db*/.

        /* Begin_Include: i_eliminar_api_centraliz_integr_acr_vdr */
        /* ==> MODULO VENDOR <== */
        /* ELIMINA DA MEM‡RIA PROGRAMA VENDOR PERSIST“NTE */
        if  valid-handle( v_hdl_api_centraliz_acr_vdr ) AND v_log_handle
        then do:
            delete procedure v_hdl_api_centraliz_acr_vdr.
            ASSIGN v_hdl_api_centraliz_acr_vdr = ?.
        end.
        /* End_Include: i_eliminar_api_centraliz_integr_acr_vdr */

    end /* if */.

    assign v_log_funcao_base_tribut = &if defined(BF_FIN_REDUCAO_BASE_TRIBUT) &then yes &else GetDefinedFunction('SPP_REDUCAO_BASE_TRIBUTAVEL':U) &endif
           v_log_func_control_comis_renegoc = &IF DEFINED(BF_FIN_CONT_COMIS_REN) &THEN YES &ELSE GetDefinedFunction('SPP_CONT_COMIS_REN':U) &ENDIF.

    for each tt_ped_vda_tit_acr_pend:
        delete tt_ped_vda_tit_acr_pend.
    end.

    assign v_cod_usuar_corren_ant = v_cod_usuar_corren.

    /* End_Include: i_eliminar_api_centraliz_integr_acr_vdr */


    for each tt_integr_acr_renegoc:
       assign v_log_error_renegoc_acr  = no           
              v_cod_empresa            = v_cod_empres_usuar
              v_cod_usuar_corren       = v_cod_usuar_corren
              v_cod_modul_dtsul_empres = "ACR" /*l_acr*/ 
              v_log_atualiza_renegoc   = tt_integr_acr_renegoc.ttv_log_atualiza_renegoc.

       /* Vari†vel v_val_tot deve ser zerada a cada novo Lote de Renegociaá∆o */
       assign v_log_atualizado = no
              v_val_tot        = 0.

       find first cliente no-lock
           where cliente.cod_empresa = v_cod_empres_usuar
             and cliente.cdn_cliente = tt_integr_acr_renegoc.tta_cdn_cliente no-error.
       if  not avail cliente
       then do:
          run pi_integr_acr_renegoc_erros(2827,tt_integr_acr_renegoc.tta_cod_estab,tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,"",tt_integr_acr_renegoc.tta_cdn_cliente,"","","","","","","").
          return "NOK" /*l_nok*/ .
       end.   


       /* verifica se foi informado titulo para a renegociaá∆o*/
       if not can-find(first tt_integr_acr_item_renegoc
                       where tt_integr_acr_item_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr) then do:
           run pi_integr_acr_renegoc_erros (Input 344,
                                            Input tt_integr_acr_renegoc.tta_cod_estab,
                                            Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "") /*pi_integr_acr_renegoc_erros*/.
       end.

       assign v_log_tit_acr_estordo = no.

       /* ** AtravÇs da vari†vel V_LOG_TIT_ACR_ESTORDO se controla se na seleá∆o dos t°tulos de renegociaá∆o s¢ foram escolhidos t°tulos estornados ou n∆o.***/
       block_estorno:
       for each tt_integr_acr_item_renegoc
          where tt_integr_acr_item_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr,
           each tit_acr exclusive-lock
          where tit_acr.cod_estab           = tt_integr_acr_item_renegoc.tta_cod_estab
            and tit_acr.num_id_tit_acr      = tt_integr_acr_item_renegoc.tta_num_id_tit_acr
            and tit_acr.log_tit_acr_estordo = yes:

            assign v_log_tit_acr_estordo = yes.
            leave block_estorno.
       end.

       /* verifica se os titulos que foram informados para renegociaªío estío cadastrados na base */
       for each tt_integr_acr_item_renegoc
           where tt_integr_acr_item_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:

           if tt_integr_acr_item_renegoc.tta_cod_motiv_movto_tit_acr <> "" then do:
               find first motiv_movto_tit_acr no-lock 
                  where motiv_movto_tit_acr.cod_estab               = tt_integr_acr_item_renegoc.tta_cod_estab
                  and   motiv_movto_tit_acr.cod_motiv_movto_tit_acr = tt_integr_acr_item_renegoc.tta_cod_motiv_movto_tit_acr no-error.
               if  not avail motiv_movto_tit_acr then do:
                   v_cod_parameters =  "Motivo Movimento ACR" /*l_motiv_movto_tit_acr*/  + "," + "Motivo Movimento ACR" /*l_motiv_movto_tit_acr*/  + ",,,,,,,".
                   run pi_integr_acr_renegoc_erros (Input 1284,
                                                    Input tt_integr_acr_renegoc.tta_cod_estab,
                                                    Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input "",
                                                    Input v_cod_parameters) /*pi_integr_acr_renegoc_erros*/.
               end.
           end.

           find first tit_acr no-lock
               where tit_acr.cod_estab       = tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr  /* leticia*/
                 and tit_acr.num_id_tit_acr  = tt_integr_acr_item_renegoc.tta_num_id_tit_acr no-error.
           if not avail tit_acr then do:
               run pi_integr_acr_renegoc_erros (Input 6033, 
                                                Input tt_integr_acr_renegoc.tta_cod_estab,
                                                Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "").
               return "NOK" /*l_nok*/ .
           end.
           else do:
               if  tit_acr.log_tit_acr_estordo
               then do:
                   delete tt_integr_acr_item_renegoc.
               end /* if */.
               else do:
                   if  tit_acr.ind_tip_cobr_acr = "Especial" /*l_especial*/ 
                   then do:
                       run pi_integr_acr_renegoc_erros (Input 20299,
                                                        Input tt_integr_acr_renegoc.tta_cod_estab,
                                                        Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "").
                       return "NOK" /*l_nok*/ .
                   end /* if */.

                   find first b_cart_bcia no-lock
                        where b_cart_bcia.cod_cart_bcia = tit_acr.cod_cart_bcia no-error.

                   if  tit_acr.cod_movto_operac_financ <> ?
                   and tit_acr.cod_movto_operac_financ  <> "" 
                   and (avail b_cart_bcia
                   and b_cart_bcia.ind_tip_cart_bcia    = "Desconto" /*l_desconto*/ )
                   then do:

                       run pi_integr_acr_renegoc_erros (Input 20301,
                                                        Input tt_integr_acr_renegoc.tta_cod_estab,
                                                        Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "",
                                                        Input "").
                       return "NOK" /*l_nok*/ .
                   end /* if */.
               end /* else */.           
           end /* else */.
       end.

       if  v_log_tit_acr_estordo
       then do:
           run pi_integr_acr_renegoc_erros (Input 20211,
                                            Input tt_integr_acr_renegoc.tta_cod_estab,
                                            Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "") /*pi_integr_acr_renegoc_erros*/.
           return "NOK" /*l_nok*/ .
       end /* if */.

       if not v_log_error_renegoc_acr then do:
           run pi_vld_acr_cria_renegoc.
           if  return-value = "NOK" /*l_nok*/ 
           then do:
              assign v_log_error_renegoc_acr = yes.
           end /* if */.
           else do:
              run pi_vld_renegoc_acr_substituicao.
              if return-value = "NOK" /*l_nok*/  then
                 assign v_log_error_renegoc_acr = yes.
           end /* else */.       
       end.

       if v_log_error_renegoc_acr then next.

       if not v_log_error_renegoc_acr then do:
           assign v_ind_espec_docto = "Aviso DÇbito" /*l_aviso_debito*/ .

           for each tt_repres_tit_acr_comis_ext:
               delete tt_repres_tit_acr_comis_ext.
           end.

           for each tt_integr_acr_item_renegoc
               where tt_integr_acr_item_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:           

               run pi_validar_usuar_estab_acr_renegoc.
               if  return-value = "NOK" /*l_nok*/ 
               then do:
                  return "NOK" /*l_nok*/ .
               end /* if */.

               find first tit_acr no-lock
                   where tit_acr.cod_estab      = tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr
                     and tit_acr.num_id_tit_acr = tt_integr_acr_item_renegoc.tta_num_id_tit_acr no-error.
               if  avail tit_acr then do:
                   find estabelecimento no-lock
                       where estabelecimento.cod_empresa = v_cod_empres_usuar
                       and   estabelecimento.cod_estab   = tit_acr.cod_estab no-error.
                   if  not avail estabelecimento
                   then do:
                       run pi_integr_acr_renegoc_erros(6099,tit_acr.cod_estab,"","","",tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                       delete renegoc_acr.
                       return "NOK" /*l_nok*/ .
                   end /* if */.    

                   if  can-find(first cart_bcia
                        where cart_bcia.cod_cart_bcia = tit_acr.cod_cart_bcia
                        and   cart_bcia.ind_tip_cart_bcia = "Vendor" /*l_vendor*/ )  then do:
                        assign v_cod_parameters = tit_acr.cod_cart_bcia  + ",,,,,,,,".
                        run pi_integr_acr_renegoc_erros(12157,tit_acr.cod_estab,"","","",tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                        delete renegoc_acr.
                        return "NOK" /*l_nok*/ .
                   end.

                   /* ## Caso o cliente da renegociaá∆o Ç diferente do t°tulo, verifica se a matriz Ç igual ##*/
                   if tit_acr.cdn_cliente <> tt_integr_acr_renegoc.tta_cdn_cliente then do:

                       /* Begin_Include: i_main_code_api_integr_acr_renegoc_8 */
                       find first cliente no-lock
                            where cliente.cod_empresa = tit_acr.cod_empresa
                              and cliente.cdn_cliente = tit_acr.cdn_cliente no-error.
                       if  (avail cliente)
                       then do:
                          find first pessoa_jurid no-lock
                               where pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa no-error.
                          if  avail pessoa_jurid
                          and v_log_pessoa_jurid_lote
                          then do:
                             find first b_cliente no-lock
                                  where b_cliente.cod_empresa = v_cod_empres_usuar
                                    and b_cliente.cdn_cliente = tt_integr_acr_renegoc.tta_cdn_cliente no-error.
                             if  (avail b_cliente)
                             then do:
                                find first b_pessoa_jurid no-lock
                                     where b_pessoa_jurid.num_pessoa_jurid = b_cliente.num_pessoa no-error.
                                if  avail b_pessoa_jurid
                                then do:
                                    if  pessoa_jurid.num_pessoa_jurid_matriz <> b_pessoa_jurid.num_pessoa_jurid_matriz
                                    then do:
                                       assign v_cod_parameters = string(pessoa_jurid.num_pessoa_jurid_matriz) + "," + string(b_pessoa_jurid.num_pessoa_jurid_matriz) + ",,,,,,,".
                                       run pi_integr_acr_renegoc_erros_help(13633,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                                       delete renegoc_acr.
                                       return "NOK" /*l_nok*/ .
                                    end /* if */.
                                end /* if */.
                                else do:
                                    find first pessoa_fisic no-lock
                                         where pessoa_fisic.num_pessoa_fisic = b_cliente.num_pessoa no-error.
                                    if  avail pessoa_fisic
                                    then do:
                                  &IF DEFINED(BF_FIN_MATRIZ_PESSOA) &THEN
                                        if  pessoa_jurid.num_pessoa_jurid_matriz <> pessoa_fisic.num_pessoa_fisic_matriz
                                        then do:
                                            assign v_cod_parameters = string(pessoa_jurid.num_pessoa_jurid) + ",,,,,,,,".
                                            run pi_integr_acr_renegoc_erros_help(13633,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                                            delete renegoc_acr.
                                            return "NOK" /*l_nok*/ .
                                        end /* if */.
                                  &ELSE
                                        assign v_cod_parameters = string(pessoa_jurid.num_pessoa_jurid) + ",,,,,,,,".
                                        run pi_integr_acr_renegoc_erros_help(20182,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                                        delete renegoc_acr.
                                        return "NOK" /*l_nok*/ .
                                  &ENDIF     
                                    end /* if */.
                                end /* else */.
                             end /* if */.
                          end /* if */.
                          else do:
                              assign v_log_pessoa_jurid_lote = no.

                              find first pessoa_fisic no-lock
                                   where pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa no-error.
                              if  avail pessoa_fisic
                              then do:
                                 find first b_cliente no-lock
                                      where b_cliente.cod_empresa = v_cod_empres_usuar
                                        and b_cliente.cdn_cliente = tt_integr_acr_renegoc.tta_cdn_cliente no-error.
                                 if  (avail b_cliente)
                                 then do:                                      
                                     find first b_pessoa_fisic no-lock
                                          where b_pessoa_fisic.num_pessoa_fisic = b_cliente.num_pessoa no-error.
                                     if  avail b_pessoa_fisic
                                     then do:

                                   &IF DEFINED(BF_FIN_MATRIZ_PESSOA) &THEN
                                         if  pessoa_fisic.num_pessoa_fisic_matriz <> b_pessoa_fisic.num_pessoa_fisic_matriz
                                         then do:
                                             assign v_cod_parameters = string(pessoa_fisic.num_pessoa_fisic) + ",,,,,,,,".
                                             run pi_integr_acr_renegoc_erros_help(22009,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                                             delete renegoc_acr.
                                             return "NOK" /*l_nok*/ .
                                         end /* if */.
                                   &ELSE
                                        if  pessoa_fisic.num_pessoa_fisic <> b_pessoa_fisic.num_pessoa_fisic
                                        then do:
                                           assign v_cod_parameters = string(cliente.cdn_cliente) + "," + string(b_cliente.cdn_cliente)  + ",,,,,,,".
                                           run pi_integr_acr_renegoc_erros_help(20181,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters). 
                                           delete renegoc_acr.
                                           return "NOK" /*l_nok*/ .
                                        end /* if */.
                                   &ENDIF 

                                     end /* if */.
                                     else do:
                                         find first pessoa_jurid no-lock
                                              where pessoa_jurid.num_pessoa_jurid = b_cliente.num_pessoa no-error.
                                         if  avail pessoa_jurid
                                         then do:

                                       &IF DEFINED(BF_FIN_MATRIZ_PESSOA) &THEN
                                         if  pessoa_fisic.num_pessoa_fisic_matriz <> pessoa_jurid.num_pessoa_jurid_matriz
                                         then do:
                                             assign v_cod_parameters = string(pessoa_fisic.num_pessoa_fisic) + ",,,,,,,,".
                                             run pi_integr_acr_renegoc_erros_help(22009,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters).
                                             delete renegoc_acr.
                                             return "NOK" /*l_nok*/ .
                                         end /* if */.            
                                       /*&ELSE
                                              assign v_cod_parameters = string(pessoa_fisic.num_pessoa_fisic) + ",,,,,,,,".
                                             run pi_integr_acr_renegoc_erros_help(20168,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","",v_cod_parameters). 
                                             delete renegoc_acr.
                                             return "NOK" /*l_nok*/ . */
                                       &ENDIF 

                                         end /* if */.
                                     end /* else */.
                                 end /* if */.
                              end /* if */.
                          end /* else */.
                       end /* if */.
                       else do:
                          run pi_integr_acr_renegoc_erros(2827,tit_acr.cod_estab,"","",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                          delete renegoc_acr.
                          return "NOK" /*l_nok*/ .
                       end /* else */.
                       /* End_Include: i_main_code_api_integr_acr_renegoc_8 */

                   end.

                   if tit_acr.log_tit_acr_cobr_bcia then do:
                      if can-find(first movto_ocor_bcia no-lock use-index mvtcrbc_id
                         where  movto_ocor_bcia.cod_estab                  = tit_acr.cod_estab
                           and  movto_ocor_bcia.num_id_tit_acr             = tit_acr.num_id_tit_acr
                           and  movto_ocor_bcia.cod_portador               = tit_acr.cod_portador
                           and  movto_ocor_bcia.cod_cart_bcia              = tit_acr.cod_cart_bcia
                           and  movto_ocor_bcia.ind_ocor_bcia_remes_ret    = "Remessa" /*l_remessa*/ 
                           and  movto_ocor_bcia.ind_tip_ocor_bcia          = "Implantaá∆o" /*l_implantacao*/ 
                           and  movto_ocor_bcia.log_movto_envdo_bco        = yes
                           and  movto_ocor_bcia.log_confir_movto_envdo_bco = no
                           and (movto_ocor_bcia.num_id_movto_ocor_confir   = 0
                           or  movto_ocor_bcia.num_id_movto_ocor_confir   = ?)) then do:
                         run pi_integr_acr_renegoc_erros(8874,tt_integr_acr_item_renegoc.tta_cod_estab,tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr,"",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                         delete renegoc_acr.
                         return "NOK" /*l_nok*/ .
                      end.
                   end.

                   find espec_docto no-lock
                       where espec_docto.cod_espec_docto = tit_acr.cod_espec_docto no-error.
                   if  avail espec_docto
                   and espec_docto.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/  then
                       assign v_ind_espec_docto = "Normal" /*l_normal*/ .

                   if  tit_acr.ind_tip_espec_docto <> "Normal" /*l_normal*/ 
                   and tit_acr.ind_tip_espec_docto <> "Nota Fiscal" /*l_nota_fiscal*/ 
                   and tit_acr.ind_tip_espec_docto <> "Nota Promiss¢ria" /*l_nota_promissoria*/ 
                   and tit_acr.ind_tip_espec_docto <> "Nota de DÇbito" /*l_nota_de_debito*/ 
                   and tit_acr.ind_tip_espec_docto <> "Aviso DÇbito" /*l_aviso_debito*/ 
                   and tit_acr.ind_tip_espec_docto <> "Cheques Recebidos" /*l_cheques_recebidos*/ 
                   then do:
                      run pi_integr_acr_renegoc_erros(6076,tit_acr.cod_estab,"","","",tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                      delete renegoc_acr.
                      return "NOK" /*l_nok*/ .
                   end /* if */.                  

                   if  (tit_acr.dat_transacao > tt_integr_acr_renegoc.tta_dat_transacao)
                   then do:
                       run pi_integr_acr_renegoc_erros(2261,tit_acr.cod_estab,"","","",tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                       delete renegoc_acr.
                       return "NOK" /*l_nok*/ .
                   end /* if */.    

                   if  (tit_acr.val_sdo_tit_acr <= 0)
                   then do:
                       run pi_integr_acr_renegoc_erros(707,tit_acr.cod_estab,"","","",tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                       delete renegoc_acr.
                       return "NOK" /*l_nok*/ .
                   end /* if */.    

                   run pi_confere_dados_comissao.
                   if  return-value = "NOK" /*l_nok*/ 
                   then do:
                      delete renegoc_acr.
                      return "NOK" /*l_nok*/ .
                   end /* if */.

                   if v_log_atualizado = no then do:
                      assign v_log_atualizado = yes. 
                      if tt_integr_acr_renegoc.tta_cod_indic_econ = '' then do:
                         find renegoc_acr exclusive-lock
                            where renegoc_acr.cod_estab            = tt_integr_acr_renegoc.tta_cod_estab
                            and   renegoc_acr.num_renegoc_cobr_acr = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr no-error.
                         if avail renegoc_acr then
                            assign renegoc_acr.cod_indic_econ = tit_acr.cod_indic_econ.
                      end.
                   end.

                   find param_integr_ems no-lock
                       where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
                   if  avail param_integr_ems then do:

                       for each tt_log_erros:
                           delete tt_log_erros.
                       end.

                       for each tt_log_erros_atualiz:
                           delete tt_log_erros_atualiz.
                       end.

                       run pi_valida_integracao_cambio(output table tt_log_erros).

                       find first tt_log_erros where tt_log_erros.ttv_num_cod_erro <> 0 no-error.
                       if avail tt_log_erros then do:
                           for each tt_log_erros:
                               create tt_log_erros_atualiz.
                               assign tt_log_erros_atualiz.tta_cod_estab       = tt_integr_acr_renegoc.tta_cod_estab
                                      tt_log_erros_atualiz.tta_cod_refer       = string(tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr)
                                      tt_log_erros_atualiz.ttv_num_mensagem    = tt_log_erros.ttv_num_cod_erro
                                      tt_log_erros_atualiz.ttv_ind_tip_relacto = ""
                                      tt_log_erros_atualiz.ttv_num_relacto     = 0
                                      tt_log_erros_atualiz.ttv_des_msg_erro    = tt_log_erros.ttv_des_erro.
                                      tt_log_erros_atualiz.ttv_des_msg_ajuda   = tt_log_erros.ttv_des_ajuda.
                           end.
                       end.
                   end.

                   find first b_item_renegoc_acr_verif no-lock
                     where b_item_renegoc_acr_verif.cod_estab_tit_acr = tit_acr.cod_estab
                     and   b_item_renegoc_acr_verif.num_id_tit_acr    = tit_acr.num_id_tit_acr no-error.
                   if avail b_item_renegoc_acr_verif then do:
                      find first b_renegoc_acr no-lock
                        where b_renegoc_acr.cod_estab = b_item_renegoc_acr_verif.cod_estab
                        and   b_renegoc_acr.num_renegoc_cobr_acr = b_item_renegoc_acr_verif.num_renegoc_cobr_acr no-error.
                      if  avail b_renegoc_acr
                      and b_renegoc_acr.ind_sit_renegoc_acr <> "Atualizado" /*l_atualizado*/ 
                      then do:
                         run pi_integr_acr_renegoc_erros(6202,tit_acr.cod_estab,tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,"",tit_acr.cdn_cliente,tit_acr.cod_espec_docto,tit_acr.cod_ser_docto,tit_acr.cod_tit_acr,tit_acr.cod_parcela,"","","").
                         delete renegoc_acr.
                         return "NOK" /*l_nok*/ .
                      end /* if */.   
                   end.
                   if(v_log_error_renegoc_acr = no) then do:
                      run pi_verificar_sdo_tit_acr_integr.
                      run pi_vld_acr_cria_item_renegoc.
                   end.

                   assign v_val_tot_renegoc_tit_acr = v_val_tot_renegoc_tit_acr + tit_acr.val_sdo_tit_acr.

                   for each  ped_vda_tit_acr no-lock
                       where ped_vda_tit_acr.cod_estab      = tit_acr.cod_estab
                       and   ped_vda_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:
                       find tt_ped_vda_tit_acr_pend no-lock
                            where tt_ped_vda_tit_acr_pend.tta_cod_ped_vda = ped_vda_tit_acr.cod_ped_vda no-error.
                       if not avail tt_ped_vda_tit_acr_pend then do:
                          create tt_ped_vda_tit_acr_pend.
                          assign tt_ped_vda_tit_acr_pend.tta_cod_estab     = ped_vda_tit_acr.cod_estab
                                 tt_ped_vda_tit_acr_pend.tta_num_seq_refer = tt_ped_vda_tit_acr_pend.tta_num_seq_refer + 1 
                                 tt_ped_vda_tit_acr_pend.tta_cod_ped_vda   = ped_vda_tit_acr.cod_ped_vda
                                 tt_ped_vda_tit_acr_pend.tta_cod_ped_vda_repres        = ped_vda_tit_acr.cod_ped_vda_repres
                                 tt_ped_vda_tit_acr_pend.tta_val_perc_particip_ped_vda = ped_vda_tit_acr.val_perc_particip_ped_vda
                                 tt_ped_vda_tit_acr_pend.tta_des_ped_vda     = ped_vda_tit_acr.des_ped_vda
                                 tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr = (tit_acr.val_sdo_tit_acr * ped_vda_tit_acr.val_perc_particip_ped_vda) / 100.
                       end.
                       else
                          assign tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr = tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr + ((tit_acr.val_sdo_tit_acr * ped_vda_tit_acr.val_perc_particip_ped_vda) / 100).
                   end.
               end.
               else do:
                   run pi_integr_acr_renegoc_erros(6033,tt_integr_acr_item_renegoc.tta_cod_estab,tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr,"","","","","","","","",""). 
                   delete renegoc_acr.
                   return "NOK" /*l_nok*/ .
               end /* else */.    

               find tit_acr exclusive-lock
                   where tit_acr.cod_estab      = tt_integr_acr_item_renegoc.tta_cod_estab
                   and   tit_acr.num_id_tit_acr = tt_integr_acr_item_renegoc.tta_num_id_tit_acr no-error.
               if avail tit_acr and tit_acr.dat_indcao_perda_dedut <> date(12,31,9999) then
                  ASSIGN tit_acr.dat_indcao_perda_dedut = date(12,31,9999).

           end. /* for each tt_integr_acr_item_renegoc */

           /* Grava a tt-integr-acr-item-lote-impl p/ o renegoc-acr, p/ se apresentar erros na validacao gravar o renegoc-acr */.

           find first tt_integr_acr_item_renegoc_new no-lock
                where tt_integr_acr_item_renegoc_new.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr no-error.
           if avail tt_integr_acr_item_renegoc_new then do:
               assign renegoc_acr.cod_tit_acr = tt_integr_acr_item_renegoc_new.tta_cod_tit_acr.
               run pi_for_each_tt_integr_acr_item_lote_impl.

               find renegoc_acr exclusive-lock
                  where renegoc_acr.cod_estab            = tt_integr_acr_renegoc.tta_cod_estab
                  and   renegoc_acr.num_renegoc_cobr_acr = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr no-error.
               if avail renegoc_acr then
                  assign renegoc_acr.val_renegoc_cobr_acr = v_val_tot
                         renegoc_acr.qtd_parc_renegoc     = v_num_cont_tit_acr.
           end.
           else do:
               run pi_api_item_renegoc_acr_subst_tit_novos /*pi_api_item_renegoc_acr_subst_tit_novos*/.
           end.

           /* verifica se foi informado mais de uma vez a mesma pessoa pra ser fiador/testemunha */
           for each tt_integr_acr_fiador_renegoc
               where tt_integr_acr_fiador_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:
               assign v_num_cont_aux = 0.
               for each btt_integr_acr_fiador_renegoc
                   where btt_integr_acr_fiador_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr
                     and btt_integr_acr_fiador_renegoc.tta_num_pessoa = tt_integr_acr_fiador_renegoc.tta_num_pessoa:
                         assign v_num_cont_aux = v_num_cont_aux + 1.
               end.
               if v_num_cont_aux > 1 then do:
                   run pi_integr_acr_renegoc_erros(20111,tt_integr_acr_renegoc.tta_cod_estab,tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,"","","","","","","","","").
                   return "NOK" /*l_nok*/ .
               end.
           end.


           for each tt_integr_acr_fiador_renegoc
               where tt_integr_acr_fiador_renegoc.ttv_rec_renegoc_acr = tt_integr_acr_renegoc.ttv_rec_renegoc_acr:
               if tt_integr_acr_fiador_renegoc.tta_ind_tip_pessoa = "F°sica" /*l_fisica*/  then do:
                   find first pessoa_fisic no-lock
                     where pessoa_fisic.num_pessoa_fisic = tt_integr_acr_fiador_renegoc.tta_num_pessoa
                     no-error.
                   if avail pessoa_fisic then do:
                       assign  v_num_pessoa_fiador_renegoc    = pessoa_fisic.num_pessoa_fisic
                               v_des_nom_abrev_fiador_renegoc = pessoa_fisic.nom_pessoa.
                       run pi_vld_acr_cria_fiador_renegoc.
                   end.
                   else do:
                       run pi_integr_acr_renegoc_erros(10689,tt_integr_acr_renegoc.tta_cod_estab,tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,"","","","","","","","","").
                       return "NOK" /*l_nok*/ .
                   end /* else */.    
               end.
               else do:
                   find first pessoa_jurid no-lock
                     where pessoa_jurid.num_pessoa_jurid = tt_integr_acr_fiador_renegoc.tta_num_pessoa
                     no-error.
                   if avail pessoa_jurid then do:
                       assign v_num_pessoa_fiador_renegoc    = pessoa_jurid.num_pessoa_jurid
                              v_des_nom_abrev_fiador_renegoc = pessoa_jurid.nom_pessoa.
                       run pi_vld_acr_cria_fiador_renegoc.
                   end.
                   else do:
                       run pi_integr_acr_renegoc_erros(10689,tt_integr_acr_renegoc.tta_cod_estab,tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,"","","","","","","","","").
                       return "NOK" /*l_nok*/ .
                   end /* else */.    
               end.
           end.
           if v_log_error_renegoc_acr = no and v_log_atualiza_renegoc = yes then do:
               assign v_rec_renegoc_acr = recid(renegoc_acr).
               for each tt_log_erros_atualiz:
                   delete tt_log_erros_atualiz.
               end.
               run pi_criticar_atualizacao_renegoc_subst_acr /*pi_criticar_atualizacao_renegoc_subst_acr*/.

               find first tt_log_erros_atualiz no-lock no-error.
               if avail tt_log_erros_atualiz then do:
                  assign v_log_error_renegoc_acr = yes.
                  for each tt_log_erros_atualiz:
                      create tt_log_erros_renegoc.
                      assign tt_log_erros_renegoc.tta_cod_estab                = tt_integr_acr_renegoc.tta_cod_estab
                             tt_log_erros_renegoc.tta_num_renegoc_cobr_acr     = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                             tt_log_erros_renegoc.tta_num_seq_item_renegoc_acr = tt_log_erros_atualiz.tta_num_seq_refer
                             tt_log_erros_renegoc.tta_num_mensagem             = tt_log_erros_atualiz.ttv_num_mensagem 
                             tt_log_erros_renegoc.ttv_des_msg                  = tt_log_erros_atualiz.ttv_des_msg_erro
                             tt_log_erros_renegoc.ttv_des_help                 = tt_log_erros_atualiz.ttv_des_msg_ajuda.
                  end.
               end.
               else do:
                   run pi_controlar_renegoc_acr_subst_atualiza /*pi_controlar_renegoc_acr_subst_atualiza*/.
                   if can-find(first tt_log_erros_atualiz) then do:
                      assign v_log_error_renegoc_acr = yes.
                      for each tt_log_erros_atualiz:
                          create tt_log_erros_renegoc.
                          assign tt_log_erros_renegoc.tta_cod_estab                = tt_integr_acr_renegoc.tta_cod_estab
                                 tt_log_erros_renegoc.tta_num_renegoc_cobr_acr     = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                                 tt_log_erros_renegoc.tta_num_seq_item_renegoc_acr = tt_log_erros_atualiz.tta_num_seq_refer
                                 tt_log_erros_renegoc.tta_num_mensagem             = tt_log_erros_atualiz.ttv_num_mensagem 
                                 tt_log_erros_renegoc.ttv_des_msg                  = tt_log_erros_atualiz.ttv_des_msg_erro
                                 tt_log_erros_renegoc.ttv_des_help                 = tt_log_erros_atualiz.ttv_des_msg_ajuda.
                      end.
                   end.
               end.
           end.
       end.

       if (v_log_error_renegoc_acr = yes) then do:
           find renegoc_acr exclusive-lock
             where renegoc_acr.cod_estab             = tt_integr_acr_renegoc.tta_cod_estab
             and   renegoc_acr.num_renegoc_cobr_acr  = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr no-error.
           if avail renegoc_acr then do:
              for each item_renegoc_acr exclusive-lock
                  where item_renegoc_acr.cod_estab             = renegoc_acr.cod_estab
                  and   item_renegoc_acr.num_renegoc_cobr_acr  = renegoc_acr.num_renegoc_cobr_acr:
                  delete item_renegoc_acr.
              end.
              for each item_lote_impl_tit_acr exclusive-lock
                  where item_lote_impl_tit_acr.cod_estab             = renegoc_acr.cod_estab
                  and   item_lote_impl_tit_acr.num_renegoc_cobr_acr  = renegoc_acr.num_renegoc_cobr_acr:
                  delete item_lote_impl_tit_acr.
              end.
              for each fiador_renegoc exclusive-lock
                  where fiador_renegoc.cod_estab             = renegoc_acr.cod_estab
                  and   fiador_renegoc.num_renegoc_cobr_acr  = renegoc_acr.num_renegoc_cobr_acr:
                  delete fiador_renegoc.
              end.
              delete renegoc_acr.
           end.
       end.
    end.

    assign v_cod_usuar_corren = v_cod_usuar_corren_ant.

    IF VALID-HANDLE(v_hdl_funcao_padr) THEN
        DELETE PROCEDURE v_hdl_funcao_padr.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_main_code_api_integr_acr_renegoc_8 */
/*****************************************************************************
** Procedure Interna.....: pi_api_item_renegoc_acr_subst_tit_novos
** Descricao.............: pi_api_item_renegoc_acr_subst_tit_novos
** Criado por............: fut31947
** Criado em.............: 11/09/2009 09:02:08
** Alterado por..........: fut41061
** Alterado em...........: 14/04/2010 13:58:15
*****************************************************************************/
PROCEDURE pi_api_item_renegoc_acr_subst_tit_novos:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_impl_tit_acr
        for item_lote_impl_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_lista_parc
        as character
        format "x(8)":U
        no-undo.
    def var v_cod_proces_export
        as character
        format "x(12)":U
        label "Processo Exportaá∆o"
        column-label "Processo Exportaá∆o"
        no-undo.
    def var v_log_controle
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_log_erro
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_log_incl
        as logical
        format "Sim/Nao"
        initial no
        no-undo.
    def var v_log_soma_movto_cobr
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        label "Soma Custo Mov Cob"
        column-label "Soma Custo Mov Cob"
        no-undo.
    def var v_num_dias_vencto_renegoc
        as integer
        format ">9":U
        label "Dias Vencimentto"
        column-label "Dias Vencimento"
        no-undo.
    def var v_rec_renegoc_acr
        as recid
        format ">>>>>>9":U
        initial ?
        no-undo.
    def var v_val_acresc_parc
        as decimal
        format ">>9.99":U
        decimals 2
        label "Acrescimo Parcela"
        column-label "Acrescimo Parcela"
        no-undo.
    def var v_val_parcela
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_val_tot_cust_movto_cobr
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        label "Total Custo Movto"
        column-label "Total Custo Movto"
        no-undo.
    def var v_dat_vencto_tit_acr             as date            no-undo. /*local*/
    def var v_num_ano                        as integer         no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/
    def var v_num_dia                        as integer         no-undo. /*local*/
    def var v_num_mes                        as integer         no-undo. /*local*/
    def var v_val_acum_perc                  as decimal         no-undo. /*local*/
    def var v_val_maior_perc                 as decimal         no-undo. /*local*/
    def var v_val_taxa                       as decimal         no-undo. /*local*/
    def var v_val_tot_parc_renegoc           as decimal         no-undo. /*local*/
    def var v_val_tot_renegoc_acr            as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if tt_integr_acr_renegoc.tta_cod_tit_acr = "" then do:
        run pi_integr_acr_renegoc_erros (Input 6289,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "") /*pi_integr_acr_renegoc_erros*/.
    end.

    do  on error undo, return error:

        &if '{&emsuni_version}' > '5.01' &then
            assign v_val_acresc_parc         = renegoc_acr.val_acresc_parc
                   v_log_soma_movto_cobr     = renegoc_acr.log_soma_movto_cobr
                   v_num_dias_vencto_renegoc = renegoc_acr.num_dias_vencto_renegoc.
        &else
            assign v_val_acresc_parc         = renegoc_acr.val_livre_1
                   v_log_soma_movto_cobr     = renegoc_acr.log_livre_1
                   v_num_dias_vencto_renegoc = renegoc_acr.num_livre_1.
        &endif

        assign v_rec_renegoc_acr = recid(renegoc_acr)
               v_log_incl = no.

        run pi_vld_renegoc_acr_subst_novos (Input no) /*pi_vld_renegoc_acr_subst_novos*/.

        /* Cria Tabela Tempor†ria utilizada na API com os t°tulos renegociados. */
        for each tt_item_renegoc_acr:
            delete tt_item_renegoc_acr.
        end.
        for each tt_ped_vda_tit_acr_pend:
            delete tt_ped_vda_tit_acr_pend.
        end.
        for each item_renegoc_acr no-lock
           where item_renegoc_acr.cod_estab            = renegoc_acr.cod_estab
           and   item_renegoc_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr:        
           create tt_item_renegoc_acr.
           assign tt_item_renegoc_acr.cod_estab                 = item_renegoc_acr.cod_estab
                  tt_item_renegoc_acr.num_renegoc_cobr_acr      = item_renegoc_acr.num_renegoc_cobr_acr
                  tt_item_renegoc_acr.num_seq_item_renegoc_acr  = item_renegoc_acr.num_seq_item_renegoc_acr
                  tt_item_renegoc_acr.cod_estab_tit_acr         = item_renegoc_acr.cod_estab_tit_acr
                  tt_item_renegoc_acr.num_id_tit_acr            = item_renegoc_acr.num_id_tit_acr
                  tt_item_renegoc_acr.dat_novo_vencto_tit_acr   = item_renegoc_acr.dat_novo_vencto_tit_acr
                  tt_item_renegoc_acr.val_juros_renegoc_tit_acr = item_renegoc_acr.val_juros_renegoc_tit_acr
                  tt_item_renegoc_acr.val_multa_renegoc_tit_acr = item_renegoc_acr.val_multa_renegoc_tit_acr
                  tt_item_renegoc_acr.val_juros_renegoc_calcul  = item_renegoc_acr.val_juros_renegoc_calcul
                  tt_item_renegoc_acr.val_multa_renegoc_calcul  = item_renegoc_acr.val_multa_renegoc_calcul.

           find tit_acr no-lock
               where tit_acr.cod_estab      = item_renegoc_acr.cod_estab_tit_acr
               and   tit_acr.num_id_tit_acr = item_renegoc_acr.num_id_tit_acr no-error.

           assign v_val_tot_renegoc_tit_acr = v_val_tot_renegoc_tit_acr + tit_acr.val_sdo_tit_acr.

           if v_cod_pais_empres_usuar = 'BRA' then do:
               &if '{&EMSFIN_VERSION}' >= '5.06' &then
                   assign v_val_tot_cr_pis        = v_val_tot_cr_pis    + (tit_acr.val_cr_pis          * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                          v_val_tot_cr_cofins     = v_val_tot_cr_cofins + (tit_acr.val_cr_cofins       * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                          v_val_tot_cr_csll       = v_val_tot_cr_csll   + (tit_acr.val_cr_csll         * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                          v_val_tot_base_calc     = v_val_tot_base_calc + (tit_acr.val_base_calc_impto * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                          v_log_retenc_impto_impl = tit_acr.log_retenc_impto_impl.
               &else
                   find first tab_livre_emsfin
                       where tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                       and   tab_livre_emsfin.cod_tab_dic_dtsul    = 'TIT_ACR_IMPTO_CR'
                       and   tab_livre_emsfin.cod_compon_1_idx_tab = tit_acr.cod_estab
                       and   tab_livre_emsfin.cod_compon_2_idx_tab = string(tit_acr.num_id_tit_acr)
                       no-lock no-error.
                   if  avail tab_livre_emsfin
                   then do:
                       assign v_val_tot_cr_pis    = v_val_tot_cr_pis    + (dec(entry(1,tab_livre_emsfin.cod_livre_1,chr(24))) * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                              v_val_tot_cr_cofins = v_val_tot_cr_cofins + (dec(entry(2,tab_livre_emsfin.cod_livre_1,chr(24))) * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                              v_val_tot_cr_csll   = v_val_tot_cr_csll   + (dec(entry(3,tab_livre_emsfin.cod_livre_1,chr(24))) * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr).
                       if num-entries(tab_livre_emsfin.cod_livre_1,chr(24)) >= 5 then       
                           assign v_val_tot_base_calc     = v_val_tot_base_calc + (dec(entry(4,tab_livre_emsfin.cod_livre_1,chr(24))) * tit_acr.val_sdo_tit_acr / tit_acr.val_liq_tit_acr)
                                  v_log_retenc_impto_impl = (entry(5,tab_livre_emsfin.cod_livre_1,chr(24)) = "yes" /*l_yes*/ ).
                   end /* if */.
               &endif
           end.

           for each ped_vda_tit_acr no-lock
               where ped_vda_tit_acr.cod_estab      = tit_acr.cod_estab
               and   ped_vda_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:

               find tt_ped_vda_tit_acr_pend no-lock
                   where tt_ped_vda_tit_acr_pend.tta_cod_ped_vda        = ped_vda_tit_acr.cod_ped_vda no-error.
               if  not avail tt_ped_vda_tit_acr_pend
               then do:
                   create tt_ped_vda_tit_acr_pend.
                   assign tt_ped_vda_tit_acr_pend.tta_cod_estab     = ped_vda_tit_acr.cod_estab
                          tt_ped_vda_tit_acr_pend.tta_num_seq_refer = tt_ped_vda_tit_acr_pend.tta_num_seq_refer + 1 
                          tt_ped_vda_tit_acr_pend.tta_cod_ped_vda   = ped_vda_tit_acr.cod_ped_vda
                          tt_ped_vda_tit_acr_pend.tta_cod_ped_vda_repres        = ped_vda_tit_acr.cod_ped_vda_repres
                          tt_ped_vda_tit_acr_pend.tta_val_perc_particip_ped_vda = ped_vda_tit_acr.val_perc_particip_ped_vda
                          tt_ped_vda_tit_acr_pend.tta_des_ped_vda   = ped_vda_tit_acr.des_ped_vda
                          tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr = (tit_acr.val_sdo_tit_acr * ped_vda_tit_acr.val_perc_particip_ped_vda) / 100.
               end /* if */.
               else do:
                   assign tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr = tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr + ((tit_acr.val_sdo_tit_acr * ped_vda_tit_acr.val_perc_particip_ped_vda) / 100).
               end /* else */.
           end.
        end.

        find first b_item_lote_impl_tit_acr no-lock
             where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
             and   b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr no-error.

        if  avail b_item_lote_impl_tit_acr
        then do:
            if renegoc_acr.cod_tit_acr = "" then
                run pi_integr_acr_renegoc_erros (Input 344,
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "",
                                                 Input "") /*pi_integr_acr_renegoc_erros*/.

            for each tt_item_lote_impl_tit_acr exclusive-lock:
               delete tt_item_lote_impl_tit_acr.
            end.
            assign v_cod_lista_parc = ''.
            for each b_item_lote_impl_tit_acr exclusive-lock 
               where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
                 and b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
               break by b_item_lote_impl_tit_acr.num_seq_refer:
                create tt_item_lote_impl_tit_acr.
                assign tt_item_lote_impl_tit_acr.cod_estab     = b_item_lote_impl_tit_acr.cod_estab
                       tt_item_lote_impl_tit_acr.cod_estab     = b_item_lote_impl_tit_acr.cod_estab
                       tt_item_lote_impl_tit_acr.cod_refer     = b_item_lote_impl_tit_acr.cod_refer
                       tt_item_lote_impl_tit_acr.num_seq_refer = b_item_lote_impl_tit_acr.num_seq_refer.
                assign tt_item_lote_impl_tit_acr.cod_empresa                = b_item_lote_impl_tit_acr.cod_empresa
                       tt_item_lote_impl_tit_acr.cod_estab                  = b_item_lote_impl_tit_acr.cod_estab
    &if '{&emsfin_version}' >= "5.07" &then
                       tt_item_lote_impl_tit_acr.cod_estab                  = b_item_lote_impl_tit_acr.cod_estab
    &endif
                       tt_item_lote_impl_tit_acr.cdn_cliente                = b_item_lote_impl_tit_acr.cdn_cliente
                       tt_item_lote_impl_tit_acr.cdn_repres                 = b_item_lote_impl_tit_acr.cdn_repres
                       tt_item_lote_impl_tit_acr.cod_espec_docto            = b_item_lote_impl_tit_acr.cod_espec_docto
                       tt_item_lote_impl_tit_acr.cod_ser_docto              = b_item_lote_impl_tit_acr.cod_ser_docto
                       tt_item_lote_impl_tit_acr.cod_tit_acr                = b_item_lote_impl_tit_acr.cod_tit_acr
                       tt_item_lote_impl_tit_acr.cod_parcela                = b_item_lote_impl_tit_acr.cod_parcela
                       tt_item_lote_impl_tit_acr.cod_indic_econ             = b_item_lote_impl_tit_acr.cod_indic_econ
                       tt_item_lote_impl_tit_acr.cod_portador               = b_item_lote_impl_tit_acr.cod_portador
                       tt_item_lote_impl_tit_acr.cod_cart_bcia              = b_item_lote_impl_tit_acr.cod_cart_bcia
                       tt_item_lote_impl_tit_acr.cod_cond_cobr              = b_item_lote_impl_tit_acr.cod_cond_cobr
                       tt_item_lote_impl_tit_acr.cod_motiv_movto_tit_acr    = b_item_lote_impl_tit_acr.cod_motiv_movto_tit_acr
                       tt_item_lote_impl_tit_acr.cod_contrat_vda            = b_item_lote_impl_tit_acr.cod_contrat_vda
                       tt_item_lote_impl_tit_acr.cod_proj_invest            = b_item_lote_impl_tit_acr.cod_proj_invest
                       tt_item_lote_impl_tit_acr.cod_histor_padr            = b_item_lote_impl_tit_acr.cod_histor_padr
                       tt_item_lote_impl_tit_acr.dat_vencto_tit_acr         = b_item_lote_impl_tit_acr.dat_vencto_tit_acr
                       tt_item_lote_impl_tit_acr.dat_prev_liquidac          = b_item_lote_impl_tit_acr.dat_prev_liquidac
                       tt_item_lote_impl_tit_acr.dat_desconto               = b_item_lote_impl_tit_acr.dat_desconto
                       tt_item_lote_impl_tit_acr.dat_emis_docto             = b_item_lote_impl_tit_acr.dat_emis_docto
                       tt_item_lote_impl_tit_acr.dat_compra_cartao_cr       = b_item_lote_impl_tit_acr.dat_compra_cartao_cr
                       tt_item_lote_impl_tit_acr.val_tit_acr                = b_item_lote_impl_tit_acr.val_tit_acr
                       tt_item_lote_impl_tit_acr.val_liq_tit_acr            = b_item_lote_impl_tit_acr.val_liq_tit_acr
                       tt_item_lote_impl_tit_acr.val_abat_tit_acr           = b_item_lote_impl_tit_acr.val_abat_tit_acr
                       tt_item_lote_impl_tit_acr.val_desconto               = b_item_lote_impl_tit_acr.val_desconto
                       tt_item_lote_impl_tit_acr.val_perc_desc              = b_item_lote_impl_tit_acr.val_perc_desc
                       tt_item_lote_impl_tit_acr.val_perc_juros_dia_atraso  = b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso
                       tt_item_lote_impl_tit_acr.val_perc_multa_atraso      = b_item_lote_impl_tit_acr.val_perc_multa_atraso
                       tt_item_lote_impl_tit_acr.val_ajust_val_tit_acr      = b_item_lote_impl_tit_acr.val_ajust_val_tit_acr
                       tt_item_lote_impl_tit_acr.des_text_histor            = b_item_lote_impl_tit_acr.des_text_histor
                       tt_item_lote_impl_tit_acr.ind_tip_espec_docto        = b_item_lote_impl_tit_acr.ind_tip_espec_docto
                       tt_item_lote_impl_tit_acr.ind_sit_tit_acr            = b_item_lote_impl_tit_acr.ind_sit_tit_acr
                       tt_item_lote_impl_tit_acr.ind_ender_cobr             = b_item_lote_impl_tit_acr.ind_ender_cobr
                       tt_item_lote_impl_tit_acr.cod_banco                  = b_item_lote_impl_tit_acr.cod_banco
                       tt_item_lote_impl_tit_acr.cod_agenc_bcia             = b_item_lote_impl_tit_acr.cod_agenc_bcia
                       tt_item_lote_impl_tit_acr.cod_cta_corren_bco         = b_item_lote_impl_tit_acr.cod_cta_corren_bco
                       tt_item_lote_impl_tit_acr.cod_digito_cta_corren      = b_item_lote_impl_tit_acr.cod_digito_cta_corren
                       tt_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto   = b_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto
                       tt_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto   = b_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto
                       tt_item_lote_impl_tit_acr.nom_abrev_contat           = b_item_lote_impl_tit_acr.nom_abrev_contat
                       tt_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr  = b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr
                       tt_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr  = b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr
                       tt_item_lote_impl_tit_acr.log_liquidac_autom         = b_item_lote_impl_tit_acr.log_liquidac_autom
                       tt_item_lote_impl_tit_acr.log_rat_val_ok             = b_item_lote_impl_tit_acr.log_rat_val_ok
                       tt_item_lote_impl_tit_acr.log_db_autom               = b_item_lote_impl_tit_acr.log_db_autom
                       tt_item_lote_impl_tit_acr.log_destinac_cobr          = b_item_lote_impl_tit_acr.log_destinac_cobr
                       tt_item_lote_impl_tit_acr.log_tip_cr_perda_dedut_tit = b_item_lote_impl_tit_acr.log_tip_cr_perda_dedut_tit
                       tt_item_lote_impl_tit_acr.cod_admdra_cartao_cr       = b_item_lote_impl_tit_acr.cod_admdra_cartao_cr
                       tt_item_lote_impl_tit_acr.cod_cartcred               = b_item_lote_impl_tit_acr.cod_cartcred
                       tt_item_lote_impl_tit_acr.cod_autoriz_cartao_cr      = b_item_lote_impl_tit_acr.cod_autoriz_cartao_cr
                       tt_item_lote_impl_tit_acr.cod_mes_ano_valid_cartao   = b_item_lote_impl_tit_acr.cod_mes_ano_valid_cartao
                       tt_item_lote_impl_tit_acr.cod_conces_telef           = b_item_lote_impl_tit_acr.cod_conces_telef
                       tt_item_lote_impl_tit_acr.num_ddd_localid_conces     = b_item_lote_impl_tit_acr.num_ddd_localid_conces
                       tt_item_lote_impl_tit_acr.num_prefix_localid_conces  = b_item_lote_impl_tit_acr.num_prefix_localid_conces
                       tt_item_lote_impl_tit_acr.num_milhar_localid_conces  = b_item_lote_impl_tit_acr.num_milhar_localid_conces
                       tt_item_lote_impl_tit_acr.num_renegoc_cobr_acr       = b_item_lote_impl_tit_acr.num_renegoc_cobr_acr
    &if '{&emsfin_version}' >= "5.02" &then
                       tt_item_lote_impl_tit_acr.log_val_fix_parc           = b_item_lote_impl_tit_acr.log_val_fix_parc
    &endif
    &if '{&emsfin_version}' >= "5.02" &then
                       tt_item_lote_impl_tit_acr.cod_tit_acr_bco            = b_item_lote_impl_tit_acr.cod_tit_acr_bco
    &endif
    &if '{&emsfin_version}' >= "5.02" &then
                       tt_item_lote_impl_tit_acr.ind_sit_bcia_tit_acr       = b_item_lote_impl_tit_acr.ind_sit_bcia_tit_acr
    &endif
    &if '{&emsfin_version}' >= "5.02" &then
                       tt_item_lote_impl_tit_acr.des_observacao             = b_item_lote_impl_tit_acr.des_observacao
    &endif
    &if '{&emsfin_version}' >= "5.02" &then
                       tt_item_lote_impl_tit_acr.des_obs_cobr               = b_item_lote_impl_tit_acr.des_obs_cobr
    &endif
    &if '{&emsfin_version}' >= "5.03" &then
                       tt_item_lote_impl_tit_acr.dat_abat_tit_acr           = b_item_lote_impl_tit_acr.dat_abat_tit_acr
    &endif
    &if '{&emsfin_version}' >= "5.03" &then
                       tt_item_lote_impl_tit_acr.val_perc_abat_acr          = b_item_lote_impl_tit_acr.val_perc_abat_acr
    &endif
    &if '{&emsfin_version}' >= "5.03" &then
                       tt_item_lote_impl_tit_acr.cod_agenc_cobr_bcia        = b_item_lote_impl_tit_acr.cod_agenc_cobr_bcia
    &endif.
                assign &if '{&emsfin_version}' >= "5.04" &then
                       tt_item_lote_impl_tit_acr.val_abat_tit_acr_infor     = b_item_lote_impl_tit_acr.val_abat_tit_acr_infor
    &endif
    &if '{&emsfin_version}' >= "5.05" &then
                       tt_item_lote_impl_tit_acr.val_cotac_indic_econ       = b_item_lote_impl_tit_acr.val_cotac_indic_econ
    &endif
    &if '{&emsfin_version}' >= "5.05" &then
                       tt_item_lote_impl_tit_acr.ind_tip_calc_juros         = b_item_lote_impl_tit_acr.ind_tip_calc_juros
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.cod_comprov_vda            = b_item_lote_impl_tit_acr.cod_comprov_vda
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.num_parc_cartcred          = b_item_lote_impl_tit_acr.num_parc_cartcred
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.cod_autoriz_bco_emissor    = b_item_lote_impl_tit_acr.cod_autoriz_bco_emissor
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.cod_lote_origin            = b_item_lote_impl_tit_acr.cod_lote_origin
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.cod_proces_export          = b_item_lote_impl_tit_acr.cod_proces_export
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.cod_indic_econ_desemb      = b_item_lote_impl_tit_acr.cod_indic_econ_desemb
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.val_cr_pis                 = b_item_lote_impl_tit_acr.val_cr_pis
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.val_cr_cofins              = b_item_lote_impl_tit_acr.val_cr_cofins
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.val_cr_csll                = b_item_lote_impl_tit_acr.val_cr_csll
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.val_base_calc_impto        = b_item_lote_impl_tit_acr.val_base_calc_impto
    &endif
    &if '{&emsfin_version}' >= "5.06" &then
                       tt_item_lote_impl_tit_acr.log_retenc_impto_impl      = b_item_lote_impl_tit_acr.log_retenc_impto_impl
    &endif
    &if '{&emsfin_version}' >= "5.07" &then
                       tt_item_lote_impl_tit_acr.cod_nota_fisc_faturam      = b_item_lote_impl_tit_acr.cod_nota_fisc_faturam
    &endif
    &if '{&emsfin_version}' >= "5.07" &then
                       tt_item_lote_impl_tit_acr.cod_parcela_faturam        = b_item_lote_impl_tit_acr.cod_parcela_faturam
    &endif.
                &if '{&emsfin_version}' < "5.06" &then
                    find first param_integr_ems no-lock
                         where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
                    if  avail param_integr_ems
                      and v_num_natur = 3 
                      and v_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  then do:

                        assign v_cod_proces_export = GetEntryField(6, 
                                                                   b_item_lote_impl_tit_acr.cod_livre_1, 
                                                                   chr(24)).

                               tt_item_lote_impl_tit_acr.cod_livre_1 = SetEntryField(6, 
                                                                                     tt_item_lote_impl_tit_acr.cod_livre_1, 
                                                                                     chr(24),
                                                                                     v_cod_proces_export).
                    end.
                &endif

                if tt_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto = "0000" then
                   assign tt_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto = "".
                if tt_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto = "0000" then
                   assign tt_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto = "".

                &if '{&emsuni_version}' = '5.03' &then
                    assign tt_item_lote_impl_tit_acr.cod_livre_1 = string(entry(1, b_item_lote_impl_tit_acr.cod_livre_1, chr(24))) + chr(24).
                &endif
                &if '{&emsuni_version}' > '5.01' &then
                    assign tt_item_lote_impl_tit_acr.log_val_fix_parc = b_item_lote_impl_tit_acr.log_val_fix_parc.
                    if v_cod_lista_parc = '' then
                       assign v_cod_lista_parc = string(tt_item_lote_impl_tit_acr.log_val_fix_parc).
                    else 
            	   assign v_cod_lista_parc = v_cod_lista_parc + chr(44) + string(tt_item_lote_impl_tit_acr.log_val_fix_parc).
                &else
                    assign tt_item_lote_impl_tit_acr.log_livre_1 = b_item_lote_impl_tit_acr.log_livre_1.
                    if v_cod_lista_parc = '' then
                       assign v_cod_lista_parc = string(tt_item_lote_impl_tit_acr.log_livre_1).
                    else 
            	   assign v_cod_lista_parc = v_cod_lista_parc + chr(44) + string(tt_item_lote_impl_tit_acr.log_livre_1).
                &endif
            end.
            assign v_log_controle = no.
            do v_num_cont = 1 to num-entries(v_cod_lista_parc):
               if  v_log_controle and (entry(v_num_cont, v_cod_lista_parc) = "yes" /*l_yes*/ )
               then do:
                  run pi_integr_acr_renegoc_erros (Input 8528,
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "") /*pi_integr_acr_renegoc_erros*/.
               end /* if */.
               assign v_log_controle = (entry(v_num_cont, v_cod_lista_parc) = "no" /*l_no*/ ).
            end.
            if  search("prgfin/acr/acr748zf.r") = ? and search("prgfin/acr/acr748zf.py") = ? then do:
                if  v_cod_dwb_user begins 'es_' then
                    return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr748zf.py".
                else do:
                    message getStrTrans("Programa execut†vel n∆o foi encontrado:", "ACR") /*l_programa_nao_encontrado*/  "prgfin/acr/acr748zf.py"
                           view-as alert-box error buttons ok.
                    return.
                end.
            end.
            else
                run prgfin/acr/acr748zf.py (Input renegoc_acr.cod_estab,
                                        Input renegoc_acr.num_renegoc_cobr_acr,
                                        Input renegoc_acr.ind_vencto_renegoc,
                                        Input renegoc_acr.val_perc_reaj_renegoc,
                                        Input renegoc_acr.qtd_parc_renegoc,
                                        Input renegoc_acr.dat_primei_vencto_renegoc,
                                        Input renegoc_acr.cod_empresa,
                                        Input renegoc_acr.cod_refer,
                                        Input renegoc_acr.cdn_cliente,
                                        Input renegoc_acr.cod_espec_docto,
                                        Input renegoc_acr.cod_ser_docto,
                                        Input renegoc_acr.cod_tit_acr,
                                        Input renegoc_acr.cod_indic_econ,
                                        Input renegoc_acr.cod_portador,
                                        Input renegoc_acr.cod_cart_bcia,
                                        Input renegoc_acr.cdn_repres,
                                        Input renegoc_acr.dat_transacao,
                                        Input renegoc_acr.num_dia_mes_base_vencto,
                                        Input v_log_soma_movto_cobr,
                                        Input v_val_acresc_parc,
                                        output v_val_parcela,
                                        Input v_num_dias_vencto_renegoc,
                                        Input renegoc_acr.cod_indic_econ_reaj_renegoc) /*prg_api_atualiza_valor_parcela*/.

            for each b_item_lote_impl_tit_acr exclusive-lock
                where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
                and   b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
              &if '{&emsuni_version}' > '5.01' &then                
                and   b_item_lote_impl_tit_acr.log_val_fix_parc     = no:
              &else                
                and   b_item_lote_impl_tit_acr.log_livre_1          = no:                
              &endif   
                if v_val_parcela <> 0 then
                    assign b_item_lote_impl_tit_acr.val_tit_acr     = v_val_parcela
                           b_item_lote_impl_tit_acr.val_liq_tit_acr = b_item_lote_impl_tit_acr.val_tit_acr.
                else do:
                    if v_cod_pais_empres_usuar = 'BRA' then do:
                        &if '{&EMSFIN_VERSION}' < '5.06' &THEN
                            find tab_livre_emsfin
                                where tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                                and   tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                                and   tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                                            + chr(24)
                                                                            + b_item_lote_impl_tit_acr.cod_refer
                                and   tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer)
                                exclusive-lock no-error.
                            if avail tab_livre_emsfin then

                                /* Begin_Include: i_executa_pi_epc_fin */
                                run pi_exec_program_epc_FIN (Input 'BEFORE_DELETE',
                                                             Input 'yes',
                                                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
                                if v_log_return_epc then /* epc retornou erro*/
                                    undo, retry.
                                /* End_Include: i_executa_pi_epc_fin */

                                delete tab_livre_emsfin.

                                /* Begin_Include: i_executa_pi_epc_fin */
                                run pi_exec_program_epc_FIN (Input 'AFTER_DELETE',
                                                             Input 'yes',
                                                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
                                if v_log_return_epc then /* epc retornou erro*/
                                    undo, retry.
                                /* End_Include: i_executa_pi_epc_fin */

                        &endif
                    end.
                    delete b_item_lote_impl_tit_acr.
                    assign renegoc_acr.qtd_parc_renegoc = renegoc_acr.qtd_parc_renegoc - 1.
                end /* else */.
            end.

            /* Soma caso tenha quebra na divis∆o*/
            assign v_val_tot_parc_renegoc    = 0
                   v_val_tot_renegoc_acr     = 0
                   v_val_tot_cust_movto_cobr = 0
                   v_val_tot_tit_acr         = 0.

            for each  b_item_lote_impl_tit_acr no-lock
                where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
                  and b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr:                
                assign v_val_tot_parc_renegoc = v_val_tot_parc_renegoc + b_item_lote_impl_tit_acr.val_liq_tit_acr
                       v_val_tot_tit_acr      = v_val_tot_tit_acr      + b_item_lote_impl_tit_acr.val_tit_acr.
            end.

            if v_cod_pais_empres_usuar = 'BRA' then
                run pi_vld_impto_renegoc_tit_acr(input "Atualizaá∆o" /*l_atualizacao*/ ).

            for each tt_item_renegoc_acr no-lock:
                find tit_acr no-lock
                     where tit_acr.cod_estab      = tt_item_renegoc_acr.cod_estab_tit_acr
                       and tit_acr.num_id_tit_acr = tt_item_renegoc_acr.num_id_tit_acr
                     no-error.
                assign v_val_tot_renegoc_acr = v_val_tot_renegoc_acr + tit_acr.val_sdo_tit_acr.
                    if v_log_soma_movto_cobr = yes 
                    then do:
                      &if '{&emsfin_version}' >= '5.03' &then 
                           for each  relac_movto_cobr_tit_acr no-lock
                               where relac_movto_cobr_tit_acr.cod_estab      = tit_acr.cod_estab
                                 and relac_movto_cobr_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:
                               find movto_cobr_tit_acr no-lock
                                    where movto_cobr_tit_acr.cod_empresa                = relac_movto_cobr_tit_acr.cod_empresa
                                      and movto_cobr_tit_acr.cdn_cliente                = relac_movto_cobr_tit_acr.cdn_cliente
                                      and movto_cobr_tit_acr.num_seq_movto_cobr_tit_acr = relac_movto_cobr_tit_acr.num_seq_movto_cobr_tit_acr
                                    no-error.
                               if avail movto_cobr_tit_acr
                               then assign v_val_tot_cust_movto_cobr = v_val_tot_cust_movto_cobr + relac_movto_cobr_tit_acr.val_cust_movto_cobr.
                           end.
                      &else
                           for each  movto_cobr_tit_acr no-lock
                               where movto_cobr_tit_acr.cod_estab      = tit_acr.cod_estab
                                 and movto_cobr_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:
                               assign v_val_tot_cust_movto_cobr = v_val_tot_cust_movto_cobr + movto_cobr_tit_acr.val_cust_movto_cobr.
                           end.
                      &endif
                    end.            
            end.
            if  v_val_tot_parc_renegoc <> ((v_val_tot_renegoc_acr + v_val_tot_cust_movto_cobr) * (1 + (v_val_acresc_parc / 100)))
            and renegoc_acr.val_perc_reaj_renegoc       = 0
            and renegoc_acr.cod_indic_econ_reaj_renegoc = ""
            then do:
                 find first b_item_lote_impl_tit_acr
                      where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
                        and b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr
                      &if '{&emsuni_version}' > '5.01' &then                
                            and b_item_lote_impl_tit_acr.log_val_fix_parc = no
                      &else                
                            and b_item_lote_impl_tit_acr.log_livre_1      = no                
                      &endif   
                     exclusive-lock no-error.
                 if avail b_item_lote_impl_tit_acr 
                    then assign b_item_lote_impl_tit_acr.val_tit_acr     = b_item_lote_impl_tit_acr.val_tit_acr + ((( v_val_tot_renegoc_acr + v_val_tot_cust_movto_cobr) * (1 + (v_val_acresc_parc / 100))) - v_val_tot_parc_renegoc)
                                b_item_lote_impl_tit_acr.val_liq_tit_acr = b_item_lote_impl_tit_acr.val_tit_acr.
            end.

        end /* if */.
        else
           assign v_log_incl = yes.
    end.
    if v_log_incl = yes then do:
        for each b_item_lote_impl_tit_acr exclusive-lock 
            where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
            and   b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr:
            if v_cod_pais_empres_usuar = 'BRA' then do:
                &if '{&EMSFIN_VERSION}' < '5.06' &THEN
                    find tab_livre_emsfin
                        where tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                        and   tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                        and   tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                                    + chr(24)
                                                                    + b_item_lote_impl_tit_acr.cod_refer
                        and   tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer)
                        exclusive-lock no-error.
                    if avail tab_livre_emsfin then
                        delete tab_livre_emsfin.      
                &endif
            end.
            delete b_item_lote_impl_tit_acr.
        end.
        if  search("prgfin/acr/acr748zd.r") = ? and search("prgfin/acr/acr748zd.py") = ? then do:
            if  v_cod_dwb_user begins 'es_' then
                return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr748zd.py".
            else do:
                message getStrTrans("Programa execut†vel n∆o foi encontrado:", "ACR") /*l_programa_nao_encontrado*/  "prgfin/acr/acr748zd.py"
                       view-as alert-box error buttons ok.
                return.
            end.
        end.
        else
            run prgfin/acr/acr748zd.py (Input renegoc_acr.cod_estab,
                                    Input renegoc_acr.num_renegoc_cobr_acr,
                                    Input renegoc_acr.ind_vencto_renegoc,
                                    Input renegoc_acr.val_perc_reaj_renegoc,
                                    Input renegoc_acr.qtd_parc_renegoc,
                                    Input renegoc_acr.dat_primei_vencto_renegoc,
                                    Input renegoc_acr.cod_empresa,
                                    Input renegoc_acr.cod_refer,
                                    Input renegoc_acr.cdn_cliente,
                                    Input renegoc_acr.cod_espec_docto,
                                    Input renegoc_acr.cod_ser_docto,
                                    Input renegoc_acr.cod_tit_acr,
                                    Input renegoc_acr.cod_indic_econ,
                                    Input renegoc_acr.cod_portador,
                                    Input renegoc_acr.cod_cart_bcia,
                                    Input renegoc_acr.cdn_repres,
                                    Input renegoc_acr.dat_transacao,
                                    Input renegoc_acr.num_dia_mes_base_vencto,
                                    Input v_log_soma_movto_cobr,
                                    Input v_val_acresc_parc,
                                    Input v_num_dias_vencto_renegoc,
                                    Input renegoc_acr.cod_cond_cobr,
                                    Input renegoc_acr.cod_indic_econ_reaj_renegoc) /*prg_api_cria_valor_parcela*/.
        find first tt_log_erros_atualiz no-lock no-error.
        if not avail tt_log_erros_atualiz then do:
            assign v_val_tot_tit_acr = 0.
            for each tt_item_lote_impl_tit_acr:

               /* Begin_Include: i_cria_item_lote_impl_tit_acr_renegoc_api */
               assign v_val_acum_perc  = 0
                      v_val_maior_perc = 0.
               create b_item_lote_impl_tit_acr.
               assign b_item_lote_impl_tit_acr.cod_estab                  = tt_item_lote_impl_tit_acr.cod_estab
                      b_item_lote_impl_tit_acr.cod_refer                  = tt_item_lote_impl_tit_acr.cod_refer
                      b_item_lote_impl_tit_acr.num_seq_refer              = tt_item_lote_impl_tit_acr.num_seq_refer
                      b_item_lote_impl_tit_acr.cod_empresa                = tt_item_lote_impl_tit_acr.cod_empresa
                      b_item_lote_impl_tit_acr.cdn_cliente                = tt_item_lote_impl_tit_acr.cdn_cliente
                      b_item_lote_impl_tit_acr.cdn_repres                 = tt_item_lote_impl_tit_acr.cdn_repres
                      b_item_lote_impl_tit_acr.cod_espec_docto            = tt_item_lote_impl_tit_acr.cod_espec_docto
                      b_item_lote_impl_tit_acr.cod_ser_docto              = tt_item_lote_impl_tit_acr.cod_ser_docto
                      b_item_lote_impl_tit_acr.cod_tit_acr                = tt_item_lote_impl_tit_acr.cod_tit_acr
                      b_item_lote_impl_tit_acr.cod_parcela                = tt_item_lote_impl_tit_acr.cod_parcela
                      b_item_lote_impl_tit_acr.cod_indic_econ             = tt_item_lote_impl_tit_acr.cod_indic_econ
                      b_item_lote_impl_tit_acr.cod_portador               = tt_item_lote_impl_tit_acr.cod_portador
                      b_item_lote_impl_tit_acr.cod_cart_bcia              = tt_item_lote_impl_tit_acr.cod_cart_bcia
                      b_item_lote_impl_tit_acr.cod_cond_cobr              = tt_item_lote_impl_tit_acr.cod_cond_cobr
                      b_item_lote_impl_tit_acr.cod_motiv_movto_tit_acr    = tt_item_lote_impl_tit_acr.cod_motiv_movto_tit_acr
                      b_item_lote_impl_tit_acr.cod_contrat_vda            = tt_item_lote_impl_tit_acr.cod_contrat_vda
                      b_item_lote_impl_tit_acr.cod_proj_invest            = tt_item_lote_impl_tit_acr.cod_proj_invest
                      b_item_lote_impl_tit_acr.cod_histor_padr            = tt_item_lote_impl_tit_acr.cod_histor_padr
                      b_item_lote_impl_tit_acr.dat_vencto_tit_acr         = tt_item_lote_impl_tit_acr.dat_vencto_tit_acr
                      b_item_lote_impl_tit_acr.dat_prev_liquidac          = tt_item_lote_impl_tit_acr.dat_prev_liquidac
                      b_item_lote_impl_tit_acr.dat_desconto               = tt_item_lote_impl_tit_acr.dat_desconto
                      b_item_lote_impl_tit_acr.dat_emis_docto             = tt_item_lote_impl_tit_acr.dat_emis_docto
                      b_item_lote_impl_tit_acr.dat_compra_cartao_cr       = tt_item_lote_impl_tit_acr.dat_compra_cartao_cr
                      b_item_lote_impl_tit_acr.val_tit_acr                = tt_item_lote_impl_tit_acr.val_tit_acr
                      b_item_lote_impl_tit_acr.val_liq_tit_acr            = tt_item_lote_impl_tit_acr.val_liq_tit_acr
                      b_item_lote_impl_tit_acr.val_abat_tit_acr           = tt_item_lote_impl_tit_acr.val_abat_tit_acr
                      b_item_lote_impl_tit_acr.val_desconto               = tt_item_lote_impl_tit_acr.val_desconto
                      b_item_lote_impl_tit_acr.val_perc_desc              = tt_item_lote_impl_tit_acr.val_perc_desc
                      b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso  = tt_item_lote_impl_tit_acr.val_perc_juros_dia_atraso
                      b_item_lote_impl_tit_acr.val_perc_multa_atraso      = tt_item_lote_impl_tit_acr.val_perc_multa_atraso
                      b_item_lote_impl_tit_acr.val_ajust_val_tit_acr      = tt_item_lote_impl_tit_acr.val_ajust_val_tit_acr
                      b_item_lote_impl_tit_acr.des_text_histor            = tt_item_lote_impl_tit_acr.des_text_histor
                      b_item_lote_impl_tit_acr.ind_tip_espec_docto        = tt_item_lote_impl_tit_acr.ind_tip_espec_docto
                      b_item_lote_impl_tit_acr.ind_sit_tit_acr            = tt_item_lote_impl_tit_acr.ind_sit_tit_acr
                      b_item_lote_impl_tit_acr.ind_ender_cobr             = tt_item_lote_impl_tit_acr.ind_ender_cobr
                      b_item_lote_impl_tit_acr.cod_banco                  = tt_item_lote_impl_tit_acr.cod_banco
                      b_item_lote_impl_tit_acr.cod_agenc_bcia             = tt_item_lote_impl_tit_acr.cod_agenc_bcia
                      b_item_lote_impl_tit_acr.cod_cta_corren_bco         = tt_item_lote_impl_tit_acr.cod_cta_corren_bco
                      b_item_lote_impl_tit_acr.cod_digito_cta_corren      = tt_item_lote_impl_tit_acr.cod_digito_cta_corren
                      b_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto   = tt_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto
                      b_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto   = tt_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto
                      b_item_lote_impl_tit_acr.nom_abrev_contat           = tt_item_lote_impl_tit_acr.nom_abrev_contat
                      b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr  = tt_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr
                      b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr  = tt_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr
                      b_item_lote_impl_tit_acr.log_liquidac_autom         = tt_item_lote_impl_tit_acr.log_liquidac_autom
                      b_item_lote_impl_tit_acr.log_rat_val_ok             = tt_item_lote_impl_tit_acr.log_rat_val_ok
                      b_item_lote_impl_tit_acr.log_db_autom               = tt_item_lote_impl_tit_acr.log_db_autom
                      b_item_lote_impl_tit_acr.log_destinac_cobr          = tt_item_lote_impl_tit_acr.log_destinac_cobr
                      b_item_lote_impl_tit_acr.log_tip_cr_perda_dedut_tit = tt_item_lote_impl_tit_acr.log_tip_cr_perda_dedut_tit
                      b_item_lote_impl_tit_acr.cod_admdra_cartao_cr       = tt_item_lote_impl_tit_acr.cod_admdra_cartao_cr
                      b_item_lote_impl_tit_acr.cod_cartcred               = tt_item_lote_impl_tit_acr.cod_cartcred
                      b_item_lote_impl_tit_acr.cod_autoriz_cartao_cr      = tt_item_lote_impl_tit_acr.cod_autoriz_cartao_cr
                      b_item_lote_impl_tit_acr.cod_mes_ano_valid_cartao   = tt_item_lote_impl_tit_acr.cod_mes_ano_valid_cartao
                      b_item_lote_impl_tit_acr.cod_conces_telef           = tt_item_lote_impl_tit_acr.cod_conces_telef
                      b_item_lote_impl_tit_acr.num_ddd_localid_conces     = tt_item_lote_impl_tit_acr.num_ddd_localid_conces
                      b_item_lote_impl_tit_acr.num_prefix_localid_conces  = tt_item_lote_impl_tit_acr.num_prefix_localid_conces
                      b_item_lote_impl_tit_acr.num_milhar_localid_conces  = tt_item_lote_impl_tit_acr.num_milhar_localid_conces
                      b_item_lote_impl_tit_acr.num_renegoc_cobr_acr       = tt_item_lote_impl_tit_acr.num_renegoc_cobr_acr.

               if b_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto = "0000" then
                  assign b_item_lote_impl_tit_acr.cod_instruc_bcia_1_movto = "".
               if b_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto = "0000" then
                  assign b_item_lote_impl_tit_acr.cod_instruc_bcia_2_movto = "".

               /* Atualizando o atributo cod_livre_1 com todos os separadores poss°veis */
               /* Posteriormente ser† atualizado apenas a "entrada" em quest∆o          */
               /* N∆o sendo necess†rio a gravaá∆o do separador chr(24)                  */
               if  num-entries(b_item_lote_impl_tit_acr.cod_livre_1, chr(24)) < 6 then do:
                   do v_num_aux = num-entries(b_item_lote_impl_tit_acr.cod_livre_1, chr(24)) + 1 to 6:
                       assign b_item_lote_impl_tit_acr.cod_livre_1 = b_item_lote_impl_tit_acr.cod_livre_1 + chr(24).
                   end.
               end.

               if  v_log_funcao_tip_calc_juros then do:
                   &if '{&emsfin_version}' >= "5.05" &then
                       assign b_item_lote_impl_tit_acr.ind_tip_calc_juros = renegoc_acr.ind_tip_calc_juros.
                   &else
                       assign entry(2,b_item_lote_impl_tit_acr.cod_livre_1, chr(24)) = entry(1,renegoc_acr.cod_livre_1,chr(24)).
                   &endif  
               end.       

               /* cria os pedidos de venda dos t°tulos antigos para o novo t°tulos ou novos t°tulos */
               for each tt_ped_vda_tit_acr_pend no-lock:
                   create ped_vda_tit_acr_pend.
                   assign ped_vda_tit_acr_pend.cod_estab                 = b_item_lote_impl_tit_acr.cod_estab
                          ped_vda_tit_acr_pend.cod_refer                 = b_item_lote_impl_tit_acr.cod_refer
                          ped_vda_tit_acr_pend.num_seq_refer             = b_item_lote_impl_tit_acr.num_seq_refer
                          ped_vda_tit_acr_pend.cod_ped_vda               = tt_ped_vda_tit_acr_pend.tta_cod_ped_vda
                          ped_vda_tit_acr_pend.cod_ped_vda_repres        = tt_ped_vda_tit_acr_pend.tta_cod_ped_vda_repres
                          ped_vda_tit_acr_pend.val_perc_particip_ped_vda = (tt_ped_vda_tit_acr_pend.tta_val_sdo_tit_acr * 100 ) / v_val_tot_renegoc_tit_acr
                          ped_vda_tit_acr_pend.des_ped_vda               = tt_ped_vda_tit_acr_pend.tta_des_ped_vda.

                   assign v_val_acum_perc = v_val_acum_perc + ped_vda_tit_acr_pend.val_perc_particip_ped_vda.

                   if ped_vda_tit_acr_pend.val_perc_particip_ped_vda > v_val_maior_perc then 
                       assign v_val_maior_perc           = ped_vda_tit_acr_pend.val_perc_particip_ped_vda
                              v_rec_ped_vda_tit_acr_pend = recid(ped_vda_tit_acr_pend).
               end.
               if  v_val_acum_perc > 100
               then do:
                   find ped_vda_tit_acr_pend exclusive-lock
                       where recid(ped_vda_tit_acr_pend) = v_rec_ped_vda_tit_acr_pend no-error.
                   if avail ped_vda_tit_acr_pend then
                       /* Ç usada a mesma vari†vel do acumulador porque ela n∆o Ç mais utilizada, e a cada nova execuá∆o ela tambÇm Ç zerada */
                       assign v_val_maior_perc                               = (v_val_acum_perc - 100)
                              ped_vda_tit_acr_pend.val_perc_particip_ped_vda = ped_vda_tit_acr_pend.val_perc_particip_ped_vda - v_val_maior_perc.
               end /* if */.
               assign v_val_tot_tit_acr = v_val_tot_tit_acr + b_item_lote_impl_tit_acr.val_tit_acr.

               /* End_Include: i_cria_item_lote_impl_tit_acr_renegoc_api */

               &if '{&emsuni_version}' > '5.01' &then
                   assign b_item_lote_impl_tit_acr.log_val_fix_parc = no.
               &else
                   assign b_item_lote_impl_tit_acr.log_livre_1 = no.
               &endif

               find first cond_cobr_acr no-lock
                    where cond_cobr_acr.cod_estab     = renegoc_acr.cod_estab 
                      and cond_cobr_acr.cod_cond_cobr = renegoc_acr.cod_cond_cobr no-error.
               if avail cond_cobr_acr then do:

                           assign b_item_lote_impl_tit_acr.val_perc_multa_atraso     = cond_cobr_acr.val_perc_multa_cond_cobr
                                  b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso = cond_cobr_acr.val_perc_juros_acr / 30
                                  b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr = cond_cobr_acr.qtd_dias_carenc_multa_acr
                                  b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr = cond_cobr_acr.qtd_dias_carenc_juros_acr.

               end.
               else do:    
                    run pi_retorna_parametro_acr (Input renegoc_acr.cod_estab,
                                                  Input renegoc_acr.dat_transacao) /*pi_retorna_parametro_acr*/.
                    if avail param_estab_acr then 
                       assign b_item_lote_impl_tit_acr.val_perc_multa_atraso     = param_estab_acr.val_perc_multa_acr
                              b_item_lote_impl_tit_acr.val_perc_juros_dia_atraso = param_estab_acr.val_perc_juros_acr / 30
                              b_item_lote_impl_tit_acr.qtd_dias_carenc_multa_acr = param_estab_acr.qtd_dias_carenc_multa_acr
                              b_item_lote_impl_tit_acr.qtd_dias_carenc_juros_acr = param_estab_acr.qtd_dias_carenc_juros_acr.
               end.
            end.
            if v_cod_pais_empres_usuar = 'BRA' then
                run pi_vld_impto_renegoc_tit_acr(input "Cria" /*l_cria*/ ).
        end.
        assign renegoc_acr.val_renegoc_cobr_acr = v_val_tot_tit_acr.
    end.
END PROCEDURE. /* pi_api_item_renegoc_acr_subst_tit_novos */
/*****************************************************************************
** Procedure Interna.....: pi_vld_impto_renegoc_tit_acr
** Descricao.............: pi_vld_impto_renegoc_tit_acr
** Criado por............: its0042
** Criado em.............: 06/05/2004 08:17:45
** Alterado por..........: fut12235
** Alterado em...........: 26/12/2007 17:26:27
*****************************************************************************/
PROCEDURE pi_vld_impto_renegoc_tit_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_tipo
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_impl_tit_acr
        for item_lote_impl_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_val_base_parc                  as decimal         no-undo. /*local*/
    def var v_val_cofins_parc                as decimal         no-undo. /*local*/
    def var v_val_csll_parc                  as decimal         no-undo. /*local*/
    def var v_val_pis_parc                   as decimal         no-undo. /*local*/
    def var v_val_tot_base_parc              as decimal         no-undo. /*local*/
    def var v_val_tot_cofins_parc            as decimal         no-undo. /*local*/
    def var v_val_tot_csll_parc              as decimal         no-undo. /*local*/
    def var v_val_tot_pis_parc               as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    for each  b_item_lote_impl_tit_acr exclusive-lock
        where b_item_lote_impl_tit_acr.cod_estab             = renegoc_acr.cod_estab
          and b_item_lote_impl_tit_acr.num_renegoc_cobr_acr  = renegoc_acr.num_renegoc_cobr_acr:
        assign v_val_pis_parc        = (v_val_tot_cr_pis     * b_item_lote_impl_tit_acr.val_tit_acr / v_val_tot_tit_acr)
               v_val_cofins_parc     = (v_val_tot_cr_cofins  * b_item_lote_impl_tit_acr.val_tit_acr / v_val_tot_tit_acr)
               v_val_csll_parc       = (v_val_tot_cr_csll    * b_item_lote_impl_tit_acr.val_tit_acr / v_val_tot_tit_acr)
               v_val_base_parc       = (v_val_tot_base_calc  * b_item_lote_impl_tit_acr.val_tit_acr / v_val_tot_tit_acr)
               v_val_tot_pis_parc    = v_val_tot_pis_parc    + round(v_val_pis_parc,2)
               v_val_tot_cofins_parc = v_val_tot_cofins_parc + round(v_val_cofins_parc,2)
               v_val_tot_csll_parc   = v_val_tot_csll_parc   + round(v_val_csll_parc,2)
               v_val_tot_base_parc   = v_val_tot_base_parc   + round(v_val_base_parc,2).

        &if '{&EMSFIN_VERSION}' >= '5.06' &then
            assign b_item_lote_impl_tit_acr.val_cr_pis           = if v_val_pis_parc    <> ? then v_val_pis_parc    else 0
                   b_item_lote_impl_tit_acr.val_cr_cofins        = if v_val_cofins_parc <> ? then v_val_cofins_parc else 0
                   b_item_lote_impl_tit_acr.val_cr_csll          = if v_val_csll_parc   <> ? then v_val_csll_parc   else 0
                   b_item_lote_impl_tit_acr.val_base_calc_impto  = if v_val_base_parc   <> ? then v_val_base_parc   else 0.
        &else
            case p_cod_tipo:
                when "Atualizaá∆o" /*l_atualizacao*/  then do:
                    find tab_livre_emsfin 
                        where tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                        and   tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                        and   tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                                    + chr(24) 
                                                                    + b_item_lote_impl_tit_acr.cod_refer
                        and   tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer)
                        exclusive-lock no-error.                                             
                end.
                when "Cria" /*l_cria*/  then do:
                    if  v_val_pis_parc    > 0 or
                         v_val_cofins_parc > 0 or
                         v_val_csll_parc   > 0 or 
                         v_val_base_parc   > 0
                    then do:

                        create tab_livre_emsfin.
                        assign tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                               tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                               tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                                     + chr(24) 
                                                                     + b_item_lote_impl_tit_acr.cod_refer
                               tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer).  


                        /* Begin_Include: i_executa_pi_epc_fin */
                        run pi_exec_program_epc_FIN (Input 'VALIDATE',
                                                     Input 'yes',
                                                     output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
                        if v_log_return_epc then /* epc retornou erro*/
                            undo, retry.
                        /* End_Include: i_executa_pi_epc_fin */


                    end /* if */.
                    else 
                        if avail tab_livre_emsfin then release tab_livre_emsfin.

                end.
            end.                                                         
            if avail tab_livre_emsfin then
                assign tab_livre_emsfin.cod_livre_1 = string(v_val_pis_parc)          + CHR(24)
                                                    + string(v_val_cofins_parc)       + CHR(24)
                                                    + string(v_val_csll_parc)         + CHR(24)
                                                    + string(v_val_base_parc)         + CHR(24)
                                                    + string(v_log_retenc_impto_impl) + CHR(24) .
        &endif
    end.

    find last b_item_lote_impl_tit_acr exclusive-lock
        where b_item_lote_impl_tit_acr.cod_estab            = renegoc_acr.cod_estab
        and   b_item_lote_impl_tit_acr.num_renegoc_cobr_acr = renegoc_acr.num_renegoc_cobr_acr no-error.
    if avail  b_item_lote_impl_tit_acr then do:
        &if '{&EMSFIN_VERSION}' >= '5.06' &then
            if v_val_tot_cr_pis    <> v_val_tot_pis_parc    then
                assign b_item_lote_impl_tit_acr.val_cr_pis    = b_item_lote_impl_tit_acr.val_cr_pis    + (v_val_tot_cr_pis    - v_val_tot_pis_parc).
            if v_val_tot_cr_cofins <> v_val_tot_cofins_parc then
                assign b_item_lote_impl_tit_acr.val_cr_cofins = b_item_lote_impl_tit_acr.val_cr_cofins + (v_val_tot_cr_cofins - v_val_tot_cofins_parc).
            if v_val_tot_cr_csll   <> v_val_tot_csll_parc   then
                assign b_item_lote_impl_tit_acr.val_cr_csll   = b_item_lote_impl_tit_acr.val_cr_csll   + (v_val_tot_cr_csll   - v_val_tot_csll_parc).
            if v_val_tot_base_calc <> v_val_tot_base_parc   then
                assign b_item_lote_impl_tit_acr.val_base_calc_impto = b_item_lote_impl_tit_acr.val_base_calc_impto + (v_val_tot_base_calc - v_val_tot_base_parc).
        &else
            find tab_livre_emsfin
                where tab_livre_emsfin.cod_modul_dtsul      = 'ACR'
                and   tab_livre_emsfin.cod_tab_dic_dtsul    = 'ITEM_IMPL_ACR_IMPTO_CR'
                and   tab_livre_emsfin.cod_compon_1_idx_tab = b_item_lote_impl_tit_acr.cod_estab
                                                            + chr(24) 
                                                            + b_item_lote_impl_tit_acr.cod_refer
                and   tab_livre_emsfin.cod_compon_2_idx_tab = string(b_item_lote_impl_tit_acr.num_seq_refer)
                exclusive-lock no-error.
            if  avail tab_livre_emsfin then do:
                if v_val_tot_cr_pis    <> v_val_tot_pis_parc    then
                    assign entry(1,tab_livre_emsfin.cod_livre_1,chr(24)) = string(dec(entry(1,tab_livre_emsfin.cod_livre_1,chr(24))) + (v_val_tot_cr_pis    - v_val_tot_pis_parc)).
                if v_val_tot_cr_cofins <> v_val_tot_cofins_parc then
                    assign entry(2,tab_livre_emsfin.cod_livre_1,chr(24)) = string(dec(entry(2,tab_livre_emsfin.cod_livre_1,chr(24))) + (v_val_tot_cr_cofins - v_val_tot_cofins_parc)).
                if v_val_tot_cr_csll   <> v_val_tot_csll_parc   then
                    assign entry(3,tab_livre_emsfin.cod_livre_1,chr(24)) = string(dec(entry(3,tab_livre_emsfin.cod_livre_1,chr(24))) + (v_val_tot_cr_csll   - v_val_tot_csll_parc)).
                if v_val_tot_base_calc <> v_val_tot_base_parc   then
                    assign entry(4,tab_livre_emsfin.cod_livre_1,chr(24)) = string(dec(entry(4,tab_livre_emsfin.cod_livre_1,chr(24))) + (v_val_tot_base_calc - v_val_tot_base_parc)).
            end. 
        &endif
    end.

END PROCEDURE. /* pi_vld_impto_renegoc_tit_acr */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_sit_movimen_modul
** Descricao.............: pi_retornar_sit_movimen_modul
** Criado por............: Rovina
** Criado em.............: // 
** Alterado por..........: 
** Alterado em...........: 28/09/1995 13:58:38
*****************************************************************************/
PROCEDURE pi_retornar_sit_movimen_modul:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_unid_organ
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_dat_refer_sit
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_des_sit_movimen_ent
        as character
        format "x(40)"
        no-undo.
    def output param p_des_sit_movimen_mod
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_des_sit_movimen_mod = "".
    situacao:
    for each sit_movimen_modul no-lock
     where sit_movimen_modul.cod_modul_dtsul = p_cod_modul_dtsul
       and sit_movimen_modul.cod_unid_organ = p_cod_unid_organ
       and sit_movimen_modul.dat_inic_sit_movimen <= p_dat_refer_sit
       and sit_movimen_modul.dat_fim_sit_movimen >= p_dat_refer_sit /*cl_retornar_sit_movimen_modul of sit_movimen_modul*/:
        if  p_des_sit_movimen_mod = ""
        then do:
            assign p_des_sit_movimen_mod = sit_movimen_modul.ind_sit_movimen.
        end /* if */.
        else do:
            assign p_des_sit_movimen_mod = p_des_sit_movimen_mod + "," + sit_movimen_modul.ind_sit_movimen.
        end /* else */.
    end /* for situacao */.

END PROCEDURE. /* pi_retornar_sit_movimen_modul */
/*****************************************************************************
** Procedure Interna.....: pi_valida_infor_renegoc_acr
** Descricao.............: pi_valida_infor_renegoc_acr
** Criado por............: fut31947
** Criado em.............: 18/09/2009 17:21:03
** Alterado por..........: fut31947
** Alterado em...........: 01/10/2009 15:36:38
*****************************************************************************/
PROCEDURE pi_valida_infor_renegoc_acr:

    /************************* Variable Definition Begin ************************/

    def var v_log_difer
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        no-undo.


    /************************** Variable Definition End *************************/

    /* --- Valida situaªío do mΩdulo ---*/
    run pi_retornar_sit_movimen_modul (Input "ACR" /*l_acr*/ ,
                                       Input v_cod_empres_usuar,
                                       Input tt_integr_acr_renegoc.tta_dat_transacao,
                                       Input "Habilitado" /*l_habilitado*/ ,
                                       output v_cod_return).
    if  not can-do(v_cod_return, "Habilitado" /*l_habilitado*/  ) then do:
        assign v_cod_parameters = tt_integr_acr_renegoc.tta_cod_estab + "," + "ACR" /*l_acr*/  + "," + string(tt_integr_acr_renegoc.tta_dat_transacao) +  ",,,,,,".
        run pi_integr_acr_renegoc_erros (Input 1628,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input v_cod_parameters) /*pi_integr_acr_renegoc_erros*/. 
        return "NOK" /*l_nok*/ .
    end.


    if not can-find(first espec_docto_financ_acr no-lock
                    where espec_docto_financ_acr.cod_espec_docto = tt_integr_acr_renegoc.tta_cod_espec_docto) then do:
        assign v_cod_parameters = tt_integr_acr_renegoc.tta_cod_espec_docto + ",,,,,,,,".
        run pi_integr_acr_renegoc_erros (Input 13504,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input v_cod_parameters) /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .                
    end.

    if not can-find(first indic_econ no-lock
                    where indic_econ.cod_indic_econ = tt_integr_acr_renegoc.tta_cod_indic_econ) then do:
       run pi_integr_acr_renegoc_erros (Input 241,
                                        Input tt_integr_acr_renegoc.tta_cod_estab,
                                        Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "",
                                        Input "") /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .
    end.

    if tt_integr_acr_renegoc.tta_log_juros_param_estab_reaj = no and tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc <> "" then do:
        if not can-find(first indic_econ no-lock
                        where indic_econ.cod_indic_econ = tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc) then do:
           run pi_integr_acr_renegoc_erros (Input 241,
                                            Input tt_integr_acr_renegoc.tta_cod_estab,
                                            Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "",
                                            Input "") /*pi_integr_acr_renegoc_erros*/.
            return "NOK" /*l_nok*/ .
        end.
    end.


    if not can-find(first portador no-lock
                    where portador.cod_portador = tt_integr_acr_renegoc.tta_cod_portador) then do:
        assign v_cod_parameters = tt_integr_acr_renegoc.tta_cod_portador + ",,,,,,,,".
        run pi_integr_acr_renegoc_erros (Input 10858,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input v_cod_parameters) /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .
    end.

    if not can-find(first cart_bcia no-lock
                    where cart_bcia.cod_cart_bcia = tt_integr_acr_renegoc.tta_cod_cart_bcia) then do:
        run pi_integr_acr_renegoc_erros (Input 3103,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "") /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .
    end.

    if tt_integr_acr_renegoc.tta_ind_vencto_renegoc <> "Di†ria" /*l_diaria*/  and
       tt_integr_acr_renegoc.tta_ind_vencto_renegoc <> "Semanal" /*l_semanal*/  and
       tt_integr_acr_renegoc.tta_ind_vencto_renegoc <> "Mensal" /*l_mensal*/  and
       tt_integr_acr_renegoc.tta_ind_vencto_renegoc <> "Quinzenal" /*l_quinzenal*/  and
       tt_integr_acr_renegoc.tta_ind_vencto_renegoc <> "Nr Dias" /*l_nr_dias*/  then do:
        run pi_integr_acr_renegoc_erros (Input 20120,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "") /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .
    end.
    if tt_integr_acr_renegoc.tta_ind_vencto_renegoc = 'Diaria' then
        assign tt_integr_acr_renegoc.tta_ind_vencto_renegoc = "Di†ria" /*l_diaria*/ .

    if tt_integr_acr_renegoc.tta_ind_tip_calc_juros <> "Simples" /*l_simples*/  and
       tt_integr_acr_renegoc.tta_ind_tip_calc_juros <> "Compostos" /*l_compostos*/  then do:
        run pi_integr_acr_renegoc_erros (Input 20121,
                                         Input tt_integr_acr_renegoc.tta_cod_estab,
                                         Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "",
                                         Input "") /*pi_integr_acr_renegoc_erros*/.
        return "NOK" /*l_nok*/ .   
    end.

    if tt_integr_acr_renegoc.tta_log_soma_movto_cobr = ? then
        assign tt_integr_acr_renegoc.tta_log_soma_movto_cobr = no.

    if tt_integr_acr_renegoc.ttv_log_bxo_estab_tit_2 = ? then
       assign tt_integr_acr_renegoc.ttv_log_bxo_estab_tit_2 = no.

    /* tratamento da periodicidade da renegociaá∆o */
    case tt_integr_acr_renegoc.tta_ind_vencto_renegoc:
       when "Di†ria" /*l_diaria*/  then
           assign tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc = 1
                  tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto = day(tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc).
       when "Semanal" /*l_semanal*/  then
           assign tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc = 7
                  tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto = day(tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc).   
       when "Quinzenal" /*l_quinzenal*/  then
           assign tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc = 15
                  tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto = day(tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc).
       when "Mensal" /*l_mensal*/  then
           assign tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc = 30
                  tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto = day(tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc).
       when "Nr Dias" /*l_nr_dias*/  then do:
           assign tt_integr_acr_renegoc.tta_num_dia_mes_base_vencto = day(tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc).
           if tt_integr_acr_renegoc.tta_num_dias_vencto_renegoc = 0 then do:
               run pi_integr_acr_renegoc_erros (Input 6091,
                                                Input tt_integr_acr_renegoc.tta_cod_estab,
                                                Input tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "",
                                                Input "") /*pi_integr_acr_renegoc_erros*/.
               return "NOK" /*l_nok*/ . 

           end.
       end.
    end.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_valida_infor_renegoc_acr */
/*****************************************************************************
** Procedure Interna.....: pi_exec_program_epc_FIN
** Descricao.............: pi_exec_program_epc_FIN
** Criado por............: src388
** Criado em.............: 09/09/2003 10:48:55
** Alterado por..........: fut1309
** Alterado em...........: 15/02/2006 09:44:03
*****************************************************************************/
PROCEDURE pi_exec_program_epc_FIN:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_event
        as character
        format "x(100)"
        no-undo.
    def Input param p_cod_return
        as character
        format "x(40)"
        no-undo.
    def output param p_log_return_epc
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* *******************************************************************************************
    ** Objetivo..............: Substituir o c¢digo gerado pela include i_exec_program_epc,
    **                         muitas vezes repetido, com o intuito de evitar estouro de segmento.
    **
    ** Utilizaá∆o............: A utilizaá∆o desta procedure funciona exatamente como a include
    **                         anteriormente utilizada para este fim, para chamar ela deve ser 
    **                         includa a include i_executa_pi_epc_fin no programa, que ira executar 
    **                         esta pi e fazer tratamento para os retornos. Deve ser declarada a 
    **                         variavel v_log_return_epc (caso o parametro ela seja verdade, Ç 
    **                         porque a EPC retornou "NOK". 
    **
    **                         @i(i_executa_pi_epc_fin &event='INITIALIZE' &return='NO')
    **
    **                         Para se ter uma idÇia de como se usa, favor olhar o fonte do apb008za.p
    **
    **
    *********************************************************************************************/

    assign p_log_return_epc = no.
    /* ix_iz1_api_integr_acr_renegoc_3 */


    /* Begin_Include: i_exec_program_epc_pi_fin */
    if  v_nom_prog_upc <> ''    
    or  v_nom_prog_appc <> ''
    or  v_nom_prog_dpc <> '' then do:
        &if '' <> '' &then
            assign v_rec_table_epc = recid()
                   v_nom_table_epc = ''.
        &else
            assign v_rec_table_epc = ?
                   v_nom_table_epc = "".
        &endif
    end.
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_upc) (input p_cod_event,
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.

    if  v_nom_prog_appc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_appc) (input p_cod_event,
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_dpc) (input p_cod_event,
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.
    &endif
    &endif

    /* End_Include: i_exec_program_epc_pi_fin */


    /* ix_iz2_api_integr_acr_renegoc_3 */
END PROCEDURE. /* pi_exec_program_epc_FIN */
/*****************************************************************************
** Procedure Interna.....: pi_vld_campo_renegoc
** Descricao.............: pi_vld_campo_renegoc
** Criado por............: fut12235
** Criado em.............: 29/10/2009 08:54:13
** Alterado por..........: fut12235
** Alterado em...........: 29/10/2009 09:00:49
*****************************************************************************/
PROCEDURE pi_vld_campo_renegoc:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_campo
        as character
        format "x(25)"
        no-undo.


    /************************* Parameter Definition End *************************/

    &if '{&frame_aux}' <> "" &then
        /* Valor &1 inv†lido para o campo &2 ! */
        run pi_messages (input "show",
                         input 19384,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            '?', p_cod_campo)) /*msg_19384*/.    
    &else
        assign v_cod_parameters = '?' + "," +  p_cod_campo  + ",,,,,,,".
        run pi_integr_acr_renegoc_erros(19384,
                                        tt_integr_acr_renegoc.tta_cod_estab,
                                        tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        "","","","","","","","",
                                        v_cod_parameters).
    &endif

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_vld_campo_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_vld_campo_item_renegoc
** Descricao.............: pi_vld_campo_item_renegoc
** Criado por............: fut12235
** Criado em.............: 29/10/2009 14:03:49
** Alterado por..........: fut12235
** Alterado em...........: 30/10/2009 09:58:08
*****************************************************************************/
PROCEDURE pi_vld_campo_item_renegoc:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_campo
        as character
        format "x(25)"
        no-undo.


    /************************* Parameter Definition End *************************/

    &if '{&frame_aux}' <> "" &then
        /* Valor &1 inv†lido para o campo &2 ! */
        run pi_messages (input "show",
                         input 20187,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                             '?',                  p_cod_campo,                 tt_integr_acr_renegoc.tta_cod_estab,                  tt_integr_acr_renegoc.tta_cod_espec_docto,                  tt_integr_acr_renegoc.tta_cod_ser_docto,                  tt_integr_acr_item_renegoc_new.tta_cod_tit_acr,                  tt_integr_acr_item_renegoc_new.tta_cod_parcela)) /*msg_20187*/.        
    &else
        assign v_cod_parameters = "?" 
                                + "," + p_cod_campo
                                + "," + if tt_integr_acr_renegoc.tta_cod_estab            = ? then "?" else tt_integr_acr_renegoc.tta_cod_estab
                                + "," + if tt_integr_acr_renegoc.tta_cod_espec_docto      = ? then "?" else tt_integr_acr_renegoc.tta_cod_espec_docto
                                + "," + if tt_integr_acr_renegoc.tta_cod_ser_docto        = ? then "?" else tt_integr_acr_renegoc.tta_cod_ser_docto
                                + "," + if tt_integr_acr_item_renegoc_new.tta_cod_tit_acr = ? then "?" else tt_integr_acr_item_renegoc_new.tta_cod_tit_acr
                                + "," + if tt_integr_acr_item_renegoc_new.tta_cod_parcela = ? then "?" else tt_integr_acr_item_renegoc_new.tta_cod_parcela.

        assign v_cod_parameters = v_cod_parameters + ",,".                        

        run pi_integr_acr_renegoc_erros(20187,
                                        tt_integr_acr_renegoc.tta_cod_estab,
                                        tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr,
                                        "","","","","","","","",
                                        v_cod_parameters).
    &endif

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_vld_campo_item_renegoc */
/*****************************************************************************
** Procedure Interna.....: pi_validar_unid_negoc_estab_dest_acr
** Descricao.............: pi_validar_unid_negoc_estab_dest_acr
** Criado por............: Pasold
** Criado em.............: 18/12/1996 10:53:56
** Alterado por..........: lucas
** Alterado em...........: 14/10/1998 15:30:41
*****************************************************************************/
PROCEDURE pi_validar_unid_negoc_estab_dest_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_estab_dest
        as character
        format "x(3)"
        no-undo.
    def Input param p_num_id_tit_acr
        as integer
        format "9999999999"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_log_erro
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return_error
        as character
        format "x(8)":U
        no-undo.
    def var v_val_unid_negoc_dest
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        initial 0
        no-undo.
    def var v_cod_finalid_econ               as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    run pi_retornar_finalid_econ_corren_estab (Input p_cod_estab,
                                               output v_cod_finalid_econ) /* pi_retornar_finalid_econ_corren_estab*/.
    for each val_tit_acr no-lock
        where val_tit_acr.cod_estab = p_cod_estab
          and val_tit_acr.num_id_tit_acr = p_num_id_tit_acr
          and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
        break by val_tit_acr.cod_unid_negoc:
        if last-of (val_tit_acr.cod_unid_negoc) then do:
            if p_cod_estab <> p_cod_estab_dest then do:
                  run pi_validar_unid_negoc (Input p_cod_estab_dest,
                                             Input val_tit_acr.cod_unid_negoc,
                                             Input p_dat_transacao,
                                             output v_cod_return_error) /* pi_validar_unid_negoc*/.
            if  v_cod_return_error <> "" then
                 assign p_log_erro = yes.
            end.
            if p_log_erro = no then do:
                run pi_validar_unid_negoc (Input p_cod_estab,
                                           Input val_tit_acr.cod_unid_negoc,
                                           Input p_dat_transacao,
                                           output v_cod_return_error) /* pi_validar_unid_negoc*/.
                if  v_cod_return_error <> "" then
                    assign p_log_erro = yes.
            end.
        end.
    end.

END PROCEDURE. /* pi_validar_unid_negoc_estab_dest_acr */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_finalid_econ_corren_estab
** Descricao.............: pi_retornar_finalid_econ_corren_estab
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut41061
** Alterado em...........: 27/04/2009 08:43:48
*****************************************************************************/
PROCEDURE pi_retornar_finalid_econ_corren_estab:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def output param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find estabelecimento no-lock
         where estabelecimento.cod_estab = p_cod_estab
         use-index stblcmnt_id no-error.
    if  avail estabelecimento
    then do:
       find pais no-lock
            where pais.cod_pais = estabelecimento.cod_pais
             no-error.
       assign p_cod_finalid_econ = pais.cod_finalid_econ_pais.
    end.
END PROCEDURE. /* pi_retornar_finalid_econ_corren_estab */
/*****************************************************************************
** Procedure Interna.....: pi_validar_usuar_estab_acr_renegoc
** Descricao.............: pi_validar_usuar_estab_acr_renegoc
** Criado por............: fut12235_3
** Criado em.............: 01/07/2010 10:55:02
** Alterado por..........: fut12235_3
** Alterado em...........: 01/07/2010 17:45:24
*****************************************************************************/
PROCEDURE pi_validar_usuar_estab_acr_renegoc:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_usuar_financ_estab_acr
        for usuar_financ_estab_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    if  tt_integr_acr_item_renegoc.tta_cod_estab <> renegoc_acr.cod_estab
    then do:
       /* --- Verifica se o Usu†rio corrente est† apto a Implantar ---*/
       run pi_validar_usuar_estab_acr (Input renegoc_acr.cod_estab,
                                       Input "Implantaá∆o" /*l_implantacao*/,
                                       output v_cod_return) /*pi_validar_usuar_estab_acr*/.   
       if  v_cod_return <> "no" /*l_no*/ 
       and v_cod_return <> '3018'
       then do:

           &if '{&emsfin_version}' >= '5.06' &then
           if not renegoc_acr.log_bxa_estab_tit_acr
           &else 
              &if '{&emsfin_version}' >= '5.04' &then 
              if not renegoc_acr.log_livre_2
              &endif
           &endif
           then do:
               find first usuar_financ_estab_acr no-lock
                    where usuar_financ_estab_acr.cod_usuario = v_cod_usuar_corren
                      and usuar_financ_estab_acr.cod_estab   = renegoc_acr.cod_estab no-error.
               find first b_usuar_financ_estab_acr no-lock
                    where b_usuar_financ_estab_acr.cod_usuario = v_cod_usuar_corren
                      and b_usuar_financ_estab_acr.cod_estab   = tt_integr_acr_item_renegoc.tta_cod_estab no-error.
               if  not avail usuar_financ_estab_acr
               or not avail b_usuar_financ_estab_acr
               or not usuar_financ_estab_acr.log_habilit_transf_tit_acr
               or not b_usuar_financ_estab_acr.log_habilit_transf_tit_acr
               then do:

                   /* --- Verifica se o Usu†rio corrente est† apto a Transferir ---*/
                   assign v_cod_parameters =  v_cod_usuar_corren + "," + 'Transferir no estabelecimento do lote ou t°tulo' + ",,,,,,,".
                   run pi_integr_acr_renegoc_erros(701, renegoc_acr.cod_estab, renegoc_acr.num_renegoc_cobr_acr, "","","","","","","","", v_cod_parameters).
                   return "NOK" /*l_nok*/ .
               end.
               else do:

                   /* --- Verifica se o Usu†rio corrente est† apto a Liquidar ---*/
                   run pi_validar_usuar_estab_acr (Input renegoc_acr.cod_estab,
                                                   Input "Liquidaá∆o" /*l_liquidacao*/,
                                                   output v_cod_return) /*pi_validar_usuar_estab_acr*/.
                   if  v_cod_return <> "no" /*l_no*/ 
                   and v_cod_return <> '3018'
                   then do:

                       run pi_validar_usuar_estab_acr (Input tt_integr_acr_item_renegoc.tta_cod_estab,
                                                       Input "Liquidaá∆o" /*l_liquidacao*/,
                                                       output v_cod_return) /*pi_validar_usuar_estab_acr*/.
                       if v_cod_return = "no" /*l_no*/ 
                       or v_cod_return = '3018' then
                          assign v_des_permissao = "Liquidar" /*l_liquidar*/ .
                   end.
                   else
                      assign v_des_permissao = "Liquidar" /*l_liquidar*/ .
               end /* else */.
           end /* if */.
           else do:
               /* --- Verifica se o Usu†rio corrente est† apto a Liquidar ---*/
               run pi_validar_usuar_estab_acr (Input tt_integr_acr_item_renegoc.tta_cod_estab,
                                               Input "Liquidaá∆o" /*l_liquidacao*/,
                                               output v_cod_return) /*pi_validar_usuar_estab_acr*/.
               if v_cod_return = "no" /*l_no*/ 
               or v_cod_return = '3018' then
                  assign v_des_permissao = "Liquidar" /*l_liquidar*/ .
           end /* else */.
       end.    
       else 
          assign v_des_permissao = "Implantar" /*l_implantar*/ .
    end.
    else do:

       /* --- Verifica se o Usu†rio corrente est† apto a Implantar ---*/
       run pi_validar_usuar_estab_acr (Input renegoc_acr.cod_estab,
                                       Input "Implantaá∆o" /*l_implantacao*/,
                                       output v_cod_return) /*pi_validar_usuar_estab_acr*/.   
       if  v_cod_return <> "no" /*l_no*/ 
       and v_cod_return <> '3018'
       then do:

           /* --- Verifica se o Usu†rio corrente est† apto a Liquidar ---*/
           run pi_validar_usuar_estab_acr (Input renegoc_acr.cod_estab,
                                           Input "Liquidaá∆o" /*l_liquidacao*/,
                                           output v_cod_return) /*pi_validar_usuar_estab_acr*/.       
           if v_cod_return = "no" /*l_no*/ 
           or v_cod_return = '3018' then
               assign v_des_permissao = "Liquidar" /*l_liquidar*/ .
       end.
       else 
          assign v_des_permissao = "Implantar" /*l_implantar*/ .
    end.
    case v_cod_return:
        when "no" /*l_no*/   then do:
            assign v_cod_parameters =  v_cod_usuar_corren + "," + v_des_permissao + ",,,,,,,".
            run pi_integr_acr_renegoc_erros(701, 
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","",
                                            v_cod_parameters).
            return "NOK" /*l_nok*/ .
        end.
        when "3018" then do:
            run pi_integr_acr_renegoc_erros(3018,
                                            renegoc_acr.cod_estab,
                                            renegoc_acr.num_renegoc_cobr_acr,
                                            "","","","","","","","","").
            return "NOK" /*l_nok*/ .
        end.
    end.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_validar_usuar_estab_acr_renegoc */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/

/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_messages
**  Descricao........: Mostra Mensagem com Ajuda
*****************************************************************************/
PROCEDURE pi_messages:

    def input param c_action    as char    no-undo.
    def input param i_msg       as integer no-undo.
    def input param c_param     as char    no-undo.

    def var c_prg_msg           as char    no-undo.

    assign c_prg_msg = "messages/":U
                     + string(trunc(i_msg / 1000,0),"99":U)
                     + "/msg":U
                     + string(i_msg, "99999":U).

    if search(c_prg_msg + ".r":U) = ? and search(c_prg_msg + ".p":U) = ? then do:
        message getStrTrans("Mensagem nr. ", "ACR") i_msg "!!!":U skip
                getStrTrans("Programa Mensagem", "ACR") c_prg_msg getStrTrans("n∆o encontrado.", "ACR")
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/*********************  End of api_integr_acr_renegoc_3 *********************/
