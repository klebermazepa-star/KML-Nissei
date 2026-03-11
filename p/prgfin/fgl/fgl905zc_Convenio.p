/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: api_retornar_sdo_ctbl_demonst
** Descricao.............: Aplication Program Interface
** Versao................:  1.00.00.045
** Procedimento..........: utl_retornar_sdo_ctbl
** Nome Externo..........: prgfin/fgl/fgl905zc.py
** Data Geracao..........: 01/09/2011 - 09:02:54
** Criado por............: src531
** Criado em.............: 20/08/2002 08:41:57
** Alterado por..........: fut43112_2
** Alterado em...........: 28/10/2009 16:39:17
** Gerado por............: fut41422
*****************************************************************************/
DEFINE BUFFER empresa               FOR ems5.empresa.
DEFINE BUFFER histor_exec_especial  FOR ems5.histor_exec_especial.
DEFINE BUFFER cliente               FOR ems5.cliente.
DEFINE BUFFER portador              FOR ems5.portador.
DEFINE BUFFER espec_docto           FOR ems5.espec_docto.
DEFINE BUFFER unid_negoc            FOR ems5.unid_negoc.
DEFINE BUFFER pais                  FOR ems5.pais.
DEFINE BUFFER segur_unid_organ      FOR ems5.segur_unid_organ.
DEFINE BUFFER unid_organ            FOR ems5.unid_organ.
DEFINE BUFFER ccusto                FOR ems5.ccusto.
DEFINE BUFFER estrut_unid_organ     FOR ems5.estrut_unid_organ.

def var c-versao-prg as char initial " 1.00.00.045":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i api_retornar_sdo_ctbl_demonst FGL}
&ENDIF

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=3":U.
/*************************************  *************************************/

&if "{&emsfin_version}" < "5.05" &then
run pi_messages (input "show",
                 input 5135,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "INICIAL","~~MAIOR","~~API_RETORNAR_SDO_CTBL_DEMONST","~~5.05","~~EMSFIN","~~{&emsfin_version}")) /*msg_5135*/.
&else

/********************* Temporary Table Definition Begin *********************/

def shared temp-table tt_ccustos_demonst no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field ttv_cod_ccusto_pai               as Character format "x(11)" label "Centro Custo Pai" column-label "Centro Custo Pai"
    field ttv_log_proces                   as logical format "Sim/Nao" initial no label "&prc(" column-label "&prc("
    index tt_cod_ccusto_pai               
          ttv_cod_ccusto_pai               ascending
    index tt_log_proces                   
          ttv_log_proces                   ascending
    index tt_select_id                     is primary unique
          tta_cod_empresa                  ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
    .

def new global shared temp-table tt_ccusto_segur no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    index tt_custo_cv                      is primary
          tta_cod_empresa                  ascending
          tta_cod_ccusto                   ascending
          tta_cod_plano_ccusto             ascending
    .

def shared temp-table tt_cta_ctbl_demonst no-undo
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field ttv_cod_cta_ctbl_pai             as character format "x(20)" label "Conta Ctbl Pai" column-label "Conta Ctbl Pai"
    field ttv_log_consid_apurac            as logical format "Sim/NÆo" initial no
    field tta_ind_espec_cta_ctbl           as character format "X(10)" initial "Anal¡tica" label "Esp‚cie Conta" column-label "Esp‚cie"
    index tt_cod_cta_ctbl_pai             
          tta_cod_plano_cta_ctbl           ascending
          ttv_cod_cta_ctbl_pai             ascending
    index tt_select_id                     is primary unique
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
    .

def temp-table tt_data_ult_exerc no-undo
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field ttv_dat_process                  as date format "99/99/9999"
    field ttv_dat_ult_exerc                as date format "99/99/9999"
    index tt_id                           
          tta_cod_cenar_ctbl               ascending
          ttv_dat_process                  ascending
    .

def temp-table tt_empresa_leitura_sdo no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    index tt_id                            is primary
          tta_cod_empresa                  ascending
    .

def temp-table tt_estrut_unid_organ no-undo like ems5.estrut_unid_organ
    field tta_cod_unid_organ_pai           as character format "x(3)" label "Unidade Organiz Pai" column-label "UO Pai"
    field tta_cod_unid_organ_filho         as character format "x(3)" label "Unid Organiz Filho" column-label "Unid Organiz Filho"
    field tta_num_seq_estrut_unid_organ    as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Sequˆncia"
    field tta_dat_inic_valid               as date format "99/99/9999" initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF label "In¡cio Validade" column-label "Inic Validade"
    field tta_dat_fim_valid                as date format "99/99/9999" initial 12/31/9999 label "Fim Validade" column-label "Fim Validade"
    field ttv_rec_unid_organ               as recid format ">>>>>>9" initial ?
    field ttv_cod_order                    as character format "x(40)"
    field ttv_log_finalid_unid_organ       as logical format "Sim/NÆo" initial no label "Inclui Finalidade" column-label "Inclui Finalidade"
    field ttv_log_unid_organ_rel           as logical format "Sim/NÆo" initial no
    field ttv_des_unid_organ               as character format "x(40)" label "Descri‡Æo" column-label "Descri‡Æo"
    field ttv_des_estrut_unid_organ        as character format "x(70)" label "Unid Organ" column-label "Unid Organ"
    field tta_cod_tip_unid_organ           as character format "x(3)" label "Tipo Unidade Organiz" column-label "Tipo UO"
    index tt_estrut                       
          tta_cod_unid_organ_pai           ascending
          tta_num_seq_estrut_unid_organ    ascending
    .

def temp-table tt_input_leitura_sdo_demonst no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_num_seq_1                    as integer format ">>>,>>9"
    index tt_ID                            is primary
          ttv_num_seq_1                    ascending
    .

def temp-table tt_input_sdo no-undo
    field tta_cod_unid_organ_inic          as character format "x(3)" label "UO Inicial" column-label "UO Unicial"
    field tta_cod_unid_organ_fim           as character format "x(3)" label "UO Final" column-label "UO FInal"
    field ttv_cod_unid_organ_orig_ini      as character format "x(3)" label "UO Origem" column-label "UO Origem"
    field ttv_cod_unid_organ_orig_fim      as character format "x(3)" label "UO Origem" column-label "UO Origem"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl_inic            as character format "x(20)" label "Conta Contabil" column-label "Conta Contab Inicial"
    field tta_cod_cta_ctbl_fim             as character format "x(20)" label "at‚" column-label "Conta Cont bil Final"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto_inic              as Character format "x(11)" label "Centro Custo" column-label "Centro Custo Inicial"
    field tta_cod_ccusto_fim               as Character format "x(11)" label "at‚" column-label "Centro Custo Final"
    field tta_cod_proj_financ_inic         as character format "x(8)" label "NÆo Utilizar..." column-label "Projeto"
    field tta_cod_proj_financ_fim          as character format "x(20)" label "Projeto Final" column-label "Projeto Final"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field tta_cod_estab_inic               as character format "x(3)" label "Estabelecimento" column-label "Estab Inicial"
    field tta_cod_estab_fim                as character format "x(3)" label "at‚" column-label "Estabel Final"
    field tta_cod_unid_negoc_inic          as character format "x(3)" label "Unid Negoc" column-label "UN Inicial"
    field tta_cod_unid_negoc_fim           as character format "x(3)" label "at‚" column-label "UN Final"
    field ttv_ind_espec_sdo_tot            as character format "X(15)"
    field ttv_log_consid_apurac_restdo     as logical format "Sim/NÆo" initial yes label "Consid Apurac Restdo" column-label "Apurac Restdo"
    field ttv_cod_elimina_intercomp        as character format "x(20)"
    field ttv_log_espec_sdo_ccusto         as logical format "Sim/NÆo" initial no
    field ttv_log_restric_estab            as logical format "Sim/NÆo" initial no label "Usa Segur Estab" column-label "Usa Segur Estab"
    field ttv_ind_espec_cta                as character format "X(10)"
    field ttv_cod_leitura                  as character format "x(8)"
    field ttv_cod_condicao                 as character format "x(20)"
    field ttv_cod_cenar_orctario           as character format "x(8)" label "Cenar Orctario" column-label "Cen rio Or‡ament rio"
    field ttv_cod_unid_orctaria            as character format "x(8)" label "Unid Or‡ament ria" column-label "Unid Or‡ament ria"
    field ttv_num_seq_orcto_ctbl           as integer format ">>>>>>>>9" label "Seq Orcto Cont bil" column-label "Seq Orcto Cont bil"
    field ttv_cod_vers_orcto_ctbl          as character format "x(10)" label "VersÆo Or‡amento" column-label "VersÆo Or‡amento"
    field ttv_cod_cta_ctbl_pfixa           as character format "x(20)" label "Parte Fixa" column-label "Parte Fixa Cta Ctbl"
    field ttv_cod_ccusto_pfixa             as character format "x(11)" label "Parte Fixa CCusto" column-label "Parte Fixa CCusto"
    field ttv_cod_proj_financ_pfixa        as character format "x(20)" label "Parte Fixa"
    field ttv_cod_cta_ctbl_excec           as character format "x(20)" initial "...................." label "Parte Exce‡Æo" column-label "Parte Exce‡Æo"
    field ttv_cod_ccusto_excec             as character format "x(11)" initial "..........." label "Parte Exce‡Æo" column-label "Parte Exce‡Æo"
    field ttv_cod_proj_financ_excec        as character format "x(20)" initial "...................." label "Exce‡Æo" column-label "Exce‡Æo"
    field ttv_num_seq_demonst_ctbl         as integer format ">>>,>>9" label "Sequˆncia" column-label "Sequˆncia"
    field ttv_num_seq_compos_demonst       as integer format ">>>>,>>9"
    field ttv_cod_chave                    as character format "x(40)"
    field ttv_cod_seq                      as character format "x(200)"
    field ttv_cod_dat_sdo_ctbl_inic        as character format "x(200)"
    field ttv_cod_dat_sdo_ctbl_fim         as character format "x(200)"
    field ttv_cod_exerc_ctbl               as character format "9999" label "Exerc¡cio Cont bil" column-label "Exerc¡cio Cont bil"
    field ttv_cod_period_ctbl              as character format "x(08)" label "Per¡odo Cont bil" column-label "Per¡odo Cont bil"
    .

def shared temp-table tt_item_demonst_ctbl_video no-undo
    field ttv_val_seq_demonst_ctbl         as decimal format ">>>,>>9.99" decimals 2
    field ttv_rec_item_demonst_ctbl_cad    as recid format ">>>>>>9"
    field ttv_rec_item_demonst_ctbl_video  as recid format ">>>>>>9"
    field ttv_cod_chave_1                  as character format "x(20)"
    field ttv_cod_chave_2                  as character format "x(20)"
    field ttv_cod_chave_3                  as character format "x(20)"
    field ttv_cod_chave_4                  as character format "x(20)"
    field ttv_cod_chave_5                  as character format "x(20)"
    field ttv_cod_chave_6                  as character format "x(20)"
    field ttv_des_chave_1                  as character format "x(40)"
    field ttv_des_chave_2                  as character format "x(40)"
    field ttv_des_chave_3                  as character format "x(40)"
    field ttv_des_chave_4                  as character format "x(40)"
    field ttv_des_chave_5                  as character format "x(40)"
    field ttv_des_chave_6                  as character format "x(40)"
    field tta_des_tit_ctbl                 as character format "x(40)" label "T¡tulo Cont bil" column-label "T¡tulo Cont bil"
    field ttv_des_valpres                  as character format "x(40)"
    field ttv_log_tit_ctbl_vld             as logical format "Sim/NÆo" initial no
    field tta_ind_funcao_col_demonst_ctbl  as character format "X(12)" initial "ImpressÆo" label "Fun‡Æo Coluna" column-label "Fun‡Æo Coluna"
    field tta_ind_orig_val_col_demonst     as character format "X(12)" initial "T¡tulo" label "Origem Valores" column-label "Origem Valores"
    field tta_cod_format_col_demonst_ctbl  as character format "x(40)" label "Formato Coluna" column-label "Formato Coluna"
    field ttv_cod_identif_campo            as character format "x(40)"
    field ttv_log_cta_sint                 as logical format "Sim/NÆo" initial no
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    index tt_id                            is primary
          ttv_cod_chave_1                  ascending
          ttv_cod_chave_2                  ascending
          ttv_cod_chave_3                  ascending
          ttv_cod_chave_4                  ascending
          ttv_cod_chave_5                  ascending
          ttv_cod_chave_6                  ascending
          ttv_val_seq_demonst_ctbl         ascending
    index tt_recid                        
          ttv_rec_item_demonst_ctbl_video  ascending
    index tt_recid_cad                    
          ttv_rec_item_demonst_ctbl_cad    ascending
    .

def temp-table tt_lista_ccusto no-undo
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field ttv_log_segur_ccusto             as logical format "Sim/NÆo" initial no label "Inclui Seguran‡a" column-label "Inclui Seguran‡a"
    index tt_id                           
          tta_cod_ccusto                   ascending
          ttv_log_segur_ccusto             ascending
    .

def temp-table tt_lista_cta_ctbl_demonst no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_proj_financ              as character format "x(20)" label "Projeto" column-label "Projeto"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field ttv_rec_lista_cta_ctbl_aux       as recid format ">>>>>>9"
    index tt_rec                           is primary
          ttv_rec_lista_cta_ctbl_aux       ascending
    .

def temp-table tt_lista_inform no-undo
    field ttv_cod_tip_lista                as character format "x(8)"
    field ttv_cod_inform                   as character format "x(60)"
    field ttv_cod_fill                     as character format "x(8)"
    field ttv_log_selec                    as logical format "Sim/NÆo" initial no column-label "Gera"
    index tt_conta                        
          ttv_cod_tip_lista                ascending
          ttv_cod_inform                   ascending
          ttv_cod_fill                     ascending
    index tt_id                            is primary
          ttv_cod_tip_lista                ascending
          ttv_cod_inform                   ascending
    index tt_select_id                    
          ttv_cod_tip_lista                ascending
          ttv_log_selec                    ascending
          ttv_cod_fill                     ascending
    .

def temp-table tt_log_elim_intercomp no-undo
    field ttv_log_elimina_intercomp        as logical format "Sim/NÆo" initial no
    field ttv_log_simul                    as logical format "Sim/NÆo" initial no label "Simuladas"
    .

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "Seqˆncia" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistˆncia" column-label "Inconsistˆncia"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    index tt_id                           
          ttv_num_seq                      ascending
          ttv_num_cod_erro                 ascending
    .

def temp-table tt_perc_particip no-undo
    field tta_cod_unid_organ_orig          as character format "x(3)" label "UO Origem" column-label "UO Origem"
    field tta_cod_unid_organ_dest          as character format "x(3)" label "UO Destino" column-label "UO Destino"
    field ttv_val_perc_criter_distrib      as decimal format ">>9.99" decimals 6 initial 0 label "Percentual" column-label "Percentual"
    index tt_id                           
          tta_cod_unid_organ_orig          ascending
          tta_cod_unid_organ_dest          ascending
    .

def shared temp-table tt_proj_financ_demonst no-undo
    field tta_cod_proj_financ              as character format "x(20)" label "Projeto" column-label "Projeto"
    field ttv_cod_proj_financ_pai          as character format "x(20)" label "Projeto Pai" column-label "Projeto Pai"
    field ttv_log_proces                   as logical format "Sim/Nao" initial no label "&prc(" column-label "&prc("
    field ttv_ind_espec_proj_financ        as character format "X(10)"
    index tt_cod_proj_financ_pai          
          ttv_cod_proj_financ_pai          ascending
    index tt_log_proces                   
          ttv_log_proces                   ascending
    index tt_select_id                     is primary unique
          tta_cod_proj_financ              ascending
    .

def shared temp-table tt_relacto_item_retorna no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "NumSeq"
    field ttv_rec_item_demonst             as recid format ">>>>>>9"
    field ttv_rec_ret                      as recid format ">>>>>>9"
    index tt_id                           
          tta_num_seq                      ascending
          ttv_rec_item_demonst             ascending
          ttv_rec_ret                      ascending
    index tt_id_2                         
          ttv_rec_item_demonst             ascending
          ttv_rec_ret                      ascending
    index tt_recid_item                   
          ttv_rec_item_demonst             ascending
    .

def shared temp-table tt_relacto_item_retorna_cons no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "NumSeq"
    field ttv_rec_ret_orig                 as recid format ">>>>>>9"
    field ttv_rec_ret_dest                 as recid format ">>>>>>9"
    index tt_id                           
          tta_num_seq                      ascending
          ttv_rec_ret_orig                 ascending
          ttv_rec_ret_dest                 ascending
    index tt_recid_item                   
          ttv_rec_ret_orig                 ascending
    .

def temp-table tt_relacto_unid_orctaria no-undo like relacto_unid_orctaria
    field tta_num_tip_inform_organ         as integer format ">9" initial 0 label "Tipo Inform Organ" column-label "Tipo Inform Organ"
    field tta_cod_inform_organ             as character format "x(60)" label "Informacao Organiz" column-label "Informacao Organiz"
    index tt_id                            is primary
          tta_num_tip_inform_organ         ascending
    .

def shared temp-table tt_retorna_sdo_ctbl_demonst no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "NumSeq"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_proj_financ              as character format "x(20)" label "Projeto" column-label "Projeto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_dat_sdo_ctbl                 as date format "99/99/9999" initial ? label "Data Saldo Cont bil" column-label "Data Saldo Cont bil"
    field tta_cod_unid_organ_orig          as character format "x(3)" label "UO Origem" column-label "UO Origem"
    field ttv_ind_espec_sdo                as character format "X(20)"
    field tta_val_sdo_ctbl_db              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto D‚bito" column-label "Movto D‚bito"
    field tta_val_sdo_ctbl_cr              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Cr‚dito" column-label "Movto Cr‚dito"
    field tta_val_sdo_ctbl_fim             as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Cont bil Final" column-label "Saldo Cont bil Final"
    field tta_val_apurac_restdo            as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apura‡Æo Resultado" column-label "Apura‡Æo Resultado"
    field tta_val_apurac_restdo_db         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apura‡Æo Restdo DB" column-label "Apura‡Æo Restdo DB"
    field tta_val_apurac_restdo_cr         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apura‡Æo Restdo CR" column-label "Apura‡Æo Restdo CR"
    field tta_val_apurac_restdo_acum       as decimal format "->>>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apuracao Final" column-label "Apuracao Final"
    field tta_val_movto_empenh             as decimal format "->>,>>>,>>>,>>9.99" decimals 9 initial 0 label "Movto Empenhado" column-label "Movto Empenhado"
    field tta_qtd_sdo_ctbl_db              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade DB" column-label "Quantidade DB"
    field tta_qtd_sdo_ctbl_cr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade CR" column-label "Quantidade CR"
    field tta_qtd_sdo_ctbl_fim             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade Final" column-label "Quantidade Final"
    field ttv_val_movto_ctbl               as decimal format ">>>,>>>,>>>,>>9.99" decimals 2
    field ttv_qtd_movto_ctbl               as decimal format "->>>>,>>9.9999" decimals 4
    field tta_qtd_movto_empenh             as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtde Movto Empenhado" column-label "Qtde Movto Empenhado"
    field tta_val_orcado                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Or‡ado" column-label "Valor Or‡ado"
    field tta_val_orcado_sdo               as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Or‡ado" column-label "Saldo Or‡ado"
    field tta_qtd_orcado                   as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtdade Or‡ada" column-label "Qtdade Or‡ada"
    field tta_qtd_orcado_sdo               as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Saldo Quantidade" column-label "Saldo Quantidade"
    field ttv_rec_ret_sdo_ctbl             as recid format ">>>>>>9"
    field ttv_log_sdo_orcado_sint          as logical format "Sim/NÆo" initial no
    field ttv_val_perc_criter_distrib      as decimal format ">>9.99" decimals 6 initial 0 label "Percentual" column-label "Percentual"
    index tt_busca                        
          tta_cod_empresa                  ascending
          tta_cod_finalid_econ             ascending
          tta_cod_cenar_ctbl               ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_dat_sdo_ctbl                 ascending
    index tt_busca_proj                   
          tta_cod_empresa                  ascending
          tta_cod_finalid_econ             ascending
          tta_cod_cenar_ctbl               ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_proj_financ              ascending
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_dat_sdo_ctbl                 ascending
    index tt_id                            is primary unique
          tta_cod_empresa                  ascending
          tta_cod_finalid_econ             ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_proj_financ              ascending
          tta_cod_cenar_ctbl               ascending
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
          tta_dat_sdo_ctbl                 ascending
          tta_num_seq                      ascending
          ttv_ind_espec_sdo                ascending
          tta_cod_unid_organ_orig          ascending
    index tt_id2                          
          tta_cod_empresa                  ascending
          tta_cod_finalid_econ             ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_cenar_ctbl               ascending
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
          tta_cod_proj_financ              ascending
          tta_dat_sdo_ctbl                 ascending
          ttv_ind_espec_sdo                ascending
          tta_num_seq                      ascending
    index tt_rec                          
          ttv_rec_ret_sdo_ctbl             ascending
    .

def shared temp-table tt_retorna_sdo_orcto_ccusto no-undo
    field ttv_rec_ret_sdo_ctbl             as recid format ">>>>>>9"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_val_orcado                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Or‡ado" column-label "Valor Or‡ado"
    field tta_val_orcado_sdo               as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Or‡ado" column-label "Saldo Or‡ado"
    field tta_qtd_orcado                   as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtdade Or‡ada" column-label "Qtdade Or‡ada"
    field tta_qtd_orcado_sdo               as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Saldo Quantidade" column-label "Saldo Quantidade"
    index tt_id                            is primary unique
          ttv_rec_ret_sdo_ctbl             ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
    .

def shared temp-table tt_unid_negocio no-undo
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field ttv_cod_unid_negoc_pai           as character format "x(3)" label "Un Neg Pai" column-label "Un Neg Pai"
    field ttv_log_proces                   as logical format "Sim/Nao" initial no label "&prc(" column-label "&prc("
    field ttv_ind_espec_unid_negoc         as character format "X(10)" label "Esp‚cie UN" column-label "Esp‚cie UN"
    index tt_cod_unid_negoc_pai           
          ttv_cod_unid_negoc_pai           ascending
    index tt_log_proces                   
          ttv_log_proces                   ascending
    index tt_select_id                     is primary unique
          tta_cod_unid_negoc               ascending
    .

def temp-table tt_unid_orctaria no-undo
    field tta_cod_unid_orctaria            as character format "x(8)" label "Unid Or‡ament ria" column-label "Unid Or‡ament ria"
    .



/********************** Temporary Table Definition End **********************/

/************************ Parameter Definition Begin ************************/

def Input param p_num_vers_integr_api
    as integer
    format ">>>>,>>9"
    no-undo.
def input param table 
    for tt_input_sdo.
def Input param table 
    for tt_input_leitura_sdo_demonst.
def output param p_des_lista_estab
    as character
    format "x(2000)"
    no-undo.
def output param table 
    for tt_log_erros.


/************************* Parameter Definition End *************************/

/************************** Buffer Definition Begin *************************/

def buffer btt_cta_ctbl_demonst
    for tt_cta_ctbl_demonst.
def buffer btt_lista_inform_ccusto
    for tt_lista_inform.
def buffer btt_lista_inform_ccusto_aux
    for tt_lista_inform.
def buffer btt_lista_inform_conta
    for tt_lista_inform.
def buffer btt_lista_inform_conta_aux
    for tt_lista_inform.
def buffer btt_lista_inform_proj
    for tt_lista_inform.
def buffer btt_lista_inform_proj_aux
    for tt_lista_inform.
def buffer btt_lista_inform_un
    for tt_lista_inform.
def buffer btt_proj_financ_demonst
    for tt_proj_financ_demonst.
def buffer btt_retorna_sdo_ctbl_demonst
    for tt_retorna_sdo_ctbl_demonst.
def buffer btt_unid_negocio
    for tt_unid_negocio.
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_cta_ctbl
    for cta_ctbl.
&endif
&if "{&emsfin_version}" >= "1.00" &then
def buffer b_estrut_ctbl_movto_analit
    for estrut_ctbl_movto_analit.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_period_ctbl
    for period_ctbl.
&endif
&if "{&emsfin_version}" >= "5.05" &then
def buffer b_sdo_ctbl
    for sdo_ctbl.
&endif
&if "{&emsfin_version}" >= "5.05" &then
def buffer b_unid_orctaria_enter
    for unid_orctaria.
&endif


/*************************** Buffer Definition End **************************/

/************************* Variable Definition Begin ************************/

def var v_cdn_cont_ccusto
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_cont_cta
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_cont_proj
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_cont_un
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_ccusto
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_ccusto_excec
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_con_excec
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_cta
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_dat
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_orcto
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_proj
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_proj_excec
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_tot_un
    as Integer
    format ">>>,>>9":U
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def var v_cod_ccusto
    as Character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_ccusto_analit
    as character
    format "x(8)":U
    no-undo.
def var v_cod_ccusto_aux
    as Character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_ccusto_excec
    as character
    format "x(11)":U
    initial "..........."
    label "Parte Exce‡Æo"
    column-label "Parte Exce‡Æo"
    no-undo.
def var v_cod_ccusto_final
    as character
    format "x(11)":U
    initial "ZZZZZZZZZZZ" /*l_ZZZZZZZZZZZ*/
    label "at‚"
    column-label "at‚"
    no-undo.
def var v_cod_ccusto_inic
    as character
    format "x(11)":U
    label "C.Custo Inicial"
    column-label "C.Custo Inicial"
    no-undo.
def var v_cod_ccusto_initial
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_ccusto_pfixa
    as character
    format "x(11)":U
    label "Parte Fixa CCusto"
    column-label "Parte Fixa CCusto"
    no-undo.
def var v_cod_cenar_ctbl
    as character
    format "x(8)":U
    label "Cen rio Cont bil"
    column-label "Cen rio Cont bil"
    no-undo.
def var v_cod_cenar_orctario
    as character
    format "x(8)":U
    label "Cenar Orctario"
    column-label "Cen rio Or‡ament rio"
    no-undo.
def var v_cod_chave
    as character
    format "x(40)":U
    no-undo.
def var v_cod_chave_1
    as character
    format "x(20)":U
    no-undo.
def var v_cod_chave_2
    as character
    format "x(20)":U
    no-undo.
def var v_cod_chave_3
    as character
    format "x(20)":U
    no-undo.
def var v_cod_chave_4
    as character
    format "x(20)":U
    no-undo.
def var v_cod_chave_5
    as character
    format "x(20)":U
    no-undo.
def var v_cod_chave_6
    as character
    format "x(20)":U
    no-undo.
def var v_cod_condicao
    as character
    format "x(20)":U
    no-undo.
def var v_cod_cta_ctbl
    as character
    format "x(20)":U
    label "Conta Cont bil"
    column-label "Conta Cont bil"
    no-undo.
def var v_cod_cta_ctbl_analit
    as character
    format "x(8)":U
    no-undo.
def var v_cod_cta_ctbl_ant_2
    as character
    format "x(8)":U
    no-undo.
def var v_cod_cta_ctbl_apurac_restdo
    as character
    format "x(8)":U
    no-undo.
def var v_cod_cta_ctbl_aux
    as character
    format "x(20)":U
    label "Conta Cont bil"
    column-label "Conta Cont bil"
    no-undo.
def var v_cod_cta_ctbl_excec
    as character
    format "x(20)":U
    initial "...................."
    label "Parte Exce‡Æo"
    column-label "Parte Exce‡Æo"
    no-undo.
def var v_cod_cta_ctbl_final
    as character
    format "x(20)":U
    initial "ZZZZZZZZZZZZZZZZZZZZ"
    label "at‚"
    column-label "at‚"
    no-undo.
def var v_cod_cta_ctbl_inic
    as character
    format "x(20)":U
    label "Conta Cont bil"
    column-label "Conta Cont bil"
    no-undo.
def var v_cod_cta_ctbl_pfixa
    as character
    format "x(20)":U
    label "Parte Fixa"
    column-label "Parte Fixa Cta Ctbl"
    no-undo.
def var v_cod_dat_sdo_ctbl_fim_aux
    as character
    format "x(8)":U
    no-undo.
def var v_cod_dat_sdo_ctbl_inic_aux
    as character
    format "x(8)":U
    no-undo.
def var v_cod_demonst_ctbl
    as character
    format "x(8)":U
    label "Demonstrativo"
    column-label "Demonstrativo"
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu rio"
    column-label "Usu rio"
    no-undo.
def var v_cod_elimina_intercomp
    as character
    format "x(20)":U
    no-undo.
def new global shared var v_cod_empres_usuar
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
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_estab_final
    as character
    format "x(3)":U
    initial "ZZZ"
    label "Final"
    column-label "Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_estab_final
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "Final"
    column-label "Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_estab_inic
    as character
    format "x(3)":U
    label "Estab Inicial"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_estab_inic
    as Character
    format "x(5)":U
    label "Estab Inicial"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_exerc_ctbl
    as character
    format "9999":U
    label "Exerc¡cio Cont bil"
    column-label "Exerc¡cio Cont bil"
    no-undo.
def var v_cod_exerc_ctbl_aux
    as character
    format "9999":U
    label "Exerc¡cio Cont bil"
    column-label "Exerc¡cio Cont bil"
    no-undo.
def var v_cod_finalid_econ
    as character
    format "x(10)":U
    label "Finalidade Econ“mica"
    column-label "Finalidade Econ“mica"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usu rios"
    column-label "Grupo"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def var v_cod_indic_econ
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Moeda"
    no-undo.
def var v_cod_leitura
    as character
    format "x(8)":U
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
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa¡s Empresa Usu rio"
    column-label "Pa¡s"
    no-undo.
def var v_cod_period_ctbl_aux
    as character
    format "x(8)":U
    no-undo.
def var v_cod_plano_ccusto
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def var v_cod_plano_cta_ctbl
    as character
    format "x(8)":U
    label "Plano Contas"
    column-label "Plano Contas"
    no-undo.
def var v_cod_proj_financ
    as character
    format "x(20)":U
    label "Projeto"
    column-label "Projeto"
    no-undo.
def var v_cod_proj_financ_000
    as character
    format "x(20)":U
    label "Projeto"
    column-label "Projeto"
    no-undo.
def var v_cod_proj_financ_999
    as character
    format "x(20)":U
    label "Projeto"
    column-label "Projeto"
    no-undo.
def var v_cod_proj_financ_analit
    as character
    format "x(8)":U
    no-undo.
def var v_cod_proj_financ_aux
    as character
    format "x(20)":U
    label "Projeto"
    column-label "Projeto"
    no-undo.
def var v_cod_proj_financ_excec
    as character
    format "x(20)":U
    initial "...................."
    label "Exce‡Æo"
    column-label "Exce‡Æo"
    no-undo.
def var v_cod_proj_financ_final
    as character
    format "x(20)":U
    label "Projeto Final"
    column-label "Projeto Final"
    no-undo.
def var v_cod_proj_financ_inic
    as character
    format "x(20)":U
    label "Projeto Inicial"
    no-undo.
def var v_cod_proj_financ_pfixa
    as character
    format "x(20)":U
    label "Parte Fixa"
    no-undo.
def var v_cod_return
    as character
    format "x(40)":U
    no-undo.
def var v_cod_seq_aux
    as character
    format "x(8)":U
    no-undo.
def var v_cod_seq_orcto_ctbl_tot
    as character
    format "x(200)":U
    no-undo.
def var v_cod_unid_negoc
    as character
    format "x(3)":U
    label "Unid Neg¢cio"
    column-label "Un Neg"
    no-undo.
def var v_cod_unid_negoc_analit
    as character
    format "x(8)":U
    no-undo.
def var v_cod_unid_negoc_aux
    as character
    format "x(3)":U
    label "Unid Neg¢cio"
    column-label "Un Neg"
    no-undo.
def var v_cod_unid_negoc_final
    as character
    format "x(3)":U
    initial "ZZZ"
    label "at‚"
    column-label "at‚"
    no-undo.
def var v_cod_unid_negoc_inic
    as character
    format "x(3)":U
    label "Unidade Neg¢cio"
    column-label "Unidade Neg¢cio"
    no-undo.
def new global shared var v_cod_unid_negoc_usuar
    as character
    format "x(3)":U
    view-as combo-box
    list-items ""
    inner-lines 5
    bgcolor 15 font 2
    label "Unidade Neg¢cio"
    column-label "Unid Neg¢cio"
    no-undo.
def var v_cod_unid_orctaria
    as character
    format "x(8)":U
    label "Unid Or‡ament ria"
    column-label "Unid Or‡ament ria"
    no-undo.
def var v_cod_unid_orctaria_tot
    as character
    format "x(200)":U
    no-undo.
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ
    as character
    format "x(3)":U
    label "Unid Organizacional"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ
    as Character
    format "x(5)":U
    label "Unid Organizacional"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "Final"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ_fim
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "Final"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ_ini
    as character
    format "x(3)":U
    label "UO Inicial"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ_ini
    as Character
    format "x(5)":U
    label "UO Inicial"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ_orig_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "UO Origem"
    column-label "UO Origem"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ_orig_fim
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "UO Origem"
    column-label "UO Origem"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ_orig_ini
    as character
    format "x(3)":U
    label "UO Origem"
    column-label "UO Origem"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ_orig_ini
    as Character
    format "x(5)":U
    label "UO Origem"
    column-label "UO Origem"
    no-undo.
&ENDIF
def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_cod_vers_orcto_ctbl
    as character
    format "x(10)":U
    label "VersÆo Or‡amento"
    column-label "VersÆo Or‡amento"
    no-undo.
def var v_cod_vers_orcto_ctbl_tot
    as character
    format "x(200)":U
    no-undo.
def var v_dat_movto_ctbl
    as date
    format "99/99/9999":U
    no-undo.
def var v_dat_period_pos
    as date
    format "99/99/9999":U
    no-undo.
def var v_dat_sdo_cta_fim
    as date
    format "99/99/9999":U
    label "at‚"
    column-label "at‚"
    no-undo.
def var v_dat_sdo_cta_inic
    as date
    format "99/99/9999":U
    label "Data Saldo"
    column-label "Data Saldo"
    no-undo.
def var v_des_lista_estab
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 80 by 12
    bgcolor 15 font 2
    label "Estabelecimentos"
    column-label "Estabelecimentos"
    no-undo.
def var v_des_lista_estab_com_segur
    as character
    format "x(40)":U
    no-undo.
def var v_des_lista_estab_sem_segur
    as character
    format "x(40)":U
    no-undo.
def var v_des_percent_complete
    as character
    format "x(06)":U
    no-undo.
def var v_des_percent_complete_fnd
    as character
    format "x(08)":U
    no-undo.
def var v_ind_espec_cta
    as character
    format "X(10)":U
    no-undo.
def var v_ind_espec_sdo
    as character
    format "X(20)":U
    no-undo.
def var v_ind_espec_sdo_tot
    as character
    format "X(15)":U
    no-undo.
def var v_ind_tip_ccusto_consid
    as character
    format "X(20)":U
    initial "Administrativo" /*l_administrativo*/
    view-as combo-box
    list-items "Administrativo","Produtivo","Ambos"
     /*l_administrativo*/ /*l_produtivo*/ /*l_ambos*/
    inner-lines 3
    bgcolor 15 font 2
    label "Tipo"
    column-label "Tipo"
    no-undo.
def var v_log_consid_apurac_restdo
    as logical
    format "Sim/NÆo"
    initial yes
    view-as toggle-box
    label "Consid Apurac Restdo"
    column-label "Apurac Restdo"
    no-undo.
def var v_log_consolid_recur
    as logical
    format "Sim/NÆo"
    initial NO
    view-as toggle-box
    label "Consolida‡Æo Recurs"
    column-label "Consolid Recurv"
    no-undo.
def var v_log_cta_sint
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_espec_sdo_ccusto
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_existe_orcto_ccusto
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_funcao_dw_demonst
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_funcao_perc_dec
    as logical
    format "Sim/NÆo"
    initial NO
    no-undo.
def var v_log_movto_ctbl
    as logical
    format "Sim/NÆo"
    initial yes
    no-undo.
def var v_log_orcto_cta_sint
    as logical
    format "Sim/NÆo"
    initial NO
    no-undo.
def var v_log_plano_cta_ctbl_unico
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_possui_permis
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_restric_estab
    as logical
    format "Sim/NÆo"
    initial no
    view-as toggle-box
    label "Usa Segur Estab"
    column-label "Usa Segur Estab"
    no-undo.
def var v_log_return
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_saldo
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_sdo_orcado_realzdo
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_ccusto
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont
    as integer
    format ">,>>9":U
    initial 0
    no-undo.
def var v_num_contador
    as integer
    format ">>>>,>>9":U
    initial 0
    no-undo.
def var v_num_cont_1
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont_2
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont_ccusto_aux
    as integer
    format ">>>>>>,>>9":U
    no-undo.
def var v_num_cont_cta
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont_proj_financ
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_cont_unid_negoc
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_count
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_count_1
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_count_2
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_dias_period_pos
    as integer
    format ">>9":U
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_period_ctbl
    as integer
    format "99":U
    initial 01
    label "Per¡odo Atual"
    column-label "Period"
    no-undo.
def var v_num_seq
    as integer
    format ">>>,>>9":U
    label "Seqˆncia"
    column-label "Seq"
    no-undo.
def var v_num_seq_1
    as integer
    format ">>>,>>9":U
    no-undo.
def var v_num_seq_compos_demonst
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_seq_demonst_ctbl
    as integer
    format ">>>,>>9":U
    label "Sequˆncia"
    column-label "Sequˆncia"
    no-undo.
def var v_num_seq_orcto_ctbl
    as integer
    format ">>>>>>>>9":U
    label "Seq Orcto Cont bil"
    column-label "Seq Orcto Cont bil"
    no-undo.
def var v_num_tam_ccusto
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_tam_cta
    as integer
    format ">>9":U
    no-undo.
def var v_num_tot_1
    as integer
    format ">>>>,>>9":U
    initial 0
    no-undo.
def var v_qtd_movto_ctbl_cr
    as decimal
    format ">>>>9":U
    decimals 0
    no-undo.
def var v_qtd_movto_ctbl_db
    as decimal
    format "->>>>,>>9.9999":U
    decimals 4
    no-undo.
def var v_qtd_sdo_ctbl_inic
    as decimal
    format ">>>9":U
    decimals 0
    no-undo.
def var v_qtd_sdo_ctbl_inic_tot
    as decimal
    format ">>>9":U
    decimals 0
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_movto_ctbl
    as decimal
    format ">>>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_movto_ctbl_cr
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_movto_empenh
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 9
    label "Movto Empenhado"
    column-label "Movto Empenhado"
    no-undo.
def var v_val_sdo_ctbl_inic
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Saldo Inicial"
    column-label "Saldo Inicial"
    no-undo.
def var v_val_sdo_ctbl_inic_tot
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_apurac_restdo_acum
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_cod_final                      as character       no-undo. /*local*/
def var v_cod_initial                    as character       no-undo. /*local*/
def var v_cod_lista_cta_restric          as character       no-undo. /*local*/
def var v_cod_plano_ccusto_sdo           as character       no-undo. /*local*/
def var v_log_busca_empenh               as logical         no-undo. /*local*/
def var v_log_busca_sdo_nova_logic       as logical         no-undo. /*local*/
def var v_log_sdo_orcado                 as logical         no-undo. /*local*/
def var v_num_cont_aux                   as integer         no-undo. /*local*/


/************************** Variable Definition End *************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_001
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_can2
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1.
/****************************** Function Button *****************************/


/*************************** Button Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_dlg_02_percent_update
    rt_001
         at row 01.29 col 02.00
    " Percentual Completo " view-as text
         at row 01.00 col 04.00
    v_des_percent_complete_fnd
         at row 02.04 col 03.00 no-label
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_des_percent_complete
         at row 02.04 col 03.00 no-label
         view-as fill-in
         size-chars 7.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_can2
         at row 03.50 col 20.00 font ?
         help "Cancela"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 50.00 by 05.00
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "".
    /* adjust size of objects in this frame */
    assign bt_can2:width-chars  in frame f_dlg_02_percent_update = 10.00
           bt_can2:height-chars in frame f_dlg_02_percent_update = 01.00
           rt_001:width-chars   in frame f_dlg_02_percent_update = 46.72
           rt_001:height-chars  in frame f_dlg_02_percent_update = 01.92.
    /* set private-data for the help system */
    assign v_des_percent_complete_fnd:private-data in frame f_dlg_02_percent_update = "HLP=000022169":U
           v_des_percent_complete:private-data     in frame f_dlg_02_percent_update = "HLP=000022167":U
           bt_can2:private-data                    in frame f_dlg_02_percent_update = "HLP=000011451":U
           frame f_dlg_02_percent_update:private-data                               = "HLP=000010975".



{include/i_fclfrm.i f_dlg_02_percent_update }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_can2 IN FRAME f_dlg_02_percent_update
DO:

    hide frame f_dlg_02_percent_update.

    stop.
END. /* ON CHOOSE OF bt_can2 IN FRAME f_dlg_02_percent_update */


/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/


ON HELP OF FRAME f_dlg_02_percent_update ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_dlg_02_percent_update */

ON RIGHT-MOUSE-DOWN OF FRAME f_dlg_02_percent_update ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_right_mouse_down_dialog_box */
    if  (self:type <> "DIALOG-BOX" /*l_dialog_box*/ )
    and (self:type <> "FRAME" /*l_frame*/      )
    and (self:type <> "text" /*l_text*/       )
    and (self:type <> "IMAGE" /*l_image*/      )
    and (self:type <> "RECTANGLE" /*l_rectangle*/  )
    then do:

        assign v_wgh_frame = self:parent.

        if  self:type        = "fill-in" /*l_fillin*/ 
        and v_wgh_frame:type = "Browse" /*l_browse*/  then
            return no-apply.

        if  valid-handle(self:popup-menu) = yes then
            return no-apply.

        assign v_wgh_frame = self:frame.

        if  (v_wgh_frame:type <> "DIALOG-BOX" /*l_dialog_box*/ ) and (v_wgh_frame:frame <> ?)
        then do:
               assign v_wgh_frame     = v_wgh_frame:frame.
        end /* if */.
        assign v_nom_title_aux    = v_wgh_frame:title
               v_wgh_frame:title  = self:help.
    end /* if */.
    /* End_Include: i_right_mouse_down_dialog_box */

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_dlg_02_percent_update */

ON RIGHT-MOUSE-UP OF FRAME f_dlg_02_percent_update ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_right_mouse_up_dialog_box */
    if  (self:type <> "DIALOG-BOX" /*l_dialog_box*/ )
    and (self:type <> "FRAME" /*l_frame*/      )
    and (self:type <> "text" /*l_text*/       )
    and (self:type <> "IMAGE" /*l_image*/      )
    and (self:type <> "RECTANGLE" /*l_rectangle*/  )
    then do:

        assign v_wgh_frame = self:parent.

        if  self:type        = "fill-in" /*l_fillin*/ 
        and v_wgh_frame:type = "Browse" /*l_browse*/  then
            return no-apply.

        if  valid-handle(self:popup-menu) = yes then
            return no-apply.

        assign v_wgh_frame        = self:frame.
        if  (v_wgh_frame:type <> "DIALOG-BOX" /*l_dialog_box*/ ) and (v_wgh_frame:frame <> ?)
        then do:
               assign v_wgh_frame     = v_wgh_frame:frame.
        end /* if */.
        assign v_wgh_frame:title  = v_nom_title_aux.
    end /* if */.

    /* End_Include: i_right_mouse_up_dialog_box */

END. /* ON RIGHT-MOUSE-UP OF FRAME f_dlg_02_percent_update */

ON WINDOW-CLOSE OF FRAME f_dlg_02_percent_update
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_dlg_02_percent_update */


/***************************** Frame Trigger End ****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i api_retornar_sdo_ctbl_demonst}


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
    run pi_version_extract ('api_retornar_sdo_ctbl_demonst':U, 'prgfin/fgl/fgl905zc.py':U, '1.00.00.045':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */


/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = '@(&program)' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = '@(&program)'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */



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
    where prog_dtsul.cod_prog_dtsul = "api_retornar_sdo_ctbl_demonst":U
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


/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUN€ÇO *******************************
** Fun‡Æo para tratamento dos Entries dos c¢digos livres
** 
**  p_num_posicao     - N£mero do Entry que ser  atualizado
**  p_cod_campo       - Campo / Vari vel que ser  atualizada
**  p_cod_separador   - Separador que ser  utilizado
*******************************************************************/

    if  p_num_posicao <= 0  then do:
        assign p_num_posicao  = 1.
    end.
    if num-entries(p_cod_campo,p_cod_separador) >= p_num_posicao  then do:
       return entry(p_num_posicao,p_cod_campo,p_cod_separador).
    end.
    return "" /*l_*/ .

END FUNCTION.

/* End_Include: i_declara_GetEntryField */


/* Begin_Include: i_declara_Verifica_Program_Name */
FUNCTION Verifica_Program_Name RETURN LOG (INPUT Programa AS CHAR, INPUT Repeticoes AS INT):
    DEF VAR v_num_cont  AS INTEGER NO-UNDO.
    DEF VAR v_log_achou AS LOGICAL NO-UNDO.


    /* Begin_Include: i_verifica_program_name */
    /* include feita para nÆo ocorrer problemas na utiliza‡Æo do comando program-name */
    assign  v_num_cont  = 1
            v_log_achou = no.
    bloco:
    repeat:
        if index(program-name(v_num_cont),Programa) = ? then 
            leave bloco.
        if index(program-name(v_num_cont),Programa) <> 0 then do:
            assign v_log_achou = yes.
            leave bloco.
        end.
        if v_num_cont = Repeticoes then
            leave bloco.
        assign v_num_cont = v_num_cont + 1.
    end.
    /* End_Include: i_verifica_program_name */


    RETURN v_log_achou.
END FUNCTION.
/* End_Include: i_declara_Verifica_Program_Name */


/* Begin_Include: i_declara_GetDefinedFunction */
FUNCTION GetDefinedFunction RETURNS LOGICAL (INPUT SPP AS CHARACTER):

    DEF VAR v_log_retorno AS LOGICAL INITIAL NO NO-UNDO.

    IF CAN-FIND (FIRST histor_exec_especial NO-LOCK
         WHERE histor_exec_especial.cod_modul_dtsul = "UFN" /* l_ufn*/ 
           AND histor_exec_especial.cod_prog_dtsul  = SPP) THEN
        ASSIGN v_log_retorno = YES.


    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            SPP      at 1 
            v_log_retorno  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */
    .

    RETURN v_log_retorno.
END FUNCTION.
/* End_Include: i_declara_GetDefinedFunction */

assign v_log_orcto_cta_sint = &IF DEFINED (BF_FIN_ORCTO_CTA_SINT_BGC) &THEN YES 
                              &ELSE GetDefinedFunction('SPP_ORCTO_CTA_SINT_BGC':U) &ENDIF.
assign v_log_funcao_perc_dec = &if defined(BF_FIN_PERC_DECIMAIS) &then yes
                               &else GetDefinedFunction('SPP_PERC_DECIMAIS') &endif
       v_log_funcao_dw_demonst = GetDefinedFunction('SPP_DWF_DEMONST':U).

assign v_log_busca_sdo_nova_logic = GetDefinedFunction('SPP_NOVA_LOGICA_DEMONST':U).

/* --- Eliminar os registros da temp-table de Output ---*/
EMPTY TEMP-TABLE tt_retorna_sdo_ctbl_demonst.
EMPTY TEMP-TABLE tt_retorna_sdo_orcto_ccusto.
EMPTY TEMP-TABLE tt_log_erros.
EMPTY TEMP-TABLE tt_ccusto_segur.
if not v_cod_dwb_user begins 'es_' 
   and Verifica_Program_Name('pi_item_demonst_ctbl_video':U,30) then do:
   assign v_num_tot_1    = 0
          v_num_contador = 0.
   for each tt_input_sdo no-lock:
       assign v_num_tot_1 = v_num_tot_1 + 1.
   end.
end.

/* --- Ler os par³metros de Entrada da API ---*/
leitura_block:
for each tt_input_sdo:

    if not v_cod_dwb_user begins 'es_' 
      and Verifica_Program_Name('pi_item_demonst_ctbl_video':U,30) then do:
       run pi_percent_update (Input v_num_tot_1,
                              Input v_num_contador,
                              Input "Buscando Saldos..." /*l_buscando_saldos*/ ).
       disable bt_can2 with frame f_dlg_02_percent_update.
       assign v_num_contador = v_num_contador + 1.
   end.

   assign v_log_busca_empenh   = no
          v_log_consolid_recur = no
          v_cod_demonst_ctbl   = "".

    do v_num_cont_aux = 1 to num-entries(tt_input_sdo.ttv_cod_seq, chr(10)):
       for each tt_input_leitura_sdo_demonst
           where tt_input_leitura_sdo_demonst.ttv_num_seq_1 = int(entry(v_num_cont_aux, tt_input_sdo.ttv_cod_seq, chr(10))):
           case tt_input_leitura_sdo_demonst.ttv_cod_label:
               when "Valores Empenhados" /*l_valores_empenhados*/  then do:
                   if tt_input_leitura_sdo_demonst.ttv_des_conteudo = "yes" /*l_yes*/  then
                       assign v_log_busca_empenh = yes.
                   else
                       assign v_log_busca_empenh = no.
               end.
               when "Consolida‡Æo Recursiva" /*l_consolida‡Æo_recursiva*/  then do:
                   if  tt_input_leitura_sdo_demonst.ttv_des_conteudo = "yes" /*l_yes*/  then
                       assign v_log_consolid_recur = yes.
                   else
                       assign v_log_consolid_recur = no.
               end.
               when "Demonstrativo Cont bil" /*l_demonstrativo_contabil*/  then do:
                   assign v_cod_demonst_ctbl = tt_input_leitura_sdo_demonst.ttv_des_conteudo.
               end.
           end case.
       end.
   end.
   assign v_cod_unid_organ_ini       = tt_input_sdo.tta_cod_unid_organ_inic
          v_cod_unid_organ_fim       = tt_input_sdo.tta_cod_unid_organ_fim
          v_cod_unid_organ_orig_ini  = tt_input_sdo.ttv_cod_unid_organ_orig_ini
          v_cod_unid_organ_orig_fim  = tt_input_sdo.ttv_cod_unid_organ_orig_fim
          v_cod_cenar_ctbl           = tt_input_sdo.tta_cod_cenar_ctbl
          v_cod_finalid_econ         = tt_input_sdo.tta_cod_finalid_econ
          v_cod_plano_cta_ctbl       = tt_input_sdo.tta_cod_plano_cta_ctbl
          v_cod_plano_ccusto         = tt_input_sdo.tta_cod_plano_ccusto
          v_cod_cta_ctbl_inic        = tt_input_sdo.tta_cod_cta_ctbl_inic
          v_cod_cta_ctbl_final       = tt_input_sdo.tta_cod_cta_ctbl_fim
          v_cod_proj_financ_inic     = tt_input_sdo.tta_cod_proj_financ_inic
          v_cod_proj_financ_final    = tt_input_sdo.tta_cod_proj_financ_fim
          v_cod_estab_inic           = tt_input_sdo.tta_cod_estab_inic
          v_cod_estab_final          = tt_input_sdo.tta_cod_estab_fim
          v_cod_unid_negoc_inic      = tt_input_sdo.tta_cod_unid_negoc_inic
          v_cod_unid_negoc_final     = tt_input_sdo.tta_cod_unid_negoc_fim
          v_cod_ccusto_inic          = tt_input_sdo.tta_cod_ccusto_inic
          v_cod_ccusto_final         = tt_input_sdo.tta_cod_ccusto_fim
          v_log_consid_apurac_restdo = tt_input_sdo.ttv_log_consid_apurac_restdo
          v_cod_elimina_intercomp    = tt_input_sdo.ttv_cod_elimina_intercomp
          v_log_espec_sdo_ccusto     = tt_input_sdo.ttv_log_espec_sdo_ccusto
          v_log_restric_estab        = tt_input_sdo.ttv_log_restric_estab
          v_ind_espec_sdo_tot        = tt_input_sdo.ttv_ind_espec_sdo_tot
          v_ind_espec_cta            = tt_input_sdo.ttv_ind_espec_cta
          v_cod_leitura              = tt_input_sdo.ttv_cod_leitura
          v_cod_condicao             = tt_input_sdo.ttv_cod_condicao
          v_cod_cenar_orctario       = tt_input_sdo.ttv_cod_cenar_orctario
          v_cod_unid_orctaria        = tt_input_sdo.ttv_cod_unid_orctaria
          v_num_seq_orcto_ctbl       = tt_input_sdo.ttv_num_seq_orcto_ctbl
          v_cod_vers_orcto_ctbl      = tt_input_sdo.ttv_cod_vers_orcto_ctbl
          v_cod_cta_ctbl_pfixa       = tt_input_sdo.ttv_cod_cta_ctbl_pfixa
          v_cod_ccusto_pfixa         = tt_input_sdo.ttv_cod_ccusto_pfixa
          v_cod_proj_financ_pfixa    = tt_input_sdo.ttv_cod_proj_financ_pfixa
          v_cod_cta_ctbl_excec       = tt_input_sdo.ttv_cod_cta_ctbl_excec
          v_cod_ccusto_excec         = tt_input_sdo.ttv_cod_ccusto_excec
          v_cod_proj_financ_excec    = tt_input_sdo.ttv_cod_proj_financ_excec
          v_num_seq_demonst_ctbl     = tt_input_sdo.ttv_num_seq_demonst_ctbl
          v_num_seq_compos_demonst   = tt_input_sdo.ttv_num_seq_compos_demonst
          v_cod_chave                = tt_input_sdo.ttv_cod_chave
          v_cdn_tot_dat              = num-entries(tt_input_sdo.ttv_cod_seq, chr(10))
          v_cdn_tot_con_excec        = num-entries(tt_input_sdo.ttv_cod_cta_ctbl_excec, chr(10))
          v_cdn_tot_ccusto_excec     = num-entries(tt_input_sdo.ttv_cod_ccusto_excec, chr(10))
          v_cdn_tot_proj_excec       = num-entries(tt_input_sdo.ttv_cod_proj_financ_excec, chr(10)).

    if  v_cod_cta_ctbl_inic      = v_cod_cta_ctbl_final then
        assign v_cod_cta_ctbl    = v_cod_cta_ctbl_inic.
    if  v_cod_proj_financ_inic   = v_cod_proj_financ_final then
        assign v_cod_proj_financ = v_cod_proj_financ_inic.
    if  v_cod_ccusto_inic        = v_cod_ccusto_final then
        assign v_cod_ccusto      = v_cod_ccusto_inic.
    if  v_cod_estab_inic         = v_cod_estab_final then
        assign v_cod_estab       = v_cod_estab_inic.
    if  v_cod_unid_negoc_inic    = v_cod_unid_negoc_final then
        assign v_cod_unid_negoc  = v_cod_unid_negoc_inic.

    EMPTY TEMP-TABLE tt_empresa_leitura_sdo.
    if lookup("Consolida‡Æo" /*l_consolidacao*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 then do:
        /* --- Faixa de Unidades Organiz --- */
        uo_block:
        for each unid_organ no-lock
           where unid_organ.cod_unid_organ    >= v_cod_unid_organ_ini
             and unid_organ.cod_unid_organ    <= v_cod_unid_organ_fim
             and unid_organ.num_niv_unid_organ < 998:

            if v_cod_plano_cta_ctbl <> "" then do:
                find plano_cta_unid_organ no-lock
                   where plano_cta_unid_organ.cod_unid_organ     = unid_organ.cod_unid_organ
                   and   plano_cta_unid_organ.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl no-error.
                if not avail plano_cta_unid_organ then
                    next uo_block.
            end.

            assign v_cod_unid_organ = unid_organ.cod_unid_organ.

            create tt_empresa_leitura_sdo.        
            assign tt_empresa_leitura_sdo.tta_cod_empresa        = v_cod_unid_organ
                   tt_empresa_leitura_sdo.tta_cod_cenar_ctbl     = v_cod_cenar_ctbl
                   tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl.


            /* --- Faixa de UO‹s ---*/
            assign v_num_seq = 1.

            for each tt_estrut_unid_organ:
                delete tt_estrut_unid_organ.
            end.
            for each tt_log_elim_intercomp:
                delete tt_log_elim_intercomp.
            end.
            run pi_cria_tt_estrut_unid_organ_demonst (Input v_cod_unid_organ) /*pi_cria_tt_estrut_unid_organ_demonst*/.
            if  not can-find(first tt_estrut_unid_organ) then
                next leitura_block.
            if v_cod_elimina_intercomp = "Consolidado" /*l_consolidado*/  then do:
                create tt_log_elim_intercomp.
                assign tt_log_elim_intercomp.ttv_log_elimina_intercomp = no
                       tt_log_elim_intercomp.ttv_log_simul = no.
            end.
            else if v_cod_elimina_intercomp = "Elimina‡äes" /*l_eliminacoes*/  then do:
                create tt_log_elim_intercomp.
                assign tt_log_elim_intercomp.ttv_log_elimina_intercomp = yes
                       tt_log_elim_intercomp.ttv_log_simul = no.
            end.
            else do:
                create tt_log_elim_intercomp.
                assign tt_log_elim_intercomp.ttv_log_elimina_intercomp = no
                       tt_log_elim_intercomp.ttv_log_simul = no.
                create tt_log_elim_intercomp.
                assign tt_log_elim_intercomp.ttv_log_elimina_intercomp = yes
                       tt_log_elim_intercomp.ttv_log_simul = no.
            end.
        end.
    end.        
    if lookup("Cont bil" /*l_contabil*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 
    or lookup("Or‡amento" /*l_orcamento*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 then do:
        /* --- Faixa de Unidades Organiz ---*/
        uo_block:
        for each unid_organ no-lock
           where unid_organ.cod_unid_organ    >= v_cod_unid_organ_ini
             and unid_organ.cod_unid_organ    <= v_cod_unid_organ_fim
             and unid_organ.num_niv_unid_organ = 998:

            if v_cod_plano_cta_ctbl <> "" then do:
                find plano_cta_unid_organ no-lock
                   where plano_cta_unid_organ.cod_unid_organ     = unid_organ.cod_unid_organ
                   and   plano_cta_unid_organ.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl no-error.
                if not avail plano_cta_unid_organ then
                    next uo_block.
            end.

            assign v_cod_unid_organ = unid_organ.cod_unid_organ.
            /* *****Rafael Lima - deixar em comentÿrio esse c½digo 
           /* O codigo abaixo verifica se a data passada como parametro esta desabilitado na contabilidade. 
               se estiver, devera ignorar esta data no processamento. Isso eh feito eliminando esta data da lista a ser processada */
            if lookup(@%(l_orcamento) , v_ind_espec_sdo_tot, chr(59)) = 0 then do:
                assign v_cod_seq_aux               = ""
                       v_cod_dat_sdo_ctbl_inic_aux = ""
                       v_cod_dat_sdo_ctbl_fim_aux  = ""
                       v_cod_exerc_ctbl_aux        = ""
                       v_cod_period_ctbl_aux       = "".

                do v_num_count_1 = 1 to v_cdn_tot_dat:
                    assign v_dat_sdo_cta_fim  = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10))).

                        /* --- Valida situa¯Êo do M«dulo ---*/
                    @run(pi_retornar_sit_movimen_modul_demonst('FGL',
                                                   v_cod_unid_organ,
                                                   v_dat_sdo_cta_fim,
                                                   @%(l_habilitado),
                                                   v_cod_return)).
                    if not can-do(v_cod_return, @%(l_desabilitado)) then do:
                        if v_cod_seq_aux = "" then
                            assign v_cod_seq_aux               = entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))
                                   v_cod_dat_sdo_ctbl_inic_aux = entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10))
                                   v_cod_dat_sdo_ctbl_fim_aux  = entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10))
                                   v_cod_exerc_ctbl_aux        = entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10))
                                   v_cod_period_ctbl_aux       = entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)).
                        else
                            assign v_cod_seq_aux               = v_cod_seq_aux               + chr(10) + entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))
                                   v_cod_dat_sdo_ctbl_inic_aux = v_cod_dat_sdo_ctbl_inic_aux + chr(10) + entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10))
                                   v_cod_dat_sdo_ctbl_fim_aux  = v_cod_dat_sdo_ctbl_fim_aux  + chr(10) + entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10))
                                   v_cod_exerc_ctbl_aux        = v_cod_exerc_ctbl_aux        + chr(10) + entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10))
                                   v_cod_period_ctbl_aux       = v_cod_period_ctbl_aux       + chr(10) + entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)).
                    end.
                end.
                if v_cod_seq_aux = "" then
                    next uo_block.
                else
                    assign tt_input_sdo.ttv_cod_seq               = v_cod_seq_aux
                           tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic = v_cod_dat_sdo_ctbl_inic_aux
                           tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim  = v_cod_dat_sdo_ctbl_fim_aux
                           tt_input_sdo.ttv_cod_exerc_ctbl        = v_cod_exerc_ctbl_aux
                           tt_input_sdo.ttv_cod_period_ctbl       = v_cod_period_ctbl_aux.
            end.
            /* Fim do codigo de verificacao se o periodo esta desabilitado */
            ******/

            /* --- Se nÊo informou cen˜rio cont˜bil, localiza o Cen˜rio fiscal da Empresa ---*/
            if  v_cod_cenar_ctbl = "" then do:
                run pi_retornar_cenar_ctbl_fisc_demonst (Input v_cod_unid_organ,
                                                         Input v_dat_sdo_cta_inic,
                                                         output v_cod_cenar_ctbl) /*pi_retornar_cenar_ctbl_fisc_demonst*/.
            end.
            /* --- Se n’o informou o Plano de Contas, localiza o Plano Primÿrio da Empresa ---*/
            if  v_cod_plano_cta_ctbl = "" then do:
                run pi_retornar_plano_cta_ctbl_prim_demonst (Input v_cod_unid_organ,
                                                             Input v_dat_sdo_cta_inic,
                                                             output v_cod_plano_cta_ctbl,
                                                             output v_log_plano_cta_ctbl_unico) /*pi_retornar_plano_cta_ctbl_prim_demonst*/.
            end.
            create tt_empresa_leitura_sdo.
            assign tt_empresa_leitura_sdo.tta_cod_empresa        = v_cod_unid_organ
                   tt_empresa_leitura_sdo.tta_cod_cenar_ctbl     = v_cod_cenar_ctbl
                   tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl.
        end.
    end.
    assign v_log_sdo_orcado = no.
    if lookup("Or‡amento" /*l_orcamento*/  , v_ind_espec_sdo_tot, chr(59)) <> 0 then do:
        if v_cod_cenar_orctario <> "" 
        or v_cod_unid_orctaria  <> ""
        or v_num_seq_orcto_ctbl <> 0 then do:
            find orcto_ctbl_bgc
               where orcto_ctbl_bgc.cod_cenar_orctario = v_cod_cenar_orctario
               and   orcto_ctbl_bgc.cod_unid_orctaria  = v_cod_unid_orctaria
               and   orcto_ctbl_bgc.num_seq_orcto_ctbl = v_num_seq_orcto_ctbl
               and   orcto_ctbl_bgc.cod_finalid_econ   = v_cod_finalid_econ
               no-lock no-error.
            if not avail orcto_ctbl_bgc then
                next leitura_block.
            if v_log_orcto_cta_sint = yes then
                assign v_log_sdo_orcado = yes.

            &IF DEFINED (BF_FIN_CONSOLID_UNID_ORCTARIA) &THEN
                find unid_orctaria 
                   where unid_orctaria.cod_unid_orctaria = v_cod_unid_orctaria
                   no-lock no-error.
                if avail unid_orctaria
                and unid_orctaria.ind_espec_unid_orctaria = "Sint‚tica" /*l_sintetica*/  then do:
                    assign v_cod_unid_orctaria_tot   = "" /*l_null*/ 
                           v_cod_seq_orcto_ctbl_tot  = "" /*l_null*/ 
                           v_cod_vers_orcto_ctbl_tot = "" /*l_null*/ .
                    run pi_busca_vers_orcto_unid_orctaria (Input v_cod_unid_orctaria,
                                                           Input v_num_seq_orcto_ctbl,
                                                           Input v_cod_vers_orcto_ctbl) /*pi_busca_vers_orcto_unid_orctaria*/.
                    assign v_cdn_tot_orcto = num-entries(v_cod_unid_orctaria_tot, chr(10)).
                end.
                else do:
                    assign v_cdn_tot_orcto           = 1
                           v_cod_unid_orctaria_tot   = v_cod_unid_orctaria
                           v_cod_seq_orcto_ctbl_tot  = string(v_num_seq_orcto_ctbl)
                           v_cod_vers_orcto_ctbl_tot = v_cod_vers_orcto_ctbl.
                end.
            &ELSE
                assign v_cdn_tot_orcto           = 1
                       v_cod_unid_orctaria_tot   = v_cod_unid_orctaria
                       v_cod_seq_orcto_ctbl_tot  = string(v_num_seq_orcto_ctbl)
                       v_cod_vers_orcto_ctbl_tot = v_cod_vers_orcto_ctbl.
            &ENDIF
        end.
    end.  
    if lookup("Cont bil" /*l_contabil*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 
       and lookup("Or‡amento" /*l_orcamento*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 
       and v_cod_unid_orctaria <> "" then do:

        /* 225498 - trazer os valores de saldos realizados ao informar Unidade Or‡ament ria Sint‚tica*/
        &IF DEFINED (BF_FIN_CONSOLID_UNID_ORCTARIA) &THEN
            find unid_orctaria no-lock 
                where unid_orctaria.cod_unid_orctaria = v_cod_unid_orctaria no-error.
            if avail unid_orctaria
            and unid_orctaria.ind_espec_unid_orctaria = "Sint‚tica" /*l_sintetica*/  then do:
                empty temp-table tt_relacto_unid_orctaria no-error.
                assign v_log_sdo_orcado_realzdo    = yes
                       v_log_existe_orcto_ccusto   = no.

                run pi_achar_unid_orctaria_filho (Input unid_orctaria.cod_unid_orctaria) /* pi_achar_unid_orctaria_filho*/.
                for each tt_unid_orctaria:
                    for each relacto_unid_orctaria no-lock
                        where relacto_unid_orctaria.cod_unid_orctaria =  tt_unid_orctaria.tta_cod_unid_orctaria
                        break by relacto_unid_orctaria.num_tip_inform_organ.
                        if relacto_unid_orctaria.num_tip_inform_organ = 3 then
                            assign v_log_existe_orcto_ccusto = yes.
                            create tt_relacto_unid_orctaria.
                            assign tt_relacto_unid_orctaria.tta_num_tip_inform_organ = relacto_unid_orctaria.num_tip_inform_organ.
                                   tt_relacto_unid_orctaria.tta_cod_inform_organ = relacto_unid_orctaria.cod_inform_organ.
                    end.
                end.
            end.
            else do:      
                empty temp-table tt_relacto_unid_orctaria no-error.
                assign v_log_sdo_orcado_realzdo    = yes
                       v_log_existe_orcto_ccusto   = no.
                for each relacto_unid_orctaria no-lock
                    where relacto_unid_orctaria.cod_unid_orctaria = v_cod_unid_orctaria
                    break by relacto_unid_orctaria.num_tip_inform_organ.
                    if relacto_unid_orctaria.num_tip_inform_organ = 3 then
                        assign v_log_existe_orcto_ccusto = yes.
                        create tt_relacto_unid_orctaria.
                        assign tt_relacto_unid_orctaria.tta_num_tip_inform_organ = relacto_unid_orctaria.num_tip_inform_organ.
                               tt_relacto_unid_orctaria.tta_cod_inform_organ = relacto_unid_orctaria.cod_inform_organ.
                end.
            end.     
        &ELSE
            empty temp-table tt_relacto_unid_orctaria no-error.
            assign v_log_sdo_orcado_realzdo    = yes
                   v_log_existe_orcto_ccusto   = no.
            for each relacto_unid_orctaria no-lock
                where relacto_unid_orctaria.cod_unid_orctaria = v_cod_unid_orctaria
                break by relacto_unid_orctaria.num_tip_inform_organ.
                if relacto_unid_orctaria.num_tip_inform_organ = 3 then
                    assign v_log_existe_orcto_ccusto = yes.
                    create tt_relacto_unid_orctaria.
                    assign tt_relacto_unid_orctaria.tta_num_tip_inform_organ = relacto_unid_orctaria.num_tip_inform_organ.
                           tt_relacto_unid_orctaria.tta_cod_inform_organ = relacto_unid_orctaria.cod_inform_organ.
            end.
        &ENDIF             
    end.
    else
        assign v_log_sdo_orcado_realzdo = no.

    find plano_cta_ctbl
        where plano_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl no-lock no-error.
    assign v_cod_cta_ctbl_apurac_restdo = plano_cta_ctbl.cod_cta_ctbl_apurac_restdo.
    if v_cod_plano_ccusto <> '' then do:
        find plano_ccusto
            where plano_ccusto.cod_empresa      = v_cod_unid_organ_ini
            and   plano_ccusto.cod_plano_ccusto = v_cod_plano_ccusto 
            no-lock no-error.
    end. 
     /* atualiza a variavel v_cdn_tot_dat apos retirar os periodos que estao desabilitados */
    assign v_cdn_tot_dat = num-entries(tt_input_sdo.ttv_cod_seq, chr(10)).

    find first tt_empresa_leitura_sdo no-lock no-error.
    if not avail tt_empresa_leitura_sdo then
        next leitura_block.
    /* Melhoria de performance. Se nao existir estrut_ctbl para informacao, deve sair */
    if  v_cod_cta_ctbl_inic    = v_cod_cta_ctbl_final
    and v_cod_proj_financ_inic = v_cod_proj_financ_final
    and v_cod_ccusto_inic      = v_cod_ccusto_final
    and v_cod_estab_inic       = v_cod_estab_final
    and v_cod_unid_negoc_inic  = v_cod_unid_negoc_final
    and v_cod_unid_organ      <> ''
    and v_cod_plano_cta_ctbl  <> '' 
    and v_cod_plano_ccusto    = '' then do:
        find estrut_ctbl_movto_analit
            where estrut_ctbl_movto_analit.cod_empresa        = v_cod_unid_organ
            and estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
            and estrut_ctbl_movto_analit.cod_cta_ctbl       = v_cod_cta_ctbl
            and estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
            and estrut_ctbl_movto_analit.cod_ccusto         = '' 
            and estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
            and estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
            and estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
            no-lock no-error.
        if avail estrut_ctbl_movto_analit then
            if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
            &if '{&emsbas_version}' >= '5.06' &then            
            and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
            &else
            and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
            &endif
            or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then            
                run pi_busca_saldo /*pi_busca_saldo*/.
    end.
    else if  v_cod_cta_ctbl_inic = v_cod_cta_ctbl_final
    and v_cod_proj_financ_inic   = v_cod_proj_financ_final
    and v_cod_ccusto_inic        = v_cod_ccusto_final
    and v_cod_estab_inic         = v_cod_estab_final
    and v_cod_unid_negoc_inic    = v_cod_unid_negoc_final
    and v_cod_unid_organ        <> ''
    and v_cod_plano_cta_ctbl    <> '' 
    and v_cod_plano_ccusto      <> '' then do:
        find estrut_ctbl_movto_analit
            where estrut_ctbl_movto_analit.cod_empresa        = v_cod_unid_organ
            and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
            and   estrut_ctbl_movto_analit.cod_cta_ctbl       = v_cod_cta_ctbl
            and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
            and   estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto
            and   estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
            and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
            and   estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
            no-lock no-error.
        if avail estrut_ctbl_movto_analit then
            if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
            &if '{&emsbas_version}' >= '5.06' &then            
            and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
            &else
            and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
            &endif            
            or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then            
                run pi_busca_saldo /*pi_busca_saldo*/.
    end.
    else do:
        cta_ctbl:
        for each cta_ctbl fields(cod_cta_ctbl ind_espec_cta_ctbl ind_natur_cta_ctbl) no-lock
           where cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
           and   cta_ctbl.cod_cta_ctbl >= v_cod_cta_ctbl_inic
           and   cta_ctbl.cod_cta_ctbl <= v_cod_cta_ctbl_final:

            if v_ind_espec_cta = "Primeiro N¡vel" /*l_primeiro_nivel*/  then do:
                /* Consulta de Saldos */
                if not can-find(first estrut_cta_ctbl
                        where estrut_cta_ctbl.cod_plano_Cta_ctbl = v_cod_plano_cta_ctbl
                        and   estrut_cta_ctbl.cod_cta_ctbl_filho = cta_ctbl.cod_cta_ctbl
                        and   estrut_cta_ctbl.cod_cta_ctbl_pai   = "") then
                    next cta_ctbl.
            end.
            else do:
                if v_ind_espec_cta <> "" then do:
                    /* --- Verifica Esp²cie da Conta ---*/
                    if (v_ind_espec_cta <> "Todas" /*l_todas*/ 
                    and v_ind_espec_cta <> cta_ctbl.ind_espec_cta_ctbl) then
                        next cta_ctbl.
                end.
            end.
            if (not cta_ctbl.cod_cta_ctbl matches v_cod_cta_ctbl_pfixa and v_cod_cta_ctbl_pfixa <> '') then
                next cta_ctbl.

            /* Excecao */
            if v_cod_cta_ctbl_excec <> '' then do:
                do v_num_count = 1 to v_cdn_tot_con_excec:
                    if (entry(v_num_count,v_cod_cta_ctbl_excec,chr(10)) <> fill(chr(46), length(cta_ctbl.cod_cta_ctbl))
                    and cta_ctbl.cod_cta_ctbl matches entry(v_num_count,v_cod_cta_ctbl_excec,chr(10))) then
                        next cta_ctbl.
                end.
            end.
            /* MELHORIA DE PERFORMANCE PARA CONTA CONTæBIL */
            if lookup("Conta Cont bil" /*l_conta_contabil*/  ,v_cod_chave,chr(10)) = 0
            and v_ind_espec_cta <> "Anal¡tica" /*l_analitica*/ 
            and (v_cod_cta_ctbl_pfixa = '' or   v_cod_cta_ctbl_pfixa = fill(chr(46), length(cta_ctbl.cod_cta_ctbl)))
            and (v_cod_cta_ctbl_excec = '' or   v_cod_cta_ctbl_excec = fill(chr(46), length(cta_ctbl.cod_cta_ctbl))) 
            and  v_cod_cta_ctbl_inic <> v_cod_cta_ctbl_final 
            then do:

                /* ** SE O PAI DA CONTA SELECIONADO ESTIVER DENTRO DA FAIXA DESCONSIDERA A CONTA ***/
                if can-find(first estrut_cta_ctbl
                    where estrut_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                    and   estrut_cta_ctbl.cod_cta_ctbl_FILHO = cta_ctbl.cod_cta_ctbl
                    and   estrut_cta_ctbl.cod_cta_ctbl_pai  >= v_cod_cta_ctbl_inic
                    and   estrut_cta_ctbl.cod_cta_ctbl_pai  <= v_cod_cta_ctbl_final
                    and   estrut_cta_ctbl.cod_cta_ctbl_pai  <> "") then do:
                    next.
                end.
            end.


            /* Begin_Include: i_retornar_sdo_ctbl */
            for each tt_empresa_leitura_sdo:

                /* Saldo com Centro de Custo */
                if  v_cod_plano_ccusto    <> ''
                and v_cod_proj_financ_inic = v_cod_proj_financ_final
                and v_cod_ccusto_inic      = v_cod_ccusto_final
                and v_cod_estab_inic       = v_cod_estab_final
                and v_cod_unid_negoc_inic  = v_cod_unid_negoc_final then do:
                    find estrut_ctbl_movto_analit use-index estrtctb_id
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto
                       and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
                       and   estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
                       no-lock no-error.
                    if avail estrut_ctbl_movto_analit then
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                end.
                else
                if  v_cod_plano_ccusto    <> ''
                and v_cod_ccusto_inic      = v_cod_ccusto_final
                and v_cod_estab_inic       = v_cod_estab_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_ccusto
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto
                       and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then            
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto    <> ''
                and v_cod_ccusto_inic      = v_cod_ccusto_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_ccusto
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto    <> ''
                and v_cod_estab_inic       = v_cod_estab_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_estab
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto        >= v_cod_ccusto_inic
                       and   estrut_ctbl_movto_analit.cod_ccusto        <= v_cod_ccusto_final
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then   
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto    <> ''
                and v_cod_unid_negoc_inic       = v_cod_unid_negoc_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_unid_negoc
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto        >= v_cod_ccusto_inic
                       and   estrut_ctbl_movto_analit.cod_ccusto        <= v_cod_ccusto_final
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto    <> ''
                and v_cod_proj_financ_inic       = v_cod_proj_financ_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_proj_financ
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_ccusto        >= v_cod_ccusto_inic
                       and   estrut_ctbl_movto_analit.cod_ccusto        <= v_cod_ccusto_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto    <> '' then do:
                    for each estrut_ctbl_movto_analit
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       and   estrut_ctbl_movto_analit.cod_ccusto        >= v_cod_ccusto_inic
                       and   estrut_ctbl_movto_analit.cod_ccusto        <= v_cod_ccusto_final
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.




                /* Saldo sem Centro de custo */
                else
                if  v_cod_plano_ccusto     = ''
                and v_cod_proj_financ_inic = v_cod_proj_financ_final
                and v_cod_estab_inic       = v_cod_estab_final
                and v_cod_unid_negoc_inic  = v_cod_unid_negoc_final then do:
                    find estrut_ctbl_movto_analit use-index estrtctb_id
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
                       and   estrut_ctbl_movto_analit.cod_ccusto         = ''
                       and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
                       and   estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
                       no-lock no-error.
                    if avail estrut_ctbl_movto_analit then
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                end.
                else
                if  v_cod_plano_ccusto     = ''
                and v_cod_estab_inic       = v_cod_estab_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_ccusto
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
                       and   estrut_ctbl_movto_analit.cod_ccusto         = ''
                       and   estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto          = ''
                and v_cod_unid_negoc_inic       = v_cod_unid_negoc_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_unid_negoc
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
                       and   estrut_ctbl_movto_analit.cod_ccusto         = ''
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else
                if  v_cod_plano_ccusto           = ''
                and v_cod_proj_financ_inic       = v_cod_proj_financ_final then do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_proj_financ
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
                       and   estrut_ctbl_movto_analit.cod_ccusto         = ''
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
                else do:
                    for each estrut_ctbl_movto_analit use-index estrtctb_ccusto
                       where estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   estrut_ctbl_movto_analit.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                       and   estrut_ctbl_movto_analit.cod_plano_ccusto   = ''
                       and   estrut_ctbl_movto_analit.cod_ccusto         = ''
                       and   estrut_ctbl_movto_analit.cod_estab         >= v_cod_estab_inic
                       and   estrut_ctbl_movto_analit.cod_estab         <= v_cod_estab_final
                       and   estrut_ctbl_movto_analit.cod_proj_financ   >= v_cod_proj_financ_inic
                       and   estrut_ctbl_movto_analit.cod_proj_financ   <= v_cod_proj_financ_final
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    >= v_cod_unid_negoc_inic
                       and   estrut_ctbl_movto_analit.cod_unid_negoc    <= v_cod_unid_negoc_final
                       no-lock:
                        if (v_ind_espec_sdo_tot = "Or‡amento" /*l_orcamento*/ 
                        &if '{&emsbas_version}' >= '5.06' &then            
                        and estrut_ctbl_movto_analit.ind_tip_sdo = "Or‡amento" /*l_orcamento*/ )
                        &else            
                        and estrut_ctbl_movto_analit.cod_livre_1 = "Or‡amento" /*l_orcamento*/ )
                        &endif
                        or v_ind_espec_sdo_tot <> "Or‡amento" /*l_orcamento*/  then
                            run pi_busca_saldo /*pi_busca_saldo*/.
                    end.
                end.
            end.        

            /* End_Include: i_retornar_sdo_ctbl */


        end.
    end.
    if v_log_busca_sdo_nova_logic then do:
        for each tt_empresa_leitura_sdo:
            run pi_leitura_sdo_ctbl_demonst_novo /*pi_leitura_sdo_ctbl_demonst_novo*/.
        end.
        for each tt_lista_inform:
            assign tt_lista_inform.ttv_log_selec = no.
        end.
    end.
end.
if not v_cod_dwb_user begins 'es_'
   and Verifica_Program_Name('pi_item_demonst_ctbl_video':U,30) then do:
    run pi_percent_update (Input v_num_tot_1,
                           Input v_num_contador,
                           Input "Buscando Saldos..." /*l_buscando_saldos*/ ).
end.

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

return.


/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_ctbl_demonst
** Descricao.............: pi_leitura_sdo_ctbl_demonst
** Criado por............: src531
** Criado em.............: 20/08/2002 11:08:48
** Alterado por..........: bre17108
** Alterado em...........: 29/01/2004 11:56:32
*****************************************************************************/
PROCEDURE pi_leitura_sdo_ctbl_demonst:

    for each btt_lista_inform_ccusto
      where btt_lista_inform_ccusto.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/  
      and   btt_lista_inform_ccusto.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + estrut_ctbl_movto_analit.cod_ccusto
      and   btt_lista_inform_ccusto.ttv_log_selec    = yes:
        assign v_cod_ccusto_analit = btt_lista_inform_ccusto.ttv_cod_fill.
        if v_cod_ccusto_analit <> "" then
            if not can-find(estrut_ctbl_movto_sint
                where estrut_ctbl_movto_sint.cod_empresa    = tt_empresa_leitura_sdo.tta_cod_empresa
                and estrut_ctbl_movto_sint.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                AND estrut_ctbl_movto_sint.cod_cta_ctbl     = estrut_ctbl_movto_analit.cod_cta_ctbl
                and estrut_ctbl_movto_sint.cod_plano_ccusto = v_cod_plano_ccusto
                and estrut_ctbl_movto_sint.cod_ccusto       = v_cod_ccusto_analit) THEN next.

        for each btt_lista_inform_conta
          where btt_lista_inform_conta.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/  
          and   btt_lista_inform_conta.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl + chr(10) + estrut_ctbl_movto_analit.cod_cta_ctbl
          and   btt_lista_inform_conta.ttv_log_selec   = yes:
            assign v_cod_cta_ctbl_analit = btt_lista_inform_conta.ttv_cod_fill.
            if v_cod_ccusto_analit <> "" then
                if not can-find(estrut_ctbl_movto_sint
                    where estrut_ctbl_movto_sint.cod_empresa    = tt_empresa_leitura_sdo.tta_cod_empresa
                    and estrut_ctbl_movto_sint.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                    and estrut_ctbl_movto_sint.cod_cta_ctbl     = v_cod_cta_ctbl_analit
                    and estrut_ctbl_movto_sint.cod_plano_ccusto = v_cod_plano_ccusto
                    and estrut_ctbl_movto_sint.cod_ccusto       = v_cod_ccusto_analit) THEN next.

            for each btt_lista_inform_un
              where btt_lista_inform_un.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/  
              and   btt_lista_inform_un.ttv_cod_inform    = estrut_ctbl_movto_analit.cod_unid_negoc
              and   btt_lista_inform_un.ttv_log_selec    = yes:
                assign v_cod_unid_negoc_analit  = btt_lista_inform_un.ttv_cod_fill.
                if not can-find(b_estrut_ctbl_movto_analit
                    where b_estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                      and b_estrut_ctbl_movto_analit.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                      and b_estrut_ctbl_movto_analit.cod_cta_ctbl       = v_cod_cta_ctbl_analit
                      and b_estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                      and b_estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto_analit
                      &IF DEFINED(BF_ADM_FIN_PROJ) &THEN
                      and b_estrut_ctbl_movto_analit.cod_proj_financ    = estrut_ctbl_movto_analit.cod_proj_financ
                      &ENDIF
                      and b_estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                      and b_estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc_analit) THEN next.

                for each btt_lista_inform_proj
                  where btt_lista_inform_proj.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                  and   btt_lista_inform_proj.ttv_cod_inform    = estrut_ctbl_movto_analit.cod_proj_financ
                  and   btt_lista_inform_proj.ttv_log_selec    = yes:
                    assign v_cod_proj_financ_analit = btt_lista_inform_proj.ttv_cod_fill.
                    do v_num_count_1 = 1 to v_cdn_tot_dat:
                        assign v_dat_sdo_cta_inic = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10)))
                               v_dat_sdo_cta_fim = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10)))
                               v_cod_exerc_ctbl  = trim(entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10)))
                               v_num_period_ctbl = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)))
                               v_num_seq_1       = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))).

                        find first tt_retorna_sdo_ctbl_demonst
                             where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa   = tt_empresa_leitura_sdo.tta_cod_empresa
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ = v_cod_finalid_econ
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl  = v_cod_cta_ctbl_analit
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto = v_cod_plano_ccusto
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto    = v_cod_ccusto_analit 
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_estab      = v_cod_estab
                             AND tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc = v_cod_unid_negoc_analit
                             and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ = v_cod_proj_financ_analit 
                             and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl    = v_dat_sdo_cta_fim
                             and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo   = v_ind_espec_sdo
                             and tt_retorna_sdo_ctbl_demonst.tta_num_seq         = v_num_seq_1 no-error.
                        if avail tt_retorna_sdo_ctbl_demonst then do:
                            if avail tt_item_demonst_ctbl_video then do:
                                find tt_relacto_item_retorna 
                                   where tt_relacto_item_retorna.tta_num_seq   = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                   and tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                   and tt_relacto_item_retorna.ttv_rec_ret  = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl no-error.
                                if not avail tt_relacto_item_retorna then do:
                                    create tt_relacto_item_retorna.
                                    assign tt_relacto_item_retorna.tta_num_seq = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                           tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                           tt_relacto_item_retorna.ttv_rec_ret  = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                                end.
                            end.
                            next.
                        end.

                        /* Begin_Include: i_leitura_sdo_ctbl_demonst */
                        case v_cod_leitura:
                            when "for each" /*l_for_each*/  then do:
                                case v_cod_condicao: 
                                    when "Igual" /*l_igual*/  then do:
                                        find sdo_ctbl no-lock
                                            where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                            and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                            and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                            and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                            and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                            and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                            &IF DEFINED(BF_ADM_FIN_PROJ) &THEN
                                            and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit                    
                                            &ENDIF
                                            and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                            and sdo_ctbl.cod_estab = v_cod_estab
                                            and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                            and sdo_ctbl.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                       if avail sdo_ctbl then do:
                                            assign v_log_saldo = no.
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                        else do:   
                                            if Verifica_Program_Name('mgl303aa':U, 30) = yes then do:                           
                                                find first estrut_ccusto 
                                                     where estrut_ccusto.cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
                                                       and estrut_ccusto.cod_plano_ccusto = v_cod_plano_ccusto
                                                       and estrut_ccusto.cod_ccusto_filho =  v_cod_ccusto_analit no-lock no-error.
                                                     if avail estrut_ccusto then do:                                           
                                                         find b_sdo_ctbl no-lock
                                                             where b_sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                                                               and b_sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                                                               and b_sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                                               and b_sdo_ctbl.cod_cta_ctbl       = v_cod_cta_ctbl_analit
                                                               and b_sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto 
                                                               and b_sdo_ctbl.cod_ccusto         = estrut_ccusto.cod_ccusto_pai
                                                               &IF DEFINED(BF_ADM_FIN_PROJ) &THEN
                                                               and b_sdo_ctbl.cod_proj_financ    = v_cod_proj_financ_analit
                                                               &ENDIF
                                                               and b_sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                                               and b_sdo_ctbl.cod_estab          = v_cod_estab
                                                               and b_sdo_ctbl.cod_unid_negoc     = v_cod_unid_negoc_analit
                                                               and b_sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim no-error.
                                                             if avail b_sdo_ctbl then do:
                                                                 assign v_log_saldo = yes.
                                                                 run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1).
                                                             end.
                                                     end.          
                                            end.         
                                        end.
                                    end.
                                    when "menor ou igual" /*l_menor_igual*/  then do:
                                        for each sdo_ctbl no-lock
                                             where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                             and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                             and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                             and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                             and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                             and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                             and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                             and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                             and sdo_ctbl.cod_estab = v_cod_estab
                                             and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                             and sdo_ctbl.dat_sdo_ctbl <= v_dat_sdo_cta_fim:
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                    end.
                                    when "Menor" /*l_menor*/  then do:
                                        for each sdo_ctbl no-lock
                                             where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                             and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                             and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                             and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                             and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                             and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                             and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                             and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                             and sdo_ctbl.cod_estab = v_cod_estab
                                             and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                             and sdo_ctbl.dat_sdo_ctbl < v_dat_sdo_cta_fim:
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                    end.
                                    when "Maior ou Igual e Menor ou Igual" /*l_maior_igual_menor_igual*/  then do:
                                        for each sdo_ctbl no-lock
                                             where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                             and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                             and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                             and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                             and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                             and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                             and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                             and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                             and sdo_ctbl.cod_estab = v_cod_estab
                                             and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                             and sdo_ctbl.dat_sdo_ctbl >= v_dat_sdo_cta_inic
                                             and sdo_ctbl.dat_sdo_ctbl <= v_dat_sdo_cta_fim:
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                    end.
                                end.
                            end.
                            when "find last" /*l_find_last*/  then do:
                                case v_cod_condicao: 
                                    when "Igual" /*l_igual*/   then do:
                                        find sdo_ctbl no-lock
                                             where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                             and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                             and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                             and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                             and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                             and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                             and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                             and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                             and sdo_ctbl.cod_estab = v_cod_estab
                                             and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                             and sdo_ctbl.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                        if  avail sdo_ctbl then do:
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                     end.
                                    when "menor ou igual" /*l_menor_igual*/  then do:
                                        find last sdo_ctbl no-lock
                                             where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                             and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                             and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                             and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                             and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                             and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                             and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                             and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                             and sdo_ctbl.cod_estab = v_cod_estab
                                             and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                             and sdo_ctbl.dat_sdo_ctbl <= v_dat_sdo_cta_fim no-error.
                                        if  avail sdo_ctbl then do:
                                            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                        end.
                                     end.

                                     /* Begin_Include: i_leitura_sdo_ctbl_demonst_aux */
                                             when "Menor" /*l_menor*/  then do:
                                                 find last sdo_ctbl no-lock
                                                      where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                                      and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                                      and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                                      and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                                      and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                                      and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                                      and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                                      and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                                      and sdo_ctbl.cod_estab = v_cod_estab
                                                      and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                                      and sdo_ctbl.dat_sdo_ctbl < v_dat_sdo_cta_fim no-error.
                                                 if  avail sdo_ctbl then do:
                                                     run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                                 end.
                                             end.
                                         end.
                                     end.
                                      when "find first" /*l_find_first*/  then do:
                                         case v_cod_condicao: 
                                             when "Igual" /*l_igual*/   then do:
                                                 find sdo_ctbl no-lock
                                                      where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                                      and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                                      and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                                      and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                                      and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                                      and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                                      and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                                      and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                                      and sdo_ctbl.cod_estab = v_cod_estab
                                                      and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                                      and sdo_ctbl.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                                 if  avail sdo_ctbl then do:
                                                     run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                                 end.
                                             end.
                                             when "menor ou igual" /*l_menor_igual*/  then do:
                                                 find first sdo_ctbl no-lock
                                                      where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                                      and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                                      and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                                      and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                                      and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                                      and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                                      and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                                      and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                                      and sdo_ctbl.cod_estab = v_cod_estab
                                                      and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                                      and sdo_ctbl.dat_sdo_ctbl <= v_dat_sdo_cta_fim no-error.
                                                 if  avail sdo_ctbl then do:
                                                     run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                                 end.
                                             end.
                                             when "Menor" /*l_menor*/  then do:
                                                 find first sdo_ctbl no-lock
                                                      where sdo_ctbl.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                                                      and sdo_ctbl.cod_finalid_econ = v_cod_finalid_econ
                                                      and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                                      and sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                                      and sdo_ctbl.cod_plano_ccusto = v_cod_plano_ccusto
                                                      and sdo_ctbl.cod_ccusto = v_cod_ccusto_analit
                                                      and sdo_ctbl.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                                      and sdo_ctbl.cod_proj_financ = v_cod_proj_financ_analit
                                                      and sdo_ctbl.cod_estab = v_cod_estab
                                                      and sdo_ctbl.cod_unid_negoc = v_cod_unid_negoc_analit 
                                                      and sdo_ctbl.dat_sdo_ctbl < v_dat_sdo_cta_fim no-error.
                                                 if  avail sdo_ctbl then do:
                                                     run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /*pi_leitura_sdo_ctbl_grava_tt_demonst*/.
                                                 end.
                                             end.

                                     /* End_Include: i_leitura_sdo_ctbl_demonst_aux */

                                end.
                            end.
                         END.
                        /* End_Include: i_leitura_sdo_ctbl_demonst_aux */

                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_leitura_sdo_ctbl_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_ccusto_analitico_demonst
** Descricao.............: pi_localiza_ccusto_analitico_demonst
** Criado por............: src531
** Criado em.............: 20/08/2002 10:40:16
** Alterado por..........: fut35059
** Alterado em...........: 09/11/2006 15:34:42
*****************************************************************************/
PROCEDURE pi_localiza_ccusto_analitico_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_ccusto
        as Character
        format "x(11)"
        no-undo.
    def Input param p_cod_ccusto_pai
        as Character
        format "x(11)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find first tt_lista_inform
       where   tt_lista_inform.ttv_cod_tip_lista =  "Centro Custo" /*l_centro_custo*/ 
       and     tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto
       and     tt_lista_inform.ttv_cod_fill      = p_cod_ccusto
       no-lock no-error.
    if not avail tt_lista_inform then do:
        create tt_lista_inform.
        assign tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
               tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto
               tt_lista_inform.ttv_cod_fill      = p_cod_ccusto
               tt_lista_inform.ttv_log_selec    = yes.

        /* Saldo de centro de custo sintetico */
        if  v_log_espec_sdo_ccusto = no
        and p_cod_ccusto <> v_cod_ccusto then
            assign tt_lista_inform.ttv_log_selec = no.
    end.

    find tt_ccustos_demonst  
        where tt_ccustos_demonst.tta_cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
        and   tt_ccustos_demonst.tta_cod_plano_ccusto = v_cod_plano_ccusto
        and   tt_ccustos_demonst.tta_cod_ccusto       = p_cod_ccusto 
        no-error. 
    if  not avail tt_ccustos_demonst then do: 
        create tt_ccustos_demonst. 
        assign tt_ccustos_demonst.tta_cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
               tt_ccustos_demonst.tta_cod_plano_ccusto = v_cod_plano_ccusto
               tt_ccustos_demonst.tta_cod_ccusto       = p_cod_ccusto
               tt_ccustos_demonst.ttv_cod_ccusto_pai   = p_cod_ccusto_pai.
        if p_cod_ccusto = '' then do:
            return.
        end.
    end.
    else do:
        if p_cod_ccusto_pai <> "" then
            assign tt_ccustos_demonst.ttv_cod_ccusto_pai   = p_cod_ccusto_pai.

        if p_cod_ccusto = '' then do:
            return.
        end.

        /* se ja existe tt_ccusto, entao os filhos tamb‚m j  estÆo na tt_ccusto */
        run pi_localiza_tt_ccusto_analitico (Input p_cod_ccusto) /*pi_localiza_tt_ccusto_analitico*/.
    end. 

    for each  estrut_ccusto no-lock
        where estrut_ccusto.cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
        and   estrut_ccusto.cod_plano_ccusto = v_cod_plano_ccusto
        and   estrut_ccusto.cod_ccusto_pai   = p_cod_ccusto:
        run pi_localiza_ccusto_analitico_demonst (Input estrut_ccusto.cod_ccusto_filho,
                                                  Input estrut_ccusto.cod_ccusto_pai) /*pi_localiza_ccusto_analitico_demonst*/.
    end.

END PROCEDURE. /* pi_localiza_ccusto_analitico_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_cta_ctbl_analitica_demonst
** Descricao.............: pi_localiza_cta_ctbl_analitica_demonst
** Criado por............: src531
** Criado em.............: 20/08/2002 10:30:23
** Alterado por..........: fut41422
** Alterado em...........: 01/09/2011 08:42:14
*****************************************************************************/
PROCEDURE pi_localiza_cta_ctbl_analitica_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_cta_ctbl
        as character
        format "x(20)"
        no-undo.
    def Input param p_cod_cta_ctbl_pai
        as character
        format "x(20)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* Se for buscar saldo or‡ado, dever  adicionar a lista todas as contas (anal¡ticas ou sint‚ticas)*/
    if v_log_sdo_orcado = yes then do:
        find first tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/  
           and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
           and   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
           no-lock no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
                   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end.

    find tt_cta_ctbl_demonst
         where tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
         and   tt_cta_ctbl_demonst.tta_cod_cta_ctbl       = p_cod_cta_ctbl
         no-error.
    if  not avail tt_cta_ctbl_demonst then do:
        find b_cta_ctbl
           where b_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
           and   b_cta_ctbl.cod_cta_ctbl       = p_cod_cta_ctbl
           no-lock no-error.
        find grp_cta_ctbl of b_cta_ctbl no-lock no-error.

        /* Rodrigo - SDOT04*/
        find first estrut_cta_ctbl no-lock
           where estrut_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
             and estrut_cta_ctbl.cod_cta_ctbl_filho = p_cod_cta_ctbl no-error.
        if avail estrut_cta_ctbl then
            assign p_cod_cta_ctbl_pai = estrut_cta_ctbl.cod_cta_ctbl_pai.
        /* Rodrigo - SDOT04*/

        /* Rodrigo - 242524*/
        create tt_cta_ctbl_demonst.
        assign tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
               tt_cta_ctbl_demonst.tta_cod_cta_ctbl       = p_cod_cta_ctbl
               tt_cta_ctbl_demonst.ttv_cod_cta_ctbl_pai   = p_cod_cta_ctbl_pai
               tt_cta_ctbl_demonst.ttv_log_consid_apurac  = if avail grp_cta_ctbl then grp_cta_ctbl.log_consid_apurac else no
               tt_cta_ctbl_demonst.tta_ind_espec_cta_ctbl = if avail b_cta_ctbl   then b_cta_ctbl.ind_espec_cta_ctbl  else ''.
        /* Rodrigo - 242524*/           
    end.
    else do:
        if p_cod_cta_ctbl_pai <> "" then
            assign tt_cta_ctbl_demonst.ttv_cod_cta_ctbl_pai   = p_cod_cta_ctbl_pai.
        /* se ja existe tt_cta_ctbl_demonst, entao os filhos tamb‚m j  estÆo na tt_cta_ctbl_demonst */
        run pi_localiza_tt_cta_ctbl_analitica (Input p_cod_cta_ctbl) /*pi_localiza_tt_cta_ctbl_analitica*/.
        return.
    end. 

    /* --- Verifica se a conta ² Pai na Estrutura ---*/
    if not can-find(first estrut_cta_ctbl no-lock
        where estrut_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
        and   estrut_cta_ctbl.cod_cta_ctbl_pai   = p_cod_cta_ctbl) then do:

        /* Se busca saldo or‡ado, j  adcionou a conta na lista, no come‡o da pi */
        if v_log_sdo_orcado = no then do:
            find first tt_lista_inform
               where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
               and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
               and   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
               no-lock no-error.
            if not avail tt_lista_inform then do:
                create tt_lista_inform.
                assign tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                       tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
                       tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
                       tt_lista_inform.ttv_log_selec    = yes.
            end.
        end.
    end.
    else do:
        for each  estrut_cta_ctbl no-lock
            where estrut_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
            and   estrut_cta_ctbl.cod_cta_ctbl_pai   = p_cod_cta_ctbl:
            run pi_localiza_cta_ctbl_analitica_demonst (Input estrut_cta_ctbl.cod_cta_ctbl_filho,
                                                        Input estrut_cta_ctbl.cod_cta_ctbl_pai) /*pi_localiza_cta_ctbl_analitica_demonst*/.
        end.
    end.

END PROCEDURE. /* pi_localiza_cta_ctbl_analitica_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_proj_financ_analitico_demonst
** Descricao.............: pi_localiza_proj_financ_analitico_demonst
** Criado por............: src531
** Criado em.............: 20/08/2002 10:45:13
** Alterado por..........: bre17108
** Alterado em...........: 09/12/2003 09:19:10
*****************************************************************************/
PROCEDURE pi_localiza_proj_financ_analitico_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_proj_financ
        as character
        format "x(20)"
        no-undo.
    def Input param p_cod_proj_financ_pai
        as character
        format "x(20)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find tt_proj_financ_demonst
        where tt_proj_financ_demonst.tta_cod_proj_financ = p_cod_proj_financ
        no-lock no-error.
    if not avail tt_proj_financ_demonst then do:
        create tt_proj_financ_demonst.
        assign tt_proj_financ_demonst.tta_cod_proj_financ     = p_cod_proj_financ
               tt_proj_financ_demonst.ttv_cod_proj_financ_pai = p_cod_proj_financ_pai.
        if p_cod_proj_financ = '' then do:
            find tt_lista_inform
               where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
               and   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
               and   tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
               no-error.
            if not avail tt_lista_inform then do:
                create tt_lista_inform.
                assign tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                       tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
                       tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
                       tt_lista_inform.ttv_log_selec    = yes.
            end.
            return.               
        end.
    end /* if */.
    else do:
        if p_cod_proj_financ = '' then
            return.               

        if p_cod_proj_financ_pai <> "" then
            assign tt_proj_financ_demonst.ttv_cod_proj_financ_pai = p_cod_proj_financ_pai.
        /* se ja existe tt_ccusto, entao os filhos tamb‚m j  estÆo na tt_ccusto */
        run pi_localiza_tt_proj_financ_analitico (Input p_cod_proj_financ) /*pi_localiza_tt_proj_financ_analitico*/.
        return.
    end. 

    /* --- Verifica se o Projeto ² Pai na Estrutura ---*/
    if  not can-find(first estrut_proj_financ no-lock
        where estrut_proj_financ.cod_proj_financ_pai    = p_cod_proj_financ) then do:
        find tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
           and   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
           and   tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
           no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
                   tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end /* if */.
    else do:
        for each estrut_proj_financ no-lock
            where estrut_proj_financ.cod_proj_financ_pai = p_cod_proj_financ:
            run pi_localiza_proj_financ_analitico_demonst (Input estrut_proj_financ.cod_proj_financ_filho,
                                                           Input estrut_proj_financ.cod_proj_financ_pai) /*pi_localiza_proj_financ_analitico_demonst*/.
        end.
    end /* else */.

END PROCEDURE. /* pi_localiza_proj_financ_analitico_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_ctbl_grava_tt_demonst
** Descricao.............: pi_leitura_sdo_ctbl_grava_tt_demonst
** Criado por............: src531
** Criado em.............: 20/08/2002 11:32:55
** Alterado por..........: fut43112_2
** Alterado em...........: 28/10/2009 16:54:13
*****************************************************************************/
PROCEDURE pi_leitura_sdo_ctbl_grava_tt_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_seq
        as integer
        format ">>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_cenar_ctbl_sdo             as character       no-undo. /*local*/
    def var v_cod_cta_ctbl_sdo               as character       no-undo. /*local*/
    def var v_cod_empres_sdo                 as character       no-undo. /*local*/
    def var v_cod_estab_sdo                  as character       no-undo. /*local*/
    def var v_cod_finalid_econ_sdo           as character       no-undo. /*local*/
    def var v_cod_plano_cta_ctbl_sdo         as character       no-undo. /*local*/
    def var v_cod_proj_financ_sdo            as character       no-undo. /*local*/
    def var v_cod_unid_negoc_sdo             as character       no-undo. /*local*/
    def var v_dat_sdo_ctbl                   as date            no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  v_log_sdo_orcado_realzdo
        and v_log_existe_orcto_ccusto
        and sdo_ctbl.cod_ccusto = "" then do:

        assign v_cod_empres_sdo         = sdo_ctbl.cod_empresa
               v_cod_finalid_econ_sdo   = sdo_ctbl.cod_finalid_econ
               v_cod_plano_cta_ctbl_sdo = sdo_ctbl.cod_plano_cta_ctbl
               v_cod_cta_ctbl_sdo       = sdo_ctbl.cod_cta_ctbl
               v_cod_proj_financ_sdo    = sdo_ctbl.cod_proj_financ
               v_cod_cenar_ctbl_sdo     = sdo_ctbl.cod_cenar_ctbl
               v_cod_estab_sdo          = sdo_ctbl.cod_estab
               v_cod_unid_negoc_sdo     = sdo_ctbl.cod_unid_negoc
               v_cod_plano_ccusto_sdo   = sdo_ctbl.cod_plano_ccusto
               v_dat_sdo_ctbl           = sdo_ctbl.dat_sdo_ctbl.
        for each sdo_ctbl no-lock
            where sdo_ctbl.cod_empresa        = v_cod_empres_sdo
            and   sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ_sdo
            and   sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl_sdo
            and   sdo_ctbl.cod_cta_ctbl       = v_cod_cta_ctbl_sdo
            and   sdo_ctbl.cod_plano_ccusto   <> ""
            and   sdo_ctbl.cod_ccusto         <> ""
            and   sdo_ctbl.cod_proj_financ    = v_cod_proj_financ_sdo
            and   sdo_ctbl.cod_cenar_ctbl     = v_cod_cenar_ctbl_sdo
            and   sdo_ctbl.cod_estab          = v_cod_estab_sdo
            and   sdo_ctbl.cod_unid_negoc     = v_cod_unid_negoc_sdo
            and   sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_ctbl:
            run pi_leitura_sdo_ctbl_grava_tt_demonst_2 (input p_num_seq).
        end.
    end.
    else do:
        if v_log_saldo = yes then
            assign v_cod_plano_ccusto_sdo   = b_sdo_ctbl.cod_plano_ccusto. 
        else    
            assign v_cod_plano_ccusto_sdo   = sdo_ctbl.cod_plano_ccusto.

        run pi_leitura_sdo_ctbl_grava_tt_demonst_2 (input p_num_seq).
    end.
END PROCEDURE. /* pi_leitura_sdo_ctbl_grava_tt_demonst */
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
** Procedure Interna.....: pi_leitura_sdo_orcto
** Descricao.............: pi_leitura_sdo_orcto
** Criado por............: bre17108
** Criado em.............: 09/08/2002 14:52:40
** Alterado por..........: fut41162
** Alterado em...........: 22/01/2009 09:06:29
*****************************************************************************/
PROCEDURE pi_leitura_sdo_orcto:

    for each tt_lista_cta_ctbl_demonst:
        delete tt_lista_cta_ctbl_demonst.
    end.

    for each btt_lista_inform_ccusto
      where btt_lista_inform_ccusto.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
      and   btt_lista_inform_ccusto.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + estrut_ctbl_movto_analit.cod_ccusto
      and   btt_lista_inform_ccusto.ttv_log_selec    = yes:
        assign v_cod_ccusto_analit = btt_lista_inform_ccusto.ttv_cod_fill.
        if v_cod_ccusto_analit <> "" then
            if not can-find(estrut_ctbl_movto_sint
                where estrut_ctbl_movto_sint.cod_empresa    = tt_empresa_leitura_sdo.tta_cod_empresa
                and estrut_ctbl_movto_sint.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                AND estrut_ctbl_movto_sint.cod_cta_ctbl     = estrut_ctbl_movto_analit.cod_cta_ctbl
                and estrut_ctbl_movto_sint.cod_plano_ccusto = v_cod_plano_ccusto
                and estrut_ctbl_movto_sint.cod_ccusto       = v_cod_ccusto_analit) THEN next.

        for each btt_lista_inform_conta
          where btt_lista_inform_conta.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
          and   btt_lista_inform_conta.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl + chr(10) + estrut_ctbl_movto_analit.cod_cta_ctbl
          and   btt_lista_inform_conta.ttv_log_selec   = yes:
            assign v_cod_cta_ctbl_analit = btt_lista_inform_conta.ttv_cod_fill.
            if v_cod_ccusto_analit <> "" then
                if not can-find(estrut_ctbl_movto_sint
                    where estrut_ctbl_movto_sint.cod_empresa    = tt_empresa_leitura_sdo.tta_cod_empresa
                    and estrut_ctbl_movto_sint.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                    and estrut_ctbl_movto_sint.cod_cta_ctbl     = v_cod_cta_ctbl_analit
                    and estrut_ctbl_movto_sint.cod_plano_ccusto = v_cod_plano_ccusto
                    and estrut_ctbl_movto_sint.cod_ccusto       = v_cod_ccusto_analit) THEN next.

            for each btt_lista_inform_un
              where btt_lista_inform_un.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
              and   btt_lista_inform_un.ttv_cod_inform    = estrut_ctbl_movto_analit.cod_unid_negoc
              and   btt_lista_inform_un.ttv_log_selec    = yes:
                assign v_cod_unid_negoc_analit  = btt_lista_inform_un.ttv_cod_fill.
                if not can-find(b_estrut_ctbl_movto_analit
                    where b_estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                      and b_estrut_ctbl_movto_analit.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                      and b_estrut_ctbl_movto_analit.cod_cta_ctbl       = v_cod_cta_ctbl_analit
                      and b_estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                      and b_estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto_analit
                      &IF DEFINED(BF_ADM_FIN_PROJ) &THEN
                      and b_estrut_ctbl_movto_analit.cod_proj_financ    = estrut_ctbl_movto_analit.cod_proj_financ
                      &ENDIF
                      and b_estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                      and b_estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc_analit) THEN next.

                for each btt_lista_inform_proj
                  where btt_lista_inform_proj.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                  and   btt_lista_inform_proj.ttv_cod_inform    = estrut_ctbl_movto_analit.cod_proj_financ
                  and   btt_lista_inform_proj.ttv_log_selec    = yes:
                    assign v_cod_proj_financ_analit = btt_lista_inform_proj.ttv_cod_fill.

                    find b_estrut_ctbl_movto_analit use-index estrtctb_id
                       where b_estrut_ctbl_movto_analit.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   b_estrut_ctbl_movto_analit.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                       and   b_estrut_ctbl_movto_analit.cod_cta_ctbl       = v_cod_cta_ctbl_analit
                       and   b_estrut_ctbl_movto_analit.cod_plano_ccusto   = v_cod_plano_ccusto
                       and   b_estrut_ctbl_movto_analit.cod_ccusto         = v_cod_ccusto_analit
                       and   b_estrut_ctbl_movto_analit.cod_estab          = v_cod_estab
                       and   b_estrut_ctbl_movto_analit.cod_proj_financ    = v_cod_proj_financ_analit
                       and   b_estrut_ctbl_movto_analit.cod_unid_negoc     = v_cod_unid_negoc_analit
                       &if '{&emsbas_version}' >= '5.06' &then            
                       and   b_estrut_ctbl_movto_analit.ind_tip_sdo        = "Or‡amento" /*l_orcamento*/ 
                       &else                             
                       and   b_estrut_ctbl_movto_analit.cod_livre_1        = "Or‡amento" /*l_orcamento*/ 
                       &endif                        
                       no-lock no-error.                
                    if avail b_estrut_ctbl_movto_analit then do:              
                        do v_num_count_1 = 1 to v_cdn_tot_dat:
                            assign v_dat_sdo_cta_inic = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10)))
                                   v_dat_sdo_cta_fim  = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10)))
                                   v_cod_exerc_ctbl   = trim(entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10)))
                                   v_num_period_ctbl  = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)))
                                   v_num_seq_1        = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))).
                            find first tt_retorna_sdo_ctbl_demonst
                                 where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ   = v_cod_finalid_econ
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl       = v_cod_cta_ctbl_analit
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto   = v_cod_plano_ccusto
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto         = v_cod_ccusto_analit 
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_estab          = v_cod_estab
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc     = v_cod_unid_negoc_analit
                                 and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ    = v_cod_proj_financ_analit 
                                 and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl       = v_dat_sdo_cta_fim
                                 and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo      = v_ind_espec_sdo
                                 and tt_retorna_sdo_ctbl_demonst.tta_num_seq            = v_num_seq_1 no-error. 
                            if avail tt_retorna_sdo_ctbl_demonst then do:
                                if avail tt_item_demonst_ctbl_video then do:
                                    find tt_relacto_item_retorna 
                                       where tt_relacto_item_retorna.tta_num_seq   = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                       and tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                       and tt_relacto_item_retorna.ttv_rec_ret  = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl no-error.
                                    if not avail tt_relacto_item_retorna then do:
                                        create tt_relacto_item_retorna.
                                        assign tt_relacto_item_retorna.tta_num_seq = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                               tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                               tt_relacto_item_retorna.ttv_rec_ret  = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                                    end.
                                end.
                                next.
                            end.
                            do v_num_count_2 = 1 to v_cdn_tot_orcto:
                                assign v_cod_unid_orctaria   = trim(entry(v_num_count_2,v_cod_unid_orctaria_tot, chr(10)))
                                       v_num_seq_orcto_ctbl  = int(entry(v_num_count_2,v_cod_seq_orcto_ctbl_tot, chr(10)))
                                       v_cod_vers_orcto_ctbl = trim(entry(v_num_count_2,v_cod_vers_orcto_ctbl_tot, chr(10))).
                                run pi_leitura_sdo_orcto_more.
                                run pi_leitura_sdo_orcto_more_1.
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_leitura_sdo_orcto */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_tt_ccusto_analitico
** Descricao.............: pi_localiza_tt_ccusto_analitico
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:13:03
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 17:57:03
*****************************************************************************/
PROCEDURE pi_localiza_tt_ccusto_analitico:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_ccusto
        as Character
        format "x(11)"
        no-undo.


    /************************* Parameter Definition End *************************/

    for each  tt_ccustos_demonst
        where tt_ccustos_demonst.tta_cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
        and   tt_ccustos_demonst.tta_cod_plano_ccusto = v_cod_plano_ccusto
        and   tt_ccustos_demonst.ttv_cod_ccusto_pai   = p_cod_ccusto:

        find first tt_lista_inform
           where   tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
           and     tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto
           and     tt_lista_inform.ttv_cod_fill      = p_cod_ccusto
           no-lock no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                   tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto
                   tt_lista_inform.ttv_cod_fill      = p_cod_ccusto
                   tt_lista_inform.ttv_log_selec    = yes.
            /* Saldo de centro de custo sintetico */
            if  v_log_espec_sdo_ccusto = no
            and p_cod_ccusto <> v_cod_ccusto then
                assign tt_lista_inform.ttv_log_selec = no.
        end.

        run pi_localiza_tt_ccusto_analitico (Input tt_ccustos_demonst.tta_cod_ccusto) /*pi_localiza_tt_ccusto_analitico*/.
    end.

END PROCEDURE. /* pi_localiza_tt_ccusto_analitico */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_tt_cta_ctbl_analitica
** Descricao.............: pi_localiza_tt_cta_ctbl_analitica
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:17:17
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 18:00:31
*****************************************************************************/
PROCEDURE pi_localiza_tt_cta_ctbl_analitica:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_cta_ctbl
        as character
        format "x(20)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* Se for buscar saldo or‡ado, dever  adicionar a lista todas as contas (anal¡ticas ou sint‚ticas)*/
    if v_log_sdo_orcado = yes then do:
        find first tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
           and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
           and   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
           no-lock no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
                   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end.

    /* --- Verifica se a conta ² Pai na Estrutura ---*/
    if not can-find(first btt_cta_ctbl_demonst
        where btt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
        and   btt_cta_ctbl_demonst.ttv_cod_cta_ctbl_pai   = p_cod_cta_ctbl) then do:

        /* Se busca saldo or‡ado, j  adcionou a conta na lista, no come‡o da pi */
        if v_log_sdo_orcado = no then do:
            find first tt_lista_inform
               where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
               and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
               and   tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
               no-lock no-error.
            if not avail tt_lista_inform then do:
                create tt_lista_inform.
                assign tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                       tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
                       tt_lista_inform.ttv_cod_fill      = p_cod_cta_ctbl
                       tt_lista_inform.ttv_log_selec    = yes.
            end.
        end.
    end.
    else do:
        for each  tt_cta_ctbl_demonst no-lock
            where tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
            and   tt_cta_ctbl_demonst.ttv_cod_cta_ctbl_pai   = p_cod_cta_ctbl:
            run pi_localiza_tt_cta_ctbl_analitica (Input tt_cta_ctbl_demonst.tta_cod_cta_ctbl) /*pi_localiza_tt_cta_ctbl_analitica*/.
        end.
    end.

END PROCEDURE. /* pi_localiza_tt_cta_ctbl_analitica */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_tt_proj_financ_analitico
** Descricao.............: pi_localiza_tt_proj_financ_analitico
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:32:43
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 18:01:29
*****************************************************************************/
PROCEDURE pi_localiza_tt_proj_financ_analitico:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_proj_financ
        as character
        format "x(20)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* --- Verifica se o Projeto ² Pai na Estrutura ---*/
    if  not can-find(first btt_proj_financ_demonst no-lock
        where btt_proj_financ_demonst.ttv_cod_proj_financ_pai = p_cod_proj_financ) then do:

        find tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
           and   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
           and   tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
           no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
                   tt_lista_inform.ttv_cod_fill      = p_cod_proj_financ
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end /* if */.
    else do:
        for each tt_proj_financ_demonst no-lock
            where tt_proj_financ_demonst.ttv_cod_proj_financ_pai = p_cod_proj_financ:
            run pi_localiza_tt_proj_financ_analitico (Input tt_proj_financ_demonst.tta_cod_proj_financ) /*pi_localiza_tt_proj_financ_analitico*/.
        end.
    end /* else */.

END PROCEDURE. /* pi_localiza_tt_proj_financ_analitico */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_unid_negoc_analitico
** Descricao.............: pi_localiza_unid_negoc_analitico
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:36:58
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 18:02:36
*****************************************************************************/
PROCEDURE pi_localiza_unid_negoc_analitico:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_unid_negoc
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_unid_negoc_pai
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find tt_unid_negocio
        where tt_unid_negocio.tta_cod_unid_negoc = p_cod_unid_negoc
        no-lock no-error.
    if not avail tt_unid_negocio then do:
        create tt_unid_negocio.
        assign tt_unid_negocio.tta_cod_unid_negoc     = p_cod_unid_negoc
               tt_unid_negocio.ttv_cod_unid_negoc_pai = p_cod_unid_negoc_pai.
    end /* if */.
    else do:
        if p_cod_unid_negoc_pai <> "" then
            assign tt_unid_negocio.ttv_cod_unid_negoc_pai = p_cod_unid_negoc_pai.
        /* se ja existe tt_ccusto, entao os filhos tamb‚m j  estÆo na tt_ccusto */
        run pi_localiza_tt_unid_negoc_analitico (Input p_cod_unid_negoc) /*pi_localiza_tt_unid_negoc_analitico*/.
        return.
    end. 

    /* --- Verifica se a Unidade de Negocio ² Pai na Estrutura ---*/
    if  not can-find(first estrut_unid_negoc no-lock
        where estrut_unid_negoc.cod_unid_negoc_pai    = p_cod_unid_negoc) then do:

        find tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
           and   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc
           and   tt_lista_inform.ttv_cod_fill      = p_cod_unid_negoc
           no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc
                   tt_lista_inform.ttv_cod_fill      = p_cod_unid_negoc
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end /* if */.
    else do:
        for each estrut_unid_negoc no-lock
            where estrut_unid_negoc.cod_unid_negoc_pai = p_cod_unid_negoc:
            run pi_localiza_unid_negoc_analitico (Input estrut_unid_negoc.cod_unid_negoc_filho,
                                                  Input estrut_unid_negoc.cod_unid_negoc_pai) /*pi_localiza_unid_negoc_analitico*/.
        end.
    end /* else */.

END PROCEDURE. /* pi_localiza_unid_negoc_analitico */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_tt_unid_negoc_analitico
** Descricao.............: pi_localiza_tt_unid_negoc_analitico
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:37:06
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 18:03:29
*****************************************************************************/
PROCEDURE pi_localiza_tt_unid_negoc_analitico:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_unid_negoc
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* --- Verifica se a Unidade de Negocio ² Pai na Estrutura ---*/
    if  not can-find(first btt_unid_negocio no-lock
        where btt_unid_negocio.ttv_cod_unid_negoc_pai = p_cod_unid_negoc) then do:

        find tt_lista_inform
           where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
           and   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc
           and   tt_lista_inform.ttv_cod_fill      = p_cod_unid_negoc
           no-error.
        if not avail tt_lista_inform then do:
            create tt_lista_inform.
            assign tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
                   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc
                   tt_lista_inform.ttv_cod_fill      = p_cod_unid_negoc
                   tt_lista_inform.ttv_log_selec    = yes.
        end.
    end /* if */.
    else do:
        for each tt_unid_negocio no-lock
            where tt_unid_negocio.ttv_cod_unid_negoc_pai = p_cod_unid_negoc:
            run pi_localiza_tt_unid_negoc_analitico (Input tt_unid_negocio.tta_cod_unid_negoc) /*pi_localiza_tt_unid_negoc_analitico*/.
        end.
    end /* else */.

END PROCEDURE. /* pi_localiza_tt_unid_negoc_analitico */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_consolid_grava_tt
** Descricao.............: pi_leitura_sdo_consolid_grava_tt
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:53:47
** Alterado por..........: fut41162
** Alterado em...........: 18/02/2009 18:27:57
*****************************************************************************/
PROCEDURE pi_leitura_sdo_consolid_grava_tt:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_seq
        as integer
        format ">>>,>>9"
        no-undo.
    def Input param p_log_simul
        as logical
        format "Sim/NÆo"
        no-undo.
    def Input param p_log_busca_recur
        as logical
        format "Sim/NÆo"
        no-undo.
    def Input param p_rec_ret_orig
        as recid
        format ">>>>>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* --- Verifica se a Conta Contÿbil, Ccusto e o Projeto est’o dentro das Faixas parametrizadas ---*/ 
    bloco:
    do:

        find first tt_retorna_sdo_ctbl_demonst
             where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = sdo_cta_ctbl_consolid.cod_unid_organ
               and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = sdo_cta_ctbl_consolid.cod_finalid_econ
               and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = sdo_cta_ctbl_consolid.cod_plano_cta_ctbl
               and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = sdo_cta_ctbl_consolid.cod_cta_ctbl
               and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = sdo_cta_ctbl_consolid.cod_cenar_ctbl
               and tt_retorna_sdo_ctbl_demonst.tta_cod_estab           = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = sdo_cta_ctbl_consolid.cod_unid_negoc
               and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = ""
               and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = sdo_cta_ctbl_consolid.dat_sdo_ctbl
               and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = v_ind_espec_sdo
               and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = sdo_cta_ctbl_consolid.cod_unid_organ_orig
               and tt_retorna_sdo_ctbl_demonst.tta_num_seq             = p_num_seq
               no-error. 
        if not avail tt_retorna_sdo_ctbl_demonst then do:
            create tt_retorna_sdo_ctbl_demonst.
            assign tt_retorna_sdo_ctbl_demonst.tta_num_seq                 = p_num_seq
                   tt_retorna_sdo_ctbl_demonst.tta_cod_empresa             = sdo_cta_ctbl_consolid.cod_unid_organ
                   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ        = sdo_cta_ctbl_consolid.cod_finalid_econ
                   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl      = sdo_cta_ctbl_consolid.cod_plano_cta_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl            = sdo_cta_ctbl_consolid.cod_cta_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto        = ""
                   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto              = ""
                   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl          = sdo_cta_ctbl_consolid.cod_cenar_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_estab               = ""
                   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc          = sdo_cta_ctbl_consolid.cod_unid_negoc
                   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ         = ""
                   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl            = sdo_cta_ctbl_consolid.dat_sdo_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig     = sdo_cta_ctbl_consolid.cod_unid_organ_orig
                   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo           = v_ind_espec_sdo
                   tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl        = recid(tt_retorna_sdo_ctbl_demonst).

            if avail tt_item_demonst_ctbl_video then do:
                if  p_log_busca_recur = no
                then do:
                    create tt_relacto_item_retorna.
                    assign tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                           tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                           tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                end.
                else do:
                    create tt_relacto_item_retorna_cons.
                    assign tt_relacto_item_retorna_cons.tta_num_seq      = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                           tt_relacto_item_retorna_cons.ttv_rec_ret_orig = p_rec_ret_orig
                           tt_relacto_item_retorna_cons.ttv_rec_ret_dest = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                end.
            end.
        end.                   

        /* ------------------------------------- EPC ---------------------------------------*/
        /* Esta epc visa alterar o valor do saldo das contas intercompany */
        if  v_nom_prog_dpc  <> ''
        or  v_nom_prog_upc  <> ''
        or  v_nom_prog_appc <> ''
        then do:
            if sdo_cta_ctbl_consolid.log_elimina_intercomp = yes then do:

                for each tt_epc:
                    delete tt_epc.
                end.

                create tt_epc.
                assign tt_epc.cod_event     = 'CONSOLID INTERCOMPANY'
                       tt_epc.cod_param     = 'RECID SDO_CTA_CTBL_CONSOLID'
                       tt_epc.val_parameter = STRING(recid(sdo_cta_ctbl_consolid)).

                if v_nom_prog_dpc <> "" then
                    run value(v_nom_prog_dpc) (input 'CONSOLID INTERCOMPANY', input-output table tt_epc).
                else if v_nom_prog_upc <> "" then
                    run value(v_nom_prog_upc) (input 'CONSOLID INTERCOMPANY', input-output table tt_epc).
                else if v_nom_prog_appc <> "" then
                    run value(v_nom_prog_appc) (input 'CONSOLID INTERCOMPANY', input-output table tt_epc).

                find tt_epc
                   where tt_epc.cod_event     = 'CONSOLID INTERCOMPANY'
                   and   tt_epc.cod_parameter = 'RETORNO CONSOLID INTERCOMPANY' no-lock no-error.
                if avail tt_epc then do:

                    if p_log_simul then
                        assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db
                                                                                      - decimal(entry(1,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr
                                                                                      - decimal(entry(2,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim       = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim
                                                                                      - decimal(entry(3,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db        = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db
                                                                                      - decimal(entry(4,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr        = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr
                                                                                      - decimal(entry(5,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo      = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo 
                                                                                      - decimal(entry(6,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr   = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr
                                                                                      - decimal(entry(7,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db   = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db
                                                                                      - decimal(entry(8,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum
                                                                                      - decimal(entry(9,tt_epc.val_parameter,chr(10)))
                               tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl         = tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl
                                                                                      - (decimal(entry(1,tt_epc.val_parameter,chr(10)))
                                                                                      -  decimal(entry(2,tt_epc.val_parameter,chr(10))))
                               tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl         = tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl
                                                                                      - (decimal(entry(4,tt_epc.val_parameter,chr(10)))
                                                                                      -  decimal(entry(5,tt_epc.val_parameter,chr(10)))).
                    else
                        assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db        
                                                                                      + decimal(entry(1,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr        
                                                                                      + decimal(entry(2,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim       = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim       
                                                                                      + decimal(entry(3,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db        = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db        
                                                                                      + decimal(entry(4,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr        = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr        
                                                                                      + decimal(entry(5,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo      = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo      
                                                                                      + decimal(entry(6,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr   = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr   
                                                                                      + decimal(entry(7,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db   = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db   
                                                                                      + decimal(entry(8,tt_epc.val_parameter,chr(10)))                                 
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum 
                                                                                      + decimal(entry(9,tt_epc.val_parameter,chr(10)))             
                               tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl         = tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl         
                                                                                      + (decimal(entry(1,tt_epc.val_parameter,chr(10)))            
                                                                                      -  decimal(entry(2,tt_epc.val_parameter,chr(10))))           
                               tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl         = tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl         
                                                                                      + (decimal(entry(4,tt_epc.val_parameter,chr(10)))            
                                                                                      -  decimal(entry(5,tt_epc.val_parameter,chr(10)))).          

                    return.
                end.
            end.
        end /* if */.
        /* ----------------------------------- FIM EPC -------------------------------------*/


        if p_log_simul then
            assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db
                                                                   - sdo_cta_ctbl_consolid.val_sdo_ctbl_db
                   tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr
                                                                   - sdo_cta_ctbl_consolid.val_sdo_ctbl_cr 
                   tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim
                                                                   - sdo_cta_ctbl_consolid.val_sdo_ctbl_fim 
                   tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db
                                                                   - sdo_cta_ctbl_consolid.qtd_sdo_ctbl_db 
                   tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr
                                                                   - sdo_cta_ctbl_consolid.qtd_sdo_ctbl_cr
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo       = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo + sdo_cta_ctbl_consolid.val_apurac_restdo

                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr
                                                                   - sdo_cta_ctbl_consolid.val_apurac_restdo_cr
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db
                                                                   - sdo_cta_ctbl_consolid.val_apurac_restdo_db                                
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum
                                                                   - sdo_cta_ctbl_consolid.val_apurac_restdo_acum
                   tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl
                                                                   - (sdo_cta_ctbl_consolid.val_sdo_ctbl_db
                                                                   -  sdo_cta_ctbl_consolid.val_sdo_ctbl_cr)
                   tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl
                                                                   - (sdo_cta_ctbl_consolid.qtd_sdo_ctbl_db
                                                                   -  sdo_cta_ctbl_consolid.qtd_sdo_ctbl_cr).
        else
            assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db
                                                                   + sdo_cta_ctbl_consolid.val_sdo_ctbl_db
                   tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr
                                                                   + sdo_cta_ctbl_consolid.val_sdo_ctbl_cr 
                   tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim
                                                                   + sdo_cta_ctbl_consolid.val_sdo_ctbl_fim 
                   tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db
                                                                   + sdo_cta_ctbl_consolid.qtd_sdo_ctbl_db 
                   tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr
                                                                   + sdo_cta_ctbl_consolid.qtd_sdo_ctbl_cr
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo       = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo + sdo_cta_ctbl_consolid.val_apurac_restdo

                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr
                                                                   + sdo_cta_ctbl_consolid.val_apurac_restdo_cr
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db
                                                                   + sdo_cta_ctbl_consolid.val_apurac_restdo_db                                
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum
                                                                   + sdo_cta_ctbl_consolid.val_apurac_restdo_acum
                   tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl
                                                                   + (sdo_cta_ctbl_consolid.val_sdo_ctbl_db
                                                                   -  sdo_cta_ctbl_consolid.val_sdo_ctbl_cr)
                   tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl
                                                                   + (sdo_cta_ctbl_consolid.qtd_sdo_ctbl_db
                                                                   -  sdo_cta_ctbl_consolid.qtd_sdo_ctbl_cr).

        if  p_log_busca_recur = yes
        then do:
            find tt_perc_particip no-lock
                where tt_perc_particip.tta_cod_unid_organ_orig = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig
                  and tt_perc_particip.tta_cod_unid_organ_dest = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa no-error.
            if  not avail tt_perc_particip
            then do:
                find first item_distrib_gerc_ctbl no-lock
                     where item_distrib_gerc_ctbl.cod_unid_organ_orig     = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig
                       and item_distrib_gerc_ctbl.cod_plano_cta_ctbl_dest = tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl
                       and item_distrib_gerc_ctbl.cod_unid_organ_dest     = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa
                       and item_distrib_gerc_ctbl.dat_inic_valid         <= tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl
                       and item_distrib_gerc_ctbl.dat_fim_valid          >= tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl no-error.
                if  avail item_distrib_gerc_ctbl
                then do:
                    create tt_perc_particip.
                    assign tt_perc_particip.tta_cod_unid_organ_orig     = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig
                           tt_perc_particip.tta_cod_unid_organ_dest     = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa.

                    &if '{&emsbas_version}' >= '5.06' &then                            
                        assign tt_perc_particip.ttv_val_perc_criter_distrib = item_distrib_gerc_ctbl.val_perc_criter_distrib.
                    &else
                        if  v_log_funcao_perc_dec then
                            assign tt_perc_particip.ttv_val_perc_criter_distrib = dec(entry(1,item_distrib_gerc_ctbl.cod_livre_1,chr(24))).
                        else
                            assign tt_perc_particip.ttv_val_perc_criter_distrib = item_distrib_gerc_ctbl.val_perc_criter_distrib.
                    &endif
                end.
            end.
            if avail tt_perc_particip then
                assign tt_retorna_sdo_ctbl_demonst.ttv_val_perc_criter_distrib = tt_perc_particip.ttv_val_perc_criter_distrib.
        end.

        if  v_log_consolid_recur
        then do:
            run pi_leitura_sdo_consolid_more (Input sdo_cta_ctbl_consolid.cod_unid_organ_orig,
                                              Input sdo_cta_ctbl_consolid.cod_plano_cta_ctbl,
                                              Input sdo_cta_ctbl_consolid.cod_cta_ctbl,
                                              Input sdo_cta_ctbl_consolid.cod_unid_negoc,
                                              Input sdo_cta_ctbl_consolid.cod_finalid_econ,
                                              Input sdo_cta_ctbl_consolid.cod_cenar_ctbl,
                                              Input sdo_cta_ctbl_consolid.dat_sdo_ctbl,
                                              Input tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl) /*pi_leitura_sdo_consolid_more*/.
        end.
    end.

END PROCEDURE. /* pi_leitura_sdo_consolid_grava_tt */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_orcto_grava_tt
** Descricao.............: pi_leitura_sdo_orcto_grava_tt
** Criado por............: bre17108
** Criado em.............: 09/08/2002 17:53:35
** Alterado por..........: fut41162
** Alterado em...........: 22/01/2009 14:47:40
*****************************************************************************/
PROCEDURE pi_leitura_sdo_orcto_grava_tt:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_seq
        as integer
        format ">>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* --- Verifica se a Conta Contÿbil, Ccusto e o Projeto est’o dentro das Faixas parametrizadas ---*/ 
    bloco:
    do:
        find tt_retorna_sdo_ctbl_demonst
            where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa        = sdo_orcto_ctbl_bgc.cod_empresa
              and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ   = v_cod_finalid_econ
              and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl = sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl
              and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl       = sdo_orcto_ctbl_bgc.cod_cta_ctbl
              and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto   = (if v_cod_plano_ccusto <> "" then sdo_orcto_ctbl_bgc.cod_plano_ccusto
                                                                       else "")
              and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto         = (if v_cod_plano_ccusto <> "" then sdo_orcto_ctbl_bgc.cod_ccusto
                                                                       else "")
              and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl     = sdo_orcto_ctbl_bgc.cod_cenar_ctbl
              and tt_retorna_sdo_ctbl_demonst.tta_cod_estab          = sdo_orcto_ctbl_bgc.cod_estab
              and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc     = sdo_orcto_ctbl_bgc.cod_unid_negoc
              and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ    = sdo_orcto_ctbl_bgc.cod_proj_financ
              and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl       = v_dat_sdo_cta_fim
              and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo      = v_ind_espec_sdo
              and tt_retorna_sdo_ctbl_demonst.tta_num_seq            = p_num_seq
              and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = sdo_orcto_ctbl_bgc.cod_empresa
              no-error. 

        if  not avail tt_retorna_sdo_ctbl_demonst then do: 
            create tt_retorna_sdo_ctbl_demonst.
            assign tt_retorna_sdo_ctbl_demonst.tta_num_seq                 = p_num_seq
                   tt_retorna_sdo_ctbl_demonst.tta_cod_empresa             = sdo_orcto_ctbl_bgc.cod_empresa
                   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ        = v_cod_finalid_econ
                   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl      = sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl            = sdo_orcto_ctbl_bgc.cod_cta_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto        = (if v_cod_plano_ccusto <> "" then sdo_orcto_ctbl_bgc.cod_plano_ccusto
                                                                             else "")
                   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto              = (if v_cod_plano_ccusto <> "" then sdo_orcto_ctbl_bgc.cod_ccusto
                                                                             else "")
                   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl          = sdo_orcto_ctbl_bgc.cod_cenar_ctbl
                   tt_retorna_sdo_ctbl_demonst.tta_cod_estab               = sdo_orcto_ctbl_bgc.cod_estab
                   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc          = sdo_orcto_ctbl_bgc.cod_unid_negoc
                   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ         = sdo_orcto_ctbl_bgc.cod_proj_financ
                   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl            = v_dat_sdo_cta_fim
                   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo           = v_ind_espec_sdo
                   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig     = sdo_orcto_ctbl_bgc.cod_empresa
                   tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl        = recid(tt_retorna_sdo_ctbl_demonst).

            if avail tt_item_demonst_ctbl_video then do:
                create tt_relacto_item_retorna.
                assign tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                       tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                       tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
            end.
        end.
        assign tt_retorna_sdo_ctbl_demonst.tta_val_orcado     = tt_retorna_sdo_ctbl_demonst.tta_val_orcado     
                                                              + sdo_orcto_ctbl_bgc.val_orcado
               tt_retorna_sdo_ctbl_demonst.tta_val_orcado_sdo = tt_retorna_sdo_ctbl_demonst.tta_val_orcado_sdo 
                                                              + sdo_orcto_ctbl_bgc.val_orcado_sdo
               tt_retorna_sdo_ctbl_demonst.tta_qtd_orcado     = tt_retorna_sdo_ctbl_demonst.tta_qtd_orcado     
                                                              + sdo_orcto_ctbl_bgc.qtd_orcado
               tt_retorna_sdo_ctbl_demonst.tta_qtd_orcado_sdo = tt_retorna_sdo_ctbl_demonst.tta_qtd_orcado_sdo 
                                                              + sdo_orcto_ctbl_bgc.qtd_orcado_sdo.


        /* ********* RAFA *********/
        if v_log_orcto_cta_sint then do:
            find tt_cta_ctbl_demonst
               where tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl
               and   tt_cta_ctbl_demonst.tta_cod_cta_ctbl       = tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl
               no-lock no-error.
            if avail tt_cta_ctbl_demonst 
            and tt_cta_ctbl_demonst.tta_ind_espec_cta_ctbl = "Sint‚tica" /*l_sintetica*/  then do:
                run pi_localiza_tt_cta_ctbl_analitica_demonst_1 (Input tt_cta_ctbl_demonst.tta_cod_cta_ctbl) /*pi_localiza_tt_cta_ctbl_analitica_demonst_1*/.
            end.

            /* 216521 - erro  progress "REPLACE/CONCAT may not result in data >  bytes */
            find first tt_lista_cta_ctbl_demonst 
                where tt_lista_cta_ctbl_demonst.ttv_rec_lista_cta_ctbl_aux = recid(tt_retorna_sdo_ctbl_demonst)
                  and tt_lista_cta_ctbl_demonst.tta_cod_empresa  = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa    
                  and tt_lista_cta_ctbl_demonst.tta_cod_estab       = tt_retorna_sdo_ctbl_demonst.tta_cod_estab 
                  and tt_lista_cta_ctbl_demonst.tta_cod_unid_negoc  = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc               
                  and tt_lista_cta_ctbl_demonst.tta_cod_proj_financ = tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ
                  and tt_lista_cta_ctbl_demonst.tta_cod_cta_ctbl    = tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl
                  and tt_lista_cta_ctbl_demonst.tta_cod_ccusto      = tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto no-error.
            if avail tt_lista_cta_ctbl_demonst then                          
                assign tt_retorna_sdo_ctbl_demonst.ttv_log_sdo_orcado_sint = yes.

            if  sdo_orcto_ctbl_bgc.cod_ccusto <> ""
            and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto = "" then do:
                find tt_retorna_sdo_orcto_ccusto
                   where tt_retorna_sdo_orcto_ccusto.ttv_rec_ret_sdo_ctbl = recid(tt_retorna_sdo_ctbl_demonst)
                   and   tt_retorna_sdo_orcto_ccusto.tta_cod_plano_ccusto = sdo_orcto_ctbl_bgc.cod_plano_ccusto
                   and   tt_retorna_sdo_orcto_ccusto.tta_cod_ccusto       = sdo_orcto_ctbl_bgc.cod_ccusto
                   no-error.
                if not avail tt_retorna_sdo_orcto_ccusto then do: 
                    create tt_retorna_sdo_orcto_ccusto.
                    assign tt_retorna_sdo_orcto_ccusto.ttv_rec_ret_sdo_ctbl = recid(tt_retorna_sdo_ctbl_demonst)
                           tt_retorna_sdo_orcto_ccusto.tta_cod_plano_ccusto = sdo_orcto_ctbl_bgc.cod_plano_ccusto
                           tt_retorna_sdo_orcto_ccusto.tta_cod_ccusto       = sdo_orcto_ctbl_bgc.cod_ccusto
                           tt_retorna_sdo_orcto_ccusto.tta_val_orcado       = sdo_orcto_ctbl_bgc.val_orcado
                           tt_retorna_sdo_orcto_ccusto.tta_val_orcado_sdo   = sdo_orcto_ctbl_bgc.val_orcado_sdo
                           tt_retorna_sdo_orcto_ccusto.tta_qtd_orcado       = sdo_orcto_ctbl_bgc.qtd_orcado
                           tt_retorna_sdo_orcto_ccusto.tta_qtd_orcado_sdo   = sdo_orcto_ctbl_bgc.qtd_orcado_sdo.

                end.
            end.
        end.
        /* *******************/

    end.

END PROCEDURE. /* pi_leitura_sdo_orcto_grava_tt */
/*****************************************************************************
** Procedure Interna.....: pi_busca_saldo
** Descricao.............: pi_busca_saldo
** Criado por............: src531
** Criado em.............: 13/08/2002 10:49:56
** Alterado por..........: fut12161
** Alterado em...........: 18/01/2008 09:44:03
*****************************************************************************/
PROCEDURE pi_busca_saldo:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "1.00" &then
    def buffer b_compos_demonst_ctbl
        for compos_demonst_ctbl.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_ind_tip_ccusto
        as character
        format "X(08)":U
        no-undo.


    /************************** Variable Definition End *************************/

    /* - Chamada UPC que verifica a regra para os estabelecimentos do Demostrativo Cont bil */
    if  v_nom_prog_dpc  <> ''
    or  v_nom_prog_upc  <> ''
    or  v_nom_prog_appc <> ''
    then do:
        for each tt_epc exclusive-lock:
            delete tt_epc.
        end.
        create tt_epc.
        assign tt_epc.cod_event     = 'regra'
               tt_epc.cod_param     = "cod_estab" /*l_cod_estab*/ 
               tt_epc.val_parameter = STRING(estrut_ctbl_movto_analit.cod_estab).


        /* Begin_Include: i_exec_program_epc_custom */
        if  v_nom_prog_upc <> '' then
        do:
            run value(v_nom_prog_upc) (input 'regra',
                                       input-output table tt_epc).
        end.

        if  v_nom_prog_appc <> '' then
        do:
            run value(v_nom_prog_appc) (input 'regra',
                                        input-output table tt_epc).
        end.

        &if '{&emsbas_version}' > '5.00' &then
        if  v_nom_prog_dpc <> '' then
        do:
            run value(v_nom_prog_dpc) (input 'regra',
                                        input-output table tt_epc).
        end.
        &endif
        /* End_Include: i_exec_program_epc_custom */


        if return-value = 'NOK' then return.
    end.

    if v_log_restric_estab = yes then do:

        if  can-do(v_des_lista_estab_sem_segur, estrut_ctbl_movto_analit.cod_estab) then
            return.

        if not can-do(v_des_lista_estab_com_segur, estrut_ctbl_movto_analit.cod_estab) then do:

            assign v_log_possui_permis = no.
            if  can-find(first segur_unid_organ no-lock
                where segur_unid_organ.cod_unid_organ = estrut_ctbl_movto_analit.cod_estab
                and   segur_unid_organ.cod_grp_usuar  = "*") then do:
                assign v_log_possui_permis = yes.
            end.
            else do:
                loop_block:
                for each usuar_grp_usuar no-lock
                    where usuar_grp_usuar.cod_usuario = v_cod_usuar_corren:
                    if  can-find(first segur_unid_organ no-lock
                        where segur_unid_organ.cod_unid_organ = estrut_ctbl_movto_analit.cod_estab
                        and   segur_unid_organ.cod_grp_usuar  = usuar_grp_usuar.cod_grp_usuar) then do:
                        assign v_log_possui_permis = yes.
                        leave loop_block.
                    end.
                end.
            end.

            if  v_log_possui_permis = no then do:
                /* ** MONTA LISTA DE ESTAB. N€O-LISTAdoS POR FALTA DE ACESSO ***/
                assign v_des_lista_estab_sem_segur = v_des_lista_estab_sem_segur
                                         + (if v_des_lista_estab_sem_segur <> "" then "," else "")
                                         + estrut_ctbl_movto_analit.cod_estab.
                return.
            end.
            else 
                /* ** MONTA LISTA DE ESTAB. LISTAdoS ***/
                assign v_des_lista_estab_com_segur = v_des_lista_estab_com_segur
                                         + (if v_des_lista_estab_com_segur <> "" then "," else "")
                                         + estrut_ctbl_movto_analit.cod_estab.
        end.
    end.

    /* ** VERIFICA RESTRI€ÇO CONTRO DE CUSTO ***/
    if estrut_ctbl_movto_analit.cod_ccusto <> '' then do:
        if  can-find(first tt_lista_ccusto 
                     where tt_lista_ccusto.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto
                       and tt_lista_ccusto.ttv_log_segur_ccusto = no ) then return.

        if  not can-find(first tt_lista_ccusto 
                     where tt_lista_ccusto.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto
                       and tt_lista_ccusto.ttv_log_segur_ccusto = yes )  then do:

            /* ** VERIFICA SE O USUæRIO TEM PERMISS€O DE ACESSO ***/ 
            run pi_verifica_segur_ccusto_demonst (Input v_cod_unid_organ,
                                                  Input v_cod_plano_ccusto,
                                                  Input estrut_ctbl_movto_analit.cod_ccusto,
                                                  output v_log_return) /* pi_verifica_segur_ccusto_demonst*/. 
            if  v_log_return = no then do:
                /* ** MONTA LISTA DE CCUSTOS. NAO-LISTADOS POR FALTA DE ACESSO ***/
                CREATE tt_lista_ccusto.
                ASSIGN tt_lista_ccusto.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto
                       tt_lista_ccusto.ttv_log_segur_ccusto = no. /* sem seguran‡a*/
                if not can-find(first tt_ccusto_segur
                   where tt_ccusto_segur.tta_cod_empres = v_cod_unid_organ
                   and   tt_ccusto_segur.tta_cod_plano_ccusto = v_cod_plano_ccusto
                   and   tt_ccusto_segur.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto)
                then do:
                     create tt_ccusto_segur.
                     assign tt_ccusto_segur.tta_cod_empres = v_cod_unid_organ
                            tt_ccusto_segur.tta_cod_plano_ccusto = v_cod_plano_ccusto
                            tt_ccusto_segur.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto.
                end.
                return.
            end.
            else 
                /* ** MONTA LISTA DE CCUSTOS. LISTADOS ***/
                CREATE tt_lista_ccusto.
                ASSIGN tt_lista_ccusto.tta_cod_ccusto = estrut_ctbl_movto_analit.cod_ccusto
                       tt_lista_ccusto.ttv_log_segur_ccusto = yes. /* com seguran‡a*/
        end.
    end.

    /* ** VERIFICA PARTE FIXA ***/
    if ( not estrut_ctbl_movto_analit.cod_cta_ctbl matches v_cod_cta_ctbl_pfixa and v_cod_cta_ctbl_pfixa <> '')
    or ( not estrut_ctbl_movto_analit.cod_ccusto matches v_cod_ccusto_pfixa and v_cod_ccusto_pfixa <> '')
    or ( not estrut_ctbl_movto_analit.cod_proj_financ matches substring(v_cod_proj_financ_pfixa,1,length(estrut_ctbl_movto_analit.cod_proj_financ)) and v_cod_proj_financ_pfixa <> '') then
        return.

    /* ** VERIFICA EXCE€ÇO ***/
    if v_cod_cta_ctbl_excec <> "" then do:
        do v_num_count = 1 to v_cdn_tot_con_excec:
            if (entry(v_num_count,v_cod_cta_ctbl_excec,chr(10)) <> fill(chr(46), length(estrut_ctbl_movto_analit.cod_cta_ctbl))
            and estrut_ctbl_movto_analit.cod_cta_ctbl matches entry(v_num_count,v_cod_cta_ctbl_excec,chr(10))) then
                return.
        end.
    end.
    if v_cod_ccusto_excec <> "" then do:
        do v_num_count = 1 to v_cdn_tot_ccusto_excec:
            if (entry(v_num_count,v_cod_ccusto_excec,chr(10)) <> fill(chr(46), length(estrut_ctbl_movto_analit.cod_ccusto))
            and estrut_ctbl_movto_analit.cod_ccusto matches entry(v_num_count,v_cod_ccusto_excec,chr(10))) then
                return.
        end.
    end.
    if v_cod_proj_financ_excec <> "" then do:
        do v_num_count = 1 to v_cdn_tot_proj_excec:
            if (substring(entry(v_num_count,v_cod_proj_financ_excec,chr(10)),1,length(estrut_ctbl_movto_analit.cod_proj_financ)) <> fill(chr(46), length(estrut_ctbl_movto_analit.cod_proj_financ))
            and estrut_ctbl_movto_analit.cod_proj_financ matches (substring(entry(v_num_count,v_cod_proj_financ_excec,chr(10)),1,length(estrut_ctbl_movto_analit.cod_proj_financ)))) then
                return.
        end.
    end.

    assign v_cod_cta_ctbl    = estrut_ctbl_movto_analit.cod_cta_ctbl
           v_cod_ccusto      = estrut_ctbl_movto_analit.cod_ccusto
           v_cod_estab       = estrut_ctbl_movto_analit.cod_estab
           v_cod_unid_negoc  = estrut_ctbl_movto_analit.cod_unid_negoc
           v_cod_proj_financ = estrut_ctbl_movto_analit.cod_proj_financ.

    /* ** VERIFICA OS SALDOS QUE O PROGRMA DEVE RETORNAR ***/
    do v_num_count = 1 to num-entries(v_ind_espec_sdo_tot,chr(59)):

        assign v_ind_espec_sdo = entry(v_num_count, v_ind_espec_sdo_tot, chr(59)).

        /* Varre a estrutura de contas, centro de custos, etc  uma unica vez */
        if v_num_count = 1 then do:
            /* ** MELHORIA DE PERFORMANCE PARA CENTROS DE CUSTO ***/
            if   estrut_ctbl_movto_analit.cod_plano_ccusto <> ""
            and  v_log_espec_sdo_ccusto = yes
            and  avail plano_ccusto
            and (lookup("Centro de Custo" /*l_centro_de_custo*/  ,v_cod_chave,chr(10)) = 0 
            or   v_ind_espec_cta = "" /* consulta de saldo conta centro de custo */)
            and (v_cod_ccusto_pfixa = ''
            or   v_cod_ccusto_pfixa = fill(chr(46), length(estrut_ctbl_movto_analit.cod_ccusto)))
            and (v_cod_ccusto_excec = ''
            or   v_cod_ccusto_excec = fill(chr(46), length(estrut_ctbl_movto_analit.cod_ccusto))) 
            and  v_cod_ccusto_inic <> v_cod_ccusto_final 
            then do:

                run pi_retornar_valores_iniciais_prefer (Input plano_ccusto.cod_format_ccusto,
                                                         Input "CCusto" /*l_ccusto*/,
                                                         output v_cod_initial,
                                                         output v_cod_final) /*pi_retornar_valores_iniciais_prefer*/.

                /* ** SE O PAI DO CCUSTO SELECIONADO ESTIVER DENTRO DA FAIXA DESCONSIDERA O CCUSTO ***/
                find first estrut_ccusto
                    where estrut_ccusto.cod_empresa      = v_cod_unid_organ
                    and   estrut_ccusto.cod_plano_ccusto = v_cod_plano_ccusto
                    and   estrut_ccusto.cod_ccusto_FILHO = v_cod_ccusto
                    and   estrut_ccusto.cod_ccusto_pai  >= v_cod_ccusto_inic
                    and   estrut_ccusto.cod_ccusto_pai  <= v_cod_ccusto_final
                    and   estrut_ccusto.cod_ccusto_pai  <> ""
                    and   estrut_ccusto.cod_ccusto_pai  <> v_cod_initial no-lock no-error.
                if avail estrut_ccusto then do:

                    /* ** VERIFICA RESTRI°€O CENTRO DE CUSTO PAI ***/

                    if  can-find(first tt_lista_ccusto 
                                 where tt_lista_ccusto.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai
                                   and tt_lista_ccusto.ttv_log_segur_ccusto = yes ) then return.

                    if  not can-find(first tt_lista_ccusto 
                                     where tt_lista_ccusto.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai
                                       and tt_lista_ccusto.ttv_log_segur_ccusto = no )  then do:

                        /* ** VERIFICA SE O USUæRIO TEM PERMISS€O DE ACESSO ***/ 
                        run pi_verifica_segur_ccusto_demonst (Input v_cod_unid_organ,
                                                              Input v_cod_plano_ccusto,
                                                              Input estrut_ccusto.cod_ccusto_pai,
                                                              output v_log_return) /* pi_verifica_segur_ccusto_demonst*/. 
                        if  v_log_return = no then do:
                            /* ** MONTA LISTA DE CCUSTOS. N€O-LISTADOS POR FALTA DE ACESSO ***/
                            CREATE tt_lista_ccusto.
                            ASSIGN tt_lista_ccusto.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai
                                   tt_lista_ccusto.ttv_log_segur_ccusto = no. /* sem seguran‡a*/

                            if not can-find(first tt_ccusto_segur
                               where tt_ccusto_segur.tta_cod_empres = v_cod_unid_organ
                               and   tt_ccusto_segur.tta_cod_plano_ccusto = v_cod_plano_ccusto
                               and   tt_ccusto_segur.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai)
                            then do:
                                 create tt_ccusto_segur.
                                 assign tt_ccusto_segur.tta_cod_empres = v_cod_unid_organ
                                        tt_ccusto_segur.tta_cod_plano_ccusto = v_cod_plano_ccusto
                                        tt_ccusto_segur.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai.
                            end.
                        end.
                        else do: 
                            /* ** MONTA LISTA DE CCUSTOS. LISTADOS ***/
                            CREATE tt_lista_ccusto.
                            ASSIGN tt_lista_ccusto.tta_cod_ccusto = estrut_ccusto.cod_ccusto_pai
                                   tt_lista_ccusto.ttv_log_segur_ccusto = yes. /* com seguran‡a*/
                            return.
                        end.
                    end.
                end.
            end.

            /* ** MELHORIA DE PERFORMANCE PARA PROJETO ***/
            if   estrut_ctbl_movto_analit.cod_proj_financ <> ""
            and  lookup("Projeto" /*l_projeto*/  ,v_cod_chave,chr(10)) = 0
            and (v_cod_proj_financ_pfixa = ''
            or   substring(v_cod_proj_financ_pfixa,1,length(estrut_ctbl_movto_analit.cod_proj_financ)) = fill(chr(46), length(estrut_ctbl_movto_analit.cod_proj_financ)))
            and (v_cod_proj_financ_excec = ''
            or   substring(v_cod_proj_financ_excec,1,length(estrut_ctbl_movto_analit.cod_proj_financ)) = fill(chr(46), length(estrut_ctbl_movto_analit.cod_proj_financ))) 
            and  v_cod_proj_financ_inic <> v_cod_proj_financ_final 
            then do:
                /* ** SE O PAI DO PROJETO SELECIONADO ESTIVER DENTRO DA FAIXA DESCONSIDERA O PROJETO ***/
                IF  CAN-find(first estrut_proj_financ
                    where estrut_proj_financ.cod_proj_financ_FILHO = v_cod_proj_financ
                    and   estrut_proj_financ.cod_proj_financ_pai  >= v_cod_proj_financ_inic
                    and   estrut_proj_financ.cod_proj_financ_pai  <= v_cod_proj_financ_final
                    and   estrut_proj_financ.cod_proj_financ_pai  <> ""
                    and   estrut_proj_financ.cod_proj_financ_pai  <> fill("0",length(v_cod_proj_financ))) then do:
                    return.
                end.
            end.

            /* ** MELHORIA DE PERFORMANCE PRA UNIDADE DE NEGàCIO ***/
            if   lookup("Unidade Neg¢cio" /*l_unidade_negocio*/  ,v_cod_chave,chr(10)) = 0
            and  v_cod_unid_negoc_inic <> v_cod_unid_negoc_final 
            then do:
                /* ** SE O PAI DA UNIDADE DE NEGàCIO SELECIONADO ESTIVER DENTRO DA FAIXA DESCONSIDERA A UNIDADE DE NEGàCIO ***/
                if can-find(first estrut_unid_negoc
                    where estrut_unid_negoc.cod_unid_negoc_FILHO = v_cod_unid_negoc
                    and   estrut_unid_negoc.cod_unid_negoc_pai  >= v_cod_unid_negoc_inic
                    and   estrut_unid_negoc.cod_unid_negoc_pai  <= v_cod_unid_negoc_final
                    and   estrut_unid_negoc.cod_unid_negoc_pai  <> ""
                    and   estrut_unid_negoc.cod_unid_negoc_pai  <> "000") then do:
                    return.
                end.
            end.

            /* ** SE FOR DEMONSTRATIVO CONTµBIL, CRIA A LINHA A SER MOSTRADA NA CONSULTA ***/
            if   v_num_seq_demonst_ctbl   <> 0
            and  v_num_seq_compos_demonst <> 0 
            and (lookup("Cont bil" /*l_contabil*/ , v_ind_espec_sdo_tot, chr(59)) <> 0
            or   lookup("Or‡amento" /*l_orcamento*/ , v_ind_espec_sdo_tot, chr(59)) <> 0) then do:

                assign v_cod_chave_1  = ""
                       v_cod_chave_2  = ""
                       v_cod_chave_3  = ""
                       v_cod_chave_4  = ""
                       v_cod_chave_5  = ""
                       v_cod_chave_6  = ""
                       v_log_cta_sint = no.
                do v_num_count_2 = 1 to (num-entries(v_cod_chave, chr(10)) - 1):
                    if entry(v_num_count_2,v_cod_chave, chr(10)) = "Conta Cont bil" /*l_conta_contabil*/  then do:
                        if v_cod_chave_1 = "" then
                            assign v_cod_chave_1 = v_cod_cta_ctbl.
                        else
                        if v_cod_chave_2 = "" then
                            assign v_cod_chave_2 = v_cod_cta_ctbl.
                        else
                        if v_cod_chave_3 = "" then
                            assign v_cod_chave_3 = v_cod_cta_ctbl.
                        else
                        if v_cod_chave_4 = "" then
                            assign v_cod_chave_4 = v_cod_cta_ctbl.
                        else
                        if v_cod_chave_5 = "" then
                            assign v_cod_chave_5 = v_cod_cta_ctbl.
                        else
                        if v_cod_chave_6 = "" then
                            assign v_cod_chave_6 = v_cod_cta_ctbl.

                        if not avail cta_ctbl then
                            find cta_ctbl
                               where cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                               and   cta_ctbl.cod_cta_ctbl       = v_cod_cta_ctbl
                               no-lock no-error.

                        if  avail cta_ctbl
                        and v_ind_espec_cta = "Todas" /*l_todas*/ 
                        and cta_ctbl.ind_espec_cta_ctbl = "Sint‚tica" /*l_sintetica*/  then
                            assign v_log_cta_sint = yes.

                    end.
                    if entry(v_num_count_2,v_cod_chave, chr(10)) = "Centro de Custo" /*l_centro_de_custo*/  then do:
                        if v_cod_chave_1 = "" then
                            assign v_cod_chave_1 = v_cod_ccusto.
                        else
                        if v_cod_chave_2 = "" then
                            assign v_cod_chave_2 = v_cod_ccusto.
                        else
                        if v_cod_chave_3 = "" then
                            assign v_cod_chave_3 = v_cod_ccusto.
                        else
                        if v_cod_chave_4 = "" then
                            assign v_cod_chave_4 = v_cod_ccusto.
                        else
                        if v_cod_chave_5 = "" then
                            assign v_cod_chave_5 = v_cod_ccusto.
                        else
                        if v_cod_chave_6 = "" then
                            assign v_cod_chave_6 = v_cod_ccusto.
                    end.
                    if entry(v_num_count_2,v_cod_chave, chr(10)) = "Estabelecimento" /*l_estabelecimento*/  then do:
                        if v_cod_chave_1 = "" then
                            assign v_cod_chave_1 = v_cod_estab.
                        else
                        if v_cod_chave_2 = "" then
                            assign v_cod_chave_2 = v_cod_estab.
                        else
                        if v_cod_chave_3 = "" then
                            assign v_cod_chave_3 = v_cod_estab.
                        else
                        if v_cod_chave_4 = "" then
                            assign v_cod_chave_4 = v_cod_estab.
                        else
                        if v_cod_chave_5 = "" then
                            assign v_cod_chave_5 = v_cod_estab.
                        else
                        if v_cod_chave_6 = "" then
                            assign v_cod_chave_6 = v_cod_estab.
                    end.
                    if entry(v_num_count_2,v_cod_chave, chr(10)) = "Unidade Neg¢cio" /*l_unidade_negocio*/  then do:
                        if v_cod_chave_1 = "" then
                            assign v_cod_chave_1 = v_cod_unid_negoc.
                        else
                        if v_cod_chave_2 = "" then
                            assign v_cod_chave_2 = v_cod_unid_negoc.
                        else
                        if v_cod_chave_3 = "" then
                            assign v_cod_chave_3 = v_cod_unid_negoc.
                        else
                        if v_cod_chave_4 = "" then
                            assign v_cod_chave_4 = v_cod_unid_negoc.
                        else
                        if v_cod_chave_5 = "" then
                            assign v_cod_chave_5 = v_cod_unid_negoc.
                        else
                        if v_cod_chave_6 = "" then
                            assign v_cod_chave_6 = v_cod_unid_negoc.
                    end.
                    if entry(v_num_count_2,v_cod_chave, chr(10)) = "Projeto" /*l_projeto*/  then do:
                        if v_cod_chave_1 = "" then
                            assign v_cod_chave_1 = v_cod_proj_financ.
                        else
                        if v_cod_chave_2 = "" then
                            assign v_cod_chave_2 = v_cod_proj_financ.
                        else
                        if v_cod_chave_3 = "" then
                            assign v_cod_chave_3 = v_cod_proj_financ.
                        else
                        if v_cod_chave_4 = "" then
                            assign v_cod_chave_4 = v_cod_proj_financ.
                        else
                        if v_cod_chave_5 = "" then
                            assign v_cod_chave_5 = v_cod_proj_financ.
                        else
                        if v_cod_chave_6 = "" then
                            assign v_cod_chave_6 = v_cod_proj_financ.
                    end.
                end.

                find tt_item_demonst_ctbl_video
                   where tt_item_demonst_ctbl_video.ttv_val_seq_demonst_ctbl   = v_num_seq_demonst_ctbl
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_1            = v_cod_chave_1
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_2            = v_cod_chave_2
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_3            = v_cod_chave_3
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_4            = v_cod_chave_4
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_5            = v_cod_chave_5
                     and tt_item_demonst_ctbl_video.ttv_cod_chave_6            = v_cod_chave_6
                     no-lock no-error.
                if not avail tt_item_demonst_ctbl_video then do:
                    create tt_item_demonst_ctbl_video. 
                    assign tt_item_demonst_ctbl_video.ttv_val_seq_demonst_ctbl        = v_num_seq_demonst_ctbl
                           tt_item_demonst_ctbl_video.ttv_cod_chave_1                 = v_cod_chave_1
                           tt_item_demonst_ctbl_video.ttv_cod_chave_2                 = v_cod_chave_2
                           tt_item_demonst_ctbl_video.ttv_cod_chave_3                 = v_cod_chave_3
                           tt_item_demonst_ctbl_video.ttv_cod_chave_4                 = v_cod_chave_4
                           tt_item_demonst_ctbl_video.ttv_cod_chave_5                 = v_cod_chave_5
                           tt_item_demonst_ctbl_video.ttv_cod_chave_6                 = v_cod_chave_6
                           tt_item_demonst_ctbl_video.ttv_cod_identif_campo           = v_cod_chave
                           tt_item_demonst_ctbl_video.tta_ind_orig_val_col_demonst    = ""
                           tt_item_demonst_ctbl_video.ttv_log_cta_sint                = v_log_cta_sint
                           tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video = recid(tt_item_demonst_ctbl_video)
                           tt_item_demonst_ctbl_video.tta_cod_plano_ccusto            = estrut_ctbl_movto_analit.cod_plano_ccusto.
                end.
            end.

            find plano_cta_ctbl no-lock
                where plano_cta_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl no-error.
            if avail plano_cta_ctbl then
                assign v_num_tam_cta = 25000 / length(plano_cta_ctbl.cod_format_cta_ctbl).

            if avail plano_ccusto then
                assign v_num_tam_ccusto = 25000 / length(plano_ccusto.cod_format_ccusto).

            assign v_num_cont_cta         = 0
                   v_num_cont_unid_negoc  = 0
                   v_num_cont_proj_financ = 0
                   v_num_cont_ccusto_aux  = 0.

            if v_log_busca_sdo_nova_logic then do:
                find first tt_lista_inform
                  where tt_lista_inform.ttv_cod_tip_lista = "Estabelecimento" /*l_estabelecimento*/ 
                  and   tt_lista_inform.ttv_cod_inform    = v_cod_estab
                  no-lock no-error.
                if not avail tt_lista_inform then do:
                    create tt_lista_inform.
                    assign tt_lista_inform.ttv_cod_tip_lista = "Estabelecimento" /*l_estabelecimento*/ 
                           tt_lista_inform.ttv_cod_inform    = v_cod_estab
                           tt_lista_inform.ttv_cod_fill      = v_cod_estab
                           tt_lista_inform.ttv_log_selec    = yes.
                end.
                else
                    assign tt_lista_inform.ttv_log_selec  = yes.
            end.

            /* ** ESTRUTURA CONTA CONTµBIL ***/
            find first tt_lista_inform
              where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
              and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl
              no-lock no-error.
            if not avail tt_lista_inform then do:
                run pi_localiza_cta_ctbl_analitica_demonst (Input v_cod_cta_ctbl,
                                                            Input '') /*pi_localiza_cta_ctbl_analitica_demonst*/.
            end.
            else do:
                for each tt_lista_inform
                   where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                   and   tt_lista_inform.ttv_cod_inform    = v_cod_plano_cta_ctbl + chr(10) + v_cod_cta_ctbl:
                    assign tt_lista_inform.ttv_log_selec  = yes.
                end.
            end.

            /* ** ESTRUTURA UNIDADE NEGàCIO ***/
            find first tt_lista_inform
              where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
              and   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc
              no-lock no-error.
            if not avail tt_lista_inform then do:
                run pi_localiza_unid_negoc_analitico (Input v_cod_unid_negoc,
                                                      Input '') /*pi_localiza_unid_negoc_analitico*/.
            end.
            else do:
                for each tt_lista_inform
                   where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
                   and   tt_lista_inform.ttv_cod_inform    = v_cod_unid_negoc:
                    assign tt_lista_inform.ttv_log_selec  = yes.
                end.
            end.

            if lookup("Cont bil" /*l_contabil*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 
            or lookup("Or‡amento" /*l_orcamento*/ , v_ind_espec_sdo_tot, chr(59)) <> 0 then do:

                /* ** ESTRUTURA PROJETO ***/
                find first tt_lista_inform
                  where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                  and   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ
                  no-lock no-error.
                if not avail tt_lista_inform then do:
                    run pi_localiza_proj_financ_analitico_demonst (Input v_cod_proj_financ,
                                                                   Input '') /*pi_localiza_proj_financ_analitico_demonst*/.
                end.
                else do:
                    for each tt_lista_inform
                       where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                       and   tt_lista_inform.ttv_cod_inform    = v_cod_proj_financ:
                        assign tt_lista_inform.ttv_log_selec  = yes.
                    end.
                end.

                /* ** ESTRUTURA CENTRO DE CUSTO ***/
                find first tt_lista_inform
                  where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                  and   tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto
                  no-lock no-error.
                if not avail tt_lista_inform then do:
                    run pi_localiza_ccusto_analitico_demonst (Input v_cod_ccusto,
                                                              Input '') /*pi_localiza_ccusto_analitico_demonst*/.
                end.
                else do:
                    for each tt_lista_inform
                       where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                       and   tt_lista_inform.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_empresa + chr(10) + v_cod_plano_ccusto + chr(10) + v_cod_ccusto:
                        if (v_log_espec_sdo_ccusto = no 
                        and tt_lista_inform.ttv_cod_fill = v_cod_ccusto)
                        or v_log_espec_sdo_ccusto = yes then
                            assign tt_lista_inform.ttv_log_selec  = yes.
                    end.
                end.
            end. 

            if  v_log_funcao_dw_demonst
            then do:
                find first b_compos_demonst_ctbl no-lock
                    where b_compos_demonst_ctbl.cod_demonst_ctbl       = v_cod_demonst_ctbl
                      and b_compos_demonst_ctbl.num_seq_demonst_ctbl   = v_num_seq_demonst_ctbl
                      and b_compos_demonst_ctbl.num_seq_compos_demonst = v_num_seq_compos_demonst no-error.
                if avail b_compos_demonst_ctbl then do:
                    &if '{&emsuni_version}' >= "5.07" &then
                        assign v_ind_tip_ccusto_consid = b_compos_demonst_ctbl.ind_tip_ccusto_consid.
                    &else
                        assign v_ind_tip_ccusto_consid = GetEntryField(3,b_compos_demonst_ctbl.cod_livre_1,chr(10)).
                    &endif
                    if v_ind_tip_ccusto_consid <> "Ambos" /*l_ambos*/  then do:
                        for each tt_lista_inform
                            where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                              and tt_lista_inform.ttv_log_selec     = yes:
                            find first ccusto no-lock
                                where ccusto.cod_empresa      = tt_empresa_leitura_sdo.tta_cod_empresa
                                  and ccusto.cod_plano_ccusto = v_cod_plano_ccusto
                                  and ccusto.cod_ccusto       = tt_lista_inform.ttv_cod_fill no-error.
                            if avail ccusto then do:
                                &if '{&emsuni_version}' >= "5.07" &then
                                    assign v_ind_tip_ccusto  = ccusto.ind_tip_ccusto.
                                &else
                                    assign v_ind_tip_ccusto = GetEntryField(1,ccusto.cod_livre_1,chr(10)).
                                &endif
                                if v_ind_tip_ccusto_consid <> v_ind_tip_ccusto then
                                    assign tt_lista_inform.ttv_log_selec = no.
                            end.
                        end.
                    end.
                end.
            end /* if */.

            /* ------------------------------------- EPC ---------------------------------------*/

            /* Begin_Include: i_pusca_saldo_epc */
                   /* Esta epc visa alterar o conteœdo da temp-table tt_lista_inform */
                    if  v_nom_prog_dpc  <> ''
                    or  v_nom_prog_upc  <> ''
                    or  v_nom_prog_appc <> ''
                    then do:
                        if v_cod_demonst_ctbl <> "" then do:

                            for each tt_epc:
                                delete tt_epc.
                            end.

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'DEMONSTRATIVO'
                                   tt_epc.val_parameter = v_cod_demonst_ctbl.

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'SEQUENCIA ITEM DEMONSTRATIVO'
                                   tt_epc.val_parameter = STRING(v_num_seq_demonst_ctbl).

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'SEQUENCIA COMPOSICAO'
                                   tt_epc.val_parameter = STRING(v_num_seq_compos_demonst).

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'EMPRESA'
                                   tt_epc.val_parameter = tt_empresa_leitura_sdo.tta_cod_empresa.

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'PLANO CCUSTO'
                                   tt_epc.val_parameter = v_cod_plano_ccusto.

                            create tt_epc.
                            assign tt_epc.cod_event     = 'ALTERA SELECAO'
                                   tt_epc.cod_param     = 'HANDLE tt_lista_inform'
                                   tt_epc.val_parameter = STRING(TEMP-TABLE tt_lista_inform:DEFAULT-BUFFER-HANDLE).

                            if v_nom_prog_dpc <> "" then
                                run value(v_nom_prog_dpc) (input 'ALTERA SELECAO', input-output table tt_epc).
                            else if v_nom_prog_upc <> "" then
                                run value(v_nom_prog_upc) (input 'ALTERA SELECAO', input-output table tt_epc).
                            else if v_nom_prog_appc <> "" then
                                run value(v_nom_prog_appc) (input 'ALTERA SELECAO', input-output table tt_epc).

                            for each tt_epc:
                                delete tt_epc.
                            end.
                        end.
                    end /* if */.

            /* End_Include: i_pusca_saldo_epc */

            /* ----------------------------------- FIM EPC -------------------------------------*/

        end.

        if v_log_busca_sdo_nova_logic = no 
        or v_ind_espec_sdo = "Consolida‡Æo" /*l_consolidacao*/ 
        or v_cdn_tot_orcto > 1 then do:
            if v_ind_espec_sdo = "Cont bil" /*l_contabil*/  then
                run pi_leitura_sdo_ctbl_demonst /*pi_leitura_sdo_ctbl_demonst*/.
            else if v_ind_espec_sdo = "Or‡amento" /*l_orcamento*/  then
                run pi_leitura_sdo_orcto /*pi_leitura_sdo_orcto*/.
            else if v_ind_espec_sdo = "Consolida‡Æo" /*l_consolidacao*/  then 
                run pi_leitura_sdo_consolid /*pi_leitura_sdo_consolid*/.
        end.
    end.
END PROCEDURE. /* pi_busca_saldo */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_cenar_ctbl_fisc_demonst
** Descricao.............: pi_retornar_cenar_ctbl_fisc_demonst
** Criado por............: src531
** Criado em.............: 30/08/2002 12:59:31
** Alterado por..........: src531
** Alterado em...........: 02/09/2002 08:28:34
*****************************************************************************/
PROCEDURE pi_retornar_cenar_ctbl_fisc_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_dat_refer_ent
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_cenar_ctbl
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find first utiliz_cenar_ctbl no-lock
         where utiliz_cenar_ctbl.cod_empresa = p_cod_empresa
           and utiliz_cenar_ctbl.log_cenar_fisc = yes no-error.
    if  avail utiliz_cenar_ctbl
    then do:
        if  p_dat_refer_ent = ? or (utiliz_cenar_ctbl.dat_inic_valid <= p_dat_refer_ent and
                                    utiliz_cenar_ctbl.dat_fim_valid >= p_dat_refer_ent)
        then do:
            assign p_cod_cenar_ctbl = utiliz_cenar_ctbl.cod_cenar_ctbl.
        end /* if */.
        else do:
            assign p_cod_cenar_ctbl = "".
        end /* else */.
    end /* if */.
    else do:
        assign p_cod_cenar_ctbl = "".
    end /* else */.

END PROCEDURE. /* pi_retornar_cenar_ctbl_fisc_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_plano_cta_ctbl_prim_demonst
** Descricao.............: pi_retornar_plano_cta_ctbl_prim_demonst
** Criado por............: src531
** Criado em.............: 30/08/2002 13:05:05
** Alterado por..........: src531
** Alterado em...........: 30/08/2002 13:07:49
*****************************************************************************/
PROCEDURE pi_retornar_plano_cta_ctbl_prim_demonst:

    /************************ Parameter Definition Begin ************************/

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
    def Input param p_dat_refer_ent
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_plano_cta_ctbl
        as character
        format "x(8)"
        no-undo.
    def output param p_log_plano_cta_ctbl_uni
        as logical
        format "Sim/NÆo"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    calcula_block:
    for each plano_cta_unid_organ no-lock
     where plano_cta_unid_organ.cod_unid_organ = p_cod_unid_organ
       and plano_cta_unid_organ.ind_tip_plano_cta_ctbl = "Prim rio" /*l_primario*/  /* cl_retorna_plano_cta_ctbl_prim of plano_cta_unid_organ*/:
        if  p_dat_refer_ent = ?
        or (plano_cta_unid_organ.dat_inic_valid <= p_dat_refer_ent
        and plano_cta_unid_organ.dat_fim_valid >= p_dat_refer_ent)
        then do:
            assign v_cod_return         = v_cod_return + "," + plano_cta_unid_organ.cod_plano_cta_ctbl
                   p_cod_plano_cta_ctbl = plano_cta_unid_organ.cod_plano_cta_ctbl.
        end /* if */.
    end /* for calcula_block */.

    if  num-entries(v_cod_return) = 2
    then do:
        assign p_log_plano_cta_ctbl_uni = yes.
    end /* if */.
    else do:
        assign p_log_plano_cta_ctbl_uni = no.
    end /* else */.

END PROCEDURE. /* pi_retornar_plano_cta_ctbl_prim_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_cria_tt_estrut_unid_organ_demonst
** Descricao.............: pi_cria_tt_estrut_unid_organ_demonst
** Criado por............: src531
** Criado em.............: 30/08/2002 13:18:11
** Alterado por..........: fut12209
** Alterado em...........: 17/12/2004 16:59:12
*****************************************************************************/
PROCEDURE pi_cria_tt_estrut_unid_organ_demonst:

    /************************ Parameter Definition Begin ************************/

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


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsuni_version}" >= "1.00" &then
    def buffer b_estrut_unid_organ
        for ems5.estrut_unid_organ.
    &endif


    /*************************** Buffer Definition End **************************/

    estrut_block:
    for each b_estrut_unid_organ no-lock
           where b_estrut_unid_organ.cod_unid_organ_pai = p_cod_unid_organ:
            if  not can-find(first tt_estrut_unid_organ where
              tt_estrut_unid_organ.cod_unid_organ_pai = v_cod_unid_organ and
              tt_estrut_unid_organ.cod_unid_organ_filho= b_estrut_unid_organ.cod_unid_organ_filho)
           then do:
              create tt_estrut_unid_organ.
              assign tt_estrut_unid_organ.cod_unid_organ_pai = v_cod_unid_organ
                     tt_estrut_unid_organ.num_seq_estrut_unid_organ = v_num_seq
                     tt_estrut_unid_organ.cod_unid_organ_filho = b_estrut_unid_organ.cod_unid_organ_filho.
              assign v_num_seq = v_num_seq + 1.
           end /* if */.
    end /* for estrut_block */.

    find first tt_estrut_unid_organ no-lock no-error.
    if not avail tt_estrut_unid_organ then do:
        create tt_estrut_unid_organ.
        assign tt_estrut_unid_organ.cod_unid_organ_pai = v_cod_unid_organ
               tt_estrut_unid_organ.num_seq_estrut_unid_organ = v_num_seq
               tt_estrut_unid_organ.cod_unid_organ_filho = v_cod_unid_organ.
    end.

END PROCEDURE. /* pi_cria_tt_estrut_unid_organ_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_segur_ccusto_demonst
** Descricao.............: pi_verifica_segur_ccusto_demonst
** Criado por............: src531
** Criado em.............: 30/08/2002 13:21:00
** Alterado por..........: src531
** Alterado em...........: 30/08/2002 13:22:31
*****************************************************************************/
PROCEDURE pi_verifica_segur_ccusto_demonst:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_plano_ccusto
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_ccusto
        as Character
        format "x(11)"
        no-undo.
    def output param p_log_return
        as logical
        format "Sim/NÆo"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_log_return = no.
    /* default ² n’o ter permiss’o */

    if can-find (first segur_ccusto
       where segur_ccusto.cod_empresa      = p_cod_empresa
         and segur_ccusto.cod_plano_ccusto = p_cod_plano_ccusto
         and segur_ccusto.cod_ccusto       = p_cod_ccusto
         and segur_ccusto.cod_grp_usuar    = "*")
    then
        assign p_log_return = yes.
    else do:
        loop_block:
        for each usuar_grp_usuar no-lock
            where usuar_grp_usuar.cod_usuario = v_cod_usuar_corren
            &if '{&emsbas_version}' >= '5.01' &then
               use-index srgrpsr_usuario
            &endif:
            find first segur_ccusto no-lock
                 where segur_ccusto.cod_empresa = p_cod_empresa
                   and segur_ccusto.cod_plano_ccusto = p_cod_plano_ccusto
                   and segur_ccusto.cod_ccusto  = p_cod_ccusto
                   and segur_ccusto.cod_grp_usuar = usuar_grp_usuar.cod_grp_usuar no-error.
            if  avail segur_ccusto
            then do:
                assign p_log_return = yes.
                leave loop_block.
            end /* if */.
        end /* for loop_block */.
    end /* else */.

END PROCEDURE. /* pi_verifica_segur_ccusto_demonst */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_consolid
** Descricao.............: pi_leitura_sdo_consolid
** Criado por............: bre17108
** Criado em.............: 09/08/2002 15:31:41
** Alterado por..........: bre17108
** Alterado em...........: 09/12/2003 09:12:44
*****************************************************************************/
PROCEDURE pi_leitura_sdo_consolid:

    /* --- Se foi informado Conta / Projeto / Centro de Custo ---*/
    empresa:
    for each tt_estrut_unid_organ no-lock
      where tt_estrut_unid_organ.cod_unid_organ_pai = tt_empresa_leitura_sdo.tta_cod_empresa:
       if tt_estrut_unid_organ.cod_unid_organ_filho < v_cod_unid_organ_orig_ini
       or tt_estrut_unid_organ.cod_unid_organ_filho > v_cod_unid_organ_orig_fim THEN next.
       /* Demonstrativo Contabil */
       if  v_num_seq_demonst_ctbl   <> 0 and v_num_seq_compos_demonst <> 0 then do:
           assign v_cod_chave_1 = "" v_cod_chave_2 = "" v_cod_chave_3 = ""
                  v_cod_chave_4 = "" v_cod_chave_5 = "" v_cod_chave_6 = "".
           do v_num_count_2 = 1 to num-entries(v_cod_chave, chr(10)):
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "Conta Cont bil" /*l_conta_contabil*/  then do:
                   if v_cod_chave_1 = "" THEN assign v_cod_chave_1 = v_cod_cta_ctbl.
                   ELSE if v_cod_chave_2 = "" then assign v_cod_chave_2 = v_cod_cta_ctbl.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = v_cod_cta_ctbl.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = v_cod_cta_ctbl.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = v_cod_cta_ctbl.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = v_cod_cta_ctbl.
               end.
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "Centro de Custo" /*l_centro_de_custo*/  then do:
                   if v_cod_chave_1 = "" then assign v_cod_chave_1 = v_cod_ccusto.
                   else if v_cod_chave_2 = "" then assign v_cod_chave_2 = v_cod_ccusto.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = v_cod_ccusto.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = v_cod_ccusto.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = v_cod_ccusto.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = v_cod_ccusto.
               end.
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "Estabelecimento" /*l_estabelecimento*/  then do:
                   if v_cod_chave_1 = "" THEN assign v_cod_chave_1 = v_cod_estab.
                   else if v_cod_chave_2 = "" then assign v_cod_chave_2 = v_cod_estab.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = v_cod_estab.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = v_cod_estab.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = v_cod_estab.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = v_cod_estab.
               end.
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "Unidade Neg¢cio" /*l_unidade_negocio*/  then do:
                   if v_cod_chave_1 = "" then assign v_cod_chave_1 = v_cod_unid_negoc.
                   else if v_cod_chave_2 = "" then assign v_cod_chave_2 = v_cod_unid_negoc.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = v_cod_unid_negoc.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = v_cod_unid_negoc.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = v_cod_unid_negoc.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = v_cod_unid_negoc.
               end.
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "Projeto" /*l_projeto*/  then do:
                   if v_cod_chave_1 = "" then assign v_cod_chave_1 = v_cod_proj_financ.
                   else if v_cod_chave_2 = "" then assign v_cod_chave_2 = v_cod_proj_financ.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = v_cod_proj_financ.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = v_cod_proj_financ.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = v_cod_proj_financ.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = v_cod_proj_financ.
               end.
               if entry(v_num_count_2,v_cod_chave, chr(10)) = "UO Origem" /*l_uo_origem*/  then do:
                   if v_cod_chave_1 = "" then assign v_cod_chave_1 = tt_estrut_unid_organ.cod_unid_organ_filho.
                   else if v_cod_chave_2 = "" then assign v_cod_chave_2 = tt_estrut_unid_organ.cod_unid_organ_filho.
                   else if v_cod_chave_3 = "" then assign v_cod_chave_3 = tt_estrut_unid_organ.cod_unid_organ_filho.
                   else if v_cod_chave_4 = "" then assign v_cod_chave_4 = tt_estrut_unid_organ.cod_unid_organ_filho.
                   else if v_cod_chave_5 = "" then assign v_cod_chave_5 = tt_estrut_unid_organ.cod_unid_organ_filho.
                   else if v_cod_chave_6 = "" then assign v_cod_chave_6 = tt_estrut_unid_organ.cod_unid_organ_filho.
               end.
           end.
           find tt_item_demonst_ctbl_video
              where tt_item_demonst_ctbl_video.ttv_val_seq_demonst_ctbl = v_num_seq_demonst_ctbl
              and tt_item_demonst_ctbl_video.ttv_cod_chave_1 = v_cod_chave_1
              and tt_item_demonst_ctbl_video.ttv_cod_chave_2 = v_cod_chave_2
              and tt_item_demonst_ctbl_video.ttv_cod_chave_3 = v_cod_chave_3
              and tt_item_demonst_ctbl_video.ttv_cod_chave_4 = v_cod_chave_4
              and tt_item_demonst_ctbl_video.ttv_cod_chave_5 = v_cod_chave_5
              and tt_item_demonst_ctbl_video.ttv_cod_chave_6 = v_cod_chave_6 no-lock no-error.
           if not avail tt_item_demonst_ctbl_video then do:
               create tt_item_demonst_ctbl_video. 
               assign tt_item_demonst_ctbl_video.ttv_val_seq_demonst_ctbl = v_num_seq_demonst_ctbl
                      tt_item_demonst_ctbl_video.ttv_cod_chave_1 = v_cod_chave_1
                      tt_item_demonst_ctbl_video.ttv_cod_chave_2 = v_cod_chave_2
                      tt_item_demonst_ctbl_video.ttv_cod_chave_3 = v_cod_chave_3
                      tt_item_demonst_ctbl_video.ttv_cod_chave_4 = v_cod_chave_4
                      tt_item_demonst_ctbl_video.ttv_cod_chave_5 = v_cod_chave_5
                      tt_item_demonst_ctbl_video.ttv_cod_chave_6 = v_cod_chave_6
                      tt_item_demonst_ctbl_video.ttv_cod_identif_campo = v_cod_chave
                      tt_item_demonst_ctbl_video.tta_ind_orig_val_col_demonst    = ""
                      tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video = recid(tt_item_demonst_ctbl_video).
           end.
       end.

       for each btt_lista_inform_un
         where btt_lista_inform_un.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/  
         and   btt_lista_inform_un.ttv_cod_inform    = estrut_ctbl_movto_analit.cod_unid_negoc
         and   btt_lista_inform_un.ttv_log_selec    = yes:
           assign v_cod_unid_negoc_analit  = btt_lista_inform_un.ttv_cod_fill.
           for each btt_lista_inform_conta
             where btt_lista_inform_conta.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
             and   btt_lista_inform_conta.ttv_cod_inform    = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl + chr(10) + estrut_ctbl_movto_analit.cod_cta_ctbl
             and   btt_lista_inform_conta.ttv_log_selec    = yes:
               assign v_cod_cta_ctbl_analit = btt_lista_inform_conta.ttv_cod_fill.
               if can-find(first b_estrut_ctbl_movto_analit use-index estrtctb_unid_negoc
                    where b_estrut_ctbl_movto_analit.cod_empresa = tt_empresa_leitura_sdo.tta_cod_empresa
                    and b_estrut_ctbl_movto_analit.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                    and b_estrut_ctbl_movto_analit.cod_cta_ctbl  = v_cod_cta_ctbl_analit 
                    and b_estrut_ctbl_movto_analit.cod_unid_negoc = v_cod_unid_negoc_analit) then do:
                    /* Busca os saldos em cada uma das datas passadas para o programa */
                    do v_num_count_1 = 1 to v_cdn_tot_dat:
                       assign v_dat_sdo_cta_inic = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10)))
                              v_dat_sdo_cta_fim  = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10)))
                              v_cod_exerc_ctbl   = trim(entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10)))
                              v_num_period_ctbl  = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)))
                              v_num_seq_1        = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))).
                       find first tt_retorna_sdo_ctbl_demonst
                            where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa  = tt_empresa_leitura_sdo.tta_cod_empresa
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ  = v_cod_finalid_econ
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl = v_cod_cta_ctbl_analit
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto  = ""
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto   = ""
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_estab    = ""
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc = v_cod_unid_negoc_analit
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ = ""
                            and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl  = v_dat_sdo_cta_fim
                            and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo = v_ind_espec_sdo
                            and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                            and tt_retorna_sdo_ctbl_demonst.tta_num_seq = v_num_seq_1 no-error. 
                       if avail tt_retorna_sdo_ctbl_demonst then do:
                           if avail tt_item_demonst_ctbl_video then do:
                               find tt_relacto_item_retorna 
                                  where tt_relacto_item_retorna.tta_num_seq    = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                  and tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                  and tt_relacto_item_retorna.ttv_rec_ret  = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl no-error.
                               if not avail tt_relacto_item_retorna then do:
                                   create tt_relacto_item_retorna.
                                   assign tt_relacto_item_retorna.tta_num_seq = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                                          tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                                          tt_relacto_item_retorna.ttv_rec_ret = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                               end.
                           end.
                           next.
                       end.
                       for each tt_log_elim_intercomp:

                           /* Begin_Include: i_pi_leitura_sdo_consolid */
                           case v_cod_leitura:
                              when "for each" /*l_for_each*/  then do:
                                  case v_cod_condicao: 
                                      when "Igual" /*l_igual*/  then do:
                                          find sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                          if avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "menor ou igual" /*l_menor_igual*/  then do:
                                          for each sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_ctbl_conta_projeto_ccusto of sdo_ctbl*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl <= v_dat_sdo_cta_fim:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "Menor" /*l_menor*/  then do:
                                          for each sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_ctbl_conta_projeto_ccusto of sdo_ctbl*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl < v_dat_sdo_cta_fim:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "Maior ou Igual e Menor ou Igual" /*l_maior_igual_menor_igual*/  then do:
                                          for each sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               AND sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl >= v_dat_sdo_cta_inic
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl <= v_dat_sdo_cta_fim:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                  end.
                              end.
                              when "find last" then do:
                                  case v_cod_condicao: 
                                      when "Igual" /*l_igual*/  then do:
                                          find sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                           if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "menor ou igual" /*l_menor_igual*/  then do:
                                          find last sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl <= v_dat_sdo_cta_fim no-error.
                                          if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "Menor" /*l_menor*/  then do:
                                          find last sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl < v_dat_sdo_cta_fim no-error.
                                          if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                  end.
                              end.
                              when "find first" then do:
                                  case v_cod_condicao: 
                                      when "Igual" /*l_igual*/  then do:
                                          find sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl = v_dat_sdo_cta_fim no-error.
                                          if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "menor ou igual" /*l_menor_igual*/  then do:
                                          find first sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl <= v_dat_sdo_cta_fim no-error.
                                          if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                      when "Menor" /*l_menor*/  then do:
                                          find first sdo_cta_ctbl_consolid no-lock
                                               where sdo_cta_ctbl_consolid.cod_unid_organ = tt_empresa_leitura_sdo.tta_cod_empresa
                                               and sdo_cta_ctbl_consolid.cod_unid_organ_orig = tt_estrut_unid_organ.cod_unid_organ_filho
                                               and sdo_cta_ctbl_consolid.cod_finalid_econ = v_cod_finalid_econ
                                               and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                                               and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                                               and sdo_cta_ctbl_consolid.cod_cenar_ctbl = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                                               and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit /* cl_sdo_cta_ctbl_consolid_conta_projeto_ccusto of sdo_cta_ctbl_consolid*/
                                               and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                                               and sdo_cta_ctbl_consolid.dat_sdo_ctbl < v_dat_sdo_cta_fim no-error.
                                          if  avail sdo_cta_ctbl_consolid then do:
                                              run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                                                    Input tt_log_elim_intercomp.ttv_log_simul,
                                                                                    Input no,
                                                                                    Input ?) /*pi_leitura_sdo_consolid_grava_tt*/.
                                          end.
                                      end.
                                  end.
                              end.
                           end.
                           /* End_Include: i_pi_leitura_sdo_consolid */

                       end.
                   end.
               end.
           end.
       end.
    end.

END PROCEDURE. /* pi_leitura_sdo_consolid */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_consolid_more
** Descricao.............: pi_leitura_sdo_consolid_more
** Criado por............: its0068
** Criado em.............: 26/08/2005 08:47:31
** Alterado por..........: its0068
** Alterado em...........: 26/08/2005 08:56:14
*****************************************************************************/
PROCEDURE pi_leitura_sdo_consolid_more:

    /************************ Parameter Definition Begin ************************/

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
    def Input param p_cod_plano_cta_ctbl
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_cta_ctbl
        as character
        format "x(20)"
        no-undo.
    def Input param p_cod_unid_negoc
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_cenar_ctbl
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_sdo_ctbl
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_rec_ret_orig
        as recid
        format ">>>>>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* --- Se foi informado Conta / Projeto / Centro de Custo ---*/
    empresa:
    for each estrut_unid_organ no-lock
       where estrut_unid_organ.cod_unid_organ_pai = p_cod_unid_organ:
        assign v_cod_unid_negoc_analit = p_cod_unid_negoc
               v_cod_cta_ctbl_analit   = p_cod_cta_ctbl.
        find first tt_retorna_sdo_ctbl_demonst
             where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa  = p_cod_unid_organ
               and tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ  = p_cod_finalid_econ
               and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = p_cod_plano_cta_ctbl
               and tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl = v_cod_cta_ctbl_analit
               and tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto  = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto   = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl = p_cod_cenar_ctbl
               and tt_retorna_sdo_ctbl_demonst.tta_cod_estab    = ""
               and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc = v_cod_unid_negoc_analit
               and tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ = ""
               and tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl  = p_dat_sdo_ctbl
               and tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo = v_ind_espec_sdo
               and tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = estrut_unid_organ.cod_unid_organ_filho
               and tt_retorna_sdo_ctbl_demonst.tta_num_seq = v_num_seq_1 no-error. 
        if avail tt_retorna_sdo_ctbl_demonst then do:
            find tt_relacto_item_retorna_cons
               where tt_relacto_item_retorna_cons.tta_num_seq = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                 and tt_relacto_item_retorna_cons.ttv_rec_ret_orig = p_rec_ret_orig
                 and tt_relacto_item_retorna_cons.ttv_rec_ret_dest = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl no-error.
            if not avail tt_relacto_item_retorna_cons then do:
                create tt_relacto_item_retorna_cons.
                assign tt_relacto_item_retorna_cons.tta_num_seq  = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                       tt_relacto_item_retorna_cons.ttv_rec_ret_orig = p_rec_ret_orig
                       tt_relacto_item_retorna_cons.ttv_rec_ret_dest = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
            end.
            next.
        end.
        for each tt_log_elim_intercomp:
            find sdo_cta_ctbl_consolid no-lock
                 where sdo_cta_ctbl_consolid.cod_unid_organ = p_cod_unid_organ
                   and sdo_cta_ctbl_consolid.cod_unid_organ_orig = estrut_unid_organ.cod_unid_organ_filho
                   and sdo_cta_ctbl_consolid.cod_finalid_econ = p_cod_finalid_econ
                   and sdo_cta_ctbl_consolid.cod_plano_cta_ctbl = p_cod_plano_cta_ctbl
                   and sdo_cta_ctbl_consolid.cod_cta_ctbl = v_cod_cta_ctbl_analit
                   and sdo_cta_ctbl_consolid.cod_cenar_ctbl = p_cod_cenar_ctbl
                   and sdo_cta_ctbl_consolid.cod_unid_negoc = v_cod_unid_negoc_analit
                   and sdo_cta_ctbl_consolid.log_elimina_intercomp = tt_log_elim_intercomp.ttv_log_elimina_intercomp
                   and sdo_cta_ctbl_consolid.dat_sdo_ctbl = p_dat_sdo_ctbl no-error.
            if avail sdo_cta_ctbl_consolid then do:
                run pi_leitura_sdo_consolid_grava_tt (Input v_num_seq_1,
                                                      Input tt_log_elim_intercomp.ttv_log_simul,
                                                      Input yes,
                                                      Input p_rec_ret_orig) /*pi_leitura_sdo_consolid_grava_tt*/.
            end.
        end.
    end.
END PROCEDURE. /* pi_leitura_sdo_consolid_more */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_valores_iniciais_prefer
** Descricao.............: pi_retornar_valores_iniciais_prefer
** Criado por............: src388
** Criado em.............: 11/06/2001 11:40:43
** Alterado por..........: fut35059
** Alterado em...........: 30/01/2006 14:29:47
*****************************************************************************/
PROCEDURE pi_retornar_valores_iniciais_prefer:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_format
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_campo
        as character
        format "x(25)"
        no-undo.
    def output param p_cod_initial
        as character
        format "x(8)"
        no-undo.
    def output param p_cod_final
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_count_proj                 as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_num_count_proj = 1
           v_cod_proj_financ_000 = ""
           v_cod_proj_financ_999 = ""
           p_cod_initial = ""
           p_cod_final = "".

    do while v_num_count_proj <= length(p_cod_format):
        if  substring(p_cod_format,v_num_count_proj,1) <> "-"
        and substring(p_cod_format,v_num_count_proj,1) <> "."
        then do:
            if  substring(p_cod_format,v_num_count_proj,1) = "9"
            then do:
                assign v_cod_proj_financ_000 = v_cod_proj_financ_000 + "0"
                       v_cod_proj_financ_999 = v_cod_proj_financ_999 + "9".
            end.
            else do:
                if  substring(p_cod_format,v_num_count_proj,1) = "x" /*l_x*/  
                then do:
                    if p_cod_campo <> "Projeto" /*l_projeto*/  then
                        assign v_cod_proj_financ_000 = v_cod_proj_financ_000 + "0".

                    assign v_cod_proj_financ_999 = v_cod_proj_financ_999 + "Z" /*l_z*/ .
                end.
            end.
        end.
        assign v_num_count_proj = v_num_count_proj + 1.
    end.

    assign p_cod_initial = v_cod_proj_financ_000
           p_cod_final   = v_cod_proj_financ_999.
END PROCEDURE. /* pi_retornar_valores_iniciais_prefer */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_orcto_more
** Descricao.............: pi_leitura_sdo_orcto_more
** Criado por............: Souza
** Criado em.............: 02/12/2002 09:50:49
** Alterado por..........: bre17108
** Alterado em...........: 09/11/2004 21:20:25
*****************************************************************************/
PROCEDURE pi_leitura_sdo_orcto_more:

    case v_cod_leitura:
        when "for each" /*l_for_each*/  then do:
            case v_cod_condicao: 
                when "Igual" /*l_igual*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                        find sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                           and sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                           and sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl 
                           and sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl  
                           and sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                           and sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                           and sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                           and sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                           and sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                           and sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                           and sdo_orcto_ctbl_bgc.cod_plano_ccusto    = v_cod_plano_ccusto
                           and sdo_orcto_ctbl_bgc.cod_ccusto          = v_cod_ccusto_analit
                           and sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                           and sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                           and sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl no-error.
                        if avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /*pi_leitura_sdo_orcto_grava_tt*/.
                       end.
                    end.
                    else do:
                        for each sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                             and sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                             and sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl 
                             and sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl  
                             and sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                             and sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                             and sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                             and sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                             and sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                             and sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                             and sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                             and sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                             and sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl:
                              run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /* pi_leitura_sdo_orcto_grava_tt*/.
                        end.
                    end.
                end.
                when "menor ou igual" /*l_menor_igual*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                        for each sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                            and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                            and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                            and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                            and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_ccusto    = v_cod_plano_ccusto
                            and  sdo_orcto_ctbl_bgc.cod_ccusto          = v_cod_ccusto_analit
                            and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                            and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                            and  sdo_orcto_ctbl_bgc.num_period_ctbl    <= v_num_period_ctbl:
                             run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /*pi_leitura_sdo_orcto_grava_tt*/.
                        end.
                    end.
                    else do:
                        for each sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                           and  sdo_orcto_ctbl_bgc.cod_unid_orctaria    = v_cod_unid_orctaria
                           and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl   = v_num_seq_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl  = v_cod_vers_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl       = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_empresa          = tt_empresa_leitura_sdo.tta_cod_empresa
                           and  sdo_orcto_ctbl_bgc.cod_estab            = v_cod_estab
                           and  sdo_orcto_ctbl_bgc.cod_unid_negoc       = v_cod_unid_negoc_analit
                           and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl   = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cta_ctbl         = v_cod_cta_ctbl_analit
                           and  sdo_orcto_ctbl_bgc.cod_proj_financ      = v_cod_proj_financ_analit
                           and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl      <= v_cod_exerc_ctbl
                           and  sdo_orcto_ctbl_bgc.num_period_ctbl     <= v_num_period_ctbl:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                end.
                when "Menor" /*l_menor*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                        for each sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario = v_cod_cenar_orctario
                           and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                           and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                           and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                           and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                           and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                           and  sdo_orcto_ctbl_bgc.cod_plano_ccusto    = v_cod_plano_ccusto
                           and  sdo_orcto_ctbl_bgc.cod_ccusto          = v_cod_ccusto_analit
                           and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                           and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                           and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl:
                             run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                    else do:
                        for each sdo_orcto_ctbl_bgc no-lock 
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                            and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                            and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                            and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                            and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                            and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                            and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                            and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                end.
            end.
        end.
    end.

END PROCEDURE. /* pi_leitura_sdo_orcto_more */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_find_last_igual
** Descricao.............: pi_leitura_find_last_igual
** Criado por............: src507
** Criado em.............: 14/12/2002 12:26:21
** Alterado por..........: src507
** Alterado em...........: 14/12/2002 12:26:49
*****************************************************************************/
PROCEDURE pi_leitura_find_last_igual:

    if v_cod_plano_ccusto <> "" then do:
        find LAST sdo_orcto_ctbl_bgc no-lock 
        where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
          and sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
          and sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
          and sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
          and sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
          and sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
          and sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
          and sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
          and sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
          and sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
          and sdo_orcto_ctbl_bgc.cod_plano_ccusto    = v_cod_plano_ccusto
          and sdo_orcto_ctbl_bgc.cod_ccusto          = v_cod_ccusto_analit
          and sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
          and sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
          and sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl no-error.
       if  avail sdo_orcto_ctbl_bgc then do:
           run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /* pi_leitura_sdo_orcto_grava_tt*/.
       end.
    end.
    else do:
       find LAST sdo_orcto_ctbl_bgc no-lock 
         where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
           and sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
           and sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
           and sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
           and sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
           and sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
           and sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
           and sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
           and sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
           and sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
           and sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
           and sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
           and sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl no-error.
        if  avail sdo_orcto_ctbl_bgc then do:
            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /* pi_leitura_sdo_orcto_grava_tt*/.
        end. 
    end.
END PROCEDURE. /* pi_leitura_find_last_igual */
/*****************************************************************************
** Procedure Interna.....: pi_percent_update
** Descricao.............: pi_percent_update
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: bre16250
** Alterado em...........: 13/02/2006 11:33:07
*****************************************************************************/
PROCEDURE pi_percent_update:

    /************************ Parameter Definition Begin ************************/

    def Input param p_val_maximum
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_current_value
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_nom_frame_title
        as character
        format "x(32)"
        no-undo.


    /************************* Parameter Definition End *************************/

    if  p_val_maximum = 0
    then do:
       assign p_val_maximum = 1.
    end /* if */.

    assign v_des_percent_complete     = string(integer(p_val_current_value * 100 / p_val_maximum))
                                      + chr(32) + chr(37)
           v_des_percent_complete_fnd = v_des_percent_complete.

    if  not v_cod_dwb_user begins 'es_'
    then do:
        if  p_val_current_value = 0
        then do:
            assign v_des_percent_complete:width-pixels     in frame f_dlg_02_percent_update = 1
                   v_des_percent_complete:bgcolor          in frame f_dlg_02_percent_update = 1
                   v_des_percent_complete:fgcolor          in frame f_dlg_02_percent_update = 15
                   v_des_percent_complete:font             in frame f_dlg_02_percent_update = 1
            &if '{&emsbas_version}' < '5.06' &then
                   rt_001:bgcolor                          in frame f_dlg_02_percent_update = 8
            &endif
                   v_des_percent_complete_fnd:width-pixels in frame f_dlg_02_percent_update = 315
                   v_des_percent_complete_fnd:font         in frame f_dlg_02_percent_update = 1.
            if  p_nom_frame_title <> ""
            then do:
                assign frame f_dlg_02_percent_update:title = p_nom_frame_title.
            end /* if */.
            else do:
                assign frame f_dlg_02_percent_update:title = "Aguarde, em processamento..." /*l_aguarde_em_processamento*/ .
            end /* else */.
            view frame f_dlg_02_percent_update.
        end /* if */.
        else do:
            assign v_des_percent_complete:width-pixels = max(((315 * p_val_current_value)
                                                       / p_val_maximum), 1).
        end /* else */.
        display v_des_percent_complete
                v_des_percent_complete_fnd
                with frame f_dlg_02_percent_update.
        enable all with frame f_dlg_02_percent_update.
        process events.
    end /* if */.
    else do:
        run prgtec/btb/btb908ze.py (Input 1,
                                    Input v_des_percent_complete) /*prg_api_atualizar_ult_obj*/.
    end /* else */.



END PROCEDURE. /* pi_percent_update */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_ctbl_grava_tt_demonst_2
** Descricao.............: pi_leitura_sdo_ctbl_grava_tt_demonst_2
** Criado por............: fut1180
** Criado em.............: 04/09/2003 10:05:12
** Alterado por..........: fut43112_2
** Alterado em...........: 23/11/2009 13:07:09
*****************************************************************************/
PROCEDURE pi_leitura_sdo_ctbl_grava_tt_demonst_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_seq
        as integer
        format ">>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.05" &then
    def buffer b_sdo_ctbl
        for sdo_ctbl.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_ccusto_2
        as character
        format "x(8)":U
        no-undo.
    def var v_cod_plano_ccusto_2
        as character
        format "x(8)":U
        label "Plano CCusto"
        column-label "Plano CCusto"
        no-undo.
    def var v_cod_tip_inform                 as character       no-undo. /*local*/
    def var v_log_novo                       as logical         no-undo. /*local*/
    def var v_log_ok                         as logical         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/
    def var v_num_cont_2                     as integer         no-undo. /*local*/
    def var v_val_tot_apurac_acum            as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

        /* --- Verifica se a Conta Contÿbil, Ccusto e o Projeto est’o dentro das Faixas parametrizadas ---*/ 
    bloco:
    do:
        if v_log_sdo_orcado_realzdo then do:
            do v_num_cont = 1 to 6:
                assign v_log_ok = no.
                assign v_log_novo = no.
                case v_num_cont:
                    when 1 /* Empresa */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 1 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_empresa then do:
                                assign v_log_ok = yes.
                                leave.
                            end.
                        end.
                    end.
                    when 2 /* Conta Cont˜bil */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 2 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_plano_cta_ctbl then do:
                                if entry(2, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_cta_ctbl then do:
                                    assign v_log_ok = yes.
                                    leave.
                                end.
                            end.
                        end.
                    end.
                    when 3 /* Centro de Custo */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 3 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_empresa then do:
                                if entry(2, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_plano_ccusto then do:
                                    if entry(3, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_ccusto then do:
                                        assign v_log_ok = yes.
                                        leave.
                                    end.
                                end.
                            end.
                        end.
                    end.
                    when 4 /* Estabelecimento */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 4 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_estab then do:
                                assign v_log_ok = yes.
                                leave.
                            end.
                        end.
                    end.
                    when 5 /* Unidade de Neg«cio */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 5 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_unid_negoc then do:
                                assign v_log_ok = yes.
                                leave.
                            end.
                        end.
                    end.
                    when 6 /* Projeto */ then do:
                        for each tt_relacto_unid_orctaria 
                            where tt_relacto_unid_orctaria.tta_num_tip_inform_organ = 6 no-lock:
                            assign v_log_novo = yes
                                   v_cod_tip_inform = tt_relacto_unid_orctaria.tta_cod_inform_organ.
                            if entry(1, v_cod_tip_inform, chr(10)) = sdo_ctbl.cod_proj_financ then do:
                                assign v_log_ok = yes.
                                leave.
                            end.
                        end.
                    end.
                end case.
                if not v_log_ok and v_log_novo then leave bloco.
            end. /* fim do 1 a 6*/
        end.

        assign v_log_novo = yes.
        if  v_log_sdo_orcado_realzdo 
        and v_log_existe_orcto_ccusto 
        and v_cod_plano_ccusto_sdo = "" then do:

            find tt_retorna_sdo_ctbl_demonst
                where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = sdo_ctbl.cod_empresa       
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = sdo_ctbl.cod_finalid_econ  
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = sdo_ctbl.cod_plano_cta_ctbl
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = sdo_ctbl.cod_cta_ctbl      
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = ""
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = ""
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = sdo_ctbl.cod_proj_financ    
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = sdo_ctbl.cod_cenar_ctbl     
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_estab           = sdo_ctbl.cod_estab          
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = sdo_ctbl.cod_unid_negoc     
                and   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = sdo_ctbl.dat_sdo_ctbl
                and   tt_retorna_sdo_ctbl_demonst.tta_num_seq             = p_num_seq
                and   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = v_ind_espec_sdo
                and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = sdo_ctbl.cod_empresa no-error.          
            if avail tt_retorna_sdo_ctbl_demonst then do:

                assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db        + sdo_ctbl.val_sdo_ctbl_db
                       tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr        + sdo_ctbl.val_sdo_ctbl_cr 
                       tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim       + sdo_ctbl.val_sdo_ctbl_fim 
                       tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db        + sdo_ctbl.qtd_sdo_ctbl_db 
                       tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr         = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr        + sdo_ctbl.qtd_sdo_ctbl_cr
                       tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_fim        = tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_fim       + sdo_ctbl.qtd_sdo_ctbl_fim
                       tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo       = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo      + sdo_ctbl.val_apurac_restdo
                       tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr   + sdo_ctbl.val_apurac_restdo_cr
                       tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db    = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db   + sdo_ctbl.val_apurac_restdo_db
                       tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum + sdo_ctbl.val_apurac_restdo_acum
                       tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl         + (sdo_ctbl.val_sdo_ctbl_db - sdo_ctbl.val_sdo_ctbl_cr)
                       tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl          = tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl         + (sdo_ctbl.qtd_sdo_ctbl_db - sdo_ctbl.qtd_sdo_ctbl_cr)
                       v_log_novo = no.
            end.
        end.

        if v_log_novo then do:
            if v_log_saldo = yes then do:
                find first b_sdo_ctbl                         
                    where b_sdo_ctbl.cod_empresa        = estrut_ccusto.cod_empresa
                      and b_sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                      and b_sdo_ctbl.cod_ccusto         = estrut_ccusto.cod_ccusto_pai no-lock no-error.
                if avail b_sdo_ctbl then do:


                    assign v_cod_plano_ccusto_2 = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else v_cod_plano_ccusto 
                           v_cod_ccusto_2       = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else v_cod_ccusto_analit.                   

                    find tt_retorna_sdo_ctbl_demonst
                        where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = b_sdo_ctbl.cod_empresa       
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = b_sdo_ctbl.cod_finalid_econ  
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = b_sdo_ctbl.cod_plano_cta_ctbl
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = b_sdo_ctbl.cod_cta_ctbl      
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = v_cod_plano_ccusto_2
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = v_cod_ccusto_2
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = b_sdo_ctbl.cod_proj_financ    
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = b_sdo_ctbl.cod_cenar_ctbl     
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_estab           = b_sdo_ctbl.cod_estab          
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = b_sdo_ctbl.cod_unid_negoc     
                        and   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = b_sdo_ctbl.dat_sdo_ctbl
                        and   tt_retorna_sdo_ctbl_demonst.tta_num_seq             = p_num_seq
                        and   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = v_ind_espec_sdo
                        and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = b_sdo_ctbl.cod_empresa no-error.          
                    if not avail tt_retorna_sdo_ctbl_demonst then do:
                        create tt_retorna_sdo_ctbl_demonst.
                        assign tt_retorna_sdo_ctbl_demonst.tta_num_seq                 = p_num_seq
                               tt_retorna_sdo_ctbl_demonst.tta_cod_empresa             = b_sdo_ctbl.cod_empresa
                               tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ        = b_sdo_ctbl.cod_finalid_econ
                               tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl      = b_sdo_ctbl.cod_plano_cta_ctbl
                               tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl            = b_sdo_ctbl.cod_cta_ctbl
                               tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto        = v_cod_plano_ccusto 
                               tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto              = v_cod_ccusto_analit
                               tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl          = b_sdo_ctbl.cod_cenar_ctbl
                               tt_retorna_sdo_ctbl_demonst.tta_cod_estab               = b_sdo_ctbl.cod_estab
                               tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc          = b_sdo_ctbl.cod_unid_negoc
                               tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ         = b_sdo_ctbl.cod_proj_financ
                               tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl            = b_sdo_ctbl.dat_sdo_ctbl
                               tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo           = v_ind_espec_sdo
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db         = b_sdo_ctbl.val_sdo_ctbl_db
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr         = b_sdo_ctbl.val_sdo_ctbl_cr 
                               tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = b_sdo_ctbl.val_sdo_ctbl_fim 
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db         = b_sdo_ctbl.qtd_sdo_ctbl_db 
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr         = b_sdo_ctbl.qtd_sdo_ctbl_cr
                               tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_fim        = b_sdo_ctbl.qtd_sdo_ctbl_fim
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo       = b_sdo_ctbl.val_apurac_restdo
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr    = b_sdo_ctbl.val_apurac_restdo_cr
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db    = b_sdo_ctbl.val_apurac_restdo_db
                               tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = b_sdo_ctbl.val_apurac_restdo_acum
                               tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl = recid(tt_retorna_sdo_ctbl_demonst)
                               tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig     = b_sdo_ctbl.cod_empresa
                               tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl          = (b_sdo_ctbl.val_sdo_ctbl_db - b_sdo_ctbl.val_sdo_ctbl_cr)
                               tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl          = (b_sdo_ctbl.qtd_sdo_ctbl_db - b_sdo_ctbl.qtd_sdo_ctbl_cr).
                    end.
                    if avail tt_item_demonst_ctbl_video then do:
                        create tt_relacto_item_retorna.
                        assign tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                               tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                               tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                    end.
                end.        
            end.           
            else do:    
                assign v_cod_plano_ccusto_2 = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else sdo_ctbl.cod_plano_ccusto
                       v_cod_ccusto_2       = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else sdo_ctbl.cod_ccusto.

                find tt_retorna_sdo_ctbl_demonst
                    where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = sdo_ctbl.cod_empresa       
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = sdo_ctbl.cod_finalid_econ  
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = sdo_ctbl.cod_plano_cta_ctbl
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = sdo_ctbl.cod_cta_ctbl      
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = v_cod_plano_ccusto_2
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = v_cod_ccusto_2
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = sdo_ctbl.cod_proj_financ    
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = sdo_ctbl.cod_cenar_ctbl     
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_estab           = sdo_ctbl.cod_estab          
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = sdo_ctbl.cod_unid_negoc     
                    and   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = sdo_ctbl.dat_sdo_ctbl
                    and   tt_retorna_sdo_ctbl_demonst.tta_num_seq             = p_num_seq
                    and   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = v_ind_espec_sdo
                    and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = sdo_ctbl.cod_empresa no-error.          
                if not avail tt_retorna_sdo_ctbl_demonst then do:
                    create tt_retorna_sdo_ctbl_demonst.
                    assign tt_retorna_sdo_ctbl_demonst.tta_num_seq                 = p_num_seq
                           tt_retorna_sdo_ctbl_demonst.tta_cod_empresa             = sdo_ctbl.cod_empresa
                           tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ        = sdo_ctbl.cod_finalid_econ
                           tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl      = sdo_ctbl.cod_plano_cta_ctbl
                           tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl            = sdo_ctbl.cod_cta_ctbl
                           tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto        = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else sdo_ctbl.cod_plano_ccusto
                           tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto              = if v_log_existe_orcto_ccusto and v_cod_plano_ccusto_sdo = "" then "" else sdo_ctbl.cod_ccusto
                           tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl          = sdo_ctbl.cod_cenar_ctbl
                           tt_retorna_sdo_ctbl_demonst.tta_cod_estab               = sdo_ctbl.cod_estab
                           tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc          = sdo_ctbl.cod_unid_negoc
                           tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ         = sdo_ctbl.cod_proj_financ
                           tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl            = sdo_ctbl.dat_sdo_ctbl
                           tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo           = v_ind_espec_sdo
                           tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_db         = sdo_ctbl.val_sdo_ctbl_db
                           tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_cr         = sdo_ctbl.val_sdo_ctbl_cr 
                           tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = sdo_ctbl.val_sdo_ctbl_fim 
                           tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_db         = sdo_ctbl.qtd_sdo_ctbl_db 
                           tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_cr         = sdo_ctbl.qtd_sdo_ctbl_cr
                           tt_retorna_sdo_ctbl_demonst.tta_qtd_sdo_ctbl_fim        = sdo_ctbl.qtd_sdo_ctbl_fim
                           tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo       = sdo_ctbl.val_apurac_restdo
                           tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_cr    = sdo_ctbl.val_apurac_restdo_cr
                           tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_db    = sdo_ctbl.val_apurac_restdo_db
                           tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = sdo_ctbl.val_apurac_restdo_acum
                           tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl = recid(tt_retorna_sdo_ctbl_demonst)
                           tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig     = sdo_ctbl.cod_empresa
                           tt_retorna_sdo_ctbl_demonst.ttv_val_movto_ctbl          = (sdo_ctbl.val_sdo_ctbl_db - sdo_ctbl.val_sdo_ctbl_cr)
                           tt_retorna_sdo_ctbl_demonst.ttv_qtd_movto_ctbl          = (sdo_ctbl.qtd_sdo_ctbl_db - sdo_ctbl.qtd_sdo_ctbl_cr).
                end.
                if avail tt_item_demonst_ctbl_video then do:
                    create tt_relacto_item_retorna.
                    assign tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                           tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                           tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
                end.
            end.
        end.    
        if v_log_busca_empenh then do:
            if sdo_ctbl.cod_plano_ccusto = "" then do:
                for each orig_movto_empenh 
                    fields (orig_movto_empenh.num_ult_funcao
                           orig_movto_empenh.val_movto_empenh
                           orig_movto_empenh.qtd_movto_empenh
                           orig_movto_empenh.cod_empresa                                       
                           orig_movto_empenh.cod_plano_cta_ctbl 
                           orig_movto_empenh.cod_cta_ctbl       
                           orig_movto_empenh.cod_estab          
                           orig_movto_empenh.cod_unid_negoc     
                           orig_movto_empenh.cod_plano_ccusto   
                           orig_movto_empenh.cod_ccusto         
                           orig_movto_empenh.cod_proj_financ    
                           orig_movto_empenh.dat_sdo_ctbl       
                           orig_movto_empenh.cod_finalid_econ)
                    where orig_movto_empenh.cod_empresa        = sdo_ctbl.cod_empresa
                    and   orig_movto_empenh.cod_plano_cta_ctbl = sdo_ctbl.cod_plano_cta_ctbl
                    and   orig_movto_empenh.cod_cta_ctbl       = sdo_ctbl.cod_cta_ctbl
                    and   orig_movto_empenh.cod_estab          = sdo_ctbl.cod_estab
                    and   orig_movto_empenh.cod_unid_negoc     = sdo_ctbl.cod_unid_negoc
                    and   orig_movto_empenh.cod_proj_financ    = sdo_ctbl.cod_proj_financ
                    and   orig_movto_empenh.dat_sdo_ctbl       = sdo_ctbl.dat_sdo_ctbl
                    and   orig_movto_empenh.cod_finalid_econ   = sdo_ctbl.cod_finalid_econ no-lock:

                    if orig_movto_empenh.num_ult_funcao = 3 then next.

                    assign tt_retorna_sdo_ctbl_demonst.tta_val_movto_empenh = tt_retorna_sdo_ctbl_demonst.tta_val_movto_empenh + orig_movto_empenh.val_movto_empenh
                           tt_retorna_sdo_ctbl_demonst.tta_qtd_movto_empenh = tt_retorna_sdo_ctbl_demonst.tta_qtd_movto_empenh + orig_movto_empenh.qtd_movto_empenh.
                end.
            end.
            else do:
                for each orig_movto_empenh 
                    fields (orig_movto_empenh.num_ult_funcao
                           orig_movto_empenh.val_movto_empenh
                           orig_movto_empenh.qtd_movto_empenh
                           orig_movto_empenh.cod_empresa                                       
                           orig_movto_empenh.cod_plano_cta_ctbl 
                           orig_movto_empenh.cod_cta_ctbl       
                           orig_movto_empenh.cod_estab          
                           orig_movto_empenh.cod_unid_negoc     
                           orig_movto_empenh.cod_plano_ccusto   
                           orig_movto_empenh.cod_ccusto         
                           orig_movto_empenh.cod_proj_financ    
                           orig_movto_empenh.dat_sdo_ctbl       
                           orig_movto_empenh.cod_finalid_econ)
                    where orig_movto_empenh.cod_empresa        = sdo_ctbl.cod_empresa
                    and   orig_movto_empenh.cod_plano_cta_ctbl = sdo_ctbl.cod_plano_cta_ctbl
                    and   orig_movto_empenh.cod_cta_ctbl       = sdo_ctbl.cod_cta_ctbl
                    and   orig_movto_empenh.cod_estab          = sdo_ctbl.cod_estab
                    and   orig_movto_empenh.cod_unid_negoc     = sdo_ctbl.cod_unid_negoc
                    and   orig_movto_empenh.cod_plano_ccusto   = sdo_ctbl.cod_plano_ccusto
                    and   orig_movto_empenh.cod_ccusto         = sdo_ctbl.cod_ccusto
                    and   orig_movto_empenh.cod_proj_financ    = sdo_ctbl.cod_proj_financ
                    and   orig_movto_empenh.dat_sdo_ctbl       = sdo_ctbl.dat_sdo_ctbl
                    and   orig_movto_empenh.cod_finalid_econ   = sdo_ctbl.cod_finalid_econ no-lock:

                    if orig_movto_empenh.num_ult_funcao = 3 then next.

                    assign tt_retorna_sdo_ctbl_demonst.tta_val_movto_empenh = tt_retorna_sdo_ctbl_demonst.tta_val_movto_empenh + orig_movto_empenh.val_movto_empenh
                           tt_retorna_sdo_ctbl_demonst.tta_qtd_movto_empenh = tt_retorna_sdo_ctbl_demonst.tta_qtd_movto_empenh + orig_movto_empenh.qtd_movto_empenh.
                end.
            end.
        end.

        if v_log_saldo = yes then 
            find first sdo_ctbl
                 where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                   and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                   and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                   and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto    
                   and sdo_ctbl.cod_ccusto         = estrut_ccusto.cod_ccusto_pai
                   and sdo_ctbl.cod_plano_cta_ctbl = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                   and sdo_ctbl.cod_cta_ctbl       = v_cod_cta_ctbl_analit
                   and sdo_ctbl.cod_proj_financ    = v_cod_proj_financ_analit no-lock no-error.

        find tt_cta_ctbl_demonst
           where tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
           and   tt_cta_ctbl_demonst.tta_cod_cta_ctbl       = sdo_ctbl.cod_cta_ctbl
           no-error.


        /* Verifica se a conta informada eh a conta de apuracao de resultado */
        if sdo_ctbl.cod_cta_ctbl = v_cod_cta_ctbl_apurac_restdo 
        or tt_cta_ctbl_demonst.ttv_log_consid_apurac = no 
        then do:

            assign v_val_tot_apurac_restdo_acum = 0.

            find tt_data_ult_exerc
               where tt_data_ult_exerc.tta_cod_cenar_ctbl = sdo_ctbl.cod_cenar_ctbl
               and   tt_data_ult_exerc.ttv_dat_process    = sdo_ctbl.dat_sdo_ctbl
               no-error.
            if not avail tt_data_ult_exerc then do:
                /* Acha o periodo do movimento */
                find period_ctbl no-lock
                   where period_ctbl.cod_cenar_ctbl        = sdo_ctbl.cod_cenar_ctbl
                     and period_ctbl.dat_inic_period_ctbl <= sdo_ctbl.dat_sdo_ctbl
                     and period_ctbl.dat_fim_period_ctbl  >= sdo_ctbl.dat_sdo_ctbl
                     no-error.
                /* Acha o primeiro periodo do exercicio */
                find first b_period_ctbl
                   where b_period_ctbl.cod_cenar_ctbl = period_ctbl.cod_cenar_ctbl
                    and  b_period_ctbl.cod_exerc_ctbl = period_ctbl.cod_exerc_ctbl
                    no-lock no-error.
                /* Acha o ultimo periodo do exercicio anterior */
                find last period_ctbl
                   where period_ctbl.cod_cenar_ctbl      = b_period_ctbl.cod_cenar_ctbl
                    and  period_ctbl.dat_fim_period_ctbl < b_period_ctbl.dat_inic_period_ctbl
                    no-lock no-error.
                if avail period_ctbl then do:
                    create tt_data_ult_exerc.
                    assign tt_data_ult_exerc.ttv_dat_process    = sdo_ctbl.dat_sdo_ctbl
                           tt_data_ult_exerc.tta_cod_cenar_ctbl = sdo_ctbl.cod_cenar_ctbl
                           tt_data_ult_exerc.ttv_dat_ult_exerc  = period_ctbl.dat_fim_period_ctbl.
                end.
            end.
            if avail tt_data_ult_exerc then do:

                find b_sdo_ctbl no-lock
                   where b_sdo_ctbl.cod_empresa        = sdo_ctbl.cod_empresa
                     and b_sdo_ctbl.cod_finalid_econ   = sdo_ctbl.cod_finalid_econ
                     and b_sdo_ctbl.cod_plano_cta_ctbl = sdo_ctbl.cod_plano_cta_ctbl
                     and b_sdo_ctbl.cod_cta_ctbl       = sdo_ctbl.cod_cta_ctbl
                     and b_sdo_ctbl.cod_plano_ccusto   = sdo_ctbl.cod_plano_ccusto
                     and b_sdo_ctbl.cod_ccusto         = sdo_ctbl.cod_ccusto
                     and b_sdo_ctbl.cod_cenar_ctbl     = sdo_ctbl.cod_cenar_ctbl
                     and b_sdo_ctbl.cod_proj_financ    = sdo_ctbl.cod_proj_financ
                     and b_sdo_ctbl.cod_estab          = sdo_ctbl.cod_estab
                     and b_sdo_ctbl.cod_unid_negoc     = sdo_ctbl.cod_unid_negoc
                     and b_sdo_ctbl.dat_sdo_ctbl       = tt_data_ult_exerc.ttv_dat_ult_exerc
                     no-error.
                if avail b_sdo_ctbl then do:
                    /* Atualiza variavel com o acumulado da apuracao de resultado do exercicio anterior */
                    assign v_val_tot_apurac_restdo_acum = b_sdo_ctbl.val_apurac_restdo_acum.
                end.
            end.

            assign tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim        = tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim + v_val_tot_apurac_restdo_acum
                   tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum  = tt_retorna_sdo_ctbl_demonst.tta_val_apurac_restdo_acum - v_val_tot_apurac_restdo_acum.
        end.
    end.
END PROCEDURE. /* pi_leitura_sdo_ctbl_grava_tt_demonst_2 */
/*****************************************************************************
** Procedure Interna.....: pi_localiza_tt_cta_ctbl_analitica_demonst_1
** Descricao.............: pi_localiza_tt_cta_ctbl_analitica_demonst_1
** Criado por............: bre17108
** Criado em.............: 25/07/2003 19:53:32
** Alterado por..........: fut41162
** Alterado em...........: 22/01/2009 14:45:29
*****************************************************************************/
PROCEDURE pi_localiza_tt_cta_ctbl_analitica_demonst_1:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_cta_ctbl
        as character
        format "x(20)"
        no-undo.


    /************************* Parameter Definition End *************************/

    for each  btt_cta_ctbl_demonst no-lock
        where btt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl = tt_cta_ctbl_demonst.tta_cod_plano_cta_ctbl
        and   btt_cta_ctbl_demonst.ttv_cod_cta_ctbl_pai   = p_cod_cta_ctbl:

        /* 216521 - erro  progress "REPLACE/CONCAT may not result in data >  bytes */
        create  tt_lista_cta_ctbl_demonst.
        assign  tt_lista_cta_ctbl_demonst.ttv_rec_lista_cta_ctbl_aux = recid(tt_retorna_sdo_ctbl_demonst)
                tt_lista_cta_ctbl_demonst.tta_cod_empresa     = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa    
                tt_lista_cta_ctbl_demonst.tta_cod_estab       = tt_retorna_sdo_ctbl_demonst.tta_cod_estab       
    	    tt_lista_cta_ctbl_demonst.tta_cod_unid_negoc  = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc                    
                tt_lista_cta_ctbl_demonst.tta_cod_proj_financ = tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ
                tt_lista_cta_ctbl_demonst.tta_cod_ccusto      = tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto  
                tt_lista_cta_ctbl_demonst.tta_cod_cta_ctbl    = btt_cta_ctbl_demonst.tta_cod_cta_ctbl.  

        find first btt_retorna_sdo_ctbl_demonst
           where btt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = tt_retorna_sdo_ctbl_demonst.tta_cod_empresa        
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ   
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl 
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = btt_cta_ctbl_demonst.tta_cod_cta_ctbl
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto   
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto         
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ    
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl     
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_estab           = tt_retorna_sdo_ctbl_demonst.tta_cod_estab          
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc     
           and   btt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl       
           and   btt_retorna_sdo_ctbl_demonst.tta_num_seq             = tt_retorna_sdo_ctbl_demonst.tta_num_seq            
           and   btt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = "Or‡amento" /*l_orcamento*/ 
           and   btt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig
           no-error.
        if avail btt_retorna_sdo_ctbl_demonst then do:
            assign btt_retorna_sdo_ctbl_demonst.ttv_log_sdo_orcado_sint = yes.
        end.
        run pi_localiza_tt_cta_ctbl_analitica_demonst_1 (Input btt_cta_ctbl_demonst.tta_cod_cta_ctbl) /*pi_localiza_tt_cta_ctbl_analitica_demonst_1*/.
    end.

END PROCEDURE. /* pi_localiza_tt_cta_ctbl_analitica_demonst_1 */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_ctbl_demonst_novo
** Descricao.............: pi_leitura_sdo_ctbl_demonst_novo
** Criado por............: bre17108
** Criado em.............: 08/12/2003 15:24:21
** Alterado por..........: fut35059
** Alterado em...........: 08/05/2007 16:21:04
*****************************************************************************/
PROCEDURE pi_leitura_sdo_ctbl_demonst_novo:

    /************************* Variable Definition Begin ************************/

    def var v_cod_ccusto_final
        as character
        format "x(11)":U
        initial "ZZZZZZZZZZZ" /*l_ZZZZZZZZZZZ*/
        label "at‚"
        column-label "at‚"
        no-undo.
    def var v_cod_ccusto_inicial
        as character
        format "x(11)":U
        label "Centro de Custo"
        no-undo.
    def var v_cod_cta_ctbl_final
        as character
        format "x(20)":U
        initial "ZZZZZZZZZZZZZZZZZZZZ"
        label "at‚"
        column-label "at‚"
        no-undo.
    def var v_cod_cta_ctbl_inicial
        as character
        format "x(20)":U
        label "Conta Cont bil"
        column-label "Conta Cont bil"
        no-undo.
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    def var v_cod_estab_final
        as character
        format "x(3)":U
        initial "ZZZ"
        label "Final"
        column-label "Final"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    def var v_cod_estab_final
        as Character
        format "x(5)":U
        initial "ZZZZZ"
        label "Final"
        column-label "Final"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    def var v_cod_estab_inicial
        as character
        format "x(3)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    def var v_cod_estab_inicial
        as Character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    &ENDIF
    def var v_cod_proj_financ_final
        as character
        format "x(20)":U
        label "Projeto Final"
        column-label "Projeto Final"
        no-undo.
    def var v_cod_proj_financ_inicial
        as character
        format "x(20)":U
        label "Projeto Inicial"
        column-label "Projeto Inicial"
        no-undo.
    def var v_cod_un_final
        as character
        format "x(8)":U
        no-undo.
    def var v_cod_un_inicial
        as character
        format "x(8)":U
        no-undo.
    def var v_num_count_cc
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_count_cta
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_count_proj
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    find first tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Estabelecimento" /*l_estabelecimento*/ 
         and   tt_lista_inform.ttv_log_selec     = yes no-error.
    if not avail tt_lista_inform then return.
    assign v_cod_estab_inicial = tt_lista_inform.ttv_cod_fill.
    find last tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Estabelecimento" /*l_estabelecimento*/ 
         and   tt_lista_inform.ttv_log_selec     = yes no-error.
    assign v_cod_estab_final = tt_lista_inform.ttv_cod_fill.

    find first tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
         and   tt_lista_inform.ttv_log_selec     = yes no-error.
    if not avail tt_lista_inform then return.
    assign v_cod_cta_ctbl_inicial = tt_lista_inform.ttv_cod_fill.
    find last tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
         and   tt_lista_inform.ttv_log_selec     = yes no-error.
    assign v_cod_cta_ctbl_final = tt_lista_inform.ttv_cod_fill.
    for each tt_lista_inform use-index tt_select
       where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
       and   tt_lista_inform.ttv_log_selec     = yes:
        assign v_num_count_cta = v_num_count_cta + 1.
    end.

    find first tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
         and   tt_lista_inform.ttv_log_selec    = yes no-error.
    if not avail tt_lista_inform then return.
    assign v_cod_ccusto_inicial = tt_lista_inform.ttv_cod_fill.
    find last tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
         and   tt_lista_inform.ttv_log_selec    = yes no-error.
    assign v_cod_ccusto_final = tt_lista_inform.ttv_cod_fill.
    for each tt_lista_inform use-index tt_select
       where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
       and   tt_lista_inform.ttv_log_selec    = yes:
        assign v_num_count_cc = v_num_count_cc + 1.
    end.

    find first tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
         and   tt_lista_inform.ttv_log_selec    = yes no-error.
    if avail tt_lista_inform then do:
        assign v_cod_proj_financ_inicial = tt_lista_inform.ttv_cod_fill.
        find last tt_lista_inform use-index tt_select
             where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
             and   tt_lista_inform.ttv_log_selec    = yes no-error.
        assign v_cod_proj_financ_final = tt_lista_inform.ttv_cod_fill.
    end.
    else do:
        create tt_lista_inform.
        assign tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
               tt_lista_inform.ttv_log_selec    = yes.
    end.
    for each tt_lista_inform use-index tt_select
       where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
       and   tt_lista_inform.ttv_log_selec    = yes:
        assign v_num_count_proj = v_num_count_proj + 1.
    end.

    find first tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
         and   tt_lista_inform.ttv_log_selec    = yes no-error.
    if not avail tt_lista_inform then return.
    assign v_cod_un_inicial = tt_lista_inform.ttv_cod_fill.
    find last tt_lista_inform use-index tt_select
         where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
         and   tt_lista_inform.ttv_log_selec    = yes no-error.
    assign v_cod_un_final = tt_lista_inform.ttv_cod_fill.

    do v_num_count = 1 to num-entries(v_ind_espec_sdo_tot,chr(59)):

        assign v_ind_espec_sdo = entry(v_num_count, v_ind_espec_sdo_tot, chr(59)).

        do v_num_count_1 = 1 to v_cdn_tot_dat:
            assign v_dat_sdo_cta_inic = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic, chr(10)))
                   v_dat_sdo_cta_fim = date(entry(v_num_count_1,tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim, chr(10)))
                   v_cod_exerc_ctbl  = trim(entry(v_num_count_1,tt_input_sdo.ttv_cod_exerc_ctbl, chr(10)))
                   v_num_period_ctbl = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_period_ctbl, chr(10)))
                   v_num_seq_1       = integer(entry(v_num_count_1,tt_input_sdo.ttv_cod_seq, chr(10))).

            if v_ind_espec_sdo = "Cont bil" /*l_contabil*/  then do:
                if v_num_count_cta <= 100 then do:
                    if v_num_count_cc <= 100 then do:
                        for each btt_lista_inform_conta_aux use-index tt_select
                           where btt_lista_inform_conta_aux.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                           and   btt_lista_inform_conta_aux.ttv_log_selec    = yes,
                        each btt_lista_inform_ccusto_aux use-index tt_select
                           where btt_lista_inform_ccusto_aux.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                           and   btt_lista_inform_ccusto_aux.ttv_log_selec    = yes,
                        each sdo_ctbl no-lock
                           where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                             and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                             and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                             and sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                             and sdo_ctbl.cod_cta_ctbl       = btt_lista_inform_conta_aux.ttv_cod_fill  
                             and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                             and sdo_ctbl.cod_ccusto         = btt_lista_inform_ccusto_aux.ttv_cod_fill   
                             and sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim
                             and sdo_ctbl.cod_proj_financ   >= v_cod_proj_financ_inicial
                             and sdo_ctbl.cod_proj_financ   <= v_cod_proj_financ_final  
                             and sdo_ctbl.cod_estab         >= v_cod_estab_inicial 
                             and sdo_ctbl.cod_estab         <= v_cod_estab_final   
                             and sdo_ctbl.cod_unid_negoc    >= v_cod_un_inicial   
                             and sdo_ctbl.cod_unid_negoc    <= v_cod_un_final:
                            assign v_cod_estab_aux       = sdo_ctbl.cod_estab
                                   v_cod_cta_ctbl_aux    = sdo_ctbl.cod_cta_ctbl
                                   v_cod_ccusto_aux      = sdo_ctbl.cod_ccusto
                                   v_cod_proj_financ_aux = sdo_ctbl.cod_proj_financ
                                   v_cod_unid_negoc_aux  = sdo_ctbl.cod_unid_negoc.
                            run pi_leitura_sdo_ctbl_demonst_novo_1 (input 1).
                        end.
                    end.
                    else do:
                        for each btt_lista_inform_conta_aux use-index tt_select
                           where btt_lista_inform_conta_aux.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
                           and   btt_lista_inform_conta_aux.ttv_log_selec    = yes,
                        each sdo_ctbl no-lock
                           where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                             and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                             and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                             and sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                             and sdo_ctbl.cod_cta_ctbl       = btt_lista_inform_conta_aux.ttv_cod_fill  
                             and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                             and sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim
                             and sdo_ctbl.cod_ccusto        >= v_cod_ccusto_inicial   
                             and sdo_ctbl.cod_ccusto        <= v_cod_ccusto_final     
                             and sdo_ctbl.cod_proj_financ   >= v_cod_proj_financ_inicial
                             and sdo_ctbl.cod_proj_financ   <= v_cod_proj_financ_final  
                             and sdo_ctbl.cod_estab         >= v_cod_estab_inicial 
                             and sdo_ctbl.cod_estab         <= v_cod_estab_final   
                             and sdo_ctbl.cod_unid_negoc    >= v_cod_un_inicial   
                             and sdo_ctbl.cod_unid_negoc    <= v_cod_un_final:
                            assign v_cod_estab_aux       = sdo_ctbl.cod_estab
                                   v_cod_cta_ctbl_aux    = sdo_ctbl.cod_cta_ctbl
                                   v_cod_ccusto_aux      = sdo_ctbl.cod_ccusto
                                   v_cod_proj_financ_aux = sdo_ctbl.cod_proj_financ
                                   v_cod_unid_negoc_aux  = sdo_ctbl.cod_unid_negoc.
                            run pi_leitura_sdo_ctbl_demonst_novo_1 (input 1).
                        end.
                    end.
                end.
                else if v_num_count_cc <= 100 then do:
                    for each btt_lista_inform_ccusto_aux use-index tt_select
                       where btt_lista_inform_ccusto_aux.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
                       and   btt_lista_inform_ccusto_aux.ttv_log_selec    = yes,
                    each sdo_ctbl no-lock
                       where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                         and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                         and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                         and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                         and sdo_ctbl.cod_ccusto         = btt_lista_inform_ccusto_aux.ttv_cod_fill   
                         and sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                         and sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim
                         and sdo_ctbl.cod_cta_ctbl      >= v_cod_cta_ctbl_inicial  
                         and sdo_ctbl.cod_cta_ctbl      <= v_cod_cta_ctbl_final    
                         and sdo_ctbl.cod_proj_financ   >= v_cod_proj_financ_inicial
                         and sdo_ctbl.cod_proj_financ   <= v_cod_proj_financ_final  
                         and sdo_ctbl.cod_estab         >= v_cod_estab_inicial 
                         and sdo_ctbl.cod_estab         <= v_cod_estab_final   
                         and sdo_ctbl.cod_unid_negoc    >= v_cod_un_inicial   
                         and sdo_ctbl.cod_unid_negoc    <= v_cod_un_final:
                        assign v_cod_estab_aux       = sdo_ctbl.cod_estab
                               v_cod_cta_ctbl_aux    = sdo_ctbl.cod_cta_ctbl
                               v_cod_ccusto_aux      = sdo_ctbl.cod_ccusto
                               v_cod_proj_financ_aux = sdo_ctbl.cod_proj_financ
                               v_cod_unid_negoc_aux  = sdo_ctbl.cod_unid_negoc.
                        run pi_leitura_sdo_ctbl_demonst_novo_1 (input 1).
                    end.
                end.
                else if v_num_count_proj <= 10 then do:
                    for each btt_lista_inform_proj_aux use-index tt_select
                       where btt_lista_inform_proj_aux.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
                       and   btt_lista_inform_proj_aux.ttv_log_selec    = yes,
                    each sdo_ctbl no-lock
                       where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                         and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                         and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                         and sdo_ctbl.cod_proj_financ    = btt_lista_inform_proj_aux.ttv_cod_fill
                         and sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                         and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                         and sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim
                         and sdo_ctbl.cod_cta_ctbl      >= v_cod_cta_ctbl_inicial  
                         and sdo_ctbl.cod_cta_ctbl      <= v_cod_cta_ctbl_final    
                         and sdo_ctbl.cod_ccusto        >= v_cod_ccusto_inicial   
                         and sdo_ctbl.cod_ccusto        <= v_cod_ccusto_final     
                         and sdo_ctbl.cod_estab         >= v_cod_estab_inicial 
                         and sdo_ctbl.cod_estab         <= v_cod_estab_final   
                         and sdo_ctbl.cod_unid_negoc    >= v_cod_un_inicial   
                         and sdo_ctbl.cod_unid_negoc    <= v_cod_un_final:
                        assign v_cod_estab_aux       = sdo_ctbl.cod_estab
                               v_cod_cta_ctbl_aux    = sdo_ctbl.cod_cta_ctbl
                               v_cod_ccusto_aux      = sdo_ctbl.cod_ccusto
                               v_cod_proj_financ_aux = sdo_ctbl.cod_proj_financ
                               v_cod_unid_negoc_aux  = sdo_ctbl.cod_unid_negoc.
                        run pi_leitura_sdo_ctbl_demonst_novo_1 (input 1).
                    end.
                end.
                else do:
                    for each sdo_ctbl no-lock
                       where sdo_ctbl.cod_empresa        = tt_empresa_leitura_sdo.tta_cod_empresa
                         and sdo_ctbl.cod_finalid_econ   = v_cod_finalid_econ
                         and sdo_ctbl.cod_cenar_ctbl     = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                         and sdo_ctbl.cod_plano_cta_ctbl = v_cod_plano_cta_ctbl
                         and sdo_ctbl.cod_plano_ccusto   = v_cod_plano_ccusto
                         and sdo_ctbl.dat_sdo_ctbl       = v_dat_sdo_cta_fim
                         and sdo_ctbl.cod_cta_ctbl      >= v_cod_cta_ctbl_inicial  
                         and sdo_ctbl.cod_cta_ctbl      <= v_cod_cta_ctbl_final    
                         and sdo_ctbl.cod_ccusto        >= v_cod_ccusto_inicial   
                         and sdo_ctbl.cod_ccusto        <= v_cod_ccusto_final     
                         and sdo_ctbl.cod_proj_financ   >= v_cod_proj_financ_inicial
                         and sdo_ctbl.cod_proj_financ   <= v_cod_proj_financ_final  
                         and sdo_ctbl.cod_estab         >= v_cod_estab_inicial 
                         and sdo_ctbl.cod_estab         <= v_cod_estab_final   
                         and sdo_ctbl.cod_unid_negoc    >= v_cod_un_inicial   
                         and sdo_ctbl.cod_unid_negoc    <= v_cod_un_final:
                        assign v_cod_estab_aux       = sdo_ctbl.cod_estab
                               v_cod_cta_ctbl_aux    = sdo_ctbl.cod_cta_ctbl
                               v_cod_ccusto_aux      = sdo_ctbl.cod_ccusto
                               v_cod_proj_financ_aux = sdo_ctbl.cod_proj_financ
                               v_cod_unid_negoc_aux  = sdo_ctbl.cod_unid_negoc.
                        run pi_leitura_sdo_ctbl_demonst_novo_1 (input 1).
                    end.
                end.
            end.
            if v_ind_espec_sdo = "Or‡amento" /*l_orcamento*/  then do:
                if v_cod_plano_ccusto <> "" then do:
                    for each sdo_orcto_ctbl_bgc no-lock 
                       where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                       and   sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                       and   sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl 
                       and   sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl  
                       and   sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                       and   sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_plano_ccusto    = v_cod_plano_ccusto
                       and   sdo_orcto_ctbl_bgc.cod_cta_ctbl       >= v_cod_cta_ctbl_inicial   
                       and   sdo_orcto_ctbl_bgc.cod_cta_ctbl       <= v_cod_cta_ctbl_final     
                       and   sdo_orcto_ctbl_bgc.cod_ccusto         >= v_cod_ccusto_inicial    
                       and   sdo_orcto_ctbl_bgc.cod_ccusto         <= v_cod_ccusto_final      
                       and   sdo_orcto_ctbl_bgc.cod_estab          >= v_cod_estab_inicial 
                       and   sdo_orcto_ctbl_bgc.cod_estab          <= v_cod_estab_final   
                       and   sdo_orcto_ctbl_bgc.cod_proj_financ    >= v_cod_proj_financ_inicial  
                       and   sdo_orcto_ctbl_bgc.cod_proj_financ    <= v_cod_proj_financ_final    
                       and   sdo_orcto_ctbl_bgc.cod_unid_negoc     >= v_cod_un_inicial    
                       and   sdo_orcto_ctbl_bgc.cod_unid_negoc     <= v_cod_un_final:     
                        assign v_cod_estab_aux       = sdo_orcto_ctbl_bgc.cod_estab
                               v_cod_cta_ctbl_aux    = sdo_orcto_ctbl_bgc.cod_cta_ctbl
                               v_cod_ccusto_aux      = if v_cod_plano_ccusto = "" then "" else sdo_orcto_ctbl_bgc.cod_ccusto
                               v_cod_proj_financ_aux = sdo_orcto_ctbl_bgc.cod_proj_financ
                               v_cod_unid_negoc_aux  = sdo_orcto_ctbl_bgc.cod_unid_negoc.
                        run pi_leitura_sdo_ctbl_demonst_novo_1 (input 2).
                   end.
                end.
                else do:
                    for each sdo_orcto_ctbl_bgc no-lock 
                       where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                       and   sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                       and   sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl 
                       and   sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl  
                       and   sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                       and   sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                       and   sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                       and   sdo_orcto_ctbl_bgc.cod_cta_ctbl       >= v_cod_cta_ctbl_inicial   
                       and   sdo_orcto_ctbl_bgc.cod_cta_ctbl       <= v_cod_cta_ctbl_final     
                       and   sdo_orcto_ctbl_bgc.cod_estab          >= v_cod_estab_inicial   
                       and   sdo_orcto_ctbl_bgc.cod_estab          <= v_cod_estab_final     
                       and   sdo_orcto_ctbl_bgc.cod_proj_financ    >= v_cod_proj_financ_inicial
                       and   sdo_orcto_ctbl_bgc.cod_proj_financ    <= v_cod_proj_financ_final  
                       and   sdo_orcto_ctbl_bgc.cod_unid_negoc     >= v_cod_un_inicial    
                       and   sdo_orcto_ctbl_bgc.cod_unid_negoc     <= v_cod_un_final:     
                        assign v_cod_estab_aux       = sdo_orcto_ctbl_bgc.cod_estab
                               v_cod_cta_ctbl_aux    = sdo_orcto_ctbl_bgc.cod_cta_ctbl
                               v_cod_ccusto_aux      = if v_cod_plano_ccusto = "" then "" else sdo_orcto_ctbl_bgc.cod_ccusto
                               v_cod_proj_financ_aux = sdo_orcto_ctbl_bgc.cod_proj_financ
                               v_cod_unid_negoc_aux  = sdo_orcto_ctbl_bgc.cod_unid_negoc.
                        run pi_leitura_sdo_ctbl_demonst_novo_1 (input 2).
                   end.
                end.
            end.
        end.
    end.

END PROCEDURE. /* pi_leitura_sdo_ctbl_demonst_novo */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_ctbl_demonst_novo_1
** Descricao.............: pi_leitura_sdo_ctbl_demonst_novo_1
** Criado por............: bre17108
** Criado em.............: 08/12/2003 15:42:57
** Alterado por..........: bre17108
** Alterado em...........: 08/12/2003 15:49:28
*****************************************************************************/
PROCEDURE pi_leitura_sdo_ctbl_demonst_novo_1:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_tip_sdo
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    find first tt_lista_inform 
       where tt_lista_inform.ttv_cod_tip_lista = "Estabelecimento" /*l_estabelecimento*/ 
       and   tt_lista_inform.ttv_log_selec     = yes
       and   tt_lista_inform.ttv_cod_fill      = v_cod_estab_aux
       no-error.
    if not avail tt_lista_inform then
        next.
    assign v_cod_estab = tt_lista_inform.ttv_cod_inform.
    find first tt_lista_inform 
       where tt_lista_inform.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
       and   tt_lista_inform.ttv_log_selec     = yes
       and   tt_lista_inform.ttv_cod_fill      = v_cod_cta_ctbl_aux
       no-error.
    if not avail tt_lista_inform then 
        next.

    if not (p_num_tip_sdo = 2
    and v_cod_plano_ccusto = "") then do:
        find first tt_lista_inform 
           where tt_lista_inform.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
           and   tt_lista_inform.ttv_log_selec     = yes
           and   tt_lista_inform.ttv_cod_fill      = v_cod_ccusto_aux
           no-error.
        if not avail tt_lista_inform then 
            next.
    end.

    find first tt_lista_inform 
       where tt_lista_inform.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
       and   tt_lista_inform.ttv_log_selec     = yes
       and   tt_lista_inform.ttv_cod_fill      = v_cod_proj_financ_aux
       no-error.
    if not avail tt_lista_inform then 
        next.
    find first tt_lista_inform 
       where tt_lista_inform.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
       and   tt_lista_inform.ttv_log_selec     = yes
       and   tt_lista_inform.ttv_cod_fill      = v_cod_unid_negoc_aux
       no-error.
    if not avail tt_lista_inform then 
        next.

    release tt_item_demonst_ctbl_video.

    find tt_retorna_sdo_ctbl_demonst
        where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = sdo_ctbl.cod_empresa       
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = sdo_ctbl.cod_finalid_econ  
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = sdo_ctbl.cod_plano_cta_ctbl
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = sdo_ctbl.cod_cta_ctbl      
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_ccusto    = sdo_ctbl.cod_plano_ccusto
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_ccusto          = sdo_ctbl.cod_ccusto
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_proj_financ     = sdo_ctbl.cod_proj_financ    
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = sdo_ctbl.cod_cenar_ctbl     
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_estab           = sdo_ctbl.cod_estab          
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc      = sdo_ctbl.cod_unid_negoc     
        and   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = sdo_ctbl.dat_sdo_ctbl
        and   tt_retorna_sdo_ctbl_demonst.tta_num_seq             = v_num_seq_1
        and   tt_retorna_sdo_ctbl_demonst.ttv_ind_espec_sdo       = v_ind_espec_sdo
        and   tt_retorna_sdo_ctbl_demonst.tta_cod_unid_organ_orig = sdo_ctbl.cod_empresa no-error.          
    if not avail tt_retorna_sdo_ctbl_demonst then do:
        if p_num_tip_sdo = 1 then
            run pi_leitura_sdo_ctbl_grava_tt_demonst (Input v_num_seq_1) /* pi_leitura_sdo_ctbl_grava_tt_demonst*/.
        else
            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /* pi_leitura_sdo_orcto_grava_tt*/.
    end.

    if not avail tt_retorna_sdo_ctbl_demonst then
        next.

    for each btt_lista_inform_conta 
       where btt_lista_inform_conta.ttv_cod_tip_lista = "Conta Cont bil" /*l_conta_contabil*/ 
       and   btt_lista_inform_conta.ttv_log_selec     = yes
       and   btt_lista_inform_conta.ttv_cod_fill      = v_cod_cta_ctbl_aux,
    each btt_lista_inform_ccusto 
       where btt_lista_inform_ccusto.ttv_cod_tip_lista = "Centro Custo" /*l_centro_custo*/ 
       and   btt_lista_inform_ccusto.ttv_log_selec     = yes
       and   btt_lista_inform_ccusto.ttv_cod_fill      = v_cod_ccusto_aux,
    each btt_lista_inform_proj 
       where btt_lista_inform_proj.ttv_cod_tip_lista = "Projeto" /*l_projeto*/ 
       and   btt_lista_inform_proj.ttv_log_selec     = yes
       and   btt_lista_inform_proj.ttv_cod_fill      = v_cod_proj_financ_aux,
    each btt_lista_inform_un
       where btt_lista_inform_un.ttv_cod_tip_lista = "Unidade Neg¢cio" /*l_unidade_negocio*/ 
       and   btt_lista_inform_un.ttv_log_selec     = yes
       and   btt_lista_inform_un.ttv_cod_fill      = v_cod_unid_negoc_aux:

        assign v_cod_proj_financ = btt_lista_inform_proj.ttv_cod_inform
               v_cod_cta_ctbl    = entry(2,btt_lista_inform_conta.ttv_cod_inform,chr(10))
               v_cod_ccusto      = entry(3,btt_lista_inform_ccusto.ttv_cod_inform,chr(10))
               v_cod_unid_negoc  = btt_lista_inform_un.ttv_cod_inform.


        /* ** SE FOR DEMONSTRATIVO CONTµBIL, CRIA A LINHA A SER MOSTRADA NA CONSULTA ***/
        if   v_num_seq_demonst_ctbl   <> 0
        and  v_num_seq_compos_demonst <> 0 
        and (lookup("Cont bil" /*l_contabil*/  , v_ind_espec_sdo_tot, chr(59)) <> 0
        or   lookup("Or‡amento" /*l_orcamento*/  , v_ind_espec_sdo_tot, chr(59)) <> 0) then do:

            assign v_cod_chave_1  = ""
                   v_cod_chave_2  = ""
                   v_cod_chave_3  = ""
                   v_cod_chave_4  = ""
                   v_cod_chave_5  = ""
                   v_cod_chave_6  = ""
                   v_log_cta_sint = no.
            do v_num_count_2 = 1 to (num-entries(v_cod_chave, chr(10)) - 1):
                if entry(v_num_count_2,v_cod_chave, chr(10)) = "Conta Cont bil" /*l_conta_contabil*/   then do:
                    if v_cod_chave_1 = "" then
                        assign v_cod_chave_1 = v_cod_cta_ctbl.
                    else
                    if v_cod_chave_2 = "" then
                        assign v_cod_chave_2 = v_cod_cta_ctbl.
                    else
                    if v_cod_chave_3 = "" then
                        assign v_cod_chave_3 = v_cod_cta_ctbl.
                    else
                    if v_cod_chave_4 = "" then
                        assign v_cod_chave_4 = v_cod_cta_ctbl.
                    else
                    if v_cod_chave_5 = "" then
                        assign v_cod_chave_5 = v_cod_cta_ctbl.
                    else
                    if v_cod_chave_6 = "" then
                        assign v_cod_chave_6 = v_cod_cta_ctbl.
                end.
                if entry(v_num_count_2,v_cod_chave, chr(10)) = "Centro de Custo" /*l_centro_de_custo*/   then do:
                    if v_cod_chave_1 = "" then
                        assign v_cod_chave_1 = v_cod_ccusto.
                    else
                    if v_cod_chave_2 = "" then
                        assign v_cod_chave_2 = v_cod_ccusto.
                    else
                    if v_cod_chave_3 = "" then
                        assign v_cod_chave_3 = v_cod_ccusto.
                    else
                    if v_cod_chave_4 = "" then
                        assign v_cod_chave_4 = v_cod_ccusto.
                    else
                    if v_cod_chave_5 = "" then
                        assign v_cod_chave_5 = v_cod_ccusto.
                    else
                    if v_cod_chave_6 = "" then
                        assign v_cod_chave_6 = v_cod_ccusto.
                end.
                if entry(v_num_count_2,v_cod_chave, chr(10)) = "Estabelecimento" /*l_estabelecimento*/   then do:
                    if v_cod_chave_1 = "" then
                        assign v_cod_chave_1 = v_cod_estab.
                    else
                    if v_cod_chave_2 = "" then
                        assign v_cod_chave_2 = v_cod_estab.
                    else
                    if v_cod_chave_3 = "" then
                        assign v_cod_chave_3 = v_cod_estab.
                    else
                    if v_cod_chave_4 = "" then
                        assign v_cod_chave_4 = v_cod_estab.
                    else
                    if v_cod_chave_5 = "" then
                        assign v_cod_chave_5 = v_cod_estab.
                    else
                    if v_cod_chave_6 = "" then
                        assign v_cod_chave_6 = v_cod_estab.
                end.
                if entry(v_num_count_2,v_cod_chave, chr(10)) = "Unidade Neg¢cio" /*l_unidade_negocio*/   then do:
                    if v_cod_chave_1 = "" then
                        assign v_cod_chave_1 = v_cod_unid_negoc.
                    else
                    if v_cod_chave_2 = "" then
                        assign v_cod_chave_2 = v_cod_unid_negoc.
                    else
                    if v_cod_chave_3 = "" then
                        assign v_cod_chave_3 = v_cod_unid_negoc.
                    else
                    if v_cod_chave_4 = "" then
                        assign v_cod_chave_4 = v_cod_unid_negoc.
                    else
                    if v_cod_chave_5 = "" then
                        assign v_cod_chave_5 = v_cod_unid_negoc.
                    else
                    if v_cod_chave_6 = "" then
                        assign v_cod_chave_6 = v_cod_unid_negoc.
                end.
                if entry(v_num_count_2,v_cod_chave, chr(10)) = "Projeto" /*l_projeto*/   then do:
                    if v_cod_chave_1 = "" then
                        assign v_cod_chave_1 = v_cod_proj_financ.
                    else
                    if v_cod_chave_2 = "" then
                        assign v_cod_chave_2 = v_cod_proj_financ.
                    else
                    if v_cod_chave_3 = "" then
                        assign v_cod_chave_3 = v_cod_proj_financ.
                    else
                    if v_cod_chave_4 = "" then
                        assign v_cod_chave_4 = v_cod_proj_financ.
                    else
                    if v_cod_chave_5 = "" then
                        assign v_cod_chave_5 = v_cod_proj_financ.
                    else
                    if v_cod_chave_6 = "" then
                        assign v_cod_chave_6 = v_cod_proj_financ.
                end.
            end.

            find tt_item_demonst_ctbl_video
               where tt_item_demonst_ctbl_video.ttv_val_seq_demonst_ctbl   = v_num_seq_demonst_ctbl
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_1            = v_cod_chave_1
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_2            = v_cod_chave_2
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_3            = v_cod_chave_3
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_4            = v_cod_chave_4
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_5            = v_cod_chave_5
                 and tt_item_demonst_ctbl_video.ttv_cod_chave_6            = v_cod_chave_6
                 no-lock no-error.
            if not avail tt_item_demonst_ctbl_video then
                next.

            find tt_relacto_item_retorna
               where tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
               and   tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
               and   tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl
               no-lock no-error.
            if not avail tt_relacto_item_retorna then do:
                create tt_relacto_item_retorna.
                assign tt_relacto_item_retorna.tta_num_seq          = tt_retorna_sdo_ctbl_demonst.tta_num_seq
                       tt_relacto_item_retorna.ttv_rec_item_demonst = tt_item_demonst_ctbl_video.ttv_rec_item_demonst_ctbl_video
                       tt_relacto_item_retorna.ttv_rec_ret          = tt_retorna_sdo_ctbl_demonst.ttv_rec_ret_sdo_ctbl.
            end.
        end.
    end.

END PROCEDURE. /* pi_leitura_sdo_ctbl_demonst_novo_1 */
/*****************************************************************************
** Procedure Interna.....: pi_leitura_sdo_orcto_more_1
** Descricao.............: pi_leitura_sdo_orcto_more_1
** Criado por............: bre17108
** Criado em.............: 09/11/2004 21:20:58
** Alterado por..........: bre17108
** Alterado em...........: 09/11/2004 21:21:22
*****************************************************************************/
PROCEDURE pi_leitura_sdo_orcto_more_1:

    case v_cod_leitura:
        when "find last" /*l_find_last*/   then do:
            case v_cod_condicao: 
                when "Igual" /*l_igual*/   then do:
                   run pi_leitura_find_last_igual.
                end.
                when "menor ou igual" /*l_menor_igual*/   then do:
                    if v_cod_plano_ccusto <> "" then do:
                        find LAST sdo_orcto_ctbl_bgc no-lock
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                            and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                            and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                            and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                            and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_ccusto     = v_cod_plano_ccusto
                            and  sdo_orcto_ctbl_bgc.cod_ccusto           = v_cod_ccusto_analit
                            and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                            and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                            and  sdo_orcto_ctbl_bgc.num_period_ctbl    <= v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                    else do:
                        find LAST sdo_orcto_ctbl_bgc no-lock
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                            and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                            and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                            and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                            and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                            and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                            and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                            and  sdo_orcto_ctbl_bgc.num_period_ctbl    <= v_num_period_ctbl no-error.
                         if  avail sdo_orcto_ctbl_bgc then do:
                             run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                         end.
                     end.
                 end.
                 when "Menor" /*l_menor*/   then do:
                     if v_cod_plano_ccusto <> "" then do:
                         find LAST sdo_orcto_ctbl_bgc no-lock
                            where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                            and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                            and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                            and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                            and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                            and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                            and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                            and sdo_orcto_ctbl_bgc.cod_plano_ccusto     = v_cod_plano_ccusto
                            and sdo_orcto_ctbl_bgc.cod_ccusto           = v_cod_ccusto_analit
                            and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                            and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                            and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                    else do:
                       find LAST sdo_orcto_ctbl_bgc no-lock
                          where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                          and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                          and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                          and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                          and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                          and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                          and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                          and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                          and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                          and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                          and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                          and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                          and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl no-error.
                       if  avail sdo_orcto_ctbl_bgc then do:
                           run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                       end.
                   end.
               end.
           end.
        end.
        when "find first" /*l_find_first*/  then do:
            case v_cod_condicao:
                when "Igual" /*l_igual*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                        find first sdo_orcto_ctbl_bgc no-lock
                             where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                              and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                              and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                              and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                              and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                              and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                              and sdo_orcto_ctbl_bgc.cod_plano_ccusto     = v_cod_plano_ccusto
                              and sdo_orcto_ctbl_bgc.cod_ccusto           = v_cod_ccusto_analit
                              and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                              and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                              and  sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /*pi_leitura_sdo_orcto_grava_tt*/.
                        end.
                    end.
                    else do:
                        find first sdo_orcto_ctbl_bgc no-lock
                             where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                              and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                              and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                              and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                              and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                              and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                              and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                              and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl      = v_cod_exerc_ctbl
                              and  sdo_orcto_ctbl_bgc.num_period_ctbl     = v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end. 
                end.
                when "menor ou igual" /*l_menor_igual*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                        find first sdo_orcto_ctbl_bgc no-lock
                          where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                           and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                           and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                           and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                           and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                           and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                           and sdo_orcto_ctbl_bgc.cod_plano_ccusto     = v_cod_plano_ccusto
                           and sdo_orcto_ctbl_bgc.cod_ccusto           = v_cod_ccusto_analit
                           and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                           and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                           and  sdo_orcto_ctbl_bgc.num_period_ctbl    <= v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /*pi_leitura_sdo_orcto_grava_tt*/.
                        end.
                    end.
                    else do:
                        find first sdo_orcto_ctbl_bgc no-lock
                           where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                           and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                           and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                           and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                           and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                           and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                           and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                           and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                           and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                           and  sdo_orcto_ctbl_bgc.num_period_ctbl    <= v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                        end.
                    end.
                end.
                when "Menor" /*l_menor*/  then do:
                    if v_cod_plano_ccusto <> "" then do:
                       find first sdo_orcto_ctbl_bgc no-lock 
                            where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                             and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                             and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                             and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                             and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                             and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                             and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                             and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                             and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                             and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit 
                             and sdo_orcto_ctbl_bgc.cod_plano_ccusto     = v_cod_plano_ccusto
                             and sdo_orcto_ctbl_bgc.cod_ccusto           = v_cod_ccusto_analit
                             and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                             and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                             and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl no-error.
                       if  avail sdo_orcto_ctbl_bgc then do:
                           run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1).
                       end.
                    end.
                    else do:
                        find first sdo_orcto_ctbl_bgc no-lock 
                             where sdo_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                              and  sdo_orcto_ctbl_bgc.cod_unid_orctaria   = v_cod_unid_orctaria
                              and  sdo_orcto_ctbl_bgc.num_seq_orcto_ctbl  = v_num_seq_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_vers_orcto_ctbl = v_cod_vers_orcto_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cenar_ctbl      = tt_empresa_leitura_sdo.tta_cod_cenar_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_empresa         = tt_empresa_leitura_sdo.tta_cod_empresa
                              and  sdo_orcto_ctbl_bgc.cod_estab           = v_cod_estab
                              and  sdo_orcto_ctbl_bgc.cod_unid_negoc      = v_cod_unid_negoc_analit
                              and  sdo_orcto_ctbl_bgc.cod_plano_cta_ctbl  = tt_empresa_leitura_sdo.tta_cod_plano_cta_ctbl
                              and  sdo_orcto_ctbl_bgc.cod_cta_ctbl        = v_cod_cta_ctbl_analit
                              and  sdo_orcto_ctbl_bgc.cod_proj_financ     = v_cod_proj_financ_analit
                              and  sdo_orcto_ctbl_bgc.cod_exerc_ctbl     <= v_cod_exerc_ctbl
                              and  sdo_orcto_ctbl_bgc.num_period_ctbl     < v_num_period_ctbl no-error.
                        if  avail sdo_orcto_ctbl_bgc then do:
                            run pi_leitura_sdo_orcto_grava_tt (Input v_num_seq_1) /*pi_leitura_sdo_orcto_grava_tt*/.
                        end.
                    end.
                end.
            end.
        end.
    end.

END PROCEDURE. /* pi_leitura_sdo_orcto_more_1 */
/*****************************************************************************
** Procedure Interna.....: pi_busca_vers_orcto_unid_orctaria
** Descricao.............: pi_busca_vers_orcto_unid_orctaria
** Criado por............: bre17108
** Criado em.............: 16/11/2004 08:47:27
** Alterado por..........: fut12136
** Alterado em...........: 22/11/2004 20:27:36
*****************************************************************************/
PROCEDURE pi_busca_vers_orcto_unid_orctaria:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_unid_orctaria
        as character
        format "x(8)"
        no-undo.
    def Input param p_num_seq_orcto_ctbl
        as integer
        format ">>>>>>>>9"
        no-undo.
    def Input param p_cod_vers_orcto_ctbl
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_vers_orcto_ctbl_aux
        as character
        format "x(10)":U
        label "VersÆo Or‡amento"
        column-label "VersÆo Or‡amento"
        no-undo.


    /************************** Variable Definition End *************************/

    &IF DEFINED (BF_FIN_CONSOLID_UNID_ORCTARIA) &THEN
        for each vers_orcto_unid_orctaria no-lock
           where vers_orcto_unid_orctaria.cod_cenar_orctario  = v_cod_cenar_orctario
           and   vers_orcto_unid_orctaria.cod_unid_orctaria   = p_cod_unid_orctaria
           and   vers_orcto_unid_orctaria.num_seq_orcto_ctbl  = p_num_seq_orcto_ctbl
           and   vers_orcto_unid_orctaria.cod_vers_orcto_ctbl = p_cod_vers_orcto_ctbl:

            assign v_cod_vers_orcto_ctbl_aux = "" /*l_null*/ .

            if vers_orcto_unid_orctaria.ind_tip_relacto = "Informada" /*l_informada*/  then do:
                assign v_cod_vers_orcto_ctbl_aux = vers_orcto_unid_orctaria.cod_vers_orcto_ctbl_filho.
            end.
            else if vers_orcto_unid_orctaria.ind_tip_relacto = "éltima VersÆo" /*l_ultima_versao*/  then do:
                find last vers_orcto_ctbl_bgc
                   where vers_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                   and   vers_orcto_ctbl_bgc.cod_unid_orctaria   = vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                   and   vers_orcto_ctbl_bgc.num_seq_orcto_ctbl  = vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho
                   no-lock no-error.
                if avail vers_orcto_ctbl_bgc then do:
                    assign v_cod_vers_orcto_ctbl_aux = vers_orcto_ctbl_bgc.cod_vers_orcto_ctbl.
                end.
            end.
            else if vers_orcto_unid_orctaria.ind_tip_relacto = "Primeira VersÆo" /*l_primeira_versao*/  then do:
                find first vers_orcto_ctbl_bgc
                   where vers_orcto_ctbl_bgc.cod_cenar_orctario  = v_cod_cenar_orctario
                   and   vers_orcto_ctbl_bgc.cod_unid_orctaria   = vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                   and   vers_orcto_ctbl_bgc.num_seq_orcto_ctbl  = vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho
                   no-lock no-error.
                if avail vers_orcto_ctbl_bgc then do:
                    assign v_cod_vers_orcto_ctbl_aux = vers_orcto_ctbl_bgc.cod_vers_orcto_ctbl.
                end.
            end.
            else if vers_orcto_unid_orctaria.ind_tip_relacto = "VersÆo Aprovada" /*l_versao_aprovada*/  then do:
                find vers_orcto_ctbl_bgc
                   where vers_orcto_ctbl_bgc.cod_cenar_orctario      = v_cod_cenar_orctario
                   and   vers_orcto_ctbl_bgc.cod_unid_orctaria       = vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                   and   vers_orcto_ctbl_bgc.num_seq_orcto_ctbl      = vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho
                   and   vers_orcto_ctbl_bgc.num_sit_vers_orcto_ctbl = 2
                   no-lock no-error.
                if avail vers_orcto_ctbl_bgc then do:
                    assign v_cod_vers_orcto_ctbl_aux = vers_orcto_ctbl_bgc.cod_vers_orcto_ctbl.
                end.
            end.

            if v_cod_vers_orcto_ctbl_aux <> "" /*l_null*/  then do:
                find unid_orctaria
                   where unid_orctaria.cod_unid_orctaria = vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                   no-lock no-error.
                if  avail unid_orctaria 
                and unid_orctaria.ind_espec_unid_orctaria = "Sint‚tica" /*l_sintetica*/  then do:
                    run pi_busca_vers_orcto_unid_orctaria (Input vers_orcto_unid_orctaria.cod_unid_orctaria_filho,
                                                           Input vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho,
                                                           Input v_cod_vers_orcto_ctbl_aux) /*pi_busca_vers_orcto_unid_orctaria*/.
                end.
                else do:
                    if v_cod_unid_orctaria_tot = "" /*l_null*/  then
                        assign v_cod_unid_orctaria_tot   = vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                               v_cod_seq_orcto_ctbl_tot  = string(vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho)
                               v_cod_vers_orcto_ctbl_tot = v_cod_vers_orcto_ctbl_aux.
                    else
                        assign v_cod_unid_orctaria_tot   = v_cod_unid_orctaria_tot   + chr(10) + vers_orcto_unid_orctaria.cod_unid_orctaria_filho
                               v_cod_seq_orcto_ctbl_tot  = v_cod_seq_orcto_ctbl_tot  + chr(10) + string(vers_orcto_unid_orctaria.num_seq_orcto_ctbl_filho)
                               v_cod_vers_orcto_ctbl_tot = v_cod_vers_orcto_ctbl_tot + chr(10) + v_cod_vers_orcto_ctbl_aux.
                end.
            end.
        end.
    &ENDIF
END PROCEDURE. /* pi_busca_vers_orcto_unid_orctaria */
/*****************************************************************************
** Procedure Interna.....: pi_achar_unid_orctaria_filho
** Descricao.............: pi_achar_unid_orctaria_filho
** Criado por............: fut41162
** Criado em.............: 09/09/2009 10:21:42
** Alterado por..........: fut41162
** Alterado em...........: 09/09/2009 10:41:34
*****************************************************************************/
PROCEDURE pi_achar_unid_orctaria_filho:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_unid_orctaria_pai
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    &IF DEFINED (BF_FIN_CONSOLID_UNID_ORCTARIA) &THEN
        for each estrut_unid_orctaria no-lock
            where estrut_unid_orctaria.cod_unid_orctaria_pai = p_cod_unid_orctaria_pai:
            find b_unid_orctaria_enter no-lock
                where b_unid_orctaria_enter.cod_unid_orctaria = estrut_unid_orctaria.cod_unid_orctaria_filho no-error.
            if avail b_unid_orctaria_enter
            and b_unid_orctaria_enter.ind_espec_unid_orctaria = "Sint‚tica" /*l_sintetica*/   then 
                run pi_achar_unid_orctaria_filho (Input estrut_unid_orctaria.cod_unid_orctaria_filho) /* pi_achar_unid_orctaria_filho*/.
            else do:
                find tt_unid_orctaria no-lock
                    where tt_unid_orctaria.tta_cod_unid_orctaria = estrut_unid_orctaria.cod_unid_orctaria_filho no-error.
                if not avail tt_unid_orctaria then do:
                    create tt_unid_orctaria.
                    assign tt_unid_orctaria.tta_cod_unid_orctaria = estrut_unid_orctaria.cod_unid_orctaria_filho.
                end.
            end.
        end.
    &ENDIF
END PROCEDURE. /* pi_achar_unid_orctaria_filho */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/
&endif

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
        message "Mensagem nr. " i_msg "!!!":U skip
                "Programa Mensagem" c_prg_msg "nÆo encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/*******************  End of api_retornar_sdo_ctbl_demonst ******************/
