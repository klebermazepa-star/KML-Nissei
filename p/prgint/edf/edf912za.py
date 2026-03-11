/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: fnc_banking_connect_05
** Descricao.............: F¢rmula Banking Connect 05
** Versao................:  1.00.00.001
** Procedimento..........: utl_banking_connect_02
** Nome Externo..........: prgint/edf/edf912za.py
** Data Geracao..........: 25/03/2008 - 15:35:13
** Criado por............: fut41506
** Criado em.............: 14/12/2007 16:36:24
** Alterado por..........: fut41506
** Alterado em...........: 26/12/2007 09:44:17
** Gerado por............: fut31947
*****************************************************************************/

/*-- Filtro Multi-idioma Aplicado --*/

def var c-versao-prg as char initial " 1.00.00.001":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.001[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */
def var h_facelift as handle no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/i_fcldef.i}
{include/i_trddef.i}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i  fnc_banking_connect_05 EDF}
&ENDIF



/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=0":U.
/*************************************  *************************************/

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_param_program_formul no-undo
    field tta_cdn_segment_edi              as Integer format ">>>>>9" initial 0 label "Segmento" column-label "Segmento"
    field tta_cdn_element_edi              as Integer format ">>>>>9" initial 0 label "Elemento" column-label "Elemento"
    field tta_des_label_utiliz_formul_edi  as character format "x(10)" label "Label Utiliz Formula" column-label "Label Utiliz Formula"
    field ttv_des_contdo                   as character format "x(100)" label "Conteudo" column-label "Conteudo"
    index tt_param_program_formul_id       is primary
          tta_cdn_segment_edi              ascending
          tta_cdn_element_edi              ascending
    .

def shared temp-table tt_segment_tot no-undo
    field tta_cdn_segment_edi              as Integer format ">>>>>9" initial 0 label "Segmento" column-label "Segmento"
    field ttv_qtd_proces_edi               as decimal format "->>>>,>>9.9999" decimals 4
    field ttv_qtd_bloco_docto              as decimal format "99999"
    field ttv_log_trailler_edi             as logical format "Sim/NÆo" initial no label "Trailler" column-label "Trailler"
    field ttv_log_header_edi               as logical format "Sim/NÆo" initial no label "Header" column-label "Header"
    .



/********************** Temporary Table Definition End **********************/

/************************ Parameter Definition Begin ************************/

def Input param p_cdn_mapa_edi
    as Integer
    format ">>>>>9"
    no-undo.
def Input param p_cdn_segment_edi
    as Integer
    format ">>>>>9"
    no-undo.
def Input param p_cdn_element_edi
    as Integer
    format ">>>>>9"
    no-undo.
def Input param table 
    for tt_param_program_formul.


/************************* Parameter Definition End *************************/

/************************* Variable Definition Begin ************************/

def var v_cdn_contador
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_inicial
    as Integer
    format ">>>9":U
    label "Inicial"
    column-label "Inicial"
    no-undo.
def var v_cdn_tip_forma_pagto
    as Integer
    format ">>9":U
    no-undo.
def var v_cod_agenc_bcia
    as character
    format "x(10)":U
    label "Agˆncia Banc ria"
    column-label "Agˆncia Banc ria"
    no-undo.
def var v_cod_agenc_bcia_fav
    as character
    format "x(10)":U
    label "Agˆncia Banc ria"
    column-label "Agˆncia Banc ria"
    no-undo.
def var v_cod_agenc_favorec_1
    as character
    format "x(8)":U
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def var v_cod_banco
    as character
    format "x(8)":U
    label "Banco"
    column-label "Banco"
    no-undo.
def var v_cod_barra
    as character
    format "x(44)":U
    label "C¢d. Barras"
    no-undo.
def var v_cod_barra_2
    as character
    format "99999.999999":U
    no-undo.
def var v_cod_campo_ctro
    as character
    format "999":U
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_cta_corren
    as character
    format "x(10)":U
    label "Conta Corrente"
    column-label "Conta Corrente"
    no-undo.
def var v_cod_cta_corren_fav
    as character
    format "x(10)":U
    label "Conta Corrente"
    column-label "Cta Corrente"
    no-undo.
def var v_cod_det
    as character
    format "x(308)":U
    no-undo.
def var v_cod_digito_agenc_bcia
    as character
    format "x(8)":U
    no-undo.
def var v_cod_digito_agenc_bcia_fav
    as character
    format "x(2)":U
    label "D¡gito Ag Bcia"
    column-label "Dig Ag"
    no-undo.
def var v_cod_digito_agenc_cta_corren
    as character
    format "x(2)":U
    label "D¡gito Agˆncia + Cta"
    column-label "D¡g Agˆncia + Cta"
    no-undo.
def var v_cod_digito_cta_corren
    as character
    format "x(2)":U
    label "D¡gito Cta Corrente"
    column-label "D¡gito Cta Corrente"
    no-undo.
def var v_cod_digito_cta_corren_fav
    as character
    format "x(2)":U
    label "D¡gito Cta Corrente"
    column-label "D¡gito Cta Corrente"
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu rio"
    column-label "Usu rio"
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
def var v_cod_forma
    as character
    format "x(3)":U
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
def var v_cod_ocor_bcia
    as character
    format "x(30)":U
    label "Ocorrˆncia Bcia"
    column-label "Ocorrˆncia Bcia"
    no-undo.
def var v_cod_pagto_ocor
    as character
    format "x(7)":U
    no-undo.
def var v_cod_pagto_remes
    as character
    format "x(6)":U
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa¡s Empresa Usu rio"
    column-label "Pa¡s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def var v_cod_sist_nac_bcio_fav
    as character
    format "x(8)":U
    label "C¢digo Sist Banc rio"
    column-label "C¢digo Sist Banc rio"
    no-undo.
def var v_cod_tip_reg_boleto
    as character
    format "x(1)":U
    initial "2"
    no-undo.
def var v_cod_tit_ap
    as character
    format "x(10)":U
    label "T¡tulo Ap"
    column-label "T¡tulo Ap"
    no-undo.
def var v_cod_tit_ap_bco
    as character
    format "x(20)":U
    label "T¡tulo  Banco"
    column-label "T¡tulo Banco"
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
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_cod_vencto
    as character
    format "x(8)":U
    no-undo.
def var v_ind_tip_instruc
    as character
    format "X(15)":U
    no-undo.
def var v_nom_empresa
    as character
    format "x(40)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def var v_nom_favorec
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_bco
    as integer
    format ">>>>,>>9":U
    no-undo.
def new global shared var v_num_cont
    as integer
    format ">,>>9":U
    initial 0
    no-undo.
def new global shared var v_num_contador
    as integer
    format ">>>>,>>9":U
    initial 0
    no-undo.
def new global shared var v_num_cont_val
    as integer
    format ">>>>,>>9":U
    initial 0
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_serv
    as integer
    format "99999":U
    initial 0
    label "C¢digo do Servi‡o"
    column-label "C¢digo do Servi‡o"
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_abat
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Abatimento"
    column-label "Valor Abatimento"
    no-undo.
def var v_val_acresc
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Acr‚scimo"
    column-label "Valor Acr‚scimo"
    no-undo.
def var v_val_correc
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Valor Corre‡Æo"
    column-label "Valor Corre‡Æo"
    no-undo.
def var v_val_desconto
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Desconto"
    column-label "Desconto"
    no-undo.
def var v_val_juros
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Juros"
    column-label "Valor Juros"
    no-undo.
def var v_val_multa
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Vl Multa"
    column-label "Vl Multa"
    no-undo.
def var v_val_pagto
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Valor Pagamento"
    column-label "Valor Pagamento"
    no-undo.
def var v_val_titulo
    as decimal
    format ">>>,>>>,>>9.99999":U
    decimals 5
    label "Valor"
    column-label "Valor"
    no-undo.
def var v_val_tot_desc_abat
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Descto/Abat"
    column-label "Descto/Abat"
    no-undo.


/************************** Variable Definition End *************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i fnc_banking_connect_05}


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
    run pi_version_extract ('fnc_banking_connect_05':U, 'prgint/edf/edf912za.py':U, '1.00.00.001':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

/* ----------------------------------------------------------------------------
   LNP - Layout Nexxera de Pagamento a fornecedores - Programa F«rmula EMS-5.05 
   ----------------------------------------------------------------------------*/


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


/* -------------- DETALHE ---------------*/
run pi_extracao_detalhe_edf912za.
/* --------------------------------------*/

return v_cod_det.


/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_retorna_cod_barra_leitora2
** Descricao.............: pi_retorna_cod_barra_leitora2
** Criado por............: tech14020
** Criado em.............: 03/04/2006 17:22:44
** Alterado por..........: tech14020
** Alterado em...........: 04/04/2006 13:58:10
*****************************************************************************/
PROCEDURE pi_retorna_cod_barra_leitora2:

        /* *********************** Parameter Definition Begin ************************/

        def Input param p_cod_barra_2
            as character
            format "99999.999999"
            no-undo.
        def output param p_cod_barra
            as character
            format "x(44)" /*l_x(44)*/ 
            no-undo.


        /* ************************ Parameter Definition End *************************/

        /* ************************ Variable Definition Begin ************************/

        def var v_num_tam_format
            as integer
            format ">>9":U
            no-undo.
        def var v_val_tit_barra
            as decimal
            format "->>,>>>,>>>,>>9.99":U
            decimals 2
            no-undo.


        /* ************************* Variable Definition End *************************/

        assign v_val_tit_barra = 0.

        &if defined(BF_FIN_ALTER_CODIGO_BARRA) &then
            assign v_num_tam_format = 14.
        &else
            find ems5.histor_exec_especial no-lock
                 where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
                   and histor_exec_especial.cod_prog_dtsul  = "SPP_alter_codigo_barra" /*l_spp_alter_codigo_barra*/ 
                 no-error.
            if   avail histor_exec_especial then
                 assign v_num_tam_format = 14.
            else assign v_num_tam_format = 12.
        &endif

        assign v_val_tit_barra = dec(substring(p_cod_barra_2, 38, 10))
               p_cod_barra = substring(p_cod_barra_2,01,03)
                           + substring(p_cod_barra_2, 04,01)
                           + substring(p_cod_barra_2, 33,01)
                           + substring(p_cod_barra_2, 34,04)
                           + string(v_val_tit_barra,"9999999999")
                           + substring(p_cod_barra_2, 05,05)
                           + substring(p_cod_barra_2, 11,10)
                           + substring(p_cod_barra_2, 22,10).
END PROCEDURE. /* pi_retorna_cod_barra_leitora2 */
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
** Procedure Interna.....: pi_extracao_detalhe_edf912za
** Descricao.............: pi_extracao_detalhe_edf912za
** Criado por............: fut41506
** Criado em.............: 26/12/2007 08:25:02
** Alterado por..........: fut31947
** Alterado em...........: 18/03/2008 15:47:07
*****************************************************************************/
PROCEDURE pi_extracao_detalhe_edf912za:

        /* ************************ Variable Definition Begin ************************/

        def var v_cod_bairro_favorec             as character       no-undo. /* local*/
        def var v_cod_cep_favorec                as character       no-undo. /* local*/
        def var v_cod_cidad_favorec              as character       no-undo. /* local*/
        def var v_cod_ender_favorec              as character       no-undo. /* local*/
        def var v_cod_estado_favorec             as character       no-undo. /* local*/
        def var v_cod_id_feder_favorec           as character       no-undo. /* local*/
        def var v_num_bloco                      as integer         no-undo. /* local*/
        def var v_num_reg_bloco                  as integer         no-undo. /* local*/
        def var v_num_tip_id_feder               as integer         no-undo. /* local*/
        def var v_num_tip_id_estabel             as integer         no-undo. /* criado por Jonas*/
        def var v_cod_id_feder_estabel           as character       no-undo. /* criado por Jonas*/
        def var v_cod_nome_estabel               as character       no-undo. /* criado por Jonas*/

        /* ************************* Variable Definition End *************************/

        if  p_cdn_segment_edi = 371
        then do: /* --- DETALHE ---*/
            /* ---- Codigo do Banco ----*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 4681 no-error. 
            assign v_cod_banco = string(tt_param_program_formul.ttv_des_contdo).

            /* --- Tipo de Pagamento ---*/
            find first tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3729 no-error.
            assign v_cdn_tip_forma_pagto = int(tt_param_program_formul.ttv_des_contdo).

            /* --- Agencia Bancaria Empresa ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 3901 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 4       
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 3).                
                else assign v_cdn_inicial = 1. 
            assign v_cod_agenc_bcia = substring(tt_param_program_formul.ttv_des_contdo, v_cdn_inicial,4).

            /* --- Digito Agencia Bancaria Empresa ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 3902 no-error.
            assign v_cod_digito_agenc_bcia = substring(tt_param_program_formul.ttv_des_contdo, 1,1).

            /* --- Conta Corrente Empresa ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 3903 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 9
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 8).
                else assign v_cdn_inicial = 1.
            assign v_cod_cta_corren = substring(tt_param_program_formul.ttv_des_contdo,v_cdn_inicial,9).

            /* --- Digito Conta Corrente Empresa ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 3904 no-error.
            assign v_cod_digito_cta_corren = substring(tt_param_program_formul.ttv_des_contdo,1,1).

            /* --- Digito Agencia/Conta Corrente ---*/
            /* find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3888 no-error.
            assign v_cod_digito_agenc_cta_corren = substring(tt_param_program_formul.ttv_des_contdo,1,1).*/

            /* --- Numero do Titulo ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3743 no-error.
            assign v_cod_tit_ap_bco = substring(tt_param_program_formul.ttv_des_contdo,1,20).

            /* --- Numero do Titulo ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3928 no-error.
            assign v_cdn_contador = 20 - length(substring(tt_param_program_formul.ttv_des_contdo,1,20)).

            assign v_cod_tit_ap = substring(tt_param_program_formul.ttv_des_contdo,1,20) + fill(' ',v_cdn_contador).

            /* --- Banco do Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3737 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 3
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 2).
                else assign v_cdn_inicial = 1.
            assign v_cod_sist_nac_bcio_fav = string(int(substring(tt_param_program_formul.ttv_des_contdo,v_cdn_inicial,3)),'999').

            /* --- Agencia do Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3922 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 4
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 3).
                else assign v_cdn_inicial = 1.
            assign v_cod_agenc_bcia_fav = substring(tt_param_program_formul.ttv_des_contdo,v_cdn_inicial,4).

            /* --- Digito Agencia Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 5143 no-error.
            assign v_cod_digito_agenc_bcia_fav = substring(tt_param_program_formul.ttv_des_contdo,1,1).

            /* --- Conta Corrente Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3796 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 10
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 9).
                else assign v_cdn_inicial = 1.
            assign v_cod_cta_corren_fav = substring(tt_param_program_formul.ttv_des_contdo,v_cdn_inicial,10).

            /* --- Digito Conta Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3927 no-error.
            assign v_cod_digito_cta_corren_fav = trim(tt_param_program_formul.ttv_des_contdo).

            if  v_cod_sist_nac_bcio_fav = "341" then
                assign v_cod_digito_agenc_cta_corren = v_cod_digito_cta_corren_fav 
                       v_cod_digito_cta_corren_fav = ''.

                    /* assign v_cod_cta_corren_fav = trim(v_cod_cta_corren_fav) + substring(tt_param_program_formul.ttv_des_contdo,1,1)
                       v_cod_digito_cta_corren_fav = substring(tt_param_program_formul.ttv_des_contdo,2,1).*/


            if length(v_cod_digito_cta_corren_fav) = 0 then
                assign v_cod_digito_cta_corren_fav = ' '.
            assign v_cdn_contador      = 0.

            /* --- Nome do Favorecido ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3734 no-error.
            assign v_cdn_contador = 35 - length(substring(tt_param_program_formul.ttv_des_contdo,1,35)).
            assign v_nom_favorec = substring(tt_param_program_formul.ttv_des_contdo,1,35) + fill(' ',v_cdn_contador).

            /* --- Data Pagamento ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3709 no-error.
            assign v_cod_pagto_remes = substring(tt_param_program_formul.ttv_des_contdo,1,2) + substring(tt_param_program_formul.ttv_des_contdo,3,2) + substring(tt_param_program_formul.ttv_des_contdo,5,4)
                   v_cod_pagto_ocor  = substring(tt_param_program_formul.ttv_des_contdo,1,2) + substring(tt_param_program_formul.ttv_des_contdo,3,2) + substring(tt_param_program_formul.ttv_des_contdo,5,4).

            /* --- Valor Pagamento ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4436 no-error.
            assign v_val_pagto = dec(tt_param_program_formul.ttv_des_contdo).

            /* --- Codigo do Servico da Empresa no Banco ---*/
            if v_cod_sist_nac_bcio_fav = '   ' then do: 
                find tt_param_program_formul
                    where tt_param_program_formul.tta_cdn_segment_edi = 288
                    and   tt_param_program_formul.tta_cdn_element_edi = 4641 no-error.
                assign v_num_serv = int(substring(tt_param_program_formul.ttv_des_contdo, 1,3)).
            end.
            else /* --- Outros Bancos ---*/ assign v_num_serv = 17.

            /* Nosso Numero do Banco Destinatario */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4022 no-error.
                if  v_cod_tit_ap_bco = "" then
                    assign v_cod_tit_ap_bco = substring(tt_param_program_formul.ttv_des_contdo, 1,20).            

            /* * Data de Vencimento do Titulo **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3606 no-error.
            assign v_cod_vencto = substring(tt_param_program_formul.ttv_des_contdo,1,2) + substring(tt_param_program_formul.ttv_des_contdo,3,2) + substring(tt_param_program_formul.ttv_des_contdo,5,4).

            /* * Valor do Titulo **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4421 no-error.
            assign v_val_titulo = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).

            /* * Valor de Abatimentos **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4425 no-error.
            assign v_val_abat = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).

            /* * Valor de Descontos **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4423 no-error.
            assign v_val_desconto = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).
            assign v_val_tot_desc_abat = v_val_abat + v_val_desconto.

            /* * Juros **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4422 no-error.
            assign v_val_juros = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).

            /* * Multa **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4426 no-error.
            assign v_val_multa = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).

            /* * Correcao Monetaria **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 4437 no-error.
            assign v_val_correc = int(substring(tt_param_program_formul.ttv_des_contdo, 1,17)).
            assign v_val_acresc = v_val_juros + v_val_multa + v_val_correc.

            assign v_cdn_contador = 0.
            /* * Codigo de Barras **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 2807 no-error.
            assign v_cdn_contador = 47 - length(substring(tt_param_program_formul.ttv_des_contdo,1,47)).
            assign v_cod_barra_2 = substring(tt_param_program_formul.ttv_des_contdo,1,47) + fill(' ',v_cdn_contador).
            run pi_retorna_cod_barra_leitora2 (input v_cod_barra_2, output v_cod_barra).

            /* * C½digo Movimento **/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3933 no-error.
            assign v_cod_ocor_bcia = substring(tt_param_program_formul.ttv_des_contdo, 1,2).

            /* --- Agencia Codigo do Cedente ---*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3922 no-error.
            if length(tt_param_program_formul.ttv_des_contdo) > 20
                then assign v_cdn_inicial = (length(tt_param_program_formul.ttv_des_contdo) - 19).
                else assign v_cdn_inicial = 1.
            assign v_cod_agenc_favorec_1 = substring(tt_param_program_formul.ttv_des_contdo,v_cdn_inicial,20).

            /* tipo CGC/CPF Estabelecimento - criado por Jonas 
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 3710 no-error.
            assign v_num_tip_id_estabel = if avail tt_param_program_formul then int(tt_param_program_formul.ttv_des_contdo) else 0.

            /* CGC/CPF favorecido - criado por Jonas*/
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 4643 no-error.
            assign v_cod_id_feder_estabel = if avail tt_param_program_formul then tt_param_program_formul.ttv_des_contdo else "".

            /* Nome Estabelecimento - criado por Jonas */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 288
                and   tt_param_program_formul.tta_cdn_element_edi = 16 no-error.
            assign v_cod_nome_estabel = if avail tt_param_program_formul then tt_param_program_formul.ttv_des_contdo else "".
            */

            v_num_tip_id_estabel = 2.
            for each item_bord_ap no-lock where 
                item_bord_ap.cod_estab_bord = entry(1,V_COD_TIT_AP,";") and
                item_bord_ap.num_id_item_bord_ap = INT64(entry(2,V_COD_TIT_AP,";")):
                for first tit_ap no-lock of item_bord_ap:
                   
                    /*for first pessoa_jurid no-lock where 
                        pessoa_jurid.num_pessoa_jurid = tit_ap.num_pessoa:
                        
                        v_cod_id_feder_estabel = pessoa_jurid.cod_id_feder.
                        v_cod_nome_estabel = pessoa_jurid.nom_pessoa.*/
            
                      for first estabelecimento no-lock
                          where estabelecimento.cod_estab = tit_ap.cod_estab:
                        
                          v_cod_id_feder_estabel = estabelecimento.cod_id_feder.
                          v_cod_nome_estabel = estabelecimento.nom_pessoa.
                        
                    end.
            
                end.
            end.


            /* tipo CGC/CPF Favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3915 no-error.
            assign v_num_tip_id_feder = int(tt_param_program_formul.ttv_des_contdo).

            /* CGC/CPF favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3916 no-error.
            assign v_cod_id_feder_favorec = tt_param_program_formul.ttv_des_contdo.

            /* Endereco Favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3917 no-error.
            assign v_cod_ender_favorec = tt_param_program_formul.ttv_des_contdo.

            /* Bairro favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3621 no-error.
            assign v_cod_bairro_favorec = tt_param_program_formul.ttv_des_contdo.

            /* Cidade Favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3918 no-error.
            assign v_cod_cidad_favorec = tt_param_program_formul.ttv_des_contdo.

            /* Cep Favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3920 no-error.
            assign v_cod_cep_favorec = tt_param_program_formul.ttv_des_contdo.

            /* Estado Favorecido */
            find tt_param_program_formul
                where tt_param_program_formul.tta_cdn_segment_edi = 289
                and   tt_param_program_formul.tta_cdn_element_edi = 3919 no-error.
            assign v_cod_estado_favorec = tt_param_program_formul.ttv_des_contdo.

           /* Tratamento Tipo de Pagamento*/
                if v_cdn_tip_forma_pagto    = 2 then /* DOC */    
                    assign v_cod_forma      = '03'
                           v_cod_campo_ctro = '700'.

                if v_cdn_tip_forma_pagto    = 3 then /* Credito Conta Corrente */
                    assign v_cod_forma      = '01'
                           v_cod_campo_ctro = '000'.

                if v_cdn_tip_forma_pagto    = 4 then /* Cheque Administrativo  */
                    assign v_cod_forma      = '02'
                           v_cod_campo_ctro = '000'.

                if v_cdn_tip_forma_pagto    = 7 then /* TED CIP  */
                    assign v_cod_forma      = '41'
                           v_cod_campo_ctro = '018'.

                if v_cdn_tip_forma_pagto    = 8 then /* TED STR  */
                    assign v_cod_forma      = '43'
                           v_cod_campo_ctro = '018'.

            if  v_cdn_tip_forma_pagto = 1 or  v_cdn_tip_forma_pagto = 5
            then do:
                if GetEntryField(4, v_cod_tit_ap, ';') = "" then 
                   assign v_cod_tip_reg_boleto = '2'.
                else assign v_cod_tip_reg_boleto = '8'.
            end /* if */.

            /* --- DOC / CREDITO CONTA CORRENTE / CHEQUE ADMINISTRATIVO ---*/    
            if  v_cdn_tip_forma_pagto = 2 or  v_cdn_tip_forma_pagto = 3 or  v_cdn_tip_forma_pagto = 4
            or  v_cdn_tip_forma_pagto = 7 or  v_cdn_tip_forma_pagto = 8
            then do:        
                if v_cod_sist_nac_bcio_fav = "341"
                then do :

                    assign v_cod_det = caps('A' + 
                                            '0' + 
                                            string(v_cod_ocor_bcia,'99') + 
                                            string(v_cod_campo_ctro,'999') + 
                                            string(int(v_cod_sist_nac_bcio_fav),'999') +
                                            string(int(v_cod_agenc_bcia_fav),'99999') + 
                                            string(substring(v_cod_digito_agenc_bcia_fav,1,1),'x') +
                                            string(dec(v_cod_cta_corren_fav),'999999999999') + 
                                            string(substring(v_cod_digito_cta_corren_fav,1,1),'x') +
                                            string(substring(v_cod_digito_agenc_cta_corren,1,1),'x') + 
                                            string(v_nom_favorec,'x(30)') + 
                                            string(v_cod_tit_ap,'x(20)') +
                                            string(v_cod_pagto_ocor,'x(8)') + 
                                            'BRL' + 
                                            fill('0',15) + 
                                            string(v_val_pagto,'999999999999999') + 
                                            fill(' ',20) +
                                            fill('0',23) + 
                                            fill(' ',52) + 
                                            fill('0',1) + 
                                            fill(' ',10)).     
                end. 
                else do:
                    assign v_cod_det = caps('A' + 
                                            '0' + 
                                            string(v_cod_ocor_bcia,'99') + 
                                            string(v_cod_campo_ctro,'999') + 
                                            string(int(v_cod_sist_nac_bcio_fav),'999') +
                                            string(int(v_cod_agenc_bcia_fav),'99999') + 
                                            string(substring(v_cod_digito_agenc_bcia_fav,1,1),'x') +
                                            string(dec(v_cod_cta_corren_fav),'999999999999') + 
                                            string(substring(v_cod_digito_cta_corren_fav,1,2),'xx') +
                                            string(v_nom_favorec,'x(30)') + 
                                            string(v_cod_tit_ap,'x(20)') +
                                            string(v_cod_pagto_ocor,'x(8)') + 
                                            'BRL' + 
                                            fill('0',15) + 
                                            string(v_val_pagto,'999999999999999') + 
                                            fill(' ',20) +
                                            fill('0',23) + 
                                            fill(' ',52) + 
                                            fill('0',1) + 
                                            fill(' ',10)).

                end.
                /* gera segunda parte - procura sequencia do registro */ 
                find first tt_segment_tot
                     where tt_segment_tot.tta_cdn_segment_edi = 371 no-error.

                if avail tt_segment_tot
                then do:
                    assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                            tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1
                            v_num_reg_bloco                    = tt_segment_tot.ttv_qtd_bloco_docto.
                end.
                /* Atualiza somatoria dos blocos*/
                find first tt_segment_tot
                     where tt_segment_tot.tta_cdn_segment_edi = 999999 no-error.

                if avail tt_segment_tot
                then do:
                    assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                            tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1.
                end.

                /* localiza o bloco */
                find first tt_param_program_formul
                     where tt_param_program_formul.tta_cdn_segment_edi = 0
                       and tt_param_program_formul.tta_cdn_element_edi = 2
                       and tt_param_program_formul.tta_des_label_utiliz_formul_edi = "QTD BLOCOS" /*l_qtd_blocos*/  no-error.
                 if avail tt_param_program_formul then
                     assign v_num_bloco = int(tt_param_program_formul.ttv_des_contdo) + 1.

                assign  v_cod_det = caps(v_cod_det + 
                                         chr(10) +  
                                         string(v_cod_banco,'999') + 
                                         string(v_num_bloco,'9999') + 
                                         '3' + 
                                         string(v_num_reg_bloco,'99999') + 
                                         'B' + 
                                         fill(' ',3) + 
                                         string(v_num_tip_id_feder,'9') + 
                                         string(dec(v_cod_id_feder_favorec),'99999999999999') + 
                                         string(v_cod_ender_favorec,'x(30)') +
                                         '00000' + 
                                         fill(' ',15) + 
                                         string(v_cod_bairro_favorec,'x(15)') + 
                                         string(v_cod_cidad_favorec,'x(20)') + 
                                         string(v_cod_cep_favorec,'x(8)') + 
                                         string(v_cod_estado_favorec,'x(2)') + 
                                         v_cod_vencto + 
                                         string(v_val_titulo,'999999999999999') +
                                         string(v_val_abat,'999999999999999') + 
                                         string(v_val_desconto,'999999999999999') + 
                                         string(v_val_juros,'999999999999999') + 
                                         string(v_val_multa,'999999999999999') + 
                                         fill(' ',15) + 
                                         fill(' ',3) +
                                         fill(' ',2) +
                                         fill(' ',10) +
                                         chr(10)).

                assign v_num_cont = v_num_cont + 1.
            end /* if */.

            /* --- BOLETO ---*/
            if  v_cdn_tip_forma_pagto = 1 or  v_cdn_tip_forma_pagto = 5
            then do:
                assign v_num_contador  = v_num_contador + 1
                       v_num_cont_val  = v_val_pagto + v_num_cont_val.

                /* localiza a instrucao de cobranca para saber se² implantacao/alteracao ou estorno */
                find first ocor_bcia_bco no-lock
                    where ocor_bcia_bco.cod_banco               = v_cod_banco
                    and   ocor_bcia_bco.cod_modul_dtsul         = "APB" /*l_apb*/  
                    and   ocor_bcia_bco.ind_ocor_bcia_remes_ret = "Remessa" /*l_remessa*/  
                    and   ocor_bcia_bco.cod_ocor_bcia_bco       = v_cod_ocor_bcia no-error.
                if avail ocor_bcia_bco then do:
                    if ocor_bcia_bco.ind_tip_ocor_bcia = "Implanta‡Æo" /*l_implantacao*/   then
                        assign v_ind_tip_instruc = '0'. /* implantacao */
                    else
                        if ocor_bcia_bco.ind_tip_ocor_bcia begins "Altera‡Æo" /*l_alteracao*/ 
                        or ocor_bcia_bco.ind_tip_ocor_bcia begins "Acerto" /*l_acerto*/   then
                            assign v_ind_tip_instruc = '5'. /* alteracao */
                        else
                            assign v_ind_tip_instruc = '9'. /* estorno */
                end.
                else
                    assign v_ind_tip_instruc = '0'. /* sempre serÿ implantacao */

                assign v_cod_det = caps('J' + 
                                        string(v_ind_tip_instruc,"x(01)" /*l_x(01)*/ ) + 
                                        string(v_cod_ocor_bcia,"x(02)" /*l_x(02)*/ ) + 
                                        string(v_cod_barra,"x(44)" /*l_x(44)*/ ) +
                                        string(v_nom_favorec,"x(30)" /*l_x(30)*/ ) + 
                                        v_cod_vencto + 
                                        string(v_val_titulo,'999999999999999') + 
                                        string(v_val_tot_desc_abat,'999999999999999') +
                                        string(v_val_acresc,'999999999999999') + 
                                        v_cod_pagto_remes + 
                                        string(v_val_pagto,'999999999999999') +
                                        fill('0',15) + 
                                        string(v_cod_tit_ap,"x(20)" /*l_x20*/ ) + 
                                        string(v_cod_tit_ap_bco,"x(20)" /*l_x20*/ ) + 
                                        '09' +
                                        fill(' ',6) + 
                                        fill(' ',10)) + 
                                        chr(10).

                if v_cod_banco = "399" /* HSBC */ 
                or v_cod_banco = "237" /* Bradesco */ then do:
                    assign  v_cod_det = caps(v_cod_det + 
                                             chr(10) +  
                                             string(v_cod_banco,'999') + 
                                             string(v_num_bloco,'9999') + 
                                             '3' + 
                                             string(v_num_reg_bloco,'99999') + 
                                             'K' + 
                                             fill(' ',3) + 
                                             string(v_num_tip_id_feder,'9') + 
                                             string(dec(v_cod_id_feder_favorec),'99999999999999') + 
                                             string(v_cod_ender_favorec,'x(30)') +
                                             '00000' + 
                                             fill(' ',15) + 
                                             string(v_cod_bairro_favorec,'x(15)') + 
                                             string(v_cod_cidad_favorec,'x(20)') + 
                                             string(v_cod_cep_favorec,'x(8)') + 
                                             string(v_cod_estado_favorec,'x(2)') +
                                             fill(' ',83) + 
                                             fill(' ',15) +
                                             fill(' ',3) +
                                             fill(' ',2) +
                                             fill(' ',10) +
                                             chr(10)).
                end. 

                /* gera segunda parte J52 - procura sequencia do registro */ 
                find first tt_segment_tot
                     where tt_segment_tot.tta_cdn_segment_edi = 371 no-error.

                if avail tt_segment_tot
                then do:
                    assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                            tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1
                            v_num_reg_bloco                    = tt_segment_tot.ttv_qtd_bloco_docto.
                end.
                /* Atualiza somatoria dos blocos*/
                find first tt_segment_tot
                     where tt_segment_tot.tta_cdn_segment_edi = 999999 no-error.

                if avail tt_segment_tot
                then do:
                    assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                            tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1.
                end.

                /* localiza o bloco */
                find first tt_param_program_formul
                     where tt_param_program_formul.tta_cdn_segment_edi = 0
                       and tt_param_program_formul.tta_cdn_element_edi = 2
                       and tt_param_program_formul.tta_des_label_utiliz_formul_edi = "QTD BLOCOS" /*l_qtd_blocos*/  no-error.
                 if avail tt_param_program_formul then
                     assign v_num_bloco = int(tt_param_program_formul.ttv_des_contdo) + 1.

                     assign  v_cod_det = caps(v_cod_det + 
                                              chr(10) +  
                                              string(v_cod_banco,'999') + 
                                              string(v_num_bloco,'9999') + 
                                              '3' + 
                                              string(v_num_reg_bloco,'99999') + 
                                              'J' + 
                                              fill(' ',1) + 
                                              string(v_cod_ocor_bcia,'x(02)') +
                                              '52' +
                                              string(v_num_tip_id_estabel,'9') +
                                              string(dec(v_cod_id_feder_estabel),'999999999999999') +
                                              string(v_cod_nome_estabel,'x(40)')  +
                                              string(v_num_tip_id_feder,'9') + 
                                              string(dec(v_cod_id_feder_favorec),'999999999999999') + 
                                              string(v_nom_favorec,'x(40)')  +
                                              string(v_num_tip_id_feder,'9') + 
                                              string(dec(v_cod_id_feder_favorec),'999999999999999') + 
                                              string(v_nom_favorec,'x(40)')   +
                                              fill(' ',53) +
                                              chr(10)).

                assign v_num_cont = v_num_cont + 1.

            end /* if */.
        end /* if */.
END PROCEDURE. /* pi_extracao_detalhe_edf912za */


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
        message getStrTrans("Mensagem nr. ", "EDF") i_msg "!!!":U skip
                getStrTrans("Programa Mensagem", "EDF") c_prg_msg getStrTrans("nÆo encontrado.", "EDF")
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/**********************  End of fnc_banking_connect_05 **********************/
