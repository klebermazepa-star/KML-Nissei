/****************************************************************************************************
**
** 26/12/2024 - Everton
** alterado para atualizar o campo tt_titulo_antecip_pef_a_pagar qdo estiver em branco buscando do fornec_financ.cod_forma_pagto
**
** 06/01/2025 - Everton                
** alterado para colocar entre coment†rios os comandos para testes locais
**
** 15/01/2025 - Everton
** alterado o tratamento que verifica se o fornecedor possui antecipaá‰es 
** para atualizar corretamente o campo tt_titulos_bord.log_possui_antecip_forn
**
** 22/01/2025 - Everton
** alÇm do parÉmetro que indicava se o fornecedor do t°tulo tinha antecipaá‰es, foi criado um
** parÉmetro para indicar se o grupo matriz/filial do fornecedor do t°tulo possui alguma antecipaá∆o
** temos clientes com regras diferentes para o tratamento da antecipaá∆o por esse motivo ser† 
** necess†rio adicionar parÉmetros no grid de parÉmetros
** mas por enquanto a API est† atualizando somente o campo de antecipaá∆o do fornecedor
**
** sobre os clientes:
** CMNP = precisa do controle de antecipaá‰es por fornecedor e por matriz/filial
** MRN = n∆o possui tratamento para antecipa‰es
**
****************************************************************************************************/

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
// ATENÄ«O
// ATUALIZAR A VERS«O NO INCLUDE robotapi004.i
// - roboteasy\robotapi004.p
// - roboteasy\api\v1\restapiborderoap.p
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------

{esp/roboteasy/robotapi004.i "robotapi004.p"}

{esp/roboteasy/robot_db.i}

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/i_fcldef.i}

{include/i-license-manager.i robotapi004 roboteasy}

//----------------------------------------------------------------------------------------------------

// everton revisar
def var v_ind_favorec_cheq as char no-undo.
def var v_nom_favorec_cheq as char no-undo.
def var v_log_atualiz_hora_liber as logical no-undo.
def var v_log_pagto_ant_outras_moed as logical no-undo.
def var v_val_cotac_indic_econ as decimal no-undo.

def buffer b_tit_ap_bxa
    for tit_ap.

&if "{&emsfin_version}" >= "5.01" &then
def buffer b_bord_ap_add
    for bord_ap.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_bord_ap_copy
    for bord_ap.
&endif
&if "{&emsfin_version}" >= "5.01" &then
def buffer b_msg_financ
    for msg_financ.
&endif

DEF BUFFER b_portad_finalid_econ 
    FOR portad_finalid_econ.

DEF BUFFER b_movto_tit_ap 
    FOR movto_tit_ap.

DEF BUFFER b_movto_tit_ap_aux
    FOR movto_tit_ap.

def buffer b_tit_ap
    for tit_ap.

def buffer b_item_lote_pagto
    for item_lote_pagto.

DEF BUFFER b_bord_ap 
    FOR bord_ap.

def buffer b_item_bord_ap
    for item_bord_ap.

def buffer b_compl_movto_pagto
        for compl_movto_pagto.

DEF BUFFER b_cta_corren
    FOR cta_corren.

DEF BUFFER b_indic_econ
    FOR indic_econ.

DEF BUFFER b_tit_ap_impto
    FOR tit_ap.
/*************************** Buffer Definition End **************************/

/************************* Variable Definition Begin ************************/
def NEW shared temp-table tt_proces_pagto_ant no-undo like proces_pagto
    field ttv_rec_proces_pagto             as recid format ">>>>>>9" initial ?
    .

DEF TEMP-TABLE tt_lista_fornec NO-UNDO
    FIELD cdn_fornecedor LIKE fornecedor.cdn_fornecedor
    INDEX idx1 cdn_fornecedor.

def new shared temp-table tt_converter_finalid_econ no-undo
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cotaá∆o" column-label "Data Cotaá∆o"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
    field tta_val_cotac_tax_juros          as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Taxa Juros" column-label "Cotac Taxa Juros"
    field tta_val_prev_cotac_fasb          as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Previs Fasb" column-label "Cotac Previs Fasb"
    field tta_val_cotac_cm_emis            as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Cm Emiss" column-label "Cotac Cm Emiss"
    field tta_val_cotac_cm_vencto          as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Cm Vencto" column-label "Cotac Cm Vencto"
    field tta_val_cotac_cm_pagto           as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotac Cm Pagto" column-label "Cotac CM Pagto"
    field tta_val_transacao                as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Transaá∆o" column-label "Transaá∆o"
    field tta_val_variac_cambial           as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Varic Cambial" column-label "Variac Cambial"
    field tta_val_acerto_cmcac             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Acerto CMCAC" column-label "Vl Acerto CMCAC"
    field tta_val_fatorf                   as decimal format "->999.9999999999" decimals 10 initial 0 label "Fator F" column-label "Fator F"
    field tta_val_fatorx                   as decimal format "->999.9999999999" decimals 10 initial 0 label "Fator X" column-label "Fator X"
    field tta_val_fatory                   as decimal format "->999.9999999999" decimals 10 initial 0 label "Fator Y" column-label "Fator Y"
    field tta_val_ganho_perda_cm           as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "G/P CM" column-label "G/P CM"
    field tta_val_ganho_perda_projec       as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "G/P Projeá∆o" column-label "G/P Projeá∆o"
    field tta_ind_forma_conver             as character format "X(10)" initial "Direta" label "Forma Convers∆o" column-label "Forma Convers∆o"
    field ttv_val_multa                    as decimal format "->>>,>>>,>>9.99" decimals 2 label "Vl Multa" column-label "Vl Multa"
    field ttv_val_desc                     as decimal format "->>>,>>>,>>9.99" decimals 2 label "Vl Desc" column-label "Vl Desc"
    field ttv_val_juros                    as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Juros" column-label "Valor Juros"
    field ttv_val_abat                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatimento" column-label "Valor Abatimento"
    field ttv_val_cm                       as decimal format "->>>>>,>>>,>>9.99" decimals 4 initial 0 label "Correá∆o Monet†ria" column-label "Correá∆o Monet†ria"
    field tta_val_despes_bcia              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    .

/* def temp-table tt_item_bord_ap_an no-undo                                                                                                              */
/*     field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequ?ncia" column-label "Seq"                                     */
/*     field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"                                     */
/*     field tta_cod_espec_docto              as character format "x(3)" label "Esp?cie Documento" column-label "Esp?cie"                                 */
/*     field tta_cod_ser_docto                as character format "x(5)" label "S?rie Documento" column-label "S?rie"                                     */
/*     field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"                      */
/*     field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"                            */
/*     field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"                                            */
/*     field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"                                             */
/*     field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"                  */
/*     field tta_val_pagto                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagamento" column-label "Valor Pagto" */
/*     INDEX idx1 tta_cdn_fornecedor.                                                                                                                     */

DEF TEMP-TABLE tt_antecip_fornec_emp NO-UNDO
    FIELD cdn_fornecedor    LIKE tit_ap.cdn_fornecedor
    FIELD cod_empresa       LIKE tit_ap.cod_empresa
    FIELD tipo_fornec       AS   CHAR.

def new shared temp-table tt_item_bord_lote_mensagem no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer_antecip_pef        as character format "x(10)" label "Ref Antec PEF Pend" column-label "Ref Antec PEF Pend"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(5)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_val_pagto                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagamento" column-label "Valor Pagto"
    .

def temp-table tt_integr_apb_item_bord_aux no-undo
    field tta_cod_estab_bord               as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "N£mero Borderì" COLUMN-LABEL "Borderì"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_rec_item_bord_ap             as recid format ">>>>>>9"
    field tta_dat_pagto                    as date format "99/99/9999" initial today label "Data Pagamento" column-label "Data Pagto"
    index tt_id                            is unique
          ttv_rec_item_bord_ap             ascending
    index tt_id_item_bord_ap               is primary unique
          tta_cod_estab_bord               ascending
          tta_cod_portador                 ascending
          tta_num_bord_ap                  ascending
          tta_num_seq_bord                 ascending
    .

def temp-table tt_item_bord_ap no-undo like item_bord_ap
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field ttv_rec_item_bord_ap             as recid format ">>>>>>9"
    field tta_num_id_movto_tit_ap_ult      as integer format ">>>>,>>9" initial 0 label "Çltimo Movimento" column-label "Çltimo Movimento"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    index tt_cheque_bordero                is primary
          cod_estab_bord                   ascending
          cod_portador                     ascending
          num_bord_ap                      ascending
          num_id_cheq_ap                   ascending
          cod_estab_cheq                   ascending
    index tt_id                            is unique
          ttv_rec_item_bord_ap             ascending
    index tt_id_item_bord                 
          cod_estab_bord                   ascending
          cod_portador                     ascending
          num_bord_ap                      ascending
          num_seq_bord                     ascending
    .

def temp-table tt_titulos_msg_alerta no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(5)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_refer_antecip_pef        as character format "x(10)" label "Ref Antec PEF Pend" column-label "Ref Antec PEF Pend"
    field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    .

def new shared temp-table tt_integr_apb_item_bord no-undo
    field ttv_rec_item_bord_ap             as recid format ">>>>>>9"
    field tta_dat_pagto                    as date format "99/99/9999" initial today label "Data Pagamento" column-label "Data Pagto"
    .


def new shared temp-table tt_erros_api_enviar_msg_pagto no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "Número BorderÀ" column-label "BorderÀ"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequºncia" column-label "Seq"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaªío" column-label "Dat Transac"
    field ttv_num_msg_erro                 as integer format ">>>>>>9" label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistºncia"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    .

def new shared temp-table tt_log_erros_tit_antecip no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(5)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_talon_cheq               as integer format ">>>,>>>,>>9" initial 0 label "Talon†rio Cheques" column-label "Talon†rio Cheques"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "N£m Cheque" column-label "Num Cheque"
    field ttv_log_atlzdo                   as logical format "Sim/N∆o" initial yes label "Atualizado" column-label "Atualizado"
    field tta_nom_favorec_cheq             as character format "x(40)" label "Nome Favorecido" column-label "Nome Favorecido"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Data Emiss∆o" column-label "Dt Emiss"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_estab_refer              as character format "x(5)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_des_msg_erro_1               as character format "x(80)" label "Mensagem de Erro" column-label "Mensagem de Erro"
    field ttv_cod_bord_ap                  as character format "x(6)" label "BorderÀ" column-label "BorderÀ"
    field ttv_cod_seq_cheq                 as character format "x(2)" label "Sequància" column-label "Sequància"
    .


def temp-table tt_impostos_abat no-undo
    field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    .

define temp-table tt_epc no-undo
    field cod_event        as character
    field cod_parameter    as character
    field val_parameter    as character
    index id is primary cod_parameter cod_event ascending.

def temp-table tt_log_erros no-undo
    field ttv_num_seq                      as integer format ">>>,>>9" label "SeqÅància" column-label "Seq"
    field ttv_num_cod_erro                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_erro                     as character format "x(50)" label "Inconsistància" column-label "Inconsistància"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    index tt_id                           
          ttv_num_seq                      ascending
          ttv_num_cod_erro                 ascending
    .

def temp-table tt_itens_sem_desemb no-undo
    field tta_cod_estab_bord               as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "N£mero Borderì" column-label "Borderì"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    .

def temp-table tt_dados_tit_ap_pagto no-undo
    field tta_cod_estab_tit_ap             as character format "x(5)" label "Estabel APB" column-label "Estabel APB"
    field tta_num_id_tit_ap                as integer format "999999999" initial 0 label "Token T°t AP" column-label "Token T°t AP"
    field tta_cod_estab_refer              as character format "x(5)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "N£mero Borderì" column-label "Borderì"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_pagto                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagamento" column-label "Valor Pagto"
    .

def temp-table tt_titulo_dados_bcia_pgto_bord no-undo
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field ttv_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field ttv_cod_agenc_bcia_digito        as character format "x(13)" label "Agància" column-label "Agància"
    field ttv_cod_cta_corren_bco_digito    as character format "x(23)" label "Conta Corrente" column-label "Conta Corrente"
    index tt_rec_tit_ap                    is primary unique
          ttv_rec_tit_ap                   ascending
    .

def new shared temp-table tt_erros_inform_bcia_fornec         like fornec_financ
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_digito_agenc_bcia        as character format "x(2)" label "D°gito Ag Bcia" column-label "Dig Ag"
    field tta_ind_tip_forma_pagto          as character format "X(22)" label "Tipo Forma Pagto" column-label "Tipo Forma Pagto"
    field ttv_log_pagto_agrup              as logical format "Sim/N∆o" initial no label "Forma Pagto Agrup"
    .

def new shared var v_log_atualiza_dat_pagto
    as logical
    format "Sim/NU"
    initial yes
    view-as toggle-box
    no-undo.

def new shared temp-table tt_pagamentos_realizados no-undo
    field ttv_rec_item_lote_pagto          as recid format ">>>>>>9"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    index tt_recid_tit_ap                 
          ttv_rec_tit_ap                   ascending
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

def new shared temp-table tt_param_api_enviar_msg_pagto no-undo
    field tta_ind_dwb_set_type             as character format "X(09)" initial "Regra" label "Tipo Conjunto" column-label "Tipo Conjunto"
    field ttv_ind_pagto_ocor_bord_ap       as character format "x(10)"
    field ttv_ind_sel_indual_conjto        as character format "X(08)"
    field ttv_cod_estab_ini                as character format "x(3)" label "Estabelecimento" column-label "Estab Inicial"
    field ttv_cod_estab_fim                as character format "x(3)" label "atÇ" column-label "Estab Final"
    field ttv_cod_portador_ini             as character format "x(5)" label "Portador" column-label "Portador Inicial"
    field ttv_cod_portador_fim             as character format "x(5)" label "atÇ" column-label "Portador Final"
    field ttv_num_bord_ap_ini              as integer format ">>>>>9" initial 0 label "Borderì" COLUMN-LABEL "Bord Inicial"
    field ttv_num_bord_ap_fim              as integer format ">>>>>9" initial 0 label "atÇ" column-label "Bord Final"
    field ttv_dat_transacao_ini            as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Data Transaá∆o"
    field ttv_dat_transacao_fim            as date format "99/99/9999" initial today label "Final" column-label "Final"
    field ttv_cod_indic_econ_fim           as character format "x(8)" label "atÇ" column-label "Final"
    field ttv_cod_indic_econ_ini           as character format "x(8)" label "Moeda" column-label "Inicial"
    field tta_num_dwb_order                as integer format ">>>>,>>9" initial 0 label "Ordem" column-label "Ordem"
    index tt_id                            is primary
          tta_ind_dwb_set_type             ascending
          ttv_ind_pagto_ocor_bord_ap       ascending
          tta_num_dwb_order                ascending
    .


def NEW shared temp-table tt_item_bord_ap_situacao_envio no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "Número BorderÀ" column-label "BorderÀ"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequºncia" column-label "Seq"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp≤cie Documento" column-label "Esp≤cie"
    field tta_cod_ser_docto                as character format "x(5)" label "S≤rie Documento" column-label "S≤rie"
    field tta_cod_tit_ap                   as character format "x(16)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parcela"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_val_pagto                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagamento" column-label "Valor Pagto"
    field tta_cod_docto_bco_pagto          as character format "x(20)" label "Tit Bco Pagto" column-label "Tit Bco Pagto"
    field tta_des_id_reg_bloco_modul_edi   as character format "x(60)" label "Id Registro Bloco" column-label "Id Registro Bloco"
    field ttv_log_situacao                 as logical format "Sim/Nío" initial yes label "Curso Ativo" column-label "Curso Ativo"
    field ttv_num_erro_msg                 as integer format ">,>>>,>>9" label "Número do Erro" column-label "Número do Erro"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field tta_cdn_proces_edi               as Integer format ">>>>>>>9" initial 0 label "Processo" column-label "Processo"
    field tta_num_prox_remes_msg_edi       as integer format ">>>>>>>>9" initial 0 label "PrΩxima Remessa" column-label "PrΩxima Remessa"
    field ttv_cod_arq_edi                  as character format "x(80)" label "Nome arquivo" column-label "Nome arquivo"
    field tta_ind_tip_ocor_bcia            as character format "x(40)" label "Tipo Ocor Bancia" column-label "Tipo Ocor Bancia"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agºncia Bancˇria" column-label "Agºncia Bancˇria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_val_juros                    as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_abat                     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatimento" column-label "Valor Abatimento"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_val_multa                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Multa" column-label "Valor Multa"
    field ttv_val_liquidacao               as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor Liquidaªío"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    index tt_envio                        
          ttv_log_situacao                 ascending
    index tt_item                         
          tta_cod_estab                    ascending
          tta_cod_portador                 ascending
          tta_num_bord_ap                  ascending
          tta_num_seq_bord                 ascending
    .


def temp-table tt_cheq_adm_cancel no-undo like cheq_ap
&if "{&emsfin_version}" >= "5.01" &then
    use-index cheqap_id                    as primary
&endif
&if "{&emsfin_version}" >= "5.01" &then
    use-index cheqap_token                
&endif
    .

def temp-table tt_histor_finalid no-undo
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_inic_valid               as date format "99/99/9999" initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF label "In°cio Validade" column-label "Inic Validade"
    field tta_dat_fim_valid                as date format "99/99/9999" initial 12/31/9999 label "Fim Validade" column-label "Fim Validade"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    index tt_finalid                      
          tta_cod_finalid_econ             ascending
          tta_dat_inic_valid               ascending
    index tt_indic                         is primary
          tta_cod_indic_econ               ascending
          tta_dat_inic_valid               ascending
    .


def temp-table tt_item_bord_ap_favorec no-undo
    field tta_cod_estab_bord               as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_num_bord_ap                  as integer format ">>>>>9" initial 0 label "N£mero BorderÀ" column-label "BorderÀ"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_ind_favorec_cheq             as character format "X(15)" initial "Portador" label "Favorec" column-label "Favorec"
    field ttv_nom_favorec_cheq             as character format "x(40)" label "Favorecido" column-label "Nome Favorecido"
    field tta_cod_forma_pagto_altern       as character format "x(3)" label "Forma Pagamento" column-label "F Pagto Alt"
    field tta_dat_vencto                   as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_pagto                    as date format "99/99/9999" initial today label "Data Pagamento" column-label "Data Pagto"
    field tta_cod_bco_pagto                as character format "x(8)" label "Banco Pagamento" column-label "Banco Pagamento"
    field tta_cod_agenc_bcia_pagto         as character format "x(10)" label "Agencia Bcia Pagto" column-label "Agencia Bcia Pagto"
    field tta_cod_cta_corren_bco_pagto     as character format "x(20)" label "Cta Corren Bco Pagto" column-label "Cta Corren Bco Pagto"
    index tt_agrup                        
          tta_cod_forma_pagto_altern       ascending
          ttv_nom_favorec_cheq             ascending
          tta_dat_pagto                    ascending
    index tt_favorecido                   
          tta_cod_forma_pagto_altern       ascending
          ttv_nom_favorec_cheq             ascending
          tta_dat_vencto                   ascending
    index tt_sequencia                     is primary unique
          tta_cod_estab_bord               ascending
          tta_cod_portador                 ascending
          tta_num_bord_ap                  ascending
          tta_num_seq_bord                 ascending
    .


def new shared temp-table tt_titulo_antecip_pef_a_pagar no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Saldo" column-label "Valor Saldo"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_dat_prepar_pagto             as date format "99/99/9999" initial ? label "Data Prepar Pagto" column-label "Dat Prepar"
    field tta_dat_liber_pagto              as date format "99/99/9999" initial ? label "Data Liber Pagto" column-label "Dat  Liber"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_refer_antecip_pef        as character format "x(10)" label "Ref Antec PEF Pend" column-label "Ref Antec PEF Pend"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_num_seq_pagto_tit_ap         as integer format ">9" initial 0 label "SequÇncia" column-label "Seq"
    field ttv_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Saldo" column-label "Valor Saldo"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"                          
    field ttv_val_pagto_moe                as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagto Moeda" column-label "Valor Pagto Moeda"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field ttv_rec_proces_pagto             as recid format ">>>>>>9" initial ?
    field ttv_log_mostra_tit               as logical format "Sim/NU" initial yes label "T°tulo" column-label "T°tulo"
    field ttv_ind_sit_prepar_liber         as character format "X(03)" label "Situaá∆o" column-label "Sit"
    field tta_cod_forma_pagto              as character format "x(3)" label "Forma Pagamento" column-label "F Pagto"
    field tta_cod_refer                    as character format "x(10)" label "ReferÇncia" column-label "ReferÇncia"
    field ttv_cod_classif_1                as character format "x(8)"
    field ttv_cod_classif_2                as character format "x(8)"
    field ttv_cod_classif_3                as character format "x(8)"
    field ttv_cod_classif_4                as character format "x(8)"
    field ttv_cod_classif_5                as character format "x(8)"
    field ttv_cod_classif_6                as character format "x(8)"
    field ttv_cod_classif_7                as character format "x(8)"
    field ttv_cod_classif_8                as character format "x(8)"
    field tta_cod_safra                    as character format "9999/9999" label "Safra" column-label "Safra"
    field tta_cod_contrat_graos            as character format "x(20)" label "Contrato GrUs" column-label "Contr GrUs"
    index tt_cdn_fornec                   
          tta_cdn_fornecedor               ascending
          tta_cod_estab                    ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_cod_classif                  
          ttv_cod_classif_1                ascending
          ttv_cod_classif_2                ascending
          ttv_cod_classif_3                ascending
          ttv_cod_classif_4                ascending
          ttv_cod_classif_5                ascending
          ttv_cod_classif_6                ascending
          ttv_cod_classif_7                ascending
          ttv_cod_classif_8                ascending
    index tt_cod_forma_pagto              
          tta_cod_forma_pagto              ascending
          tta_cod_estab                    ascending
          tta_cdn_fornecedor               ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_cod_refer                    
          tta_cod_refer                    ascending
    index tt_cod_tit_ap                   
          tta_cod_tit_ap                   ascending
    index tt_dat_prev_pagto               
          tta_dat_prev_pagto               ascending
          tta_cod_estab                    ascending
          tta_cdn_fornecedor               ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_estab_espec                  
          tta_cod_estab                    ascending
          tta_cdn_fornecedor               ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_ap                   ascending
          tta_cod_parcela                  ascending
    index tt_sel_faixa                    
          ttv_log_mostra_tit               ascending
          tta_cdn_fornecedor               ascending
          tta_nom_abrev                    ascending
          tta_dat_prev_pagto               ascending
          tta_dat_vencto_tit_ap            ascending
          tta_cod_tit_ap                   ascending
          tta_cod_estab                    ascending
          tta_cod_forma_pagto              ascending
          ttv_val_sdo_tit_ap               ascending
          tta_cod_refer                    ascending
    .

def new shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(5)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento"
    .

def temp-table tt_xml_input_output no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_des_conteudo_aux             as character format "x(40)"
    field ttv_num_seq_1                    as integer format ">>>,>>9"
    .


def temp-table tt_nome_abrev_fornec no-undo
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_nom_abrev                    as character format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    .

DEFINE VARIABLE v_log_erro                      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_hdl_indic_econ_finalid        AS HANDLE      NO-UNDO.
DEFINE VARIABLE v_log_exist                     AS LOGICAL     NO-UNDO.
DEFINE VARIABLE p_ind_modo_pagto                AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_log_achou                     AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_log_achou_2                   AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_log_achou_3                   AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_cod_indic_econ_pag            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_log_method                    AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_cod_indic_econ_corren         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_log_dat_pagto_bord            AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_log_funcao_val_max_tip_pagto  AS LOGICAL     NO-UNDO.
DEFINE VARIABLE v_val_lim_forma_pagto           AS DECIMAL     NO-UNDO.
DEFINE VARIABLE v_cod_forma_pagto_subst         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_dat_confir_bxa_tit_ap         AS DATE        NO-UNDO.

def var v_ind_origin_tit_ap
    as CHARACTER NO-UNDO.

DEF VAR v_log_execucao_local             as logical         no-undo. /*local*/
def var v_cod_finalid_param              as character       no-undo. /*local*/
def var v_cod_histor_padr                as character       no-undo. /*local*/
def var v_cod_indic_econ_param           as character       no-undo. /*local*/
def var v_log_erro_liber                 as logical         no-undo. /*local*/
def var v_log_tit_dupl                   as logical         no-undo. /*local*/
def var v_num_select_row                 as integer         no-undo. /*local*/
def var v_val_acerto_impl                as decimal         no-undo. /*local*/
def var v_val_acum_tit_ap                as decimal         no-undo. /*local*/
def var v_val_impto_calc                 as decimal         no-undo. /*local*/
def var v_val_perc_val_pagto             as decimal         no-undo. /*local*/
def var v_val_sdo_tit_ap_vincul          as decimal         no-undo. /*local*/
def var v_val_tot_vincul                 as decimal         no-undo. /*local*/
def var v_des_seq_item_bord_ap           as character       no-undo. /*local*/
DEF VAR v_log_cta_fornec                 AS LOGICAL         NO-UNDO.
def var v_log_return_epc                 as logical         no-undo. /*local*/
def var v_log_prog_upc                   as logical         no-undo. /*local*/
DEF VAR v_wgh_servid_rpc                 AS HANDLE          NO-UNDO.
def var v_log_prog_upc_aux               as logical         no-undo. /*local*/
DEF VAR v_des_text_histor                AS CHARACTER       NO-UNDO.

def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
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
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
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
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
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
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.

def new shared var v_log_atualiz_tit_impto_vinc
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_corrig_val
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def new global shared var v_rec_bord_ap
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_bord_ap_dest
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.

def var v_dat_min_sql
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    no-undo.
def var v_num_count
    as integer
    format ">>>>,>>9":U
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def var v_cod_cart_bcia
    as character
    format "x(3)":U
    label "Carteira"
    column-label "Carteira"
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(20)":U
    label "Centro Custo"
    column-label "Centro Custo"
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
def new global shared var v_cod_estab
    as character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estabelecimento"
    no-undo.
def new global shared var v_cod_estab_bord
    as character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def new global shared var v_cod_estab_usuar
    as character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def new global shared var v_cod_finalid_econ
    as character
    format "x(10)":U
    label "Finalidade Econìmica"
    column-label "Finalidade Econìmica"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_forma_pagto_aux
    as character
    format "x(3)":U
    label "Forma Pagamento"
    column-label "F Pagto"
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
def var v_cod_indic_econ
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Moeda"
    no-undo.
def new global shared var v_cod_mensagem
    as character
    format "x(2)":U
    label "Mensagem"
    column-label "Mensagem"
    no-undo.
def new global shared var v_cod_modul_dtsul_corren
    as character
    format "x(3)":U
    label "M¢dulo Corrente"
    column-label "M¢dulo Corrente"
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
def new global shared var v_cod_portador
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador"
    no-undo.
def new global shared var v_cod_return
    as character
    format "x(40)":U
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
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def new global shared var v_dat_refer_sit
    as date
    format "99/99/9999":U
    no-undo.
def new global shared var v_dat_transacao
    as date
    format "99/99/9999":U
    initial today
    label "Data Transaá∆o"
    column-label "Data Transaá∆o"
    no-undo.
def new global shared var v_des_sit_movimen_ent
    as character
    format "x(40)":U
    no-undo.
def new global shared var v_des_sit_movimen_mod
    as character
    format "x(40)":U
    no-undo.
def var v_hdl_valid_estab_refer
    as Handle
    format ">>>>>>9":U
    no-undo.
def new global shared var v_ind_tip_usuar
    as character
    format "X(08)":U
    no-undo.
def new global shared var v_ind_tip_verific
    as character
    format "X(08)":U
    no-undo.
def var v_log_favorec_cheq_adm
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_cotac_contrat
    as logical
    format "Sim/N∆o"
    initial no
    label "Cotac Contratada"
    column-label "Cotac Contratada"
    no-undo.
def var v_log_bord_dados_1
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_bxo_estab
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_bxo_estab_tit
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_guia
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "GPS s/ C¢d Barras"
    column-label "GPS s/ C¢d."
    no-undo.
def var v_log_pagto_trib
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_repeat
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_save_ok
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_vinc_impto_auto
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "PIS/COFINS/CSLL Auto"
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
def var v_nom_prog_upc
    as character
    format "X(50)":U
    label "Programa UPC"
    column-label "Programa UPC"
    no-undo.
def var v_nom_table_epc
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_aux
    as integer
    format ">>>>,>>9":U
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def new global shared var v_rec_estabelecimento
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_indic_econ
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_msg_financ
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_portador
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_portad_estab
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.

def var v_rec_table_sav
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_usuar_financ_estab_apb
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_val_lim_liber_usuar_mes
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Limite Màs"
    column-label "Limite Màs"
    no-undo.
def new global shared var v_val_lim_liber_usuar_movto
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Limite Movimento"
    column-label "Limite Movimento"
    no-undo.
def new global shared var v_val_lim_pagto_usuar_mes
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Limite Màs"
    column-label "Limite Màs"
    no-undo.
def new global shared var v_val_lim_pagto_usuar_movto
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Limite Movimento"
    column-label "Limite Movimento"
    no-undo.
def new global shared var v_wgh_estab
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_log_abat_antecip
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_val_tot_abat
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Abat"
    column-label "Tot Abat"
    no-undo.
def var v_val_tot_abat_antecip
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_abat_antecip_aux
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_log_impto_vincul_refer
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_val_tot_impto
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Total a Ratear"
    column-label "Valor Total a Ratear"
    no-undo.
def var v_log_guia_det
    as logical
    format "Sim/N∆o"
    initial no
    label "GPS s/ C¢d Barras"
    column-label "GPS s/ C¢d."
    no-undo.
def var v_log_deduc_base_calc_impto
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_agrup_por_dat_trans
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
DEF VAR v_log_bord_dados                 as logical         no-undo. /*local*/
def var v_log_validac                    as logical         no-undo. /*local*/

DEF VAR c-razao-social      AS CHAR NO-UNDO.
DEF VAR l-empresa-cofco     AS LOGICAL NO-UNDO.
DEF VAR l-empresa-agapys    AS LOGICAL NO-UNDO.
DEF VAR l-empresa-CMNP      AS LOGICAL NO-UNDO.
DEF VAR l-empresa-MRN       AS LOGICAL NO-UNDO.
DEF VAR l-empresa-valgroup  AS LOGICAL NO-UNDO.

DEF STREAM s-arq.

FUNCTION rpc_exec         RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_server       RETURNS handle    (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_program      RETURNS character (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_tip_exec     RETURNS logical   (input p_cod_program as character) in v_wgh_servid_rpc.
FUNCTION rpc_exec_set     RETURNS logical   (input p_cod_program as character, 
                                             input p_log_value as logical)     in v_wgh_servid_rpc.

//----------------------------------------------------------------------------------------------------

FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUN∞ÄO *******************************
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

//----------------------------------------------------------------------------------------------------

FUNCTION GetDefinedFunction RETURNS LOGICAL (INPUT SPP AS CHARACTER):

    DEF VAR v_log_retorno AS LOGICAL INITIAL NO NO-UNDO.
    DEFINE VARIABLE v_cod_arq AS CHARACTER   NO-UNDO.

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


//**************************************************
// BLOCO PRINCIPAL
//**************************************************

//DEF STREAM s-log.
//OUTPUT stream s-log TO VALUE(SESSION:TEMP-DIRECTORY + "bordero-" + string(year(today), "9999") + string(month(today), "99") + string(day(today),"99") + "-" + replace(string(time, "hh:mm:ss"), ":", "") + ".txt") CONVERT TARGET "iso8859-1".
        .

//**************************************************
// CONTROLE DE PARAMETROS POR CLIENTE
//**************************************************
// Esse controle ser† mantido na API atÇ a criaá∆o dos parÉmetros no GRID

    ASSIGN c-razao-social = "".

    FOR FIRST mguni.empresa NO-LOCK
        WHERE ep-codigo = "1":
        ASSIGN c-razao-social = mguni.empresa.razao-social.
    END.

    IF  c-razao-social BEGINS "COFCO" THEN
        ASSIGN l-empresa-cofco = YES.

    IF  c-razao-social BEGINS "Empresa TESTE" THEN
        ASSIGN l-empresa-agapys = YES.

    IF  c-razao-social BEGINS "Companhia Melhoramentos" THEN
        ASSIGN l-empresa-CMNP = YES.

    IF  INDEX(c-razao-social, "RIO DO NORTE") <> 0 THEN
        ASSIGN l-empresa-MRN = YES.

    IF  INDEX(c-razao-social, "Valgroup") <> 0 THEN
        ASSIGN l-empresa-valgroup = YES.

//----------------------------------------------------------------------------------------------------

//**************************************************
// BLOCODE EXECUÄ«O LOCAL PARA TESTES
//**************************************************

// para ativar a execuá∆o local alterar essa vari†vel para YES; mas na liberaá∆o sempe deixar com o valor NO
ASSIGN v_log_execucao_local = NO.

IF  v_log_execucao_local THEN DO:
    {esp/roboteasy/robotapi004.i1} // comandos para execuá∆o local
END. // IF  v_log_execucao_local THEN DO:

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-cria-bordero:
    DEF INPUT           PARAM TABLE FOR tt_bordero.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE c-desc-erro AS CHAR         NO-UNDO.
    
    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì para criaá∆o".
        ASSIGN v_log_erro = YES.

        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    IF tt_bordero.ind_tip_bord_ap = "" THEN
        ASSIGN tt_bordero.ind_tip_bord_ap = "Normal".

    IF v_cod_empres_usuar <> tt_bordero.cod_empresa THEN
        ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    IF tt_bordero.dat_transacao = ? THEN
        ASSIGN tt_bordero.dat_transacao = TODAY.


    find FIRST portador no-lock
         where portador.cod_portador = tt_bordero.cod_portador
    &if "{&emsfin_version}" >= "5.01" &then
         use-index portador_id
    &endif
          /*cl_frame of portador*/ no-error.
   
    IF NOT AVAIL portador THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Portador n∆o existente!".
        ASSIGN v_log_erro = YES.
    END.
    if avail portador and portador.ind_tip_portad = "M£tuo" /*l_mutuo*/  then do:
        /* Portador inv†lido ! */
        
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Portador inv†lido!".
        ASSIGN v_log_erro = YES.
    end.

    assign v_cod_portador = tt_bordero.cod_portador.

    /* **
     Mostra Imagem Cta Corrente
    ***/
    IF tt_bordero.num_bord_ap = ? OR tt_bordero.num_bord_ap = 0 THEN DO:
        assign tt_bordero.num_bord_ap = 1.                                   
        find last b_bord_ap no-lock
            where b_bord_ap.cod_estab_bord = tt_bordero.cod_estab
            and   b_bord_ap.cod_portador   = tt_bordero.cod_portador
            no-error.
        if avail b_bord_ap then
            assign tt_bordero.num_bord_ap = b_bord_ap.num_bord_ap + 1.

        find last b_compl_movto_pagto no-lock    
            where b_compl_movto_pagto.cod_estab_pagto = tt_bordero.cod_estab
            and   b_compl_movto_pagto.cod_portador    = tt_bordero.cod_portador
            no-error.
        if avail b_compl_movto_pagto then do:
            if b_compl_movto_pagto.num_bord_ap >= tt_bordero.num_bord_ap then
                assign tt_bordero.num_bord_ap = b_compl_movto_pagto.num_bord_ap + 1.
        end.
    END.


    IF tt_bordero.cod_indic_econ = ? THEN DO:
        run pi_retornar_finalid_econ_corren_estab (Input tt_bordero.cod_estab,
                                                   output v_cod_finalid_econ).
        
    
        run pi_retornar_indic_econ_finalid (Input v_cod_finalid_econ,
                                            Input tt_bordero.dat_transacao,
                                            output v_cod_indic_econ).
    
        ASSIGN tt_bordero.cod_indic_econ = v_cod_finalid_econ.
    END.



    find estabelecimento no-lock
         where estabelecimento.cod_estab = tt_bordero.cod_estab /*cl_estab_bord of estabelecimento*/ no-error.
    
    assign v_cod_estab = tt_bordero.cod_estab.

    if  avail estabelecimento
    then do:
        find last param_estab_apb
            where param_estab_apb.cod_estab = tt_bordero.cod_estab
            no-lock no-error.

        if  avail param_estab_apb
        then do:
          
            IF tt_bordero.cod_msg_inic = ? THEN
                assign tt_bordero.cod_msg_inic = param_estab_apb.cod_msg_inic.

            IF tt_bordero.cod_msg_fim = ? THEN
                ASSIGN tt_bordero.cod_msg_fim  = param_estab_apb.cod_msg_fim.

        end /* if */.    
    end /* if */.


    IF tt_bordero.ind_tip_bord_ap = "Canc. Cheque ADM." AND tt_bordero.log_bord_ap_escrit = YES THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Quando tipo for Canc. Cheque ADM, Borderì n∆o poder† ser Escritural".
        ASSIGN v_log_erro = YES.
    END.

    IF NOT AVAIL param_estab_apb THEN
        FOR FIRST param_estab_apb NO-LOCK
            WHERE param_estab_apb.cod_estab = tt_bordero.cod_estab:
        END.
    IF param_estab_apb.log_pagto_escrit = NO AND tt_bordero.log_bord_ap_escrit = YES THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Estabelecimento " + tt_bordero.cod_estab + " n∆o habilitado para Borderì Escritural".
        ASSIGN v_log_erro = YES.
    END.

    IF tt_bordero.log_bord_ap_escrit = YES AND (tt_bordero.log_bord_gps = YES OR tt_bordero.log_bord_darf = YES) THEN DO:

        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì Escritural n∆o poder† ser selecionado GPS e DARF sem c¢digo de barras ".
        ASSIGN v_log_erro = YES.
    END.

    IF tt_bordero.log_bord_gps = YES AND tt_bordero.log_bord_darf = YES THEN DO:

        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "GPS s/ Cod Barras e DARF s/ Cod Barras n∆o podem ser marcados simultaneamente".
        ASSIGN v_log_erro = YES.
    END.

    run pi_vld_bord_ap.

    IF v_log_erro = YES THEN DO:

        ASSIGN c-desc-erro = "".
        FOR FIRST tt-retorno
            WHERE tt-retorno.cod-status <> 200:
            ASSIGN c-desc-erro = tt-retorno.desc-retorno.
        END.
        
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201.
        IF  c-desc-erro <> "" THEN
            ASSIGN tt-retorno.desc-retorno = c-desc-erro.
        ELSE
            ASSIGN tt-retorno.desc-retorno = "Ocorreu um erro na criaá∆o do borderì".

        RETURN.
    END.
    ELSE DO:
        CREATE bord_ap.
        ASSIGN bord_ap.cod_estab                = tt_bordero.cod_estab               
               bord_ap.cod_empresa              = tt_bordero.cod_empresa             
               bord_ap.cod_portador             = tt_bordero.cod_portador            
               bord_ap.num_bord_ap              = tt_bordero.num_bord_ap             
               bord_ap.dat_transacao            = tt_bordero.dat_transacao           
               bord_ap.ind_tip_bord_ap          = tt_bordero.ind_tip_bord_ap         
               bord_ap.val_tot_lote_pagto_efetd = tt_bordero.val_tot_lote_pagto_efetd
               bord_ap.cod_indic_econ           = tt_bordero.cod_indic_econ          
               bord_ap.cod_msg_inic             = tt_bordero.cod_msg_inic            
               bord_ap.cod_msg_fim              = tt_bordero.cod_msg_fim             
               bord_ap.log_bxa_estab_tit_ap     = tt_bordero.log_bxa_estab_tit_ap    
               bord_ap.log_vincul_autom         = tt_bordero.log_vincul_autom        
               bord_ap.log_bord_gps             = tt_bordero.log_bord_gps            
               bord_ap.log_bord_darf            = tt_bordero.log_bord_darf           
               bord_ap.log_bord_ap_escrit       = tt_bordero.log_bord_ap_escrit      
               bord_ap.cod_usuar_pagto          = v_cod_usuar_corren
               bord_ap.cod_finalid_econ         = tt_bordero.cod_finalid_econ
               bord_ap.cod_refer                = tt_bordero.cod_refer  
               bord_ap.cod_cart_bcia            = v_cod_cart_bcia
               bord_ap.ind_sit_bord_ap          = "Em Digitaá∆o"
               bord_ap.ind_tip_bord_ap          = tt_bordero.ind_tip_bord_ap
               .     

        RELEASE bord_ap.
        IF CAN-FIND (FIRST bord_ap WHERE bord_ap.cod_estab    = tt_bordero.cod_estab               
                                    and  bord_ap.cod_empresa  = tt_bordero.cod_empresa             
                                    and  bord_ap.cod_portador = tt_bordero.cod_portador            
                                    and  bord_ap.num_bord_ap  = tt_bordero.num_bord_ap  ) THEN DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 200
                   tt-retorno.desc-retorno = "Criado com sucesso. Borderì " + string(tt_bordero.num_bord_ap).
        END.
        ELSE DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 201
                   tt-retorno.desc-retorno = "Erro na criaá∆o. Borderì " + string(tt_bordero.num_bord_ap).

        END.
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-busca-tit:
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt_param.
    DEF OUTPUT          PARAM TABLE FOR tt_titulos_bord.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-cont                       AS INTEGER     NO-UNDO.

    FOR FIRST tt_param:
    END.

    IF NOT AVAIL tt_param THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "ParÉmetros n∆o foram enviados".
        RETURN.
    END.

    IF NOT CAN-FIND(FIRST mguni.empresa
                    WHERE mguni.empresa.ep-codigo = tt_param.cod_empresa) THEN DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 201
                   tt-retorno.desc-retorno = "Empresa n∆o cadastrada: " + tt_param.cod_empresa.
            RETURN.
    END.
    ELSE 
        ASSIGN v_cod_empres_usuar = tt_param.cod_empresa. 

    FIND FIRST bord_ap NO-LOCK
         WHERE bord_ap.cod_estab_bord  = tt_param.cod_estab
           AND bord_ap.cod_portador    = tt_param.cod_portador 
           AND bord_ap.cod_empresa     = tt_param.cod_empresa
           AND bord_ap.num_bord_ap     = tt_param.num_bord_ap NO-ERROR.

    ASSIGN v_log_atualiza_dat_pagto = YES.
    if GetDefinedFunction('SPP_DESM_FLAG_BORD':U) then
        assign v_log_atualiza_dat_pagto = no.

    IF tt_param.log_atualiza_dat_pagto <> ? THEN
         assign v_log_atualiza_dat_pagto = tt_param.log_atualiza_dat_pagto.

    IF AVAIL bord_ap THEN DO:
        RUN pi_inicializa_tt_param (INPUT-OUTPUT TABLE tt_param).

        ASSIGN v_rec_bord_ap = recid(bord_ap).
    
        EMPTY TEMP-TABLE tt_titulo_antecip_pef_a_pagar.
        EMPTY TEMP-TABLE tt_titulo_dados_bcia_pgto_bord.
        
        // everton
        IF  v_log_execucao_local THEN DO:
            MESSAGE "tt_param.ind_pagto_liber = " tt_param.ind_pagto_liber
                VIEW-AS ALERT-BOX.
        END.

        run pi_controlar_selecao_pagamento (Input (IF bord_ap.log_bord_ap_escrit THEN "Escritural" ELSE "Borderì")  , //if bord_ap.log_bord_ap_escrit then "Escritural" /*l_escritural*/  else "BorderÀ" /*l_bordero*/,
                                            Input bord_ap.dat_transacao                                             , //bord_ap.dat_transacao,
                                            Input tt_param.ind_tip_docto_prepar_pagto                               , //v_ind_tip_docto_prepar_pagto,
                                            Input tt_param.ind_liber_pagto_dat                                      , //v_ind_pagto_dat,
                                            Input tt_param.dat_inicio                                               , //v_dat_inicio,
                                            Input tt_param.dat_fim                                                  , //v_dat_fim,
                                            Input tt_param.cod_estab_ini                                            , //v_cod_estab_ini,
                                            Input tt_param.cod_estab_fim                                            , //v_cod_estab_fim,
                                            Input tt_param.cdn_fornecedor_ini                                       , //v_cdn_fornecedor_ini,
                                            Input tt_param.cdn_fornecedor_fim                                       , //v_cdn_fornecedor_fim,
                                            Input tt_param.cod_espec_docto_ini                                      , //v_cod_espec_docto_ini,
                                            Input tt_param.cod_espec_docto_fim                                      , //v_cod_espec_docto_fim,
                                            Input tt_param.cod_forma_pagto_ini                                      , //v_cod_forma_pagto_in,
                                            Input tt_param.cod_forma_pagto_fim                                      , //v_cod_forma_pagto_fn,
                                            Input tt_param.cod_indic_econ_ini                                       , //v_cod_indic_econ_ini,
                                            Input tt_param.cod_indic_econ_fim                                       , //v_cod_indic_econ_fim,
                                            Input tt_param.cod_portador_ini                                         , //v_cod_portador_ini,
                                            Input tt_param.cod_portador_fim                                         , //v_cod_portador_fim,
                                            Input bord_ap.cod_portador                                              , //bord_ap.cod_portador,
                                            Input bord_ap.cod_cart_bcia                                             , //bord_ap.cod_cart_bcia,
                                            Input bord_ap.cod_indic_econ                                            , //bord_ap.cod_indic_econ,
                                            Input tt_param.ind_pagto_liber                                          , //v_ind_pagto_liber,
                                            Input tt_param.val_cotac_indic_econ                                     , //v_val_cotac_indic_econ,
                                            Input tt_param.dat_cotac_indic_econ                                     , //v_dat_cotac_indic_econ,
                                            Input 999999999999.99                                                   , //v_val_lim_pagto,
                                            Input tt_param.ind_forma_pagto                                          , //v_ind_forma_pagto,
                                            Input tt_param.cod_forma_pagto                                          , //v_cod_forma_pagto,
                                            Input ""                                                                , //v_ind_juros_pagto_autom,
                                            Input 0                                                                 , //0,
                                            Input 0                                                                 , //0,
                                            Input tt_param.ind_favorec_cheq                                         , //v_ind_favorec_cheq,
                                            Input ""                                                                , //v_nom_favorec_cheq,
                                            Input bord_ap.cod_estab_bord                                            , //bord_ap.cod_estab_bord,
                                            Input tt_param.log_gerac_autom                                          , //v_log_gerac_autom,
                                            Input v_rec_bord_ap                                                     , //recid(bord_ap),
                                            Input tt_param.cod_histor_padr                                          , //v_cod_histor_padr,
                                            Input tt_param.log_consid_fatur_cta  ). //v_log_consid_fatur_cta) /*pi_controlar_selecao_pagamento*/.                                  
                            
            EMPTY TEMP-TABLE tt_lista_fornec.

            FOR EACH tt_titulo_antecip_pef_a_pagar:

                // atualizar o campo tt_titulo_antecip_pef_a_pagar qdo estiver em branco
                IF  tt_titulo_antecip_pef_a_pagar.tta_cod_forma_pagto = "" 
                OR  tt_titulo_antecip_pef_a_pagar.tta_cod_forma_pagto = ? THEN DO:
                    FIND FIRST fornec_financ NO-LOCK
                    WHERE fornec_financ.cod_empresa    = v_cod_empres_usuar  
                      AND fornec_financ.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor NO-ERROR.
                    IF  AVAIL fornec_financ THEN
                        ASSIGN tt_titulo_antecip_pef_a_pagar.tta_cod_forma_pagto = fornec_financ.cod_forma_pagto.
                END.
      
                IF NOT CAN-FIND(tt_titulo_dados_bcia_pgto_bord 
                            WHERE tt_titulo_dados_bcia_pgto_bord.ttv_rec_tit_ap = tt_titulo_antecip_pef_a_pagar.ttv_rec_tit_ap) THEN DO:
                    find FIRST fornec_financ no-lock 
                    where fornec_financ.cod_empresa    = v_cod_empres_usuar  
                      AND fornec_financ.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor no-error.
                if  avail fornec_financ then do:
                    CREATE tt_titulo_dados_bcia_pgto_bord.
                    ASSIGN tt_titulo_dados_bcia_pgto_bord.ttv_rec_tit_ap                = tt_titulo_antecip_pef_a_pagar.ttv_rec_tit_ap
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_banco                 = fornec_financ.cod_banco                                                      
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_agenc_bcia_digito     = fornec_financ.cod_agenc_bcia     + "-" /* l_-*/  + fornec_financ.cod_digito_agenc_bcia     
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_cta_corren_bco_digito = fornec_financ.cod_cta_corren_bco + "-" /* l_-*/  + fornec_financ.cod_digito_cta_corren.
                end.
                ELSE DO:
                    CREATE tt_titulo_dados_bcia_pgto_bord.
                    ASSIGN tt_titulo_dados_bcia_pgto_bord.ttv_rec_tit_ap                = tt_titulo_antecip_pef_a_pagar.ttv_rec_tit_ap
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_banco                 = "" /* l_*/                                                       
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_agenc_bcia_digito     = "" /* l_*/ 
                           tt_titulo_dados_bcia_pgto_bord.ttv_cod_cta_corren_bco_digito = "" /* l_*/ .
                END.
            END.

            IF NOT CAN-FIND(FIRST tt_lista_fornec
                            WHERE tt_lista_fornec.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor) THEN DO:
                CREATE tt_lista_fornec.
                ASSIGN tt_lista_fornec.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor.
            END.
        END.
                          
        RUN pi-gerar-tab-antecip-por-fornec-emp.
        
        FOR EACH tt_titulo_antecip_pef_a_pagar 
            BREAK BY tt_titulo_antecip_pef_a_pagar.tta_cod_estab:

            IF  FIRST-OF(tt_titulo_antecip_pef_a_pagar.tta_cod_estab) THEN
                FOR FIRST estabelec FIELDS (ep-codigo) NO-LOCK
                    WHERE estabelec.cod-estabel = tt_titulo_antecip_pef_a_pagar.tta_cod_estab:
                END.

            FOR FIRST tt_titulo_dados_bcia_pgto_bord 
                WHERE tt_titulo_dados_bcia_pgto_bord.ttv_rec_tit_ap = tt_titulo_antecip_pef_a_pagar.ttv_rec_tit_ap:
            END.

            ASSIGN i-cont = i-cont + 1.
            CREATE tt_titulos_bord.
            ASSIGN tt_titulos_bord.ind_sit_prepar_liber      = tt_titulo_antecip_pef_a_pagar.ttv_ind_sit_prepar_liber      
                   tt_titulos_bord.cod_estab                 = tt_titulo_antecip_pef_a_pagar.tta_cod_estab                 
                   tt_titulos_bord.cdn_fornecedor            = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor            
                   tt_titulos_bord.nom_abrev                 = tt_titulo_antecip_pef_a_pagar.tta_nom_abrev                 
                   tt_titulos_bord.cod_espec_docto           = tt_titulo_antecip_pef_a_pagar.tta_cod_espec_docto           
                   tt_titulos_bord.cod_ser_docto             = tt_titulo_antecip_pef_a_pagar.tta_cod_ser_docto             
                   tt_titulos_bord.cod_tit_ap                = tt_titulo_antecip_pef_a_pagar.tta_cod_tit_ap                
                   tt_titulos_bord.cod_parcela               = tt_titulo_antecip_pef_a_pagar.tta_cod_parcela               
                   tt_titulos_bord.dat_prev_pagto            = tt_titulo_antecip_pef_a_pagar.tta_dat_prev_pagto            
                   tt_titulos_bord.val_sdo_tit_ap            = tt_titulo_antecip_pef_a_pagar.tta_val_sdo_tit_ap            
                   tt_titulos_bord.dat_vencto_tit_ap         = tt_titulo_antecip_pef_a_pagar.tta_dat_vencto_tit_ap         
                   tt_titulos_bord.cod_indic_econ            = tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ            
                   tt_titulos_bord.cod_refer_antecip_pef     = tt_titulo_antecip_pef_a_pagar.tta_cod_refer_antecip_pef     
                   tt_titulos_bord.val_pagto_moe             = tt_titulo_antecip_pef_a_pagar.ttv_val_pagto_moe             
                   tt_titulos_bord.dat_emis_docto            = tt_titulo_antecip_pef_a_pagar.tta_dat_emis_docto            
                   tt_titulos_bord.dat_desconto              = tt_titulo_antecip_pef_a_pagar.tta_dat_desconto              
                   tt_titulos_bord.cod_forma_pagto           = tt_titulo_antecip_pef_a_pagar.tta_cod_forma_pagto           
                   tt_titulos_bord.cod_refer                 = tt_titulo_antecip_pef_a_pagar.tta_cod_refer                 
                   tt_titulos_bord.cod_banco                 = tt_titulo_dados_bcia_pgto_bord.ttv_cod_banco                
                   tt_titulos_bord.cod_agenc_bcia_digito     = tt_titulo_dados_bcia_pgto_bord.ttv_cod_agenc_bcia_digito    
                   tt_titulos_bord.cod_cta_corren_bco_digito = tt_titulo_dados_bcia_pgto_bord.ttv_cod_cta_corren_bco_digito
                   tt_titulos_bord.val_cotac_indic_econ      = tt_titulo_antecip_pef_a_pagar.tta_val_cotac_indic_econ
                   tt_titulos_bord.num_seq_pagto_tit_ap      = tt_titulo_antecip_pef_a_pagar.tta_num_seq_pagto_tit_ap
                   tt_titulos_bord.log_possui_antecip_forn   = CAN-FIND(FIRST tt_antecip_fornec_emp 
                                                                              WHERE tt_antecip_fornec_emp.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor            
                                                                              AND   tt_antecip_fornec_emp.cod_empresa    = estabelec.ep-codigo
                                                                              AND   tt_antecip_fornec_emp.tipo_fornec    = "F")
                   tt_titulos_bord.log_possui_antecip_matriz_filial = CAN-FIND(FIRST tt_antecip_fornec_emp 
                                                                                     WHERE tt_antecip_fornec_emp.cdn_fornecedor = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor            
                                                                                     AND   tt_antecip_fornec_emp.cod_empresa    = estabelec.ep-codigo
                                                                                     AND   tt_antecip_fornec_emp.tipo_fornec    = "M").

//**************************************************
// CONTROLE DE PARAMETROS POR CLIENTE
//**************************************************
// Esse controle ser† mantido na API atÇ a criaá∆o dos parÉmetros no GRID
//----------------------------------------------------------------------------------------------------
            IF  l-empresa-CMNP THEN DO:
                // j† est† usando o parÉmeetro e antec por fornec
                // precisa tratar antec por matriz/filial que ainda n∆o foi implementado no robì
                // por esse motivo copiar o param antec por matriz/filial para o param por fonec
                IF  tt_titulos_bord.log_possui_antecip_matriz_filial THEN DO:
                    // copiar param por "matriz/filial" para param por "fornec"
                    ASSIGN tt_titulos_bord.log_possui_antecip_forn = YES.
                END.
            END.
            ELSE DO:
                // para todos os outros cliente vamos desativar o tratamento das antecipaá‰es 
                // atÇ que eles digam a regra que utilizam 
                ASSIGN tt_titulos_bord.log_possui_antecip_forn          = NO
                       tt_titulos_bord.log_possui_antecip_matriz_filial = NO.
            END.

//----------------------------------------------------------------------------------------------------

            FOR FIRST tit_ap
                where tit_ap.cod_estab       = tt_titulos_bord.cod_estab
                and   tit_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                and   tit_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                and   tit_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                and   tit_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                and   tit_ap.cod_parcela     = tt_titulos_bord.cod_parcela:
                            
                ASSIGN tt_titulos_bord.cod_barras_pagto = tit_ap.cb4_tit_ap_bco_cobdor.
            END.
        END. // FOR EACH tt_titulo_antecip_pef_a_pagar 
     
        IF i-cont > 0 THEN DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 200
                   tt-retorno.desc-retorno = "Busca com sucesso. T°tulos: " + STRING(i-cont).
        END.
        ELSE DO:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 201
                   tt-retorno.desc-retorno = "N∆o foram encontrados t°tulos dispon°veis".
        END.
       
    END. // IF AVAIL bord_ap THEN DO:
    ELSE DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Estab: " + tt_param.cod_estab + "|Port: " + tt_param.cod_portador   + "|Nro: " + string(tt_param.num_bord_ap).
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-gerar-tab-antecip-por-fornec-emp:

    DEFINE VARIABLE v_val_sdo_tit_ap AS DECIMAL     NO-UNDO.
    DEF VAR c-nome-matriz LIKE emitente.nome-matriz NO-UNDO.

    if not can-find(FIRST tt_lista_fornec) then return.

    FOR EACH tt_lista_fornec:

        RUN pi-buscar-antecipacoes (INPUT tt_lista_fornec.cdn_fornecedor,   // fornecedor do t°tulo
                                    INPUT tt_lista_fornec.cdn_fornecedor,   // fornecedor da antecipaá∆o
                                    INPUT "F").                             // tipo: F = fornecedor M = matriz

        FOR FIRST emitente FIELDS (nome-matriz) NO-LOCK
            WHERE emitente.cod-emitente = tt_lista_fornec.cdn_fornecedor:
            ASSIGN c-nome-matriz = emitente.nome-matriz.
        END.

        FOR EACH emitente FIELDS (cod-emitente) NO-LOCK
            WHERE emitente.nome-matriz = c-nome-matriz:
            RUN pi-buscar-antecipacoes (INPUT tt_lista_fornec.cdn_fornecedor,   // fornecedor do t°tulo
                                        INPUT emitente.cod-emitente,            // fornecedor da antecipaá∆o
                                        INPUT "M").                             // tipo: F = fornecedor M = matriz/filial
        END.

    END. // FOR EACH tt_lista_fornec:
    
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-buscar-antecipacoes:

    DEF INPUT PARAM p_cdn_fornec_titulo LIKE fornecedor.cdn_fornecedor NO-UNDO.
    DEF INPUT PARAM p_cdn_fornec_antecip LIKE fornecedor.cdn_fornecedor NO-UNDO.
    
    DEF INPUT PARAM p_c_tipo_fornec AS CHAR NO-UNDO.
    
    DEFINE VARIABLE v_val_sdo_tit_ap AS DECIMAL     NO-UNDO.

    bloco-antecip:
    FOR each tit_ap NO-LOCK // usa °ndice c/ CDN_FORNECEDOR + IND_TIP_ESPEC_DOCTO
        where tit_ap.cdn_fornecedor      = p_cdn_fornec_antecip
        and   tit_ap.ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/  
        and   tit_ap.dat_transacao      <= today 
        and   tit_ap.log_tit_ap_estordo  = no:

        // gerar temp-table tt_antecip_fornec_emp
        FOR FIRST tt_antecip_fornec_emp 
            WHERE tt_antecip_fornec_emp.cdn_fornecedor = p_cdn_fornec_titulo
            AND   tt_antecip_fornec_emp.cod_empresa    = tit_ap.cod_empresa
            AND   tt_antecip_fornec_emp.tipo_fornec    = p_c_tipo_fornec:
        END.

        IF  AVAIL tt_antecip_fornec_emp THEN
            NEXT bloco-antecip.

        assign v_val_sdo_tit_ap = tit_ap.val_sdo_tit_ap.
        for each abat_antecip_vouch no-lock
            where abat_antecip_vouch.cod_estab       = tit_ap.cod_estab
            and   abat_antecip_vouch.cod_espec_docto = tit_ap.cod_espec_docto
            and   abat_antecip_vouch.cod_ser_docto   = tit_ap.cod_ser_docto
            and   abat_antecip_vouch.cdn_fornecedor  = tit_ap.cdn_fornecedor
            and   abat_antecip_vouch.cod_tit_ap      = tit_ap.cod_tit_ap
            and   abat_antecip_vouch.cod_parcela     = tit_ap.cod_parcela
            and   abat_antecip_vouch.log_abat_atlzdo = no:

            find first item_lote_pagto no-lock
                 where item_lote_pagto.cod_estab_refer = abat_antecip_vouch.cod_estab_refer
                 and   item_lote_pagto.cod_refer = abat_antecip_vouch.cod_refer
                 and   item_lote_pagto.num_seq_refer = abat_antecip_vouch.num_seq_refer no-error.

            if (    avail item_lote_pagto
                and item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Estornado" /*l_estornado*/ 
                and item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Baixado" /*l_baixado*/ )
            or not avail item_lote_pagto then 
               assign v_val_sdo_tit_ap = v_val_sdo_tit_ap - abat_antecip_vouch.val_abtdo_antecip_orig.
        END. // for each abat_antecip_vouch no-lock

        IF  v_val_sdo_tit_ap <= 0 THEN
            NEXT bloco-antecip.

        // gerar temp-table tt_antecip_fornec_emp
        CREATE tt_antecip_fornec_emp.
        ASSIGN tt_antecip_fornec_emp.cdn_fornecedor = p_cdn_fornec_titulo 
               tt_antecip_fornec_emp.cod_empresa    = tit_ap.cod_empresa
               tt_antecip_fornec_emp.tipo_fornec    = p_c_tipo_fornec.

    END. // FOR each tit_ap NO-LOCK // 
    
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-vincula-bord:

    DEF INPUT-OUTPUT    PARAM TABLE FOR tt_param.
    DEF INPUT           PARAM TABLE FOR tt_titulos_bord.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE v_log_erro_cotac AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE v_log_cotac_contrat         AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_cod_impto                 AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE v_num_select_row            AS INTEGER     NO-UNDO.
    DEFINE VARIABLE v_log_impto                 AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_log_tit_dupl              AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_cod_return_liber_pagto    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE v_log_erro_liber            AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_val_pagto_liber           AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE c-msg-aux                   AS CHARACTER   NO-UNDO.

    ASSIGN p_ind_modo_pagto = "Borderì".

    FOR FIRST tt_param:
    END.

    IF NOT AVAIL tt_param THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o informado". 
        RETURN.
    END.

    //IF NOT can-find(FIRST empresa
    //                WHERE empresa.ep-codigo = tt_param.cod_empresa) THEN DO:
    //        CREATE tt-retorno.
    //        ASSIGN tt-retorno.versao-api = c-versao-api 
    //               tt-retorno.cod-status = 201
    //               tt-retorno.desc-retorno = "Empresa n∆o existe: " + tt_param.cod_empresa.
    //END.
    //ELSE 
        ASSIGN v_cod_empres_usuar = tt_param.cod_empresa. 

    FOR FIRST bord_ap NO-LOCK
        WHERE bord_ap.cod_estab_bord = tt_param.cod_estab    
          AND bord_ap.cod_empresa    = tt_param.cod_empresa  
          AND bord_ap.cod_portador   = tt_param.cod_portador 
          AND bord_ap.num_bord_ap    = tt_param.num_bord_ap:
    END.
    IF  NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Estab: " + tt_param.cod_estab + "|Port: " + tt_param.cod_portador   + "|Nro: " + string(tt_param.num_bord_ap). 
        RETURN.
    END.

    RUN pi_inicializa_tt_param (INPUT-OUTPUT TABLE tt_param).

    //----------------------------------------------------------------------------------------------------

    //Contabiliza e retifica campos
    FOR EACH tt_titulos_bord:

        IF tt_titulos_bord.rec_tit_ap = ? THEN DO:
            if  tt_titulos_bord.cod_refer_antecip_pef = "" then
                FOR FIRST tit_ap NO-LOCK
                    WHERE tit_ap.cod_estab        = tt_titulos_bord.cod_estab      
                      AND tit_ap.cdn_fornecedor   = tt_titulos_bord.cdn_fornecedor 
                      AND tit_ap.cod_espec_docto  = tt_titulos_bord.cod_espec_docto
                      AND tit_ap.cod_ser_docto    = tt_titulos_bord.cod_ser_docto  
                      AND tit_ap.cod_tit_ap       = tt_titulos_bord.cod_tit_ap     
                      AND tit_ap.cod_parcela      = tt_titulos_bord.cod_parcela: 
                   ASSIGN tt_titulos_bord.rec_tit_ap = RECID(tit_ap).
                END.
            else
                for first antecip_pef_pend no-lock
                    where antecip_pef_pend.cod_estab = tt_titulos_bord.cod_estab    
                    and   antecip_pef_pend.cod_refer = tt_titulos_bord.cod_refer_antecip_pef:
                    assign tt_titulos_bord.rec_tit_ap = recid(antecip_pef_pend).
                end.
        END.

        IF tt_titulos_bord.rec_proces_pagto = ? THEN DO:
            FOR FIRST proces_pagto NO-LOCK
                WHERE proces_pagto.cod_estab        = tt_titulos_bord.cod_estab      
                  AND proces_pagto.cdn_fornecedor   = tt_titulos_bord.cdn_fornecedor 
                  AND proces_pagto.cod_espec_docto  = tt_titulos_bord.cod_espec_docto
                  AND proces_pagto.cod_ser_docto    = tt_titulos_bord.cod_ser_docto  
                  AND proces_pagto.cod_tit_ap       = tt_titulos_bord.cod_tit_ap     
                  AND proces_pagto.cod_parcela      = tt_titulos_bord.cod_parcela :
                ASSIGN tt_titulos_bord.rec_proces_pagto = RECID(proces_pagto).
            END.
        END.

        ASSIGN v_num_select_row = v_num_select_row + 1
               tt_titulos_bord.log_mostra_tit  = yes.
    END.
    
    //----------------------------------------------------------------------------------------------------
    
    IF v_num_select_row = 0 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "T°tulos n∆o informados". 
        RETURN.
    END.

    assign v_log_cotac_contrat = &if defined(BF_FIN_COTAC_CONTRAT) &then yes &else no &endif and
                                can-find(first param_integr_ems NO-LOCK where param_integr_ems.ind_param_integr_ems = "Originaá∆o De Gr∆os" /*l_originacao_graos*/ ).

    if v_log_cotac_contrat then /* Busca cotaá∆o do m¢dulo de contrato */
        run prgint/utb/utb921zb.py persistent set v_hdl_indic_econ_finalid.
    else
        run prgint/utb/utb921za.py persistent set v_hdl_indic_econ_finalid.	

    //----------------------------------------------------------------------------------------------------

    FOR EACH tt_titulos_bord:
    
        // esse bloco vai processar somente os t°tulos (tabela tit_ap)
        // pq os adiantamentos (tabela antecip_pef_pend) ainda n∆o foram criados na tabela tit_ap
        for first tit_ap no-lock
            where tit_ap.cod_estab       = tt_titulos_bord.cod_estab
            and   tit_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
            and   tit_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
            and   tit_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
            and   tit_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
            and   tit_ap.cod_parcela     = tt_titulos_bord.cod_parcela:

            if v_log_cotac_contrat then do:
                run pi_set_tit_ap in v_hdl_indic_econ_finalid(input tit_ap.cod_estab, input tit_ap.num_id_tit_ap).
            end.    
    
            for each compl_retenc_impto_pagto no-lock
                where compl_retenc_impto_pagto.cod_estab     = tit_ap.cod_estab
                and   compl_retenc_impto_pagto.num_id_tit_ap = tit_ap.num_id_tit_ap:
    
                for FIRST imposto 
                    WHERE imposto.cod_pais = compl_retenc_impto_pagto.cod_pais
                    and   imposto.cod_unid_federac = compl_retenc_impto_pagto.cod_unid_federac 
                    and   imposto.cod_imposto = compl_retenc_impto_pagto.cod_imposto no-lock:
    
                    IF NUM-ENTRIES(v_cod_impto) > 1 THEN
                    DO:
                        IF v_num_select_row > 1 THEN
                        DO:
                          IF index(v_cod_impto, imposto.des_imposto) = 0 THEN
                          DO:
                            ASSIGN v_cod_impto = v_cod_impto + imposto.des_imposto.
                            ASSIGN v_cod_impto = v_cod_impto + ', '.
                          END.
                        END.
                        ELSE
                        DO:
                            IF v_num_select_row > 0 THEN
                            DO:
                          IF index(v_cod_impto, imposto.cod_imposto) = 0 THEN
                                DO:
                                    ASSIGN v_cod_impto = v_cod_impto + imposto.cod_imposto.
                                    ASSIGN v_cod_impto = v_cod_impto + ', '.
                                END.
                            END.
                        END.
                    END.
                    ELSE
                    DO:
                        IF v_num_select_row > 1 THEN
                        DO:
                            ASSIGN v_cod_impto = v_cod_impto + imposto.des_imposto.
                            ASSIGN v_cod_impto = v_cod_impto + ', '.
                        END.
                        ELSE
                        DO:
                            IF v_num_select_row > 0 THEN
                            DO:
                                ASSIGN v_cod_impto = v_cod_impto + imposto.cod_imposto.
                                ASSIGN v_cod_impto = v_cod_impto + ', '.
                            END.
                        END.
                    END.
                    ASSIGN v_log_impto = YES.             
                end.
            end.    
        end.
    END.
    
    //----------------------------------------------------------------------------------------------------

    IF  v_log_impto 
    AND p_ind_modo_pagto <> "Liberaá∆o" /*l_liberacao*/  
    AND p_ind_modo_pagto <> "Preparaá∆o" /*l_preparacao*/  THEN
    DO:
        /* Imposto(s) a Reter no Pagamento n∆o Informado(s). */ 
        run pi_messages (input "show",
                         input 13713,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            v_cod_impto)) /*msg_13713*/.
    END.

    //----------------------------------------------------------------------------------------------------

    assign v_log_exist  = no.

    if  v_num_select_row <> 0
    then do:
        if  p_ind_modo_pagto <> "Liberaá∆o" /*l_liberacao*/  
        and  p_ind_modo_pagto <> "Preparaá∆o" /*l_preparacao*/ 
        then do:
            run pi_valida_val_usuar_pagamento (output v_cod_return). 
            if v_cod_return <> "OK" /*l_ok*/  then do:
                run pi_msg_validacao_usuario (input v_cod_return,
                                              input v_cod_return,
                                              input "Pagto" /*l_pagto*/  ).
                return. // tratamento de erro revisado (realizado dentro da procedure)
            end.
        end.

        //----------------------------------------------------------------------------------------------------

        assign v_log_tit_dupl = no.
        table_src_a:
        FOR EACH tt_titulos_bord
        on endkey undo table_src_a, leave table_src_a on error undo table_src_a, leave table_src_a
        TRANSACTION:      
        
        
            IF CAN-FIND(FIRST item_bord_ap
                        WHERE item_bord_ap.cod_estab       = tt_titulos_bord.cod_estab      
                          AND item_bord_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor 
                          AND item_bord_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                          AND item_bord_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto  
                          AND item_bord_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap     
                          AND item_bord_ap.cod_parcela     = tt_titulos_bord.cod_parcela 
                          AND item_bord_ap.cod_portador    = bord_ap.cod_portador 
                          AND item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap  ) THEN DO:
                CREATE tt-retorno.
                ASSIGN tt-retorno.versao-api   = c-versao-api 
                       tt-retorno.cod-status   = 201
                       tt-retorno.desc-retorno = "T°tulo j† est† vinculado no Borderì: ".
                      
                if  tt_titulos_bord.cod_refer_antecip_pef = "" then
                    assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
                else
                    assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Estab: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                NEXT.
            END.
            
            if v_log_cotac_contrat then do:
                if  tt_titulos_bord.cod_refer_antecip_pef = "" then do: /* titulo */
                    for first tit_ap no-lock
                        where tit_ap.cod_estab       = tt_titulos_bord.cod_estab
                        and   tit_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                        and   tit_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                        and   tit_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                        and   tit_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                        and   tit_ap.cod_parcela     = tt_titulos_bord.cod_parcela: 
                        run pi_set_tit_ap in v_hdl_indic_econ_finalid(input tit_ap.cod_estab, input tit_ap.num_id_tit_ap). 
                    end.                    
                end.
                else do:
                    run pi_set_antecip_pef_pend in v_hdl_indic_econ_finalid(input tt_titulos_bord.cod_estab, input tt_titulos_bord.cod_refer_antecip_pef).
                end.        
            end.

            //----------------------------------------------------------------------------------------------------

            //****************************************************************************************************
            // A PROCEDURE DO BOT«O EXCLUI O REGISTRO, POR ISSO TEM QUE GERAR A MENSAGEM ANTES DE CHAMAR
            //****************************************************************************************************
            if  tt_titulos_bord.cod_refer_antecip_pef = "" then
                assign c-msg-aux = "Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
            else
                assign c-msg-aux = "Estab: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.


            /* ** BUSCA TIT_AP, ANTECIP_PEF ou PROCES_PAGTO CORRESPONDENTE e PRENDE COM EXCLUSIVE-LOCK ***/        
            run pi_botao_down_le_tabelas (input-output v_cod_return) /*pi_botao_down_le_tabelas*/.
            
            if return-value <> "OK" /*l_ok*/  then do:

                CREATE tt-retorno.
                ASSIGN tt-retorno.versao-api = c-versao-api 
                       tt-retorno.cod-status = 201
                       tt-retorno.desc-retorno = "T°tulo n∆o vinculado: " + c-msg-aux.
                       
/*                 if  tt_titulos_bord.cod_refer_antecip_pef = "" then                                                                                                                                                                                           */
/*                     assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela. */
/*                 else                                                                                                                                                                                                                                          */
/*                     assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Estab: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.                                                                                */

                if return-value = "next" /*l_next*/  then
                    next.
                    
                if return-value = "undo next" /*l_undo_next*/  then
                    undo, next.        
            end.        

            //----------------------------------------------------------------------------------------------------

            if  p_ind_modo_pagto <> "Liberaá∆o" /*l_liberacao*/ 
            and  p_ind_modo_pagto <> "Preparaá∆o" /*l_preparacao*/ 
            then do:
                run pi_verifica_permis_pagto (Input p_ind_modo_pagto,
                                              output v_cod_return_liber_pagto,
                                              output v_cod_return) /*pi_verifica_permis_pagto*/.
                if  v_cod_return <> "OK" /*l_ok*/ 
                then do:
                    run pi_msg_validacao_usuario (input v_cod_return,
                                                  input v_cod_return,
                                                  input "Pagto" /*l_pagto*/ ).
                    assign v_log_erro_liber = no.

                    CREATE tt-retorno.
                    ASSIGN tt-retorno.versao-api = c-versao-api 
                           tt-retorno.cod-status = 201
                           tt-retorno.desc-retorno = "T°tulo n∆o vinculado: ".
                       
                    if  tt_titulos_bord.cod_refer_antecip_pef = "" then
                        assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
                    else
                        assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Estab: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                    
                    // alterado undo table_src_a, leave table_src_a.
                    undo, next.
                end.
            end.

            run pi_valida_pgto_selec_cjto_integr_mec.
            if  return-value = "NOK" /*l_nok*/  then
                // alterado undo table_src_a, leave table_src_a.
                undo, next.

            /* ** CRIA ITEM_LOTE DE PAGAMENTO ***/
            if  p_ind_modo_pagto = "Cheque" /*l_cheque*/ 
            or  p_ind_modo_pagto = "Borderì" /*l_bordero*/ 
            then do:

                //----------------------------------------------------------------------------------------------------

                if  tt_titulos_bord.cod_refer_antecip_pef = ""
                then do: /* titulo */

                    //if avail tt_proces_pagto_ant then
                    //    assign v_val_pagto_liber = tt_proces_pagto_ant.val_liber_pagto_orig.
                    
                    assign v_val_pagto_liber = tt_titulos_bord.val_sdo_tit_ap.  
                    

                    run pi_gerar_item_pagto_cjto_titulo (Input "Borderì" /*l_bordero*/,
                                                         Input bord_ap.cod_estab_bord,
                                                         Input bord_ap.dat_transacao,
                                                         Input yes,
                                                         Input "Paga Juros" /*l_paga_juros*/,
                                                         Input bord_ap.cod_indic_econ,
                                                         Input v_val_pagto_liber) /*pi_gerar_item_pagto_cjto_titulo*/.
                    if  return-value <> 'OK'
                    then do:

                        /* @run( pi_msg_erro(return-value) ).*/
                        CREATE tt-retorno.
                        ASSIGN tt-retorno.versao-api = c-versao-api 
                               tt-retorno.cod-status = 201
                               tt-retorno.desc-retorno = "T°tulo n∆o vinculado. Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
                        assign v_log_exist = yes.
                        undo, next.
                    end.
                    create tt_pagamentos_realizados.
                    assign tt_pagamentos_realizados.ttv_rec_item_lote_pagto = recid(item_bord_ap)
                           tt_pagamentos_realizados.ttv_rec_tit_ap          = recid(tit_ap)
                           tt_titulos_bord.log_mostra_tit                   = no.           
                    run pi_nome_abrev_fornec_pagto (Input v_cod_empres_usuar,
                                                    Input recid(tit_ap),
                                                    Input item_bord_ap.cdn_fornecedor) /*pi_nome_abrev_fornec_pagto*/.                           

                    &if defined(BF_FIN_ORIG_GRAOS) &then
                        if  avail item_bord_ap then do:
                            if  v_log_program 
                            and valid-handle(v_hdl_api_graos) then do:
                                run piSugereDadosBancariosOrig in v_hdl_api_graos (INPUT tit_ap.cod_estab,
                                                                                   INPUT tit_ap.num_id_tit_ap,
                                                                                   INPUT ?,
                                                                                   INPUT tit_ap.cod_espec_docto,
                                                                                  OUTPUT v_cod_banco,
                                                                                  OUTPUT v_cod_agenc,
                                                                                  OUTPUT v_cod_digito_agenc,
                                                                                  OUTPUT v_cod_cta_corren,
                                                                                  OUTPUT v_cod_digito_cta_corren).
                                /* Atualiza dados banc†rios*/
                                if v_cod_banco <> "" then
                                    assign item_bord_ap.cod_bco_pagto = v_cod_banco.

                                if v_cod_agenc <> "" then
                                    assign item_bord_ap.cod_agenc_bcia_pagto = v_cod_agenc.

                                if v_cod_digito_agenc <> "" then                        
                                    assign item_bord_ap.cod_digito_agenc_bcia_pagto = v_cod_digito_agenc.

                                if v_cod_cta_corren <> "" then
                                    assign item_bord_ap.cod_cta_corren_bco_pagto = v_cod_cta_corren.

                                if v_cod_digito_cta_corren <> "" then
                                    assign item_bord_ap.cod_digito_cta_corren_pagto = v_cod_digito_cta_corren.
                            end.                       
                        end. 
                    &endif
                end.
                
                //----------------------------------------------------------------------------------------------------

                else do: /* antecipacao */
                
                    find antecip_pef_pend exclusive-lock
                        where antecip_pef_pend.cod_estab = tt_titulos_bord.cod_estab
                        and   antecip_pef_pend.cod_refer = tt_titulos_bord.cod_refer_antecip_pef no-error.
                        
                    if  not avail antecip_pef_pend then do:
                        CREATE tt-retorno.
                        ASSIGN tt-retorno.versao-api   = c-versao-api 
                               tt-retorno.cod-status   = 201
                               tt-retorno.desc-retorno = "T°tulo j† est† vinculado no Borderì: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                        undo, next.                               
                    end.             
    
                    run pi_gerar_item_pagto_cjto_pef (Input "Borderì" /*l_bordero*/,
                                                      Input bord_ap.cod_estab_bord,
                                                      Input bord_ap.dat_transacao,
                                                      Input bord_ap.cod_indic_econ,
                                                      Input tt_param.cod_indic_econ_ini,
                                                      Input tt_param.cod_indic_econ_fim,
                                                      Input tt_param.val_cotac_indic_econ) /*pi_gerar_item_pagto_cjto_pef*/.

                    if  return-value <> 'OK'
                    then do:
                        if  entry(1,return-value) = "358"
                        or   entry(1,return-value) = "335"
                        then do:
                            if v_log_erro_cotac = no then do:
                                run pi_msg_erro (Input return-value) /*pi_msg_erro*/.
                                assign v_log_erro_cotac = yes.
                            end.
                        end.
                        else
                            assign v_log_exist = yes.

                        CREATE tt-retorno.
                        ASSIGN tt-retorno.versao-api = c-versao-api 
                               tt-retorno.cod-status = 201
                               tt-retorno.desc-retorno = "Antecipaá∆o n∆o vinculada: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                        undo, next.
                    end.
                    
                    create tt_pagamentos_realizados.
                    assign tt_pagamentos_realizados.ttv_rec_item_lote_pagto = recid(item_bord_ap)
                           tt_pagamentos_realizados.ttv_rec_tit_ap          = recid(antecip_pef_pend)
                           tt_titulos_bord.log_mostra_tit                   = no.                           
                    run pi_nome_abrev_fornec_pagto (Input v_cod_empres_usuar,
                                                    Input recid(antecip_pef_pend),
                                                    Input item_bord_ap.cdn_fornecedor) /*pi_nome_abrev_fornec_pagto*/.                           
                    &if defined(BF_FIN_ORIG_GRAOS) &then
                        if avail item_bord_ap then do:
                            if  v_log_program 
                            and valid-handle(v_hdl_api_graos) then do:
                                run piSugereDadosBancariosOrig in v_hdl_api_graos (INPUT antecip_pef_pend.cod_estab,
                                                                                   INPUT ?,
                                                                                   INPUT antecip_pef_pend.cod_refer,
                                                                                   INPUT antecip_pef_pend.cod_espec_docto,
                                                                                  OUTPUT v_cod_banco,
                                                                                  OUTPUT v_cod_agenc,
                                                                                  OUTPUT v_cod_digito_agenc,
                                                                                  OUTPUT v_cod_cta_corren,
                                                                                  OUTPUT v_cod_digito_cta_corren).
                                /* Atualiza dados banc†rios*/
                                if v_cod_banco <> "" then
                                    assign item_bord_ap.cod_bco_pagto = v_cod_banco.

                                if v_cod_agenc <> "" then
                                    assign item_bord_ap.cod_agenc_bcia_pagto = v_cod_agenc.

                                if v_cod_digito_agenc <> "" then                        
                                    assign item_bord_ap.cod_digito_agenc_bcia_pagto = v_cod_digito_agenc.

                                if v_cod_cta_corren <> "" then
                                    assign item_bord_ap.cod_cta_corren_bco_pagto = v_cod_cta_corren.

                                if v_cod_digito_cta_corren <> "" then
                                    assign item_bord_ap.cod_digito_cta_corren_pagto = v_cod_digito_cta_corren.                                           
                            end.                       
                        end.
                    &endif
                end /* else */.
            end /* do table_src_a */.

            run pi_cria_epc_titulo /*pi_cria_epc_titulo*/.
            
            if  return-value = 'NOK'
            then do:
                if avail tt_titulos_bord then 
                   assign tt_titulos_bord.log_mostra_tit = yes.

                if avail tt_pagamentos_realizados then
                    delete tt_pagamentos_realizados.

                if avail tt_proces_pagto_ant then
                    delete tt_proces_pagto_ant.

                CREATE tt-retorno.
                ASSIGN tt-retorno.versao-api = c-versao-api 
                       tt-retorno.cod-status = 201
                       tt-retorno.desc-retorno = "T°tulo n∆o vinculado. Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
                // alterado undo table_src_a, leave table_src_a.
                undo, next.
                //return.
            end.
            /* ** LIBERA TODOS OS REGISTROS PRESOS COM EXCLUSIVE-LOCK ***/
            release movto_usuar_financ.
            release acum_pagto_pessoa.
            release tit_ap.
            release antecip_pef_pend.
            release item_bord_ap.
            release item_lote_pagto.
            release proces_pagto.
            
        end. // FOR EACH tt_titulos_bord
    end. // if  v_num_select_row <> 0

    release proces_pagto.
    release tit_ap.
    release antecip_pef_pend.

    if v_log_tit_dupl then do:
        if   p_ind_modo_pagto      = "Borderì" /*l_bordero*/ 
        or   p_ind_modo_pagto      = "Cheque" /*l_cheque*/ 
        or   p_ind_modo_pagto      = "Escritural" /*l_escritural*/ 
        or   p_ind_modo_pagto      = "Dinheiro" /*l_dinheiro*/  then do:
            /* T°tulo com valor comprometido ! */
            run pi_messages (input "show",
                             input 18049, 
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               'pago')) /*msg_18049*/.
        end.
    end.
    
    /*if  v_log_forma
    then do:
        assign v_log_exist = no.
        /* Forma de Pagamento em Branco ! */
        run pi_messages (input "show",
                         input 8519,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8519*/.
    end.*/    
    
    if  v_log_exist = yes
    then do:   /* ** ERRO AO JOGAR P/ BAIXO ***/
        if return-value = "18597" then
            /* Processo de Pagamento Alterado ! */
            run pi_messages (input "show",
                             input 18597,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_18597*/.
        else
            /* Erro na atualizaá∆o ! */
            run pi_messages (input "show",
                             input 22849,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_22849*/.
    end.
    
    if  v_log_erro_liber = yes
    then do:
        /* Problemas com os valores liberados ! */
        run pi_messages (input "show",
                         input 3321,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_3321*/.
    end.

    FOR FIRST item_bord_ap OF bord_ap NO-LOCK:
    END.

    if  tt_param.zerar-total-informado
    or  tt_param.zerar-total-vinculado 
    or  tt_param.alterar-status-impresso then do:

        FOR FIRST bord_ap EXCLUSIVE-LOCK
        WHERE bord_ap.cod_estab_bord = tt_param.cod_estab    
          AND bord_ap.cod_empresa    = tt_param.cod_empresa  
          AND bord_ap.cod_portador   = tt_param.cod_portador 
          AND bord_ap.num_bord_ap    = tt_param.num_bord_ap:
          
            if  tt_param.zerar-total-informado then
                assign bord_ap.val_tot_lote_pagto_infor = 0.
                
            if tt_param.zerar-total-vinculado then
                assign bord_ap.val_tot_lote_pagto_efetd = 0.
                
            if tt_param.alterar-status-impresso then
                ASSIGN bord_ap.ind_sit_bord_ap = "Ja Impresso".

        END.
        
    end. // if  tt_param.zerar-total-informado
    
    CREATE tt-retorno.
    IF  AVAIL item_bord_ap THEN  
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 200
               tt-retorno.desc-retorno = "Processo finalizado. Valor total bruto informado: " + STRING(bord_ap.val_tot_lote_pagto_infor,">>>,>>>,>>>,>>>,>>9.99").
    ELSE
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Nenhum t°tulo foi vinculado ao borderì".
    
    IF VALID-HANDLE(v_hdl_indic_econ_finalid) THEN
        DELETE PROCEDURE v_hdl_indic_econ_finalid.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-imprime-bord:

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_ap
        for tit_ap.
    &endif

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_inss
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_log_test_com_des
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_val_liq_item_bord
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        column-label "Valor L°quido"
        no-undo.


    /************************** Variable Definition End *************************/

    /* ************Pagamento de Tributos *************************/
        find last param_estab_apb no-lock
            where param_estab_apb.cod_estab = bord_ap.cod_estab_bord no-error.
    
        if  avail param_estab_apb and     
        &if '{&emsbas_version}' >= '5.07' &then
            param_estab_apb.log_pagto_sem_desemb_bord
        &else
            (getentryfield(1,param_estab_apb.cod_livre_1,chr(10)) = "yes" /*l_yes*/ )
        &endif    
        then do:
            /* jucinei verificar se todos estao com valor zero, caso sim nenhum item deve ser
               impresso, ou seja n∆o deve ser impreso nem o relatorio*/
            item_BLOCK:
            for each item_bord_ap no-lock
               where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
                 and item_bord_ap.cod_portador   = bord_ap.cod_portador
                 and item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap:
    
                assign v_log_test_com_des = no.
    
                run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                             Input "",
                                                             Input item_bord_ap.num_seq_bord,
                                                             Input item_bord_ap.cod_portador,
                                                             Input item_bord_ap.num_bord_ap,
                                                             Input "Antecipaá∆o" /*l_antecipacao*/,
                                                             output v_log_abat_antecip,
                                                             output v_val_tot_abat_antecip,
                                                             output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.
    
                if item_bord_ap.cod_refer_antecip_pef <> "" and
                   item_bord_ap.cod_refer_antecip_pef <> ? then
                    run prgfin/apb/apb794za.py (Input item_bord_ap.cod_estab,
                                                Input item_bord_ap.cod_refer_antecip_pef,
                                                Input "",
                                                Input 0,
                                                Input 0,
                                                Input yes,
                                                Input bord_ap.dat_transacao,
                                                Input "Retido" /*l_retido*/ ,
                                                output v_log_impto_vincul_refer,
                                                output v_val_tot_impto,
                                                Input recid(bord_ap),
                                                Input recid(cheq_ap),
                                                Input recid(item_lote_pagto)).
                else
                    run prgfin/apb/apb794za.py (Input item_bord_ap.cod_estab_bord,
                                                Input "",
                                                Input bord_ap.cod_portador,
                                                Input bord_ap.num_bord_ap,
                                                Input item_bord_ap.num_seq_bord,
                                                Input yes,
                                                Input bord_ap.dat_transacao,
                                                Input "Retido" /*l_retido*/ ,
                                                output v_log_impto_vincul_refer,
                                                output v_val_tot_impto,
                                                Input ?,
                                                Input ?,
                                                Input ?).
    
                assign v_val_liq_item_bord = item_bord_ap.val_pagto
                                           + item_bord_ap.val_multa_tit_ap
                                           + item_bord_ap.val_juros
                                           + item_bord_ap.val_cm_tit_ap
                                           - item_bord_ap.val_desc_tit_ap
                                           - item_bord_ap.val_abat_tit_ap
                                           - v_val_tot_abat_antecip
                                           - v_val_tot_impto.
    
                if  v_val_liq_item_bord <> 0
                then do:
                    assign v_log_test_com_des = yes.
                    leave item_BLOCK.
                end.
            end.
    
            if  not v_log_test_com_des
            then do:
                /* N∆o existem itens para pagamento via Borderì ! */
                run pi_messages (input "show",
                                 input 18037,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_18037*/.
                return error.
            end.
        end.
    
        if  (v_log_pagto_trib and v_log_bord_dados)
        or  v_log_guia_det
        then do:
    
            for each item_bord_ap no-lock
                where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
                and   item_bord_ap.cod_portador   = bord_ap.cod_portador
                and   item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap:
    
                if  item_bord_ap.cod_refer_antecip_pef <> ""
                then do:
                    if  v_log_guia_det then
                        /* Somente t°tulos poder∆o ser vinculados a este borderì ! */
                        run pi_messages (input "show",
                                         input 11409,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_11409*/.
                    else
                        /* Somente t°tulos poder∆o ser vinculados a este borderì ! */
                        run pi_messages (input "show",
                                         input 14344,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                            "Darf" /*l_darf*/)) /*msg_14344*/.
    
                    return "NOK" /*l_nok*/ .
                end /* if */.
    
                assign v_log_inss = no.
                find first b_tit_ap no-lock
                    where b_tit_ap.cod_estab       = item_bord_ap.cod_estab
                      and b_tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
                      and b_tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
                      and b_tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
                      and b_tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
                      and b_tit_ap.cod_parcela     = item_bord_ap.cod_parcela no-error.
                if  avail b_tit_ap then do:    
                    for each compl_impto_retid_ap no-lock
                        where compl_impto_retid_ap.cod_estab     = b_tit_ap.cod_estab
                        and   compl_impto_retid_ap.num_id_tit_ap = b_tit_ap.num_id_tit_ap:
    
                        if (v_log_guia_det
                        and can-find (first imposto no-lock
                                      where imposto.cod_pais         = compl_impto_retid_ap.cod_pais
                                        and imposto.cod_unid_federac = compl_impto_retid_ap.cod_unid_federac
                                        and imposto.cod_imposto      = compl_impto_retid_ap.cod_imposto
                                        and (imposto.ind_tip_impto   = "Inst Nacional Seguro Social (INSS)" /*l_inst_nacional_seguro_social*/ 
                                         or (v_log_deduc_base_calc_impto and imposto.ind_tip_impto = "SEST/SENAT" /*l_sest/senat*/ ))))
                        or (v_log_pagto_trib and v_log_bord_dados
                        and can-find (first imposto no-lock
                                      where imposto.cod_pais         = compl_impto_retid_ap.cod_pais
                                        and imposto.cod_unid_federac = compl_impto_retid_ap.cod_unid_federac
                                        and imposto.cod_imposto      = compl_impto_retid_ap.cod_imposto
                                        and (imposto.ind_tip_impto    = "Imposto de Renda Retido na Fonte" /*l_imposto_de_renda_retido_na_fon*/ 
                                         or imposto.ind_tip_impto    = "Imposto COFINS  PIS  CSLL Retido" /*l_Imposto_cofins_pis_csll_retido*/ )))
                        then do:
                            assign v_log_inss = yes.
                            leave.
                        end.
    
                    end.
                end.
    
                if  v_log_guia_det = yes and v_log_inss = no
                then do:
                    run pi_procura_compl_impto_retid_ap_sbnd_inss (Input recid(b_tit_ap)) /*pi_procura_compl_impto_retid_ap_sbnd_inss*/.
                    assign v_log_inss = (return-value = 'OK').
                end /* if */.
    
                if  not v_log_inss
                then do:
                    if  v_log_guia_det then
                        /* T°tulos somente podem ser de impostos I.N.S.S e SEST/SENAT ! */
                        run pi_messages (input "show",
                                         input 14237,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_14237*/.
                    else
                        /* Somente ser∆o aceitos T°tulos de Imposto Retido ! */
                        run pi_messages (input "show",
                                         input 13909,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_13909*/.
    
                    return "NOK" /*l_nok*/ .
                end /* if */.
            end.
        end /* if */. 

        ASSIGN bord_ap.ind_sit_bord_ap = "Ja Impresso".
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-busca-bordero-aberto:
    
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt_param.
    DEF OUTPUT          PARAM TABLE FOR tt_bordero.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord AS INTEGER     NO-UNDO.

    FOR FIRST tt_param:
    END.

    IF NOT AVAIL tt_param OR (AVAIL tt_param AND tt_param.cod_empresa = ?) THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Empresa n∆o informada.".
        RETURN.
    END.

    EMPTY TEMP-TABLE tt_bordero.
    RUN pi_inicializa_tt_param (INPUT-OUTPUT TABLE tt_param).
   
    IF AVAIL tt_param THEN DO:
        FOR EACH estabelec NO-LOCK
            WHERE estabelec.cod-estabel >= tt_param.cod_estab_ini
              AND estabelec.cod-estabel <= tt_param.cod_estab_fim:
              
            FOR EACH bord_ap NO-LOCK
                WHERE bord_ap.cod_empresa     = tt_param.cod_empresa 
                  AND bord_ap.cod_estab_bord  = estabelec.cod-estabel
                  AND bord_ap.ind_sit_bord_ap <> "Totalmente Baixado"
                  AND bord_ap.dat_transacao  >= tt_param.dat_inicio
                  AND bord_ap.dat_transacao  <= tt_param.dat_fim:   
                CREATE tt_bordero.
                BUFFER-COPY bord_ap TO tt_bordero.
                ASSIGN tt_bordero.cod_estab = bord_ap.cod_estab_bord.
            END.
        END.
    END.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord = 0 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Nenhum borderì encontrado.".
    END.
    ELSE DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 200
               tt-retorno.desc-retorno = "Busca com sucesso. Borderìs: " + STRING(i-bord).
    END.

END PROCEDURE.

//---------------------------------------------------------------------------------------------------- 

PROCEDURE pi-transfere-bordero:

    DEF INPUT           PARAM TABLE FOR tt_bordero.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord                       AS INTEGER     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    if  avail bord_ap
    then do:
         if  bord_ap.ind_sit_bord_ap <> "Ja Impresso" /*l_ja_impresso*/  
         and bord_ap.ind_sit_bord_ap <> "Em Digitaá∆o" /*l_em_digitacao*/ 
         and bord_ap.ind_sit_bord_ap <> "Transmitir ao Banco" /*l_transmitir_ao_banco*/ 
         then do:
             CREATE tt-retorno.
             ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 201
                    tt-retorno.desc-retorno = "Situaá∆o do Borderì diferente de  J† Impresso ou Em Digitaá∆o".             
             return error.  
         end.
         else do:
             assign v_rec_bord_ap      = recid(bord_ap)
                    v_rec_bord_ap_dest = recid(bord_ap).
             run prgfin/apb/apb007zb.p /*prg_fnc_item_bord_ap_transf*/.
         end.
    end.
    find bord_ap
         where recid(bord_ap) = v_rec_bord_ap no-error.
    
    CREATE tt-retorno.
    ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 200
           tt-retorno.desc-retorno = "Transferido com sucesso. Borderì: " + STRING(bord_ap.num_bord_ap) + " - Situaá∆o: " + bord_ap.ind_sit_bord_ap.  

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-consulta-bordero:
    
    DEF INPUT-OUTPUT PARAM TABLE FOR tt_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord                       AS INTEGER     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        EMPTY TEMP-TABLE tt_bordero.
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.

        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est=" + tt_bordero.cod_estab + "|Nr=" + string(tt_bordero.num_bord_ap) + "|Port=" + tt_bordero.cod_portador .
        EMPTY TEMP-TABLE tt_bordero.
        ASSIGN v_log_erro = YES.
    END.
    ELSE DO:
        DELETE tt_bordero.
        CREATE tt_bordero.
        BUFFER-COPY bord_ap TO tt_bordero.
        ASSIGN tt_bordero.cod_estab = bord_ap.cod_estab_bord.
        
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 200
               tt-retorno.desc-retorno = "Busca borderì executada com sucesso. Est=" + tt_bordero.cod_estab + "|Nr=" + string(tt_bordero.num_bord_ap) + "|Port=" + tt_bordero.cod_portador .
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-consulta-item-bordero:
    
    DEF INPUT           PARAM TABLE FOR tt_bordero.
    DEF OUTPUT          PARAM TABLE FOR tt_titulos_bord.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord                       AS INTEGER     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.
        RETURN.
    END.
    ELSE DO:
        ASSIGN i-bord = 0.
        FOR EACH item_bord_ap OF bord_ap NO-LOCK:
            ASSIGN i-bord = i-bord + 1.
            CREATE tt_titulos_bord.
            BUFFER-COPY item_bord_ap TO tt_titulos_bord.
            ASSIGN tt_titulos_bord.cod_estab = bord_ap.cod_estab_bord.
        END.
    END.

    CREATE tt-retorno.
    ASSIGN tt-retorno.versao-api = c-versao-api.

    IF  i-bord = 0 THEN
        ASSIGN tt-retorno.cod-status   = 201
               tt-retorno.desc-retorno = "N∆o foram encontrados t°tulos/antecipaá‰es para o borderì: Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
    ELSE
        ASSIGN tt-retorno.cod-status   = 200
               tt-retorno.desc-retorno = "Busca de t°tulos do borderì executada com sucesso: Quant T°tulos = " + STRING(i-bord).

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-elimina-bordero:

    DEF INPUT           PARAM TABLE FOR tt_bordero.
    DEF INPUT-OUTPUT    PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord                       AS INTEGER     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.
       
    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.
        RETURN.
    END.
    
    IF bord_ap.ind_sit_bord_ap <> "Em Digitaá∆o" THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì com status indevido: " + bord_ap.ind_sit_bord_ap.
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    IF CAN-FIND(FIRST item_bord_ap OF bord_ap) THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì possui t°tulos vinculados".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    IF v_log_erro = NO THEN DO:
        DELETE bord_ap.
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 200
               tt-retorno.desc-retorno = "Borderì eliminado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-confirma-bordero:
    DEF INPUT PARAM TABLE FOR tt_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE v_log_corrig_val             AS LOGICAL     NO-UNDO INIT YES.
    DEFINE VARIABLE i-bord                       AS INTEGER     NO-UNDO.
    DEFINE VARIABLE v_num_msg_erro               AS INTEGER     NO-UNDO.
    DEFINE VARIABLE p_num_msg_erro               AS INTEGER     NO-UNDO.
    DEFINE VARIABLE p_log_atualiz_tit_impto_vinc AS LOGICAL     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.
        RETURN.
    END.
    
    IF NOT (bord_ap.ind_sit_bord_ap = "Enviado ao Banco"
        or  bord_ap.ind_sit_bord_ap = "Parcialmente Baixado") THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì com status indevido: " + bord_ap.ind_sit_bord_ap.
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    ASSIGN v_dat_confir_bxa_tit_ap = bord_ap.dat_transacao.

    FOR EACH item_bord_ap OF bord_ap
        WHERE item_bord_ap.ind_sit_item_bord_ap = "Em Aberto":
        CREATE tt_item_bord_ap.
        BUFFER-COPY item_bord_ap TO tt_item_bord_ap.
    END.

    if  bord_ap.ind_tip_bord_ap = "Normal" then do:
        RUN pi_vld_item_bord_ap_confirmacao.
    
        FOR EACH tt_log_erros_tit_antecip:
            ASSIGN v_log_erro = YES.
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status  = 201
                   tt-retorno.desc-retorno = tt_log_erros_tit_antecip.ttv_des_msg_erro_1.
        END.
    
        IF v_log_erro = YES THEN
            RETURN.
    
        /* ******************************************
         Chamada RPC
        *******************************************/
        for each tt_exec_rpc:
            delete tt_exec_rpc.
        end.
        create tt_exec_rpc.
        assign tt_exec_rpc.ttv_cod_aplicat_dtsul_corren  = v_cod_aplicat_dtsul_corren 
               tt_exec_rpc.ttv_cod_ccusto_corren         = v_cod_ccusto_corren
               tt_exec_rpc.ttv_cod_dwb_user              = v_cod_dwb_user
               tt_exec_rpc.ttv_cod_empres_usuar          = v_cod_empres_usuar
               tt_exec_rpc.ttv_cod_estab_usuar           = v_cod_estab_usuar 
               tt_exec_rpc.ttv_cod_funcao_negoc_empres   = v_cod_funcao_negoc_empres
               tt_exec_rpc.ttv_cod_grp_usuar_lst         = v_cod_grp_usuar_lst
               tt_exec_rpc.ttv_cod_idiom_usuar           = v_cod_idiom_usuar
               tt_exec_rpc.ttv_cod_modul_dtsul_corren    = v_cod_modul_dtsul_corren
               tt_exec_rpc.ttv_cod_modul_dtsul_empres    = ""
               tt_exec_rpc.ttv_cod_pais_empres_usuar     = v_cod_pais_empres_usuar
               tt_exec_rpc.ttv_cod_plano_ccusto_corren   = v_cod_plano_ccusto_corren
               tt_exec_rpc.ttv_cod_unid_negoc_usuar      = v_cod_unid_negoc_usuar
               tt_exec_rpc.ttv_cod_usuar_corren          = v_cod_usuar_corren
               tt_exec_rpc.ttv_cod_usuar_corren_criptog  = v_cod_usuar_corren_criptog
               tt_exec_rpc.ttv_num_ped_exec_corren       = v_num_ped_exec_corren 
               tt_exec_rpc.ttv_cod_livre                 = string(recid(bord_ap))          + chr(10) +
                                                           string(v_dat_confir_bxa_tit_ap) + chr(10) +
                                                           string(v_log_corrig_val).
      
        for each tt_integr_apb_item_bord exclusive-lock:
            delete tt_integr_apb_item_bord.
        end.

        FOR EACH item_bord_ap OF bord_ap:
            if  not can-find(tt_integr_apb_item_bord_aux no-lock
                       where tt_integr_apb_item_bord_aux.ttv_rec_item_bord_ap = recid(item_bord_ap)) then do:
                       create tt_integr_apb_item_bord_aux.
                       assign tt_integr_apb_item_bord_aux.ttv_rec_item_bord_ap = recid(item_bord_ap)
                              tt_integr_apb_item_bord_aux.tta_dat_pagto        = bord_ap.dat_transacao
                              tt_integr_apb_item_bord_aux.tta_cod_estab_bord   = item_bord_ap.cod_estab_bord
                              tt_integr_apb_item_bord_aux.tta_cod_portador     = item_bord_ap.cod_portador  
                              tt_integr_apb_item_bord_aux.tta_num_bord_ap      = item_bord_ap.num_bord_ap   
                              tt_integr_apb_item_bord_aux.tta_num_seq_bord     = item_bord_ap.num_seq_bord.
                   end.
        END.

        for each tt_integr_apb_item_bord_aux no-lock
            by tt_integr_apb_item_bord_aux.tta_cod_estab_bord 
            by tt_integr_apb_item_bord_aux.tta_cod_portador   
            by tt_integr_apb_item_bord_aux.tta_num_bord_ap    
            by tt_integr_apb_item_bord_aux.tta_num_seq_bord:   
            create tt_integr_apb_item_bord. 
            buffer-copy tt_integr_apb_item_bord_aux  
                except tt_integr_apb_item_bord_aux.tta_cod_estab_bord 
                       tt_integr_apb_item_bord_aux.tta_cod_portador  
                       tt_integr_apb_item_bord_aux.tta_num_bord_ap   
                       tt_integr_apb_item_bord_aux.tta_num_seq_bord  
                to tt_integr_apb_item_bord. 
            
        end.
        for each tt_integr_apb_item_bord_aux no-lock:
            delete tt_integr_apb_item_bord_aux.
        end.

        assign v_cod_aplicat_dtsul_corren = tt_exec_rpc.ttv_cod_aplicat_dtsul_corren
               v_cod_ccusto_corren        = tt_exec_rpc.ttv_cod_ccusto_corren
               v_cod_dwb_user             = tt_exec_rpc.ttv_cod_dwb_user
               v_cod_empres_usuar         = tt_exec_rpc.ttv_cod_empres_usuar
               v_cod_estab_usuar          = tt_exec_rpc.ttv_cod_estab_usuar
               v_cod_funcao_negoc_empres  = tt_exec_rpc.ttv_cod_funcao_negoc_empres
               v_cod_grp_usuar_lst        = tt_exec_rpc.ttv_cod_grp_usuar_lst
               v_cod_idiom_usuar          = tt_exec_rpc.ttv_cod_idiom_usuar
               v_cod_modul_dtsul_corren   = tt_exec_rpc.ttv_cod_modul_dtsul_corren
               v_cod_modul_dtsul_empres   = tt_exec_rpc.ttv_cod_modul_dtsul_empres
               v_cod_pais_empres_usuar    = tt_exec_rpc.ttv_cod_pais_empres_usuar
               v_cod_plano_ccusto_corren  = tt_exec_rpc.ttv_cod_plano_ccusto_corren
               v_cod_unid_negoc_usuar     = tt_exec_rpc.ttv_cod_unid_negoc_usuar
               v_cod_usuar_corren         = tt_exec_rpc.ttv_cod_usuar_corren
               v_cod_usuar_corren_criptog = tt_exec_rpc.ttv_cod_usuar_corren_criptog
               v_num_ped_exec_corren      = tt_exec_rpc.ttv_num_ped_exec_corren
               v_rec_bord_ap              = int64(entry(1,tt_exec_rpc.ttv_cod_livre,chr(10)))
               v_dat_confir_bxa_tit_ap    = date(entry(2,tt_exec_rpc.ttv_cod_livre,chr(10)))
               v_log_corrig_val           = (entry(3,tt_exec_rpc.ttv_cod_livre,chr(10))="yes" /*l_yes*/ ).
    
        RELEASE tt_exec_rpc.

        DEFINE VARIABLE v_cod_indic_econ_estab AS CHARACTER     NO-UNDO.
        DEFINE VARIABLE v_dat_cotac_indic_econ AS DATE        NO-UNDO.
        DEFINE VARIABLE v_val_cotac_indic_econ AS DECIMAL     NO-UNDO.
        run pi_retornar_indic_econ_corren_estab (Input bord_ap.cod_estab_bord,
                                                 Input bord_ap.dat_transacao,
                                                 output v_cod_indic_econ_estab) /*pi_retornar_indic_econ_corren_estab*/.

        run prgfin/apb/apb716zg.py (INPUT 1,
                                    Input TABLE tt_exec_rpc,
                                    INPUT TABLE tt_integr_apb_item_bord,
                                    INPUT-OUTPUT TABLE tt_log_erros_tit_antecip,
                                    OUTPUT p_num_msg_erro,
                                    INPUT p_log_atualiz_tit_impto_vinc).
    
        find first tt_log_erros_tit_antecip no-lock no-error.
        if  avail tt_log_erros_tit_antecip
        then do:
            if  avail tt_log_erros_tit_antecip
            then do:
                tt_block:
                for each tt_log_erros_tit_antecip :
                        CREATE tt-retorno.
                        ASSIGN tt-retorno.versao-api = c-versao-api 
                               tt-retorno.cod-status = 201
                               tt-retorno.desc-retorno = tt_log_erros_tit_antecip.ttv_des_msg_erro_1.
                end /* for tt_block */.
            end /* if */.
            //run prgfin/apb/apb715za.py (Input "Borderì") /*prg_fnc_log_erros_tit_antecip_cheq*/.
            assign v_num_msg_erro = 2387.
        end /* if */.
    end /* if */.
    else do transaction:
        if  v_dat_confir_bxa_tit_ap < bord_ap.dat_transacao
        then do:
           /* Data Baixa deve ser maior ou igual a Data do Borderì*/
           run pi_messages (input "show",
                            input 2471,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               v_dat_confir_bxa_tit_ap, bord_ap.dat_transacao)) /*msg_2471*/.
           return error.
        end /* if */.
        for each tt_cheq_adm_cancel:
            find cheq_ap exclusive-lock where 
                 cheq_ap.cod_estab_cheq = tt_cheq_adm_cancel.cod_estab_cheq and
                 cheq_ap.num_id_cheq_ap = tt_cheq_adm_cancel.num_id_cheq_ap use-index cheqap_token
                 no-error.
            if  avail cheq_ap
            then do:
                assign cheq_ap.ind_sit_cheq_administ    = "Cancelado" /*l_cancelado*/ 
                       cheq_ap.dat_cancel_cheq_administ = v_dat_confir_bxa_tit_ap.
            end /* if */.
        end.
        find bord_ap where recid(bord_ap) = v_rec_bord_ap exclusive-lock no-error.
        if  not can-find(first cheq_ap where
            cheq_ap.cod_estab_bord  = bord_ap.cod_estab_bord and
            cheq_ap.num_bord_ap     = bord_ap.num_bord_ap    and
            cheq_ap.cod_portador    = bord_ap.cod_portador   and
            cheq_ap.ind_sit_cheq_administ    <> "Cancelado" /*l_cancelado*/ )
        then do:
            assign bord_ap.ind_sit_bord_ap = "Totalmente Baixado" /*l_totalmente_baixado*/ .
        end /* if */.
        else do:
            if  can-find(first cheq_ap where
                cheq_ap.cod_estab_bord  = bord_ap.cod_estab_bord and
                cheq_ap.num_bord_ap     = bord_ap.num_bord_ap    and
                cheq_ap.cod_portador    = bord_ap.cod_portador   and
                cheq_ap.ind_sit_cheq_administ  <>  "Cancelado" /*l_cancelado*/ )
            then do:
                assign bord_ap.ind_sit_bord_ap = "Parcialmente Baixado" /*l_parcialmente_baixado*/ .
            end /* if */.
            else do:
                assign bord_ap.ind_sit_bord_ap = "Enviado ao Banco" /*l_enviado_ao_banco*/ .
            end /* else */.
        end /* else */.
    end /* else */.
    
    IF NOT CAN-FIND(FIRST tt-retorno) THEN  DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 200
               tt-retorno.desc-retorno = "Processo finalizado. Status: " + bord_ap.ind_sit_bord_ap.
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-transmitir-banco:
    DEF INPUT PARAM TABLE FOR tt_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord AS INTEGER     NO-UNDO.


    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 902
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.

        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api
               tt-retorno.cod-status = 903
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.

        RETURN.
    END.

    IF AVAIL bord_ap
        AND bord_ap.ind_sit_bord_ap <> "Transmitir ao Banco" THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 901
               tt-retorno.desc-retorno = "Status inv†lido para transmiss∆o: " + bord_ap.ind_sit_bord_ap .
        ASSIGN v_log_erro = YES.

        RETURN.
    END.

    IF v_log_erro = NO THEN DO:
        
        create tt_param_api_enviar_msg_pagto.
        assign tt_param_api_enviar_msg_pagto.tta_ind_dwb_set_type       = "Regra"
               tt_param_api_enviar_msg_pagto.tta_num_dwb_order          = 999
               tt_param_api_enviar_msg_pagto.ttv_ind_sel_indual_conjto  = "Individual" /*l_single*/ 
               tt_param_api_enviar_msg_pagto.ttv_ind_pagto_ocor_bord_ap = "Pagamento" /*l_pagamento*/ 
               tt_param_api_enviar_msg_pagto.ttv_cod_estab_ini          = tt_bordero.cod_estab
               tt_param_api_enviar_msg_pagto.ttv_cod_estab_fim          = tt_bordero.cod_estab
               tt_param_api_enviar_msg_pagto.ttv_cod_portador_ini       = tt_bordero.cod_portador
               tt_param_api_enviar_msg_pagto.ttv_cod_portador_fim       = tt_bordero.cod_portador
               tt_param_api_enviar_msg_pagto.ttv_num_bord_ap_ini        = tt_bordero.num_bord_ap
               tt_param_api_enviar_msg_pagto.ttv_num_bord_ap_fim        = tt_bordero.num_bord_ap.

        run prgfin/apb/apb760za.py (INPUT 1).

        if  can-find(first tt_item_bord_ap_situacao_envio no-lock
            where tt_item_bord_ap_situacao_envio.ttv_log_situacao = yes) THEN DO:


            FOR FIRST bord_ap NO-LOCK
                WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
                  AND bord_ap.cod_portador   = tt_bordero.cod_portador  
                  AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
            END.
            
            CREATE tt-retorno.               
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status   = 900
                   tt-retorno.desc-retorno = "Envio realizado com sucesso. Status: " + bord_ap.ind_sit_bord_ap.
        END.
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi-envio-banco:

    DEF INPUT PARAM TABLE FOR tt_bordero.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-retorno.

    DEFINE VARIABLE i-bord AS INTEGER     NO-UNDO.

    ASSIGN i-bord = 0.
    FOR EACH tt_bordero:
        ASSIGN i-bord = i-bord + 1.
    END.

    IF i-bord <> 1 THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Dever† ser informado apenas um borderì".
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    FOR FIRST tt_bordero:
    END.

    //ASSIGN v_cod_empres_usuar = tt_bordero.cod_empresa.

    FOR FIRST bord_ap
        WHERE bord_ap.cod_estab_bord = tt_bordero.cod_estab
          AND bord_ap.cod_portador   = tt_bordero.cod_portador  
          AND bord_ap.num_bord_ap    = tt_bordero.num_bord_ap:
    END.

    IF NOT AVAIL bord_ap THEN DO:
        
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201
               tt-retorno.desc-retorno = "Borderì n∆o encontrado. Est: " + tt_bordero.cod_estab + "|Nr: " + string(tt_bordero.num_bord_ap) + "|Port:" + tt_bordero.cod_portador .
        ASSIGN v_log_erro = YES.
        RETURN.
    END.

    IF bord_ap.ind_sit_bord_ap = "Em Digitaá∆o" THEN 
        RUN pi-imprime-bord.

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_cheq_ap
        for cheq_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap
        for item_bord_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_ap_aux
        for tit_ap.
    &endif

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_erro_aux
        as character
        format "x(200)":U
        label "Erro RPC AUX"
        column-label "Erro"
        no-undo.
    def var v_des_erro_rpc
        as character
        format "x(200)":U
        label "Erro RPC"
        column-label "Erro RPC"
        no-undo.
    def var v_des_msg_cta
        as character
        format "x(40)":U
        no-undo.
    def var v_des_param_cta
        as character
        format "x(40)":U
        no-undo.
    def var v_log_answer
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        no-undo.
    def var v_log_erro
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_log_pagto_sem_desemb
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Sem Desembolso"
        column-label "Sem Desembolso"
        no-undo.
    def var v_log_rpc
        as logical
        format "Sim/N∆o"
        initial no
        label "RPC"
        column-label "RPC"
        no-undo.
    def var v_num_msg_cta
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_rec_aux
        as recid
        format ">>>>>>9":U
        no-undo.
    def var v_val_liq_item_bord
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        column-label "Valor L°quido"
        no-undo.
    def var v_val_liq_item_bord_aux
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        column-label "Valor L°quido"
        no-undo.
    def var v_wgh_servid_rpc
        as widget-handle
        format ">>>>>>9":U
        label "Handle RPC"
        column-label "Handle RPC"
        no-undo.
		
    def var v_cod_indic_econ_estab               as character       no-undo. /*local*/
    def var v_cod_param_1                        as character       no-undo. /*local*/
    def var v_cod_param_2                        as character       no-undo. /*local*/
    def var v_cod_return                         as character       no-undo. /*local*/
    def var v_des_param                          as character       no-undo. /*local*/
    def var v_log_exec_epc                       as logical         no-undo. /*local*/
    def var v_num_cont                           as integer         no-undo. /*local*/
    def var v_num_mensagem                       as integer         no-undo. /*local*/
	
    DEFINE VARIABLE v_log_aux_1                  AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_log_localiz_mex            AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_hdl_funcao_mex             AS HANDLE          NO-UNDO.
    DEFINE VARIABLE v_val_tot_desemb             AS DECIMAL         NO-UNDO.
    DEFINE VARIABLE v_cod_return_aux             AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE v_cod_cta_ctbl_db            AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE v_cod_imposto                AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE v_log_achou_1                AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_log_atualiz_tit_impto_vinc AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_val_cotac_indic_econ       AS DECIMAL         NO-UNDO.
    DEFINE VARIABLE v_log_fornec_aux             AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_dat_cotac_indic_econ       AS DATE            NO-UNDO.
    DEFINE VARIABLE v_val_aux                    AS DECIMAL         NO-UNDO.
    DEFINE VARIABLE v_log_retorno                AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_log_bloq_pagto             AS LOGICAL         NO-UNDO.
    DEFINE VARIABLE v_log_aux_2                  AS LOGICAL         NO-UNDO.

    /************************** Variable Definition End *************************/

    /* Begin_Include: i_pi_choose_bt_send_bord_ap */
    assign v_log_exec_epc = (v_nom_prog_upc  <> '' 
                             or v_nom_prog_appc <> ''
                             or v_nom_prog_dpc <> '').

    if  v_log_exec_epc
    then do:
        assign v_log_return_epc = no.
        run pi_exec_program_epc_FIN (Input 'altera_bordero',
                                     Input "yes" /*l_yes*/,
                                     output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
        if v_log_return_epc then
            return.
    end /* if */.

    assign v_num_count = 0
           v_des_seq_item_bord_ap = ""
           v_log_aux_1 = no.
    for each item_bord_ap no-lock
        where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
        and item_bord_ap.cod_portador = bord_ap.cod_portador
        and item_bord_ap.num_bord_ap = bord_ap.num_bord_ap:
        assign v_num_count = v_num_count + 1. 
    end.

    if  (avail bord_ap) and (not can-find(first estabelecimento 
                                where estabelecimento.cod_estab   = bord_ap.cod_estab_bord
                                and   estabelecimento.cod_empresa = v_cod_empres_usuar))
    then do:
        /* Usu†rio sem permiss∆o para enviar o borderì ! */
        run pi_messages (input "show",
                         input 13846,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_13846*/.
        return "NOK" /*l_nok*/ .
    end /* if */.

    assign v_num_cont = 0.
    finalid_block:
    for each finalid_econ
        where finalid_econ.ind_armaz_val = "M¢dulos" /*l_modulos*/  no-lock:
        assign v_num_cont = v_num_cont + 1.
        if v_num_cont = 2 then leave finalid_block.
    end.

    if v_num_cont = 2 then do:

        run prgfin/apb/apb516za.py (Input bord_ap.cod_estab,
                                    Input "",
                                    Input bord_ap.cod_portador,
                                    Input bord_ap.num_bord_ap,
                                    Input "Borderì" /*l_bordero*/) /*prg_fnc_parid_indic_econ*/.                                

        if return-value <> "" then do:
            assign v_cod_return = return-value + ",,,,,,,,,".
            assign v_num_mensagem = integer(getentryfield(1,v_cod_return,',')).
           
            /* Aviso sobre a paridade entre os indicadores econìmicos ! */
            run pi_messages (input "show",
                             input 18212,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                                    if num-entries(v_cod_return) >= 2 then entry(2,v_cod_return) else "",                     if num-entries(v_cod_return) >= 3 then entry(3,v_cod_return) else "")) /*msg_18212*/.
        end.
    end. // if v_num_cont = 2 

    &if defined(BF_FIN_FLUIG) &then
        assign v_rec_aux = recid(bord_ap)
               v_log_aux = no.
        assign v_cod_workflow   = ""
               v_log_answer_vld = no.
        for each tt_cheq_ap exclusive-lock:
            delete tt_cheq_ap.
        end.
    &endif

    if  v_log_exec_epc
    then do:
        assign v_log_return_epc = no.
        run pi_exec_program_epc_FIN (Input 'valida_atualiz_bordero',
                                     Input "yes" /*l_yes*/,
                                     output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
        if v_log_return_epc then
            return.
    end /* if */.

    if  bord_ap.ind_tip_bord_ap = "Normal" /*l_normal*/ 
    then do:
	
        IF v_log_localiz_mex THEN /* silvia verificar outro lugar */
            run prgfin/lmx/lmx800za.py /*prg_fnc_bord_ap_pagto_max_lmx*/ persistent set v_hdl_funcao_mex.

        assign v_log_bxo_estab_tit = no.

        if  v_log_bxo_estab
        and avail bord_ap
        &if '{&emsuni_version}' < '5.06' &then
             and GetEntryField(2,bord_ap.cod_livre_1,chr(10)) = "yes" /*l_yes*/  then
                 assign v_log_bxo_estab_tit = yes.
        &else
             and bord_ap.log_bxa_estab_tit_ap = yes then
                 assign v_log_bxo_estab_tit = yes.
        &endif

        find first cart_bcia no-lock where cart_bcia.ind_tip_cart_bcia = "Contas a Pagar" /*l_contas_a_pagar*/  no-error.
        if avail cart_bcia then
            find first portad_finalid_econ no-lock
                where portad_finalid_econ.cod_estab        = bord_ap.cod_estab
                  and portad_finalid_econ.cod_portador     = bord_ap.cod_portador    
                  and portad_finalid_econ.cod_cart_bcia    = cart_bcia.cod_cart_bcia   
                  and portad_finalid_econ.cod_finalid_econ = bord_ap.cod_finalid_econ no-error.
        assign v_des_msg_cta = "".

        item_block:
        for each b_item_bord_ap no-lock
           where b_item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
             and b_item_bord_ap.cod_portador   = bord_ap.cod_portador
             and b_item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap:

            /* Begin_Include: i_pi_choose_bt_send_bord_ap_4 */
            if v_log_bxo_estab_tit then do:
                
                find FIRST espec_docto no-lock
                     where espec_docto.cod_espec_docto = b_item_bord_ap.cod_espec_docto no-error.

                assign v_val_tot_desemb = 0.
                if avail espec_docto
                    and espec_docto.ind_tip_espec_docto = "Normal" /*l_normal*/  then do:
                    run pi_verificar_abat_antecip_voucher (Input bord_ap.cod_estab_bord,
                                                           Input "",
                                                           Input b_item_bord_ap.num_seq_bord,
                                                           Input bord_ap.cod_portador,
                                                           Input bord_ap.num_bord_ap,
                                                           Input "Antecipaá∆o" /*l_antecipacao*/ ,
                                                           output v_log_abat_antecip,
                                                           output v_val_tot_abat_antecip) /* pi_verificar_abat_antecip_voucher*/.

                    run prgfin/apb/apb794za.py (Input bord_ap.cod_estab_bord,
                                                Input "",
                                                Input bord_ap.cod_portador,
                                                Input bord_ap.num_bord_ap,
                                                Input b_item_bord_ap.num_seq_bord,
                                                Input yes,
                                                Input bord_ap.dat_transacao,
                                                Input "Retido" /*l_retido*/ ,
                                                output v_log_impto_vincul_refer,
                                                output v_val_tot_impto,
                                                Input ?,
                                                Input ?,
                                                Input ?) /* prg_fnc_verificar_impto_vincul_refer*/.
                end.
                else do:
                    assign v_val_tot_abat_antecip = 0.
                    run prgfin/apb/apb794za.py (Input b_item_bord_ap.cod_estab,
                                                Input b_item_bord_ap.cod_refer_antecip_pef,
                                                Input "",
                                                Input 0,
                                                Input 0,
                                                Input yes,
                                                Input bord_ap.dat_transacao,
                                                Input "Retido" /*l_retido*/ ,
                                                output v_log_impto_vincul_refer,
                                                output v_val_tot_impto,
                                                Input recid(bord_ap),
                                                Input recid(cheq_ap),
                                                Input recid(item_lote_pagto)) /* prg_fnc_verificar_impto_vincul_refer*/.

/*                     run pi_validar_impto_impl_pend_antecip (Input b_item_bord_ap.cod_estab, */
/*                                                             Input b_item_bord_ap.cod_refer_antecip_pef, */
/*                                                             Input "", */
/*                                                             Input 0, */
/*                                                             Input 0, */
/*                                                             Input "Retido" /*l_retido*/ , */
/*                                                             Input bord_ap.dat_transacao, */
/*                                                             output v_cod_return_aux, */
/*                                                             output v_cod_cta_ctbl_db, */
/*                                                             output v_cod_imposto) /* pi_validar_impto_impl_pend_antecip*/. */
/*                     if v_cod_return_aux <> "OK" /*l_ok*/   then do: */
/*                         /* Conta DÇbito Antecipaá∆o utiliza Centro de Custo ! */ */
/*                         run pi_messages (input "show", */
/*                                          input 9440, */
/*                                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", */
/*                                                            v_cod_cta_ctbl_db, v_cod_imposto)) /*msg_9440*/. */
/*                         return. */
/*                     end. */
                end.

                /* End_Include: i_pi_validar_item_bord_ap_individual_2 */

                /* Chamada realizada para obter o valor do imposto da AN vinculada, porque
                   nesse momento o valor ficou zerado - jucinei */
                for each tt_impostos_abat:
                    delete tt_impostos_abat.
                end.

                find first fornecedor no-lock 
                    where fornecedor.cdn_fornecedor  = b_item_bord_ap.cdn_fornecedor no-error.
                if avail fornecedor and
                   &if '{&emsfin_version}' > '5.05' &then
                   fornecedor.log_retenc_impto_pagto
                   &else
                   (getentryfield(2,fornecedor.cod_livre_1,chr(10)) = "yes" /*l_yes*/ )
                   &endif then do:
                    if avail imposto and imposto.ind_tip_impto = "Imposto COFINS  PIS  CSLL Retido" /*l_Imposto_cofins_pis_csll_retido*/  THEN DO: // novo
                       run pi_verif_an_com_pis_cofins_csll (output v_log_achou_1) /* pi_verif_AN_com_pis_cofins_csll*/.
                    END. // novo
                end.
				
                if v_log_achou_1 then do:
                    run pi_verificar_abat_antecip_voucher_pis_cofins_csll (Input b_item_bord_ap.cod_estab,
                                                                           Input b_item_bord_ap.cod_refer_antecip_pef,
                                                                           Input b_item_bord_ap.cod_portador,
                                                                           Input b_item_bord_ap.num_bord_ap,
                                                                           Input b_item_bord_ap.num_seq_bord,
                                                                           Input "",
                                                                           Input "",
                                                                           Input "",
                                                                           Input "",
                                                                           Input bord_ap.cod_indic_econ,
                                                                           Input bord_ap.dat_transacao,
                                                                           output v_val_tot_abat_antecip_aux) /* pi_verificar_abat_antecip_voucher_pis_cofins_csll*/.
                end.

                assign v_val_tot_desemb = b_item_bord_ap.val_pagto + b_item_bord_ap.val_multa_tit_ap
                                        + b_item_bord_ap.val_juros + b_item_bord_ap.val_cm_tit_ap
                                        - b_item_bord_ap.val_desc_tit_ap - b_item_bord_ap.val_abat_tit_ap
                                        - v_val_tot_abat_antecip       - v_val_tot_impto.

                for each tt_impostos_abat:
                    assign v_val_tot_desemb = v_val_tot_desemb - tt_impostos_abat.tta_val_imposto.
                end.

                if v_val_tot_desemb > 0 then do: /* pagamento com desembolso*/        

                    if avail portad_finalid_econ then do:
                        find first cta_corren no-lock
                             where cta_corren.cod_cta_corren = portad_finalid_econ.cod_cta_corren no-error.
                        if avail cta_corren then do:
                            find first b_portad_finalid_econ no-lock        
                                where b_portad_finalid_econ.cod_estab        = b_item_bord_ap.cod_estab
                                  and b_portad_finalid_econ.cod_portador     = b_item_bord_ap.cod_portador 
                                  and b_portad_finalid_econ.cod_cart_bcia    = cart_bcia.cod_cart_bcia 
                                  and b_portad_finalid_econ.cod_finalid_econ = bord_ap.cod_finalid_econ no-error.
                            if avail b_portad_finalid_econ then do:
                                find first b_cta_corren no-lock
                                    where b_cta_corren.cod_cta_corren = b_portad_finalid_econ.cod_cta_corren no-error.
                                if avail b_cta_corren
                                    and b_cta_corren.cod_cta_corren <> cta_corren.cod_cta_corren then
                                    assign v_num_msg_cta = 18678
                                           v_des_msg_cta = v_des_msg_cta + string(b_item_bord_ap.num_seq_bord) + "/" + b_item_bord_ap.cod_estab + chr(10).
                            end.
                            else /* finalidade economica nao existente para o portador do item*/
                                assign v_num_msg_cta   = 18681
                                       v_des_param_cta = bord_ap.cod_finalid_econ     + chr(10) + 
                                                         b_item_bord_ap.cod_portador  + chr(10) +
                                                         b_item_bord_ap.cod_estab
                                       v_des_msg_cta = v_des_msg_cta + string(b_item_bord_ap.num_seq_bord) + "/" + b_item_bord_ap.cod_estab + chr(10).
									   
                        end. // if avail cta_corren 
                    end. // if avail portad_finalid_econ 
                end. // if v_val_tot_desemb > 0         
            end. // if v_log_bxo_estab_tit 

            /* End_Include: i_pi_choose_bt_send_bord_ap_4 */

            find  tit_ap no-lock
                  where tit_ap.cod_estab       = b_item_bord_ap.cod_estab
                  and   tit_ap.cod_espec_docto = b_item_bord_ap.cod_espec_docto
                  and   tit_ap.cod_ser_docto   = b_item_bord_ap.cod_ser_docto
                  and   tit_ap.cdn_fornecedor  = b_item_bord_ap.cdn_fornecedor
                  and   tit_ap.cod_tit_ap      = b_item_bord_ap.cod_tit_ap
                  and   tit_ap.cod_parcela     = b_item_bord_ap.cod_parcela no-error.

			if  avail tit_ap then do:

                if tit_ap.val_entr_transf_estab <> 0 
                and b_item_bord_ap.cod_refer_antecip_pef = "" then do:

/*                    /* O t°tulo &1 n∆o poder† ser anexado ao borderì ! */                    */
/*                    run pi_messages (input "show",                                           */
/*                                     input 13058,                                            */
/*                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", */
/*                                                       tit_ap.cod_tit_ap)) /*msg_13058*/.    */
                   return.
                end.

                assign v_cod_param_1 = "" /*l_*/ 
                       v_cod_param_2 = "" /*l_*/ .
                if  tit_ap.cod_indic_econ = bord_ap.cod_indic_econ then do:

                    if  b_item_bord_ap.val_pagto <> b_item_bord_ap.val_pagto_orig then
                        assign v_cod_param_1 = "Pagamento" /*l_pagamento*/ 
                               v_cod_param_2 = "Original" /*l_original*/ .
                    else do:
                        if  b_item_bord_ap.val_desc_tit_ap <> b_item_bord_ap.val_desc_tit_ap_orig then
                            assign v_cod_param_1 = "Desconto" /*l_desconto*/ 
                                   v_cod_param_2 = "Desconto Original" /*l_desconto_original*/ .
                    end.

                    if  v_cod_param_1 <> "" /*l_*/  then do:
                        /* Valor de &1 diferente do valor &2 ! */
                        CREATE tt-retorno.
                        ASSIGN tt-retorno.versao-api = c-versao-api 
                               tt-retorno.cod-status = 17958
                               tt-retorno.desc-retorno = "Valor de " + v_cod_param_1 + " diferente do valor " + v_cod_param_2 + " !".
                        return.
                    end.
                end.

                /* Begin_Include: i_pi_choose_bt_send_bord_ap_5 */
                &if defined(BF_FIN_ORIG_GRAOS) &then

                  if v_log_program then do:

                    for each tt_retorno_tit_ap:
                       delete tt_retorno_tit_ap.                           
                    end.

                    create tt_retorno_tit_ap.
                    buffer-copy tit_ap to tt_retorno_tit_ap.
                    if valid-handle(v_hdl_api_graos) then DO: // novo
                        run piAtzSaldoExtTitAp in v_hdl_api_graos (INPUT TABLE tt_retorno_tit_ap). 
                    END. // novo
                        
                  end.
                &endif
                /* End_Include: i_pi_choose_bt_send_bord_ap_5 */
            end. // if  avail tit_ap 
			
            if 
            &if '{&emsbas_version}' >= '5.07' &then
                b_item_bord_ap.log_pagto_sem_desemb
            &else
                (getentryfield(7,b_item_bord_ap.cod_livre_1,chr(10)) = "yes" /*l_yes*/ )
            &endif
            then do:
                create tt_titulos_msg_alerta.
                assign tt_titulos_msg_alerta.tta_cod_estab             = b_item_bord_ap.cod_estab
                       tt_titulos_msg_alerta.tta_cod_espec_docto       = b_item_bord_ap.cod_espec_docto
                       tt_titulos_msg_alerta.tta_cod_ser_docto         = b_item_bord_ap.cod_ser_docto
                       tt_titulos_msg_alerta.tta_cdn_fornecedor        = b_item_bord_ap.cdn_fornecedor
                       tt_titulos_msg_alerta.tta_cod_refer_antecip_pef = ""
                       tt_titulos_msg_alerta.tta_cod_tit_ap            = b_item_bord_ap.cod_tit_ap
                       tt_titulos_msg_alerta.tta_cod_parcela           = b_item_bord_ap.cod_parcela.
            end.
			
            find FIRST forma_pagto
                of b_item_bord_ap no-lock no-error.
            
			if avail forma_pagto 
            and forma_pagto.ind_bxa_tit_ap      = "No Envio ao Banco" /*l_no_envio_ao_banco*/  then do:

                if b_item_bord_ap.dat_vencto_tit_ap <> bord_ap.dat_transacao then do:

                    find tit_ap of b_item_bord_ap no-lock no-error.

                    if avail tit_ap then do:

                        find movto_tit_ap no-lock
                            where movto_tit_ap.cod_estab     = tit_ap.cod_estab
                              and movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap
                              and movto_tit_ap.ind_trans_ap  = "Implantaá∆o" /*l_implantacao*/  no-error.
                        if avail movto_tit_ap then do:
                            for each compl_impto_retid_ap no-lock
                               where compl_impto_retid_ap.cod_estab               = movto_tit_ap.cod_estab
                                 and compl_impto_retid_ap.num_id_movto_tit_ap_pai = movto_tit_ap.num_id_movto_tit_ap:
                               find classif_impto of compl_impto_retid_ap no-lock no-error.
                               if avail classif_impto then do:
                                   find imposto of classif_impto no-lock no-error.
                                   if avail imposto then do:
                                       if imposto.ind_tip_impto = "Imposto COFINS  PIS  CSLL Retido" /*l_Imposto_cofins_pis_csll_retido*/   then do:
                                           find b_tit_ap_aux no-lock
                                               where b_tit_ap_aux.cod_estab     = compl_impto_retid_ap.cod_estab
                                                 and b_tit_ap_aux.num_id_tit_ap = compl_impto_retid_ap.num_id_tit_ap no-error.
                                           if avail b_tit_ap_aux and b_tit_ap_aux.val_sdo_tit_ap <> 0
                                                   and v_log_aux_1 = no then do:
                                               /*run pi_messages (input "show",
                                                                input 13197,
                                                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                                               assign v_log_answer = (if   return-value = "yes" then YES //daniele - verificar tratativa por parametro
                                                                      else if return-value = "no" then no
                                                                      else ?) /*msg_13197*/.*/
                                               assign v_log_answer = YES.
                                               assign v_log_atualiz_tit_impto_vinc = v_log_answer
                                                      v_log_aux_1 = yes.
                                           end.
                                       end.
                                   end.
                               end.
                           end.
                        end.
                    end.
                end.
            end. // if avail forma_pagto 

            if bord_ap.log_bord_ap_escrit = yes then do:
                if avail tit_ap then do:
                    if tit_ap.cb4_tit_ap_bco_cobdor = "" then do:
                        find FIRST forma_pagto  NO-LOCK
                            where forma_pagto.cod_forma_pagto = b_item_bord_ap.cod_forma_pagto no-error.
                        if avail forma_pagto THEN DO: // novo
                            &if '{&emsfin_version}' >= "5.02" &then
                                if forma_pagto.ind_tip_forma_pagto = "Boleto" /*l_boleto*/  then
                                    assign v_des_seq_item_bord_ap = v_des_seq_item_bord_ap + chr(10) +
                                                                    string(b_item_bord_ap.num_seq_bord).
                            &else
                                if getentryfield(1,forma_pagto.cod_livre_1,chr(24)) = "Boleto" /*l_boleto*/  then
                                    assign v_des_seq_item_bord_ap = v_des_seq_item_bord_ap + chr(10) +
                                                                    string(b_item_bord_ap.num_seq_bord).
                            &endif. 
                        END. // novo
                    end.
                end.
            end.

            if not v_log_bxo_estab
            or (v_log_bxo_estab
            &if '{&emsuni_version}' < '5.06' &then
            and num-entries(bord_ap.cod_livre_1, chr(10)) >= 2
            and getentryfield(2,bord_ap.cod_livre_1,chr(10)) = "no" /*l_no*/ )
            &else
            and bord_ap.log_bxa_estab_tit_ap = no)
            &endif
            and b_item_bord_ap.cod_estab <> bord_ap.cod_estab_bord then do:

                assign v_cod_return = "OK" /*l_ok*/ .
                if  b_item_bord_ap.cod_refer_antecip_pef <> "" THEN 
                    run pi_validar_unid_negoc_antecip_pef_pend_dest (Input b_item_bord_ap.cod_estab,
                                                                     Input bord_ap.cod_estab,
                                                                     Input b_item_bord_ap.cod_refer_antecip_pef,
                                                                     Input bord_ap.dat_transacao,
                                                                     output v_cod_return) /*pi_validar_unid_negoc_antecip_pef_pend_dest*/.
                else
                    run pi_validar_unid_negoc_estab_dest (Input tit_ap.cod_estab,
                                                          Input bord_ap.cod_estab_bord,
                                                          Input tit_ap.num_id_tit_ap,
                                                          Input bord_ap.dat_transacao,
                                                          output v_cod_return) /*pi_validar_unid_negoc_estab_dest*/.

                /* Begin_Include: i_pi_choose_bt_send_bord_ap_2 */
                if  v_cod_return <> "OK" /*l_ok*/  then do:
                    run pi_messages (input "msg" /*l_show*/ ,
                                     input int(getentryfield(1, v_cod_return, ',')),
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                       if num-entries(v_cod_return) >= 2 then entry(2,v_cod_return) else "",
                                                       if num-entries(v_cod_return) >= 3 then entry(3,v_cod_return) else "",
                                                       if num-entries(v_cod_return) >= 4 then entry(4,v_cod_return) else "")).
                    return.
                end.
                /* End_Include: i_pi_choose_bt_send_bord_ap_2 */
            end.

            /* Inclus∆o da pi, pelo usu†rio bre17230 */
            assign v_log_erro = no.
			run pi_validar_movtos_dat_transacao (Input b_item_bord_ap.cod_estab,
                                                 Input b_item_bord_ap.cdn_fornecedor,
                                                 Input b_item_bord_ap.cod_espec_docto,
                                                 Input b_item_bord_ap.cod_ser_docto,
                                                 Input b_item_bord_ap.cod_tit_ap,
                                                 Input b_item_bord_ap.cod_parcela,
                                                 Input bord_ap.dat_transacao,
                                                 output v_log_erro) /*pi_validar_movtos_dat_transacao*/.

            if  v_log_erro = yes
            then do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab     = b_item_bord_ap.cod_estab
                       tt_log_erros_atualiz.tta_num_seq_refer = b_item_bord_ap.num_seq_bord
                       tt_log_erros_atualiz.ttv_num_mensagem  = 12987.
                run pi_messages (Input "Msg" /*l_msg*/ ,
                                 Input tt_log_erros_atualiz.ttv_num_mensagem,
                                 Input substitute("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value
                       tt_log_erros_atualiz.ttv_des_msg_erro = substitute(tt_log_erros_atualiz.ttv_des_msg_erro,string(bord_ap.dat_transacao)).

                run pi_messages (input "Help" /*l_help*/ ,
                                 input tt_log_erros_atualiz.ttv_num_mensagem,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value
                       tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,string(bord_ap.dat_transacao),"Borderì" /*l_bordero*/ ,b_item_bord_ap.cod_estab,string(b_item_bord_ap.cdn_fornecedor),b_item_bord_ap.cod_espec_docto,b_item_bord_ap.cod_ser_docto,b_item_bord_ap.cod_tit_ap,b_item_bord_ap.cod_parcela).
            end /* if */.

            IF VALID-HANDLE(v_hdl_funcao_mex) AND bord_ap.log_bord_ap_escrit = no THEN DO:

                assign v_val_cotac_indic_econ = 1
                       v_log_fornec_aux       = yes.

                /* Busca moeda corrente do estabelecimento */
                run pi_retornar_indic_econ_corren_estab (Input b_item_bord_ap.cod_estab_bord,
                                                         Input bord_ap.dat_transacao,
                                                         output v_cod_indic_econ_estab) /*pi_retornar_indic_econ_corren_estab*/.

                /* Verifica se a moeda do registro Ç a moeda corrente */
                if v_cod_indic_econ_estab <> bord_ap.cod_indic_econ then do:
                    run pi_achar_cotac_indic_econ (Input bord_ap.cod_indic_econ,
                                                   Input v_cod_indic_econ_estab,
                                                   Input bord_ap.dat_transacao,
                                                   Input "Real" /*l_real*/,
                                                   output v_dat_cotac_indic_econ,
                                                   output v_val_cotac_indic_econ,
                                                   output v_cod_return) /*pi_achar_cotac_indic_econ*/.
                    if  v_cod_return <> "OK" /*l_ok*/  then do:

                        /* Begin_Include: i_pi_choose_bt_send_bord_ap_3 */
                        /* erro_block: */
                        case getentryfield(1, v_cod_return, ','):
                            when "335" then  /* Indicador Econìmico Inexistente ! */
                              run pi_messages (input "show",
                                               input 335,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_335*/.
                            when "358" then  /* Cotaá∆o entre Indicadores Econìmicos n∆o encontrada ! */
                              run pi_messages (input "show",
                                               input 358,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                                                                if num-entries(v_cod_return) >= 2 then entry(2,v_cod_return) else "",                               if num-entries(v_cod_return) >= 3 then entry(3,v_cod_return) else "",                               if num-entries(v_cod_return) >= 4 then entry(4,v_cod_return) else "",                               if num-entries(v_cod_return) >= 5 then entry(5,v_cod_return) else "")) /*msg_358*/.
                        end /* case erro_block */.
                        /* End_Include: i_pi_choose_bt_send_bord_ap_3 */

                        return error.
                    end.
                end.

                RUN pi_identif_fornec_nacional IN v_hdl_funcao_mex (INPUT bord_ap.cod_empresa,
                                                                    INPUT b_item_bord_ap.cdn_fornecedor,
                                                                    OUTPUT v_log_fornec_aux).

                /* Para pagamentos em moeda estrangeira, a validaá∆o do valor l°quido
                   de pagamento s¢ dever† ser efetuada caso o fornecedor seja nacional */
                
				if v_log_fornec_aux then do:
                    run pi_verificar_abat_antecip_voucher_pagto (Input b_item_bord_ap.cod_estab_bord,
                                                                 Input "",
                                                                 Input b_item_bord_ap.num_seq_bord,
                                                                 Input b_item_bord_ap.cod_portador,
                                                                 Input b_item_bord_ap.num_bord_ap,
                                                                 Input "Antecipaá∆o" /*l_antecipacao*/ ,
                                                                 output v_log_abat_antecip,
                                                                 output v_val_tot_abat_antecip,
                                                                 output v_val_tot_abat) /* pi_verificar_abat_antecip_voucher_pagto*/.
                    if b_item_bord_ap.cod_refer_antecip_pef <> "" and
                       b_item_bord_ap.cod_refer_antecip_pef <> ? then
                        run prgfin/apb/apb794za.py (Input b_item_bord_ap.cod_estab,
                                                    Input b_item_bord_ap.cod_refer_antecip_pef,
                                                    Input "",
                                                    Input 0,
                                                    Input 0,
                                                    Input yes,
                                                    Input bord_ap.dat_transacao,
                                                    Input "Retido" /*l_retido*/ ,
                                                    output v_log_impto_vincul_refer,
                                                    output v_val_tot_impto,
                                                    Input recid(bord_ap),
                                                    Input recid(cheq_ap),
                                                    Input recid(item_lote_pagto)).
                    else
                        run prgfin/apb/apb794za.py (Input b_item_bord_ap.cod_estab_bord,
                                                    Input "",
                                                    Input bord_ap.cod_portador,
                                                    Input bord_ap.num_bord_ap,
                                                    Input b_item_bord_ap.num_seq_bord,
                                                    Input yes,
                                                    Input bord_ap.dat_transacao,
                                                    Input "Retido" /*l_retido*/ ,
                                                    output v_log_impto_vincul_refer,
                                                    output v_val_tot_impto,
                                                    Input ?,
                                                    Input ?,
                                                    Input ?).

                    assign v_val_liq_item_bord_aux = b_item_bord_ap.val_pagto
                                                   + b_item_bord_ap.val_multa_tit_ap
                                                   + b_item_bord_ap.val_juros
                                                   + b_item_bord_ap.val_cm_tit_ap
                                                   - b_item_bord_ap.val_desc_tit_ap
                                                   - b_item_bord_ap.val_abat_tit_ap
                                                   - v_val_tot_abat_antecip
                                                   - v_val_tot_impto.

                    assign v_val_aux = v_val_liq_item_bord_aux / v_val_cotac_indic_econ.

                    RUN pi_validar_bloq_pagto_bord IN v_hdl_funcao_mex (Input bord_ap.cod_empresa,
                                                                        Input v_val_aux,
                                                                        OUTPUT v_log_retorno,
                                                                        OUTPUT v_log_bloq_pagto).
                    IF v_log_retorno THEN DO:
                        ASSIGN v_log_aux_2 = YES.
                        CREATE tt_item_bord_lote_mensagem.
                        ASSIGN tt_item_bord_lote_mensagem.tta_cod_empresa           = b_item_bord_ap.cod_empresa
                               tt_item_bord_lote_mensagem.tta_num_seq_bord          = b_item_bord_ap.num_seq_bord
                               tt_item_bord_lote_mensagem.tta_cod_estab             = b_item_bord_ap.cod_estab
                               tt_item_bord_lote_mensagem.tta_cod_refer_antecip_pef = b_item_bord_ap.cod_refer_antecip_pef
                               tt_item_bord_lote_mensagem.tta_cod_espec_docto       = b_item_bord_ap.cod_espec_docto
                               tt_item_bord_lote_mensagem.tta_cod_ser_docto         = b_item_bord_ap.cod_ser_docto
                               tt_item_bord_lote_mensagem.tta_cdn_fornecedor        = b_item_bord_ap.cdn_fornecedor
                               tt_item_bord_lote_mensagem.tta_cod_tit_ap            = b_item_bord_ap.cod_tit_ap
                               tt_item_bord_lote_mensagem.tta_cod_parcela           = b_item_bord_ap.cod_parcela
                               tt_item_bord_lote_mensagem.tta_val_pagto             = v_val_liq_item_bord_aux.
                    END.
                END. // if v_log_fornec_aux 
            END. // IF VALID-HANDLE(v_hdl_funcao_mex)
        end. // for each b_item_bord_ap no-lock

        run pi_imprime_erros_cta(input v_num_msg_cta, 
                                 input v_des_param_cta,
                                 input v_des_msg_cta, 
                                 input 'borderì').
        if return-value = "NOK" /*l_nok*/  then
            return.

        IF v_log_aux_2 THEN DO:

            RUN pi_mensagens_itens IN v_hdl_funcao_mex (Input v_cod_empres_usuar,
                                                        Input  "" /*l_*/ ,
                                                        INPUT  v_log_bloq_pagto,
                                                        OUTPUT v_log_retorno).
            FOR EACH tt_item_bord_lote_mensagem:
                DELETE tt_item_bord_lote_mensagem.
            END.

            ASSIGN v_log_aux_2 = NO.

            IF v_log_retorno THEN do:
                IF VALID-HANDLE(v_hdl_funcao_mex) THEN
                    DELETE PROCEDURE v_hdl_funcao_mex.        
                RETURN ERROR.
            END.            
        END.

        IF VALID-HANDLE(v_hdl_funcao_mex) THEN
            DELETE PROCEDURE v_hdl_funcao_mex.

        if  can-find(first tt_log_erros_atualiz) then do:
            run prgint/ufn/ufn901za.py (Input 1) /* prg_api_mostra_log_erros*/.
            for each tt_log_erros_atualiz:
                delete tt_log_erros_atualiz.
            end.
            return error.
        end.

        if v_des_seq_item_bord_ap <> "" then do:
            /*run pi_messages (input "show",
                             input 12635,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               v_des_seq_item_bord_ap)).
            assign v_log_answer = (if   return-value = "yes" then YES //daniele - verificar tratativa por parametro
                                   else if return-value = "no" then no
                                   else ?) /*msg_12635*/. */
            assign v_log_answer = YES.
            if v_log_answer <> yes then
                return.
        end.

        if  can-find(first tt_titulos_msg_alerta no-lock) then do:
            if  search("prgfin/apb/apb999za.r") = ? and search("prgfin/apb/apb999za.py") = ? then do:
                if  v_cod_dwb_user begins 'es_' then
                    return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/apb/apb999za.py".
                else do:
                    message "Programa execut†vel n∆o foi encontrado: prgfin/apb/apb999za.py"
                           view-as alert-box error buttons ok.
                    stop.
                end.
            end.
            ELSE DO: // novo
                run prgfin/apb/apb999za.py (Input table tt_titulos_msg_alerta,
                                        Input 17997,
                                        Input "",
                                        output v_log_erro) /*prg_api_mostra_msg_tit_apb*/.
            END. // novo
            if (NOT v_log_erro) then
                return.
        end.
        else do:
            find last param_estab_apb no-lock
                where param_estab_apb.cod_estab = bord_ap.cod_estab_bord no-error.
            if  avail param_estab_apb and param_estab_apb.log_pagto_sem_desemb_bord
            then do: 
                /* DMANAPB1-962 - Validar itens sem desembolso.*/
                assign v_val_liq_item_bord    = 0
                       v_log_pagto_sem_desemb = no.

                run pi_verifica_desembolso_bord_ap (output v_log_pagto_sem_desemb,
                                                    output v_val_liq_item_bord).
                /* Se n o tem item marcado como desembolso e o valor de pagamento ? zero, mostrar mensagem de erro */    
                if  v_val_liq_item_bord = 0 and v_log_pagto_sem_desemb = no
                then do:
                    /* T°tulos sem valor de desembolso, retire-os do borderì ! */
                    run pi_messages (input "msg",
                                     input 22749,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_22749*/.
                    return.
                end.
            end.    
            /* DMANAPB1-962 - Validar itens sem desembolso.*/
        end.

        assign v_log_answer = YES /*msg_5686*/.
        
		if  v_log_answer = yes
        then do:

            &if defined(BF_FIN_FLUIG) &then
                assign v_log_aux = yes.
            &endif

            assign v_log_method = session:set-wait-state('general').

            /* * Fo 785700 -> Alterado por Rodrigo Rossi (03/05/02) **/

            /* Begin_Include: i_exec_program_epc */
            &if '{&emsbas_version}' > '1.00' &then
            if  v_nom_prog_upc <> '' then
            do:
                assign v_rec_table_epc = recid(bord_ap).    
                run value(v_nom_prog_upc) (input 'SALVAR',
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
                assign v_rec_table_epc = recid(bord_ap).    
                run value(v_nom_prog_appc) (input 'SALVAR',
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
                assign v_rec_table_epc = recid(bord_ap).    
                run value(v_nom_prog_dpc) (input 'SALVAR',
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

            do transaction:
                if bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/  then
                    assign v_log_exec_epc = no.

                run pi_controlar_envio_bordero_pagto (Input bord_ap.cod_estab_bord,
                                                      Input bord_ap.cod_portador,
                                                      Input bord_ap.num_bord_ap,
                                                      Input "API" /*l_online*/) /*pi_controlar_envio_bordero_pagto*/.
                if return-value = "NOK" /*l_nok*/  then
                    undo, leave.

                /* Begin_Include: i_exec_epc_choose_bt_send_bord_ap */
                if  v_log_exec_epc and bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/ 
                then do:
                    run pi_exec_program_epc_FIN (Input 'envia_documento',
                                                 Input "no" /*l_no*/,
                                                 output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
                    run pi_disp_fields /*pi_disp_fields*/.
                end /* if */.
                /* End_Include: i_exec_epc_choose_bt_send_bord_ap */
            end.

            /* ** Atualizaá∆o dos Saldos das Contas Correntes SPOOL ***/
            run pi_sdo_cta_corren_spool_modulos.

            assign v_log_method = session:set-wait-state('').
        end. // if  v_log_answer = yes
    end. // if  bord_ap.ind_tip_bord_ap = "Normal" 
    else do:
        do transaction:
            find current bord_ap exclusive-lock no-error.
            if  avail bord_ap
            then do:
                find first cheq_ap no-lock
                    where cheq_ap.num_bord_ap = bord_ap.num_bord_ap no-error.
                if  avail cheq_ap
                then do:
                    assign bord_ap.ind_sit_bord_ap = "Enviado ao Banco" /*l_enviado_ao_banco*/ .
                    run pi_exec_program_epc_FIN (Input 'envia_documento',
                                                 Input "no" /*l_no*/,
                                                 output v_log_return_epc) /*pi_exec_program_epc_FIN*/.

                    run pi_disp_fields /*pi_disp_fields*/.
                end /* if */.
                else do:
                    /* Nenhum Cheque ADM para ser Atualizado ! */
                    run pi_messages (input "msg",
                                     input 5688,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_5688*/.
                end /* else */.
            end. // if  avail bord_ap
        end. // do transaction:
    end. // ELSE ... // if  bord_ap.ind_tip_bord_ap = "Normal" 
	
    /* End_Include: i_exec_epc_choose_bt_send_bord_ap */

    &if defined(BF_FIN_FLUIG) &then
		
        if v_log_aux = yes then do:

            find first b_bord_ap no-lock
                where b_bord_ap.cod_empresa = v_cod_empres_usuar
                 and recid(b_bord_ap) = v_rec_aux no-error.
			
            if avail b_bord_ap
            and b_bord_ap.ind_sit_bord_ap = "Enviado ao Banco" /*l_enviado_ao_banco*/ 
            and b_bord_ap.log_bord_ap_escrit = no then do:

                /* salva a empresa do ems5 para voltar depois da integraá∆o*/
                assign v_cod_empresa_aux = v_cod_empres_usuar.

                /* * Instancia programa EMS2 **/
                if  not valid-handle(v_hdl_program_fnd) then do:
                    run utp/ut-integra-ecm.p persistent set v_hdl_program_fnd.
                end.

                /* procedure checkFluigIntegration verifica se tem o FLUIG, s¢ funciona com o identity ativo, sen∆o sempre retorna "NO" */
                if isFluigIntegrated <> yes then 
                   run checkFluigIntegration in v_hdl_program_fnd (output isFluigIntegrated).

                if isFluigIntegrated = yes then do: /* verificar se tem o FLUIG*/

                    /* procedure checkExistingProcess verifica se existe o WF no FLUIG */
                    if existProcess <> yes then
                        run checkExistingProcess in v_hdl_program_fnd (input "wfapbconfirmbordap" /*l_wfapbconfirmbordap*/ ,
                                                                       output existProcess).

                    if existProcess = yes then do: /* existe o WF de confirmaá∆o de bordero */
					
                        if b_bord_ap.cod_workflow = "" then do:
                            /*
                            run pi_messages (input "show",
                                             input 21624,
                                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                            assign v_log_answer = (if   return-value = "yes" then YES //daniele - verificar tratativa por parametro
                                                   else if return-value = "no" then no
                                                   else ?) /*msg_21624*/.*/
                            assign v_log_answer = YES.
                            assign v_log_answer_vld = v_log_answer.
							
                            if  v_log_answer = yes
                            then do:
                                assign comments = "Abertura Workflow de Confirmaá∆o de Bordero via ERP Datasul" /*l_abert_wf_confirm_bord_ap*/ .

                                assign v_val_liq = 0.
                                run pi_retorna_val_liquido_bord_ap (Input "Base" /*l_base*/ , 
                                                                    Input recid(b_bord_ap),
                                                                    Input ?,
                                                                    output v_val_liq) /* pi_retorna_val_liquido_bord_ap*/.

                                if b_bord_ap.log_bord_ap_escrit = yes then
                                    assign v_cod_bord_ap_escrit = "Sim" /*l_sim*/ .
                                else 
                                    assign v_cod_bord_ap_escrit = "N∆o" /*l_nao*/ .

                                if b_bord_ap.log_bord_ap_escrit_envdo = yes then
                                    assign v_cod_bord_ap_escrit_envdo = "Sim" /*l_sim*/ .
                                else 
                                    assign v_cod_bord_ap_escrit_envdo = "N∆o" /*l_nao*/ .

                                assign cardData = '<cardData>' + 
                                                  ' <item>'   + 
                                                  '  <item>cod_estab_bord</item>'  + 
                                                  '  <item>' + b_bord_ap.cod_estab_bord   + '</item>' + 
                                                  ' </item>' + 
                                                  ' <item>'     + 
                                                  '  <item>cod_portador</item>' + 
                                                  '  <item>' + b_bord_ap.cod_portador  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>num_bord_ap</item>' + 
                                                  '  <item>' + string(b_bord_ap.num_bord_ap)  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>dat_transacao</item>' + 
                                                  '  <item>' + string(b_bord_ap.dat_transacao,"99/99/9999")  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>cod_indic_econ</item>' + 
                                                  '  <item>' + b_bord_ap.cod_indic_econ  + '</item>' + 
                                                  ' </item>' + 
                                                  ' <item>'     + 
                                                  '  <item>val_liq</item>' + 
                                                  '  <item>' + string(v_val_liq, "->>>,>>>,>>9.99")  + '</item>' + 
                                                  ' </item>' + 
                                                  ' <item>'     + 
                                                  '  <item>val_tot_lote_pagto_infor</item>' + 
                                                  '  <item>' + string(b_bord_ap.val_tot_lote_pagto_info, "->>>,>>>,>>9.99")  + '</item>' + 
                                                  ' </item>' + 
                                                  ' <item>'     + 
                                                  '  <item>cod_usuar_pagto</item>' + 
                                                  '  <item>' + b_bord_ap.cod_usuar_pagto  + '</item>' + 
                                                  ' </item>' + 
                                                  ' <item>'     + 
                                                  '  <item>ind_sit_bord_ap</item>' + 
                                                  '  <item>' + b_bord_ap.ind_sit_bord_ap  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>ind_tip_bord_ap</item>' + 
                                                  '  <item>' + b_bord_ap.ind_tip_bord_ap  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>log_bord_ap_escrit</item>' + 
                                                  '  <item>' + v_cod_bord_ap_escrit  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>log_bord_ap_escrit_envdo</item>' + 
                                                  '  <item>' + v_cod_bord_ap_escrit_envdo  + '</item>' + 
                                                  ' </item>' +
                                                  ' <item>'     + 
                                                  '  <item>dat_confir_bord_ap</item>' + 
                                                  '  <item>' + string(today,"99/99/9999")  + '</item>' + 
                                                  ' </item>' +
                                                  '</cardData>'.

                                run startProcess in v_hdl_program_fnd (input  "",
                                                                       input  "",
                                                                       input  "",
                                                                       input  "wfapbconfirmbordap" /*l_wfapbconfirmbordap*/ ,
                                                                       input  comments,
                                                                       input  v_cod_usuar_corren,
                                                                       input  attachments,
                                                                       input  cardData,
                                                                       input  "Pool:Group:FAN" /*l_Pool:Group:FAN*/ ,
                                                                       output ecmId,
                                                                       output resultXML).

                                /* salvar o ecmId no campo cod_workflow da tabela*/
                                if ecmID <> 0 and ecmID <> -1 then do:
                                    if v_cod_workflow = "" then 
                                        assign v_cod_workflow = string(ecmID).
                                    else
                                        assign v_cod_workflow = v_cod_workflow + "/" + string(ecmID).

                                    do transaction:
                                        find current b_bord_ap exclusive-lock no-error.
                                        if avail b_bord_ap then
                                            assign b_bord_ap.cod_workflow = string(ecmID).
                                    end.
                                end.
                                else do:
                                    /* Ocorreram problemas na criaá∆o do Workflow no Fluig ! */
                                    run pi_messages (input "show",
                                                     input 21636,
                                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21636*/.
                                end.
								
                            end. // if  v_log_answer = yes
                        end. // if b_bord_ap.cod_workflow = ""
                    end. // if existProcess = yes // existe o WF de confirmaá∆o bordero
                    
                    if v_log_answer_vld = yes then do:
                        /* procedure checkExistingProcess verifica se existe o WF de Cheque no FLUIG */
                        if existProcessch <> yes then
                            run checkExistingProcess in v_hdl_program_fnd (input "wfapbconfirmcheqap" /*l_wfapbconfirmcheqap*/ ,
                                                                       output existProcessch).

                        if existProcessch = yes then do: /* existe o WF de confirmaá∆o de cheque */
                            for each tt_cheq_ap no-lock:
                                find first b_cheq_ap exclusive-lock
                                    where b_cheq_ap.cod_empresa = v_cod_empres_usuar
                                      and recid(b_cheq_ap) = tt_cheq_ap.ttv_rec_cheq_ap no-error.
                                if avail b_cheq_ap and b_cheq_ap.cod_workflow = "" then do:
                                    assign ecmID = 0.
                                    assign comments = "Abertura Workflow de Confirmaá∆o de Cheque via ERP Datasul" /*l_abert_wf_confirm_cheq*/ .

                                    assign cardData = '<cardData>' + 
                                                      ' <item>'   + 
                                                      '  <item>cod_estab_cheq</item>'  + 
                                                      '  <item>' + b_cheq_ap.cod_estab_cheq   + '</item>' + 
                                                      ' </item>' + 
                                                      ' <item>'     + 
                                                      '  <item>cod_banco</item>' + 
                                                      '  <item>' + b_cheq_ap.cod_banco  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>cod_agenc_bcia</item>' + 
                                                      '  <item>' + b_cheq_ap.cod_agenc_bcia  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>cod_cta_corren_bco</item>' + 
                                                      '  <item>' + b_cheq_ap.cod_cta_corren_bco  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>num_talon_cheq</item>' + 
                                                      '  <item>' + string(b_cheq_ap.num_talon_cheq)  + '</item>' + 
                                                      ' </item>' + 
                                                      ' <item>'     + 
                                                      '  <item>num_cheque</item>' + 
                                                      '  <item>' + string(b_cheq_ap.num_cheque)  + '</item>' + 
                                                      ' </item>' + 
                                                      ' <item>'     + 
                                                      '  <item>val_cheque</item>' + 
                                                      '  <item>' + string(b_cheq_ap.val_cheque)  + '</item>' + 
                                                      ' </item>' + 
                                                      ' <item>'     + 
                                                      '  <item>nom_favorec_cheq</item>' + 
                                                      '  <item>' + b_cheq_ap.nom_favorec_cheq  + '</item>' + 
                                                      ' </item>' + 
                                                      ' <item>'     + 
                                                      '  <item>cod_portador</item>' + 
                                                      '  <item>' + b_cheq_ap.cod_portador  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>cod_finalid_econ</item>' + 
                                                      '  <item>' + b_cheq_ap.cod_finalid_econ  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>dat_emis_cheq</item>' + 
                                                      '  <item>' + string(b_cheq_ap.dat_emis_cheq,"99/99/9999")  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>ind_favorec_cheq</item>' + 
                                                      '  <item>' + b_cheq_ap.ind_favorec_cheq  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>dat_confir_cheq_ap</item>' + 
                                                      '  <item>' + string(today,"99/99/9999")  + '</item>' + 
                                                      ' </item>' +
                                                      ' <item>'     + 
                                                      '  <item>num_id_cheq_ap</item>' + 
                                                      '  <item>' + string(b_cheq_ap.num_id_cheq_ap)  + '</item>' + 
                                                      ' </item>' +
                                                      '</cardData>'.

                                    run startProcess in v_hdl_program_fnd (input  "",
                                                                           input  "",
                                                                           input  "",
                                                                           input  "wfapbconfirmcheqap" /*l_wfapbconfirmcheqap*/ ,
                                                                           input  comments,
                                                                           input  v_cod_usuar_corren,
                                                                           input  attachments,
                                                                           input  cardData ,
                                                                           input  "Pool:Group:FAN" /*l_Pool:Group:FAN*/ ,
                                                                           output ecmId,
                                                                           output resultXML).

                                    /* salvar o ecmId no campo cod_workflow da tabela*/
                                    if ecmID <> 0 and ecmID <> -1 then do:
                                        if v_cod_workflow = "" then 
                                            assign v_cod_workflow = string(ecmID).
                                        else
                                            assign v_cod_workflow = v_cod_workflow + "/" + string(ecmID).

                                        assign b_cheq_ap.cod_workflow = string(ecmID).
                                    end.
                                    else do:
                                        /* Ocorreram problemas na criaá∆o do Workflow no Fluig ! */
                                        run pi_messages (input "show",
                                                         input 21636,
                                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21636*/.
                                    end.
                                end.
                            end. // if existProcessch = yes then do: /* existe o WF de confirmaá∆o de cheque */
                        end. // existe o WF de confirmaá∆o cheque
                    end. // if v_log_answer_vld = yes then do: = foi dado yes na mensagem do bordero
                end. // if isFluigIntegrated = yes /* verificar se tem o FLUIG*/

                /* * Elimina Handle EMS2 **/
                if  valid-handle(v_hdl_program_fnd) then do:
                    delete procedure v_hdl_program_fnd.
                    assign v_hdl_program_fnd = ?.
                end.

                /* retorna a empresa do ems5 depois da integraá∆o*/
                assign v_cod_empres_usuar = v_cod_empresa_aux.
				
            end. // if avail b_bord_ap
			
        end. // if v_log_aux = yes
		
        if v_cod_workflow <> "" then do:
            /* Solicitaá∆o criada com sucesso no Fluig. */
            run pi_messages (input "show",
                             input 21623,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               v_cod_workflow)) /*msg_21623*/.
        end.
		
    &endif // &if defined(BF_FIN_FLUIG) &then
    
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_vld_bord_ap:
    DEFINE VARIABLE v_des_param AS CHARACTER   NO-UNDO.

    /* ***
        Todos as validaáÑes que est∆o abaixo do &else s∆o para tratamento de API.
    ****/
   
    /* Valida Estabelecimento/Empresa */
    &if '{&emsuni_dbinst}' = 'yes' &then
    def buffer bcx_stblcmnt_brdrp for estabelecimento.
    
        if  not (can-find(first bcx_stblcmnt_brdrp
            where bcx_stblcmnt_brdrp.cod_estab = tt_bordero.cod_estab)) then do:
            assign v_des_param = "Estabelecimento" /*l_estabelecimento*/  + ';;;;;;;;;'.

            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 1284,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end.
    &endif.

    run prgfin/apb/apb739ze.py persistent set v_hdl_valid_estab_refer.
 
    run pi_validar_estab in v_hdl_valid_estab_refer (Input v_cod_empres_usuar,
                          Input tt_bordero.cod_estab,
                          Input tt_bordero.dat_transacao,
                          output v_cod_return) /*pi_validar_estab*/.



    if  v_cod_return = "Unidade Organizacional" /*l_unid_organ*/ 
    then do:
        /* Estabelecimento n∆o habilitado como Unidade Organizacional ! */
        

        if  v_cod_return = "Unidade Organizacional" /*l_unid_organ*/ 
        then do:
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 347,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end /* if */.
    end /* if */.

    
    //"Empresa do Estabelecimento Diferente da Empresa do Usu†rio"
    if  v_cod_return = "Empresa" /*l_empresa*/ 
    then do:
        assign v_des_param = ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input integer(tt_bordero.num_bord_ap),
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 512,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
    end /* if */.


    
    /* Usu†rio sem permiss∆o para acessar o estabelecimento &1 ! */
    if  v_cod_return = "Usu†rio" /*l_usuario*/ 
    then do:
        assign v_des_param = ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input integer(tt_bordero.num_bord_ap),
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 348,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
    end /* if */.
 
    
    run pi_validar_usuar_estab_apb in v_hdl_valid_estab_refer (Input tt_bordero.cod_estab,
                                    Input "Pagador" /*l_pagador*/,
                                    output v_cod_return,
                                    output v_val_lim_liber_usuar_movto,
                                    output v_val_lim_liber_usuar_mes,
                                    output v_val_lim_pagto_usuar_movto,
                                    output v_val_lim_pagto_usuar_mes) /*pi_validar_usuar_estab_apb*/.
 

    IF VALID-HANDLE(v_hdl_valid_estab_refer) THEN
        DELETE PROCEDURE v_hdl_valid_estab_refer.
    /* case_block: */
    case v_cod_return:
    when "no" /*l_no*/ then
        /* Usu†rio &1 n∆o possui permiss∆o para &2 ! */
        no_block:
        do:

                assign v_des_param = v_cod_usuar_corren + ';' + "Pagar" /*l_pagar*/  + ';;;;;;;;'.
                run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                       Input integer(tt_bordero.num_bord_ap),
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input 0,
                                                       Input 701,
                                                       Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.

        end /* do no_block */.

    when "602" then
        /* Usu†rio Financeiro Inexistente ! */
        602_block:
        do:
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 602,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end /* do 602_block */.

    end /* case case_block */.


    run pi_validar_portador_bord /*pi_validar_portador_bord*/.
    run pi_validar_num_bord_ap /*pi_validar_num_bord_ap*/.
    run pi_controlar_sit_movimen_modul_ap (Input tt_bordero.cod_estab,
                                           Input tt_bordero.dat_transacao) /*pi_controlar_sit_movimen_modul_ap*/.
   

    
    run pi_validar_portador_estab_finalid_econ /*pi_validar_portador_estab_finalid_econ*/.

    /* Esta rotina valida a mensagem de in°cio de borderì,
       de acordo com a mensagem do financeiro              */
    /* Mensagem de in°cio de Borderì Inexistente ! */
    if  tt_bordero.cod_msg_inic <> ""
    and tt_bordero.cod_msg_inic <> ? then do:
        assign v_cod_mensagem = tt_bordero.cod_msg_inic.
        run pi_validar_mensagem_bordero.
        if  v_ind_tip_verific = "NOK" /*l_nok*/  then do:
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 933,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end.
    end.
    /* Situaá∆o de movimentaá∆o do m¢dulo n∆o est† Habilitada ! */
      
    run pi_retornar_sit_movimen_modul (Input "APB" /*l_apb*/ ,
                                       Input v_cod_empres_usuar,
                                       Input tt_bordero.dat_transacao,
                                       Input "Habilitado" /*l_habilitado*/ ,
                                       output v_cod_return) /* pi_retornar_sit_movimen_modul*/.
  
    if  not can-do(v_cod_return, "Habilitado" /*l_habilitado*/ )
    then do:
      
       
        assign v_des_param = tt_bordero.cod_estab + ';' + "APB" /*l_apb*/  + ';' + string(tt_bordero.dat_transacao) + ';;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input tt_bordero.num_bord_ap,
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 1628,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
    end.

    /* Esta rotina valida a mensagem de fim de borderì,
       de acordo com a mensagem do financeiro              */
   /* Mensagem de fim de Borderì Inexistente ! */
       
    if  tt_bordero.cod_msg_fim <> ""
    and tt_bordero.cod_msg_fim <> ? then do:
        assign v_cod_mensagem = tt_bordero.cod_msg_fim.
        run pi_validar_mensagem_bordero.
        if  v_ind_tip_verific = "NOK" /*l_nok*/ 
        then do:
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 935,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end.
    end.
  
    if  v_cod_return = "OK" /*l_ok*/ 
    then do:
        assign tt_bordero.cod_empresa = v_cod_empres_usuar
               tt_bordero.cod_usuar_pagto = v_cod_usuar_corren.
    end /* if */.
    

    &if defined (BF_FIN_BCOS_HISTORICOS) &then
        
        if  can-find(first his_bord_ap no-lock
            where his_bord_ap.cod_estab_bord = tt_bordero.cod_estab
              and his_bord_ap.cod_portador = tt_bordero.cod_portador
              and his_bord_ap.num_bord_ap = tt_bordero.num_bord_ap)
        then do:
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 14010,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        end.
    &endif
    
    IF VALID-HANDLE(v_hdl_valid_estab_refer) THEN
        DELETE PROCEDURE v_hdl_valid_estab_refer.
   
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_cria_tt_log_error_import_pagto:

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
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.06" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.06" AND "{&emsfin_version}" < "9.99" &THEN
        as character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_tit_ap
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
        no-undo.
    def Input param p_cdn_fornec_titulo
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_num_mensagem
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_cod_parameters
        as character
        format "x(256)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_ajuda
        as character
        format "x(50)":U
        view-as editor max-chars 2000 scrollbar-vertical
        size 50 by 3
        bgcolor 15 font 2
        label "Ajuda"
        column-label "Ajuda"
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
    def var v_num_mensagem
        as integer
        format ">>>>,>>9":U
        label "N£mero"
        column-label "N£mero Mensagem"
        no-undo.

    
    /************************** Variable Definition End *************************/

    assign v_log_erro = yes
           v_num_mensagem = p_num_mensagem.
    run pi_messages (input "msg",
                     input v_num_mensagem,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
    assign v_des_mensagem = return-value /*msg_v_num_mensagem*/.  
    run pi_messages (input "help",
                     input v_num_mensagem,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
    assign v_des_ajuda = return-value /*msg_v_num_mensagem*/.   

    CREATE tt-retorno.
    ASSIGN tt-retorno.versao-api = c-versao-api 
           tt-retorno.cod-status = p_num_mensagem 
           tt-retorno.desc-retorno = substitute(v_des_mensagem, GetEntryField(1, p_cod_parameters, ';'), GetEntryField(2, p_cod_parameters, ';'), GetEntryField(3, p_cod_parameters, ';'), GetEntryField(4, p_cod_parameters, ';'), GetEntryField(5, p_cod_parameters, ';'), GetEntryField(6, p_cod_parameters, ';'), GetEntryField(7, p_cod_parameters, ';'), GetEntryField(8, p_cod_parameters, ';'), GetEntryField(9, p_cod_parameters, ';')) 
        //v_des_mensagem 
        .
END PROCEDURE. /* pi_cria_tt_log_error_import_pagto */

//----------------------------------------------------------------------------------------------------

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
/*         message string(i_msg) skip */
/*                 c_prg_msg + " n∆o encontrado." */
/*                 view-as alert-box error. */
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201 // usar codigo de erro para o robì = 201 // i_msg
               tt-retorno.desc-retorno = "Programa de mensagem n∆o encontrado: " + c_prg_msg.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input "msg", input c_param).

    IF c_action = "show" THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 201 // usar codigo de erro para o robì = 201 // i_msg
               tt-retorno.desc-retorno = RETURN-VALUE.
    END.

    return return-value.
END PROCEDURE.  /* pi_messages */

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_portador_bord:
    DEFINE VARIABLE v_des_param AS CHARACTER   NO-UNDO.

    /* ***
        O bloco que esta abaixo do &else, Ç para tratamento da API contas a pagar,
        toda a alteraá∆o feita no programa principal, dever† ser feita tambÇm
        para a API.
    ****/

    /* Esta rotina faz a validacao para o portador do borderì */

    find FIRST portador no-lock
     where portador.cod_portador = tt_bordero.cod_portador no-error.

    if  not avail portador
    then do:
        /* Portador Inexistente ! */
        assign v_des_param = ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input integer(tt_bordero.num_bord_ap),
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 925,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
   
    end /* if */.
    else do:
        if  portador.ind_tip_portad <> "Caixa" /*l_caixa*/ 
        then do:
            /* Portador n∆o Vinculado ao Estabelecimento. */
        
            find portad_estab no-lock
                where portad_estab.cod_estab  = tt_bordero.cod_estab
                and portad_estab.cod_portador = tt_bordero.cod_portador no-error.
            if  not avail portad_estab
            then do:
                assign v_des_param = ';;;;;;;;;'.
                run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                       Input integer(tt_bordero.num_bord_ap),
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input 0,
                                                       Input 925,
                                                       Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.    
            end /* if */.
      
        end /* if */.
        else do:
            /* Portador do tipo Caixa n∆o permitido para Borderì ! */
        
            assign v_des_param = ';;;;;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input integer(tt_bordero.num_bord_ap),
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 2417,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
   
        end /* else */.
    end /* else */.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_portador_estab_finalid_econ:
    DEFINE VARIABLE v_des_param AS CHARACTER   NO-UNDO.

    
    run pi_retornar_finalid_indic_econ(Input tt_bordero.cod_indic_econ,
                                        Input tt_bordero.dat_transacao,
                                        output tt_bordero.cod_finalid_econ) /* pi_retornar_finalid_indic_econ*/.
    find FIRST finalid_econ no-lock
        where finalid_econ.cod_finalid_econ = tt_bordero.cod_finalid_econ no-error.

    find FIRST cart_bcia no-lock
     where cart_bcia.ind_tip_cart_bcia = "Contas a Pagar" /*l_contas_a_pagar*/ no-error.
    if  avail cart_bcia then do:
        assign v_cod_cart_bcia = cart_bcia.cod_cart_bcia.
    end /* if */.


    if  avail finalid_econ then do:
        
        assign tt_bordero.cod_finalid_econ = finalid_econ.cod_finalid_econ.
        find portad_finalid_econ no-lock
            where portad_finalid_econ.cod_estab        = tt_bordero.cod_estab
            and   portad_finalid_econ.cod_portador     = tt_bordero.cod_portador
            and   portad_finalid_econ.cod_cart_bcia    = v_cod_cart_bcia
            and   portad_finalid_econ.cod_finalid_econ = tt_bordero.cod_finalid_econ
            no-error.
        if  not avail portad_finalid_econ
        then do:
            /* Finalidade Econìmica n∆o vinculada ao Portador do Estab ! */
        
            assign v_des_param = tt_bordero.cod_finalid_econ + ';' + tt_bordero.cod_estab + ';' +
                                     tt_bordero.cod_portador + ';' + v_cod_cart_bcia + ';;;;;;'.
            run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                   Input tt_bordero.cod_refer,
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input "",
                                                   Input 0,
                                                   Input 22888,
                                                   Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
        
        end /* if */.
                        
        if  tt_bordero.log_bord_ap_escrit = yes
        then do:
            find portad_edi
                where portad_edi.cod_modul_dtsul  = "APB" /*l_apb*/ 
                and   portad_edi.cod_estab        = portad_finalid_econ.cod_estab
                and   portad_edi.cod_portador     = portad_finalid_econ.cod_portador
                and   portad_edi.cod_cart_bcia    = portad_finalid_econ.cod_cart_bcia
                and   portad_edi.cod_finalid_econ = portad_finalid_econ.cod_finalid_econ
                no-lock no-error.
            /* Portador &1 sem as informaáÑes para EDI ! */
            if  not avail portad_edi
            then do:
                assign v_des_param = portad_finalid_econ.cod_portador + ';;;;;;;;;'.
                run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                       Input tt_bordero.cod_refer,
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input "",
                                                       Input 0,
                                                       Input 4580,
                                                       Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
            end /* if */.
            else do:
                /* Par≥metros Portador EDI inv†lido ! */
                if  index(portad_edi.des_tip_var_portad_edi, "Ç") <> 0
                then do:
                    assign v_des_param = ';;;;;;;;;'.
                    run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                                           Input tt_bordero.cod_refer,
                                                           Input "",
                                                           Input "",
                                                           Input "",
                                                           Input "",
                                                           Input 0,
                                                           Input 18194,
                                                           Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
                end /* if */.
            end /* else */.
        end /* if */.
    end /* if */.
    else do:
        /* Indicador Econìmico &1 n∆o econtrado ! */
        assign v_des_param = tt_bordero.cod_finalid_econ + ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input tt_bordero.cod_refer,
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 1457,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
  
    end /* else */.
END PROCEDURE. /* pi_validar_portador_estab_finalid_econ */

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_num_bord_ap:

    DEFINE VARIABLE v_des_param AS CHARACTER   NO-UNDO.

     /* N£mero do Borderì Inv†lido ! */
    if tt_bordero.num_bord_ap <= 0 
    then do:
        assign v_des_param = ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input integer(tt_bordero.num_bord_ap),
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 7616,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
    end.

    find first compl_movto_pagto no-lock
        where compl_movto_pagto.cod_estab_pagto = tt_bordero.cod_estab
        and   compl_movto_pagto.cod_portador    = tt_bordero.cod_portador
        and   compl_movto_pagto.num_bord_ap     = tt_bordero.num_bord_ap
        no-error.
    /* Borderì Existente com Estabelecimento do Portador. */
    if  avail compl_movto_pagto
    then do:
        assign v_des_param = ';;;;;;;;;'.
        run pi_cria_tt_log_error_import_pagto (Input tt_bordero.cod_estab,
                                               Input integer(tt_bordero.num_bord_ap),
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input "",
                                               Input 0,
                                               Input 923,
                                               Input v_des_param) /*pi_cria_tt_log_error_import_pagto*/.
    end /* if */.


END PROCEDURE.

//----------------------------------------------------------------------------------------------------

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

END PROCEDURE.

//----------------------------------------------------------------------------------------------------
PROCEDURE pi_retornar_finalid_econ_corren_estab:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
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
        find FIRST pais no-lock
            where pais.cod_pais = estabelecimento.cod_pais
             no-error.
       assign p_cod_finalid_econ = pais.cod_finalid_econ_pais.
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_controlar_sit_movimen_modul_ap:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab_bord
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/



    run pi_retornar_sit_movimen_modul (Input "APB" /*l_apb*/,
                                       Input p_cod_estab_bord,
                                       Input p_dat_transacao,
                                       Input "Habilitado" /*l_habilitado*/,
                                       output v_des_sit_movimen_mod) /*pi_retornar_sit_movimen_modul*/.

    if  v_ind_tip_verific = "Habilitado" /*l_habilitado*/ 
    then do:
        /* Per°odo n∆o Habilitado. */
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 105
               tt-retorno.desc-retorno = "Per°odo n∆o habilitado".
        ASSIGN v_log_erro = YES.
    end /* if */.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_retornar_sit_movimen_modul:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_unid_organ
        as character
        format "x(5)"
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

END PROCEDURE.

//----------------------------------------------------------------------------------------------------
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




END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_valida_val_usuar_pagamento:

    /************************ Parameter Definition Begin ************************/

    def output param p_cod_return_pagto
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_estab                      as character       no-undo. /*local*/
    def var v_dat_transacao                  as date            no-undo. /*local*/
    def var v_val_acum_tit_ap_aux            as decimal         no-undo. /*local*/
   
    def var v_val_acum_tit_ap                as decimal         no-undo. /*local*/
    def var v_log_cotac_contrat              as logical         no-undo. /*local*/
    def var v_cod_return_liber_pagto         as character       no-undo. /*local*/

    /************************** Variable Definition End *************************/
    
    assign v_cod_estab     = bord_ap.cod_estab
           v_dat_transacao = bord_ap.dat_transacao.

    find last param_empres_apb no-lock
        where param_empres_apb.cod_empresa = v_cod_empres_usuar /* cl_empres_usuar of param_empres_apb*/ no-error.
    if  avail param_empres_apb
    then do:
       
        assign v_cod_finalid_param =  param_empres_apb.cod_finalid_econ_val_usuar.
        /* Retorna °ndice econ-mico da finalidade parametrizada no sistema */
        run pi_retornar_indic_econ_finalid (Input v_cod_finalid_param,
                                            Input v_dat_transacao,
                                            output v_cod_indic_econ_param) /* pi_retornar_indic_econ_finalid*/. 
    end.
    else do:
        assign p_cod_return_pagto = "1053".
        return.
    end /* else */.
    
    assign v_val_acum_tit_ap = 0.

    FOR EACH tt_titulos_bord:
        if v_log_cotac_contrat then do:
            if  tt_titulos_bord.cod_refer_antecip_pef = "" then do: /* titulo */
                find first tit_ap no-lock
                    where tit_ap.cod_estab       = tt_titulos_bord.cod_estab
                    and   tit_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                    and   tit_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                    and   tit_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                    and   tit_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                    and   tit_ap.cod_parcela     = tt_titulos_bord.cod_parcela no-error. 
                if avail tit_ap then
                    run pi_set_tit_ap in v_hdl_indic_econ_finalid(input tit_ap.cod_estab, input tit_ap.num_id_tit_ap).                 
            end.
            else do:
                run pi_set_antecip_pef_pend in v_hdl_indic_econ_finalid(input tt_titulos_bord.cod_estab, input tt_titulos_bord.cod_refer_antecip_pef).
            end.        
        end.    

        run pi_verifica_val_acum_tit_ap(input v_dat_transacao,
                                        output v_val_acum_tit_ap_aux).

        assign v_val_acum_tit_ap = v_val_acum_tit_ap + v_val_acum_tit_ap_aux.
    end.
    assign v_val_acum_tit_ap = round(v_val_acum_tit_ap, 2).

    find usuar_financ_estab_apb
        where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
        and   usuar_financ_estab_apb.cod_estab   = v_cod_estab
        no-lock no-error.
    run pi_verificar_val_usuar_ant (Input v_cod_estab,
                                    Input v_dat_transacao,
                                    Input "Pagamento" /*l_pagamento*/ ,
                                    Input v_val_acum_tit_ap,
                                    Input usuar_financ_estab_apb.val_lim_liber_usuar_movto,
                                    Input usuar_financ_estab_apb.val_lim_liber_usuar_mes,
                                    Input usuar_financ_estab_apb.val_lim_pagto_usuar_movto,
                                    Input usuar_financ_estab_apb.val_lim_pagto_usuar_mes,
                                    output v_cod_return_liber_pagto,
                                    output v_cod_return) /* pi_verificar_val_usuar*/.
    if  v_cod_return <> "OK" /*l_ok*/ 
    then do:
        assign p_cod_return_pagto = v_cod_return.
        return.
    end.
    
    assign p_cod_return_pagto = "OK" /*l_ok*/ .

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_msg_validacao_usuario:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_return_liber_pagto
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_return_pagto
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_tip_movto
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_tip_movto
        as character
        format "x(3)":U
        label "Tipo Movto"
        column-label "Tipo Movto"
        no-undo.

    /************************** Variable Definition End *************************/

    if  string(p_cod_return_liber_pagto) <> "OK" /*l_ok*/ 
    then do:
        assign p_cod_return_liber_pagto = p_cod_return_liber_pagto + ",,,,,,,,,".
        run pi_messages (input "show" /*l_show*/ ,
                         input integer(entry(1,p_cod_return_liber_pagto)),
                         input substitute("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                 entry(2, p_cod_return_liber_pagto), entry(3, p_cod_return_liber_pagto),
                                 entry(4, p_cod_return_liber_pagto), entry(5, p_cod_return_liber_pagto),
                                 entry(6, p_cod_return_liber_pagto), entry(7, p_cod_return_liber_pagto),
                                 entry(8, p_cod_return_liber_pagto), entry(9, p_cod_return_liber_pagto),
                                 entry(10, p_cod_return_liber_pagto))).

    
    end /* if */.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_botao_down_le_tabelas:

    /************************ Parameter Definition Begin ************************/

    def input-output param p_cod_return
        as character
        format "x(40)"
        no-undo.
        
    /************************* Parameter Definition End *************************/
    
    def var v_log_tit_dupl                   as logical         no-undo. /*local*/
    def var v_val_sdo_tit_ap                 as decimal         no-undo. /*local*/
    def var v_num_seq_bord                   as integer         no-undo. /*local*/
    def var v_cod_cta_ctbl_db                as character       no-undo. /*local*/
    def var v_cod_imposto                    as character       no-undo. /*local*/

    if  tt_titulos_bord.cod_refer_antecip_pef = ""
    then do: /* titulo */
    
        if  tt_titulos_bord.rec_tit_ap <> ? then
            find tit_ap exclusive-lock
                where recid(tit_ap) = tt_titulos_bord.rec_tit_ap no-error.
        if  avail tit_ap then do:
            if  tt_titulos_bord.ind_sit_prepar_liber = "Lib" /*l_Lib*/ 
            then do:
                if  can-find(first proces_pagto  no-lock
                    where proces_pagto.cod_estab             = tit_ap.cod_estab
                     and  proces_pagto.cod_espec_docto       = tit_ap.cod_espec_docto
                     and  proces_pagto.cod_ser_docto         = tit_ap.cod_ser_docto
                     and  proces_pagto.cdn_fornecedor        = tit_ap.cdn_fornecedor
                     and  proces_pagto.cod_tit_ap            = tit_ap.cod_tit_ap
                     and  proces_pagto.cod_parcela           = tit_ap.cod_parcela
                     and  proces_pagto.num_seq_pagto_tit_ap  = tt_titulos_bord.num_seq_pagto_tit_ap
                     and  proces_pagto.ind_sit_proces_pagto = "Em Pagamento" /*l_em_pagamento*/ )
                then do:
                    assign v_log_tit_dupl = yes.
                    return 'next'.
                end.
            end /* if */.
            else do:
                run pi_retornar_saldo_liber_pagto_2 (output v_val_sdo_tit_ap,
                                                     output v_num_seq_bord) /*pi_retornar_saldo_liber_pagto_2*/.
                if  tt_titulos_bord.val_sdo_tit_ap > v_val_sdo_tit_ap
                then do:
                     assign v_log_tit_dupl = yes.
                     return 'next'.
                end.
            end /* else */.
        end.
        
        if  tt_titulos_bord.rec_proces_pagto <> ?
        then do:
            find proces_pagto exclusive-lock
                where recid(proces_pagto) = tt_titulos_bord.rec_proces_pagto no-error.
            if  not avail tit_ap then
                find tit_ap exclusive-lock
                    where tit_ap.cod_estab       = proces_pagto.cod_estab
                    and   tit_ap.cod_espec_docto = proces_pagto.cod_espec_docto
                    and   tit_ap.cod_ser_docto   = proces_pagto.cod_ser_docto
                    and   tit_ap.cdn_fornecedor  = proces_pagto.cdn_fornecedor
                    and   tit_ap.cod_tit_ap      = proces_pagto.cod_tit_ap
                    and   tit_ap.cod_parcela     = proces_pagto.cod_parcela no-error.

            find first tt_proces_pagto_ant exclusive-lock 
                 where tt_proces_pagto_ant.cod_estab       = proces_pagto.cod_estab
                   and tt_proces_pagto_ant.cod_espec_docto = proces_pagto.cod_espec_docto
                   and tt_proces_pagto_ant.cod_ser_docto   = proces_pagto.cod_ser_docto
                   and tt_proces_pagto_ant.cdn_fornecedor  = proces_pagto.cdn_fornecedor
                   and tt_proces_pagto_ant.cod_tit_ap      = proces_pagto.cod_tit_ap
                   and tt_proces_pagto_ant.cod_parcela     = proces_pagto.cod_parcela
                   and tt_proces_pagto_ant.num_seq_pagto_tit_ap = proces_pagto.num_seq_pagto_tit_ap no-error.
            if  not avail tt_proces_pagto_ant then do:
                create tt_proces_pagto_ant.
                assign tt_proces_pagto_ant.cod_estab              = proces_pagto.cod_estab
                       tt_proces_pagto_ant.cod_espec_docto        = proces_pagto.cod_espec_docto
                       tt_proces_pagto_ant.cod_ser_docto          = proces_pagto.cod_ser_docto
                       tt_proces_pagto_ant.cdn_fornecedor         = proces_pagto.cdn_fornecedor
                       tt_proces_pagto_ant.cod_tit_ap             = proces_pagto.cod_tit_ap
                       tt_proces_pagto_ant.cod_parcela            = proces_pagto.cod_parcela
                       tt_proces_pagto_ant.num_seq_pagto_tit_ap   = proces_pagto.num_seq_pagto_tit_ap.
            end.

            assign tt_proces_pagto_ant.cod_empresa            = proces_pagto.cod_empresa
                   tt_proces_pagto_ant.cod_portador           = proces_pagto.cod_portador
                   tt_proces_pagto_ant.dat_vencto_tit_ap      = proces_pagto.dat_vencto_tit_ap
                   tt_proces_pagto_ant.dat_prev_pagto         = proces_pagto.dat_prev_pagto
                   tt_proces_pagto_ant.dat_desconto           = proces_pagto.dat_desconto
                   tt_proces_pagto_ant.ind_sit_proces_pagto   = proces_pagto.ind_sit_proces_pagto
                   tt_proces_pagto_ant.cod_usuar_prepar_pagto = proces_pagto.cod_usuar_prepar_pagto
                   tt_proces_pagto_ant.dat_prepar_pagto       = proces_pagto.dat_prepar_pagto
                   tt_proces_pagto_ant.cod_usuar_liber_pagto  = proces_pagto.cod_usuar_liber_pagto
                   tt_proces_pagto_ant.dat_liber_pagto        = proces_pagto.dat_liber_pagto
                   tt_proces_pagto_ant.val_liberd_pagto       = proces_pagto.val_liberd_pagto
                   tt_proces_pagto_ant.val_liber_pagto_orig   = proces_pagto.val_liber_pagto_orig
                   tt_proces_pagto_ant.cod_indic_econ         = proces_pagto.cod_indic_econ
                   tt_proces_pagto_ant.cod_usuar_pagto        = proces_pagto.cod_usuar_pagto
                   tt_proces_pagto_ant.dat_pagto              = proces_pagto.dat_pagto
                   tt_proces_pagto_ant.ind_modo_pagto         = proces_pagto.ind_modo_pagto
                   tt_proces_pagto_ant.cod_refer_antecip_pef  = proces_pagto.cod_refer_antecip_pef
                   tt_proces_pagto_ant.ttv_rec_proces_pagto   = recid(proces_pagto).

            &if '{&emsfin_version}' < "5.06" &then
                assign tt_proces_pagto_ant.cod_livre_1 = proces_pagto.cod_livre_1.
            &else
                assign tt_proces_pagto_ant.cod_contrat_cambio        = proces_pagto.cod_contrat_cambio
                       tt_proces_pagto_ant.dat_contrat_cambio_import = proces_pagto.dat_contrat_cambio_import
                       tt_proces_pagto_ant.num_contrat_id_cambio     = proces_pagto.num_contrat_id_cambio
                       tt_proces_pagto_ant.cod_estab_contrat_cambio  = proces_pagto.cod_estab_contrat_cambio
                       tt_proces_pagto_ant.cod_refer_contrat_cambio  = proces_pagto.cod_refer_contrat_cambio
                       tt_proces_pagto_ant.dat_refer_contrat_cambio  = proces_pagto.dat_refer_contrat_cambio
                       tt_proces_pagto_ant.val_cotac_indic_econ      = proces_pagto.val_cotac_indic_econ.
            &endif
        end.

        if  not avail tit_ap
        then do:
            if  not locked tit_ap
            and not locked proces_pagto then
                delete tt_titulos_bord.
            assign v_log_exist = yes.
            return "next" /*l_next*/ .
        end.
    end.
    
    //----------------------------------------------------------------------------------------------------

    else do: /* antecipacao */
    
        if  tt_titulos_bord.rec_tit_ap <> ? then
            find antecip_pef_pend exclusive-lock
                where recid(antecip_pef_pend) = tt_titulos_bord.rec_tit_ap no-error.

        if  not avail antecip_pef_pend then 
            find antecip_pef_pend exclusive-lock
                where antecip_pef_pend.cod_estab = tt_titulos_bord.cod_estab
                and   antecip_pef_pend.cod_refer = tt_titulos_bord.cod_refer_antecip_pef no-error.
        
        if  avail antecip_pef_pend then do:
            if can-find (first proces_pagto
                where proces_pagto.cod_estab             = antecip_pef_pend.cod_estab
                and   proces_pagto.cod_refer_antecip_pef = antecip_pef_pend.cod_refer
                and   proces_pagto.ind_sit_proces_pagto  = "Em Pagamento" /*l_em_pagamento*/ ) then do:
                assign v_log_tit_dupl = yes.
                
                CREATE tt-retorno.
                ASSIGN tt-retorno.versao-api = c-versao-api 
                       tt-retorno.cod-status = 398
                       tt-retorno.desc-retorno = "Antecipaá∆o j† est† em pagamento: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                return 'next'.
            end.
        end.
        
        if  tt_titulos_bord.rec_proces_pagto <> ?
        then do:
            find proces_pagto exclusive-lock
                where recid(proces_pagto) = tt_titulos_bord.rec_proces_pagto no-error.
            if not avail antecip_pef_pend then
                find antecip_pef_pend exclusive-lock
                    where antecip_pef_pend.cod_estab = proces_pagto.cod_estab
                    and   antecip_pef_pend.cod_refer = proces_pagto.cod_refer_antecip_pef no-error.

            create tt_proces_pagto_ant.
            assign tt_proces_pagto_ant.cod_empresa            = proces_pagto.cod_empresa
                   tt_proces_pagto_ant.cod_estab              = proces_pagto.cod_estab
                   tt_proces_pagto_ant.cod_espec_docto        = proces_pagto.cod_espec_docto
                   tt_proces_pagto_ant.cod_ser_docto          = proces_pagto.cod_ser_docto
                   tt_proces_pagto_ant.cdn_fornecedor         = proces_pagto.cdn_fornecedor
                   tt_proces_pagto_ant.cod_tit_ap             = proces_pagto.cod_tit_ap
                   tt_proces_pagto_ant.cod_parcela            = proces_pagto.cod_parcela
                   tt_proces_pagto_ant.num_seq_pagto_tit_ap   = proces_pagto.num_seq_pagto_tit_ap

                   tt_proces_pagto_ant.cod_portador           = proces_pagto.cod_portador
                   tt_proces_pagto_ant.dat_vencto_tit_ap      = proces_pagto.dat_vencto_tit_ap
                   tt_proces_pagto_ant.dat_prev_pagto         = proces_pagto.dat_prev_pagto
                   tt_proces_pagto_ant.dat_desconto           = proces_pagto.dat_desconto
                   tt_proces_pagto_ant.ind_sit_proces_pagto   = proces_pagto.ind_sit_proces_pagto
                   tt_proces_pagto_ant.cod_usuar_prepar_pagto = proces_pagto.cod_usuar_prepar_pagto
                   tt_proces_pagto_ant.dat_prepar_pagto       = proces_pagto.dat_prepar_pagto
                   tt_proces_pagto_ant.cod_usuar_liber_pagto  = proces_pagto.cod_usuar_liber_pagto
                   tt_proces_pagto_ant.dat_liber_pagto        = proces_pagto.dat_liber_pagto
                   tt_proces_pagto_ant.val_liberd_pagto       = proces_pagto.val_liberd_pagto
                   tt_proces_pagto_ant.val_liber_pagto_orig   = proces_pagto.val_liber_pagto_orig
                   tt_proces_pagto_ant.cod_indic_econ         = proces_pagto.cod_indic_econ
                   tt_proces_pagto_ant.cod_usuar_pagto        = proces_pagto.cod_usuar_pagto
                   tt_proces_pagto_ant.dat_pagto              = proces_pagto.dat_pagto
                   tt_proces_pagto_ant.ind_modo_pagto         = proces_pagto.ind_modo_pagto
                   tt_proces_pagto_ant.cod_refer_antecip_pef  = proces_pagto.cod_refer_antecip_pef
                   tt_proces_pagto_ant.ttv_rec_proces_pagto   = recid(proces_pagto).

            &if '{&emsfin_version}' < "5.06" &then
                assign tt_proces_pagto_ant.cod_livre_1 = proces_pagto.cod_livre_1.
            &else
                assign tt_proces_pagto_ant.cod_contrat_cambio        = proces_pagto.cod_contrat_cambio
                       tt_proces_pagto_ant.dat_contrat_cambio_import = proces_pagto.dat_contrat_cambio_import
                       tt_proces_pagto_ant.num_contrat_id_cambio     = proces_pagto.num_contrat_id_cambio
                       tt_proces_pagto_ant.cod_estab_contrat_cambio  = proces_pagto.cod_estab_contrat_cambio
                       tt_proces_pagto_ant.cod_refer_contrat_cambio  = proces_pagto.cod_refer_contrat_cambio
                       tt_proces_pagto_ant.dat_refer_contrat_cambio  = proces_pagto.dat_refer_contrat_cambio
                       tt_proces_pagto_ant.val_cotac_indic_econ      = proces_pagto.val_cotac_indic_econ.
            &endif
        end.
        
        if  not avail antecip_pef_pend
        then do:
            if  not locked antecip_pef_pend
            and not locked proces_pagto then do:
                CREATE tt-retorno.
                ASSIGN tt-retorno.versao-api = c-versao-api 
                       tt-retorno.cod-status = 398
                       tt-retorno.desc-retorno = "Erro na leitura da antecipaá∆o: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
                delete tt_titulos_bord.
            end.
                            
            assign v_log_exist = yes.
            return "next" /*l_next*/ .
        end.
        else
            assign antecip_pef_pend.ind_sit_pef_antecip = "Em Pagamento" /*l_em_pagamento*/ .
            
        if  can-find( first tt_pagamentos_realizados
            where tt_pagamentos_realizados.ttv_rec_tit_ap = recid(antecip_pef_pend) ) then do:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status = 398
                   tt-retorno.desc-retorno = "Antecipaá∆o j† foi paga: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
            return "next" /*l_next*/ .
        end.
        
        if  p_ind_modo_pagto <> "Liberaá∆o" /*l_liberacao*/ 
        and  p_ind_modo_pagto <> "Preparaá∆o" /*l_preparacao*/ 
        then do:

// everton revisar - essa procedure "pi_validar_impto_impl_pend_antecip" n∆o existe no programa
/*           run pi_validar_impto_impl_pend_antecip (Input tt_titulos_bord.cod_estab, */
/*                                                   Input tt_titulos_bord.cod_refer_antecip_pef, */
/*                                                   Input "", */
/*                                                   Input 0, */
/*                                                   Input 0, */
/*                                                   Input "Retido" /*l_retido*/, */
/*                                                   Input bord_ap.dat_transacao, */
/*                                                   output p_cod_return, */
/*                                                   output v_cod_cta_ctbl_db, */
/*                                                   output v_cod_imposto) /*pi_validar_impto_impl_pend_antecip*/. */
/*            if  p_cod_return <> "OK" /*l_ok*/ */
/*            then do: */
/*               /* Conta DÇbito Antecipaá∆o utiliza Centro de Custo ! */ */
/*               run pi_messages (input "show", */
/*                                input 9440, */
/*                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", */
/*                                                   v_cod_cta_ctbl_db, v_cod_imposto)) /*msg_9440*/. */
/*    */
/*               CREATE tt-retorno. */
/*               ASSIGN tt-retorno.versao-api = c-versao-api */
/*                      tt-retorno.cod-status = 398 */
/*                      tt-retorno.desc-retorno = "Conta DÇbito Antecipaá∆o utiliza Centro de Custo: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef. */
/*    */
/*               return "undo next" /*l_undo_next*/ . */
/*            end. */
        end.
    end.
    return "OK" /*l_ok*/ .
END PROCEDURE.

//----------------------------------------------------------------------------------------------------
PROCEDURE pi_verifica_permis_pagto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_modo_pagto
        as character
        format "X(10)"
        no-undo.
    def output param p_cod_return_liber_pagto
        as character
        format "x(8)"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ_aux
        as character
        format "x(10)":U
        label "Finalidade"
        column-label "Finalidade"
        no-undo.
    def var v_cod_indic_econ_pag
        as character
        format "x(8)":U
        label "Moeda"
        column-label "Moeda"
        no-undo.

    /************************** Variable Definition End *************************/

    /*if p_ind_modo_pagto = "Cheque" /*l_cheque*/  then do:
        find usuar_financ_estab_apb
            where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
            and   usuar_financ_estab_apb.cod_estab   = lote_pagto.cod_estab
            no-lock no-error.
        run pi_retornar_finalid_indic_econ_tt (Input tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ,
                                               Input lote_pagto.dat_transacao,
                                               output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ_tt*/.
        run pi_retornar_finalid_indic_econ_tt (Input bord_ap.cod_indic_econ,
                                               Input lote_pagto.dat_transacao,
                                               output v_cod_finalid_econ_aux) /*pi_retornar_finalid_indic_econ_tt*/.

        run pi_verificar_val_usuar_cotac_inf (Input lote_pagto.cod_estab,
                                              Input lote_pagto.dat_transacao,
                                              Input "Pagamento" /*l_pagamento*/,
                                              Input tt_titulos_bord.val_pagto_moe,
                                              Input usuar_financ_estab_apb.val_lim_liber_usuar_movto,
                                              Input usuar_financ_estab_apb.val_lim_liber_usuar_mes,
                                              Input usuar_financ_estab_apb.val_lim_pagto_usuar_movto,
                                              Input usuar_financ_estab_apb.val_lim_pagto_usuar_mes,
                                              Input v_cod_finalid_econ,
                                              Input v_cod_finalid_econ_aux,
                                              Input tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ,
                                              Input bord_ap.cod_indic_econ,
                                              Input tt_titulo_antecip_pef_a_pagar.tta_val_cotac_indic_econ,
                                              output p_cod_return_liber_pagto,
                                              output p_cod_return) /*pi_verificar_val_usuar_cotac_inf*/.
    end.
    else*/ do:
        find usuar_financ_estab_apb
            where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
            and   usuar_financ_estab_apb.cod_estab   = bord_ap.cod_estab
            no-lock no-error.
        run pi_retornar_finalid_indic_econ_tt (Input tt_titulos_bord.cod_indic_econ,
                                               Input bord_ap.dat_transacao,
                                               output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ_tt*/.

        run pi_verificar_val_usuar_cotac_inf (Input bord_ap.cod_estab,
                                              Input bord_ap.dat_transacao,
                                              Input "Pagamento" /*l_pagamento*/,
                                              Input tt_titulos_bord.val_pagto_moe,
                                              Input usuar_financ_estab_apb.val_lim_liber_usuar_movto,
                                              Input usuar_financ_estab_apb.val_lim_liber_usuar_mes,
                                              Input usuar_financ_estab_apb.val_lim_pagto_usuar_movto,
                                              Input usuar_financ_estab_apb.val_lim_pagto_usuar_mes,
                                              Input v_cod_finalid_econ,
                                              Input bord_ap.cod_finalid_econ,
                                              Input tt_titulos_bord.cod_indic_econ,
                                              Input bord_ap.cod_indic_econ,
                                              Input tt_titulos_bord.val_cotac_indic_econ,
                                              output p_cod_return_liber_pagto,
                                              output p_cod_return) /*pi_verificar_val_usuar_cotac_inf*/.
    end. 
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_choose_bt_ok_f_dlg_03_item_lote_pagto_conjunto:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_impto_impl_pend_ap
        for impto_impl_pend_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_indic_econ_aux
        as character
        format "x(8)":U
        label "Moeda"
        column-label "Moeda"
        no-undo.
    def var v_cod_msg
        as character
        format "x(255)":U
        label "Mensagem"
        column-label "Mensagem"
        no-undo.
    def var v_dat_transacao
        as date
        format "99/99/9999":U
        label "Data Transaá∆o"
        column-label "Data Transaá∆o"
        no-undo.
    def var v_log_aux_2
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        no-undo.
    def var v_log_bloq_pagto
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Bloqueia Pagamento"
        no-undo.
    def var v_log_excec
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        no-undo.
    def var v_log_fornec_aux
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        no-undo.
    def var v_log_retorno
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_num_seq
        as integer
        format ">>>,>>9":U
        label "SeqÅància"
        column-label "Seq"
        no-undo.
    def var v_val_aux
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        initial 0
        no-undo.
    def var v_cod_indic_econ_geral           as character       no-undo. /*local*/
    def var v_log_abat_antecip               as logical         no-undo. /*local*/
    def var v_val_tot_abat                   as decimal         no-undo. /*local*/
    def var v_val_tot_pagto_impto            as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_dat_transacao = today.

    if  v_nom_prog_upc <> '' then do:
        assign v_rec_table_epc = recid(bord_ap).
        run value(v_nom_prog_upc) (input 'valid_item_pgto_antecip',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input '',
                                   input v_rec_table_epc).

        if  return-value = "NOK" /*l_nok*/  then 
        do:
            return 'NOK'.
        end.  

    end.


    for each tt_log_erros_atualiz:
        delete tt_log_erros_atualiz.
    end.

    assign v_log_erro = no.
    for EACH tt_titulos_bord 
        where tt_titulos_bord.log_mostra_tit = no:

        run pi_choose_bt_ok_f_dlg_03_item_lote_pagto_conjunto_compl.
        if  return-value = "NOK" /*l_nok*/  then
            return "NOK" /*l_nok*/ .

        assign v_log_achou = NO. //Verifica_Program_Name('apb711aa':U, 30).

        assign v_log_excec = no.
        IF AVAIL bord_ap THEN DO:
            IF bord_ap.log_bord_ap_escrit = no THEN 
                assign v_log_excec = YES.
            ELSE
                assign v_log_excec = NO.
        END.

        IF AVAIL proces_pagto OR AVAIL lote_pagto THEN DO:

            FIND FIRST portador no-lock
                WHERE portador.cod_portador = bord_ap.cod_portador NO-ERROR.
            IF AVAIL portador AND portador.ind_tip_portad <> "Caixa" /*l_caixa*/  then 
                    assign v_log_excec = no.
        END.

        /*if valid-handle(v_hdl_funcao_mex) then do:
            if v_log_excec
            or (v_log_achou_2 and avail portador and portador.ind_tip_portad = "Caixa" /*l_caixa*/ ) then do:

                assign v_val_cotac_indic_econ = 1
                       v_log_fornec_aux       = yes.

                if v_log_achou and avail lote_pagto then
                        assign v_dat_transacao = lote_pagto.dat_transacao.
                else
                    if avail bord_ap then
                        assign v_dat_transacao = bord_ap.dat_transacao. 

                IF p_dat_liber_pagto <> ? THEN
                    ASSIGN v_dat_transacao = p_dat_liber_pagto.

                IF AVAIL bord_ap THEN DO:
                    ASSIGN v_cod_indic_econ_geral = bord_ap.cod_indic_econ.
                    FIND FIRST b_item_bord_ap no-lock
                        where b_item_bord_ap.cod_estab_bord  = bord_ap.cod_estab_bord
                        and   b_item_bord_ap.cod_portador    = bord_ap.cod_portador
                        AND   b_item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap 
                        AND   b_item_bord_ap.cod_estab       = tt_titulo_antecip_pef_a_pagar.tta_cod_estab
                        and   b_item_bord_ap.cod_ser_docto   = tt_titulo_antecip_pef_a_pagar.tta_cod_ser_docto
                        AND   b_item_bord_ap.cod_espec_docto = tt_titulo_antecip_pef_a_pagar.tta_cod_espec_docto
                        and   b_item_bord_ap.cdn_fornecedor  = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor
                        and   b_item_bord_ap.cod_tit_ap      = tt_titulo_antecip_pef_a_pagar.tta_cod_tit_ap
                        and   b_item_bord_ap.cod_parcela     = tt_titulo_antecip_pef_a_pagar.tta_cod_parcela 
                        AND   b_item_bord_ap.cod_refer_antecip_pef = tt_titulo_antecip_pef_a_pagar.tta_cod_refer_antecip_pef
                        NO-ERROR.
                    IF AVAIL b_item_bord_ap THEN DO:

                        assign v_val_tot_pagto_impto = 0.

                        for each b_impto_impl_pend_ap no-lock
                            where b_impto_impl_pend_ap.cod_estab_refer = b_item_bord_ap.cod_estab_bord
                            and   b_impto_impl_pend_ap.cod_refer       = "" /* l_*/ 
                            and   b_impto_impl_pend_ap.cod_portador    = b_item_bord_ap.cod_portador
                            and   b_impto_impl_pend_ap.num_bord_ap     = b_item_bord_ap.num_bord_ap
                            and   b_impto_impl_pend_ap.num_seq_refer   = b_item_bord_ap.num_seq_bord:
                            assign v_val_tot_pagto_impto = v_val_tot_pagto_impto + b_impto_impl_pend_ap.val_imposto.
                        end.

                        run pi_verificar_abat_antecip_voucher_pagto (Input b_item_bord_ap.cod_estab_bord,
                                                                     Input " ",
                                                                     Input b_item_bord_ap.num_seq_bord,
                                                                     Input b_item_bord_ap.cod_portador,
                                                                     Input b_item_bord_ap.num_bord_ap,
                                                                     Input "Antecipaá∆o" /*l_antecipacao*/,
                                                                     output v_log_abat_antecip,
                                                                     output v_val_tot_abat_antecip,
                                                                     output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.

                        ASSIGN v_val_aux = b_item_bord_ap.val_pagto        +
                                           b_item_bord_ap.val_multa_tit_ap +
                                           b_item_bord_ap.val_juros        +
                                           b_item_bord_ap.val_cm_tit_ap    -
                                           b_item_bord_ap.val_desc_tit_ap  -
                                           b_item_bord_ap.val_abat_tit_ap  -
                                           v_val_tot_abat_antecip          -
                                           v_val_tot_pagto_impto
                               v_cod_msg = "".
                    END.
                END.
                ELSE IF AVAIL lote_pagto THEN DO:
                /* pagamento via caixa ou cheque */
                    find first b_item_lote_pagto no-lock
                         where b_item_lote_pagto.cod_estab_refer = lote_pagto.cod_estab_refer
                           and b_item_lote_pagto.cod_refer       = lote_pagto.cod_refer
                           and b_item_lote_pagto.cod_estab       = tt_titulo_antecip_pef_a_pagar.tta_cod_estab
                           and b_item_lote_pagto.cod_espec_docto = tt_titulo_antecip_pef_a_pagar.tta_cod_espec_docto
                           and b_item_lote_pagto.cod_ser_docto   = tt_titulo_antecip_pef_a_pagar.tta_cod_ser_docto
                           and b_item_lote_pagto.cdn_fornecedor  = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor
                           and b_item_lote_pagto.cod_tit_ap      = tt_titulo_antecip_pef_a_pagar.tta_cod_tit_ap
                           and b_item_lote_pagto.cod_parcela     = tt_titulo_antecip_pef_a_pagar.tta_cod_parcela NO-ERROR.
                    IF AVAIL b_item_lote_pagto THEN do:

                        assign v_val_tot_pagto_impto = 0
                               v_val_tot_abat_antecip = 0
                               v_cod_indic_econ_geral = b_item_lote_pagto.cod_indic_econ.

                        for each b_impto_impl_pend_ap no-lock
                            where b_impto_impl_pend_ap.cod_estab_refer = b_item_lote_pagto.cod_estab_refer
                            and   b_impto_impl_pend_ap.cod_refer       = b_item_lote_pagto.cod_refer
                            and   b_impto_impl_pend_ap.num_seq_refer   = b_item_lote_pagto.num_seq_refer:
                            assign v_val_tot_pagto_impto = v_val_tot_pagto_impto + b_impto_impl_pend_ap.val_imposto.
                        end.

                        for each abat_antecip_vouch no-lock
                            where abat_antecip_vouch.cod_estab_refer = b_item_lote_pagto.cod_estab_refer
                              and abat_antecip_vouch.cod_refer       = b_item_lote_pagto.cod_refer
                              and abat_antecip_vouch.cod_portador    = ""
                              and abat_antecip_vouch.num_bord_ap     = 0
                              and abat_antecip_vouch.num_seq_refer   = b_item_lote_pagto.num_seq_refer:

                            assign v_val_tot_abat_antecip = v_val_tot_abat_antecip + abat_antecip_vouch.val_abtdo_antecip.
                        end.

                        ASSIGN v_val_aux = b_item_lote_pagto.val_pagto
                                           + b_item_lote_pagto.val_multa_tit_ap
                                           - b_item_lote_pagto.val_desc_tit_ap
                                           + b_item_lote_pagto.val_juros
                                           - b_item_lote_pagto.val_abat_tit_ap
                                           + b_item_lote_pagto.val_cm_tit_ap
                                           - v_val_tot_pagto_impto
                                           - v_val_tot_abat_antecip
                              v_cod_msg = "".
                    end.
                END.
                ELSE DO:
                    if avail antecip_pef_pend then do:
                        find first proces_pagto no-lock
                             where proces_pagto.cod_estab = antecip_pef_pend.cod_estab
                               and proces_pagto.cod_refer_antecip_pef = antecip_pef_pend.cod_refer no-error.
                        if avail proces_pagto then
                            assign v_val_aux = proces_pagto.val_liberd_pagto
                                   v_cod_msg = "Itens" /*l_itens*/ 
                                   v_cod_indic_econ_geral = proces_pagto.cod_indic_econ.
                    end.
                END.

                /* Retornar o Indicador econìmico do t°tulo*/
                run pi_retornar_indic_econ_corren_estab (Input v_cod_estab_usuar,
                                                         Input v_dat_transacao,
                                                         output v_cod_indic_econ_aux) /*pi_retornar_indic_econ_corren_estab*/.

                if v_cod_indic_econ_aux <> v_cod_indic_econ_geral THEN DO:                                                                
                    run pi_achar_cotac_indic_econ in v_hdl_indic_econ_finalid (Input v_cod_indic_econ_geral,
                                                                               Input v_cod_indic_econ_aux,
                                                                               Input v_dat_transacao,
                                                                               Input "Real" /*l_real*/ ,
                                                                               output v_dat_cotac_indic_econ,
                                                                               output v_val_cotac_indic_econ,
                                                                               output v_cod_return) /* pi_achar_cotac_indic_econ*/.

                    IF v_cod_return <> "OK" /*l_ok*/  THEN DO:
                        /* erro_block: */
                        case entry(1, v_cod_return):
                            when "335" then  /* Indicador Econìmico Inexistente ! */
                              run pi_messages (input "show",
                                               input 335,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_335*/.
                            when "358" then  /* Cotaá∆o entre Indicadores Econìmicos n∆o encontrada ! */
                              run pi_messages (input "show",
                                               input 358,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                                 entry(2,v_cod_return), entry(3, v_cod_return), entry(4, v_cod_return), entry(5, v_cod_return))) /*msg_358*/.
                        end /* case erro_block */.
                        return "NOK" /*l_nok*/ .
                    end.            

                    ASSIGN v_val_aux = v_val_aux / v_val_cotac_indic_econ.

                    /* Recebe o n£mero de sequància */
                    if v_log_achou then
                        IF AVAIL b_item_lote_pagto THEN
                            ASSIGN v_num_seq = b_item_lote_pagto.num_seq_refer.
                        ELSE IF AVAIL ITEM_bord_ap THEN
                            ASSIGN v_num_seq = item_bord_ap.num_seq_pagto_tit_ap.
                        ELSE IF AVAIL item_lote_pagto THEN
                            ASSIGN v_num_seq = item_lote_pagto.num_seq_refer.
                    ELSE 
                        ASSIGN v_num_seq = tt_titulo_antecip_pef_a_pagar.tta_num_seq_pagto_tit_ap.                                                                
                END.

                RUN pi_identif_fornec_nacional IN v_hdl_funcao_mex (INPUT v_cod_empres_usuar,
                                                                    INPUT tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor,
                                                                    OUTPUT v_log_fornec_aux).    

                if v_log_fornec_aux then do:
                    RUN pi_validar_bloq_pagto_bord IN v_hdl_funcao_mex (Input v_cod_empres_usuar,
                                                                        Input v_val_aux,
                                                                        OUTPUT v_log_retorno,
                                                                        OUTPUT v_log_bloq_pagto).            
                end.

                IF v_log_retorno THEN DO:
                    ASSIGN v_log_aux_2 = YES.
                    CREATE tt_item_bord_lote_mensagem.
                    ASSIGN tt_item_bord_lote_mensagem.tta_cod_empresa           = v_cod_empres_usuar
                           tt_item_bord_lote_mensagem.tta_num_seq_bord          = v_num_seq
                           tt_item_bord_lote_mensagem.tta_cod_estab             = tt_titulo_antecip_pef_a_pagar.tta_cod_estab
                           tt_item_bord_lote_mensagem.tta_cod_refer_antecip_pef = tt_titulo_antecip_pef_a_pagar.tta_cod_refer_antecip_pef
                           tt_item_bord_lote_mensagem.tta_cod_espec_docto       = tt_titulo_antecip_pef_a_pagar.tta_cod_espec_docto
                           tt_item_bord_lote_mensagem.tta_cod_ser_docto         = tt_titulo_antecip_pef_a_pagar.tta_cod_ser_docto
                           tt_item_bord_lote_mensagem.tta_cdn_fornecedor        = tt_titulo_antecip_pef_a_pagar.tta_cdn_fornecedor
                           tt_item_bord_lote_mensagem.tta_cod_tit_ap            = tt_titulo_antecip_pef_a_pagar.tta_cod_tit_ap
                           tt_item_bord_lote_mensagem.tta_cod_parcela           = tt_titulo_antecip_pef_a_pagar.tta_cod_parcela
                           tt_item_bord_lote_mensagem.tta_val_pagto             = v_val_aux.
                END.
            END.
        end.*/
    END.

    /* Caso seja criada a temptable com problemas ent∆o mosta a mensagem respectiva */
    /*IF v_log_aux_2 THEN DO:
        RUN pi_mensagens_itens IN v_hdl_funcao_mex (Input  tt_item_bord_lote_mensagem.tta_cod_empresa,
                                                    Input  v_cod_msg,
                                                    INPUT  v_log_bloq_pagto,
                                                    OUTPUT v_log_retorno).
        FOR EACH tt_item_bord_lote_mensagem:
            DELETE tt_item_bord_lote_mensagem.
        END.

        ASSIGN v_log_aux_2 = NO.

        IF v_log_retorno THEN
            RETURN "NOK" /*l_nok*/ .
    END.*/

    run pi_validar_cb4_tit_ap_bco_cobdor /*pi_validar_cb4_tit_ap_bco_cobdor*/.

    if v_log_erro then do:
        if can-find(first tt_log_erros_atualiz) then
            run prgint/ufn/ufn901za.py (Input 1) /* prg_api_mostra_log_erros*/.
        return 'NOK'.
    end.
    return 'OK'.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_valida_pgto_selec_cjto_integr_mec:

    if v_log_achou_2 or v_log_achou_3 then
        assign v_cod_indic_econ_pag = "" /*l_*/ .    

    if avail bord_ap then
        assign v_cod_indic_econ_pag = bord_ap.cod_indic_econ.

    run pi_retornar_indic_econ_corren_estab (input tt_titulos_bord.cod_estab,
                                             input tt_titulos_bord.dat_emis_docto,
                                             output v_cod_indic_econ_corren).

    find param_integr_ems no-lock
        where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
    if  avail param_integr_ems then do:     
        run pi_valida_antecip_mec (INPUT tt_param.cod_empresa, 
                                   INPUT tt_titulos_bord.cod_estab,
                                   INPUT tt_titulos_bord.cod_espec_docto,
                                   INPUT tt_titulos_bord.cod_ser_docto,
                                   INPUT tt_titulos_bord.cdn_fornecedor,
                                   INPUT tt_titulos_bord.cod_tit_ap,
                                   INPUT tt_titulos_bord.cod_parcela,
                                   INPUT tt_titulos_bord.cod_indic_econ,
                                   INPUT tt_titulos_bord.dat_emis_docto,
                                   INPUT 12533, 
                                   OUTPUT table tt_log_erros).                             
        find tt_log_erros where tt_log_erros.ttv_num_cod_erro <> 0 no-error.
        if  avail tt_log_erros then do:
            for each tt_log_erros:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.ttv_num_mensagem  = tt_log_erros.ttv_num_cod_erro
                       tt_log_erros_atualiz.ttv_des_msg_erro  = tt_log_erros.ttv_des_erro
                       tt_log_erros_atualiz.ttv_des_msg_ajuda = tt_log_erros.ttv_des_ajuda.
            end.
            if  search("prgint/ufn/ufn901za.r") = ? and search("prgint/ufn/ufn901za.py") = ? then do:
                if  v_cod_dwb_user begins 'es_' then
                    return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn901za.py".
                else do:
                    message "Programa execut†vel n∆o foi encontrado: prgint/ufn/ufn901za.py"
                           view-as alert-box error buttons ok.
                    return.
                end.
            end.
            else
                run prgint/ufn/ufn901za.py (Input 1) /*prg_api_mostra_log_erros*/.
        end.
        if return-value = "NOK" /*l_nok*/  then
           return "NOK" /*l_nok*/ .
        else return "OK" /*l_ok*/ .
    end.
    return "OK" /*l_ok*/ .
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gerar_item_pagto_cjto_titulo_bord:

    /************************ Parameter Definition Begin ************************/

    def Input param p_val_pagto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def Input param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_juros_pagto_autom
        as character
        format "X(14)"
        no-undo.
    def Input param p_num_seq
        as integer
        format ">>>,>>9"
        no-undo.
    def output param p_cod_finalid_econ_base
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_impto_impl_pend_ap
        for impto_impl_pend_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap
        for item_bord_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_agenc
        as character
        format "x(8)":U
        no-undo.
    def var v_cod_banco
        as character
        format "x(8)":U
        label "Banco"
        column-label "Banco"
        no-undo.
    def var v_cod_cta_corren
        as character
        format "x(10)":U
        label "Conta Corrente"
        column-label "Conta Corrente"
        no-undo.
    def var v_cod_digito_agenc
        as character
        format "x(2)":U
        label "D°gito Agància"
        column-label "D°gito Agància"
        no-undo.
    def var v_cod_digito_cta_corren
        as character
        format "x(2)":U
        label "D°gito Cta Corrente"
        column-label "D°gito Cta Corrente"
        no-undo.
    def var v_cod_empresa
        as character
        format "x(3)":U
        label "Empresa"
        column-label "Empresa"
        no-undo.
    def var v_cod_estab
        as character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    def var v_cod_estab_aux
        as character
        format "x(5)":U
        label "Estabelecimento"
        column-label "Estabelecimento"
        no-undo.
    def var v_cod_moeda
        as character
        format "x(8)":U
        label "Moeda"
        column-label "Moeda"
        no-undo.
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
    def var v_hdl_aux
        as Handle
        format ">>>>>>9":U
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
    def var v_num_natur
        as integer
        format ">>>>,>>9":U
        no-undo.
    def var v_num_seq_refer
        as integer
        format ">>>9":U
        label "Sequància"
        column-label "Sequància"
        no-undo.
    def var v_dat_acum_impto                 as date            no-undo. /*local*/
    def var v_log_abat_antecip               as logical         no-undo. /*local*/
    def var v_val_tot_abat                   as decimal         no-undo. /*local*/
    def var v_val_tot_desemb                 as decimal         no-undo. /*local*/
    def var v_val_tot_pagto_impto            as decimal         no-undo. /*local*/
    DEF VAR v_log_favorec_cheq_adm           AS LOGICAL         NO-UNDO.
    DEF VAR v_nom_favorec_cheq_aux           AS CHARACTER       NO-UNDO.
    def var v_nom_favorec_cheq               as character       no-undo.
    def var v_ind_favorec_cheq               as character       no-undo.
    DEF VAR v_cod_empres_usuar_2             AS CHARACTER       NO-UNDO.
    DEF VAR v_num_dias_atraso                as INTEGER         no-undo.
    DEF VAR v_log_dia_util                   AS LOGICAL         NO-UNDO.
    DEF VAR v_val_tax_calcul                 AS DECIMAL         NO-UNDO.
    DEF VAR v_log_tax_calcul                 AS LOGICAL         NO-UNDO.
    DEF VAR v_val_acerto_impl                AS DECIMAL         NO-UNDO.
    DEF VAR v_val_impto_calc                 AS DECIMAL         NO-UNDO.
    DEF VAR v_val_perc_val_pagto             AS DECIMAL         NO-UNDO.
    DEF VAR v_val_tot_abat_antecip           AS DECIMAL         NO-UNDO.

    /************************** Variable Definition End *************************/

    find last b_item_bord_ap
        where b_item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
        and   b_item_bord_ap.cod_portador   = bord_ap.cod_portador
        and   b_item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap
        no-lock no-error.
    assign v_num_seq_refer = if avail b_item_bord_ap
             then b_item_bord_ap.num_seq_bord + 1 else 1.

    &if  defined(BF_FIN_FAVOR_CH_ADM) &then
         assign v_log_favorec_cheq_adm = yes.
    &else
        &if '{&emsfin_version}' > '5.01' &then
            find FIRST histor_exec_especial
                where histor_exec_especial.cod_modul_dtsul = 'UFN'
                and   histor_exec_especial.cod_prog_dtsul  = 'spp_favor_ch_adm':U
                no-lock no-error.
            if  avail histor_exec_especial then
                assign v_log_favorec_cheq_adm = yes.
        &endif     
    &endif

    if  v_log_favorec_cheq_adm then do: 
        if  v_nom_favorec_cheq_aux = "" then do:
            find FIRST fornecedor no-lock
            where fornecedor.cdn_fornecedor = tt_titulos_bord.cdn_fornecedor
            and   fornecedor.cod_empresa    = v_cod_empres_usuar no-error.
            assign v_nom_favorec_cheq = fornecedor.nom_pessoa
                   v_ind_favorec_cheq = "Fornecedor" /*l_fornecedor*/ .
        end.
    end.    

    FOR FIRST portador NO-LOCK
        WHERE portador.cod_portador = bord_ap.cod_portador:
    END.

    create item_bord_ap.
    assign item_bord_ap.cod_empresa           = bord_ap.cod_empresa
           item_bord_ap.cod_estab_bord        = bord_ap.cod_estab_bord
           item_bord_ap.cod_portador          = bord_ap.cod_portador
           item_bord_ap.num_bord_ap           = bord_ap.num_bord_ap
           item_bord_ap.num_seq_bord          = v_num_seq_refer
           item_bord_ap.cod_refer_antecip_pef = ""
           item_bord_ap.cod_estab             = tt_titulos_bord.cod_estab
           item_bord_ap.cod_espec_docto       = tt_titulos_bord.cod_espec_docto
           item_bord_ap.cod_ser_docto         = tt_titulos_bord.cod_ser_docto
           item_bord_ap.cdn_fornecedor        = tt_titulos_bord.cdn_fornecedor
           item_bord_ap.cod_tit_ap            = tt_titulos_bord.cod_tit_ap
           item_bord_ap.cod_parcela           = tt_titulos_bord.cod_parcela
           item_bord_ap.num_seq_pagto_tit_ap  = p_num_seq
           item_bord_ap.cod_banco             = portador.cod_banco
           item_bord_ap.val_pagto             = p_val_pagto
           item_bord_ap.ind_sit_item_bord_ap  = "Em Aberto" /*l_em_aberto*/ 
           item_bord_ap.num_id_item_bord_ap   = next-value(seq_item_bord_ap)
           item_bord_ap.log_pix_sem_chave     = tt_param.log_pix_sem_chave
.
           
    if  tt_param.cod_histor_padr <> "" then do:
        find first histor_padr no-lock
            where histor_padr.cod_histor_padr         = tt_param.cod_histor_padr
            and   histor_padr.cod_modul_dtsul         = "APB" /*l_apb*/ 
            and   histor_padr.cod_finalid_histor_padr = "PagtBord" /*l_pagtbord*/  no-error.
        if avail histor_padr then
            assign item_bord_ap.des_text_histor = histor_padr.des_text_histor.
    end.       

    find param_integr_ems no-lock
       where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
    if avail param_integr_ems then do:
       run pi_verificar_fornec_estrangeiro(input item_bord_ap.cod_empresa,
                                           input item_bord_ap.cdn_fornecedor,
                                           input item_bord_ap.cod_estab,
                                           input tt_titulos_bord.cod_indic_econ,
                                           input tit_ap.dat_vencto_tit_ap, 
                                           output v_cod_moeda,
                                           output v_num_natur).
       if  v_num_natur = 3 and
           v_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  then do:
           find first proces_pagto
              where proces_pagto.cod_estab            = item_bord_ap.cod_estab
                and proces_pagto.cod_espec_docto      = item_bord_ap.cod_espec_docto
                and proces_pagto.cdn_fornecedor       = item_bord_ap.cdn_fornecedor
                and proces_pagto.cod_ser_docto        = item_bord_ap.cod_ser_docto
                and proces_pagto.cod_tit_ap           = item_bord_ap.cod_tit_ap
                and proces_pagto.cod_parcela          = item_bord_ap.cod_parcela
                and proces_pagto.num_seq_pagto_tit_ap = item_bord_ap.num_seq_pagto_tit_ap no-lock no-error.
           if avail proces_pagto then do:
              &if '{&emsfin_version}' < "5.06" &then
                  assign item_bord_ap.cod_livre_1 = proces_pagto.cod_livre_1.
              &else
                  assign item_bord_ap.cod_contrat_cambio        = proces_pagto.cod_contrat_cambio
                         item_bord_ap.dat_contrat_cambio_import = proces_pagto.dat_contrat_cambio_import
                         item_bord_ap.num_contrat_id_cambio     = proces_pagto.num_contrat_id_cambio
                         item_bord_ap.cod_estab_contrat_cambio  = proces_pagto.cod_estab_contrat_cambio
                         item_bord_ap.cod_refer_contrat_cambio  = proces_pagto.cod_refer_contrat_cambio
                         item_bord_ap.dat_refer_contrat_cambio  = proces_pagto.dat_refer_contrat_cambio.
              &endif
           end.
           else do:
              run pi_retornar_indic_econ_corren_estab (Input v_cod_estab_usuar,
                                                       Input tit_ap.dat_transacao,
                                                       output v_cod_indic_econ_corren).


              for each tt_xml_input_output:
                  delete tt_xml_input_output.
              end.

              for each tt_log_erros:
                  delete tt_log_erros.
              end.

              create  tt_xml_input_output.
              assign  tt_xml_input_output.ttv_cod_label = 'Funá∆o':U
                      tt_xml_input_output.ttv_des_conteudo = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  
                      tt_xml_input_output.ttv_num_seq_1 = 1.

              create  tt_xml_input_output.
              assign  tt_xml_input_output.ttv_cod_label = 'Produto':U
                      tt_xml_input_output.ttv_des_conteudo = "EMS 2" /*l_ems2*/       
                      tt_xml_input_output.ttv_num_seq_1 = 1.

              create  tt_xml_input_output.
              assign  tt_xml_input_output.ttv_cod_label = 'Empresa':U 
                      tt_xml_input_output.ttv_des_conteudo = item_bord_ap.cod_empresa
                      tt_xml_input_output.ttv_num_seq_1 = 1.

              create  tt_xml_input_output.
              assign  tt_xml_input_output.ttv_cod_label = 'Estabel':U 
                      tt_xml_input_output.ttv_des_conteudo = item_bord_ap.cod_estab
                      tt_xml_input_output.ttv_num_seq_1 = 1.

              RUN prgint/utb/utb786za.py (INPUT-OUTPUT table tt_xml_input_output,
                                          OUTPUT table tt_log_erros).

              find first tt_log_erros where tt_log_erros.ttv_num_cod_erro <> 0 no-error.
              if avail tt_log_erros then 
                 return error .

              for each tt_xml_input_output break by tt_xml_input_output.ttv_num_seq_1:
                  if tt_xml_input_output.ttv_cod_label = 'Empresa':U  then
                     ASSIGN v_cod_empresa  =  tt_xml_input_output.ttv_des_conteudo_aux.

                  if tt_xml_input_output.ttv_cod_label = 'Estabel':U THEN
                     ASSIGN v_cod_estab    =  tt_xml_input_output.ttv_des_conteudo_aux.
              end.

              /* A atividade 138.827 alterou este ponto, mas devido a lista de impacto, a alteraá∆o foi realizada sob demanda.*/    
              run prgint/utb/utb720za.py (Input 1,
                                          Input "On-Line" /*l_online*/  ,
                                          output v_log_connect_ems2_ok,
                                          output v_log_connect) /* prg_fnc_conecta_bases_externas*/.

              if  v_log_connect         = no
                  and v_log_connect_ems2_ok = no then do:
                  /* A atividade 138.827 alterou este ponto, mas devido a lista de impacto, a altera?∆o foi realizada sob demanda.*/        
                  run prgint/utb/utb720za.py (Input 2,
                                              Input "On-Line" /*l_online*/  ,
                                              output v_log_connect_ems2_ok,
                                              output v_log_connect) /* prg_fnc_conecta_bases_externas*/.
                  return error.
              end.

              assign v_cod_empres_usuar_2 = v_cod_empres_usuar.
              run adbo/boad342.p persistent set v_hdl_aux.

              run pi-vld-cancela-titulo-ap in v_hdl_aux (input v_cod_empresa, 
                                                         input item_bord_ap.cdn_fornecedor, 
                                                         input v_cod_estab,
                                                         input item_bord_ap.cod_espec_docto,
                                                         input item_bord_ap.cod_ser_docto,
                                                         input item_bord_ap.cod_tit_ap,
                                                         input item_bord_ap.cod_parcela,
                                                         output v_cod_estab_aux,
                                                         output v_cod_refer,
                                                         output v_dat_refer).
              if valid-handle(v_hdl_aux) then
                 delete procedure v_hdl_aux.
              assign v_cod_empres_usuar = v_cod_empres_usuar_2.
              /* A atividade 138.827 alterou este ponto, mas devido a lista de impacto, a alteraá∆o foi realizada sob demanda.*/    
              run prgint/utb/utb720za.py (Input 2,
                                          Input "On-Line" /*l_online*/  ,
                                          output v_log_connect_ems2_ok,
                                          output v_log_connect) /* prg_fnc_conecta_bases_externas*/.


              if  v_cod_refer <> "" /*l_*/  then do:
                  /* T°tulo dever† ser liquidado pelo m¢dulo de cÉmbio ! */
                  run pi_messages (input "show",
                                   input 12596,
                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_12596*/.
                  return error.
              end.
              else if v_cod_indic_econ_corren = bord_ap.cod_indic_econ then do:
                  /* T°tulo dever† ser liquidado pelo m¢dulo de cÉmbio ! */
                  run pi_messages (input "show",
                                   input 12596,
                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_12596*/.
                  return error.    
              end.

           end.
       end.
    end.

    &if '{&emsfin_version}' >= '5.04' &then
        if tt_param.log_atualiza_dat_pagto = yes then
            assign item_bord_ap.dat_pagto_tit_ap = tit_ap.dat_vencto_tit_ap.
        else
            assign item_bord_ap.dat_pagto_tit_ap = bord_ap.dat_transacao.
    &endif       
    
    IF tt_param.log_atualiza_dat_pagto <> ? THEN
        assign v_log_atualiza_dat_pagto = tt_param.log_atualiza_dat_pagto.


    if  tt_param.ind_forma_pagto = "Assume do T°tulo" /*l_assume_do_titulo*/ 
    then do:
        assign item_bord_ap.cod_forma_pagto   = tit_ap.cod_forma_pagto
               item_bord_ap.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
               item_bord_ap.dat_prev_pagto    = tit_ap.dat_prev_pagto
               item_bord_ap.dat_desconto      = tit_ap.dat_desconto.

        //Alteraá∆o Forma de Pagamento
        IF can-find(FIRST forma_pagto
                    where forma_pagto.cod_forma_pagto = tt_titulos_bord.cod_forma_pagto)
            AND tt_titulos_bord.cod_forma_pagto <> tit_ap.cod_forma_pagto THEN
            ASSIGN item_bord_ap.cod_forma_pagto = tt_titulos_bord.cod_forma_pagto.

        /**IF v_log_localiz_equador THEN
            ASSIGN item_bord_ap.cod_livre_2 = SetEntryField(3,item_bord_ap.cod_livre_2,CHR(10),GetEntryField(2,tit_ap.cod_livre_1,chr(10))).*/

    end /* if */.
    else do:
        assign item_bord_ap.cod_forma_pagto   = tt_param.cod_forma_pagto
               item_bord_ap.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
               item_bord_ap.dat_prev_pagto    = tit_ap.dat_prev_pagto
               item_bord_ap.dat_desconto      = tit_ap.dat_desconto.

        /*IF v_log_localiz_equador THEN
            ASSIGN item_bord_ap.cod_livre_2 = SetEntryField(3,item_bord_ap.cod_livre_2,CHR(10),v_cod_forma_pagto_equador_aux).*/

    end /* else */.

    ASSIGN v_log_cta_fornec     = &if defined(BF_FIN_CONTAS_CORRENTES_FORNEC) &then yes &else GetDefinedFunction('SPP_CONTAS_CORRENTES_FORNEC':U) &endif.

    if v_log_cta_fornec then do:

        /* 194974 - Dani 07/02/08 = alteraá∆o sob demanda (melhora a performace)  */ 
        if can-find (FIRST forma_pagto
            where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto
            and   forma_pagto.log_agrup_tit_fornec) then do:
            if can-find (first b_item_bord_ap no-lock
                where b_item_bord_ap.cod_estab_bord  = bord_ap.cod_estab_bord
                  and b_item_bord_ap.cod_portador    = bord_ap.cod_portador
                  and b_item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap
                  and b_item_bord_ap.cdn_fornec      = item_bord_ap.cdn_fornec
                  and b_item_bord_ap.cod_forma_pagto = item_bord_ap.cod_forma_pagto) THEN DO:
                for each  b_item_bord_ap fields( cod_bco_pagto cod_agenc_bcia_pagto cod_digito_agenc_bcia_pagto cod_cta_corren_bco_pagto cod_digito_cta_corren_pagto) no-lock   


                    where b_item_bord_ap.cod_estab_bord  = bord_ap.cod_estab_bord
                      and b_item_bord_ap.cod_portador    = bord_ap.cod_portador
                      and b_item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap
                      and b_item_bord_ap.cdn_fornec      = item_bord_ap.cdn_fornec
                      and b_item_bord_ap.cod_forma_pagto = item_bord_ap.cod_forma_pagto:
                     assign item_bord_ap.cod_bco_pagto               = b_item_bord_ap.cod_bco_pagto
                            item_bord_ap.cod_agenc_bcia_pagto        = b_item_bord_ap.cod_agenc_bcia_pagto
                            item_bord_ap.cod_digito_agenc_bcia_pagto = b_item_bord_ap.cod_digito_agenc_bcia_pagto
                            item_bord_ap.cod_cta_corren_bco_pagto    = b_item_bord_ap.cod_cta_corren_bco_pagto
                            item_bord_ap.cod_digito_cta_corren_pagto = b_item_bord_ap.cod_digito_cta_corren_pagto.
                end.
            end.
        end.
    end.

    &if defined(BF_FIN_ORIG_GRAOS) &then
        if  avail item_bord_ap then do:
            if  v_log_program then do:
                run piSugereDadosBancariosOrig in v_hdl_api_graos (INPUT tit_ap.cod_estab,
                                                                   INPUT tit_ap.num_id_tit_ap,
                                                                   INPUT ?,
                                                                   INPUT tit_ap.cod_espec_docto,
                                                                  OUTPUT v_cod_banco,
                                                                  OUTPUT v_cod_agenc,
                                                                  OUTPUT v_cod_digito_agenc,
                                                                  OUTPUT v_cod_cta_corren,
                                                                  OUTPUT v_cod_digito_cta_corren).

                /* Atualiza dados banc†rios*/
                if v_cod_banco <> "" then
                    assign item_bord_ap.cod_bco_pagto = v_cod_banco.

                if v_cod_agenc <> "" then
                    assign item_bord_ap.cod_agenc_bcia_pagto = v_cod_agenc.

                if v_cod_digito_agenc <> "" then                        
                    assign item_bord_ap.cod_digito_agenc_bcia_pagto = v_cod_digito_agenc.

                if v_cod_cta_corren <> "" then
                    assign item_bord_ap.cod_cta_corren_bco_pagto = v_cod_cta_corren.

                if v_cod_digito_cta_corren <> "" then
                    assign item_bord_ap.cod_digito_cta_corren_pagto = v_cod_digito_cta_corren.
            end.                       
        end. 
    &endif

    run pi_calcula_dias_uteis_2 (Input bord_ap.cod_estab,
                                 Input tit_ap.dat_vencto_tit_ap,
                                 Input bord_ap.dat_transacao,
                                 output v_num_dias_atraso) /*pi_calcula_dias_uteis_2*/.

    if  v_num_dias_atraso >= 1
    then do:
        assign v_log_dia_util = no.
        run pi_verifica_dia_util_dat_vencto_x_dat_trans (Input bord_ap.cod_estab,
                                                         Input tit_ap.dat_vencto_tit_ap,
                                                         Input bord_ap.dat_transacao - 1,
                                                         output v_log_dia_util) /*pi_verifica_dia_util_dat_vencto_x_dat_trans*/.
        if  v_log_dia_util then
            assign v_num_dias_atraso = bord_ap.dat_transacao - tit_ap.dat_vencto_tit_ap.
        else 
            assign v_num_dias_atraso = 0.
    end /* if */.

    if  bord_ap.dat_transacao > tit_ap.dat_vencto_tit_ap
    and tit_ap.num_dias < v_num_dias_atraso
    then do:

       if v_val_tax_calcul = 0

       or not v_log_tax_calcul 

       then
            assign v_val_tax_calcul = tit_ap.val_perc_juros_dia_atraso.

        if  p_ind_juros_pagto_autom = "Paga Juros" /*l_paga_juros*/ 
        or (p_ind_juros_pagto_autom = "Assume Fornec" /*l_assume_fornec*/ 
        and fornec_financ.ind_pagto_juros_fornec_ap = "Paga" /*l_paga*/ ) then
            assign item_bord_ap.val_multa_tit_ap = item_bord_ap.val_pagto *
                                                   (tit_ap.val_perc_multa_atraso / 100)
                   item_bord_ap.val_juros = item_bord_ap.val_pagto *
                                            (v_val_tax_calcul / 100) *
                                            v_num_dias_atraso.
    end /* if */.
    if  bord_ap.dat_transacao <= tit_ap.dat_desconto
    then do:

        assign v_val_acerto_impl    = 0
               v_val_impto_calc     = 0
               v_val_perc_val_pagto = 0.
        find first b_movto_tit_ap no-lock
            where b_movto_tit_ap.cod_estab          = tit_ap.cod_estab
              and b_movto_tit_ap.num_id_tit_ap      = tit_ap.num_id_tit_ap
              and b_movto_tit_ap.ind_trans_ap_abrev = "IMPL" /*l_impl*/  no-error.
        if avail b_movto_tit_ap then do:
            find first b_movto_tit_ap_aux no-lock
                where b_movto_tit_ap_aux.cod_estab     = tit_ap.cod_estab     
                  and b_movto_tit_ap_aux.num_id_tit_ap = tit_ap.num_id_tit_ap
                  and b_movto_tit_ap_aux.ind_trans_ap  = "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/ 
                  and b_movto_tit_ap_aux.cod_refer     = b_movto_tit_ap.cod_refer no-error.
            if avail b_movto_tit_ap_aux then
                assign v_val_acerto_impl = b_movto_tit_ap_aux.val_movto_ap.

            assign v_val_perc_val_pagto = item_bord_ap.val_pagto / (tit_ap.val_origin_tit_ap - v_val_acerto_impl).
            for each compl_impto_retid_ap no-lock
                 where compl_impto_retid_ap.cod_estab               = b_movto_tit_ap.cod_estab
                   and compl_impto_retid_ap.num_id_movto_tit_ap_pai = b_movto_tit_ap.num_id_movto_tit_ap:
                find b_tit_ap_impto no-lock
                     where b_tit_ap_impto.cod_estab     = compl_impto_retid_ap.cod_estab
                       and b_tit_ap_impto.num_id_tit_ap = compl_impto_retid_ap.num_id_tit_ap
                      no-error.
                if avail b_tit_ap_impto then
                    assign v_val_impto_calc = v_val_impto_calc + (b_tit_ap_impto.val_origin_tit_ap * v_val_perc_val_pagto).
            end.
        end.

        if (item_bord_ap.val_pagto + v_val_acerto_impl) = tit_ap.val_origin_tit_ap then
             assign item_bord_ap.val_desc_tit_ap = tit_ap.val_desconto.
        else assign item_bord_ap.val_desc_tit_ap = (item_bord_ap.val_pagto + v_val_impto_calc) * 
                                              (tit_ap.val_perc_desc / 100).
    end /* if */.
    assign item_bord_ap.val_abat_tit_ap       = 0
           item_bord_ap.val_cm_tit_ap         = 0
           item_bord_ap.val_multa_tit_ap_orig = item_bord_ap.val_multa_tit_ap * tt_titulos_bord.val_cotac_indic_econ
           item_bord_ap.val_juros_tit_ap_orig = item_bord_ap.val_juros * tt_titulos_bord.val_cotac_indic_econ
           item_bord_ap.val_cm_tit_ap_orig    = 0
           item_bord_ap.val_desc_tit_ap_orig  = item_bord_ap.val_desc_tit_ap * tt_titulos_bord.val_cotac_indic_econ
           item_bord_ap.val_abat_tit_ap_orig  = 0
           item_bord_ap.dat_cotac_indic_econ  = p_dat_cotac_indic_econ
           item_bord_ap.val_cotac_indic_econ  = tt_titulos_bord.val_cotac_indic_econ.
    if  avail proces_pagto and proces_pagto.val_liber_pagto_orig <> ? 
    and proces_pagto.val_liber_pagto_orig <> 0 then 
        assign item_bord_ap.val_pagto_orig = proces_pagto.val_liber_pagto_orig.
    else
        assign item_bord_ap.val_pagto_orig = tt_titulos_bord.val_sdo_tit_ap.

    if  v_log_favorec_cheq_adm then do:
        &if '{&emsfin_version}' >= '5.05' &then
                find FIRST forma_pagto 
                where  forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto 
                no-lock no-error.
            if avail forma_pagto
               and   forma_pagto.ind_tip_forma_pagto = "Cheque Administrativo" /*l_cheque_administ*/  then do:  
                if v_nom_favorec_cheq = '' then do:
                    /* Favorecido n∆o informado ! */
                    run pi_messages (input "show",
                                     input 10789,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_10789*/.
                    return error.
                end.       
                else 
                    assign item_bord_ap.ind_favorec_cheq = v_ind_favorec_cheq
                           item_bord_ap.nom_favorec_cheq = v_nom_favorec_cheq.
            end.
        &else
            &if '{&emsfin_version}' >= '5.02' &then
                find FIRST forma_pagto no-lock
                    where  forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto 
                    no-lock no-error.
                if avail forma_pagto
                   and   forma_pagto.ind_tip_forma_pagto = "Cheque Administrativo" /*l_cheque_administ*/  then do:  
                    if v_nom_favorec_cheq = '' then do:
                        /* Favorecido n∆o informado ! */
                        run pi_messages (input "show",
                                         input 10789,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_10789*/.
                        return error.
                    end.       
                    else 
                        assign item_bord_ap.cod_livre_1 = v_ind_favorec_cheq + chr(10) + 
                                                          v_nom_favorec_cheq.
                end. 
             &else
                find FIRST forma_pagto no-lock
                    where  entry(1,forma_pagto.cod_livre_1,chr(24)) = item_bord_ap.cod_forma_pagto 
                    no-lock no-error.
                if avail forma_pagto
                   and   entry(1,forma_pagto.cod_livre_1,chr(24)) = "Cheque Administrativo" /*l_cheque_administ*/  then do:  
                    if v_nom_favorec_cheq = '' then do:
                        /* Favorecido n∆o informado ! */
                        run pi_messages (input "show",
                                         input 10789,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_10789*/.
                        return error.
                    end.       
                    else 
                        assign item_bord_ap.cod_livre_1 = v_ind_favorec_cheq + chr(10) + 
                                                          v_nom_favorec_cheq.
                end.            
            &endif
        &endif
    end.

    /* Gera os impostos de PIS/COFINS/CSLL quando o lote indicar que deve gerar */
    /* 194974 - Dani 07/02/08 = alteraá∆o sob demanda (melhora a performace)  */
    if v_log_vinc_impto_auto then do:
        if can-find (first fornecedor NO-LOCK
            where fornecedor.cod_empresa = tit_ap.cod_empresa
              and fornecedor.cdn_fornecedor = tit_ap.cdn_fornecedor
              and &if '{&emsfin_version}' > '5.05' &then
                      fornecedor.log_retenc_impto_pagto
                  &else
                      num-entries(fornecedor.cod_livre_1,chr(10)) >= 2
                  and (entry(2,fornecedor.cod_livre_1,CHR(10))    = 'yes')
                  &endif ) then do:
            if can-find (first compl_retenc_impto_pagto NO-LOCK
                where compl_retenc_impto_pagto.cod_estab     = tit_ap.cod_estab
                and compl_retenc_impto_pagto.num_id_tit_ap = tit_ap.num_id_tit_ap ) THEN DO:
                &IF INTEGER(ENTRY(1,PROVERSION,".")) >= 9 &THEN
                    EMPTY TEMP-TABLE tt_dados_tit_ap_pagto NO-ERROR.
                &ELSE
                    FOR EACH tt_dados_tit_ap_pagto:
                        DELETE tt_dados_tit_ap_pagto.
                    END.
                &ENDIF
                assign &if '{&emsfin_version}' >= '5.04' &then
                        v_dat_acum_impto = item_bord_ap.dat_pagto_tit_ap
                    &else
                        v_dat_acum_impto = item_bord_ap.dat_vencto
                    &endif.
                if  bord_ap.dat_transacao > v_dat_acum_impto then
                    assign v_dat_acum_impto = bord_ap.dat_transacao.    

                &if '{&emsfin_version}' <= '5.03' &then
                    assign v_dat_acum_impto = bord_ap.dat_transacao.
                &endif

                CREATE tt_dados_tit_ap_pagto.
                ASSIGN tt_dados_tit_ap_pagto.tta_cod_estab_tit_ap = tit_ap.cod_estab
                       tt_dados_tit_ap_pagto.tta_num_id_tit_ap    = tit_ap.num_id_tit_ap
                       tt_dados_tit_ap_pagto.tta_cod_estab_refer  = bord_ap.cod_estab
                       tt_dados_tit_ap_pagto.tta_cod_refer        = ""
                       tt_dados_tit_ap_pagto.tta_cod_portador     = bord_ap.cod_portador
                       tt_dados_tit_ap_pagto.tta_num_bord_ap      = bord_ap.num_bord_ap
                       tt_dados_tit_ap_pagto.tta_num_seq_refer    = item_bord_ap.num_seq_bord
                       tt_dados_tit_ap_pagto.tta_cdn_fornecedor   = item_bord_ap.cdn_fornecedor
                       tt_dados_tit_ap_pagto.tta_dat_transacao    = v_dat_acum_impto
                       tt_dados_tit_ap_pagto.tta_cod_indic_econ   = bord_ap.cod_indic_econ
                       tt_dados_tit_ap_pagto.tta_val_pagto        = item_bord_ap.val_pagto.
                IF RECID(item_bord_ap) <> ? THEN.

                RUN prgfin/apb/apb509za.py (INPUT YES,
                                                INPUT TABLE tt_dados_tit_ap_pagto).
                assign v_val_tot_pagto_impto = 0.
                for each b_impto_impl_pend_ap no-lock
                    where b_impto_impl_pend_ap.cod_estab_refer = item_bord_ap.cod_estab_bord
                    and   b_impto_impl_pend_ap.cod_refer       = "" /*l_*/ 
                    and   b_impto_impl_pend_ap.cod_portador    = item_bord_ap.cod_portador
                    and   b_impto_impl_pend_ap.num_bord_ap     = item_bord_ap.num_bord_ap
                    and   b_impto_impl_pend_ap.num_seq_refer   = item_bord_ap.num_seq_bord:
                    assign v_val_tot_pagto_impto = v_val_tot_pagto_impto + b_impto_impl_pend_ap.val_imposto.
                end.

                run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                             Input " ",
                                                             Input item_bord_ap.num_seq_bord,
                                                             Input item_bord_ap.cod_portador,
                                                             Input item_bord_ap.num_bord_ap,
                                                             Input "Antecipaá∆o" /*l_antecipacao*/,
                                                             output v_log_abat_antecip,
                                                             output v_val_tot_abat_antecip,
                                                             output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.

                assign v_val_tot_desemb = item_bord_ap.val_pagto        +
                                          item_bord_ap.val_multa_tit_ap +
                                          item_bord_ap.val_juros        +
                                          item_bord_ap.val_cm_tit_ap    -
                                          item_bord_ap.val_desc_tit_ap  -
                                          item_bord_ap.val_abat_tit_ap  -
                                          v_val_tot_abat_antecip        -
                                          v_val_tot_pagto_impto.
                if v_val_tot_desemb = 0 then do:
                    if  not can-find(first tt_itens_sem_desemb no-lock
                                      where tt_itens_sem_desemb.tta_cod_estab_bord = item_bord_ap.cod_estab_bord
                                      and   tt_itens_sem_desemb.tta_cod_portador   = item_bord_ap.cod_portador
                                      and   tt_itens_sem_desemb.tta_num_bord_ap    = item_bord_ap.num_bord_ap
                                      and   tt_itens_sem_desemb.tta_num_seq_bord   = item_bord_ap.num_seq_bord) then do:
                        create tt_itens_sem_desemb.
                        assign tt_itens_sem_desemb.tta_cod_estab_bord = item_bord_ap.cod_estab_bord
                               tt_itens_sem_desemb.tta_cod_portador   = item_bord_ap.cod_portador
                               tt_itens_sem_desemb.tta_num_bord_ap    = item_bord_ap.num_bord_ap
                               tt_itens_sem_desemb.tta_num_seq_bord   = item_bord_ap.num_seq_bord.
                    end.
                end.        
            end.
        end.
    end.


    &if '{&emsbas_version}' > '5.00' &then
        if  v_nom_prog_dpc <> '' then do:
            assign v_rec_table_epc = recid(item_bord_ap)
                   v_nom_table_epc = 'item_bord_ap'.
            run value(v_nom_prog_dpc) (input 'gera_conjunto_bordero',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then
                return 'NOK'.
        end.
    &endif

    run pi_retornar_finalid_indic_econ_tt (Input bord_ap.cod_indic_econ,
                                           Input bord_ap.dat_transacao,
                                           output p_cod_finalid_econ_base) /*pi_retornar_finalid_indic_econ_tt*/.

    find current bord_ap exclusive-lock no-error.
    assign bord_ap.val_tot_lote_pagto_infor = bord_ap.val_tot_lote_pagto_infor +
                                              item_bord_ap.val_pagto.

    CREATE tt-retorno.
    ASSIGN tt-retorno.versao-api = c-versao-api 
           tt-retorno.cod-status = 399
           tt-retorno.desc-retorno = "T°tulo vinculado. Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela + "|Val Pg: " + STRING(item_bord_ap.val_pagto,">>>,>>>,>>>,>>>,>>9.99").

    //Equaliza Total Pagamento com o total informado
    ASSIGN bord_ap.val_tot_lote_pagto_efetd = bord_ap.val_tot_lote_pagto_infor.
   
    return 'OK'.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gerar_item_pagto_cjto_titulo:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tipo
        as character
        format "X(10)"
        no-undo.
    def Input param p_cod_estab_refer
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_log_pagto
        as logical
        format "Sim/N∆o"
        no-undo.
    def Input param p_ind_juros_pagto_autom
        as character
        format "X(14)"
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_val_pagto_apb
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_dat_cotac_indic_econ
        as date
        format "99/99/9999":U
        initial today
        label "Data Cotaá∆o"
        column-label "Data Cotaá∆o"
        no-undo.
    def var v_val_cotac_indic_econ
        as decimal
        format "->>,>>>,>>>,>>9.9999999999":U
        decimals 10
        label "Cotaá∆o"
        column-label "Cotaá∆o"
        no-undo.
    def var v_val_max_pagto
        as decimal
        format ">>>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_cod_finalid_econ               as character       no-undo. /*local*/
    def var v_cod_finalid_econ_val_usuar     as character       no-undo. /*local*/
    def var v_cod_indic_econ_val_usuar       as character       no-undo. /*local*/
    def var v_num_seq_pagto                  as integer         no-undo. /*local*/
    def var v_val_lim_liber_pagto            as decimal         no-undo. /*local*/
    def var v_val_lim_pagto                  as decimal         no-undo. /*local*/
    def var v_val_pagto                      as decimal         no-undo. /*local*/
    def var v_val_sdo_tit_ap_aux             as decimal         no-undo. /*local*/
    DEFINE VARIABLE v_cod_moeda              AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE v_num_natur              AS INTEGER         NO-UNDO.


    /************************** Variable Definition End *************************/

    if  tit_ap.log_sdo_tit_ap     = no
    or  tit_ap.val_sdo_tit_ap    <= 0.00
    or  tit_ap.log_tit_ap_estordo = yes then
        return "6858".

    if  tit_ap.log_pagto_bloqdo   = yes then
        return "796".

    find fornec_financ use-index frncfnnc_id
        where fornec_financ.cod_empresa    = tit_ap.cod_empresa
        and   fornec_financ.cdn_fornecedor = tit_ap.cdn_fornecedor
        no-lock no-error.
    if  not avail fornec_financ then
        return "537".
    if  fornec_financ.log_pagto_bloqdo = yes then
        return "794".

    find usuar_financ_estab_apb
        where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
        and   usuar_financ_estab_apb.cod_estab   = p_cod_estab_refer
        no-lock no-error.
    if  not avail usuar_financ_estab_apb then
        return "20," + v_cod_usuar_corren + "," + p_cod_estab_refer.

    /* N∆o tirar, pois ir† trazer corretamente as movimentaáSes dos t°tulos*/
    assign v_val_sdo_tit_ap_aux = tt_titulos_bord.val_sdo_tit_ap.

    if tt_titulos_bord.ind_sit_prepar_liber = "Pre" /*l_pre*/ 
    or tt_titulos_bord.ind_sit_prepar_liber = "" /*l_*/  then
        assign v_num_seq_pagto = 0.
    else
        assign v_num_seq_pagto = tt_titulos_bord.num_seq_pagto_tit_ap.
    if  tt_titulos_bord.val_sdo_tit_ap <= 0.00 then
        return "3632".

    if  can-find( first relacto_pend_tit_ap no-lock
        where relacto_pend_tit_ap.cod_estab_tit_ap_pai = tit_ap.cod_estab
        and   relacto_pend_tit_ap.num_id_tit_ap_pai    = tit_ap.num_id_tit_ap ) then
        return "523".

    /* ************************************
    *  A PARTE DE CONTROLE DOS VALORES POR USU∆RIO SER∆ REVISADA NO FUTURO,
    *  ATê L∆ ESTE CaDIGO FICAR∆ SEM USO
    *
    *@run( pi_retornar_limite_valor_usuario(
    *      p_cod_estab_refer,
    *      p_dat_transacao,
    *      usuar_financ_estab_apb.val_lim_liber_usuar_movto,
    *      usuar_financ_estab_apb.val_lim_liber_usuar_mes,
    *      usuar_financ_estab_apb.val_lim_pagto_usuar_movto,
    *      usuar_financ_estab_apb.val_lim_pagto_usuar_mes,
    *      v_val_lim_liber_pagto,
    *      v_val_lim_pagto,
    *      v_cod_finalid_econ_val_usuar,
    *      v_cod_return)).
    *if  v_cod_return <> 'OK' then
    *    return v_cod_return.
    *@run( pi_retornar_indic_econ_finalid_tt(
    *      v_cod_finalid_econ_val_usuar,
    *      p_dat_transacao,
    *      v_cod_indic_econ_val_usuar)).
    *
    *if  v_num_seq_pagto = 0 then do:
    *    @if(v_cod_indic_econ_val_usuar <> tt_titulos_bord.cod_indic_econ)
    *        @run (pi_converter_indic_econ_indic_econ_tt(
    *              v_cod_indic_econ_val_usuar,
    *              v_cod_empres_usuar,
    *              p_dat_transacao,
    *              v_val_lim_liber_pagto,
    *              tt_titulos_bord.cod_indic_econ,
    *              v_cod_return)).
    *        if  v_cod_return <> 'OK' then
    *            return v_cod_return.
    *        find first tt_converter_finalid_econ no-lock no-error.
    *        assign v_val_lim_liber_pagto = tt_converter_finalid_econ.tta_val_transacao
    *               v_val_max_pagto       = v_val_lim_liber_pagto.
    *    end.
    *    else
    *        assign v_val_max_pagto = v_val_lim_liber_pagto.
    *end.
    *else
    *    assign v_val_max_pagto = @fx_objpro(v_val_max_pagto, valmax).
    *
    *if  v_cod_indic_econ_val_usuar <> tt_titulos_bord.cod_indic_econ
    *then do:
    *    @run( pi_converter_indic_econ_indic_econ_tt(
    *          v_cod_indic_econ_val_usuar,
    *          v_cod_empres_usuar,
    *          p_dat_transacao,
    *          v_val_lim_pagto,
    *          tt_titulos_bord.cod_indic_econ,
    *          v_cod_return)).
    *    if  v_cod_return <> 'OK' then
    *        return v_cod_return.
    *    find first tt_converter_finalid_econ no-lock no-error.
    *    assign v_val_lim_pagto = tt_converter_finalid_econ.tta_val_transacao.
    *end.
    *if  v_val_lim_pagto < v_val_max_pagto then
    *    assign v_val_max_pagto = v_val_lim_pagto.
    *****************************************************/

       assign v_val_lim_pagto = 999999999.99
              v_val_max_pagto = 999999999.99.

    if  dbtype('emsfin') = 'MSS' then
        assign v_dat_min_sql = 01/01/1800.
    else
        assign v_dat_min_sql = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF.

    if  p_log_pagto = yes then do:
        run pi_retornar_cotac_infor_lote (Input p_dat_transacao,
                                          output v_val_cotac_indic_econ,
                                          output v_dat_cotac_indic_econ) /*pi_retornar_cotac_infor_lote*/.
        if  return-value <> 'OK' then
            return (return-value).
    end.
    else
        assign v_val_cotac_indic_econ = 1
               v_dat_cotac_indic_econ = v_dat_min_sql.

    find param_integr_ems no-lock
       where param_integr_ems.ind_param_integr_ems = "CÉmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/  no-error.
    if  avail param_integr_ems then do:
        run pi_verificar_fornec_estrangeiro(input tit_ap.cod_empresa,
                                            input tt_titulos_bord.cdn_fornecedor,
                                            input tt_titulos_bord.cod_estab,
                                            input tt_titulos_bord.cod_indic_econ,
                                            input tt_titulos_bord.dat_vencto_tit_ap, 
                                            output v_cod_moeda,
                                            output v_num_natur).

        if  v_num_natur = 3 and
            v_cod_moeda = "Estrangeiro" /*l_estrangeiro*/  then do:
            assign v_val_cotac_indic_econ = 0           
                   v_val_cotac_indic_econ = tt_titulos_bord.val_cotac_indic_econ.

        end.
    end.

    if  tt_titulos_bord.val_sdo_tit_ap > v_val_max_pagto then
        assign v_val_pagto = v_val_max_pagto / v_val_cotac_indic_econ.
    else
        if avail proces_pagto and p_cod_indic_econ = tit_ap.cod_indic_econ then 
            if  proces_pagto.ind_sit_proces_pagto = "Preparado" /*l_preparado*/  then
                assign v_val_pagto = tt_titulos_bord.val_sdo_tit_ap.
            else
                // everton - alterado em 17/09/25
                if  proces_pagto.ind_sit_proces_pagto = "Em pagamento" or proces_pagto.ind_sit_proces_pagto = "Confirmado" then
                    assign v_val_pagto = 0.
                else
                    assign v_val_pagto = proces_pagto.val_liber_pagto_orig.                 
        else
            if tt_titulos_bord.cod_indic_econ <> p_cod_indic_econ then  
                assign v_val_pagto = tt_titulos_bord.val_sdo_tit_ap / v_val_cotac_indic_econ.     
            else
                assign v_val_pagto = tt_titulos_bord.val_sdo_tit_ap.  

    if  v_val_pagto <= 0 then
        return "3983".

    /* ** CRIA ITEM_LOTE_PAGTO ou ITEM_BORD_AP ***/
    if  p_ind_tipo = "Cheque" /*l_cheque*/  then do:
        run pi_gerar_item_pagto_cjto_titulo_lote (Input v_val_pagto,
                                                  Input v_val_cotac_indic_econ,
                                                  Input v_dat_cotac_indic_econ,
                                                  Input p_ind_juros_pagto_autom,
                                                  Input v_num_seq_pagto,
                                                  output v_cod_finalid_econ) /*pi_gerar_item_pagto_cjto_titulo_lote*/.
                                                  
        if  return-value <> 'OK' then do:
        
            return (return-value).
        end.

                                                  
        run pi_gerar_proces_pagto_item_pagto (Input item_lote_pagto.cod_estab_refer,
                                              Input item_lote_pagto.cod_refer,
                                              Input item_lote_pagto.num_seq_refer,
                                              Input item_lote_pagto.cod_estab,
                                              Input item_lote_pagto.cdn_fornecedor,
                                              Input item_lote_pagto.cod_espec_docto,
                                              Input item_lote_pagto.cod_ser_docto,
                                              Input item_lote_pagto.cod_tit_ap,
                                              Input item_lote_pagto.cod_parcela,
                                              Input item_lote_pagto.cod_portador,
                                              Input p_dat_transacao,
                                              Input item_lote_pagto.val_pagto,
                                              Input item_lote_pagto.val_pagto_orig,
                                              Input item_lote_pagto.cod_indic_econ,
                                              Input v_cod_finalid_econ,
                                              Input IF portador.ind_tip_portad = "Caixa" /*l_caixa*/  then "Dinheiro" /*l_dinheiro*/  else "Cheque" /*l_cheque*/,
                                              input-output item_lote_pagto.num_seq_pagto_tit_ap) /*pi_gerar_proces_pagto_item_pagto*/.
        if  return-value <> 'OK' then
            return (return-value).

        /* se o titulo teve sua libera+∆o em uma moeda diferente da implantacao*/
        if  avail proces_pagto
        and avail item_lote_pagto
        and item_lote_pagto.val_pagto_orig <> proces_pagto.val_liberd_pagto then do:
            if item_lote_pagto.val_pagto_orig <> proces_pagto.val_liber_pagto_orig then
                return "18597".
        end.
    end.
    else do:
        run pi_gerar_item_pagto_cjto_titulo_bord (Input v_val_pagto,
                                                  Input v_val_cotac_indic_econ,
                                                  Input v_dat_cotac_indic_econ,
                                                  Input p_ind_juros_pagto_autom,
                                                  Input v_num_seq_pagto,
                                                  output v_cod_finalid_econ) /*pi_gerar_item_pagto_cjto_titulo_bord*/.
                                                  
        run pi_gerar_proces_pagto_item_pagto (Input item_bord_ap.cod_estab_bord,
                                              Input "",
                                              Input item_bord_ap.num_seq_bord,
                                              Input item_bord_ap.cod_estab,
                                              Input item_bord_ap.cdn_fornecedor,
                                              Input item_bord_ap.cod_espec_docto,
                                              Input item_bord_ap.cod_ser_docto,
                                              Input item_bord_ap.cod_tit_ap,
                                              Input item_bord_ap.cod_parcela,
                                              Input bord_ap.cod_portador,
                                              Input p_dat_transacao,
                                              Input item_bord_ap.val_pagto,
                                              Input item_bord_ap.val_pagto_orig,
                                              Input bord_ap.cod_indic_econ,
                                              Input v_cod_finalid_econ,
                                              Input "Borderì" /*l_bordero*/,
                                              input-output item_bord_ap.num_seq_pagto_tit_ap) /*pi_gerar_proces_pagto_item_pagto*/.
                                              
        if  return-value <> 'OK' then
            return (return-value).

        /* se o t°tulo teve sua libera+∆o em uma moeda diferente da implantacao*/
        if  avail proces_pagto
        and avail item_bord_ap
        and item_bord_ap.val_pagto_orig <> proces_pagto.val_liberd_pagto then do:
            if item_bord_ap.val_pagto_orig <> proces_pagto.val_liber_pagto_orig then
                return "18597".
        end.     
    end.

    return 'OK'.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_nome_abrev_fornec_pagto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.
    def Input param p_rec_tit_ap
        as recid
        format ">>>>>>9"
        no-undo.
    def Input param p_cdn_fornec_titulo
        as Integer
        format ">>>,>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsuni_version}" >= "1.00" &then
    def buffer b_fornecedor_pagto
        &if DEFINED(ems5_db) &then
             for ems5.fornecedor.
        &ELSEIF DEFINED(emscad_db) &then
             for emscad.fornecedor.
        &ELSEIF DEFINED(ems5cad_db) &then
             for ems5cad.fornecedor.
        &endif
    &endif


    /*************************** Buffer Definition End **************************/

    create tt_nome_abrev_fornec.

    find b_fornecedor_pagto no-lock
        where b_fornecedor_pagto.cod_empresa    = p_cod_empresa
        and   b_fornecedor_pagto.cdn_fornecedor = p_cdn_fornec_titulo
        no-error.
    if avail b_fornecedor_pagto then
        assign tt_nome_abrev_fornec.ttv_rec_tit_ap          = p_rec_tit_ap
               tt_nome_abrev_fornec.tta_cdn_fornecedor      = b_fornecedor_pagto.cdn_fornecedor
               tt_nome_abrev_fornec.tta_nom_abrev           = b_fornecedor_pagto.nom_abrev.
    else
        assign tt_nome_abrev_fornec.ttv_rec_tit_ap          = p_rec_tit_ap
               tt_nome_abrev_fornec.tta_cdn_fornecedor      = p_cdn_fornec_titulo
               tt_nome_abrev_fornec.tta_nom_abrev           = "".

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_cria_epc_titulo:

    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        if  avail item_lote_pagto then do:
            assign v_rec_table_epc = recid(item_lote_pagto)
                   v_nom_table_epc = 'item_lote_pagto'.
            run value(v_nom_prog_upc) (input 'ITEM LOTE',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end.
        end.       
        if  avail item_bord_ap then do:
            assign v_rec_table_epc = recid(item_bord_ap)
                   v_nom_table_epc = 'item_bord_ap'.
            run value(v_nom_prog_upc) (input 'ITEM BORDERO',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end. 
        end.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        if  avail item_lote_pagto then do:
            assign v_rec_table_epc = recid(item_lote_pagto)
                   v_nom_table_epc = 'item_lote_pagto'.
            run value(v_nom_prog_appc) (input 'ITEM LOTE',
                                        input 'viewer',
                                        input this-procedure,
                                        input v_wgh_frame_epc,
                                        input v_nom_table_epc,
                                        input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end.
        end.
        if  avail item_bord_ap then do:
            assign v_rec_table_epc = recid(item_bord_ap)
                   v_nom_table_epc = 'item_bord_ap'.
            run value(v_nom_prog_appc) (input 'ITEM BORDERO',
                                        input 'viewer',
                                        input this-procedure,
                                        input v_wgh_frame_epc,
                                        input v_nom_table_epc,
                                        input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end.
        end.    
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        if  avail item_lote_pagto then do:
            assign v_rec_table_epc = recid(item_lote_pagto)
                   v_nom_table_epc = 'item_lote_pagto'.
            run value(v_nom_prog_dpc) (input 'ITEM LOTE',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end.
        end.
        if  avail item_bord_ap then do:    
            assign v_rec_table_epc = recid(item_bord_ap)
                   v_nom_table_epc = 'item_bord_ap'.
            run value(v_nom_prog_dpc) (input 'ITEM BORDERO',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then do:
                return 'NOK'.
            end.
        end.
    end.
    &endif
    &endif
    return 'ok'.
    /* End_Include: i_exec_program_epc */
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verifica_val_acum_tit_ap:

    /************************ Parameter Definition Begin ************************/

    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_acum_tit_ap
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.

    DEF VAR v_dat_cotac_indic_econ   AS DATE NO-UNDO.
    DEF VAR v_val_cotac_indic_econ   AS DEC  NO-UNDO.

    /************************* Parameter Definition End *************************/

    /* Retornar a finalidade econ-mica do t°tulo*/
    run pi_retornar_finalid_indic_econ_tt (Input tt_titulos_bord.cod_indic_econ,
                                           Input p_dat_transacao,
                                           output v_cod_finalid_econ) /* pi_retornar_finalid_indic_econ_tt*/.

    if v_cod_finalid_econ <> v_cod_finalid_param then do:
        run pi_achar_cotac_indic_econ in v_hdl_indic_econ_finalid (Input tt_titulos_bord.cod_indic_econ,
                                                                   Input v_cod_indic_econ_param,
                                                                   Input p_dat_transacao,
                                                                   Input "Real" /*l_real*/ ,
                                                                   output v_dat_cotac_indic_econ,
                                                                   output v_val_cotac_indic_econ,
                                                                   output v_cod_return) /* pi_achar_cotac_indic_econ*/.
        assign p_val_acum_tit_ap = tt_titulos_bord.val_sdo_tit_ap / v_val_cotac_indic_econ.
    end.
    else
        assign p_val_acum_tit_ap = tt_titulos_bord.val_sdo_tit_ap.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_retornar_finalid_indic_econ_tt:

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

    find first tt_histor_finalid use-index tt_indic
        where tt_histor_finalid.tta_cod_indic_econ  = p_cod_indic_econ
        and   tt_histor_finalid.tta_dat_inic_valid <= p_dat_transacao
        and   tt_histor_finalid.tta_dat_fim_valid   > p_dat_transacao no-error.
    if  not avail tt_histor_finalid then do:
        run pi_retornar_finalid_indic_econ (Input p_cod_indic_econ,
                                            Input p_dat_transacao,
                                            output p_cod_finalid_econ) /*pi_retornar_finalid_indic_econ*/.

        create tt_histor_finalid.
        assign tt_histor_finalid.tta_cod_indic_econ   = p_cod_indic_econ
               tt_histor_finalid.tta_cod_finalid_econ = p_cod_finalid_econ.
        if avail histor_finalid_econ then
            assign tt_histor_finalid.tta_dat_inic_valid = histor_finalid_econ.dat_inic_valid_finalid
                   tt_histor_finalid.tta_dat_fim_valid  = histor_finalid_econ.dat_fim_valid_finalid.
    end.
    assign p_cod_finalid_econ = tt_histor_finalid.tta_cod_finalid_econ.
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verificar_val_usuar_ant:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_verific
        as character
        format "X(08)"
        no-undo.
    def Input param p_val_pagto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_liber_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_liber_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_pagto_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_pagto_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_cod_return_liber_pagto
        as character
        format "x(8)"
        no-undo.
    def output param p_cod_return_pagto
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_val_tot_liber                  as decimal         no-undo. /*local*/
    def var v_val_tot_pagto                  as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign p_cod_return_liber_pagto = "OK" /*l_ok*/  
           p_cod_return_pagto       = "OK" /*l_ok*/ .

    assign p_dat_transacao = date(month(p_dat_transacao),01,year(p_dat_transacao)).
    find movto_usuar_financ no-lock use-index mvtsrfnn_id
         where movto_usuar_financ.cod_usuario = v_cod_usuar_corren
         and   movto_usuar_financ.cod_estab = p_cod_estab
         and   movto_usuar_financ.dat_movto_usuar_ap = p_dat_transacao no-error.

    if  avail movto_usuar_financ then
        assign v_val_tot_liber = movto_usuar_financ.val_tot_liber_pagto_mes
               v_val_tot_pagto = movto_usuar_financ.val_tot_pagto_mes + movto_usuar_financ.val_tot_pagto_pend_mes.
    else
        assign v_val_tot_liber = 0
               v_val_tot_pagto = 0.

    if  p_ind_tip_verific = "Liber" /*l_liber*/   or
        p_ind_tip_verific = "Ambos" /*l_ambos*/   then do:
        if  p_val_pagto + v_val_tot_liber > p_val_lim_liber_usuar_mes
        then do:
            assign p_cod_return_liber_pagto = "1055".
            return.
        end.
        else
            assign p_cod_return_liber_pagto = "OK" /*l_ok*/ .
    end.

    if  p_ind_tip_verific = "Pagamento" /*l_pagamento*/  
    or  p_ind_tip_verific = "Ambos" /*l_ambos*/  then do:
        if  p_val_pagto + v_val_tot_pagto > p_val_lim_pagto_usuar_mes
        then do:
            assign p_cod_return_pagto = "1057".
            return.
        end.
        else
            assign p_cod_return_pagto = "OK" /*l_ok*/ .
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_choose_bt_ok_f_dlg_03_item_lote_pagto_conjunto_compl:

       if can-find (first tt_titulos_bord) then do:

            IF tt_titulos_bord.cod_forma_pagto = "" THEN DO:
                if  tt_titulos_bord.cod_refer_antecip_pef = "" then do: /* titulo */ 
                    if tt_titulos_bord.num_seq_pagto_tit_ap <> 0 then
                        find first item_bord_ap
                            where item_bord_ap.cod_estab       = tt_titulos_bord.cod_estab
                            and   item_bord_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                            and   item_bord_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                            and   item_bord_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                            and   item_bord_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                            and   item_bord_ap.cod_parcela     = tt_titulos_bord.cod_parcela
                            and   item_bord_ap.num_seq_pagto_tit_ap = tt_titulos_bord.num_seq_pagto_tit_ap
                            no-lock no-error.
                    else
                        find first item_bord_ap
                            where item_bord_ap.cod_estab       = tt_titulos_bord.cod_estab
                            and   item_bord_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                            and   item_bord_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                            and   item_bord_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                            and   item_bord_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                            and   item_bord_ap.cod_parcela     = tt_titulos_bord.cod_parcela
                            no-lock no-error.
                end.                        
                else do:
                    if tt_titulos_bord.num_seq_pagto_tit_ap <> 0 then
                        find first item_bord_ap
                            where item_bord_ap.cod_estab             = tt_titulos_bord.cod_estab
                            and   item_bord_ap.cod_refer_antecip_pef = tt_titulos_bord.cod_refer_antecip_pef
                            and   item_bord_ap.val_pagto             = tt_titulos_bord.val_sdo_tit_ap
                            and   item_bord_ap.num_seq_pagto_tit_ap  = tt_titulos_bord.num_seq_pagto_tit_ap
                            no-lock no-error.
                    else
                        find first item_bord_ap
                            where item_bord_ap.cod_estab             = tt_titulos_bord.cod_estab
                            and   item_bord_ap.cod_refer_antecip_pef = tt_titulos_bord.cod_refer_antecip_pef
                            and   item_bord_ap.val_pagto             = tt_titulos_bord.val_sdo_tit_ap
                            no-lock no-error.
                end /* else */.
                if avail item_bord_ap
                and item_bord_ap.cod_forma_pagto = ""
                then do:
                    create tt_log_erros_atualiz.
                    assign tt_log_erros_atualiz.tta_cod_estab    = tt_titulos_bord.cod_estab
                           tt_log_erros_atualiz.ttv_num_mensagem = 12988
                           tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
                    run pi_messages (input "msg",
                                     input 12988,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_12988*/.
                    run pi_messages (input "help",
                                     input 12988,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_12988*/.
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, item_bord_ap.num_seq_bord).

                    assign v_log_erro = yes.
                end.
            end.
        end.
        assign v_val_tot_vincul = 0.
        if tt_titulos_bord.cod_refer_antecip_pef = "" 
        then do:
            for each b_item_bord_ap no-lock
                where b_item_bord_ap.cod_estab       = tt_titulos_bord.cod_estab
                and   b_item_bord_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                and   b_item_bord_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                and   b_item_bord_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                and   b_item_bord_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                and   b_item_bord_ap.cod_parcela     = tt_titulos_bord.cod_parcela
                and   b_item_bord_ap.ind_sit_item_bord_ap <> "Estornado" /*l_estornado*/  
                and   b_item_bord_ap.ind_sit_item_bord_ap <> "Baixado" /*l_baixado*/ :
                assign v_val_tot_vincul = v_val_tot_vincul + b_item_bord_ap.val_pagto_orig.
            end.
            for each b_item_lote_pagto no-lock
                where b_item_lote_pagto.cod_estab       = tt_titulos_bord.cod_estab      
                and   b_item_lote_pagto.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                and   b_item_lote_pagto.cod_ser_docto   = tt_titulos_bord.cod_ser_docto  
                and   b_item_lote_pagto.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor 
                and   b_item_lote_pagto.cod_tit_ap      = tt_titulos_bord.cod_tit_ap     
                and   b_item_lote_pagto.cod_parcela     = tt_titulos_bord.cod_parcela    
                and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Estornado" /*l_estornado*/ 
                and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Baixado" /*l_baixado*/ :
                assign v_val_tot_vincul = v_val_tot_vincul + b_item_lote_pagto.val_pagto_orig.
            end.
            find first b_tit_ap no-lock
                where b_tit_ap.cod_estab       = tt_titulos_bord.cod_estab
                and   b_tit_ap.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                and   b_tit_ap.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                and   b_tit_ap.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                and   b_tit_ap.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                and   b_tit_ap.cod_parcela     = tt_titulos_bord.cod_parcela no-error.
            if avail b_tit_ap then
                assign v_val_sdo_tit_ap_vincul = b_tit_ap.val_sdo_tit_ap - v_val_tot_vincul.

            if v_log_cotac_contrat and avail b_tit_ap then do:
                run pi_set_tit_ap in v_hdl_indic_econ_finalid(input b_tit_ap.cod_estab, input b_tit_ap.num_id_tit_ap).  
            end.            

            if v_val_sdo_tit_ap_vincul < 0 then do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab    = tt_titulos_bord.cod_estab
                       tt_log_erros_atualiz.ttv_num_mensagem = 12620
                       tt_log_erros_atualiz.tta_num_seq_refer = tt_titulos_bord.num_seq_pagto_tit_ap.
                run pi_messages (input "msg",
                                 input 12620,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_12620*/.
                run pi_messages (input "help",
                                 input 12620,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_12620*/.
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, tt_titulos_bord.cod_tit_ap,
                                                                           tt_titulos_bord.cod_ser_docto,
                                                                           tt_titulos_bord.cod_parcela,
                                                                           tt_titulos_bord.cod_refer_antecip_pef,
                                                                           string (tt_titulos_bord.cdn_fornecedor)).

                assign v_log_erro = yes.
            end.

            assign v_log_achou = NO. //Verifica_Program_Name('apb711aa':U, 30).

            if  v_log_achou then do:  

                /* Posiciona no item_lote correto ao passar na validacao do MEC */       
                find first b_item_lote_pagto no-lock
                     where b_item_lote_pagto.cod_estab_refer = lote_pagto.cod_estab_refer
                       and b_item_lote_pagto.cod_refer       = lote_pagto.cod_refer
                       and b_item_lote_pagto.cod_estab       = tt_titulos_bord.cod_estab
                       and b_item_lote_pagto.cod_espec_docto = tt_titulos_bord.cod_espec_docto
                       and b_item_lote_pagto.cod_ser_docto   = tt_titulos_bord.cod_ser_docto
                       and b_item_lote_pagto.cdn_fornecedor  = tt_titulos_bord.cdn_fornecedor
                       and b_item_lote_pagto.cod_tit_ap      = tt_titulos_bord.cod_tit_ap
                       and b_item_lote_pagto.cod_parcela     = tt_titulos_bord.cod_parcela no-error.

                if avail b_item_lote_pagto then do:
                   /* Validacao Integracao MEC5 */
                   run pi_busca_saldo_titulo_mec (input b_tit_ap.cod_empresa,
                                                  input b_item_lote_pagto.cod_estab,
                                                  input b_item_lote_pagto.cdn_fornecedor, 
                                                  input b_item_lote_pagto.cod_espec_docto,
                                                  input b_item_lote_pagto.cod_ser_docto,
                                                  input b_item_lote_pagto.cod_tit_ap,
                                                  input b_item_lote_pagto.cod_parcela,
                                                  input b_item_lote_pagto.dat_vencto_tit_ap,
                                                  input b_tit_ap.cod_indic_econ, 
                                                  input 1 / tt_titulos_bord.val_cotac_indic_econ,
                                                  input b_item_lote_pagto.val_pagto).
                   if  return-value <> "OK" /*l_ok*/  then do:
                       return "NOK" /*l_nok*/ .
                   end.  
                end.                                           
            end.    
        end.
        else do:
            find antecip_pef_pend no-lock
                where antecip_pef_pend.cod_estab = tt_titulos_bord.cod_estab
                and   antecip_pef_pend.cod_refer = tt_titulos_bord.cod_refer_antecip_pef no-error.
            if  avail antecip_pef_pend then do:
                if v_log_cotac_contrat then do:
                    run pi_set_antecip_pef_pend in v_hdl_indic_econ_finalid(input antecip_pef_pend.cod_estab, input antecip_pef_pend.cod_refer).
                end.        

                for each b_item_bord_ap no-lock
                    where b_item_bord_ap.cod_estab             = antecip_pef_pend.cod_estab
                    and   b_item_bord_ap.cod_refer_antecip_pef = antecip_pef_pend.cod_refer
                    and   b_item_bord_ap.ind_sit_item_bord_ap <> "Estornado" /*l_estornado*/  
                    and   b_item_bord_ap.ind_sit_item_bord_ap <> "Baixado" /*l_baixado*/ :
                    assign v_val_tot_vincul = v_val_tot_vincul + b_item_bord_ap.val_pagto_orig.
                end.
                for each b_item_lote_pagto no-lock
                    where b_item_lote_pagto.cod_estab             = antecip_pef_pend.cod_estab
                    and   b_item_lote_pagto.cod_refer_antecip_pef = antecip_pef_pend.cod_refer
                    and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Estornado" /*l_estornado*/ 
                    and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Baixado" /*l_baixado*/ :
                    assign v_val_tot_vincul = v_val_tot_vincul + b_item_lote_pagto.val_pagto_orig.
                end.
                if v_val_tot_vincul - tt_titulos_bord.val_sdo_tit_ap > 0 then do:
                    create tt_log_erros_atualiz.
                    assign tt_log_erros_atualiz.tta_cod_estab    = tt_titulos_bord.cod_estab
                           tt_log_erros_atualiz.ttv_num_mensagem = 12620
                           tt_log_erros_atualiz.tta_num_seq_refer = tt_titulos_bord.num_seq_pagto_tit_ap.
                    run pi_messages (input "msg",
                                     input 12620,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_12620*/.
                    run pi_messages (input "help",
                                     input 12620,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_12620*/.
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, tt_titulos_bord.cod_tit_ap,
                                                                               tt_titulos_bord.cod_ser_docto,
                                                                               tt_titulos_bord.cod_parcela,
                                                                               tt_titulos_bord.cod_refer_antecip_pef,
                                                                               string (tt_titulos_bord.cdn_fornecedor)).
                    assign v_log_erro = yes.
                end.
            end.
        end.
    return "OK" /*l_ok*/ .
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_retornar_saldo_liber_pagto_2:

    /************************ Parameter Definition Begin ************************/

    def output param p_val_sdo_tit_ap
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_num_seq_bord
        as integer
        format ">>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap_saldo
        for item_bord_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_pagto_saldo
        for item_lote_pagto.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_proces_pagto_saldo
        for proces_pagto.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_val_tot_liber                  as decimal         no-undo. /*local*/
    def var v_val_tot_pagto                  as decimal         no-undo. /*local*/
    def var v_log_liberacao                  as logical         no-undo. /*local*/


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_pi_retornar_saldo_liber_pagto */
    assign v_val_tot_liber     = 0
           v_val_tot_pagto     = 0.




    for each b_proces_pagto_saldo


        use-index prcspgt_id
        where b_proces_pagto_saldo.cod_estab       = tit_ap.cod_estab
        and   b_proces_pagto_saldo.cod_espec_docto = tit_ap.cod_espec_docto
        and   b_proces_pagto_saldo.cod_ser_docto   = tit_ap.cod_ser_docto
        and   b_proces_pagto_saldo.cdn_fornecedor  = tit_ap.cdn_fornecedor
        and   b_proces_pagto_saldo.cod_tit_ap      = tit_ap.cod_tit_ap
        and   b_proces_pagto_saldo.cod_parcela     = tit_ap.cod_parcela no-lock:

         if  b_proces_pagto_saldo.ind_sit_proces_pagto = "Preparado" /* l_preparado*/  then do:
            assign p_num_seq_bord = b_proces_pagto_saldo.num_seq_pagto_tit_ap.
         end. 
         else do:
             if  b_proces_pagto_saldo.ind_sit_proces_pagto = "Liberado" /* l_liberado*/  then do:
                assign v_val_tot_liber = v_val_tot_liber + b_proces_pagto_saldo.val_liber_pagto_orig.


            end.
            else do:

                for each b_item_bord_ap_saldo 
                    use-index itmbrdp_tit_ap
                    where b_item_bord_ap_saldo.cod_estab            = tit_ap.cod_estab
                    and   b_item_bord_ap_saldo.cdn_fornecedor       = tit_ap.cdn_fornecedor
                    and   b_item_bord_ap_saldo.cod_espec_docto      = tit_ap.cod_espec_docto
                    and   b_item_bord_ap_saldo.cod_ser_docto        = tit_ap.cod_ser_docto
                    and   b_item_bord_ap_saldo.cod_tit_ap           = tit_ap.cod_tit_ap
                    and   b_item_bord_ap_saldo.cod_parcela          = tit_ap.cod_parcela
                    and   b_item_bord_ap_saldo.num_seq_pagto_tit_ap = b_proces_pagto_saldo.num_seq_pagto_tit_ap
                    and   b_item_bord_ap_saldo.ind_sit_item_bord_ap <> "Estornado" /*l_estornado*/ 
                    and   b_item_bord_ap_saldo.ind_sit_item_bord_ap <> "Baixado" /*l_baixado*/  no-lock:
                    assign v_val_tot_pagto = v_val_tot_pagto + b_item_bord_ap_saldo.val_pagto_orig.
                end.

                for each b_item_lote_pagto_saldo
                    use-index itmltpgt_tit_ap
                    where b_item_lote_pagto_saldo.cod_estab                 = tit_ap.cod_estab
                    and   b_item_lote_pagto_saldo.cdn_fornecedor            = tit_ap.cdn_fornecedor
                    and   b_item_lote_pagto_saldo.cod_espec_docto           = tit_ap.cod_espec_docto
                    and   b_item_lote_pagto_saldo.cod_ser_docto             = tit_ap.cod_ser_docto
                    and   b_item_lote_pagto_saldo.cod_tit_ap                = tit_ap.cod_tit_ap
                    and   b_item_lote_pagto_saldo.cod_parcela               = tit_ap.cod_parcela
                    and   b_item_lote_pagto_saldo.num_seq_pagto_tit_ap      = b_proces_pagto_saldo.num_seq_pagto_tit_ap
                    and   b_item_lote_pagto_saldo.ind_sit_item_lote_bxa_ap <> "Estornado" /*l_estornado*/ 
                    and   b_item_lote_pagto_saldo.ind_sit_item_lote_bxa_ap <> "Baixado" /*l_baixado*/  no-lock:
                    assign v_val_tot_pagto = v_val_tot_pagto + b_item_lote_pagto_saldo.val_pagto_orig.
                end.
            end.
        end.
    end.




    /* ** Manter o No-lock no fonte - geraá∆o conforme demanda ***/



    for each   relacto_pend_tit_ap no-lock
         where relacto_pend_tit_ap.cod_estab_tit_ap_pai = tit_ap.cod_estab
         and   relacto_pend_tit_ap.num_id_tit_ap_pai    = tit_ap.num_id_tit_ap:

         assign v_val_tot_pagto = v_val_tot_pagto + relacto_pend_tit_ap.val_relacto_tit_ap.



    end.
    /* End_Include: i_pi_retornar_saldo_liber_pagto */


    &if defined(BF_FIN_ORIG_GRAOS) &then
      if  v_log_program
      and valid-handle(v_hdl_api_graos) then do:   
         run piRetornaValorAlocadoFechto in v_hdl_api_graos (INPUT tit_ap.cod_estab, 
                                                             INPUT tit_ap.num_id_tit_ap,
                                                             INPUT "APB" /*l_apb*/ , 
                                                            OUTPUT v_val_sdo_comprtdo).
         assign v_val_tot_pagto = v_val_tot_pagto + v_val_sdo_comprtdo.
      end.
    &endif

    if  v_log_liberacao = yes then
        assign p_val_sdo_tit_ap = tit_ap.val_sdo_tit_ap - v_val_tot_liber - v_val_tot_pagto.
    else do:
        if  v_val_tot_liber > 0 then 
            assign p_val_sdo_tit_ap = tit_ap.val_sdo_tit_ap - v_val_tot_liber - v_val_tot_pagto.
        else
            assign p_val_sdo_tit_ap = tit_ap.val_sdo_tit_ap - v_val_tot_pagto.
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verificar_val_usuar_cotac_inf:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_verific
        as character
        format "X(08)"
        no-undo.
    def Input param p_val_pagto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_liber_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_liber_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_pagto_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_lim_pagto_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_finalid_econ_pag
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_pag
        as character
        format "x(8)"
        no-undo.
    def Input param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def output param p_cod_return_liber_pagto
        as character
        format "x(8)"
        no-undo.
    def output param p_cod_return_pagto
        as character
        format "x(8)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_val_tot_liber
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_val_tot_pagto
        as decimal
        format "->>,>>>,>>>,>>>,>>>,>>9.99":U
        decimals 2
        label "Total do Pagamento"
        column-label "Total do Pagamento"
        no-undo.

    /************************** Variable Definition End *************************/

    assign p_cod_return_liber_pagto = "OK" /*l_ok*/ 
           p_cod_return_pagto       = "OK" /*l_ok*/ .

    find last param_empres_apb no-lock
        where param_empres_apb.cod_empresa = v_cod_empres_usuar no-error.

    if  avail param_empres_apb then do:
        if  p_cod_finalid_econ_pag  = param_empres_apb.cod_finalid_econ_val_usuar 
            then assign p_val_pagto = p_val_pagto * 1.
        else do:
             if  p_cod_finalid_econ_pag <> param_empres_apb.cod_finalid_econ_val_usuar
             and p_cod_finalid_econ      = param_empres_apb.cod_finalid_econ_val_usuar
                 then assign p_val_pagto = p_val_pagto * p_val_cotac_indic_econ.
             else do:
                run pi_converter_indic_econ_finalid (Input p_cod_indic_econ_pag,
                                                     Input v_cod_empres_usuar,
                                                     Input p_dat_transacao,
                                                     Input p_val_pagto,
                                                     Input param_empres_apb.cod_finalid_econ_val_usuar,
                                                     output v_cod_return) /*pi_converter_indic_econ_finalid*/.
                if  v_cod_return = "OK" /*l_ok*/  or v_cod_return = "" then do:
                    find first tt_converter_finalid_econ no-lock no-error.
                    assign p_val_pagto = tt_converter_finalid_econ.tta_val_transacao.
                end.
                else do:
                    assign p_cod_return_liber_pagto = v_cod_return
                           p_cod_return_pagto       = v_cod_return.
                    return. // tratamento de erro revisado
                end.
            end.
        end.

        assign p_dat_transacao = date(month(p_dat_transacao),01,year(p_dat_transacao)).
        find movto_usuar_financ no-lock use-index mvtsrfnn_id
             where movto_usuar_financ.cod_usuario        = v_cod_usuar_corren
             and   movto_usuar_financ.cod_estab          = p_cod_estab
             and   movto_usuar_financ.dat_movto_usuar_ap = p_dat_transacao no-error.
        if  avail movto_usuar_financ then
            assign v_val_tot_liber = movto_usuar_financ.val_tot_liber_pagto_mes
                   v_val_tot_pagto = movto_usuar_financ.val_tot_pagto_mes + movto_usuar_financ.val_tot_pagto_pend_mes.
        else
            assign v_val_tot_liber = 0
                   v_val_tot_pagto = 0.

        if  p_ind_tip_verific = "Liber" /*l_liber*/  or
            p_ind_tip_verific = "Ambos" /*l_ambos*/  then do:
            if  p_val_pagto > p_val_lim_liber_usuar_movto then 
                assign p_cod_return_liber_pagto = "1054".
            else do:
                if  p_val_pagto + v_val_tot_liber > p_val_lim_liber_usuar_mes then
                    assign p_cod_return_liber_pagto = "1055".
                else
                    assign p_cod_return_liber_pagto = "OK" /*l_ok*/ .
            end.
        end.

        if  p_ind_tip_verific = "Pagamento" /*l_pagamento*/ 
        or  p_ind_tip_verific  = "Ambos" /*l_ambos*/  then do:
            if  p_val_pagto > p_val_lim_pagto_usuar_movto then
                assign p_cod_return_pagto = "1056".
            else do:
                if  p_val_pagto + v_val_tot_pagto > p_val_lim_pagto_usuar_mes then
                    assign p_cod_return_pagto = "1057".
                else
                    assign p_cod_return_pagto = "OK" /*l_ok*/ .
            end.
        end.
    end.
    else
        assign p_cod_return_liber_pagto = "1053"
               p_cod_return_pagto       = "1053".
               
    // tratamento de erro revisado, retorna c¢digo no parÉmetro                   

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_retornar_indic_econ_corren_estab:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
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

    find estabelecimento no-lock
         where estabelecimento.cod_estab = p_cod_estab
         use-index stblcmnt_id no-error.
    if  avail estabelecimento
    then do:
        find FIRST pais no-lock
            where pais.cod_pais = estabelecimento.cod_pais
             no-error.
        IF NOT VALID-HANDLE(v_hdl_indic_econ_finalid) THEN
               run prgint/utb/utb921zb.py persistent set v_hdl_indic_econ_finalid.
       run pi_retornar_indic_econ_finalid 

           in v_hdl_indic_econ_finalid

             (Input pais.cod_finalid_econ_pais,
              Input p_dat_transacao,
              output p_cod_indic_econ) /* pi_retornar_indic_econ_finalid*/.
    end /* if */.

    IF VALID-HANDLE(v_hdl_indic_econ_finalid) THEN
        DELETE PROCEDURE v_hdl_indic_econ_finalid.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_retornar_cotac_infor_lote:

    /************************ Parameter Definition Begin ************************/

    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_cotac_impl
        as decimal
        format "->>,>>>,>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def output param p_dat_cotac
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    /* ** QUANDO NO PAGAMENTO, » INFORMADO NA TELA A COTA∞ÄO MANUALMENTE,
     *** ESTA PI RETORNA A COTA∞ÄO INFORMADA, OU CALCULA.
     ***/

    if  tt_param.cod_indic_econ_ini = tt_param.cod_indic_econ_fim
    and tt_param.cod_indic_econ_ini <> ""
    and tt_param.cod_indic_econ_ini <> bord_ap.cod_indic_econ then
        assign p_val_cotac_impl = tt_param.val_cotac_indic_econ
               p_dat_cotac      = tt_param.dat_cotac_indic_econ.
    else do:
       if  bord_ap.cod_indic_econ <> tt_titulos_bord.cod_indic_econ
       then do:
           IF NOT VALID-HANDLE(v_hdl_indic_econ_finalid) THEN
               run prgint/utb/utb921zb.py persistent set v_hdl_indic_econ_finalid.
           run pi_achar_cotac_indic_econ 

                    in v_hdl_indic_econ_finalid 

                                       (Input tt_titulos_bord.cod_indic_econ,
                                        Input bord_ap.cod_indic_econ,
                                        Input p_dat_transacao,
                                        Input "Real" /*l_real*/ ,
                                        output p_dat_cotac,
                                        output p_val_cotac_impl,
                                        output v_cod_return).

           if  v_cod_return <> 'OK' then
               return "3414".
       end.
       else
           assign p_val_cotac_impl = 1
                  p_dat_cotac      = v_dat_min_sql.
    end.

    IF VALID-HANDLE(v_hdl_indic_econ_finalid) THEN
        DELETE PROCEDURE v_hdl_indic_econ_finalid.
    return 'OK'.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_calcula_dias_uteis_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_param_1
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_dat_param_2
        as date
        format "99/99/9999"
        no-undo.
    def output param p_num_dias_util
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_aux
        as date
        format "99/99/9999":U
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_num_dias_util = 0.

    if p_dat_param_2 - p_dat_param_1 < 1 then return.

    find estabelecimento no-lock
        where estabelecimento.cod_estab = p_cod_estab 
        no-error.
    if not avail estabelecimento then return.

    find calend_glob no-lock 
        where calend_glob.cod_calend = estabelecimento.cod_calend_financ 
        no-error.
    if not avail calend_glob then return.

    do v_dat_aux = p_dat_param_1 to p_dat_param_2:
        /* 194974 - Dani 07/02/08 = alteraá∆o sob demanda (melhora a performace)  */
        if can-find (first dia_calend_glob no-lock 
            where dia_calend_glob.cod_calend = calend_glob.cod_calend
              and dia_calend_glob.dat_calend = v_dat_aux
              and dia_calend_glob.log_dia_util) then 
            assign p_num_dias_util = p_num_dias_util + 1.
    end.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verifica_dia_util_dat_vencto_x_dat_trans:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_param_1
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_dat_param_2
        as date
        format "99/99/9999"
        no-undo.
    def output param p_log_dia_util
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_aux
        as date
        format "99/99/9999":U
        no-undo.


    /************************** Variable Definition End *************************/

    if  p_dat_param_2 - p_dat_param_1 < 0 then return.

    find estabelecimento no-lock
        where estabelecimento.cod_estab = p_cod_estab 
        no-error.
    if not avail estabelecimento then return.

    find calend_glob no-lock 
        where calend_glob.cod_calend = estabelecimento.cod_calend_financ 
        no-error.
    if not avail calend_glob then return.

    assign p_log_dia_util = no.
    /* 194974 - Dani 07/02/08 = alteraá∆o sob demanda (melhora a performace)  */
    data_block:
    do  v_dat_aux = p_dat_param_1 to p_dat_param_2:
        if can-find (first dia_calend_glob no-lock 
            where dia_calend_glob.cod_calend = calend_glob.cod_calend
              and dia_calend_glob.dat_calend = v_dat_aux 
              and dia_calend_glob.log_dia_util ) then do:
            assign p_log_dia_util = yes.
            leave data_block.
        end.
    end.
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gerar_proces_pagto_item_pagto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab_refer
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_num_seq_refer
        as integer
        format ">>>9"
        no-undo.
    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cdn_fornec_titulo
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_tit_ap
        as character
        format "x(16)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
        no-undo.
    def Input param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_val_pagto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_val_pagto_orig
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_ind_modo_pagto
        as character
        format "X(10)"
        no-undo.
    def input-output param p_num_seq_pagto_tit_ap
        as integer
        format ">9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.
    def var v_ind_tip_atualiz_val_usuar
        as character
        format "X(08)":U
        no-undo.
    def var v_val_pagto
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        label "Valor Pagamento"
        column-label "Valor Pagamento"
        no-undo.
    def var v_num_seq_pagto                  as integer         no-undo. /*local*/
    DEF VAR v_log_atualiz_hora_liber         AS LOGICAL         NO-UNDO.

    /************************** Variable Definition End *************************/

    assign v_log_atualiz_hora_liber = no.
    &if defined(BF_ATUALIZ_HORA_PROCES_PAGTO) &then
        assign v_log_atualiz_hora_liber = yes.
    &elseif '{&emsfin_version}' >= '5.03'&then
        find FIRST histor_exec_especial no-lock
            where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
            and   histor_exec_especial.cod_prog_dtsul = 'SPP_ATUALIZ_HORA_PROCES_PAGTO':U no-error.
        if avail histor_exec_especial then
            assign v_log_atualiz_hora_liber = yes.
    &endif

    if  p_num_seq_pagto_tit_ap <> ?
    and p_num_seq_pagto_tit_ap <> 0
    then do:
        find proces_pagto
            where proces_pagto.cod_estab            = p_cod_estab
            and   proces_pagto.cod_espec_docto      = p_cod_espec_docto
            and   proces_pagto.cod_ser_docto        = p_cod_ser_docto
            and   proces_pagto.cdn_fornecedor       = p_cdn_fornec_titulo
            and   proces_pagto.cod_tit_ap           = p_cod_tit_ap
            and   proces_pagto.cod_parcela          = p_cod_parcela
            and   proces_pagto.num_seq_pagto_tit_ap = p_num_seq_pagto_tit_ap
            exclusive-lock no-error.
        assign v_ind_tip_atualiz_val_usuar = "Pagto" /*l_pagto*/ .
    end.
    else do:
        find first proces_pagto
            where proces_pagto.cod_estab            = p_cod_estab
            and   proces_pagto.cod_espec_docto      = p_cod_espec_docto
            and   proces_pagto.cod_ser_docto        = p_cod_ser_docto
            and   proces_pagto.cdn_fornecedor       = p_cdn_fornec_titulo
            and   proces_pagto.cod_tit_ap           = p_cod_tit_ap
            and   proces_pagto.cod_parcela          = p_cod_parcela
            and   proces_pagto.ind_sit_proces_pagto = "Preparado" /*l_preparado*/ 
            exclusive-lock no-error.
        if  not avail proces_pagto
        then do:
            find last proces_pagto
                where proces_pagto.cod_estab       = p_cod_estab
                and   proces_pagto.cod_espec_docto = p_cod_espec_docto
                and   proces_pagto.cod_ser_docto   = p_cod_ser_docto
                and   proces_pagto.cdn_fornecedor  = p_cdn_fornec_titulo
                and   proces_pagto.cod_tit_ap      = p_cod_tit_ap
                and   proces_pagto.cod_parcela     = p_cod_parcela
                no-lock no-error.
            if  avail proces_pagto then
                assign v_num_seq_pagto = proces_pagto.num_seq_pagto_tit_ap + 1.
            else
                assign v_num_seq_pagto = 1.

            create proces_pagto.
            assign proces_pagto.cod_empresa            = v_cod_empres_usuar
                   proces_pagto.cod_estab              = p_cod_estab
                   proces_pagto.cod_espec_docto        = p_cod_espec_docto
                   proces_pagto.cod_ser_docto          = p_cod_ser_docto
                   proces_pagto.cdn_fornecedor         = p_cdn_fornec_titulo
                   proces_pagto.cod_tit_ap             = p_cod_tit_ap
                   proces_pagto.cod_parcela            = p_cod_parcela
                   proces_pagto.num_seq_pagto_tit_ap   = v_num_seq_pagto
                   proces_pagto.cod_usuar_prepar_pagto = v_cod_usuar_corren
                   proces_pagto.dat_prepar_pagto       = p_dat_transacao.
        end.
        assign proces_pagto.cod_portador            = p_cod_portador
               proces_pagto.dat_vencto_tit_ap       = tit_ap.dat_vencto_tit_ap
               proces_pagto.dat_prev_pagto          = tit_ap.dat_prev_pagto
               proces_pagto.dat_desconto            = tit_ap.dat_desconto
               proces_pagto.cod_usuar_liber_pagto   = v_cod_usuar_corren
               proces_pagto.dat_liber_pagto         = p_dat_transacao
               proces_pagto.val_liberd_pagto        = p_val_pagto
               proces_pagto.val_liber_pagto_orig    = p_val_pagto_orig
               proces_pagto.cod_indic_econ          = p_cod_indic_econ
               proces_pagto.cod_refer_antecip_pef   = ""
               p_num_seq_pagto_tit_ap               = proces_pagto.num_seq_pagto_tit_ap.
        assign v_ind_tip_atualiz_val_usuar = "Ambos" /*l_ambos*/ .
        if v_log_atualiz_hora_liber = yes then do:
        &if '{&emsfin_version}' < '5.05' &then
            assign proces_pagto.cod_livre_1 = string(time,'hh:mm:ss').
        &else
            assign proces_pagto.hra_liber_proces_pagto = replace(string(time,'HH:MM:SS'),":","").
        &endif
    end.
    end.
    assign proces_pagto.cod_portador         = p_cod_portador
           proces_pagto.ind_sit_proces_pagto = "Em Pagamento" /*l_em_pagamento*/ 
           proces_pagto.cod_usuar_pagto      = v_cod_usuar_corren
           proces_pagto.dat_pagto            = p_dat_transacao
           proces_pagto.ind_modo_pagto       = p_ind_modo_pagto
           proces_pagto.val_liberd_pagto     = p_val_pagto
           proces_pagto.val_liber_pagto_orig = p_val_pagto_orig
           proces_pagto.cod_indic_econ       = p_cod_indic_econ.


    /* ** ATUALIZA VALORES DO USUÊRIO e VALORES DO FORNECEDOR ***/
    find last param_empres_apb no-lock
        where param_empres_apb.cod_empresa = v_cod_empres_usuar
        no-error.
    if  not avail param_empres_apb then
        return "1053".

    if  p_cod_finalid_econ <> param_empres_apb.cod_finalid_econ_val_usuar
    then do:
        run pi_converter_indic_econ_finalid (Input p_cod_indic_econ,
                                             Input v_cod_empres_usuar,
                                             Input p_dat_transacao,
                                             Input p_val_pagto,
                                             Input param_empres_apb.cod_finalid_econ_val_usuar,
                                             output v_cod_return) /*pi_converter_indic_econ_finalid*/.
        if  v_cod_return = 'OK'
        or  v_cod_return = "" then do:
            find first tt_converter_finalid_econ no-lock no-error.
            assign v_val_pagto = tt_converter_finalid_econ.tta_val_transacao.
        end.
        else
            return v_cod_return.
    end.
    else
        assign v_val_pagto = p_val_pagto.

    run pi_atualizar_valor_usuar_apb (Input p_cod_estab_refer,
                                      Input p_cod_estab,
                                      Input p_dat_transacao,
                                      Input v_ind_tip_atualiz_val_usuar,
                                      Input v_val_pagto,
                                      Input v_cod_usuar_corren) /*pi_atualizar_valor_usuar_apb*/.

    run prgfin/apb/apb012za.py (Input p_cod_estab_refer,
                                Input p_cod_refer,
                                Input p_num_seq_refer,
                                Input "",
                                Input 0,
                                Input p_dat_transacao,
                                Input tit_ap.num_pessoa,
                                Input p_cod_indic_econ,
                                Input p_cod_estab,
                                Input p_val_pagto) /*prg_fnc_atualiza_acumulados_pessoa*/.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_atualizar_valor_usuar_apb:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab_bord
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_verific
        as character
        format "X(08)"
        no-undo.
    def Input param p_val_finalid_econ
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_cod_usuar_corren
        as character
        format "x(12)"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign_block:
    do on error undo assign_block, return error:

        assign p_dat_transacao = date(month(p_dat_transacao),01,year(p_dat_transacao)).

        /* -- Atualiza valor total de liberaá∆o feito pelo usu†rio no màs --*/
        if  p_ind_tip_verific = "Liber" /*l_liber*/  or  p_ind_tip_verific = "Ambos" /*l_ambos*/  then do:
            find movto_usuar_financ exclusive-lock use-index mvtsrfnn_id
                where movto_usuar_financ.cod_estab          = p_cod_estab
                and   movto_usuar_financ.cod_usuario        = p_cod_usuar_corren
                and   movto_usuar_financ.dat_movto_usuar_ap = p_dat_transacao no-error.

            if  not avail movto_usuar_financ then do:
                create movto_usuar_financ.
                assign movto_usuar_financ.cod_usuario             = p_cod_usuar_corren
                       movto_usuar_financ.cod_estab               = p_cod_estab
                       movto_usuar_financ.dat_movto_usuar_ap      = p_dat_transacao
                       movto_usuar_financ.val_tot_liber_pagto_mes = 0
                       movto_usuar_financ.val_tot_pagto_mes       = 0
                       movto_usuar_financ.val_tot_pagto_pend_mes  = 0.
            end.

            assign movto_usuar_financ.val_tot_liber_pagto_mes =
                   movto_usuar_financ.val_tot_liber_pagto_mes + p_val_finalid_econ.
        end.

        /* -- Atualiza valor total de pagto feito pelo usu†rio no màs--*/
        if  p_ind_tip_verific = "Pagto" /*l_pagto*/  or p_ind_tip_verific = "Ambos" /*l_ambos*/  then do:
            find movto_usuar_financ exclusive-lock use-index mvtsrfnn_id
                where movto_usuar_financ.cod_usuario = p_cod_usuar_corren
                and   movto_usuar_financ.cod_estab   = p_cod_estab_bord
                and   movto_usuar_financ.dat_movto_usuar_ap = p_dat_transacao no-error.

            if  not avail movto_usuar_financ then do:
                create movto_usuar_financ.
                assign movto_usuar_financ.cod_usuario             = p_cod_usuar_corren
                       movto_usuar_financ.cod_estab               = p_cod_estab_bord
                       movto_usuar_financ.dat_movto_usuar_ap      = p_dat_transacao
                       movto_usuar_financ.val_tot_liber_pagto_mes = 0
                       movto_usuar_financ.val_tot_pagto_mes       = 0
                       movto_usuar_financ.val_tot_pagto_pend_mes  = 0.
            end.

            assign movto_usuar_financ.val_tot_pagto_pend_mes =
                   movto_usuar_financ.val_tot_pagto_pend_mes + p_val_finalid_econ.

            /* ** Ser† atualizado o valor dos limites de pagamento do usu†rio junto ao item de pagamento
                 para caso o lote venha a ser estornado, atualize os valores do usu†rio que fez o pagamento
                 e n∆o o que est† fazendo a movimentaá∆o de estorno.
            ***/
            &if '{&emsbas_version}' >= '5.03' &then
                if avail item_bord_ap then
                    assign item_bord_ap.cod_usuar_pagto = movto_usuar_financ.cod_usuario.

                if avail antecip_pef_pend then do:
                    /* Alteracao por demanda - 175894 */
                    find current antecip_pef_pend exclusive-lock no-error.
                    assign antecip_pef_pend.cod_usuar_pagto = movto_usuar_financ.cod_usuario.
                end.

                if avail item_lote_pagto then
                    assign item_lote_pagto.cod_usuar_pagto = movto_usuar_financ.cod_usuario.
            &endif

        end.

        /* -- Atualiza valor total de pagto feito pelo usu†rio no màs e o limite do valor que ainda pode usar --*/
        if  p_ind_tip_verific = "Confirm" /*l_confirm*/  then do:
            find movto_usuar_financ exclusive-lock use-index mvtsrfnn_id
                where movto_usuar_financ.cod_usuario = p_cod_usuar_corren
                and   movto_usuar_financ.cod_estab   = p_cod_estab_bord
                and   movto_usuar_financ.dat_movto_usuar_ap = p_dat_transacao no-error.

            if  not avail movto_usuar_financ then do:
                create movto_usuar_financ.
                assign movto_usuar_financ.cod_usuario             = p_cod_usuar_corren
                       movto_usuar_financ.cod_estab               = p_cod_estab_bord
                       movto_usuar_financ.dat_movto_usuar_ap      = p_dat_transacao
                       movto_usuar_financ.val_tot_liber_pagto_mes = 0
                       movto_usuar_financ.val_tot_pagto_mes       = 0
                       movto_usuar_financ.val_tot_pagto_pend_mes  = 0.
            end.

            assign movto_usuar_financ.val_tot_pagto_mes =
                   movto_usuar_financ.val_tot_pagto_mes + p_val_finalid_econ.
            if  movto_usuar_financ.val_tot_pagto_pend_mes > 0 then
                assign movto_usuar_financ.val_tot_pagto_pend_mes = movto_usuar_financ.val_tot_pagto_pend_mes - p_val_finalid_econ.
        end.
        find current movto_usuar_financ no-lock no-error.
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verificar_abat_antecip_voucher_pagto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_num_seq_refer
        as integer
        format ">>>9"
        no-undo.
    def Input param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def Input param p_num_bord_ap
        as integer
        format ">>>>>9"
        no-undo.
    def Input param p_ind_tip_abat
        as character
        format "X(08)"
        no-undo.
    def output param p_log_abat_antecip
        as logical
        format "Sim/N∆o"
        no-undo.
    def output param p_val_tot_abat_antecip
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_val_tot_abat
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_refer
        as character
        format "x(10)":U
        label "Referància"
        column-label "Referància"
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_cod_refer = p_cod_refer.
    if  p_num_bord_ap <> 0
    and p_num_bord_ap <> ? then do:
        assign v_cod_refer = "".
    end. 

    antecipacoes:
    for
        each abat_antecip_vouch no-lock use-index abtntcpb_id
        where abat_antecip_vouch.cod_estab_refer = p_cod_estab
        and   abat_antecip_vouch.cod_refer       = v_cod_refer
        and   abat_antecip_vouch.num_seq_refer   = p_num_seq_refer
        and   abat_antecip_vouch.cod_portador    = p_cod_portador
        and   abat_antecip_vouch.num_bord_ap     = p_num_bord_ap:
        /* alteracoes sob demanda - atividade 195864*/
        assign p_log_abat_antecip     = yes
               p_val_tot_abat_antecip = p_val_tot_abat_antecip + abat_antecip_vouch.val_abtdo_antecip
               p_val_tot_abat         = p_val_tot_abat         + abat_antecip_vouch.val_abtdo_antecip_tit_abat.
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_limpa_retorno:

    return ''.
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_unid_negoc_estab_dest:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_estab_dest
        as character
        format "x(5)"
        no-undo.
    def Input param p_num_id_tit_ap
        as integer
        format "999999999"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_return_error
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ
        as character
        format "x(10)":U
        label "Finalidade EconÀmica"
        column-label "Finalidade EconÀmica"
        no-undo.
    def var v_cod_return_error
        as character
        format "x(8)":U
        no-undo.
    def var v_val_unid_negoc
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.


    /************************** Variable Definition End *************************/

    run pi_retornar_finalid_econ_corren_estab (Input p_cod_estab,
                                               output v_cod_finalid_econ) /*pi_retornar_finalid_econ_corren_estab*/.
    assign v_val_unid_negoc = 0
           p_cod_return_error = "OK" /*l_ok*/ .
    block_1:
    for
    each val_tit_ap no-lock
    where val_tit_ap.cod_estab = p_cod_estab
      and val_tit_ap.num_id_tit_ap = p_num_id_tit_ap
      and val_tit_ap.cod_finalid_econ = v_cod_finalid_econ /*cl_valida_unid_negoc of val_tit_ap*/
        break by val_tit_ap.cod_unid_negoc:
        assign v_val_unid_negoc = v_val_unid_negoc + val_tit_ap.val_sdo_tit_ap.
        if  last-of(val_tit_ap.cod_unid_negoc)
        then do:
            if  v_val_unid_negoc > 0
            then do:
                run pi_validar_unid_negoc (Input p_cod_estab_dest,
                                           Input val_tit_ap.cod_unid_negoc,
                                           Input p_dat_transacao,
                                           output v_cod_return_error) /*pi_validar_unid_negoc*/.
                if  v_cod_return_error <> ""
                then do:                


                    case v_cod_return_error:
                        when "Estabelecimento" /*l_estabelecimento*/  then 
                            assign p_cod_return_error = "8450" + "," + p_cod_estab_dest + "," + val_tit_ap.cod_unid_negoc + ",,,,,,,".
                        when "Data" /*l_data*/  then 
                            assign p_cod_return_error = "13600" + "," + val_tit_ap.cod_unid_negoc + "," + p_cod_estab_dest + "," + string(p_dat_transacao) + ",,,,,,".
                        when "Usu†rio" /*l_usuario*/  then
                            assign p_cod_return_error = "8452" + "," + val_tit_ap.cod_unid_negoc + ",,,,,,,,".
                    end.
                    return.
                end /* if */.
            end /* if */.
            assign v_val_unid_negoc = 0.
        end /* if */.
    end /* for block_1 */.




END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_unid_negoc:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
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


END PROCEDURE.

//----------------------------------------------------------------------------------------------------

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
    for each usuar_grp_usuar no-lock
        where usuar_grp_usuar.cod_usuario = v_cod_usuar_corren:
        find first segur_unid_negoc no-lock
            where segur_unid_negoc.cod_unid_negoc = p_cod_unid_negoc
              and segur_unid_negoc.cod_grp_usuar  = usuar_grp_usuar.cod_grp_usuar no-error.
        if avail segur_unid_negoc then do:
            assign p_log_return = yes.
            return.
            /* tem permiss∆o*/
        end.
    end.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_movtos_dat_transacao:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cdn_fornec_titulo
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_espec_docto
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_ser_docto
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_tit_ap
        as character
        format "x(16)"
        no-undo.
    def Input param p_cod_parcela
        as character
        format "x(02)"
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

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_ap
        for movto_tit_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_ap
        for tit_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    /* Esta procedure interna foi criada com o objetivo de validar os movimentos de Acerto 
        de Valor a Maior, e verificar se esses movimentos possuem data do movimento menor 
        que a data de transacao do lote
        bre17230.
        FO 935164 - implementar verificaá∆o para os movimentos acerto de valor a menor e 
                    transferància de unidade de neg¢cio.
    */

    find b_tit_ap no-lock
        where b_tit_ap.cod_estab       = p_cod_estab
        and   b_tit_ap.cdn_fornecedor  = p_cdn_fornec_titulo
        and   b_tit_ap.cod_espec_docto = p_cod_espec_docto
        and   b_tit_ap.cod_ser_docto   = p_cod_ser_docto
        and   b_tit_ap.cod_tit_ap      = p_cod_tit_ap
        and   b_tit_ap.cod_parcela     = p_cod_parcela
        no-error.
    if avail b_tit_ap then do:
        find first b_movto_tit_ap no-lock
            where b_movto_tit_ap.cod_estab         = b_tit_ap.cod_estab
            and   b_movto_tit_ap.num_id_tit_ap     = b_tit_ap.num_id_tit_ap
            and ( b_movto_tit_ap.ind_trans_ap      = "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/ 
               or b_movto_tit_ap.ind_trans_ap      = "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/ 
               or b_movto_tit_ap.ind_trans_ap      = "Transf Unidade Neg¢cio" /*l_transf_unidade_negocio*/ )
            and   b_movto_tit_ap.dat_transacao     > p_dat_transacao
            and   b_movto_tit_ap.log_movto_estordo = no
            no-error.
        if avail b_movto_tit_ap then
            assign p_log_erro = yes.
    end.
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_imprime_erros_cta:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_msg_cta
        as integer
        format ">>>>,>>9"
        no-undo.
    def Input param p_des_param_cta
        as character
        format "x(40)"
        no-undo.
    def Input param p_des_msg_cta
        as character
        format "x(40)"
        no-undo.
    def Input param p_ind_tipo
        as character
        format "X(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    if p_des_msg_cta <> "" then do:  
       if p_num_msg_cta = 18678 then
           run pi_messages (input "show" /*l_show*/ ,
                            input 18678,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                  p_ind_tipo,
                                  p_des_msg_cta)).
       else
           run pi_messages (input "show" /*l_show*/ ,
                            input 18681,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                  getentryfield(1,p_des_param_cta,chr(10)),
                                  getentryfield(2,p_des_param_cta,chr(10)),
                                  getentryfield(3,p_des_param_cta,chr(10)),
                                  p_des_msg_cta,
                                  p_ind_tipo)).
       return "NOK" /*l_nok*/ . 
    end.       
    return "OK" /*l_ok*/ .
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verifica_desembolso_bord_ap:

    /************************ Parameter Definition Begin ************************/

    def output param p_log_pagto_sem_desemb
        as logical
        format "Sim/N∆o"
        no-undo.
    def output param p_val_liq_item_bord
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_abat_antecip
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_log_impto_vincul_refer
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_val_tot_abat
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        label "Tot Abat"
        column-label "Tot Abat"
        no-undo.
    def var v_val_tot_abat_antecip
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_val_tot_impto
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        label "Total a Ratear"
        column-label "Valor Total a Ratear"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_pagto_sem_desemb = no.
    item_BLOCK:
    for each item_bord_ap no-lock
       where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
         and item_bord_ap.cod_portador   = bord_ap.cod_portador
         and item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap:

        if item_bord_ap.log_pagto_sem_desemb  then
            assign p_log_pagto_sem_desemb = yes.
            
        run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                     Input "",
                                                     Input item_bord_ap.num_seq_bord,
                                                     Input item_bord_ap.cod_portador,
                                                     Input item_bord_ap.num_bord_ap,
                                                     Input "Antecipaá∆o" /*l_antecipacao*/,
                                                     output v_log_abat_antecip,
                                                     output v_val_tot_abat_antecip,
                                                     output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.
                                                     
        if item_bord_ap.cod_refer_antecip_pef <> "" and
           item_bord_ap.cod_refer_antecip_pef <> ? then
            run prgfin/apb/apb794za.py (Input item_bord_ap.cod_estab,
                                        Input item_bord_ap.cod_refer_antecip_pef,
                                        Input "",
                                        Input 0,
                                        Input 0,
                                        Input yes,
                                        Input bord_ap.dat_transacao,
                                        Input "Retido" /*l_retido*/ ,
                                        output v_log_impto_vincul_refer,
                                        output v_val_tot_impto,
                                        Input recid(bord_ap),
                                        Input recid(cheq_ap),
                                        Input recid(item_lote_pagto)).
        else
            run prgfin/apb/apb794za.py (Input item_bord_ap.cod_estab_bord,
                                        Input "",
                                        Input bord_ap.cod_portador,
                                        Input bord_ap.num_bord_ap,
                                        Input item_bord_ap.num_seq_bord,
                                        Input yes,
                                        Input bord_ap.dat_transacao,
                                        Input "Retido" /*l_retido*/ ,
                                        output v_log_impto_vincul_refer,
                                        output v_val_tot_impto,
                                        Input ?,
                                        Input ?,
                                        Input ?).

        assign p_val_liq_item_bord = item_bord_ap.val_pagto
                                   + item_bord_ap.val_multa_tit_ap
                                   + item_bord_ap.val_juros
                                   + item_bord_ap.val_cm_tit_ap
                                   - item_bord_ap.val_desc_tit_ap
                                   - item_bord_ap.val_abat_tit_ap
                                   - v_val_tot_abat_antecip
                                   - v_val_tot_impto.

    end.   
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_controlar_envio_bordero_pagto:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab_bord
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def Input param p_num_bord_ap
        as integer
        format ">>>>>9"
        no-undo.
    def Input param p_ind_dwb_run_mode
        as character
        format "X(07)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_altdo                      as logical         no-undo. /*local*/
    def var v_log_erro                       as logical         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    find bord_ap no-lock
         where bord_ap.cod_estab_bord = p_cod_estab_bord
           and bord_ap.cod_portador   = p_cod_portador
           and bord_ap.num_bord_ap    = p_num_bord_ap no-error.

    /* Vari†vel da GPS */
    &if defined(bf_fin_gps) &then
        assign v_log_guia = bord_ap.log_bord_gps.
    &else
        assign v_log_guia = (entry(1,bord_ap.cod_livre_1,chr(10)) = 'yes').
    &endif

    if  not avail bord_ap then do:
        if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
            /* BorderÀ n∆o localizado ! */
            run pi_messages (input "show",
                             input 3128,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                p_num_bord_ap, p_cod_estab_bord, p_cod_portador)) /*msg_3128*/.
        end.
        else do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab     = p_cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem  = 3128
                   tt_log_erros_atualiz.tta_num_seq_refer = 0.
            run pi_messages (input "msg",
                             input 3128,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_3128*/.
            run pi_messages (input "help",
                             input 3128,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_3128*/.
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, p_num_bord_ap, p_cod_estab_bord, p_cod_portador).
        end.
    end.

    if  not can-find(first estabelecimento 
                    where estabelecimento.cod_estab   = bord_ap.cod_estab_bord
                    and   estabelecimento.cod_empresa = v_cod_empres_usuar
        )
    then do:

        create tt_log_erros_atualiz.
        assign tt_log_erros_atualiz.tta_cod_estab     = bord_ap.cod_estab_bord
               tt_log_erros_atualiz.ttv_num_mensagem  = 13846.
        run pi_messages (input "help",
                         input 13846,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_13846*/.               
        run pi_messages (input "msg",
                         input 13846,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_13846*/.        

    end /* if */.


    find first item_bord_ap no-lock
         where item_bord_ap.cod_estab_bord = p_cod_estab_bord
           and item_bord_ap.cod_portador   = p_cod_portador
           and item_bord_ap.num_bord_ap    = p_num_bord_ap no-error.
    if  not avail item_bord_ap
    then do:
        if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
            /* Bordero n∆o pode ser atualizado. */
            run pi_messages (input "show",
                             input 2904,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2904*/.
        end.
        else do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab     = p_cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem  = 2904
                   tt_log_erros_atualiz.tta_num_seq_refer = 0.
            run pi_messages (input "msg",
                             input 2904,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_2904*/.
            run pi_messages (input "help",
                             input 2904,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_2904*/.
        end.
    end /* if */.
    else do:
        if  bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/ 
        and bord_ap.log_bord_ap_escrit = yes
        then do:
            if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
                /* BorderÀ Escritural. */
                run pi_messages (input "show",
                                 input 13200,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_13200*/.
            end.
            else do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab     = p_cod_estab_bord
                       tt_log_erros_atualiz.ttv_num_mensagem  = 13200
                       tt_log_erros_atualiz.tta_num_seq_refer = 0.
                run pi_messages (input "msg",
                                 input 13200,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_13200*/.
                run pi_messages (input "help",
                                 input 13200,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_13200*/.
            end.    
        end /* if */.
        if  bord_ap.ind_sit_bord_ap <> "Ja Impresso" /*l_ja_impresso*/ 
        and bord_ap.log_bord_ap_escrit = no
        then do:
            if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
                /* Situaá∆o do BorderÀ diferente de  J† Impresso. */
                run pi_messages (input "show",
                                 input 911,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_911*/.
            end.
            else do:
                create tt_log_erros_atualiz.
                assign tt_log_erros_atualiz.tta_cod_estab     = p_cod_estab_bord
                       tt_log_erros_atualiz.ttv_num_mensagem  = 911
                       tt_log_erros_atualiz.tta_num_seq_refer = 0.
                run pi_messages (input "msg",
                                 input 911,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_911*/.
                run pi_messages (input "help",
                                 input 911,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_911*/.
            end.
        end /* if */.
        else do:
            
            if  bord_ap.val_tot_lote_pagto_efetd <> bord_ap.val_tot_lote_pagto_infor
            and bord_ap.val_tot_lote_pagto_efetd <> 0
            then do:
                if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
                    /* Total do BorderÀ n∆o Confere com Total Informado. */
                    run pi_messages (input "show",
                                     input 4356,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4356*/.
                end.
                else do:
                    create tt_log_erros_atualiz.
                    assign tt_log_erros_atualiz.tta_cod_estab     = p_cod_estab_bord
                           tt_log_erros_atualiz.ttv_num_mensagem  = 4356
                           tt_log_erros_atualiz.tta_num_seq_refer = 0.
                    run pi_messages (input "msg",
                                     input 4356,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_4356*/.
                    run pi_messages (input "help",
                                     input 4356,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_4356*/.
                end.
            end /* if */.
            else do:
                run pi_verificar_erro_bord_ap (Input p_ind_dwb_run_mode,
                                               output v_log_erro,
                                               output v_log_altdo) /*pi_verificar_erro_bord_ap*/.
               
                do  transaction:
                    find bord_ap exclusive-lock
                         where bord_ap.cod_estab_bord = p_cod_estab_bord
                           and bord_ap.cod_portador   = p_cod_portador
                           and bord_ap.num_bord_ap    = p_num_bord_ap no-error.
                    if  v_log_erro = no and v_log_altdo = no and v_log_guia = no
                    then do:
                        if  bord_ap.log_bord_ap_escrit = no
                        then do:
                            assign bord_ap.ind_sit_bord_ap = "Enviado ao Banco" /*l_enviado_ao_banco*/ .
                        end /* if */.
                        else do:
                            assign bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/ .
                        end /* else */.    
                    end /* if */.
                    else do:
                        if  not bord_ap.log_bord_ap_escrit 
                        and not v_log_erro 
                        and not v_log_guia then do:
                           if  not can-find(first item_bord_ap
                               where item_bord_ap.cod_estab_bord       = bord_ap.cod_estab_bord
                                 and item_bord_ap.cod_portador         = bord_ap.cod_portador
                                 and item_bord_ap.num_bord_ap          = bord_ap.num_bord_ap
                                 and item_bord_ap.ind_sit_item_bord_ap = "Em Aberto" /*l_em_aberto*/ ) then
                               assign bord_ap.ind_sit_bord_ap = "Totalmente Baixado" /*l_totalmente_baixado*/ .
                           else do:
                               if  can-find(first item_bord_ap
                                   where item_bord_ap.cod_estab_bord       = bord_ap.cod_estab_bord
                                     and item_bord_ap.cod_portador         = bord_ap.cod_portador
                                     and item_bord_ap.num_bord_ap          = bord_ap.num_bord_ap
                                     and item_bord_ap.ind_sit_item_bord_ap = "Baixado" /*l_baixado*/ ) then
                                   assign bord_ap.ind_sit_bord_ap = "Parcialmente Baixado" /*l_parcialmente_baixado*/ .
                           end.
                        end.
                    end.
                   
                    /* Pagamento de Tributos */
                    if v_log_pagto_trib then do:
                        find first bord_ap exclusive-lock
                         where bord_ap.cod_estab_bord = p_cod_estab_bord
                          and bord_ap.cod_portador    = p_cod_portador
                          and bord_ap.num_bord_ap     = p_num_bord_ap no-error.
                        if avail bord_ap then do:
                            if  bord_ap.log_bord_ap_escrit = no then do:                           
                                &if '{&emsfin_version}' >= '5.06' &then
                                    if bord_ap.log_bord_darf then 
                                &else 
                                    if entry(3,bord_ap.cod_livre_1,chr(10)) = 'yes' then
                                &endif
                                    assign bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/ .

                                &if defined(bf_fin_gps) &then
                                    if bord_ap.log_bord_gps = yes then
                                &else
                                    if (entry(1,bord_ap.cod_livre_1,chr(10)) = 'yes') = yes then
                                &endif
                                    assign bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/ .

                                /* Acrescentada a consistància testando bord_ap.ind_sit_bord_ap para evitar erro progress*/
                                if p_ind_dwb_run_mode = "On-Line" /*l_online*/  and bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/  then do:
                                    run pi_lista_fornecedor_titulos_gps /*pi_lista_fornecedor_titulos_gps*/.
                                    run prgfin/apb/apb339za.p (Input recid(bord_ap)) /*prg_fnc_enviar_pagto_gps*/.
                                    if return-value = "NOK" /*l_nok*/  then
                                        return "NOK" /*l_nok*/ .
                                    if bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/  
                                    or bord_ap.ind_sit_bord_ap = "Enviado ao Banco" /*l_enviado_ao_banco*/  then do:
                                        find FIRST forma_pagto no-lock
                                           where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto no-error.
                                       if avail forma_pagto and forma_pagto.ind_bxa_tit_ap = "No Envio ao Banco" /*l_no_envio_ao_banco*/  then
                                           assign bord_ap.ind_sit_bord_ap = "Totalmente Baixado" /*l_totalmente_baixado*/ .
                                    end.
                                end.
                            end.
                        end.
                    end.
                    else do:
                        /* Se for borderÀ de GPS, executa */
                        &if defined(bf_fin_gps) &then
                        if bord_ap.log_bord_gps = yes then do:
                        &else
                        if (entry(1,bord_ap.cod_livre_1,chr(10)) = 'yes') = yes then do:
                        &endif
                            if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
                                run pi_lista_fornecedor_titulos_gps /*pi_lista_fornecedor_titulos_gps*/.
                                run prgfin/apb/apb339za.p (Input recid(bord_ap)) /*prg_fnc_enviar_pagto_gps*/.
                                if bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" /*l_transmitir_ao_banco*/  then
                                    assign bord_ap.ind_sit_bord_ap = "Ja Impresso" /*l_ja_impresso*/ .                            
                            end.
                        end.
                    end.
                end.
            end /* else */.
        end /* else */.    
        if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
            run pi_disp_fields /*pi_disp_fields*/.
        end.
    end /* else */.

    // everton - revisar
    IF NOT CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:

        IF bord_ap.ind_sit_bord_ap = "Transmitir ao Banco" THEN DO:
            CREATE tt-retorno.               
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status   = 200 // 499
                   tt-retorno.desc-retorno = "Status alterado para: " + bord_ap.ind_sit_bord_ap.
        END.
        ELSE IF bord_ap.ind_sit_bord_ap = "Enviado ao Banco" THEN DO:
            CREATE tt-retorno.               
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status   = 200 // 400
                   tt-retorno.desc-retorno = "Envio realizado com sucesso. Status: " + bord_ap.ind_sit_bord_ap.
        END.

    END.
    ELSE DO:
        CREATE tt-retorno.               
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status   = 201
               tt-retorno.desc-retorno = "Erro na execuá∆o. Status: " + bord_ap.ind_sit_bord_ap.

        FOR EACH tt_log_erros_atualiz:
            CREATE tt-retorno.
            ASSIGN tt-retorno.versao-api = c-versao-api 
                   tt-retorno.cod-status   = ttv_num_mensagem
                   tt-retorno.desc-retorno = tt_log_erros_atualiz.ttv_des_msg_erro.
        END.
    END.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_sdo_cta_corren_spool_modulos:

    /* --- API para Atualizaá∆o dos Saldos das Contas Correntes SPOOL ---*/
    DO ON ERROR UNDO, RETURN ERROR:
        run prgfin/cmg/cmg709za.py (Input 1) /*prg_api_sdo_cta_corren_spool*/.
    
        if  return-value = '2782' then do:
            /* Vers∆o de integraá∆o incorreta ! */
            run pi_messages (input "show",
                             input 2782,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2782*/.
            return error.
        end.
        
        run pi_sdo_fluxo_cx_spool_modulos /*pi_sdo_fluxo_cx_spool_modulos*/.
    END.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_sdo_fluxo_cx_spool_modulos:

    /* --- API para Atualizaá∆o dos Saldos do Fluxo de Caixa SPOOL ---*/

    DO ON ERROR UNDO, RETURN ERROR:
    /* Manter esta alteraá∆o - Lista de Impacto gerada conforme alteraá∆o nos programas 
       ref. FO 1139356 */

        &if '{&emsfin_version}' >= "5.02" &then
        run prgfin/cfl/cfl704za.py (Input 1) /*prg_api_sdo_fluxo_cx_spool*/.
        &else
        run prgfin/cfl/cfl704zb.py (Input 1) /*prg_api_tab_livre_emsfin_spool_fluxo_cx*/.
        &endif

        if  return-value = '2782' then do:
            /* Vers∆o de integraá∆o incorreta ! */
            run pi_messages (input "show",
                             input 2782,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2782*/.
            return error.
        end.

    END.
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_verificar_erro_bord_ap:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_dwb_run_mode
        as character
        format "X(07)"
        no-undo.
    def output param p_log_erro
        as logical
        format "Sim/N∆o"
        no-undo.
    def output param p_log_alterado
        as logical
        format "Sim/N∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_forma_pagto
        &if DEFINED(ems5_db) &then
                for ems5.forma_pagto.
        &ELSEIF DEFINED(emscad_db) &then
                for emscad.forma_pagto.
        &ELSEIF DEFINED(ems5cad_db) &then
                for ems5cad.forma_pagto.
        &endif
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap
        for item_bord_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_lote_pagto
        for item_lote_pagto.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_forma_pagto_altern
        as character
        format "x(3)":U
        label "Forma Pagamento"
        column-label "F Pagto Alt"
        no-undo.
    def var v_ind_bxa_tit_ap
        as character
        format "X(22)":U
        view-as radio-set Vertical
        radio-buttons "No Envio ao Banco", "No Envio ao Banco", "Na Confirmaá∆o Recebto", "Na Confirmaá∆o Recebto", "Na Confirmaá∆o Pagto", "Na Confirmaá∆o Pagto"
         /*l_no_envio_ao_banco*/ /*l_no_envio_ao_banco*/ /*l_na_confirmacao_recebto*/ /*l_na_confirmacao_recebto*/ /*l_na_confirmacao_pagto*/ /*l_na_confirmacao_pagto*/
        bgcolor 8 
        label "Baixa T°tulo"
        column-label "Baixa T°tulos"
        no-undo.
    def var v_log_answer
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        no-undo.
    def var v_log_forma_pagto
        as logical
        format "Sim/N∆o"
        initial yes
        view-as toggle-box
        label "Forma de Pagto"
        no-undo.
    def var v_num_msg_erro
        as integer
        format ">>>>>>9":U
        label "Mensagem"
        column-label "Mensagem"
        no-undo.
    def var v_cod_erro                       as character       no-undo. /*local*/
    def var v_cod_forma                      as character       no-undo. /*local*/
    def var v_cod_return                     as character       no-undo. /*local*/
    def var v_log_erro_item_bord             as logical         no-undo. /*local*/
    def var v_val_lim_liber_usuar_mes        as decimal         no-undo. /*local*/
    def var v_val_lim_liber_usuar_movto      as decimal         no-undo. /*local*/
    def var v_val_lim_pagto_usuar_mes        as decimal         no-undo. /*local*/
    def var v_val_lim_pagto_usuar_movto      as decimal         no-undo. /*local*/
    def var v_val_tot_vincul_bord            as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/


    assign p_log_erro = no.
    for each tt_item_bord_ap:
        delete tt_item_bord_ap.
    end.
    for each tt_log_erros_atualiz:
        delete tt_log_erros_atualiz.
    end.    
    for each tt_erros_inform_bcia_fornec:
        delete tt_erros_inform_bcia_fornec.
    end.
    for each tt_log_erros_tit_antecip:
        delete tt_log_erros_tit_antecip.
    end.
    for each tt_integr_apb_item_bord:
        delete tt_integr_apb_item_bord.
    end.
    valida_bord:
    for each item_bord_ap no-lock
      where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
      and item_bord_ap.cod_portador = bord_ap.cod_portador
      and item_bord_ap.num_bord_ap = bord_ap.num_bord_ap
      break by item_bord_ap.cod_forma_pagto
            by item_bord_ap.cdn_fornecedor:
      if item_bord_ap.ind_sit_item_bord_ap = "Estornado" /*l_estornado*/  then next.
      find tit_ap no-lock
        where tit_ap.cod_estab       = item_bord_ap.cod_estab
        and tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
        and tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
        and tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
        and tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
        and tit_ap.cod_parcela     = item_bord_ap.cod_parcela no-error.
      assign v_val_tot_vincul_bord = 0.
      for each b_item_bord_ap no-lock
        where b_item_bord_ap.cod_estab       = tit_ap.cod_estab
        and b_item_bord_ap.cod_espec_docto = tit_ap.cod_espec_docto
        and b_item_bord_ap.cod_ser_docto   = tit_ap.cod_ser_docto 
        and b_item_bord_ap.cdn_fornecedor  = tit_ap.cdn_fornecedor
        and b_item_bord_ap.cod_tit_ap      = tit_ap.cod_tit_ap
        and b_item_bord_ap.cod_parcela     = tit_ap.cod_parcela
        and b_item_bord_ap.ind_sit_item_bord_ap <> "Estornado" /*l_estornado*/  
        and b_item_bord_ap.ind_sit_item_bord_ap <> "Baixado" /*l_baixado*/ :
        assign v_val_tot_vincul_bord = v_val_tot_vincul_bord + b_item_bord_ap.val_pagto_orig.
      end.
      for each b_item_lote_pagto no-lock
        where b_item_lote_pagto.cod_estab       = tit_ap.cod_estab
        and   b_item_lote_pagto.cod_espec_docto = tit_ap.cod_espec_docto
        and   b_item_lote_pagto.cod_ser_docto   = tit_ap.cod_ser_docto
        and   b_item_lote_pagto.cdn_fornecedor  = tit_ap.cdn_fornecedor
        and   b_item_lote_pagto.cod_tit_ap      = tit_ap.cod_tit_ap
        and   b_item_lote_pagto.cod_parcela     = tit_ap.cod_parcela
        and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Estornado" /*l_estornado*/ 
        and   b_item_lote_pagto.ind_sit_item_lote_bxa_ap <> "Baixado" /*l_baixado*/ :
        assign v_val_tot_vincul_bord = v_val_tot_vincul_bord + b_item_lote_pagto.val_pagto_orig.
      end.
      if avail tit_ap then do:
       if tit_ap.val_sdo_tit_ap - item_bord_ap.val_pagto_orig < 0 
       or v_val_tot_vincul_bord > tit_ap.val_sdo_tit_ap
       then do:
         create tt_log_erros_atualiz.
         assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                tt_log_erros_atualiz.ttv_num_mensagem = 11648
                tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
         run pi_messages (input "msg",
                          input 11648,
                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
         assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_11648*/.
         run pi_messages (input "help",
                          input 11648,
                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
         assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_11648*/.
         assign p_log_erro = yes.
         end.
      end.
      if  first-of (item_bord_ap.cod_forma_pagto) then do:
        assign v_log_forma_pagto = yes.
        find FIRST forma_pagto no-lock
            where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto no-error.
        if  not avail forma_pagto then do:
          create tt_log_erros_atualiz.
          assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                 tt_log_erros_atualiz.ttv_num_mensagem = 5253
                 tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
          run pi_messages (input "msg",
                           input 5253,
                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
          assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5253*/.
          run pi_messages (input "help",
                           input 5253,
                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5253*/.
          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,"Sequància:" /*l_sequencia:*/  + string(item_bord_ap.num_seq_bord)).
          assign v_log_forma_pagto = no p_log_erro = yes.
        end.
        if  avail forma_pagto
        and bord_ap.log_bord_ap_escrit = yes
        and forma_pagto.ind_bxa_tit_ap = "No Envio ao Banco" /*l_no_envio_ao_banco*/  then do:
          create tt_log_erros_atualiz.
          assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                 tt_log_erros_atualiz.ttv_num_mensagem = 7009
                 tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
          run pi_messages (input "msg",
                           input 7009,
                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
          assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_7009*/.
          run pi_messages (input "help",
                           input 7009,
                           input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_7009*/.
          assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,"Sequància:" /*l_sequencia:*/  + string(item_bord_ap.num_seq_bord)).
          assign v_log_forma_pagto = no p_log_erro = yes.
        end.
      end.
     
      find FIRST forma_pagto no-lock
            where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto no-error.
      if  avail forma_pagto then do:
          
        if forma_pagto.ind_bxa_tit_ap = "No Envio ao Banco" /*l_no_envio_ao_banco*/  then do:
          run pi_validar_usuar_estab_apb (Input item_bord_ap.cod_estab,
                                          Input "Confirmador" /*l_confirmador*/ ,
                                          output v_cod_return,
                                          output v_val_lim_liber_usuar_movto,
                                          output v_val_lim_liber_usuar_mes,
                                          output v_val_lim_pagto_usuar_movto,
                                          output v_val_lim_pagto_usuar_mes).
          assign v_cod_erro = "Confirmar" /*l_confirmar*/ .
        end.
        else do:
          run pi_validar_usuar_estab_apb (Input item_bord_ap.cod_estab,
                                          Input "Pagador" /*l_pagador*/ ,
                                          output v_cod_return,
                                          output v_val_lim_liber_usuar_movto,
                                          output v_val_lim_liber_usuar_mes,
                                          output v_val_lim_pagto_usuar_movto,
                                          output v_val_lim_pagto_usuar_mes).
          assign v_cod_erro = "Pagar" /*l_pagar*/ .
        end.
        case v_cod_return:
          when "no" /*l_no*/  then do:
              create tt_log_erros_atualiz.
              assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                     tt_log_erros_atualiz.ttv_num_mensagem = 701
                     tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
              run pi_messages (input "msg",
                               input 701,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_701*/.
              assign tt_log_erros_atualiz.ttv_des_msg_erro = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, v_cod_usuar_corren, v_cod_erro).
              run pi_messages (input "help",
                               input 701,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_701*/.
              assign p_log_erro = yes.
          end.
          when "602" then do:
              create tt_log_erros_atualiz.
              assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                     tt_log_erros_atualiz.ttv_num_mensagem = 602
                     tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
              run pi_messages (input "msg",
                               input 602,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_602*/.
              run pi_messages (input "help",
                               input 602,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_602*/.
              assign p_log_erro = yes.
          end.
        end.
      end.
    
      if  v_log_forma_pagto = yes then do:

        if  first-of (item_bord_ap.cdn_fornecedor) then do:

          assign v_log_erro_item_bord = no
                 v_cod_forma_pagto_altern = item_bord_ap.cod_forma_pagto
                 v_ind_bxa_tit_ap = forma_pagto.ind_bxa_tit.

          if  item_bord_ap.cod_refer_antecip_pef <> ""
          and item_bord_ap.cod_refer_antecip_pef <> ?
          then do:
            find antecip_pef_pend no-lock
                 where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                   and antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                  no-error.
            FIND FIRST fornecedor no-lock
                 where fornecedor.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
                   and fornecedor.cod_empresa = antecip_pef_pend.cod_empresa
                  no-error.
          end.
          else do:
            find fornecedor no-lock
            where fornecedor.cod_empresa    = item_bord_ap.cod_empresa
            and fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
          end /* else */.


          if  avail fornecedor
          then do:
            find fornec_financ no-lock
            where fornec_financ.cod_empresa    = fornecedor.cod_empresa
            and   fornec_financ.cdn_fornecedor = fornecedor.cdn_fornecedor no-error.
          end.

// bloco everton
          if  avail fornec_financ
          AND AVAIL forma_pagto
          then do:

            if  v_log_cta_fornec
            and item_bord_ap.cod_bco_pagto <> "" /* l_*/  then do:
                if  (forma_pagto.ind_regra_uso_forma_altern = "Banco  = Banco Fornecedor" /*l_banco___banco_fornecedor*/  
                and item_bord_ap.cod_banco = item_bord_ap.cod_bco_pagto)
                 or (forma_pagto.ind_regra_uso_forma_altern = "Banco <> Banco Fornecedor" /*l_banco__banco_fornecedor*/  
                and item_bord_ap.cod_banco <> item_bord_ap.cod_bco_pagto
                and fornec_financ.cod_banco <> "" /* l_*/ ) then
                    assign v_cod_forma_pagto_altern = forma_pagto.cod_forma_pagto_altern.   
            end.
            else do:      
                if  (forma_pagto.ind_regra_uso_forma_altern = "Banco  = Banco Fornecedor" /*l_banco___banco_fornecedor*/  
                and fornec_financ.cod_banco = item_bord_ap.cod_banco)
                 or (forma_pagto.ind_regra_uso_forma_altern = "Banco <> Banco Fornecedor" /*l_banco__banco_fornecedor*/  
                and fornec_financ.cod_banco <> item_bord_ap.cod_banco
                and fornec_financ.cod_banco <> "") then
                    assign v_cod_forma_pagto_altern = forma_pagto.cod_forma_pagto_altern.
            end.

            &if '{&emsbas_version}' > '1.00' &then
            if  v_nom_prog_upc <> '' then do:
              assign v_cod_forma_pagto_aux = v_cod_forma_pagto_altern
                     v_rec_table_epc = recid(item_bord_ap).
              run value(v_nom_prog_upc) (input 'FORMA-PGTO-ALTERNATIVA',
                                         input 'viewer',
                                         input this-procedure,
                                         input v_wgh_frame_epc,
                                         input v_nom_table_epc,
                                         input v_rec_table_epc).
              if  'no' = 'yes'
              and return-value = 'NOK' then
                  undo, retry.
              assign v_cod_forma_pagto_altern = v_cod_forma_pagto_aux.
            end.
            &endif
            
            find FIRST forma_pagto_bco NO-LOCK
              where forma_pagto_bco.cod_forma_pagto = v_cod_forma_pagto_altern
            &if '{&emsfin_version}' >= "5.02" &then
              and   forma_pagto_bco.cod_empresa = bord_ap.cod_empresa
            &endif
              
              and   forma_pagto_bco.cod_banco = item_bord_ap.cod_banco
              and   forma_pagto_bco.dat_inic_valid <= bord_ap.dat_transacao
              and   forma_pagto_bco.dat_fim_valid   > bord_ap.dat_transacao no-error.
            

//                if  not avail forma_pagto_bco
                if  NO AND not avail forma_pagto_bco
            then do:
              create tt_log_erros_atualiz.
              assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                     tt_log_erros_atualiz.ttv_num_mensagem = 5252
                     tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
              run pi_messages (input "msg",
                               input 5252,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5252*/.
              run pi_messages (input "help",
                               input 5252,
                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
              assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5252*/.
              assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, "Banco Forma Pagto")
                     tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,"Sequància:" /*l_sequencia:*/  + string(item_bord_ap.num_seq_bord), 
              "Banco Forma Pagto", "Bancos Forma Pagto", string( bord_ap.dat_transacao )).
              assign p_log_erro = yes v_log_erro_item_bord = yes.
            end.
            else do:
              if  v_cod_forma_pagto_altern <> item_bord_ap.cod_forma_pagto then do:
                FIND FIRST b_forma_pagto no-lock
                    where b_forma_pagto.cod_forma_pagto = v_cod_forma_pagto_altern no-error.

                IF AVAIL b_forma_pagto  THEN
                assign v_ind_bxa_tit_ap = b_forma_pagto.ind_bxa_tit.
              end.
            end /* else */.

            if v_ind_bxa_tit_ap <> "No Envio ao Banco" /*l_no_envio_ao_banco*/  then do:
             if fornec_financ.log_pagto_bloqdo = yes then do:
               create tt_log_erros_atualiz.
               assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                      tt_log_erros_atualiz.ttv_num_mensagem = 7838
                      tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
               run pi_messages (input "msg",
                                input 7838,
                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
               assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_7838*/.
               run pi_messages (input "help",
                                input 7838,
                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
               assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_7838*/.
               assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,string(item_bord_ap.cdn_fornecedor)).
               assign v_log_forma_pagto = no p_log_erro = YES v_log_erro_item_bord = yes.
             end.
            end.
            else do:

                /* Begin_Include: i_valida_period_ctbl */
                find sit_movimen_modul no-lock where
                     sit_movimen_modul.cod_modul_dtsul = "APB" /*l_apb*/  and
                     sit_movimen_modul.cod_unid_organ  = bord_ap.cod_empresa and
                     sit_movimen_modul.ind_sit_movimen = "Habilitado" /*l_habilitado*/  use-index stmvmnmd_id no-error.
                if  not avail sit_movimen_modul
                or bord_ap.dat_transacao < sit_movimen_modul.dat_inic_sit_movimen 
                or bord_ap.dat_transacao > sit_movimen_modul.dat_fim_sit_movimen then do:
                    create tt_log_erros_atualiz.
                    assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
                           tt_log_erros_atualiz.ttv_num_mensagem = 1628
                           tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
                    run pi_messages (input "msg",
                                     input 1628,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_1628*/.
                    run pi_messages (input "help",
                                     input 1628,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_1628*/.
                    assign tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda, bord_ap.cod_estab_bord, "APB" /*l_apb*/ , bord_ap.dat_transacao).
                    assign p_log_erro = yes v_log_erro_item_bord = yes.
                end /* if */.

                /* End_Include: i_valida_period_ctbl */

            end.
            if  avail forma_pagto and  forma_pagto.log_cta_corren_fornec_obrig = yes then do:
              &if '{&emsfin_version}' >= "5.02" &then
                  assign v_cod_forma = forma_pagto.ind_tip_forma_pagto.
              &else
                  assign v_cod_forma = entry(1,forma_pagto.cod_livre_1,chr(24)).
              &endif
              run pi_origem_documento_eec /*pi_origem_documento_eec*/.

              /* Begin_Include: i_verificar_erro_bord_ap_eec */
              if  v_ind_origin_tit_ap <> "EEC" /*l_eec*/   then do:


                  assign v_log_prog_upc     = no
                         v_log_prog_upc_aux = no.

                  if  v_nom_prog_upc <> '' then do:
                      run pi_limpa_retorno.
                      assign v_nom_table_epc = 'item_bord_ap'
                             v_rec_table_epc = recid(item_bord_ap).
                      run value(v_nom_prog_upc) (input 'Desvio Validacao',
                                                 input 'viewer',
                                                 input this-procedure,
                                                 input v_wgh_frame_epc,
                                                 input v_nom_table_epc,
                                                 input v_rec_table_epc).
                      if  return-value = 'desvio_validacao' then
                          assign v_log_prog_upc = yes.
                      if  return-value = "retorna_erro" then
                          assign v_log_prog_upc_aux = yes.
                      run pi_limpa_retorno.
                  end.

                  if  not v_log_prog_upc then do:


                      if ( v_cod_forma <> "Ordem de Pagamento" /*l_ordem_de_pagamento*/  and
                         (fornec_financ.cod_cta_corren_bco = "" or
                          fornec_financ.cod_agenc_bcia = "" or
                          fornec_financ.cod_banco = ""))
                      or ( v_cod_forma = "Ordem de Pagamento" /*l_ordem_de_pagamento*/  and
                         (fornec_financ.cod_agenc_bcia = "" or
                          fornec_financ.cod_banco = "")) 

                      or  v_log_prog_upc_aux

                      then do:               

                              create tt_log_erros_atualiz.
                              assign tt_log_erros_atualiz.tta_cod_estab = bord_ap.cod_estab_bord
                                     tt_log_erros_atualiz.ttv_num_mensagem = 14082
                                     tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
                              run pi_messages (input 'msg',
                                               input 14082,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                              assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value .
                              run pi_messages (input 'help',
                                               input 14082,
                                               input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                              assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value.
                              assign p_log_erro = yes v_log_erro_item_bord = yes.

                              find tt_erros_inform_bcia_fornec no-lock
                                  where tt_erros_inform_bcia_fornec.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                              if  not avail tt_erros_inform_bcia_fornec  then do:
                                  create tt_erros_inform_bcia_fornec.
                                  assign tt_erros_inform_bcia_fornec.cod_empresa = item_bord_ap.cod_empresa
                                          tt_erros_inform_bcia_fornec.cdn_fornecedor = item_bord_ap.cdn_fornecedor
                                          tt_erros_inform_bcia_fornec.tta_nom_abrev  = fornecedor.nom_abrev
                                          tt_erros_inform_bcia_fornec.cod_banco      = fornec_financ.cod_banco
                                          tt_erros_inform_bcia_fornec.cod_agenc_bcia = fornec_financ.cod_Agenc_bcia
                                          tt_erros_inform_bcia_fornec.cod_cta_corren_bco = fornec_financ.cod_cta_corren_bco
                                          tt_erros_inform_bcia_Fornec.cod_digito_cta_corren   = fornec_financ.cod_digito_cta_corre
                                          tt_erros_inform_bcia_Fornec.tta_ind_tip_forma_pagto = v_cod_forma.
                                  assign tt_erros_inform_bcia_fornec.tta_cod_digito_agenc_bcia = fornec_financ.cod_digito_agenc_bcia.
                              end.

                      end.

                  end.

              end.
              /* End_Include: i_verificar_erro_bord_ap_eec */

            end.
          end.
        end.
        if avail antecip_pef_pend then do:
          find first portad_finalid_econ no-lock
              where portad_finalid_econ.cod_estab    = antecip_pef_pend.cod_estab       
                and portad_finalid_econ.cod_portador = antecip_pef_pend.cod_portador    
                and portad_finalid_econ.cod_cart_bcia = antecip_pef_pend.cod_cart_bcia   
                and portad_finalid_econ.cod_finalid_econ = antecip_pef_pend.cod_finalid_econ no-error.
          if avail portad_finalid_econ
           then do:
            find first cta_corren no-lock
                where cta_corren.cod_cta_corren = portad_finalid_econ.cod_cta_corren no-error.
            if avail cta_corren
            then do:
              find first cta_corren_cta_ctbl no-lock
                  where cta_corren_cta_ctbl.cod_cta_corren = cta_corren.cod_cta_corren
                    and cta_corren_cta_ctbl.dat_inic_valid <= antecip_pef_pend.dat_emis_docto
                    and cta_corren_cta_ctbl.dat_fim_valid  >= antecip_pef_pend.dat_emis_docto no-error.
              if avail cta_corren_cta_ctbl
              then do:
                if can-find(cta_restric_unid_negoc where
                          cta_restric_unid_negoc.cod_unid_organ     = cta_corren.cod_empresa and
                          cta_restric_unid_negoc.cod_plano_cta_ctbl = cta_corren_cta_ctbl.cod_plano_cta_ctbl and
                          cta_restric_unid_negoc.cod_cta_ctbl       = cta_corren_cta_ctbl.cod_cta_ctbl and
                          cta_restric_unid_negoc.cod_unid_negoc     = cta_corren.cod_unid_negoc) then do:                                
                  create tt_log_erros_atualiz.
                  assign tt_log_erros_atualiz.tta_cod_estab = bord_ap.cod_estab_bord
                         tt_log_erros_atualiz.ttv_num_mensagem = 13287
                         tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
                  run pi_messages (input 'msg',
                                   input 13287,
                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                  assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value .
                  run pi_messages (input 'help',
                                   input 13287,
                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
                  assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value.
                  assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute('Conta Cont†bil &1 incorreta para a Unidade de Neg¢cio !', string(cta_corren_cta_ctbl.cod_cta_ctbl))
                         tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute('A Conta Cont†bil informada n∆o est† habilitada a ser utilizada na Unidade de Neg¢cio &1', string(cta_corren.cod_unid_negoc))
                         p_log_erro = yes v_log_erro_item_bord = yes.
                end.
              end.
            end.
          end.
        end.
        if  not avail fornec_financ
        AND AVAIL forma_pagto
        then do:
          if  forma_pagto.log_cta_corren_fornec_obrig = yes
          then do:
            assign p_log_erro = yes
                   v_log_erro_item_bord = yes.
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab = bord_ap.cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem = 5262
                   tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
            run pi_messages (input "msg",
                             input 5262,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5262*/.
            run pi_messages (input "help",
                             input 5262,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5262*/.
          end.
          if  forma_pagto.log_agrup_tit_fornec = yes
          then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab = bord_ap.cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem = 5412
                   tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
            run pi_messages (input "msg",
                             input 5412,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5412*/.
            run pi_messages (input "help",
                             input 5412,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5412*/.
          end.
          if  forma_pagto.log_cheq_administ = yes
          and antecip_pef_pend.nom_favorec_cheq = ""
          then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab = bord_ap.cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem = 5411
                   tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
            run pi_messages (input "msg",
                             input 5411,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5411*/.
            run pi_messages (input "help",
                             input 5411,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5411*/.
          end.
          find forma_pagto_bco no-lock
              where forma_pagto_bco.cod_forma_pagto = v_cod_forma_pagto_altern
          &if '{&emsfin_version}' >= "5.02" &then
              and   forma_pagto_bco.cod_empresa     = bord_ap.cod_empresa
          &endif
              and   forma_pagto_bco.cod_banco     = item_bord_ap.cod_banco
              and   forma_pagto_bco.dat_inic_valid <= bord_ap.dat_transacao
              and   forma_pagto_bco.dat_fim_valid > bord_ap.dat_transacao no-error.
          if  not avail forma_pagto_bco
          then do:
            create tt_log_erros_atualiz.
            assign tt_log_erros_atualiz.tta_cod_estab= bord_ap.cod_estab_bord
                   tt_log_erros_atualiz.ttv_num_mensagem = 5252
                   tt_log_erros_atualiz.tta_num_seq_refer = item_bord_ap.num_seq_bord.
            run pi_messages (input "msg",
                             input 5252,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_5252*/.
            run pi_messages (input "help",
                             input 5252,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_5252*/.
            assign tt_log_erros_atualiz.ttv_des_msg_erro  = substitute(tt_log_erros_atualiz.ttv_des_msg_erro, "Banco Forma Pagto")
                   tt_log_erros_atualiz.ttv_des_msg_ajuda = substitute(tt_log_erros_atualiz.ttv_des_msg_ajuda,"Sequància:" /*l_sequencia:*/  + string(item_bord_ap.num_seq_bord),
            "Banco Forma Pagto", "Bancos Forma Pagto", string( bord_ap.dat_transacao))
            p_log_erro = yes v_log_erro_item_bord = yes.
          end.
        end.
      end.
      if v_log_erro_item_bord = no then do:
        find b_item_bord_ap exclusive-lock
            where recid(b_item_bord_ap) = recid(item_bord_ap).
        assign item_bord_ap.cod_forma_pagto_altern = v_cod_forma_pagto_altern.
        if  p_log_erro = no then
          run pi_gravar_datas_item_bord_ap.
        if AVAIL forma_pagto AND forma_pagto.log_cta_corren_fornec_obrig = yes then do:
            run pi_tratar_epc_atualiz_inform_bcia (Input "Salvar" /*l_salvar*/) /*pi_tratar_epc_atualiz_inform_bcia*/.

            if not v_log_agrup_por_dat_trans then do:
                if v_log_cta_fornec then do:
                    if item_bord_ap.cod_bco_pagto = "" /*l_*/  then
                        assign item_bord_ap.cod_bco_pagto = fornec_financ.cod_banco
                               item_bord_ap.cod_agenc_bcia_pagto = fornec_financ.cod_agenc_bcia
                               item_bord_ap.cod_digito_agenc_bcia_pagto = fornec_financ.cod_digito_agenc_bcia
                               item_bord_ap.cod_cta_corren_bco_pagto = fornec_financ.cod_cta_corren_bco
                               item_bord_ap.cod_digito_cta_corren_pagto = fornec_financ.cod_digito_cta_corren.
                end.
                else
                    assign item_bord_ap.cod_bco_pagto = fornec_financ.cod_banco
                           item_bord_ap.cod_agenc_bcia_pagto = fornec_financ.cod_agenc_bcia
                           item_bord_ap.cod_digito_agenc_bcia_pagto = fornec_financ.cod_digito_agenc_bcia
                           item_bord_ap.cod_cta_corren_bco_pagto = fornec_financ.cod_cta_corren_bco
                           item_bord_ap.cod_digito_cta_corren_pagto = fornec_financ.cod_digito_cta_corren.
           end.

           run pi_tratar_epc_atualiz_inform_bcia (Input "Recuperar" /*l_recuperar*/) /*pi_tratar_epc_atualiz_inform_bcia*/.
        end.
        else do:
          &if '{&emsfin_version}' >= "5.02" &then
          assign item_bord_ap.cod_bco_pagto = "" item_bord_ap.cod_agenc_bcia_pagto = ""
                 item_bord_ap.cod_digito_agenc_bcia_pagto = "" item_bord_ap.cod_cta_corren_bco_pagto = ""
                 item_bord_ap.cod_digito_cta_corren_pagto = ""
          &endif.
        end.
        run pi_eec_acerta_informacoes_bancarias.
      end.
      find b_item_bord_ap no-lock
           where recid(b_item_bord_ap) = recid(item_bord_ap).
      if  p_log_erro  = no 
      and v_ind_bxa_tit_ap = "No Envio ao Banco" /*l_no_envio_ao_banco*/  
      and v_log_guia  = no then do:
          run pi_create_tt_item_bord_ap /*pi_create_tt_item_bord_ap*/.
      end.
    end /* for valida_bord */.

    /* Begin_Include: i_pi_verificar_erro_bord_ap */
    find first tt_item_bord_ap no-lock no-error.
    if  avail tt_item_bord_ap and p_log_erro = no
    then do:
        /* *  Chamada RPC **/
        for each tt_exec_rpc:
            delete tt_exec_rpc.
        end.
        create tt_exec_rpc.
        assign tt_exec_rpc.ttv_cod_aplicat_dtsul_corren = v_cod_aplicat_dtsul_corren
               tt_exec_rpc.ttv_cod_ccusto_corren        = v_cod_ccusto_corren
               tt_exec_rpc.ttv_cod_dwb_user             = v_cod_dwb_user
               tt_exec_rpc.ttv_cod_empres_usuar         = v_cod_empres_usuar
               tt_exec_rpc.ttv_cod_estab_usuar          = v_cod_estab_usuar
               tt_exec_rpc.ttv_cod_funcao_negoc_empres  = v_cod_funcao_negoc_empres
               tt_exec_rpc.ttv_cod_grp_usuar_lst        = v_cod_grp_usuar_lst
               tt_exec_rpc.ttv_cod_idiom_usuar          = v_cod_idiom_usuar
               tt_exec_rpc.ttv_cod_modul_dtsul_corren   = v_cod_modul_dtsul_corren
               tt_exec_rpc.ttv_cod_modul_dtsul_empres   = ""
               tt_exec_rpc.ttv_cod_pais_empres_usuar    = v_cod_pais_empres_usuar
               tt_exec_rpc.ttv_cod_plano_ccusto_corren  = v_cod_plano_ccusto_corren
               tt_exec_rpc.ttv_cod_unid_negoc_usuar     = v_cod_unid_negoc_usuar
               tt_exec_rpc.ttv_cod_usuar_corren         = v_cod_usuar_corren
               tt_exec_rpc.ttv_cod_usuar_corren_criptog = v_cod_usuar_corren_criptog
               tt_exec_rpc.ttv_num_ped_exec_corren      = v_num_ped_exec_corren
               tt_exec_rpc.ttv_cod_livre                = string(recid(bord_ap)) + chr(10) +
                   string(bord_ap.dat_transacao) + chr(10) + string(v_log_corrig_val).

        if  p_ind_dwb_run_mode    = "On-Line" /*l_online*/ 
        or  v_num_ped_exec_corren = 0 then do:

            /* Begin_Include: i_exec_program_rpc2 */
            &if '{&emsbas_version}' > '1.00' &then

               /* Begin_Include: i_exec_initialize_rpc */
               if  not valid-handle(v_wgh_servid_rpc)
               or v_wgh_servid_rpc:type <> 'procedure':U
               or v_wgh_servid_rpc:file-name <> 'prgtec/btb/btb008za.py':U
               then do:
                   run prgtec/btb/btb008za.py persistent set v_wgh_servid_rpc (input 1).
               end /* if */.

               run pi_connect in v_wgh_servid_rpc ("api_controlar_baixa_titulo_via_bord":U, '', no).
               /* End_Include: i_exec_initialize_rpc */

               if  rpc_exec("api_controlar_baixa_titulo_via_bord":U)
               then do:

                   /* Begin_Include: i_exec_dispatch_rpc */
                   rpc_exec_set("api_controlar_baixa_titulo_via_bord":U,yes).
                   rpc_block:
                   repeat while rpc_exec("api_controlar_baixa_titulo_via_bord":U) on stop undo rpc_block, retry rpc_block:
                       if  rpc_program("api_controlar_baixa_titulo_via_bord":U) = ?
                       then do: 
                          leave rpc_block.        
                       end /* if */.
                       if  retry
                       then do:
                           run pi_status_error in v_wgh_servid_rpc.
                           next rpc_block.
                       end /* if */.
                       if  rpc_tip_exec("api_controlar_baixa_titulo_via_bord":U)
                       then do:
                           run pi_check_server in v_wgh_servid_rpc ("api_controlar_baixa_titulo_via_bord":U).
                           if  return-value = 'yes'
                           then do:
                               if  rpc_program("api_controlar_baixa_titulo_via_bord":U) <> ?
                               then do:
                                   if  '1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc' = '""'
                                   then do:
                                       &if '""' = '""' &then
                                           run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) on rpc_server("api_controlar_baixa_titulo_via_bord":U) transaction distinct no-error.
                                       &else
                                           run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) persistent set "" on rpc_server("api_controlar_baixa_titulo_via_bord":U) transaction distinct no-error.
                                       &endif
                                   end /* if */.
                                   else do:
                                       &if '""' = '""' &then
                                           run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) on rpc_server("api_controlar_baixa_titulo_via_bord":U) transaction distinct (1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc) no-error.
                                       &else
                                           run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) persistent set "" on rpc_server("api_controlar_baixa_titulo_via_bord":U) transaction distinct (1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc) no-error.
                                       &endif
                                   end /* else */.
                               end /* if */.    
                           end /* if */.
                           else do:
                               next rpc_block.
                           end /* else */.
                       end /* if */.
                       else do:
                           if  rpc_program("api_controlar_baixa_titulo_via_bord":U) <> ?
                           then do: 
                               if  '1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc' = '""'
                               then do:
                                   &if '""' = '""' &then 
                                       run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) no-error.
                                   &else
                                       run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) persistent set "" no-error.
                                   &endif
                               end /* if */.
                               else do:
                                   &if '""' = '""' &then 
                                       run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) (1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc) no-error.
                                   &else
                                       run value(rpc_program("api_controlar_baixa_titulo_via_bord":U)) persistent set "" (1, input table tt_exec_rpc, input table tt_integr_apb_item_bord, input-output table tt_log_erros_tit_antecip, output v_num_msg_erro, input v_log_atualiz_tit_impto_vinc) no-error.
                                   &endif
                               end /* else */.
                           end /* if */.        
                       end /* else */.

                       run pi_status_error in v_wgh_servid_rpc.
                   end /* repeat rpc_block */.
                   /* End_Include: i_exec_dispatch_rpc */

               end /* if */.

               /* Begin_Include: i_exec_destroy_rpc */
               run pi_destroy_rpc in v_wgh_servid_rpc ("api_controlar_baixa_titulo_via_bord":U).

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

            run prgfin/apb/apb716zg.py (Input 1,
                                        Input table tt_exec_rpc,
                                        Input table tt_integr_apb_item_bord,
                                        input-output table tt_log_erros_tit_antecip,
                                        output v_num_msg_erro,
                                        Input v_log_atualiz_tit_impto_vinc) /*prg_api_controlar_baixa_titulo_via_bord*/.
        end.

        find first tt_log_erros_tit_antecip no-lock no-error.
        if  avail tt_log_erros_tit_antecip
        then do:
            tt_block:
            for each tt_log_erros_tit_antecip exclusive-lock
                where tt_log_erros_tit_antecip.ttv_log_atlzdo = no:
                assign tt_log_erros_tit_antecip.ttv_cod_bord_ap  = string(bord_ap.num_bord_ap)
                       tt_log_erros_tit_antecip.tta_cod_portador = bord_ap.cod_portador
                       tt_log_erros_tit_antecip.ttv_log_atlzdo   = yes.
            end /* for tt_block */.
            /*  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
                run prgfin/apb/apb715za.py (Input "BorderÀ" /*l_bordero*/) /*prg_fnc_log_erros_tit_antecip_cheq*/.
            end.*/
            assign v_num_msg_erro = 2387.
        end.
        if  v_num_msg_erro = 2387
        then do:
            assign p_log_erro = yes
                   v_log_erro_item_bord = yes.
        end.
        else do:
            assign p_log_alterado = yes.
        end /* else */.
    end /* if */.
    else do:
        assign p_log_alterado = no.
    end /* else */.
    if  p_ind_dwb_run_mode = "On-Line" /*l_online*/  then do:
      find first tt_erros_inform_bcia_fornec no-lock no-error.
      if  avail tt_erros_inform_bcia_fornec
      then do:
          /*
        run pi_messages (input "show",
                         input 5237,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign v_log_answer = (if   return-value = "yes" then YES //daniele - verificar tratativa por parametro
                               else if return-value = "no" then no
                               else ?) /*msg_5237*/.*/
        assign v_log_answer = YES.
        if  v_log_answer = yes
        then do:
          incl_block:
          do on error undo incl_block, return error:
            run prgfin/apb/apb710zu.p (Input '') /*prg_fnc_fornec_financ_inc_rpda*/.
          end.
        end.
      end.
    end.
    else do:
      for each tt_log_erros_tit_antecip no-lock:
        create tt_log_erros_atualiz.
        assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
               tt_log_erros_atualiz.ttv_num_mensagem = 0
               tt_log_erros_atualiz.tta_num_seq_refer = tt_log_erros_tit_antecip.tta_num_seq_refer
               tt_log_erros_atualiz.ttv_des_msg_erro  = tt_log_erros_tit_antecip.ttv_des_msg_erro_1
               tt_log_erros_atualiz.ttv_des_msg_ajuda = "Estab." /*l_estab*/    + ' ' + tt_log_erros_tit_antecip.tta_cod_estab               + ', ' + 
               "Espec" /*l_espec*/    + ' ' + tt_log_erros_tit_antecip.tta_cod_espec_docto         + ', ' +
               "Fornec" /*l_fornec*/   + ' ' + string(tt_log_erros_tit_antecip.tta_cdn_fornecedor)  + ', ' +
               "T°tulo" /*l_titulo*/   + ' ' + tt_log_erros_tit_antecip.tta_cod_tit_ap              + ', ' +
               "Parcela" /*l_parcela*/  + ' ' + tt_log_erros_tit_antecip.tta_cod_parcela.                                                        
        assign p_log_erro = yes.
      end.
      for each tt_erros_inform_bcia_fornec no-lock:
        create tt_log_erros_atualiz.
        assign tt_log_erros_atualiz.tta_cod_estab    = bord_ap.cod_estab_bord
               tt_log_erros_atualiz.ttv_num_mensagem = 963
               tt_log_erros_atualiz.tta_num_seq_refer = 0.
        run pi_messages (input "msg",
                         input 963,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_erro = return-value /*msg_963*/.
        run pi_messages (input "help",
                         input 963,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = return-value /*msg_963*/.
        assign tt_log_erros_atualiz.ttv_des_msg_ajuda = tt_log_erros_atualiz.ttv_des_msg_ajuda + chr(10) 
               + '            Fornecedor: ' + string (tt_erros_inform_bcia_fornec.cdn_fornecedor).
        assign p_log_erro = yes.
      end.
    end.
    if  p_log_erro = yes
    then do:
      run pi_atualiza_envio_ao_banco /*pi_atualiza_envio_ao_banco*/.
      if  p_ind_dwb_run_mode = "On-Line" /*l_online*/ 
      and can-find(first tt_log_erros_atualiz) then do:
        run prgint/ufn/ufn901za.py (Input 1) /*prg_api_mostra_log_erros*/.
        for each tt_log_erros_atualiz:
            delete tt_log_erros_atualiz.
        end.
      end.
    end.
    else do:
      &if defined(bf_fin_gps) &then
      if bord_ap.log_bord_gps = no then
      &else
      if (entry(1,bord_ap.cod_livre_1,chr(10)) = 'yes') = no then 
      &endif run pi_atualiza_envio_ao_banco /*pi_atualiza_envio_ao_banco*/.
    end /* else */.
    /* End_Include: i_exec_destroy_rpc */

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_usuar_estab_apb:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_ind_tip_usuar
        as character
        format "X(08)"
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.
    def output param p_val_lim_liber_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_val_lim_liber_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_val_lim_pagto_usuar_movto
        as decimal
        format "->>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def output param p_val_lim_pagto_usuar_mes
        as decimal
        format "->>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_seq
        as integer
        format ">>>,>>9":U
        label "Seq±ància"
        column-label "Seq"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_cod_return = "".
    find usuar_financ_estab_apb no-lock
         where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
           and usuar_financ_estab_apb.cod_estab = p_cod_estab /*cl_validar_usuar_financ_estab_apb of usuar_financ_estab_apb*/ no-error.

    if  avail usuar_financ_estab_apb
    then do:
        assign p_val_lim_liber_usuar_movto = usuar_financ_estab_apb.val_lim_liber_usuar_movto
               p_val_lim_liber_usuar_mes   = usuar_financ_estab_apb.val_lim_liber_usuar_mes
               p_val_lim_pagto_usuar_movto = usuar_financ_estab_apb.val_lim_pagto_usuar_movto
               p_val_lim_pagto_usuar_mes   = usuar_financ_estab_apb.val_lim_pagto_usuar_mes.

        teste_usuar:
        do v_num_seq = 1 to num-entries(p_ind_tip_usuar):
            if  v_num_seq <> 1
            then do:
                assign p_cod_return = p_cod_return + ",".
            end /* if */.

            /* case_block: */
            case entry(v_num_seq, p_ind_tip_usuar):
                when "Implantador" /*l_implantador*/ then
                    if  usuar_financ_estab_apb.log_habilit_impl_tit_ap = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.

                when "Preparador" /*l_preparador*/ then
                    if  usuar_financ_estab_apb.log_habilit_prepar_tit_ap = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.

                when "Liberador" /*l_liberador*/ then
                    if  usuar_financ_estab_apb.log_habilit_liber_tit_ap = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.

                when "Pagador" /*l_pagador*/ then
                    if  usuar_financ_estab_apb.log_habilit_pagto_tit_ap = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.

                when "Confirmador" /*l_confirmador*/ then
                    if  usuar_financ_estab_apb.log_habilit_confir_tit_ap = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.

                when "Impressor" /*l_impressor*/ then
                    if  usuar_financ_estab_apb.log_habilit_impr_docto = no
                    then do:
                        assign p_cod_return = p_cod_return + "no" /*l_no*/ .
                    end /* if */.
                    else do:
                        assign p_cod_return = p_cod_return + "yes" /*l_yes*/ .
                    end /* else */.
                when "Encontro de Contas" /*l_encontro_de_contas*/ then
                    if  usuar_financ_estab_apb.log_habilit_enctro_cta = no
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
        assign p_cod_return = "602".
    end /* else */.

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_origem_documento_eec:


    assign v_ind_origin_tit_ap = "". 
    if  item_bord_ap.cod_refer_antecip_pef = ""
    or  item_bord_ap.cod_refer_antecip_pef = ?  then do:
        if  can-find(tit_ap
            where tit_ap.cod_estab         = item_bord_ap.cod_estab
            and   tit_ap.cdn_fornecedor    = item_bord_ap.cdn_fornecedor
            and   tit_ap.cod_espec_docto   = item_bord_ap.cod_espec_docto            
            and   tit_ap.cod_ser_docto     = item_bord_ap.cod_ser_docto
            and   tit_ap.cod_tit_ap        = item_bord_ap.cod_tit_ap
            and   tit_ap.cod_parcela       = item_bord_ap.cod_parcela
            and   tit_ap.ind_origin_tit_ap = "EEC" /*l_eec*/ ) then
        assign v_ind_origin_tit_ap = "EEC" /*l_eec*/ .
    end.
    else do:
        &IF '{&emsfin_version}' >= "5.04" &THEN   
            if can-find(antecip_pef_pend
                where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                and   antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                and   antecip_pef_pend.ind_origin_tit_ap = "EEC" /*l_eec*/  ) then
                assign v_ind_origin_tit_ap = "EEC" /*l_eec*/  .
       &ENDIF
    end. 

    RETURN "OK" /*l_ok*/ .
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_tratar_epc_atualiz_inform_bcia:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_event
        as character
        format "X(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then do:
        run value(v_nom_prog_upc) (input p_ind_event,
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input forma_pagto.cod_forma_pagto,
                                   input recid(item_bord_ap)).
        if  return-value = 'NOK' then
            return 'NOK'.
    end.

    if  v_nom_prog_appc <> '' then do:
        run value(v_nom_prog_appc) (input p_ind_event,
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input forma_pagto.cod_forma_pagto,
                                    input recid(item_bord_ap)).
        if  return-value = 'NOK' then
            return 'NOK'.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then do:
        run value(v_nom_prog_dpc) (input p_ind_event,
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input forma_pagto.cod_forma_pagto,
                                   input recid(item_bord_ap)).
        if  return-value = 'NOK' then
            return 'NOK'.
    end.
    &endif
    &endif



END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_eec_acerta_informacoes_bancarias:

    &IF '{&emsfin_version}' >= "5.04" &THEN
        if  item_bord_ap.cod_refer_antecip_pef <> ""
        and item_bord_ap.cod_refer_antecip_pef <> ?
        then do:
            if  not avail antecip_pef_pend then
                find antecip_pef_pend
                     where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                     and   antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                     no-lock no-error.
            if  antecip_pef_pend.ind_origin_tit_ap = "EEC" /*l_eec*/  then do:
                for first adiant_prestac_cta_eec
                    FIELDS(adiant_prestac_cta_eec.cod_estab
                           adiant_prestac_cta_eec.cod_refer
                           adiant_prestac_cta_eec.cod_banco
                           adiant_prestac_cta_eec.cod_agenc_bcia                  
                           &IF '{&emsfin_version}' >= "5.06" &THEN   
                               adiant_prestac_cta_eec.cod_digito_agenc_bcia
                           &ELSE
                               adiant_prestac_cta_eec.cod_livre_1
                           &ENDIF
                           adiant_prestac_cta_eec.cod_cta_corren_bco
                           adiant_prestac_cta_eec.cod_digito_cta_corren
                           adiant_prestac_cta_eec.ind_adiant_depos_espec)
                    where  adiant_prestac_cta_eec.cod_estab              = item_bord_ap.cod_estab
                    and    adiant_prestac_cta_eec.cod_refer              = item_bord_ap.cod_refer_antecip_pef
                    and    adiant_prestac_cta_eec.ind_adiant_depos_espec = "Dep¢sito" /*l_deposito*/ 
                    no-lock:
                end.
                if  avail adiant_prestac_cta_eec then
                    assign item_bord_ap.cod_bco_pagto         = adiant_prestac_cta_eec.cod_banco
                           item_bord_ap.cod_agenc_bcia_pagto = adiant_prestac_cta_eec.cod_agenc_bcia
                           &IF '{&emsfin_version}' >= "5.06" &THEN   
                               item_bord_ap.cod_digito_agenc_bcia_pagto = adiant_prestac_cta_eec.cod_digito_agenc_bcia
                           &ELSE
                               item_bord_ap.cod_digito_agenc_bcia_pagto = adiant_prestac_cta_eec.cod_livre_1
                           &ENDIF
                           item_bord_ap.cod_cta_corren_bco_pagto        = adiant_prestac_cta_eec.cod_cta_corren_bco
                           item_bord_ap.cod_digito_cta_corren_pagto = adiant_prestac_cta_eec.cod_digito_cta_corren.
            end.
        end.
        else do:
            if  not avail tit_ap then
                find first tit_ap
                     where tit_ap.cod_estab       = item_bord_ap.cod_estab
                     and   tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
                     and   tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
                     and   tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
                     and   tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
                     and   tit_ap.cod_parcela     = item_bord_ap.cod_parcela
                     no-lock no-error.
            if  tit_ap.ind_origin_tit_ap = "EEC" /*l_eec*/  then do:
                for first acerto_cta_eec
                    FIELDS(acerto_cta_eec.cod_estab
                           acerto_cta_eec.cod_refer
                           acerto_cta_eec.cod_banco
                           acerto_cta_eec.cod_agenc_bcia                  
                           &IF '{&emsfin_version}' >= "5.06" &THEN   
                               acerto_cta_eec.cod_digito_agenc_bcia
                           &ELSE
                               acerto_cta_eec.cod_livre_1
                           &ENDIF
                           acerto_cta_eec.cod_cta_corren_bco
                           acerto_cta_eec.cod_digito_cta_corren                           
                           acerto_cta_eec.cod_estab
                           acerto_cta_eec.num_id_tit_ap)
                    where acerto_cta_eec.cod_estab     = tit_ap.cod_estab
                    and   acerto_cta_eec.num_id_tit_ap = tit_ap.num_id_tit_ap
                    no-lock :
                end.
                if  avail acerto_cta_eec then 
                    assign item_bord_ap.cod_bco_pagto         = acerto_cta_eec.cod_banco
                           item_bord_ap.cod_agenc_bcia_pagto  = acerto_cta_eec.cod_agenc_bcia
                           &IF '{&emsfin_version}' >= "5.06" &THEN   
                                item_bord_ap.cod_digito_agenc_bcia_pagto = acerto_cta_eec.cod_digito_agenc_bcia
                           &ELSE
                                item_bord_ap.cod_digito_agenc_bcia_pagto  = acerto_cta_eec.cod_livre_1
                           &ENDIF
                           item_bord_ap.cod_cta_corren_bco_pagto        = acerto_cta_eec.cod_cta_corren_bco
                           item_bord_ap.cod_digito_cta_corren_pagto = acerto_cta_eec.cod_digito_cta_corren.
            end.
        end.
    &ENDIF    
    RETURN "OK" /*l_ok*/ .

END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_atualiza_envio_ao_banco:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_antecip_pef_pend
        for antecip_pef_pend.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_compl_movto_pagto
        for compl_movto_pagto.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap
        for item_bord_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_agenc_bcia
        as character
        format "x(10)":U
        label "Agància Banc†ria"
        column-label "Agància Banc†ria"
        no-undo.
    def var v_cod_cta_corren
        as character
        format "x(10)":U
        label "Conta Corrente"
        column-label "Conta Corrente"
        no-undo.
    def var v_cod_estab_cheq
        as character
        format "x(5)":U
        no-undo.
    def var v_log_abat_antecip
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.
    def var v_nom_pessoa
        as character
        format "x(40)":U
        label "Nome"
        column-label "Nome"
        no-undo.
    def var v_num_id_agrup_item_bord_ap
        as integer
        format ">>>>>>>>>9":U
        label "Id Agrup IBA"
        column-label "Id Agrup IBA"
        no-undo.
    def var v_num_id_cheq_ap
        as integer
        format "9999999999":U
        label "Token cheq_ap"
        column-label "Token cheq_ap"
        no-undo.
    def var v_num_seq_cheq_ap
        as integer
        format ">9":U
        label "Seq"
        column-label "Seq"
        no-undo.
    def var v_val_tot_abat
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        label "Tot Abat"
        column-label "Tot Abat"
        no-undo.
    def var v_val_tot_abat_antecip
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.
    def var v_num_cont                       as integer         no-undo. /*local*/
    def var v_val_liq_item_bord              as decimal         no-undo. /*local*/
    def var v_val_total                      as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_val_total = 0
           v_num_cont  = 0
           v_num_id_agrup_item_bord_ap = 0.

    for each tt_item_bord_ap_favorec:
        delete tt_item_bord_ap_favorec.
    end.

    cria_item:
    for each  item_bord_ap no-lock use-index itmbrdp_id
        where item_bord_ap.cod_estab_bord  = bord_ap.cod_estab_bord
          and item_bord_ap.cod_portador    = bord_ap.cod_portador
          and item_bord_ap.num_bord_ap     = bord_ap.num_bord_ap  :  

        find first tit_ap
             where tit_ap.cod_estab = item_bord_ap.cod_estab
             and   tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
             and   tit_ap.cod_ser_docto = item_bord_ap.cod_ser_docto
             and   tit_ap.cdn_fornecedor = item_bord_ap.cdn_fornecedor
             and   tit_ap.cod_tit_ap = item_bord_ap.cod_tit_ap
             and   tit_ap.cod_parcela = item_bord_ap.cod_parcela no-error.
        if avail tit_ap then do:
           &if '{&emsfin_version}' >= "5.02" &then
               if tit_ap.cb4_tit_ap_bco_cobdor <> "" then
                  next cria_item.
           &endif
        end.

          create tt_item_bord_ap_favorec.
          assign tt_item_bord_ap_favorec.tta_cod_estab_bord = item_bord_ap.cod_estab_bord
                 tt_item_bord_ap_favorec.tta_cod_portador   = item_bord_ap.cod_portador
                 tt_item_bord_ap_favorec.tta_num_bord_ap    = item_bord_ap.num_bord_ap
                 tt_item_bord_ap_favorec.tta_num_seq_bord   = item_bord_ap.num_seq_bord
                 tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern = item_bord_ap.cod_forma_pagto_altern
                 tt_item_bord_ap_favorec.tta_dat_vencto     = item_bord_ap.dat_vencto.

          &if '{&emsfin_version}' >= '5.04' &then
              assign tt_item_bord_ap_favorec.tta_dat_pagto = item_bord_ap.dat_pagto_tit_ap.
          &endif
          &if '{&emsfin_version}' < '5.04' &then
              assign tt_item_bord_ap_favorec.tta_dat_pagto = item_bord_ap.dat_vencto.
          &endif

          /* especifico para oesp - utilizado funcao especial pois nao foi possivel fazer via epc - gilmar 15/03/03 */       
          if v_log_agrup_por_dat_trans then do:
             assign tt_item_bord_ap_favorec.tta_dat_vencto               = bord_ap.dat_transacao
                    tt_item_bord_ap_favorec.tta_dat_pagto                = bord_ap.dat_transacao.
             &if '{&emsfin_version}' >= "5.02" &then
                 assign tt_item_bord_ap_favorec.tta_cod_bco_pagto            = item_bord_ap.cod_bco_pagto
                        tt_item_bord_ap_favorec.tta_cod_agenc_bcia_pagto     = item_bord_ap.cod_agenc_bcia_pagto
                        tt_item_bord_ap_favorec.tta_cod_cta_corren_bco_pagto = item_bord_ap.cod_cta_corren_bco_pagto.
             &endif
          end.
          find FIRST forma_pagto 
               where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto_altern 
               no-lock no-error.       

          find FIRST fornecedor no-lock
              where fornecedor.cod_empresa    = item_bord_ap.cod_empresa    and
                    fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.

          if avail fornecedor then
             assign v_nom_pessoa = fornecedor.nom_abrev.
          else
             assign v_nom_pessoa = "".

          if  avail forma_pagto
          and forma_pagto.log_cheq_administ = yes
          and v_log_favorec_cheq_adm        = yes then do:
              &if '{&emsfin_version}' >= '5.05' &then
                  assign tt_item_bord_ap_favorec.ttv_ind_favorec_cheq = item_bord_ap.ind_favorec_cheq    
                         tt_item_bord_ap_favorec.ttv_nom_favorec_cheq = item_bord_ap.nom_favorec_cheq.
              &else
                  assign tt_item_bord_ap_favorec.ttv_ind_favorec_cheq = entry(1,item_bord_ap.cod_livre_1,chr(10))   
                         tt_item_bord_ap_favorec.ttv_nom_favorec_cheq = entry(2,item_bord_ap.cod_livre_1,chr(10)).             
              &endif
          end.
          else do:
             assign tt_item_bord_ap_favorec.ttv_nom_favorec_cheq = if avail fornecedor then string(fornecedor.cdn_fornecedor) + v_nom_pessoa
                                                                   else v_nom_pessoa
                    tt_item_bord_ap_favorec.ttv_ind_favorec_cheq = "Fornecedor" /*l_fornecedor*/ .
          end. 

          run pi_exec_program_epc_FIN (input 'troca_de_favorecido',
                                       input "no" /*l_no*/ ,
                                       output v_log_return_epc) /* pi_exec_program_epc_FIN*/.                                           

    end /* for cria_item */.     

    /* especifico para oesp - fo 878654 - utilizado funcao especial pois nao foi possivel fazer via epc - gilmar 15/03/03 */       
    if  v_log_agrup_por_dat_trans then do:
        valida_bord:
        for each tt_item_bord_ap_favorec no-lock use-index tt_favorecido
            break by tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern
                  by tt_item_bord_ap_favorec.tta_cod_bco_pagto
                  by tt_item_bord_ap_favorec.tta_cod_agenc_bcia_pagto
                  by tt_item_bord_ap_favorec.tta_cod_cta_corren_bco_pagto
                  by tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                  by tt_item_bord_ap_favorec.tta_dat_vencto
                  by tt_item_bord_ap_favorec.tta_dat_pagto:

            /* Begin_Include: i_for_each_tt_item_bord_ap_favorec */
            if  first-of(tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern) then do:
                 find FIRST forma_pagto  NO-LOCK
                    where forma_pagto.cod_forma_pagto = tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern no-error.
            end.

            find first item_bord_ap 
                 where item_bord_ap.cod_estab_bord     = tt_item_bord_ap_favorec.tta_cod_estab_bord  
                 and   item_bord_ap.cod_portador       = tt_item_bord_ap_favorec.tta_cod_portador   
                 and   item_bord_ap.num_bord_ap        = tt_item_bord_ap_favorec.tta_num_bord_ap
                 and   item_bord_ap.num_seq_bord       = tt_item_bord_ap_favorec.tta_num_seq_bord  
                 exclusive-lock no-error.
            if not avail item_bord_ap or item_bord_ap.ind_sit_item_bord_ap = "Estornado" /*l_estornado*/  then next.

            assign v_des_text_histor = "".

            if  avail forma_pagto
            and (forma_pagto.log_agrup_tit_fornec = yes
            or  forma_pagto.log_cheq_administ    = yes)
            then do:

                if  first-of(tt_item_bord_ap_favorec.ttv_nom_favorec_cheq)
                or  item_bord_ap.cdn_fornecedor = 0 then do:

                    if  item_bord_ap.cdn_fornecedor = 0
                    then do:
                        find antecip_pef_pend no-lock
                             where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                               and antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                              no-error.
                        if  avail antecip_pef_pend
                        then do:
                            if  antecip_pef_pend.cdn_fornecedor > 0
                            then do:
                                find fornecedor no-lock
                                     where fornecedor.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
                                       and fornecedor.cod_empresa = antecip_pef_pend.cod_empresa
                                      no-error.
                                if  avail fornecedor
                                then do:
                                    find fornec_financ no-lock
                                       where fornec_financ.cod_empresa    = fornecedor.cod_empresa    and
                                             fornec_financ.cdn_fornecedor = fornecedor.cdn_fornecedor no-error.
                                    if  avail fornec_financ
                                    then do:
                                        assign v_nom_pessoa      = fornecedor.nom_pessoa
                                               v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                                               v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                                    end /* if */.
                                end /* if */.
                            end /* if */.
                            else do:
                                assign v_nom_pessoa      = antecip_pef_pend.nom_favorec
                                       v_cod_agenc_bcia  = ""
                                       v_cod_cta_corren  = "".
                            end /* else */.
                        end /* if */.
                    end /* if */.
                    else do:
                        find fornecedor no-lock
                            where fornecedor.cod_empresa    = item_bord_ap.cod_empresa    and
                                  fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                        find fornec_financ no-lock
                             where fornec_financ.cod_empresa    = item_bord_ap.cod_empresa    and
                                   fornec_financ.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                        assign v_nom_pessoa      = tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                                                   /* fornecedor.nom_pessoa */
                               v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                               v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                    end /* else */.           
                end.              
                if  first-of(tt_item_bord_ap_favorec.tta_dat_vencto)
                or  first-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                or  item_bord_ap.cdn_fornecedor = 0
                or  forma_pagto.log_agrup_tit_fornec = no then do:
                    if  forma_pagto.log_cheq_administ = yes
                    then do:
                        run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                 Input bord_ap.cod_cart_bcia,
                                                 Input item_bord_ap.cod_estab_bord,
                                                 Input bord_ap.cod_indic_econ,
                                                 Input bord_ap.dat_transacao,
                                                 Input v_nom_pessoa,
                                                 Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                 Input 0,
                                                 Input 0,
                                                 Input 0,
                                                 Input /* Zero para Iniciar Valor */                                       0,
                                                 Input v_des_text_histor,
                                                 output v_cod_estab_cheq,
                                                 output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                        assign v_num_seq_cheq_ap = 1.
                    end /* if */.
                    if  forma_pagto.log_agrup_tit_fornec = yes
                    and v_num_count >= 2
                    then do:
                        create item_bord_ap_agrup.
                        assign item_bord_ap_agrup.cod_estab_bord             = item_bord_ap.cod_estab_bord
                               item_bord_ap_agrup.num_id_agrup_item_bord_ap  = next-value(seq_item_bord_ap_agrup)
                               item_bord_ap_agrup.cod_banco                  = item_bord_ap.cod_banco
                               item_bord_ap_agrup.cod_agenc_bcia             = v_cod_agenc_bcia
                               item_bord_ap_agrup.cod_cta_corren             = v_cod_cta_corren
                               item_bord_ap_agrup.nom_favorec_cheq           = v_nom_pessoa
                               item_bord_ap_agrup.cod_forma_pagto            = item_bord_ap.cod_forma_pagto_altern
                               item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total
                               item_bord_ap_agrup.cod_estab_cheq             = v_cod_estab_cheq
                               item_bord_ap_agrup.num_id_cheq_ap             = v_num_id_cheq_ap
                               item_bord_ap_agrup.dat_vencto_agrup_bord_ap   = item_bord_ap.dat_vencto.

                        /* especifico para oesp - utilizado funcao especial pois nao foi possivel fazer via epc - gilmar 15/03/03 */       
                        if v_log_agrup_por_dat_trans then
                           assign item_bord_ap_agrup.dat_vencto_agrup_bord_ap = tt_item_bord_ap_favorec.tta_dat_vencto.           
                    end /* if */.           
                end.
                run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                             Input " ",
                                                             Input item_bord_ap.num_seq_bord,
                                                             Input item_bord_ap.cod_portador,
                                                             Input item_bord_ap.num_bord_ap,
                                                             Input "Antecipaá∆o" /*l_antecipacao*/,
                                                             output v_log_abat_antecip,
                                                             output v_val_tot_abat_antecip,
                                                             output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.

                assign v_val_liq_item_bord = item_bord_ap.val_pagto        +
                                             item_bord_ap.val_multa_tit_ap +
                                             item_bord_ap.val_juros        -
                                             item_bord_ap.val_desc_tit_ap  -
                                             item_bord_ap.val_abat_tit_ap  -
                                             v_val_tot_abat.

                if  forma_pagto.log_agrup_tit_fornec = yes
                and v_num_count >= 2
                then do:
                    assign v_val_total = v_val_total + v_val_liq_item_bord
                           item_bord_ap.num_id_agrup_item_bord_ap = item_bord_ap_agrup.num_id_agrup_item_bord_ap
                           v_num_id_agrup_item_bord_ap            = item_bord_ap_agrup.num_id_agrup_item_bord_ap.
                end /* if */.
                else do:
                    assign v_val_total = v_val_liq_item_bord.
                end /* else */.

                find compl_movto_pagto exclusive-lock where
                     compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord and
                     compl_movto_pagto.cod_portador    = item_bord_ap.cod_portador   and
                     compl_movto_pagto.num_bord_ap     = item_bord_ap.num_bord_ap    and
                     compl_movto_pagto.num_seq_bord    = item_bord_ap.num_seq_bord   no-error.
                /* Cr°ticas do Sistema - Agrup e Id do Cheque para controle de busca */
                if  avail compl_movto_pagto
                then do:
                    if forma_pagto.log_agrup_tit_fornec = yes then
                       assign compl_movto_pagto.num_id_agrup_item_bord_ap = v_num_id_agrup_item_bord_ap.

                    if forma_pagto.log_cheq_administ = yes then
                       assign compl_movto_pagto.cod_estab_cheq            = v_cod_estab_cheq
                              compl_movto_pagto.num_id_cheq_ap            = v_num_id_cheq_ap
                              compl_movto_pagto.num_seq_item_cheq         = v_num_seq_cheq_ap.
                end /* if */.

                if  forma_pagto.log_cheq_administ = yes
                then do:
                    create item_cheq_ap.
                    assign item_cheq_ap.cod_empresa           = v_cod_empres_usuar
                           item_cheq_ap.cod_refer             = string(bord_ap.num_bord_ap)
                           item_cheq_ap.cod_estab_refer       = item_bord_ap.cod_estab_bord
                           item_cheq_ap.cod_estab_cheq        = v_cod_estab_cheq
                           item_cheq_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                           item_cheq_ap.cod_estab             = item_bord_ap.cod_estab
                           item_cheq_ap.cod_espec_docto       = item_bord_ap.cod_espec_docto
                           item_cheq_ap.cdn_fornecedor        = item_bord_ap.cdn_fornecedor
                           item_cheq_ap.cod_ser_docto         = item_bord_ap.cod_ser_docto
                           item_cheq_ap.cod_tit_ap            = item_bord_ap.cod_tit_ap
                           item_cheq_ap.cod_parcela           = item_bord_ap.cod_parcela
                           item_cheq_ap.cod_refer_antecip_pef = item_bord_ap.cod_refer_antecip_pef
                           item_cheq_ap.ind_tip_refer         = "Baixa" /*l_baixa*/  
                           item_cheq_ap.cod_usuario           = v_cod_usuar_corren
                           item_cheq_ap.cod_usuar_pagto       = v_cod_usuar_corren
                           item_cheq_ap.val_pagto             = item_bord_ap.val_pagto
                           item_cheq_ap.log_cheq_cancdo       = no
                           item_cheq_ap.des_text_histor       = item_bord_ap.des_text_histor
                           item_cheq_ap.num_seq_refer         = item_bord_ap.num_seq_bord
                           item_cheq_ap.num_seq_item_cheq     = v_num_seq_cheq_ap
                           item_bord_ap.cod_estab_cheq        = v_cod_estab_cheq
                           item_bord_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                           item_bord_ap.num_seq_item_cheq     = v_num_seq_cheq_ap.

                    assign v_num_seq_cheq_ap = v_num_seq_cheq_ap + 1.
                    if  item_bord_ap.cod_refer_antecip_pef <> ""
                    and item_bord_ap.cod_refer_antecip_pef <> ?
                    then do:
                        find   b_antecip_pef_pend no-lock
                         where b_antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                           and b_antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                               no-error.
                        assign item_cheq_ap.ind_tip_refer = b_antecip_pef_pend.ind_tip_refer.
                        if  item_cheq_ap.ind_tip_refer          = "Antecipaá∆o" /*l_antecipacao*/ 
                        then do:
                            assign item_cheq_ap.cod_ser_docto   = b_antecip_pef_pend.cod_ser_docto
                                   item_cheq_ap.cod_tit_ap      = b_antecip_pef_pend.cod_tit_ap
                                   item_cheq_ap.cod_parcela     = b_antecip_pef_pend.cod_parcela
                                   item_cheq_ap.cod_espec_docto = b_antecip_pef_pend.cod_espec_docto.
                        end /* if */.
                    end /* if */.
                end /* if */.
                if  last-of(tt_item_bord_ap_favorec.tta_dat_vencto)
                or  last-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                or  item_bord_ap.cdn_fornecedor = 0
                or  forma_pagto.log_agrup_tit_fornec = no then do:
                    if  forma_pagto.log_cheq_administ = yes
                    then do:                              
                        run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                 Input bord_ap.cod_cart_bcia,
                                                 Input item_bord_ap.cod_estab_bord,
                                                 Input bord_ap.cod_indic_econ,
                                                 Input bord_ap.dat_transacao,
                                                 Input v_nom_pessoa,
                                                 Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                 Input 0,
                                                 Input 0,
                                                 Input v_val_total,
                                                 Input recid(cheq_ap),
                                                 Input v_des_text_histor,
                                                 output v_cod_estab_cheq,
                                                 output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                        assign cheq_ap.log_cheq_administ         = yes
                               cheq_ap.log_impres_cheq_sist      = no
                               cheq_ap.ind_sit_cheq_administ     = "Gerado" /*l_gerado*/ 
                               cheq_ap.log_bord_ap_escrit        = bord_ap.log_bord_ap_escrit
                               cheq_ap.ind_localiz_cheq_administ = forma_pagto.ind_localiz_cheq_administ
                               cheq_ap.cod_estab_bord            = item_bord_ap.cod_estab_bord.
                    end /* if */.
                    else do:
                        if v_num_count >= 2 then
                            assign item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total.
                    end /* else */.
                    assign v_val_total                 = 0
                           v_num_id_agrup_item_bord_ap = 0.
                end.
                if  forma_pagto.log_cheq_administ = yes
                then do:
                    for each compl_movto_pagto no-lock
                        where compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord
                        and   compl_movto_pagto.cod_portador = item_bord_ap.cod_portador
                        and   compl_movto_pagto.num_bord_ap = item_bord_ap.num_bord_ap
                        and   compl_movto_pagto.num_seq_bord = item_bord_ap.num_seq_bord:
                        find movto_tit_ap exclusive-lock
                            where movto_tit_ap.cod_estab = compl_movto_pagto.cod_estab
                            and movto_tit_ap.num_id_movto_tit_ap = compl_movto_pagto.num_id_movto_tit_ap
                            and movto_tit_ap.log_movto_estordo = no no-error.
                        if avail movto_tit_ap then do:
                            find b_tit_ap_bxa no-lock
                                where b_tit_ap_bxa.cod_estab = movto_tit_ap.cod_estab
                                and   b_tit_ap_bxa.num_id_tit_ap = movto_tit_ap.num_id_tit_ap no-error.
                            if avail tit_ap then
                                assign item_cheq_ap.cod_parcela           = b_tit_ap_bxa.cod_parcela
                                       item_cheq_ap.num_id_movto_tit_ap   = movto_tit_ap.num_id_movto_tit_ap
                                    &if "{&emsfin_version}" /*l_{&emsfin_version}*/  > '5.01' &then
                                       item_cheq_ap.log_item_cheq_atlzdo  = yes
                                    &endif
                                       item_cheq_ap.cod_estab             = b_tit_ap_bxa.cod_estab
                                       cheq_ap.dat_confir_cheq_ap         = movto_tit_ap.dat_transacao
                                       cheq_ap.log_cheq_confdo            = yes.
                            leave.
                        end.
                    end.
                    release item_cheq_ap.
                end.
            end /* if */.
            /* End_Include: i_for_each_tt_item_bord_ap_favorec */

        end /* for valida_bord */.
    end.
    else do:
        if v_log_dat_pagto_bord = yes then do:
            valida_bord:
            for each tt_item_bord_ap_favorec no-lock use-index tt_favorecido
                break by tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern
                      by tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                      by tt_item_bord_ap_favorec.tta_dat_pagto:

                /* Begin_Include: i_for_each_tt_item_bord_ap_favorec_2 */
                if  first-of(tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern) then do:
                    find FIRST forma_pagto  NO-LOCK
                        where forma_pagto.cod_forma_pagto = tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern no-error.
                end.

                find first item_bord_ap 
                     where item_bord_ap.cod_estab_bord     = tt_item_bord_ap_favorec.tta_cod_estab_bord  
                     and   item_bord_ap.cod_portador       = tt_item_bord_ap_favorec.tta_cod_portador   
                     and   item_bord_ap.num_bord_ap        = tt_item_bord_ap_favorec.tta_num_bord_ap
                     and   item_bord_ap.num_seq_bord       = tt_item_bord_ap_favorec.tta_num_seq_bord  
                     exclusive-lock no-error.
                if not avail item_bord_ap or item_bord_ap.ind_sit_item_bord_ap = "Estornado" /*l_estornado*/  then next.

                assign v_des_text_histor = "".

                if  avail forma_pagto
                and (forma_pagto.log_agrup_tit_fornec = yes
                or  forma_pagto.log_cheq_administ    = yes)
                then do:

                    if  first-of(tt_item_bord_ap_favorec.ttv_nom_favorec_cheq)
                    or  item_bord_ap.cdn_fornecedor = 0 then do:

                        if  item_bord_ap.cdn_fornecedor = 0
                        then do:
                            find antecip_pef_pend no-lock
                                 where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                                   and antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                                  no-error.
                            if  avail antecip_pef_pend
                            then do:
                                if  antecip_pef_pend.cdn_fornecedor > 0
                                then do:
                                    find fornecedor no-lock
                                         where fornecedor.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
                                           and fornecedor.cod_empresa = antecip_pef_pend.cod_empresa
                                          no-error.
                                    if  avail fornecedor
                                    then do:
                                        find fornec_financ no-lock
                                           where fornec_financ.cod_empresa    = fornecedor.cod_empresa    and
                                                 fornec_financ.cdn_fornecedor = fornecedor.cdn_fornecedor no-error.
                                        if  avail fornec_financ
                                        then do:
                                            assign v_nom_pessoa      = fornecedor.nom_pessoa
                                                   v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                                                   v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                                        end /* if */.
                                    end /* if */.
                                end /* if */.
                                else do:
                                    assign v_nom_pessoa      = antecip_pef_pend.nom_favorec
                                           v_cod_agenc_bcia  = ""
                                           v_cod_cta_corren  = "".
                                end /* else */.
                            end /* if */.
                        end /* if */.
                        else do:
                            find fornecedor no-lock
                                where fornecedor.cod_empresa    = item_bord_ap.cod_empresa    and
                                      fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                            find fornec_financ no-lock
                                 where fornec_financ.cod_empresa    = item_bord_ap.cod_empresa    and
                                       fornec_financ.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                            assign v_nom_pessoa      = tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                                                       /* fornecedor.nom_pessoa */
                                   v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                                   v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                        end /* else */.           
                    end.
                    if  first-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                    or  item_bord_ap.cdn_fornecedor = 0
                    or  forma_pagto.log_agrup_tit_fornec = no then do:        
                        if  forma_pagto.log_cheq_administ = yes
                        then do:
                            run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                     Input bord_ap.cod_cart_bcia,
                                                     Input item_bord_ap.cod_estab_bord,
                                                     Input bord_ap.cod_indic_econ,
                                                     Input bord_ap.dat_transacao,
                                                     Input v_nom_pessoa,
                                                     Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                     Input 0,
                                                     Input 0,
                                                     Input 0,
                                                     Input /* Zero para Iniciar Valor */                                       0,
                                                     Input v_des_text_histor,
                                                     output v_cod_estab_cheq,
                                                     output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                            assign v_num_seq_cheq_ap = 1.
                        end /* if */.
                        if  forma_pagto.log_agrup_tit_fornec = yes
                        and v_num_count >= 2
                        then do:
                            create item_bord_ap_agrup.
                            assign item_bord_ap_agrup.cod_estab_bord             = item_bord_ap.cod_estab_bord
                                   item_bord_ap_agrup.num_id_agrup_item_bord_ap  = next-value(seq_item_bord_ap_agrup)
                                   item_bord_ap_agrup.cod_banco                  = item_bord_ap.cod_banco
                                   item_bord_ap_agrup.cod_agenc_bcia             = v_cod_agenc_bcia
                                   item_bord_ap_agrup.cod_cta_corren             = v_cod_cta_corren
                                   item_bord_ap_agrup.nom_favorec_cheq           = v_nom_pessoa
                                   item_bord_ap_agrup.cod_forma_pagto            = item_bord_ap.cod_forma_pagto_altern
                                   item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total
                                   item_bord_ap_agrup.cod_estab_cheq             = v_cod_estab_cheq
                                   item_bord_ap_agrup.num_id_cheq_ap             = v_num_id_cheq_ap
                                   item_bord_ap_agrup.dat_vencto_agrup_bord_ap   = item_bord_ap.dat_vencto.

                            /* especifico para oesp - utilizado funcao especial pois nao foi possivel fazer via epc - gilmar 15/03/03 */       
                            if v_log_agrup_por_dat_trans then
                               assign item_bord_ap_agrup.dat_vencto_agrup_bord_ap = tt_item_bord_ap_favorec.tta_dat_vencto.           
                        end /* if */.           
                    end.
                    run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                                 Input " ",
                                                                 Input item_bord_ap.num_seq_bord,
                                                                 Input item_bord_ap.cod_portador,
                                                                 Input item_bord_ap.num_bord_ap,
                                                                 Input "Antecipaá∆o" /*l_antecipacao*/,
                                                                 output v_log_abat_antecip,
                                                                 output v_val_tot_abat_antecip,
                                                                 output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.

                    assign v_val_liq_item_bord = item_bord_ap.val_pagto        +
                                                 item_bord_ap.val_multa_tit_ap +
                                                 item_bord_ap.val_juros        -
                                                 item_bord_ap.val_desc_tit_ap  -
                                                 item_bord_ap.val_abat_tit_ap  -
                                                 v_val_tot_abat.

                    if  forma_pagto.log_agrup_tit_fornec = yes
                    and v_num_count >= 2
                    then do:
                        assign v_val_total = v_val_total + v_val_liq_item_bord
                               item_bord_ap.num_id_agrup_item_bord_ap = item_bord_ap_agrup.num_id_agrup_item_bord_ap
                               v_num_id_agrup_item_bord_ap            = item_bord_ap_agrup.num_id_agrup_item_bord_ap.
                    end /* if */.
                    else do:
                        assign v_val_total = v_val_liq_item_bord.
                    end /* else */.

                    find compl_movto_pagto exclusive-lock where
                         compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord and
                         compl_movto_pagto.cod_portador    = item_bord_ap.cod_portador   and
                         compl_movto_pagto.num_bord_ap     = item_bord_ap.num_bord_ap    and
                         compl_movto_pagto.num_seq_bord    = item_bord_ap.num_seq_bord   no-error.
                    /* Cr°ticas do Sistema - Agrup e Id do Cheque para controle de busca */
                    if  avail compl_movto_pagto
                    then do:
                        if forma_pagto.log_agrup_tit_fornec = yes then
                           assign compl_movto_pagto.num_id_agrup_item_bord_ap = v_num_id_agrup_item_bord_ap.

                        if forma_pagto.log_cheq_administ = yes then
                           assign compl_movto_pagto.cod_estab_cheq            = v_cod_estab_cheq
                                  compl_movto_pagto.num_id_cheq_ap            = v_num_id_cheq_ap
                                  compl_movto_pagto.num_seq_item_cheq         = v_num_seq_cheq_ap.
                    end /* if */.

                    if  forma_pagto.log_cheq_administ = yes
                    then do:
                        create item_cheq_ap.
                        assign item_cheq_ap.cod_empresa           = v_cod_empres_usuar
                               item_cheq_ap.cod_refer             = string(bord_ap.num_bord_ap)
                               item_cheq_ap.cod_estab_refer       = item_bord_ap.cod_estab_bord
                               item_cheq_ap.cod_estab_cheq        = v_cod_estab_cheq
                               item_cheq_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                               item_cheq_ap.cod_estab             = item_bord_ap.cod_estab
                               item_cheq_ap.cod_espec_docto       = item_bord_ap.cod_espec_docto
                               item_cheq_ap.cdn_fornecedor        = item_bord_ap.cdn_fornecedor
                               item_cheq_ap.cod_ser_docto         = item_bord_ap.cod_ser_docto
                               item_cheq_ap.cod_tit_ap            = item_bord_ap.cod_tit_ap
                               item_cheq_ap.cod_parcela           = item_bord_ap.cod_parcela
                               item_cheq_ap.cod_refer_antecip_pef = item_bord_ap.cod_refer_antecip_pef
                               item_cheq_ap.ind_tip_refer         = "Baixa" /*l_baixa*/  
                               item_cheq_ap.cod_usuario           = v_cod_usuar_corren
                               item_cheq_ap.cod_usuar_pagto       = v_cod_usuar_corren
                               item_cheq_ap.val_pagto             = item_bord_ap.val_pagto
                               item_cheq_ap.log_cheq_cancdo       = no
                               item_cheq_ap.des_text_histor       = item_bord_ap.des_text_histor
                               item_cheq_ap.num_seq_refer         = item_bord_ap.num_seq_bord
                               item_cheq_ap.num_seq_item_cheq     = v_num_seq_cheq_ap
                               item_bord_ap.cod_estab_cheq        = v_cod_estab_cheq
                               item_bord_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                               item_bord_ap.num_seq_item_cheq     = v_num_seq_cheq_ap.

                        assign v_num_seq_cheq_ap = v_num_seq_cheq_ap + 1.
                        if  item_bord_ap.cod_refer_antecip_pef <> ""
                        and item_bord_ap.cod_refer_antecip_pef <> ?
                        then do:
                            find   b_antecip_pef_pend no-lock
                             where b_antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                               and b_antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                                   no-error.
                            assign item_cheq_ap.ind_tip_refer = b_antecip_pef_pend.ind_tip_refer.
                            if  item_cheq_ap.ind_tip_refer          = "Antecipaá∆o" /*l_antecipacao*/ 
                            then do:
                                assign item_cheq_ap.cod_ser_docto   = b_antecip_pef_pend.cod_ser_docto
                                       item_cheq_ap.cod_tit_ap      = b_antecip_pef_pend.cod_tit_ap
                                       item_cheq_ap.cod_parcela     = b_antecip_pef_pend.cod_parcela
                                       item_cheq_ap.cod_espec_docto = b_antecip_pef_pend.cod_espec_docto.
                            end /* if */.
                        end /* if */.
                    end /* if */.
                    if  last-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                    or  item_bord_ap.cdn_fornecedor = 0
                    or  forma_pagto.log_agrup_tit_fornec = no then do:

                    if  forma_pagto.log_cheq_administ = yes
                    then do:                              
                        run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                 Input bord_ap.cod_cart_bcia,
                                                 Input item_bord_ap.cod_estab_bord,
                                                 Input bord_ap.cod_indic_econ,
                                                 Input bord_ap.dat_transacao,
                                                 Input v_nom_pessoa,
                                                 Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                 Input 0,
                                                 Input 0,
                                                 Input v_val_total,
                                                 Input recid(cheq_ap),
                                                 Input v_des_text_histor,
                                                 output v_cod_estab_cheq,
                                                 output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                        assign cheq_ap.log_cheq_administ         = yes
                               cheq_ap.log_impres_cheq_sist      = no
                               cheq_ap.ind_sit_cheq_administ     = "Gerado" /*l_gerado*/ 
                               cheq_ap.log_bord_ap_escrit        = bord_ap.log_bord_ap_escrit
                               cheq_ap.ind_localiz_cheq_administ = forma_pagto.ind_localiz_cheq_administ
                               cheq_ap.cod_estab_bord            = item_bord_ap.cod_estab_bord.
                    end /* if */.
                    else do:
                        if v_num_count >= 2 then
                            assign item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total.
                    end /* else */.
                    assign v_val_total                 = 0
                           v_num_id_agrup_item_bord_ap = 0.
                end.
                if  forma_pagto.log_cheq_administ = yes
                then do:
                    for each compl_movto_pagto no-lock
                        where compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord
                        and   compl_movto_pagto.cod_portador = item_bord_ap.cod_portador
                        and   compl_movto_pagto.num_bord_ap = item_bord_ap.num_bord_ap
                        and   compl_movto_pagto.num_seq_bord = item_bord_ap.num_seq_bord:
                        find movto_tit_ap exclusive-lock
                            where movto_tit_ap.cod_estab = compl_movto_pagto.cod_estab
                            and movto_tit_ap.num_id_movto_tit_ap = compl_movto_pagto.num_id_movto_tit_ap
                            and movto_tit_ap.log_movto_estordo = no no-error.
                        if avail movto_tit_ap then do:
                            find b_tit_ap_bxa no-lock
                                where b_tit_ap_bxa.cod_estab = movto_tit_ap.cod_estab
                                and   b_tit_ap_bxa.num_id_tit_ap = movto_tit_ap.num_id_tit_ap no-error.
                            if avail tit_ap then
                                assign item_cheq_ap.cod_parcela           = b_tit_ap_bxa.cod_parcela
                                       item_cheq_ap.num_id_movto_tit_ap   = movto_tit_ap.num_id_movto_tit_ap
                                    &if "{&emsfin_version}" /*l_{&emsfin_version}*/  > '5.01' &then
                                       item_cheq_ap.log_item_cheq_atlzdo  = yes
                                    &endif
                                       item_cheq_ap.cod_estab             = b_tit_ap_bxa.cod_estab
                                       cheq_ap.dat_confir_cheq_ap         = movto_tit_ap.dat_transacao
                                       cheq_ap.log_cheq_confdo            = yes.
                                leave.
                            end.
                        end.
                        release item_cheq_ap.
                    end.
                end /* if */.
                /* End_Include: i_for_each_tt_item_bord_ap_favorec_2 */

            end /* for valida_bord */.
        end.          
        else do:
            valida_bord:
            for each tt_item_bord_ap_favorec no-lock use-index tt_favorecido
                break by tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern
                      by tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                      by tt_item_bord_ap_favorec.tta_dat_vencto
                      by tt_item_bord_ap_favorec.tta_dat_pagto:

                /* Begin_Include: i_for_each_tt_item_bord_ap_favorec */
                if  first-of(tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern) then do:
                    find FIRST forma_pagto  NO-LOCK
                        where forma_pagto.cod_forma_pagto = tt_item_bord_ap_favorec.tta_cod_forma_pagto_altern no-error.
                end.

                find first item_bord_ap 
                     where item_bord_ap.cod_estab_bord     = tt_item_bord_ap_favorec.tta_cod_estab_bord  
                     and   item_bord_ap.cod_portador       = tt_item_bord_ap_favorec.tta_cod_portador   
                     and   item_bord_ap.num_bord_ap        = tt_item_bord_ap_favorec.tta_num_bord_ap
                     and   item_bord_ap.num_seq_bord       = tt_item_bord_ap_favorec.tta_num_seq_bord  
                     exclusive-lock no-error.
                if not avail item_bord_ap or item_bord_ap.ind_sit_item_bord_ap = "Estornado" /*l_estornado*/  then next.

                assign v_des_text_histor = "".

                if  avail forma_pagto
                and (forma_pagto.log_agrup_tit_fornec = yes
                or  forma_pagto.log_cheq_administ    = yes)
                then do:

                    if  first-of(tt_item_bord_ap_favorec.ttv_nom_favorec_cheq)
                    or  item_bord_ap.cdn_fornecedor = 0 then do:

                        if  item_bord_ap.cdn_fornecedor = 0
                        then do:
                            find antecip_pef_pend no-lock
                                 where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                                   and antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                                  no-error.
                            if  avail antecip_pef_pend
                            then do:
                                if  antecip_pef_pend.cdn_fornecedor > 0
                                then do:
                                    find fornecedor no-lock
                                         where fornecedor.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
                                           and fornecedor.cod_empresa = antecip_pef_pend.cod_empresa
                                          no-error.
                                    if  avail fornecedor
                                    then do:
                                        find fornec_financ no-lock
                                           where fornec_financ.cod_empresa    = fornecedor.cod_empresa    and
                                                 fornec_financ.cdn_fornecedor = fornecedor.cdn_fornecedor no-error.
                                        if  avail fornec_financ
                                        then do:
                                            assign v_nom_pessoa      = fornecedor.nom_pessoa
                                                   v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                                                   v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                                        end /* if */.
                                    end /* if */.
                                end /* if */.
                                else do:
                                    assign v_nom_pessoa      = antecip_pef_pend.nom_favorec
                                           v_cod_agenc_bcia  = ""
                                           v_cod_cta_corren  = "".
                                end /* else */.
                            end /* if */.
                        end /* if */.
                        else do:
                            find fornecedor no-lock
                                where fornecedor.cod_empresa    = item_bord_ap.cod_empresa    and
                                      fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                            find fornec_financ no-lock
                                 where fornec_financ.cod_empresa    = item_bord_ap.cod_empresa    and
                                       fornec_financ.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
                            assign v_nom_pessoa      = tt_item_bord_ap_favorec.ttv_nom_favorec_cheq
                                                       /* fornecedor.nom_pessoa */
                                   v_cod_cta_corren  = fornec_financ.cod_cta_corren_bco
                                   v_cod_agenc_bcia  = fornec_financ.cod_agenc_bcia.
                        end /* else */.           
                    end.              
                    if  first-of(tt_item_bord_ap_favorec.tta_dat_vencto)
                    or  first-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                    or  item_bord_ap.cdn_fornecedor = 0
                    or  forma_pagto.log_agrup_tit_fornec = no then do:
                        if  forma_pagto.log_cheq_administ = yes
                        then do:
                            run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                     Input bord_ap.cod_cart_bcia,
                                                     Input item_bord_ap.cod_estab_bord,
                                                     Input bord_ap.cod_indic_econ,
                                                     Input bord_ap.dat_transacao,
                                                     Input v_nom_pessoa,
                                                     Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                     Input 0,
                                                     Input 0,
                                                     Input 0,
                                                     Input /* Zero para Iniciar Valor */                                       0,
                                                     Input v_des_text_histor,
                                                     output v_cod_estab_cheq,
                                                     output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                            assign v_num_seq_cheq_ap = 1.
                        end /* if */.
                        if  forma_pagto.log_agrup_tit_fornec = yes
                        and v_num_count >= 2
                        then do:
                            create item_bord_ap_agrup.
                            assign item_bord_ap_agrup.cod_estab_bord             = item_bord_ap.cod_estab_bord
                                   item_bord_ap_agrup.num_id_agrup_item_bord_ap  = next-value(seq_item_bord_ap_agrup)
                                   item_bord_ap_agrup.cod_banco                  = item_bord_ap.cod_banco
                                   item_bord_ap_agrup.cod_agenc_bcia             = v_cod_agenc_bcia
                                   item_bord_ap_agrup.cod_cta_corren             = v_cod_cta_corren
                                   item_bord_ap_agrup.nom_favorec_cheq           = v_nom_pessoa
                                   item_bord_ap_agrup.cod_forma_pagto            = item_bord_ap.cod_forma_pagto_altern
                                   item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total
                                   item_bord_ap_agrup.cod_estab_cheq             = v_cod_estab_cheq
                                   item_bord_ap_agrup.num_id_cheq_ap             = v_num_id_cheq_ap
                                   item_bord_ap_agrup.dat_vencto_agrup_bord_ap   = item_bord_ap.dat_vencto.

                            /* especifico para oesp - utilizado funcao especial pois nao foi possivel fazer via epc - gilmar 15/03/03 */       
                            if v_log_agrup_por_dat_trans then
                               assign item_bord_ap_agrup.dat_vencto_agrup_bord_ap = tt_item_bord_ap_favorec.tta_dat_vencto.           
                        end /* if */.           
                    end.
                    run pi_verificar_abat_antecip_voucher_pagto (Input item_bord_ap.cod_estab_bord,
                                                                 Input " ",
                                                                 Input item_bord_ap.num_seq_bord,
                                                                 Input item_bord_ap.cod_portador,
                                                                 Input item_bord_ap.num_bord_ap,
                                                                 Input "Antecipaá∆o" /*l_antecipacao*/,
                                                                 output v_log_abat_antecip,
                                                                 output v_val_tot_abat_antecip,
                                                                 output v_val_tot_abat) /*pi_verificar_abat_antecip_voucher_pagto*/.

                    assign v_val_liq_item_bord = item_bord_ap.val_pagto        +
                                                 item_bord_ap.val_multa_tit_ap +
                                                 item_bord_ap.val_juros        -
                                                 item_bord_ap.val_desc_tit_ap  -
                                                 item_bord_ap.val_abat_tit_ap  -
                                                 v_val_tot_abat.

                    if  forma_pagto.log_agrup_tit_fornec = yes
                    and v_num_count >= 2
                    then do:
                        assign v_val_total = v_val_total + v_val_liq_item_bord
                               item_bord_ap.num_id_agrup_item_bord_ap = item_bord_ap_agrup.num_id_agrup_item_bord_ap
                               v_num_id_agrup_item_bord_ap            = item_bord_ap_agrup.num_id_agrup_item_bord_ap.
                    end /* if */.
                    else do:
                        assign v_val_total = v_val_liq_item_bord.
                    end /* else */.

                    find compl_movto_pagto exclusive-lock where
                         compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord and
                         compl_movto_pagto.cod_portador    = item_bord_ap.cod_portador   and
                         compl_movto_pagto.num_bord_ap     = item_bord_ap.num_bord_ap    and
                         compl_movto_pagto.num_seq_bord    = item_bord_ap.num_seq_bord   no-error.
                    /* Cr°ticas do Sistema - Agrup e Id do Cheque para controle de busca */
                    if  avail compl_movto_pagto
                    then do:
                        if forma_pagto.log_agrup_tit_fornec = yes then
                           assign compl_movto_pagto.num_id_agrup_item_bord_ap = v_num_id_agrup_item_bord_ap.

                        if forma_pagto.log_cheq_administ = yes then
                           assign compl_movto_pagto.cod_estab_cheq            = v_cod_estab_cheq
                                  compl_movto_pagto.num_id_cheq_ap            = v_num_id_cheq_ap
                                  compl_movto_pagto.num_seq_item_cheq         = v_num_seq_cheq_ap.
                    end /* if */.

                    if  forma_pagto.log_cheq_administ = yes
                    then do:
                        create item_cheq_ap.
                        assign item_cheq_ap.cod_empresa           = v_cod_empres_usuar
                               item_cheq_ap.cod_refer             = string(bord_ap.num_bord_ap)
                               item_cheq_ap.cod_estab_refer       = item_bord_ap.cod_estab_bord
                               item_cheq_ap.cod_estab_cheq        = v_cod_estab_cheq
                               item_cheq_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                               item_cheq_ap.cod_estab             = item_bord_ap.cod_estab
                               item_cheq_ap.cod_espec_docto       = item_bord_ap.cod_espec_docto
                               item_cheq_ap.cdn_fornecedor        = item_bord_ap.cdn_fornecedor
                               item_cheq_ap.cod_ser_docto         = item_bord_ap.cod_ser_docto
                               item_cheq_ap.cod_tit_ap            = item_bord_ap.cod_tit_ap
                               item_cheq_ap.cod_parcela           = item_bord_ap.cod_parcela
                               item_cheq_ap.cod_refer_antecip_pef = item_bord_ap.cod_refer_antecip_pef
                               item_cheq_ap.ind_tip_refer         = "Baixa" /*l_baixa*/  
                               item_cheq_ap.cod_usuario           = v_cod_usuar_corren
                               item_cheq_ap.cod_usuar_pagto       = v_cod_usuar_corren
                               item_cheq_ap.val_pagto             = item_bord_ap.val_pagto
                               item_cheq_ap.log_cheq_cancdo       = no
                               item_cheq_ap.des_text_histor       = item_bord_ap.des_text_histor
                               item_cheq_ap.num_seq_refer         = item_bord_ap.num_seq_bord
                               item_cheq_ap.num_seq_item_cheq     = v_num_seq_cheq_ap
                               item_bord_ap.cod_estab_cheq        = v_cod_estab_cheq
                               item_bord_ap.num_id_cheq_ap        = v_num_id_cheq_ap
                               item_bord_ap.num_seq_item_cheq     = v_num_seq_cheq_ap.

                        assign v_num_seq_cheq_ap = v_num_seq_cheq_ap + 1.
                        if  item_bord_ap.cod_refer_antecip_pef <> ""
                        and item_bord_ap.cod_refer_antecip_pef <> ?
                        then do:
                            find   b_antecip_pef_pend no-lock
                             where b_antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
                               and b_antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef
                                   no-error.
                            assign item_cheq_ap.ind_tip_refer = b_antecip_pef_pend.ind_tip_refer.
                            if  item_cheq_ap.ind_tip_refer          = "Antecipaá∆o" /*l_antecipacao*/ 
                            then do:
                                assign item_cheq_ap.cod_ser_docto   = b_antecip_pef_pend.cod_ser_docto
                                       item_cheq_ap.cod_tit_ap      = b_antecip_pef_pend.cod_tit_ap
                                       item_cheq_ap.cod_parcela     = b_antecip_pef_pend.cod_parcela
                                       item_cheq_ap.cod_espec_docto = b_antecip_pef_pend.cod_espec_docto.
                            end /* if */.
                        end /* if */.
                    end /* if */.
                    if  last-of(tt_item_bord_ap_favorec.tta_dat_vencto)
                    or  last-of(tt_item_bord_ap_favorec.tta_dat_pagto)
                    or  item_bord_ap.cdn_fornecedor = 0
                    or  forma_pagto.log_agrup_tit_fornec = no then do:
                        if  forma_pagto.log_cheq_administ = yes
                        then do:                              
                            run pi_gerar_cheque_apb (Input bord_ap.cod_portador,
                                                     Input bord_ap.cod_cart_bcia,
                                                     Input item_bord_ap.cod_estab_bord,
                                                     Input bord_ap.cod_indic_econ,
                                                     Input bord_ap.dat_transacao,
                                                     Input v_nom_pessoa,
                                                     Input tt_item_bord_ap_favorec.ttv_ind_favorec_cheq,
                                                     Input 0,
                                                     Input 0,
                                                     Input v_val_total,
                                                     Input recid(cheq_ap),
                                                     Input v_des_text_histor,
                                                     output v_cod_estab_cheq,
                                                     output v_num_id_cheq_ap) /*pi_gerar_cheque_apb*/. 

                            assign cheq_ap.log_cheq_administ         = yes
                                   cheq_ap.log_impres_cheq_sist      = no
                                   cheq_ap.ind_sit_cheq_administ     = "Gerado" /*l_gerado*/ 
                                   cheq_ap.log_bord_ap_escrit        = bord_ap.log_bord_ap_escrit
                                   cheq_ap.ind_localiz_cheq_administ = forma_pagto.ind_localiz_cheq_administ
                                   cheq_ap.cod_estab_bord            = item_bord_ap.cod_estab_bord.
                        end /* if */.
                        else do:
                            if v_num_count >= 2 then
                                assign item_bord_ap_agrup.val_tot_agrup_item_bord_ap = v_val_total.
                        end /* else */.
                        assign v_val_total                 = 0
                               v_num_id_agrup_item_bord_ap = 0.
                    end.
                    if  forma_pagto.log_cheq_administ = yes
                    then do:
                        for each compl_movto_pagto no-lock
                            where compl_movto_pagto.cod_estab_pagto = item_bord_ap.cod_estab_bord
                            and   compl_movto_pagto.cod_portador = item_bord_ap.cod_portador
                            and   compl_movto_pagto.num_bord_ap = item_bord_ap.num_bord_ap
                            and   compl_movto_pagto.num_seq_bord = item_bord_ap.num_seq_bord:
                            find movto_tit_ap exclusive-lock
                                where movto_tit_ap.cod_estab = compl_movto_pagto.cod_estab
                                and movto_tit_ap.num_id_movto_tit_ap = compl_movto_pagto.num_id_movto_tit_ap
                                and movto_tit_ap.log_movto_estordo = no no-error.
                            if avail movto_tit_ap then do:
                                find b_tit_ap_bxa no-lock
                                    where b_tit_ap_bxa.cod_estab = movto_tit_ap.cod_estab
                                    and   b_tit_ap_bxa.num_id_tit_ap = movto_tit_ap.num_id_tit_ap no-error.
                                if avail tit_ap then
                                    assign item_cheq_ap.cod_parcela           = b_tit_ap_bxa.cod_parcela
                                           item_cheq_ap.num_id_movto_tit_ap   = movto_tit_ap.num_id_movto_tit_ap
                                        &if "{&emsfin_version}" /*l_{&emsfin_version}*/  > '5.01' &then
                                           item_cheq_ap.log_item_cheq_atlzdo  = yes
                                        &endif
                                           item_cheq_ap.cod_estab             = b_tit_ap_bxa.cod_estab
                                           cheq_ap.dat_confir_cheq_ap         = movto_tit_ap.dat_transacao
                                           cheq_ap.log_cheq_confdo            = yes.
                                leave.
                            end.
                        end.
                        release item_cheq_ap.
                    end.
                end /* if */.
                /* End_Include: i_for_each_tt_item_bord_ap_favorec */

            end /* for valida_bord */. 
        end.           
    end.    

    if v_log_funcao_val_max_tip_pagto then do:
        run pi_retornar_finalid_econ_corren_estab (Input bord_ap.cod_estab_bord,
                                                   output v_cod_finalid_econ) . 
        if  bord_ap.dat_transacao <> ? then do:
            run pi_retornar_indic_econ_finalid (Input v_cod_finalid_econ,
                                                Input bord_ap.dat_transacao,
                                                output v_cod_indic_econ).
        end.
        else do:
            run pi_retornar_indic_econ_finalid (Input v_cod_finalid_econ,
                                                Input today,
                                                output v_cod_indic_econ).
        end.

        /* ** Alteraá∆o feita para gravar num_id_agrup zero, para quando existir apenas um item do borderÀ ***/
        for each item_bord_ap exclusive-lock use-index itmbrdp_id
            where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
              and item_bord_ap.cod_portador   = bord_ap.cod_portador 
              and item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap:
            if item_bord_ap.num_id_agrup_item_bord_ap <> 0 then do:
                find first b_item_bord_ap no-lock use-index itmbrdp_id
                    where b_item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
                      and b_item_bord_ap.cod_portador   = bord_ap.cod_portador
                      and b_item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap
                      and b_item_bord_ap.num_id_agrup_item_bord_ap = item_bord_ap.num_id_agrup_item_bord_ap
                      and recid(b_item_bord_ap) <> recid(item_bord_ap) no-error.
                if not avail b_item_bord_ap then do:
                    find item_bord_ap_agrup exclusive-lock
                        where item_bord_ap_agrup.cod_estab_bord = item_bord_ap.cod_estab_bord
                          and item_bord_ap_agrup.num_id_agrup_item_bord_ap = item_bord_ap.num_id_agrup_item_bord_ap no-error.
                    if avail item_bord_ap_agrup then do:
                        delete item_bord_ap_agrup.
                    end.
                    assign item_bord_ap.num_id_agrup_item_bord_ap = 0.
                end.    
            end.

            if bord_ap.cod_indic_econ = v_cod_indic_econ then do:
            /* Alteraá∆o feita para atualizar a forma alternativa com a forma de substituiá∆o, caso exista o */
            /* limite de pagto parametrizado na forma enviada ao banco */
                if item_bord_ap.cod_forma_pagto_altern <> "" then
        	        find FIRST forma_pagto
                        where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto_altern 
                        no-lock no-error.
                else 
               	        find FIRST forma_pagto 
                        where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto 
                        no-lock no-error.

                &if '{&emsfin_version}' >= '5.06' &then
                    assign v_val_lim_forma_pagto   = forma_pagto.val_lim_pagto
                           v_cod_forma_pagto_subst = forma_pagto.cod_forma_pagto_subst.
                &else
                    assign v_val_lim_forma_pagto   = forma_pagto.val_livre_1
                           v_cod_forma_pagto_subst = entry(2,forma_pagto.cod_livre_1,chr(24)).
                &endif

                /* Alteraá∆o feita para atualizar a forma alternativa com a forma de substituiá∆o, caso exista o limite de pagto parametrizado */        
                if avail forma_pagto and v_val_lim_forma_pagto <> 0 then do:
                    find first item_bord_ap_agrup 
                        where item_bord_ap_agrup.cod_estab_bord             = item_bord_ap.cod_estab_bord 
                          and item_bord_ap_agrup.num_id_agrup_item_bord_ap  = item_bord_ap.num_id_agrup_item_bord_ap exclusive-lock no-error.
                    if avail item_bord_ap_agrup then do:
                        if item_bord_ap_agrup.val_tot_agrup_item_bord_ap >= v_val_lim_forma_pagto then do:
                            assign item_bord_ap.cod_forma_pagto_altern = v_cod_forma_pagto_subst
                                   item_bord_ap_agrup.cod_forma_pagto = v_cod_forma_pagto_subst.
                        end.
                    end.
                    else do:
                        if item_bord_ap.val_pagto >= v_val_lim_forma_pagto then
                            assign item_bord_ap.cod_forma_pagto_altern = v_cod_forma_pagto_subst.
                    end.
                end.
            end.
        end.
    end.
    else do:
        for each item_bord_ap exclusive-lock use-index itmbrdp_id
            where item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
              and item_bord_ap.cod_portador   = bord_ap.cod_portador 
              and item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap
              and item_bord_ap.num_id_agrup_item_bord_ap <> 0:
            find first b_item_bord_ap no-lock use-index itmbrdp_id
                where b_item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
                  and b_item_bord_ap.cod_portador   = bord_ap.cod_portador
                  and b_item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap
                  and b_item_bord_ap.num_id_agrup_item_bord_ap = item_bord_ap.num_id_agrup_item_bord_ap
                  and recid(b_item_bord_ap) <> recid(item_bord_ap) no-error.
            if not avail b_item_bord_ap then do:
                find item_bord_ap_agrup exclusive-lock
                    where item_bord_ap_agrup.cod_estab_bord = item_bord_ap.cod_estab_bord
                      and item_bord_ap_agrup.num_id_agrup_item_bord_ap = item_bord_ap.num_id_agrup_item_bord_ap no-error.
                if avail item_bord_ap_agrup then do:
                   delete item_bord_ap_agrup.
                end.
                assign item_bord_ap.num_id_agrup_item_bord_ap = 0.
            end.    
        end.
    end.


    for each compl_movto_pagto exclusive-lock
        where compl_movto_pagto.cod_estab_pagto = bord_ap.cod_estab_bord
          and compl_movto_pagto.num_bord_ap     = bord_ap.num_bord_ap
          and compl_movto_pagto.cod_portador    = bord_ap.cod_portador
          and compl_movto_pagto.num_id_agrup_item_bord_ap <> 0:
        find first b_compl_movto_pagto no-lock
            where b_compl_movto_pagto.cod_estab_pagto = bord_ap.cod_estab_bord
              and b_compl_movto_pagto.num_bord_ap     = bord_ap.num_bord_ap
              and b_compl_movto_pagto.cod_portador    = bord_ap.cod_portador
              and b_compl_movto_pagto.num_id_agrup_item_bord_ap = compl_movto_pagto.num_id_agrup_item_bord_ap
              and recid(b_compl_movto_pagto) <> recid(compl_movto_pagto) no-error.
        if not avail b_compl_movto_pagto then     
            assign compl_movto_pagto.num_id_agrup_item_bord_ap = 0.
    end.



END PROCEDURE.

//----------------------------------------------------------------------------------------------------

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
    /* ix_iz1_bas_bord_ap */


    /* Begin_Include: i_exec_program_epc_pi_fin */
    if  v_nom_prog_upc <> ''    
    or  v_nom_prog_appc <> ''
    or  v_nom_prog_dpc <> '' then do:
        &if 'bord_ap' <> '' &then
            assign v_rec_table_epc = recid(bord_ap)
                   v_nom_table_epc = 'bord_ap'.
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


    /* ix_iz2_bas_bord_ap */
END PROCEDURE.

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gravar_datas_item_bord_ap:

    if  item_bord_ap.cod_refer_antecip_pef = "" or  item_bord_ap.cod_refer_antecip_pef = ?
    then do:
        find tit_ap no-lock
          where tit_ap.cod_estab       = item_bord_ap.cod_estab
            and tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
            and tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto
            and tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor
            and tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap
            and tit_ap.cod_parcela     = item_bord_ap.cod_parcela no-error.
        if  avail tit_ap
        then do:
            assign item_bord_ap.dat_desconto      = tit_ap.dat_desconto
                   item_bord_ap.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
                   item_bord_ap.dat_prev_pagto    = tit_ap.dat_prev_pagto no-error.
        end.
    end.
    else do:
        find antecip_pef_pend no-lock
          where antecip_pef_pend.cod_estab = item_bord_ap.cod_estab
            and antecip_pef_pend.cod_refer = item_bord_ap.cod_refer_antecip_pef  no-error.
        if  avail antecip_pef_pend
        then do:
            assign item_bord_ap.dat_desconto      = antecip_pef_pend.dat_desconto
                   item_bord_ap.dat_vencto_tit_ap = antecip_pef_pend.dat_vencto_tit_ap
                   item_bord_ap.dat_prev_pagto    = antecip_pef_pend.dat_prev_pagto no-error.
        end.
    end.
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_vld_item_bord_ap_confirmacao:
    DEFINE VARIABLE v_log_erro_valid AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_des_msg_erro_1 AS CHARACTER   NO-UNDO.

    tt_block:
    for each tt_log_erros_tit_antecip exclusive-lock:
        delete tt_log_erros_tit_antecip.
    end /* for tt_block */.

    find first tt_item_bord_ap no-lock no-error.
    if not avail tt_item_bord_ap then do:
        run pi_messages (input "show" /*l_show*/ ,
                         input 18428,
                         input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')) /* msg_18148*/.
        return error.
    end.

  

    /* Permite o controle os itens do border‰ que n?t?erros mas n?podem ser atualizados
     devido a data de transa? de baixa n?estar habilitada para movimenta? ou ser
     menor que a data de transa? do border??????    */

    assign v_log_erro_valid = yes.

    /* Verifica a data da confirma? do border??????    */
    if  v_dat_confir_bxa_tit_ap < bord_ap.dat_transacao
    then do:
        assign v_des_msg_erro_1 = substitute( "Data Baixa " + string(v_dat_confir_bxa_tit_ap) +  " deve ser maior ou igual a Data do Borderì " + string(bord_ap.dat_transacao)).
        create tt_log_erros_tit_antecip.
        assign tt_log_erros_tit_antecip.ttv_des_msg_erro_1  = v_des_msg_erro_1
               tt_log_erros_tit_antecip.tta_cod_estab_refer = " "
               tt_log_erros_tit_antecip.ttv_log_atlzdo      = yes.
        assign v_log_erro_valid = no.
        /* Data Baixa deve ser maior ou igual a Data do Border??????*/
        run pi_messages (input "show",
                         input 2471,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            v_dat_confir_bxa_tit_ap, bord_ap.dat_transacao)) /*msg_2471*/.
        return error. /* incluido por gilmar em 19/03/99 */
    end /* if */.

    /* Valida a Situa? do M??o
    */
    run pi_retornar_sit_movimen_modul (Input "APB" /*l_apb*/,
                                       Input bord_ap.cod_empresa,
                                       Input v_dat_confir_bxa_tit_ap,
                                       Input "",
                                       output v_des_sit_movimen_ent) /*pi_retornar_sit_movimen_modul*/.
    if  v_des_sit_movimen_ent <> "Habilitado" /*l_habilitado*/ 
    then do:
        assign v_des_msg_erro_1 = substitute( "M¢dulo APB n∆o habilitado para movimentaá∆o em " + string( v_dat_confir_bxa_tit_ap ) + "!" ).
        create tt_log_erros_tit_antecip.
        assign tt_log_erros_tit_antecip.ttv_des_msg_erro_1  = v_des_msg_erro_1
               tt_log_erros_tit_antecip.tta_cod_estab_refer = " "
               tt_log_erros_tit_antecip.ttv_log_atlzdo      = yes.
        assign v_log_erro_valid = no.
        /* M??o &1 n?habilitado para movimenta? em &2 ! */
        run pi_messages (input "show",
                         input 4153,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "APB" /*l_apb*/ , string( v_dat_confir_bxa_tit_ap ))) /*msg_4153*/.
        return error.
    end /* if */.

    /* --- EPC PARA CONTROLE CONTµBIL - BANCO MERCANTIL BRASIL ---------------- */
    if  v_nom_prog_upc  <> '' or
        v_nom_prog_appc <> '' or
        v_nom_prog_dpc  <> '' then do:

        for each tt_epc:
            delete tt_epc.
        end.

        create tt_epc.
        assign tt_epc.cod_event     = "Valida Situaá∆o" /*l_valida_situacao*/  
               tt_epc.cod_parameter = "Dados" /*l_dados*/  
               tt_epc.val_parameter = "On-Line" /*l_online*/            + chr(10) +
                                      "APB" /*l_apb*/               + chr(10) +
                                      bord_ap.cod_estab_bord + chr(10) + 
                                      string(v_dat_confir_bxa_tit_ap).


        /* Begin_Include: i_exec_program_epc_custom */
        if  v_nom_prog_upc <> '' then
        do:
            run value(v_nom_prog_upc) (input "Valida Situaá∆o" /* l_valida_situacao*/,
                                       input-output table tt_epc).
        end.

        if  v_nom_prog_appc <> '' then
        do:
            run value(v_nom_prog_appc) (input "Valida Situaá∆o" /* l_valida_situacao*/,
                                        input-output table tt_epc).
        end.

        &if '{&emsbas_version}' > '5.00' &then
        if  v_nom_prog_dpc <> '' then
        do:
            run value(v_nom_prog_dpc) (input "Valida Situaá∆o" /* l_valida_situacao*/,
                                        input-output table tt_epc).
        end.
        &endif
        /* End_Include: i_exec_program_epc_custom */


        if  return-value = 'NOK':U then 
                return error.

        for each tt_epc :
            delete tt_epc.
        end.
    end.
    /* --- FIM EPC PARA CONTROLE CONTµBIL - BANCO MERCANTIL BRASIL ------------ */


END PROCEDURE.

//----------------------------------------------------------------------------------------------------

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
         Quando a Base e o ôndice forem iguais, significa que a cotaá∆o pode ser percentual,
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
END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_mensagem_bordero:
    assign v_ind_tip_verific = "OK" /*l_ok*/ .

    find msg_financ no-lock
         where msg_financ.cod_empresa  = v_cod_empres_usuar
           and msg_financ.cod_estab    = tt_bordero.cod_estab
           and msg_financ.cod_mensagem = v_cod_mensagem /*cl_verifica of msg_financ*/ no-error.


    if  not avail msg_financ
    then do:
        find msg_financ no-lock
             where msg_financ.cod_empresa = v_cod_empres_usuar
               and msg_financ.cod_estab = """"
               and msg_financ.cod_mensagem = v_cod_mensagem /*cl_verifica2 of msg_financ*/ no-error.
        if  not avail msg_financ
        then do:
          find msg_financ no-lock
               where msg_financ.cod_empresa = """"
                 and msg_financ.cod_estab = """"
                 and msg_financ.cod_mensagem = v_cod_mensagem /*cl_verifica3 of msg_financ*/ no-error.
          if  not avail msg_financ
          then do:
              assign v_ind_tip_verific = "NOK" /*l_nok*/    .
          end /* if */.
        end /* if */.
    end /* if */.

END PROCEDURE. 

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gerar_item_pagto_cjto_pef:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tipo
        as character
        format "X(10)"
        no-undo.
    def Input param p_cod_estab_refer
        as character
        format "x(5)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_ini
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_fim
        as character
        format "x(8)"
        no-undo.
    def Input param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ_val_usuar     as character       no-undo. /*local*/
    def var v_cod_indic_econ_val_usuar       as character       no-undo. /*local*/
    def var v_cod_return                     as character       no-undo. /*local*/
    def var v_val_lim_liber_pagto            as decimal         no-undo. /*local*/
    def var v_val_lim_pagto                  as decimal         no-undo. /*local*/
    def var v_val_max_pagto                  as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  (antecip_pef_pend.ind_sit_pef_antecip <> "Em Pagamento" /*l_em_pagamento*/ 
    and  antecip_pef_pend.ind_sit_pef_antecip <> "Pend" /*l_pendente*/ )
    or  can-find( first proces_pagto no-lock
        where proces_pagto.cod_estab = antecip_pef_pend.cod_estab
        and   proces_pagto.cod_refer_antecip = antecip_pef_pend.cod_refer
        and   proces_pagto.ind_sit_proces_pagto <> "Preparado" /*l_preparado*/ 
        and   proces_pagto.ind_sit_proces_pagto <> "Liberado" /*l_liberado*/ ) then
        return "802".
    if  antecip_pef_pend.val_tit_ap <= 0.00 then
        return "6862".

    if  antecip_pef_pend.cdn_fornecedor <> 0
    and antecip_pef_pend.cdn_fornecedor <> ? then do:
        find fornec_financ use-index frncfnnc_id
            where fornec_financ.cod_empresa    = antecip_pef_pend.cod_empresa
            and   fornec_financ.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
            no-lock no-error.
        if  not avail fornec_financ then
            return "537".
        if  fornec_financ.log_pagto_bloqdo = yes then
            return "794".
    end.

    find usuar_financ_estab_apb
        where usuar_financ_estab_apb.cod_usuario = v_cod_usuar_corren
        and   usuar_financ_estab_apb.cod_estab   = p_cod_estab_refer
        no-lock no-error.
    if  not avail usuar_financ_estab_apb then
        return "20," + v_cod_usuar_corren + "," + p_cod_estab_refer.

    /* ************************************
    *  A PARTE DE CONTROLE DOS VALORES POR USUÊRIO SERÊ REVISADA NO FUTURO,
    *  AT» LÊ ESTE CÖDIGO FICARÊ SEM USO
    *
    *@run( pi_retornar_limite_valor_usuario(
    *      p_cod_estab_refer,
    *      p_dat_transacao,
    *      usuar_financ_estab_apb.val_lim_liber_usuar_movto,
    *      usuar_financ_estab_apb.val_lim_liber_usuar_mes,
    *      usuar_financ_estab_apb.val_lim_pagto_usuar_movto,
    *      usuar_financ_estab_apb.val_lim_pagto_usuar_mes,
    *      v_val_lim_liber_pagto,
    *      v_val_lim_pagto,
    *      v_cod_finalid_econ_val_usuar,
    *      v_cod_return)).
    *if  v_cod_return <> 'OK' then
    *    return v_cod_return.
    *
    *@run( pi_retornar_indic_econ_finalid_tt(
    *      v_cod_finalid_econ_val_usuar,
    *      p_dat_transacao,
    *      v_cod_indic_econ_val_usuar)).
    *
    *if  tt_titulo_antecip_pef_a_pagar.tta_num_seq_pagto_tit_ap = 0
    *or  tt_titulo_antecip_pef_a_pagar.tta_num_seq_pagto_tit_ap = ? then do:
    *    if  v_cod_indic_econ_val_usuar <> tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ then do:
    *        @run( pi_converter_indic_econ_indic_econ_tt(
    *              v_cod_indic_econ_val_usuar,
    *              v_cod_empres_usuar,
    *              p_dat_transacao,
    *              v_val_lim_liber_pagto,
    *              tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ,
    *              v_cod_return)).
    *        if  v_cod_return <> 'OK' then
    *            return v_cod_return.
    *        find first tt_converter_finalid_econ no-lock no-error.
    *        assign v_val_lim_liber_pagto = tt_converter_finalid_econ.tta_val_transacao
    *               v_val_max_pagto       = v_val_lim_liber_pagto.
    *    end.
    *    else
    *        assign v_val_max_pagto = v_val_lim_liber_pagto.
    *end.
    *else
    *    assign v_val_max_pagto = @fx_objpro(v_val_max_pagto, valmax).
    *
    *if  v_cod_indic_econ_val_usuar <> tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ then do:
    *    @run( pi_converter_indic_econ_indic_econ_tt(
    *          v_cod_indic_econ_val_usuar,
    *          v_cod_empres_usuar,
    *          p_dat_transacao,
    *          v_val_lim_pagto,
    *          tt_titulo_antecip_pef_a_pagar.tta_cod_indic_econ,
    *          v_cod_return )).
    *    find first tt_converter_finalid_econ no-lock no-error.
    *    assign v_val_lim_pagto = tt_converter_finalid_econ.tta_val_transacao.
    *end.
    *if  v_val_lim_pagto < v_val_max_pagto then
    *    assign v_val_max_pagto = v_val_lim_pagto.
    *if  tt_titulo_antecip_pef_a_pagar.tta_val_sdo_tit_ap > v_val_max_pagto then
    *    return "3983".
    **************************************************/

/*     // everton revisar */
/*     if  tt_titulos_bord.tta_val_sdo_tit_ap > antecip_pef_pend.val_tit_ap then */
/*         assign tt_titulos_bord.tta_val_sdo_tit_ap = antecip_pef_pend.val_tit_ap. */

    // everton revisar
/*     if  p_ind_tipo = "Cheque" /*l_cheque*/  then do: */
/*         run pi_gerar_item_pagto_cjto_pef_lote /*pi_gerar_item_pagto_cjto_pef_lote*/. */
/*     end. */
/*     else do: */
/*         run pi_gerar_item_pagto_cjto_pef_bord (Input p_cod_indic_econ, */
/*                                                Input p_cod_indic_econ_ini, */
/*                                                Input p_cod_indic_econ_fim, */
/*                                                Input p_val_cotac_indic_econ) /*pi_gerar_item_pagto_cjto_pef_bord*/. */
/*     end. */
    
    run pi_gerar_item_pagto_cjto_pef_bord (Input p_cod_indic_econ,
                                           Input p_cod_indic_econ_ini,
                                           Input p_cod_indic_econ_fim,
                                           Input p_val_cotac_indic_econ) /*pi_gerar_item_pagto_cjto_pef_bord*/.
    if  return-value <> 'OK' then do:
/**
        CREATE tt-retorno.
        ASSIGN tt-retorno.versao-api = c-versao-api 
               tt-retorno.cod-status = 398
               tt-retorno.desc-retorno = "Antecipaá∆o j† est† em pagamento: ESTAB: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.
***/
        return (return-value).
    end.

    return 'OK'.
END PROCEDURE. /* pi_gerar_item_pagto_cjto_pef */

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_gerar_item_pagto_cjto_pef_bord:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_ini
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_fim
        as character
        format "x(8)"
        no-undo.
    def Input param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_item_bord_ap
        for item_bord_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ               as character       no-undo. /*local*/
    def var v_cod_return                     as character       no-undo. /*local*/
    def var v_ind_tip_atualiz_val_usuar      as character       no-undo. /*local*/
    def var v_num_seq_refer                  as integer         no-undo. /*local*/
    def var v_val_pagto                      as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    find FIRST portador no-lock
         where portador.cod_portador = bord_ap.cod_portador no-error.

    find last b_item_bord_ap
        where b_item_bord_ap.cod_estab_bord = bord_ap.cod_estab_bord
        and   b_item_bord_ap.cod_portador   = bord_ap.cod_portador
        and   b_item_bord_ap.num_bord_ap    = bord_ap.num_bord_ap
        no-lock no-error.
    if  avail b_item_bord_ap then
        assign v_num_seq_refer = b_item_bord_ap.num_seq_bord + 1.
    else
        assign v_num_seq_refer = 1.

    create item_bord_ap.
    assign item_bord_ap.cod_empresa           = bord_ap.cod_empresa
           item_bord_ap.cod_estab_bord        = bord_ap.cod_estab_bord
           item_bord_ap.cod_portador          = bord_ap.cod_portador
           item_bord_ap.num_bord_ap           = bord_ap.num_bord_ap
           item_bord_ap.num_id_item_bord_ap   = next-value(seq_item_bord_ap)
           item_bord_ap.num_seq_bord          = v_num_seq_refer
           item_bord_ap.cod_estab             = tt_titulos_bord.cod_estab
           item_bord_ap.cod_refer_antecip_pef = tt_titulos_bord.cod_refer_antecip_pef
           item_bord_ap.cod_espec_docto       = ""
           item_bord_ap.cod_ser_docto         = ""
           item_bord_ap.cdn_fornecedor        = tt_titulos_bord.cdn_fornecedor
           item_bord_ap.cod_tit_ap            = ""
           item_bord_ap.cod_parcela           = ""
           item_bord_ap.num_seq_pagto_tit_ap  = tt_titulos_bord.num_seq_pagto_tit_ap
           item_bord_ap.cod_banco             = portador.cod_banco
           item_bord_ap.dat_cotac_indic_econ  = v_dat_min_sql
           item_bord_ap.val_cotac_indic_econ  = if tt_titulos_bord.val_cotac_indic_econ <> 0 
                                                then tt_titulos_bord.val_cotac_indic_econ 
                                                else 1
           item_bord_ap.val_pagto             = if tt_titulos_bord.val_pagto_moe <> 0 
                                                then tt_titulos_bord.val_pagto_moe
                                                else tt_titulos_bord.val_sdo_tit_ap
           item_bord_ap.val_multa_tit_ap      = 0
           item_bord_ap.val_juros             = 0
           item_bord_ap.val_cm_tit_ap         = 0
           item_bord_ap.val_desc_tit_ap       = 0
           item_bord_ap.val_abat_tit_ap       = 0
           item_bord_ap.val_pagto_orig        = tt_titulos_bord.val_sdo_tit_ap
           item_bord_ap.val_multa_tit_ap_orig = 0
           item_bord_ap.val_juros_tit_ap_orig = 0
           item_bord_ap.val_cm_tit_ap_orig    = 0
           item_bord_ap.val_desc_tit_ap_orig  = 0
           item_bord_ap.val_abat_tit_ap_orig  = 0
           item_bord_ap.ind_sit_item_bord_ap  = "Em Aberto" /*l_em_aberto*/ 
           item_bord_ap.dat_vencto_tit_ap     = antecip_pef_pend.dat_vencto_tit_ap
           item_bord_ap.dat_prev_pagto        = antecip_pef_pend.dat_vencto_tit_ap.

    &if '{&emsfin_version}' >= '5.04' &then
        if v_log_atualiza_dat_pagto = yes then
            assign item_bord_ap.dat_pagto_tit_ap = antecip_pef_pend.dat_vencto_tit_ap.
        else
            assign item_bord_ap.dat_pagto_tit_ap = bord_ap.dat_transacao.
    &endif        

    if  v_cod_histor_padr <> ""
    then do:
        find histor_padr no-lock
            where histor_padr.cod_histor_padr         = v_cod_histor_padr
            and   histor_padr.cod_modul_dtsul         = "APB" /*l_apb*/   
            and   histor_padr.cod_finalid_histor_padr = "PagtBord" /*l_pagtbord*/   no-error.
        if avail histor_padr then
            assign item_bord_ap.des_text_histor = histor_padr.des_text_histor.
    end.

    assign antecip_pef_pend.cod_portador = bord_ap.cod_portador.

    // everton revisar
    if  tt_param.ind_forma_pagto = "Assume do T°tulo" /*l_assume_do_titulo*/  then do:

        assign item_bord_ap.cod_forma_pagto = antecip_pef_pend.cod_forma_pagto. 
        if antecip_pef_pend.cod_forma_pagto = "" then
            if antecip_pef_pend.cdn_fornecedor > 0 then do:
                find fornec_financ no-lock
                    where fornec_financ.cdn_fornecedor = antecip_pef_pend.cdn_fornecedor
                    and   fornec_financ.cod_empresa    = antecip_pef_pend.cod_empresa
                    no-error.
                if avail fornec_financ then do:
                    assign item_bord_ap.cod_forma_pagto = fornec_financ.cod_forma_pagto.
                end.
            end.
    end.    
    else do:
        assign item_bord_ap.cod_forma_pagto = tt_param.cod_forma_pagto.
    end.        

    /* Emerson */  
    if item_bord_ap.cdn_fornecedor > 0 then do:

/*         // everton revisar */
/*         find fornecedor no-lock */
/*             where fornecedor.cod_empresa    = item_bord_ap.cod_empresa */
/*             and   fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor */
/*             no-error. */

        find first fornecedor no-lock
            where fornecedor.cod_empresa    = item_bord_ap.cod_empresa
            and   fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor.
            
        if avail fornecedor then
            assign v_ind_favorec_cheq = "Fornecedor" /*l_fornecedor*/ 
                   v_nom_favorec_cheq = fornecedor.nom_pessoa.
    end.
    else do:
        find portador no-lock
            where portador.cod_portador = item_bord_ap.cod_portador
            no-error.
        if avail portador then
            assign v_ind_favorec_cheq = "Portador" /*l_portador*/ 
                   v_nom_favorec_cheq = Portador.nom_pessoa.
    end.

        assign item_bord_ap.cod_livre_1 = v_ind_favorec_cheq + chr(10) +      
                                          v_nom_favorec_cheq. 

    find first proces_pagto
        where proces_pagto.cod_estab             = antecip_pef_pend.cod_estab
        and   proces_pagto.cod_refer_antecip_pef = antecip_pef_pend.cod_refer
        exclusive-lock no-error.

    assign v_ind_tip_atualiz_val_usuar = "Pagto" /*l_pagto*/ .
    if  not avail proces_pagto then do:
        create proces_pagto.
        assign proces_pagto.cod_empresa             = v_cod_empres_usuar
               proces_pagto.cod_estab               = antecip_pef_pend.cod_estab
               proces_pagto.cod_refer_antecip_pef   = antecip_pef_pend.cod_refer
               proces_pagto.num_seq_pagto_tit_ap    = 1
               proces_pagto.dat_vencto_tit_ap       = antecip_pef_pend.dat_vencto_tit_ap
               proces_pagto.dat_prev_pagto          = antecip_pef_pend.dat_vencto_tit_ap
               proces_pagto.cod_usuar_prepar_pagto  = v_cod_usuar_corren
               proces_pagto.dat_prepar_pagto        = bord_ap.dat_transacao
               proces_pagto.cod_usuar_liber_pagto   = v_cod_usuar_corren
               proces_pagto.dat_liber_pagto         = bord_ap.dat_transacao
               proces_pagto.val_liberd_pagto        = antecip_pef_pend.val_tit_ap
               proces_pagto.val_liber_pagto_orig    = antecip_pef_pend.val_tit_ap
               proces_pagto.cod_indic_econ          = antecip_pef_pend.cod_indic_econ
               item_bord_ap.num_seq_pagto_tit_ap    = proces_pagto.num_seq_pagto_tit_ap
               v_ind_tip_atualiz_val_usuar          = "Ambos" /*l_ambos*/ 
               proces_pagto.cod_espec_docto         = antecip_pef_pend.cod_espec_docto
               proces_pagto.cod_ser_docto           = antecip_pef_pend.cod_ser_docto
               proces_pagto.cdn_fornecedor          = antecip_pef_pend.cdn_fornecedor
               proces_pagto.cod_tit_ap              = antecip_pef_pend.cod_tit_ap
               proces_pagto.cod_parcela             = antecip_pef_pend.cod_parcela.

        if v_log_atualiz_hora_liber = yes then do:
           &if '{&emsfin_version}' < '5.05' &then
            assign proces_pagto.cod_livre_1 = string(time,'hh:mm:ss').
           &else
            assign proces_pagto.hra_liber_proces_pagto = replace(string(time,'HH:MM:SS'),":","").
           &endif
        end.
    end.
    else do:
        if  proces_pagto.ind_sit_proces_pagto = "Preparado" /*l_preparado*/  then do:
            assign proces_pagto.dat_vencto_tit_ap       = antecip_pef_pend.dat_vencto_tit_ap
                   proces_pagto.dat_prev_pagto          = antecip_pef_pend.dat_vencto_tit_ap
                   proces_pagto.cod_usuar_liber_pagto   = v_cod_usuar_corren
                   proces_pagto.dat_liber_pagto         = bord_ap.dat_transacao
                   proces_pagto.val_liberd_pagto        = antecip_pef_pend.val_tit_ap
                   proces_pagto.val_liber_pagto_orig    = antecip_pef_pend.val_tit_ap
                   proces_pagto.cod_indic_econ          = antecip_pef_pend.cod_indic_econ
                   item_bord_ap.num_seq_pagto_tit_ap    = proces_pagto.num_seq_pagto_tit_ap
                   v_ind_tip_atualiz_val_usuar          = "Ambos" /*l_ambos*/ .
            if v_log_atualiz_hora_liber = yes then do:
               &if '{&emsfin_version}' < '5.05' &then
                assign proces_pagto.cod_livre_1 = string(time,'hh:mm:ss').
               &else
                assign proces_pagto.hra_liber_proces_pagto = replace(string(time,'HH:MM:SS'),":","").
               &endif
            end.
        end.
    end.

    if  v_log_pagto_ant_outras_moed = yes
    and  antecip_pef_pend.ind_tip_refer = "Antecipaá∆o" /*l_antecipacao*/   
    and  antecip_pef_pend.cod_indic_econ <> bord_ap.cod_indic_econ
    then do:
        assign v_val_cotac_indic_econ        = if tt_titulos_bord.val_cotac_indic_econ  <> 0 then tt_titulos_bord.val_cotac_indic_econ 
                                               else  antecip_pef_pend.val_cotac_indic_econ
               proces_pagto.val_liberd_pagto = antecip_pef_pend.val_tit_ap / v_val_cotac_indic_econ
               proces_pagto.cod_indic_econ   = bord_ap.cod_indic_econ.
    end.

    &if '{&emsbas_version}' > '5.00' &then
        if  v_nom_prog_dpc <> '' then do:
            assign v_rec_table_epc = recid(item_bord_ap)
                   v_nom_table_epc = 'item_bord_ap'.
            run value(v_nom_prog_dpc) (input 'gera_conjunto_bordero',
                                       input 'viewer',
                                       input this-procedure,
                                       input v_wgh_frame_epc,
                                       input v_nom_table_epc,
                                       input v_rec_table_epc).
            if  return-value = 'NOK' then
                return 'NOK'.
        end.
    &endif

    assign proces_pagto.cod_portador         = bord_ap.cod_portador
           proces_pagto.ind_sit_proces_pagto = "Em Pagamento" /*l_em_pagamento*/ 
           proces_pagto.cod_usuar_pagto      = v_cod_usuar_corren
           proces_pagto.dat_pagto            = bord_ap.dat_transacao.
           proces_pagto.ind_modo_pagto       = "Borderì" /*l_bordero*/ .

    run pi_retornar_finalid_indic_econ_tt (Input bord_ap.cod_indic_econ,
                                           Input bord_ap.dat_transacao,
                                           output v_cod_finalid_econ) /*pi_retornar_finalid_indic_econ_tt*/.

    find last param_empres_apb no-lock
        where param_empres_apb.cod_empresa = v_cod_empres_usuar
        no-error.
    if  avail param_empres_apb then do:
        if  v_cod_finalid_econ <> param_empres_apb.cod_finalid_econ_val_usuar then do:
            run pi_converter_indic_econ_finalid (Input bord_ap.cod_indic_econ,
                                                 Input v_cod_empres_usuar,
                                                 Input bord_ap.dat_transacao,
                                                 Input item_bord_ap.val_pagto,
                                                 Input param_empres_apb.cod_finalid_econ_val_usuar,
                                                 output v_cod_return) /*pi_converter_indic_econ_finalid*/.
            if  v_cod_return = "OK" /*l_ok*/  or v_cod_return = "" then do:
                find first tt_converter_finalid_econ no-lock no-error.
                assign v_val_pagto = tt_converter_finalid_econ.tta_val_transacao.
            end.
            else return v_cod_return.
        end.
        else 
            assign v_val_pagto = item_bord_ap.val_pagto.

        run pi_atualizar_valor_usuar_apb (Input item_bord_ap.cod_estab_bord,
                                          Input item_bord_ap.cod_estab,
                                          Input bord_ap.dat_transacao,
                                          Input v_ind_tip_atualiz_val_usuar,
                                          Input v_val_pagto,
                                          Input v_cod_usuar_corren) /*pi_atualizar_valor_usuar_apb*/.
    end.
    else return "1053".

    find current bord_ap exclusive-lock no-error.
    assign bord_ap.val_tot_lote_pagto_infor = bord_ap.val_tot_lote_pagto_infor + item_bord_ap.val_pagto.
    
    //Equaliza Total Pagamento com o total informado
    ASSIGN bord_ap.val_tot_lote_pagto_efetd = bord_ap.val_tot_lote_pagto_infor.
                                            
    CREATE tt-retorno.
    ASSIGN tt-retorno.versao-api = c-versao-api 
            tt-retorno.cod-status = 399
           tt-retorno.desc-retorno = "T°tulo vinculado. ".
    if  tt_titulos_bord.cod_refer_antecip_pef = "" then
        assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Nr: " + tt_titulos_bord.cod_tit_ap + "|For: " + STRING(tt_titulos_bord.cdn_fornecedor) + "|Esp: " + tt_titulos_bord.cod_espec_docto + "|Par: " + tt_titulos_bord.cod_parcela.
    else
        assign tt-retorno.desc-retorno = tt-retorno.desc-retorno + "Estab: " + tt_titulos_bord.cod_estab + " Cod Refer: " + tt_titulos_bord.cod_refer_antecip_pef.

    return 'OK'.
END PROCEDURE. /* pi_gerar_item_pagto_cjto_pef_bord */

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_inicializa_tt_param:
    DEF INPUT-OUTPUT PARAM TABLE FOR tt_param.

    DEFINE VARIABLE v_log_achou_reg              AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_dat_cotac_indic_econ       AS DATE        NO-UNDO.
    DEFINE VARIABLE v_val_cotac_indic_econ       AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE v_cod_return                 AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE v_val_cotac_indic_econ_infor AS DECIMAL     NO-UNDO.

    FOR FIRST tt_param:
    END.

    assign tt_param.val_cotac_indic_econ = 0
               v_log_achou_reg = no.

    IF AVAIL bord_ap THEN DO:
        if  (tt_param.cod_indic_econ_ini <> ? AND tt_param.cod_indic_econ_ini = tt_param.cod_indic_econ_fim)
        and can-find(first indic_econ no-lock where indic_econ.cod_indic_econ = tt_param.cod_indic_econ_ini)
        then do:

           if  bord_ap.cod_indic_econ = tt_param.cod_indic_econ_ini
           then do:
              assign tt_param.val_cotac_indic_econ = 1.

           end /* if */.   
           else do:   
              assign v_log_achou_reg = yes.
              run pi_achar_cotac_indic_econ (INPUT tt_param.cod_indic_econ_ini,
                                             Input bord_ap.cod_indic_econ,
                                             Input bord_ap.dat_transacao,
                                             Input "Real" /*l_real*/,
                                             output v_dat_cotac_indic_econ,
                                             output v_val_cotac_indic_econ,
                                             output v_cod_return) /*pi_achar_cotac_indic_econ*/.
              if v_cod_return = "OK" /*l_ok*/ 
                 then assign v_val_cotac_indic_econ_infor = (1 / v_val_cotac_indic_econ).
                 else assign v_val_cotac_indic_econ_infor = 0
                             v_cod_return                 = "OK" /*l_ok*/ .
              find first indic_econ no-lock
                   where indic_econ.cod_indic_econ = tt_param.cod_indic_econ_ini no-error.
              find first b_indic_econ no-lock
                   where b_indic_econ.cod_indic_econ = bord_ap.cod_indic_econ no-error.
              IF NOT avail b_indic_econ THEN DO: //permite informar campos
                  ASSIGN tt_param.val_cotac_indic_econ = v_val_cotac_indic_econ_infor.
              END.
           END.
        END.
    END.

    IF tt_param.dat_cotac_indic_econ =  ? AND AVAIL bord_ap THEN
        ASSIGN tt_param.dat_cotac_indic_econ = bord_ap.dat_transacao.

    IF tt_param.ind_tip_docto_prepar_pagto = ? THEN ASSIGN tt_param.ind_tip_docto_prepar_pagto = "Ambos".
    IF tt_param.ind_liber_pagto_dat        = ? THEN ASSIGN tt_param.ind_liber_pagto_dat        = "Previs Pagto".
    IF tt_param.dat_inicio                 = ? THEN ASSIGN tt_param.dat_inicio                 = TODAY.
    IF tt_param.dat_fim                    = ? THEN ASSIGN tt_param.dat_fim                    = TODAY.
    IF tt_param.cod_portador_ini           = ? THEN ASSIGN tt_param.cod_portador_ini           = "".
    IF tt_param.cod_portador_fim           = ? THEN ASSIGN tt_param.cod_portador_fim           = "ZZZZZ".
    IF tt_param.cod_estab_ini              = ? THEN ASSIGN tt_param.cod_estab_ini              = "".
    IF tt_param.cod_estab_fim              = ? THEN ASSIGN tt_param.cod_estab_fim              = "ZZZZZ".
    IF tt_param.cdn_fornecedor_ini         = ? THEN ASSIGN tt_param.cdn_fornecedor_ini         = 0.
    IF tt_param.cdn_fornecedor_fim         = ? THEN ASSIGN tt_param.cdn_fornecedor_fim         = 999999999.
    IF tt_param.cod_espec_docto_ini        = ? THEN ASSIGN tt_param.cod_espec_docto_ini        = "".
    IF tt_param.cod_espec_docto_fim        = ? THEN ASSIGN tt_param.cod_espec_docto_fim        = "ZZZ".
    IF tt_param.cod_forma_pagto_ini        = ? THEN ASSIGN tt_param.cod_forma_pagto_ini        = "".
    IF tt_param.cod_forma_pagto_fim        = ? THEN ASSIGN tt_param.cod_forma_pagto_fim        = "ZZZ".
    IF tt_param.cod_indic_econ_ini         = ? THEN ASSIGN tt_param.cod_indic_econ_ini         = "".
    IF tt_param.cod_indic_econ_fim         = ? THEN ASSIGN tt_param.cod_indic_econ_fim         = "ZZZZZZZZ".
    IF tt_param.ind_pagto_liber            = ? THEN ASSIGN tt_param.ind_pagto_liber            = "J† Liberados".
    //IF tt_param.val_cotac_indic_econ       = ? THEN ASSIGN tt_param.val_cotac_indic_econ       = 0.
    IF tt_param.dat_cotac_indic_econ       = ? THEN ASSIGN tt_param.dat_cotac_indic_econ       = v_dat_cotac_indic_econ.
    //IF tt_param.val_lim_pagto              = ? THEN ASSIGN tt_param.val_lim_pagto              = 999999999999.99.
    IF tt_param.ind_forma_pagto            = ? THEN ASSIGN tt_param.ind_forma_pagto            = "Assume do T°tulo".
    IF tt_param.cod_forma_pagto            = ? THEN ASSIGN tt_param.cod_forma_pagto            = "".
    //IF tt_param.ind_juros_pagto_autom      = ? THEN ASSIGN tt_param.ind_juros_pagto_autom      = "Paga Juros".
    //IF tt_param.num_talon_cheq             = ? THEN ASSIGN tt_param.num_talon_cheq             = 0.
    //IF tt_param.num_cheque                 = ? THEN ASSIGN tt_param.num_cheque                 = 0.
    IF tt_param.ind_favorec_cheq           = ? THEN ASSIGN tt_param.ind_favorec_cheq           = "".
    //IF tt_param.nom_favorec_cheq           = ? THEN ASSIGN tt_param.nom_favorec_cheq           = "".
    IF tt_param.log_gerac_autom            = ? THEN ASSIGN tt_param.log_gerac_autom            = NO.
    IF tt_param.cod_histor_padr            = ? THEN ASSIGN tt_param.cod_histor_padr            = "".
    IF tt_param.log_consid_fatur_cta       = ? THEN ASSIGN tt_param.log_consid_fatur_cta       = NO.
    IF tt_param.cod_histor_padr            = ? THEN ASSIGN tt_param.cod_histor_padr            = "".
    IF tt_param.log_atualiza_dat_pagto     = ? THEN ASSIGN tt_param.log_atualiza_dat_pagto     = IF GetDefinedFunction('SPP_DESM_FLAG_BORD':U) THEN NO ELSE YES.
    IF tt_param.log_assume_chave_pix_pref  = ? THEN ASSIGN tt_param.log_assume_chave_pix_pref  = NO.
    IF tt_param.log_pix_sem_chave          = ? THEN ASSIGN tt_param.log_pix_sem_chave          = NO.
    IF tt_param.zerar-total-informado      = ? THEN ASSIGN tt_param.zerar-total-informado      = NO.
    IF tt_param.zerar-total-vinculado      = ? THEN ASSIGN tt_param.zerar-total-vinculado      = NO.
    IF tt_param.alterar-status-impresso    = ? THEN ASSIGN tt_param.alterar-status-impresso    = NO.

    // os blocos abaixo ser∆o alterado qdo foram criados parÉmetros no grid do Maestro

    //**************************************************
    // controle da seleá∆o da FAIXA DE ESTABELECIMENTOS
    //**************************************************
    //ASSIGN tt_param.cod_estab_ini = tt_param.cod_estab
    //       tt_param.cod_estab_fim = tt_param.cod_estab.

    //IF  l-empresa-valgroup 
    //OR  l-empresa-cofco THEN
    //    ASSIGN tt_param.cod_estab_ini = ""
    //           tt_param.cod_estab_fim = "ZZZZZ".

    //**************************************************
    // controle da seleá∆o da FAIXA DE PORTADORES
    //**************************************************
    //ASSIGN tt_param.cod_portador_ini = tt_param.cod_portador
    //       tt_param.cod_portador_fim = tt_param.cod_portador.
    //
    //IF  l-empresa-mrn 
    //OR  l-empresa-cofco THEN
    //    ASSIGN tt_param.cod_portador_ini = ""
    //           tt_param.cod_portador_fim = "ZZZZZ".

    IF tt_param.ind_forma_pagto <> "Assume do T°tulo" AND tt_param.ind_forma_pagto <> "Informada" THEN DO:
        //Forma de pagamento inv†lida
    END.

    IF tt_param.ind_liber_pagto_dat <> "Vencimento" AND tt_param.ind_liber_pagto_dat <> "Previs Pagto" AND tt_param.ind_liber_pagto_dat <> "Desconto" THEN DO:
        //Liberaá∆o de pagamento inv†lida
    END.

    IF tt_param.ind_tip_docto_prepar_pagto <> "Ambos" AND tt_param.ind_tip_docto_prepar_pagto <> "T°tulo" AND tt_param.ind_tip_docto_prepar_pagto <> "Antecipaá∆o/PEF" THEN DO:
        //EspÇcie Documento inv†lido
    END.

    IF tt_param.ind_pagto_liber <> "J† Liberados" AND tt_param.ind_pagto_liber <> "N∆o Liberados" AND tt_param.ind_pagto_liber <> "Ambos" THEN DO:
        //Situaá∆o inv†lida
    END.

 END PROCEDURE.

//----------------------------------------------------------------------------------------------------

/* PROCEDURE pi-log:                                                   */
/*                                                                     */
/*     DEF INPUT PARAM p-i-ponto AS INTE no-undo.                      */
/*     DEF INPUT PARAM p-c-msg AS CHAR NO-UNDO.                        */
/*                                                                     */
/*     IF  p-c-msg = "" THEN                                           */
/*         ASSIGN p-c-msg = "Ponto = " + TRIM(STRING(p-i-ponto)).      */
/*     ELSE                                                            */
/*         ASSIGN p-c-msg = TRIM(STRING(p-i-ponto)) + " - " + p-c-msg. */
/*                                                                     */
/*     CREATE tt-retorno.                                              */
/*     ASSIGN tt-retorno.versao-api   = c-versao-api                   */
/*            tt-retorno.cod-status   = -1                             */
/*            tt-retorno.desc-retorno = p-c-msg.                       */
/*                                                                     */
/* END PROCEDURE.                                                      */

//----------------------------------------------------------------------------------------------------

PROCEDURE pi_validar_unid_negoc_antecip_pef_pend_dest:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_estab_dest
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_return_error
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_finalid_econ
        as character
        format "x(10)":U
        label "Finalidade EconÀmica"
        column-label "Finalidade EconÀmica"
        no-undo.
    def var v_cod_return_error
        as character
        format "x(8)":U
        no-undo.
    def var v_val_unid_negoc
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.

    /************************** Variable Definition End *************************/

    run pi_retornar_finalid_econ_corren_estab (Input p_cod_estab,
                                               output v_cod_finalid_econ) /*pi_retornar_finalid_econ_corren_estab*/.
    assign v_val_unid_negoc = 0
           p_cod_return_error = "OK" /*l_ok*/ .

    for each aprop_ctbl_pend_ap no-lock
       where aprop_ctbl_pend_ap.cod_estab = p_cod_estab
       and   aprop_ctbl_pend_ap.cod_refer = p_cod_refer
        break by aprop_ctbl_pend_ap.cod_unid_negoc:
        assign v_val_unid_negoc = v_val_unid_negoc + aprop_ctbl_pend_ap.val_aprop_ctbl.
        if  last-of(aprop_ctbl_pend_ap.cod_unid_negoc)
        then do:
            if  v_val_unid_negoc > 0
            then do:
                run pi_validar_unid_negoc (Input p_cod_estab_dest,
                                           Input aprop_ctbl_pend_ap.cod_unid_negoc,
                                           Input p_dat_transacao,
                                           output v_cod_return_error) /*pi_validar_unid_negoc*/.
                if  v_cod_return_error <> ""
                then do:
                    case v_cod_return_error:
                        when "Estabelecimento" /*l_estabelecimento*/  then 
                            assign p_cod_return_error = "8450" + "," + p_cod_estab_dest + "," + aprop_ctbl_pend_ap.cod_unid_negoc + ",,,,,,,".
                        when "Data" /*l_data*/  then 
                            assign p_cod_return_error = "13600" + "," + aprop_ctbl_pend_ap.cod_unid_negoc + "," + p_cod_estab_dest + "," + string(p_dat_transacao) + ",,,,,,".
                        when "Usuˇrio" /*l_usuario*/  then
                            assign p_cod_return_error = "8452" + "," + aprop_ctbl_pend_ap.cod_unid_negoc + ",,,,,,,,".
                    end.
                    return.
                end /* if */.
            end /* if */.
            assign v_val_unid_negoc = 0.
        end /* if */.
    end.

END PROCEDURE. /* pi_validar_unid_negoc_antecip_pef_pend_dest */

//----------------------------------------------------------------------------------------------------

/*****************************************************************************
** Procedure Interna.....: pi_controlar_selecao_pagamento
** Descricao.............: pi_controlar_selecao_pagamento
** Criado por............: Rafael
** Criado em.............: 19/06/1998 08:52:21
** Alterado por..........: its0068
** Alterado em...........: 19/04/2004 15:56:09
*****************************************************************************/
PROCEDURE pi_controlar_selecao_pagamento:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_modo_pagto
        as character
        format "X(10)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_docto_prepar_pagto
        as character
        format "X(11)"
        no-undo.
    def Input param p_ind_liber_pagto_dat
        as character
        format "X(12)"
        no-undo.
    def Input param p_dat_inicio
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_dat_fim
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_cod_estab_ini
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cod_estab_fim
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_cdn_fornecedor_ini
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cdn_fornecedor_fim
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_espec_docto_ini
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_espec_docto_fim
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_forma_pagto_in
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_forma_pagto_fn
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_indic_econ_ini
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_fim
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_portador_ini
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_portador_fim
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_portador
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_cart_bcia
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_ind_pagto_liber
        as character
        format "X(08)"
        no-undo.
    def Input param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def Input param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_val_lim_pagto
        as decimal
        format ">>>,>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_ind_forma_pagto
        as character
        format "X(18)"
        no-undo.
    def Input param p_cod_forma_pagto
        as character
        format "x(3)"
        no-undo.
    def Input param p_ind_juros_pagto_autom
        as character
        format "X(14)"
        no-undo.
    def Input param p_num_talon_cheq
        as integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_num_cheque
        as integer
        format ">>>>,>>>,>>9"
        no-undo.
    def Input param p_ind_favorec_cheq
        as character
        format "X(15)"
        no-undo.
    def Input param p_nom_favorec_cheq
        as character
        format "x(40)"
        no-undo.
    def Input param p_cod_estab_refer
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def Input param p_log_gerac_autom
        as logical
        format "Sim/Nío"
        no-undo.
    def Input param p_rec_table
        as recid
        format ">>>>>>9"
        no-undo.
    def Input param p_cod_histor_padr
        as character
        format "x(8)"
        no-undo.
    def Input param p_log_consid_fatur_cta
        as logical
        format "Sim/Nío"
        no-undo.


    /************************* Parameter Definition End *************************/

    for each tt_exec_rpc:
        delete tt_exec_rpc.
    end.

    ASSIGN tt_param.log-processo = "1|".

    if  p_dat_cotac_indic_econ = ?
        then assign p_dat_cotac_indic_econ = p_dat_transacao.

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
            tt_exec_rpc.ttv_cod_livre                 = p_ind_modo_pagto               + chr(10) +
                                                        string(p_dat_transacao)        + chr(10) +
                                                        p_ind_tip_docto_prepar_pagto   + chr(10) +
                                                        p_ind_liber_pagto_dat          + chr(10) +
                                                        string(p_dat_inicio)           + chr(10) +
                                                        string(p_dat_fim)              + chr(10) +
                                                        p_cod_estab_ini                + chr(10) +
                                                        p_cod_estab_fim                + chr(10) +
                                                        string(p_cdn_fornecedor_ini)   + chr(10) +
                                                        string(p_cdn_fornecedor_fim)   + chr(10) +
                                                        p_cod_espec_docto_ini          + chr(10) +
                                                        p_cod_espec_docto_fim          + chr(10) +
                                                        p_cod_forma_pagto_in           + chr(10) +
                                                        p_cod_forma_pagto_fn           + chr(10) +
                                                        p_cod_indic_econ_ini           + chr(10) +
                                                        p_cod_indic_econ_fim           + chr(10) +
                                                        p_cod_portador_ini             + chr(10) +
                                                        p_cod_portador_fim             + chr(10) +
                                                        p_cod_portador                 + chr(10) +
                                                        p_cod_cart_bcia                + chr(10) +
                                                        p_cod_indic_econ               + chr(10) +
                                                        p_ind_pagto_liber              + chr(10) +
                                                        string(p_val_cotac_indic_econ) + chr(10) +
                                                        string(p_dat_cotac_indic_econ) + chr(10) +
                                                        string(p_val_lim_pagto)        + chr(10) +
                                                        p_ind_forma_pagto              + chr(10) +
                                                        p_cod_forma_pagto              + chr(10) +
                                                        p_ind_juros_pagto_autom        + chr(10) +
                                                        string(p_num_talon_cheq)       + chr(10) +
                                                        string(p_num_cheque)           + chr(10) +
                                                        p_ind_favorec_cheq             + chr(10) +
                                                        p_nom_favorec_cheq             + chr(10) +
                                                        p_cod_estab_refer              + chr(10) +
                                                        string(p_log_gerac_autom)      + chr(10) +
                                                        p_cod_histor_padr              + chr(10) +
                                                        string(p_log_consid_fatur_cta).

    assign v_log_method = session:set-wait-state('general').


    /* Begin_Include: i_exec_program_rpc2 */

       /* Begin_Include: i_exec_initialize_rpc */
       if  not valid-handle(v_wgh_servid_rpc)
       or v_wgh_servid_rpc:type <> 'procedure':U
       or v_wgh_servid_rpc:file-name <> 'prgtec/btb/btb008za.py':U
       then do:
           run prgtec/btb/btb008za.py persistent set v_wgh_servid_rpc (input 1).
       end /* if */.

       run pi_connect in v_wgh_servid_rpc ("api_controlar_selecao_pagamento":U, "", no).
       /* End_Include: i_exec_initialize_rpc */
        ASSIGN tt_param.log-processo = tt_param.log-processo + "2|".
       if  rpc_exec("api_controlar_selecao_pagamento":U)
       then do:
           ASSIGN tt_param.log-processo = tt_param.log-processo + "3|".
          

           /* Begin_Include: i_exec_dispatch_rpc */
           rpc_exec_set("api_controlar_selecao_pagamento":U,yes).
           rpc_block:
           repeat while rpc_exec("api_controlar_selecao_pagamento":U) on stop undo rpc_block, retry rpc_block:
               ASSIGN tt_param.log-processo = tt_param.log-processo + "4|".
               if  rpc_program("api_controlar_selecao_pagamento":U) = ?
               then do: 
                  leave rpc_block.        
               end /* if */.
               if  retry
               then do:
                   run pi_status_error in v_wgh_servid_rpc.
                   next rpc_block.
               end /* if */.
               ASSIGN tt_param.log-processo = tt_param.log-processo + "5|".
               if  rpc_tip_exec("api_controlar_selecao_pagamento":U)
               then do:
                   ASSIGN tt_param.log-processo = tt_param.log-processo + "6|".
                   run pi_check_server in v_wgh_servid_rpc ("api_controlar_selecao_pagamento":U).
                   if  return-value = 'yes'
                   then do:
                       ASSIGN tt_param.log-processo = tt_param.log-processo + "7|".
                       if  rpc_program("api_controlar_selecao_pagamento":U) <> ?
                       then do:
                           ASSIGN tt_param.log-processo = tt_param.log-processo + "8|".
                           if  '1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table' = '""'
                           then do:
                               ASSIGN tt_param.log-processo = tt_param.log-processo + "9|".
                               &if '""' = '""' &then
                                   run value(rpc_program("api_controlar_selecao_pagamento":U)) on rpc_server("api_controlar_selecao_pagamento":U) transaction distinct no-error.
                               &else
                                   run value(rpc_program("api_controlar_selecao_pagamento":U)) persistent set "" on rpc_server("api_controlar_selecao_pagamento":U) transaction distinct no-error.
                               &endif
                           end /* if */.
                           else do:
                               ASSIGN tt_param.log-processo = tt_param.log-processo + "10|".
                               &if '""' = '""' &then
                                   run value(rpc_program("api_controlar_selecao_pagamento":U)) on rpc_server("api_controlar_selecao_pagamento":U) transaction distinct (1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table) no-error.
                               &else
                                   run value(rpc_program("api_controlar_selecao_pagamento":U)) persistent set "" on rpc_server("api_controlar_selecao_pagamento":U) transaction distinct (1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table) no-error.
                               &endif
                           end /* else */.
                       end /* if */.    
                   end /* if */.
                   else do:
                       ASSIGN tt_param.log-processo = tt_param.log-processo + "next1|".
                       next rpc_block.
                   end /* else */.
               end /* if */.
               else do:
                   ASSIGN tt_param.log-processo = tt_param.log-processo + "11|".
                   if  rpc_program("api_controlar_selecao_pagamento":U) <> ?
                   then do: 
                       ASSIGN tt_param.log-processo = tt_param.log-processo + "12|".
                       if  '1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table' = '""'
                       then do:
                           ASSIGN tt_param.log-processo = tt_param.log-processo + "13|".
                           &if '""' = '""' &then 
                               run value(rpc_program("api_controlar_selecao_pagamento":U)) no-error.
                           &else
                               run value(rpc_program("api_controlar_selecao_pagamento":U)) persistent set "" no-error.
                           &endif
                       end /* if */.
                       else do:
                           ASSIGN tt_param.log-processo = tt_param.log-processo + "14|".
                           &if '""' = '""' &then 
                               run value(rpc_program("api_controlar_selecao_pagamento":U)) (1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table) no-error.
                           &else
                               run value(rpc_program("api_controlar_selecao_pagamento":U)) persistent set "" (1,input table tt_exec_rpc,input-output table tt_titulo_antecip_pef_a_pagar, input p_rec_table) no-error.
                           &endif
                       end /* else */.
                   end /* if */.        
               end /* else */.

               run pi_status_error in v_wgh_servid_rpc.
           end /* repeat rpc_block */.
           /* End_Include: i_exec_dispatch_rpc */

       end /* if */.
       ASSIGN tt_param.log-processo = tt_param.log-processo + "fim|".

       /* Begin_Include: i_exec_destroy_rpc */
       run pi_destroy_rpc in v_wgh_servid_rpc ("api_controlar_selecao_pagamento":U).

       &if '""' <> '""' &then
           if  valid-handle("") then
               delete procedure "".
       &endif

       if  valid-handle(v_wgh_servid_rpc) then
           delete procedure v_wgh_servid_rpc.

       /* End_Include: i_exec_destroy_rpc */




    /* End_Include: i_exec_destroy_rpc */


    assign v_log_method = session:set-wait-state('').

END PROCEDURE. /* pi_controlar_selecao_pagamento */
