/***
* Programa.........: rpt_comp_orcamen_desp_denso
* Descricao .......: Relatorio Destinacao Pagamentos
* Versao...........: 1.00.000
* Nome Externo.....: cstp/csap004
*/

/****************** Definiá∆o de Tabelas Tempor†rias do Relat¢rio **********************/
   
/****************** INCLUDE COM VARIµVEIS GLOBAIS *********************/
{cstp/csap004.i}

define input parameter table for ttTitulo.
define input parameter table for ttPortador.

def new shared temp-table tt_tit_ap_alteracao_base_1 no-undo
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usu†rio Corrente" column-label "Usu†rio Corrente"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_dat_transacao                as date format "99/99/9999" label "Data Transaá∆o" column-label "Data Transaá∆o"
    field ttv_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Saldo" column-label "Valor Saldo"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_ult_pagto                as date format "99/99/9999" initial ? label "Data £ltimo Pagto" column-label "Data £ltimo Pagto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_cod-portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field ttv_cod-portador_mov             as character format "x(5)" label "Portador Movto" column-label "Portador Movto"
    field tta_log_pagto_bloqdo             as logical format "Sim/Nío" initial no label "Bloqueia Pagamento" column-label "Pagto Bloqdo"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_apol_seguro              as character format "x(12)" label "Ap¢lice Seguro" column-label "Apolice Seguro"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo EspÇcie" column-label "Tipo EspÇcie"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_ind_motiv_alter_val_tit_ap   as character format "X(09)" initial "Alteraá∆o" label "Motivo Alteraá∆o" column-label "Motivo Alteraá∆o"
    field ttv_wgh_lista                    as widget-handle extent 15 format ">>>>>>9"
    field ttv_log_gera_ocor_alter_valores  as logical format "Sim/N∆o" initial no
    field tta_cb4_tit_ap_bco_cobdor        as Character format "x(50)" label "Titulo Bco Cobrador" column-label "Titulo Bco Cobrador"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_des_histor_padr              as character format "x(40)" label "Descriá∆o" column-label "Descriá∆o Hist¢rico Padr∆o"
    field tta_ind_sit_tit_ap               as character format "X(13)" label "Situaá∆o" column-label "Situaá∆o"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    index tt_titap_id                     
          tta_cod_estab                    ascending
          tta_cdn_fornecedor               ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending.

def new shared temp-table tt_tit_ap_alteracao_rateio no-undo
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "SeqÅància" column-label "Seq"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field ttv_ind_tip_rat                  as character format "X(08)"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field tta_num_id_aprop_ctbl_ap         as integer format "9999999999" initial 0 label "Id Aprop Ctbl AP" column-label "Id Aprop Ctbl AP"
    index tt_aprpctba_id                   is primary unique
          tta_cod_estab                    ascending
          tta_cod_refer                    ascending
          tta_num_seq_refer                ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_tip_fluxo_financ         ascending
          ttv_rec_tit_ap                   ascending.

def new shared temp-table tt_log_erros_tit_ap_alteracao no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Número" column-label "N£mero Mensagem"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "inconsistància"
    field ttv_des_msg_ajuda_1              as character format "x(360)"
    field ttv_wgh_focus                    as widget-handle format ">>>>>>9".

def temp-table tt_log_erros_total no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Número" column-label "N£mero Mensagem"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "inconsistància"
    field ttv_des_msg_ajuda_1              as character format "x(360)"
    field ttv_wgh_focus                    as widget-handle format ">>>>>>9"
    field tta_val_sdo_tit_ap               as decimal format ">>>,>>>,>>9.99" label "Val Sdo".


def var rw-log-exec                                              as rowid no-undo.
def new global shared var i-pais-impto-usuario  as integer format ">>9" no-undo.
def new global shared var l-rpc                 as logical no-undo.

def new global shared temp-table tt-servid-rpc-aplicat
    field tta-cod-aplicat-dtsul like aplicat_dtsul.cod_aplicat_dtsul
    field tta-hdl-servid-rpc     as   handle.

def var c-erro-rpc                              as character format "x(60)" initial " " no-undo.
def var c-erro-aux                              as character format "x(60)" initial " " no-undo.
def new global shared var r-registro-atual      as rowid no-undo.
def new global shared var c-arquivo-log         as char  format "x(60)"no-undo.


/* Vari†veis Padr∆o DWB / Datasul HR */

def new global shared var i-num-ped             as integer no-undo.
def new global shared var v_cdn_empres_usuar    like emsuni.empresa.cod_empresa  no-undo.
def new global shared var h_prog_segur_estab    as handle                   no-undo.
def new global shared var v_cod_grp_usuar_lst   as char                     no-undo.
def new global shared var v_num_tip_aces_usuar  as int                      no-undo.     

/****************** Definiáao de Vari†veis de Processamento do Relat¢rio *********************/

def new global shared var v_cod_dwb_user     as char no-undo. /* usuario corrente */
def var v-num-teste          as integer format "9999" initial 1.
def var i                    as integer no-undo.
def var h-hacr440            as handle no-undo.

DEF VAR c-programa     AS CHARACTER  NO-UNDO. 
DEF VAR c-versao       AS CHARACTER  NO-UNDO.
DEF VAR c-revisao      AS CHARACTER  NO-UNDO.
DEF VAR c-titulo-relat AS CHARACTER  NO-UNDO.
DEF VAR c-sistema      AS CHARACTER  NO-UNDO.
DEF VAR ca-rodape      AS CHARACTER  NO-UNDO.
def var c-empresa      AS CHARACTER  NO-UNDO.
def var c-rodape       AS CHARACTER  NO-UNDO.

DEF VAR p-estab-ini   AS CHARACTER  NO-UNDO.
DEF VAR p-estab-fim   AS CHARACTER  NO-UNDO.
DEF VAR p-espec-ini   AS CHARACTER  NO-UNDO.
DEF VAR p-espec-fim   AS CHARACTER  NO-UNDO.
DEF VAR p-titulo-ini  AS CHARACTER  NO-UNDO.
DEF VAR p-titulo-fim  AS CHARACTER  NO-UNDO.
DEF VAR p-parcela-ini AS CHARACTER  NO-UNDO.
DEF VAR p-parcela-fim AS CHARACTER  NO-UNDO.
DEF VAR p-vencto-ini  AS DATE       NO-UNDO.
DEF VAR p-vencto-fim  AS DATE       NO-UNDO.
DEF VAR p-emissao-ini AS DATE       NO-UNDO.
DEF VAR p-emissao-fim AS DATE       NO-UNDO.
DEF VAR p-portad-ini  AS CHARACTER  NO-UNDO.
DEF VAR p-portad-fim  AS CHARACTER  NO-UNDO.
DEF VAR p-fornec-ini  AS INTEGER  NO-UNDO.
DEF VAR p-fornec-fim  AS INTEGER  NO-UNDO.

def var v-valor       like tit_ap.val_origin_tit_ap no-undo.
def var v-valor-dest  like tit_ap.val_origin_tit_ap no-undo.
def var v-valor-tot   like tit_ap.val_origin_tit_ap no-undo.
def var i-titulo-tot  as int no-undo.

define variable destinados as integer   no-undo.
define variable naoDestinados as integer   no-undo.
define variable emPagamento as integer   no-undo.


def new global shared var c-dir-spool-servid-exec as char no-undo.
def new global shared var i-num-ped-exec-rpw as int no-undo.
def new global shared var v_num_ped_exec_corren as integer format ">>>>>9" no-undo.


/* Vari†veis a serem recuperados pela DWB - set list param */
/* ======================================================= */

def var v_cod_empresa as char no-undo.
def var v_cta_ctbl_1 as char no-undo.
def var v_cta_ctbl_2 as char no-undo.
def var v_cta_ctbl_3 as char no-undo.
def var v_cta_ctbl_4 as char no-undo.
def var v_cta_ctbl_5 as char no-undo.
def var v_cta_ctbl_fim as char no-undo.
def var v_cta_ctbl_ini as char no-undo.
def var v_depto_fim as char no-undo.
def var v_depto_ini as char no-undo.
def var v_direto as char no-undo.
def var v_diretoria_fim as char no-undo.
def var v_diretoria_ini as char no-undo.
def var v_divisao_fim as char no-undo.
def var v_divisao_ini as char no-undo.
def var v_indireto as char no-undo.
def var v_periodo_fim as char format "9999/99" no-undo.
def var v_periodo_ini as char format "9999/99" no-undo.
def var v_Semi as char no-undo.
def var v_tp_despesa as int no-undo.
def var v_tp_relat as int no-undo. 
def var v_variaveis as char no-undo.
def var v_cod_moeda as char no-undo.

/******** Vari†veis do Programa ***************/
def var i-conta          like cta_ctbl.cod_cta_ctbl NO-UNDO. 
def var i-sub-conta      like emsuni.ccusto.cod_ccusto NO-UNDO.
def var c-tipo-desp      as char no-undo.
def var v_debito         like item_lancto_ctbl.val_lancto_ctbl no-undo.
def var v_credito        like item_lancto_ctbl.val_lancto_ctbl no-undo.
def var w-titulo         as char format "x(5)" NO-UNDO.
def var c-per-rel        as char format "XXX-9999" NO-UNDO.
def var d-vl-orc         as de format ">>>>,>>>,>>9.99-". 
def var c-tipo-inf       as char format "!" NO-UNDO.
def var w-descricao-desp as char format "x(29)" NO-UNDO.
def var c-esc-desp       as char format "X" extent 4  initial ["D","I","S","V"] NO-UNDO.
def var w-descfil        as char format "x(15)" NO-UNDO.
def var c-nome-inf       as char format "x(30)" NO-UNDO.
def var l-pagina         as l NO-UNDO.
def var l-ok             as log no-undo.
def var w-descricao      as char format "x(29)" NO-UNDO.
def var c-titulo         as char format "x(132)" NO-UNDO.
def var de-dif-mes       as de format ">>>>,>>>,>>9.99-" NO-UNDO.
def var de-dif-acum      as de format ">>>>,>>>,>>9.99-" NO-UNDO.
def var i-cont-2         as int format "99".
def var de-per-mes       as de NO-UNDO.
def var de-per-acum      as de NO-UNDO.
def var w-moeda-desc     as char format "x(30)" NO-UNDO.
def var i-per-ini        as char format "9999/99" init 0 NO-UNDO.
def var i-per-fim        as char format "9999/99" init 0 NO-UNDO.


def var v_imp_parametro         as log no-undo.
def var i-diretoria    as int.                                       
def var i-tp-diretoria as char no-undo.


/******** TEMP TABLE *********/

/*Define buffer*/
/*=============*/
def buffer b_ped_exec_style for ped_exec.
def buffer b_servid_exec_style for servid_exec.


/****************** Definiáao de Forms do Relat¢rio 132 Colunas ***************************************/ 

def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as char initial "CLIENTES PEND/VENC EM CARTEIRA A MAIS DE NN DIAS".

/******************************************************************************************************/
/* In°cio de Execuá∆o do Relat¢rio */

assign c-programa     = "csap004rp"
       c-versao       = "1.00"
       c-revisao      = "000"
       c-titulo-relat = "Destinaá∆o de Pagamentos"
       c-sistema      = "EMS5"
       ca-rodape      = c-empresa + " - " + c-sistema + " - " 
                      + c-programa + " - V:" + c-versao.
       ca-rodape      = fill("-", 132 - length(ca-rodape)) + ca-rodape.
       v_cod_programa = "csap004".

find first emsuni.empresa no-lock
    where empresa.cod_empresa = v_cod_empres_usuar no-error.

if  avail empresa
then
    assign c-empresa = empresa.nom_razao_social.
else
    assign c-empresa = "".

def stream s_1.
   
if v_cod_dwb_user = "" then
    assign v_cod_dwb_user = v_cod_usuar_corren.

if v_cod_dwb_user begins 'es_' then
    assign v_cod_dwb_user = entry(2,v_cod_dwb_user, "_").
    
if v_num_ped_exec_corren > 0 then do:

    find ped_exec_param no-lock
        where ped_exec_param.num_ped_exec = v_num_ped_exec_corren no-error.
        assign v_cod_parameters = ped_exec_param.cod_dwb_parameters
               v_imp_parametro  = ped_exec_param.log_dwb_print_parameters
               v_cod_dwb_file   = session:temp-directory + 'csap004rp' + ".lst"
               v_cod_dwb_output = ped_exec_param.cod_dwb_output
               c-impressora     = ped_exec_param.nom_dwb_printer
               c-layout         = ped_exec_param.cod_dwb_print_layout
               v_cod_dwb_user   = ped_exec_param.cod_usuar.
end. 
else do:
    find dwb_set_list_param no-lock
        where dwb_set_list_param.cod_dwb_program = v_cod_programa
        and   dwb_set_list_param.cod_dwb_user    = v_cod_dwb_user
        no-error.
        
    if avail dwb_set_list_param then do:
        assign v_cod_parameters = dwb_set_list_param.cod_dwb_parameters
               v_imp_parametro  = dwb_set_list_param.log_dwb_print_parameters
               v_cod_dwb_file   = session:temp-directory + 'csap004rp' + ".lst"
               v_cod_dwb_output = dwb_set_list_param.cod_dwb_output
               c-impressora     = dwb_set_list_param.nom_dwb_printer
               c-layout         = dwb_set_list_param.cod_dwb_print_layout
               v_cod_dwb_user   = dwb_set_list_param.cod_dwb_user.
    end.
end.

do:  /* seta a saida da impressao */
    case v_cod_dwb_output:
        when "Terminal" /*l_terminal*/  then do:
            assign v_cod_dwb_file   = session:temp-directory + 'csap004rp' + ".lst".
            output stream s_1 to value(v_cod_dwb_file) paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
        end.
        when "Impressora" /*l_printer*/  then do:
            find emsfnd.imprsor_usuar no-lock
                where emsfnd.imprsor_usuar.nom_impressora = c-impressora
                and  emsfnd.imprsor_usuar.cod_usuario     = v_cod_dwb_user
                use-index imprsrsr_id no-error.
                
            find first emsfnd.layout_impres no-lock
                where emsfnd.layout_impres.nom_impressora    = c-impressora
                and   emsfnd.layout_impres.cod_layout_impres = c-layout
                no-error.

            assign v_rpt_s_1_bottom = emsfnd.layout_impres.num_lin_pag /* + v_rpt_s_1_bottom - v_rpt_s_1_lines */
                   v_rpt_s_1_lines  = emsfnd.layout_impres.num_lin_pag.
                   
            if opsys = "UNIX" then do:
                if v_num_ped_exec_corren <> 0 then do:
                    find emsfnd.ped_exec no-lock
                        where emsfnd.ped_exec.num_ped_exec = v_num_ped_exec_corren no-error.
                    if avail emsfnd.ped_exec then do:
                        find emsfnd.servid_exec_imprsor no-lock
                            where emsfnd.servid_exec_imprsor.cod_servid_exec = emsfnd.ped_exec.cod_servid_exec
                            and   emsfnd.servid_exec_imprsor.nom_impressora  = c-impressora no-error.
                        if avail servid_exec_imprsor then
                            output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                   paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                       else
                            output stream s_1 through value(imprsor_usuar.nom_disposit_so)
                                paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
                   end.
                end.
                else
                    output stream s_1 through value(imprsor_usuar.nom_disposit_so)
                        paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
            end.
            else
                output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                       paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.

            for each emsfnd.configur_layout_impres no-lock
                where emsfnd.configur_layout_impres.num_id_layout_impres = emsfnd.layout_impres.num_id_layout_impres
                by emsfnd.configur_layout_impres.num_ord_funcao_imprsor:

                find emsfnd.configur_tip_imprsor no-lock
                    where emsfnd.configur_tip_imprsor.cod_tip_imprsor        = layout_impres.cod_tip_imprsor
                    and   emsfnd.configur_tip_imprsor.cod_funcao_imprsor     = configur_layout_impres.cod_funcao_imprsor
                    and   emsfnd.configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
                    no-error.

                put stream s_1 control configur_tip_imprsor.cod_comando_configur.

            end.
        end.
        when "Arquivo" /*l_file*/  then do:
            output stream s_1 to value(session:temp-directory + 'csap004rp' + ".lst")
                   paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.

        end.
    end.
end.

ASSIgn  p-estab-ini    = entry(1,  v_cod_parameters, chr(10))            
        p-estab-fim    = entry(2,  v_cod_parameters, chr(10))
        p-espec-ini    = entry(3,  v_cod_parameters, chr(10))                        
        p-espec-fim    = entry(4,  v_cod_parameters, chr(10))
        p-titulo-ini   = entry(5,  v_cod_parameters, chr(10))
        p-titulo-fim   = entry(6,  v_cod_parameters, chr(10))
        p-parcela-ini  = entry(7,  v_cod_parameters, chr(10))
        p-parcela-fim  = entry(8,  v_cod_parameters, chr(10))
        p-vencto-ini   = date(entry(9,  v_cod_parameters, chr(10)))
        p-vencto-fim   = date(entry(10,  v_cod_parameters, chr(10)))
        p-emissao-ini  = date(entry(11,  v_cod_parameters, chr(10)))
        p-emissao-fim  = date(entry(12,  v_cod_parameters, chr(10)))
        p-portad-ini   = entry(13,  v_cod_parameters, chr(10))
        p-portad-fim   = entry(14,  v_cod_parameters, chr(10))
        p-fornec-ini   = int(entry(15,  v_cod_parameters, chr(10)))
        p-fornec-fim   = int(entry(16,  v_cod_parameters, chr(10))).


/*********************************************************************************************
** BLOCO PRINCIPAL - rpt_comp_orcamen_desp_denso
** Lucas Sergio 
** 17/12/98
**********************************************************************************************/
form header
    fill("-", 132) format "x(136)" skip
    c-empresa  format "x(40)" c-titulo-relat at 51 format "x(40)"
    "Folha:  " at 120 page-number(s_1) format ">>>9" skip
    fill("-", 110) format "x(110)" today format "99/99/9999"
    "-" string(time, "HH:MM:SS") skip
    with width 250 no-labels no-box page-top frame fr-cabec.

form header
    ca-rodape format "x(132)"
    with width 180 no-labels no-box page-bottom frame fr-rodape.

form header
    fill("-", 150) format "x(150)" skip
    c-empresa c-titulo-relat at 60
    "Folha:" at 130 page-number  at 137 format ">>>9" skip
    fill("-",124) format "x(124)" today format "99/99/99"
    "-" string(time, "HH:MM:SS") skip(1)
with no-box no-labels width 150 stream-io column 7 page-top frame f-cabec-1.


form header
    c-rodape format "x(150)"
    with stream-io width 150 column 7 no-labels no-box page-bottom frame f-rodape-1.

    
view stream s_1 frame fr-cabec.
view stream s_1 frame fr-rodape.

run pi-destina-pagto.


if v_imp_parametro = yes then do:
               
      
/*    Put stream s_1 unformatted
            skip(2)
            "SELEÄ«O" at 001 skip 
            "Empresa...................: " at 005 v_empresa      skip
            "Per°odo Inicial...........: " at 005 v_periodo      skip
            "Conta Cont†bil Inicial....: " at 005 v_cta_ctbl_ini           "Conta Cont†bil Final....: " at 055 v_cta_ctbl_fim          skip
            "Centro Custo Inicial......: " at 005 v_cod_ccusto_ini         "Centro Custo Final......: " at 055 v_cod_ccusto_fim        skip
            "Despesa Indireta..........: " at 005 v_indireto               "Despesa Direta..........: " at 055 v_direto                skip
            "Despesa Semi-Direta.......: " at 005 v_semi                   "Despesa Variavel........: " at 055 v_variavel              skip
            "IMPRESS«O" at 001 skip
            "Classifica por.: " at 005 c_classif
            "Tipo Impress∆o.: " at 005 c_tipo_relat
            "Por Despesa....: " at 005 v_resumo_tipo
            "Por Cta Ctbl...: " at 005 v_resumo_conta
            "Destino........: " at 005 v_cod_dwb_output skip
            "Usu†rio........: " at 005 v_cod_usuar_corren skip(2).*/
end. 

output stream s_1 close.

return "ok".

/* fim dor progama */
/*********************************************************************************************
** Procedure Interna pi-destina-pagto
** Relat¢rio Destinacao Pagamentos
** Lucas Sergio
** 06/11/2002
**********************************************************************************************/
procedure pi-destina-pagto:

    Define var v_cod_forma_pagto like tit_ap.cod_forma_pagto no-undo.

    for each ttTitulo:
    
        empty temp-table tt_tit_ap_alteracao_base_1.
        find first portador NO-LOCK
            where portador.cod_portador = ttTitulo.cod-portador no-error.
        
        find first ttPortador no-lock
            where ttPortador.cod-portador = ttTitulo.cod-portador
              and ttPortador.cod-cart-bcia = ttTitulo.cod-cart-bcia no-error.
    
        find first tit_ap no-lock
            where recid(tit_ap) = re-tit-ap no-error.
            

        if substring(tit_ap.cb4_tit_ap_bco_cobdor,1,3) = portador.cod_banco then
           assign 
               v_cod_forma_pagto = ttPortador.cod-forma-pagto-mesmo.
        else
           assign 
               v_cod_forma_pagto = ttPortador.cod-forma-pagto-outro.

        if tit_ap.cod_portador <> portador.cod_portador or
            tit_ap.cod_forma_pagto <> v_cod_forma_pagto then do:
        
            create tt_tit_ap_alteracao_base_1.
            assign tt_tit_ap_alteracao_base_1.ttv_cod_usuar_corren         = v_cod_usuar_corren
                tt_tit_ap_alteracao_base_1.tta_cod_empresa                 = tit_ap.cod_empresa                              
                tt_tit_ap_alteracao_base_1.tta_cod_estab                   = tit_ap.cod_estab                                
                tt_tit_ap_alteracao_base_1.tta_num_id_tit_ap               = tit_ap.num_id_tit_ap                            
                tt_tit_ap_alteracao_base_1.ttv_rec_tit_ap                  = recid(tit_ap)                                   
                tt_tit_ap_alteracao_base_1.tta_cdn_fornecedor              = tit_ap.cdn_fornecedor                           
                tt_tit_ap_alteracao_base_1.tta_cod_espec_docto             = tit_ap.cod_espec_docto                          
                tt_tit_ap_alteracao_base_1.tta_cod_ser_docto               = tit_ap.cod_ser_docto                            
                tt_tit_ap_alteracao_base_1.tta_cod_tit_ap                  = tit_ap.cod_tit_ap                               
                tt_tit_ap_alteracao_base_1.tta_cod_parcela                 = tit_ap.cod_parcela                              
                tt_tit_ap_alteracao_base_1.ttv_dat_transacao               = TODAY
                tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap              = tit_ap.val_sdo_tit_ap                           
                tt_tit_ap_alteracao_base_1.tta_dat_emis_docto              = ?
                tt_tit_ap_alteracao_base_1.tta_dat_vencto_tit_ap           = ?
                tt_tit_ap_alteracao_base_1.tta_dat_prev_pagto              = ?
                tt_tit_ap_alteracao_base_1.tta_dat_ult_pagto               = ?
                tt_tit_ap_alteracao_base_1.tta_dat_desconto                = tit_ap.dat_desconto
                tt_tit_ap_alteracao_base_1.tta_val_desconto                = tit_ap.val_desconto
                tt_tit_ap_alteracao_base_1.tta_cod-portador                = portador.cod_portador 
                tt_tit_ap_alteracao_base_1.tta_log_pagto_bloqdo            = tit_ap.LOG_pagto_bloqdo                             
                tt_tit_ap_alteracao_base_1.tta_cod_seguradora              = tit_ap.cod_seguradora                           
                tt_tit_ap_alteracao_base_1.tta_cod_apol_seguro             = tit_ap.cod_apol_seguro                 
                tt_tit_ap_alteracao_base_1.tta_cod_arrendador              = tit_ap.cod_arrendador                         
                tt_tit_ap_alteracao_base_1.tta_cod_contrat_leas            = tit_ap.cod_contrat_leas                 
                tt_tit_ap_alteracao_base_1.tta_ind_tip_espec_docto         = tit_ap.ind_tip_espec_docto                           
                tt_tit_ap_alteracao_base_1.tta_cod_indic_econ              = tit_ap.cod_indic_econ                        
                tt_tit_ap_alteracao_base_1.tta_cod_forma_pagto             = v_cod_forma_pagto
                /*tt_tit_ap_alteracao_base_1.tta_cb4_tit_ap_bco_cobdor       = "21123123" */
                tt_tit_ap_alteracao_base_1.tta_ind_sit_tit_ap              = tit_ap.ind_sit_tit_ap
                tt_tit_ap_alteracao_base_1.ttv_ind_motiv_alter_val_tit_ap  = "Alteraá∆o".
            
            
            
           repeat:
            
               IF tit_ap.cod_portador <> portador.cod_portador or
                   tit_ap.cod_forma_pagto <> v_cod_forma_pagto then do:

                    run prgfin/apb/apb767zc.py (input 1,
                                        input "APB",
                                        input "",
                                        input-output table tt_tit_ap_alteracao_base_1,
                                        input-output table tt_tit_ap_alteracao_rateio,
                                        output table tt_log_erros_tit_ap_alteracao).

                    IF NOT CAN-FIND(first tt_log_erros_tit_ap_alteracao) THEN DO:

/*                             find last proces_pagto use-index prcspgt_id                     */
/*                                 where proces_pagto.cod_estab       = tit_ap.cod_estab       */
/*                                 and   proces_pagto.cod_espec_docto = tit_ap.cod_espec_docto */
/*                                 and   proces_pagto.cod_ser_docto   = tit_ap.cod_ser_docto   */
/*                                 and   proces_pagto.cdn_fornecedor  = tit_ap.cdn_fornecedor  */
/*                                 and   proces_pagto.cod_tit_ap      = tit_ap.cod_tit_ap      */
/*                                 and   proces_pagto.cod_parcela     = tit_ap.cod_parcela     */
/*                                 AND   proces_pagto.ind_sit_proces_pagto     = "Liberado"    */
/*                                 EXCLUSIVE-LOCK no-error.                                    */
/*                                                                                             */
/*                             IF AVAIL proces_pagto THEN                                      */
/*                                                                                             */
/*                                 ASSIGN                                                      */
/*                                     proces_pagto.cod-portador = portador.cod-portador.      */

                    END.

                    if not can-find(first tt_log_erros_tit_ap_alteracao 
                                    where tt_log_erros_tit_ap_alteracao.ttv_num_mensagem = 742) THEN 
                    
                                    leave.
               end.          
               else
                 leave.
            end.        
            
            for each tt_log_erros_tit_ap_alteracao no-lock WHERE
                tt_log_erros_tit_ap_alteracao.ttv_num_mensagem <> 0:

                for first tit_ap
                    fields (val_sdo_tit_ap)
                    where tit_ap.cod_estab       = tt_log_erros_tit_ap_alteracao.tta_cod_estab      
                      and tit_ap.cdn_fornecedor  = tt_log_erros_tit_ap_alteracao.tta_cdn_fornecedor 
                      and tit_ap.cod_espec_docto = tt_log_erros_tit_ap_alteracao.tta_cod_espec_docto
                      and tit_ap.cod_ser_docto   = tt_log_erros_tit_ap_alteracao.tta_cod_ser_docto  
                      and tit_ap.cod_tit_ap      = tt_log_erros_tit_ap_alteracao.tta_cod_tit_ap     
                      and tit_ap.cod_parcela     = tt_log_erros_tit_ap_alteracao.tta_cod_parcela.
                end.
                
                create tt_log_erros_total.
                buffer-copy tt_log_erros_tit_ap_alteracao to tt_log_erros_total
                    assign tt_log_erros_total.tta_val_sdo_tit_ap = if avail tit_ap 
                                                                   then tit_ap.val_sdo_tit_ap
                                                                   else 0.
            end.
        end.
    end.
   /* 
    run prgfin/apb/apb767zc.py (input 1,
                                input "APB",
                                input "",
                                input-outPUT table tt_tit_ap_alteracao_base_1,
                                input-outPUT table tt_tit_ap_alteracao_rateio,
                                outPUT table tt_log_erros_tit_ap_alteracao). */
    /* if not can-find(first tt_log_erros_tit_ap_alteracao) then */
        run pi-imprime-destinacao.
    /* else do: */
        put stream s_1 skip(2).
        for each tt_log_erros_total:
            disp stream s_1
                 tt_log_erros_total.tta_cod_estab                    
                 tt_log_erros_total.tta_cdn_fornecedor               
                 tt_log_erros_total.tta_cod_espec_docto              
                 tt_log_erros_total.tta_cod_ser_docto                
                 tt_log_erros_total.tta_cod_tit_ap                   
                 tt_log_erros_total.tta_cod_parcela                  
                 tt_log_erros_total.tta_val_sdo_tit_ap
               with width 132 no-box stream-io down frame f-tit-erro.  
            disp stream s_1
                 tt_log_erros_total.ttv_num_mensagem                 
                 tt_log_erros_total.ttv_des_msg_erro                 
                 tt_log_erros_total.ttv_des_msg_ajuda_1 view-as editor inner-chars 45 inner-lines 4 column-label "Mensagem Ajuda"
               with width 132 no-box stream-io down frame f-erro.  
        /* end. */
            
    end.
end.

/*********************************************************************************************
** Procedure Interna pi-imprime-destinacao
** Relat¢rio Destinacao Pagamentos
** Lucas Sergio
** 06/11/2002
**********************************************************************************************/
Procedure pi-imprime-destinacao:

    define variable d-valor-pgto-tit like tit_ap.val_sdo_tit_ap no-undo.

    put stream s_1 skip(1).

    for each ttPortador
        no-lock
        break by ttPortador.cod-portador:
        
        for each ttTitulo 
            where ttTitulo.cod-portador = ttPortador.cod-portador
              and ttTitulo.cod-cart-bcia = ttPortador.cod-cart-bcia 
            no-lock:
            
            for each tit_ap 
               where recid(tit_ap) = ttTitulo.re-tit-ap
                no-lock:

                assign 
                    d-valor-pgto-tit = tit_ap.val_sdo_tit_ap.

                if tit_ap.dat_desconto >= today then
                    assign 
                        d-valor-pgto-tit = d-valor-pgto-tit - tit_ap.val_desconto.
                
               assign 
                   v-valor = v-valor + d-valor-pgto-tit
                   destinados = destinados + 1
                   v-valor-tot = v-valor-tot + d-valor-pgto-tit
                   i-titulo-tot = i-titulo-tot + 1. 
            end.
        end.
        
        if last-of(ttPortador.cod-portador) then do:

            find first portador 
                where portador.cod_portador = ttPortador.cod-portador 
                no-lock no-error.        
        
            assign 
                v-valor-dest = v-valor-dest + ttPortador.vl-maximo.

            disp stream s_1
                 portador.cod_portador when avail portador
                 ttPortador.cod-cart-bcia 
                 ttPortador.vl-maximo at 26
                 v-valor  column-label "Vl. Destinado"
                 destinados column-label "Qt T°tulos"
                 with width 132 no-box down stream-io frame f-destinac.

            assign 
                v-valor = 0
                destinados = 0.
        end.
    end.

    put stream s_1
        "--------------- --------------- ----------" at 26
        "Total Geral" at 1
        v-valor-dest   at 26
        v-valor-tot    at 42
        i-titulo-tot   at 58.
           
    put stream s_1
        skip(1)
        "---------- T°tulos N∆o Destinados ---------" at 1.

    put stream s_1 skip(1).
    
    for each tit_ap use-index titap_dat_prev_pagto
        where tit_ap.cod_estab           >= p-estab-ini
          and tit_ap.cod_estab           <= p-estab-fim
          and tit_ap.cod_espec_docto     >= p-espec-ini
          and tit_ap.cod_espec_docto     <= p-espec-fim
          and tit_ap.dat_prev_pagto      >= p-vencto-ini - 10
          and tit_ap.dat_vencto_tit_ap   >= p-vencto-ini
          and tit_ap.dat_vencto_tit_ap   <= p-vencto-fim 
          and tit_ap.dat_liquidac_tit_ap  = 12/31/9999
        no-lock:

        if not can-find(first ems5.espec_docto
                    where espec_docto.cod_espec_docto 
                          = tit_ap.cod_espec_docto
                      and espec_docto.ind_tip_espec_docto = "normal") then next.

        if not (
              tit_ap.cod_empresa            = v_cod_empres_usuar
          and tit_ap.cb4_tit_ap_bco_cobdor <> ''
          and tit_ap.val_sdo_tit_ap         > 0
          and tit_ap.cdn_fornecedor        >= p-fornec-ini
          and tit_ap.cdn_fornecedor        <= p-fornec-fim
          and tit_ap.cod_tit_ap            >= p-titulo-ini
          and tit_ap.cod_tit_ap            <= p-titulo-fim
          and tit_ap.cod_parcela           >= p-parcela-ini
          and tit_ap.cod_parcela           <= p-parcela-fim
          and tit_ap.dat_emis_docto        >= p-emissao-ini
          and tit_ap.dat_emis_docto        <= p-emissao-fim
          and tit_ap.cod_portador          >= p-portad-ini
          and tit_ap.cod_portador          <= p-portad-fim
            ) then next.

        if can-find(first ttTitulo
            where ttTitulo.re-tit-ap = recid(tit_ap))
        then next.

        assign 
            d-valor-pgto-tit = tit_ap.val_sdo_tit_ap.

        if tit_ap.dat_desconto >= today then
            assign 
                d-valor-pgto-tit = d-valor-pgto-tit - tit_ap.val_desconto.

        if can-find(first item_bord_ap
                    where item_bord_ap.cod_estab           = tit_ap.cod_estab
                      and item_bord_ap.cod_espec_docto     = tit_ap.cod_espec_docto
                      and item_bord_ap.cod_ser_docto       = tit_ap.cod_ser_docto
                      and item_bord_ap.cdn_fornecedor      = tit_ap.cdn_fornecedor
                      and item_bord_ap.cod_tit_ap          = tit_ap.cod_tit_ap
                      and item_bord_ap.cod_parcela         = tit_ap.cod_parcela) or
            can-find(first item_lote_pagto
                    where item_lote_pagto.cod_estab        = tit_ap.cod_estab
                      and item_lote_pagto.cod_espec_docto  = tit_ap.cod_espec_docto
                      and item_lote_pagto.cod_ser_docto    = tit_ap.cod_ser_docto
                      and item_lote_pagto.cdn_fornecedor   = tit_ap.cdn_fornecedor
                      and item_lote_pagto.cod_tit_ap       = tit_ap.cod_tit_ap
                      and item_lote_pagto.cod_parcela      = tit_ap.cod_parcela) then
            assign 
                emPagamento = emPagamento + 1.
        else
            assign 
                naoDestinados = naoDestinados + 1.
        
        disp stream s_1
             tit_ap.cod_estab        
             tit_ap.cod_espec_docto  
             tit_ap.cod_ser_docto
             tit_ap.cod_tit_ap       
             tit_ap.cod_parcela      
             tit_ap.dat_vencto_tit_ap
             tit_ap.dat_emis_docto   
             d-valor-pgto-tit label "Valor"
             tit_ap.cod_portador     
             tit_ap.cdn_fornecedor
             tit_ap.val_sdo_tit_ap
             with width 132 no-box stream-io down frame f-titulo.
    end.
    put stream s_1
        skip(1)
        "Total N∆o Destinados" 
        naoDestinados at 30.

    put stream s_1
        skip(1)
        "Total em processo pagamento" 
        emPagamento at 30.


End Procedure.      /* Procedure pi-imprime-desp-deptos-liquid */

/*********************************************************************************************
** Procedure Interna pi-abre-edit
** Titulos em Aberto Vencidos
** Joubert Anderson Vieira.
** 20/08/2002
**********************************************************************************************/
Procedure pi-abre-edit:

def Input param p_cod_dwb_file
    as char
    format "x(40)"
    no-undo.

def var v_cod_key_value
    as char
    format "x(8)"
    no-undo.

get-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value.
if  v_cod_key_value = ""
or  v_cod_key_value = ?
then do:
    assign v_cod_key_value = 'notepad.exe'.
    put-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value no-error.
end.

os-command silent value(v_cod_key_value + chr(32) + p_cod_dwb_file).

END PROCEDURE. 

/**********************************************************/
Procedure pi-tira-espaco:

DEF INPUT PARAM P_COD_TXT AS CHAR.
def output param p_cod_txt2 as char.
def var v_cod_txt  as char.
def var v_cod_txt1 as char.

def var i as integer.
def var j as integer.
def var v_cont_i as integer.

ASSIGN v_cod_txt = P_cod_txt.
    
  
    assign v_cod_txt1 = v_cod_txt.
  
    
    do i = 1 to length(v_cod_txt1):
    
        if  substring(v_cod_txt1, i, 1)     <> chr(-1)
        then
            assign p_cod_txt2 = p_cod_txt2 + substring(v_cod_txt1, i, 1).
        else do:
            assign j = i.
            repeat:
                if substring(v_cod_txt1, j, 1) = chr(-1) then 
                    assign p_cod_txt2 = p_cod_txt2 + "".
                else do:
                    if j > i then
                        assign p_cod_txt2 = p_cod_txt2 + " ".
                    leave.
                end.
                assign j = j + 1.
                if j > length(v_cod_txt1) then leave.
            end.
            assign p_cod_txt2 = p_cod_txt2 + substring(v_cod_txt1, j, 1).
            assign i = j.
        end.
    
    end.
    
end procedure.

if i-num-ped-exec-rpw <> 0 then 
    return "OK".
