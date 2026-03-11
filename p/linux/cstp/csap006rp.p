{cstp\i-var-imp.i}
def var v_imp_parametro         as log no-undo.

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


/* Vari veis PadrÆo DWB / Datasul HR */

def new global shared var i-num-ped             as integer no-undo.
def new global shared var v_cdn_empres_usuar    like emsuni.empresa.cod_empresa  no-undo.
def new global shared var h_prog_segur_estab    as handle                   no-undo.
def new global shared var v_cod_grp_usuar_lst   as char                     no-undo.
def new global shared var v_num_tip_aces_usuar  as int                      no-undo.     

/****************** Defini‡ao de Vari veis de Processamento do Relat¢rio *********************/

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

def new global shared var c-dir-spool-servid-exec as char no-undo.
def new global shared var i-num-ped-exec-rpw as int no-undo.
def new global shared var v_num_ped_exec_corren as integer format ">>>>>9" no-undo.


/* Vari veis a serem recuperados pela DWB - set list param */
/* ======================================================= */

def var v_cod_empresa as char no-undo.
def var v_cta_ctbl_1 as char no-undo.
def var v_cta_ctbl_2 as char no-undo.
def var v_cta_ctbl_3 as char no-undo.
def var v_cta_ctbl_4 as char no-undo.
def var v_cta_ctbl_5 as char no-undo.
def var c-fornec-fim as INT no-undo.
def var c-fornec-ini as INT no-undo.
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



DEF VAR c-estab-ini     AS CHAR NO-UNDO.
DEF VAR c-estab-fim     AS CHAR NO-UNDO.
DEF VAR c-especie-ini   AS CHAR NO-UNDO.
DEF VAR c-especie-fim   AS CHAR NO-UNDO.
DEF VAR c-serie-ini     AS CHAR NO-UNDO.
DEF VAR c-serie-fim     AS CHAR NO-UNDO.
DEF VAR c-titulo-ini    AS CHAR NO-UNDO.
DEF VAR c-titulo-fim    AS CHAR NO-UNDO.
DEF VAR c-parcela-ini   AS CHAR NO-UNDO.
DEF VAR c-parcela-fim   AS CHAR NO-UNDO.
DEF VAR i-fornec-ini    AS INT NO-UNDO.
DEF VAR i-fornec-fim    AS INT NO-UNDO.
DEF VAR da-vencto-ini   AS DATE NO-UNDO.
DEF VAR da-vencto-fim   AS DATE NO-UNDO.
def var c-linha-digi    as char no-undo.
DEF VAR i-impressos     AS INT  NO-UNDO.

DEF VAR d-total-ap     LIKE movto_tit_ap.val_movto_ap NO-UNDO.
DEF VAR d-acrescimo-ap LIKE movto_tit_ap.val_movto_ap NO-UNDO.
DEF VAR d-desconto-ap LIKE movto_tit_ap.val_movto_ap NO-UNDO.
DEFINE VARIABLE i-cont AS INTEGER  INIT 1  NO-UNDO.

def var v-valortit      as decimal no-undo.
def var v-datavenctit   as date    no-undo.

DEF BUFFER fornecedor FOR ems5.fornecedor.
DEF BUFFER portador FOR ems5.portador.
def buffer b_ped_exec_style for emsfnd.ped_exec.
def buffer b_servid_exec_style for emsfnd.servid_exec.


/****************** Defini‡ao de Forms do Relat¢rio 132 Colunas ***************************************/ 

def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as char initial "CLIENTES PEND/VENC EM CARTEIRA A MAIS DE NN DIAS".

/****************** Defini‡äes para utiliza‡Æo da fun‡Æo de numero extenso ***************************/
DEFINE VARIABLE c-retorno AS CHARACTER  NO-UNDO.
DEFINE NEW SHARED TEMP-TABLE tt_val_extenso
    FIELD ttv_des_val_extenso AS CHAR.

/******************************************************************************************************/
/* In¡cio de Execu‡Æo do Relat¢rio */

assign c-programa     = "csap006"
       c-versao       = "1.00"
       c-revisao      = "000"
       c-titulo-relat = "Recibo Pagamento Escritural"
       c-sistema      = "EMS5"
       ca-rodape      = c-empresa + " - " + c-sistema + " - " 
                      + c-programa + " - V:" + c-versao.
       ca-rodape      = fill("-", 132 - length(ca-rodape)) + ca-rodape.
       v_cod_programa = "csap006".

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

    find emsfnd.ped_exec_param no-lock
        where emsfnd.ped_exec_param.num_ped_exec = v_num_ped_exec_corren no-error.
        assign v_cod_parameters = emsfnd.ped_exec_param.cod_dwb_parameters
               v_imp_parametro  = emsfnd.ped_exec_param.log_dwb_print_parameters
               v_cod_dwb_file   = session:temp-directory + 'csap006rp' + ".lst"
               v_cod_dwb_output = emsfnd.ped_exec_param.cod_dwb_output
               c-impressora     = emsfnd.ped_exec_param.nom_dwb_printer
               c-layout         = emsfnd.ped_exec_param.cod_dwb_print_layout
               v_cod_dwb_user   = emsfnd.ped_exec_param.cod_usuar.
end. 
else do:
    find emsfnd.dwb_set_list_param no-lock
        where emsfnd.dwb_set_list_param.cod_dwb_program = v_cod_programa
        and   emsfnd.dwb_set_list_param.cod_dwb_user    = v_cod_dwb_user
        no-error.
        
    if avail emsfnd.dwb_set_list_param then do:
        assign v_cod_parameters = emsfnd.dwb_set_list_param.cod_dwb_parameters
               v_imp_parametro  = emsfnd.dwb_set_list_param.log_dwb_print_parameters
               v_cod_dwb_file   = session:temp-directory + 'csap006rp' + ".lst"
               v_cod_dwb_output = emsfnd.dwb_set_list_param.cod_dwb_output
               c-impressora     = emsfnd.dwb_set_list_param.nom_dwb_printer
               c-layout         = emsfnd.dwb_set_list_param.cod_dwb_print_layout
               v_cod_dwb_user   = emsfnd.dwb_set_list_param.cod_dwb_user.
    end.
end.

do:  /* seta a saida da impressao */
    case v_cod_dwb_output:
        when "Terminal" /*l_terminal*/  then do:
            assign v_cod_dwb_file   = session:temp-directory + 'csap006rp' + ".lst".
            output stream s_1 to value(session:temp-directory + 'csap006rp' + ".lst") paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.
        end.
        when "Arquivo" /*l_file*/  then do:
            output stream s_1 to value(session:temp-directory + 'csap006rp' + ".lst")
                   paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.

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
    end.
end.


ASSIGN i-fornec-ini = int(ENTRY(1, v_cod_parameters, CHR(10)))
       i-fornec-fim = int(ENTRY(2, v_cod_parameters, CHR(10)))
       c-titulo-ini    = ENTRY(3, v_cod_parameters, CHR(10))
       c-titulo-fim    = ENTRY(4, v_cod_parameters, CHR(10))
       c-parcela-ini   = ENTRY(5, v_cod_parameters, CHR(10))
       c-parcela-fim   = ENTRY(6, v_cod_parameters, CHR(10))
       da-vencto-ini   = DATE(ENTRY(7, v_cod_parameters, CHR(10)))
       da-vencto-fim   = DATE(ENTRY(8, v_cod_parameters, CHR(10)))
       c-linha-digi    = entry(9, v_cod_parameters, chr(10))
       v-valortit      = deci(substring(c-linha-digi, 38, 10)) / 100
       v-datavenctit   = 10/07/97 + int(substring(c-linha-digi, 34, 4)).    

etime(yes).

for each tit_ap 
    fields(
        dat_vencto_tit_ap   log_tit_ap_estordo
        val_sdo_tit_ap      cb4_tit_ap_bco_cobdor
        cod_estab           num_id_tit_ap
        cod_tit_ap          cod_parcela 
        cdn_fornecedor                            ) no-lock
    where tit_ap.cod_estab      >= ""
      and tit_ap.cod_estab      <= "ZZZ"
      and tit_ap.cdn_fornecedor >= i-fornec-ini
      and tit_ap.cdn_fornecedor <= i-fornec-fim
      and tit_ap.cod_tit_ap     >= c-titulo-ini
      and tit_ap.cod_tit_ap     <= c-titulo-fim
      and tit_ap.cod_parcela    >= c-parcela-ini
      and tit_ap.cod_parcela    <= c-parcela-fim:

    if not ( tit_ap.dat_vencto_tit_ap >= da-vencto-ini and
             tit_ap.dat_vencto_tit_ap <= da-vencto-fim and
             tit_ap.log_tit_ap_estordo = false ) then 
        next.

    if length(c-linha-digi)        = 48              and
       (tit_ap.val_sdo_tit_ap     <> v-valortit      or
        tit_ap.dat_vencto_tit_ap  <> v-datavenctit)  then 
        next.

    if c-linha-digi                 <> ""            and 
       tit_ap.cb4_tit_ap_bco_cobdor <> c-linha-digi  then 
        next.

    for each movto_tit_ap  
        where movto_tit_ap.cod_estab          = tit_ap.cod_estab
          and movto_tit_ap.num_id_tit_ap      = tit_ap.num_id_tit_ap
        no-lock:

        if movto_tit_ap.ind_trans_ap_abrev  <> "BXA" then 
            next.

        PUT STREAM s_1 "Comprovante de Pagamento" AT 31 SKIP(2).
        PUT STREAM s_1 "Emitido Em......... : " TODAY skip.

        FOR FIRST fornecedor FIELDS (cdn_fornecedor num_pessoa cod_empresa nom_pessoa) WHERE fornecedor.cdn_fornecedor = tit_ap.cdn_fornecedor NO-LOCK.
        END.

        find first estabelecimento
            where estabelecimento.cod_estab = tit_ap.cod_estab
            no-lock no-error.

        if avail estabelecimento then do:
            FOR FIRST empresa FIELDS (nom_razao_social) WHERE empresa.cod_empresa = estabelecimento.cod_empresa.
            END.
        end.

        PUT STREAM s_1 "Sacado..............: " AT 1 empresa.nom_razao_social skip.
        PUT STREAM s_1 "Favorecido..........: " AT 1 fornecedor.nom_pessoa skip.

        PUT STREAM s_1 "Documento/Parcela...: " AT 1 
            trim(tit_ap.cod_tit_ap) format ("x(" + string(length(trim(tit_ap.cod_tit_ap))) + ")") 
            "/" tit_ap.cod_parcela SKIP.

        
        ASSIGN d-total-ap = movto_tit_ap.val_movto_ap + movto_tit_ap.val_juros + movto_tit_ap.val_multa_tit_ap - (movto_tit_ap.val_desconto + movto_tit_ap.val_abat_tit_ap)
               d-acrescimo-ap = movto_tit_ap.val_juros + movto_tit_ap.val_multa_tit_ap 
               d-desconto-ap  = movto_tit_ap.val_desconto + movto_tit_ap.val_abat_tit_ap.

        PUT STREAM s_1 "Valor do Documento..: " AT 1 movto_tit_ap.val_movto_ap.
        PUT STREAM s_1 "Acr‚scimos..........: " AT 1 d-acrescimo-ap.
        PUT STREAM s_1 "Descontos...........: " AT 1 d-desconto-ap.
        PUT STREAM s_1 "Valor L¡quido.......: " AT 1 d-total-ap.
        PUT STREAM s_1 "Data Pagamento......: " AT 1 movto_tit_ap.dat_transacao.
               
        FIND FIRST portador NO-LOCK
            WHERE portador.cod_portador = movto_tit_ap.cod_portador NO-ERROR.
        IF AVAIL portador then do:
            PUT STREAM s_1 "Liquidado no........: " AT 1 portador.nom_pessoa SKIP
                           "Ag: " at 23 portador.cod_agenc_bcia. 
            for first portad_finalid_econ fields(cod_cta_corren) 
                where portad_finalid_econ.cod_portador = portador.cod_portador
                  and portad_finalid_econ.cod_estab    = tit_ap.cod_estab.
            end.
            if avail portad_finalid_econ then
                put stream s_1 "CC: " portad_finalid_econ.cod_cta_corren skip.
            else
                put stream s_1 skip.
        end.
            IF tit_ap.cb4_tit_ap_bco_cobdor <> "" THEN 
                PUT STREAM s_1 "Linha Digit vel.....:" AT 1 tit_ap.cb4_tit_ap_bco_cobdor.
        

            
        PUT STREAM s_1 FILL("-",80) FORMAT "x(80)" AT 1.
        PUT STREAM s_1 SKIP(2).
    end.
end.
/*
IF v_imp_parametro = TRUE  THEN do:
    PUT STREAM s_1  "Estab Inicial: " c-estab-ini skip
                    "Estab Final: "  c-estab-fim skip   
                    "Especie Inicial: "  c-especie-ini  skip   
                    "Especie Final: "  c-especie-fim  skip   
                    "Serie Inicial: " c-serie-ini    skip   
                    "Serie Final: " c-serie-fim    skip   
                    "Titulo Inicial: " c-titulo-ini   skip   
                    "Titulo Final: " c-titulo-fim    skip   
                    "Parcela Inicial: " c-parcela-ini  skip   
                    "Parecla Final: " c-parcela-fim  skip   
                    "Fornec Inicial: " i-fornec-ini format ">>>>>>>>>>>>>>>9"  skip   
                    "Fornec Final: " i-fornec-fim format ">>>>>>>>>>>>>>>9"  skip   
                    "Vcto Inicial: " da-vencto-ini  skip   
                    "Vcto Final: " da-vencto-fim  skip   
                    "Imprime: " ENTRY(i-impressos,"NÆo Impressos,Impressos,Todos") format "x(13)"SKIP(1).
end.*/
