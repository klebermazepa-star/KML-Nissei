/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: rpt_tit_acr_em_aberto
** Descricao.............: Demonstrativo T°tulos em Aberto
** Versao................:  1.00.00.173
** Procedimento..........: rel_tit_acr_em_aber
** Nome Externo..........: prgfin/acr/acr303aa.py
** Data Geracao..........: 02/07/2013 - 11:15:11
** Criado por............: Uno
** Criado em.............: 24/12/1996 08:56:40
** Alterado por..........: fut43120
** Alterado em...........: 04/06/2013 10:31:42
** Gerado por............: fut43120
*****************************************************************************/
DEFINE BUFFER empresa               FOR ems5.empresa.
DEFINE BUFFER histor_exec_especial  FOR ems5.histor_exec_especial.
DEFINE BUFFER cliente               FOR ems5.cliente.
DEFINE BUFFER portador              FOR ems5.portador.
DEFINE BUFFER espec_docto           FOR ems5.espec_docto.
DEFINE BUFFER unid_negoc            FOR ems5.unid_negoc.
DEFINE BUFFER pais                  FOR ems5.pais.
DEFINE BUFFER segur_unid_organ      FOR ems5.segur_unid_organ.
DEFINE BUFFER bf_tit_acr            FOR tit_acr.


def var c-versao-prg as char initial " 1.00.00.173":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

/* Alteracao via filtro - Controle de impressao - inicio */
{include/i_prdvers.i}
/* Alteracao via filtro - Controle de impressao - fim    */

{include/i_fcldef.i}

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i rpt_tit_acr_em_aberto ACR}
&ENDIF

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=37":U.
/*************************************  *************************************/

&if "{&emsfin_dbinst}" <> "yes" &then
run pi_messages (input "show",
                 input 5884,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "EMSFIN")) /*msg_5884*/.
&elseif "{&emsfin_version}" < "5.01" &then
run pi_messages (input "show",
                 input 5009,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "RPT_TIT_ACR_EM_ABERTO","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
&else

/********************* Temporary Table Definition Begin *********************/

def new shared temp-table tt_ccustos_demonst no-undo
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

def new shared temp-table tt_cta_ctbl_demonst no-undo
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field ttv_cod_cta_ctbl_pai             as character format "x(20)" label "Conta Ctbl Pai" column-label "Conta Ctbl Pai"
    field ttv_log_consid_apurac            as logical format "Sim/N∆o" initial no
    field tta_ind_espec_cta_ctbl           as character format "X(10)" initial "Anal°tica" label "EspÇcie Conta" column-label "EspÇcie"
    index tt_cod_cta_ctbl_pai             
          tta_cod_plano_cta_ctbl           ascending
          ttv_cod_cta_ctbl_pai             ascending
    index tt_select_id                     is primary unique
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
    .

def temp-table tt_empresa no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_id                           
          tta_cod_empresa                  ascending
    .

def temp-table tt_empresa_selec no-undo like ems5.empresa
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_cod_empresa                   is primary unique
          tta_cod_empresa                  ascending
    .

def temp-table tt_espec_docto no-undo
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    index tt_espec_docto                  
          tta_cod_espec_docto              ascending
    .

def temp-table tt_estabelecimento_empresa no-undo like estabelecimento
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_nom_razao_social             as character format "x(40)" label "Raz∆o Social" column-label "Raz∆o Social"
    field ttv_log_selec                    as logical format "Sim/N∆o" initial no column-label "Gera"
    index tt_cod_estab                     is primary unique
          tta_cod_estab                    ascending
    .

def temp-table tt_estab_unid_negoc no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    index tt_estab_unid_negoc              is primary unique
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
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
    field tta_cod_cta_ctbl_fim             as character format "x(20)" label "atÇ" column-label "Conta Cont†bil Final"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto_inic              as Character format "x(11)" label "Centro Custo" column-label "Centro Custo Inicial"
    field tta_cod_ccusto_fim               as Character format "x(11)" label "atÇ" column-label "Centro Custo Final"
    field tta_cod_proj_financ_inic         as character format "x(8)" label "N∆o Utilizar..." column-label "Projeto"
    field tta_cod_proj_financ_fim          as character format "x(20)" label "Projeto Final" column-label "Projeto Final"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen†rio Cont†bil" column-label "Cen†rio Cont†bil"
    field tta_cod_estab_inic               as character format "x(3)" label "Estabelecimento" column-label "Estab Inicial"
    field tta_cod_estab_fim                as character format "x(3)" label "atÇ" column-label "Estabel Final"
    field tta_cod_unid_negoc_inic          as character format "x(3)" label "Unid Negoc" column-label "UN Inicial"
    field tta_cod_unid_negoc_fim           as character format "x(3)" label "atÇ" column-label "UN Final"
    field ttv_ind_espec_sdo_tot            as character format "X(15)"
    field ttv_log_consid_apurac_restdo     as logical format "Sim/N∆o" initial yes label "Consid Apurac Restdo" column-label "Apurac Restdo"
    field ttv_cod_elimina_intercomp        as character format "x(20)"
    field ttv_log_espec_sdo_ccusto         as logical format "Sim/N∆o" initial no
    field ttv_log_restric_estab            as logical format "Sim/N∆o" initial no label "Usa Segur Estab" column-label "Usa Segur Estab"
    field ttv_ind_espec_cta                as character format "X(10)"
    field ttv_cod_leitura                  as character format "x(8)"
    field ttv_cod_condicao                 as character format "x(20)"
    field ttv_cod_cenar_orctario           as character format "x(8)" label "Cenar Orctario" column-label "Cen†rio Oráament†rio"
    field ttv_cod_unid_orctaria            as character format "x(8)" label "Unid Oráament†ria" column-label "Unid Oráament†ria"
    field ttv_num_seq_orcto_ctbl           as integer format ">>>>>>>>9" initial 0 label "Seq Orcto Cont†bil" column-label "Seq Orcto Cont†bil"
    field ttv_cod_vers_orcto_ctbl          as character format "x(10)" label "Vers∆o Oráamento" column-label "Vers∆o Oráamento"
    field ttv_cod_cta_ctbl_pfixa           as character format "x(20)" initial "####################" label "Parte Fixa" column-label "Parte Fixa Cta Ctbl"
    field ttv_cod_ccusto_pfixa             as character format "x(11)" initial "..........." label "Parte Fixa CCusto" column-label "Parte Fixa CCusto"
    field ttv_cod_proj_financ_pfixa        as character format "x(20)" label "Parte Fixa"
    field ttv_cod_cta_ctbl_excec           as character format "x(20)" initial "...................." label "Parte Exceá∆o" column-label "Parte Exceá∆o"
    field ttv_cod_ccusto_excec             as character format "x(11)" initial "..........." label "Parte Exceá∆o" column-label "Parte Exceá∆o"
    field ttv_cod_proj_financ_excec        as character format "x(20)" initial "...................." label "Exceá∆o" column-label "Exceá∆o"
    field ttv_num_seq_demonst_ctbl         as integer format ">>>,>>9" initial 0 label "Sequància" column-label "Sequància"
    field ttv_num_seq_compos_demonst       as integer format ">>>>,>>9"
    field ttv_cod_chave                    as character format "x(40)"
    field ttv_cod_seq                      as character format "x(200)"
    field ttv_cod_dat_sdo_ctbl_inic        as character format "x(200)"
    field ttv_cod_dat_sdo_ctbl_fim         as character format "x(200)"
    field ttv_cod_exerc_ctbl               as character format "9999" label "Exerc°cio Cont†bil" column-label "Exerc°cio Cont†bil"
    field ttv_cod_period_ctbl              as character format "x(08)" label "Per°odo Cont†bil" column-label "Per°odo Cont†bil"
    .

def new shared temp-table tt_item_demonst_ctbl_video no-undo
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
    field tta_des_tit_ctbl                 as character format "x(40)" label "T°tulo Cont†bil" column-label "T°tulo Cont†bil"
    field ttv_des_valpres                  as character format "x(40)"
    field ttv_log_tit_ctbl_vld             as logical format "Sim/N∆o" initial no
    field tta_ind_funcao_col_demonst_ctbl  as character format "X(12)" initial "Impress∆o" label "Funá∆o Coluna" column-label "Funá∆o Coluna"
    field tta_ind_orig_val_col_demonst     as character format "X(12)" initial "T°tulo" label "Origem Valores" column-label "Origem Valores"
    field tta_cod_format_col_demonst_ctbl  as character format "x(40)" label "Formato Coluna" column-label "Formato Coluna"
    field ttv_cod_identif_campo            as character format "x(40)"
    field ttv_log_cta_sint                 as logical format "Sim/N∆o" initial no
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

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "SeqÅància" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistància" column-label "Inconsistància"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    index tt_id                           
          ttv_num_seq                      ascending
          ttv_num_cod_erro                 ascending
    .

def temp-table tt_log_erros_aux no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "SeqÅància" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistància" column-label "Inconsistància"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    .

def new shared temp-table tt_proj_financ_demonst no-undo
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

def new shared temp-table tt_relacto_item_retorna no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequància" column-label "NumSeq"
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

def new shared temp-table tt_relacto_item_retorna_cons no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequància" column-label "NumSeq"
    field ttv_rec_ret_orig                 as recid format ">>>>>>9"
    field ttv_rec_ret_dest                 as recid format ">>>>>>9"
    index tt_id                           
          tta_num_seq                      ascending
          ttv_rec_ret_orig                 ascending
          ttv_rec_ret_dest                 ascending
    index tt_recid_item                   
          ttv_rec_ret_orig                 ascending
    .

def temp-table tt_resumo_conta no-undo
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_resumo_conta_id               is unique
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
    .

def temp-table tt_resumo_conta_estab_acr no-undo
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_val_sdo_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo T°tulo" column-label "Saldo T°tulo"
    field ttv_val_sdo_ctbl                 as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Saldo Cont†bil" column-label "Saldo Cont†bil"
    field ttv_val_diferenca                as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_resumo_conta_estab_un_id     
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_estab                    ascending
          tta_cod_unid_negoc               ascending
    .

def new shared temp-table tt_retorna_sdo_ctbl_demonst no-undo
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequància" column-label "NumSeq"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_proj_financ              as character format "x(20)" label "Projeto" column-label "Projeto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen†rio Cont†bil" column-label "Cen†rio Cont†bil"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_dat_sdo_ctbl                 as date format "99/99/9999" initial ? label "Data Saldo Cont†bil" column-label "Data Saldo Cont†bil"
    field tta_cod_unid_organ_orig          as character format "x(3)" label "UO Origem" column-label "UO Origem"
    field ttv_ind_espec_sdo                as character format "X(20)"
    field tta_val_sdo_ctbl_db              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto DÇbito" column-label "Movto DÇbito"
    field tta_val_sdo_ctbl_cr              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto CrÇdito" column-label "Movto CrÇdito"
    field tta_val_sdo_ctbl_fim             as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Cont†bil Final" column-label "Saldo Cont†bil Final"
    field tta_val_apurac_restdo            as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apuraá∆o Resultado" column-label "Apuraá∆o Resultado"
    field tta_val_apurac_restdo_db         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apuraá∆o Restdo DB" column-label "Apuraá∆o Restdo DB"
    field tta_val_apurac_restdo_cr         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apuraá∆o Restdo CR" column-label "Apuraá∆o Restdo CR"
    field tta_val_apurac_restdo_acum       as decimal format "->>>>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apuracao Final" column-label "Apuracao Final"
    field tta_val_movto_empenh             as decimal format "->>,>>>,>>>,>>9.99" decimals 9 initial 0 label "Movto Empenhado" column-label "Movto Empenhado"
    field tta_qtd_sdo_ctbl_db              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade DB" column-label "Quantidade DB"
    field tta_qtd_sdo_ctbl_cr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade CR" column-label "Quantidade CR"
    field tta_qtd_sdo_ctbl_fim             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Quantidade Final" column-label "Quantidade Final"
    field ttv_val_movto_ctbl               as decimal format ">>>,>>>,>>>,>>9.99" decimals 2
    field ttv_qtd_movto_ctbl               as decimal format "->>>>,>>9.9999" decimals 4
    field tta_qtd_movto_empenh             as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtde Movto Empenhado" column-label "Qtde Movto Empenhado"
    field tta_val_orcado                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Oráado" column-label "Valor Oráado"
    field tta_val_orcado_sdo               as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Oráado" column-label "Saldo Oráado"
    field tta_qtd_orcado                   as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtdade Oráada" column-label "Qtdade Oráada"
    field tta_qtd_orcado_sdo               as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Saldo Quantidade" column-label "Saldo Quantidade"
    field ttv_rec_ret_sdo_ctbl             as recid format ">>>>>>9"
    field ttv_log_sdo_orcado_sint          as logical format "Sim/N∆o" initial no
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

def new shared temp-table tt_retorna_sdo_orcto_ccusto no-undo
    field ttv_rec_ret_sdo_ctbl             as recid format ">>>>>>9"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_val_orcado                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Oráado" column-label "Valor Oráado"
    field tta_val_orcado_sdo               as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Oráado" column-label "Saldo Oráado"
    field tta_qtd_orcado                   as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Qtdade Oráada" column-label "Qtdade Oráada"
    field tta_qtd_orcado_sdo               as decimal format "->>>>,>>9.9999" decimals 4 initial 0 label "Saldo Quantidade" column-label "Saldo Quantidade"
    index tt_id                            is primary unique
          ttv_rec_ret_sdo_ctbl             ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
    .

def new shared temp-table tt_titulos_em_aberto_acr no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo EspÇcie" column-label "Tipo EspÇcie"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field ttv_nom_abrev_clien              as character format "x(12)" label "Cliente" column-label "Cliente"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field ttv_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abrev"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cdn_clien_matriz             as Integer format ">>>,>>>,>>9" initial 0 label "Cliente Matriz" column-label "Cliente Matriz"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_liquidac_tit_acr         as date format "99/99/9999" initial ? label "Liquidaá∆o" column-label "Liquidaá∆o"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_origin_tit_acr           as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Original T°tulo" column-label "Vl Original T°tulo"
    field tta_val_sdo_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo T°tulo" column-label "Saldo T°tulo"
    field ttv_val_origin_tit_acr_apres     as decimal format "->>>,>>>,>>9.99" decimals 2 label "Vl Original Apres" column-label "Vl Original Apres"
    field ttv_val_sdo_tit_acr_apres        as decimal format "->>>,>>>,>>9.99" decimals 2 label "Saldo Finalid Apres" column-label "Saldo Apres"
    field ttv_num_atraso_dias_acr          as integer format "->>>>>>9" label "Dias" column-label "Dias"
    field ttv_val_movto_tit_acr_pmr        as decimal format "->>>,>>>,>>>,>>9.99" decimals 2 label "Val Movto PMR" column-label "Val Movto PMR"
    field ttv_val_movto_tit_acr_amr        as decimal format "->>>,>>>,>>>,>>9.99" decimals 2 label "Val Movto AMR" column-label "Val Movto AMR"
    field tta_val_movto_tit_acr            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Movimento" column-label "Vl Movimento"
    field ttv_rec_tit_acr                  as recid format ">>>>>>9"
    field ttv_cod_dwb_field_rpt            as character extent 9 format "x(32)" label "Conjunto" column-label "Conjunto"
    field tta_cod_grp_clien                as character format "x(4)" label "Grupo Cliente" column-label "Grupo Cliente"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num T°tulo Banco" column-label "Num T°tulo Banco"
    field tta_dat_indcao_perda_dedut       as date format "99/99/9999" initial ? label "Data Indicaá∆o" column-label "Data Indicaá∆o"
    field ttv_dat_tit_acr_aber             as date format "99/99/9999" initial today label "Posiá∆o Em" column-label "Posiá∆o Em"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condiá∆o Cobranáa" column-label "Cond Cobranáa"
    field tta_val_desc_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field ttv_val_impto_retid              as decimal format ">>>>,>>>,>>9.99" decimals 2 label "Impto Retido" column-label "Imposto Retido"
    field tta_val_juros                    as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    field ttv_nom_cidad_cobr               as character format "x(30)" label "Cidade Cobranáa" column-label "Cidade Cobranáa"
    FIELD ttv_cod_convenio                 as character format "x(30)" label "Convànio" column-label "Convànio"
    FIELD ttv_cod_cliente                  as character format "x(30)" label "Cliente Convànio" column-label "Cliente Convànio"
    FIELD ttv_nome_cliente                 as character format "x(30)" label "Nome Convànio" column-label "Nome Convànio"
    FIELD ttv_id_pedido                    LIKE  cst_nota_fiscal.id_pedido_convenio
    FIELD ttv_num_renegoc_cobr_acr         LIKE tit_acr.num_renegoc_cobr_acr
    index tt_cod_empr_estab               
          tta_cod_empresa                  ascending
          tta_cdn_cliente                  ascending
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_unid_negoc               ascending
    index tt_proc_export                  
          ttv_cod_proces_export            ascending
    .

def temp-table tt_titulos_em_aberto_acr_compl no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_nom_cidade                   as character format "x(32)" label "Cidade" column-label "Cidade"
    field tta_cod_telefone                 as character format "x(20)" label "Telefone" column-label "Telefone"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_unid_negoc               ascending
    .

def temp-table tt_tot_movtos_acr no-undo
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field ttv_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field ttv_val_tot_movto                as decimal format "->>,>>>,>>9.99" decimals 2 label "Valor Total" column-label "Valor Total"
    field ttv_num_ord_reg                  as integer format ">>9" label "Ordem Registro" column-label "Ordem Registro"
    field ttv_dat_initial                  as date format "99/99/9999" label "Data Inicial" column-label "Data Inicial"
    field ttv_dat_final                    as date format "99/99/9999" label "Data Final" column-label "Data Final"
    field ttv_ind_vencid_avencer           as character format "X(08)" initial "Vencidos" label "Vencid/a Vencer" column-label "Vencid/a Vencer"
    field ttv_num_dias_avencer_2           as integer format ">>>9" initial 31 label "de" column-label "de"
    field ttv_num_dias_avencer_3           as integer format ">>>9" initial 60 label "atÇ" column-label "atÇ"
    field ttv_log_graf                     as logical format "Sim/N∆o" initial no label "Gr†fico" column-label "Gr†fico"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field ttv_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    field tta_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    field ttv_val_tot_geral_antecip        as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Total Antecipado" column-label "Total Antecipado"
    field ttv_val_tot_geral_normal         as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Total de T°tulos" column-label "Total de T°tulos"
    .

def new shared temp-table tt_unid_negocio no-undo
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field ttv_cod_unid_negoc_pai           as character format "x(3)" label "Un Neg Pai" column-label "Un Neg Pai"
    field ttv_log_proces                   as logical format "Sim/Nao" initial no label "&prc(" column-label "&prc("
    field ttv_ind_espec_unid_negoc         as character format "X(10)" initial "Anal°tica" label "EspÇcie UN" column-label "EspÇcie UN"
    index tt_cod_unid_negoc_pai           
          ttv_cod_unid_negoc_pai           ascending
    index tt_log_proces                   
          ttv_log_proces                   ascending
    index tt_select_id                     is primary unique
          tta_cod_unid_negoc               ascending
    .

def temp-table tt_usuar_grp_usuar no-undo like usuar_grp_usuar
    .

def temp-table tt_valores_prazo no-undo
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field ttv_val_sdo_apres_vencid         as decimal extent 7 format "->>,>>>,>>>,>>9.99" decimals 2 label "Vl Saldo Apres" column-label "Vl Saldo Apres"
    field ttv_val_sdo_apres_avencer        as decimal extent 7 format "->>,>>>,>>>,>>9.99" decimals 2 label "Vl Saldo Apres" column-label "Vl Saldo Apres"
    field ttv_val_tot_sdo_vencid           as decimal format "->>>,>>>,>>>,>>9.99" decimals 2 label "Tot Saldo Vencid" column-label "Tot Saldo Vencid"
    field ttv_val_tot_sdo_avencer          as decimal format "->>>,>>>,>>>,>>9.99" decimals 2 label "Tot Saldo a Vencer" column-label "Tot Saldo a Vencer"
    field ttv_val_tot_antecip              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Total Antecipaá∆o" column-label "Total Antecipaá∆o"
    index tt_id                            is primary unique
          tta_cdn_cliente                  ascending
    .



/********************** Temporary Table Definition End **********************/

/************************** Buffer Definition Begin *************************/

def buffer btt_tot_movtos_acr
    for tt_tot_movtos_acr.
def buffer btt_tot_movtos_acr_proc
    for tt_tot_movtos_acr.
def buffer btt_tot_movtos_acr_un
    for tt_tot_movtos_acr.
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_compl_cond_cobr_acr
    for compl_cond_cobr_acr.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_finalid_econ
    for finalid_econ.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_finalid_unid_organ
    for finalid_unid_organ.
&endif
&if "{&emsbas_version}" >= "1.00" &then
def buffer b_ped_exec_style
    for ped_exec.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_segur_unid_organ
    for ems5.segur_unid_organ.
&endif
&if "{&emsbas_version}" >= "1.00" &then
def buffer b_servid_exec_style
    for servid_exec.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_unid_organ
    for ems5.unid_organ.
&endif


/*************************** Buffer Definition End **************************/

/************************** Stream Definition Begin *************************/

def new shared stream s_1.
def stream s_planilha.


/*************************** Stream Definition End **************************/

/************************* Variable Definition Begin ************************/

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
DEFINE VARIABLE v_page_number                   AS INTEGER INITIAL -1 NO-UNDO.
DEFINE VARIABLE v_cod_usuar_abert               AS CHARACTER          NO-UNDO.

&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
DEFINE VARIABLE c-servid_exec_nom_dir_spool     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod_dwb_user                  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-num_ped_exec                  AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-usuar_mestre_nom_subdir_spool AS CHARACTER   NO-UNDO.

DEFINE BUFFER b-dwb_rpt_param FOR dwb_rpt_param.
&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim */


def new shared var v_cdn_cliente_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "atÇ"
    column-label "Cliente Final"
    no-undo.
def new shared var v_cdn_cliente_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente Inicial"
    no-undo.
def new shared var v_cdn_clien_matriz_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_cdn_clien_matriz_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente Matriz"
    column-label "Cliente Matriz"
    no-undo.
def new shared var v_cdn_repres_fim
    as Integer
    format ">>>,>>9":U
    initial 999999
    label "atÇ"
    column-label "Repres Final"
    no-undo.
def new shared var v_cdn_repres_ini
    as Integer
    format ">>>,>>9":U
    initial 0
    label "Representante"
    column-label "Repres Inicial"
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def new shared var v_cod_arq_modul
    as character
    format "x(8)":U
    no-undo.
def new shared var v_cod_arq_planilha
    as character
    format "x(40)":U
    label "Arq Planilha"
    column-label "Arq Planilha"
    no-undo.
def new shared var v_cod_carac_lim
    as character
    format "x(1)":U
    initial ";"
    label "Caracter Delimitador"
    no-undo.
def new shared var v_cod_cart_bcia_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Carteira"
    no-undo.
def new shared var v_cod_cart_bcia_ini
    as character
    format "x(3)":U
    label "Carteira"
    column-label "Carteira"
    no-undo.

/* ---------------------------
Erro
---------------------------
prgfin/acr/acr303za_Convenio.p Variavel shared v_cod_num_contrat_fim ainda nao foi criada. (392)
---------------------------
OK   
---------------------------
 */
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_cep
    as character
    format "x(20)":U
    label "CEP"
    column-label "CEP"
    no-undo.
def var v_cod_cep_dest_cobr
    as character
    format "x(20)":U
    label "CEP"
    column-label "CEP"
    no-undo.
def new shared var v_cod_cond_cobr_fim
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_cod_cond_cobr_ini
    as character
    format "x(8)":U
    label "Condiá∆o Cobranáa"
    column-label "Cond Cobranáa"
    no-undo.
def var v_cod_cta_ctbl
    as character
    format "x(20)":U
    label "Conta Cont†bil"
    column-label "Conta Cont†bil"
    no-undo.
def new shared var v_cod_cta_ctbl_final
    as character
    format "x(20)":U
    initial "ZZZZZZZZZZZZZZZZZZZZ"
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_cod_cta_ctbl_ini
    as character
    format "x(20)":U
    label "Conta Inicial"
    column-label "Inicial"
    no-undo.
def var v_cod_cx_post
    as character
    format "x(20)":U
    label "Cxa Postal"
    no-undo.
def new shared var v_cod_dwb_file
    as character
    format "x(40)":U
    label "Arquivo"
    column-label "Arquivo"
    no-undo.
def var v_cod_dwb_file_temp
    as character
    format "x(12)":U
    no-undo.
def var v_cod_dwb_parameters
    as character
    format "x(8)":U
    no-undo.
def var v_cod_dwb_print_layout
    as character
    format "x(8)":U
    no-undo.
def var v_cod_dwb_proced
    as character
    format "x(8)":U
    no-undo.
def new shared var v_cod_dwb_program
    as character
    format "x(32)":U
    label "Programa"
    column-label "Programa"
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu†rio"
    column-label "Usu†rio"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def var v_cod_ender_eletron
    as character
    format "x(50)":U
    no-undo.
def var v_cod_erro
    as character
    format "x(10)":U
    column-label "Cod Erro"
    no-undo.
def new shared var v_cod_espec_docto_fim
    as character
    format "x(3)":U
    initial "CV"
    label "atÇ"
    column-label "C¢digo Final"
    no-undo.
def new shared var v_cod_espec_docto_ini
    as character
    format "x(3)":U
    label "EspÇcie"
    column-label "C¢digo Inicial"
    INITIAL "CF"
    no-undo.
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def new shared var v_cod_estab_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def new shared var v_cod_estab_fim
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def new shared var v_cod_estab_ini
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def new shared var v_cod_estab_ini
    as Character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_fax_dest
    as character
    format "x(8)":U
    no-undo.
def var v_cod_finalid_econ
    as character
    format "x(10)":U
    label "Finalidade Econìmica"
    column-label "Finalidade Econìmica"
    no-undo.
def var v_cod_finalid_econ_apres
    as character
    format "x(10)":U
    initial "Corrente" /*l_corrente*/
    label "Finalid Apresentaá∆o"
    column-label "Finalid Apresentaá∆o"
    no-undo.
def var v_cod_finalid_econ_aux
    as character
    format "x(10)":U
    label "Finalidade"
    column-label "Finalidade"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new shared var v_cod_grp_clien_fim
    as character
    format "x(4)":U
    initial "ZZZZ"
    label "atÇ"
    column-label "Grupo Cliente"
    no-undo.
def new shared var v_cod_grp_clien_ini
    as character
    format "x(4)":U
    label "Grupo Cliente"
    column-label "Grupo Cliente"
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
def new shared var v_cod_indic_econ_fim
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "atÇ"
    column-label "Final"
    no-undo.
def new shared var v_cod_indic_econ_ini
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Inicial"
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
def new shared var v_cod_order_rpt
    as character
    format "x(80)":U
    label "Ordem Relat"
    column-label "Ordem Relat"
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def new shared var v_cod_plano_cta_ctbl_final
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "Final"
    column-label "Final"
    no-undo.
def new shared var v_cod_plano_cta_ctbl_inic
    as character
    format "x(8)":U
    label "Plano Conta"
    column-label "Plano Cta"
    no-undo.
def new shared var v_cod_portador_fim
    as character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Portador Final"
    no-undo.
def new shared var v_cod_portador_ini
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador Inicial"
    no-undo.
def new shared var v_cod_proces_export_fim
    as character
    format "x(12)":U
    initial "ZZZZZZZZZZZZ"
    label "atÇ"
    column-label "Proc Exp Final"
    no-undo.
def new shared var v_cod_proces_export_ini
    as character
    format "x(12)":U
    label "Processo Exportaá∆o"
    column-label "Proc Exp Inicial"
    no-undo.
def new shared var v_cod_release
    as character
    format "x(12)":U
    no-undo.
def var v_cod_telefone
    as character
    format "x(20)":U
    label "Telefone"
    column-label "Telefone"
    no-undo.
def var v_cod_ult_obj_procesdo
    as character
    format "x(32)":U
    no-undo.
def var v_cod_unid_federac
    as character
    format "x(3)":U
    label "Unidade Federaá∆o"
    column-label "Unidade Federaá∆o"
    no-undo.
def new shared var v_cod_unid_negoc_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Final"
    no-undo.
def new shared var v_cod_unid_negoc_ini
    as character
    format "x(3)":U
    label "Unid Neg¢cio"
    column-label "Inicial"
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
def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu†rio Corrente"
    column-label "Usu†rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_dat_calc_atraso
    as date
    format "99/99/9999":U
    initial today
    label "Calc Dias Atraso"
    column-label "Calc Dias Atraso"
    no-undo.
def var v_dat_conver
    as date
    format "99/99/9999":U
    initial today
    label "Data Convers∆o"
    column-label "Data Convers∆o"
    no-undo.
def var v_dat_cotac_indic_econ
    as date
    format "99/99/9999":U
    initial today
    label "Data Cotaá∆o"
    column-label "Data Cotaá∆o"
    no-undo.
def new shared var v_dat_emis_docto_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_dat_emis_docto_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Data Emiss∆o"
    column-label "Emiss∆o"
    no-undo.
def new shared var v_dat_execution
    as date
    format "99/99/9999":U
    no-undo.
def new shared var v_dat_execution_end
    as date
    format "99/99/9999":U
    no-undo.
def new shared var v_dat_fim_period
    as date
    format "99/99/9999":U
    label "Fim Per°odo"
    no-undo.
def new shared var v_dat_inic_period
    as date
    format "99/99/9999":U
    label "In°cio Per°odo"
    column-label "Per°odo"
    no-undo.
def var v_dat_tit_acr_aber
    as date
    format "99/99/9999":U
    initial today
    label "Posiá∆o Em"
    column-label "Posiá∆o Em"
    no-undo.
def var v_cod_convenio_ini
    as CHAR
    format "999999":U
    initial "000000"
    label "Convànio"
    column-label "Convànio"
    no-undo.
def var v_cod_convenio_fim
    as CHAR
    format "999999":U
    initial "999999"
    label "Convànio"
    column-label "Convànio"
    no-undo.
def new shared var v_dat_vencto_tit_acr_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "Vencto Final"
    no-undo.
def new shared var v_dat_vencto_tit_acr_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Vencimento"
    column-label "Vencto Inicial"
    no-undo.
def var v_des_cta_ctbl
    as character
    format "x(50)":U
    label "Conta Cont†bil"
    column-label "Conta Cont†bil"
    no-undo.
def var v_des_div
    as character
    format "x(200)":U
    no-undo.
def var v_des_div_2
    as character
    format "x(200)":U
    no-undo.
def new shared var v_des_estab_select
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 no-word-wrap
    size 30 by 1
    bgcolor 15 font 2
    label "Selecionados"
    column-label "Selecionados"
    no-undo.
def var v_des_labels_vencto
    as character
    format "x(200)":U
    no-undo.
def var v_des_labels_vencto_1
    as character
    format "x(200)":U
    no-undo.
def var v_des_label_1
    as character
    format "x(25)":U
    no-undo.
def var v_des_label_2
    as character
    format "x(25)":U
    no-undo.
def var v_des_label_3
    as character
    format "x(25)":U
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
def var v_des_valores_valores
    as character
    format "x(200)":U
    no-undo.
def var v_des_valores_valores_2
    as character
    format "x(200)":U
    no-undo.
def new shared var v_hra_execution
    as Character
    format "99:99":U
    no-undo.
def new shared var v_hra_execution_end
    as Character
    format "99:99:99":U
    label "Tempo Exec"
    no-undo.
def new shared var v_ind_classif_tit_acr_em_aber
    as character
    format "X(30)":U
    initial "Por Representante/Cliente" /*l_por_representantecliente*/
    view-as radio-set Vertical
    radio-buttons "Por Representante/Cliente", "Por Representante/Cliente", "Por Portador/Carteira", "Por Portador/Carteira", "Por Cliente/Vencimento", "Por Cliente/Vencimento", "Por Nome do Cliente/Vencimento", "Por Nome Cliente/Vencimento", "Por Grupo Cliente/Cliente", "Por Grupo Cliente/Cliente", "Por Vencimento/Nome Cliente", "Por Vencimento/Nome Cliente", "Por Matriz", "Por Matriz", "Por Condiá∆o Cobranáa/Cliente", "Por Condiá∆o Cobranáa/Cliente", "Por EspÇcie/Vencto/Nome Cliente", "Por EspÇcie/Vencto/Nome Cliente"
     /*l_por_representantecliente*/ /*l_por_representantecliente*/ /*l_por_portadorcarteira*/ /*l_por_portadorcarteira*/ /*l_por_clientevencimento*/ /*l_por_clientevencimento*/ /*l_por_nome_do_clientevencimento*/ /*l_por_nome_clientevencimento*/ /*l_por_grupo_clientecliente*/ /*l_por_grupo_clientecliente*/ /*l_por_vencimentonome_cliente*/ /*l_por_vencimentonome_cliente*/ /*l_por_matriz*/ /*l_por_matriz*/ /*l_por_condcobranca_cliente*/ /*l_por_condcobranca_cliente*/ /*l_por_espec_Vencto_nomcli*/ /*l_por_espec_Vencto_nomcli*/
    bgcolor 8 
    label "Classificaá∆o"
    column-label "Classificaá∆o"
    no-undo.
def var v_ind_coluna
    as character
    format "X(15)":U
    view-as combo-box
    list-items ""
    inner-lines 8
    bgcolor 15 font 2
    label "Detalhar a Coluna"
    no-undo.
def var v_ind_dwb_run_mode
    as character
    format "X(07)":U
    initial "On-Line" /*l_online*/
    view-as radio-set Horizontal
    radio-buttons "On-Line", "On-Line", "Batch", "Batch"
     /*l_online*/ /*l_online*/ /*l_batch*/ /*l_batch*/
    bgcolor 8 
    label "Run Mode"
    column-label "Run Mode"
    no-undo.
def var v_ind_forma_tot
    as character
    format "X(08)":U
    view-as radio-set Vertical
    radio-buttons "Por Unidade Neg¢cio", "Por Unidade Neg¢cio", "Por Estab/Unidade Neg¢cio", "Por Estab/Unidade Neg¢cio"
     /*l_por_unid_negoc*/ /*l_por_unid_negoc*/ /*l_por_estab_unidade_negocio*/ /*l_por_estab_unidade_negocio*/
    bgcolor 8 
    no-undo.
def new shared var v_ind_run_mode
    as character
    format "X(08)":U
    initial "On-Line" /*l_online*/
    no-undo.
def var v_ind_tip_calc_juros
    as character
    format "X(10)":U
    initial "Simples" /*l_simples*/
    view-as combo-box
    list-items "Simples","Compostos"
     /*l_simples*/ /*l_compostos*/
    inner-lines 2
    bgcolor 15 font 2
    label "Tipo C†lculo Juros"
    column-label "Tipo C†lculo Juros"
    no-undo.
def new shared var v_ind_visualiz_tit_acr_vert
    as character
    format "X(20)":U
    initial "Por Estabelecimento" /*l_por_estabelecimento*/
    view-as radio-set Vertical
    radio-buttons "Por Estabelecimento", "Por Estabelecimento", "Por Unidade Neg¢cio", "Por Unidade Neg¢cio"
     /*l_por_estabelecimento*/ /*l_por_estabelecimento*/ /*l_por_unid_negoc*/ /*l_por_unid_negoc*/
    bgcolor 8 
    label "Visualiza T°tulo"
    column-label "Visualiza T°tulo"
    no-undo.
def new shared var v_log_acum_sdo_clien
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_answer
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_aux_frame
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new shared var v_log_classif_estab
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Classif Estab"
    column-label "Classif Estab"
    no-undo.
def new shared var v_log_classif_un
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Classif Unid Negoc"
    no-undo.
def var v_log_consid_abat
    as logical
    format "Sim/N∆o"
    initial No
    view-as toggle-box
    no-undo.
def var v_log_consid_desc
    as logical
    format "Sim/N∆o"
    initial No
    view-as toggle-box
    no-undo.
def var v_log_consid_impto_retid
    as logical
    format "Sim/N∆o"
    initial No
    view-as toggle-box
    label "Imposto Retido"
    no-undo.
def var v_log_consid_juros
    as logical
    format "Sim/N∆o"
    initial No
    view-as toggle-box
    label "Juros"
    no-undo.
def var v_log_consid_multa
    as logical
    format "Sim/N∆o"
    initial No
    view-as toggle-box
    no-undo.
def var v_log_control_cheq
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_control_terc_acr
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_emit_movto_cobr
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Emitir Movtos Cobr"
    column-label "Emitir Movtos Cobr"
    no-undo.
def new global shared var v_log_execution
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_funcao_juros_multa
    as logical
    format "Sim/N∆o"
    initial NO
    no-undo.
def var v_log_funcao_melhoria_tit_aber
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_funcao_proces_export
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_funcao_tip_calc_juros
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new global shared var v_log_gerac_planilha
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Gera Planilha"
    no-undo.
def var v_log_gera_sit_envio
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def new shared var v_log_habilita_con_corporat
    as logical
    format "Sim/N∆o"
    initial no
    label "Habilita Consulta"
    column-label "Habilita Consulta"
    no-undo.
def var v_log_impto_cop
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_integr_mec
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new shared var v_log_localiz_arg
    as logical
    format "Sim/N∆o"
    initial no
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
def var v_log_mostra_acr_cheq_devolv
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Cheques Devolvidos"
    column-label "Cheques Devolvidos"
    no-undo.
def var v_log_mostra_acr_cheq_recbdo
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Cheques Recebidos"
    column-label "Cheques Receb"
    no-undo.
def var v_log_mostra_docto_acr_antecip
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Antecipaá∆o"
    column-label "Antecipaá∆o"
    no-undo.
def var v_log_mostra_docto_acr_aviso_db
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Aviso DÇbito"
    column-label "Aviso DÇbito"
    no-undo.
def var v_log_mostra_docto_acr_cheq
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Cheque"
    column-label "Cheque"
    no-undo.
def var v_log_mostra_docto_acr_normal
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Normal"
    column-label "Normal"
    no-undo.
def var v_log_mostra_docto_acr_prev
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Previs∆o"
    column-label "Previs∆o"
    no-undo.
def var v_log_mostra_docto_vendor
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Vendor"
    column-label "Vendor"
    no-undo.
def var v_log_mostra_docto_vendor_repac
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Vendor Repactuado"
    column-label "Vendor Repactuado"
    no-undo.
def new shared var v_log_nao_impr_tit
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Somente Totais"
    no-undo.
def var v_log_pessoa_fisic_cobr
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_preco_flut_graos
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_print
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_print_par
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_sdo_tit_acr
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Tem Saldo"
    no-undo.
def var v_log_tip_espec_docto_cheq_terc
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Cheques Terceiros"
    column-label "Cheques Terceiros"
    no-undo.
def var v_log_tip_espec_docto_terc
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Dupl. Terceiros"
    column-label "Dupl. Terceiros"
    no-undo.
def var v_log_tip_fluxo_un
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Fluxo / Unidade"
    column-label "Fluxo / Unidade"
    no-undo.
def var v_log_tit_acr_avencer
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "T°tulos a Vencer"
    column-label "T°tulos a Vencer"
    no-undo.
def var v_log_tit_acr_estordo
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Estornados"
    column-label "Estornados"
    no-undo.
def var v_log_tit_acr_indcao_perda_dedut
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Indic Perda Dedut"
    no-undo.
def var v_log_tit_acr_nao_indcao_perda
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "N∆o Indic Perd Dedut"
    no-undo.
def var v_log_tit_acr_vencid
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "T°tulos Vencidos"
    column-label "T°tulos Vencidos"
    no-undo.
def new shared var v_log_tot_clien
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Cliente"
    column-label "Totaliza Cliente"
    no-undo.
def new shared var v_log_tot_cond_cobr
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Cond. Cobr."
    column-label "Totaliza Cond. Cobr."
    no-undo.
def new shared var v_log_tot_cta
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Cta Ctabil"
    no-undo.
def new shared var v_log_tot_espec_docto
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Espec Docto"
    column-label "Totaliza Espec Docto"
    no-undo.
def new shared var v_log_tot_estab
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Estab"
    column-label "Totaliza Estab"
    no-undo.
def new shared var v_log_tot_grp_clien
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Totaliza Grupo Clien"
    no-undo.
def new shared var v_log_tot_matriz
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Matriz"
    column-label "Totaliza Matriz"
    no-undo.
def new shared var v_log_tot_num_proces_export
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Proc. Expor"
    column-label "Totaliza Proc. Expor"
    no-undo.
def new shared var v_log_tot_portad_cart
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Portad/Cart"
    column-label "Totaliza Portad/Cart"
    no-undo.
def new shared var v_log_tot_repres
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Repres"
    column-label "Totaliza Repres"
    no-undo.
def new shared var v_log_tot_unid_negoc
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Unid Negoc"
    column-label "Totaliza Unid Negoc"
    no-undo.
def new shared var v_log_tot_vencto
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Totaliza Data Vencto"
    column-label "Totaliza Data Vencto"
    no-undo.
def var v_log_transf_estab_operac_financ
    as logical
    format "Sim/N∆o"
    initial ?
    no-undo.
def var v_log_un_tip_fluxo
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_vers_50_6
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_view_tip_fluxo
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_visualiz_analit
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Visualiz Anal°tico"
    column-label "Visualiz Anal°tico"
    no-undo.
def var v_log_visualiz_clien
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Visualiz Cliente"
    column-label "Visualiz Cliente"
    no-undo.
def var v_log_visualiz_sint
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Visualiz SintÇtico"
    column-label "Visualiz SintÇtico"
    no-undo.
def var v_log_imprime_fatura_convenio
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Imprime Fatura Convànio"
    column-label "Imprime Fatura Convànio"
    no-undo.
def var v_log_imprime_cupom_convenio
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Imprime Cupom Convànio"
    column-label "Imprime Cupom Convànio"
    no-undo.
def new shared var v_nom_abrev_clien_matriz_final
    as character
    format "x(15)":U
    initial "ZZZZZZZZZZZZZZZ"
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_nom_abrev_clien_matriz_inic
    as character
    format "x(15)":U
    label "Nome Matriz"
    column-label "Nome Matriz"
    no-undo.
def var v_nom_bairro
    as character
    format "x(20)":U
    label "Bairro"
    column-label "Bairro"
    no-undo.
def var v_nom_cidade
    as character
    format "x(32)":U
    label "Cidade"
    column-label "Cidade"
    no-undo.
def var v_nom_condado
    as character
    format "x(32)":U
    label "Condado"
    column-label "Condado"
    no-undo.
def var v_nom_dwb_printer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_dwb_print_file
    as character
    format "x(100)":U
    label "Arquivo Impress∆o"
    column-label "Arq Impr"
    no-undo.
def var v_nom_endereco
    as character
    format "x(40)":U
    label "Endereáo"
    column-label "Endereáo"
    no-undo.
def var v_nom_ender_compl
    as character
    format "x(10)":U
    no-undo.
def new shared var v_nom_enterprise
    as character
    format "x(40)":U
    no-undo.
def var v_nom_field
    as character
    format "x(30)":U
    no-undo.
def var v_nom_integer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_pessoa
    as character
    format "x(40)":U
    label "Nome"
    column-label "Nome"
    no-undo.
def var v_nom_prog_appc
    as character
    format "x(50)":U
    label "Programa APPC"
    column-label "Programa APPC"
    no-undo.
def var v_nom_prog_dpc
    as character
    format "x(50)":U
    label "Programa Dpc"
    column-label "Programa Dpc"
    no-undo.
def new shared var v_nom_prog_ext
    as character
    format "x(8)":U
    label "Nome Externo"
    no-undo.
def new shared var v_nom_prog_ext_aux
    as character
    format "x(8)":U
    no-undo.
def var v_nom_prog_upc
    as character
    format "X(50)":U
    label "Programa UPC"
    column-label "Programa UPC"
    no-undo.
def new shared var v_nom_report_title
    as character
    format "x(40)":U
    no-undo.
def var v_nom_table_epc
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_cont_aux
    as integer
    format ">9":U
    no-undo.
def var v_num_count
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_dias_amr_7
    as integer
    format "->>>>>>9":U
    no-undo.
def new shared var v_num_dias_avencer_1
    as integer
    format ">>>9":U
    initial 30
    label "A Vencer atÇ"
    no-undo.
def new shared var v_num_dias_avencer_10
    as integer
    format ">>>9":U
    initial 151
    label "de"
    no-undo.
def new shared var v_num_dias_avencer_11
    as integer
    format ">>>9":U
    initial 180
    label "atÇ"
    no-undo.
def new shared var v_num_dias_avencer_12
    as integer
    format ">>>9":U
    initial 180
    label "Mais de"
    no-undo.
def new shared var v_num_dias_avencer_2
    as integer
    format ">>>9":U
    initial 31
    label "de"
    column-label "de"
    no-undo.
def new shared var v_num_dias_avencer_3
    as integer
    format ">>>9":U
    initial 60
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_num_dias_avencer_4
    as integer
    format ">>>9":U
    initial 61
    label "de"
    no-undo.
def new shared var v_num_dias_avencer_5
    as integer
    format ">>>9":U
    initial 90
    label "atÇ"
    no-undo.
def new shared var v_num_dias_avencer_6
    as integer
    format ">>>9":U
    initial 91
    label "Mais de"
    no-undo.
def new shared var v_num_dias_avencer_7
    as integer
    format ">>>9":U
    initial 120
    label "atÇ"
    no-undo.
def new shared var v_num_dias_avencer_8
    as integer
    format ">>>9":U
    initial 121
    label "Mais de"
    no-undo.
def new shared var v_num_dias_avencer_9
    as integer
    format ">>>9":U
    initial 150
    label "atÇ"
    no-undo.
def var v_num_dias_pmr_7
    as integer
    format "->>>>>>9":U
    no-undo.
def new shared var v_num_dias_vencid_1
    as integer
    format ">>>9":U
    initial 30
    label "Vencidos atÇ"
    no-undo.
def new shared var v_num_dias_vencid_10
    as integer
    format ">>>9":U
    initial 151
    label "de"
    no-undo.
def new shared var v_num_dias_vencid_11
    as integer
    format ">>>9":U
    initial 180
    label "atÇ"
    no-undo.
def new shared var v_num_dias_vencid_12
    as integer
    format ">>>9":U
    initial 180
    label "Mais de"
    no-undo.
def new shared var v_num_dias_vencid_2
    as integer
    format ">>>9":U
    initial 31
    label "de"
    column-label "de"
    no-undo.
def new shared var v_num_dias_vencid_3
    as integer
    format ">>>9":U
    initial 60
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_num_dias_vencid_4
    as integer
    format ">>>9":U
    initial 61
    label "de"
    no-undo.
def new shared var v_num_dias_vencid_5
    as integer
    format ">>>9":U
    initial 90
    label "atÇ"
    no-undo.
def new shared var v_num_dias_vencid_6
    as integer
    format ">>>9":U
    initial 91
    label "Mais de"
    no-undo.
def new shared var v_num_dias_vencid_7
    as integer
    format ">>>9":U
    initial 120
    label "atÇ"
    no-undo.
def new shared var v_num_dias_vencid_8
    as integer
    format ">>>9":U
    initial 121
    label "Mais de"
    no-undo.
def new shared var v_num_dias_vencid_9
    as integer
    format ">>>9":U
    initial 150
    label "atÇ"
    no-undo.
def new shared var v_num_entry
    as integer
    format ">>>>,>>9":U
    label "Ordem"
    column-label "Ordem"
    no-undo.
def var v_num_ord_reg
    as integer
    format ">>9":U
    label "Ordem Registro"
    column-label "Ordem Registro"
    no-undo.
def new shared var v_num_page_number
    as integer
    format ">>>>>9":U
    label "P†gina"
    column-label "P†gina"
    no-undo.
def var v_num_ped_exec
    as integer
    format ">>>>9":U
    label "Pedido"
    column-label "Pedido"
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_seq
    as integer
    format ">>>,>>9":U
    label "SeqÅància"
    column-label "Seq"
    no-undo.
def var v_qtd_bottom
    as decimal
    format ">>9":U
    decimals 0
    no-undo.
def var v_qtd_column
    as decimal
    format ">>9":U
    decimals 0
    label "Colunas"
    column-label "Colunas"
    no-undo.
def var v_qtd_dias_avencer
    as decimal
    format ">>>9":U
    decimals 0
    initial 9999
    label "Em atÇ ...dias"
    column-label "Em AtÇ"
    no-undo.
def var v_qtd_dias_vencid
    as decimal
    format ">>>9":U
    decimals 0
    initial 0
    label "A mais de ...dias"
    column-label "A mais de"
    no-undo.
def var v_qtd_dias_vencto_tit_acr
    as decimal
    format "->>9":U
    decimals 0
    label "Dias Vencimento"
    column-label "Dias Vencimento"
    no-undo.
def var v_qtd_line
    as decimal
    format ">>9":U
    decimals 0
    label "Linhas"
    column-label "Linhas"
    no-undo.
def var v_qtd_line_ant
    as decimal
    format "->>>>,>>9.9999":U
    decimals 4
    no-undo.
def var v_qtd_tit_acr_avencer
    as decimal
    format ">>>>9":U
    decimals 0
    extent 7
    label "Quant"
    column-label "Quant"
    no-undo.
def var v_qtd_tit_acr_vencid
    as decimal
    format ">>>>9":U
    decimals 0
    extent 7
    label "Quant"
    column-label "Quant"
    no-undo.
def var v_qtd_tot_tit_antecip
    as decimal
    format ">>>,>>9":U
    decimals 0
    label "Total Antecipaá∆o"
    column-label "Total Antecipaá∆o"
    no-undo.
def var v_qtd_tot_tit_avencer
    as decimal
    format ">>>,>>9":U
    decimals 0
    label "Qtd Total"
    column-label "Qtd Total"
    no-undo.
def var v_qtd_tot_tit_normal
    as decimal
    format ">>>,>>9":U
    decimals 0
    label "Total Normal"
    column-label "Total Normal"
    no-undo.
def var v_qtd_tot_tit_vencid
    as decimal
    format ">>>,>>9":U
    decimals 0
    label "Qtd Total"
    column-label "Qtd Total"
    no-undo.
def new global shared var v_rec_clien_financ
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_finalid_econ
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_cotac_indic_econ
    as decimal
    format "->>,>>>,>>>,>>9.9999999999":U
    decimals 10
    label "Cotaá∆o"
    column-label "Cotaá∆o"
    no-undo.
def var v_val_cust_movto_cobr
    as decimal
    format ">>>,>>>,>>9.99":U
    decimals 2
    extent 25
    label "Total Custo Movto"
    column-label "Total Custo Movto"
    no-undo.
def var v_val_estab
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_estab_antecip
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_estab_normal
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_juros_aux
    as decimal
    format ">>>>,>>>,>>9.99":U
    decimals 2
    label "Valor"
    column-label "Valor"
    no-undo.
def var v_val_origin_apres_avencer
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 0
    extent 7
    label "Vl Original Apres"
    column-label "Vl Original Apres"
    no-undo.
def var v_val_origin_apres_vencid
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    extent 7
    label "Vl Original Apres"
    column-label "Vl Original Apres"
    no-undo.
def var v_val_origin_tit_acr
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Original"
    column-label "Valor Original"
    no-undo.
def var v_val_perc_abat_acr_1
    as decimal
    format ">>9.9999":U
    decimals 4
    label "Perc Abatimento"
    column-label "Perc. Abatimento"
    no-undo.
def var v_val_perc_Abat_acr_cond_cobr
    as decimal
    format ">>9.9999":U
    decimals 4
    label "Perc. Abatimento"
    column-label "Perc. Abatimento"
    no-undo.
def var v_val_perc_avencer
    as decimal
    format ">>9.99":U
    decimals 5
    extent 8
    label "Percentual"
    column-label "Percentual"
    no-undo.
def var v_val_perc_geral_avencer
    as decimal
    format ">>9.99":U
    decimals 5
    extent 8
    label "Percentual Geral"
    column-label "Percentual Geral"
    no-undo.
def var v_val_perc_geral_vencid
    as decimal
    format ">>9.99":U
    decimals 5
    extent 8
    label "Percentual Geral"
    column-label "Percentual Geral"
    no-undo.
def var v_val_perc_vencid
    as decimal
    format ">>9.99":U
    decimals 5
    extent 8
    label "Percentual"
    column-label "Percentual"
    no-undo.
def var v_val_proces_antecip
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    no-undo.
def var v_val_proces_export
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    no-undo.
def var v_val_proces_normal
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    no-undo.
def var v_val_sdo
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Valor Saldo"
    column-label "Valor Saldo"
    no-undo.
def var v_val_sdo_apres_acum
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    label "Saldo Acumulado"
    column-label "Saldo Acumulado"
    no-undo.
def var v_val_sdo_apres_avencer
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    extent 7
    label "Vl Saldo Apres"
    column-label "Vl Saldo Apres"
    no-undo.
def var v_val_sdo_apres_vencid
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    extent 7
    label "Vl Saldo Apres"
    column-label "Vl Saldo Apres"
    no-undo.
def var v_val_sdo_tit_acr
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Saldo"
    column-label "Valor Saldo"
    no-undo.
def var v_val_soma_impto_retid
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
def var v_val_tot_movto
    as decimal
    format "->>,>>>,>>9.99":U
    decimals 2
    label "Valor Total"
    column-label "Valor Total"
    no-undo.
def var v_val_tot_movto_amr
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Movto AMR"
    column-label "Total Movto AMR"
    no-undo.
def var v_val_tot_movto_pmr
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Movto PMR"
    column-label "Total Movto PMR"
    no-undo.
def var v_val_tot_origin_antecip
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 0
    label "Total Antecipado"
    column-label "Total Antecipado"
    no-undo.
def var v_val_tot_origin_avencer
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Origin a Vencer"
    column-label "Tot Origin a Vencer"
    no-undo.
def var v_val_tot_origin_geral
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Geral"
    column-label "Total Geral"
    no-undo.
def var v_val_tot_origin_normal
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total de T°tulos"
    column-label "Total de T°tulos"
    no-undo.
def var v_val_tot_origin_vencid
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Origin Vencid"
    column-label "Tot Origin Vencid"
    no-undo.
def var v_val_tot_sdo
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Saldo"
    column-label "Total Saldo"
    no-undo.
def var v_val_tot_sdo_acr
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    extent 6
    label "Total Saldo"
    column-label "Total Saldo"
    no-undo.
def var v_val_tot_sdo_antecip
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Antecipado"
    column-label "Total Antecipado"
    no-undo.
def var v_val_tot_sdo_avencer
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Saldo a Vencer"
    column-label "Tot Saldo a Vencer"
    no-undo.
def var v_val_tot_sdo_geral
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Geral"
    column-label "Total Geral"
    no-undo.
def var v_val_tot_sdo_normal
    as decimal
    format "->>>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total de T°tulos"
    column-label "Total de T°tulos"
    no-undo.
def var v_val_tot_sdo_vencid
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Saldo Vencid"
    column-label "Tot Saldo Vencid"
    no-undo.
def var v_val_unid_negoc
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_unid_negoc_antecip
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_unid_negoc_normal
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_cod_indic_econ_apres           as character       no-undo. /*local*/
def var v_cod_return                     as character       no-undo. /*local*/
def var v_log_funcao_aging_acr           as logical         no-undo. /*local*/
def var v_log_return                     as logical         no-undo. /*local*/
def var v_num_entries                    as integer         no-undo. /*local*/
def var v_num_idx                        as integer         no-undo. /*local*/
def var v_num_multiplic                  as integer         no-undo. /*local*/


/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/

.

def menu      m_help                menubar
    menu-item mi_conteudo           label "&Conte£do"
    menu-item mi_sobre              label "&Sobre".



/**************************** Menu Definition End ***************************/

/************************** Query Definition Begin **************************/

def query qr_tit_acr_em_aberto
    for tt_titulos_em_aberto_acr
    scrolling.
def query qr_tit_acr_em_aberto_un
    for tt_titulos_em_aberto_acr
    scrolling.
def query qr_tot_tit_acr
    for tt_tot_movtos_acr
    scrolling.


/*************************** Query Definition End ***************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_002
    size 1 by 1
    edge-pixels 2.
def rectangle rt_006
    size 1 by 1
    edge-pixels 2.
def rectangle rt_007
    size 1 by 1
    edge-pixels 2.
def rectangle rt_015
    size 1 by 1
    edge-pixels 2.
def rectangle rt_016
    size 1 by 1
    edge-pixels 2.
def rectangle rt_018
    size 1 by 1
    edge-pixels 2.
def rectangle rt_019
    size 1 by 1
    edge-pixels 2.
def rectangle rt_021
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_dimensions
    size 1 by 1
    edge-pixels 2.
def rectangle rt_run
    size 1 by 1
    edge-pixels 2.
def rectangle rt_target
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_classificacao
    label "Classificaá∆o"
    tooltip "Classificaá∆o"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-cla.bmp"
    image-insensitive file "image/ii-cla.bmp"
&endif
    size 1 by 1.
def button bt_close
    label "&Fecha"
    tooltip "Fecha"
    size 1 by 1
    auto-go.
def button bt_fil2
    label "Fil"
    tooltip "Filtro"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-fil"
    image-insensitive file "image/ii-fil"
&endif
    size 1 by 1.
def button bt_get_file
    label "Pesquisa Arquivo"
    tooltip "Pesquisa Arquivo"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-sea1"
    image-insensitive file "image/ii-sea1"
&endif
    size 1 by 1.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
    size 1 by 1
    auto-go.
def button bt_planilha_excel
    label "Planilha"
    tooltip "Planilha do Excel"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-exel.bmp"
&endif
    size 1 by 1.
def button bt_print
    label "&Imprime"
    tooltip "Imprime"
    size 1 by 1
    auto-go.
def button bt_ran2
    label "Faixa"
    tooltip "Faixa"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-ran"
    image-insensitive file "image/ii-ran"
&endif
    size 1 by 1.
def button bt_set_printer
    label "Define Impressora e Layout"
    tooltip "Define Impressora e Layout de Impress∆o"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-setpr.bmp"
    image-insensitive file "image/ii-setpr"
&endif
    size 1 by 1.
def button bt_time
    label "Tempo"
    tooltip "Prazos"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-time.bmp"
    image-insensitive file "image/im-time1"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_188063
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.
def button bt_zoo_188064
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.


/*************************** Button Definition End **************************/

/************************** Editor Definition Begin *************************/

def var ed_1x40
    as character
    view-as editor no-word-wrap
    size 40 by 1
    bgcolor 15 font 2
    no-undo.


/*************************** Editor Definition End **************************/

/************************ Radio-Set Definition Begin ************************/

def var rs_cod_dwb_output
    as character
    initial "Terminal"
    view-as radio-set Horizontal
    radio-buttons "Terminal", "Terminal", "Arquivo", "Arquivo", "Impressora", "Impressora"
     /*l_terminal*/ /*l_terminal*/ /*l_file*/ /*l_file*/ /*l_printer*/ /*l_printer*/
    bgcolor 8 
    no-undo.
def var rs_ind_run_mode
    as character
    initial "On-Line"
    view-as radio-set Horizontal
    radio-buttons "On-Line", "On-Line", "Batch", "Batch"
     /*l_online*/ /*l_online*/ /*l_batch*/ /*l_batch*/
    bgcolor 8 
    no-undo.


/************************* Radio-Set Definition End *************************/

/************************** Report Definition Begin *************************/

def new shared var v_rpt_s_1_lines as integer initial 66.
def new shared var v_rpt_s_1_columns as integer initial 255.
def new shared var v_rpt_s_1_bottom as integer initial 65.
def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as character initial "T°tulos em Aberto ACR".
def frame f_rpt_s_1_header_period header
    "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    "P†gina:" at 226
    (page-number (s_1) + v_rpt_s_1_page) at 233 format ">>>>>9" skip
    v_nom_enterprise at 1 format "x(40)"
    v_nom_report_title at 198 format "x(40)" skip
    "Per°odo: " at 1
    v_dat_inic_period at 10 format "99/99/9999"
    "A" at 21
    v_dat_fim_period at 23 format "99/99/9999"
    "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 34
    v_dat_execution at 221 format "99/99/9999" "- "
    v_hra_execution at 234 format "99:99" skip (1)
    with no-box no-labels width 238 page-top stream-io.
def frame f_rpt_s_1_header_unique header
    "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    'P†gina:' at 226
    (page-number (s_1) + v_rpt_s_1_page) at 233 format '>>>>>9' skip
    v_nom_enterprise at 1 format 'x(40)'
    v_nom_report_title at 199 format 'x(40)' skip
    '---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' at 1
    v_dat_execution at 221 format '99/99/9999' '- '
    v_hra_execution at 234 format "99:99" skip (1)
    with no-box no-labels width 238 page-top stream-io.
def frame f_rpt_s_1_footer_last_page header
    "Èltima p†gina " at 1
    "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 15
    v_nom_prog_ext at 216 format "x(08)" "- "
    v_cod_release at 227 format "x(12)" skip
    with no-box no-labels width 238 page-bottom stream-io.
def frame f_rpt_s_1_footer_normal header
    "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    "- " at 214
    v_nom_prog_ext at 216 format "x(08)" "- "
    v_cod_release at 227 format "x(12)" skip
    with no-box no-labels width 238 page-bottom stream-io.
def frame f_rpt_s_1_footer_param_page header
    "P†gina ParÉmetros " at 1
    "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 19
    v_nom_prog_ext at 222 format "x(08)" "- "
    v_cod_release at 233 format "x(12)" skip
    with no-box no-labels width 244 page-bottom stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_aging_acr header
    "Vencidos atÇ:" at 24
    /* objeto  ignorado. N∆o foi encontrado esse objeto */
    v_des_labels_vencto at 39 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_aging_div header
    v_des_div at 24 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_aging_val header
    v_des_valores_valores at 24 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_ag_vencer header
    "A Vencer atÇ:" at 24
    /* objeto  ignorado. N∆o foi encontrado esse objeto */
    v_des_labels_vencto_1 at 39 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_cliente header
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_cliente ignorado */
    "-" at 34
    /* Atributo cliente.nom_pessoa ignorado */
    "-" at 77
    /* Atributo cliente.cod_id_feder ignorado */
    "-" at 100
    /* Atributo cliente.nom_abrev ignorado */
    "-" at 118
    v_nom_cidade at 120 format "x(32)" view-as text
    "-" at 153
    v_cod_unid_federac at 155 format "x(3)" view-as text
    "-" at 159
    v_cod_telefone at 161 format "x(20)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_div_vencer header
    v_des_div_2 at 24 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_aging_acr_Lay_val_vencer header
    v_des_valores_valores_2 at 24 format "x(200)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.

def frame f_rpt_s_1_Grp_detalhe_Lay_avencer_1 header
    "Vl Saldo Apres" to 80
    "Quant" to 90
    "Percentual" to 105
    "Percentual Geral" to 124 skip
    "------------------" to 80
    "-----" to 90
    "----------" to 105
    "----------------" to 124 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_Cliente header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Un N" at 37
    "Cliente" to 52
    "Nome Abrev" at 54
    "Emiss∆o" at 70
    "Vencto" at 81
    "CrÇdito" at 92
    "Refer" at 103
    "Num T°tulo Banco" at 114
    "Moeda" at 135
    "Vl Original" to 157
    "Saldo" to 172
    "Saldo" to 188
/*     "Dias" to 197         */
/*     "Pedido Venda" at 199 */
/*     "Dt Indic" at 212     */
     skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "----" at 37
    "-----------" to 52
    "---------------" at 54
    "----------" at 70
    "----------" at 81
    "----------" at 92
    "----------" at 103
    "--------------------" at 114
    "--------" at 135
    "--------------" to 157
    "--------------" to 172
    "---------------" to 188
    "--------" to 197
    "------------" at 199
    "----------" at 212 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_Cliente_Arg header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Un N" at 37
    "Cliente" to 52
    "Nome Abrev" at 54
    "Emiss∆o" at 70
    "Vencto" at 81
    "CrÇdito" at 92
    "Refer" at 103
    "Num T°tulo Banco" at 114
    "Moeda" at 135
    "Vl Original" to 157
    "Saldo" to 172
    "Saldo" to 188
    "Saldo Acumulado" to 207
/*     "Dias" to 216         */
/*     "Pedido Venda" at 218 */
/*     "Dt Indic" at 231     */
     skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "----" at 37
    "-----------" to 52
    "---------------" at 54
    "----------" at 70
    "----------" at 81
    "----------" at 92
    "----------" at 103
    "--------------------" at 114
    "--------" at 135
    "--------------" to 157
    "--------------" to 172
    "---------------" to 188
    "------------------" to 207
    "--------" to 216
    "------------" at 218
    "----------" at 231 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_principal header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Un N" at 37
    "Cliente" at 42
    "Port" at 55
    "Cart" at 61
    "Emiss∆o" at 66
    "Vencto" at 77
    "CrÇdito" at 88
    "Refer" at 99
    "Num T°tulo Banco" at 110
    "Moeda" at 131
    "Vl Original" to 153
    "Saldo" to 168
    "Saldo" to 184
/*     "Dias" to 193         */
/*     "Pedido Venda" at 195 */
/*     "Dt Indic" at 208     */
    skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "----" at 37
    "------------" at 42
    "-----" at 55
    "----" at 61
    "----------" at 66
    "----------" at 77
    "----------" at 88
    "----------" at 99
    "--------------------" at 110
    "--------" at 131
    "--------------" to 153
    "--------------" to 168
    "---------------" to 184
    "--------" to 193
    "------------" at 195
    "----------" at 208 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_princip_arg header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Un N" at 37
    "Cliente" at 42
    "Port" at 55
    "Cart" at 61
    "Emiss∆o" at 66
    "Vencto" at 77
    "CrÇdito" at 88
    "Refer" at 99
    "Num T°tulo Banco" at 110
    "Moeda" at 131
    "Vl Original" to 153
    "Saldo" to 168
    "Saldo" to 184
    "Saldo Acumulado" to 203
/*     "Dias" to 212         */
/*     "Pedido Venda" at 214 */
/*     "Dt Indic" at 227     */
    skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "----" at 37
    "------------" at 42
    "-----" at 55
    "----" at 61
    "----------" at 66
    "----------" at 77
    "----------" at 88
    "----------" at 99
    "--------------------" at 110
    "--------" at 131
    "--------------" to 153
    "--------------" to 168
    "---------------" to 184
    "------------------" to 203
    "--------" to 212
    "------------" at 214
    "----------" at 227 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_vencid_1 header
    "Vl Saldo Apres" to 80
    "Quant" to 90
    "Percentual" to 105
    "Percentual Geral" to 124 skip
    "------------------" to 80
    "-----" to 90
    "----------" to 105
    "----------------" to 124 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_det_cobr_Lay_movto_cobr header
    skip (1)
    "Data" at 10
    "Hora" at 21
    "Usu†rio" at 30
    "Tipo" at 43
    "Contato Cobr" at 54
    "Descr Abrev" at 85
    "Moeda" at 126
    "Custo Movto" to 148 skip
    "----------" at 10
    "--------" at 21
    "------------" at 30
    "--------------------" at 43
    "------------------------------" at 54
    "----------------------------------------" at 85
    "--------" at 126
    "--------------" to 148 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_erros_Lay_erros header
    /* Atributo tt_log_erros.ttv_num_seq ignorado */
    /* Atributo tt_log_erros.ttv_num_cod_erro ignorado */
    /* Atributo tt_log_erros.ttv_des_erro ignorado */
    /* Atributo tt_log_erros.ttv_des_ajuda ignorado */ skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_labels_Lay_labels header
    "EST" at 1
    "Esp " at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Unid " at 37
    "Tipo Fluxo" at 42
    "Cliente  " at 55
    "Port " at 67
    "Cart " at 73
    "Emiss∆o" at 78
    "Vencto" at 89
    "CrÇdito" at 100
    "Refer  " at 111
    "Num Tit Banco   " at 122
    "Moeda" at 143
    "Vl Original" at 155
    "Saldo" at 176
    "Saldo" at 192
/*     "Dias" at 201              */
/*     "Ped Venda  " at 206       */
/*     "Data Indicaá∆o   " at 219 */
    skip
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_lin_branco_Lay_lin_branco header skip (1) skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_1 header
    "---------------------------------------------" at 33
    "Visualizaá∆o" at 79
    "---------------------------------------------" at 94
    skip (1)
    "  Visualiza: " at 74
    v_ind_visualiz_tit_acr_vert at 87 format "X(20)" view-as text skip
    "  Anal°tico: " at 74
    v_log_visualiz_analit at 87 format "Sim/N∆o" view-as text skip
    "  SintÇtico: " at 74
    v_log_visualiz_sint at 87 format "Sim/N∆o" view-as text
    skip (1)
    "---------------------------------------------" at 33
    "Apresentaá∆o  " at 79
    "---------------------------------------------" at 94
    skip (1)
    "  Posiá∆o Em: " at 73
    v_dat_tit_acr_aber at 87 format "99/99/9999" view-as text skip
    "    Finalidade Econìmica: " at 61
    v_cod_finalid_econ at 87 format "x(10)" view-as text skip
    "Finalid Apresentaá∆o: " at 65
    v_cod_finalid_econ_apres at 87 format "x(10)" view-as text skip
    "Data Cotaá∆o: " at 73
    v_dat_cotac_indic_econ at 87 format "99/99/9999" view-as text
    skip (1)
    "---------------------------------------------" at 35
    "Situaá∆o" at 82
    "---------------------------------------------" at 92
    skip (1)
    "  Vencidos: " at 60
    v_log_tit_acr_vencid at 72 format "Sim/N∆o" view-as text
    "  A mais de: " at 90
    v_qtd_dias_vencid to 106 format ">>>9" view-as text
    "Dias" at 108 skip
    "  A Vencer: " at 60
    v_log_tit_acr_avencer at 72 format "Sim/N∆o" view-as text
    " Em AtÇ: " at 94
    v_qtd_dias_avencer to 106 format ">>>9" view-as text
    "Dias" at 108 skip
    "    Calc Dias Atraso: " at 86
    v_dat_calc_atraso at 108 format "99/99/9999" view-as text
    skip (1)
    "---------------------------------------------" at 35
    "Considera " at 81
    "---------------------------------------------" at 92
    skip (1)
    "Estornados: " at 60
    v_log_tit_acr_estordo at 72 format "Sim/N∆o" view-as text
    "  Abatimento: " at 94
    v_log_consid_abat at 108 format "Sim/N∆o" view-as text skip
    "    Indic Perda Dedut: " at 49
    v_log_tit_acr_indcao_perda_dedut at 72 format "Sim/N∆o" view-as text
    "  Desconto: " at 96
    v_log_consid_desc at 108 format "Sim/N∆o" view-as text skip
    "    N∆o Indic Perd Dedut: " at 46
    v_log_tit_acr_nao_indcao_perda at 72 format "Sim/N∆o" view-as text
    "   Imposto Retido: " at 89
    v_log_consid_impto_retid at 108 format "Sim/N∆o" view-as text skip
    "   Juros: " at 62
    v_log_consid_juros at 72 format "Sim/N∆o" view-as text
    "Multa: " at 101
    v_log_consid_multa at 108 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_2 header
    "---------------------------------------------" at 36
    "Faixa" at 83
    "---------------------------------------------" at 90
    /* Vari†vel v_cod_estab_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_estab_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_unid_negoc_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_unid_negoc_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_espec_docto_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_espec_docto_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_cliente_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_cliente_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_grp_clien_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_grp_clien_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_portador_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_portador_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cart_bcia_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cart_bcia_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_repres_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_repres_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_dat_vencto_tit_acr_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_dat_vencto_tit_acr_fim ignorada. N∆o esta definida no programa */
    skip (10)
    "   Cliente Matriz: " at 61
    v_cdn_clien_matriz_ini to 90 format ">>>,>>>,>>9" view-as text
    "atÇ: " at 98
    v_cdn_clien_matriz_fim to 113 format ">>>,>>>,>>9" view-as text
    /* Vari†vel v_cod_cond_cobr_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cond_cobr_fim ignorada. N∆o esta definida no programa */
    skip (1)
    "  Moeda: " at 68
    v_cod_indic_econ_ini at 77 format "x(8)" view-as text
    "atÇ: " at 98
    v_cod_indic_econ_fim at 103 format "x(8)" view-as text skip
    "    Processo Exportaá∆o: " at 52
    v_cod_proces_export_ini at 77 format "x(12)" view-as text
    "atÇ: " at 98
    v_cod_proces_export_fim at 103 format "x(12)" view-as text skip
    "  Data Emiss∆o: " at 61
    v_dat_emis_docto_ini at 77 format "99/99/9999" view-as text
    " atÇ: " at 97
    v_dat_emis_docto_fim at 103 format "99/99/9999" view-as text skip
    "   Plano Conta: " at 61
    v_cod_plano_cta_ctbl_inic at 77 format "x(8)" view-as text
    "atÇ: " at 98
    v_cod_plano_cta_ctbl_final at 103 format "x(8)" view-as text skip
    "   Conta Inicial: " at 59
    v_cod_cta_ctbl_ini at 77 format "x(20)" view-as text
    "atÇ: " at 98
    v_cod_cta_ctbl_final at 103 format "x(20)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_2a header
    "---------------------------------------------" at 23
    "Faixa" at 70
    "---------------------------------------------" at 77
    /* Vari†vel v_cod_estab_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_estab_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_unid_negoc_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_unid_negoc_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_espec_docto_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_espec_docto_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_cliente_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_cliente_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_grp_clien_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_grp_clien_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_portador_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_portador_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cart_bcia_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cart_bcia_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_repres_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cdn_repres_fim ignorada. N∆o esta definida no programa */
    /* Vari†vel v_dat_vencto_tit_acr_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_dat_vencto_tit_acr_fim ignorada. N∆o esta definida no programa */
    skip (10)
    "   Cliente Matriz: " at 48
    v_cdn_clien_matriz_ini to 77 format ">>>,>>>,>>9" view-as text
    "atÇ: " at 85
    v_cdn_clien_matriz_fim to 100 format ">>>,>>>,>>9" view-as text
    /* Vari†vel v_cod_cond_cobr_ini ignorada. N∆o esta definida no programa */
    /* Vari†vel v_cod_cond_cobr_fim ignorada. N∆o esta definida no programa */
    skip (1)
    "  Moeda: " at 55
    v_cod_indic_econ_ini at 64 format "x(8)" view-as text
    "atÇ: " at 85
    v_cod_indic_econ_fim at 90 format "x(8)" view-as text skip
    "    Processo Exportaá∆o: " at 39
    v_cod_proces_export_ini at 64 format "x(12)" view-as text
    "atÇ: " at 85
    v_cod_proces_export_fim at 90 format "x(12)" view-as text skip
    "  Data Emiss∆o: " at 48
    v_dat_emis_docto_ini at 64 format "99/99/9999" view-as text
    " atÇ: " at 84
    v_dat_emis_docto_fim at 90 format "99/99/9999" view-as text skip (2)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_3 header
    "---------------------------------------------" at 32
    "Classificaá∆o" at 79
    "---------------------------------------------" at 94
    /* Vari†vel v_log_classif_estab ignorada. N∆o esta definida no programa */
    skip (2)
    "   Classif Unid Negoc: " at 64
    v_log_classif_un at 87 format "Sim/N∆o" view-as text
    /* Vari†vel v_ind_classif_tit_acr_em_aber ignorada. N∆o esta definida no programa */
    skip (2)
    "---------------------------------------------" at 33
    "Totalizaá∆o" at 80
    "---------------------------------------------" at 93
    /* Vari†vel v_log_tot_estab ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_repres ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_portad_cart ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_clien ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_grp_clien ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_vencto ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_matriz ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_cond_cobr ignorada. N∆o esta definida no programa */
    /* Vari†vel v_log_tot_espec_docto ignorada. N∆o esta definida no programa */
    skip (10)
    "    Totaliza Proc. Expor: " at 61
    v_log_tot_num_proces_export at 87 format "Sim/N∆o" view-as text skip
    "    Totaliza Unid Negoc: " at 62
    v_log_tot_unid_negoc at 87 format "Sim/N∆o" view-as text skip
    "    Totaliza Cta Ctabil: " at 62
    v_log_tot_cta at 87 format "Sim/N∆o" view-as text
    skip (1)
    "---------------------------------------------" at 33
    "Imprime" at 80
    "---------------------------------------------" at 93
    /* Vari†vel v_log_nao_impr_tit ignorada. N∆o esta definida no programa */
    skip (2)
    "    Emitir Movtos Cobr: " at 63
    v_log_emit_movto_cobr at 87 format "Sim/N∆o" view-as text skip
    "    Gera Planilha: " at 68
    v_log_gerac_planilha at 87 format "Sim/N∆o" view-as text skip
    "   Arq Planilha: " at 70
    v_cod_arq_planilha at 87 format "x(40)" view-as text skip
    " Caracter Delimitador: " at 64
    v_cod_carac_lim at 87 format "x(1)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_4 header
    "---------------------------------------------" at 33
    "Prazos Resumo  " at 79
    "---------------------------------------------" at 95
    skip (1)
    "------------------------------" at 26
    "Doctos Vencidos   " at 57
    "--------------------" at 76
    "Doctos a Vencer   " at 97
    "------------------------------" at 116
    /* Vari†vel v_num_dias_vencid_1 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_1 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_2 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_3 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_2 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_3 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_4 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_5 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_4 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_5 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_6 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_7 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_6 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_7 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_8 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_9 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_8 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_9 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_10 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_11 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_10 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_11 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_12 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_12 ignorada. N∆o esta definida no programa */ skip (8)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_5 header
    "---------------------------------------------" at 33
    "Tipo EspÇcie  " at 79
    "---------------------------------------------" at 94 skip
    "  Normal: " at 77
    v_log_mostra_docto_acr_normal at 87 format "Sim/N∆o" view-as text skip
    "   Antecipaá∆o: " at 71
    v_log_mostra_docto_acr_antecip at 87 format "Sim/N∆o" view-as text skip
    "  Previs∆o: " at 75
    v_log_mostra_docto_acr_prev at 87 format "Sim/N∆o" view-as text skip
    "   Aviso DÇbito: " at 70
    v_log_mostra_docto_acr_aviso_db at 87 format "Sim/N∆o" view-as text skip
    "  Cheque: " at 77
    v_log_mostra_docto_acr_cheq at 87 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_6 header
    "  Dupl. Terceiros: " at 68
    v_log_tip_espec_docto_terc at 87 format "Sim/N∆o" view-as text skip
    "    Cheques Terceiros: " at 64
    v_log_tip_espec_docto_cheq_terc at 87 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_7 header
    "  Vendor: " at 77
    v_log_mostra_docto_vendor at 87 format "Sim/N∆o" view-as text skip
    "    Vendor Repactuado: " at 64
    v_log_mostra_docto_vendor_repac at 87 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_8 header
    "    Cheques Recebidos: " at 64
    v_log_mostra_acr_cheq_recbdo at 87 format "Sim/N∆o" view-as text skip
    "    Cheques Devolvidos: " at 63
    v_log_mostra_acr_cheq_devolv at 87 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param_9 header
    "---------------------------------------------" at 33
    "Tipo EspÇcie  " at 79
    "---------------------------------------------" at 94 skip
    "  Normal: " at 77
    v_log_mostra_docto_acr_normal at 87 format "Sim/N∆o" view-as text skip
    "   Antecipaá∆o: " at 71
    v_log_mostra_docto_acr_antecip at 87 format "Sim/N∆o" view-as text skip
    "  Previs∆o: " at 75
    v_log_mostra_docto_acr_prev at 87 format "Sim/N∆o" view-as text skip
    "   Aviso DÇbito: " at 70
    v_log_mostra_docto_acr_aviso_db at 87 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_pos_Lay_pos header
    "T°tulos em Aberto ACR -" at 1
    "  Posiá∆o Em: " at 24
    v_dat_tit_acr_aber at 38 format "99/99/9999" view-as text skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_aging_acr header
    "Resumo do Cliente    " at 1 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_branco header skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_cab_resumo header
    "----------------" at 1 skip
    "RESUMO POR CONTA" at 1 skip
    "----------------" at 1 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_cliente header
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_cliente ignorado */
    "-" at 34
    v_nom_pessoa at 36 format "x(40)" view-as text
    "-" at 77
    /* Atributo cliente.cod_id_feder ignorado */
    "-" at 100
    /* Atributo cliente.nom_abrev ignorado */
    "-" at 118
    v_nom_cidade at 120 format "x(32)" view-as text
    "-" at 153
    v_cod_unid_federac at 155 format "x(3)" view-as text
    "-" at 159
    v_cod_telefone at 161 format "x(20)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_cond_cobr header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_cond_cobr ignorado */
    "-" at 39
    /* Atributo cond_cobr_acr.des_cond_cobr ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_conta header
    "  Conta Cont†bil: " at 4
    v_cod_cta_ctbl at 22 format "x(20)" view-as text
    "-" at 43
    v_des_cta_ctbl at 45 format "x(50)" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_empresa header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_empresa ignorado */
    "-" at 34
    /* Atributo empresa.nom_razao_social ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_espec_docto header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_espec_docto ignorado */
    /* Atributo espec_docto.des_espec_docto ignorado */ skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_estab header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_estab ignorado */
    "-" at 34
    /* Atributo estabelecimento.nom_pessoa ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_grp_clien header
    /* Atributo grp_clien.cod_grp_clien ignorado */
    "-" at 34
    /* Atributo grp_clien.des_grp_clien ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_matriz header
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_clien_matriz ignorado */
    "-" at 34
    /* Atributo cliente.nom_pessoa ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_moedas header
    "|---------- Moeda Original ----------|" at 136
    "|-- Apresent -|" at 175 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_port_cart header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_portador ignorado */
    "-" at 34
    /* Atributo portador.nom_pessoa ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_cart_bcia ignorado */
    "-" at 96
    /* Atributo cart_bcia.des_cart_bcia ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_Processo header
    /* Atributo tt_titulos_em_aberto_acr.ttv_cod_proces_export ignorado */ skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_repres header
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_repres ignorado */
    "-" at 34
    /* Atributo representante.nom_pessoa ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_un header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_unid_negoc ignorado */
    "-" at 26
    /* Atributo unid_negoc.des_unid_negoc ignorado */ skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_quebra_Lay_vencto header skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_amr_pmr header
    skip (1)
    "     Prazo MÇdio de Recebimento" at 21
    ":" at 52
    v_num_dias_pmr_7 to 62 format "->>>>>>9" view-as text skip
    "     Atraso MÇdio do Per°odo" at 24
    ":" at 52
    v_num_dias_amr_7 to 62 format "->>>>>>9" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_2 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_2 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_3 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[2] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[2] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[2] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[2] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_3 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_4 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_5 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[3] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[3] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[3] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[3] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_4 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_6 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_7 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[4] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[4] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[4] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[4] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_5 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_8 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_9 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[5] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[5] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[5] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[5] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_6 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_10 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_avencer_11 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[6] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[6] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[6] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[6] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_avencer_7 header
    skip (1)
    /* Vari†vel v_num_dias_avencer_12 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_avencer[7] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_avencer[7] to 90 format ">>>>9" view-as text
    v_val_perc_avencer[7] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[7] to 124 format ">>9.99" view-as text
    skip (1)
    "     Total de T°tulos a Vencer" at 28
    ":" at 58
    v_val_tot_sdo_avencer to 80 format "->>>,>>>,>>>,>>9.99" view-as text
    v_qtd_tot_tit_avencer to 90 format ">>>,>>9" view-as text
    v_val_perc_avencer[8] to 105 format ">>9.99" view-as text
    v_val_perc_geral_avencer[8] to 124 format ">>9.99" view-as text skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_geral header
    skip (1)
    "    Total de T°tulos" at 38
    ":" at 58
    v_val_tot_sdo_normal to 80 format "->>>>,>>>,>>>,>>9.99" view-as text
    v_qtd_tot_tit_normal to 90 format ">>>,>>9" view-as text
    skip (1)
    "    Total Antecipado" at 38
    ":" at 58
    v_val_tot_sdo_antecip to 80 format "->>>>,>>>,>>>,>>9.99" view-as text
    v_qtd_tot_tit_antecip to 90 format ">>>,>>9" view-as text
    skip (1)
    "Total Geral" at 47
    ":" at 58
    v_val_tot_sdo_geral to 80 format "->>>>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_2 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_2 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_3 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[2] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[2] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[2] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[2] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_3 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_4 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_5 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[3] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[3] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[3] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[3] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_4 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_6 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_7 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[4] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[4] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[4] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[4] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_5 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_8 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_9 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[5] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[5] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[5] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[5] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_6 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_10 ignorada. N∆o esta definida no programa */
    /* Vari†vel v_num_dias_vencid_11 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[6] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[6] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[6] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[6] to 124 format ">>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_Lay_vencid_7 header
    skip (1)
    /* Vari†vel v_num_dias_vencid_12 ignorada. N∆o esta definida no programa */
    "Dias" at 55
    v_val_sdo_apres_vencid[7] to 80 format "->>,>>>,>>>,>>9.99" view-as text
    v_qtd_tit_acr_vencid[7] to 90 format ">>>>9" view-as text
    v_val_perc_vencid[7] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[7] to 124 format ">>9.99" view-as text
    skip (1)
    "     Total de T°tulos Vencidos" at 28
    ":" at 58
    v_val_tot_sdo_vencid to 80 format "->>>,>>>,>>>,>>9.99" view-as text
    v_qtd_tot_tit_vencid to 90 format ">>>,>>9" view-as text
    v_val_perc_vencid[8] to 105 format ">>9.99" view-as text
    v_val_perc_geral_vencid[8] to 124 format ">>9.99" view-as text skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_cta_Lay_resumo_cta header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Est" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Est" at 1
&ENDIF
    "Un N" at 7
    "Conta" at 12
    "Saldo" to 50
    "Sdo Ctbl" to 69
    "Diferenáa" to 88 skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "---" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "----" at 7
    "--------------------" at 12
    "------------------" to 50
    "------------------" to 69
    "------------------" to 88 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_resumo_cta_Lay_resumo_cta2 header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Est" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Est" at 1
&ENDIF
    "Conta" at 7
    "Saldo" to 45
    "Sdo Ctbl" to 64
    "Diferenáa" to 83 skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "---" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "--------------------" at 7
    "------------------" to 45
    "------------------" to 64
    "------------------" to 83 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_tip_fluxo_Lay_tip_fluxo header
    "Tipo Fluxo Financ" at 149
    "Valor Origin" to 190
    "Saldo T°tulo" to 205
    "Saldo Apres" to 221 skip
    "-----------------" at 149
    "------------------" to 190
    "--------------" to 205
    "---------------" to 221 skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_tit_aber_flu_Lay_tit_aber_flu header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_estab ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_espec_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_ser_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_parcela ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_unid_negoc ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tip_fluxo_financ ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_cliente ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_nom_abrev ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_emis_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_refer ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_indic_econ ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_val_origin_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres ignorado */
    /* Atributo tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr ignorado */
    /* Atributo ped_vda_tit_acr.cod_ped_vda ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut ignorado */ skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_tit_aber_flu_Lay_tit_ab_f_por header
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_estab ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_espec_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_ser_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_parcela ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_unid_negoc ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tip_fluxo_financ ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cdn_cliente ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_portador ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_cart_bcia ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_emis_docto ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_refer ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_cod_indic_econ ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_val_origin_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr ignorado */
    /* Atributo tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres ignorado */
    /* Atributo tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr ignorado */
    /* Atributo ped_vda_tit_acr.cod_ped_vda ignorado */
    /* Atributo tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut ignorado */ skip (1)
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_total header
    "---------------" at 163 skip
    fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
    ":" at 155
    v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_total_geral header
    "---------------" at 163 skip
    "     Prazo MÇdio de Recebimento" at 30
    ":" at 62
    v_num_dias_pmr_7 to 71 format "->>>>>>9" view-as text
    "     Atraso MÇdio de Recebimento" at 75
    ":" at 108
    v_num_dias_amr_7 to 117 format "->>>>>>9" view-as text
    fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
    ":" at 155
    v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 244 page-top stream-io.
def frame f_rpt_s_1_Grp_unid_negoc_Lay_unid_negoc header skip (1) skip
    with no-box no-labels width 244 page-top stream-io.


/*************************** Report Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_fil_01_tit_acr_em_aberto_rpt
    rt_015
         at row 01.54 col 52.43
    " Situaá∆o " view-as text
         at row 01.24 col 54.43 bgcolor 8 
    rt_021
         at row 01.54 col 21.00
    " Considera " view-as text
         at row 01.24 col 23.00 bgcolor 8 
    rt_016
         at row 01.54 col 02.00
    " Tipo EspÇcie " view-as text
         at row 01.24 col 04.00 bgcolor 8 
    rt_019
         at row 02.38 col 53.29 bgcolor 8 
    rt_cxcf
         at row 12.29 col 02.00 bgcolor 7 
    v_log_mostra_docto_acr_normal
         at row 02.13 col 03.00 label "Normal"
         help "Mostra T°tulo Normal ?"
         view-as toggle-box
    v_log_mostra_docto_acr_prev
         at row 03.13 col 03.00 label "Previs∆o"
         help "Mostra Previs∆o ?"
         view-as toggle-box
    v_log_mostra_docto_acr_cheq
         at row 04.13 col 03.00 label "Cheque"
         help "Mostra Cheques?"
         view-as toggle-box
    v_log_mostra_docto_acr_aviso_db
         at row 05.13 col 03.00 label "Aviso Deb"
         help "Mostra Aviso DÇbito ?"
         view-as toggle-box
    v_log_mostra_docto_acr_antecip
         at row 06.13 col 03.00 label "Antecip"
         help "Mostra Antecipaá∆o ?"
         view-as toggle-box
    v_log_mostra_docto_vendor
         at row 07.13 col 03.00 label "Vendor"
         help "T°tulos de EspÇcie Vendor"
         view-as toggle-box
    v_log_mostra_docto_vendor_repac
         at row 08.13 col 03.00 label "Vendor Repactuado"
         help "T°tulos com EspÇcie Vendor Repactuado"
         view-as toggle-box
    v_log_tip_espec_docto_terc
         at row 09.13 col 03.00 label "Dup. Terceiros"
         view-as toggle-box
    v_log_tip_espec_docto_cheq_terc
         at row 10.13 col 03.00 label "Cheques Terceiros"
         view-as toggle-box
    v_log_tit_acr_indcao_perda_dedut
         at row 02.13 col 23.00 label "Indicados Perda Dedut°vel"
         view-as toggle-box
    v_log_tit_acr_nao_indcao_perda
         at row 03.13 col 23.00 label "N∆o Indicados Perda Dedut°vel"
         view-as toggle-box
    v_log_tit_acr_estordo
         at row 04.13 col 23.00 label "Estornados que n∆o Contabilizam"
         view-as toggle-box
    v_log_consid_abat
         at row 05.13 col 23.00 label "Abatimento"
         view-as toggle-box
    v_log_consid_desc
         at row 06.13 col 23.00 label "Desconto"
         view-as toggle-box
    v_log_consid_impto_retid
         at row 07.13 col 23.00 label "Imposto Retido"
         view-as toggle-box
    v_log_consid_juros
         at row 08.13 col 23.00 label "Juros"
         view-as toggle-box
    v_log_consid_multa
         at row 09.13 col 23.00 label "Multa"
         view-as toggle-box
    v_log_mostra_acr_cheq_recbdo
         at row 10.13 col 23.00 label "Cheques Receb."
         help "Cheques Recebidos"
         view-as toggle-box
    v_log_mostra_acr_cheq_devolv
         at row 11.13 col 23.00 label "Cheques Devolv."
         help "Cheques Devolvidos"
         view-as toggle-box
    v_log_tit_acr_vencid
         at row 03.00 col 54.43 label "Vencidos"
         help "Mostra os T°tulos Vencidos ?"
         view-as toggle-box
    v_qtd_dias_vencid
         at row 03.00 col 78.86 colon-aligned label "A mais de ...dias"
         help "Quantidade de Dias Vencidos"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_log_tit_acr_avencer
         at row 04.58 col 54.43 label "A Vencer"
         help "Mostra os T°tulos a Vencer ?"
         view-as toggle-box
    v_qtd_dias_avencer
         at row 04.58 col 78.86 colon-aligned label "Em atÇ ...dias"
         help "Quantidade de Dias a Vencer"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_calc_atraso
         at row 07.75 col 73.14 colon-aligned label "Calc Dias Atraso"
         help "Data de C†lculo dos Dias em Atraso"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_ok
         at row 12.50 col 03.00 font ?
         help "OK"
    bt_can
         at row 12.50 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 12.50 col 77.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 14.13 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Filtro T°tulos em Aberto - ACR".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 10.00
           bt_can:height-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 01.00
           bt_hel2:width-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 10.00
           bt_hel2:height-chars in frame f_fil_01_tit_acr_em_aberto_rpt = 01.00
           bt_ok:width-chars    in frame f_fil_01_tit_acr_em_aberto_rpt = 10.00
           bt_ok:height-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 01.00
           rt_015:width-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 35.72
           rt_015:height-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 10.46
           rt_016:width-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 18.57
           rt_016:height-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 10.46
           rt_019:width-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 34.14
           rt_019:height-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 03.63
           rt_021:width-chars   in frame f_fil_01_tit_acr_em_aberto_rpt = 31.00
           rt_021:height-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 10.46
           rt_cxcf:width-chars  in frame f_fil_01_tit_acr_em_aberto_rpt = 86.57
           rt_cxcf:height-chars in frame f_fil_01_tit_acr_em_aberto_rpt = 01.42.
    /* set private-data for the help system */
    assign v_log_mostra_docto_acr_normal:private-data    in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023768":U
           v_log_mostra_docto_acr_prev:private-data      in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023834":U
           v_log_mostra_docto_acr_cheq:private-data      in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023766":U
           v_log_mostra_docto_acr_aviso_db:private-data  in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023765":U
           v_log_mostra_docto_acr_antecip:private-data   in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023764":U
           v_log_mostra_docto_vendor:private-data        in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_mostra_docto_vendor_repac:private-data  in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_tip_espec_docto_terc:private-data       in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_tip_espec_docto_cheq_terc:private-data  in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_tit_acr_indcao_perda_dedut:private-data in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023772":U
           v_log_tit_acr_nao_indcao_perda:private-data   in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023773":U
           v_log_tit_acr_estordo:private-data            in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023771":U
           v_log_consid_abat:private-data                in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000022882":U
           v_log_consid_desc:private-data                in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000022884":U
           v_log_consid_impto_retid:private-data         in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_consid_juros:private-data               in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000022886":U
           v_log_consid_multa:private-data               in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000022888":U
           v_log_mostra_acr_cheq_recbdo:private-data     in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_mostra_acr_cheq_devolv:private-data     in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000017474":U
           v_log_tit_acr_vencid:private-data             in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023770":U
           v_qtd_dias_vencid:private-data                in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023775":U
           v_log_tit_acr_avencer:private-data            in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023769":U
           v_qtd_dias_avencer:private-data               in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023774":U
           v_dat_calc_atraso:private-data                in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000023763":U
           bt_ok:private-data                            in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000010721":U
           bt_can:private-data                           in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000011050":U
           bt_hel2:private-data                          in frame f_fil_01_tit_acr_em_aberto_rpt = "HLP=000011326":U
           frame f_fil_01_tit_acr_em_aberto_rpt:private-data                                     = "HLP=000017474".

def frame f_rpt_41_tit_acr_em_aberto
    rt_006
         at row 01.42 col 02.00
    " Visualizaá∆o " view-as text
         at row 01.12 col 04.00 bgcolor 8 
    rt_002
         at row 01.42 col 54.72
    " Apresentaá∆o " view-as text
         at row 01.12 col 56.72 bgcolor 8 
    rt_018
         at row 01.42 col 30.72 bgcolor 8 
    rt_007
         at row 01.42 col 82.43 bgcolor 8 
    rt_target
         at row 08.33 col 02.00
    " Destino " view-as text
         at row 08.03 col 04.00 bgcolor 8 
    rt_run
         at row 08.33 col 48.00
    " Execuá∆o " view-as text
         at row 08.03 col 50.00
    rt_dimensions
         at row 08.33 col 72.72
    " Dimens‰es " view-as text
         at row 08.03 col 74.72
/*     rt_019                      */
/*          at row 04.25 col 33.43 */
/*     " Planilha " view-as text             */
/*          at row 03.95 col 35.43 bgcolor 8 */
    rt_cxcf
         at row 11.83 col 02.00 bgcolor 7 
    v_ind_visualiz_tit_acr_vert
         at row 01.92 col 03.14 no-label
         help "Visualiza T°tulos por Estabelecimento ou UN"
         view-as radio-set Vertical
         radio-buttons "Por Estabelecimento", "Por Estabelecimento", "Por Unidade Neg¢cio", "Por Unidade Neg¢cio"
          /*l_por_estabelecimento*/ /*l_por_estabelecimento*/ /*l_por_unid_negoc*/ /*l_por_unid_negoc*/
         bgcolor 8 
    v_log_visualiz_analit
         at row 04.71 col 03.14 label "Imprime Relat¢rio"
         help "Visualiza Anal°tico ?"
         view-as toggle-box
    v_log_visualiz_sint
         at row 05.71 col 03.14 label "Imprime Resumo Final"
         help "Visualiza SintÇtico ?"
         view-as toggle-box
    v_log_visualiz_clien
         at row 06.71 col 03.14 label "Imprime Resumo Cliente"
         help "Visualiza por Cliente ?"
         view-as toggle-box
    v_log_emit_movto_cobr
         at row 02.25 col 33.14 label "Emitir Movtos Cobr"
         help "Emitir Movimentos de Cobranáa do T°tulo?"
         view-as toggle-box
    bt_planilha_excel
         at row 04.75 col 38.43 font ?
         help "Planilha do Excel"
    v_dat_tit_acr_aber
         at row 01.92 col 64.14 colon-aligned label "Posiá∆o Em"
         help "Data para Consideraá∆o dos T°tulos em Aberto"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_log_imprime_fatura_convenio
         at row 05.71 col 33.14 label "Imprime Fatura Convànio"
         help "Imprime Fatura Convànio ?"
    v_log_imprime_cupom_convenio
         at row 04.71 col 33.14 label "Imprime Cupom Convànio"
         help "Imprime Cupom Convànio ?"
         view-as toggle-box
    " Convànio " view-as text
         at row 01.85 col 32.43 bgcolor 8 
    v_cod_convenio_ini
         at row 02.55 col 31.14 colon-aligned 
         help "Informar a Faixa Inicial do Convànio"
         view-as fill-in
         size-chars 6.5 by .88
         fgcolor ? bgcolor 15 font 2 NO-LABEL
    v_cod_convenio_fim
         at row 02.55 col 43.14 colon-aligned label "<< >>"
         help "Informar a Faixa FINAL do Convànio"
         view-as fill-in
         size-chars 6.5 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_finalid_econ
         at row 03.58 col 64.29 colon-aligned label "Finalidade"
         help "Finalidade Econìmica"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_188063
         at row 03.58 col 77.43
    v_cod_finalid_econ_apres
         at row 04.58 col 64.29 colon-aligned label "Apresentaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_188064
         at row 04.58 col 77.43
    v_dat_cotac_indic_econ
         at row 05.58 col 64.29 colon-aligned label "Data Cotaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_fil2
         at row 01.58 col 83.43 font ?
         help "Filtro"
    bt_ran2
         at row 02.83 col 83.43 font ?
         help "Faixa"
    bt_classificacao
         at row 04.08 col 83.43 font ?
         help "Classificaá∆o"
    bt_time
         at row 05.33 col 83.57 font ?
         help "Prazos"
    rs_cod_dwb_output
         at row 09.04 col 03.00
         help "" no-label
    ed_1x40
         at row 10.00 col 03.00
         help "" no-label
    bt_get_file
         at row 10.00 col 42.00 font ?
         help "Pesquisa Arquivo"
    bt_set_printer
         at row 10.00 col 42.00 font ?
         help "Define Impressora e Layout de Impress∆o"
    rs_ind_run_mode
         at row 09.04 col 49.00
         help "" no-label
    v_log_print_par
         at row 10.04 col 49.00 label "Imprime ParÉmetros"
         view-as toggle-box
    v_qtd_line
         at row 09.04 col 81.00 colon-aligned
         view-as fill-in
         fgcolor ? bgcolor 15 font 2
    v_qtd_column
         at row 10.04 col 81.00 colon-aligned
         view-as fill-in
         fgcolor ? bgcolor 15 font 2
    bt_close
         at row 12.04 col 03.00 font ?
         help "Fecha"
    bt_print
         at row 12.04 col 14.00 font ?
         help "Imprime"
    bt_can
         at row 12.04 col 25.00 font ?
         help "Cancela"
    bt_hel2
         at row 12.04 col 77.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 13.67
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "T°tulos em Aberto - Convànio".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 10.00
           bt_can:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 01.00
           bt_classificacao:width-chars   in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_classificacao:height-chars  in frame f_rpt_41_tit_acr_em_aberto = 01.13
           bt_close:width-chars           in frame f_rpt_41_tit_acr_em_aberto = 10.00
           bt_close:height-chars          in frame f_rpt_41_tit_acr_em_aberto = 01.00
           bt_fil2:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_fil2:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.13
           bt_get_file:width-chars        in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_get_file:height-chars       in frame f_rpt_41_tit_acr_em_aberto = 01.08
           bt_hel2:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 10.00
           bt_hel2:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.00
           bt_planilha_excel:width-chars  in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_planilha_excel:height-chars in frame f_rpt_41_tit_acr_em_aberto = 01.13
           bt_print:width-chars           in frame f_rpt_41_tit_acr_em_aberto = 10.00
           bt_print:height-chars          in frame f_rpt_41_tit_acr_em_aberto = 01.00
           bt_ran2:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_ran2:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.13
           bt_set_printer:width-chars     in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_set_printer:height-chars    in frame f_rpt_41_tit_acr_em_aberto = 01.08
           bt_time:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 04.00
           bt_time:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.13
           ed_1x40:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 38.00
           ed_1x40:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.00
           rt_002:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 27.43
           rt_002:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 06.33
           rt_006:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 28.43
           rt_006:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 06.33
           rt_007:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 06.00
           rt_007:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 06.33
           rt_018:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 23.72
           rt_018:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 06.33
/*            rt_019:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 15.14 */
/*            rt_019:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 02.25 */
           rt_cxcf:width-chars            in frame f_rpt_41_tit_acr_em_aberto = 86.57
           rt_cxcf:height-chars           in frame f_rpt_41_tit_acr_em_aberto = 01.42
           rt_dimensions:width-chars      in frame f_rpt_41_tit_acr_em_aberto = 15.72
           rt_dimensions:height-chars     in frame f_rpt_41_tit_acr_em_aberto = 03.00
           rt_run:width-chars             in frame f_rpt_41_tit_acr_em_aberto = 23.86
           rt_run:height-chars            in frame f_rpt_41_tit_acr_em_aberto = 03.00
           rt_target:width-chars          in frame f_rpt_41_tit_acr_em_aberto = 45.00
           rt_target:height-chars         in frame f_rpt_41_tit_acr_em_aberto = 03.00.
    /* set return-inserted = yes for editors */
    assign ed_1x40:return-inserted in frame f_rpt_41_tit_acr_em_aberto = yes.
    /* set private-data for the help system */
    assign v_ind_visualiz_tit_acr_vert:private-data in frame f_rpt_41_tit_acr_em_aberto = "HLP=000023756":U
           v_log_visualiz_analit:private-data       in frame f_rpt_41_tit_acr_em_aberto = "HLP=000023761":U
           v_log_visualiz_sint:private-data         in frame f_rpt_41_tit_acr_em_aberto = "HLP=000023762":U
           v_log_visualiz_clien:private-data        in frame f_rpt_41_tit_acr_em_aberto = "HLP=000017474":U
           v_log_emit_movto_cobr:private-data       in frame f_rpt_41_tit_acr_em_aberto = "HLP=000027391":U
           bt_planilha_excel:private-data           in frame f_rpt_41_tit_acr_em_aberto = "HLP=000017474":U
           v_dat_tit_acr_aber:private-data          in frame f_rpt_41_tit_acr_em_aberto = "HLP=000023755":U
           bt_zoo_188063:private-data               in frame f_rpt_41_tit_acr_em_aberto = "HLP=000009431":U
           v_cod_finalid_econ:private-data          in frame f_rpt_41_tit_acr_em_aberto = "HLP=000014662":U
           bt_zoo_188064:private-data               in frame f_rpt_41_tit_acr_em_aberto = "HLP=000009431":U
           v_cod_finalid_econ_apres:private-data    in frame f_rpt_41_tit_acr_em_aberto = "HLP=000014663":U
           v_dat_cotac_indic_econ:private-data      in frame f_rpt_41_tit_acr_em_aberto = "HLP=000012264":U
           bt_fil2:private-data                     in frame f_rpt_41_tit_acr_em_aberto = "HLP=000008766":U
           bt_ran2:private-data                     in frame f_rpt_41_tit_acr_em_aberto = "HLP=000008773":U
           bt_classificacao:private-data            in frame f_rpt_41_tit_acr_em_aberto = "HLP=000021578":U
           bt_time:private-data                     in frame f_rpt_41_tit_acr_em_aberto = "HLP=000008764":U
           rs_cod_dwb_output:private-data           in frame f_rpt_41_tit_acr_em_aberto = "HLP=000017474":U
           ed_1x40:private-data                     in frame f_rpt_41_tit_acr_em_aberto = "HLP=000017474":U
           bt_get_file:private-data                 in frame f_rpt_41_tit_acr_em_aberto = "HLP=000008782":U
           bt_set_printer:private-data              in frame f_rpt_41_tit_acr_em_aberto = "HLP=000008785":U
           rs_ind_run_mode:private-data             in frame f_rpt_41_tit_acr_em_aberto = "HLP=000017474":U
           v_log_print_par:private-data             in frame f_rpt_41_tit_acr_em_aberto = "HLP=000024662":U
           v_qtd_line:private-data                  in frame f_rpt_41_tit_acr_em_aberto = "HLP=000024737":U
           v_qtd_column:private-data                in frame f_rpt_41_tit_acr_em_aberto = "HLP=000024669":U
           bt_close:private-data                    in frame f_rpt_41_tit_acr_em_aberto = "HLP=000009420":U
           bt_print:private-data                    in frame f_rpt_41_tit_acr_em_aberto = "HLP=000010815":U
           bt_can:private-data                      in frame f_rpt_41_tit_acr_em_aberto = "HLP=000011050":U
           bt_hel2:private-data                     in frame f_rpt_41_tit_acr_em_aberto = "HLP=000011326":U
           frame f_rpt_41_tit_acr_em_aberto:private-data                                = "HLP=000017474".
    /* enable function buttons */
    assign bt_zoo_188063:sensitive in frame f_rpt_41_tit_acr_em_aberto = yes
           bt_zoo_188064:sensitive in frame f_rpt_41_tit_acr_em_aberto = yes.
    /* move buttons to top */
    bt_zoo_188063:move-to-top().
    bt_zoo_188064:move-to-top().



{include/i_fclfrm.i f_fil_01_tit_acr_em_aberto_rpt f_rpt_41_tit_acr_em_aberto }
/*************************** Frame Definition End ***************************/

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
def var v_prog_filtro_pdf as handle no-undo.

function getCodTipoRelat returns character in v_prog_filtro_pdf.

run prgtec/btb/btb920aa.py persistent set v_prog_filtro_pdf.

run pi_define_objetos in v_prog_filtro_pdf (frame f_rpt_41_tit_acr_em_aberto:handle,
                       rs_cod_dwb_output:handle in frame f_rpt_41_tit_acr_em_aberto,
                       bt_get_file:row in frame f_rpt_41_tit_acr_em_aberto,
                       bt_get_file:col in frame f_rpt_41_tit_acr_em_aberto).

&endif
/* tech38629 - Fim da alteraá∆o */


/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON CHOOSE OF bt_ok IN FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    assign input frame f_fil_01_tit_acr_em_aberto_rpt v_dat_calc_atraso
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_consid_abat
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_consid_desc
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_consid_impto_retid
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_antecip
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_aviso_db
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_normal
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_prev
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_avencer
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_estordo
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_indcao_perda_dedut
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_nao_indcao_perda
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_vencid
           input frame f_fil_01_tit_acr_em_aberto_rpt v_qtd_dias_avencer
           input frame f_fil_01_tit_acr_em_aberto_rpt v_qtd_dias_vencid
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_consid_juros
           input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_cheq.
    if v_log_control_terc_acr = yes then do:
        assign input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tip_espec_docto_terc
               input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tip_espec_docto_cheq_terc.
    end.

    &if defined(BF_FIN_CONTROL_CHEQUES) &then
        assign input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_acr_cheq_recbdo
    	   input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_acr_cheq_devolv.
    &endif

    if  v_log_modul_vendor = yes then do:
        assign input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_vendor
               input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_vendor_repac.
    end.
END. /* ON CHOOSE OF bt_ok IN FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON VALUE-CHANGED OF v_log_mostra_docto_acr_cheq IN FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    &if defined(BF_FIN_CONTROL_CHEQUES) &then
    if  input frame f_fil_01_tit_acr_em_aberto_rpt v_log_mostra_docto_acr_cheq = yes then do:
            enable v_log_mostra_acr_cheq_recbdo
                   v_log_mostra_acr_cheq_devolv
                   with frame f_fil_01_tit_acr_em_aberto_rpt.
        end.
        else do:
            assign v_log_mostra_acr_cheq_recbdo:checked in frame f_fil_01_tit_acr_em_aberto_rpt = no
                   v_log_mostra_acr_cheq_devolv:checked in frame f_fil_01_tit_acr_em_aberto_rpt = no.
            disable v_log_mostra_acr_cheq_recbdo
                    v_log_mostra_acr_cheq_devolv
                    with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
    &endif
END. /* ON VALUE-CHANGED OF v_log_mostra_docto_acr_cheq IN FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON VALUE-CHANGED OF v_log_tit_acr_avencer IN FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    if  input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_avencer = yes then do:
        enable v_qtd_dias_avencer
               with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
    else do:
        disable v_qtd_dias_avencer
                with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
END. /* ON VALUE-CHANGED OF v_log_tit_acr_avencer IN FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON VALUE-CHANGED OF v_log_tit_acr_vencid IN FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    if  input frame f_fil_01_tit_acr_em_aberto_rpt v_log_tit_acr_vencid = yes then do:
        enable v_qtd_dias_vencid
               with frame f_fil_01_tit_acr_em_aberto_rpt.
        enable v_log_emit_movto_cobr
               with frame f_rpt_41_tit_acr_em_aberto.
    end.
    else do:
        assign v_log_emit_movto_cobr:checked in frame f_rpt_41_tit_acr_em_aberto = no.
        disable v_qtd_dias_vencid
                with frame f_fil_01_tit_acr_em_aberto_rpt.
        disable v_log_emit_movto_cobr
                with frame f_rpt_41_tit_acr_em_aberto.
    end.

    ASSIGN v_log_emit_movto_cobr:VISIBLE IN FRAME  f_rpt_41_tit_acr_em_aberto = NO.
END. /* ON VALUE-CHANGED OF v_log_tit_acr_vencid IN FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON CHOOSE OF bt_classificacao IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    assign input frame f_rpt_41_tit_acr_em_aberto v_ind_visualiz_tit_acr_vert.
    if  search("prgfin/acr/acr303zb.r") = ? and search("prgfin/acr/acr303zb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr303zb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr303zb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr303zb.p /*prg_fnc_tit_acr_em_aber_classif*/.
END. /* ON CHOOSE OF bt_classificacao IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    run pi_choose_bt_fil2_rpt_tit_acr_em_aberto /*pi_choose_bt_fil2_rpt_tit_acr_em_aberto*/.
END. /* ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    system-dialog get-file v_cod_dwb_file
        title "Imprimir" /*l_imprimir*/ 
        filters '*.rpt' '*.rpt',
                "*.*"   "*.*"
        save-as
        create-test-file
        ask-overwrite.
        assign dwb_rpt_param.cod_dwb_file             = v_cod_dwb_file
               ed_1x40:screen-value in frame f_rpt_41_tit_acr_em_aberto = v_cod_dwb_file.

END. /* ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_em_aberto
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_planilha_excel IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    assign v_cod_dwb_file  = ed_1x40:screen-value in frame f_rpt_41_tit_acr_em_aberto
           v_cod_arq_modul = "plan" /*l_plan*/  + "-" + lc("ACR" /*l_acr*/ ) + '.tmp'
           v_ind_run_mode  = input frame f_rpt_41_tit_acr_em_aberto rs_ind_run_mode. 

    if  search("prgint/ufn/ufn902za.r") = ? and search("prgint/ufn/ufn902za.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn902za.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn902za.p"
                   view-as alert-box error buttons ok.
            stop.
        end.
    end.
    else
        run prgint/ufn/ufn902za.p /*prg_fnc_info_planilha*/.

END. /* ON CHOOSE OF bt_planilha_excel IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    run pi_choose_bt_print_rpt_tit_acr_em_aberto /*pi_choose_bt_print_rpt_tit_acr_em_aberto*/.

    if return-value <> "OK" /*l_ok*/  then do:
        case v_cod_erro:
           when '1652' or when '1389' or when '8751' or when '2452' then
               apply "entry" to v_cod_finalid_econ in frame f_rpt_41_tit_acr_em_aberto.
           when '2450' or when '8752' or when '2453' then
               apply "entry" to v_cod_finalid_econ_apres in frame f_rpt_41_tit_acr_em_aberto.
           when '358' then
               apply "entry" to v_dat_cotac_indic_econ in frame f_rpt_41_tit_acr_em_aberto.
        end.
        return no-apply.
    end.

END. /* ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_ran2 IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    assign input frame f_rpt_41_tit_acr_em_aberto v_ind_visualiz_tit_acr_vert.

    if  search("prgfin/acr/acr303za_Convenio.r") = ? and search("prgfin/acr/acr303za_Convenio.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr303za_Convenio.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr303za_Convenio.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr303za_Convenio.p /*prg_fnc_tit_acr_em_aber_faixa*/.
END. /* ON CHOOSE OF bt_ran2 IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    assign v_nom_dwb_printer      = ""
           v_cod_dwb_print_layout = "".

    &if '{&emsbas_version}' <= '1.00' &then
    if  search("prgtec/btb/btb036nb.r") = ? and search("prgtec/btb/btb036nb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb036nb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb036nb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgtec/btb/btb036nb.p (output v_nom_dwb_printer,
                               output v_cod_dwb_print_layout) /*prg_see_layout_impres_imprsor*/.
    &else
    if  search("prgtec/btb/btb036zb.r") = ? and search("prgtec/btb/btb036zb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb036zb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb036zb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgtec/btb/btb036zb.p (input-output v_nom_dwb_printer,
                               input-output v_cod_dwb_print_layout,
                               input-output v_nom_dwb_print_file) /*prg_fnc_layout_impres_imprsor*/.
    &endif

    if  v_nom_dwb_printer <> ""
    and  v_cod_dwb_print_layout <> ""
    then do:
        assign dwb_rpt_param.nom_dwb_printer      = v_nom_dwb_printer
               dwb_rpt_param.cod_dwb_print_layout = v_cod_dwb_print_layout
    &if '{&emsbas_version}' > '1.00' &then           
    &if '{&emsbas_version}' >= '5.03' &then           
               dwb_rpt_param.nom_dwb_print_file        = v_nom_dwb_print_file
    &else
               dwb_rpt_param.cod_livre_1               = v_nom_dwb_print_file
    &endif
    &endif
               ed_1x40:screen-value in frame f_rpt_41_tit_acr_em_aberto = v_nom_dwb_printer
                                                       + ":"
                                                       + v_cod_dwb_print_layout
    &if '{&emsbas_version}' > '1.00' &then
                                                       + (if v_nom_dwb_print_file <> "" then ":" + v_nom_dwb_print_file
                                                          else "")
    &endif
    .
        find layout_impres no-lock
             where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
               and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
        assign v_qtd_line               = layout_impres.num_lin_pag.
        display v_qtd_line
                with frame f_rpt_41_tit_acr_em_aberto.
    end /* if */.

END. /* ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_em_aberto */

ON CHOOSE OF bt_time IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if  search("prgfin/acr/acr303zc.r") = ? and search("prgfin/acr/acr303zc.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr303zc.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr303zc.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr303zc.p /*prg_fnc_tit_acr_em_aber_praz*/.
END. /* ON CHOOSE OF bt_time IN FRAME f_rpt_41_tit_acr_em_aberto */

ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_filename_final             as character       no-undo. /*local*/
    def var v_cod_filename_initial           as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    block:
    do with frame f_rpt_41_tit_acr_em_aberto:
        if  rs_cod_dwb_output:screen-value = "Arquivo" /*l_file*/ 
        then do:
            if  rs_ind_run_mode:screen-value <> "Batch" /*l_batch*/ 
            then do:
                if  ed_1x40:screen-value <> ""
                then do:
                    assign ed_1x40:screen-value   = replace(ed_1x40:screen-value, '~\', '/')
                           v_cod_filename_initial = entry(num-entries(ed_1x40:screen-value, '/'), ed_1x40:screen-value, '/')
                           v_cod_filename_final   = substring(ed_1x40:screen-value, 1,
                                                              length(ed_1x40:screen-value) - length(v_cod_filename_initial) - 1)
                           file-info:file-name    = v_cod_filename_final.
                    if  file-info:file-type = ?
                    then do:
                         /* O diret¢rio &1 n∆o existe ! */
                         run pi_messages (input "show",
                                          input 4354,
                                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                             v_cod_filename_final)) /*msg_4354*/.
                         return no-apply.
                    end /* if */.
                end /* if */.
            end /* if */.

            find dwb_rpt_param
                where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
                and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                exclusive-lock no-error.
            assign dwb_rpt_param.cod_dwb_file = ed_1x40:screen-value.
        end /* if */.
    end /* do block */.

END. /* ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_em_aberto */

ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    initout:
    do with frame f_rpt_41_tit_acr_em_aberto:
        /* block: */
        case self:screen-value:
            when "Terminal" /*l_terminal*/ then ter:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_em_aberto v_qtd_line.
                end /* if */.
                if  v_qtd_line_ant > 0
                then do:
                    assign v_qtd_line = v_qtd_line_ant.
                end /* if */.
                else do:
                    assign v_qtd_line = (if  dwb_rpt_param.qtd_dwb_line > 0 then dwb_rpt_param.qtd_dwb_line
                                        else v_rpt_s_1_lines).
                end /* else */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_em_aberto.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = no
                       bt_get_file:visible    = no
                       bt_set_printer:visible = no.
            end /* do ter */.
            when "Arquivo" /*l_file*/ then fil:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_em_aberto v_qtd_line.
                end /* if */.
                if  v_qtd_line_ant > 0
                then do:
                    assign v_qtd_line = v_qtd_line_ant.
                end /* if */.
                else do:
                    assign v_qtd_line = (if  dwb_rpt_param.qtd_dwb_line > 0 then dwb_rpt_param.qtd_dwb_line
                                        else v_rpt_s_1_lines).
                end /* else */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_em_aberto.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = yes
                       bt_set_printer:visible = no
                       bt_get_file:visible    = yes.

                /* define arquivo default */
                find usuar_mestre no-lock
                     where usuar_mestre.cod_usuario = v_cod_dwb_user
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index srmstr_id
    &endif
                      /*cl_current_user of usuar_mestre*/ no-error.
                do  transaction:                
                    find dwb_rpt_param
                        where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
                        and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                        exclusive-lock no-error.

                    assign dwb_rpt_param.cod_dwb_file = "".

                    if  rs_ind_run_mode:screen-value in frame f_rpt_41_tit_acr_em_aberto <> "Batch" /*l_batch*/ 
                    then do:
                        if  usuar_mestre.nom_dir_spool <> ""
                        then do:
                            assign dwb_rpt_param.cod_dwb_file = usuar_mestre.nom_dir_spool
                                                              + "~/".
                        end /* if */.
                        if  usuar_mestre.nom_subdir_spool <> ""
                        then do:
                            assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                              + usuar_mestre.nom_subdir_spool
                                                              + "~/".
                        end /* if */.
                    end /* if */.
                    else do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file.
                    end /* else */.
                    if  v_cod_dwb_file_temp = ""
                    then do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + caps("acr303aa":U)
                                                          + '.rpt'.
                    end /* if */.
                    else do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + v_cod_dwb_file_temp.
                    end /* else */.
                    assign ed_1x40:screen-value               = dwb_rpt_param.cod_dwb_file
                           dwb_rpt_param.cod_dwb_print_layout = ""
                           v_qtd_line                         = (if v_qtd_line_ant > 0 then v_qtd_line_ant
                                                                 else v_rpt_s_1_lines)
    &if '{&emsbas_version}' > '1.00' &then
                           v_nom_dwb_print_file               = ""
    &endif
    .
                end.     
            end /* do fil */.
            when "Impressora" /*l_printer*/ then prn:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/  /* and rs_ind_run_mode <> "Batch" /*l_batch*/  */
                then do: 
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_em_aberto v_qtd_line.
                end /* if */.

                assign ed_1x40:sensitive        = no
                       bt_get_file:visible      = no
                       bt_set_printer:visible   = yes
                       bt_set_printer:sensitive = yes.

                /* define layout default */
                if  dwb_rpt_param.nom_dwb_printer = ""
                or  dwb_rpt_param.cod_dwb_print_layout = ""
                then do:
                    run pi_set_print_layout_default /*pi_set_print_layout_default*/.
                end /* if */.
                else do:
                    assign ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                                + ":"
                                                + dwb_rpt_param.cod_dwb_print_layout.
                end /* else */.
                find layout_impres no-lock
                     where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                       and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                if  avail layout_impres
                then do:
                    assign v_qtd_line               = layout_impres.num_lin_pag.
                end /* if */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_em_aberto.
            end /* do prn */.
        end /* case block */.

        assign v_cod_dwb_file_temp = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/").
        if  index(v_cod_dwb_file_temp, "~/") <> 0
        then do:
            assign v_cod_dwb_file_temp = substring(v_cod_dwb_file_temp, r-index(v_cod_dwb_file_temp, "~/") + 1).
        end /* if */.
        else do:
            assign v_cod_dwb_file_temp = dwb_rpt_param.cod_dwb_file.
        end /* else */.
    end /* do initout */.

    if  self:screen-value = "Impressora" /*l_printer*/ 
    then do:
        disable v_qtd_line
                with frame f_rpt_41_tit_acr_em_aberto.
    end /* if */.
    else do:
        enable v_qtd_line
               with frame f_rpt_41_tit_acr_em_aberto.
    end /* else */.
    assign rs_cod_dwb_output.

END. /* ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_em_aberto */

ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    do  transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.ind_dwb_run_mode = input frame f_rpt_41_tit_acr_em_aberto rs_ind_run_mode.

        if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            if  rs_cod_dwb_output:disable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_em_aberto
            then do:
            end /* if */.
        end /* if */.
        else do:
            if  rs_cod_dwb_output:enable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_em_aberto
            then do:
            end /* if */.
        end /* else */.
        if  rs_ind_run_mode = "Batch" /*l_batch*/ 
        then do:
           assign v_qtd_line = v_qtd_line_ant.
           display v_qtd_line
                   with frame f_rpt_41_tit_acr_em_aberto.
        end /* if */.
        assign rs_ind_run_mode.
        apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_em_aberto.
    end.    

END. /* ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_em_aberto */

ON LEAVE OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if  v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_em_aberto = " "
    then do:
        assign v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_em_aberto = input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ.
    end /* if */.

    apply "leave" to v_cod_finalid_econ_apres in frame f_rpt_41_tit_acr_em_aberto.
END. /* ON LEAVE OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_em_aberto */

ON LEAVE OF v_cod_finalid_econ_apres IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if  input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ = input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ_apres then do:
        disable v_dat_cotac_indic_econ
                with frame f_rpt_41_tit_acr_em_aberto.
    end.
    else do:
        enable v_dat_cotac_indic_econ
               with frame f_rpt_41_tit_acr_em_aberto.
    end.
END. /* ON LEAVE OF v_cod_finalid_econ_apres IN FRAME f_rpt_41_tit_acr_em_aberto */

ON VALUE-CHANGED OF v_ind_visualiz_tit_acr_vert IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then
        assign v_cod_proces_export_ini = ' '
               v_cod_proces_export_fim = 'ZZZZZZZZZZZZ'.
    if v_ind_visualiz_tit_acr_vert <> "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then
        assign v_log_classif_un = no
               v_log_tot_unid_negoc = no
               v_cod_plano_cta_ctbl_inic  = ' '
               v_cod_plano_cta_ctbl_final = "ZZZZZZZZ" /*l_zzzzzzzz*/ 
               v_cod_cta_ctbl_ini         = ' '
               v_cod_cta_ctbl_final       = "ZZZZZZZZZZZZZZZZZZZZ" /*l_zzzzzzzzzzzzzzzzzzzz*/ .
END. /* ON VALUE-CHANGED OF v_ind_visualiz_tit_acr_vert IN FRAME f_rpt_41_tit_acr_em_aberto */

ON VALUE-CHANGED OF v_log_visualiz_clien IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if  v_log_funcao_aging_acr = yes
    then do:
        if  input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_clien = yes
        then do:
            enable bt_time
                   with frame f_rpt_41_tit_acr_em_aberto.
        end /* if */.
        else do:
            if  input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_sint = no
            then do:
                disable bt_time
                        with frame f_rpt_41_tit_acr_em_aberto.
            end /* if */.
        end /* else */.
    end /* if */.
END. /* ON VALUE-CHANGED OF v_log_visualiz_clien IN FRAME f_rpt_41_tit_acr_em_aberto */

ON VALUE-CHANGED OF v_log_visualiz_sint IN FRAME f_rpt_41_tit_acr_em_aberto
DO:

    if  input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_sint = yes
    then do:
        enable bt_time
               with frame f_rpt_41_tit_acr_em_aberto.
        assign v_log_visualiz_sint:checked in frame f_rpt_41_tit_acr_em_aberto = yes.
    end /* if */.
    else do:
        if  v_log_funcao_aging_acr = no or
           (v_log_funcao_aging_acr = yes and
            input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_clien = no)
        then do:
            disable bt_time
                    with frame f_rpt_41_tit_acr_em_aberto.
            assign v_log_visualiz_sint:checked in frame f_rpt_41_tit_acr_em_aberto = no.
        end /* if */.
    end /* else */.
END. /* ON VALUE-CHANGED OF v_log_visualiz_sint IN FRAME f_rpt_41_tit_acr_em_aberto */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_188063 IN FRAME f_rpt_41_tit_acr_em_aberto
OR F5 OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_em_aberto DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/utb/utb077ka.r") = ? and search("prgint/utb/utb077ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb077ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb077ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb077ka.p /*prg_sea_finalid_econ*/.
    if  v_rec_finalid_econ <> ?
    then do:
        find finalid_econ where recid(finalid_econ) = v_rec_finalid_econ no-lock no-error.
        assign v_cod_finalid_econ:screen-value in frame f_rpt_41_tit_acr_em_aberto =
               string(finalid_econ.cod_finalid_econ).

        apply "entry" to v_cod_finalid_econ in frame f_rpt_41_tit_acr_em_aberto.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_188063 IN FRAME f_rpt_41_tit_acr_em_aberto */

ON  CHOOSE OF bt_zoo_188064 IN FRAME f_rpt_41_tit_acr_em_aberto
OR F5 OF v_cod_finalid_econ_apres IN FRAME f_rpt_41_tit_acr_em_aberto DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/utb/utb077ka.r") = ? and search("prgint/utb/utb077ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb077ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb077ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb077ka.p /*prg_sea_finalid_econ*/.
    if  v_rec_finalid_econ <> ?
    then do:
        find b_finalid_econ where recid(b_finalid_econ) = v_rec_finalid_econ no-lock no-error.
        assign v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_em_aberto =
               string(b_finalid_econ.cod_finalid_econ).

        apply "entry" to v_cod_finalid_econ_apres in frame f_rpt_41_tit_acr_em_aberto.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_188064 IN FRAME f_rpt_41_tit_acr_em_aberto */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON GO OF FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    /* **
    assign dwb_rpt_param.cod_dwb_output   = rs_cod_dwb_output:screen-value in frame @&(frame).
    @if(dwb_rpt_param.cod_dwb_output = @%(l_file))
        @run (pi_filename_validation (dwb_rpt_param.cod_dwb_file)).
        @if(return-value = @%(l_nok))
            @cx_message(1064).
            return no-apply.
        @end_if().
    @end_if().
    @else()
        @if(dwb_rpt_param.cod_dwb_output = @%(l_printer))
            @if(dwb_rpt_param.nom_dwb_printer = ""
            or   dwb_rpt_param.cod_dwb_print_layout = "")
                @cx_message(2052).
                return no-apply.
            @end_if().
        @end_if().
    @end_else().

    @cx_assign(@&(frame), v_cod_finalid_econ, v_cod_finalid_econ_apres, v_dat_calc_atraso,
                        v_dat_cotac_indic_econ, v_dat_tit_acr_aber, v_ind_visualiz_tit_acr_vert,
                        v_log_gera_sit_envio, v_log_mostra_docto_acr_antecip,v_log_mostra_docto_acr_cheq,
                        v_log_mostra_docto_acr_nf, v_log_mostra_docto_acr_normal, v_log_mostra_docto_acr_aviso_db,
                        v_log_tit_acr_avencer, v_log_tit_acr_vencid, v_log_tit_acr_estordo, v_log_visualiz_analit,
                        v_log_visualiz_sint, v_qtd_dias_avencer, v_qtd_dias_vencid, v_log_emit_movto_cobr).
    if v_log_control_terc_acr = yes then do:
        @cx_assign (f_fil_01_tit_acr_em_aberto_rpt, v_log_tip_espec_docto_terc,
                                                    v_log_tip_espec_docto_cheq_terc).
    end.
    ***/
END. /* ON GO OF FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON HELP OF FRAME f_fil_01_tit_acr_em_aberto_rpt ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr_em_aberto_rpt ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr_em_aberto_rpt ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr_em_aberto_rpt
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr_em_aberto_rpt */

ON GO OF FRAME f_rpt_41_tit_acr_em_aberto
DO:

    assign dwb_rpt_param.cod_dwb_output   = rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_em_aberto.
    if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
    then do:
        run pi_filename_validation (Input dwb_rpt_param.cod_dwb_file) /*pi_filename_validation*/.
        if  return-value = "NOK" /*l_nok*/ 
        then do:
            /* Nome do arquivo incorreto ! */
            run pi_messages (input "show",
                             input 1064,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1064*/.
            return no-apply.
        end /* if */.
    end /* if */.
    else do:
        if  dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ 
        then do:
            if  dwb_rpt_param.nom_dwb_printer = ""
            or   dwb_rpt_param.cod_dwb_print_layout = ""
            then do:
                /* Impressora destino e layout de impress∆o n∆o definidos ! */
                run pi_messages (input "show",
                                 input 2052,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2052*/.
                return no-apply.
            end /* if */.
        end /* if */.
    end /* else */.

    assign input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ
           input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ_apres
           input frame f_rpt_41_tit_acr_em_aberto v_dat_cotac_indic_econ
           input frame f_rpt_41_tit_acr_em_aberto v_dat_tit_acr_aber
           input frame f_rpt_41_tit_acr_em_aberto v_cod_convenio_ini
           input frame f_rpt_41_tit_acr_em_aberto v_cod_convenio_fim
           input frame f_rpt_41_tit_acr_em_aberto v_ind_visualiz_tit_acr_vert
           input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_analit
           input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_sint
           input frame f_rpt_41_tit_acr_em_aberto v_log_imprime_fatura_convenio
           input frame f_rpt_41_tit_acr_em_aberto v_log_imprime_cupom_convenio
           input frame f_rpt_41_tit_acr_em_aberto v_log_emit_movto_cobr.

    ASSIGN v_log_emit_movto_cobr:VISIBLE IN FRAME f_rpt_41_tit_acr_em_aberto = NO.

    if v_log_funcao_aging_acr = yes then
        assign input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_clien.

    /* @cx_assign(f_fil_01_tit_acr_em_aberto_rpt, v_dat_calc_atraso,
                                               v_log_mostra_docto_acr_antecip,
                                               v_log_mostra_docto_acr_cheq,
                                               v_log_mostra_docto_acr_nf, 
                                               v_log_mostra_docto_acr_normal, 
                                               v_log_mostra_docto_acr_aviso_db,
                                               v_log_tit_acr_avencer, 
                                               v_log_tit_acr_vencid, 
                                               v_log_tit_acr_estordo,
                                               v_qtd_dias_avencer, 
                                               v_qtd_dias_vencid).
    */
END. /* ON GO OF FRAME f_rpt_41_tit_acr_em_aberto */

ON ENDKEY OF FRAME f_rpt_41_tit_acr_em_aberto
DO:


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'CANCEL',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'CANCEL',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'CANCEL',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */

END. /* ON ENDKEY OF FRAME f_rpt_41_tit_acr_em_aberto */

ON HELP OF FRAME f_rpt_41_tit_acr_em_aberto ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_rpt_41_tit_acr_em_aberto */

ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_em_aberto ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_em_aberto */

ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_em_aberto ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_em_aberto */

ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_em_aberto
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_em_aberto */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_rpt_41_tit_acr_em_aberto.





END. /* ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help */

ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_release
        as character
        format "x(12)":U
        no-undo.
    def var v_nom_prog
        as character
        format "x(8)":U
        no-undo.
    def var v_nom_prog_ext
        as character
        format "x(8)":U
        label "Nome Externo"
        no-undo.


    /************************** Variable Definition End *************************/


        assign v_nom_prog     = substring(frame f_rpt_41_tit_acr_em_aberto:title, 1, max(1, length(frame f_rpt_41_tit_acr_em_aberto:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "rpt_tit_acr_em_aberto":U.




    assign v_nom_prog_ext = "prgfin/acr/acr303aa.py":U
           v_cod_release  = trim(" 1.00.00.173":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i rpt_tit_acr_em_aberto}


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
    run pi_version_extract ('rpt_tit_acr_em_aberto':U, 'prgfin/acr/acr303aa.py':U, '1.00.00.173':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

run pi_return_user (output v_cod_dwb_user) /*pi_return_user*/.

if  search("prgtec/btb/btb906za.r") = ? and search("prgtec/btb/btb906za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb906za.py".
    else do:
        message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb906za.py"
               view-as alert-box error buttons ok.
        stop.
    end.
end.
else
    run prgtec/btb/btb906za.py /*prg_fnc_verify_controls*/.
if (v_cod_dwb_user = "") then
   assign v_cod_dwb_user = v_cod_usuar_corren.


/* Begin_Include: i_verify_security */
if  search("prgtec/men/men901za.r") = ? and search("prgtec/men/men901za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/men/men901za.py".
    else do:
        message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/men/men901za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgtec/men/men901za.py (Input 'rpt_tit_acr_em_aberto') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_em_aberto')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_em_aberto')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'rpt_tit_acr_em_aberto' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'rpt_tit_acr_em_aberto'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_permissoes in v_prog_filtro_pdf (input 'rpt_tit_acr_em_aberto':U).
&endif
/* tech38629 - Fim da alteraá∆o */




/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "rpt_tit_acr_em_aberto":U
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


assign v_wgh_frame_epc = frame f_rpt_41_tit_acr_em_aberto:handle.



assign v_nom_table_epc = 'tit_acr':U
       v_rec_table_epc = recid(tit_acr).

&endif

/* End_Include: i_verify_program_epc */


/* redefiniá‰es do frame */

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_rpt_41_tit_acr_em_aberto:title = frame f_rpt_41_tit_acr_em_aberto:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.173":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_rpt_41_tit_acr_em_aberto = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f_rpt_41_tit_acr_em_aberto FRAME}


/* inicializa vari†veis */
find empresa no-lock
     where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.
find dwb_rpt_param
     where dwb_rpt_param.cod_dwb_program = "rel_tit_acr_em_aber":U
       and dwb_rpt_param.cod_dwb_user    = v_cod_dwb_user
       no-lock no-error.
if  avail dwb_rpt_param then do:
&if '{&emsbas_version}' > '1.00' &then
&if '{&emsbas_version}' >= '5.03' &then
    assign v_nom_dwb_print_file = dwb_rpt_param.nom_dwb_print_file.
&else
    assign v_nom_dwb_print_file = dwb_rpt_param.cod_livre_1.
&endif
&endif
    if  dwb_rpt_param.qtd_dwb_line <> 0 then
        assign v_qtd_line = dwb_rpt_param.qtd_dwb_line.
    else
        assign v_qtd_line = v_rpt_s_1_lines.
end.
assign v_cod_dwb_proced   = "rel_tit_acr_em_aber":U
       v_cod_dwb_program  = "rel_tit_acr_em_aber":U
       v_cod_release      = trim(" 1.00.00.173":U)
       v_ind_dwb_run_mode = "On-Line" /*l_online*/ 
       v_qtd_column       = v_rpt_s_1_columns
       v_qtd_bottom       = v_rpt_s_1_bottom.
if (avail empresa) then
    assign v_nom_enterprise   = empresa.nom_razao_social.
else
    assign v_nom_enterprise   = 'DATASUL'.


/* Begin_Include: ix_p00_rpt_tit_acr_em_aberto */
&if '{&emsfin_version}' >= '5.06' &then
    assign v_log_vers_50_6 = yes.
&endif

/* Begin_Include: i_verifica_transf_estab_operac_financ */
assign v_log_transf_estab_operac_financ = no.
&if defined(BF_FIN_TRANSF_ESTAB_OPER_FINANC) &then
   assign v_log_transf_estab_operac_financ = yes.
&else
   find histor_exec_especial no-lock
      where histor_exec_especial.cod_modul_dtsul = 'UFN'
      and   histor_exec_especial.cod_prog_dtsul  = 'spp_transf_estab_oper_financ' no-error.
   if avail histor_exec_especial then
      assign v_log_transf_estab_operac_financ = yes.

   /* Begin_Include: i_funcao_extract */
   if  v_cod_arq <> '' and v_cod_arq <> ?
   then do:

       output stream s-arq to value(v_cod_arq) append.

       put stream s-arq unformatted
           'spp_transf_estab_oper_financ'      at 1 
           v_log_transf_estab_operac_financ  at 43 skip.

       output stream s-arq close.

   end /* if */.
   /* End_Include: i_funcao_extract */

&endif
/* End_Include: i_funcao_extract */


/* Begin_Include: i_verifica_funcao_tip_calc_juros */
&if defined(bf_fin_tip_calc_juros) &then
    assign v_log_funcao_tip_calc_juros = yes.
&else
    find histor_exec_especial no-lock
        where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
          and histor_exec_especial.cod_prog_dtsul  = "spp_tip_calc_juros" /*l_spp_tip_cal_juros*/  no-error.
    if  avail histor_exec_especial then
        assign v_log_funcao_tip_calc_juros = yes.

    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            "spp_tip_calc_juros" /* l_spp_tip_cal_juros*/      at 1 
            v_log_funcao_tip_calc_juros  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */

&endif
/* End_Include: i_funcao_extract */


/* Begin_Include: i_vrf_funcao_ir_cooperativas */
assign v_log_impto_cop = no.
&if defined(BF_FIN_IRCOOPERATIVAS) &then
    assign v_log_impto_cop = yes.
&else
    find first histor_exec_especial no-lock
        where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
        and   histor_exec_especial.cod_prog_dtsul  = "spp_" /*l_spp*/  + "IRCOOPERATIVAS" /*l_ircooperativas*/  no-error.
    if  avail histor_exec_especial then
        assign v_log_impto_cop = yes.

    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            'spp_IRCOOPERATIVAS'      at 1 
            v_log_impto_cop  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */

&endif

/* End_Include: i_funcao_extract */


/* Begin_Include: i_fn_retorna_ultimo_dia_mes_ano */
FUNCTION fn_retorna_ultimo_dia_mes_ano RETURN DATE (INPUT p_mes AS INT,
                                                    INPUT p_ano AS INT):
    DEF VAR v_dat_retorno AS DATE NO-UNDO.

    CASE p_mes:
        WHEN 1 OR WHEN 3 OR WHEN 5  OR
        WHEN 7 OR WHEN 8 OR WHEN 10 OR WHEN 12 THEN
            ASSIGN v_dat_retorno = DATE(p_mes,31,p_ano).
        WHEN 4  OR WHEN 6  OR
        WHEN 9  OR WHEN 11 THEN
            ASSIGN v_dat_retorno = DATE(p_mes,30,p_ano).
        WHEN 2 THEN /* Verifica se o ano Ç bissexto */
            ASSIGN v_dat_retorno = IF p_ano MODULO 4 = 0 THEN DATE(p_mes,29,p_ano)
                                   ELSE DATE(p_mes,28,p_ano).
    END CASE.

    RETURN v_dat_retorno.
END.
/* End_Include: i_fn_retorna_ultimo_dia_mes_ano */



/* Begin_Include: i_testa_funcao_aging_acr */
&IF DEFINED(BF_FIN_AGING_ACR) &THEN
    assign v_log_funcao_aging_acr = yes.
&ELSE
    if  can-find (first histor_exec_especial no-lock
         where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
         and   histor_exec_especial.cod_prog_dtsul  = 'spp_aging_acr':U)
    then do:
        assign v_log_funcao_aging_acr = yes.
    end /* if */.

    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            'spp_aging_acr'      at 1 
            v_log_funcao_aging_acr  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */
    .
&ENDIF
/* End_Include: i_funcao_extract */
.

IF v_log_funcao_aging_acr = NO THEN
    ASSIGN v_log_visualiz_clien = no
           v_log_visualiz_clien:VISIBLE IN FRAME f_rpt_41_tit_acr_em_aberto = NO.

/* Funá∆o para Controle Terceiros */

/* Begin_Include: i_verifica_controle_terceiros_acr */
assign v_log_control_terc_acr = no.
find histor_exec_especial no-lock
     where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
     and   histor_exec_especial.cod_prog_dtsul  = 'SPP_CONTROLE_TERCEIROS_ACR':u
     no-error.
if avail histor_exec_especial then
   assign v_log_control_terc_acr = yes.

/* Begin_Include: i_funcao_extract */
if  v_cod_arq <> '' and v_cod_arq <> ?
then do:

    output stream s-arq to value(v_cod_arq) append.

    put stream s-arq unformatted
        'SPP_CONTROLE_TERCEIROS_ACR':U      at 1 
        v_log_control_terc_acr  at 43 skip.

    output stream s-arq close.

end /* if */.
/* End_Include: i_funcao_extract */
. 

/* End_Include: i_funcao_extract */

if v_log_control_terc_acr = no then
    assign v_log_tip_espec_docto_terc      = no
           v_log_tip_espec_docto_cheq_terc = no.

/* assign v_log_habilita_con_corporat = no.
&if defined(BF_FIN_REG_CORP_ACR) &then
    assign v_log_habilita_con_corporat = yes.
&else
    find  histor_exec_especial no-lock
        where histor_exec_especial.cod_modul_dtsul = 'UFN'
        and   histor_exec_especial.cod_prog_dtsul = 'Spp_registro_corporativo_acr' no-error.
    if  avail histor_exec_especial then
        assign v_log_habilita_con_corporat = yes.
&endif*/

find last param_geral_apb no-lock no-error.
if avail param_geral_apb then 
   assign v_log_habilita_con_corporat = param_geral_apb.log_reg_corporat .
else
   assign v_log_habilita_con_corporat = no.    

/* ==> MODULO VENDOR <== */
run pi_verifica_vendor /*pi_verifica_vendor*/.


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


assign v_log_funcao_juros_multa = &IF DEFINED(BF_FIN_CONSID_JUROS_MULTA) &THEN YES &ELSE GetDefinedFunction('SPP_CONSID_JUROS_MULTA':U) &ENDIF
       v_log_pessoa_fisic_cobr = &IF DEFINED (BF_FIN_ENDER_COB_PESSOA_FISIC) &THEN YES &ELSE GetDefinedFunction('SPP_ENDER_COB_PESSOA_FISIC':U) &ENDIF.

/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUNÄ«O *******************************
** Funá∆o para tratamento dos Entries dos c¢digos livres
** 
**  p_num_posicao     - N£mero do Entry que ser† atualizado
**  p_cod_campo       - Campo / Vari†vel que ser† atualizada
**  p_cod_separador   - Separador que ser† utilizado
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


/* Begin_Include: i_vrf_funcao_integr_mec_ems5 */
IF  can-find(first param_integr_ems no-lock
    where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/ ) THEN
    assign v_log_integr_mec = YES.
ELSE
    assign v_log_integr_mec = NO.


/* Begin_Include: i_funcao_extract */
if  v_cod_arq <> '' and v_cod_arq <> ?
then do:

    output stream s-arq to value(v_cod_arq) append.

    put stream s-arq unformatted
        'spp_integr_mec_ems5'      at 1 
        v_log_integr_mec  at 43 skip.

    output stream s-arq close.

end /* if */.
/* End_Include: i_funcao_extract */


/* End_Include: i_funcao_extract */


if v_log_integr_mec then
    assign v_log_funcao_proces_export = &IF DEFINED(BF_FIN_NUM_PROC_EXP_REL_CON) &THEN YES
                                        &ELSE GetDefinedFunction('SPP_NUM_PROC_EXP_REL_CON':U) &ENDIF.

assign v_log_funcao_melhoria_tit_aber = &IF DEFINED(BF_FIN_MELHORIAS_TIT_EM_ABERTO) &THEN YES
                                        &ELSE GetDefinedFunction('SPP_MELHORIAS_TIT_EM_ABERTO':U) &ENDIF.

assign v_log_localiz_arg            = GetDefinedFunction('SPP_LOCALIZ_ARGENTINA':U).

/* End_Include: i_funcao_extract */


if  v_cod_dwb_user begins 'es_'
then do:
    find dwb_rpt_param no-lock
         where dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
           and dwb_rpt_param.cod_dwb_user = v_cod_dwb_user /*cl_dwb_rpt_param of dwb_rpt_param*/ no-error.
    if (not avail dwb_rpt_param) then
        return "ParÉmetros para o relat¢rio n∆o encontrado." /*1993*/ + " (" + "1993" + ")" + chr(10) + "N∆o foi poss°vel encontrar os parÉmetros necess†rios para a impress∆o do relat¢rio para o programa e usu†rio corrente." /*1993*/.
    if index( dwb_rpt_param.cod_dwb_file ,'~\') <> 0 then
        assign file-info:file-name = replace(dwb_rpt_param.cod_dwb_file, '~\', '~/').
    else
        assign file-info:file-name = dwb_rpt_param.cod_dwb_file.

    assign file-info:file-name = substring(file-info:file-name, 1,
                                           r-index(file-info:file-name, '~/') - 1).
    if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
    then do:
       if file-info:file-type = ? then
          return "Diret¢rio Inexistente:" /*l_directory*/  + dwb_rpt_param.cod_dwb_file.
    end /* if */.

    find ped_exec no-lock
         where ped_exec.num_ped_exec = v_num_ped_exec_corren /*cl_le_ped_exec_global of ped_exec*/ no-error.
    if (ped_exec.cod_release_prog_dtsul <> trim(" 1.00.00.173":U)) then
        return "Vers‰es do programa diferente." /*1994*/ + " (" + "1994" + ")" + chr(10)
                                     + substitute("A vers∆o do programa (&3) que gerou o pedido de execuá∆o batch (&1) Ç diferente da vers∆o do programa que deveria executar o pedido batch (&2)." /*1994*/,ped_exec.cod_release_prog_dtsul,
                                                  trim(" 1.00.00.173":U),
                                                  "prgfin/acr/acr303aa.py":U).
    assign v_nom_prog_ext     = caps("acr303aa":U)
           v_dat_execution    = today
           v_hra_execution    = replace(string(time, "hh:mm:ss" /*l_hh:mm:ss*/ ), ":", "")
           v_cod_dwb_file     = dwb_rpt_param.cod_dwb_file
           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_ind_dwb_run_mode = "Batch" /*l_batch*/ .


    /* Begin_Include: ix_p02_rpt_tit_acr_em_aberto */
    run pi_ix_p02_rpt_tit_acr_em_aberto /*pi_ix_p02_rpt_tit_acr_em_aberto*/.
    /* End_Include: ix_p02_rpt_tit_acr_em_aberto */


    /* configura e define destino de impress∆o */
    if (dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ ) then
        assign v_qtd_line_ant = v_qtd_line.


/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
    IF CAN-FIND(FIRST PARAM_extens_ems
                WHERE PARAM_extens_ems.cod_entid_param_ems = "impressao":U
                  AND PARAM_extens_ems.cod_chave_param_ems = "impress_escala":U
                  AND PARAM_extens_ems.cod_param_ems       = "impress_escala":U
                  AND PARAM_extens_ems.log_param_ems       = YES) THEN DO:

       ASSIGN v_nom_dwb_print_file = dwb_rpt_param.cod_dwb_file
              v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/")
              v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file, R-INDEX(v_nom_dwb_print_file,"/") + 1).

       ASSIGN c-cod_dwb_user = ENTRY(2,v_cod_dwb_user,"_")
              i-num_ped_exec = INTEGER(ENTRY(3,v_cod_dwb_user,"_")) NO-ERROR.

       IF v_nom_dwb_print_file <> "" THEN DO:
          IF SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3, 1) = "." THEN
             ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file,1,INDEX(v_nom_dwb_print_file,"."))
                + STRING(TODAY,"99999999")
                + STRING(TIME,"99999")
                + STRING(i-num_ped_exec)
                + SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3).
          ELSE
             ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file, 1, R-INDEX(v_nom_dwb_print_file,"."))
                   + STRING(TODAY,"99999999")
                   + STRING(TIME,"99999")
                   + STRING(i-num_ped_exec).

          FIND FIRST ped_exec NO-LOCK
             WHERE ped_exec.num_ped_exec = i-num_ped_exec NO-ERROR.
          IF AVAIL ped_exec THEN DO:
             FIND FIRST servid_exec NO-LOCK
                WHERE servid_exec.cod_servid_exec = ped_exec.cod_servid_exec NO-ERROR.
             IF AVAIL servid_exec THEN
                ASSIGN c-servid_exec_nom_dir_spool = servid_exec.nom_dir_spool.
          END.

          FIND FIRST usuar_mestre NO-LOCK
             WHERE usuar_mestre.cod_usuario = c-cod_dwb_user NO-ERROR.
          IF AVAIL usuar_mestre THEN
             ASSIGN c-usuar_mestre_nom_subdir_spool = usuar_mestre.nom_subdir_spool.

          IF CAN-FIND(FIRST param_extens_ems
               WHERE param_extens_ems.cod_entid_param_ems = "impressao":U
                 AND param_extens_ems.cod_chave_param_ems = "impress_escala":U
                 AND param_extens_ems.cod_param_ems       = "impress_escala":U
                 AND param_extens_ems.log_param_ems       = YES) AND
             CAN-FIND(FIRST impressora
                      WHERE impressora.nom_impressora = dwb_rpt_param.nom_dwb_printer
                        AND impressora.log_impres_escal = YES) THEN
             ASSIGN v_nom_dwb_print_file = c-servid_exec_nom_dir_spool + "/" + v_nom_dwb_print_file.
          ELSE
             ASSIGN v_nom_dwb_print_file = c-servid_exec_nom_dir_spool + "/" + c-usuar_mestre_nom_subdir_spool + "/" + v_nom_dwb_print_file.

       END.

       ASSIGN v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").

       DO TRANSACTION:
          FIND b-dwb_rpt_param EXCLUSIVE-LOCK
             WHERE ROWID(b-dwb_rpt_param) = ROWID(dwb_rpt_param) NO-ERROR.
          IF AVAIL b-dwb_rpt_param THEN
             ASSIGN b-dwb_rpt_param.cod_dwb_file = v_nom_dwb_print_file
                    b-dwb_rpt_param.nom_dwb_print_file = v_nom_dwb_print_file.
          RELEASE b-dwb_rpt_param.
       END.
    END.

&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim    */

    run pi_output_reports /*pi_output_reports*/.

    if  dwb_rpt_param.log_dwb_print_parameters = yes
    then do:
        if (page-number (s_1) > 0) then
            page stream s_1.

        /* ix_p29_rpt_tit_acr_em_aberto */

        hide stream s_1 frame f_rpt_s_1_header_period.
        view stream s_1 frame f_rpt_s_1_header_unique.
        hide stream s_1 frame f_rpt_s_1_footer_last_page.
        hide stream s_1 frame f_rpt_s_1_footer_normal.
        view stream s_1 frame f_rpt_s_1_footer_param_page.
        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "Usu†rio: " at 1
            v_cod_usuar_corren at 10 format "x(12)" skip (1).


        /* Begin_Include: ix_p30_rpt_tit_acr_em_aberto */
        run pi_ix_p30_rpt_tit_acr_em_aberto.
        /* End_Include: ix_p30_rpt_tit_acr_em_aberto */


    end /* if */.


/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
    ASSIGN v_page_number = PAGE-NUMBER(s_1) NO-ERROR.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

    output stream s_1 close.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_call_convert_object in v_prog_filtro_pdf (input yes,
                                                 input dwb_rpt_param.cod_dwb_output,
                                                 input dwb_rpt_param.nom_dwb_print_file,
                                                 input v_cod_dwb_file,
                                                 input v_nom_report_title).
&endif
/* tech38629 - Fim da alteraá∆o */


&if '{&emsbas_version}':U >= '5.05':U &then
    if ((dwb_rpt_param.cod_dwb_output = 'Impressora':U or dwb_rpt_param.cod_dwb_output = 'Impresora':U or dwb_rpt_param.cod_dwb_output = 'printer':U) and getCodTipoRelat() = 'PDF':U) then do:
        if dwb_rpt_param.nom_dwb_print_file = '' then
            run pi_print_pdf_file in v_prog_filtro_pdf (input yes).
    end.
&endif

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
   IF CAN-FIND(FIRST param_extens_ems
               WHERE PARAM_extens_ems.cod_entid_param_ems = "histor_impres":U
                 AND param_extens_ems.cod_chave_param_ems = "histor_impres":U
                 AND param_extens_ems.cod_param_ems       = "log_histor_impres":U
                 AND param_extens_ems.log_param_ems       = YES) AND
      CAN-FIND(FIRST usuar_mestre
               WHERE usuar_mestre.cod_usuario = c-cod_dwb_user
                 AND usuar_mestre.log_solic_impres = YES) AND
     (dwb_rpt_param.cod_dwb_output = "Impressora":U OR
      dwb_rpt_param.cod_dwb_output = "Impresora":U OR
      dwb_rpt_param.cod_dwb_output = "printer":U) THEN DO:
      ASSIGN v_cod_usuar_abert = TRIM(dwb_rpt_param.cod_livre_1).
   END.

   RUN prgtec/btb/btb001.p (INPUT c-cod_dwb_user,
                            INPUT v_cod_usuar_abert,
                            INPUT v_page_number,
                            INPUT v_dat_execution,
                            INPUT dwb_rpt_param.cod_dwb_program,
                            INPUT v_nom_report_title,
                            INPUT dwb_rpt_param.nom_dwb_printer,
                            INPUT dwb_rpt_param.cod_dwb_file).
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

    return "OK" /*l_ok*/ .

end /* if */.

pause 0 before-hide.
view frame f_rpt_41_tit_acr_em_aberto.

/* Begin_Include: i_exec_program_epc */
&if '{&emsbas_version}' > '1.00' &then
if  v_nom_prog_upc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_upc) (input 'INITIALIZE',
                               input 'viewer',
                               input this-procedure,
                               input v_wgh_frame_epc,
                               input v_nom_table_epc,
                               input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.

if  v_nom_prog_appc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_appc) (input 'INITIALIZE',
                                input 'viewer',
                                input this-procedure,
                                input v_wgh_frame_epc,
                                input v_nom_table_epc,
                                input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.

&if '{&emsbas_version}' > '5.00' &then
if  v_nom_prog_dpc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_dpc) (input 'INITIALIZE',
                                input 'viewer',
                                input this-procedure,
                                input v_wgh_frame_epc,
                                input v_nom_table_epc,
                                input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.
&endif
&endif
/* End_Include: i_exec_program_epc */


super_block:
repeat
    on stop undo super_block, retry super_block:

    if (retry) then
       output stream s_1 close.

    param_block:
    do transaction:

        find dwb_rpt_param exclusive-lock
             where dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
               and dwb_rpt_param.cod_dwb_user = v_cod_dwb_user /*cl_dwb_rpt_param of dwb_rpt_param*/ no-error.
        if  not available dwb_rpt_param
        then do:
            create dwb_rpt_param.
            assign dwb_rpt_param.cod_dwb_program         = v_cod_dwb_program
                   dwb_rpt_param.cod_dwb_user            = v_cod_dwb_user
                   dwb_rpt_param.cod_dwb_parameters      = v_cod_dwb_parameters
                   dwb_rpt_param.cod_dwb_output          = "Terminal" /*l_terminal*/ 
                   dwb_rpt_param.ind_dwb_run_mode        = "On-Line" /*l_online*/ 
                   dwb_rpt_param.cod_dwb_file            = ""
                   dwb_rpt_param.nom_dwb_printer         = ""
                   dwb_rpt_param.cod_dwb_print_layout    = ""
                   v_cod_dwb_file_temp                   = "".
        end /* if */.
        assign v_qtd_line = (if dwb_rpt_param.qtd_dwb_line <> 0 then dwb_rpt_param.qtd_dwb_line else v_rpt_s_1_lines).
    end /* do param_block */.

    init:
    do with frame f_rpt_41_tit_acr_em_aberto:
        assign rs_cod_dwb_output:screen-value   = dwb_rpt_param.cod_dwb_output
               rs_ind_run_mode:screen-value     = dwb_rpt_param.ind_dwb_run_mode.

        if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
        then do:
            assign v_cod_dwb_file_temp = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/").
            if (index(v_cod_dwb_file_temp, "~/") <> 0) then
                assign v_cod_dwb_file_temp = substring(v_cod_dwb_file_temp, r-index(v_cod_dwb_file_temp, "~/") + 1).
            else
                assign v_cod_dwb_file_temp = dwb_rpt_param.cod_dwb_file.
            assign ed_1x40:screen-value = v_cod_dwb_file_temp.
        end /* if */.

        if  dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ 
        then do:
            if (not can-find(imprsor_usuar
                            where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                              and imprsor_usuar.cod_usuario = dwb_rpt_param.cod_dwb_user
&if "{&emsbas_version}" >= "5.01" &then
                            use-index imprsrsr_id
&endif
                             /*cl_get_printer of imprsor_usuar*/)
            or   not can-find(layout_impres
                             where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                               and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/)) then
                run pi_set_print_layout_default /*pi_set_print_layout_default*/.
            assign ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                        + ":"
                                        + dwb_rpt_param.cod_dwb_print_layout.
        end /* if */.
        assign v_log_print_par = dwb_rpt_param.log_dwb_print_parameters.
        display v_log_print_par
                with frame f_rpt_41_tit_acr_em_aberto.
    end /* do init */.

    display v_qtd_column
            v_qtd_line
            with frame f_rpt_41_tit_acr_em_aberto.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'DISPLAY',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'DISPLAY',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'DISPLAY',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */


    enable rs_cod_dwb_output
           v_log_print_par
           bt_get_file
           bt_set_printer
           bt_close
           bt_print
           bt_can
           bt_hel2
           bt_classificacao
           bt_time
           bt_ran2
           bt_fil2
           with frame f_rpt_41_tit_acr_em_aberto.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'ENABLE',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'ENABLE',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'ENABLE',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */


/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_posiciona_dwb_rpt_param in v_prog_filtro_pdf (input rowid(dwb_rpt_param)).
    run pi_load_params in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */



    apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_em_aberto.


    if  yes = yes
    then do:
       enable rs_ind_run_mode
              with frame f_rpt_41_tit_acr_em_aberto.
       apply "value-changed" to rs_ind_run_mode in frame f_rpt_41_tit_acr_em_aberto.
    end /* if */.



    /* Begin_Include: ix_p10_rpt_tit_acr_em_aberto */
    assign v_log_tot_grp_clien = no.


    /* Begin_Include: ix_p02_rpt_tit_acr_em_aberto */
    run pi_ix_p02_rpt_tit_acr_em_aberto /*pi_ix_p02_rpt_tit_acr_em_aberto*/.
    /* End_Include: ix_p02_rpt_tit_acr_em_aberto */


    if v_log_funcao_proces_export or v_log_vers_50_6 then
       v_ind_visualiz_tit_acr_vert:add-last("Por Processo Exportaá∆o" /*l_por_processo_exportacao*/ ,"Por Processo Exportaá∆o" /*l_por_processo_exportacao*/ ).
    else do:
       if v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then
          assign v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ .
    end.      


    display v_cod_finalid_econ
            v_cod_finalid_econ_apres
            v_dat_cotac_indic_econ
            v_dat_tit_acr_aber
            v_cod_convenio_ini
            v_cod_convenio_fim
            v_ind_visualiz_tit_acr_vert
            v_log_visualiz_analit
            v_log_visualiz_sint
            v_log_imprime_fatura_convenio
            v_log_imprime_cupom_convenio
            with frame f_rpt_41_tit_acr_em_aberto.

    enable v_cod_finalid_econ
           v_cod_finalid_econ_apres
           v_dat_cotac_indic_econ
           v_dat_tit_acr_aber
           v_cod_convenio_ini
           v_cod_convenio_fim
           v_ind_visualiz_tit_acr_vert
           v_log_visualiz_analit
           v_log_visualiz_sint
           v_log_imprime_fatura_convenio
           v_log_imprime_cupom_convenio
           bt_planilha_excel
           with frame f_rpt_41_tit_acr_em_aberto.

    v_log_emit_movto_cobr:VISIBLE IN FRAME f_rpt_41_tit_acr_em_aberto = NO.
    bt_planilha_excel:VISIBLE IN FRAME f_rpt_41_tit_acr_em_aberto = NO.

    IF v_log_funcao_aging_acr = YES THEN DO:
        DISPLAY v_log_visualiz_clien with frame f_rpt_41_tit_acr_em_aberto.
        ENABLE v_log_visualiz_clien  with frame f_rpt_41_tit_acr_em_aberto.
    END.

    apply "leave" to v_cod_finalid_econ in frame f_rpt_41_tit_acr_em_aberto.

    /* Foi comentada a parte do programa onde h† tratamento para geraá∆o da Posiá∆o 
    do Cliente para envio via EDI.
    J† foi aberta FO para prÇ-comiss∆o para que se avalie se esta implementaá∆o deve 
    ou n∆o ser complementada. 
    ------------------------------------------------------------------------------
    Somente habilitar† a vari†vel v_log_gera_sit_envio, que tem a finalidade de
    enviar a posiá∆o dos clientes, caso a empresa possua o m¢dulo EDF, e se o
    usu†rio tiver permiss∆o para acessar o m¢dulo.
    ------------------------------------------------------------------------------ 
    @run (pi_verifica_utiliz_modulo(v_cod_empres_usuar, @%(l_EDF), v_log_return)).
    @if(v_log_return = yes)
        @run (pi_verificar_segur_modul_dtsul(@%(l_EDF), v_cod_usuar_corren, v_log_return)).
        @if(v_log_return = yes)
            @enable(@&(frame), v_log_gera_sit_envio).
        @end_if().
    @end_if(). */
    apply "value-changed" to v_log_visualiz_sint in frame f_rpt_41_tit_acr_em_aberto.
    /* End_Include: ix_p02_rpt_tit_acr_em_aberto */


    block1:
    repeat on error undo block1, retry block1:

        main_block:
        repeat on error undo super_block, retry super_block
                        on endkey undo super_block, leave super_block
                        on stop undo super_block, retry super_block
                        with frame f_rpt_41_tit_acr_em_aberto:

            if (retry) then
                output stream s_1 close.
            assign v_log_print = no.
            if  valid-handle(v_wgh_focus) then
                wait-for go of frame f_rpt_41_tit_acr_em_aberto focus v_wgh_focus.
            else
                wait-for go of frame f_rpt_41_tit_acr_em_aberto.

            param_block:
            do transaction:

                /* Begin_Include: ix_p15_rpt_tit_acr_em_aberto */
                run pi_ix_p15_rpt_tit_acr_em_aberto.
                /* End_Include: ix_p15_rpt_tit_acr_em_aberto */

                assign dwb_rpt_param.log_dwb_print_parameters = input frame f_rpt_41_tit_acr_em_aberto v_log_print_par
                       dwb_rpt_param.ind_dwb_run_mode         = input frame f_rpt_41_tit_acr_em_aberto rs_ind_run_mode
                       input frame f_rpt_41_tit_acr_em_aberto v_qtd_line.

                /* ix_p20_rpt_tit_acr_em_aberto */
            end /* do param_block */.

            if  v_log_print = yes
            then do:
/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
               IF CAN-FIND(FIRST param_extens_ems
                           WHERE PARAM_extens_ems.cod_entid_param_ems = "histor_impres":U
                             AND param_extens_ems.cod_chave_param_ems = "histor_impres":U
                             AND param_extens_ems.cod_param_ems       = "log_histor_impres":U
                             AND param_extens_ems.log_param_ems       = YES) AND
                  CAN-FIND(FIRST usuar_mestre
                           WHERE usuar_mestre.cod_usuario = v_cod_usuar_corren
                             AND usuar_mestre.log_solic_impres = YES) AND
                 (dwb_rpt_param.cod_dwb_output = "Impressora":U OR
                  dwb_rpt_param.cod_dwb_output = "Impresora":U OR
                  dwb_rpt_param.cod_dwb_output = "printer":U) THEN DO:

                  RUN btb/btb004aa.w (OUTPUT v_cod_usuar_abert).
                  RUN pi-grava-usuar-solic.

               END.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
               ASSIGN v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").

               IF CAN-FIND(FIRST PARAM_extens_ems
                           WHERE PARAM_extens_ems.cod_entid_param_ems = "impressao":U
                             AND PARAM_extens_ems.cod_chave_param_ems = "impress_escala":U
                             AND PARAM_extens_ems.cod_param_ems       = "impress_escala":U
                             AND PARAM_extens_ems.log_param_ems       = YES) THEN DO:
                  IF v_nom_dwb_print_file <> "" THEN DO:
                     IF SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3, 1) = "." THEN DO:
                        ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file,1,INDEX(v_nom_dwb_print_file,"."))
                           + STRING(TODAY,"99999999")
                           + STRING(TIME,"99999")
                           + SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3).
                     END.
                     IF INDEX(v_nom_dwb_print_file, "/") = 0 THEN DO:
                        FIND FIRST usuar_mestre NO-LOCK
                           WHERE usuar_mestre.cod_usuario = v_cod_dwb_user NO-ERROR.
                        IF AVAIL usuar_mestre THEN
                           ASSIGN v_nom_dwb_print_file = usuar_mestre.nom_dir_spool + "/" + usuar_mestre.nom_subdir_spool + "/" + v_nom_dwb_print_file
                                  v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").
                     END.
                  END.
               END.
&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim    */

                if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
                then do:
                   if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
                   then do:
                       assign v_cod_dwb_file = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/")
                              v_nom_integer = v_cod_dwb_file.
                       if  index(v_cod_dwb_file, ":") <> 0
                       then do:
                           /* Nome de arquivo com problemas. */
                           run pi_messages (input "show",
                                            input 1979,
                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                           next main_block.
                       end /* if */.

                       file_1:
                       do
                          while index(v_cod_dwb_file,"~/") <> 0:
                          assign v_cod_dwb_file = substring(v_cod_dwb_file,(index(v_cod_dwb_file,"~/" ) + 1)).
                       end /* do file_1 */.

                       /* valname: */
                       case num-entries(v_cod_dwb_file,"."):
                           when 1 then
                               if  length(v_cod_dwb_file) > 8
                               then do:
                                  /* Nome de arquivo com problemas. */
                                  run pi_messages (input "show",
                                                   input 1979,
                                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                                  next main_block.
                               end /* if */.
                           when 2 then
                               if  length(entry(1, v_cod_dwb_file, ".")) > 8
                               or length(entry(2, v_cod_dwb_file, ".")) > 3
                               then do:
                                  /* Nome de arquivo com problemas. */
                                  run pi_messages (input "show",
                                                   input 1979,
                                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                                  next main_block.
                               end /* if */.
                           otherwise other:
                                     do:
                               /* Nome de arquivo com problemas. */
                               run pi_messages (input "show",
                                                input 1979,
                                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                               next main_block.
                           end /* do other */.
                       end /* case valname */.
                   end /* if */.
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
                    run pi_filename_batch in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */


                   assign v_cod_dwb_file = v_nom_integer.
                   if  search("prgtec/btb/btb911za.r") = ? and search("prgtec/btb/btb911za.p") = ? then do:
                       if  v_cod_dwb_user begins 'es_' then
                           return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb911za.p".
                       else do:
                           message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb911za.p"
                                  view-as alert-box error buttons ok.
                           return.
                       end.
                   end.
                   else
                       run prgtec/btb/btb911za.p (Input v_cod_dwb_program,
                                              Input v_cod_release,
                                              Input 41,
                                              Input recid(dwb_rpt_param),
                                              output v_num_ped_exec) /*prg_fnc_criac_ped_exec*/.
                   if (v_num_ped_exec <> 0) then
                       leave main_block.
                   else
                       next main_block.
                end /* if */.
                else do:
                    assign v_log_method = session:set-wait-state('general')
                           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name.
                    /* out_def: */
&if '{&emsbas_version}':U >= '5.05':U &then
/*                    case dwb_rpt_param.cod_dwb_output:*/
&else
                    case dwb_rpt_param.cod_dwb_output:
&endif
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Terminal" /*l_terminal*/ then out_term:*/
                        if dwb_rpt_param.cod_dwb_output = 'Terminal' then
&else
                        when "Terminal" /*l_terminal*/ then out_term:
&endif
                         do:
                            assign v_cod_dwb_file   = session:temp-directory + substring ("prgfin/acr/acr303aa.py", 12, 6) + '.tmp'
                                   v_rpt_s_1_bottom = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).
                            output stream s_1 to value(v_cod_dwb_file) paged page-size value(v_qtd_line) convert target 'iso8859-1'.
                        end /* do out_term */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Impressora" /*l_printer*/ then out_print:*/
                        if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() <> 'PDF':U and getCodTipoRelat() <> 'RTF':U then
&else
                        when "Impressora" /*l_printer*/ then out_print:
&endif
                         do:
                            find imprsor_usuar no-lock
                                 where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                                   and imprsor_usuar.cod_usuario = dwb_rpt_param.cod_dwb_user
&if "{&emsbas_version}" >= "5.01" &then
                                 use-index imprsrsr_id
&endif
                                  /*cl_get_printer of imprsor_usuar*/ no-error.
                            find impressora no-lock
                                 where impressora.nom_impressora = imprsor_usuar.nom_impressora
                                  no-error.
                            find tip_imprsor no-lock
                                 where tip_imprsor.cod_tip_imprsor = impressora.cod_tip_imprsor
                                  no-error.
                            find layout_impres no-lock
                                 where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                                   and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                            assign v_rpt_s_1_bottom = layout_impres.num_lin_pag - (v_rpt_s_1_lines - v_qtd_bottom).
&if '{&emsbas_version}' > '1.00' &then
                            if  v_nom_dwb_print_file <> "" then
                                if  layout_impres.num_lin_pag = 0 then
                                    output stream s_1 to value(lc(v_nom_dwb_print_file))
                                           page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                                else
                                    output stream s_1 to value(lc(v_nom_dwb_print_file))
                                           paged page-size value(layout_impres.num_lin_pag) convert target  tip_imprsor.cod_pag_carac_conver.
                            else
&endif
                                if  layout_impres.num_lin_pag = 0 then
                                    output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                                           page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                                else
                                    output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                                           paged page-size value(layout_impres.num_lin_pag) convert target  tip_imprsor.cod_pag_carac_conver.

                            setting:
                            for
                                each configur_layout_impres no-lock
                                where configur_layout_impres.num_id_layout_impres = layout_impres.num_id_layout_impres

                                by configur_layout_impres.num_ord_funcao_imprsor:
                                find configur_tip_imprsor no-lock
                                     where configur_tip_imprsor.cod_tip_imprsor = layout_impres.cod_tip_imprsor
                                       and configur_tip_imprsor.cod_funcao_imprsor = configur_layout_impres.cod_funcao_imprsor
                                       and configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
&if "{&emsbas_version}" >= "5.01" &then
                                     use-index cnfgrtpm_id
&endif
                                      /*cl_get_print_command of configur_tip_imprsor*/ no-error.
                                bloco_1:
                                do
                                    v_num_count = 1 to extent(configur_tip_imprsor.num_carac_configur):
                                    /* configur_tip_imprsor: */
                                    case configur_tip_imprsor.num_carac_configur[v_num_count]:
                                         when 0 then put  stream s_1 control null.
                                         when ? then leave.
                                         otherwise 
                                             /* Convers∆o interna do OUTPUT TARGET */
                                             put stream s_1 control codepage-convert ( chr(configur_tip_imprsor.num_carac_configur[v_num_count]),
                                                                                       session:cpinternal,
                                                                                       tip_imprsor.cod_pag_carac_conver).
                                    end /* case configur_tip_imprsor */.
                                end /* do bloco_1 */.   
                            end /* for setting */.
                        end /* do out_print */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Arquivo" /*l_file*/ then out_file:*/
                        if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() = 'PDF':U then do:
                            run pi_config_output_print_pdf in v_prog_filtro_pdf (input v_qtd_line, input-output v_cod_dwb_file, input dwb_rpt_param.cod_dwb_user, input no).
                        end.
                        if dwb_rpt_param.cod_dwb_output = 'Arquivo' then
&else
                        when "Arquivo" /*l_file*/ then out_file:
&endif
                         do:
                            assign v_cod_dwb_file   = dwb_rpt_param.cod_dwb_file
                                   v_rpt_s_1_bottom = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_rename_file in v_prog_filtro_pdf (input-output v_cod_dwb_file).
&endif
/* tech38629 - Fim da alteraá∆o */



                            output stream s_1 to value(v_cod_dwb_file)
                                   paged page-size value(v_qtd_line) convert target 'iso8859-1'.
                        end /* do out_file */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                    end /* case out_def */.*/
&else
                    end /* case out_def */.
&endif
                    assign v_nom_prog_ext  = caps(substring("prgfin/acr/acr303aa.py",12,8))
                           v_cod_release   = trim(" 1.00.00.173":U)
                           v_dat_execution = today
                           v_hra_execution = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").
                    run pi_rpt_tit_acr_em_aberto /*pi_rpt_tit_acr_em_aberto*/.
                end /* else */.
                if  dwb_rpt_param.log_dwb_print_parameters = yes
                then do:
                    if (page-number (s_1) > 0) then
                        page stream s_1.
                    /* ix_p29_rpt_tit_acr_em_aberto */    
                    hide stream s_1 frame f_rpt_s_1_header_period.
                    view stream s_1 frame f_rpt_s_1_header_unique.
                    hide stream s_1 frame f_rpt_s_1_footer_last_page.
                    hide stream s_1 frame f_rpt_s_1_footer_normal.
                    view stream s_1 frame f_rpt_s_1_footer_param_page.
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        skip (1)
                        "Usu†rio: " at 1
                        v_cod_usuar_corren at 10 format "x(12)" skip (1).

                    /* Begin_Include: ix_p30_rpt_tit_acr_em_aberto */
                    run pi_ix_p30_rpt_tit_acr_em_aberto.
                    /* End_Include: ix_p30_rpt_tit_acr_em_aberto */

                end /* if */.

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
                ASSIGN v_page_number = PAGE-NUMBER(s_1) NO-ERROR.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

                output stream s_1 close.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_call_convert_object in v_prog_filtro_pdf (input no,
                                                 input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_em_aberto,
                                                 input v_nom_dwb_print_file,
                                                 input v_cod_dwb_file,
                                                 input v_nom_report_title).
&endif
/* tech38629 - Fim da alteraá∆o */


&if '{&emsbas_version}':U >= '5.05':U &then
    if ((dwb_rpt_param.cod_dwb_output = 'Impressora':U or dwb_rpt_param.cod_dwb_output = 'Impresora':U or dwb_rpt_param.cod_dwb_output = 'printer':U) and getCodTipoRelat() = 'PDF':U) then do:
        if v_nom_dwb_print_file = '' then
            run pi_print_pdf_file in v_prog_filtro_pdf (input no).
    end.
&endif
                assign v_log_method = session:set-wait-state("").
                if (dwb_rpt_param.cod_dwb_output = "Terminal" /*l_terminal*/ ) then do:
                /* tech38629 - Alteraá∆o efetuada via filtro */
                &if '{&emsbas_version}':U >= '5.05':U &then
                    if  getCodTipoRelat() = 'PDF':U and OPSYS = 'WIN32':U
                    then do:
                        run pi_open_pdf_file in v_prog_filtro_pdf.
                    end.
                    else if getCodTipoRelat() = 'Texto' then do:
                &endif
                /* tech38629 - Fim da alteraá∆o */
                    run pi_show_report_2 (Input v_cod_dwb_file) /*pi_show_report_2*/.
                /* tech38629 - Alteraá∆o efetuada via filtro */
                &if '{&emsbas_version}':U >= '5.05':U &then
                    end.
                &endif
                /* tech38629 - Fim da alteraá∆o */
                end.


/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
                RUN prgtec/btb/btb001.p (INPUT v_cod_usuar_corren,
                                         INPUT v_cod_usuar_abert,
                                         INPUT v_page_number,
                                         INPUT v_dat_execution,
                                         INPUT v_cod_dwb_program,
                                         INPUT v_nom_report_title,
                                         INPUT v_nom_dwb_printer,
                                         INPUT v_nom_dwb_print_file).
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

                leave main_block.

            end /* if */.
            else do:
                leave super_block.
            end /* else */.

        end /* repeat main_block */.

        /* ix_p32_rpt_tit_acr_em_aberto */

        if  v_num_ped_exec <> 0
        then do:
            /* Criado pedido &1 para execuá∆o batch. */
            run pi_messages (input "show",
                             input 3556,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_num_ped_exec)) /*msg_3556*/.
            assign v_num_ped_exec = 0.
        end /* if */.

        /* ix_p35_rpt_tit_acr_em_aberto */

    end /* repeat block1 */.
end /* repeat super_block */.

/* ix_p40_rpt_tit_acr_em_aberto */

hide frame f_rpt_41_tit_acr_em_aberto.

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


if  this-procedure:persistent then
    delete procedure this-procedure.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
delete procedure v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */





/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/* Alteracao via filtro - Controle de impressao - inicio    */
&IF "{&product_version}" >= "11.5.7" &THEN
PROCEDURE pi-grava-usuar-solic:
   DO TRANSACTION:
      FIND b-dwb_rpt_param EXCLUSIVE-LOCK
         WHERE ROWID(b-dwb_rpt_param) = ROWID(dwb_rpt_param) NO-ERROR.
      IF AVAIL b-dwb_rpt_param THEN
         ASSIGN b-dwb_rpt_param.cod_livre_1 = TRIM(v_cod_usuar_abert).
      RELEASE b-dwb_rpt_param.
   END.
END PROCEDURE.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */


/*****************************************************************************
** Procedure Interna.....: pi_return_user
** Descricao.............: pi_return_user
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: vladimir
** Alterado em...........: 12/02/1996 10:16:42
*****************************************************************************/
PROCEDURE pi_return_user:

    /************************ Parameter Definition Begin ************************/

    def output param p_nom_user
        as character
        format "x(32)"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_nom_user = v_cod_usuar_corren.

    if  v_cod_usuar_corren begins 'es_'
    then do:
       assign v_cod_usuar_corren = entry(2,v_cod_usuar_corren,"_").
    end /* if */.

END PROCEDURE. /* pi_return_user */
/*****************************************************************************
** Procedure Interna.....: pi_filename_validation
** Descricao.............: pi_filename_validation
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: tech35592
** Alterado em...........: 14/02/2006 07:39:05
*****************************************************************************/
PROCEDURE pi_filename_validation:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_filename
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_1                          as character       no-undo. /*local*/
    def var v_cod_2                          as character       no-undo. /*local*/
    def var v_num_1                          as integer         no-undo. /*local*/
    def var v_num_2                          as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  p_cod_filename = "" or p_cod_filename = "."
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    assign v_cod_1 = replace(p_cod_filename, "~\", "/").

    1_block:
    repeat v_num_1 = 1 to length(v_cod_1):
        if  index('abcdefghijklmnopqrstuvwxyz0123456789-_:/.', substring(v_cod_1, v_num_1, 1)) = 0
        then do:
            return "NOK" /*l_nok*/ .
        end /* if */.
    end /* repeat 1_block */.

    if  num-entries(v_cod_1, ":") > 2
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  num-entries(v_cod_1, ":") = 2 and length(entry(1,v_cod_1,":")) > 1
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  num-entries(v_cod_1, ".") > 2
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  num-entries(v_cod_1, ".") = 2 and length(entry(2,v_cod_1,".")) > 3
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  index(entry(num-entries(v_cod_1, "/"),v_cod_1, "/"),".") = 0
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.
    else do:
        if  entry(1,entry(num-entries(v_cod_1,"/"),v_cod_1,"/"),".") = ""
        or  entry(2,entry(num-entries(v_cod_1,"/"),v_cod_1,"/"),".") = ""
        then do:
           return "NOK" /*l_nok*/ .
        end /* if */.
    end /* else */.

    assign v_num_1 = 1.
    2_block:
    repeat v_num_2 = 1 to length(v_cod_1):
        if  index(":" + "/" + ".", substring(v_cod_1, v_num_2, 1)) > 0
        then do:
            assign v_cod_2 = substring(v_cod_1, v_num_1, v_num_2 - v_num_1)
                   v_num_1 = v_num_2 + 1.
        end /* if */.
    end /* repeat 2_block */.
    assign v_cod_2 = substring(v_cod_1, v_num_1).

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_filename_validation */
/*****************************************************************************
** Procedure Interna.....: pi_set_print_layout_default
** Descricao.............: pi_set_print_layout_default
** Criado por............: Gilsinei
** Criado em.............: 04/03/1996 09:22:54
** Alterado por..........: bre19127
** Alterado em...........: 16/09/2002 08:39:04
*****************************************************************************/
PROCEDURE pi_set_print_layout_default:

    dflt:
    do with frame f_rpt_41_tit_acr_em_aberto:

        find layout_impres_padr no-lock
             where layout_impres_padr.cod_usuario = v_cod_dwb_user
               and layout_impres_padr.cod_proced = v_cod_dwb_proced
    &if "{&emsbas_version}" >= "5.01" &then
             use-index lytmprsp_id
    &endif
              /*cl_default_procedure_user of layout_impres_padr*/ no-error.
        if  not avail layout_impres_padr
        then do:
            find layout_impres_padr no-lock
                 where layout_impres_padr.cod_usuario = "*"
                   and layout_impres_padr.cod_proced = v_cod_dwb_proced
    &if "{&emsbas_version}" >= "5.01" &then
                 use-index lytmprsp_id
    &endif
                  /*cl_default_procedure of layout_impres_padr*/ no-error.
            if  avail layout_impres_padr
            then do:
                find imprsor_usuar no-lock
                     where imprsor_usuar.nom_impressora = layout_impres_padr.nom_impressora
                       and imprsor_usuar.cod_usuario = v_cod_dwb_user
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index imprsrsr_id
    &endif
                      /*cl_layout_current_user of imprsor_usuar*/ no-error.
            end /* if */.
            if  not avail imprsor_usuar
            then do:
                find layout_impres_padr no-lock
                     where layout_impres_padr.cod_usuario = v_cod_dwb_user
                       and layout_impres_padr.cod_proced = "*"
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index lytmprsp_id
    &endif
                      /*cl_default_user of layout_impres_padr*/ no-error.
            end /* if */.
        end /* if */.
        do transaction:
            find dwb_rpt_param
                where dwb_rpt_param.cod_dwb_user = v_cod_usuar_corren
                and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                exclusive-lock no-error.
            if  avail layout_impres_padr
            then do:
                assign dwb_rpt_param.nom_dwb_printer      = layout_impres_padr.nom_impressora
                       dwb_rpt_param.cod_dwb_print_layout = layout_impres_padr.cod_layout_impres
                       ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                            + ":"
                                            + dwb_rpt_param.cod_dwb_print_layout.
            end /* if */.
            else do:
                assign dwb_rpt_param.nom_dwb_printer       = ""
                       dwb_rpt_param.cod_dwb_print_layout  = ""
                       ed_1x40:screen-value = "".
            end /* else */.
        end.
    end /* do dflt */.
END PROCEDURE. /* pi_set_print_layout_default */
/*****************************************************************************
** Procedure Interna.....: pi_show_report_2
** Descricao.............: pi_show_report_2
** Criado por............: Gilsinei
** Criado em.............: 07/03/1996 14:42:50
** Alterado por..........: bre19127
** Alterado em...........: 21/05/2002 10:16:34
*****************************************************************************/
PROCEDURE pi_show_report_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_dwb_file
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_key_value
        as character
        format "x(8)":U
        no-undo.


    /************************** Variable Definition End *************************/

    get-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value.
    if  v_cod_key_value = ""
    or   v_cod_key_value = ?
    then do:
        assign v_cod_key_value = 'notepad.exe'.
        put-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value no-error.
    end /* if */.

    run winexec (input v_cod_key_value + chr(32) + p_cod_dwb_file, input 1).

    END PROCEDURE.

    PROCEDURE WinExec EXTERNAL 'kernel32.dll':
      DEF INPUT  PARAM prg_name                          AS CHARACTER.
      DEF INPUT  PARAM prg_style                         AS SHORT.




END PROCEDURE. /* pi_show_report_2 */
/*****************************************************************************
** Procedure Interna.....: pi_output_reports
** Descricao.............: pi_output_reports
** Criado por............: glauco
** Criado em.............: 21/03/1997 09:26:29
** Alterado por..........: tech38629
** Alterado em...........: 06/10/2006 22:40:15
*****************************************************************************/
PROCEDURE pi_output_reports:

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_posiciona_dwb_rpt_param in v_prog_filtro_pdf (input rowid(dwb_rpt_param)).
    run pi_load_params in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */




    assign v_log_method       = session:set-wait-state('general')
           v_nom_report_title = fill(" ",40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_rpt_s_1_bottom   = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).

    /* block: */
&if '{&emsbas_version}':U >= '5.05':U &then
/*    case dwb_rpt_param.cod_dwb_output:*/
&else
    case dwb_rpt_param.cod_dwb_output:
&endif
&if '{&emsbas_version}':U >= '5.05':U &then
/*            when "Arquivo" /*l_file*/ then*/
            if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() = 'PDF':U then do:
                run pi_config_output_print_pdf in v_prog_filtro_pdf (input v_qtd_line, input-output v_cod_dwb_file, input v_cod_usuar_corren, input yes).
            end.
            if dwb_rpt_param.cod_dwb_output = 'Arquivo' then
&else
            when "Arquivo" /*l_file*/ then
&endif
            block1:
            do:

               /* tech38629 - Relatorio PDF e RTF                 */
               /* Renomear arquivo quando extensao for pdf ou rtf */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_rename_file in v_prog_filtro_pdf (input-output v_cod_dwb_file).
&endif
/* tech38629 - Fim da alteraá∆o */



               output stream s_1 to value(v_cod_dwb_file)
               paged page-size value(v_qtd_line) convert target 'iso8859-1'.
            end /* do block1 */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*            when "Impressora" /*l_printer*/ then*/
            if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() <> 'PDF':U and getCodTipoRelat() <> 'RTF':U then
&else
            when "Impressora" /*l_printer*/ then
&endif
               block2:
               do:
                  find imprsor_usuar use-index imprsrsr_id no-lock
                      where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                      and   imprsor_usuar.cod_usuario    = v_cod_usuar_corren no-error.
                  find impressora no-lock
                       where impressora.nom_impressora = imprsor_usuar.nom_impressora
                        no-error.
                  find tip_imprsor no-lock
                       where tip_imprsor.cod_tip_imprsor = impressora.cod_tip_imprsor
                        no-error.
                  find layout_impres no-lock
                       where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                         and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                  find b_ped_exec_style
                      where b_ped_exec_style.num_ped_exec = v_num_ped_exec_corren no-lock no-error.
                  find servid_exec_imprsor no-lock
                       where servid_exec_imprsor.nom_impressora = dwb_rpt_param.nom_dwb_printer
                         and servid_exec_imprsor.cod_servid_exec = b_ped_exec_style.cod_servid_exec no-error.

                  find b_servid_exec_style no-lock
                       where b_servid_exec_style.cod_servid_exec = b_ped_exec_style.cod_servid_exec
                       no-error.

                  if  avail layout_impres
                  then do:
                     assign v_rpt_s_1_bottom = layout_impres.num_lin_pag - (v_rpt_s_1_lines - v_qtd_bottom).
                  end /* if */.

                  if  available b_servid_exec_style
                  and b_servid_exec_style.ind_tip_fila_exec = 'UNIX'
                  then do:
                      &if '{&emsbas_version}' > '1.00' &then           
                      &if '{&emsbas_version}' >= '5.03' &then           
                          if dwb_rpt_param.nom_dwb_print_file <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                      &else
                          if dwb_rpt_param.cod_livre_1 <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                      &endif
                      &endif
                  end /* if */.
                  else do:
                      &if '{&emsbas_version}' > '1.00' &then           
                      &if '{&emsbas_version}' >= '5.03' &then           
                          if dwb_rpt_param.nom_dwb_print_file <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                      &else
                          if dwb_rpt_param.cod_livre_1 <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                      &endif
                      &endif
                  end /* else */.

                  setting:
                  for
                      each configur_layout_impres no-lock
                      where configur_layout_impres.num_id_layout_impres = layout_impres.num_id_layout_impres

                      by configur_layout_impres.num_ord_funcao_imprsor:

                      find configur_tip_imprsor no-lock
                           where configur_tip_imprsor.cod_tip_imprsor = layout_impres.cod_tip_imprsor
                             and configur_tip_imprsor.cod_funcao_imprsor = configur_layout_impres.cod_funcao_imprsor
                             and configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
    &if "{&emsbas_version}" >= "5.01" &then
                           use-index cnfgrtpm_id
    &endif
                            /*cl_get_print_command of configur_tip_imprsor*/ no-error.

                      bloco_1:
                      do
                          v_num_count = 1 to extent(configur_tip_imprsor.num_carac_configur):
                          /* configur_tip_imprsor: */
                          case configur_tip_imprsor.num_carac_configur[v_num_count]:
                              when 0 then put  stream s_1 control null.
                              when ? then leave.
                              otherwise 
                                  /* Convers∆o interna do OUTPUT TARGET */
                                  put stream s_1 control codepage-convert ( chr(configur_tip_imprsor.num_carac_configur[v_num_count]),
                                                                            session:cpinternal,
                                                                            tip_imprsor.cod_pag_carac_conver).
                          end /* case configur_tip_imprsor */.
                      end /* do bloco_1 */.
                 end /* for setting */.
            end /* do block2 */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*    end /* case block */.*/
&else
    end /* case block */.
&endif

    run pi_rpt_tit_acr_em_aberto /*pi_rpt_tit_acr_em_aberto*/.
END PROCEDURE. /* pi_output_reports */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_tit_acr_em_aberto
** Descricao.............: pi_verifica_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 02/01/1997 11:57:21
** Alterado por..........: fut41675
** Alterado em...........: 13/05/2011 16:52:38
*****************************************************************************/
PROCEDURE pi_verifica_tit_acr_em_aberto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cdn_estil_dwb
        as Integer
        format ">>9"
        no-undo.
    def Input param p_dat_tit_acr_aber
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_ult
        for movto_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_liquidac_tit_acr
        as date
        format "99/99/9999":U
        label "Liquidaá∆o"
        column-label "Liquidaá∆o"
        no-undo.
    def var v_log_vers_50_6
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_num_seq_ult_movto              as integer         no-undo. /*local*/
    def var v_num_seq_ult_movto_final        as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* **  P_CDN_ESTIL_DWB: IDENTIFICA O PROGRAMA CHAMADOR DESTA PROCEDURE
    *
    *           20 - CONSULTA TITULOS EM ABERTO
    *           41 - RELAT‡RIO TITULOS EM ABERTO
    *
    ***/
    &if '{&emsfin_version}' >= '5.06' &then
        assign v_log_vers_50_6 = yes.
    &endif

    run pi_retornar_indic_econ_finalid (Input v_cod_finalid_econ_apres,
                                        Input v_dat_cotac_indic_econ,
                                        output v_cod_indic_econ_apres) /*pi_retornar_indic_econ_finalid*/.

/*     &if '{&ems_dbtype}' <> 'progress' &then                                                           */
/*         assign v_num_seq_ult_movto = 0.                                                               */
/*         for each estabelecimento fields(cod_estab) no-lock:                                           */
/*             find last movto_tit_acr no-lock                                                           */
/*                 where movto_tit_acr.cod_estab = estabelecimento.cod_estab                             */
/*                 use-index mvtttcr_token no-error.                                                     */
/*             if  avail movto_tit_acr and movto_tit_acr.num_id_movto_tit_acr > v_num_seq_ult_movto then */
/*                 assign v_num_seq_ult_movto = movto_tit_acr.num_id_movto_tit_acr.                      */
/*         end.                                                                                          */
/*     &else                                                                                             */
/*         assign v_num_seq_ult_movto = current-value(seq_movto_tit_acr).                                */
/*     &endif                                                                                            */

    des_estab_block:
    do v_num_cont_aux = 1 to num-entries(v_des_estab_select):
        estab_block:
        for each estabelecimento fields(cod_estab cod_empresa) no-lock
            where estabelecimento.cod_estab  = entry(v_num_cont_aux, v_des_estab_select):

            if  not can-find(first tit_acr where tit_acr.cod_estab = estabelecimento.cod_estab) then
                next estab_block.

            /* ** QUANDO INFORMADO UMA FAIXA DE CLIENTE, USA INDICE DIFERENTE (Barth) ***/

            &if '{&emsfin_version}' >= '5.02' &then
            if  length(string(v_cdn_cliente_ini)) = length(string(v_cdn_cliente_fim)) then do:
                clien_block:
                for each clien_financ no-lock
                    where clien_financ.cod_empresa  = estabelecimento.cod_empresa
                    and   clien_financ.cdn_cliente >= v_cdn_cliente_ini
                    and   clien_financ.cdn_cliente <= v_cdn_cliente_fim:
                    if  not can-find(first tit_acr 
                        where tit_acr.cod_estab   = estabelecimento.cod_estab
                        and   tit_acr.cdn_cliente = clien_financ.cdn_cliente) then 
                        next clien_block.

                    dat_block:
                    do v_dat_liquidac_tit_acr = (p_dat_tit_acr_aber + 1) to 12/31/9999:
                        find first tit_acr no-lock
                            where tit_acr.cod_estab             = estabelecimento.cod_estab
                            and   tit_acr.cdn_cliente           = clien_financ.cdn_cliente
                            and   tit_acr.dat_liquidac_tit_acr >= v_dat_liquidac_tit_acr no-error.
                        if  avail tit_acr
                            then assign v_dat_liquidac_tit_acr = tit_acr.dat_liquidac_tit_acr.
                            else leave dat_block.

                        tit_block:
                        for each tit_acr use-index titacr_clien_datas no-lock
                            where tit_acr.cod_estab            = estabelecimento.cod_estab
                            and   tit_acr.cdn_cliente          = clien_financ.cdn_cliente
                            and   tit_acr.dat_liquidac_tit_acr = v_dat_liquidac_tit_acr
                            and   tit_acr.dat_transacao       <= p_dat_tit_acr_aber
                            and   tit_acr.cdn_repres          >= v_cdn_repres_ini
                            and   tit_acr.cdn_repres          <= v_cdn_repres_fim
                            and   tit_acr.dat_vencto_tit_acr  >= v_dat_vencto_tit_acr_ini
                            and   tit_acr.dat_vencto_tit_acr  <= v_dat_vencto_tit_acr_fim
                            and   tit_acr.cdn_clien_matriz    >= v_cdn_clien_matriz_ini
                            and   tit_acr.cdn_clien_matriz    <= v_cdn_clien_matriz_fim
                            and   tit_acr.cod_cond_cobr       >= v_cod_cond_cobr_ini
                            and   tit_acr.cod_cond_cobr       <= v_cod_cond_cobr_fim
                            and   tit_acr.cod_indic_econ      >= v_cod_indic_econ_ini
                            and   tit_acr.cod_indic_econ      <= v_cod_indic_econ_fim:

                            IF v_log_imprime_fatura_convenio = NO AND tit_acr.cod_espec_docto = "CF" THEN NEXT.
                            IF v_log_imprime_cupom_convenio  = NO AND tit_acr.cod_espec_docto = "CV" THEN NEXT.

                            /* Begin_Include: i_verifica_processo_exportacao */
                            &if defined(BF_FIN_NUM_PROC_EXP_REL_CON) &then
                                if v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then do:
                                    if tit_acr.cod_proces_export < v_cod_proces_export_ini
                                    or tit_acr.cod_proces_export > v_cod_proces_export_fim then
                                        next tit_block.
                                end.       
                            &else
                                if (v_log_funcao_proces_export or v_log_vers_50_6) and v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then do:
                                    if num-entries (tit_acr.cod_livre_1,chr(24)) > 3 then do:
                                       if string(entry(4,tit_acr.cod_livre_1,CHR(24))) < v_cod_proces_export_ini
                                       or string(entry(4,tit_acr.cod_livre_1,CHR(24))) > v_cod_proces_export_fim then
                                          next tit_block.
                                    end.
                                    else do:
                                       if v_cod_proces_export_ini <> "" /*l_null*/  then do:
                                          if num-entries (tit_acr.cod_livre_1,chr(24)) < 4 then
                                             next tit_block.
                                       end.   
                                    end.               
                                end.       
                            &endif
                            /* End_Include: i_verifica_processo_exportacao */

                            if  not can-find(first tt_espec_docto
                                where tt_espec_docto.tta_cod_espec_docto = tit_acr.cod_espec_docto) then
                                next tit_block.
                            &if defined(BF_FIN_CONTROL_CHEQUES) &then    
                            if tit_acr.ind_tip_espec_docto = "Cheques Recebidos" /*l_cheques_recebidos*/  then do:
                                find first cheq_acr no-lock
                                    where cheq_acr.cod_estab      = tit_acr.cod_estab
                                      and cheq_acr.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.
                                if avail cheq_acr then do:
                                    find first movto_devol_cheq_acr no-lock
                                        where movto_devol_cheq_acr.num_id_cheq_acr = cheq_acr.num_id_cheq_acr
                                          and movto_devol_cheq_acr.dat_devol_cheq_acr <= p_dat_tit_acr_aber no-error.
                                    if avail movto_devol_cheq_acr then do:
    				    if v_log_mostra_acr_cheq_recbdo = yes and v_log_mostra_acr_cheq_devolv = no then
    					next tit_block.
    				end.		
    				else do:
    				    if v_log_mostra_acr_cheq_recbdo = no and v_log_mostra_acr_cheq_devolv = yes then
    				    next tit_block.
    				end.
                                end.      
                            end.
                            &endif    
                            run pi_verifica_tit_acr_em_aberto_cria_tt (Input p_cdn_estil_dwb,
                                                                       Input p_dat_tit_acr_aber) /*pi_verifica_tit_acr_em_aberto_cria_tt*/.
                        end.
                    end.
                end.
            end.
            else
            &endif
            do:
                espec_block:
                for each tt_espec_docto no-lock:
                    if  not can-find(first tit_acr
                        where tit_acr.cod_estab = estabelecimento.cod_estab
                        and   tit_acr.cod_espec_docto = tt_espec_docto.tta_cod_espec_docto) then 
                        next espec_block.
                    dat_block:
                    do v_dat_liquidac_tit_acr = (p_dat_tit_acr_aber + 1) to 12/31/9999:
                        find first tit_acr no-lock
                            where tit_acr.cod_estab             = estabelecimento.cod_estab
                            and   tit_acr.dat_liquidac_tit_acr >= v_dat_liquidac_tit_acr no-error.
                        if  avail tit_acr
                            then assign v_dat_liquidac_tit_acr = tit_acr.dat_liquidac_tit_acr.
                            else leave dat_block.    
                        tit_block:
                        for each tit_acr use-index titacr_liquidac no-lock
                            where tit_acr.cod_estab            = estabelecimento.cod_estab
                            and   tit_acr.dat_liquidac_tit_acr = v_dat_liquidac_tit_acr
                            and   tit_acr.cod_espec_docto      = tt_espec_docto.tta_cod_espec_docto
                            and   tit_acr.dat_transacao       <= p_dat_tit_acr_aber
                            and   tit_acr.cdn_cliente         >= v_cdn_cliente_ini
                            and   tit_acr.cdn_cliente         <= v_cdn_cliente_fim
                            and   tit_acr.cdn_repres          >= v_cdn_repres_ini
                            and   tit_acr.cdn_repres          <= v_cdn_repres_fim
                            and   tit_acr.dat_vencto_tit_acr  >= v_dat_vencto_tit_acr_ini
                            and   tit_acr.dat_vencto_tit_acr  <= v_dat_vencto_tit_acr_fim
                            and   tit_acr.cdn_clien_matriz    >= v_cdn_clien_matriz_ini
                            and   tit_acr.cdn_clien_matriz    <= v_cdn_clien_matriz_fim
                            and   tit_acr.cod_cond_cobr       >= v_cod_cond_cobr_ini
                            and   tit_acr.cod_cond_cobr       <= v_cod_cond_cobr_fim
                            and   tit_acr.cod_indic_econ      >= v_cod_indic_econ_ini
                            and   tit_acr.cod_indic_econ      <= v_cod_indic_econ_fim:

                            IF v_log_imprime_fatura_convenio = NO AND tit_acr.cod_espec_docto = "CF" THEN NEXT.
                            IF v_log_imprime_cupom_convenio  = NO AND tit_acr.cod_espec_docto = "CV" THEN NEXT.

                            &if defined(BF_FIN_CONTROL_CHEQUES) &then    
                            if tit_acr.ind_tip_espec_docto = "Cheques Recebidos" /*l_cheques_recebidos*/  then do:
                                find first cheq_acr no-lock
                                    where cheq_acr.cod_estab      = tit_acr.cod_estab
                                      and cheq_acr.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.
                                if avail cheq_acr then do:
                                    find first movto_devol_cheq_acr no-lock
                                        where movto_devol_cheq_acr.num_id_cheq_acr = cheq_acr.num_id_cheq_acr
                                          and movto_devol_cheq_acr.dat_devol_cheq_acr <= p_dat_tit_acr_aber no-error.
                                    if avail movto_devol_cheq_acr then do:
    				    if v_log_mostra_acr_cheq_recbdo = yes and v_log_mostra_acr_cheq_devolv = no then
    					next tit_block.
    				end.		
    				else do:
    				    if v_log_mostra_acr_cheq_recbdo = no and v_log_mostra_acr_cheq_devolv = yes then
    				    next tit_block.
    				end.
                                end.      
                            end.
                            &endif


                            /* Begin_Include: i_verifica_processo_exportacao */
                            &if defined(BF_FIN_NUM_PROC_EXP_REL_CON) &then
                                if v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then do:
                                    if tit_acr.cod_proces_export < v_cod_proces_export_ini
                                    or tit_acr.cod_proces_export > v_cod_proces_export_fim then
                                        next tit_block.
                                end.       
                            &else
                                if (v_log_funcao_proces_export or v_log_vers_50_6) and v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then do:
                                    if num-entries (tit_acr.cod_livre_1,chr(24)) > 3 then do:
                                       if string(entry(4,tit_acr.cod_livre_1,CHR(24))) < v_cod_proces_export_ini
                                       or string(entry(4,tit_acr.cod_livre_1,CHR(24))) > v_cod_proces_export_fim then
                                          next tit_block.
                                    end.
                                    else do:
                                       if v_cod_proces_export_ini <> "" /*l_null*/  then do:
                                          if num-entries (tit_acr.cod_livre_1,chr(24)) < 4 then
                                             next tit_block.
                                       end.   
                                    end.               
                                end.       
                            &endif
                            /* End_Include: i_verifica_processo_exportacao */

                            run pi_verifica_tit_acr_em_aberto_cria_tt (Input p_cdn_estil_dwb,
                                                                       Input p_dat_tit_acr_aber) /*pi_verifica_tit_acr_em_aberto_cria_tt*/.
                        end.
                    end.
                end.
            end.
        end.
    end.

    /* ** TRATAMENTO ESPECIAL PARA QUE OS TITULOS LIQUIDADOS DURANTE A EMISSAO DO RELATORIO
         NAO FIQUEM DE FORA DO RELATORIO, DEVIDO AO "DO:" DATAS DE LIQUIDAÄ«O (Barth) ***/


/*     &if '{&ems_dbtype}' <> 'progress' &then                                                                 */
/*         assign v_num_seq_ult_movto_final = 0.                                                               */
/*         for each estabelecimento fields(cod_estab) no-lock:                                                 */
/*             find last movto_tit_acr no-lock                                                                 */
/*                 where movto_tit_acr.cod_estab = estabelecimento.cod_estab                                   */
/*                 use-index mvtttcr_token no-error.                                                           */
/*             if  avail movto_tit_acr and movto_tit_acr.num_id_movto_tit_acr > v_num_seq_ult_movto_final then */
/*                 assign v_num_seq_ult_movto_final = movto_tit_acr.num_id_movto_tit_acr.                      */
/*         end.                                                                                                */
/*     &else                                                                                                   */
/*         assign v_num_seq_ult_movto_final = current-value(seq_movto_tit_acr).                                */
/*     &endif                                                                                                  */

    if  v_num_seq_ult_movto_final > v_num_seq_ult_movto then do:
        estab_block:
        for each estabelecimento fields(cod_estab cod_empresa) no-lock
            where estabelecimento.cod_empresa  = v_cod_empres_usuar
            and   lookup(estabelecimento.cod_estab, v_des_estab_select) > 0,
            each  b_movto_tit_acr_ult no-lock
            where b_movto_tit_acr_ult.cod_estab            = estabelecimento.cod_estab
            and   b_movto_tit_acr_ult.num_id_movto_tit_acr > v_num_seq_ult_movto
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Alteraá∆o Data Emiss∆o" /*l_alteracao_data_emissao*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Alteraá∆o Data Vencimento" /*l_alteracao_data_vencimento*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Correá∆o de Valor" /*l_correcao_de_valor*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Correá∆o Valor na Liquidac" /*l_correcao_valor_na_liquidac*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Estorno Correá∆o Valor" /*l_estorno_correcao_valor*/ 
            and   b_movto_tit_acr_ult.ind_trans_acr <> "Estorno Correá∆o Val Liquidac" /*l_estorno_correcao_val_liquidac*/ ,
            tit_acr no-lock
            where tit_acr.cod_estab      = b_movto_tit_acr_ult.cod_estab
            and   tit_acr.num_id_tit_acr = b_movto_tit_acr_ult.num_id_tit_acr,
            first tt_espec_docto
            where tt_espec_docto.tta_cod_espec_docto = tit_acr.cod_espec_docto:

            for each tt_titulos_em_aberto_acr
                where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr:
                delete tt_titulos_em_aberto_acr.
            end.

            run pi_verifica_tit_acr_em_aberto_cria_tt (Input p_cdn_estil_dwb,
                                                       Input p_dat_tit_acr_aber) /*pi_verifica_tit_acr_em_aberto_cria_tt*/.
        end.
    end.

    if  p_cdn_estil_dwb = 41 then run pi_atualiza_prazos_tit_acr_em_aberto /*pi_atualiza_prazos_tit_acr_em_aberto*/.
    if  p_cdn_estil_dwb = 10 then run pi_atualizar_tot_tit_acr_em_aberto /*pi_atualizar_tot_tit_acr_em_aberto*/.

END PROCEDURE. /* pi_verifica_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_tit_acr_em_aberto_cria_tt
** Descricao.............: pi_verifica_tit_acr_em_aberto_cria_tt
** Criado por............: Barth
** Criado em.............: 22/06/1999 08:29:49
** Alterado por..........: log352284
** Alterado em...........: 08/05/2013 14:50:51
*****************************************************************************/
PROCEDURE pi_verifica_tit_acr_em_aberto_cria_tt:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cdn_estil_dwb
        as Integer
        format ">>9"
        no-undo.
    def Input param p_dat_tit_acr_aber
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer btt_titulos_em_aberto_acr
        for tt_titulos_em_aberto_acr.
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_aux
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_dest
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_pai
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_acr_dest
        for tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_cart_bcia
        as character
        format "x(3)":U
        label "Carteira"
        column-label "Carteira"
        no-undo.
    def var v_cod_portador
        as character
        format "x(5)":U
        label "Portador"
        column-label "Portador"
        no-undo.
    def var v_log_vers_50_6
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
    def var v_num_atraso_dias_acr
        as integer
        format "->>>>>>9":U
        label "Dias"
        column-label "Dias"
        no-undo.
    def var v_val_origin_transf_estab
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        initial 0
        no-undo.
    def var v_cod_pessoa                     as character       no-undo. /*local*/
    def var v_dat_aux                        as date            no-undo. /*local*/
    def var v_dat_aux_2                      as date            no-undo. /*local*/
    def var v_dat_cotac_aux                  as date            no-undo. /*local*/
    def var v_hra_aux                        as character       no-undo. /*local*/
    def var v_log_operac_financ              as logical         no-undo. /*local*/
    def var v_val_cotac_aux                  as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    &if '{&emsfin_version}' >= '5.06' &then
        assign v_log_vers_50_6 = yes.
    &endif

    if  tit_acr.dat_liquidac_tit_acr <= p_dat_tit_acr_aber
    or  tit_acr.dat_transacao        >  p_dat_tit_acr_aber
    or  tit_acr.cdn_cliente          <  v_cdn_cliente_ini
    or  tit_acr.cdn_cliente          >  v_cdn_cliente_fim
    or  tit_acr.cdn_repres           <  v_cdn_repres_ini
    or  tit_acr.cdn_repres           >  v_cdn_repres_fim
    or  tit_acr.dat_vencto_tit_acr   <  v_dat_vencto_tit_acr_ini
    or  tit_acr.dat_vencto_tit_acr   >  v_dat_vencto_tit_acr_fim
    or  tit_acr.cdn_clien_matriz     <  v_cdn_clien_matriz_ini
    or  tit_acr.cdn_clien_matriz     >  v_cdn_clien_matriz_fim
    or  tit_acr.cod_cond_cobr        <  v_cod_cond_cobr_ini
    or  tit_acr.cod_cond_cobr        >  v_cod_cond_cobr_fim
    or  tit_acr.cod_indic_econ       <  v_cod_indic_econ_ini
    or  tit_acr.cod_indic_econ       >  v_cod_indic_econ_fim then
        return 'NOK'.

    if v_log_funcao_melhoria_tit_aber then do:
        if  tit_acr.dat_emis_docto       <  v_dat_emis_docto_ini
        or  tit_acr.dat_emis_docto       >  v_dat_emis_docto_fim then
            return 'NOK'.
    end.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'VALIDA TITULO',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'yes' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'VALIDA TITULO',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'yes' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'VALIDA TITULO',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'yes' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */


    if  (v_log_tit_acr_nao_indcao_perda   = no and tit_acr.dat_indcao_perda_dedut >  p_dat_tit_acr_aber)
    or  (v_log_tit_acr_indcao_perda_dedut = no and tit_acr.dat_indcao_perda_dedut <=   p_dat_tit_acr_aber) then
        return 'NOK'.

    if  tit_acr.log_tit_acr_estordo = yes then do:
        find first movto_tit_acr use-index mvtttcr_id
            where movto_tit_acr.cod_estab      = tit_acr.cod_estab
            and   movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
            and  (movto_tit_acr.ind_trans_acr = "Implantaá∆o" /*l_implantacao*/ 
            or    movto_tit_acr.ind_trans_acr = "Implantaá∆o a CrÇdito" /*l_implantacao_a_credito*/ 
            or    movto_tit_acr.ind_trans_acr = "Implantaá∆o a DÇbito" /*l_implantacao_a_debito*/ 
            or    movto_tit_acr.ind_trans_acr = "Renegociaá∆o" /*l_renegociacao*/ 
            or    movto_tit_acr.ind_trans_acr = "Transf Estabelecimento" /*l_transf_estabelecimento*/ )
            no-lock no-error.
        if  avail movto_tit_acr
        and movto_tit_acr.log_ctbz_aprop_ctbl = no
        and v_log_tit_acr_estordo             = no then
            return 'NOK'.
    end.

    assign v_val_origin_transf_estab = 0.
    if  can-find(first movto_tit_acr
        where movto_tit_acr.cod_estab     = tit_acr.cod_estab
        and  movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
        and  movto_tit_acr.ind_trans_acr  = "Transf Estabelecimento" /*l_transf_estabelecimento*/ ) then do:
        if  v_log_transf_estab_operac_financ then do:
            find first movto_tit_acr no-lock
                where movto_tit_acr.cod_estab      = tit_acr.cod_estab
                  and movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
                  and movto_tit_acr.ind_trans_acr  = "Desconto Banc†rio" /*l_desconto_bancario*/  no-error.
            if not avail movto_tit_acr then
               return 'NOK'.
            else
               assign v_val_origin_transf_estab = movto_tit_acr.val_movto_tit_acr.   
        end.
        else
            return 'NOK'.
    end.    

    assign v_log_operac_financ = no.
    if  not v_log_transf_estab_operac_financ then
        assign v_log_sdo_tit_acr = tit_acr.log_sdo_tit_acr.
    else do:
        assign v_log_sdo_tit_acr = tit_acr.log_sdo_tit_acr.    
        find first b_movto_tit_acr_pai no-lock
            where b_movto_tit_acr_pai.cod_estab        = tit_acr.cod_estab
             and  b_movto_tit_acr_pai.num_id_tit_acr    = tit_acr.num_id_tit_acr
             and  b_movto_tit_acr_pai.ind_trans_acr     = "Liquidaá∆o Transf Estab" /*l_liquidacao_transf_estab*/ 
             and  b_movto_tit_acr_pai.log_movto_estordo = no no-error.
        if  avail b_movto_tit_acr_pai then do:
            find first b_movto_tit_acr_dest no-lock
                 where b_movto_tit_acr_dest.cod_estab_tit_acr_pai    = b_movto_tit_acr_pai.cod_estab 
                   and b_movto_tit_acr_dest.num_id_movto_tit_acr_pai = b_movto_tit_acr_pai.num_id_movto_tit_acr
                   and b_movto_tit_acr_dest.ind_trans_acr_abrev      = "TRES" /*l_tres*/  no-error.
            if  avail b_movto_tit_acr_dest then do:
                find first b_movto_tit_acr_aux no-lock
                    where b_movto_tit_acr_aux.cod_estab      = b_movto_tit_acr_dest.cod_estab
                      and b_movto_tit_acr_aux.num_id_tit_acr = b_movto_tit_acr_dest.num_id_tit_acr
                      and b_movto_tit_acr_aux.ind_trans_acr  = "Desconto Banc†rio" /*l_desconto_bancario*/  no-error.
                if avail b_movto_tit_acr_aux then do:
                   assign v_val_origin_transf_estab = tit_acr.val_transf_estab.
                   find b_tit_acr_dest no-lock
                      where b_tit_acr_dest.cod_estab      = b_movto_tit_acr_dest.cod_estab
                        and b_tit_acr_dest.num_id_tit_acr = b_movto_tit_acr_dest.num_id_tit_acr no-error.
                   assign v_log_sdo_tit_acr = b_tit_acr_dest.log_sdo_tit_acr.
                   if p_dat_tit_acr_aber > b_movto_tit_acr_aux.dat_transacao then
                      assign v_cod_portador   = b_movto_tit_acr_aux.cod_portador
                             v_cod_cart_bcia  = b_movto_tit_acr_aux.cod_cart_bcia
                             v_log_operac_financ = yes.
                end.   
            end.            
        end.    
    end.

    if  tit_acr.dat_vencto_tit_acr < p_dat_tit_acr_aber then do:
        if  v_log_tit_acr_vencid = no
        or (tit_acr.dat_vencto_tit_acr > p_dat_tit_acr_aber - v_qtd_dias_vencid) then
            return 'NOK'.
    end.
    else if  v_log_tit_acr_avencer = no
         or  (tit_acr.dat_vencto_tit_acr > p_dat_tit_acr_aber + v_qtd_dias_avencer) 
         and v_qtd_dias_avencer <> 9999 then
             return 'NOK'.

    find first cliente no-lock
        where cliente.cod_empresa    = tit_acr.cod_empresa /* v_cod_empres_usuar - leticia*/
        and   cliente.cdn_cliente    = tit_acr.cdn_cliente
        and   cliente.cod_grp_clien >= v_cod_grp_clien_ini
        and   cliente.cod_grp_clien <= v_cod_grp_clien_fim no-error.
    if  not avail cliente then
        return 'NOK'.

    if v_log_gerac_planilha then do:
       if cliente.num_pessoa mod 2 = 0 then do:
          find first pessoa_fisic no-lock
               where pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa no-error.
          assign v_cod_pessoa = 'F'.
       end.
       else do:
          find first pessoa_jurid no-lock
               where pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa no-error.
          assign v_cod_pessoa = 'J'.
       end.
    end.

    /* ** RETORNA A FINALIDADE ORIGINAL DO T÷TULO ***/
    run pi_retornar_finalid_indic_econ (Input tit_acr.cod_indic_econ,
                                        Input tit_acr.dat_transacao,
                                        output v_cod_finalid_econ_aux) /*pi_retornar_finalid_indic_econ*/.

    /* ** SE DATA DA POSIÄ«O FOR RETROCEDENTE, REFAZ O PORTADOR DA EPOCA ***/
    if  p_dat_tit_acr_aber  < today
    and v_log_operac_financ = no then do:
        run pi_retornar_portador_tit_acr_na_epoca (buffer tit_acr,
                                                   Input p_dat_tit_acr_aber,
                                                   output v_cod_portador,
                                                   output v_cod_cart_bcia) /*pi_retornar_portador_tit_acr_na_epoca*/.
    end.
    if  v_cod_portador = "" then
        assign v_cod_portador  = tit_acr.cod_portador
               v_cod_cart_bcia = tit_acr.cod_cart_bcia.

    if  v_cod_portador  < v_cod_portador_ini
    or  v_cod_portador  > v_cod_portador_fim
    or  v_cod_cart_bcia < v_cod_cart_bcia_ini
    or  v_cod_cart_bcia > v_cod_cart_bcia_fim then
        return 'NOK'.

    find portador where portador.cod_portador = v_cod_portador no-lock no-error.
    if  avail portador then
        assign v_nom_abrev = portador.nom_abrev.

    if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/  then do:
           /* Quaado o t≠tulo nío possui val_tit_acr, nío cria temp_table. Neste caso, os cˇlculos de juros, abatimentos, etc, atualizam sempre 
           o último registro da temp table criado. Desta forma os valores iam se acumulando para cada t≠tulo (o que ≤ incorreto, visto que ≤ 
           filtrado por UN), e estouravam a mˇscara do campo. Colocado os if not can-find. Fiz os testes e funcionou. */    
            if  not can-find(first val_tit_acr where val_tit_acr.cod_estab = tit_acr.cod_estab
                             and   val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
                             and   val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
                             and   val_tit_acr.cod_unid_negoc  >= v_cod_unid_negoc_ini
                             and   val_tit_acr.cod_unid_negoc  <= v_cod_unid_negoc_fim  )  
            and not can-find(first val_tit_acr where val_tit_acr.cod_estab = tit_acr.cod_estab
                             and   val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
                             and   val_tit_acr.cod_finalid_econ = v_cod_finalid_econ_aux
                             and   val_tit_acr.cod_unid_negoc  >= v_cod_unid_negoc_ini
                             and   val_tit_acr.cod_unid_negoc  <= v_cod_unid_negoc_fim  ) then return.


        /* Begin_Include: i_verifica_tit_acr_em_aberto_un */
        /* VALORES DO T÷TULO NA FINALIDADE INFORMADA */
        val_block:
        for each val_tit_acr fields (cod_estab num_id_tit_acr cod_finalid_econ cod_unid_negoc val_origin_tit_acr val_sdo_tit_acr val_entr_transf_estab  val_saida_transf_unid_negoc) no-lock
            where val_tit_acr.cod_estab        = tit_acr.cod_estab
            and   val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
            and   val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
            and   val_tit_acr.cod_unid_negoc  >= v_cod_unid_negoc_ini
            and   val_tit_acr.cod_unid_negoc  <= v_cod_unid_negoc_fim
            break by val_tit_acr.cod_unid_negoc:

            assign v_val_origin_tit_acr = v_val_origin_tit_acr + val_tit_acr.val_origin_tit_acr + val_tit_acr.val_entr_transf_estab
                   v_val_sdo_tit_acr    = v_val_sdo_tit_acr + val_tit_acr.val_sdo_tit_acr.

            if  last-of(val_tit_acr.cod_unid_negoc) then do:

                create tt_titulos_em_aberto_acr.
                assign tt_titulos_em_aberto_acr.tta_cod_estab = tit_acr.cod_estab
                       tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                       tt_titulos_em_aberto_acr.tta_cod_espec_docto = tit_acr.cod_espec_docto
                       tt_titulos_em_aberto_acr.tta_cod_ser_docto = tit_acr.cod_ser_docto
                       tt_titulos_em_aberto_acr.tta_cod_tit_acr = tit_acr.cod_tit_acr
                       tt_titulos_em_aberto_acr.tta_cod_parcela = tit_acr.cod_parcela
                       tt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc
                       tt_titulos_em_aberto_acr.tta_cdn_cliente = tit_acr.cdn_cliente
                       tt_titulos_em_aberto_acr.tta_cdn_clien_matriz = tit_acr.cdn_clien_matriz
                       tt_titulos_em_aberto_acr.tta_nom_abrev = cliente.nom_pessoa
                       tt_titulos_em_aberto_acr.ttv_nom_abrev_clien = tit_acr.nom_abrev
                       tt_titulos_em_aberto_acr.tta_cod_portador = v_cod_portador
                       tt_titulos_em_aberto_acr.ttv_nom_abrev = v_nom_abrev             
                       tt_titulos_em_aberto_acr.tta_cod_cart_bcia = v_cod_cart_bcia               
                       tt_titulos_em_aberto_acr.tta_cdn_repres = tit_acr.cdn_repres
                       tt_titulos_em_aberto_acr.tta_cod_refer = tit_acr.cod_refer
                       tt_titulos_em_aberto_acr.tta_dat_emis_docto = tit_acr.dat_emis_docto
                       tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
                       tt_titulos_em_aberto_acr.tta_cod_cond_cobr = tit_acr.cod_cond_cobr 
                       tt_titulos_em_aberto_acr.tta_cod_indic_econ = tit_acr.cod_indic_econ
                       tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
                       tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres = v_val_origin_tit_acr / v_val_cotac_indic_econ
                       tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = v_val_sdo_tit_acr / v_val_cotac_indic_econ
                       tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr = v_dat_calc_atraso - tit_acr.dat_vencto_tit_acr
                       tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = 0
                       tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = 0
                       tt_titulos_em_aberto_acr.tta_val_movto_tit_acr = 0
                       tt_titulos_em_aberto_acr.tta_cod_grp_clien = cliente.cod_grp_clien
                       tt_titulos_em_aberto_acr.ttv_rec_tit_acr = recid(tit_acr)
                       tt_titulos_em_aberto_acr.ttv_dat_tit_acr_aber = p_dat_tit_acr_aber
                       tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco = tit_acr.cod_tit_acr_bco
                       tt_titulos_em_aberto_acr.ttv_nom_cidad_cobr = if v_cod_pessoa = 'J' then pessoa_jurid.nom_cidad_cobr else "".

                if  tit_acr.dat_indcao_perda_dedut = 12/31/9999 then
                    assign tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut = ?.
                else 
                    assign tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut = tit_acr.dat_indcao_perda_dedut.

                assign v_val_origin_tit_acr = 0
                       v_val_sdo_tit_acr    = 0.

            if  v_log_sdo_tit_acr = yes then
                assign tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr = ?.
            else
                assign tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr = if (tit_acr.dat_liquidac_tit_acr     <> 12/31/9999
                                                                           and tit_acr.dat_ult_liquidac_tit_acr <> 12/31/9999 
                                                                           and tit_acr.dat_liquidac_tit_acr     <> tit_acr.dat_ult_liquidac_tit_acr
                                                                           and tit_acr.val_sdo_tit_acr           = 0) 
                                                                           then tit_acr.dat_ult_liquidac_tit_acr
                                                                           else tit_acr.dat_liquidac_tit_acr.

                assign tt_titulos_em_aberto_acr.tta_cod_empresa = tit_acr.cod_empresa.

                if  p_cdn_estil_dwb = 41 then do:
                    run pi_classifica_tit_acr_em_aberto /*pi_classifica_tit_acr_em_aberto*/.
                    if return-value = "NOK" /*l_nok*/  then
                        return "NOK" /*l_nok*/ .
                end.

                if v_log_gerac_planilha then do:
                   find tt_titulos_em_aberto_acr_compl no-lock
                        where tt_titulos_em_aberto_acr_compl.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                        and   tt_titulos_em_aberto_acr_compl.tta_num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                        and   tt_titulos_em_aberto_acr_compl.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-error.
                   if not avail tt_titulos_em_aberto_acr_compl then do:
                      create tt_titulos_em_aberto_acr_compl.
                      assign tt_titulos_em_aberto_acr_compl.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                             tt_titulos_em_aberto_acr_compl.tta_num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                             tt_titulos_em_aberto_acr_compl.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                             tt_titulos_em_aberto_acr_compl.tta_nom_cidade     = if v_cod_pessoa = 'J' then pessoa_jurid.nom_cidade   else pessoa_fisic.nom_cidade
                             tt_titulos_em_aberto_acr_compl.tta_cod_telefone   = if v_cod_pessoa = 'J' then pessoa_jurid.cod_telefone else pessoa_fisic.cod_telefone.
                   end.
                end.
            end.
        end /* for val_block */.

        if  not avail tt_titulos_em_aberto_acr then
            return 'NOK'.

        /* ** VALORES DO T÷TULO NA FINALIDADE ORIGINAL ***/
        val_block:
        for each val_tit_acr fields (cod_estab num_id_tit_acr cod_finalid_econ cod_unid_negoc val_origin_tit_acr val_sdo_tit_acr cod_tip_fluxo_financ val_entr_transf_estab val_perc_rat) no-lock
            where val_tit_acr.cod_estab        = tit_acr.cod_estab
            and   val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
            and   val_tit_acr.cod_finalid_econ = v_cod_finalid_econ_aux
            and   val_tit_acr.cod_unid_negoc  >= v_cod_unid_negoc_ini
            and   val_tit_acr.cod_unid_negoc  <= v_cod_unid_negoc_fim
            break by val_tit_acr.cod_unid_negoc:

            if  v_log_transf_estab_operac_financ and v_val_origin_transf_estab > 0 then do:
                assign v_val_origin_tit_acr = v_val_origin_tit_acr + (v_val_origin_transf_estab * val_tit_acr.val_perc_rat) / 100.
                if  tit_acr.val_transf_estab = 0 then do:
                    assign v_val_sdo_tit_acr = v_val_sdo_tit_acr + (v_val_origin_transf_estab * val_tit_acr.val_perc_rat) / 100.
                end.
            end.
            else do:
                assign v_val_origin_tit_acr = v_val_origin_tit_acr + val_tit_acr.val_origin_tit_acr + val_tit_acr.val_entr_transf_estab
                       v_val_sdo_tit_acr    = v_val_sdo_tit_acr + val_tit_acr.val_sdo_tit_acr.
            end.

            if  last-of(val_tit_acr.cod_unid_negoc)
            then do:
                find first btt_titulos_em_aberto_acr exclusive-lock
                    where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                    and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                    and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
               if avail btt_titulos_em_aberto_acr then
                  assign btt_titulos_em_aberto_acr.tta_val_origin_tit_acr = v_val_origin_tit_acr
                         btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = v_val_sdo_tit_acr.

                assign v_val_sdo_tit_acr    = 0
                       v_val_origin_tit_acr = 0.
            end /* if */.
        end /* for val_block */.

        /* End_Include: i_verifica_tit_acr_em_aberto_un */

    end.
    else do:

        FIND FIRST tt_titulos_em_aberto_acr EXCLUSIVE-LOCK
             WHERE tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
               AND tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
               AND tt_titulos_em_aberto_acr.tta_cod_unid_negoc = "" NO-ERROR.
        IF NOT AVAIL tt_titulos_em_aberto_acr THEN DO:
            create tt_titulos_em_aberto_acr.
        END.
        
        assign tt_titulos_em_aberto_acr.tta_cod_estab = tit_acr.cod_estab
               tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
               tt_titulos_em_aberto_acr.tta_cod_espec_docto = tit_acr.cod_espec_docto
               tt_titulos_em_aberto_acr.tta_cod_ser_docto = tit_acr.cod_ser_docto
               tt_titulos_em_aberto_acr.tta_cod_tit_acr = tit_acr.cod_tit_acr
               tt_titulos_em_aberto_acr.tta_cod_parcela = tit_acr.cod_parcela
               tt_titulos_em_aberto_acr.tta_cod_unid_negoc = ""
               tt_titulos_em_aberto_acr.tta_cdn_cliente = tit_acr.cdn_cliente
               tt_titulos_em_aberto_acr.tta_cdn_clien_matriz = tit_acr.cdn_clien_matriz
               tt_titulos_em_aberto_acr.tta_nom_abrev = cliente.nom_pessoa
               tt_titulos_em_aberto_acr.ttv_nom_abrev_clien = tit_acr.nom_abrev
               tt_titulos_em_aberto_acr.tta_cod_portador = v_cod_portador
               tt_titulos_em_aberto_acr.ttv_nom_abrev = v_nom_abrev             
               tt_titulos_em_aberto_acr.tta_cod_cart_bcia = v_cod_cart_bcia
               tt_titulos_em_aberto_acr.tta_cdn_repres = tit_acr.cdn_repres
               tt_titulos_em_aberto_acr.tta_cod_refer = tit_acr.cod_refer
               tt_titulos_em_aberto_acr.tta_dat_emis_docto = tit_acr.dat_emis_docto
               tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
               tt_titulos_em_aberto_acr.tta_cod_cond_cobr = tit_acr.cod_cond_cobr 
               tt_titulos_em_aberto_acr.tta_cod_indic_econ = tit_acr.cod_indic_econ
               tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = tit_acr.ind_tip_espec_docto
               tt_titulos_em_aberto_acr.tta_val_origin_tit_acr = tit_acr.val_origin_tit_acr
               tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tit_acr.val_sdo_tit_acr
               tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres = 0
               tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = 0
               tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr = v_dat_calc_atraso - tit_acr.dat_vencto_tit_acr
               tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = 0
               tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = 0
               tt_titulos_em_aberto_acr.tta_val_movto_tit_acr = 0
               tt_titulos_em_aberto_acr.tta_cod_grp_clien = cliente.cod_grp_clien
               tt_titulos_em_aberto_acr.ttv_rec_tit_acr = recid(tit_acr)
               tt_titulos_em_aberto_acr.ttv_dat_tit_acr_aber = p_dat_tit_acr_aber
               tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco = tit_acr.cod_tit_acr_bco
               tt_titulos_em_aberto_acr.ttv_nom_cidad_cobr = if v_cod_pessoa = 'J' then pessoa_jurid.nom_cidad_cobr else "".

        /* INICIO - Logica para buscar o codigo do convànio da Fatura e do Cupom Convànio */
        ASSIGN tt_titulos_em_aberto_acr.ttv_num_renegoc_cobr_acr = tit_acr.num_renegoc_cobr_acr.

        IF tt_titulos_em_aberto_acr.tta_cod_espec_docto = "CV" THEN DO:

            FOR FIRST cst_nota_fiscal NO-LOCK  USE-INDEX nota
                WHERE cst_nota_fiscal.cod_estabel = tt_titulos_em_aberto_acr.tta_cod_estab
                  AND cst_nota_fiscal.serie       = tt_titulos_em_aberto_acr.tta_cod_ser_docto
                  AND cst_nota_fiscal.nr_nota_fis = tt_titulos_em_aberto_acr.tta_cod_tit_acr  QUERY-TUNING(NO-LOOKAHEAD):

                ASSIGN tt_titulos_em_aberto_acr.ttv_cod_convenio = cst_nota_fiscal.convenio
                       tt_titulos_em_aberto_acr.ttv_id_pedido    = cst_nota_fiscal.id_pedido_convenio.

                FIND FIRST int_ds_convenio
                     WHERE int_ds_convenio.cod_convenio = INT(cst_nota_fiscal.convenio) NO-LOCK NO-ERROR.
                IF AVAIL int_ds_convenio THEN DO:

                    FIND FIRST cliente USE-INDEX cliente_idfedercli
                         WHERE cliente.cod_id_feder = int_ds_convenio.cnpj NO-LOCK NO-ERROR.
                    IF AVAIL cliente THEN DO:
                        ASSIGN tt_titulos_em_aberto_acr.ttv_cod_cliente  = STRING(cliente.cdn_cliente)
                               tt_titulos_em_aberto_acr.ttv_nome_cliente = cliente.nom_pessoa .
                    END.
                END.
            END.
        END.
        ELSE IF tt_titulos_em_aberto_acr.tta_cod_espec_docto = "CF" THEN DO:

            FIND FIRST renegoc_acr NO-LOCK
                 WHERE renegoc_acr.num_renegoc_cobr_acr = tt_titulos_em_aberto_acr.ttv_num_renegoc_cobr_acr NO-ERROR.
            IF AVAIL renegoc_acr THEN DO:

                estab_renegoc:
                FOR EACH estabelecimento NO-LOCK
                   WHERE estabelecimento.cod_empresa = v_cod_empres_usuar QUERY-TUNING(NO-LOOKAHEAD):

                    movto_tit_block:
                    FOR FIRST movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
                        WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                          AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                          AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/         QUERY-TUNING(NO-LOOKAHEAD):

                        IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.

                        FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                             WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                               AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.
                        IF AVAIL bf_tit_acr THEN DO:

                            FOR FIRST cst_nota_fiscal NO-LOCK                                              
                                WHERE cst_nota_fiscal.cod_estabel = bf_tit_acr.cod_estab           
                                  AND cst_nota_fiscal.serie       = bf_tit_acr.cod_ser_docto 
                                  AND cst_nota_fiscal.nr_nota_fis = bf_tit_acr.cod_tit_acr
                                query-tuning(no-lookahead):

                                ASSIGN tt_titulos_em_aberto_acr.ttv_cod_convenio = cst_nota_fiscal.convenio
                                       tt_titulos_em_aberto_acr.ttv_id_pedido    = cst_nota_fiscal.id_pedido_convenio.

                                FIND FIRST int_ds_convenio
                                     WHERE int_ds_convenio.cod_convenio = INT(cst_nota_fiscal.convenio) NO-LOCK NO-ERROR.
                                IF AVAIL int_ds_convenio THEN DO:

                                    FIND FIRST cliente USE-INDEX cliente_idfedercli
                                         WHERE cliente.cod_id_feder = int_ds_convenio.cnpj NO-LOCK NO-ERROR.
                                    IF AVAIL cliente THEN DO:
                                        ASSIGN tt_titulos_em_aberto_acr.ttv_cod_cliente  = STRING(cliente.cdn_cliente)
                                               tt_titulos_em_aberto_acr.ttv_nome_cliente = cliente.nom_pessoa .
                                    END.
                                END.
                                LEAVE estab_renegoc.
                            END.

                        END.
                    END.
                END.
            END.


        END.

        /* FIM    - Logica para buscar o codigo do convànio da Fatura e do Cupom Convànio */

        &if defined(BF_FIN_NUM_PROC_EXP_REL_CON) &then
            assign tt_titulos_em_aberto_acr.ttv_cod_proces_export = tit_acr.cod_proces_export.
        &else
            if v_log_funcao_proces_export or v_log_vers_50_6 then do:
                if num-entries(tit_acr.cod_livre_1,chr(24)) >= 4 then
                    assign tt_titulos_em_aberto_acr.ttv_cod_proces_export = entry(4,tit_acr.cod_livre_1,CHR(24)).
            end.        
        &endif       

        if  v_log_transf_estab_operac_financ and v_val_origin_transf_estab > 0 then do:
            assign tt_titulos_em_aberto_acr.tta_val_origin_tit_acr = v_val_origin_transf_estab.
            if tit_acr.val_transf_estab = 0 then
               assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = v_val_origin_transf_estab.
        end.

        if  tit_acr.dat_indcao_perda_dedut = 12/31/9999 then
            assign tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut = ?.
        else
            assign tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut = tit_acr.dat_indcao_perda_dedut.

        if  v_log_sdo_tit_acr = yes then
            assign tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr = ?.
        else
            assign tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr = if (tit_acr.dat_liquidac_tit_acr     <> 12/31/9999
                                                                       and tit_acr.dat_ult_liquidac_tit_acr <> 12/31/9999
                                                                       and tit_acr.dat_liquidac_tit_acr     <> tit_acr.dat_ult_liquidac_tit_acr
                                                                       and tit_acr.val_sdo_tit_acr           = 0) 
                                                                       then tit_acr.dat_ult_liquidac_tit_acr
                                                                       else tit_acr.dat_liquidac_tit_acr.

        assign tt_titulos_em_aberto_acr.tta_cod_empresa = tit_acr.cod_empresa.

        for each val_tit_acr fields (cod_estab num_id_tit_acr cod_finalid_econ val_origin_tit_acr val_sdo_tit_acr val_entr_transf_estab) no-lock
            where val_tit_acr.cod_estab        = tit_acr.cod_estab
            and   val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
            and   val_tit_acr.cod_finalid_econ = v_cod_finalid_econ:
            assign tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres +
                                                                           ((val_tit_acr.val_entr_transf_estab + val_tit_acr.val_origin_tit_acr) / v_val_cotac_indic_econ)
                   tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres    = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres    +
                                                                           (val_tit_acr.val_sdo_tit_acr / v_val_cotac_indic_econ).
        end.

        if  p_cdn_estil_dwb = 41 then do:
            run pi_classifica_tit_acr_em_aberto /*pi_classifica_tit_acr_em_aberto*/.
            if return-value = "NOK" /*l_nok*/  then
                    return "NOK" /*l_nok*/ .
        end.

        if v_log_gerac_planilha then do:
           find tt_titulos_em_aberto_acr_compl no-lock
                where tt_titulos_em_aberto_acr_compl.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                and   tt_titulos_em_aberto_acr_compl.tta_num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                and   tt_titulos_em_aberto_acr_compl.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-error.
           if not avail tt_titulos_em_aberto_acr_compl then do:
              create tt_titulos_em_aberto_acr_compl.
              assign tt_titulos_em_aberto_acr_compl.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                     tt_titulos_em_aberto_acr_compl.tta_num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                     tt_titulos_em_aberto_acr_compl.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                     tt_titulos_em_aberto_acr_compl.tta_nom_cidade     = if v_cod_pessoa = 'J' then pessoa_jurid.nom_cidade   else pessoa_fisic.nom_cidade
                     tt_titulos_em_aberto_acr_compl.tta_cod_telefone   = if v_cod_pessoa = 'J' then pessoa_jurid.cod_telefone else pessoa_fisic.cod_telefone.
           end.
        end.
    end.

    run pi_verifica_movtos_tit_acr_em_aberto (Input p_dat_tit_acr_aber) /*pi_verifica_movtos_tit_acr_em_aberto*/.


    /* Begin_Include: i_calcula_saldo */
    def var v_val_perc_juros_dia_atraso_tit  as decimal  decimals 6  no-undo.
    def var v_hdl_api                        as handle               no-undo. 
    def var v_log_desc_antecip_ptlidad       as logical  initial no	 no-undo.
    def var v_val_perc_desc_tit_antecip      as decimal  decimals 4  no-undo.

    assign v_val_perc_juros_dia_atraso_tit = tit_acr.val_perc_juros_dia_atraso.


    &if defined(BF_FIN_PRECO_FLUTUANTE) &then
        if can-find(first param_integr_ems no-lock
                    where param_integr_ems.ind_param_integr_ems = &if defined(BF_FIN_ORIG_GRAOS) &then
                                                                  "Originaá∆o De Gr∆os" /*l_originacao_graos*/ 
                                                                  &else
                                                                  "Gr∆os 2.00" /*l_graos_2.00*/ 
                                                                  &endif
                                                                  ) then
            assign v_log_preco_flut_graos = true.
    &endif

    if v_log_preco_flut_graos then do:
        run prgfin/acr/acr536za.py persistent set v_hdl_api.
        run pi_busca_juros_desc_liquidac_acr_graos in v_hdl_api (input tit_acr.cod_estab,
                                                                 input tit_acr.cod_espec_docto,
                                                                 input tit_acr.cod_ser_docto,
                                                                 input tit_acr.cod_tit_acr,
                                                                 input tit_acr.cod_parcela,
                                                                 input v_dat_tit_acr_aber,
                                                                 output v_val_perc_desc_tit_antecip,
                                                                 output v_val_perc_juros_dia_atraso_tit,
                                                                 output v_log_desc_antecip_ptlidad).
        delete procedure v_hdl_api.
    end.
    else do:
        assign v_val_perc_juros_dia_atraso_tit = tit_acr.val_perc_juros_dia_atraso    
               v_val_perc_desc_tit_antecip     = 0.
    end.



    /* ******* C†lculo de Juros / Desconto / Abatimento como na Liquidaá∆o / Multa ************ */

    if  v_log_funcao_juros_multa and
        v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr - tit_acr.qtd_dias_carenc_juros_acr > 0 then
        assign v_num_atraso_dias_acr = v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr.

    if  not v_log_funcao_juros_multa then
        assign v_num_atraso_dias_acr = v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr.


    /* Begin_Include: i_calcula_saldo_juros */
    if  v_log_consid_juros
    then do:
        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:
            val_block:
            for each val_tit_acr no-lock
                where val_tit_acr.cod_estab            = tit_acr.cod_estab
                and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                break by val_tit_acr.cod_unid_negoc:

                if last-of(val_tit_acr.cod_unid_negoc) then do:
                    find first btt_titulos_em_aberto_acr
                         where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                         and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                         and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                    if avail btt_titulos_em_aberto_acr then do:
                        if  btt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr <> ? then                    
                            assign btt_titulos_em_aberto_acr.tta_val_juros = btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr
                                                                          * v_num_atraso_dias_acr
                                                                          * v_val_perc_juros_dia_atraso_tit
                                                                          / 100.


                        /* **** tipo de c†lculo de juros *******/
                        if  v_log_funcao_tip_calc_juros then do:
                            &if '{&emsfin_version}' >= "5.05" &then
                                assign v_ind_tip_calc_juros = tit_acr.ind_tip_calc_juros.
                            &else
                                assign v_ind_tip_calc_juros = entry(3, tit_acr.cod_livre_1, chr(24)).
                            &endif
                            run pi_retorna_juros_compostos (Input v_ind_tip_calc_juros,
                                                            Input v_val_perc_juros_dia_atraso_tit,
                                                            Input btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr,
                                                            Input v_num_atraso_dias_acr,
                                                            output v_val_juros_aux) /*pi_retorna_juros_compostos*/.
                            if  v_val_juros_aux <> ? then
                                assign btt_titulos_em_aberto_acr.tta_val_juros = v_val_juros_aux.
                        end.

                        if  v_dat_tit_acr_aber <= tit_acr.dat_vencto_tit_acr then
                            assign btt_titulos_em_aberto_acr.tta_val_juros = 0.
                    end.
                end.
            end.
        end /* if */.
        else do:
            if  tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr <> ? then
                assign tt_titulos_em_aberto_acr.tta_val_juros = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr
                                                              * v_num_atraso_dias_acr
                                                              * v_val_perc_juros_dia_atraso_tit
                                                              / 100.


            /* **** tipo de c†lculo de juros *******/
            if  v_log_funcao_tip_calc_juros then do:
                &if '{&emsfin_version}' >= "5.05" &then
                    assign v_ind_tip_calc_juros = tit_acr.ind_tip_calc_juros.
                &else
                    assign v_ind_tip_calc_juros = entry(3, tit_acr.cod_livre_1, chr(24)).
                &endif
                run pi_retorna_juros_compostos (Input v_ind_tip_calc_juros,
                                                Input v_val_perc_juros_dia_atraso_tit,
                                                Input tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr,
                                                Input v_num_atraso_dias_acr,
                                                output v_val_juros_aux) /*pi_retorna_juros_compostos*/.
                if  v_val_juros_aux <> ? then
                    assign tt_titulos_em_aberto_acr.tta_val_juros = v_val_juros_aux.
            end.

            if  v_dat_tit_acr_aber <= tit_acr.dat_vencto_tit_acr then
                assign tt_titulos_em_aberto_acr.tta_val_juros = 0.
        end /* else */.
    end.
    else
        if avail tt_titulos_em_aberto_acr then
           assign tt_titulos_em_aberto_acr.tta_val_juros = 0.
    /* End_Include: i_calcula_saldo_juros */


    if  v_log_consid_multa
    then do:
        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:
            val_block:
            for each val_tit_acr no-lock
                where val_tit_acr.cod_estab        = tit_acr.cod_estab
                  and val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
                  and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
                  and val_tit_acr.cod_unid_negoc  >= v_cod_unid_negoc_ini
                  and val_tit_acr.cod_unid_negoc  <= v_cod_unid_negoc_fim
                break by val_tit_acr.cod_unid_negoc:

                if  last-of(val_tit_acr.cod_unid_negoc)
                then do:
                    find first btt_titulos_em_aberto_acr
                         where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                           and btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                           and btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                    if  avail btt_titulos_em_aberto_acr
                    then do:
                        if  v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr - tit_acr.qtd_dias_carenc_multa_acr > 0
                        and tit_acr.val_perc_multa_atraso <> 0 then
                            assign btt_titulos_em_aberto_acr.tta_val_juros = btt_titulos_em_aberto_acr.tta_val_juros + 
                                                                           (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * tit_acr.val_perc_multa_atraso / 100).
                    end.
                end.
            end.
        end.
        else do:
            if  v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr - tit_acr.qtd_dias_carenc_multa_acr > 0 
            and tit_acr.val_perc_multa_atraso <> 0 then
                assign tt_titulos_em_aberto_acr.tta_val_juros = tt_titulos_em_aberto_acr.tta_val_juros + 
                                                               (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * tit_acr.val_perc_multa_atraso / 100).
        end.
    end.

    if  v_log_consid_juros or v_log_consid_multa
    then do:
        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:
            for each btt_titulos_em_aberto_acr
               where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                 and btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr:
                assign btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + btt_titulos_em_aberto_acr.tta_val_juros).
            end.
        end.
        else
            assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + tt_titulos_em_aberto_acr.tta_val_juros).
    end.

    if  v_log_consid_abat or v_log_consid_desc
    then do:
        assign v_qtd_dias_vencto_tit_acr = v_dat_tit_acr_aber - tit_acr.dat_vencto_tit_acr.

        &if '{&emsfin_version}' = "5.03" &then
             assign v_val_perc_abat_acr_1 = decimal(entry(1, tit_acr.cod_livre_1, chr(24))).
        &else
             assign v_val_perc_abat_acr_1 = tit_acr.val_perc_abat_acr.
        &endif

        if  tit_acr.cod_cond_cobr <> ""
        then do:
            find cond_cobr_acr no-lock 
                 where cond_cobr_acr.cod_estab       = tit_acr.cod_estab
                 and   cond_cobr_acr.cod_cond_cobr   = tit_acr.cod_cond_cobr 
                 and   cond_cobr_acr.dat_inic_valid <= tit_acr.dat_emis_docto
                 and   cond_cobr_acr.dat_fim_valid   > tit_acr.dat_emis_docto no-error.

            find compl_cond_cobr_acr no-lock
                 where compl_cond_cobr_acr.cod_estab              = tit_acr.cod_estab
                 and   compl_cond_cobr_acr.cod_cond_cobr          = tit_acr.cod_cond_cobr
                 and   compl_cond_cobr_acr.num_seq_cond_cobr_acr  = cond_cobr_acr.num_seq_cond_cobr_acr
                 and   compl_cond_cobr_acr.log_cond_cobr_acr_padr = yes no-error.

            if avail compl_cond_cobr then do:
                &if '{&emsfin_version}' = "5.03" &then
                    assign v_val_perc_abat_acr_cond_cobr = decimal(entry(1, compl_cond_cobr_acr.cod_livre_1, chr(24))).
                &else
                    assign v_val_perc_abat_acr_cond_cobr = compl_cond_cobr_acr.val_perc_abat_cond_cobr.
                &endif

                if  v_log_consid_desc then do:
                if compl_cond_cobr_acr.val_perc_desc_cond_cobr = tit_acr.val_perc_desc
                   or tit_acr.dat_desconto = ? then do:
                   if v_qtd_dias_vencto_tit_acr < 0 then
                      find last b_compl_cond_cobr_acr no-lock
                          where b_compl_cond_cobr_acr.cod_estab                = tit_acr.cod_estab
                          and   b_compl_cond_cobr_acr.cod_cond_cobr            = tit_acr.cod_cond_cobr
                          and   b_compl_cond_cobr_acr.num_seq_cond_cobr_acr    = cond_cobr_acr.num_seq_cond_cobr_acr 
                          and   b_compl_cond_cobr_acr.qtd_dias_vencto_tit_acr <= (v_qtd_dias_vencto_tit_acr * (-1)) no-error.
                   else
                      find last b_compl_cond_cobr_acr no-lock
                          where b_compl_cond_cobr_acr.cod_estab                = tit_acr.cod_estab
                          and   b_compl_cond_cobr_acr.cod_cond_cobr            = tit_acr.cod_cond_cobr
                          and   b_compl_cond_cobr_acr.num_seq_cond_cobr_acr    = cond_cobr_acr.num_seq_cond_cobr_acr 
                          and   b_compl_cond_cobr_acr.qtd_dias_vencto_tit_acr <= (v_qtd_dias_vencto_tit_acr * (-1)) no-error.
                   if  avail b_compl_cond_cobr_acr
                   then do:
                       if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
                       then do:
                           val_block:
                           for each val_tit_acr no-lock
                               where val_tit_acr.cod_estab            = tit_acr.cod_estab
                               and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                               and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                               and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                               and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                               break by val_tit_acr.cod_unid_negoc:

                               if last-of(val_tit_acr.cod_unid_negoc) then do:
                                   find first btt_titulos_em_aberto_acr
                                       where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                                       and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                                       and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                                   if avail btt_titulos_em_aberto_acr then
                                       assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                               b_compl_cond_cobr_acr.val_perc_desc_cond_cobr) / 100.
                               end.
                           end.
                       end /* if */.
                       else
                           assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                   b_compl_cond_cobr_acr.val_perc_desc_cond_cobr) / 100.
                   end /* if */.
                   else
                      if avail tt_titulos_em_aberto_acr then 
                         assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = 0.
                end.
                else do:
                   if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
                   then do:
                       val_block:
                       for each val_tit_acr no-lock
                           where val_tit_acr.cod_estab            = tit_acr.cod_estab
                           and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                           and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                           and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                           and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                           break by val_tit_acr.cod_unid_negoc:

                           if last-of(val_tit_acr.cod_unid_negoc) then do:
                               find first btt_titulos_em_aberto_acr
                                   where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                                   and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                                   and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                               if avail btt_titulos_em_aberto_acr then
                                   assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                           tit_acr.val_perc_desc) / 100.
                           end.
                       end.
                   end /* if */.
                   else
                       assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                               tit_acr.val_perc_desc) / 100.
                end /* else */.
                end /* if considera desconto */.

                if  v_log_consid_abat then do:
                if  v_val_perc_abat_acr_cond_cobr = v_val_perc_abat_acr_1
                    or tit_acr.dat_abat_tit_acr = ? then do:
                    if v_qtd_dias_vencto_tit_acr < 0 then
                       find last b_compl_cond_cobr_acr no-lock
                           where b_compl_cond_cobr_acr.cod_estab                = tit_acr.cod_estab
                           and   b_compl_cond_cobr_acr.cod_cond_cobr            = tit_acr.cod_cond_cobr
                           and   b_compl_cond_cobr_acr.num_seq_cond_cobr_acr    = cond_cobr_acr.num_seq_cond_cobr_acr 
                           and   b_compl_cond_cobr_acr.qtd_dias_vencto_tit_acr <= (v_qtd_dias_vencto_tit_acr * (-1)) no-error.
                    else
                       find last b_compl_cond_cobr_acr no-lock
                           where b_compl_cond_cobr_acr.cod_estab                = tit_acr.cod_estab
                           and   b_compl_cond_cobr_acr.cod_cond_cobr            = tit_acr.cod_cond_cobr
                           and   b_compl_cond_cobr_acr.num_seq_cond_cobr_acr    = cond_cobr_acr.num_seq_cond_cobr_acr 
                           and   b_compl_cond_cobr_acr.qtd_dias_vencto_tit_acr <= (v_qtd_dias_vencto_tit_acr * (-1)) no-error.
                    if  avail b_compl_cond_cobr_acr
                    then do:
                       if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
                       then do:
                           val_block:
                           for each val_tit_acr no-lock
                               where val_tit_acr.cod_estab            = tit_acr.cod_estab
                               and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                               and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                               and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                               and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                               break by val_tit_acr.cod_unid_negoc:

                               if last-of(val_tit_acr.cod_unid_negoc) then do:
                                   find first btt_titulos_em_aberto_acr
                                       where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                                       and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                                       and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                                   if avail btt_titulos_em_aberto_acr then do:
                                       &if '{&emsfin_version}' = "5.03" &then
                                           assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                                   decimal(entry(1, b_compl_cond_cobr_acr.cod_livre_1, chr(24)))) / 100.
                                       &else
                                           assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                                   b_compl_cond_cobr_acr.val_perc_abat_cond_cobr) / 100.
                                       &endif
                                   end.
                               end.
                           end.
                       end /* if */.
                       else do:
                           &if '{&emsfin_version}' = "5.03" &then
                               assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                       decimal(entry(1, b_compl_cond_cobr_acr.cod_livre_1, chr(24)))) / 100.
                           &else
                               assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                       b_compl_cond_cobr_acr.val_perc_abat_cond_cobr) / 100.
                           &endif
                       end /* else */. 
                    end /* if */.
                    else
                       if avail tt_titulos_em_aberto_acr then 
                          assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = 0.
                end.
                else do:
                    if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
                    then do:
                       val_block:
                       for each val_tit_acr no-lock
                           where val_tit_acr.cod_estab            = tit_acr.cod_estab
                           and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                           and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                           and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                           and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                           break by val_tit_acr.cod_unid_negoc:

                           if last-of(val_tit_acr.cod_unid_negoc) then do:
                               find first btt_titulos_em_aberto_acr
                                   where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                                   and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                                   and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                               if avail btt_titulos_em_aberto_acr then
                                   assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                           v_val_perc_abat_acr_1) / 100.
                           end.
                       end.
                    end /* if */.
                    else
                        assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                v_val_perc_abat_acr_1) / 100.
                end.
                end /* log considera abatimento */.
            end.
            else do:
                if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
                and (v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ?
                or   v_log_consid_desc and string(tit_acr.dat_desconto)     <> ?)
                then do:
                    val_block:
                    for each val_tit_acr no-lock
                       where val_tit_acr.cod_estab            = tit_acr.cod_estab
                       and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                       and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                       and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                       and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                       break by val_tit_acr.cod_unid_negoc:

                       if last-of(val_tit_acr.cod_unid_negoc) then do:
                           find first btt_titulos_em_aberto_acr
                               where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                               and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                               and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                           if avail btt_titulos_em_aberto_acr then do:
                               if  v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ? then 
                                   assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                           v_val_perc_abat_acr_1) / 100.
                               if  v_log_consid_desc and string(tit_acr.dat_desconto) <> ? then
                                   assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                           tit_acr.val_perc_desc ) / 100.
                           end.
                       end.
                    end.
                end.
                else do:           
                    if  v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ? then 
                        assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                v_val_perc_abat_acr_1) / 100.
                    if  v_log_consid_desc and string(tit_acr.dat_desconto) <> ? then
                        assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                             tit_acr.val_perc_desc ) / 100.
                end.
            end.
        end /* if */.
        else do:
            if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
            and (v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ?
            or   v_log_consid_desc and string(tit_acr.dat_desconto)     <> ?)
            then do:
                val_block:
                for each val_tit_acr no-lock
                   where val_tit_acr.cod_estab            = tit_acr.cod_estab
                   and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                   and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                   and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                   and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                   break by val_tit_acr.cod_unid_negoc:

                   if last-of(val_tit_acr.cod_unid_negoc) then do:
                       find first btt_titulos_em_aberto_acr
                           where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                           and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                           and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                       if avail btt_titulos_em_aberto_acr then do:
                           if v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ? then 
                               assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                       v_val_perc_abat_acr_1) / 100.
                           if v_log_consid_desc and string(tit_acr.dat_desconto) <> ? then
                               assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                                       tit_acr.val_perc_desc ) / 100.
                       end.
                   end.
                end.
            end.
            else do:
                if v_log_consid_abat and string(tit_acr.dat_abat_tit_acr) <> ? then 
                    assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                         v_val_perc_abat_acr_1) / 100.
                if v_log_consid_desc and string(tit_acr.dat_desconto) <> ? then
                    assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * 
                                                                         tit_acr.val_perc_desc ) / 100.
            end.
        end.

        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:
            val_block:
            for each val_tit_acr no-lock
               where val_tit_acr.cod_estab            = tit_acr.cod_estab
               and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
               and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
               and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
               and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
               break by val_tit_acr.cod_unid_negoc:

               if last-of(val_tit_acr.cod_unid_negoc) then do:
                   find first btt_titulos_em_aberto_acr
                       where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                       and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                       and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                   if avail btt_titulos_em_aberto_acr then do:
                       if  v_dat_tit_acr_aber > tit_acr.dat_desconto then
                           assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = 0.

                       if  v_dat_tit_acr_aber > tit_acr.dat_abat_tit_acr then
                           assign btt_titulos_em_aberto_acr.tta_val_abat_tit_acr = 0.

                       if v_log_consid_desc and v_log_preco_flut_graos and v_val_perc_desc_tit_antecip <> 0 then do:
                            if v_log_desc_antecip_ptlidad then
                                assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = btt_titulos_em_aberto_acr.tta_val_desc_tit_acr + 
                                                                                       (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * v_val_perc_desc_tit_antecip) / 100.
                            else    
                                assign btt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * v_val_perc_desc_tit_antecip) / 100.
                       end.                        


                       assign btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr -
                                                                             (btt_titulos_em_aberto_acr.tta_val_abat_tit_acr +
                                                                              btt_titulos_em_aberto_acr.tta_val_desc_tit_acr).
                   end.
               end.
            end.
        end.
        else do:
            if  v_dat_tit_acr_aber > tit_acr.dat_desconto then
                assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = 0.

            if  v_dat_tit_acr_aber > tit_acr.dat_abat_tit_acr then
                assign tt_titulos_em_aberto_acr.tta_val_abat_tit_acr = 0.


            if v_log_consid_desc and v_log_preco_flut_graos and v_val_perc_desc_tit_antecip <> 0 then do:
                if v_log_desc_antecip_ptlidad then
                    assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = tt_titulos_em_aberto_acr.tta_val_desc_tit_acr + 
                                                                          (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * v_val_perc_desc_tit_antecip) / 100.
                else    
                    assign tt_titulos_em_aberto_acr.tta_val_desc_tit_acr = (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * v_val_perc_desc_tit_antecip) / 100.
            end.                        

            assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr -
                                                                  (tt_titulos_em_aberto_acr.tta_val_abat_tit_acr +
                                                                  tt_titulos_em_aberto_acr.tta_val_desc_tit_acr).
        end.
    end /* if */.
    /* End_Include: i_calcula_saldo_juros */


    /* Begin_Include: i_calcula_saldo_imposto */
    if  v_log_consid_impto_retid
    then do:
       for each impto_vincul_tit_acr no-lock 
          where impto_vincul_tit_acr.cod_estab      = tit_acr.cod_estab
          and   impto_vincul_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr:            
          if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
          then do:
              val_block:
              for each val_tit_acr no-lock
                  where val_tit_acr.cod_estab            = tit_acr.cod_estab
                  and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
                  and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                  and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                  and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                  break by val_tit_acr.cod_unid_negoc:

                  if last-of(val_tit_acr.cod_unid_negoc) then do:
                      find first btt_titulos_em_aberto_acr
                          where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                          and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                          and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                      if avail btt_titulos_em_aberto_acr then do:
                          IF v_log_impto_cop = no THEN DO:
                              assign btt_titulos_em_aberto_acr.ttv_val_impto_retid = btt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                            (btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                             impto_vincul_tit_acr.val_aliq_impto) / 100.
                          END.
                          ELSE DO:
                              &if '{&emsfin_version}' >= '5.05' &then
                                  IF impto_vincul_tit_acr.val_base_liq_impto <> 0 THEN DO:
                                      assign btt_titulos_em_aberto_acr.ttv_val_impto_retid = btt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                            (impto_vincul_tit_acr.val_base_liq_impto *
                                                                                             impto_vincul_tit_acr.val_aliq_impto) / 100.
                                  END.
                                  ELSE DO:
                                      assign btt_titulos_em_aberto_acr.ttv_val_impto_retid = btt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                            ( btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                                             impto_vincul_tit_acr.val_aliq_impto) / 100.
                                  END. 
                              &else
                                  IF impto_vincul_tit_acr.val_livre_1 <> 0 THEN DO:
                                      assign btt_titulos_em_aberto_acr.ttv_val_impto_retid = btt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                            (impto_vincul_tit_acr.val_livre_1 *
                                                                                             impto_vincul_tit_acr.val_aliq_impto) / 100.
                                  END.
                                  ELSE DO:
                                      assign btt_titulos_em_aberto_acr.ttv_val_impto_retid = btt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                            ( btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                                             impto_vincul_tit_acr.val_aliq_impto) / 100.
                                  END. 
                              &endif
                          END.
                          assign btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr  - btt_titulos_em_aberto_acr.ttv_val_impto_retid
                                 v_val_soma_impto_retid                       = v_val_soma_impto_retid                        + btt_titulos_em_aberto_acr.ttv_val_impto_retid 
                                 btt_titulos_em_aberto_acr.ttv_val_impto_retid = 0.
                      end.
                  end.
              end.
          end.
          else do:
              IF v_log_impto_cop = no THEN DO:
                  assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = tt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                        (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                         impto_vincul_tit_acr.val_aliq_impto) / 100.
              END.
              ELSE DO:
                  &if '{&emsfin_version}' >= '5.05' &then
                      IF impto_vincul_tit_acr.val_base_liq_impto <> 0 THEN DO:
                          assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = tt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                (impto_vincul_tit_acr.val_base_liq_impto *
                                                                                 impto_vincul_tit_acr.val_aliq_impto) / 100.
                      END.
                      ELSE DO:
                          assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = tt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                ( tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                                 impto_vincul_tit_acr.val_aliq_impto) / 100.
                      END. 
                  &else
                      IF impto_vincul_tit_acr.val_livre_1 <> 0 THEN DO:
                          assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = tt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                (impto_vincul_tit_acr.val_livre_1 *
                                                                                 impto_vincul_tit_acr.val_aliq_impto) / 100.
                      END.
                      ELSE DO:
                          assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = tt_titulos_em_aberto_acr.ttv_val_impto_retid +
                                                                                ( tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr *
                                                                                 impto_vincul_tit_acr.val_aliq_impto) / 100.
                      END. 
                  &endif
              END.
              assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr  - tt_titulos_em_aberto_acr.ttv_val_impto_retid
                     v_val_soma_impto_retid                       = v_val_soma_impto_retid                        + tt_titulos_em_aberto_acr.ttv_val_impto_retid 
                     tt_titulos_em_aberto_acr.ttv_val_impto_retid = 0.
          end.
       end.   
    end /* if */.
    assign tt_titulos_em_aberto_acr.ttv_val_impto_retid = v_val_soma_impto_retid
           v_val_soma_impto_retid                       = 0.

    /* End_Include: i_calcula_saldo_imposto */


    /* Begin_Include: i_calcula_saldo_2 */
    if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
    then do:
        val_block:
        for each val_tit_acr no-lock
            where val_tit_acr.cod_estab            = tit_acr.cod_estab
            and   val_tit_acr.num_id_tit_acr       = tit_acr.num_id_tit_acr
            and   val_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
            and   val_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
            and   val_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
            break by val_tit_acr.cod_unid_negoc:

            if last-of(val_tit_acr.cod_unid_negoc) then do:
                find first btt_titulos_em_aberto_acr
                     where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                     and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                     and   btt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                if avail btt_titulos_em_aberto_acr then do:
                    if  btt_titulos_em_aberto_acr.tta_val_juros <> 0
                    or  btt_titulos_em_aberto_acr.tta_val_abat_tit_acr <> 0
                    or  btt_titulos_em_aberto_acr.tta_val_desc_tit_acr <> 0
                    or  btt_titulos_em_aberto_acr.ttv_val_impto_retid <> 0 then do:
                        if  btt_titulos_em_aberto_acr.tta_cod_indic_econ <> v_cod_indic_econ_apres then
                            run pi_achar_cotac_indic_econ (Input btt_titulos_em_aberto_acr.tta_cod_indic_econ,
                                                           Input v_cod_indic_econ_apres,
                                                           Input v_dat_cotac_indic_econ,
                                                           Input "Real" /*l_real*/,
                                                           output v_dat_cotac_aux,
                                                           output v_val_cotac_aux,
                                                           output v_cod_return) /*pi_achar_cotac_indic_econ*/.
                        else
                            assign v_val_cotac_aux = 1.

                        assign btt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = btt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                  + ((btt_titulos_em_aberto_acr.tta_val_juros
                                    - btt_titulos_em_aberto_acr.tta_val_abat_tit_acr
                                    - btt_titulos_em_aberto_acr.tta_val_desc_tit_acr
                                    - btt_titulos_em_aberto_acr.ttv_val_impto_retid)
                                    / v_val_cotac_aux).
                    end.
                end.
            end.
        end.
    end.
    else do:
        if  tt_titulos_em_aberto_acr.tta_val_juros <> 0
        or  tt_titulos_em_aberto_acr.tta_val_abat_tit_acr <> 0
        or  tt_titulos_em_aberto_acr.tta_val_desc_tit_acr <> 0
        or  tt_titulos_em_aberto_acr.ttv_val_impto_retid <> 0 then do:
            if  tt_titulos_em_aberto_acr.tta_cod_indic_econ <> v_cod_indic_econ_apres then
                run pi_achar_cotac_indic_econ (Input tt_titulos_em_aberto_acr.tta_cod_indic_econ,
                                               Input v_cod_indic_econ_apres,
                                               Input v_dat_cotac_indic_econ,
                                               Input "Real" /*l_real*/,
                                               output v_dat_cotac_aux,
                                               output v_val_cotac_aux,
                                               output v_cod_return) /*pi_achar_cotac_indic_econ*/.
            else
                assign v_val_cotac_aux = 1.

            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                      + ((tt_titulos_em_aberto_acr.tta_val_juros
                        - tt_titulos_em_aberto_acr.tta_val_abat_tit_acr
                        - tt_titulos_em_aberto_acr.tta_val_desc_tit_acr
                        - tt_titulos_em_aberto_acr.ttv_val_impto_retid)
                        / v_val_cotac_aux).
        end.
    end.
    /* End_Include: i_calcula_saldo_2 */


    if  p_cdn_estil_dwb = 41 then
        run pi_calcular_pmr_amr_tit_acr_em_aberto /*pi_calcular_pmr_amr_tit_acr_em_aberto*/.

    /* ** SE O TITULO N«O TINHA SALDO NA DATA, N«O SERµ IMPRESSO ***/
    /* ** OBS: EM ALGUNS CASOS O TITULO TEM SALDO NEGATIVO, DEVE SER IMPRESSO (Barth) ***/
    if avail tt_titulos_em_aberto_acr and tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = 0.00 then do:
       delete tt_titulos_em_aberto_acr.
       return "NOK" /*l_nok*/ .
    end.

    return "".

END PROCEDURE. /* pi_verifica_tit_acr_em_aberto_cria_tt */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_portador_tit_acr_na_epoca
** Descricao.............: pi_retornar_portador_tit_acr_na_epoca
** Criado por............: Barth
** Criado em.............: 05/07/1999 13:20:58
** Alterado por..........: bre18732_2
** Alterado em...........: 04/06/2004 10:29:30
*****************************************************************************/
PROCEDURE pi_retornar_portador_tit_acr_na_epoca:

    /************************ Parameter Definition Begin ************************/

    def param buffer p_tit_acr
        for tit_acr.
    def Input param p_dat_tit_acr_aber
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def output param p_cod_cart_bcia
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_aux
        for movto_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_aux                        as date            no-undo. /*local*/
    def var v_dat_aux_2                      as date            no-undo. /*local*/
    def var v_hra_aux                        as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_dat_aux   = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
           v_dat_aux_2 = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
           v_hra_aux   = "".

    for each b_movto_tit_acr_aux no-lock use-index mvtttcr_id
        where b_movto_tit_acr_aux.cod_estab      = p_tit_acr.cod_estab
        and   b_movto_tit_acr_aux.num_id_tit_acr = p_tit_acr.num_id_tit_acr
        and  (b_movto_tit_acr_aux.ind_trans_acr = "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/ 
        or    b_movto_tit_acr_aux.ind_trans_acr = "Implantaá∆o" /*l_implantacao*/ 
        or    b_movto_tit_acr_aux.ind_trans_acr = "Transf Estabelecimento" /*l_transf_estabelecimento*/ 
        or    b_movto_tit_acr_aux.ind_trans_acr = "Renegociaá∆o" /*l_renegociacao*/ 
        or    b_movto_tit_acr_aux.ind_trans_acr = "Desconto Banc†rio" /*l_desconto_bancario*/ )
        and   b_movto_tit_acr_aux.dat_transacao <= p_dat_tit_acr_aber:

        if   b_movto_tit_acr_aux.dat_transacao > v_dat_aux_2
        or  (b_movto_tit_acr_aux.dat_transacao = v_dat_aux_2
        and (b_movto_tit_acr_aux.dat_gerac_movto > v_dat_aux
        or  (b_movto_tit_acr_aux.dat_gerac_movto = v_dat_aux
        and  b_movto_tit_acr_aux.hra_gerac_movto > v_hra_aux)))
        or  (b_movto_tit_acr_aux.dat_transacao <= v_dat_aux_2
        and (b_movto_tit_acr_aux.dat_gerac_movto > v_dat_aux
        or  (b_movto_tit_acr_aux.dat_gerac_movto = v_dat_aux
        and  b_movto_tit_acr_aux.hra_gerac_movto > v_hra_aux))) then
            assign v_dat_aux_2     = b_movto_tit_acr_aux.dat_transacao
                   v_dat_aux       = b_movto_tit_acr_aux.dat_gerac_movto
                   v_hra_aux       = b_movto_tit_acr_aux.hra_gerac_movto
                   p_cod_portador  = b_movto_tit_acr_aux.cod_portador
                   p_cod_cart_bcia = b_movto_tit_acr_aux.cod_cart_bcia.
    end.

    if  p_cod_portador = "" then
        assign p_cod_portador  = p_tit_acr.cod_portador
               p_cod_cart_bcia = p_tit_acr.cod_cart_bcia.
END PROCEDURE. /* pi_retornar_portador_tit_acr_na_epoca */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_espec_docto
** Descricao.............: pi_verifica_espec_docto
** Criado por............: Menna
** Criado em.............: 08/09/1998 09:29:53
** Alterado por..........: fut42929
** Alterado em...........: 24/08/2010 15:07:09
*****************************************************************************/
PROCEDURE pi_verifica_espec_docto:

    del_tt:
    for each tt_espec_docto exclusive-lock:
        delete tt_espec_docto.
    end /* for del_tt */.

    ASSIGN v_cod_espec_docto_ini = "CF"
           v_cod_espec_docto_fim = "CV".

    espec_block:
    for each espec_docto fields (cod_espec_docto ind_tip_espec_docto) no-lock
        where espec_docto.cod_espec_docto >= v_cod_espec_docto_ini
        and   espec_docto.cod_espec_docto <= v_cod_espec_docto_fim:

        if  not can-find( first espec_docto_financ_acr no-lock
            where espec_docto_financ_acr.cod_espec_docto = espec_docto.cod_espec_docto ) then
            next espec_block.

        if  (espec_docto.ind_tip_espec_docto = "Previs∆o" /*l_previsao*/           and v_log_mostra_docto_acr_prev)
           or (espec_docto.ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/        and v_log_mostra_docto_acr_antecip)
           or (espec_docto.ind_tip_espec_docto = "Normal" /*l_normal*/             and v_log_mostra_docto_acr_normal)
           or (espec_docto.ind_tip_espec_docto = "Aviso DÇbito" /*l_aviso_debito*/       and v_log_mostra_docto_acr_aviso_db)
           &if defined(BF_FIN_CONTROL_CHEQUES) &then
           or (espec_docto.ind_tip_espec_docto = "Cheques Recebidos" /*l_cheques_recebidos*/  and (v_log_mostra_acr_cheq_recbdo or v_log_mostra_acr_cheq_devolv))
           &else
           or (espec_docto.ind_tip_espec_docto = "Cheques Recebidos" /*l_cheques_recebidos*/  and v_log_mostra_docto_acr_cheq)
           &endif
           or (espec_docto.ind_tip_espec_docto = "Terceiros" /*l_terceiros*/          and v_log_tip_espec_docto_terc and v_log_control_terc_acr)
           or (espec_docto.ind_tip_espec_docto = "Cheques Terceiros" /*l_cheq_terc*/          and v_log_tip_espec_docto_cheq_terc and v_log_control_terc_acr)
           or (espec_docto.ind_tip_espec_docto = "Vendor" /*l_vendor*/             and v_log_mostra_docto_vendor)       
           or (espec_docto.ind_tip_espec_docto = "Vendor Repactuado" /*l_vendor_repac*/       and v_log_mostra_docto_vendor_repac)
        then do:

           create tt_espec_docto.
           assign tt_espec_docto.tta_cod_espec_docto = espec_docto.cod_espec_docto.
        end /* if */.
    end /* for espec_block */.

END PROCEDURE. /* pi_verifica_espec_docto */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_movtos_tit_acr_em_aberto
** Descricao.............: pi_verifica_movtos_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 02/01/1997 16:49:44
** Alterado por..........: fut43120
** Alterado em...........: 02/07/2013 11:11:39
*****************************************************************************/
PROCEDURE pi_verifica_movtos_tit_acr_em_aberto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_dat_tit_acr_aber
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer btt_titulos_em_aberto_acr
        for tt_titulos_em_aberto_acr.
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_avo
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr_pai
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_val_tit_acr
        for val_tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_val_unid_negoc
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_cod_estab                      as character       no-undo. /*local*/
    def var v_log_liq_perda                  as logical         no-undo. /*local*/
    def var v_num_id_movto_tit_acr           as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* ** IMPORTANTE: AS PIs ABAIXO DEVEM SER MANTIDAS EM SINCRONIA (Barth)
    *
    *    pi_verifica_movtos_tit_acr           (RAZAO)
    *    pi_verifica_movtos_tit_acr_em_aberto (TIT ABERTO)
    *    pi_sit_acr_acessar_movto_tit_acr     (SITUACAO ACR)
    */

    /* ** TRATAMENTO PARA MOVIMENTO DE LIQUIDAÄ«O PERDA DEDUTIVEL / ESTORNO DE TITULO ***/
    /* ** DETALHE: ESTES MOVIMENTOS N«O T“M VAL_MOVTO_TIT_ACR.           (Barth) ***/
    find first b_movto_tit_acr_pai
        where b_movto_tit_acr_pai.cod_estab         = tit_acr.cod_estab
        and   b_movto_tit_acr_pai.num_id_tit_acr    = tit_acr.num_id_tit_acr
        and   b_movto_tit_acr_pai.dat_transacao    <= p_dat_tit_acr_aber
        and   b_movto_tit_acr_pai.log_movto_estordo = no
        and  (b_movto_tit_acr_pai.ind_trans_acr     = "Liquidaá∆o Perda Dedut°vel" /*l_liquidacao_perda_dedutivel*/ 
        or    b_movto_tit_acr_pai.ind_trans_acr     = "Estorno de T°tulo" /*l_estorno_de_titulo*/ )
        use-index mvtttcr_id no-lock no-error.
    if  avail b_movto_tit_acr_pai then do:
        assign v_log_liq_perda = yes.
        for each btt_titulos_em_aberto_acr
            where btt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
            and   btt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr:
            assign btt_titulos_em_aberto_acr.tta_val_sdo_tit_acr       = 0
                   btt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = 0.
        end.
    end.


    /* ** VOLTA O SALDO DO T÷TULO, DE ACORDO COM OS MOVTOS POSTERIORES A DATA DE CORTE ***/
    movto_block:
    for each movto_tit_acr no-lock
        where movto_tit_acr.cod_estab      = tit_acr.cod_estab
        and   movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
        and   movto_tit_acr.dat_transacao  > p_dat_tit_acr_aber:

        if  (v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
        and movto_tit_acr.ind_trans_acr  = "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/ )
        or  movto_tit_acr.ind_trans_acr  = "Alteraá∆o Data Vencimento" /*l_alteracao_data_vencimento*/ 
        or  movto_tit_acr.ind_trans_acr  = "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/ 
        or  movto_tit_acr.ind_trans_acr  = "Implantaá∆o" /*l_implantacao*/ 
        or  movto_tit_acr.ind_trans_acr  = "Implantaá∆o a CrÇdito" /*l_implantacao_a_credito*/ 
        or  movto_tit_acr.ind_trans_acr  = "Transf Estabelecimento" /*l_transf_estabelecimento*/ 
        or  movto_tit_acr.ind_trans_acr  = "Renegociaá∆o" /*l_renegociacao*/ 
        or  movto_tit_acr.ind_trans_acr  = "Liquidaá∆o Perda Dedut°vel" /*l_liquidacao_perda_dedutivel*/ 
        or  movto_tit_acr.ind_trans_acr  = "Estorno de T°tulo" /*l_estorno_de_titulo*/  then
            next movto_block.

        /* ** LIQUIDAÄ«O AP‡S PERDA DEDUT÷VEL N«O CONTA, N«O DEVE VOLTAR SALDO ***/
        if  v_log_liq_perda = yes
        and &if '{&emsfin_version}' >= "5.04"
            &then movto_tit_acr.log_recuper_perda = yes
            &else movto_tit_acr.cod_livre_1       = 'yes'
            &endif then
            next movto_block.

        /* ** IGNORA ESTORNADOS QUE N«O CONTABILIZAM ***/
        if  v_log_tit_acr_estordo             = no
        and movto_tit_acr.log_ctbz_aprop_ctbl = no
        and (movto_tit_acr.ind_trans_acr      begins "Estorno" /*l_estorno*/ 
        or   movto_tit_acr.log_movto_estordo  = yes) then do:
            /* ** A LIQUIDAÄ«O DA ANTECIPAÄ«O NUNCA CONTABILIZA, VERIFICA A DA DUPLICATA (Barth) ***/
            if  tit_acr.ind_tip_espec_docto        = "Antecipaá∆o" /*l_antecipacao*/ 
            and (movto_tit_acr.ind_trans_acr_abrev = "ELIQ" /*l_eliq*/ 
            or   movto_tit_acr.ind_trans_acr_abrev = "LIQ" /*l_liq*/ ) then do:
                find b_movto_tit_acr_pai
                    where b_movto_tit_acr_pai.cod_estab            = movto_tit_acr.cod_estab_tit_acr_pai
                    and   b_movto_tit_acr_pai.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr_pai
                    no-lock no-error.
                if  movto_tit_acr.ind_trans_acr_abrev = "ELIQ" /*l_eliq*/  then do:
                    /* ** O PAI DO ESTORNO ê A LIQUIDAÄ«O. O PAI DA LIQUIDAÄ«O ê A LIQUIDAÄ«O DA DUPLICATA ***/
                    find b_movto_tit_acr_avo
                        where b_movto_tit_acr_avo.cod_estab            = b_movto_tit_acr_pai.cod_estab_tit_acr_pai
                        and   b_movto_tit_acr_avo.num_id_movto_tit_acr = b_movto_tit_acr_pai.num_id_movto_tit_acr_pai
                        no-lock no-error.
                    if  b_movto_tit_acr_avo.log_ctbz_aprop_ctbl = no then
                        next movto_block.
                end.
                else
                    if  b_movto_tit_acr_pai.log_ctbz_aprop_ctbl = no then
                        next movto_block.
            end.
            else
                next movto_block.
        end.

        if  movto_tit_acr.ind_trans_acr begins "Estorno" /*l_estorno*/  then do:
            assign v_num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr_pai
                   v_cod_estab            = movto_tit_acr.cod_estab_tit_acr_pai
                   v_num_multiplic        = -1. /* O estorno ser† subtra°do do saldo, por esse motivo o 
                                                   v_num_multiplic ser† multiplicado pela cotaá∆o */
        end.
        else do:
            assign v_num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr
                   v_cod_estab            = movto_tit_acr.cod_estab
                   v_num_multiplic        = 1.
        end.

        /* ** VOLTA ESTORNO DE PERDAS DEDUT÷VEIS (Barth) ***/
        if  movto_tit_acr.ind_trans_acr = "Estorno de Liquidacao" /*l_estorno_de_liquidacao*/ 
        and movto_tit_acr.dat_transacao <= p_dat_tit_acr_aber then do:
            find b_movto_tit_acr_pai
                where b_movto_tit_acr_pai.cod_estab            = movto_tit_acr.cod_estab_tit_acr_pai
                and   b_movto_tit_acr_pai.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr_pai
                no-lock no-error.
            if  avail b_movto_tit_acr_pai
            and b_movto_tit_acr_pai.ind_trans_acr = "Liquidaá∆o Perda Dedut°vel" /*l_liquidacao_perda_dedutivel*/  then do:
                if  b_movto_tit_acr_pai.dat_transacao <= p_dat_tit_acr_aber then do:
                    for each aprop_ctbl_acr no-lock
                        where aprop_ctbl_acr.cod_estab             = b_movto_tit_acr_pai.cod_estab
                        and   aprop_ctbl_acr.num_id_movto_tit_acr  = b_movto_tit_acr_pai.num_id_movto_tit_acr
                        and   aprop_ctbl_acr.cod_unid_negoc       >= v_cod_unid_negoc_ini
                        and   aprop_ctbl_acr.cod_unid_negoc       <= v_cod_unid_negoc_fim
                        and   aprop_ctbl_acr.ind_natur_lancto_ctbl = 'CR',
                        each val_aprop_ctbl_acr no-lock
                        where val_aprop_ctbl_acr.cod_estab             = aprop_ctbl_acr.cod_estab
                        and   val_aprop_ctbl_acr.num_id_aprop_ctbl_acr = aprop_ctbl_acr.num_id_aprop_ctbl_acr
                        and   val_aprop_ctbl_acr.cod_finalid_econ      = v_cod_finalid_econ:
                        find first tt_titulos_em_aberto_acr
                            where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                            and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr no-error.
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr - val_aprop_ctbl_acr.val_aprop_ctbl.
                               tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres - val_aprop_ctbl_acr.val_aprop_ctbl.
                    end.
                end.
                next movto_block.
            end.
        end.


        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:

             if  v_cod_finalid_econ <> v_cod_finalid_econ_aux
             or  v_cod_finalid_econ <> v_cod_finalid_econ_apres then do:
                /* CONVERTE E GRAVA O VALOR DO SALDO PARA A FINALIDADE DE APRESENTAÄ«O e BASE */
                val_block:
                for each val_movto_tit_acr no-lock
                    where val_movto_tit_acr.cod_estab            = v_cod_estab
                    and   val_movto_tit_acr.num_id_movto_tit_acr = v_num_id_movto_tit_acr
                    and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                    and   val_movto_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                    and   val_movto_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                    break by val_movto_tit_acr.cod_unid_negoc:


                    /* Begin_Include: i_recompoe_saldo_titulo_acr */
                    /* code_block: */
                    case movto_tit_acr.ind_trans_acr:
                        when "Acerto Valor a DÇbito" /*l_acerto_valor_a_debito*/         or
                        when "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/         or
                        when "Estorno Acerto Val DÇbito" /*l_estorno_acerto_val_debito*/         or
                        when "Estorno Acerto Val Maior" /*l_estorno_acerto_val_maior*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc - ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                        when "Acerto Valor a CrÇdito" /*l_acerto_valor_a_credito*/         or
                        when "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/         or
                        when "Estorno Acerto Val CrÇdito" /*l_estorno_acerto_val_credito*/         or
                        when "Estorno Acerto Val Menor" /*l_estorno_acerto_val_menor*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                        when "Liquidaá∆o" /*l_liquidacao*/         or
                        when "Devoluá∆o" /*l_devolucao*/         or
                        when "Liquidaá∆o Enctro Ctas" /*l_liquidacao_enctro_ctas*/         or
                        when "Estorno de Liquidacao" /*l_estorno_de_liquidacao*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc + ( ( val_movto_tit_acr.val_liquidac_tit_acr 
                                                             + val_movto_tit_acr.val_abat_tit_acr
                                                             + val_movto_tit_acr.val_desconto ) / (1 * v_num_multiplic) ).

                        when "Liquidaá∆o Renegociac" /*l_liquidacao_renegociac*/         or
                        when "Estorno Liquidacao Subst" /*l_estorno_liquidacao_subst*/         or
                        when "Estorno Liquid Renegociac" /*l_estorno_liquid_renegociac*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_saida_subst_nf_dupl / (1 * v_num_multiplic) ).

                        when "Liquidaá∆o Transf Estab" /*l_liquidacao_transf_estab*/         or
                        when "Estorno Liquid Transf Estab" /*l_estorno_liquid_transf_estab*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_transf_estab / (1 * v_num_multiplic) ).

                        when "Correá∆o de Valor" /*l_correcao_de_valor*/         or
                        when "Correá∆o Valor na Liquidac" /*l_correcao_valor_na_liquidac*/         or
                        when "Estorno Correá∆o Valor" /*l_estorno_correcao_valor*/         or
                        when "Estorno Correá∆o Val Liquidac" /*l_estorno_correcao_val_liquidac*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc - ( ( val_movto_tit_acr.val_variac_cambial
                                                             + val_movto_tit_acr.val_acerto_cmcac
                                                             + val_movto_tit_acr.val_ganho_perda_cm
                                                             + val_movto_tit_acr.val_ganho_perda_projec ) / (1 * v_num_multiplic) ).

                        when "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/         or
                        when "Estorno Transf Unid Negoc" /*l_estorno_transf_unid_negoc*/ then
                            assign v_val_unid_negoc = v_val_unid_negoc + ( ( val_movto_tit_acr.val_saida_transf_unid_negoc
                                                             - val_movto_tit_acr.val_entr_transf_unid_negoc ) / (1 * v_num_multiplic) ).
                    end /* case code_block */.
                    /* End_Include: i_recompoe_saldo_titulo_acr */


                    if  last-of(val_movto_tit_acr.cod_unid_negoc)
                    then do:
                        find first tt_titulos_em_aberto_acr
                             where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                             and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr 
                             and   tt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_movto_tit_acr.cod_unid_negoc 
                        no-error.
                        if  avail tt_titulos_em_aberto_acr then do:
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                                                                        + (v_val_unid_negoc / v_val_cotac_indic_econ)
                                   v_val_unid_negoc = 0.
                        end.       
                    end.
                end.
            end.

            /* GRAVA O VALOR ORIGINAL E SALDO DO T÷TULO NA FINALIDADE ORIGINAL */
            val_block:
            for each val_movto_tit_acr no-lock
                where val_movto_tit_acr.cod_estab            = v_cod_estab
                and   val_movto_tit_acr.num_id_movto_tit_acr = v_num_id_movto_tit_acr
                and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ_aux
                and   val_movto_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                and   val_movto_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                break by val_movto_tit_acr.cod_unid_negoc:


                /* Begin_Include: i_recompoe_saldo_titulo_acr */
                /* code_block: */
                case movto_tit_acr.ind_trans_acr:
                    when "Acerto Valor a DÇbito" /*l_acerto_valor_a_debito*/         or
                    when "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/         or
                    when "Estorno Acerto Val DÇbito" /*l_estorno_acerto_val_debito*/         or
                    when "Estorno Acerto Val Maior" /*l_estorno_acerto_val_maior*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc - ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                    when "Acerto Valor a CrÇdito" /*l_acerto_valor_a_credito*/         or
                    when "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/         or
                    when "Estorno Acerto Val CrÇdito" /*l_estorno_acerto_val_credito*/         or
                    when "Estorno Acerto Val Menor" /*l_estorno_acerto_val_menor*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o" /*l_liquidacao*/         or
                    when "Devoluá∆o" /*l_devolucao*/         or
                    when "Liquidaá∆o Enctro Ctas" /*l_liquidacao_enctro_ctas*/         or
                    when "Estorno de Liquidacao" /*l_estorno_de_liquidacao*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc + ( ( val_movto_tit_acr.val_liquidac_tit_acr 
                                                         + val_movto_tit_acr.val_abat_tit_acr
                                                         + val_movto_tit_acr.val_desconto ) / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o Renegociac" /*l_liquidacao_renegociac*/         or
                    when "Estorno Liquidacao Subst" /*l_estorno_liquidacao_subst*/         or
                    when "Estorno Liquid Renegociac" /*l_estorno_liquid_renegociac*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_saida_subst_nf_dupl / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o Transf Estab" /*l_liquidacao_transf_estab*/         or
                    when "Estorno Liquid Transf Estab" /*l_estorno_liquid_transf_estab*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc + ( val_movto_tit_acr.val_transf_estab / (1 * v_num_multiplic) ).

                    when "Correá∆o de Valor" /*l_correcao_de_valor*/         or
                    when "Correá∆o Valor na Liquidac" /*l_correcao_valor_na_liquidac*/         or
                    when "Estorno Correá∆o Valor" /*l_estorno_correcao_valor*/         or
                    when "Estorno Correá∆o Val Liquidac" /*l_estorno_correcao_val_liquidac*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc - ( ( val_movto_tit_acr.val_variac_cambial
                                                         + val_movto_tit_acr.val_acerto_cmcac
                                                         + val_movto_tit_acr.val_ganho_perda_cm
                                                         + val_movto_tit_acr.val_ganho_perda_projec ) / (1 * v_num_multiplic) ).

                    when "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/         or
                    when "Estorno Transf Unid Negoc" /*l_estorno_transf_unid_negoc*/ then
                        assign v_val_unid_negoc = v_val_unid_negoc + ( ( val_movto_tit_acr.val_saida_transf_unid_negoc
                                                         - val_movto_tit_acr.val_entr_transf_unid_negoc ) / (1 * v_num_multiplic) ).
                end /* case code_block */.
                /* End_Include: i_recompoe_saldo_titulo_acr */


                if  last-of(val_movto_tit_acr.cod_unid_negoc)
                then do:
                    find first tt_titulos_em_aberto_acr
                         where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                         and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr 
                         and   tt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_movto_tit_acr.cod_unid_negoc 
                    no-error.
                    if  avail tt_titulos_em_aberto_acr then do:     
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr
                                                                        + v_val_unid_negoc.                                                                      
                        if  v_cod_finalid_econ = v_cod_finalid_econ_aux
                        and v_cod_finalid_econ = v_cod_finalid_econ_apres then do:
                             assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr.
                        end.

                        assign v_val_unid_negoc = 0.
                    end.
                end.
            end.
        end.
        else do:
            find first tt_titulos_em_aberto_acr
                 where tt_titulos_em_aberto_acr.tta_cod_estab       = tit_acr.cod_estab
                 and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr  = tit_acr.num_id_tit_acr no-error.

            if  v_cod_finalid_econ <> v_cod_finalid_econ_aux
            or  v_cod_finalid_econ <> v_cod_finalid_econ_apres then do:
                /* CONVERTE E GRAVA O VALOR DO SALDO PARA A FINALIDADE DE APRESENTAÄ«O e BASE*/
                val_block:
                for each val_movto_tit_acr no-lock
                    where val_movto_tit_acr.cod_estab            = v_cod_estab
                    and   val_movto_tit_acr.num_id_movto_tit_acr = v_num_id_movto_tit_acr
                    and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ:


                    /* Begin_Include: i_recompoe_saldo_titulo_acr */
                    /* code_block: */
                    case movto_tit_acr.ind_trans_acr:
                        when "Acerto Valor a DÇbito" /*l_acerto_valor_a_debito*/         or
                        when "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/         or
                        when "Estorno Acerto Val DÇbito" /*l_estorno_acerto_val_debito*/         or
                        when "Estorno Acerto Val Maior" /*l_estorno_acerto_val_maior*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres - ( val_movto_tit_acr.val_ajust_val_tit_acr / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Acerto Valor a CrÇdito" /*l_acerto_valor_a_credito*/         or
                        when "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/         or
                        when "Estorno Acerto Val CrÇdito" /*l_estorno_acerto_val_credito*/         or
                        when "Estorno Acerto Val Menor" /*l_estorno_acerto_val_menor*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres + ( val_movto_tit_acr.val_ajust_val_tit_acr / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Liquidaá∆o" /*l_liquidacao*/         or
                        when "Devoluá∆o" /*l_devolucao*/         or
                        when "Liquidaá∆o Enctro Ctas" /*l_liquidacao_enctro_ctas*/         or
                        when "Estorno de Liquidacao" /*l_estorno_de_liquidacao*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres + ( ( val_movto_tit_acr.val_liquidac_tit_acr 
                                                             + val_movto_tit_acr.val_abat_tit_acr
                                                             + val_movto_tit_acr.val_desconto ) / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Liquidaá∆o Renegociac" /*l_liquidacao_renegociac*/         or
                        when "Estorno Liquidacao Subst" /*l_estorno_liquidacao_subst*/         or
                        when "Estorno Liquid Renegociac" /*l_estorno_liquid_renegociac*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres + ( val_movto_tit_acr.val_saida_subst_nf_dupl / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Liquidaá∆o Transf Estab" /*l_liquidacao_transf_estab*/         or
                        when "Estorno Liquid Transf Estab" /*l_estorno_liquid_transf_estab*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres + ( val_movto_tit_acr.val_transf_estab / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Correá∆o de Valor" /*l_correcao_de_valor*/         or
                        when "Correá∆o Valor na Liquidac" /*l_correcao_valor_na_liquidac*/         or
                        when "Estorno Correá∆o Valor" /*l_estorno_correcao_valor*/         or
                        when "Estorno Correá∆o Val Liquidac" /*l_estorno_correcao_val_liquidac*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres - ( ( val_movto_tit_acr.val_variac_cambial
                                                             + val_movto_tit_acr.val_acerto_cmcac
                                                             + val_movto_tit_acr.val_ganho_perda_cm
                                                             + val_movto_tit_acr.val_ganho_perda_projec ) / (v_val_cotac_indic_econ * v_num_multiplic) ).

                        when "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/         or
                        when "Estorno Transf Unid Negoc" /*l_estorno_transf_unid_negoc*/ then
                            assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres + ( ( val_movto_tit_acr.val_saida_transf_unid_negoc
                                                             - val_movto_tit_acr.val_entr_transf_unid_negoc ) / (v_val_cotac_indic_econ * v_num_multiplic) ).
                    end /* case code_block */.
                    /* End_Include: i_recompoe_saldo_titulo_acr */

                end /* for val_block */.
            end /* if */.

            /* GRAVA O VALOR ORIGINAL E SALDO DO T÷TULO NA FINALIDADE ORIGINAL */
            val_block:
            for each val_movto_tit_acr no-lock
                where val_movto_tit_acr.cod_estab            = v_cod_estab
                and   val_movto_tit_acr.num_id_movto_tit_acr = v_num_id_movto_tit_acr
                and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ_aux:


                /* Begin_Include: i_recompoe_saldo_titulo_acr */
                /* code_block: */
                case movto_tit_acr.ind_trans_acr:
                    when "Acerto Valor a DÇbito" /*l_acerto_valor_a_debito*/         or
                    when "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/         or
                    when "Estorno Acerto Val DÇbito" /*l_estorno_acerto_val_debito*/         or
                    when "Estorno Acerto Val Maior" /*l_estorno_acerto_val_maior*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr - ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                    when "Acerto Valor a CrÇdito" /*l_acerto_valor_a_credito*/         or
                    when "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/         or
                    when "Estorno Acerto Val CrÇdito" /*l_estorno_acerto_val_credito*/         or
                    when "Estorno Acerto Val Menor" /*l_estorno_acerto_val_menor*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + ( val_movto_tit_acr.val_ajust_val_tit_acr / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o" /*l_liquidacao*/         or
                    when "Devoluá∆o" /*l_devolucao*/         or
                    when "Liquidaá∆o Enctro Ctas" /*l_liquidacao_enctro_ctas*/         or
                    when "Estorno de Liquidacao" /*l_estorno_de_liquidacao*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + ( ( val_movto_tit_acr.val_liquidac_tit_acr 
                                                         + val_movto_tit_acr.val_abat_tit_acr
                                                         + val_movto_tit_acr.val_desconto ) / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o Renegociac" /*l_liquidacao_renegociac*/         or
                    when "Estorno Liquidacao Subst" /*l_estorno_liquidacao_subst*/         or
                    when "Estorno Liquid Renegociac" /*l_estorno_liquid_renegociac*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + ( val_movto_tit_acr.val_saida_subst_nf_dupl / (1 * v_num_multiplic) ).

                    when "Liquidaá∆o Transf Estab" /*l_liquidacao_transf_estab*/         or
                    when "Estorno Liquid Transf Estab" /*l_estorno_liquid_transf_estab*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + ( val_movto_tit_acr.val_transf_estab / (1 * v_num_multiplic) ).

                    when "Correá∆o de Valor" /*l_correcao_de_valor*/         or
                    when "Correá∆o Valor na Liquidac" /*l_correcao_valor_na_liquidac*/         or
                    when "Estorno Correá∆o Valor" /*l_estorno_correcao_valor*/         or
                    when "Estorno Correá∆o Val Liquidac" /*l_estorno_correcao_val_liquidac*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr - ( ( val_movto_tit_acr.val_variac_cambial
                                                         + val_movto_tit_acr.val_acerto_cmcac
                                                         + val_movto_tit_acr.val_ganho_perda_cm
                                                         + val_movto_tit_acr.val_ganho_perda_projec ) / (1 * v_num_multiplic) ).

                    when "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/         or
                    when "Estorno Transf Unid Negoc" /*l_estorno_transf_unid_negoc*/ then
                        assign tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr + ( ( val_movto_tit_acr.val_saida_transf_unid_negoc
                                                         - val_movto_tit_acr.val_entr_transf_unid_negoc ) / (1 * v_num_multiplic) ).
                end /* case code_block */.
                /* End_Include: i_recompoe_saldo_titulo_acr */


                if  v_cod_finalid_econ = v_cod_finalid_econ_aux
                and v_cod_finalid_econ = v_cod_finalid_econ_apres then do:
                    assign tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres = tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr.
                end.
            end.
        end.
    end.

END PROCEDURE. /* pi_verifica_movtos_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_calcular_pmr_amr_tit_acr_em_aberto
** Descricao.............: pi_calcular_pmr_amr_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 09/01/1997 19:01:04
** Alterado por..........: fut40711
** Alterado em...........: 23/12/2009 14:59:31
*****************************************************************************/
PROCEDURE pi_calcular_pmr_amr_tit_acr_em_aberto:

    /************************* Variable Definition Begin ************************/

    def var v_cod_refer_contrat_cambio
        as character
        format "x(10)":U
        no-undo.
    def var v_val_unid_negoc
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.


    /************************** Variable Definition End *************************/

    if  (tit_acr.ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/  and v_log_localiz_arg = no)
    or  tit_acr.ind_tip_espec_docto = "Nota de CrÇdito" /*l_nota_de_credito*/ 
    then do:
        return.
    end /* if */.

    movto_block:
    for each movto_tit_acr no-lock
        where movto_tit_acr.cod_estab         = tit_acr.cod_estab
        and   movto_tit_acr.num_id_tit_acr    = tit_acr.num_id_tit_acr
        and   (movto_tit_acr.ind_trans_acr     = "Liquidaá∆o" /*l_liquidacao*/ 
               &if defined(BF_FIN_LIQ_CAMBIO_ESTAT_CLI) &then
                   or movto_tit_acr.ind_trans_acr  = "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/ 
               &endif
                   or (v_log_localiz_arg and movto_tit_acr.ind_trans_acr = "Implantaá∆o" /*l_implantacao*/  and tit_acr.ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ )
               )
        and   movto_tit_acr.dat_transacao    <= v_dat_tit_acr_aber
        and   movto_tit_acr.log_movto_estordo = no:

        &if '{&emsfin_version}' >= '5.06' &then
            assign v_cod_refer_contrat_cambio = movto_tit_acr.cod_refer_contrat_cambio.
        &else
            assign v_cod_refer_contrat_cambio = getEntryField(6, movto_tit_acr.cod_livre_1, chr(24)).
        &endif

        &if defined(BF_FIN_LIQ_CAMBIO_ESTAT_CLI) &then
            if movto_tit_acr.ind_trans_acr_abrev = "AVMN" /*l_avmn*/  
            and not (v_cod_refer_contrat_cambio <> ' '
                     and movto_tit_acr.ind_motiv_acerto_val = "Liquidaá∆o" /*l_liquidacao*/ ) then
                next movto_block.
        &endif

        if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        then do:
            if tit_acr.ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/  then do:
                /* CONVERTE E GRAVA O VALOR DO SALDO PARA A FINALIDADE DE APRESENTAÄ«O */
                val_block:
                for each val_movto_tit_acr no-lock
                    where val_movto_tit_acr.cod_estab            = movto_tit_acr.cod_estab
                    and   val_movto_tit_acr.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr
                    and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ
                    and   val_movto_tit_acr.cod_unid_negoc      >= v_cod_unid_negoc_ini
                    and   val_movto_tit_acr.cod_unid_negoc      <= v_cod_unid_negoc_fim
                    break by val_movto_tit_acr.cod_unid_negoc:

                    assign v_val_unid_negoc = v_val_unid_negoc + val_movto_tit_acr.val_liquidac_tit_acr.

                    if  last-of(val_movto_tit_acr.cod_unid_negoc)
                    then do:
                        find first tt_titulos_em_aberto_acr exclusive-lock
                             where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                             and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                             and   tt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_movto_tit_acr.cod_unid_negoc no-error.
                        if  avail tt_titulos_em_aberto_acr then do:
                            assign tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = (movto_tit_acr.dat_cr_movto_tit_acr - tit_acr.dat_emis_docto) * v_val_unid_negoc
                                   tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = (movto_tit_acr.dat_liquidac_tit_acr - tit_acr.dat_vencto_tit_acr) * v_val_unid_negoc
                                   tt_titulos_em_aberto_acr.tta_val_movto_tit_acr     = v_val_unid_negoc
                                   v_val_unid_negoc = 0.
                        end.
                    end /* if */.
                end /* for val_block */.
            end.
            else do:
                for each val_tit_acr no-lock
                    where val_tit_acr.cod_estab = tit_acr.cod_estab
                      and val_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
                      and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ
                      and val_tit_acr.cod_unid_negoc   >= v_cod_unid_negoc_ini
                      and val_tit_acr.cod_unid_negoc   <= v_cod_unid_negoc_fim
                      break by val_tit_acr.cod_unid_negoc: 

                      assign v_val_unid_negoc = v_val_unid_negoc + val_tit_acr.val_sdo_tit_acr.

                      if  last-of(val_tit_acr.cod_unid_negoc)
                      then do:
                          find first tt_titulos_em_aberto_acr exclusive-lock
                               where tt_titulos_em_aberto_acr.tta_cod_estab      = tit_acr.cod_estab
                               and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr = tit_acr.num_id_tit_acr
                               and   tt_titulos_em_aberto_acr.tta_cod_unid_negoc = val_tit_acr.cod_unid_negoc no-error.
                          if  avail tt_titulos_em_aberto_acr then do:
                              assign tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = ((v_dat_tit_acr_aber - tit_acr.dat_transacao) * v_val_unid_negoc) * (-1)
                                     tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = ((v_dat_tit_acr_aber - tit_acr.dat_transacao) * v_val_unid_negoc) * (-1)
                                     tt_titulos_em_aberto_acr.tta_val_movto_tit_acr     = (v_val_unid_negoc * -1)
                                     v_val_unid_negoc = 0.
                          end.
                      end /* if */.                  
                end.
            end.
        end /* if */.
        else do:
            find first tt_titulos_em_aberto_acr exclusive-lock
                 where tt_titulos_em_aberto_acr.tta_cod_estab       = tit_acr.cod_estab
                 and   tt_titulos_em_aberto_acr.tta_num_id_tit_acr  = tit_acr.num_id_tit_acr no-error.

            if tit_acr.ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/  then do:
                /* CONVERTE E GRAVA O VALOR DO SALDO PARA A FINALIDADE DE APRESENTAÄ«O */
                val_block:
                for each val_movto_tit_acr no-lock
                    where val_movto_tit_acr.cod_estab            = movto_tit_acr.cod_estab
                    and   val_movto_tit_acr.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr
                    and   val_movto_tit_acr.cod_finalid_econ     = v_cod_finalid_econ:

                        assign tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr
                                                                                  + (movto_tit_acr.dat_cr_movto_tit_acr - tit_acr.dat_emis_docto) * val_movto_tit_acr.val_liquidac_tit_acr
                               tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr
                                                                                  + (movto_tit_acr.dat_liquidac_tit_acr - tit_acr.dat_vencto_tit_acr) * val_movto_tit_acr.val_liquidac_tit_acr
                               tt_titulos_em_aberto_acr.tta_val_movto_tit_acr     = tt_titulos_em_aberto_acr.tta_val_movto_tit_acr + val_movto_tit_acr.val_liquidac_tit_acr.
                end /* for val_block */.
            end.
            else do:
                for each val_tit_acr no-lock
                    where val_tit_acr.cod_estab = tit_acr.cod_estab
                      and val_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
                      and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ: 

                      assign tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr = (tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr
                                                                                  + (v_dat_tit_acr_aber - tit_acr.dat_transacao) * val_tit_acr.val_sdo_tit_acr) * -1
                               tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr = (tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr
                                                                                  + (v_dat_tit_acr_aber - tit_acr.dat_transacao) * val_tit_acr.val_sdo_tit_acr) * -1
                               tt_titulos_em_aberto_acr.tta_val_movto_tit_acr     = (tt_titulos_em_aberto_acr.tta_val_movto_tit_acr + val_tit_acr.val_sdo_tit_acr) * -1.
                end.
            end.
        end /* else */.
    end /* for movto_block */.
END PROCEDURE. /* pi_calcular_pmr_amr_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_classifica_tit_acr_em_aberto
** Descricao.............: pi_classifica_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 02/01/1997 13:48:17
** Alterado por..........: fut43120
** Alterado em...........: 21/06/2013 14:03:56
*****************************************************************************/
PROCEDURE pi_classifica_tit_acr_em_aberto:

    if  v_log_classif_estab
    then do:
        assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1] = tt_titulos_em_aberto_acr.tta_cod_estab.
        if v_log_classif_un then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2] = tt_titulos_em_aberto_acr.tta_cod_unid_negoc.
    end /* if */.
    else do:
        if v_log_classif_un then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1] = tt_titulos_em_aberto_acr.tta_cod_unid_negoc.
    end.

    if v_ind_classif_tit_acr_em_aber = "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then do:
        if can-find (first cta_grp_clien no-lock where cta_grp_clien.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa
                and cta_grp_clien.cod_espec_docto = tt_titulos_em_aberto_acr.tta_cod_espec_docto
                and cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/    
                and cta_grp_clien.cod_grp_clien = tt_titulos_em_aberto_acr.tta_cod_grp_clien
                and cta_grp_clien.cod_finalid_econ = v_cod_finalid_econ_aux
                and cta_grp_clien.ind_finalid_ctbl = "Saldo" /*l_saldo*/    
                and cta_grp_clien.dat_inic_valid <= v_dat_tit_acr_aber
                and cta_grp_clien.dat_fim_valid >= v_dat_tit_acr_aber) 
                or 
                can-find (first cta_grp_clien no-lock where cta_grp_clien.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa
                    and cta_grp_clien.cod_espec_docto = ""
                    and cta_grp_clien.ind_tip_espec_docto = tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto
                    and cta_grp_clien.cod_grp_clien = tt_titulos_em_aberto_acr.tta_cod_grp_clien
                    and cta_grp_clien.cod_finalid_econ = v_cod_finalid_econ_aux
                    and cta_grp_clien.ind_finalid_ctbl = "Saldo" /*l_saldo*/    
                    and cta_grp_clien.dat_inic_valid <= v_dat_tit_acr_aber
                    and cta_grp_clien.dat_fim_valid >= v_dat_tit_acr_aber) then do:

           find first cta_grp_clien no-lock
               where cta_grp_clien.cod_empresa          = tt_titulos_em_aberto_acr.tta_cod_empresa
                   and cta_grp_clien.cod_espec_docto     = tt_titulos_em_aberto_acr.tta_cod_espec_docto
                   and cta_grp_clien.ind_tip_espec_docto = "Nenhum" /*l_nenhum*/   
                   and cta_grp_clien.cod_grp_clien      = tt_titulos_em_aberto_acr.tta_cod_grp_clien
                   and cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ_aux
                   and cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/   
                   and cta_grp_clien.dat_inic_valid     <= v_dat_tit_acr_aber
                   and cta_grp_clien.dat_fim_valid      >= v_dat_tit_acr_aber  no-error.
           if not avail cta_grp_clien then do:
               find first cta_grp_clien
                   where cta_grp_clien.cod_empresa         = tt_titulos_em_aberto_acr.tta_cod_empresa
                         and cta_grp_clien.cod_espec_docto     = ""
                         and cta_grp_clien.ind_tip_espec_docto = tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto
                         and cta_grp_clien.cod_grp_clien       = tt_titulos_em_aberto_acr.tta_cod_grp_clien
                         and cta_grp_clien.cod_finalid_econ    = v_cod_finalid_econ_aux
                         and cta_grp_clien.ind_finalid_ctbl    = "Saldo" /*l_saldo*/   
                         and cta_grp_clien.dat_inic_valid     <= v_dat_tit_acr_aber
                         and cta_grp_clien.dat_fim_valid      >= v_dat_tit_acr_aber no-lock no-error.
            end.
            if cta_grp_clien.cod_plano_cta_ctbl < v_cod_plano_cta_ctbl_inic
                or cta_grp_clien.cod_plano_cta_ctbl > v_cod_plano_cta_ctbl_final
                or cta_grp_clien.cod_cta_ctbl       < v_cod_cta_ctbl_ini
                or cta_grp_clien.cod_cta_ctbl       > v_cod_cta_ctbl_final then do:

                    run pi_valida_erro_cta_grp_clien.

                    delete tt_titulos_em_aberto_acr.  
                    return "NOK" /*l_nok*/ .
            end.
        end.    
        else do:

            run pi_valida_erro_cta_grp_clien.

            delete tt_titulos_em_aberto_acr.  
            return "NOK" /*l_nok*/ .       
        end.
    end.

    /* class_block: */
    case v_ind_classif_tit_acr_em_aber:
        when "Por Representante/Cliente" /*l_por_representantecliente*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.tta_cdn_repres, ">>>,>>9":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(tt_titulos_em_aberto_acr.tta_cdn_cliente, ">>>,>>>,>>9":U).

        when "Por Portador/Carteira" /*l_por_portadorcarteira*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = tt_titulos_em_aberto_acr.tta_cod_portador
                                                                                 + tt_titulos_em_aberto_acr.tta_cod_cart_bcia
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(year(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"9999") +
                                                                                   string(month(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99") +
                                                                                   string(day(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99").

        when "Por Cliente/Vencimento" /*l_por_clientevencimento*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.tta_cdn_cliente, ">>>,>>>,>>9":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(year(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"9999") +
                                                                                   string(month(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99") +
                                                                                   string(day(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99").

        when "Por Nome Cliente/Vencimento" /*l_por_nome_clientevencimento*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(cliente.nom_pessoa + v_cod_carac_lim + string(cliente.cdn_cliente, ">>>,>>>,>>9":U))
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(year(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"9999") +
                                                                                   string(month(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99") +
                                                                                   string(day(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99").

        when "Por Vencimento/Nome Cliente" /*l_por_vencimentonome_cliente*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(year(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"9999") +
                                                                                   string(month(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99") +
                                                                                   string(day(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99")
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_titulos_em_aberto_acr.ttv_nom_abrev_clien.

        when "Por Matriz" /*l_por_matriz*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.tta_cdn_clien_matriz, ">>>,>>>,>>9":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_titulos_em_aberto_acr.ttv_nom_abrev_clien.

        when "Por Grupo Cliente/Cliente" /*l_por_grupo_clientecliente*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(cliente.cod_grp_clien, "x(4)":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(tt_titulos_em_aberto_acr.tta_cdn_cliente, ">>>,>>>,>>9":U).

        when "Por Condiá∆o Cobranáa/Cliente" /*l_por_condcobranca_cliente*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.tta_cod_cond_cobr, "x(8)":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(tt_titulos_em_aberto_acr.tta_cdn_cliente, ">>>,>>>,>>9":U).

        when "Por EspÇcie/Vencto/Nome Cliente" /*l_por_espec_Vencto_nomcli*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.tta_cod_espec_docto, "x(3)":U)
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(year(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"9999") +
                                                                                   string(month(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99") +
                                                                                   string(day(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr),"99")
                   tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3] = string(cliente.nom_pessoa + v_cod_carac_lim + string(cliente.cdn_cliente, ">>>,>>>,>>9":U)).
        when "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/ then
            assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_titulos_em_aberto_acr.ttv_cod_proces_export, "x(12)":U).
        when "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/ then
                assign tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1]    = cta_grp_clien.cod_cta_ctbl
                       tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2]    = tt_titulos_em_aberto_acr.tta_cod_espec_docto
                       tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3]    = string(tt_titulos_em_aberto_acr.tta_cod_grp_clien, "x(04)" /*l_x(4)*/ )
                       tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 4]    = string(tt_titulos_em_aberto_acr.tta_cdn_cliente, '>>>,>>>,>>9':U).
    end /* case class_block */.

    if  v_ind_dwb_run_mode = "Batch" /*l_batch*/ 
    then do:
        assign v_cod_ult_obj_procesdo = tit_acr.cod_estab + "," + tit_acr.cod_espec_docto + "," +
                                        tit_acr.cod_ser_docto + "," + tit_acr.cod_tit_acr + "," + tit_acr.cod_parcela.
        run prgtec/btb/btb908ze.py (Input 1,
                                    Input v_cod_ult_obj_procesdo) /*prg_api_atualizar_ult_obj*/.
    end /* if */.

    return "OK" /*l_ok*/ .

END PROCEDURE. /* pi_classifica_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_rpt_tit_acr_em_aberto
** Descricao.............: pi_rpt_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 24/12/1996 09:04:32
** Alterado por..........: fut43120
** Alterado em...........: 03/06/2013 11:20:38
*****************************************************************************/
PROCEDURE pi_rpt_tit_acr_em_aberto:

    /************************* Variable Definition Begin ************************/

    def var v_cod_lista_label
        as character
        format "x(300)":U
        no-undo.
    def var v_val_tot_calc_amr
        as decimal
        format "->>>,>>>,>>>,>>9.99":U
        decimals 2
        extent 6
        label "Total C†lculo AMR"
        column-label "Total C†lculo AMR"
        no-undo.
    def var v_val_tot_calc_movto
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        extent 6
        label "Total Calc Movto"
        column-label "Total Calc Movto"
        no-undo.
    def var v_val_tot_calc_pmr
        as decimal
        format "->>>>,>>>,>>>,>>9.99":U
        decimals 2
        extent 6
        label "Total C†lculo PMR"
        column-label "Total C†lculo PMR"
        no-undo.
    def var v_log_lin_cabec                  as logical         no-undo. /*local*/
    def var v_log_lin_rodap                  as logical         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* OBS.: O VALOR ORIGINAL DE APRESENTAÄ«O CONTINUA SENDO CALCULADO,
    ELE APENAS DEIXOU DE SER IMPRESSO NO RESUMO DOS PRAZOS */
    assign v_num_idx = 0.

    if v_log_classif_estab then
       assign v_num_idx = v_num_idx + 1.
    if v_log_classif_un then
       assign v_num_idx = v_num_idx + 1.

    &IF integer(entry(1,proversion,".")) >= 9 &THEN
       empty temp-table tt_titulos_em_aberto_acr no-error.
       empty temp-table tt_titulos_em_aberto_acr_compl no-error.
    &ELSE
       for each tt_titulos_em_aberto_acr:
           delete tt_titulos_em_aberto_acr.
       end.
       for each tt_titulos_em_aberto_acr_compl:
           delete tt_titulos_em_aberto_acr_compl.
       end.
    &ENDIF
       for each tt_retorna_sdo_ctbl_demonst:
           delete tt_retorna_sdo_ctbl_demonst.
       end.
       for each tt_log_erros_aux:
           delete tt_log_erros_aux.
       end.
       for each tt_resumo_conta:
           delete tt_resumo_conta.
       end.
       for each tt_resumo_conta_estab_acr:
           delete tt_resumo_conta_estab_acr.
       end.
       for each tt_log_erros:
           delete tt_log_erros.
       end.
       for each tt_input_sdo:
           delete tt_input_sdo.
       end.
       for each tt_input_leitura_sdo_demonst:
           delete tt_input_leitura_sdo_demonst.
       end.
       for each tt_log_erros:
           delete tt_log_erros.
       end.
       for each tt_proj_financ_demonst:
           delete tt_proj_financ_demonst.
       end.
       for each tt_ccustos_demonst:
           delete tt_ccustos_demonst.
       end.
       for each tt_cta_ctbl_demonst:
           delete tt_cta_ctbl_demonst.
       end.
       for each tt_item_demonst_ctbl_video:
           delete tt_item_demonst_ctbl_video.
       end.
       for each tt_proj_financ_demonst:
           delete tt_proj_financ_demonst.
       end.
       for each tt_relacto_item_retorna:
           delete tt_relacto_item_retorna.
       end.
       for each tt_relacto_item_retorna_cons:
           delete tt_relacto_item_retorna_cons.
       end.
       for each tt_retorna_sdo_orcto_ccusto:
           delete tt_retorna_sdo_orcto_ccusto.
       end.
       for each tt_unid_negocio:
           delete tt_unid_negocio.
       end.
    run pi_verifica_espec_docto /*pi_verifica_espec_docto*/.
    run pi_verifica_tit_acr_em_aberto (Input 41,
                                       Input v_dat_tit_acr_aber) /*pi_verifica_tit_acr_em_aberto*/.

    hide stream s_1 frame f_rpt_s_1_header_period.
    view stream s_1 frame f_rpt_s_1_header_unique.
    hide stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_normal.
    /* PLANILHA */
    if  v_log_gerac_planilha = yes then
       run pi_rpt_aberto_gerac_planilha (Input "Ini" /*l_INI*/) /*pi_rpt_aberto_gerac_planilha*/.
    /* IMPRESS«O ANAL÷TICA DOS T÷TULOS EM ABERTO */
    if  v_log_visualiz_analit = yes
    then do:
       assign v_log_lin_cabec = yes
              v_log_lin_rodap = yes
              v_val_tot_sdo_acr = 0
              v_val_tot_calc_movto = 0
              v_val_tot_calc_amr = 0
              v_val_tot_calc_pmr = 0.

       if v_log_nao_impr_tit = no then do:
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_aging_acr.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_branco.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_cab_resumo.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_cliente.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_cond_cobr.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_conta.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_empresa.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_espec_docto.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_estab.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_grp_clien.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_matriz.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_port_cart.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_Processo.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_repres.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_un.
           hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_vencto.
           view stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_moedas.
           run pi_tratar_layout_tit_acr_em_aberto (Input "view" /*l_view*/) /*pi_tratar_layout_tit_acr_em_aberto*/.
       end.

       if num-entries(v_cod_order_rpt) = 3 then
          assign v_cod_order_rpt = v_cod_order_rpt + ', '.
       if num-entries(v_cod_order_rpt) = 4 then
          assign v_cod_order_rpt = v_cod_order_rpt + ', '.
       if num-entries(v_cod_order_rpt) = 5 then
          assign v_cod_order_rpt = v_cod_order_rpt + ', '.

       assign v_val_sdo_apres_acum = 0.
       grp_block:
       for each tt_titulos_em_aberto_acr exclusive-lock
           where tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres <> 0.00
             AND tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
             AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
           break by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1]
                 by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]
                 by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[3]
                 by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[4]
                 by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[5]
                 by tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[6]:

           if v_log_localiz_arg and v_log_acum_sdo_clien then do:

               if first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1]) then
                   assign v_val_sdo_apres_acum = 0.

               if tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/  then
                   assign v_val_sdo_apres_acum = v_val_sdo_apres_acum - ttv_val_sdo_tit_acr_apres.
               else
                   assign v_val_sdo_apres_acum = v_val_sdo_apres_acum + ttv_val_sdo_tit_acr_apres.
           end.             

           assign v_nom_pessoa = tt_titulos_em_aberto_acr.tta_nom_abrev.
           /* ATUALIZA O ÈLTIMO OBJETO PROCESSADO, PARA EXECUÄ«O BATCH */
           if  v_ind_dwb_run_mode = "Batch" /*l_batch*/ 
           then do:
               assign v_cod_ult_obj_procesdo = tt_titulos_em_aberto_acr.tta_cod_estab + "," +
                      tt_titulos_em_aberto_acr.tta_cod_espec_docto + "," +
                      tt_titulos_em_aberto_acr.tta_cod_ser_docto + "," +
                      tt_titulos_em_aberto_acr.tta_cod_tit_acr + "," +
                      tt_titulos_em_aberto_acr.tta_cod_parcela.
               run prgtec/btb/btb908ze.py (Input 1,
                                           Input v_cod_ult_obj_procesdo) /*prg_api_atualizar_ult_obj*/.
           end /* if */.
           /* QUEBRAS DE IMPRESS«O, CONFORME A CLASSIFICAÄ«O ESCOLHIDA */

           /* Begin_Include: i_quebras_rp_tit_acr_em_aberto */
                  if  v_log_classif_estab = yes and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1])
                  then do:
                      assign v_log_lin_cabec = yes.
                      find estabelecimento no-lock
                          where estabelecimento.cod_estab = tt_titulos_em_aberto_acr.tta_cod_estab no-error.

                      if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                          page stream s_1.
                      put stream s_1 unformatted 
           &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                          "Estabelecimento: " at 5
                          tt_titulos_em_aberto_acr.tta_cod_estab at 22 format "x(3)"
           &ENDIF
           &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                          "Estabelecimento: " at 5
                          tt_titulos_em_aberto_acr.tta_cod_estab at 22 format "x(5)".
           put stream s_1 unformatted 
           &ENDIF
                          "-" at 34
                          if avail estabelecimento then estabelecimento.nom_pessoa else "" at 36 format "x(40)" skip.
                  end /* if */.

                  if  v_log_classif_estab
                  then do:
                      if  v_log_classif_un and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2])
                      then do:
                          find first unid_negoc where unid_negoc.cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-lock no-error.
                          if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                              page stream s_1.
                          put stream s_1 unformatted 
                              "Unid Neg¢cio: " at 8
                              tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 22 format "x(3)"
                              "-" at 26
                              unid_negoc.des_unid_negoc at 28 format "x(40)" skip.
                      end /* if */.
                  end /* if */.
                  else do:
                      if  v_log_classif_un and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1])
                      then do:
                          find first unid_negoc where unid_negoc.cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-lock no-error.
                          if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                              page stream s_1.
                          put stream s_1 unformatted 
                              "Unid Neg¢cio: " at 8
                              tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 22 format "x(3)"
                              "-" at 26
                              unid_negoc.des_unid_negoc at 28 format "x(40)" skip.
                      end /* if */.
                  end.

                  if  ((v_log_classif_estab and v_log_classif_un) and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[3]))
                      or  ((v_log_classif_estab and not(v_log_classif_un)) and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]))
                      or  ((not(v_log_classif_estab) and v_log_classif_un) and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]))
                      or  ((not(v_log_classif_estab) and not(v_log_classif_un)) and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1]))
                  then do:

                      assign v_log_lin_cabec = yes.

                      /* class_block: */
                      case v_ind_classif_tit_acr_em_aber:
                          when "Por Representante/Cliente" /*l_por_representantecliente*/ then code_block:
                           do:
                              find representante no-lock
                                  where representante.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa /* v_cod_empres_usuar - leticia*/
                                  and   representante.cdn_repres  = tt_titulos_em_aberto_acr.tta_cdn_repres no-error.
                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "   Representante: " at 4
                                  tt_titulos_em_aberto_acr.tta_cdn_repres to 28 format ">>>,>>9"
                                  "-" at 34
                                  if avail representante then representante.nom_pessoa else "" at 38 format "x(40)" skip.
                          end /* do code_block */.
                          when "Por Portador/Carteira" /*l_por_portadorcarteira*/ then code_block:
                           do:
                              find portador no-lock
                                  where portador.cod_portador = tt_titulos_em_aberto_acr.tta_cod_portador no-error.
                              find cart_bcia no-lock
                                  where cart_bcia.cod_cart_bcia = tt_titulos_em_aberto_acr.tta_cod_cart_bcia no-error.
                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "Portador: " at 12
                                  tt_titulos_em_aberto_acr.tta_cod_portador at 22 format "x(5)"
                                  "-" at 34
                                  if avail portador then portador.nom_pessoa else "" at 36 format "x(40)"
                                  "  Carteira: " at 80
                                  tt_titulos_em_aberto_acr.tta_cod_cart_bcia at 92 format "x(3)"
                                  "-" at 96.
           put stream s_1 unformatted 
                                  if avail cart_bcia then cart_bcia.des_cart_bcia else "" at 98 format "x(40)" skip.
                          end /* do code_block */.
                          when "Por Cliente/Vencimento" /*l_por_clientevencimento*/  or
                          when "Por Nome Cliente/Vencimento" /*l_por_nome_clientevencimento*/ then code_block:
                           do:
                              find cliente no-lock
                                  where cliente.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa /* v_cod_empres_usuar - leticia*/
                                  and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

                              run pi_retornar_endereco_cobr_cliente(input tt_titulos_em_aberto_acr.tta_cdn_cliente).
                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "  Cliente: " at 11
                                  tt_titulos_em_aberto_acr.tta_cdn_cliente to 32 format ">>>,>>>,>>9"
                                  "-" at 34
                                  v_nom_pessoa at 36 format "x(40)"
                                  "-" at 77
                                  cliente.cod_id_feder at 79 format "x(20)"
                                  "-" at 100.
           put stream s_1 unformatted 
                                  cliente.nom_abrev at 102 format "x(15)"
                                  "-" at 118
                                  v_nom_cidade at 120 format "x(32)"
                                  "-" at 153
                                  v_cod_unid_federac at 155 format "x(3)"
                                  "-" at 159
                                  v_cod_telefone at 161 format "x(20)" skip.
                          end /* do code_block */.
                          when "Por Vencimento/Nome Cliente" /*l_por_vencimentonome_cliente*/ then code_block:
                           do:
                          end /* do code_block */.
                          when "Por Matriz" /*l_por_matriz*/ then code_block:
                           do:
                              find cliente no-lock
                                  where cliente.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa /* v_cod_empres_usuar - leticia*/
                                  and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_clien_matriz no-error.     
                               if avail cliente then do:                  
                                  if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                      page stream s_1.
                                  put stream s_1 unformatted 
                                      "   Cliente Matriz: " at 3
                                      tt_titulos_em_aberto_acr.tta_cdn_clien_matriz to 32 format ">>>,>>>,>>9"
                                      "-" at 34
                                      cliente.nom_pessoa at 36 format "x(40)" skip.

                               end.   
                          end /* do code_block */.
                          when "Por Grupo Cliente/Cliente" /*l_por_grupo_clientecliente*/ then code_block:
                           do:
                              find first cliente no-lock
                                  where cliente.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa /* v_cod_empres_usuar - leticia*/
                                  and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.
                              find first grp_clien no-lock
                                  where grp_clien.cod_grp_clien = cliente.cod_grp_clien no-error.

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "   Grupo Cliente: " at 4
                                  grp_clien.cod_grp_clien at 22 format "x(4)"
                                  "-" at 34
                                  grp_clien.des_grp_clien at 36 format "x(40)" skip.
                          end /* do code_block */.
                          when "Por Condiá∆o Cobranáa/Cliente" /*l_por_condcobranca_cliente*/ then code_block:
                           do:
                              find first cond_cobr_acr no-lock
                                  where cond_cobr_acr.cod_estab     = tt_titulos_em_aberto_acr.tta_cod_estab
                                  and   cond_cobr_acr.cod_cond_cobr = tt_titulos_em_aberto_acr.tta_cod_cond_cobr 
                                  no-error.

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "  Condiá∆o Cobranáa: " at 7
                                  tt_titulos_em_aberto_acr.tta_cod_cond_cobr at 28 format "x(8)"
                                  "-" at 39
                                  if avail cond_cobr_acr then cond_cobr_acr.des_cond_cobr else "" at 43 format "x(40)" skip.
                          end /* do code_block */.
                          when "Por EspÇcie/Vencto/Nome Cliente" /*l_por_espec_vencto_nomcli*/ then code_block:
                           do:
                              find espec_docto no-lock
                                  where espec_docto.cod_espec_docto = tt_titulos_em_aberto_acr.tta_cod_espec_docto no-error.

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "EspÇcie Documento: " at 8
                                  tt_titulos_em_aberto_acr.tta_cod_espec_docto at 27 format "x(3)"
                                  espec_docto.des_espec_docto at 32 format "x(40)" skip.
                          end /* do code_block */.
                          when "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/ then code_block:
                           do:

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "    Processo Exportaá∆o: " at 1
                                  tt_titulos_em_aberto_acr.ttv_cod_proces_export at 26 format "x(12)" skip.
                          end /* do code_block */.
                          when "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/ then code_block:
                           do:
                              if avail cta_grp_clien then
                                    find first cta_ctbl
                                        where cta_ctbl.cod_plano_cta_ctbl = cta_grp_clien.cod_plano_cta_ctbl 
                                        and cta_ctbl.cod_cta_ctbl = tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1]
                                        no-lock no-error.
                              if  avail cta_ctbl
                              then do:
                                 assign v_cod_cta_ctbl = cta_ctbl.cod_cta_ctbl
                                        v_des_cta_ctbl = cta_ctbl.des_tit_ctbl.

                                 if  cta_ctbl.cod_plano_cta_ctbl >= v_cod_plano_cta_ctbl_inic
                                 and cta_ctbl.cod_plano_cta_ctbl <= v_cod_plano_cta_ctbl_final
                                 and cta_ctbl.cod_cta_ctbl       >= v_cod_cta_ctbl_ini
                                 and cta_ctbl.cod_cta_ctbl       <= v_cod_cta_ctbl_final then do:
                                     find first tt_resumo_conta
                                     where tt_resumo_conta.tta_cod_plano_cta_ctbl = cta_ctbl.cod_plano_cta_ctbl
                                       and tt_resumo_conta.tta_cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl no-lock no-error.

                                     if  not avail tt_resumo_conta
                                       then do:
                                           create tt_resumo_conta.
                                           assign tt_resumo_conta.tta_cod_plano_cta_ctbl = cta_ctbl.cod_plano_cta_ctbl
                                                  tt_resumo_conta.tta_cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                                                  tt_resumo_conta.tta_cod_empresa        = v_cod_empres_usuar.
                                       end.
                                   end.
                              end.
                              else do:
                                  delete tt_titulos_em_aberto_acr.
                                  assign v_cod_cta_ctbl = ""
                                         v_des_cta_ctbl = "".
                                  next grp_block.
                              end.

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "  Conta Cont†bil: " at 4
                                  v_cod_cta_ctbl at 22 format "x(20)"
                                  "-" at 43
                                  v_des_cta_ctbl at 45 format "x(50)" skip.
                          end /* do code_block */.
                      end /* case class_block */.
                  end /* if */.

                  if  (v_log_classif_estab = yes and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[3]))
                  or  (v_log_classif_estab = no  and first-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]))
                  then do:
                      /* class_block: */
                      case v_ind_classif_tit_acr_em_aber:
                          when "Por Representante/Cliente" /*l_por_representantecliente*/  or
                          when "Por Vencimento/Nome Cliente" /*l_por_vencimentonome_cliente*/  or
                          when "Por Grupo Cliente/Cliente" /*l_por_grupo_clientecliente*/  or
                          when "Por Condiá∆o Cobranáa/Cliente" /*l_por_condcobranca_cliente*/ then code_block:
                           do:
                              assign v_log_lin_cabec = yes.
                              find first cliente no-lock
                                  where cliente.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa /* v_cod_empres_usuar - leticia*/
                                  and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

                              run pi_retornar_endereco_cobr_cliente(input tt_titulos_em_aberto_acr.tta_cdn_cliente).

                              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                  page stream s_1.
                              put stream s_1 unformatted 
                                  "  Cliente: " at 11
                                  tt_titulos_em_aberto_acr.tta_cdn_cliente to 32 format ">>>,>>>,>>9"
                                  "-" at 34
                                  v_nom_pessoa at 36 format "x(40)"
                                  "-" at 77
                                  cliente.cod_id_feder at 79 format "x(20)"
                                  "-" at 100.
           put stream s_1 unformatted 
                                  cliente.nom_abrev at 102 format "x(15)"
                                  "-" at 118
                                  v_nom_cidade at 120 format "x(32)"
                                  "-" at 153
                                  v_cod_unid_federac at 155 format "x(3)"
                                  "-" at 159
                                  v_cod_telefone at 161 format "x(20)" skip.
                          end /* do code_block */.
                      end /* case class_block */.
                  end /* if */.

                  if v_log_lin_cabec = yes then
                      assign v_log_lin_cabec = no
                             v_log_lin_rodap = no.

                  if  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1])
                  and  entry(1, v_cod_order_rpt) <> " ")
                  or  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2])
                  and  entry(2, v_cod_order_rpt) <> " ")
                  or  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[3])
                  and  entry(3, v_cod_order_rpt) <> " ")
                  or  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[4])
                  and  entry(4, v_cod_order_rpt) <> " ")
                  or  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[5])
                  and  GetEntryField(5, v_cod_order_rpt,',') <> " ")
                  or  (last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[6])
                  and  GetEntryField(6, v_cod_order_rpt,',') <> " ")
                  then do:
                      assign v_log_lin_rodap = yes.

                      if (line-counter(s_1) + 4) > v_rpt_s_1_bottom then
                          page stream s_1.
                  end /* if */.

                  if v_log_nao_impr_tit = no then
                      run pi_tratar_layout_tit_acr_em_aberto (Input "put" /*l_put*/) /*pi_tratar_layout_tit_acr_em_aberto*/.

                  if v_log_emit_movto_cobr = yes 
                  then do:
                       &if '{&emsfin_version}' >= '5.03' &then
                           for each  relac_movto_cobr_tit_acr no-lock
                               where relac_movto_cobr_tit_acr.cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                                 and relac_movto_cobr_tit_acr.num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                               break by relac_movto_cobr_tit_acr.cod_estab:
                               find movto_cobr_tit_acr no-lock
                                    where movto_cobr_tit_acr.cod_empresa                = relac_movto_cobr_tit_acr.cod_empresa
                                      and movto_cobr_tit_acr.cdn_cliente                = relac_movto_cobr_tit_acr.cdn_cliente
                                      and movto_cobr_tit_acr.num_seq_movto_cobr_tit_acr = relac_movto_cobr_tit_acr.num_seq_movto_cobr_tit_acr
                                    no-error.
                               if avail movto_cobr_tit_acr
                               then do:
                                    if first-of( relac_movto_cobr_tit_acr.cod_estab ) then do:
                                         if (line-counter(s_1) + 4) > v_rpt_s_1_bottom then
                                             page stream s_1.
                                         put stream s_1 unformatted 
                                             skip (1)
                                             "Data" at 10
                                             "Hora" at 21
                                             "Usu†rio" at 30
                                             "Tipo" at 43
                                             "Contato Cobr" at 54
                                             "Descr Abrev" at 85
                                             "Moeda" at 126
                                             "Custo Movto" to 148 skip
                                             "----------" at 10
                                             "--------" at 21
                                             "------------" at 30
                                             "--------------------" at 43
                                             "------------------------------" at 54
                                             "----------------------------------------" at 85
                                             "--------" at 126
                                             "--------------" to 148 skip.
                                    end.

                                    assign v_val_cust_movto_cobr = relac_movto_cobr_tit_acr.val_cust_movto_cobr.
                                    if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                        page stream s_1.
                                    put stream s_1 unformatted 
                                        movto_cobr_tit_acr.dat_movto_cobr_tit_acr at 10 format "99/99/9999"
                                        movto_cobr_tit_acr.hra_movto_cobr_tit_acr at 21 format "99:99:99"
                                        movto_cobr_tit_acr.cod_usuario at 30 format "x(12)"
                                        movto_cobr_tit_acr.ind_tip_movto_cobr at 43 format "X(20)"
                                        movto_cobr_tit_acr.nom_contat_cobr at 54 format "x(30)"
                                        movto_cobr_tit_acr.des_abrev_movto_cobr at 85 format "x(40)"
                                        movto_cobr_tit_acr.cod_indic_econ at 126 format "x(8)".
           put stream s_1 unformatted 
                                        v_val_cust_movto_cobr[1] to 148 format ">>>,>>>,>>9.99" skip.

                                    if  last-of( relac_movto_cobr_tit_acr.cod_estab ) then do:
                                         if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                                             page stream s_1.
                                         put stream s_1 unformatted  skip (1) skip.
                                    end.
                               end.
                           end.
                       &else
                           for each  movto_cobr_tit_acr no-lock
                               where movto_cobr_tit_acr.cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                                 and movto_cobr_tit_acr.num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                               break by movto_cobr_tit_acr.cod_estab
                                     by movto_cobr_tit_acr.dat_movto_cobr_tit_acr:

                               if first-of( movto_cobr_tit_acr.cod_estab ) then do:
                                    if (line-counter(s_1) + 4) > v_rpt_s_1_bottom then
                                        page stream s_1.
                                    put stream s_1 unformatted 
                                        skip (1)
                                        "Data" at 10
                                        "Hora" at 21
                                        "Usu†rio" at 30
                                        "Tipo" at 43
                                        "Contato Cobr" at 54
                                        "Descr Abrev" at 85
                                        "Moeda" at 126
                                        "Custo Movto" to 148 skip
                                        "----------" at 10
                                        "--------" at 21
                                        "------------" at 30
                                        "--------------------" at 43
                                        "------------------------------" at 54
                                        "----------------------------------------" at 85
                                        "--------" at 126
                                        "--------------" to 148 skip.
                               end.

                               assign v_val_cust_movto_cobr = movto_cobr_tit_acr.val_cust_movto_cobr.
                               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                   page stream s_1.
                               put stream s_1 unformatted 
                                   movto_cobr_tit_acr.dat_movto_cobr_tit_acr at 10 format "99/99/9999"
                                   movto_cobr_tit_acr.hra_movto_cobr_tit_acr at 21 format "99:99:99"
                                   movto_cobr_tit_acr.cod_usuario at 30 format "x(12)"
                                   movto_cobr_tit_acr.ind_tip_movto_cobr at 43 format "X(20)"
                                   movto_cobr_tit_acr.nom_contat_cobr at 54 format "x(30)"
                                   movto_cobr_tit_acr.des_abrev_movto_cobr at 85 format "x(40)"
                                   movto_cobr_tit_acr.cod_indic_econ at 126 format "x(8)".
           put stream s_1 unformatted 
                                   v_val_cust_movto_cobr[1] to 148 format ">>>,>>>,>>9.99" skip.

                               if  last-of( movto_cobr_tit_acr.cod_estab ) then do:
                                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                                        page stream s_1.
                                    put stream s_1 unformatted  skip (1) skip.
                               end.
                           end.
                       &endif
                  end.

                  tot_var:
                  do v_num_cont = 1 to 6:
                      if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
                      or  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Nota de CrÇdito" /*l_nota_de_credito*/ 
                      then do:
                          assign v_val_tot_sdo_acr[v_num_cont] = v_val_tot_sdo_acr[v_num_cont] - tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                      end /* if */.
                      else do:
                          assign v_val_tot_sdo_acr[v_num_cont]    = v_val_tot_sdo_acr[v_num_cont] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                 v_val_tot_calc_amr[v_num_cont]   = v_val_tot_calc_amr[v_num_cont] + tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr
                                 v_val_tot_calc_pmr[v_num_cont]   = v_val_tot_calc_pmr[v_num_cont] + tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr
                                 v_val_tot_calc_movto[v_num_cont] = v_val_tot_calc_movto[v_num_cont] + tt_titulos_em_aberto_acr.tta_val_movto_tit_acr.
                      end /* else */.
                  end /* do tot_var */.
           /* End_Include: i_quebras_rp_tit_acr_em_aberto */

           /* IMPRESS«O DOS TOTAIS, CONFORME O SOLICITADO */
           if  v_log_lin_rodap = yes
           then do:
               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[6])
               and GetEntryField(6, v_cod_order_rpt,',') <> " "
               then do:
                   if  v_log_nao_impr_tit then
                       assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + GetEntryField(6, v_cod_order_rpt,',').
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + GetEntryField(6, v_cod_order_rpt,',').
                   if  v_val_tot_calc_movto[6] <> 0
                   then do:
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[6] / v_val_tot_calc_movto[5]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[6] / v_val_tot_calc_movto[5].
                   end /* if */.
                   else do:
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   end /* else */.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[6].
                   if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                       page stream s_1.
                   put stream s_1 unformatted 
                       "---------------" at 163 skip
                       fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                       ":" at 155
                       v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[6]    = 0
                          v_val_tot_calc_amr[6]   = 0
                          v_val_tot_calc_pmr[6]   = 0
                          v_val_tot_calc_movto[6] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.
               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[5])
               and GetEntryField(5, v_cod_order_rpt,',') <> " "
               then do:
                   if  v_log_nao_impr_tit then
                       assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + GetEntryField(5, v_cod_order_rpt,',').
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + GetEntryField(5, v_cod_order_rpt,',').
                   if  v_val_tot_calc_movto[5] <> 0
                   then do:
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[5] / v_val_tot_calc_movto[5]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[5] / v_val_tot_calc_movto[5].
                   end /* if */.
                   else do:
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   end /* else */.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[5].
                   if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                       page stream s_1.
                   put stream s_1 unformatted 
                       "---------------" at 163 skip
                       fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                       ":" at 155
                       v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[5]    = 0
                          v_val_tot_calc_amr[5]   = 0
                          v_val_tot_calc_pmr[5]   = 0
                          v_val_tot_calc_movto[5] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.

               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[4])
               and entry(4, v_cod_order_rpt) <> " "
               then do:
                   if  v_log_nao_impr_tit then
                       assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + entry(4, v_cod_order_rpt).
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + entry(4, v_cod_order_rpt).
                   if  v_val_tot_calc_movto[4] <> 0
                   then do:
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[4] / v_val_tot_calc_movto[4]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[4] / v_val_tot_calc_movto[4].
                   end /* if */.
                   else do:
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   end /* else */.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[4].
                   if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                       page stream s_1.
                   put stream s_1 unformatted 
                       "---------------" at 163 skip
                       fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                       ":" at 155
                       v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[4]    = 0
                          v_val_tot_calc_amr[4]   = 0
                          v_val_tot_calc_pmr[4]   = 0
                          v_val_tot_calc_movto[4] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.

               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[3])
               and entry(3, v_cod_order_rpt) <> " "
               then do:
                   if v_log_nao_impr_tit then do:
                       assign v_nom_field = entry(3,v_cod_order_rpt).
                       if v_nom_field = "Vencimento" /*l_vencimento*/  then
                           assign v_nom_field = "Total Saldo Vencto" /*l_tot_saldo_vencto*/  + " " + string(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr,"99/99/9999").
                       else
                           assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + entry(3, v_cod_order_rpt).
                   end.
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + entry(3, v_cod_order_rpt).
                   if  v_val_tot_calc_movto[3] <> 0
                   then do:
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[3] / v_val_tot_calc_movto[3]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[3] / v_val_tot_calc_movto[3].
                   end /* if */.
                   else do:
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   end /* else */.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[3].
                   if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                       page stream s_1.
                   put stream s_1 unformatted 
                       "---------------" at 163 skip
                       fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                       ":" at 155
                       v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[3]    = 0
                          v_val_tot_calc_amr[3]   = 0
                          v_val_tot_calc_pmr[3]   = 0
                          v_val_tot_calc_movto[3] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.

               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2])
               and entry(2, v_cod_order_rpt) <> " "
               then do:
                   if v_log_nao_impr_tit then do:
                       assign v_nom_field = entry(2,v_cod_order_rpt).
                       if v_nom_field = "Vencimento" /*l_vencimento*/  then
                           assign v_nom_field = "Total Saldo Vencto" /*l_tot_saldo_vencto*/  + " " + string(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr,"99/99/9999").
                       else
                           assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + entry(2, v_cod_order_rpt).
                   end.
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + entry(2, v_cod_order_rpt).
                   if  v_val_tot_calc_movto[2] <> 0
                   then do:
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[2] / v_val_tot_calc_movto[2]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[2] / v_val_tot_calc_movto[2].
                   end /* if */.
                   else do:
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   end /* else */.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[2].

                   if  entry(1, v_cod_order_rpt) = "Estabelecimento" /*l_estabelecimento*/ 
                   then do:
                       if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                           page stream s_1.
                       put stream s_1 unformatted 
                           "---------------" at 163 skip
                           "     Prazo MÇdio de Recebimento" at 30
                           ":" at 62
                           v_num_dias_pmr_7 to 71 format "->>>>>>9"
                           "     Atraso MÇdio de Recebimento" at 75
                           ":" at 108
                           v_num_dias_amr_7 to 117 format "->>>>>>9".
    put stream s_1 unformatted 
                           fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                           ":" at 155
                           v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                       /* Begin_Include: i_imprime_aging_acr */
                       if  (v_log_classif_estab = yes and last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]))
                       or  (v_log_classif_estab = no  and last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1]))
                       then do:
                           put stream s_1 unformatted skip(1).
                           if v_log_funcao_aging_acr = yes then
                               run pi_aging_acr (input no).
                       end /* if */.
                       /* End_Include: i_imprime_aging_acr */
                       .
                   end /* if */.
                   else do:
                       if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                           page stream s_1.
                       put stream s_1 unformatted 
                           "---------------" at 163 skip
                           fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                           ":" at 155
                           v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.
                   end /* else */.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes
                   and entry(3, v_cod_order_rpt) = "" then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[2]    = 0
                          v_val_tot_calc_amr[2]   = 0
                          v_val_tot_calc_pmr[2]   = 0
                          v_val_tot_calc_movto[2] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.

               if  last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1])
               and entry(1, v_cod_order_rpt) <> " "
               then do:
                   if v_log_nao_impr_tit then do:
                       assign v_nom_field = entry(1,v_cod_order_rpt).
                       if v_nom_field = "Vencimento" /*l_vencimento*/  then
                           assign v_nom_field = "Total Saldo Vencto" /*l_tot_saldo_vencto*/  + " " + string(tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr,"99/99/9999").
                       else
                           assign v_nom_field = "Total Saldo" /*l_tot_sdo*/  + " " + entry(1, v_cod_order_rpt).
                   end.
                   else
                       assign v_nom_field = "Total" /*l_total*/  + " " + entry(1, v_cod_order_rpt).
                   if  v_val_tot_calc_movto[1] <> 0 then
                       assign v_num_dias_amr_7 = v_val_tot_calc_amr[1] / v_val_tot_calc_movto[1]
                              v_num_dias_pmr_7 = v_val_tot_calc_pmr[1] / v_val_tot_calc_movto[1].
                   else
                       assign v_num_dias_amr_7 = 0
                              v_num_dias_pmr_7 = 0.
                   assign v_val_tot_sdo = v_val_tot_sdo_acr[1].
                   if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
                       page stream s_1.
                   put stream s_1 unformatted 
                       "---------------" at 163 skip
                       "     Prazo MÇdio de Recebimento" at 30
                       ":" at 62
                       v_num_dias_pmr_7 to 71 format "->>>>>>9"
                       "     Atraso MÇdio de Recebimento" at 75
                       ":" at 108
                       v_num_dias_amr_7 to 117 format "->>>>>>9".
    put stream s_1 unformatted 
                       fill(" ", 30 - length(trim(v_nom_field))) + trim(v_nom_field) to 153 format "x(30)"
                       ":" at 155
                       v_val_tot_sdo to 177 format "->>,>>>,>>>,>>9.99" skip.

                   if  v_log_gerac_planilha = yes
                   and v_log_nao_impr_tit   = yes
                   and entry(2, v_cod_order_rpt) = "" then
                       run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.

                   assign v_val_tot_sdo_acr[1]    = 0
                          v_val_tot_calc_amr[1]   = 0
                          v_val_tot_calc_pmr[1]   = 0
                          v_val_tot_calc_movto[1] = 0
                          v_val_tot_sdo           = 0.
               end /* if */.
           end /* if */.


           /* Begin_Include: i_create_tt_total_estab_un_acr */
           if v_ind_classif_tit_acr_em_aber = "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/ 
           and avail tt_resumo_conta then do:

               if v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/  then do:

                   find first tt_resumo_conta_estab_acr exclusive-lock
                        where tt_resumo_conta_estab_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                          and tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                          and tt_resumo_conta_estab_acr.tta_cod_cta_ctbl       = tt_resumo_conta.tta_cod_cta_ctbl
                          and tt_resumo_conta_estab_acr.tta_cod_empresa        = v_cod_empres_usuar
                          and tt_resumo_conta_estab_acr.tta_cod_unid_negoc     = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-error.
                   if not avail tt_resumo_conta_estab_acr then do:
                       create tt_resumo_conta_estab_acr.
                       assign tt_resumo_conta_estab_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                              tt_resumo_conta_estab_acr.tta_cod_unid_negoc     = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                              tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                              tt_resumo_conta_estab_acr.tta_cod_cta_ctbl       = tt_resumo_conta.tta_cod_cta_ctbl
                              tt_resumo_conta_estab_acr.tta_cod_empresa        = v_cod_empres_usuar.   
                   end.
               end.
               else do: /* Por Estabelecimento */

                   find first tt_resumo_conta_estab_acr exclusive-lock
                        where tt_resumo_conta_estab_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                          and tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                          and tt_resumo_conta_estab_acr.tta_cod_cta_ctbl       = tt_resumo_conta.tta_cod_cta_ctbl no-error.
                   if not avail tt_resumo_conta_estab_acr then do:

                       create tt_resumo_conta_estab_acr.
                       assign tt_resumo_conta_estab_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                              tt_resumo_conta_estab_acr.tta_cod_unid_negoc     = ''
                              tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                              tt_resumo_conta_estab_acr.tta_cod_cta_ctbl       = tt_resumo_conta.tta_cod_cta_ctbl
                              tt_resumo_conta_estab_acr.tta_cod_empresa        = v_cod_empres_usuar.
                   end.
               end.

               if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/  then
                   assign tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr = tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
               else
                   assign tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr = tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr - tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
           end.
           /* End_Include: i_create_tt_total_estab_un_acr */


           if  entry(1, v_cod_order_rpt) <> "Estabelecimento" /*l_estabelecimento*/ 
           then do:

               /* Begin_Include: i_imprime_aging_acr */
               if  (v_log_classif_estab = yes and last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[2]))
               or  (v_log_classif_estab = no  and last-of(tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[1]))
               then do:
                   put stream s_1 unformatted skip(1).
                   if v_log_funcao_aging_acr = yes then
                       run pi_aging_acr (input no).
               end /* if */.
               /* End_Include: i_imprime_aging_acr */
               .
           end /* if */.

           /* GERA PLANILHA */
           if  v_log_gerac_planilha = yes
           and v_log_nao_impr_tit   = no then
               run pi_rpt_aberto_gerac_planilha (Input "put" /*l_PUT*/) /*pi_rpt_aberto_gerac_planilha*/.
       end /* for grp_block */.

       hide stream s_1 frame f_rpt_s_1_Grp_quebra_Lay_moedas.
       run pi_tratar_layout_tit_acr_em_aberto (Input "hide" /*l_hide*/) /*pi_tratar_layout_tit_acr_em_aberto*/.
    end /* if */.

    if v_log_funcao_aging_acr = yes then
        run pi_aging_acr_more /*pi_aging_acr_more*/.

    if  v_log_gerac_planilha = yes then
        run pi_rpt_aberto_gerac_planilha (Input "close" /*l_CLOSE*/) /*pi_rpt_aberto_gerac_planilha*/.

    view stream s_1 frame f_rpt_s_1_footer_normal.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    hide stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_Grp_pos_Lay_pos.

    if  v_ind_classif_tit_acr_em_aber = "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then
        run pi_tratar_resumo_contas_acr.

    /* IMPRESS«O SINTêTICA DOS T÷TULOS EM ABERTO */
    if  v_log_visualiz_sint = yes
    then do:
        /* ** Foi criada a pi, por falta de espaáos para outros c¢digos ***/
        run pi_imp_sintetica_tit_em_aberto /*pi_imp_sintetica_tit_em_aberto*/.
    end /* if */.
END PROCEDURE. /* pi_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_tratar_layout_tit_acr_em_aberto
** Descricao.............: pi_tratar_layout_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 07/01/1997 11:53:34
** Alterado por..........: fut40711
** Alterado em...........: 15/12/2009 18:45:00
*****************************************************************************/
PROCEDURE pi_tratar_layout_tit_acr_em_aberto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_funcao_rpt
        as character
        format "x(06)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* param_block: */
    case p_cod_funcao_rpt:
        when "view" /*l_view*/ then view_block:
         do:

            if  v_ind_classif_tit_acr_em_aber = "Por Portador/Carteira" /*l_por_portadorcarteira*/  then do:
                view stream s_1 frame f_rpt_s_1_Grp_pos_Lay_pos.
                if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    "Estab" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                    "Estab" at 1
    &ENDIF
                    "Esp" at 7
                    "SÇrie" at 11
                    "T°tulo" at 17
                    "/P" at 34
                    "Un N" at 37
                    "Cliente" to 52
                    "Nome Abrev" at 54
                    "Emiss∆o" at 70
                    "Vencto" at 81
                    "CrÇdito" at 92
                    "Refer" at 103
                    "Num T°tulo Banco" at 114
                    "Moeda" at 135
                    "Vl Original" to 157
                    "Saldo" to 172
                    "Saldo" to 188
/*                     "Dias" to 197         */
/*                     "Pedido Venda" at 199 */
/*                     "Dt Indic" at 212     */
                    skip
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    "-----" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                    "-----" at 1
    &ENDIF
                    "---" at 7
                    "-----" at 11
                    "----------------" at 17
                    "--" at 34
                    "----" at 37
                    "-----------" to 52
                    "---------------" at 54
                    "----------" at 70
                    "----------" at 81
                    "----------" at 92
                    "----------" at 103
                    "--------------------" at 114
                    "--------" at 135
                    "--------------" to 157
                    "--------------" to 172
                    "---------------" to 188
                    "--------" to 197
                    "------------" at 199
                    "----------" at 212 skip.
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_avencer_1.
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente_Arg.
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_principal.
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_princip_arg.
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencid_1.
                view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente.
            end.
            else do:
                if v_log_localiz_arg and v_log_acum_sdo_clien then do:
                    view stream s_1 frame f_rpt_s_1_Grp_pos_Lay_pos.
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 1
    &ENDIF
                        "Esp" at 7
                        "SÇrie" at 11
                        "T°tulo" at 17
                        "/P" at 34
                        "Un N" at 37
                        "Cliente" at 42
                        "Port" at 55
                        "Cart" at 61
                        "Emiss∆o" at 66
                        "Vencto" at 77
                        "CrÇdito" at 88
                        "Refer" at 99
                        "Num T°tulo Banco" at 110
                        "Moeda" at 131
                        "Vl Original" to 153
                        "Saldo" to 168
                        "Saldo" to 184
                        "Saldo Acumulado" to 203
/*                         "Dias" to 212         */
/*                         "Pedido Venda" at 214 */
/*                         "Dt Indic" at 227     */
                        skip
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 1
    &ENDIF
                        "---" at 7
                        "-----" at 11
                        "----------------" at 17
                        "--" at 34
                        "----" at 37
                        "------------" at 42
                        "-----" at 55
                        "----" at 61
                        "----------" at 66
                        "----------" at 77
                        "----------" at 88
                        "----------" at 99
                        "--------------------" at 110
                        "--------" at 131
                        "--------------" to 153
                        "--------------" to 168
                        "---------------" to 184
                        "------------------" to 203
                        "--------" to 212
                        "------------" at 214
                        "----------" at 227 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_avencer_1.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente_Arg.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_principal.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencid_1.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_princip_arg.            
                end.
                else do:
                    view stream s_1 frame f_rpt_s_1_Grp_pos_Lay_pos.
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 1
    &ENDIF
                        "Esp" at 7
                        "SÇrie" at 11
                        "T°tulo" at 17
                        "/P" at 34
                        "Un N" at 37
                        "Cliente" at 42
                        "Port" at 55
                        "Cart" at 61
                        "Emiss∆o" at 66
                        "Vencto" at 77
                        "CrÇdito" at 88
                        "Refer" at 99
                        "Num T°tulo Banco" at 110
                        "Moeda" at 131
                        "Vl Original" to 153
                        "Saldo" to 168
                        "Saldo" to 184
                        "Convànio" TO 193
                        "Cliente Conv." TO 207
                        "Nome Convànio" AT 209
                        "ID Pedido"     AT 254
/*                         "Dias" to 193         */
/*                         "Pedido Venda" at 195 */
/*                         "Dt Indic" at 208     */
                        skip
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 1
    &ENDIF
                        "---" at 7
                        "-----" at 11
                        "----------------" at 17
                        "--" at 34
                        "----" at 37
                        "------------" at 42
                        "-----" at 55
                        "----" at 61
                        "----------" at 66
                        "----------" at 77
                        "----------" at 88
                        "----------" at 99
                        "--------------------" at 110
                        "--------" at 131
                        "--------------" to 153
                        "--------------" to 168
                        "---------------" to 184
                        "--------" to 193
                        "-------------" at 195
                        "--------------------------------------------" at 209
                        "----------------" AT 254 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_avencer_1.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente_Arg.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_princip_arg.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencid_1.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_principal.
                end.
            end.
        end /* do view_block */.

        when "put" /*l_put*/ then put_block:
         do:

            if  not can-find( first ped_vda_tit_acr no-lock
                    where ped_vda_tit_acr.cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                    and   ped_vda_tit_acr.num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr ) then do:
                if  v_ind_classif_tit_acr_em_aber = "Por Portador/Carteira" /*l_por_portadorcarteira*/  then do:
                    if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                        tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                        tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                        tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                        tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                        tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                        tt_titulos_em_aberto_acr.tta_cdn_cliente to 52 format ">>>,>>>,>>9"
                        tt_titulos_em_aberto_acr.tta_nom_abrev at 54 format "x(15)"
                        tt_titulos_em_aberto_acr.tta_dat_emis_docto at 70 format "99/99/9999"
                        tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 81 format "99/99/9999"
                        tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 92 format "99/99/9999"
                        tt_titulos_em_aberto_acr.tta_cod_refer at 103 format "x(10)".
    put stream s_1 unformatted 
                        tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 114 format "x(20)"
                        tt_titulos_em_aberto_acr.tta_cod_indic_econ at 135 format "x(8)"
                        tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 157 format ">>>,>>>,>>9.99"
                        tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 172 format "->>,>>>,>>9.99"
                        tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 188 format "->>>,>>>,>>9.99"
                        tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193
                        tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                        tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209
                        tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                         tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 197 format "->>>>>>9"      */
/*                         tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 212 format "99/99/9999" */
                          skip.
                end.
                else do:
                    if v_log_localiz_arg and v_log_acum_sdo_clien then do:
                        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                            page stream s_1.
                        put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                            tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                            tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                            tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                            tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                            tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                            tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                            tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                            tt_titulos_em_aberto_acr.ttv_nom_abrev_clien at 42 format "x(12)"
                            tt_titulos_em_aberto_acr.tta_cod_portador at 55 format "x(5)"
                            tt_titulos_em_aberto_acr.tta_cod_cart_bcia at 61 format "x(3)"
                            tt_titulos_em_aberto_acr.tta_dat_emis_docto at 66 format "99/99/9999"
                            tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 77 format "99/99/9999"
                            tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 88 format "99/99/9999".
    put stream s_1 unformatted 
                            tt_titulos_em_aberto_acr.tta_cod_refer at 99 format "x(10)"
                            tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 110 format "x(20)"
                            tt_titulos_em_aberto_acr.tta_cod_indic_econ at 131 format "x(8)"
                            tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 153 format ">>>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 168 format "->>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 184 format "->>>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193
                            tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                            tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209
                            tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                             v_val_sdo_apres_acum to 203 format "->>,>>>,>>>,>>9.99" */
/*                             tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 212 format "->>>>>>9"      */
/*                             tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 227 format "99/99/9999" */
                            skip.                
                    end.
                    else do:
                        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                            page stream s_1.
                        put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                            tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                            tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                            tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                            tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                            tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                            tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                            tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                            tt_titulos_em_aberto_acr.ttv_nom_abrev_clien at 42 format "x(12)"
                            tt_titulos_em_aberto_acr.tta_cod_portador at 55 format "x(5)"
                            tt_titulos_em_aberto_acr.tta_cod_cart_bcia at 61 format "x(3)"
                            tt_titulos_em_aberto_acr.tta_dat_emis_docto at 66 format "99/99/9999"
                            tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 77 format "99/99/9999"
                            tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 88 format "99/99/9999".
    put stream s_1 unformatted 
                            tt_titulos_em_aberto_acr.tta_cod_refer at 99 format "x(10)"
                            tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 110 format "x(20)"
                            tt_titulos_em_aberto_acr.tta_cod_indic_econ at 131 format "x(8)"
                            tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 153 format ">>>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 168 format "->>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 184 format "->>>,>>>,>>9.99"
                            tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193
                            tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                            tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209     
                            tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                             tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 193 format "->>>>>>9"      */
/*                             tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 208 format "99/99/9999" */
                            skip.
                    end.                                
                end.
            end /* if */.
            else do:
                for each ped_vda_tit_acr no-lock
                    where ped_vda_tit_acr.cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                    and   ped_vda_tit_acr.num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                    break by ped_vda_tit_acr.num_id_tit_acr:

                    if  first-of(ped_vda_tit_acr.num_id_tit_acr)
                    then do:
                        if  v_ind_classif_tit_acr_em_aber = "Por Portador/Carteira" /*l_por_portadorcarteira*/  then do:
                            if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                page stream s_1.
                            put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                                tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                                tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                                tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                                tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                                tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                                tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                                tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                                tt_titulos_em_aberto_acr.tta_cdn_cliente to 52 format ">>>,>>>,>>9"
                                tt_titulos_em_aberto_acr.tta_nom_abrev at 54 format "x(15)"
                                tt_titulos_em_aberto_acr.tta_dat_emis_docto at 70 format "99/99/9999"
                                tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 81 format "99/99/9999"
                                tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 92 format "99/99/9999"
                                tt_titulos_em_aberto_acr.tta_cod_refer at 103 format "x(10)".
    put stream s_1 unformatted 
                                tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 114 format "x(20)"
                                tt_titulos_em_aberto_acr.tta_cod_indic_econ at 135 format "x(8)"
                                tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 157 format ">>>,>>>,>>9.99"
                                tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 172 format "->>,>>>,>>9.99"
                                tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 188 format "->>>,>>>,>>9.99"
                                tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193
                                tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                                tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209
                                tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                                 tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 197 format "->>>>>>9"      */
/*                                 ped_vda_tit_acr.cod_ped_vda at 199 format "x(12)"                              */
/*                                 tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 212 format "99/99/9999" */
                                skip.
                        end.
                        else do:
                            if v_log_localiz_arg and v_log_acum_sdo_clien then do:
                                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                    page stream s_1.
                                put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                                    tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                                    tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                                    tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                                    tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                                    tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                                    tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                                    tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                                    tt_titulos_em_aberto_acr.ttv_nom_abrev_clien at 42 format "x(12)"
                                    tt_titulos_em_aberto_acr.tta_cod_portador at 55 format "x(5)"
                                    tt_titulos_em_aberto_acr.tta_cod_cart_bcia at 61 format "x(3)"
                                    tt_titulos_em_aberto_acr.tta_dat_emis_docto at 66 format "99/99/9999"
                                    tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 77 format "99/99/9999"
                                    tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 88 format "99/99/9999".
    put stream s_1 unformatted 
                                    tt_titulos_em_aberto_acr.tta_cod_refer at 99 format "x(10)"
                                    tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 110 format "x(20)"
                                    tt_titulos_em_aberto_acr.tta_cod_indic_econ at 131 format "x(8)"
                                    tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 153 format ">>>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 168 format "->>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 184 format "->>>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193 
                                    tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                                    tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209
                                    tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                                     v_val_sdo_apres_acum to 203 format "->>,>>>,>>>,>>9.99" */
/*                                     tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 212 format "->>>>>>9"      */
/*                                     ped_vda_tit_acr.cod_ped_vda at 214 format "x(12)"                              */
/*                                     tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 227 format "99/99/9999" */
                                    skip.
                            end.
                            else do:
                                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                    page stream s_1.
                                put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                                    tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                                    tt_titulos_em_aberto_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
                                    tt_titulos_em_aberto_acr.tta_cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                                    tt_titulos_em_aberto_acr.tta_cod_ser_docto at 11 format "x(5)"
                                    tt_titulos_em_aberto_acr.tta_cod_tit_acr at 17 format "x(16)"
                                    tt_titulos_em_aberto_acr.tta_cod_parcela at 34 format "x(02)"
                                    tt_titulos_em_aberto_acr.tta_cod_unid_negoc at 37 format "x(3)"
                                    tt_titulos_em_aberto_acr.ttv_nom_abrev_clien at 42 format "x(12)"
                                    tt_titulos_em_aberto_acr.tta_cod_portador at 55 format "x(5)"
                                    tt_titulos_em_aberto_acr.tta_cod_cart_bcia at 61 format "x(3)"
                                    tt_titulos_em_aberto_acr.tta_dat_emis_docto at 66 format "99/99/9999"
                                    tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr at 77 format "99/99/9999"
                                    tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr at 88 format "99/99/9999".
    put stream s_1 unformatted 
                                    tt_titulos_em_aberto_acr.tta_cod_refer at 99 format "x(10)"
                                    tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco at 110 format "x(20)"
                                    tt_titulos_em_aberto_acr.tta_cod_indic_econ at 131 format "x(8)"
                                    tt_titulos_em_aberto_acr.tta_val_origin_tit_acr to 153 format ">>>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr to 168 format "->>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres to 184 format "->>>,>>>,>>9.99"
                                    tt_titulos_em_aberto_acr.ttv_cod_convenio TO 193
                                    tt_titulos_em_aberto_acr.ttv_cod_cliente  TO 206
                                    tt_titulos_em_aberto_acr.ttv_nome_cliente AT 209
                                    tt_titulos_em_aberto_acr.ttv_id_pedido    AT 255
/*                                     tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr to 193 format "->>>>>>9"      */
/*                                     ped_vda_tit_acr.cod_ped_vda at 195 format "x(12)"                              */
/*                                     tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut at 208 format "99/99/9999" */
                                    skip.
                            end.
                        end.
                    end /* if */.
                    else do:
                        if v_log_localiz_arg and v_log_acum_sdo_clien then do:
                            if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                page stream s_1.
                            put stream s_1 unformatted 
                                ped_vda_tit_acr.cod_ped_vda at 214 format "x(12)" skip.
                        end.
                        else do:
                            if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                                page stream s_1.
                            put stream s_1 unformatted 
                                ped_vda_tit_acr.cod_ped_vda at 195 format "x(12)" skip.
                        end.
                    end /* else */.
                end.    
            end /* else */.
        end /* do put_block */.

        when "hide" /*l_hide*/ then hide_block:
         do:
            if  v_ind_classif_tit_acr_em_aber = "Por Portador/Carteira" /*l_por_portadorcarteira*/  then do:
                hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_Cliente.
            end.
            else do:            
                 hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_principal.            
            end.
        end /* do hide_block */.
    end /* case param_block */.
END PROCEDURE. /* pi_tratar_layout_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_finalid_indic_econ
** Descricao.............: pi_retornar_finalid_indic_econ
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut43117
** Alterado em...........: 05/12/2011 10:21:41
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
    if  avail histor_finalid_econ then 
        assign p_cod_finalid_econ = histor_finalid_econ.cod_finalid_econ.




END PROCEDURE. /* pi_retornar_finalid_indic_econ */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_indic_econ_finalid
** Descricao.............: pi_retornar_indic_econ_finalid
** Criado por............: vladimir
** Criado em.............: // 
** Alterado por..........: Menna
** Alterado em...........: 06/05/1999 10:21:29
*****************************************************************************/
PROCEDURE pi_retornar_indic_econ_finalid:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find first histor_finalid_econ no-lock
         where histor_finalid_econ.cod_finalid_econ = p_cod_finalid_econ
           and histor_finalid_econ.dat_inic_valid_finalid <= p_dat_transacao
           and histor_finalid_econ.dat_fim_valid_finalid > p_dat_transacao
    &if "{&emsuni_version}" >= "5.01" &then
         use-index hstrfnld_id
    &endif
          /*cl_finalid_ativa of histor_finalid_econ*/ no-error.
    if  avail histor_finalid_econ then
        assign p_cod_indic_econ = histor_finalid_econ.cod_indic_econ.

END PROCEDURE. /* pi_retornar_indic_econ_finalid */
/*****************************************************************************
** Procedure Interna.....: pi_achar_cotac_indic_econ
** Descricao.............: pi_achar_cotac_indic_econ
** Criado por............: vladimir
** Criado em.............: // 
** Alterado por..........: fut1309_4
** Alterado em...........: 08/02/2006 16:12:34
*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_indic_econ_base
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_idx
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_cotac_parid
        as character
        format "X(09)"
        no-undo.
    def output param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_cotac_mes
        as date
        format "99/99/9999":U
        no-undo.
    def var v_log_indic
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_cod_indic_econ_orig            as character       no-undo. /*local*/
    def var v_val_cotac_indic_econ_base      as decimal         no-undo. /*local*/
    def var v_val_cotac_indic_econ_idx       as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* alteraá∆o sob demanda da atividade 148.681*/
    release cotac_parid.

    if  p_cod_indic_econ_base = p_cod_indic_econ_idx
    then do:
        /* **
         Quando a Base e o ÷ndice forem iguais, significa que a cotaá∆o pode ser percentual,
         portanto n∆o basta apenas retornar 1 e deve ser feita toda a pesquisa abaixo para
         encontrar a taxa da moeda no dia informado.
         Exemplo: D¢lar - D¢lar, poder°amos retornar 1
                  ANBID - ANBID, devemos retornar a taxa do dia.
        ***/
        find indic_econ no-lock
             where indic_econ.cod_indic_econ  = p_cod_indic_econ_base
               and indic_econ.dat_inic_valid <= p_dat_transacao
               and indic_econ.dat_fim_valid  >  p_dat_transacao
             no-error.
        if  avail indic_econ then do:
            if  indic_econ.ind_tip_cotac = "Valor" /*l_valor*/  then do:
                assign p_dat_cotac_indic_econ = p_dat_transacao
                       p_val_cotac_indic_econ = 1
                       p_cod_return           = "OK" /*l_ok*/ .
            end.
            else do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                       and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
    &if "{&emsuni_version}" >= "5.01" &then
                     use-index ctcprd_id
    &endif
                      /*cl_acha_cotac of cotac_parid*/ no-error.
                if  not avail cotac_parid
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
    &if "{&emsuni_version}" >= "5.01" &then
                         use-index prdndccn_id
    &endif
                          /*cl_acha_parid_param of parid_indic_econ*/ no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then find prev cotac_parid no-lock
                              where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                              use-index ctcprd_id
    &endif
                               /*cl_acha_cotac_anterior of cotac_parid*/ no-error.
                        when "Pr¢ximo" /*l_proximo*/ then  find next cotac_parid no-lock
                               where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                 and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                 and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                 and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                 and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                               use-index ctcprd_id
    &endif
                                /*cl_acha_cotac_posterior of cotac_parid*/ no-error.
                    end /* case block */.
                    if  not avail cotac_parid
                    then do:
                        assign p_cod_return = "358"                   + "," +
                                              p_cod_indic_econ_base   + "," +
                                              p_cod_indic_econ_idx    + "," +
                                              string(p_dat_transacao) + "," +
                                              p_ind_tip_cotac_parid.
                    end /* if */.
                    else do:
                        assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                               p_cod_return           = "OK" /*l_ok*/ .
                    end /* else */.
                end /* if */.
                else do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                           p_cod_return           = "OK" /*l_ok*/ .
                end /* else */.
            end.
        end.
        else do:
            assign p_cod_return = "335".
        end.
    end /* if */.
    else do:
        find parid_indic_econ no-lock
             where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
               and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
             use-index prdndccn_id no-error.
        if  avail parid_indic_econ
        then do:


            /* Begin_Include: i_verifica_cotac_parid */
            /* verifica as cotacoes da moeda p_cod_indic_econ_base para p_cod_indic_econ_idx 
              cadastrada na base, de acordo com a periodicidade da cotacao (obtida na 
              parid_indic_econ, que deve estar avail)*/

            /* period_block: */
            case parid_indic_econ.ind_periodic_cotac:
                when "Di†ria" /*l_diaria*/ then
                    diaria_block:
                    do:
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            find parid_indic_econ no-lock
                                where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                                  and parid_indic_econ.cod_indic_econ_idx  = p_cod_indic_econ_idx
                                use-index prdndccn_id no-error.
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then 
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                                when "Pr¢ximo" /*l_proximo*/ then  
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do diaria_block */.
                when "Mensal" /*l_mensal*/ then
                    mensal_block:
                    do:
                        assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao))
                               &if yes = yes &then 
                               v_log_indic     = yes
                               &endif .
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                                when "Pr¢ximo" /*l_proximo*/ then
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do mensal_block */.
                when "Bimestral" /*l_bimestral*/ then
                    bimestral_block:
                    do:
                    end /* do bimestral_block */.
                when "Trimestral" /*l_trimestral*/ then
                    trimestral_block:
                    do:
                    end /* do trimestral_block */.
                when "Quadrimestral" /*l_quadrimestral*/ then
                    quadrimestral_block:
                    do:
                    end /* do quadrimestral_block */.
                when "Semestral" /*l_semestral*/ then
                    semestral_block:
                    do:
                    end /* do semestral_block */.
                when "Anual" /*l_anual*/ then
                    anual_block:
                    do:
                    end /* do anual_block */.
            end /* case period_block */.
            /* End_Include: i_verifica_cotac_parid */


            if  parid_indic_econ.ind_orig_cotac_parid = "Outra Moeda" /*l_outra_moeda*/  and
                 parid_indic_econ.cod_finalid_econ_orig_cotac <> "" and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                /* Cotaá∆o Ponte */
                run pi_retornar_indic_econ_finalid (Input parid_indic_econ.cod_finalid_econ_orig_cotac,
                                                    Input p_dat_transacao,
                                                    output v_cod_indic_econ_orig) /*pi_retornar_indic_econ_finalid*/.
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign v_val_cotac_indic_econ_base = cotac_parid.val_cotac_indic_econ.
                    find parid_indic_econ no-lock
                        where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                        and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
                        use-index prdndccn_id no-error.
                    run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                     Input p_cod_indic_econ_idx,
                                                     Input p_dat_transacao,
                                                     Input p_ind_tip_cotac_parid,
                                                     Input p_cod_indic_econ_base,
                                                     Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                    if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                    then do:
                        assign v_val_cotac_indic_econ_idx = cotac_parid.val_cotac_indic_econ
                               p_val_cotac_indic_econ = v_val_cotac_indic_econ_idx / v_val_cotac_indic_econ_base
                               p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_cod_return = "OK" /*l_ok*/ .
                        return.
                    end /* if */.
                end /* if */.
            end /* if */.
            if  parid_indic_econ.ind_orig_cotac_parid = "Inversa" /*l_inversa*/  and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_idx
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input p_cod_indic_econ_idx,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = 1 / cotac_parid.val_cotac_indic_econ
                           p_cod_return = "OK" /*l_ok*/ .
                    return.
                end /* if */.
            end /* if */.
        end /* if */.
        if v_log_indic = yes then do:
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(v_dat_cotac_mes) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        else do:   
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(p_dat_transacao) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        assign v_log_indic = no.
    end /* else */.
END PROCEDURE. /* pi_achar_cotac_indic_econ */
/*****************************************************************************
** Procedure Interna.....: pi_achar_cotac_indic_econ_2
** Descricao.............: pi_achar_cotac_indic_econ_2
** Criado por............: src531
** Criado em.............: 29/07/2003 11:10:10
** Alterado por..........: bre17752
** Alterado em...........: 30/07/2003 12:46:24
*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_param_1
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_param_2
        as character
        format "x(50)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_cotac_parid
        as character
        format "X(09)"
        no-undo.
    def Input param p_cod_indic_econ_base
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_idx
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_cotac_mes                  as date            no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* period_block: */
    case parid_indic_econ.ind_periodic_cotac:
        when "Di†ria" /*l_diaria*/ then
            diaria_block:
            do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_param_1
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_param_2
                         use-index prdndccn_id no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then find prev cotac_parid no-lock
                              where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                              use-index ctcprd_id
    &endif
                               /*cl_acha_cotac_anterior of cotac_parid*/ no-error.
                        when "Pr¢ximo" /*l_proximo*/ then  find next cotac_parid no-lock
                               where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                 and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                 and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                 and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                 and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                               use-index ctcprd_id
    &endif
                                /*cl_acha_cotac_posterior of cotac_parid*/ no-error.
                    end /* case block */.
                end /* if */.
            end /* do diaria_block */.
        when "Mensal" /*l_mensal*/ then
            mensal_block:
            do:
                assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao)).
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then
                        find prev cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                        when "Pr¢ximo" /*l_proximo*/ then
                        find next cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                    end /* case block */.
                end /* if */.
            end /* do mensal_block */.
        when "Bimestral" /*l_bimestral*/ then
            bimestral_block:
            do:
            end /* do bimestral_block */.
        when "Trimestral" /*l_trimestral*/ then
            trimestral_block:
            do:
            end /* do trimestral_block */.
        when "Quadrimestral" /*l_quadrimestral*/ then
            quadrimestral_block:
            do:
            end /* do quadrimestral_block */.
        when "Semestral" /*l_semestral*/ then
            semestral_block:
            do:
            end /* do semestral_block */.
        when "Anual" /*l_anual*/ then
            anual_block:
            do:
            end /* do anual_block */.
    end /* case period_block */.
END PROCEDURE. /* pi_achar_cotac_indic_econ_2 */
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
** Procedure Interna.....: pi_imp_sintetica_tit_em_aberto
** Descricao.............: pi_imp_sintetica_tit_em_aberto
** Criado por............: bre17230
** Criado em.............: 28/10/1998 16:41:52
** Alterado por..........: fut1228_2
** Alterado em...........: 25/10/2006 10:18:33
*****************************************************************************/
PROCEDURE pi_imp_sintetica_tit_em_aberto:

    if  page-number (s_1) > 0
    then do:
        page stream s_1.
    end /* if */.

    /* IMPRESS«O DO PRAZO MêDIO DE RECEBIMENTO E DO ATRASO MêDIO DO PER÷ODO */
    if  v_val_tot_movto <> 0
    then do:
        assign v_num_dias_pmr_7 = v_val_tot_movto_pmr / v_val_tot_movto
               v_num_dias_amr_7 = v_val_tot_movto_amr / v_val_tot_movto.
    end /* if */.
    else do:
        assign v_num_dias_amr_7 = 0
               v_num_dias_pmr_7 = 0.
    end /* else */.

    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        skip (1)
        "     Prazo MÇdio de Recebimento" at 21
        ":" at 52
        v_num_dias_pmr_7 to 62 format "->>>>>>9" skip
        "     Atraso MÇdio do Per°odo" at 24
        ":" at 52
        v_num_dias_amr_7 to 62 format "->>>>>>9" skip.
    put stream s_1 unformatted skip(2).

    /* IMPRESS«O DO RESUMO DOS T÷TULOS VENCIDOS */
    assign v_val_perc_vencid[1]       = (v_val_sdo_apres_vencid[1] / v_val_tot_sdo_vencid) * 100
           v_val_perc_geral_vencid[1] = (v_val_sdo_apres_vencid[1] / v_val_tot_sdo_normal) * 100.

    if v_val_perc_vencid[1] = ? then
        assign v_val_perc_vencid[1] = 0.

    if v_val_perc_geral_vencid[1] = ? then
        assign v_val_perc_geral_vencid[1] = 0.    

    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "Vl Saldo Apres" to 80
        "Quant" to 90
        "Percentual" to 105
        "Percentual Geral" to 124 skip
        "------------------" to 80
        "-----" to 90
        "----------" to 105
        "----------------" to 124 skip.
    if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "Vencidos atÇ: " at 36
        v_num_dias_vencid_1 to 53 format ">>>9"
        "Dias" at 55
        v_val_sdo_apres_vencid[1] to 80 format "->>,>>>,>>>,>>9.99"
        v_qtd_tit_acr_vencid[1] to 90 format ">>>>9"
        v_val_perc_vencid[1] to 105 format ">>9.99"
        v_val_perc_geral_vencid[1] to 124 format ">>9.99" skip.

    if  v_num_dias_vencid_2 <> 0
    then do:
        assign v_val_perc_vencid[2]       = (v_val_sdo_apres_vencid[2] / v_val_tot_sdo_vencid) * 100
               v_val_perc_geral_vencid[2] = (v_val_sdo_apres_vencid[2] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[2] = ? then
            assign v_val_perc_vencid[2] = 0.

        if v_val_perc_geral_vencid[2] = ? then
            assign v_val_perc_geral_vencid[2] = 0.    

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 36
            v_num_dias_vencid_2 to 43 format ">>>9"
            "atÇ: " at 45
            v_num_dias_vencid_3 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_vencid[2] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_vencid[2] to 90 format ">>>>9"
            v_val_perc_vencid[2] to 105 format ">>9.99"
            v_val_perc_geral_vencid[2] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_vencid_4 <> 0
    then do:
        assign v_val_perc_vencid[3]       = (v_val_sdo_apres_vencid[3] / v_val_tot_sdo_vencid) * 100
               v_val_perc_geral_vencid[3] = (v_val_sdo_apres_vencid[3] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[3] = ? then
            assign v_val_perc_vencid[3] = 0.

        if v_val_perc_geral_vencid[3] = ? then
            assign v_val_perc_geral_vencid[3] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 36
            v_num_dias_vencid_4 to 43 format ">>>9"
            "atÇ: " at 45
            v_num_dias_vencid_5 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_vencid[3] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_vencid[3] to 90 format ">>>>9"
            v_val_perc_vencid[3] to 105 format ">>9.99"
            v_val_perc_geral_vencid[3] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_vencid_6 <> 0
    then do:
        assign v_val_perc_vencid[4]       = (v_val_sdo_apres_vencid[4] / v_val_tot_sdo_vencid) * 100
               v_val_perc_geral_vencid[4] = (v_val_sdo_apres_vencid[4] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[4] = ? then
            assign v_val_perc_vencid[4] = 0.

        if v_val_perc_geral_vencid[4] = ? then
            assign v_val_perc_geral_vencid[4] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_vencid_6 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_vencid_7 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_vencid[4] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_vencid[4] to 90 format ">>>>9"
            v_val_perc_vencid[4] to 105 format ">>9.99"
            v_val_perc_geral_vencid[4] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_vencid_8 <> 0
    then do:
        assign v_val_perc_vencid[5]       = (v_val_sdo_apres_vencid[5] / v_val_tot_sdo_vencid) * 100
               v_val_perc_geral_vencid[5] = (v_val_sdo_apres_vencid[5] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[5] = ? then
            assign v_val_perc_vencid[5] = 0.

        if v_val_perc_geral_vencid[5] = ? then
            assign v_val_perc_geral_vencid[5] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "Mais de: " at 30
            v_num_dias_vencid_8 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_vencid_9 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_vencid[5] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_vencid[5] to 90 format ">>>>9"
            v_val_perc_vencid[5] to 105 format ">>9.99"
            v_val_perc_geral_vencid[5] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_vencid_10 <> 0
    then do:
        assign v_val_perc_vencid[6]       = (v_val_sdo_apres_vencid[6] / v_val_tot_sdo_vencid) * 100
               v_val_perc_geral_vencid[6] = (v_val_sdo_apres_vencid[6] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[6] = ? then
            assign v_val_perc_vencid[6] = 0.

        if v_val_perc_geral_vencid[6] = ? then
            assign v_val_perc_geral_vencid[6] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_vencid_10 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_vencid_11 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_vencid[6] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_vencid[6] to 90 format ">>>>9"
            v_val_perc_vencid[6] to 105 format ">>9.99"
            v_val_perc_geral_vencid[6] to 124 format ">>9.99" skip.
    end /* if */.

    assign v_val_perc_vencid[7]       = (v_val_sdo_apres_vencid[7] / v_val_tot_sdo_vencid) * 100
           v_val_perc_geral_vencid[7] = (v_val_sdo_apres_vencid[7] / v_val_tot_sdo_normal) * 100
           v_val_perc_vencid[8]       = (v_val_tot_sdo_vencid / v_val_tot_sdo_vencid) * 100
           v_val_perc_geral_vencid[8] = (v_val_tot_sdo_vencid / v_val_tot_sdo_normal) * 100.

        if v_val_perc_vencid[7] = ? then
            assign v_val_perc_vencid[7] = 0.

        if v_val_perc_geral_vencid[7] = ? then
            assign v_val_perc_geral_vencid[7] = 0.

        if v_val_perc_vencid[8] = ? then
            assign v_val_perc_vencid[8] = 0.

        if v_val_perc_geral_vencid[8] = ? then
            assign v_val_perc_geral_vencid[8] = 0.

    if (line-counter(s_1) + 5) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        skip (1)
        "Mais de: " at 41
        v_num_dias_vencid_12 to 53 format ">>>9"
        "Dias" at 55
        v_val_sdo_apres_vencid[7] to 80 format "->>,>>>,>>>,>>9.99"
        v_qtd_tit_acr_vencid[7] to 90 format ">>>>9"
        v_val_perc_vencid[7] to 105 format ">>9.99".
    put stream s_1 unformatted 
        v_val_perc_geral_vencid[7] to 124 format ">>9.99"
        skip (1)
        "     Total de T°tulos Vencidos" at 28
        ":" at 58
        v_val_tot_sdo_vencid to 80 format "->>>,>>>,>>>,>>9.99"
        v_qtd_tot_tit_vencid to 90 format ">>>,>>9"
        v_val_perc_vencid[8] to 105 format ">>9.99"
        v_val_perc_geral_vencid[8] to 124 format ">>9.99" skip (1).

    hide stream s_1 frame f_rpt_s_1_footer_normal.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_Grp_pos_Lay_pos.

    /* IMPRESS«O DO RESUMO DOS T÷TULOS A VENCER */
    put stream s_1 unformatted skip(1).
    assign v_val_perc_avencer[1]       = (v_val_sdo_apres_avencer[1] / v_val_tot_sdo_avencer) * 100
           v_val_perc_geral_avencer[1] = (v_val_sdo_apres_avencer[1] / v_val_tot_sdo_normal) * 100.

    if v_val_perc_avencer[1] = ? then
        assign v_val_perc_avencer[1] = 0.

    if v_val_perc_geral_avencer[1] = ? then
        assign v_val_perc_geral_avencer[1] = 0.     

    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "Vl Saldo Apres" to 80
        "Quant" to 90
        "Percentual" to 105
        "Percentual Geral" to 124 skip
        "------------------" to 80
        "-----" to 90
        "----------" to 105
        "----------------" to 124 skip.
    if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "A Vencer atÇ: " at 36
        v_num_dias_avencer_1 to 53 format ">>>9"
        "Dias" at 55
        v_val_sdo_apres_avencer[1] to 80 format "->>,>>>,>>>,>>9.99"
        v_qtd_tit_acr_avencer[1] to 90 format ">>>>9"
        v_val_perc_avencer[1] to 105 format ">>9.99"
        v_val_perc_geral_avencer[1] to 124 format ">>9.99" skip.

    if  v_num_dias_avencer_2 <> 0
    then do:
        assign v_val_perc_avencer[2]       = (v_val_sdo_apres_avencer[2] / v_val_tot_sdo_avencer) * 100
               v_val_perc_geral_avencer[2] = (v_val_sdo_apres_avencer[2] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[2] = ? then
            assign v_val_perc_avencer[2] = 0.

        if v_val_perc_geral_avencer[2] = ? then
            assign v_val_perc_geral_avencer[2] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_avencer_2 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_avencer_3 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_avencer[2] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_avencer[2] to 90 format ">>>>9"
            v_val_perc_avencer[2] to 105 format ">>9.99"
            v_val_perc_geral_avencer[2] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_avencer_4 <> 0
    then do:
        assign v_val_perc_avencer[3]       = (v_val_sdo_apres_avencer[3] / v_val_tot_sdo_avencer) * 100
               v_val_perc_geral_avencer[3] = (v_val_sdo_apres_avencer[3] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[3] = ? then
            assign v_val_perc_avencer[3] = 0.

        if v_val_perc_geral_avencer[3] = ? then
            assign v_val_perc_geral_avencer[3] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_avencer_4 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_avencer_5 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_avencer[3] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_avencer[3] to 90 format ">>>>9"
            v_val_perc_avencer[3] to 105 format ">>9.99"
            v_val_perc_geral_avencer[3] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_avencer_6 <> 0
    then do:
        assign v_val_perc_avencer[4]       = (v_val_sdo_apres_avencer[4] / v_val_tot_sdo_avencer) * 100
               v_val_perc_geral_avencer[4] = (v_val_sdo_apres_avencer[4] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[4] = ? then
            assign v_val_perc_avencer[4] = 0.

        if v_val_perc_geral_avencer[4] = ? then
            assign v_val_perc_geral_avencer[4] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_avencer_6 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_avencer_7 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_avencer[4] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_avencer[4] to 90 format ">>>>9"
            v_val_perc_avencer[4] to 105 format ">>9.99"
            v_val_perc_geral_avencer[4] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_avencer_8 <> 0
    then do:
        assign v_val_perc_avencer[5]       = (v_val_sdo_apres_avencer[5] / v_val_tot_sdo_avencer) * 100
               v_val_perc_geral_avencer[5] = (v_val_sdo_apres_avencer[5] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[5] = ? then
            assign v_val_perc_avencer[5] = 0.

        if v_val_perc_geral_avencer[5] = ? then
            assign v_val_perc_geral_avencer[5] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "Mais de: " at 30
            v_num_dias_avencer_8 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_avencer_9 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_avencer[5] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_avencer[5] to 90 format ">>>>9"
            v_val_perc_avencer[5] to 105 format ">>9.99"
            v_val_perc_geral_avencer[5] to 124 format ">>9.99" skip.
    end /* if */.
    if  v_num_dias_avencer_10 <> 0
    then do:
        assign v_val_perc_avencer[6]       = (v_val_sdo_apres_avencer[6] / v_val_tot_sdo_avencer) * 100
               v_val_perc_geral_avencer[6] = (v_val_sdo_apres_avencer[6] / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[6] = ? then
            assign v_val_perc_avencer[6] = 0.

        if v_val_perc_geral_avencer[6] = ? then
            assign v_val_perc_geral_avencer[6] = 0.

        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "de: " at 35
            v_num_dias_avencer_10 to 42 format ">>>9"
            "atÇ: " at 45
            v_num_dias_avencer_11 to 53 format ">>>9"
            "Dias" at 55
            v_val_sdo_apres_avencer[6] to 80 format "->>,>>>,>>>,>>9.99".
    put stream s_1 unformatted 
            v_qtd_tit_acr_avencer[6] to 90 format ">>>>9"
            v_val_perc_avencer[6] to 105 format ">>9.99"
            v_val_perc_geral_avencer[6] to 124 format ">>9.99" skip.
    end /* if */.

    assign v_val_perc_avencer[7]       = (v_val_sdo_apres_avencer[7] / v_val_tot_sdo_avencer) * 100
           v_val_perc_geral_avencer[7] = (v_val_sdo_apres_avencer[7] / v_val_tot_sdo_normal) * 100
           v_val_perc_avencer[8]       = (v_val_tot_sdo_avencer / v_val_tot_sdo_avencer) * 100
           v_val_perc_geral_avencer[8] = (v_val_tot_sdo_avencer / v_val_tot_sdo_normal) * 100.

        if v_val_perc_avencer[7] = ? then
            assign v_val_perc_avencer[7] = 0.

        if v_val_perc_geral_avencer[7] = ? then
            assign v_val_perc_geral_avencer[7] = 0.

        if v_val_perc_avencer[8] = ? then
            assign v_val_perc_avencer[8] = 0.

        if v_val_perc_geral_avencer[8] = ? then
            assign v_val_perc_geral_avencer[8] = 0.

    if (line-counter(s_1) + 5) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        skip (1)
        "  Mais de: " at 39
        v_num_dias_avencer_12 to 53 format ">>>9"
        "Dias" at 55
        v_val_sdo_apres_avencer[7] to 80 format "->>,>>>,>>>,>>9.99"
        v_qtd_tit_acr_avencer[7] to 90 format ">>>>9"
        v_val_perc_avencer[7] to 105 format ">>9.99".
    put stream s_1 unformatted 
        v_val_perc_geral_avencer[7] to 124 format ">>9.99"
        skip (1)
        "     Total de T°tulos a Vencer" at 28
        ":" at 58
        v_val_tot_sdo_avencer to 80 format "->>>,>>>,>>>,>>9.99"
        v_qtd_tot_tit_avencer to 90 format ">>>,>>9"
        v_val_perc_avencer[8] to 105 format ">>9.99"
        v_val_perc_geral_avencer[8] to 124 format ">>9.99" skip (1).

    /* IMPRESS«O DAS TOTALIZAÄÂES GERAIS */
    assign v_val_tot_origin_geral = v_val_tot_origin_normal - v_val_tot_origin_antecip
           v_val_tot_sdo_geral    = v_val_tot_sdo_normal - v_val_tot_sdo_antecip.

    if (line-counter(s_1) + 6) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        skip (1)
        "    Total de T°tulos" at 38
        ":" at 58
        v_val_tot_sdo_normal to 80 format "->>>>,>>>,>>>,>>9.99"
        v_qtd_tot_tit_normal to 90 format ">>>,>>9"
        skip (1)
        "    Total Antecipado" at 38.
    put stream s_1 unformatted 
        ":" at 58
        v_val_tot_sdo_antecip to 80 format "->>>>,>>>,>>>,>>9.99"
        v_qtd_tot_tit_antecip to 90 format ">>>,>>9"
        skip (1)
        "Total Geral" at 47
        ":" at 58
        v_val_tot_sdo_geral to 80 format "->>>>,>>>,>>>,>>9.99" skip.
END PROCEDURE. /* pi_imp_sintetica_tit_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_rpt_aberto_gerac_planilha
** Descricao.............: pi_rpt_aberto_gerac_planilha
** Criado por............: Barth
** Criado em.............: 04/11/1999 10:14:14
** Alterado por..........: fut43120_2
** Alterado em...........: 17/12/2009 10:59:30
*****************************************************************************/
PROCEDURE pi_rpt_aberto_gerac_planilha:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tipo
        as character
        format "X(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_proces
        as character
        format "x(20)":U
        no-undo.
    def var v_cod_lista_label                as character       no-undo. /*local*/
    def var v_cod_ped_vda                    as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_fator                      as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* ** GERA PLANILHA ***/

    if  p_ind_tipo = "Ini" /*l_INI*/  then do:
        /* ** IMPRIME OS LABELS E ABRE A STREAM ***/
        output stream s_planilha to value(v_cod_arq_planilha) convert target 'iso8859-1'.

        if  v_log_visualiz_analit = yes then do:
            if v_log_nao_impr_tit = no then do:
                assign v_cod_lista_label =
                          &IF '{&emsfin_version}' >= '5.01' AND '{&emsfin_version}' <= '5.07' &THEN "Est" &ELSE "Est" &ENDIF + v_cod_carac_lim +
                          "Esp" + v_cod_carac_lim +
                          "Ser" + v_cod_carac_lim +
                          "T°tulo" + v_cod_carac_lim +
                          "/P" + v_cod_carac_lim +
                          "Un Neg" + v_cod_carac_lim +
                          "Cliente" + v_cod_carac_lim +
                          "Nome Abrev" + v_cod_carac_lim +
                          "Nome Cliente" + v_cod_carac_lim +
                          "Grp Cliente" + v_cod_carac_lim +
                          "Cliente Matriz" + v_cod_carac_lim +
                          "Port" + v_cod_carac_lim +
                          "Cart" + v_cod_carac_lim +
                          "Repres" + v_cod_carac_lim +
                          "Emiss∆o" + v_cod_carac_lim +
                          "Vencto" + v_cod_carac_lim +
                          "Liquidac" + v_cod_carac_lim +
                          "Refer" + v_cod_carac_lim +
                          "Tit Banco" + v_cod_carac_lim +
                          "Moeda" + v_cod_carac_lim +
                          "Val Original" + v_cod_carac_lim +
                          "Saldo" /*l_saldo*/  + v_cod_carac_lim +
                          "Saldo" /*l_saldo*/  + " " + "Apresentaá∆o" /*l_apresentacao*/  + v_cod_carac_lim +
                          (if  v_log_consid_juros then "Vl Juros" + v_cod_carac_lim else "") +
                          (if  v_log_consid_desc  then &IF '{&emsfin_version}' >= '5.01' AND '{&emsfin_version}' <= '9.99' &THEN "Vl Descto" &ELSE "Vl Descto" &ENDIF + v_cod_carac_lim else "") +
                          (if  v_log_consid_abat  then "Vl Abat" + v_cod_carac_lim else "") +
                          (if  v_log_consid_impto_retid then "Vl Impto" + v_cod_carac_lim else "") +
                          "Dias" /*l_dias*/  + v_cod_carac_lim +
                          "Pedido Venda" /*l_pedido_venda*/  + v_cod_carac_lim +
                          "Data Indic" + v_cod_carac_lim +
                          "Cond Cobr" + v_cod_carac_lim +
                          "Cidade" + v_cod_carac_lim +
                          "Telefone" + v_cod_carac_lim + 
                          "Cidade Cobranáa Cliente" /*l_cidad_cobr_cliente*/  + v_cod_carac_lim + 
                          "ID Federal" /*l_id_federal*/  + v_cod_carac_lim + 
                          "Unid Federac" /*l_uni_federac*/  +
                          if  v_ind_visualiz_tit_acr_vert =  "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then v_cod_carac_lim + "Processo Exportaá∆o" /*l_proces_export*/  else "" +
                          (if v_ind_classif_tit_acr_em_aber = "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then v_cod_carac_lim + "Conta" else "").
            end.
            else do:
                do  v_num_aux = 1 to 6:
                    if  entry(v_num_aux, v_cod_order_rpt) <> "" then do:
                        assign v_cod_lista_label = v_cod_lista_label
                                                 + entry(v_num_aux, v_cod_order_rpt)
                                                 + v_cod_carac_lim.

                        /* Ativ 172186 - Feito para tratar labels do Cod do Cliente adicionado na Ativ 131979*/                   
                        if entry(v_num_aux, v_cod_order_rpt) = "Cliente" then 
                            assign v_cod_lista_label = v_cod_lista_label
                                                     + "Cod Cliente" /*l_cod_cliente*/ 
                                                     + v_cod_carac_lim.    
                    end.
                end.
                assign v_cod_lista_label = v_cod_lista_label 
                                           + "Total" /*l_total*/ 
                                           + v_cod_carac_lim
                                           + "Cidade Cobranáa Cliente" /*l_cidad_cobr_cliente*/ .
            end.    
            put stream s_planilha unformatted v_cod_lista_label skip.
            return.
        end.
    end.

    if  p_ind_tipo = "put" /*l_PUT*/  then do:
        /* ** GERA A LINHA DO TITULO OU DO TOTAL CONFORME OPÄ«O "IMPRIME S‡ TOTAIS" ***/
        if  v_log_nao_impr_tit = no then do:                    
            if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/  then
                assign v_num_fator = -1.
            else
               assign v_num_fator  = 1.
            assign v_cod_ped_vda = "".
            for each ped_vda_tit_acr no-lock
                where ped_vda_tit_acr.cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                and   ped_vda_tit_acr.num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                break by ped_vda_tit_acr.num_id_tit_acr:
                if  first-of(ped_vda_tit_acr.num_id_tit_acr) then
                    assign v_cod_ped_vda = ped_vda_tit_acr.cod_ped_vda.
            end.

            find first tt_titulos_em_aberto_acr_compl no-lock
                 where tt_titulos_em_aberto_acr_compl.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                   and tt_titulos_em_aberto_acr_compl.tta_num_id_tit_acr = tt_titulos_em_aberto_acr.tta_num_id_tit_acr
                   and tt_titulos_em_aberto_acr_compl.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-error.

            find first cliente no-lock
                 where cliente.cod_empresa = v_cod_empres_usuar
                   and cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

            run pi_retornar_endereco_cobr_cliente(input tt_titulos_em_aberto_acr.tta_cdn_cliente).      

            if tt_titulos_em_aberto_acr.ttv_cod_proces_export = "" then
                assign v_cod_proces = "Sem Processo" /*l_sem_processo*/ .
            else
                assign v_cod_proces = tt_titulos_em_aberto_acr.ttv_cod_proces_export.


            put stream s_planilha unformatted
                tt_titulos_em_aberto_acr.tta_cod_estab       v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_espec_docto v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_ser_docto   v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_tit_acr     v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_parcela     v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_unid_negoc  v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cdn_cliente     v_cod_carac_lim
                tt_titulos_em_aberto_acr.ttv_nom_abrev_clien v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_nom_abrev       v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_grp_clien   v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cdn_clien_matriz v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_portador    v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_cart_bcia   v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cdn_repres      v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_dat_emis_docto  v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr v_cod_carac_lim
                if  tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr = ? then "" else string(tt_titulos_em_aberto_acr.tta_dat_liquidac_tit_acr) v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_refer       v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_tit_acr_bco v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_indic_econ  v_cod_carac_lim
                (tt_titulos_em_aberto_acr.tta_val_origin_tit_acr * v_num_fator)    v_cod_carac_lim
                (tt_titulos_em_aberto_acr.tta_val_sdo_tit_acr * v_num_fator)       v_cod_carac_lim
                (tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres * v_num_fator) v_cod_carac_lim
                if  v_log_consid_juros       then string(tt_titulos_em_aberto_acr.tta_val_juros) + v_cod_carac_lim else ""
                if  v_log_consid_desc        then string(tt_titulos_em_aberto_acr.tta_val_desc_tit_acr) + v_cod_carac_lim else ""
                if  v_log_consid_abat        then string(tt_titulos_em_aberto_acr.tta_val_abat_tit_acr) + v_cod_carac_lim else ""
                if  v_log_consid_impto_retid then string(tt_titulos_em_aberto_acr.ttv_val_impto_retid) + v_cod_carac_lim else ""
                tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr v_cod_carac_lim
                v_cod_ped_vda v_cod_carac_lim
                if  tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut = ? then "" else string(tt_titulos_em_aberto_acr.tta_dat_indcao_perda_dedut) v_cod_carac_lim
                tt_titulos_em_aberto_acr.tta_cod_cond_cobr v_cod_carac_lim
                if avail tt_titulos_em_aberto_acr_compl then tt_titulos_em_aberto_acr_compl.tta_nom_cidade   else "" v_cod_carac_lim
                if avail tt_titulos_em_aberto_acr_compl then tt_titulos_em_aberto_acr_compl.tta_cod_telefone else "" v_cod_carac_lim
                tt_titulos_em_aberto_acr.ttv_nom_cidad_cobr v_cod_carac_lim
                if avail cliente then cliente.cod_id_feder else "" v_cod_carac_lim
                v_cod_unid_federac
                if  v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then v_cod_carac_lim + v_cod_proces else "" 
                if v_ind_classif_tit_acr_em_aber = "Por Conta Cont†bil/EspÇcie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then  v_cod_carac_lim + v_cod_cta_ctbl else ""
                skip.
        end.
        else do:
            do  v_num_aux = 1 to 6:
                if  entry(v_num_aux, v_cod_order_rpt) <> "" then
                    put stream s_planilha unformatted
                        tt_titulos_em_aberto_acr.ttv_cod_dwb_field_rpt[v_num_aux]
                        v_cod_carac_lim.
            end.
            put stream s_planilha unformatted
                v_val_tot_sdo
                v_cod_carac_lim            
                tt_titulos_em_aberto_acr.ttv_nom_cidad_cobr            
                skip.
        end.
        return.
    end.

    if  p_ind_tipo = "close" /*l_CLOSE*/  then do:
        output stream s_planilha close.
        return.
    end.

END PROCEDURE. /* pi_rpt_aberto_gerac_planilha */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_endereco_cobr_cliente
** Descricao.............: pi_retornar_endereco_cobr_cliente
** Criado por............: bre17884
** Criado em.............: 29/02/2000 11:34:00
** Alterado por..........: corp45598
** Alterado em...........: 21/05/2013 16:58:50
*****************************************************************************/
PROCEDURE pi_retornar_endereco_cobr_cliente:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cdn_cliente
        as Integer
        format ">>>,>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_pessoa_jurid
        as integer
        format ">>>,>>>,>>9":U
        label "Pessoa Jur°dica"
        column-label "Pessoa Jur°dica"
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_nom_endereco      = " "
           v_nom_ender_compl   = " "
           v_nom_bairro        = " "
           v_cod_cx_post       = " "
           v_nom_condado       = " "
           v_nom_cidade        = " "
           v_cod_unid_federac  = " "
           v_cod_cep           = " "
           v_cod_cep_dest_cobr = " "
           v_cod_telefone      = " "
           v_cod_fax_dest      = " "
           v_cod_ender_eletron = " ".

    if  avail cliente
    then do:
        if  cliente.num_pessoa mod 2 = 0
        then do:
            find pessoa_fisic no-lock
                where pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa
                no-error.
            if  avail pessoa_fisic
            then do:
                find pais no-lock
                    where pais.cod_pais = pessoa_fisic.cod_pais
                    no-error.
                if  avail pais
                then do:
                    assign v_nom_endereco      = pessoa_fisic.nom_endereco
                           v_nom_ender_compl   = pessoa_fisic.nom_ender_compl
                           v_nom_bairro        = pessoa_fisic.nom_bairro
                           v_cod_cx_post       = pessoa_fisic.cod_cx_post
                           v_nom_condado       = pessoa_fisic.nom_condado
                           v_nom_cidade        = pessoa_fisic.nom_cidade
                           v_cod_unid_federac  = pessoa_fisic.cod_unid_federac
                           v_cod_cep           = string(pessoa_fisic.cod_cep, pais.cod_format_cep)
                           v_cod_cep_dest_cobr = pessoa_fisic.cod_cep
                           v_cod_telefone      = pessoa_fisic.cod_telefone
                           v_cod_fax_dest      = pessoa_fisic.cod_fax
                           v_cod_ender_eletron = pessoa_fisic.cod_e_mail.
                    if  v_log_pessoa_fisic_cobr
                    then do:
                        &if '{&emsfin_version}' >= '5.07' &then
                            if  pessoa_fisic.nom_ender_cobr <> ''
                            then do:
                                assign v_nom_endereco      = pessoa_fisic.nom_ender_cobr
                                       v_cod_cep           = string(pessoa_fisic.cod_cep_cobr, pais.cod_format_cep)
                                       v_nom_ender_compl   = pessoa_fisic.nom_ender_compl_cobr
                                       v_nom_bairro        = pessoa_fisic.nom_bairro_cobr
                                       v_cod_cx_post       = pessoa_fisic.cod_cx_post_cobr
                                       v_nom_condado       = pessoa_fisic.nom_condad_cobr
                                       v_nom_cidade        = pessoa_fisic.nom_cidad_cobr
                                       v_cod_unid_federac  = pessoa_fisic.cod_unid_federac_cobr
                                       v_cod_cep_dest_cobr = pessoa_fisic.cod_cep_cobr
                                       v_cod_telefone      = pessoa_fisic.cod_telefone
                                       v_cod_fax_dest      = pessoa_fisic.cod_fax
                                       v_cod_ender_eletron = pessoa_fisic.cod_e_mail.
                            end.
                        &else
                            find first tab_livre_emsuni no-lock
                                 where tab_livre_emsuni.cod_modul_dtsul    = 'utb'
                                 and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                 and tab_livre_emsuni.cod_compon_1_idx_tab = STRING(0)
                                 and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.
                            if not avail tab_livre_emsuni then do:
                                find first tab_livre_emsuni no-lock
                                     where tab_livre_emsuni.cod_modul_dtsul    = 'utb'
                                       and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                       and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.                             

                            end.                                                 
                            if avail tab_livre_emsuni and
                               GetEntryField(4,  tab_livre_emsuni.cod_livre_1, chr(10)) <> '' then
                                assign v_nom_endereco      = GetEntryField(4,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_cod_cep           = string(GetEntryField(8, tab_livre_emsuni.cod_livre_1, chr(10)), pais.cod_format_cep)
                                       v_nom_ender_compl   = GetEntryField(6,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_nom_bairro        = GetEntryField(7,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_cod_cx_post       = GetEntryField(11, tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_nom_condado       = GetEntryField(10, tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_nom_cidade        = GetEntryField(9,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_cod_unid_federac  = GetEntryField(3,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_cod_cep_dest_cobr = GetEntryField(8,  tab_livre_emsuni.cod_livre_1, chr(10))
                                       v_cod_telefone      = pessoa_fisic.cod_telefone
                                       v_cod_fax_dest      = pessoa_fisic.cod_fax
                                       v_cod_ender_eletron = GetEntryField(12, tab_livre_emsuni.cod_livre_1, chr(10)).
                        &endif
                    end.
                end.
            end.
        end.
        else do:
            find pessoa_jurid no-lock
                where pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa
                no-error.
            if  avail pessoa_jurid
            and pessoa_jurid.num_pessoa_jurid_cobr <> pessoa_jurid.num_pessoa_jurid
            and pessoa_jurid.num_pessoa_jurid_cobr <> ?
            and pessoa_jurid.num_pessoa_jurid_cobr <> 0
            then do:
                assign v_num_pessoa_jurid = pessoa_jurid.num_pessoa_jurid_cobr.
                find pessoa_jurid no-lock
                    where pessoa_jurid.num_pessoa_jurid = v_num_pessoa_jurid
                    no-error.
            end.

            if  avail pessoa_jurid
            then do:
                find pais no-lock
                    where pais.cod_pais = pessoa_jurid.cod_pais
                    no-error.
                if  avail pais
                then do:
                    if  pessoa_jurid.nom_ender_cobr = ""
                    then do:
                        assign v_nom_endereco      = pessoa_jurid.nom_endereco
                               v_cod_cep           = string(pessoa_jurid.cod_cep, pais.cod_format_cep)
                               v_nom_ender_compl   = pessoa_jurid.nom_ender_compl
                               v_nom_bairro        = pessoa_jurid.nom_bairro
                               v_cod_cx_post       = pessoa_jurid.cod_cx_post
                               v_nom_condado       = pessoa_jurid.nom_condado
                               v_nom_cidade        = pessoa_jurid.nom_cidade
                               v_cod_unid_federac  = pessoa_jurid.cod_unid_federac
                               v_cod_cep           = string(pessoa_jurid.cod_cep, pais.cod_format_cep)
                               v_cod_cep_dest_cobr = pessoa_jurid.cod_cep
                               v_cod_telefone      = pessoa_jurid.cod_telefone
                               v_cod_fax_dest      = pessoa_jurid.cod_fax
                               v_cod_ender_eletron = pessoa_jurid.cod_e_mail.
                    end.
                    else do:
                        assign v_nom_endereco      = pessoa_jurid.nom_ender_cobr
                               v_cod_cep           = string(pessoa_jurid.cod_cep_cobr, pais.cod_format_cep)
                               v_nom_ender_compl   = pessoa_jurid.nom_ender_compl_cobr
                               v_nom_bairro        = pessoa_jurid.nom_bairro_cobr
                               v_cod_cx_post       = pessoa_jurid.cod_cx_post_cobr
                               v_nom_condado       = pessoa_jurid.nom_condad_cobr
                               v_nom_cidade        = pessoa_jurid.nom_cidad_cobr
                               v_cod_unid_federac  = pessoa_jurid.cod_unid_federac_cobr
                               v_cod_cep           = string(pessoa_jurid.cod_cep_cobr, pais.cod_format_cep)
                               v_cod_cep_dest_cobr = pessoa_jurid.cod_cep_cobr
                               v_cod_telefone      = pessoa_jurid.cod_telefone
                               v_cod_fax_dest      = pessoa_jurid.cod_fax
                               v_cod_ender_eletron = pessoa_jurid.cod_e_mail.
                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_retornar_endereco_cobr_cliente */
/*****************************************************************************
** Procedure Interna.....: pi_retorna_juros_compostos
** Descricao.............: pi_retorna_juros_compostos
** Criado por............: bre18490
** Criado em.............: 12/01/2001 21:09:04
** Alterado por..........: bre18490
** Alterado em...........: 21/05/2001 11:27:35
*****************************************************************************/
PROCEDURE pi_retorna_juros_compostos:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_calc_juros
        as character
        format "X(10)"
        no-undo.
    def Input param p_val_perc_juros_acr
        as decimal
        format ">>9.99"
        decimals 2
        no-undo.
    def Input param p_val_principal
        as decimal
        format ">>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_num_dias_atraso
        as integer
        format ">9"
        no-undo.
    def output param p_val_juros_aux
        as decimal
        format ">>>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_cont
        as integer
        format ">,>>9":U
        initial 0
        no-undo.
    def var v_val_juros_calc_aux
        as decimal
        format "->>,>>>,>>9.999999":U
        decimals 6
        no-undo.


    /************************** Variable Definition End *************************/

    if  p_ind_tip_calc_juros <> "Compostos" /*l_compostos*/  then do:
        assign p_val_juros_aux = ?.
        return.
    end.

    do  v_num_cont = 1 to p_num_dias_atraso:
        assign v_val_juros_calc_aux = v_val_juros_calc_aux + ((p_val_principal + v_val_juros_calc_aux) * p_val_perc_juros_acr / 100 ).
    end.

    assign p_val_juros_aux = v_val_juros_calc_aux.

END PROCEDURE. /* pi_retorna_juros_compostos */
/*****************************************************************************
** Procedure Interna.....: pi_aging_acr
** Descricao.............: pi_aging_acr
** Criado por............: src388
** Criado em.............: 07/03/2002 11:11:32
** Alterado por..........: fut41190
** Alterado em...........: 03/09/2008 14:42:06
*****************************************************************************/
PROCEDURE pi_aging_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_log_show_aging_planilha
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_val_saldo_clien
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_val_tot_docto
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_num_fill                       as integer         no-undo. /*local*/
    def var v_num_pos                        as integer         no-undo. /*local*/
    def var v_val_tot                        as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  v_log_funcao_aging_acr = yes and v_log_visualiz_clien = yes
    then do:
        assign v_des_div = ""
               v_des_labels_vencto = ""
               v_des_valores_valores = ""
               v_des_div_2 = ""
               v_des_labels_vencto_1 = ""
               v_des_valores_valores_2 = "".

        find first tt_valores_prazo
            where tt_valores_prazo.tta_cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

        assign v_val_tot = tt_valores_prazo.ttv_val_tot_sdo_vencid + tt_valores_prazo.ttv_val_tot_sdo_avencer.

        /* Atualiza layout t°tulos vencidos */

        /* Begin_Include: i_atualiza_variaveis_layout */
        assign v_des_div = fill('-',17) + ' '
               v_des_labels_vencto = string(v_num_dias_vencid_1) + ' '
               v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[1],'->>>>>,>>>,>>9.99') + ' '.

        if v_num_dias_vencid_2 <> 0 then do:
            assign v_des_div = v_des_div + fill('-',17) + ' '
                   v_num_fill = 14 - length(string(v_num_dias_vencid_2)) - length(string(v_num_dias_vencid_3))
                   v_des_labels_vencto = v_des_labels_vencto + fill(' ',v_num_fill) +
                                         string(v_num_dias_vencid_2) + ' - ' +
                                         string(v_num_dias_vencid_3) + ' '
                   v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[2],'->>>>>,>>>,>>9.99') + ' '.
            if v_num_dias_vencid_4 <> 0 then do:
                assign v_des_div = v_des_div + fill('-',17) + ' '
                       v_num_fill = 14 - length(string(v_num_dias_vencid_4)) - length(string(v_num_dias_vencid_5))
                       v_des_labels_vencto = v_des_labels_vencto + fill(' ',v_num_fill) +
                                             string(v_num_dias_vencid_4) + ' - ' +
                                             string(v_num_dias_vencid_5) + ' '
                       v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[3],'->>>>>,>>>,>>9.99') + ' '.
                if v_num_dias_vencid_6 <> 0 then do:
                    assign v_des_div = v_des_div + fill('-',17) + ' '
                           v_num_fill = 14 - length(string(v_num_dias_vencid_6)) - length(string(v_num_dias_vencid_7))
                           v_des_labels_vencto = v_des_labels_vencto + fill(' ',v_num_fill) +
                                                 string(v_num_dias_vencid_6) + ' - ' +
                                                 string(v_num_dias_vencid_7) + ' '
                           v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[4],'->>>>>,>>>,>>9.99') + ' '.
                    if v_num_dias_vencid_8 <> 0 then do:
                        assign v_des_div = v_des_div + fill('-',17) + ' '
                               v_num_fill = 14 - length(string(v_num_dias_vencid_8)) - length(string(v_num_dias_vencid_9))
                               v_des_labels_vencto = v_des_labels_vencto + fill(' ',v_num_fill) +
                                                     string(v_num_dias_vencid_8) + ' - ' +
                                                     string(v_num_dias_vencid_9) + ' '
                               v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[5],'->>>>>,>>>,>>9.99') + ' '.
                        if v_num_dias_vencid_10 <> 0 then
                            assign v_des_div = v_des_div + fill('-',17) + ' '
                                   v_num_fill = 14 - length(string(v_num_dias_vencid_10)) - length(string(v_num_dias_vencid_11))
                                   v_des_labels_vencto = v_des_labels_vencto + fill(' ',v_num_fill) +
                                                         string(v_num_dias_vencid_10) + ' - ' +
                                                         string(v_num_dias_vencid_11) + ' '
                                   v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[6],'->>>>>,>>>,>>9.99') + ' '.
                    end.
                end.
            end.
        end.
        assign v_des_div = v_des_div + fill('-',17) + ' '
               v_num_fill = 15 - length(string(v_num_dias_vencid_12))
               v_des_labels_vencto = v_des_labels_vencto +  fill(' ',v_num_fill) +
                                     string(v_num_dias_vencid_12) + ' +'
               v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_sdo_apres_vencid[7],'->>>>>,>>>,>>9.99') + ' '.
        /* End_Include: i_atualiza_variaveis_layout */
        .
        /* total vencido */
        assign v_des_div = v_des_div + fill('-',17)
               v_des_labels_vencto = v_des_labels_vencto + fill(' ',4) + "Total Vencidos" /*l_tot_vencto*/ 
               v_des_valores_valores = v_des_valores_valores + string(tt_valores_prazo.ttv_val_tot_sdo_vencid,'->>>>>,>>>,>>9.99').

        /* Atualiza layout t°tulos a vencer */

        /* Begin_Include: i_atualiza_variaveis_layout */
        assign v_des_div_2 = fill('-',17) + ' '
               v_des_labels_vencto_1 = string(v_num_dias_avencer_1) + ' '
               v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[1],'->>>>>,>>>,>>9.99') + ' '.

        if v_num_dias_avencer_2 <> 0 then do:
            assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
                   v_num_fill = 14 - length(string(v_num_dias_avencer_2)) - length(string(v_num_dias_avencer_3))
                   v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',v_num_fill) +
                                         string(v_num_dias_avencer_2) + ' - ' +
                                         string(v_num_dias_avencer_3) + ' '
                   v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[2],'->>>>>,>>>,>>9.99') + ' '.
            if v_num_dias_avencer_4 <> 0 then do:
                assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
                       v_num_fill = 14 - length(string(v_num_dias_avencer_4)) - length(string(v_num_dias_avencer_5))
                       v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',v_num_fill) +
                                             string(v_num_dias_avencer_4) + ' - ' +
                                             string(v_num_dias_avencer_5) + ' '
                       v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[3],'->>>>>,>>>,>>9.99') + ' '.
                if v_num_dias_avencer_6 <> 0 then do:
                    assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
                           v_num_fill = 14 - length(string(v_num_dias_avencer_6)) - length(string(v_num_dias_avencer_7))
                           v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',v_num_fill) +
                                                 string(v_num_dias_avencer_6) + ' - ' +
                                                 string(v_num_dias_avencer_7) + ' '
                           v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[4],'->>>>>,>>>,>>9.99') + ' '.
                    if v_num_dias_avencer_8 <> 0 then do:
                        assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
                               v_num_fill = 14 - length(string(v_num_dias_avencer_8)) - length(string(v_num_dias_avencer_9))
                               v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',v_num_fill) +
                                                     string(v_num_dias_avencer_8) + ' - ' +
                                                     string(v_num_dias_avencer_9) + ' '
                               v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[5],'->>>>>,>>>,>>9.99') + ' '.
                        if v_num_dias_avencer_10 <> 0 then
                            assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
                                   v_num_fill = 14 - length(string(v_num_dias_avencer_10)) - length(string(v_num_dias_avencer_11))
                                   v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',v_num_fill) +
                                                         string(v_num_dias_avencer_10) + ' - ' +
                                                         string(v_num_dias_avencer_11) + ' '
                                   v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[6],'->>>>>,>>>,>>9.99') + ' '.
                    end.
                end.
            end.
        end.
        assign v_des_div_2 = v_des_div_2 + fill('-',17) + ' '
               v_num_fill = 15 - length(string(v_num_dias_avencer_12))
               v_des_labels_vencto_1 = v_des_labels_vencto_1 +  fill(' ',v_num_fill) +
                                     string(v_num_dias_avencer_12) + ' +'
               v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_sdo_apres_avencer[7],'->>>>>,>>>,>>9.99') + ' '.
        /* End_Include: i_atualiza_variaveis_layout */
        .
        if  v_log_gerac_planilha = yes 
        AND p_log_show_aging_planilha = YES then do:
            find cliente no-lock
                where cliente.cod_empresa = v_cod_empres_usuar
                and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

            put stream s_planilha unformatted
                tt_titulos_em_aberto_acr.tta_cdn_cliente      v_cod_carac_lim
                cliente.nom_pessoa                            v_cod_carac_lim
                tt_valores_prazo.ttv_val_sdo_apres_vencid[1]  v_cod_carac_lim.

             if  v_num_dias_vencid_2 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_vencid[2]  v_cod_carac_lim.

             if  v_num_dias_vencid_4 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_vencid[3]  v_cod_carac_lim.

             if  v_num_dias_vencid_6 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_vencid[4]  v_cod_carac_lim.

             if  v_num_dias_vencid_8 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_vencid[5]  v_cod_carac_lim.

             if  v_num_dias_vencid_10 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_vencid[6]  v_cod_carac_lim.

             put stream s_planilha unformatted
                 tt_valores_prazo.ttv_val_sdo_apres_vencid[7]  v_cod_carac_lim
                 tt_valores_prazo.ttv_val_sdo_apres_avencer[1] v_cod_carac_lim.

             if  v_num_dias_avencer_2 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_avencer[2] v_cod_carac_lim.

             if  v_num_dias_avencer_4 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_avencer[3] v_cod_carac_lim.

             if  v_num_dias_avencer_6 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_avencer[4] v_cod_carac_lim.

             if  v_num_dias_avencer_8 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_avencer[5] v_cod_carac_lim.            
             if  v_num_dias_avencer_10 <> 0 then
                put stream s_planilha unformatted
                    tt_valores_prazo.ttv_val_sdo_apres_avencer[6] v_cod_carac_lim.

             assign v_val_tot_docto = tt_valores_prazo.ttv_val_sdo_apres_avencer[1] 
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[2]
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[3]
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[4]
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[5]
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[6]
                                     + tt_valores_prazo.ttv_val_sdo_apres_avencer[7]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[1]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[2]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[3]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[4]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[5]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[6]
                                     + tt_valores_prazo.ttv_val_sdo_apres_vencid[7]
                    v_val_saldo_clien = v_val_tot_docto - tt_valores_prazo.ttv_val_tot_antecip.


             put stream s_planilha unformatted
                 tt_valores_prazo.ttv_val_sdo_apres_avencer[7] v_cod_carac_lim
                 v_val_tot_docto                              v_cod_carac_lim 
                 (tt_valores_prazo.ttv_val_tot_antecip * (-1)) v_cod_carac_lim
                 v_val_saldo_clien                             skip.
        end.    
        /* total a vencer */
        assign v_des_div_2 = v_des_div_2 + fill('-',17)
               v_des_labels_vencto_1 = v_des_labels_vencto_1 + fill(' ',4) + "Total A Vencer" /*l_total_avencer*/ 
               v_des_valores_valores_2 = v_des_valores_valores_2 + string(tt_valores_prazo.ttv_val_tot_sdo_avencer,'->>>>>,>>>,>>9.99')
               v_des_label_1 = "Total T°tulos:" /*l_tot_titulos*/ 
               v_des_label_2 = "Total Antecipaá∆o:" /*l_tot_antecip*/ 
               v_des_label_3 = "Total Geral:" /*l_total_geral_cmg*/ .

        assign v_num_pos = index(v_des_labels_vencto_1,'+').

        if (line-counter(s_1) + 11) > v_rpt_s_1_bottom then
            page stream s_1.

        put stream s_1 unformatted skip(1).
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "Resumo do Cliente    " at 1 skip.

        /* Valores Vencidos */
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "Vencidos atÇ:" at 24
            /* objeto  ignorado. N∆o foi encontrado esse objeto */
            v_des_labels_vencto at 39 format "x(200)" skip.
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            v_des_div at 24 format "x(200)" skip.
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            v_des_valores_valores at 24 format "x(200)" skip.

        put stream s_1 unformatted skip(1).
        /* Valores a Vencer */
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "A Vencer atÇ:" at 24
            /* objeto  ignorado. N∆o foi encontrado esse objeto */
            v_des_labels_vencto_1 at 39 format "x(200)" skip.
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            v_des_div_2 at 24 format "x(200)" skip.
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            v_des_valores_valores_2 at 24 format "x(200)" skip.

        if (line-counter(s_1) + 5) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted
            skip(1)
            v_des_label_1 at ((v_num_pos + 39) - length(trim(v_des_label_1))) ' ' v_val_tot format '->>>>>,>>>,>>9.99' skip
            v_des_label_2 at ((v_num_pos + 39) - length(trim(v_des_label_2))) ' ' tt_valores_prazo.ttv_val_tot_antecip format '->>>>>,>>>,>>9.99' skip
            v_des_label_3 at ((v_num_pos + 39) - length(trim(v_des_label_3))) ' ' (v_val_tot - tt_valores_prazo.ttv_val_tot_antecip) format '->>>>>,>>>,>>9.99' skip(1).

    end /* if */.
END PROCEDURE. /* pi_aging_acr */
/*****************************************************************************
** Procedure Interna.....: pi_ix_p02_rpt_tit_acr_em_aberto
** Descricao.............: pi_ix_p02_rpt_tit_acr_em_aberto
** Criado por............: src388
** Criado em.............: 07/03/2002 11:18:33
** Alterado por..........: fut42625_3
** Alterado em...........: 15/02/2011 11:43:09
*****************************************************************************/
PROCEDURE pi_ix_p02_rpt_tit_acr_em_aberto:

    if  dwb_rpt_param.cod_dwb_parameters <> ""
    and num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 92 then
    leitura_parametros:
    do on error undo leitura_parametros, leave :
        assign v_dat_tit_acr_aber              = date(entry(1, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cod_finalid_econ              = entry(2, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_finalid_econ_apres        = entry(3, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_dat_cotac_indic_econ          = date(entry(4, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_val_cotac_indic_econ          = decimal(entry(5, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_ind_visualiz_tit_acr_vert     = entry(6, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_log_visualiz_analit           = (entry(7, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_visualiz_sint             = (entry(8, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_mostra_docto_acr_antecip  = (entry(9, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_mostra_docto_acr_prev     = (entry(10, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_mostra_docto_acr_normal   = (entry(11, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_mostra_docto_acr_aviso_db = (entry(12, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tit_acr_vencid            = (entry(13, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_qtd_dias_vencid               = decimal(entry(14, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_log_emit_movto_cobr           = (entry(15, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_dat_calc_atraso               = date(entry(16, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_log_tit_acr_avencer           = (entry(17, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_qtd_dias_avencer              = decimal(entry(18, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               no-error.
        if error-status:error then undo leitura_parametros, leave leitura_parametros.

        assign v_cdn_cliente_ini              = integer(entry(19, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_cliente_fim              = integer(entry(20, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_repres_ini               = integer(entry(21, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_repres_fim               = integer(entry(22, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cod_cart_bcia_ini            = entry(23, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_cart_bcia_fim            = entry(24, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_espec_docto_ini          = entry(25, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_espec_docto_fim          = entry(26, dwb_rpt_param.cod_dwb_parameters, chr(10))
               /* Projeto 99 - Retirada a faixa de estabelecimentos */
               v_cod_portador_ini             = entry(29, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_portador_fim             = entry(30, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_unid_negoc_ini           = entry(31, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_unid_negoc_fim           = entry(32, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_dat_vencto_tit_acr_ini       = date(entry(33, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_dat_vencto_tit_acr_fim       = date(entry(34, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_clien_matriz_ini         = integer(entry(35, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_clien_matriz_fim         = integer(entry(36, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               no-error.
        if error-status:error then undo leitura_parametros, leave leitura_parametros.

        assign v_ind_classif_tit_acr_em_aber = entry(37, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_log_classif_estab           = (entry(38, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_clien               = (entry(39, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_estab               = (entry(40, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_matriz              = (entry(41, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_portad_cart         = (entry(42, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_repres              = (entry(43, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_vencto              = (entry(44, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_cod_order_rpt               = entry(45, dwb_rpt_param.cod_dwb_parameters, chr(10))
               no-error.
        if error-status:error then undo leitura_parametros, leave leitura_parametros.

        assign v_num_dias_avencer_1        = integer(entry(46, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_2        = integer(entry(47, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_3        = integer(entry(48, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_4        = integer(entry(49, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_5        = integer(entry(50, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_6        = integer(entry(51, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_7        = integer(entry(52, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_8        = integer(entry(53, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_9        = integer(entry(54, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_10       = integer(entry(55, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_11       = integer(entry(56, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_avencer_12       = integer(entry(57, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_1         = integer(entry(58, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_2         = integer(entry(59, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_3         = integer(entry(60, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_4         = integer(entry(61, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_5         = integer(entry(62, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_6         = integer(entry(63, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_7         = integer(entry(64, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_8         = integer(entry(65, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_9         = integer(entry(66, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_10        = integer(entry(67, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_11        = integer(entry(68, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_num_dias_vencid_12        = integer(entry(69, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_log_mostra_docto_acr_cheq = (entry(70, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_cod_grp_clien_ini         = entry(71, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_grp_clien_fim         = entry(72, dwb_rpt_param.cod_dwb_parameters, chr(10))
               no-error.
        if error-status:error then undo leitura_parametros, leave leitura_parametros.

        assign v_log_tot_grp_clien              = (entry(73, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tit_acr_estordo            = (entry(74, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tot_cond_cobr              = (entry(75, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_cod_cond_cobr_ini              =  entry(76, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_cond_cobr_fim              =  entry(77, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_log_consid_abat                = (entry(78, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_consid_desc                = (entry(79, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_consid_impto_retid         = (entry(80, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tit_acr_indcao_perda_dedut = (entry(81, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_tit_acr_nao_indcao_perda   = (entry(82, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_consid_juros               = (entry(83, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_nao_impr_tit               = (entry(84, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_log_gerac_planilha             = (entry(85, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               v_cod_arq_planilha               =  entry(86, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_carac_lim                  =  entry(87, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_log_tot_espec_docto            = (entry(88, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
               no-error.
        if error-status:error then undo leitura_parametros, leave leitura_parametros.

        assign v_des_estab_select = (entry(89, dwb_rpt_param.cod_dwb_parameters, chr(10))).

        run pi_vld_estab_select(Input "ACR" /*l_acr*/ ).

        if  v_log_funcao_aging_acr = yes
        then do:
            assign v_log_visualiz_clien = (entry(90, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes') no-error.
            if error-status:error then undo leitura_parametros, leave leitura_parametros.
        end /* if */.

        if  v_log_control_terc_acr = yes
        then do:
            assign v_log_tip_espec_docto_terc      = (entry(91, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
                   v_log_tip_espec_docto_cheq_terc = (entry(92, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
            no-error.
            if error-status:error then undo leitura_parametros, leave leitura_parametros.
        end /* if */.

        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) > 92 then do:
            /* ==> MODULO VENDOR <== */
             assign v_log_mostra_docto_vendor        = (entry(93, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes') 
                    v_log_mostra_docto_vendor_repac  = (entry(94, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes') no-error.
             if error-status:error then undo leitura_parametros, leave leitura_parametros.
        end.
        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 96 then do:
             assign v_cod_indic_econ_ini             =  entry(95, dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_cod_indic_econ_fim             =  entry(96, dwb_rpt_param.cod_dwb_parameters, chr(10)).
        end.
        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 97 then
            assign v_log_consid_multa =  (entry(97, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes').

        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 98 then
             assign v_cod_proces_export_ini     =  entry(98,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_cod_proces_export_fim     =  entry(99,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_log_tot_num_proces_export = (entry(100, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes').

        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 101 then  
             assign v_dat_emis_docto_ini       = date(entry(101,  dwb_rpt_param.cod_dwb_parameters, chr(10)))
                    v_dat_emis_docto_fim       = date(entry(102,  dwb_rpt_param.cod_dwb_parameters, chr(10)))
                    v_cod_plano_cta_ctbl_inic  = entry(103,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_cod_plano_cta_ctbl_final = entry(104,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_cod_cta_ctbl_ini         = entry(105,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_cod_cta_ctbl_final       = entry(106,  dwb_rpt_param.cod_dwb_parameters, chr(10))
                    v_log_classif_un           = (entry(107,  dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
                    v_log_tot_cta              = (entry(108,  dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
                    v_log_tot_unid_negoc       = (entry(109,  dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes').

        &if defined(BF_FIN_CONTROL_CHEQUES) &then                                
            assign v_log_mostra_acr_cheq_recbdo = (getEntryField(110, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
    	       v_log_mostra_acr_cheq_devolv = (getEntryField(111, dwb_rpt_param.cod_dwb_parameters, chr(10)) = 'yes')
            no-error.
    	if error-status:error then undo leitura_parametros, leave leitura_parametros.
    	assign error-status:error = no.
        &endif            

        if  v_cod_dwb_user     begins 'es_'
        and v_cod_arq_planilha <> "" then do:
            /* ** VALIDA DIRET‡RIO DA PLANILHA ***/
            find servid_exec no-lock 
                where servid_exec.cod_servid_exec = ped_exec.cod_servid_exec no-error.
            assign v_cod_arq_planilha  = servid_exec.nom_dir_spool + '/' + v_cod_arq_planilha
                   v_cod_arq_planilha  = replace(v_cod_arq_planilha, '~\', '~/')
                   file-info:file-name = substring(v_cod_arq_planilha, 1, r-index(v_cod_arq_planilha, '~/') - 1).
            if  file-info:file-name <> ""
            and file-info:file-type = ? then
                return "Diret¢rio Inexistente:" /*l_directory*/  + v_cod_arq_planilha.
        end.
    end.
    else do:
        assign v_cod_order_rpt = " , , , , , "
               v_dat_cotac_indic_econ = today
               v_num_dias_avencer_6   = 91
               v_num_dias_vencid_6    = 91.
        run pi_vld_permissao_usuar_estab_empres (Input "ACR" /*l_acr*/ ).
    end.
END PROCEDURE. /* pi_ix_p02_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_aging_acr_more
** Descricao.............: pi_aging_acr_more
** Criado por............: src388
** Criado em.............: 12/03/2002 16:35:04
** Alterado por..........: fut1228
** Alterado em...........: 31/05/2007 17:56:41
*****************************************************************************/
PROCEDURE pi_aging_acr_more:

    if  v_log_funcao_aging_acr = yes and
       (v_log_visualiz_analit = no   and
        v_log_visualiz_clien  = yes)
    then do:
        if  v_log_gerac_planilha = yes then do:
            put stream s_planilha unformatted
                "Cliente" /*l_cliente*/   v_cod_carac_lim
                "Nome" /*l_nome*/       v_cod_carac_lim
                "Vencido atÇ" /*l_vencido_ate*/   v_num_dias_vencid_1    v_cod_carac_lim.
            if  v_num_dias_vencid_2 <> 0 then
                put stream s_planilha unformatted
                   "Vencido de" /*l_vencido_de*/   v_num_dias_vencid_2   "atÇ" /*l_ate*/  v_num_dias_vencid_3  v_cod_carac_lim.
            if  v_num_dias_vencid_4 <> 0 then
                put stream s_planilha unformatted
                   "Vencido de" /*l_vencido_de*/  v_num_dias_vencid_4    "atÇ" /*l_ate*/  v_num_dias_vencid_5  v_cod_carac_lim.
            if  v_num_dias_vencid_6 <> 0 then
                put stream s_planilha unformatted
                    "Vencido de" /*l_vencido_de*/   v_num_dias_vencid_6  "atÇ" /*l_ate*/  v_num_dias_vencid_7 v_cod_carac_lim.
            if  v_num_dias_vencid_8 <> 0 then
                put stream s_planilha unformatted
                    "Vencido de" /*l_vencido_de*/  v_num_dias_vencid_8   "atÇ" /*l_ate*/  v_num_dias_vencid_9  v_cod_carac_lim.
            if  v_num_dias_vencid_10 <> 0 then
                put stream s_planilha unformatted
                    "Vencido de" /*l_vencido_de*/  v_num_dias_vencid_10  "atÇ" /*l_ate*/  v_num_dias_vencid_11 v_cod_carac_lim.

            put stream s_planilha unformatted        
               "Vencido a mais de" /*l_vencido_mais_de*/  v_num_dias_vencid_12  v_cod_carac_lim    
               "A Vencer atÇ" /*l_a_venc_ate*/       v_num_dias_avencer_1  v_cod_carac_lim.

            if  v_num_dias_avencer_2 <> 0 then
                put stream s_planilha unformatted
                "A vencer de" /*l_a_vencer_de*/  v_num_dias_avencer_2 "atÇ" /*l_ate*/  v_num_dias_avencer_3   v_cod_carac_lim.
            if  v_num_dias_avencer_4 <> 0 then
                put stream s_planilha unformatted
                "A vencer de" /*l_a_vencer_de*/  v_num_dias_avencer_4  "atÇ" /*l_ate*/  v_num_dias_avencer_5  v_cod_carac_lim.
            if  v_num_dias_avencer_6 <> 0 then
                put stream s_planilha unformatted
                "A vencer de" /*l_a_vencer_de*/  v_num_dias_avencer_6  "atÇ" /*l_ate*/  v_num_dias_avencer_7  v_cod_carac_lim.
            if  v_num_dias_avencer_8 <> 0 then
                put stream s_planilha unformatted
                "A vencer de" /*l_a_vencer_de*/  v_num_dias_avencer_8  "atÇ" /*l_ate*/  v_num_dias_avencer_9  v_cod_carac_lim.
            if  v_num_dias_avencer_10 <> 0 then
                put stream s_planilha unformatted
                "A vencer de" /*l_a_vencer_de*/  v_num_dias_avencer_10 "atÇ" /*l_ate*/  v_num_dias_avencer_11 v_cod_carac_lim.

            put stream s_planilha unformatted
               "A vencer a mais de" /*l_a_vencer_a_mais_de*/  v_num_dias_avencer_12 v_cod_carac_lim        
               "Total Normal" /*l_total_normal*/        v_cod_carac_lim
               "Total Antecipaá∆o" /*l_total_antecipacao*/   v_cod_carac_lim
               "Saldo do Cliente" /*l_saldo_cliente*/       SKIP.
        end.

        for each tt_titulos_em_aberto_acr
           WHERE tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
             AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
            break by tt_titulos_em_aberto_acr.tta_cod_empresa
                  by tt_titulos_em_aberto_acr.tta_cdn_cliente:

            if  first-of(tt_titulos_em_aberto_acr.tta_cod_empresa)
            then do:
                find empresa no-lock
                    where empresa.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa no-error.
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    "Empresa: " at 18
                    tt_titulos_em_aberto_acr.tta_cod_empresa at 27 format "x(3)"
                    "-" at 34
                    if avail empresa then empresa.nom_razao_social else "" at 36 format "x(40)" skip.
            end /* if */.

            if  first-of(tt_titulos_em_aberto_acr.tta_cdn_cliente)
            then do:
                find cliente no-lock
                    where cliente.cod_empresa = tt_titulos_em_aberto_acr.tta_cod_empresa
                    and   cliente.cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.

                run pi_retornar_endereco_cobr_cliente(input tt_titulos_em_aberto_acr.tta_cdn_cliente).
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    "  Cliente: " at 11
                    tt_titulos_em_aberto_acr.tta_cdn_cliente to 32 format ">>>,>>>,>>9"
                    "-" at 34
                    cliente.nom_pessoa at 36 format "x(40)"
                    "-" at 77
                    cliente.cod_id_feder at 79 format "x(20)"
                    "-" at 100.
    put stream s_1 unformatted 
                    cliente.nom_abrev at 102 format "x(15)"
                    "-" at 118
                    v_nom_cidade at 120 format "x(32)"
                    "-" at 153
                    v_cod_unid_federac at 155 format "x(3)"
                    "-" at 159
                    v_cod_telefone at 161 format "x(20)" skip.

                run pi_aging_acr(input yes).
            end /* if */.
        end.
    end /* if */.
END PROCEDURE. /* pi_aging_acr_more */
/*****************************************************************************
** Procedure Interna.....: pi_atualiza_prazos_tit_acr_em_aberto
** Descricao.............: pi_atualiza_prazos_tit_acr_em_aberto
** Criado por............: Uno
** Criado em.............: 03/01/1997 13:14:03
** Alterado por..........: fut43112
** Alterado em...........: 13/04/2011 10:57:25
*****************************************************************************/
PROCEDURE pi_atualiza_prazos_tit_acr_em_aberto:

    /************************* Variable Definition Begin ************************/

    def var v_cod_entries
        as character
        format "x(35)":U
        no-undo.
    def var v_log_aging_avencer
        as logical
        format "Sim/N∆o"
        initial [no]
        extent 7
        no-undo.
    def var v_log_aging_vencid
        as logical
        format "Sim/N∆o"
        initial [no]
        extent 7
        no-undo.
    def var v_num_atraso_dias_acr
        as integer
        format "->>>>>>9":U
        label "Dias"
        column-label "Dias"
        no-undo.
    def var v_val_origin_antecip_avencer
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        extent 7
        label "Vl Saldo Apres"
        column-label "Vl Saldo Apres"
        no-undo.
    def var v_val_origin_antecip_vencid
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        extent 7
        label "Vl Saldo Apres"
        column-label "Vl Saldo Apres"
        no-undo.
    def var v_val_sdo_apres_avencer_aux
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        extent 7
        label "Vl Saldo Apres"
        column-label "Vl Saldo Apres"
        no-undo.
    def var v_val_sdo_apres_vencid_aux
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        extent 7
        label "Vl Saldo Apres"
        column-label "Vl Saldo Apres"
        no-undo.
    def var v_num_cont                       as integer         no-undo. /*local*/
    def var v_num_entries_aux                as integer         no-undo. /*local*/
    def var v_num_tit                        as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  v_log_visualiz_sint = no
    and v_log_visualiz_clien = no
    then do:
        return.
    end /* if */.

    assign v_val_origin_apres_avencer = 0
           v_val_sdo_apres_avencer    = 0
           v_qtd_tit_acr_avencer      = 0
           v_val_origin_apres_vencid  = 0
           v_val_sdo_apres_vencid     = 0
           v_qtd_tit_acr_vencid       = 0
           v_val_tot_origin_avencer   = 0
           v_val_tot_sdo_avencer      = 0
           v_qtd_tot_tit_avencer      = 0
           v_val_tot_origin_vencid    = 0
           v_val_tot_sdo_vencid       = 0
           v_qtd_tot_tit_vencid       = 0
           v_val_sdo_apres_vencid_aux = 0
           v_val_sdo_apres_avencer_aux = 0
           v_val_origin_antecip_vencid = 0
           v_val_origin_antecip_avencer = 0.
    assign v_qtd_tot_tit_antecip      = 0
           v_qtd_tot_tit_normal       = 0
           v_val_tot_origin_normal    = 0
           v_val_tot_origin_antecip   = 0
           v_val_tot_sdo_normal       = 0
           v_val_tot_sdo_antecip      = 0
           v_val_tot_movto            = 0
           v_val_tot_movto_amr        = 0
           v_val_tot_movto_pmr        = 0.

    if  v_log_funcao_aging_acr = yes
    then do:
        &IF integer(entry(1,proversion,".")) >= 9 &THEN
            empty temp-table tt_valores_prazo no-error.
        &ELSE
            for each tt_valores_prazo:
                delete tt_valores_prazo.
            end.
        &ENDIF
    end /* if */.

    tt_block:
    for each tt_titulos_em_aberto_acr no-lock
        WHERE tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
          AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
        break by tt_titulos_em_aberto_acr.tta_cod_estab
              by tt_titulos_em_aberto_acr.tta_num_id_tit_acr:

        if  v_ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            assign v_cod_ult_obj_procesdo = tt_titulos_em_aberto_acr.tta_cod_estab + "," +
                                            tt_titulos_em_aberto_acr.tta_cod_espec_docto + "," +
                                            tt_titulos_em_aberto_acr.tta_cod_ser_docto + "," +
                                            tt_titulos_em_aberto_acr.tta_cod_tit_acr + "," +
                                            tt_titulos_em_aberto_acr.tta_cod_parcela.
            run prgtec/btb/btb908ze.py (Input 1,
                                        Input v_cod_ult_obj_procesdo) /*prg_api_atualizar_ult_obj*/.
        end /* if */.

        if  first-of(tt_titulos_em_aberto_acr.tta_cod_estab)
        or  first-of(tt_titulos_em_aberto_acr.tta_num_id_tit_acr)
        then do:
            assign v_num_tit = 1.
        end /* if */.
        else do:
            assign v_num_tit = 0.
        end /* else */.

        assign v_log_aging_vencid = no
               v_log_aging_avencer = no
               v_val_origin_antecip_vencid = 0
               v_val_origin_antecip_avencer = 0.

        if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
        or  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Nota de CrÇdito" /*l_nota_de_credito*/ 
        then do:
            assign v_val_tot_origin_antecip = v_val_tot_origin_antecip + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                   v_val_tot_sdo_antecip    = v_val_tot_sdo_antecip + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                   v_qtd_tot_tit_antecip    = v_qtd_tot_tit_antecip + v_num_tit.

            if  v_log_funcao_aging_acr = yes
            then do:

                /* Begin_Include: i_verifica_antecipacoes_aging_acr */
                ASSIGN v_num_atraso_dias_acr = tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr.
                IF v_num_atraso_dias_acr > 0 THEN
                    ASSIGN v_cod_entries = string(v_num_dias_vencid_1)  + CHR(10) +
                                           string(v_num_dias_vencid_2)  + CHR(10) +
                                           string(v_num_dias_vencid_4)  + CHR(10) +
                                           string(v_num_dias_vencid_6)  + CHR(10) +
                                           string(v_num_dias_vencid_8)  + CHR(10) +
                                           string(v_num_dias_vencid_10) + CHR(10) +
                                           string(v_num_dias_vencid_12).
                ELSE
                    ASSIGN v_num_atraso_dias_acr = - v_num_atraso_dias_acr
                           v_cod_entries = string(v_num_dias_avencer_1)  + CHR(10) +
                                           string(v_num_dias_avencer_2)  + CHR(10) +
                                           string(v_num_dias_avencer_4)  + CHR(10) +
                                           string(v_num_dias_avencer_6)  + CHR(10) +
                                           string(v_num_dias_avencer_8)  + CHR(10) +
                                           string(v_num_dias_avencer_10) + CHR(10) +
                                           string(v_num_dias_avencer_12).
                do_block:
                DO v_num_entries_aux = 7 TO 1 BY -1:
                    IF v_num_entries_aux = 7 THEN DO:
                        IF v_num_atraso_dias_acr > INTEGER(ENTRY(v_num_entries_aux,v_cod_entries,CHR(10)))
                        THEN DO:
                            IF v_num_atraso_dias_acr > 0 THEN
                                ASSIGN v_val_origin_antecip_vencid[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                       v_val_sdo_apres_vencid_aux[v_num_entries_aux] = 0
                                       v_log_aging_vencid[v_num_entries_aux] = yes.
                            ELSE
                                ASSIGN v_val_origin_antecip_avencer[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                       v_val_sdo_apres_avencer_aux[v_num_entries_aux] = 0
                                       v_log_aging_avencer[v_num_entries_aux] = yes.

                            LEAVE do_block.
                        END.
                    END.

                    IF v_num_atraso_dias_acr >= INTEGER(ENTRY(v_num_entries_aux,v_cod_entries,CHR(10))) AND
                       INTEGER(ENTRY(v_num_entries_aux,v_cod_entries,CHR(10))) <> 0
                    THEN DO:
                        IF v_num_atraso_dias_acr > 0 THEN
                            ASSIGN v_val_origin_antecip_vencid[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_val_sdo_apres_vencid_aux[v_num_entries_aux] = 0
                                   v_log_aging_vencid[v_num_entries_aux] = yes.
                        ELSE
                            ASSIGN v_val_origin_antecip_avencer[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_val_sdo_apres_avencer_aux[v_num_entries_aux] = 0
                                   v_log_aging_avencer[v_num_entries_aux] = yes.

                        LEAVE do_block.
                    END.

                    IF v_num_entries_aux = 1 THEN DO:
                        IF v_num_atraso_dias_acr > 0 THEN
                            ASSIGN v_val_origin_antecip_vencid[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_val_sdo_apres_vencid_aux[v_num_entries_aux] = 0
                                   v_log_aging_vencid[v_num_entries_aux] = yes.
                        ELSE
                            ASSIGN v_val_origin_antecip_avencer[v_num_entries_aux] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_val_sdo_apres_avencer_aux[v_num_entries_aux] = 0
                                   v_log_aging_avencer[v_num_entries_aux] = yes.

                        LEAVE do_block.
                    END.
                END.
                /* End_Include: i_verifica_antecipacoes_aging_acr */
                .
            end /* if */.
        end /* if */.

        if  (tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
        or (tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/  and v_log_localiz_arg))
        and tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Nota de CrÇdito" /*l_nota_de_credito*/ 
        then do:
            assign v_num_atraso_dias_acr = tt_titulos_em_aberto_acr.ttv_num_atraso_dias_acr.

            if  v_num_atraso_dias_acr > 0
            then do:
                if  v_num_atraso_dias_acr > v_num_dias_vencid_12
                then do:
                    assign v_val_origin_apres_vencid[7] = v_val_origin_apres_vencid[7] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                           v_val_sdo_apres_vencid[7]    = v_val_sdo_apres_vencid[7] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                           v_qtd_tit_acr_vencid[7]      = v_qtd_tit_acr_vencid[7] + v_num_tit
                           v_log_aging_vencid[7]        = yes
                           v_val_sdo_apres_vencid_aux[7] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                end /* if */.
                else do:
                    if  v_num_atraso_dias_acr >= v_num_dias_vencid_10 and v_num_dias_vencid_10 <> 0
                    then do:
                        assign v_val_origin_apres_vencid[6] = v_val_origin_apres_vencid[6] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                               v_val_sdo_apres_vencid[6]    = v_val_sdo_apres_vencid[6] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                               v_qtd_tit_acr_vencid[6]      = v_qtd_tit_acr_vencid[6] + v_num_tit
                               v_log_aging_vencid[6]        = yes
                               v_val_sdo_apres_vencid_aux[6] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                    end /* if */.
                    else do:
                        if  v_num_atraso_dias_acr >= v_num_dias_vencid_8 and v_num_dias_vencid_8 <> 0
                        then do:
                            assign v_val_origin_apres_vencid[5] = v_val_origin_apres_vencid[5] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                   v_val_sdo_apres_vencid[5]    = v_val_sdo_apres_vencid[5] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_qtd_tit_acr_vencid[5]      = v_qtd_tit_acr_vencid[5] + v_num_tit
                                   v_log_aging_vencid[5]        = yes
                                   v_val_sdo_apres_vencid_aux[5] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                        end /* if */.
                        else do:
                            if  v_num_atraso_dias_acr >= v_num_dias_vencid_6 and v_num_dias_vencid_6 <> 0
                            then do:
                                assign v_val_origin_apres_vencid[4] = v_val_origin_apres_vencid[4] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                       v_val_sdo_apres_vencid[4]    = v_val_sdo_apres_vencid[4] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                       v_qtd_tit_acr_vencid[4]      = v_qtd_tit_acr_vencid[4] + v_num_tit
                                       v_log_aging_vencid[4]        = yes
                                       v_val_sdo_apres_vencid_aux[4] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                            end /* if */.
                            else do:
                                if  v_num_atraso_dias_acr >= v_num_dias_vencid_4 and v_num_dias_vencid_4 <> 0
                                then do:
                                    assign v_val_origin_apres_vencid[3] = v_val_origin_apres_vencid[3] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                           v_val_sdo_apres_vencid[3]    = v_val_sdo_apres_vencid[3] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                           v_qtd_tit_acr_vencid[3]      = v_qtd_tit_acr_vencid[3] + v_num_tit
                                           v_log_aging_vencid[3]        = yes
                                           v_val_sdo_apres_vencid_aux[3] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                end /* if */.
                                else do:
                                    if  v_num_atraso_dias_acr >= v_num_dias_vencid_2 and v_num_dias_vencid_2 <> 0
                                    then do:
                                        assign v_val_origin_apres_vencid[2] = v_val_origin_apres_vencid[2] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                               v_val_sdo_apres_vencid[2]    = v_val_sdo_apres_vencid[2] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                               v_qtd_tit_acr_vencid[2]      = v_qtd_tit_acr_vencid[2] + v_num_tit
                                               v_log_aging_vencid[2]        = yes
                                               v_val_sdo_apres_vencid_aux[2] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                    end /* if */.
                                    else do:
                                        assign v_val_origin_apres_vencid[1] = v_val_origin_apres_vencid[1] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                               v_val_sdo_apres_vencid[1]    = v_val_sdo_apres_vencid[1] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                               v_qtd_tit_acr_vencid[1]      = v_qtd_tit_acr_vencid[1] + v_num_tit
                                               v_log_aging_vencid[1]        = yes
                                               v_val_sdo_apres_vencid_aux[1] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                    end /* else */.
                                end /* else */.
                            end /* else */.
                        end /* else */.
                    end /* else */.
                end /* else */.
                /* atv. 246690, validaá∆o posta para que os demais totalizadores do relat¢rio tambÇm fossem apresentados corretamente*/
                if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
                then do:
                    assign v_val_tot_origin_vencid = v_val_tot_origin_vencid + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                           v_val_tot_sdo_vencid    = v_val_tot_sdo_vencid + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                           v_qtd_tot_tit_vencid    = v_qtd_tot_tit_vencid + v_num_tit.
                end /* if */.
            end /* if */.
            else do:
                assign v_num_atraso_dias_acr = - v_num_atraso_dias_acr.

                if  v_num_atraso_dias_acr > v_num_dias_avencer_12
                then do:
                    assign v_val_origin_apres_avencer[7] = v_val_origin_apres_avencer[7] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                           v_val_sdo_apres_avencer[7]    = v_val_sdo_apres_avencer[7] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                           v_qtd_tit_acr_avencer[7]      = v_qtd_tit_acr_avencer[7] + v_num_tit
                           v_log_aging_avencer[7]        = yes
                           v_val_sdo_apres_avencer_aux[7] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                end /* if */.
                else do:
                    if  v_num_atraso_dias_acr >= v_num_dias_avencer_10 and v_num_dias_avencer_10 <> 0
                    then do:
                        assign v_val_origin_apres_avencer[6] = v_val_origin_apres_avencer[6] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                               v_val_sdo_apres_avencer[6]    = v_val_sdo_apres_avencer[6] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                               v_qtd_tit_acr_avencer[6]      = v_qtd_tit_acr_avencer[6] + v_num_tit
                               v_log_aging_avencer[6]        = yes
                               v_val_sdo_apres_avencer_aux[6] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                    end /* if */.
                    else do:
                        if  v_num_atraso_dias_acr >= v_num_dias_avencer_8 and v_num_dias_avencer_8 <> 0
                        then do:
                            assign v_val_origin_apres_avencer[5] = v_val_origin_apres_avencer[5] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                   v_val_sdo_apres_avencer[5]    = v_val_sdo_apres_avencer[5] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                   v_qtd_tit_acr_avencer[5]      = v_qtd_tit_acr_avencer[5] + v_num_tit
                                   v_log_aging_avencer[5]        = yes
                                   v_val_sdo_apres_avencer_aux[5] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                        end /* if */.
                        else do:
                            if  v_num_atraso_dias_acr >= v_num_dias_avencer_6 and v_num_dias_avencer_6 <> 0
                            then do:
                                assign v_val_origin_apres_avencer[4] = v_val_origin_apres_avencer[4] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                       v_val_sdo_apres_avencer[4]    = v_val_sdo_apres_avencer[4] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                       v_qtd_tit_acr_avencer[4]      = v_qtd_tit_acr_avencer[4] + v_num_tit
                                       v_log_aging_avencer[4]        = yes
                                       v_val_sdo_apres_avencer_aux[4] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                            end /* if */.
                            else do:
                                if  v_num_atraso_dias_acr >= v_num_dias_avencer_4 and v_num_dias_avencer_4 <> 0
                                then do:
                                    assign v_val_origin_apres_avencer[3] = v_val_origin_apres_avencer[3] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                           v_val_sdo_apres_avencer[3]    = v_val_sdo_apres_avencer[3] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                           v_qtd_tit_acr_avencer[3]      = v_qtd_tit_acr_avencer[3] + v_num_tit
                                           v_log_aging_avencer[3]        = yes
                                           v_val_sdo_apres_avencer_aux[3] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                end /* if */.
                                else do:
                                    if  v_num_atraso_dias_acr >= v_num_dias_avencer_2 and v_num_dias_avencer_2 <> 0
                                    then do:
                                        assign v_val_origin_apres_avencer[2] = v_val_origin_apres_avencer[2] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                               v_val_sdo_apres_avencer[2]    = v_val_sdo_apres_avencer[2] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                               v_qtd_tit_acr_avencer[2]      = v_qtd_tit_acr_avencer[2] + v_num_tit
                                               v_log_aging_avencer[2]        = yes
                                               v_val_sdo_apres_avencer_aux[2] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                    end /* if */.
                                    else do:
                                        assign v_val_origin_apres_avencer[1] = v_val_origin_apres_avencer[1] + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                                               v_val_sdo_apres_avencer[1]    = v_val_sdo_apres_avencer[1] + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                                               v_qtd_tit_acr_avencer[1]      = v_qtd_tit_acr_avencer[1] + v_num_tit
                                               v_log_aging_avencer[1]        = yes
                                               v_val_sdo_apres_avencer_aux[1] = tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                                    end /* else */.
                                end /* else */.
                            end /* else */.
                        end /* else */.
                    end /* else */.
                end /* else */.
                /* atv. 246690, validaá∆o posta para que os demais totalizadores do relat¢rio tambÇm fossem apresentados corretamente*/
                if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
                then do:  
                    assign v_val_tot_origin_avencer = v_val_tot_origin_avencer + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                           v_val_tot_sdo_avencer    = v_val_tot_sdo_avencer + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                           v_qtd_tot_tit_avencer    = v_qtd_tot_tit_avencer + v_num_tit.
                end /* if */.           
            end /* else */.
            /* atv. 246690, validaá∆o posta para que os demais totalizadores do relat¢rio tambÇm fossem apresentados corretamente*/
            if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
            then do:  
                assign v_val_tot_origin_normal = v_val_tot_origin_normal + tt_titulos_em_aberto_acr.ttv_val_origin_tit_acr_apres
                       v_val_tot_sdo_normal    = v_val_tot_sdo_normal + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres
                       v_qtd_tot_tit_normal    = v_qtd_tot_tit_normal + v_num_tit.
            end /* if */.

            assign v_val_tot_movto_amr = v_val_tot_movto_amr + tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_amr
                   v_val_tot_movto_pmr = v_val_tot_movto_pmr + tt_titulos_em_aberto_acr.ttv_val_movto_tit_acr_pmr
                   v_val_tot_movto     = v_val_tot_movto + tt_titulos_em_aberto_acr.tta_val_movto_tit_acr.
        end /* else */.
        if  v_log_funcao_aging_acr = yes
        then do:
            find first tt_valores_prazo
                where tt_valores_prazo.tta_cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente no-error.
            if  not avail tt_valores_prazo
            then do:
                create tt_valores_prazo.
                assign tt_valores_prazo.tta_cdn_cliente = tt_titulos_em_aberto_acr.tta_cdn_cliente.
            end /* if */.

            do v_num_cont = 1 to 7:
                /* verificaªío de antecipaªÑes posta para que nío fossem somadas ao montante de duplicatas, o valor Ç abatido posteriormente atv. 246690*/
                if v_log_aging_vencid[v_num_cont] = yes and tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/  then
                    assign tt_valores_prazo.ttv_val_sdo_apres_vencid[v_num_cont] = tt_valores_prazo.ttv_val_sdo_apres_vencid[v_num_cont]
                                                                                 + v_val_sdo_apres_vencid_aux[v_num_cont]
                                                                                 /* - v_val_origin_antecip_vencid[v_num_cont]*/
                           tt_valores_prazo.ttv_val_tot_sdo_vencid = tt_valores_prazo.ttv_val_tot_sdo_vencid + (if v_val_sdo_apres_vencid_aux[v_num_cont] > 0 then v_val_sdo_apres_vencid_aux[v_num_cont] else 0).                                                                             
                                                                   /* - v_val_origin_antecip_vencid[v_num_cont].*/
                /* verificaªío de antecipaªÑes posta para que nío fossem somadas ao montante de duplicatas, o valor Ç abatido posteriormente atv. 246690*/
                if v_log_aging_avencer[v_num_cont] = yes and tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/  then 
                    assign tt_valores_prazo.ttv_val_sdo_apres_avencer[v_num_cont] = tt_valores_prazo.ttv_val_sdo_apres_avencer[v_num_cont]
                                                                                  + v_val_sdo_apres_avencer_aux[v_num_cont]
                                                                                  /* - v_val_origin_antecip_avencer[v_num_cont]*/
                           tt_valores_prazo.ttv_val_tot_sdo_avencer = tt_valores_prazo.ttv_val_tot_sdo_avencer
                                                                    + v_val_sdo_apres_avencer_aux[v_num_cont].
                                                                    /* - v_val_origin_antecip_avencer[v_num_cont].*/
                    assign tt_valores_prazo.ttv_val_tot_antecip = tt_valores_prazo.ttv_val_tot_antecip
                                                                + v_val_origin_antecip_vencid[v_num_cont] + v_val_origin_antecip_avencer[v_num_cont].
            end.
        end /* if */.
    end /* for tt_block */.
END PROCEDURE. /* pi_atualiza_prazos_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_atualizar_tot_tit_acr_em_aberto
** Descricao.............: pi_atualizar_tot_tit_acr_em_aberto
** Criado por............: Roberto
** Criado em.............: 21/07/1997 16:03:51
** Alterado por..........: fut40518
** Alterado em...........: 16/09/2010 16:54:44
*****************************************************************************/
PROCEDURE pi_atualizar_tot_tit_acr_em_aberto:

    close query qr_tit_acr_em_aberto_un.
    close query qr_tit_acr_em_aberto.
    close query qr_tot_tit_acr.

    assign v_num_ord_reg    = 1
           v_val_estab      = 0
           v_val_unid_negoc = 0
           v_val_tot        = 0
           v_ind_coluna     = ""
           v_val_estab_antecip      = 0
           v_val_estab_normal       = 0
           v_val_unid_negoc_antecip = 0
           v_val_unid_negoc_normal  = 0.

    del_tt:
    for each tt_tot_movtos_acr exclusive-lock:
        delete tt_tot_movtos_acr.
    end /* for del_tt */.
    del_tt:
    for each tt_estab_unid_negoc exclusive-lock:
        delete tt_estab_unid_negoc.
    end /* for del_tt */.

    /* **
     Gera temp-table com os Estab e UN que dever∆o constar no gr†fico.
    ***/
    for each tt_titulos_em_aberto_acr 
       WHERE tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
         AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim NO-LOCK:
        if  v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
        then do:
            find tt_estab_unid_negoc no-lock
                where tt_estab_unid_negoc.tta_cod_estab = tt_titulos_em_aberto_acr.tta_cod_estab no-error.
        end.
        else do:
            find tt_estab_unid_negoc no-lock
                where tt_estab_unid_negoc.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                and   tt_estab_unid_negoc.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc no-error.
        end.

        if  not avail tt_estab_unid_negoc then do:
            create tt_estab_unid_negoc.
            assign tt_estab_unid_negoc.tta_cod_estab      = tt_titulos_em_aberto_acr.tta_cod_estab
                   tt_estab_unid_negoc.tta_cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc.
        end.
    end.




    /* **
     T°tulos Vencidos
    ***/
    if  v_dat_tit_acr_aber - v_num_dias_vencid_8 >= v_dat_vencto_tit_acr_ini then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_vencto_tit_acr_ini,
                                            Input v_dat_tit_acr_aber - v_num_dias_vencid_8) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_vencid_7 <> 0
    and v_dat_tit_acr_aber - v_num_dias_vencid_6 >= v_dat_vencto_tit_acr_ini then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber - v_num_dias_vencid_7,
                                            Input v_dat_tit_acr_aber - v_num_dias_vencid_6) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_vencid_5 <> 0
    and v_dat_tit_acr_aber - v_num_dias_vencid_4 >= v_dat_vencto_tit_acr_ini then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber - v_num_dias_vencid_5,
                                            Input v_dat_tit_acr_aber - v_num_dias_vencid_4) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_vencid_3 <> 0
    and v_dat_tit_acr_aber - v_num_dias_vencid_2 >= v_dat_vencto_tit_acr_ini then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber - v_num_dias_vencid_3,
                                            Input v_dat_tit_acr_aber - v_num_dias_vencid_2) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_vencid_1 <> 0
    and v_dat_tit_acr_aber - 1 >= v_dat_vencto_tit_acr_ini then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber - v_num_dias_vencid_1,
                                            Input v_dat_tit_acr_aber - 1) /*pi_totaliza_tit_acr_aber_param*/.
    end.

    /* **
     T°tulos A Vencer
    ***/
    if  v_num_dias_avencer_1 <> 0
    and v_dat_tit_acr_aber <= v_dat_vencto_tit_acr_fim then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber,
                                            Input if (v_dat_tit_acr_aber + v_num_dias_avencer_1) > v_dat_vencto_tit_acr_fim                                                                then v_dat_vencto_tit_acr_fim else v_dat_tit_acr_aber + v_num_dias_avencer_1) /*pi_totaliza_tit_acr_aber_param*/. 
    end.
    if  v_num_dias_avencer_3 <> 0
    and v_dat_tit_acr_aber <= v_dat_vencto_tit_acr_fim then do: 
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber + v_num_dias_avencer_2,
                                            Input v_dat_tit_acr_aber + v_num_dias_avencer_3) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_avencer_5 <> 0
    and v_dat_tit_acr_aber <= v_dat_vencto_tit_acr_fim then do: 
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber + v_num_dias_avencer_4,
                                            Input v_dat_tit_acr_aber + v_num_dias_avencer_5) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_num_dias_avencer_7 <> 0
    and v_dat_tit_acr_aber <= v_dat_vencto_tit_acr_fim then do: 
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber + v_num_dias_avencer_6,
                                            Input v_dat_tit_acr_aber + v_num_dias_avencer_7) /*pi_totaliza_tit_acr_aber_param*/.
    end.
    if  v_dat_tit_acr_aber <= v_dat_vencto_tit_acr_fim then do:
        run pi_totaliza_tit_acr_aber_param (Input v_dat_tit_acr_aber + v_num_dias_avencer_8,
                                            Input v_dat_vencto_tit_acr_fim) /*pi_totaliza_tit_acr_aber_param*/.
    end.

    /* **
     Separa estabelecimento e UN
    ***/
    if  v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
    or (v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
        and v_ind_forma_tot         = "Por Estab/Unidade Neg¢cio" /*l_por_estab_unidade_negocio*/  ) then do:
        sintetiza_block:
        do while can-find( first tt_tot_movtos_acr
                                               where tt_tot_movtos_acr.ttv_cod_estab <> ""
                                                 and tt_tot_movtos_acr.ttv_log_graf  =  yes ):
            find first tt_tot_movtos_acr no-lock
                where tt_tot_movtos_acr.ttv_cod_estab <> ""
                and   tt_tot_movtos_acr.ttv_log_graf  =  yes no-error.

            find estabelecimento no-lock
                where estabelecimento.cod_estab = tt_tot_movtos_acr.ttv_cod_estab no-error.
            create btt_tot_movtos_acr.
            assign btt_tot_movtos_acr.ttv_cod_estab       = tt_tot_movtos_acr.ttv_cod_estab
                   btt_tot_movtos_acr.ttv_cod_unid_negoc  = " "
                   btt_tot_movtos_acr.tta_cod_estab       = tt_tot_movtos_acr.ttv_cod_estab
                   btt_tot_movtos_acr.tta_cod_unid_negoc  = " "
                   btt_tot_movtos_acr.ttv_nom_pessoa      = estabelecimento.nom_pessoa
                   btt_tot_movtos_acr.ttv_val_tot_movto   = 0
                   btt_tot_movtos_acr.ttv_num_ord_reg     = v_num_ord_reg
                   btt_tot_movtos_acr.ttv_log_graf        = no
                   btt_tot_movtos_acr.ttv_val_tot_geral_antecip = 0
                   btt_tot_movtos_acr.ttv_val_tot_geral_normal  = 0
                   v_num_ord_reg                          = v_num_ord_reg + 1.

            if  v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
            then do:
                tt_block:
                for each tt_tot_movtos_acr exclusive-lock
                    where tt_tot_movtos_acr.ttv_cod_estab = btt_tot_movtos_acr.ttv_cod_estab
                    and   tt_tot_movtos_acr.ttv_log_graf  = yes
                    by tt_tot_movtos_acr.ttv_num_ord_reg:
                    assign tt_tot_movtos_acr.ttv_cod_estab        = ""
                           tt_tot_movtos_acr.ttv_num_ord_reg      = v_num_ord_reg
                           v_num_ord_reg                          = v_num_ord_reg + 1
                           btt_tot_movtos_acr.ttv_val_tot_movto   = btt_tot_movtos_acr.ttv_val_tot_movto + tt_tot_movtos_acr.ttv_val_tot_movto
                           btt_tot_movtos_acr.ttv_val_tot_geral_antecip = btt_tot_movtos_acr.ttv_val_tot_geral_antecip + tt_tot_movtos_acr.ttv_val_tot_geral_antecip
                           btt_tot_movtos_acr.ttv_val_tot_geral_normal  = btt_tot_movtos_acr.ttv_val_tot_geral_normal + tt_tot_movtos_acr.ttv_val_tot_geral_normal.

                end /* for tt_block */.
            end.
            else do:
                sintetiza_un_block:
                do while can-find( first tt_tot_movtos_acr
                                                          where tt_tot_movtos_acr.ttv_cod_estab      =  btt_tot_movtos_acr.ttv_cod_estab
                                                            and tt_tot_movtos_acr.ttv_cod_unid_negoc <> ""
                                                            and tt_tot_movtos_acr.ttv_log_graf       =  yes ):
                    find first tt_tot_movtos_acr no-lock
                        where tt_tot_movtos_acr.ttv_cod_estab      =  btt_tot_movtos_acr.ttv_cod_estab
                        and   tt_tot_movtos_acr.ttv_cod_unid_negoc <> ""
                        and   tt_tot_movtos_acr.ttv_log_graf       =  yes no-error.

                    find unid_negoc no-lock
                        where unid_negoc.cod_unid_negoc = tt_tot_movtos_acr.ttv_cod_unid_negoc no-error.
                    create btt_tot_movtos_acr_un.
                    assign btt_tot_movtos_acr_un.ttv_cod_estab       = ""
                           btt_tot_movtos_acr_un.ttv_cod_unid_negoc  = tt_tot_movtos_acr.ttv_cod_unid_negoc
                           btt_tot_movtos_acr_un.tta_cod_estab       = ""
                           btt_tot_movtos_acr_un.tta_cod_unid_negoc  = tt_tot_movtos_acr.ttv_cod_unid_negoc
                           btt_tot_movtos_acr_un.ttv_nom_pessoa      = if avail unid_negoc then unid_negoc.des_unid_negoc else ''
                           btt_tot_movtos_acr_un.ttv_val_tot_movto   = 0
                           btt_tot_movtos_acr_un.ttv_num_ord_reg     = v_num_ord_reg
                           btt_tot_movtos_acr_un.ttv_log_graf        = no
                           btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip = 0
                           btt_tot_movtos_acr_un.ttv_val_tot_geral_normal  = 0
                           v_num_ord_reg                             = v_num_ord_reg + 1.

                    tt_block:
                    for each tt_tot_movtos_acr exclusive-lock
                        where tt_tot_movtos_acr.ttv_cod_estab      = btt_tot_movtos_acr.ttv_cod_estab
                        and   tt_tot_movtos_acr.ttv_cod_unid_negoc = btt_tot_movtos_acr_un.ttv_cod_unid_negoc
                        by tt_tot_movtos_acr.ttv_num_ord_reg:
                        assign tt_tot_movtos_acr.ttv_cod_estab           = ""
                               tt_tot_movtos_acr.ttv_cod_unid_negoc      = ""
                               tt_tot_movtos_acr.ttv_num_ord_reg         = v_num_ord_reg
                               v_num_ord_reg                             = v_num_ord_reg + 1
                               btt_tot_movtos_acr.ttv_val_tot_movto      = btt_tot_movtos_acr.ttv_val_tot_movto      + tt_tot_movtos_acr.ttv_val_tot_movto
                               btt_tot_movtos_acr_un.ttv_val_tot_movto   = btt_tot_movtos_acr_un.ttv_val_tot_movto   + tt_tot_movtos_acr.ttv_val_tot_movto
                               btt_tot_movtos_acr.ttv_val_tot_geral_antecip    = btt_tot_movtos_acr.ttv_val_tot_geral_antecip    + tt_tot_movtos_acr.ttv_val_tot_geral_antecip
                               btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip = btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip + tt_tot_movtos_acr.ttv_val_tot_geral_antecip
                               btt_tot_movtos_acr.ttv_val_tot_geral_normal     = btt_tot_movtos_acr.ttv_val_tot_geral_normal     + tt_tot_movtos_acr.ttv_val_tot_geral_normal
                               btt_tot_movtos_acr_un.ttv_val_tot_geral_normal  = btt_tot_movtos_acr_un.ttv_val_tot_geral_normal  + tt_tot_movtos_acr.ttv_val_tot_geral_normal.
                    end /* for tt_block */.
                end /* do sintetiza_un_block */.
            end.
        end /* do sintetiza_block */.
    end.
    else do:
        if v_ind_visualiz_tit_acr_vert <> "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/  then do:
            sintetiza_block:
            do while can-find( first tt_tot_movtos_acr
                                                   where tt_tot_movtos_acr.ttv_cod_unid_negoc <> ""
                                                     and tt_tot_movtos_acr.ttv_log_graf  =  yes ):
                find first tt_tot_movtos_acr no-lock
                    where tt_tot_movtos_acr.ttv_cod_unid_negoc <> ""
                    and   tt_tot_movtos_acr.ttv_log_graf       =  yes no-error.

                find unid_negoc no-lock
                    where unid_negoc.cod_unid_negoc = tt_tot_movtos_acr.ttv_cod_unid_negoc no-error.
                create btt_tot_movtos_acr_un.
                assign btt_tot_movtos_acr_un.ttv_cod_estab          = ""
                       btt_tot_movtos_acr_un.ttv_cod_unid_negoc     = tt_tot_movtos_acr.ttv_cod_unid_negoc
                       btt_tot_movtos_acr_un.tta_cod_estab          = ""
                       btt_tot_movtos_acr_un.tta_cod_unid_negoc     = tt_tot_movtos_acr.ttv_cod_unid_negoc
                       btt_tot_movtos_acr_un.ttv_nom_pessoa         = if avail unid_negoc then unid_negoc.des_unid_negoc else ''
                       btt_tot_movtos_acr_un.ttv_val_tot_movto      = 0
                       btt_tot_movtos_acr_un.ttv_num_ord_reg        = v_num_ord_reg
                       btt_tot_movtos_acr_un.ttv_log_graf           = no
                       btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip    = 0
                       btt_tot_movtos_acr_un.ttv_val_tot_geral_normal     = 0
                       v_num_ord_reg                                = v_num_ord_reg + 1.

                tt_block:
                for each tt_tot_movtos_acr exclusive-lock
                    where tt_tot_movtos_acr.ttv_cod_unid_negoc     = btt_tot_movtos_acr_un.ttv_cod_unid_negoc
                    and   tt_tot_movtos_acr.ttv_log_graf           = yes
                    by tt_tot_movtos_acr.ttv_num_ord_reg:

                    assign tt_tot_movtos_acr.ttv_cod_estab           = ""
                           tt_tot_movtos_acr.ttv_cod_unid_negoc      = ""
                           tt_tot_movtos_acr.ttv_num_ord_reg         = v_num_ord_reg
                           v_num_ord_reg                             = v_num_ord_reg + 1
                           btt_tot_movtos_acr_un.ttv_val_tot_movto   = btt_tot_movtos_acr_un.ttv_val_tot_movto   + tt_tot_movtos_acr.ttv_val_tot_movto
                           btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip = btt_tot_movtos_acr_un.ttv_val_tot_geral_antecip + tt_tot_movtos_acr.ttv_val_tot_geral_antecip
                           btt_tot_movtos_acr_un.ttv_val_tot_geral_normal  = btt_tot_movtos_acr_un.ttv_val_tot_geral_normal  + tt_tot_movtos_acr.ttv_val_tot_geral_normal.

                end /* for tt_block */.
            end /* do sintetiza_block */.
        end.    
        else do:
            sintetiza_block:
            do while can-find( first tt_tot_movtos_acr
                                                   where tt_tot_movtos_acr.ttv_cod_proces_export <> ""
                                                     and tt_tot_movtos_acr.ttv_log_graf  =  yes ):
                find first tt_tot_movtos_acr no-lock
                    where tt_tot_movtos_acr.ttv_cod_proces_export <> ""
                    and   tt_tot_movtos_acr.ttv_log_graf       =  yes no-error.

                create btt_tot_movtos_acr_proc.
                assign btt_tot_movtos_acr_proc.ttv_cod_proces_export  = tt_tot_movtos_acr.ttv_cod_proces_export
                       btt_tot_movtos_acr_proc.ttv_cod_estab          = ""
                       btt_tot_movtos_acr_proc.ttv_cod_unid_negoc     = ""
                       btt_tot_movtos_acr_proc.tta_cod_estab          = ""
                       btt_tot_movtos_acr_proc.tta_cod_unid_negoc     = ""
                       btt_tot_movtos_acr_proc.ttv_nom_pessoa         = ""
                       btt_tot_movtos_acr_proc.tta_cod_proces_export  = tt_tot_movtos_acr.ttv_cod_proces_export
                       btt_tot_movtos_acr_proc.ttv_val_tot_movto      = 0
                       btt_tot_movtos_acr_proc.ttv_num_ord_reg        = v_num_ord_reg
                       btt_tot_movtos_acr_proc.ttv_log_graf           = no
                       btt_tot_movtos_acr_proc.ttv_val_tot_geral_antecip    = 0
                       btt_tot_movtos_acr_proc.ttv_val_tot_geral_normal     = 0
                       v_num_ord_reg                                = v_num_ord_reg + 1.

                tt_block:
                for each tt_tot_movtos_acr exclusive-lock
                    where tt_tot_movtos_acr.ttv_cod_proces_export  = btt_tot_movtos_acr_proc.ttv_cod_proces_export
                    and   tt_tot_movtos_acr.ttv_log_graf           = yes
                    by tt_tot_movtos_acr.ttv_num_ord_reg:

                    assign tt_tot_movtos_acr.ttv_cod_proces_export = ""
                           tt_tot_movtos_acr.ttv_num_ord_reg       = v_num_ord_reg
                           v_num_ord_reg                           = v_num_ord_reg + 1
                           btt_tot_movtos_acr_proc.ttv_val_tot_movto = btt_tot_movtos_acr_proc.ttv_val_tot_movto + tt_tot_movtos_acr.ttv_val_tot_movto
                           btt_tot_movtos_acr_proc.ttv_val_tot_geral_antecip = btt_tot_movtos_acr_proc.ttv_val_tot_geral_antecip + tt_tot_movtos_acr.ttv_val_tot_geral_antecip
                           btt_tot_movtos_acr_proc.ttv_val_tot_geral_normal  = btt_tot_movtos_acr_proc.ttv_val_tot_geral_normal  + tt_tot_movtos_acr.ttv_val_tot_geral_normal.
                end /* for tt_block */.
            end /* do sintetiza_block */.
        end.
    end.

END PROCEDURE. /* pi_atualizar_tot_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_totaliza_tit_acr_aber_param
** Descricao.............: pi_totaliza_tit_acr_aber_param
** Criado por............: Roberto
** Criado em.............: 21/07/1997 18:05:02
** Alterado por..........: fut40552
** Alterado em...........: 21/06/2007 15:43:02
*****************************************************************************/
PROCEDURE pi_totaliza_tit_acr_aber_param:

    /************************ Parameter Definition Begin ************************/

    def Input param p_dat_inic
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_dat_fim
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    if  v_ind_coluna <> "" then do:
        assign v_ind_coluna = v_ind_coluna + "," + string( p_dat_inic ) + "," + string( p_dat_fim ).
    end.
    else do:
        assign v_ind_coluna = string( p_dat_inic ) + "," + string( p_dat_fim ).
    end.

    if  v_ind_visualiz_tit_acr_vert = "Por Processo Exportaá∆o" /*l_por_processo_exportacao*/ 
    then do:
        tt_block:
        for each tt_titulos_em_aberto_acr no-lock
            where tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr >= p_dat_inic
              and tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr <= p_dat_fim
              AND tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
              AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
            break by tt_titulos_em_aberto_acr.ttv_cod_proces_export:

            if(tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
            or tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Nota CrÇdito" /*l_nota_credito*/ ) then 
                assign v_val_proces_antecip = v_val_proces_antecip + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
            else
                assign v_val_proces_normal = v_val_proces_normal + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.

            if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
            then do:
                assign v_val_proces_export = v_val_proces_export + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
            end /* if */.
            else do:


                assign v_val_proces_export = v_val_proces_export - tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.    

            end /* else */.

            if  last-of(tt_titulos_em_aberto_acr.ttv_cod_proces_export)
            then do:
                create tt_tot_movtos_acr.
                assign tt_tot_movtos_acr.ttv_cod_proces_export  = if tt_titulos_em_aberto_acr.ttv_cod_proces_export = "" then "Sem Processo" /*l_sem_processo*/  else tt_titulos_em_aberto_acr.ttv_cod_proces_export
                       tt_tot_movtos_acr.ttv_cod_estab          = " "
                       tt_tot_movtos_acr.ttv_cod_unid_negoc     = " "
                       tt_tot_movtos_acr.tta_cod_estab          = " "
                       tt_tot_movtos_acr.tta_cod_unid_negoc     = " "
                       tt_tot_movtos_acr.tta_cod_proces_export  = if tt_titulos_em_aberto_acr.ttv_cod_proces_export = "" then "Sem Processo" /*l_sem_processo*/  else tt_titulos_em_aberto_acr.ttv_cod_proces_export
                       tt_tot_movtos_acr.ttv_val_tot_movto      = v_val_proces_export
                       tt_tot_movtos_acr.ttv_num_ord_reg        = v_num_ord_reg
                       tt_tot_movtos_acr.ttv_log_graf           = yes
                       tt_tot_movtos_acr.ttv_val_tot_geral_antecip = v_val_proces_antecip
                       tt_tot_movtos_acr.ttv_val_tot_geral_normal  = v_val_proces_normal
                       v_num_ord_reg                            = v_num_ord_reg + 1
                       v_val_tot                                = v_val_tot + v_val_proces_export
                       v_val_proces_export                      = 0
                       v_val_proces_antecip                     = 0
                       v_val_proces_normal                      = 0.

                if  p_dat_fim >= v_dat_tit_acr_aber then do:
                    assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                           tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                           tt_tot_movtos_acr.ttv_num_dias_avencer_2 = p_dat_inic - v_dat_tit_acr_aber
                           tt_tot_movtos_acr.ttv_num_dias_avencer_3 = p_dat_fim  - v_dat_tit_acr_aber
                           tt_tot_movtos_acr.ttv_ind_vencid_avencer = "A Venc" /*l_a_venc*/ .
                end.
                else do:
                    assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                           tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                           tt_tot_movtos_acr.ttv_num_dias_avencer_2 = v_dat_tit_acr_aber - p_dat_fim
                           tt_tot_movtos_acr.ttv_num_dias_avencer_3 = v_dat_tit_acr_aber - p_dat_inic
                           tt_tot_movtos_acr.ttv_ind_vencid_avencer = "Venc" /*l_venc*/ .
                end.
                assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "A" /*l_A*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_3 ) + " " + "D" /*l_D*/ .
                if  p_dat_inic = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF then do:
                    assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "a mais de" /*l_a_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                end.
                if  p_dat_fim = 12/31/9999 then do:
                    assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "em mais de" /*l_em_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                end.
            end /* if */.
        end /* for tt_block */.
    end.
    else do:
        if  v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
        then do:
            tt_block:
            for each tt_titulos_em_aberto_acr no-lock
                where tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr >= p_dat_inic
                  and tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr <= p_dat_fim
                  AND tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
                  AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
                break by tt_titulos_em_aberto_acr.tta_cod_estab:

                if(tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
                or tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Nota CrÇdito" /*l_nota_credito*/ ) then 
                    assign v_val_estab_antecip = v_val_estab_antecip + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                else
                    assign v_val_estab_normal = v_val_estab_normal + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.

                if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
                then do:
                    assign v_val_estab = v_val_estab + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                end /* if */.
                else do:


                    assign v_val_estab = v_val_estab - tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.

                end /* else */.

                if  last-of(tt_titulos_em_aberto_acr.tta_cod_estab)
                then do:
                    find estabelecimento no-lock
                        where estabelecimento.cod_estab = tt_titulos_em_aberto_acr.tta_cod_estab
                        no-error.
                    create tt_tot_movtos_acr.
                    assign tt_tot_movtos_acr.ttv_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                           tt_tot_movtos_acr.ttv_cod_unid_negoc     = " "
                           tt_tot_movtos_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                           tt_tot_movtos_acr.tta_cod_unid_negoc     = " "
                           tt_tot_movtos_acr.ttv_val_tot_movto      = v_val_estab
                           tt_tot_movtos_acr.ttv_num_ord_reg        = v_num_ord_reg
                           tt_tot_movtos_acr.ttv_log_graf           = yes
                           tt_tot_movtos_acr.ttv_val_tot_geral_antecip = v_val_estab_antecip
                           tt_tot_movtos_acr.ttv_val_tot_geral_normal  = v_val_estab_normal
                           v_num_ord_reg                            = v_num_ord_reg + 1
                           v_val_tot                                = v_val_tot + v_val_estab
                           v_val_estab                              = 0
                           v_val_estab_antecip                      = 0
                           v_val_estab_normal                       = 0.

                    if  p_dat_fim >= v_dat_tit_acr_aber then do:
                        assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                               tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_2 = p_dat_inic - v_dat_tit_acr_aber
                               tt_tot_movtos_acr.ttv_num_dias_avencer_3 = p_dat_fim  - v_dat_tit_acr_aber
                               tt_tot_movtos_acr.ttv_ind_vencid_avencer = "A Venc" /*l_a_venc*/ .
                    end.
                    else do:
                        assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                               tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_2 = v_dat_tit_acr_aber - p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_3 = v_dat_tit_acr_aber - p_dat_inic
                               tt_tot_movtos_acr.ttv_ind_vencid_avencer = "Venc" /*l_venc*/ .
                    end.
                    assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "A" /*l_A*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_3 ) + " " + "D" /*l_D*/ .
                    if  p_dat_inic = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF then do:
                        assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "a mais de" /*l_a_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                    end.
                    if  p_dat_fim = 12/31/9999 then do:
                        assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "em mais de" /*l_em_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                    end.
                end /* if */.
            end /* for tt_block */.
        end /* if */.
        else do:
            tt_block:
            for each tt_titulos_em_aberto_acr no-lock
                where tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr >= p_dat_inic
                  and tt_titulos_em_aberto_acr.tta_dat_vencto_tit_acr <= p_dat_fim
                  AND tt_titulos_em_aberto_acr.ttv_cod_convenio >= v_cod_convenio_ini
                  AND tt_titulos_em_aberto_acr.ttv_cod_convenio <= v_cod_convenio_fim
                break by tt_titulos_em_aberto_acr.tta_cod_estab
                      by tt_titulos_em_aberto_acr.tta_cod_unid_negoc:

                if(tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ 
                or tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto = "Nota CrÇdito" /*l_nota_credito*/ ) then
                    assign v_val_unid_negoc_antecip = v_val_unid_negoc_antecip + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                else
                    assign v_val_unid_negoc_normal = v_val_unid_negoc_normal + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.           

                if  tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto <> "Antecipaá∆o" /*l_antecipacao*/ 
                then do:
                    assign v_val_unid_negoc = v_val_unid_negoc + tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.
                end /* if */.
                else do:


                    assign v_val_unid_negoc = v_val_unid_negoc - tt_titulos_em_aberto_acr.ttv_val_sdo_tit_acr_apres.

                end /* else */.

                if  last-of(tt_titulos_em_aberto_acr.tta_cod_unid_negoc)
                then do:
                    find unid_negoc no-lock
                        where unid_negoc.cod_unid_negoc = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                        no-error.
                    create tt_tot_movtos_acr.
                    assign tt_tot_movtos_acr.ttv_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                           tt_tot_movtos_acr.ttv_cod_unid_negoc     = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                           tt_tot_movtos_acr.tta_cod_estab          = tt_titulos_em_aberto_acr.tta_cod_estab
                           tt_tot_movtos_acr.tta_cod_unid_negoc     = tt_titulos_em_aberto_acr.tta_cod_unid_negoc
                           tt_tot_movtos_acr.ttv_val_tot_movto      = v_val_unid_negoc
                           tt_tot_movtos_acr.ttv_num_ord_reg        = v_num_ord_reg
                           tt_tot_movtos_acr.ttv_log_graf           = yes
                           tt_tot_movtos_acr.ttv_val_tot_geral_antecip = v_val_unid_negoc_antecip
                           tt_tot_movtos_acr.ttv_val_tot_geral_normal  = v_val_unid_negoc_normal
                           v_num_ord_reg                            = v_num_ord_reg + 1
                           v_val_tot                                = v_val_tot + v_val_unid_negoc
                           v_val_unid_negoc                         = 0
                           v_val_unid_negoc_antecip                 = 0
                           v_val_unid_negoc_normal                  = 0.

                    if  p_dat_fim >= v_dat_tit_acr_aber then do:
                        assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                               tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_2 = p_dat_inic - v_dat_tit_acr_aber
                               tt_tot_movtos_acr.ttv_num_dias_avencer_3 = p_dat_fim  - v_dat_tit_acr_aber
                               tt_tot_movtos_acr.ttv_ind_vencid_avencer = "A Venc" /*l_a_venc*/ .
                    end.
                    else do:
                        assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                               tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_2 = v_dat_tit_acr_aber - p_dat_fim
                               tt_tot_movtos_acr.ttv_num_dias_avencer_3 = v_dat_tit_acr_aber - p_dat_inic
                               tt_tot_movtos_acr.ttv_ind_vencid_avencer = "Venc" /*l_venc*/ .
                    end.
                    assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "A" /*l_a*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_3 ) + " " + "D" /*l_d*/ .
                    if  p_dat_inic = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF then do:
                        assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "a mais de" /*l_a_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                    end.
                    if  p_dat_fim = 12/31/9999 then do:
                        assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "em mais de" /*l_em_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
                    end.
                end /* if */.
            end /* for tt_block */.
        end /* else */.
    end.    

    /* **
     Cria Registros zerados para colunas sem valor.
    ***/
    for each tt_estab_unid_negoc:
        if  not can-find( tt_tot_movtos_acr
                          where tt_tot_movtos_acr.tta_cod_estab      = tt_estab_unid_negoc.tta_cod_estab
                            and tt_tot_movtos_acr.tta_cod_unid_negoc = tt_estab_unid_negoc.tta_cod_unid_negoc
                            and tt_tot_movtos_acr.ttv_dat_initial    = p_dat_inic
                            and tt_tot_movtos_acr.ttv_dat_final      = p_dat_fim ) then do:
            create tt_tot_movtos_acr.
            assign tt_tot_movtos_acr.ttv_cod_estab          = tt_estab_unid_negoc.tta_cod_estab
                   tt_tot_movtos_acr.ttv_cod_unid_negoc     = tt_estab_unid_negoc.tta_cod_unid_negoc
                   tt_tot_movtos_acr.tta_cod_estab          = tt_estab_unid_negoc.tta_cod_estab
                   tt_tot_movtos_acr.tta_cod_unid_negoc     = tt_estab_unid_negoc.tta_cod_unid_negoc
                   tt_tot_movtos_acr.ttv_val_tot_movto      = 0
                   tt_tot_movtos_acr.ttv_num_ord_reg        = v_num_ord_reg
                   tt_tot_movtos_acr.ttv_log_graf           = yes
                   tt_tot_movtos_acr.ttv_val_tot_geral_antecip = 0
                   tt_tot_movtos_acr.ttv_val_tot_geral_normal  = 0 
                   v_num_ord_reg                            = v_num_ord_reg + 1.
            if  p_dat_fim >= v_dat_tit_acr_aber then do:
                assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                       tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                       tt_tot_movtos_acr.ttv_num_dias_avencer_2 = p_dat_inic - v_dat_tit_acr_aber
                       tt_tot_movtos_acr.ttv_num_dias_avencer_3 = p_dat_fim  - v_dat_tit_acr_aber
                       tt_tot_movtos_acr.ttv_ind_vencid_avencer = "A Venc" /*l_a_venc*/ .
            end.
            else do:
                assign tt_tot_movtos_acr.ttv_dat_initial        = p_dat_inic
                       tt_tot_movtos_acr.ttv_dat_final          = p_dat_fim
                       tt_tot_movtos_acr.ttv_num_dias_avencer_2 = v_dat_tit_acr_aber - p_dat_fim
                       tt_tot_movtos_acr.ttv_num_dias_avencer_3 = v_dat_tit_acr_aber - p_dat_inic
                       tt_tot_movtos_acr.ttv_ind_vencid_avencer = "Venc" /*l_venc*/ .
            end.
            assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "A" /*l_a*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_3 ) + " " + "D" /*l_d*/ .
            if  p_dat_inic = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF then do:
                assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "a mais de" /*l_a_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
            end.
            if  p_dat_fim = 12/31/9999 then do:
                assign tt_tot_movtos_acr.ttv_nom_pessoa = tt_tot_movtos_acr.ttv_ind_vencid_avencer + " " + "em mais de" /*l_em_mais_de*/  + " " + string( tt_tot_movtos_acr.ttv_num_dias_avencer_2 ) + " " + "D" /*l_d*/ .
            end.
        end.
    end.
END PROCEDURE. /* pi_totaliza_tit_acr_aber_param */
/*****************************************************************************
** Procedure Interna.....: pi_vld_permissao_usuar_estab_empres
** Descricao.............: pi_vld_permissao_usuar_estab_empres
** Criado por............: bre18732
** Criado em.............: 21/06/2002 16:19:21
** Alterado por..........: fut42625
** Alterado em...........: 12/08/2011 10:26:24
*****************************************************************************/
PROCEDURE pi_vld_permissao_usuar_estab_empres:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_reg_corporat
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Registro Corporativo"
        column-label "Registro Corporativo"
        no-undo.
    def var v_log_restric_estab
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Usa Segur Estab"
        column-label "Usa Segur Estab"
        no-undo.
    def var v_nom_razao_social
        as character
        format "x(30)":U
        label "Raz∆o Social"
        column-label "Raz∆o Social"
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_vld_permissao_usuar_estab_empres */
    find last param_geral_apb no-lock no-error.
    if p_cod_modul_dtsul = "EMS2" /*l_ems_2*/  then do:
        assign v_log_reg_corporat = yes.
    end.
    else do:
        if avail param_geral_apb then 
            assign v_log_reg_corporat = param_geral_apb.log_reg_corporat.
    end.



    assign v_log_restric_estab = no.
    &IF DEFINED(BF_FIN_SEGUR_ESTABELEC) &THEN
        case p_cod_modul_dtsul:
            when "ACR" /*l_acr*/  then do:
                find last param_geral_acr no-lock no-error.
                if avail param_geral_acr then
                    assign v_log_restric_estab = param_geral_acr.log_restric_estab.
            end.
            when "APB" /*l_apb*/  then do:
                find last param_geral_apb no-lock no-error.
                if avail param_geral_apb then
                    assign v_log_restric_estab = param_geral_apb.log_restric_estab.
            end.
            when "EMS2" /*l_ems_2*/  then do:
            /* QUANDO FOR CHAMADO PELO EMS2 DEVERµ FAZER A RESTRIÄ«O DOS ESTABELECIMENTOS */        
                assign v_log_restric_estab = yes.
            end.
            otherwise
                assign v_log_restric_estab = no.
        end case.
    &ELSE
        if v_log_reg_corporat then
            assign v_log_restric_estab = yes.
    &ENDIF
    /* End_Include: i_vld_permissao_usuar_estab_empres */


    for each tt_usuar_grp_usuar.
        delete tt_usuar_grp_usuar.
    end.

    /* Cria TT com os grupos de usu†rios */
    for each usuar_grp_usuar where 
             usuar_grp_usuar.cod_usuario = v_cod_usuar_corren no-lock:
        find first tt_usuar_grp_usuar where 
                   tt_usuar_grp_usuar.cod_grp_usuar = usuar_grp_usuar.cod_grp_usuar
               and tt_usuar_grp_usuar.cod_usuario   = usuar_grp_usuar.cod_usuario no-lock no-error.
        if not avail tt_usuar_grp_usuar then do:
            create tt_usuar_grp_usuar.
            buffer-copy usuar_grp_usuar to tt_usuar_grp_usuar.
        end.
    end.
    /* Cria Grupo '*' */
    find first tt_usuar_grp_usuar where 
               tt_usuar_grp_usuar.cod_grp_usuar = "*"
           and tt_usuar_grp_usuar.cod_usuario   = v_cod_usuar_corren no-lock no-error.
    if not avail tt_usuar_grp_usuar then do:
        create tt_usuar_grp_usuar.
        assign tt_usuar_grp_usuar.cod_grp_usuar = "*"
               tt_usuar_grp_usuar.cod_usuario   = v_cod_usuar_corren.
    end.

    for each tt_empresa:
        delete tt_empresa.

    end.

    if v_log_reg_corporat = yes then do:
        for each empresa no-lock:
            for each tt_usuar_grp_usuar:
                /* Verifica se o Usu†rio tem permiss∆o na Empresa */
                if not can-find(first segur_unid_organ where
                                      segur_unid_organ.cod_unid_organ = empresa.cod_empresa 
                                 and (segur_unid_organ.cod_grp_usuar  = tt_usuar_grp_usuar.cod_grp_usuar
                                  or  segur_unid_organ.cod_grp_usuar  = "*")) then 
                   next.

                create tt_empresa.
                assign tt_empresa.tta_cod_empresa = empresa.cod_empresa.
                leave.
            end.
        end.
    end.
    else do:
        create tt_empresa.
        assign tt_empresa.tta_cod_empresa = v_cod_empres_usuar.
    end.

    for each tt_estabelecimento_empresa:
        delete tt_estabelecimento_empresa.
    end.

    for each tt_empresa no-lock:
        /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
        assign v_nom_razao_social = "" /*l_*/ .
        find empresa no-lock where empresa.cod_empresa = tt_empresa.tta_cod_empresa no-error.
        if avail empresa then          
            assign v_nom_razao_social = empresa.nom_razao_social.

        for each estabelecimento where 
                 estabelecimento.cod_empresa = tt_empresa.tta_cod_empresa no-lock:
            if v_log_restric_estab then do:
                for each tt_usuar_grp_usuar:
                   /* Verifica se o Usu†rio tem permiss∆o no Estabelecimento */
                    if not can-find(first segur_unid_organ where
                                            segur_unid_organ.cod_unid_organ = estabelecimento.cod_estab
                                       and (segur_unid_organ.cod_grp_usuar  = tt_usuar_grp_usuar.cod_grp_usuar
                                         or segur_unid_organ.cod_grp_usuar  = "*")) then 
                        next.

                    create tt_estabelecimento_empresa. 
                    assign tt_estabelecimento_empresa.tta_cod_estab        = estabelecimento.cod_estab
                           tt_estabelecimento_empresa.tta_nom_pessoa       = estabelecimento.nom_pessoa
                           tt_estabelecimento_empresa.tta_cod_empresa      = estabelecimento.cod_empresa
                           /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
                           tt_estabelecimento_empresa.tta_nom_razao_social = v_nom_razao_social.
                    leave.
                end.
            end.
            else do:
                create tt_estabelecimento_empresa. 
                assign tt_estabelecimento_empresa.tta_cod_estab        = estabelecimento.cod_estab
                       tt_estabelecimento_empresa.tta_nom_pessoa       = estabelecimento.nom_pessoa
                       tt_estabelecimento_empresa.tta_cod_empresa      = estabelecimento.cod_empresa
                       /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
                       tt_estabelecimento_empresa.tta_nom_razao_social = v_nom_razao_social.
            end.
        end.
    end.

    assign v_des_estab_select = "".
    for each tt_estabelecimento_empresa:
        if v_des_estab_select = "" then
            assign v_des_estab_select = tt_estabelecimento_empresa.tta_cod_estab.
        else
            assign v_des_estab_select = v_des_estab_select + "," + tt_estabelecimento_empresa.tta_cod_estab.
    end.
END PROCEDURE. /* pi_vld_permissao_usuar_estab_empres */
/*****************************************************************************
** Procedure Interna.....: pi_vld_valores_apres_acr
** Descricao.............: pi_vld_valores_apres_acr
** Criado por............: src370
** Criado em.............: 31/10/2002 16:52:06
** Alterado por..........: fut35058
** Alterado em...........: 22/12/2005 16:33:25
*****************************************************************************/
PROCEDURE pi_vld_valores_apres_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_finalid_econ_apres
        as character
        format "x(10)"
        no-undo.
    def Input param p_dat_conver
        as date
        format "99/99/9999"
        no-undo.
    def output param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_empresa
        as character
        format "x(3)":U
        label "Empresa"
        column-label "Empresa"
        no-undo.
    def var v_cod_empresa_2
        as character
        format "x(3)":U
        label "Empresa"
        column-label "Empresa"
        no-undo.
    def var v_cod_indic_econ_base
        as character
        format "x(8)":U
        label "Moeda Base"
        column-label "Moeda Base"
        no-undo.
    def var v_cod_indic_econ_idx
        as character
        format "x(8)":U
        label "Moeda ÷ndice"
        column-label "Moeda ÷ndice"
        no-undo.
    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_des_empres_select
        as character
        format "x(2000)":U
        view-as editor max-chars 2000 no-word-wrap
        size 30 by 1
        bgcolor 15 font 2
        no-undo.
    def var v_num_cont_2
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_cont_3
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    find finalid_econ no-lock
         where finalid_econ.cod_finalid_econ = p_cod_finalid_econ
         no-error.
    if  not avail finalid_econ
    then do:
        /* Finalidade Econìmica inexistente ! */
        run pi_messages (input "show",
                         input 1652,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1652*/.
        assign v_cod_erro = '1652'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  finalid_econ.ind_armaz_val <> "M¢dulos" /*l_modulos*/ 
    then do:
        /* Finalidade Econìmica n∆o armazena valores no M¢dulo ! */
        run pi_messages (input "show",
                         input 1389,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            p_cod_finalid_econ)) /*msg_1389*/.
        assign v_cod_erro = '1389'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    for each tt_empresa_selec:
        delete tt_empresa_selec.
    end.    

    assign v_des_empres_select = " ".
    do v_num_cont_2 = 1 to num-entries(v_des_estab_select):
        find estabelecimento no-lock
            where estabelecimento.cod_estab = entry(v_num_cont_2, v_des_estab_select) no-error.
        if avail estabelecimento then do:    
            find tt_empresa_selec no-lock
                where tt_empresa_selec.tta_cod_empresa = estabelecimento.cod_empresa no-error.
            if not avail tt_empresa_selec then do:
                create tt_empresa_selec.
                assign tt_empresa_selec.tta_cod_empresa = estabelecimento.cod_empresa.        
                find finalid_unid_organ no-lock
                     where finalid_unid_organ.cod_unid_organ   = estabelecimento.cod_empresa
                     and   finalid_unid_organ.cod_finalid_econ = p_cod_finalid_econ
                     no-error.
                if  not avail finalid_unid_organ
                then do:
                    if v_des_empres_select = " " then
                        assign v_des_empres_select = estabelecimento.cod_empresa.
                    else     
                        assign v_des_empres_select = v_des_empres_select + ", " + estabelecimento.cod_empresa.
                end /* if */.
            end.    
        end.    
    end.    

    if v_des_empres_select <> " " then do:
        /* Finalidade Econìmica n∆o liberada para Empresa ! */
        run pi_messages (input "show",
                         input 8751,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            v_des_empres_select)) /*msg_8751*/.
        v_cod_erro = '8751'.
        return "NOK" /*l_nok*/ .
    end.    

    run pi_retornar_indic_econ_finalid (Input p_cod_finalid_econ,
                                        Input p_dat_conver,
                                        output v_cod_indic_econ_base) /*pi_retornar_indic_econ_finalid*/.
    if  v_cod_indic_econ_base = ? or v_cod_indic_econ_base = " "
    then do:
        /* Hist¢rico da Finalidade Inexistente para Data Convers∆o ! */
        run pi_messages (input "show",
                         input 2452,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2452*/.
        assign v_cod_erro = '2452'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    find b_finalid_econ no-lock
         where b_finalid_econ.cod_finalid_econ = p_cod_finalid_econ_apres
         no-error.
    if  not avail b_finalid_econ
    then do:
        /* Finalidade Econìmica de Apresentaá∆o Inexistente ! */
        run pi_messages (input "show",
                         input 2450,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2450*/.
        assign v_cod_erro = '2450'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    for each tt_empresa_selec:
        delete tt_empresa_selec.
    end.    

    assign v_des_empres_select = " ".
    do v_num_cont_3 = 1 to num-entries(v_des_estab_select):
        find estabelecimento no-lock
            where estabelecimento.cod_estab = entry(v_num_cont_3, v_des_estab_select) no-error.
        if avail estabelecimento then do:    
            find tt_empresa_selec no-lock
                where tt_empresa_selec.tta_cod_empresa = estabelecimento.cod_empresa no-error.
            if not avail tt_empresa_selec then do:
                create tt_empresa_selec.
                assign tt_empresa_selec.tta_cod_empresa = estabelecimento.cod_empresa.        
                find b_finalid_unid_organ no-lock
                     where b_finalid_unid_organ.cod_unid_organ   = estabelecimento.cod_empresa
                     and   b_finalid_unid_organ.cod_finalid_econ = p_cod_finalid_econ_apres
                     no-error.
                if  not avail b_finalid_unid_organ
                then do:
                    if v_des_empres_select = " " then
                        assign v_des_empres_select = estabelecimento.cod_empresa.
                    else     
                        assign v_des_empres_select = v_des_empres_select + ", " + estabelecimento.cod_empresa.        
                end /* if */.
            end.    
        end.    
    end.

    if v_des_empres_select <> " " then do:
        /* Finalidade Econìmica Apresentaá∆o n∆o liberada para Empresa ! */
        run pi_messages (input "show",
                         input 8752,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            v_des_empres_select)) /*msg_8752*/.
        assign v_cod_erro = '8752'.
        return "NOK" /*l_nok*/ .
    end.    

    run pi_retornar_indic_econ_finalid (Input p_cod_finalid_econ_apres,
                                        Input p_dat_conver,
                                        output v_cod_indic_econ_idx) /*pi_retornar_indic_econ_finalid*/.
    if  v_cod_indic_econ_idx = ? or v_cod_indic_econ_idx = " "
    then do:
        /* Hist¢rico Finalid. Apresent. Inexistente p/ Data Convers∆o ! */
        run pi_messages (input "show",
                         input 2453,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2453*/.
        assign v_cod_erro = '2453'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    run pi_achar_cotac_indic_econ (Input v_cod_indic_econ_base,
                                   Input v_cod_indic_econ_idx,
                                   Input p_dat_conver,
                                   Input "Real" /*l_real*/,
                                   output p_dat_cotac_indic_econ,
                                   output p_val_cotac_indic_econ,
                                   output v_cod_return) /*pi_achar_cotac_indic_econ*/.
    if  v_cod_return <> "OK" /*l_ok*/ 
    then do:
        assign p_val_cotac_indic_econ = 1.
        /* Cotaá∆o entre Indicadores Econìmicos n∆o encontrada ! */
        run pi_messages (input "show",
                         input 358,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            entry(2,v_cod_return), entry(3,v_cod_return), entry(4,v_cod_return), entry(5,v_cod_return))) /*msg_358*/.
        assign v_cod_erro = '358'.
        return "NOK" /*l_nok*/ .
    end /* if */.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_vld_valores_apres_acr */
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
** Procedure Interna.....: pi_choose_bt_fil2_rpt_tit_acr_em_aberto
** Descricao.............: pi_choose_bt_fil2_rpt_tit_acr_em_aberto
** Criado por............: bre19062
** Criado em.............: 03/12/2002 11:51:07
** Alterado por..........: fut42929
** Alterado em...........: 08/06/2011 11:24:43
*****************************************************************************/
PROCEDURE pi_choose_bt_fil2_rpt_tit_acr_em_aberto:

    view frame f_fil_01_tit_acr_em_aberto_rpt.

    assign v_qtd_dias_avencer = 9999.


    display v_dat_calc_atraso
            v_log_consid_abat
            v_log_consid_desc
            v_log_consid_impto_retid
            v_log_mostra_docto_acr_antecip
            v_log_mostra_docto_acr_aviso_db
            v_log_mostra_docto_acr_cheq
            v_log_mostra_docto_acr_normal
            v_log_mostra_docto_acr_prev
            v_log_tit_acr_avencer
            v_log_tit_acr_estordo
            v_log_tit_acr_indcao_perda_dedut
            v_log_tit_acr_nao_indcao_perda
            v_log_tit_acr_vencid
            v_qtd_dias_avencer
            v_qtd_dias_vencid
            v_log_consid_juros
            with frame f_fil_01_tit_acr_em_aberto_rpt.

    enable v_dat_calc_atraso
           v_log_consid_abat
           v_log_consid_desc
           v_log_consid_impto_retid
           v_log_mostra_docto_acr_antecip
           v_log_mostra_docto_acr_aviso_db
           v_log_mostra_docto_acr_cheq
           v_log_mostra_docto_acr_normal
           v_log_mostra_docto_acr_prev
           v_log_tit_acr_avencer
           v_log_tit_acr_estordo
           v_log_tit_acr_indcao_perda_dedut
           v_log_tit_acr_nao_indcao_perda
           v_log_tit_acr_vencid
           v_log_consid_juros
           with frame f_fil_01_tit_acr_em_aberto_rpt.

    apply "value-changed" to v_log_tit_acr_avencer in frame f_fil_01_tit_acr_em_aberto_rpt.
    apply "value-changed" to v_log_tit_acr_vencid  in frame f_fil_01_tit_acr_em_aberto_rpt.

    &if defined(BF_FIN_CONTROL_CHEQUES) &then
        display v_log_mostra_acr_cheq_recbdo
                v_log_mostra_acr_cheq_devolv
                with frame f_fil_01_tit_acr_em_aberto_rpt.

        enable v_log_mostra_acr_cheq_recbdo
               v_log_mostra_acr_cheq_devolv
               with frame f_fil_01_tit_acr_em_aberto_rpt.
        assign v_log_control_cheq = yes.                    
    &else
        assign v_log_mostra_acr_cheq_recbdo:visible in frame f_fil_01_tit_acr_em_aberto_rpt = no
               v_log_mostra_acr_cheq_devolv:visible in frame f_fil_01_tit_acr_em_aberto_rpt = no
               v_log_control_cheq = no.               
    &endif

    if v_log_control_terc_acr = yes then do:
        display v_log_tip_espec_docto_cheq_terc
                v_log_tip_espec_docto_terc
                with frame f_fil_01_tit_acr_em_aberto_rpt.

        enable v_log_tip_espec_docto_cheq_terc
               v_log_tip_espec_docto_terc
               with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
    else do:
        assign v_log_tip_espec_docto_cheq_terc:visible in frame f_fil_01_tit_acr_em_aberto_rpt = no
               v_log_tip_espec_docto_terc     :visible in frame f_fil_01_tit_acr_em_aberto_rpt = no.
    end.

    if  v_log_modul_vendor then do:
        enable v_log_mostra_docto_vendor
               v_log_mostra_docto_vendor_repac
               with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
    else do:
        assign v_log_mostra_docto_vendor       = no
               v_log_mostra_docto_vendor_repac = no.
        disable v_log_mostra_docto_vendor
                v_log_mostra_docto_vendor_repac
                with frame f_fil_01_tit_acr_em_aberto_rpt.

    end. 
    display v_log_mostra_docto_vendor
            v_log_mostra_docto_vendor_repac
            with frame f_fil_01_tit_acr_em_aberto_rpt.

    if  v_log_funcao_juros_multa
    then do:
        display v_log_consid_multa
                with frame f_fil_01_tit_acr_em_aberto_rpt.
        enable v_log_consid_multa
               with frame f_fil_01_tit_acr_em_aberto_rpt.
    end.
    else
        assign v_log_consid_multa:visible in frame f_fil_01_tit_acr_em_aberto_rpt = no
               v_log_consid_multa = no.

    filter_block:
    do on error undo filter_block, retry filter_block:

    /* if v_log_control_terc_acr = no then do:
            @update(f_fil_01_tit_acr_em_aberto_rpt, bt_can,
                                                    bt_hel2,
                                                    bt_ok,
                                                    v_dat_calc_atraso,
                                                    v_log_consid_abat,
                                                    v_log_consid_desc,
                                                    v_log_consid_impto_retid,
                                                    v_log_mostra_docto_acr_antecip,
                                                    v_log_mostra_docto_acr_aviso_db,
                                                    v_log_mostra_docto_acr_cheq,
                                                    v_log_mostra_docto_acr_normal,
                                                    v_log_mostra_docto_acr_prev,
                                                    v_log_tit_acr_avencer,
                                                    v_log_tit_acr_estordo,
                                                    v_log_tit_acr_indcao_perda_dedut,
                                                    v_log_tit_acr_nao_indcao_perda,
                                                    v_log_tit_acr_vencid,
                                                    v_qtd_dias_avencer,
                                                    v_qtd_dias_vencid,
                                                    v_log_consid_juros).
        end.
        else do:
            @update(f_fil_01_tit_acr_em_aberto_rpt, bt_can,
                                                    bt_hel2,
                                                    bt_ok,
                                                    v_dat_calc_atraso,
                                                    v_log_consid_abat,
                                                    v_log_consid_desc,
                                                    v_log_consid_impto_retid,
                                                    v_log_mostra_docto_acr_antecip,
                                                    v_log_mostra_docto_acr_aviso_db,
                                                    v_log_mostra_docto_acr_cheq,
                                                    v_log_mostra_docto_acr_normal,
                                                    v_log_mostra_docto_acr_prev,
                                                    v_log_tip_espec_docto_cheq_terc,
                                                    v_log_tip_espec_docto_terc,
                                                    v_log_tit_acr_avencer,
                                                    v_log_tit_acr_estordo,
                                                    v_log_tit_acr_indcao_perda_dedut,
                                                    v_log_tit_acr_nao_indcao_perda,
                                                    v_log_tit_acr_vencid,
                                                    v_qtd_dias_avencer,
                                                    v_qtd_dias_vencid,
                                                    v_log_consid_juros).
        end.
        */
        update bt_can
               bt_hel2
               bt_ok
               v_dat_calc_atraso
               v_log_consid_abat
               v_log_consid_desc
               v_log_consid_impto_retid
               v_log_mostra_docto_acr_antecip
               v_log_mostra_docto_acr_aviso_db
               v_log_mostra_docto_acr_cheq     when v_log_control_cheq     = no
               v_log_mostra_docto_acr_normal
               v_log_mostra_docto_acr_prev
               v_log_tip_espec_docto_cheq_terc when v_log_control_terc_acr = yes
               v_log_tip_espec_docto_terc      when v_log_control_terc_acr = yes
               v_log_mostra_docto_vendor       when v_log_modul_vendor     = yes
               v_log_mostra_docto_vendor_repac when v_log_modul_vendor     = yes
               v_log_mostra_acr_cheq_recbdo    when v_log_control_cheq     = yes
               v_log_mostra_acr_cheq_devolv    when v_log_control_cheq     = yes         
               v_log_tit_acr_avencer
               v_log_tit_acr_estordo
               v_log_tit_acr_indcao_perda_dedut
               v_log_tit_acr_nao_indcao_perda
               v_log_tit_acr_vencid
               v_qtd_dias_avencer
               v_qtd_dias_vencid
               v_log_consid_juros
               v_log_consid_multa              when v_log_funcao_juros_multa = yes
               with frame f_fil_01_tit_acr_em_aberto_rpt.

    end /* do filter_block */.
    hide frame f_fil_01_tit_acr_em_aberto_rpt.
END PROCEDURE. /* pi_choose_bt_fil2_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_choose_bt_print_rpt_tit_acr_em_aberto
** Descricao.............: pi_choose_bt_print_rpt_tit_acr_em_aberto
** Criado por............: src12115
** Criado em.............: 20/02/2004 14:21:04
** Alterado por..........: fut42929
** Alterado em...........: 08/06/2011 09:20:35
*****************************************************************************/
PROCEDURE pi_choose_bt_print_rpt_tit_acr_em_aberto:

    /************************* Variable Definition Begin ************************/

    def var v_log_answer
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_cod_erro = "" /*l_null*/ .

    print_block:
    do on error undo print_block, return "NOK" /*l_nok*/:
        run pi_vld_valores_apres_acr (Input input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ,
                                      Input input frame f_rpt_41_tit_acr_em_aberto v_cod_finalid_econ_apres,
                                      Input input frame f_rpt_41_tit_acr_em_aberto v_dat_cotac_indic_econ,
                                      output v_dat_conver,
                                      output v_val_cotac_indic_econ) /*pi_vld_valores_apres_acr*/.

        if return-value <> "OK" /*l_ok*/  then
               return "NOK" /*l_nok*/ .

        if  v_cod_arq_planilha <> ""
        and input frame f_rpt_41_tit_acr_em_aberto rs_ind_run_mode <> "Batch" /*l_batch*/  then do:
            assign v_cod_arq_planilha  = replace(v_cod_arq_planilha, '~\', '~/')
                   file-info:file-name = substring(v_cod_arq_planilha, 1, r-index(v_cod_arq_planilha, '~/') - 1).
            if  file-info:file-name <> ""
            and file-info:file-type = ? then do:
                /* O diret¢rio &1 n∆o existe ! */
                run pi_messages (input "show",
                                 input 4354,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    v_cod_arq_planilha)) /*msg_4354*/.
                undo, return no-apply.
            end.
        end.

        if  input frame f_rpt_41_tit_acr_em_aberto v_dat_tit_acr_aber <> v_dat_calc_atraso
        then do:
            run pi_messages (input "show",
                             input 9494,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign v_log_answer = (if   return-value = "yes" then yes
                                   else if return-value = "no" then no
                                   else ?) /*msg_9494*/.
            if v_log_answer <> yes 
                then undo, return no-apply.
        end /* if */.


        if  v_log_mostra_docto_acr_prev     = no
        and  v_log_mostra_docto_acr_normal   = no
        and  v_log_mostra_docto_acr_cheq     = no
        and  v_log_mostra_docto_acr_aviso_db = no
        and  v_log_mostra_docto_acr_antecip  = no
        and  v_log_tip_espec_docto_terc      = no
        and  v_log_tip_espec_docto_cheq_terc = no
        &if defined(BF_FIN_CONTROL_CHEQUES) &then
        and  v_log_mostra_acr_cheq_recbdo    = no
        and  v_log_mostra_acr_cheq_devolv    = no
        &endif
        and  v_log_mostra_docto_vendor       = no
        and  v_log_mostra_docto_vendor_repac = no
        then do:
            /* Tipo EspÇcie deve ser informado. */
            run pi_messages (input "show",
                             input 4320,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4320*/.
            return no-apply. 
        end. 

        if  (v_log_funcao_aging_acr = no and
             input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_analit = no and
             input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_sint   = no)
        or (v_log_funcao_aging_acr = yes and
            input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_analit = no and
            input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_sint   = no and
            input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_clien  = no)
        then do:
            /* &1 deve ser informado(a). */
            run pi_messages (input "show",
                             input 9612,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Visualizaá∆o" /*l_visualizacao*/)) /*msg_9612*/.
            return no-apply.
        end.

        if  v_log_funcao_aging_acr = YES
        then do:
            if  input frame f_rpt_41_tit_acr_em_aberto v_log_visualiz_clien = yes and
               (v_ind_classif_tit_acr_em_aber <> "Por Cliente/Vencimento" /*l_por_clientevencimento*/   and
                v_ind_classif_tit_acr_em_aber <> "Por Nome Cliente/Vencimento" /*l_por_nome_clientevencimento*/  and
                v_ind_classif_tit_acr_em_aber <> "Por Matriz" /*l_por_matriz*/ )
            then do:
                /* Classificaá∆o inv†lida para a opá∆o selecionada ! */
                run pi_messages (input "show",
                                 input 11657,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    "Imprime Resumo Cliente" /*l_imp_resumo_cliente*/                               , "Por Cliente/Vencimento" /*l_por_clientevencimento*/                               , "Por Nome Cliente/Vencimento" /*l_por_nome_clientevencimento*/                               , "Por Matriz" /*l_por_matriz*/)) /*msg_11657*/.
                return no-apply.
            end /* if */.
        end /* if */.

        if  v_log_tit_acr_indcao_perda_dedut = no and 
            v_log_tit_acr_nao_indcao_perda   = no
        then do:
            /* Informar se deve imprimir T°tulo Indicado p/ Perda Dedut°vel ! */
            run pi_messages (input "show",
                             input 9608,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_9608*/.
            return no-apply. 
        end.

        if  v_log_tit_acr_avencer = no
        and v_log_tit_acr_vencid  = no
        then do:
            /* &1 deve ser informado(a). */
            run pi_messages (input "show",
                             input 9612,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Situaá∆o" /*l_situacao2*/)) /*msg_9612*/.
            return no-apply.
        end.

        &if defined(BF_FIN_CONTROL_CHEQUES) &then
            if  v_log_mostra_docto_acr_cheq and (v_log_mostra_acr_cheq_recbdo = no and v_log_mostra_acr_cheq_devolv = no)
            then do:
                /* Informar cheque Recebido/Devolvido. */
                run pi_messages (input "show",
                                 input 20975,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_20975*/.
                return no-apply.
            end.
        &endif

do:
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_restricoes in v_prog_filtro_pdf (input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_em_aberto).
    if return-value = 'nok' then 
        return no-apply.
&endif
/* tech38629 - Fim da alteraá∆o */
        assign v_log_print = yes.
end.
    end /* do print_block */.
    return "OK" /*l_ok*/ .

END PROCEDURE. /* pi_choose_bt_print_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_ix_p15_rpt_tit_acr_em_aberto
** Descricao.............: pi_ix_p15_rpt_tit_acr_em_aberto
** Criado por............: bre18490
** Criado em.............: 07/05/2004 18:36:41
** Alterado por..........: fut42625_3
** Alterado em...........: 15/02/2011 14:53:14
*****************************************************************************/
PROCEDURE pi_ix_p15_rpt_tit_acr_em_aberto:

    assign dwb_rpt_param.cod_dwb_parameters =
           string(v_dat_tit_acr_aber)              + chr(10) +
           v_cod_finalid_econ                      + chr(10) +
           v_cod_finalid_econ_apres                + chr(10) +
           string(v_dat_cotac_indic_econ)          + chr(10) +
           string(v_val_cotac_indic_econ)          + chr(10) +
           v_ind_visualiz_tit_acr_vert             + chr(10) +
           string(v_log_visualiz_analit)           + chr(10) +
           string(v_log_visualiz_sint)             + chr(10) +
           string(v_log_mostra_docto_acr_antecip)  + chr(10) +
           string(v_log_mostra_docto_acr_prev)     + chr(10) +
           string(v_log_mostra_docto_acr_normal)   + chr(10) +
           string(v_log_mostra_docto_acr_aviso_db) + chr(10) +
           string(v_log_tit_acr_vencid)            + chr(10) +
           string(v_qtd_dias_vencid)               + chr(10) +
           string(v_log_emit_movto_cobr)           + chr(10) +
           string(v_dat_calc_atraso)               + chr(10) +
           string(v_log_tit_acr_avencer)           + chr(10) +
           string(v_qtd_dias_avencer).

    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters + chr(10) +
           string(v_cdn_cliente_ini)        + chr(10) +
           string(v_cdn_cliente_fim)        + chr(10) +
           string(v_cdn_repres_ini)         + chr(10) +
           string(v_cdn_repres_fim)         + chr(10) +
           v_cod_cart_bcia_ini              + chr(10) +
           v_cod_cart_bcia_fim              + chr(10) +
           v_cod_espec_docto_ini            + chr(10) +
           v_cod_espec_docto_fim            + chr(10) +
           ''                               + chr(10) +
           ''                               + chr(10) +
           /* Projeto 99 - Retirada a faixa de estabelecimentos */
           v_cod_portador_ini               + chr(10) +
           v_cod_portador_fim               + chr(10) +
           v_cod_unid_negoc_ini             + chr(10) +
           v_cod_unid_negoc_fim             + chr(10) +
           string(v_dat_vencto_tit_acr_ini) + chr(10) +
           string(v_dat_vencto_tit_acr_fim) + chr(10) +
           string(v_cdn_clien_matriz_ini)   + chr(10) +
           string(v_cdn_clien_matriz_fim).

    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters + chr(10) +
           v_ind_classif_tit_acr_em_aber + chr(10) +
           string(v_log_classif_estab)   + chr(10) +
           string(v_log_tot_clien)       + chr(10) +
           string(v_log_tot_estab)       + chr(10) +
           string(v_log_tot_matriz)      + chr(10) +
           string(v_log_tot_portad_cart) + chr(10) +
           string(v_log_tot_repres)      + chr(10) +
           string(v_log_tot_vencto)      + chr(10) +
           v_cod_order_rpt.

    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters + chr(10) +
           string(v_num_dias_avencer_1)  + chr(10) +
           string(v_num_dias_avencer_2)  + chr(10) +
           string(v_num_dias_avencer_3)  + chr(10) +
           string(v_num_dias_avencer_4)  + chr(10) +
           string(v_num_dias_avencer_5)  + chr(10) +
           string(v_num_dias_avencer_6)  + chr(10) +
           string(v_num_dias_avencer_7)  + chr(10) +
           string(v_num_dias_avencer_8)  + chr(10) +
           string(v_num_dias_avencer_9)  + chr(10) +
           string(v_num_dias_avencer_10) + chr(10) +
           string(v_num_dias_avencer_11) + chr(10) +
           string(v_num_dias_avencer_12) + chr(10) +
           string(v_num_dias_vencid_1)   + chr(10) +
           string(v_num_dias_vencid_2)   + chr(10) +
           string(v_num_dias_vencid_3)   + chr(10) +
           string(v_num_dias_vencid_4)   + chr(10) +
           string(v_num_dias_vencid_5)   + chr(10) +
           string(v_num_dias_vencid_6)   + chr(10) +
           string(v_num_dias_vencid_7)   + chr(10) +
           string(v_num_dias_vencid_8)   + chr(10) +
           string(v_num_dias_vencid_9)   + chr(10) +
           string(v_num_dias_vencid_10)  + chr(10) +
           string(v_num_dias_vencid_11)  + chr(10) +
           string(v_num_dias_vencid_12)  + chr(10) + 
           string(v_log_mostra_docto_acr_cheq) + chr(10) +
           v_cod_grp_clien_ini           + chr(10) +
           v_cod_grp_clien_fim.

    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters + chr(10) +
           string(v_log_tot_grp_clien)      + chr(10) +
           string(v_log_tit_acr_estordo)    + chr(10) +
           string(v_log_tot_cond_cobr)      + chr(10) +
           v_cod_cond_cobr_ini              + chr(10) +
           v_cod_cond_cobr_fim              + chr(10) +
           string(v_log_consid_abat)        + chr(10) + 
           string(v_log_consid_desc)        + chr(10) +
           string(v_log_consid_impto_retid) + chr(10) +
           string(v_log_tit_acr_indcao_perda_dedut) + chr(10) +
           string(v_log_tit_acr_nao_indcao_perda)   + chr(10) +
           string(v_log_consid_juros)               + chr(10) +
           string(v_log_nao_impr_tit)       + chr(10) +
           string(v_log_gerac_planilha)     + chr(10) +
           v_cod_arq_planilha               + chr(10) +
           v_cod_carac_lim                  + chr(10) +
           string(v_log_tot_espec_docto)    + chr(10) +
           string(v_des_estab_select).

    /* Funá∆o v_log_funcao_aging_acr = yes */
    assign dwb_rpt_param.cod_dwb_parameters = if v_log_funcao_aging_acr = yes then dwb_rpt_param.cod_dwb_parameters + chr(10) + string(v_log_visualiz_clien)
                                              else dwb_rpt_param.cod_dwb_parameters + chr(10) + "".

    /* Func∆o Controle Terceiros */
    assign dwb_rpt_param.cod_dwb_parameters = if v_log_control_terc_acr = yes then dwb_rpt_param.cod_dwb_parameters + chr(10) + string(v_log_tip_espec_docto_terc) + chr(10) + string(v_log_tip_espec_docto_cheq_terc)
                                              else dwb_rpt_param.cod_dwb_parameters + chr(10) + "" + chr(10) + "".

    /* ==> MODULO VENDOR <== */
    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters        + chr(10) +
           string(v_log_mostra_docto_vendor)       + chr(10) +
           string(v_log_mostra_docto_vendor_repac).

    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters + chr(10) +
           v_cod_indic_econ_ini             + chr(10) + 
           v_cod_indic_econ_fim             + chr(10) + 
           string(v_log_consid_multa).
    /* funcao numero processo exportaá∆o */       
    assign dwb_rpt_param.cod_dwb_parameters =
           dwb_rpt_param.cod_dwb_parameters    + chr(10) +
           v_cod_proces_export_ini             + chr(10) + 
           v_cod_proces_export_fim             + chr(10) +
           string(v_log_tot_num_proces_export) + chr(10) +
           string(v_dat_emis_docto_ini)        + chr(10) +   
           string(v_dat_emis_docto_fim)        + chr(10) +
           v_cod_plano_cta_ctbl_inic           + chr(10) +
           v_cod_plano_cta_ctbl_final          + chr(10) +
           v_cod_cta_ctbl_ini                  + chr(10) +
           v_cod_cta_ctbl_final                + chr(10) +
           string(v_log_classif_un)            + chr(10) +
           string(v_log_tot_cta)               + chr(10) +
           string(v_log_tot_unid_negoc).

    &if defined(BF_FIN_CONTROL_CHEQUES) &then
        assign dwb_rpt_param.cod_dwb_parameters = 
    	   dwb_rpt_param.cod_dwb_parameters   + chr(10) + 
               string(v_log_mostra_acr_cheq_recbdo) + chr(10) + 
    	   string(v_log_mostra_acr_cheq_devolv).
    &else
        assign dwb_rpt_param.cod_dwb_parameters = 
    	   dwb_rpt_param.cod_dwb_parameters + chr(10) + 
    	   ""                               + chr(10) + 
    	   "".	
    &endif       
END PROCEDURE. /* pi_ix_p15_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_ix_p30_rpt_tit_acr_em_aberto
** Descricao.............: pi_ix_p30_rpt_tit_acr_em_aberto
** Criado por............: bre18490
** Criado em.............: 07/05/2004 18:38:45
** Alterado por..........: fut42625_3
** Alterado em...........: 15/02/2011 11:52:55
*****************************************************************************/
PROCEDURE pi_ix_p30_rpt_tit_acr_em_aberto:

    if  v_log_funcao_juros_multa
    then do:
        if (line-counter(s_1) + 25) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "---------------------------------------------" at 33
            "Visualizaá∆o" at 79
            "---------------------------------------------" at 94
            skip (1)
            "  Visualiza: " at 74
            v_ind_visualiz_tit_acr_vert at 87 format "X(20)" skip
            "  Anal°tico: " at 74.
    put stream s_1 unformatted 
            v_log_visualiz_analit at 87 format "Sim/N∆o" skip
            "  SintÇtico: " at 74
            v_log_visualiz_sint at 87 format "Sim/N∆o"
            skip (1)
            "---------------------------------------------" at 33
            "Apresentaá∆o  " at 79
            "---------------------------------------------" at 94
            skip (1)
            "  Posiá∆o Em: " at 73
            v_dat_tit_acr_aber at 87 format "99/99/9999" skip.
    put stream s_1 unformatted 
            "    Finalidade Econìmica: " at 61
            v_cod_finalid_econ at 87 format "x(10)" skip
            "Finalid Apresentaá∆o: " at 65
            v_cod_finalid_econ_apres at 87 format "x(10)" skip
            "Data Cotaá∆o: " at 73
            v_dat_cotac_indic_econ at 87 format "99/99/9999"
            skip (1)
            "---------------------------------------------" at 35
            "Situaá∆o" at 82
            "---------------------------------------------" at 92.
    put stream s_1 unformatted 
            skip (1)
            "  Vencidos: " at 60
            v_log_tit_acr_vencid at 72 format "Sim/N∆o"
            "  A mais de: " at 90
            v_qtd_dias_vencid to 106 format ">>>9"
            "Dias" at 108 skip
            "  A Vencer: " at 60
            v_log_tit_acr_avencer at 72 format "Sim/N∆o"
            " Em AtÇ: " at 94
            v_qtd_dias_avencer to 106 format ">>>9".
    put stream s_1 unformatted 
            "Dias" at 108 skip
            "    Calc Dias Atraso: " at 86
            v_dat_calc_atraso at 108 format "99/99/9999"
            skip (1)
            "---------------------------------------------" at 35
            "Considera " at 81
            "---------------------------------------------" at 92
            skip (1)
            "Estornados: " at 60
            v_log_tit_acr_estordo at 72 format "Sim/N∆o".
    put stream s_1 unformatted 
            "  Abatimento: " at 94
            v_log_consid_abat at 108 format "Sim/N∆o" skip
            "    Indic Perda Dedut: " at 49
            v_log_tit_acr_indcao_perda_dedut at 72 format "Sim/N∆o"
            "  Desconto: " at 96
            v_log_consid_desc at 108 format "Sim/N∆o" skip
            "    N∆o Indic Perd Dedut: " at 46
            v_log_tit_acr_nao_indcao_perda at 72 format "Sim/N∆o"
            "   Imposto Retido: " at 89
            v_log_consid_impto_retid at 108 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
            "   Juros: " at 62
            v_log_consid_juros at 72 format "Sim/N∆o"
            "Multa: " at 101
            v_log_consid_multa at 108 format "Sim/N∆o" skip.
    end.
    else do:
        if (line-counter(s_1) + 25) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "---------------------------------------------" at 33
            "Visualizaá∆o" at 79
            "---------------------------------------------" at 94
            skip (1)
            "  Visualiza: " at 74
            v_ind_visualiz_tit_acr_vert at 87 format "X(20)" skip
            "  Anal°tico: " at 74.
    put stream s_1 unformatted 
            v_log_visualiz_analit at 87 format "Sim/N∆o" skip
            "  SintÇtico: " at 74
            v_log_visualiz_sint at 87 format "Sim/N∆o"
            skip (1)
            "---------------------------------------------" at 33
            "Apresentaá∆o  " at 79
            "---------------------------------------------" at 94
            skip (1)
            "  Posiá∆o Em: " at 73
            v_dat_tit_acr_aber at 87 format "99/99/9999" skip.
    put stream s_1 unformatted 
            "    Finalidade Econìmica: " at 61
            v_cod_finalid_econ at 87 format "x(10)" skip
            "Finalid Apresentaá∆o: " at 65
            v_cod_finalid_econ_apres at 87 format "x(10)" skip
            "Data Cotaá∆o: " at 73
            v_dat_cotac_indic_econ at 87 format "99/99/9999"
            skip (1)
            "---------------------------------------------" at 35
            "Situaá∆o" at 82
            "---------------------------------------------" at 92.
    put stream s_1 unformatted 
            skip (1)
            "  Vencidos: " at 60
            v_log_tit_acr_vencid at 72 format "Sim/N∆o"
            "  A mais de: " at 90
            v_qtd_dias_vencid to 106 format ">>>9"
            "Dias" at 108 skip
            "  A Vencer: " at 60
            v_log_tit_acr_avencer at 72 format "Sim/N∆o"
            " Em AtÇ: " at 94
            v_qtd_dias_avencer to 106 format ">>>9".
    put stream s_1 unformatted 
            "Dias" at 108 skip
            "    Calc Dias Atraso: " at 86
            v_dat_calc_atraso at 108 format "99/99/9999"
            skip (1)
            "---------------------------------------------" at 35
            "Considera " at 81
            "---------------------------------------------" at 92
            skip (1)
            "Estornados: " at 60
            v_log_tit_acr_estordo at 72 format "Sim/N∆o".
    put stream s_1 unformatted 
            "  Abatimento: " at 94
            v_log_consid_abat at 108 format "Sim/N∆o" skip
            "    Indic Perda Dedut: " at 49
            v_log_tit_acr_indcao_perda_dedut at 72 format "Sim/N∆o"
            "  Desconto: " at 96
            v_log_consid_desc at 108 format "Sim/N∆o" skip
            "    N∆o Indic Perd Dedut: " at 46
            v_log_tit_acr_nao_indcao_perda at 72 format "Sim/N∆o"
            "   Imposto Retido: " at 89
            v_log_consid_impto_retid at 108 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
            "   Juros: " at 62
            v_log_consid_juros at 72 format "Sim/N∆o" skip.
    end.

    &if defined(BF_FIN_CONTROL_CHEQUES) &then
    if (line-counter(s_1) + 5) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "---------------------------------------------" at 33
        "Tipo EspÇcie  " at 79
        "---------------------------------------------" at 94 skip
        "  Normal: " at 77
        v_log_mostra_docto_acr_normal at 87 format "Sim/N∆o" skip
        "   Antecipaá∆o: " at 71
        v_log_mostra_docto_acr_antecip at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
        "  Previs∆o: " at 75
        v_log_mostra_docto_acr_prev at 87 format "Sim/N∆o" skip
        "   Aviso DÇbito: " at 70
        v_log_mostra_docto_acr_aviso_db at 87 format "Sim/N∆o" skip.
    &else
    if (line-counter(s_1) + 6) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "---------------------------------------------" at 33
        "Tipo EspÇcie  " at 79
        "---------------------------------------------" at 94 skip
        "  Normal: " at 77
        v_log_mostra_docto_acr_normal at 87 format "Sim/N∆o" skip
        "   Antecipaá∆o: " at 71
        v_log_mostra_docto_acr_antecip at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
        "  Previs∆o: " at 75
        v_log_mostra_docto_acr_prev at 87 format "Sim/N∆o" skip
        "   Aviso DÇbito: " at 70
        v_log_mostra_docto_acr_aviso_db at 87 format "Sim/N∆o" skip
        "  Cheque: " at 77
        v_log_mostra_docto_acr_cheq at 87 format "Sim/N∆o" skip.
    &endif
    if  v_log_control_terc_acr = yes then do:
        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "  Dupl. Terceiros: " at 68
            v_log_tip_espec_docto_terc at 87 format "Sim/N∆o" skip
            "    Cheques Terceiros: " at 64
            v_log_tip_espec_docto_cheq_terc at 87 format "Sim/N∆o" skip.
    end.
    if  v_log_modul_vendor = yes then do:
        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "  Vendor: " at 77
            v_log_mostra_docto_vendor at 87 format "Sim/N∆o" skip
            "    Vendor Repactuado: " at 64
            v_log_mostra_docto_vendor_repac at 87 format "Sim/N∆o" skip.
    end.
    &if defined(BF_FIN_CONTROL_CHEQUES) &then
        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "    Cheques Recebidos: " at 64
            v_log_mostra_acr_cheq_recbdo at 87 format "Sim/N∆o" skip
            "    Cheques Devolvidos: " at 63
            v_log_mostra_acr_cheq_devolv at 87 format "Sim/N∆o" skip.
    &endif

    if v_log_funcao_proces_export or v_log_vers_50_6 then do:
            run pi_print_editor ('s_1', v_des_estab_select, '     030', '', '     ', '', '     ').
            put stream s_1 unformatted 
            skip (1)
              '---------------------------------------------' at 36
              'Faixa' at 83
              '---------------------------------------------' at 90
              skip (1)
              '   Estab Selec: ' at 61
            entry(1, return-value, chr(255)) at 77 format 'x(30)'.
            run pi_print_editor ('s_1', v_des_estab_select, 'at077030', '', '', '', '').
            put stream s_1 unformatted 
              '   Unid Neg¢cio: ' at 60
              v_cod_unid_negoc_ini at 77 format 'x(3)'
              'atÇ: ' at 98
              v_cod_unid_negoc_fim at 103 format 'x(3)' skip
              '  EspÇcie: ' at 66
              v_cod_espec_docto_ini at 77 format 'x(3)'
              'atÇ: ' at 98
              v_cod_espec_docto_fim at 103 format 'x(3)' skip
              '  Cliente: ' at 66
              v_cdn_cliente_ini to 87 format '>>>,>>>,>>9'
              'atÇ: ' at 98
              v_cdn_cliente_fim to 113 format '>>>,>>>,>>9' skip
              'Grupo Cliente: ' at 62
              v_cod_grp_clien_ini at 80 format 'x(4)'
              'atÇ: ' at 98
              v_cod_grp_clien_fim at 103 format 'x(4)' skip
              ' Portador: ' at 66
              v_cod_portador_ini at 77 format 'x(5)'
              'atÇ: ' at 98
              v_cod_portador_fim at 103 format 'x(5)' skip
              '  Carteira: ' at 65
              v_cod_cart_bcia_ini at 77 format 'x(3)'
              'atÇ: ' at 98
              v_cod_cart_bcia_fim at 103 format 'x(3)' skip
              '   Representante: ' at 59
              v_cdn_repres_ini to 83 format '>>>,>>9'
              'atÇ: ' at 98
              v_cdn_repres_fim to 109 format '>>>,>>9' skip
              ' Vencimento: ' at 64
              v_dat_vencto_tit_acr_ini at 77 format '99/99/9999'
              'atÇ: ' at 98
              v_dat_vencto_tit_acr_fim at 103 format '99/99/9999' skip
              'Cliente Matriz: ' at 61
              v_cdn_clien_matriz_ini to 90 format '>>>,>>>,>>9'
              'atÇ: ' at 98
              v_cdn_clien_matriz_fim to 113 format '>>>,>>>,>>9' skip
              ' Cond Cobr: ' at 65
              v_cod_cond_cobr_ini at 77 format 'x(8)'
              'atÇ: ' at 98
              v_cod_cond_cobr_fim at 103 format 'x(8)' skip
              '  Moeda: ' at 68
              v_cod_indic_econ_ini at 77 format 'x(8)'
              'atÇ: ' at 98
              v_cod_indic_econ_fim at 103 format 'x(8)' skip
              '    Processo Exportaá∆o: ' at 52
              v_cod_proces_export_ini at 77 format 'x(12)'
              'atÇ: ' at 98
              v_cod_proces_export_fim at 103 format 'x(12)' skip.
              if v_log_funcao_melhoria_tit_aber then do:
                  put stream s_1 unformatted
                     '  Data Emiss∆o: ' at 61
                      v_dat_emis_docto_ini at 77 format '99/99/9999'
                      'atÇ: ' at 98
                      v_dat_emis_docto_fim at 103 format '99/99/9999' skip
                      '   Plano Conta: ' at 61
                      v_cod_plano_cta_ctbl_inic at 77 format 'x(8)'
                      'atÇ: ' at 98
                      v_cod_plano_cta_ctbl_final at 103 format 'x(8)' skip
                      '   Conta Inicial: ' at 59.
                  put stream s_1 unformatted 
                      v_cod_cta_ctbl_ini at 77 format 'x(20)'
                      'atÇ: ' at 98
                      v_cod_cta_ctbl_final at 103 format 'x(20)' skip.
              end.
    end.
    else do:
            run pi_print_editor ('s_1', v_des_estab_select, '     030', '', '     ', '', '     ').
            put stream s_1 unformatted
            skip (1) 
                '---------------------------------------------' at 36
                'Faixa' at 83
                '---------------------------------------------' at 90
                skip (1)
                '   Estab Selec: ' at 61
                entry(1, return-value, chr(255)) at 77 format 'x(30)'.
                run pi_print_editor ('s_1', v_des_estab_select, 'at077030', '', '', '', '').
                put stream s_1 unformatted
                '   Unid Neg¢cio: ' at 60
                v_cod_unid_negoc_ini at 77 format 'x(3)'
                'atÇ: ' at 98
                v_cod_unid_negoc_fim at 103 format 'x(3)' skip
                '  EspÇcie: ' at 66
                v_cod_espec_docto_ini at 77 format 'x(3)'
                'atÇ: ' at 98
                v_cod_espec_docto_fim at 103 format 'x(3)' skip
                '  Cliente: ' at 66
                v_cdn_cliente_ini to 87 format '>>>,>>>,>>9'
                'atÇ: ' at 98
                v_cdn_cliente_fim to 113 format '>>>,>>>,>>9' skip
                'Grupo Cliente: ' at 62
                v_cod_grp_clien_ini at 80 format 'x(4)'
                'atÇ: ' at 98
                v_cod_grp_clien_fim at 103 format 'x(4)' skip
                ' Portador: ' at 66
                v_cod_portador_ini at 77 format 'x(5)'
                'atÇ: ' at 98
                v_cod_portador_fim at 103 format 'x(5)' skip
                '  Carteira: ' at 65
                v_cod_cart_bcia_ini at 77 format 'x(3)'
                'atÇ: ' at 98
                v_cod_cart_bcia_fim at 103 format 'x(3)' skip
                '   Representante: ' at 59
                v_cdn_repres_ini to 83 format '>>>,>>9'
                'atÇ: ' at 98
                v_cdn_repres_fim to 109 format '>>>,>>9' skip
                ' Vencimento: ' at 64
                v_dat_vencto_tit_acr_ini at 77 format '99/99/9999'
                'atÇ: ' at 98
                v_dat_vencto_tit_acr_fim at 103 format '99/99/9999' skip
                'Cliente Matriz: ' at 61
                v_cdn_clien_matriz_ini to 90 format '>>>,>>>,>>9'
                'atÇ: ' at 98
                v_cdn_clien_matriz_fim to 113 format '>>>,>>>,>>9' skip
                ' Cond Cobr: ' at 65
                v_cod_cond_cobr_ini at 77 format 'x(8)'
                'atÇ: ' at 98
                v_cod_cond_cobr_fim at 103 format 'x(8)' skip
                '  Moeda: ' at 68
                v_cod_indic_econ_ini at 77 format 'x(8)'
                'atÇ: ' at 98
                v_cod_indic_econ_fim at 103 format 'x(8)' skip (1).
            if v_log_funcao_melhoria_tit_aber then do:
                put stream s_1 unformatted
                   '  Data Emiss∆o: ' at 61
                    v_dat_emis_docto_ini at 77 format '99/99/9999'
                    'atÇ: ' at 98
                    v_dat_emis_docto_fim at 103 format '99/99/9999' skip
                    '   Plano Conta: ' at 61
                    v_cod_plano_cta_ctbl_inic at 77 format 'x(8)'
                    'atÇ: ' at 98
                    v_cod_plano_cta_ctbl_final at 103 format 'x(8)' skip
                    '   Conta Inicial: ' at 59.
                put stream s_1 unformatted 
                    v_cod_cta_ctbl_ini at 77 format 'x(20)'
                    'atÇ: ' at 98
                    v_cod_cta_ctbl_final at 103 format 'x(20)' skip.
            end.
    end.

    if v_log_funcao_proces_export or v_log_vers_50_6 then do:
        if v_log_funcao_melhoria_tit_aber then do:
            if (line-counter(s_1) + 28) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "---------------------------------------------" at 32
                "Classificaá∆o" at 79
                "---------------------------------------------" at 94
                skip (1)
                "   Classif Estab: " at 69
                v_log_classif_estab at 87 format "Sim/N∆o" skip
                "   Classif Unid Negoc: " at 64.
    put stream s_1 unformatted 
                v_log_classif_un at 87 format "Sim/N∆o" skip
                "   Classificaá∆o: " at 69
                v_ind_classif_tit_acr_em_aber at 87 format "X(50)"
                skip (1)
                "---------------------------------------------" at 33
                "Totalizaá∆o" at 80
                "---------------------------------------------" at 93
                skip (1)
                "   Totaliza Estab: " at 68
                v_log_tot_estab at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "   Totaliza Repres: " at 67
                v_log_tot_repres at 87 format "Sim/N∆o" skip
                "    Totaliza Portad/Cart: " at 61
                v_log_tot_portad_cart at 87 format "Sim/N∆o" skip
                "   Totaliza Cliente: " at 66
                v_log_tot_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Grupo Clien: " at 61
                v_log_tot_grp_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Data Vencto: " at 61
                v_log_tot_vencto at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "   Totaliza Matriz: " at 67
                v_log_tot_matriz at 87 format "Sim/N∆o" skip
                "    Totaliza Cond. Cobr.: " at 61
                v_log_tot_cond_cobr at 87 format "Sim/N∆o" skip
                "    Totaliza Espec Docto: " at 61
                v_log_tot_espec_docto at 87 format "Sim/N∆o" skip
                "    Totaliza Proc. Expor: " at 61
                v_log_tot_num_proces_export at 87 format "Sim/N∆o" skip
                "    Totaliza Unid Negoc: " at 62
                v_log_tot_unid_negoc at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "    Totaliza Cta Ctabil: " at 62
                v_log_tot_cta at 87 format "Sim/N∆o"
                skip (1)
                "---------------------------------------------" at 33
                "Imprime" at 80
                "---------------------------------------------" at 93
                skip (1)
                "Somente Totais: " at 71
                v_log_nao_impr_tit at 87 format "Sim/N∆o" skip
                "    Emitir Movtos Cobr: " at 63.
    put stream s_1 unformatted 
                v_log_emit_movto_cobr at 87 format "Sim/N∆o" skip
                "    Gera Planilha: " at 68
                v_log_gerac_planilha at 87 format "Sim/N∆o" skip
                "   Arq Planilha: " at 70
                v_cod_arq_planilha at 87 format "x(40)" skip
                " Caracter Delimitador: " at 64
                v_cod_carac_lim at 87 format "x(1)" skip.
        end.
        else do:
            if (line-counter(s_1) + 28) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "---------------------------------------------" at 32
                "Classificaá∆o" at 79
                "---------------------------------------------" at 94
                skip (1)
                "   Classif Estab: " at 69
                v_log_classif_estab at 87 format "Sim/N∆o"
                skip (1).
    put stream s_1 unformatted 
                "   Classificaá∆o: " at 69
                v_ind_classif_tit_acr_em_aber at 87 format "X(50)"
                skip (1)
                "---------------------------------------------" at 33
                "Totalizaá∆o" at 80
                "---------------------------------------------" at 93
                skip (1)
                "   Totaliza Estab: " at 68
                v_log_tot_estab at 87 format "Sim/N∆o" skip
                "   Totaliza Repres: " at 67.
    put stream s_1 unformatted 
                v_log_tot_repres at 87 format "Sim/N∆o" skip
                "    Totaliza Portad/Cart: " at 61
                v_log_tot_portad_cart at 87 format "Sim/N∆o" skip
                "   Totaliza Cliente: " at 66
                v_log_tot_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Grupo Clien: " at 61
                v_log_tot_grp_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Data Vencto: " at 61
                v_log_tot_vencto at 87 format "Sim/N∆o" skip
                "   Totaliza Matriz: " at 67.
    put stream s_1 unformatted 
                v_log_tot_matriz at 87 format "Sim/N∆o" skip
                "    Totaliza Cond. Cobr.: " at 61
                v_log_tot_cond_cobr at 87 format "Sim/N∆o" skip
                "    Totaliza Espec Docto: " at 61
                v_log_tot_espec_docto at 87 format "Sim/N∆o" skip
                "    Totaliza Proc. Expor: " at 61
                v_log_tot_num_proces_export at 87 format "Sim/N∆o"
                skip (3)
                "---------------------------------------------" at 33
                "Imprime" at 80.
    put stream s_1 unformatted 
                "---------------------------------------------" at 93
                skip (1)
                "Somente Totais: " at 71
                v_log_nao_impr_tit at 87 format "Sim/N∆o" skip
                "    Emitir Movtos Cobr: " at 63
                v_log_emit_movto_cobr at 87 format "Sim/N∆o" skip
                "    Gera Planilha: " at 68
                v_log_gerac_planilha at 87 format "Sim/N∆o" skip
                "   Arq Planilha: " at 70
                v_cod_arq_planilha at 87 format "x(40)" skip.
    put stream s_1 unformatted 
                " Caracter Delimitador: " at 64
                v_cod_carac_lim at 87 format "x(1)" skip.
        end.
    end.
    else do:
        if v_log_funcao_melhoria_tit_aber then do:
            if (line-counter(s_1) + 28) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "---------------------------------------------" at 32
                "Classificaá∆o" at 79
                "---------------------------------------------" at 94
                skip (1)
                "   Classif Estab: " at 69
                v_log_classif_estab at 87 format "Sim/N∆o" skip
                "   Classif Unid Negoc: " at 64.
    put stream s_1 unformatted 
                v_log_classif_un at 87 format "Sim/N∆o" skip
                "   Classificaá∆o: " at 69
                v_ind_classif_tit_acr_em_aber at 87 format "X(50)"
                skip (1)
                "---------------------------------------------" at 33
                "Totalizaá∆o" at 80
                "---------------------------------------------" at 93
                skip (1)
                "   Totaliza Estab: " at 68
                v_log_tot_estab at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "   Totaliza Repres: " at 67
                v_log_tot_repres at 87 format "Sim/N∆o" skip
                "    Totaliza Portad/Cart: " at 61
                v_log_tot_portad_cart at 87 format "Sim/N∆o" skip
                "   Totaliza Cliente: " at 66
                v_log_tot_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Grupo Clien: " at 61
                v_log_tot_grp_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Data Vencto: " at 61
                v_log_tot_vencto at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "   Totaliza Matriz: " at 67
                v_log_tot_matriz at 87 format "Sim/N∆o" skip
                "    Totaliza Cond. Cobr.: " at 61
                v_log_tot_cond_cobr at 87 format "Sim/N∆o" skip
                "    Totaliza Espec Docto: " at 61
                v_log_tot_espec_docto at 87 format "Sim/N∆o"
                skip (1)
                "    Totaliza Unid Negoc: " at 62
                v_log_tot_unid_negoc at 87 format "Sim/N∆o" skip
                "    Totaliza Cta Ctabil: " at 62.
    put stream s_1 unformatted 
                v_log_tot_cta at 87 format "Sim/N∆o"
                skip (1)
                "---------------------------------------------" at 33
                "Imprime" at 80
                "---------------------------------------------" at 93
                skip (1)
                "Somente Totais: " at 71
                v_log_nao_impr_tit at 87 format "Sim/N∆o" skip
                "    Emitir Movtos Cobr: " at 63
                v_log_emit_movto_cobr at 87 format "Sim/N∆o" skip.
    put stream s_1 unformatted 
                "    Gera Planilha: " at 68
                v_log_gerac_planilha at 87 format "Sim/N∆o" skip
                "   Arq Planilha: " at 70
                v_cod_arq_planilha at 87 format "x(40)" skip
                " Caracter Delimitador: " at 64
                v_cod_carac_lim at 87 format "x(1)" skip.
        end.
        else do:
            if (line-counter(s_1) + 28) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "---------------------------------------------" at 32
                "Classificaá∆o" at 79
                "---------------------------------------------" at 94
                skip (1)
                "   Classif Estab: " at 69
                v_log_classif_estab at 87 format "Sim/N∆o"
                skip (1).
    put stream s_1 unformatted 
                "   Classificaá∆o: " at 69
                v_ind_classif_tit_acr_em_aber at 87 format "X(50)"
                skip (1)
                "---------------------------------------------" at 33
                "Totalizaá∆o" at 80
                "---------------------------------------------" at 93
                skip (1)
                "   Totaliza Estab: " at 68
                v_log_tot_estab at 87 format "Sim/N∆o" skip
                "   Totaliza Repres: " at 67.
    put stream s_1 unformatted 
                v_log_tot_repres at 87 format "Sim/N∆o" skip
                "    Totaliza Portad/Cart: " at 61
                v_log_tot_portad_cart at 87 format "Sim/N∆o" skip
                "   Totaliza Cliente: " at 66
                v_log_tot_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Grupo Clien: " at 61
                v_log_tot_grp_clien at 87 format "Sim/N∆o" skip
                "    Totaliza Data Vencto: " at 61
                v_log_tot_vencto at 87 format "Sim/N∆o" skip
                "   Totaliza Matriz: " at 67.
    put stream s_1 unformatted 
                v_log_tot_matriz at 87 format "Sim/N∆o" skip
                "    Totaliza Cond. Cobr.: " at 61
                v_log_tot_cond_cobr at 87 format "Sim/N∆o" skip
                "    Totaliza Espec Docto: " at 61
                v_log_tot_espec_docto at 87 format "Sim/N∆o"
                skip (4)
                "---------------------------------------------" at 33
                "Imprime" at 80
                "---------------------------------------------" at 93
                skip (1).
    put stream s_1 unformatted 
                "Somente Totais: " at 71
                v_log_nao_impr_tit at 87 format "Sim/N∆o" skip
                "    Emitir Movtos Cobr: " at 63
                v_log_emit_movto_cobr at 87 format "Sim/N∆o" skip
                "    Gera Planilha: " at 68
                v_log_gerac_planilha at 87 format "Sim/N∆o" skip
                "   Arq Planilha: " at 70
                v_cod_arq_planilha at 87 format "x(40)" skip
                " Caracter Delimitador: " at 64
                v_cod_carac_lim at 87 format "x(1)" skip.
        end.
    end.    
    if (line-counter(s_1) + 11) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "---------------------------------------------" at 33
        "Prazos Resumo  " at 79
        "---------------------------------------------" at 95
        skip (1)
        "------------------------------" at 26
        "Doctos Vencidos   " at 57
        "--------------------" at 76.
    put stream s_1 unformatted 
        "Doctos a Vencer   " at 97
        "------------------------------" at 116
        skip (1)
        "Vencidos atÇ: " at 58
        v_num_dias_vencid_1 to 75 format ">>>9"
        "A Vencer atÇ: " at 98
        v_num_dias_avencer_1 to 115 format ">>>9" skip
        "de: " at 57
        v_num_dias_vencid_2 to 64 format ">>>9"
        "atÇ: " at 67.
    put stream s_1 unformatted 
        v_num_dias_vencid_3 to 75 format ">>>9"
        "de: " at 97
        v_num_dias_avencer_2 to 104 format ">>>9"
        "atÇ: " at 107
        v_num_dias_avencer_3 to 115 format ">>>9" skip
        "de: " at 57
        v_num_dias_vencid_4 to 64 format ">>>9"
        "atÇ: " at 67
        v_num_dias_vencid_5 to 75 format ">>>9"
        "de: " at 97.
    put stream s_1 unformatted 
        v_num_dias_avencer_4 to 104 format ">>>9"
        "atÇ: " at 107
        v_num_dias_avencer_5 to 115 format ">>>9" skip
        "de: " at 57
        v_num_dias_vencid_6 to 64 format ">>>9"
        "atÇ: " at 67
        v_num_dias_vencid_7 to 75 format ">>>9"
        "de: " at 97
        v_num_dias_avencer_6 to 104 format ">>>9"
        "atÇ: " at 107.
    put stream s_1 unformatted 
        v_num_dias_avencer_7 to 115 format ">>>9" skip
        "Mais de: " at 52
        v_num_dias_vencid_8 to 64 format ">>>9"
        "atÇ: " at 67
        v_num_dias_vencid_9 to 75 format ">>>9"
        "Mais de: " at 92
        v_num_dias_avencer_8 to 104 format ">>>9"
        "atÇ: " at 107
        v_num_dias_avencer_9 to 115 format ">>>9" skip
        "de: " at 57.
    put stream s_1 unformatted 
        v_num_dias_vencid_10 to 64 format ">>>9"
        "atÇ: " at 67
        v_num_dias_vencid_11 to 75 format ">>>9"
        "de: " at 97
        v_num_dias_avencer_10 to 104 format ">>>9"
        "atÇ: " at 107
        v_num_dias_avencer_11 to 115 format ">>>9" skip
        "Mais de: " at 63
        v_num_dias_vencid_12 to 75 format ">>>9"
        "  Mais de: " at 101.
    put stream s_1 unformatted 
        v_num_dias_avencer_12 to 115 format ">>>9" skip.
END PROCEDURE. /* pi_ix_p30_rpt_tit_acr_em_aberto */
/*****************************************************************************
** Procedure Interna.....: pi_tratar_resumo_contas_acr
** Descricao.............: pi_tratar_resumo_contas_acr
** Criado por............: fut42625
** Criado em.............: 27/07/2009 16:52:43
** Alterado por..........: fut43120
** Alterado em...........: 03/06/2013 10:48:15
*****************************************************************************/
PROCEDURE pi_tratar_resumo_contas_acr:

    /************************* Variable Definition Begin ************************/

    def var v_cod_cta_ctbl_final
        as character
        format "x(20)":U
        initial "ZZZZZZZZZZZZZZZZZZZZ"
        label "atÇ"
        column-label "atÇ"
        no-undo.
    def var v_cod_cta_ctbl_inicial
        as character
        format "x(20)":U
        label "Conta Cont†bil"
        column-label "Conta Cont†bil"
        no-undo.
    def var v_cod_seq
        as character
        format "x(200)":U
        no-undo.
    def var v_dat_calc
        as date
        format "99/99/9999":U
        label "Data Base de C†lculo"
        column-label "Data Base de C†lculo"
        no-undo.
    def var v_des_aux_lista
        as character
        format "x(40)":U
        no-undo.
    def var v_des_dat_exerc
        as character
        format "x(100)":U
        no-undo.
    def var v_des_exerc
        as character
        format "x(80)":U
        no-undo.
    def var v_des_seq_exec
        as character
        format "x(40)":U
        no-undo.
    def var v_log_1
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        no-undo.
    def var v_num_final
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_inicial
        as integer
        format ">>>>,>>9":U
        label "Inicial"
        no-undo.
    def var v_num_seq
        as integer
        format ">>>,>>9":U
        label "SeqÅància"
        column-label "Seq"
        no-undo.
    def var v_val_sdo_estab
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_val_sdo_un
        as decimal
        format ">>>>>>9.99":U
        decimals 2
        label "Saldo UN"
        column-label "Saldo UN"
        no-undo.
    def var v_cod_estab_fim                  as character       no-undo. /*local*/
    def var v_cod_estab_inic                 as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign  v_num_inicial    = month(v_dat_tit_acr_aber)
            v_num_final      = month(v_dat_tit_acr_aber)
            v_num_seq        = 1
            v_dat_calc       = ?
            v_des_dat_exerc  = ''
            v_des_exerc      = ''
            v_des_aux_lista  = ''
            v_des_seq_exec   = ''
            v_cod_estab_inic = ''
            v_cod_estab_fim  = ''.

    find first utiliz_cenar_ctbl no-lock
         where utiliz_cenar_ctbl.cod_empresa     = v_cod_empres_usuar
           and utiliz_cenar_ctbl.dat_inic_valid <= v_dat_tit_acr_aber
           and utiliz_cenar_ctbl.dat_fim_valid  >= v_dat_tit_acr_aber
           and utiliz_cenar_ctbl.log_cenar_fisc  = yes no-error.
    if  avail utiliz_cenar_ctbl
    then do:
        do while(v_num_inicial <= v_num_final):
            assign v_dat_calc       = fn_retorna_ultimo_dia_mes_ano(v_num_inicial, year(v_dat_tit_acr_aber))
                   v_des_dat_exerc  = (v_des_dat_exerc + string(v_dat_calc))
                   v_des_exerc      = (v_des_exerc     + string(year(v_dat_tit_acr_aber)))
                   v_des_aux_lista  = (v_des_aux_lista + string(v_num_inicial))
                   v_des_seq_exec   = (v_des_seq_exec  + string(v_num_seq)).

            if (v_num_inicial < v_num_final) then do:
            assign v_dat_calc       = fn_retorna_ultimo_dia_mes_ano(v_num_inicial, year(v_dat_tit_acr_aber))
                   v_des_dat_exerc  = (v_des_dat_exerc + chr(10))
                   v_des_exerc      = (v_des_exerc     + chr(10))
                   v_des_aux_lista  = (v_des_aux_lista + chr(10))
                   v_des_seq_exec   = (v_des_seq_exec  + chr(10)).
            end.
            assign v_num_inicial    = (v_num_inicial   + 1)
                   v_num_seq        = (v_num_seq       + 1).
        end.

        find first tt_resumo_conta no-lock no-error.
        if avail tt_resumo_conta then
                assign v_cod_cta_ctbl_inicial = tt_resumo_conta.tta_cod_cta_ctbl.
        find last 
            tt_resumo_conta no-lock no-error.
        if avail tt_resumo_conta then
                assign v_cod_cta_ctbl_final = tt_resumo_conta.tta_cod_cta_ctbl.

        do v_num_cont_aux = 1 to num-entries(v_des_estab_select):

           if  v_cod_estab_inic = "" /*l_*/  
           or  v_cod_estab_fim  = "" /*l_*/   then 
               assign v_cod_estab_inic = entry(v_num_cont_aux, v_des_estab_select)
                      v_cod_estab_fim  = entry(v_num_cont_aux, v_des_estab_select).
           else do:           
               if entry(v_num_cont_aux, v_des_estab_select) < v_cod_estab_inic then
                  assign v_cod_estab_inic = entry(v_num_cont_aux, v_des_estab_select).

               if entry(v_num_cont_aux, v_des_estab_select) > v_cod_estab_fim then
                  assign  v_cod_estab_fim  = entry(v_num_cont_aux, v_des_estab_select).

           end /* else */.
        end.            

        if avail tt_resumo_conta then do:
            create tt_input_sdo.
            assign tt_input_sdo.ttv_cod_seq                  = v_des_seq_exec
                   tt_input_sdo.tta_cod_unid_organ_ini       = v_cod_empres_usuar
                   tt_input_sdo.tta_cod_unid_organ_fim       = v_cod_empres_usuar
                   tt_input_sdo.ttv_cod_unid_organ_orig_ini  = ""
                   tt_input_sdo.ttv_cod_unid_organ_orig_fim  = "ZZZ" /*l_zzz*/ 
                   tt_input_sdo.tta_cod_cenar_ctbl           = utiliz_cenar_ctbl.cod_cenar_ctbl
                   tt_input_sdo.tta_cod_finalid_econ         = v_cod_finalid_econ_apres
                   tt_input_sdo.tta_cod_plano_cta_ctbl       = tt_resumo_conta.tta_cod_plano_cta_ctbl
                   tt_input_sdo.tta_cod_plano_ccusto         = ""
                   tt_input_sdo.tta_cod_cta_ctbl_inic        = v_cod_cta_ctbl_inicial
                   tt_input_sdo.tta_cod_cta_ctbl_fim         = v_cod_cta_ctbl_final
                   tt_input_sdo.tta_cod_proj_financ_inic     = ""
                   tt_input_sdo.tta_cod_proj_financ_fim      = "ZZZZZZZZZZZZZZZZZZZZ" /*l_zzzzzzzzzzzzzzzzzzzz*/ 
                   tt_input_sdo.tta_cod_estab_inic           = v_cod_estab_inic
                   tt_input_sdo.tta_cod_estab_fim            = v_cod_estab_fim
                   tt_input_sdo.tta_cod_unid_negoc_inic      = ""
                   tt_input_sdo.tta_cod_unid_negoc_fim       = "ZZZ" /*l_zzz*/ 
                   tt_input_sdo.tta_cod_ccusto_inic          = ""
                   tt_input_sdo.tta_cod_ccusto_fim           = ""
                   tt_input_sdo.ttv_cod_elimina_intercomp    = "Consolidado" /*l_consolidado*/ 
                   tt_input_sdo.ttv_ind_espec_cta            = "Anal°tica" /*l_analitica*/ 
                   tt_input_sdo.ttv_log_espec_sdo_ccusto     = no
                   tt_input_sdo.ttv_log_restric_estab        = no
                   tt_input_sdo.ttv_ind_espec_sdo_tot        = "Cont†bil" /*l_contabil*/ 
                   tt_input_sdo.ttv_cod_leitura              = 'for each'
                   tt_input_sdo.ttv_cod_condicao             = 'Igual'
                   tt_input_sdo.ttv_cod_dat_sdo_ctbl_inic    = v_des_dat_exerc
                   tt_input_sdo.ttv_cod_dat_sdo_ctbl_fim     = v_des_dat_exerc
                   tt_input_sdo.ttv_cod_exerc_ctbl           = v_des_exerc
                   tt_input_sdo.ttv_cod_period_ctbl          = v_des_aux_lista
                   tt_input_sdo.ttv_cod_cta_ctbl_excec       = ""
                   tt_input_sdo.ttv_cod_ccusto_excec         = ""
                   tt_input_sdo.ttv_cod_proj_financ_excec    = ""
                   tt_input_sdo.ttv_cod_cta_ctbl_pfixa       = ""
                   tt_input_sdo.ttv_cod_ccusto_pfixa         = "".
        end.
    end /* if */.
    run prgfin/fgl/fgl905zc_Convenio.p  (Input 1,
                                         input table tt_input_sdo,
                                         Input table tt_input_leitura_sdo_demonst,
                                         output v_des_lista_estab,
                                         output table tt_log_erros) /*prg_api_retornar_sdo_ctbl_demonst*/.
    page stream s_1.                                   
    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "----------------" at 1 skip
        "RESUMO POR CONTA" at 1 skip
        "----------------" at 1 skip.
    if can-find(first tt_log_erros)
    then do:
        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "Seq" to 7
            "N£m" to 16
            "Inconsist" at 18 skip
            "-------" to 7
            "--------" to 16
            "--------------------------------------------------" at 18 skip.
        for each tt_log_erros:
            run pi_print_editor ("s_1", tt_log_erros.ttv_des_ajuda, "     050", "", "     ", "", "     ").
            put stream s_1 unformatted 
                tt_log_erros.ttv_num_seq to 7 format ">>>,>>9"
                tt_log_erros.ttv_num_cod_erro to 16 format ">>>>,>>9"
                tt_log_erros.ttv_des_erro at 18 format "x(50)"
                entry(1, return-value, chr(255)) at 69 format "x(50)" skip.
            run pi_print_editor ("s_1", tt_log_erros.ttv_des_ajuda, "at069050", "", "", "", "").
        end.
    end.
    assign v_val_sdo_estab = 0
           v_val_sdo_un = 0.
    for each tt_resumo_conta:
        assign v_log_1 = no.
        for each tt_retorna_sdo_ctbl_demonst
           where tt_retorna_sdo_ctbl_demonst.tta_cod_empresa         = tt_resumo_conta.tta_cod_empresa
           and   tt_retorna_sdo_ctbl_demonst.tta_cod_finalid_econ    = v_cod_finalid_econ_apres
           and   tt_retorna_sdo_ctbl_demonst.tta_cod_plano_cta_ctbl  = tt_resumo_conta.tta_cod_plano_cta_ctbl
           and   tt_retorna_sdo_ctbl_demonst.tta_cod_cta_ctbl        = tt_resumo_conta.tta_cod_cta_ctbl
           and   tt_retorna_sdo_ctbl_demonst.tta_cod_cenar_ctbl      = utiliz_cenar_ctbl.cod_cenar_ctbl
           and   tt_retorna_sdo_ctbl_demonst.tta_dat_sdo_ctbl        = v_dat_calc
        break by tt_retorna_sdo_ctbl_demonst.tta_cod_estab
              by tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc:
            assign v_log_1 = no.
            if lookup(tt_retorna_sdo_ctbl_demonst.tta_cod_estab, v_des_estab_select) > 0 then
                assign v_log_1 = yes.

            if v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/  and v_log_1 = yes then do:
                    if (tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc < v_cod_unid_negoc_ini or
                        tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc > v_cod_unid_negoc_fim) then 
                           assign v_log_1 = no.
            end.     
            if  v_log_1 = yes then do:

                if(v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ )
                then do:
                    if  first-of(tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc)
                    then do:
                        assign v_val_sdo_un = 0.
                    end.
                    assign v_val_sdo_estab = v_val_sdo_estab + tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim
                           v_val_sdo_un = v_val_sdo_un + tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim.                    
                    if  last-of(tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc)
                    then do:
                        /* se houver registro ja criado para a unidade de negΩcio espec≠fica, atualiza somente saldo*/                
                        find first tt_resumo_conta_estab_acr 
                             where tt_resumo_conta_estab_acr.tta_cod_estab = tt_retorna_sdo_ctbl_demonst.tta_cod_estab
                               and tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                               and tt_resumo_conta_estab_acr.tta_cod_cta_ctbl = tt_resumo_conta.tta_cod_cta_ctbl
                               and tt_resumo_conta_estab_acr.tta_cod_unid_negoc = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc
                        no-lock no-error.
                        if avail tt_resumo_conta_estab_acr 
                        then do:
                            assign tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl = v_val_sdo_un.

                            /* elimina resumo de saldo do contas a pagar e contabilidade estiver 
                               zerado, porque neste caso nao ha valores e nem diferenca */
                            if tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr = 0
                            and tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl  = 0 then
                                delete tt_resumo_conta_estab_acr.                        

                        end.
                        /* se nío houver registro para a unidade de negΩcio, cria e atualiza o saldo*/
                        else do:

                            /* se caiu no else e porque nao achou saldo no contas a pagar
                               entao somente ira criar resumo se existir saldo na contabilidade */
                            if v_val_sdo_un <> 0 then do:
                                create tt_resumo_conta_estab_acr.
                                assign tt_resumo_conta_estab_acr.tta_cod_estab = tt_retorna_sdo_ctbl_demonst.tta_cod_estab
                                       tt_resumo_conta_estab_acr.tta_cod_unid_negoc = tt_retorna_sdo_ctbl_demonst.tta_cod_unid_negoc
                                       tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                                       tt_resumo_conta_estab_acr.tta_cod_cta_ctbl = tt_resumo_conta.tta_cod_cta_ctbl
                                       tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl = v_val_sdo_un.
                            end.
                        end.
                    end.
                end.
                else
                do:
                    if  first-of(tt_retorna_sdo_ctbl_demonst.tta_cod_estab)
                    then do:
                        assign v_val_sdo_estab = 0.
                    end.
                    assign v_val_sdo_estab = v_val_sdo_estab + tt_retorna_sdo_ctbl_demonst.tta_val_sdo_ctbl_fim.
                    if  last-of(tt_retorna_sdo_ctbl_demonst.tta_cod_estab)
                    then do:
                        find first tt_resumo_conta_estab_acr 
                             where tt_resumo_conta_estab_acr.tta_cod_estab = tt_retorna_sdo_ctbl_demonst.tta_cod_estab
                               and tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                               and tt_resumo_conta_estab_acr.tta_cod_cta_ctbl = tt_resumo_conta.tta_cod_cta_ctbl
                        no-lock no-error.
                        if avail tt_resumo_conta_estab_acr 
                        then do:
                            assign tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl = v_val_sdo_estab.

                            /* elimina resumo de saldo do contas a pagar e contabilidade estiver 
                               zerado, porque neste caso nao ha valores e nem diferenca */
                            if tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr = 0
                            and tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl  = 0 then
                                delete tt_resumo_conta_estab_acr.

                        end.
                        else do:

                            /* se caiu no else e porque nao achou saldo no contas a pagar
                               entao somente ira criar resumo se existir saldo na contabilidade */
                            if v_val_sdo_estab <> 0 then do:
                                create tt_resumo_conta_estab_acr.
                                assign tt_resumo_conta_estab_acr.tta_cod_estab = tt_retorna_sdo_ctbl_demonst.tta_cod_estab
                                       tt_resumo_conta_estab_acr.tta_cod_unid_negoc = ''
                                       tt_resumo_conta_estab_acr.tta_cod_plano_cta_ctbl = tt_resumo_conta.tta_cod_plano_cta_ctbl
                                       tt_resumo_conta_estab_acr.tta_cod_cta_ctbl = tt_resumo_conta.tta_cod_cta_ctbl
                                       tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl = v_val_sdo_estab.
                            end.
                        end.
                    end.
                end.
            end.           
        end.          
    end.
    if can-find(first tt_resumo_conta_estab_acr)
    then do:
       if v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
       then do:
           if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
               page stream s_1.
           put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               "Est" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               "Est" at 1
    &ENDIF
               "Un N" at 7
               "Conta" at 12
               "Saldo" to 50
               "Sdo Ctbl" to 69
               "Diferenáa" to 88 skip
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               "---" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               "-----" at 1
    &ENDIF
               "----" at 7
               "--------------------" at 12
               "------------------" to 50
               "------------------" to 69
               "------------------" to 88 skip.
       end.
       else
       do:
           if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
               page stream s_1.
           put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               "Est" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               "Est" at 1
    &ENDIF
               "Conta" at 7
               "Saldo" to 45
               "Sdo Ctbl" to 64
               "Diferenáa" to 83 skip
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               "---" at 1
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               "-----" at 1
    &ENDIF
               "--------------------" at 7
               "------------------" to 45
               "------------------" to 64
               "------------------" to 83 skip.
       end.
    end.
    for each tt_resumo_conta_estab_acr:
       assign tt_resumo_conta_estab_acr.ttv_val_diferenca = ABS(tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr) - ABS(tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl)
              tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl = ABS(tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl).
       if v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
       then do:
           if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
               page stream s_1.
           put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               tt_resumo_conta_estab_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               tt_resumo_conta_estab_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
               tt_resumo_conta_estab_acr.tta_cod_unid_negoc at 7 format "x(3)".
    put stream s_1 unformatted 
               tt_resumo_conta_estab_acr.tta_cod_cta_ctbl at 12 format "x(20)"
               tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr to 50 format "->>,>>>,>>>,>>9.99"
               tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl to 69 format "->>,>>>,>>>,>>9.99"
               tt_resumo_conta_estab_acr.ttv_val_diferenca to 88 format "->>,>>>,>>>,>>9.99" skip.
       end.       
       else
       do:
           if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
               page stream s_1.
           put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
               tt_resumo_conta_estab_acr.tta_cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
               tt_resumo_conta_estab_acr.tta_cod_estab at 1 format "x(5)"
    &ENDIF
               tt_resumo_conta_estab_acr.tta_cod_cta_ctbl at 7 format "x(20)".
    put stream s_1 unformatted 
               tt_resumo_conta_estab_acr.tta_val_sdo_tit_acr to 45 format "->>,>>>,>>>,>>9.99"
               tt_resumo_conta_estab_acr.ttv_val_sdo_ctbl to 64 format "->>,>>>,>>>,>>9.99"
               tt_resumo_conta_estab_acr.ttv_val_diferenca to 83 format "->>,>>>,>>>,>>9.99" skip.
       end.       
    end.

    if can-find(first tt_log_erros_aux)
    then do:

        put stream s_1 unformatted 
        '----------------' at 1 skip
        '   OBSERVAÄ«O   ' at 1 skip
        '----------------' at 1 skip.

        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            'Seq' to 7
            'N£m' to 16
            'Inconsist' at 18 skip
            '-------' to 7
            '--------' to 16
            '----------------------------------------------------' at 18 skip.

        for each tt_log_erros_aux:
            run pi_print_editor ('s_2', tt_log_erros_aux.ttv_des_ajuda, '     050', '', '     ', '', '     ').
            put stream s_1 unformatted 
                tt_log_erros_aux.ttv_num_seq to 7 format '>>>,>>9'
                tt_log_erros_aux.ttv_num_cod_erro to 16 format '>>>>,>>9'
                tt_log_erros_aux.ttv_des_erro at 18 format 'x(53)'
            entry(1, return-value, chr(255)) at 72 format 'x(73)' skip.
            run pi_print_editor ('s_1', tt_log_erros_aux.ttv_des_ajuda, 'at072053', '', '', '', '').
        end.
    end.

END PROCEDURE. /* pi_tratar_resumo_contas_acr */
/*****************************************************************************
** Procedure Interna.....: pi_vld_estab_select
** Descricao.............: pi_vld_estab_select
** Criado por............: fut42625_3
** Criado em.............: 14/02/2011 14:06:27
** Alterado por..........: fut42625_3
** Alterado em...........: 14/02/2011 15:41:29
*****************************************************************************/
PROCEDURE pi_vld_estab_select:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_estab_select_aux
        as character
        format "x(2000)":U
        view-as editor max-chars 2000 no-word-wrap
        size 30 by 1
        bgcolor 15 font 2
        label "Estab"
        no-undo.
    def var v_num_cont_2
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    /* ===  Verificar se o usu†rio possui permiss∆o nos estabelecintos selecionados  === */
    assign v_des_estab_select_aux = v_des_estab_select.

    run pi_vld_permissao_usuar_estab_empres (Input p_cod_modul).
    assign v_des_estab_select = "" /*l_null*/ .

    do v_num_cont_2 = 1 to num-entries(v_des_estab_select_aux):
        find first estabelecimento no-lock
           where estabelecimento.cod_estab = entry(v_num_cont_2, v_des_estab_select_aux) no-error.
        if avail estabelecimento then do:
            if can-find(first tt_estabelecimento_empresa 
                where tt_estabelecimento_empresa.tta_cod_estab = estabelecimento.cod_estab) then do:
                if v_des_estab_select = "" then
                    assign v_des_estab_select = estabelecimento.cod_estab.
                else
                    assign v_des_estab_select = v_des_estab_select + "," + estabelecimento.cod_estab.
            end.
        end.
    end.
END PROCEDURE. /* pi_vld_estab_select */
/*****************************************************************************
** Procedure Interna.....: pi_valida_erro_cta_grp_clien
** Descricao.............: pi_valida_erro_cta_grp_clien
** Criado por............: fut43120
** Criado em.............: 03/06/2013 09:43:07
** Alterado por..........: fut43120
** Alterado em...........: 03/06/2013 10:03:23
*****************************************************************************/
PROCEDURE pi_valida_erro_cta_grp_clien:

    /************************** Buffer Definition Begin *************************/

    def buffer btt_log_erros_aux
        for tt_log_erros_aux.


    /*************************** Buffer Definition End **************************/

    find last btt_log_erros_aux no-lock no-error.
    if avail btt_log_erros_aux then do:
        assign v_num_seq = btt_log_erros_aux.ttv_num_seq + 1.
    end.
    else do:
        assign v_num_seq = 1.
    end.

    create tt_log_erros_aux.
    assign tt_log_erros_aux.ttv_num_seq        = v_num_seq
           tt_log_erros_aux.ttv_num_cod_erro   = 21341
           tt_log_erros_aux.ttv_des_erro       = 'Conta de Saldo n∆o encontrada para grupo de Cliente!'
           tt_log_erros_aux.ttv_des_ajuda      = 'Verifique na manutená∆o de Contas de Grupo de Cliente se existe uma Conta de Saldo, cadastrada para o Grupo de Clientes '  + tt_titulos_em_aberto_acr.tta_cod_grp_clien +  ' v†lida em: ' + string(v_dat_tit_acr_aber) + ' onde Empresa = ' + tt_titulos_em_aberto_acr.tta_cod_empresa + ' EspÇcie de documento = ' + tt_titulos_em_aberto_acr.tta_cod_espec_docto + ' Tipo de Documento = ' + string(tt_titulos_em_aberto_acr.tta_ind_tip_espec_docto) + ' Finalidade Econ¢mica = ' + v_cod_finalid_econ_aux + '.' +
           ' Valores n∆o listados para o Titulo: ' + tt_titulos_em_aberto_acr.tta_cod_tit_acr + ' EspÇcie: ' + tt_titulos_em_aberto_acr.tta_cod_espec_docto + ' Serie: ' + tt_titulos_em_aberto_acr.tta_cod_ser_docto + ' Parcela: ' + tt_titulos_em_aberto_acr.tta_cod_parcela + '.'. 



END PROCEDURE. /* pi_valida_erro_cta_grp_clien */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/

/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_print_editor
**  Descricao........: Imprime editores nos relat¢rios
*****************************************************************************/
PROCEDURE pi_print_editor:

    def input param p_stream    as char    no-undo.
    def input param p1_editor   as char    no-undo.
    def input param p1_pos      as char    no-undo.
    def input param p2_editor   as char    no-undo.
    def input param p2_pos      as char    no-undo.
    def input param p3_editor   as char    no-undo.
    def input param p3_pos      as char    no-undo.

    def var c_editor as char    extent 5             no-undo.
    def var l_first  as logical extent 5 initial yes no-undo.
    def var c_at     as char    extent 5             no-undo.
    def var i_pos    as integer extent 5             no-undo.
    def var i_len    as integer extent 5             no-undo.

    def var c_aux    as char               no-undo.
    def var i_aux    as integer            no-undo.
    def var c_ret    as char               no-undo.
    def var i_ind    as integer            no-undo.

    assign c_editor [1] = p1_editor
           c_at  [1]    =         substr(p1_pos,1,2)
           i_pos [1]    = integer(substr(p1_pos,3,3))
           i_len [1]    = integer(substr(p1_pos,6,3)) - 4
           c_editor [2] = p2_editor
           c_at  [2]    =         substr(p2_pos,1,2)
           i_pos [2]    = integer(substr(p2_pos,3,3))
           i_len [2]    = integer(substr(p2_pos,6,3)) - 4
           c_editor [3] = p3_editor
           c_at  [3]    =         substr(p3_pos,1,2)
           i_pos [3]    = integer(substr(p3_pos,3,3))
           i_len [3]    = integer(substr(p3_pos,6,3)) - 4
           c_ret        = chr(255) + chr(255).

    do while c_editor [1] <> "" or c_editor [2] <> "" or c_editor [3] <> "":
        do i_ind = 1 to 3:
            if c_editor[i_ind] <> "" then do:
                assign i_aux = index(c_editor[i_ind], chr(10)).
                if i_aux > i_len[i_ind] or (i_aux = 0 and length(c_editor[i_ind]) > i_len[i_ind]) then
                    assign i_aux = r-index(c_editor[i_ind], " ", i_len[i_ind] + 1).
                if i_aux = 0 then
                    assign c_aux = substr(c_editor[i_ind], 1, i_len[i_ind])
                           c_editor[i_ind] = substr(c_editor[i_ind], i_len[i_ind] + 1).
                else
                    assign c_aux = substr(c_editor[i_ind], 1, i_aux - 1)
                           c_editor[i_ind] = substr(c_editor[i_ind], i_aux + 1).
                if i_pos[1] = 0 then
                    assign entry(i_ind, c_ret, chr(255)) = c_aux.
                else
                    if l_first[i_ind] then
                        assign l_first[i_ind] = no.
                    else
                        case p_stream:
                            when "s_1" then
                                if c_at[i_ind] = "at" then
                                    put stream s_1 unformatted c_aux at i_pos[i_ind].
                                else
                                    put stream s_1 unformatted c_aux to i_pos[i_ind].
                            when "s_planilha" then
                                if c_at[i_ind] = "at" then
                                    put stream s_planilha unformatted c_aux at i_pos[i_ind].
                                else
                                    put stream s_planilha unformatted c_aux to i_pos[i_ind].
                        end.
            end.
        end.
        case p_stream:
        when "s_1" then
            put stream s_1 unformatted skip.
        when "s_planilha" then
            put stream s_planilha unformatted skip.
        end.
        if i_pos[1] = 0 then
            return c_ret.
    end.
    return c_ret.
END PROCEDURE.  /* pi_print_editor */
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
                "Programa Mensagem" c_prg_msg "n∆o encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/***********************  End of rpt_tit_acr_em_aberto **********************/
