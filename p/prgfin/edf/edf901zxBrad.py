/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: fnc_extracao_Bradesco
** Descricao.............: Extraá∆o Bradesco
** Versao................:  1.00.00.014
** Procedimento..........: utl_formula_edi
** Nome Externo..........: prgint/edf/edf901zxBrad.py
** Alterado por..........: Eduardo Marcel Barth - (47) 99903-1968
** Alterado em...........: 10/2022
**
**  Implementado tratamento para impostos sem codigo de barras.
**
*****************************************************************************/
/*-- Filtro Multi-idioma Aplicado --*/

def var c-versao-prg as char initial " 1.00.00.014":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.014[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/cdcfgfin.i}


/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=0":U.
/*************************************  *************************************/

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_param no-undo
    field tta_cdn_segment_edi              as Integer format ">>>>>9" initial 0 label "Segmento" column-label "Segmento"
    field tta_cdn_element_edi              as Integer format ">>>>>9" initial 0 label "Elemento" column-label "Elemento"
    field tta_des_label_utiliz_formul_edi  as character format "x(10)" label "Label Utiliz Formula" column-label "Label Utiliz Formula"
    field ttv_des_contdo                   as character format "x(100)" label "Conteudo" column-label "Conteudo"
    index tt_param_id       is primary
          tta_cdn_segment_edi              ascending
          tta_cdn_element_edi              ascending
    .

def shared temp-table tt_segment_tot no-undo
    field tta_cdn_segment_edi              as Integer format ">>>>>9" initial 0 label "Segmento" column-label "Segmento"
    field ttv_qtd_proces_edi               as decimal format "->>>>,>>9.9999" decimals 4
    field ttv_qtd_bloco_docto              as decimal format "99999"
    field ttv_log_trailler_edi             as logical format "Sim/N∆o" initial no label "Trailler" column-label "Trailler"
    field ttv_log_header_edi               as logical format "Sim/N∆o" initial no label "Header" column-label "Header"
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
    for tt_param.


/************************* Parameter Definition End *************************/

/************************* Variable Definition Begin ************************/

def var v_cdn_contador
    as Integer
    format ">>>,>>9":U
    no-undo.
def var v_cdn_espaco
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
    label "Agància Banc†ria"
    column-label "Agància Banc†ria"
    no-undo.
def var v_cod_agenc_bcia_fav
    as character
    format "x(10)":U
    label "Agància Banc†ria"
    column-label "Agància Banc†ria"
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
    label "D°gito Ag Bcia"
    column-label "Dig Ag"
    no-undo.
def var v_cod_digito_agenc_cta_corren
    as character
    format "x(2)":U
    label "D°gito Agància + Cta"
    column-label "D°g Agància + Cta"
    no-undo.
def var v_cod_digito_cta_corren
    as character
    format "x(2)":U
    label "D°gito Cta Corrente"
    column-label "D°gito Cta Corrente"
    no-undo.
def var v_cod_digito_cta_corren_fav
    as character
    format "x(2)":U
    label "D°gito Cta Corrente"
    column-label "D°gito Cta Corrente"
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
def var v_cod_espaco_branco
    as character
    format "x(1)":U
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
def var v_cod_gravac
    as character
    format "x(8)":U
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
def var v_cod_inicial
    as character
    format "x(9)":U
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
    label "Ocorrància Bcia"
    column-label "Ocorrància Bcia"
    no-undo.
def var v_cod_pagto
    as character
    format "x(16)":U
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
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
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
    label "C¢digo Sist Banc†rio"
    column-label "C¢digo Sist Banc†rio"
    no-undo.
def var v_cod_tip_reg_boleto
    as character
    format "x(1)":U
    initial "2"
    no-undo.
def var v_cod_tit
    as character
    format "x(18)":U
    no-undo.
def var v_cod_titulo
    as character
    format "x(8)":U
    label "Titulo"
    column-label "Titulo"
    no-undo.
def var v_cod_tit_ap
    as character
    format "x(10)":U
    label "T°tulo Ap"
    column-label "T°tulo Ap"
    no-undo.
def var v_cod_tit_ap_bco
    as character
    format "x(20)":U
    label "T°tulo  Banco"
    column-label "T°tulo Banco"
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
def var v_cod_vencto
    as character
    format "x(8)":U
    no-undo.
def var v_dat_gravac
    as date
    format "99/99/9999":U
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
def var v_num_control_apres
    as integer
    format ">>>>,>>9":U
    no-undo.
def new global shared var v_num_cont_val
    as integer
    format ">>>>,>>9":U
    initial 0
    no-undo.
def var v_num_convenio
    as integer
    format "999999":U
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_seq
    as integer
    format ">>>,>>9":U
    label "Seq?ància"
    column-label "Seq"
    no-undo.
def var v_num_seq_header
    as integer
    format ">>>>>":U
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
    label "Valor AcrÇscimo"
    column-label "Valor AcrÇscimo"
    no-undo.
def var v_val_cgc_cpf
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_correc
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Valor Correá∆o"
    column-label "Valor Correá∆o"
    no-undo.
def var v_val_desconto
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Desconto"
    column-label "Desconto"
    no-undo.
def var v_val_inicial
    as decimal
    format "->>,>>>,>>>,>>9.999":U
    decimals 3
    label "Valor Inicial"
    column-label "Valor Inicial"
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
def var v_num_servico                    as integer         no-undo. /*local*/
def var v_num_tip_id_feder_fornec        as integer         no-undo. /*local*/
def var v_cod_id_feder_fornec            as character       no-undo. /*local*/
def var v_nom_fornec                     as character       format "x(30)":U no-undo.
def var v_cod_digito          as char no-undo.
def var v_cdn_bco             as int  no-undo.
def var v_num_inic            as int  no-undo.
def var v_cdn_agenc           as int  no-undo.
def var v_val_cta_arq         as dec  decimals 0 no-undo.
def var dt-aux                as date no-undo.
def var c-mes                 as int  no-undo.
def var c-ano                 as int  no-undo.
def var c-aux                 as char no-undo.
def var i-aux                 as int  no-undo.
def var v_dec_aux             as dec  no-undo.
def var v_dec_aux2            as dec  no-undo.
def var v_dec_aux3            as dec  no-undo.
def var v_num_tam_format      as int  no-undo.
def var de-aux                as dec no-undo.
def var de-aux2               as dec no-undo.
def var de-aux3               as dec no-undo.
def var c-bloco               as char no-undo.
def var v_cod_segto           as char no-undo.
def var v_forma_pagto         as char no-undo.
def var v_tp_forn             as int  no-undo.
def var v_cod_finalid_doc     as char no-undo format "x(2)".
def var v_cod_finalid_ted     as char no-undo format "x(5)".
def var v_cod_finalid_compl   as char no-undo format "x(2)".
def var v_des_item_bord_ap    as char no-undo.
def var v_log_pix             as log  no-undo.
def var v_log_pix_sem_chave   as log  no-undo.
def var v_ind_tip_cta_pix                as character       no-undo. /*local*/ 

def var c_tipolote             as char      no-undo.
def var c_segmento             as char      no-undo.
def var c_codbarras            as char      no-undo.
def var v_num_bloco                      as integer         no-undo. /*local*/
def var v_num_reg_bloco                  as integer         no-undo. /*local*/

def new global shared var v_des_flag_public_geral
    as character
    format "x(15)":U
    extent 10
    no-undo.

/************************** Variable Definition End *************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
//{include/i-ctrlrp5.i fnc_extracao_banco_brasil}


def new global shared var v_cod_arq
    as char  
    format 'x(60)'
    no-undo.
def new global shared var v_cod_tip_prog
    as character
    format 'x(8)'
    no-undo.

def stream s-arq.

/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):
    if  p_num_posicao <= 0  then do:
        assign p_num_posicao  = 1.
    end.
    if num-entries(p_cod_campo,p_cod_separador) >= p_num_posicao  then do:
       return entry(p_num_posicao,p_cod_campo,p_cod_separador).
    end.
    return "".
END FUNCTION.

// Retorna somente os digitos numericos de uma string.
FUNCTION SomenteNumeros RETURNS CHARACTER( input p_string as character ):
    def var i as int no-undo.
    def var c as char no-undo init "".
    def var cretorno as char no-undo init "".
    DO i = 1 to LENGTH(p_string):
       if index("0123456789",substr(p_string,i,1)) > 0 then
          assign cretorno = cretorno + substr(p_string,i,1).
    end.
    return cretorno.
END FUNCTION.

/*
def stream s1.
output stream s1 to "C:\Users\kml.msantos\Desktop\edf901zxBrad.txt" append no-convert.
put stream s1 unformatted
    "EDF901ZXBRAD -- dia " DAY(today) " Ös " string(TIME, "HH:MM") skip
    "MAPA: " p_cdn_mapa_edi "    SEGMENTO:" p_cdn_segment_edi "    ELEMENTO:" p_cdn_element_edi SKIP(1).
put stream s1 unformatted "Segmen Elemen Label     Conte£do" skip.
for each tt_param:
    put stream s1 
        tt_param.tta_cdn_segment_edi
        tt_param.tta_cdn_element_edi
        tt_param.tta_des_label_utiliz_formul_edi
        tt_param.ttv_des_contdo                      
        skip.
end.
put stream s1 unformatted "-----------------------------------" skip(2).
output close.
*/


if  p_cdn_segment_edi = 370 then do: /* Header Arquivo */
    if  p_cdn_element_edi = 25 then do: /* Identificaá∆o PIX */
        return ''. // A Nissei n∆o usa forma pagto PIX. (Barth em 21/10/2022)
//        assign v_log_pix = no.
//        find first reg_proces_entr_edi 
//             where reg_proces_entr_edi.cdn_proces_edi  = int(v_des_flag_public_geral[1]) 
//              and reg_proces_entr_edi.cdn_segment_edi = 289 no-lock no-error.
//        if  avail reg_proces_entr_edi then do:
//            assign v_des_item_bord_ap = GetEntryField(21,reg_proces_entr_edi.dsl_dados_entr_edi,chr(24)).
//            find first item_bord_ap no-lock
//                 where item_bord_ap.cod_estab_bord      = getentryfield(1,v_des_item_bord_ap,';')
//                   and item_bord_ap.num_id_item_bord_ap = int(getentryfield(2,v_des_item_bord_ap,';')) no-error.
//            if not avail item_bord_ap then 
//                find first item_bord_ap no-lock
//                     where item_bord_ap.cod_estab_bord            = getentryfield(1,v_des_item_bord_ap,';')
//                       and item_bord_ap.num_id_agrup_item_bord_ap = int(getentryfield(2,v_des_item_bord_ap,';')) no-error.
//
//            if  avail item_bord_ap then do:
//                find first ems5.forma_pagto no-lock
//                     where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto no-error.
//                if  avail forma_pagto and forma_pagto.ind_tip_forma_pagto begins 'PIX' then
//                    assign v_log_pix = yes.
//            end.
//        end.
//
//        if v_log_pix = yes then 
//           return 'PIX'.
//        ELSE 
//           return ''.
    end.
end.

find first tt_param
    where tt_param.tta_cdn_segment_edi = 0 // Indicador do tipo de lote / tipo de pagamento
    and   tt_param.tta_cdn_element_edi = 0 //
    and   tt_param.tta_des_label_utiliz_formul_edi = "bloco"
    no-error.
if  not avail tt_param then return "ERRO".
assign c_tipolote = trim(tt_param.ttv_des_contdo).

if  p_cdn_segment_edi = 373 then do:    // Linha Header Lote

    // Tipo do Serviáo
    if  p_cdn_element_edi = 000005 then do:
        if  c_tipolote = "BoletoOutros" // Boleto para Outros Bancos
        or  c_tipolote = "BoletoBanco"  // Boleto do pr¢prio Bradesco
        or  c_tipolote = "DOC"         
        or  c_tipolote = "CrÇdito C/C" 
        or  c_tipolote = "Cheque ADM"  
        or  c_tipolote = "Ordem Pagto" 
        or  c_tipolote = "TED CIP"      // TED para o pr¢prio Bradesco
        or  c_tipolote = "TED STR"      // TED para outros bancos
        or  c_tipolote = "PIX transferància"
        or  c_tipolote = "PIX QRCode"
        then return '20'. // Pagto Fornecedores
        else
            if c_tipolote = "PagtoDARF"
            or c_tipolote = "PagtoGPS"
            or c_tipolote = "PagtoGARE-SP"
            or c_tipolote = "PagtoFGTS"
            or c_tipolote = "PagtoContas"
            or c_tipolote = "PagtoIPTU"
            then return '22'. // Pagto Contas e Tributos
            else return '98'. // Pagamentos diversos
    end.

    // Forma de Lanáamento
    if  p_cdn_element_edi = 000006 then do:
        if  c_tipolote = "BoletoOutros" then return '31'.
        if  c_tipolote = "BoletoBanco"  then return '30'.
        if  c_tipolote = "DOC"          then return '03'.
        if  c_tipolote = "CrÇdito C/C"  then return '01'.
        if  c_tipolote = "Cheque ADM"   then return '02'.
        if  c_tipolote = "Ordem Pagto"  then return '10'.
        if  c_tipolote = "TED CIP"      then return '03'.
        if  c_tipolote = "TED STR"      then return '03'.
        if  c_tipolote = "PagtoDARF"    then return '16'.
        if  c_tipolote = "PagtoGPS"     then return '17'.
        if  c_tipolote = "PagtoGARE-SP" then return '22'.
        if  c_tipolote = "PagtoFGTS"    then return '11'.
        if  c_tipolote = "PagtoIPTU"    then return '19'.
        if  c_tipolote = "PIX transferància" then return '45'.
        if  c_tipolote = "PIX QRCode"   then return '47'.
        return '11'. // Pagto Contas e Tributos COM codigo de barras
    end.

    // Vers∆o do layout (difere por segmento)
    if  p_cdn_element_edi = 000007 then do:
        if  c_tipolote = "BoletoOutros" // Boleto para Outros Bancos
        or  c_tipolote = "BoletoBanco"  // Boleto do pr¢prio Bradesco
        or  c_tipolote = "PIX QRCode"
            then return '040'. // Boleto
        else
        if  c_tipolote = "DOC"         
        or  c_tipolote = "CrÇdito C/C"
        or  c_tipolote = "Cheque ADM"  
        or  c_tipolote = "Ordem Pagto"
        or  c_tipolote = "PIX transferància"
        or  c_tipolote = "TED CIP"      // TED para o pr¢prio Bradesco
        or  c_tipolote = "TED STR"      // TED para outros bancos
            then return '045'. // DOC/TED
        else
            return '012'. // Contas e Tributos
    end.

end.


if p_cdn_segment_edi = 371 then do:   // Linha Detalhe

   case c_tipolote:
        when "BoletoOutros"   then assign c_segmento = "J".
        when "BoletoBanco"    then assign c_segmento = "J".
        when "DOC"            then assign c_segmento = "A".
        when "CrÇdito C/C"    then assign c_segmento = "A".
        when "Cheque ADM"     then assign c_segmento = "J".
        when "Ordem Pagto"    then assign c_segmento = "J".
        when "TED CIP"        then assign c_segmento = "A".
        when "TED STR"        then assign c_segmento = "A".
        when "PagtoDARF"      then assign c_segmento = "N".
        when "PagtoGPS"       then assign c_segmento = "N".
        when "PagtoGARE-SP"   then assign c_segmento = "N".
        when "PagtoFGTS"      then assign c_segmento = "O".
        when "PagtoContas"    then assign c_segmento = "O".
        when "PagtoIPTU"      then assign c_segmento = "O".
        when "Pagto Tributos" then assign c_segmento = "O".
        otherwise assign c_segmento = "J".
    end.

   /* -------------- DETALHE ---------------*/
   case c_segmento:
     when "A" /*l_A*/  then  /* Pagamento com Cheque, OP, DOC, TED e Cr≤dito em Conta Corrente */
         run pi_segto_tipo_A_J.
     when "J" /*l_J*/  then  /* Liquidaªío de T≠tulos (bloquetos) em cobranªa no Itaú e em outros Bancos */
         run pi_segto_tipo_A_J.
     when "N" /*l_n*/  then  /* Pagamento Tributos (GPS / DARF / DARF SIMPLES) */
         run pi_segto_tipo_N.
     when "O" /*l_o*/  then  /* Pagamento Contas µguaConcession†rias */
         run pi_segto_tipo_O.
   end case.
   /* --------------------------------------*/

   return v_cod_det. /* Vai retornar registro com dados de detalhe variˇvel */
end.


/* J-52 - Somat¢rio Registros do Bloco  - 
    N«O ê CHAMADO PELO MAPA, PARECE ESTAR SEM USO (Barth)*/
//if p_cdn_segment_edi = 374 and
//   p_cdn_element_edi = 5 then do:
//   
//   find first tt_segment_tot no-lock
//        where tt_segment_tot.tta_cdn_segment_edi = 999999  no-error.
//     
//   if avail tt_segment_tot then
//      return string(tt_segment_tot.ttv_qtd_bloco_docto).
//   
//end.
/* FIM-J-52 - Somat¢rio Registros do Bloco */

/******************************* Main Code End ******************************/

/*****************************************************************************
** Procedure Interna.....: pi_retorna_cod_barra_leitora
** Descricao.............: pi_retorna_cod_barra_leitora
** Criado por............: bre17191
** Criado em.............: 15/06/2000 10:07:42
** Alterado por..........: bre18732
** Alterado em...........: 19/03/2002 11:06:36
*****************************************************************************/
PROCEDURE pi_retorna_cod_barra_leitora:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_barra_2
        as character
        format "99999.999999"
        no-undo.
    def output param p_cod_barra
        as character
        format "x(44)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_tam_format
        as integer
        format ">>9":U
        no-undo.
    def var v_val_tit_barra
        as decimal
        format "->>,>>>,>>>,>>9.99":U
        decimals 2
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_val_tit_barra = 0.

    &if defined(BF_FIN_ALTER_CODIGO_BARRA) &then
        assign v_num_tam_format = 14.
    &else
        find histor_exec_especial no-lock
             where histor_exec_especial.cod_modul_dtsul = 'UFN'
               and histor_exec_especial.cod_prog_dtsul  = 'SPP_alter_codigo_barra'
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


END PROCEDURE. /* pi_retorna_cod_barra_leitora */
/*****************************************************************************
** Procedure Interna.....: pi_segto_tipo_A_J
** Descricao.............: pi_segto_tipo_A_J
** Criado por............: brf12302
** Criado em.............: 20/10/2000 13:52:33
** Alterado por..........: diomar
** Alterado em...........: 22/12/2020
*****************************************************************************/
PROCEDURE pi_segto_tipo_A_J:

    /************************* Variable Definition Begin ************************/

    def var v_cod_bairro_favorec             as character       no-undo. /*local*/
    def var v_cod_cep_favorec                as character       no-undo. /*local*/
    def var v_cod_cidad_favorec              as character       no-undo. /*local*/
    def var v_cod_ender_favorec              as character       no-undo. /*local*/
    def var v_cod_estado_favorec             as character       no-undo. /*local*/
    def var v_cod_id_feder_favorec           as character       no-undo. /*local*/
    def var v_num_bloco                      as integer         no-undo. /*local*/
    def var v_num_reg_bloco                  as integer         no-undo. /*local*/
    def var v_num_tip_id_feder               as integer         no-undo. /*local*/
    def var v_cdn_bco                        as integer         no-undo. /*local*/
    def var v_des_j52                        as character       no-undo. /*local*/
    def var v_num_tip_id_feder_pagad         as integer         no-undo. /*local*/
    def var v_cod_id_feder_pagad             as character       no-undo. /*local*/
    def var v_nom_pagad                      as character       no-undo. /*local*/
    def var v_num_tip_id_benef               as integer         no-undo. /*local*/
    def var v_cod_id_feder_benef             as character       no-undo. /*local*/
    def var v_nom_benef                      as character       no-undo. /*local*/
    def var v_des_url_chave_pix              as character       no-undo. /*local*/ 
    def var v_des_codtxid                    as character       no-undo. /*local*/ 
    def var v_des_chave_pix                  as character       no-undo. /*local*/ 
    def var v_cod_id_chave_pix               as character       no-undo. /*local*/ 

    /************************** Variable Definition End *************************/

    if  p_cdn_segment_edi = 371
    then do: /* --- DETALHE ---*/
        /* ---- C¢digo do banco ----*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 288
            and   tt_param.tta_cdn_element_edi = 4681 no-error. 
        assign v_cod_banco = string(tt_param.ttv_des_contdo).
        /* --- Tipo de Pagamento ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3729 no-error.
        assign v_cdn_tip_forma_pagto = int(tt_param.ttv_des_contdo).
        /* --- Agància Banc†ria Empresa ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 288
            and   tt_param.tta_cdn_element_edi = 3901 no-error.
        if length(tt_param.ttv_des_contdo) > 4       
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 3).                
            else assign v_cdn_inicial = 1. 
        assign v_cod_agenc_bcia = substring(tt_param.ttv_des_contdo, v_cdn_inicial,4).
        /* --- D°gito Agància Banc†ria Empresa ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 288
            and   tt_param.tta_cdn_element_edi = 3902 no-error.
        assign v_cod_digito_agenc_bcia = substring(tt_param.ttv_des_contdo, 1,1).
        /* --- Conta Corrente Empresa ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 288
            and   tt_param.tta_cdn_element_edi = 3903 no-error.
        if length(tt_param.ttv_des_contdo) > 9
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 8).
            else assign v_cdn_inicial = 1.
        assign v_cod_cta_corren = substring(tt_param.ttv_des_contdo,v_cdn_inicial,9).
        /* --- D°gito Conta Corrente Empresa ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 288
            and   tt_param.tta_cdn_element_edi = 3904 no-error.
        assign v_cod_digito_cta_corren = substring(tt_param.ttv_des_contdo,1,1).
        /* --- N£mero do T°tulo ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3743 no-error.
        assign v_cod_tit_ap_bco = substring(tt_param.ttv_des_contdo,1,20).
        /* --- N£mero do T°tulo ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3928 no-error.
        assign v_cdn_contador = 20 - length(substring(tt_param.ttv_des_contdo,1,20)).

        assign v_cod_tit_ap = substring(tt_param.ttv_des_contdo,1,20) + fill(' ',v_cdn_contador).
        /* --- Banco do Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3737 no-error.
        if length(tt_param.ttv_des_contdo) > 3
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 2).
            else assign v_cdn_inicial = 1.
        assign v_cod_sist_nac_bcio_fav = string(int(substring(tt_param.ttv_des_contdo,v_cdn_inicial,3)),'999').

        /* --- Agància do Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3922 no-error.
        if length(tt_param.ttv_des_contdo) > 4
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 3).
            else assign v_cdn_inicial = 1.
        assign v_cod_agenc_bcia_fav = substring(tt_param.ttv_des_contdo,v_cdn_inicial,4).

        /* --- D°gito Agància Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 5143 no-error.
        assign v_cod_digito_agenc_bcia_fav = substring(tt_param.ttv_des_contdo,1,1).

        /* --- Conta Corrente Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3796 no-error.
        if length(tt_param.ttv_des_contdo) > 10
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 9).
            else assign v_cdn_inicial = 1.
        assign v_cod_cta_corren_fav = substring(tt_param.ttv_des_contdo,v_cdn_inicial,10).
        
        /* --- D°gito Conta Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3927 no-error.
        assign v_cod_digito_cta_corren_fav = trim(tt_param.ttv_des_contdo).

        if length(v_cod_digito_cta_corren_fav) = 2 then do:
            assign v_cod_cta_corren_fav        = trim(v_cod_cta_corren_fav) + substring(tt_param.ttv_des_contdo,1,1)
                   v_cod_digito_cta_corren_fav = substring(tt_param.ttv_des_contdo,2,1).
        end.
        if length(v_cod_digito_cta_corren_fav) = 0 then
            assign v_cod_digito_cta_corren_fav = ' '.
        assign v_cdn_contador      = 0.

        /* --- Nome do Favorecido ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3734 no-error.
        assign v_cdn_contador = 35 - length(substring(tt_param.ttv_des_contdo,1,35)).
        assign v_nom_favorec = substring(tt_param.ttv_des_contdo,1,35) + fill(' ',v_cdn_contador).
        /* --- Data Pagamento ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3709 no-error.
        assign v_cod_pagto_remes = substring(tt_param.ttv_des_contdo,1,2) + substring(tt_param.ttv_des_contdo,3,2) + substring(tt_param.ttv_des_contdo,5,4)
               v_cod_pagto_ocor  = substring(tt_param.ttv_des_contdo,1,2) + substring(tt_param.ttv_des_contdo,3,2) + substring(tt_param.ttv_des_contdo,5,4).
        /* --- Valor Pagamento ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4436 no-error.
        assign v_val_pagto = dec(tt_param.ttv_des_contdo).
        /* --- C¢digo do Serviáo da Empresa no Banco ---*/
        if v_cod_sist_nac_bcio_fav = '   ' then do: /* --- Banco do Brasil ---*/
            find tt_param
                where tt_param.tta_cdn_segment_edi = 288
                and   tt_param.tta_cdn_element_edi = 4641 no-error.
            assign v_num_servico = int(substring(tt_param.ttv_des_contdo, 1,3)).
        end.
        else /* --- Outros Bancos ---*/ assign v_num_servico = 17.

        /* * N£mero do Banco Destinat†rio **/
        /* find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4022 no-error.
        assign v_num_bco = int(substring(tt_param.ttv_des_contdo, 1,3)). */
        /* * Data de Vencimento do T°tulo **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3606 no-error.
        assign v_cod_vencto = substring(tt_param.ttv_des_contdo,1,2) + substring(tt_param.ttv_des_contdo,3,2) + substring(tt_param.ttv_des_contdo,5,4).
        /* * Valor do T°tulo **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4421 no-error.
        assign v_val_titulo = int(substring(tt_param.ttv_des_contdo, 1,17)).
        /* * Valor de Abatimentos **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4425 no-error.
        assign v_val_abat = int(substring(tt_param.ttv_des_contdo, 1,17)).
        /* * Valor de Descontos **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4423 no-error.
        assign v_val_desconto = int(substring(tt_param.ttv_des_contdo, 1,17)).
        assign v_val_tot_desc_abat = v_val_abat + v_val_desconto.
        /* * Juros **/
        find first tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4422 no-error.
        assign v_val_juros = int(substring(tt_param.ttv_des_contdo, 1,17)).
        /* * Multa **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4426 no-error.
        assign v_val_multa = int(substring(tt_param.ttv_des_contdo, 1,17)).
        /* * Correá∆o Monet†ria **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 4437 no-error.
        assign v_val_correc = int(substring(tt_param.ttv_des_contdo, 1,17)).
        assign v_val_acresc = v_val_juros + v_val_multa + v_val_correc.
        assign v_cdn_contador = 0.
        /* * C¢digo de Barras **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 2807 no-error.
        assign v_cdn_contador = 47 - length(substring(tt_param.ttv_des_contdo,1,47)).
        assign v_cod_barra_2 = substring(tt_param.ttv_des_contdo,1,47) + fill(' ',v_cdn_contador).
        run pi_retorna_cod_barra_leitora (input v_cod_barra_2, output v_cod_barra).
        /* * C¢digo Movimento **/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3933 no-error.
        assign v_cod_ocor_bcia = substring(tt_param.ttv_des_contdo, 1,2).
        /* --- Agància C¢digo do Cedente ---*/
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3922 no-error.
        if length(tt_param.ttv_des_contdo) > 20
            then assign v_cdn_inicial = (length(tt_param.ttv_des_contdo) - 19).
            else assign v_cdn_inicial = 1.
        assign v_cod_agenc_favorec_1 = substring(tt_param.ttv_des_contdo,v_cdn_inicial,20).
        /* tipo CGC/CPF Favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3915 no-error.
        assign v_num_tip_id_feder = int(tt_param.ttv_des_contdo).
        /* CGC/CPF favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3916 no-error.
        assign v_cod_id_feder_favorec = tt_param.ttv_des_contdo.
        /* Endereáo Favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3917 no-error.
        assign v_cod_ender_favorec = tt_param.ttv_des_contdo.
        /* Bairro favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3621 no-error.
        assign v_cod_bairro_favorec = tt_param.ttv_des_contdo.
        /* Cidade Favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3918 no-error.
        assign v_cod_cidad_favorec = tt_param.ttv_des_contdo.
        /* Cep Favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3920 no-error.
        assign v_cod_cep_favorec = tt_param.ttv_des_contdo.
        /* Estado Favorecido */
        find tt_param
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3919 no-error.
        assign v_cod_estado_favorec = tt_param.ttv_des_contdo.
        /* --- N£mero do T°tulo ---*/
        find tt_param no-lock
            where tt_param.tta_cdn_segment_edi = 289
            and   tt_param.tta_cdn_element_edi = 3928 no-error.
        assign v_log_pix           = no
               v_des_url_chave_pix = ""
               v_des_codtxid       = ""  
               v_des_chave_pix     = ""
               v_cod_id_chave_pix  = "".
        if  avail tt_param then do:
            find first item_bord_ap no-lock
                 where item_bord_ap.cod_estab_bord      = getentryfield(1,tt_param.ttv_des_contdo,';')
                 and   item_bord_ap.num_id_item_bord_ap = INT(getentryfield(2,tt_param.ttv_des_contdo,';')) no-error.

		    if not avail item_bord_ap then 
                find first item_bord_ap no-lock
                     where item_bord_ap.cod_estab_bord            = getentryfield(1,tt_param.ttv_des_contdo,';')
                       and item_bord_ap.num_id_agrup_item_bord_ap = INT(getentryfield(2,tt_param.ttv_des_contdo,';')) no-error.
            if  avail item_bord_ap then do:
                find first ems5.forma_pagto no-lock
                     where forma_pagto.cod_forma_pagto = item_bord_ap.cod_forma_pagto no-error.
                if  avail forma_pagto and forma_pagto.ind_tip_forma_pagto begins 'PIX' then do:
                    assign v_log_pix = yes.
                    &if defined(BF_FIN_PIX_APB) &then
                        assign v_des_url_chave_pix = item_bord_ap.dsl_qrcode
                               v_des_codtxid       = item_bord_ap.cod_txid
                               v_des_chave_pix     = item_bord_ap.cod_chave_pix_tit.
                    &else
                        assign v_des_chave_pix = getentryfield(4,item_bord_ap.cod_livre_2,chr(10))
                               v_des_codtxid   = getentryfield(5,item_bord_ap.cod_livre_2,chr(10))
                               v_des_url_chave_pix = getentryfield(6,item_bord_ap.cod_livre_2,chr(10)).
                    &endif.
                    find first chave_pix_fornec no-lock
                         where chave_pix_fornec.cod_empresa    = item_bord_ap.cod_empresa
                           and chave_pix_fornec.cdn_fornecedor = item_bord_ap.cdn_fornecedor
                           and chave_pix_fornec.cod_chave_pix  = v_des_chave_pix no-error.
                    if  avail chave_pix_fornec then do:
                        case chave_pix_fornec.ind_tip_chave_pix:
                            when "Celular"   then assign v_cod_id_chave_pix = '01'.
                            when "e-mail"    then assign v_cod_id_chave_pix = '02'.
                            when "cpf/CNPJ"  then assign v_cod_id_chave_pix = '03'.
                            when "Aleat¢ria" then assign v_cod_id_chave_pix = '04'.
                        end case.
                    end.

                    /*Quando for o Tipo 03 - CPF/CNPJ n∆o preencher a posiá∆o 128 a 226, 
                    os campos de CPF/CNPJ ser∆o enviados no Campo: N£mero de Inscriá∆o do favorecido das posiá‰es 19 a 32 do segmento B.*/
                    if v_cod_id_chave_pix = '03' then
                        assign v_des_chave_pix = ''.

                    assign v_log_pix_sem_chave = no.
                    &if defined(BF_FIN_PIX_AJUSTE_FS1) &then
                       assign v_log_pix_sem_chave = item_bord_ap.log_pix_sem_chave
                              v_ind_tip_cta_pix  = item_bord_ap.ind_tip_cta_pix  .
                    &else                                          
                        assign v_log_pix_sem_chave = if GetEntryField(7, item_bord_ap.cod_livre_2, chr(10)) = 'yes':u then yes else no
                               v_ind_tip_cta_pix   = GetEntryField(8,item_bord_ap.cod_livre_2,CHR(10)).
                    &endif  
                    /*Se o campo forma de iniciaá∆o (G100) for igual a 05 (dados Bancarios) - Deve ser
                    preenchido com o Tipo de Conta do recebedor posiá∆o (128 a 129)
                    N∆o ser† preenchida a chave PIX*/
                    if v_log_pix_sem_chave then do:


                        assign v_cod_id_chave_pix = '05'.
                        case v_ind_tip_cta_pix:
                             when "Conta Poupanáa"   then assign v_des_chave_pix = '03'.
                             when "Conta Pagamento"  then assign v_des_chave_pix = '02'.
                             otherwise assign v_des_chave_pix = '01'.
                        end case.

                    end.
                end.
            end.
        end.
        if  v_log_pix = yes then do:
            assign v_cod_campo_ctro              = '009'.

            if v_log_pix_sem_chave = no then 
                assign v_cod_sist_nac_bcio_fav       = '000'
                       v_cod_agenc_bcia_fav          = '00000'
                       v_cod_digito_agenc_bcia_fav   = ''
                       v_cod_cta_corren_fav          = '000000000000'
                       v_cod_digito_cta_corren_fav   = ''
                       v_cod_digito_agenc_cta_corren = ''.
        end.
        else do:
            if v_cdn_tip_forma_pagto    = 2 then /* DOC */    
                assign v_cod_forma      = '03'
                       v_cod_campo_ctro = '700'.

            if v_cdn_tip_forma_pagto    = 3 then /* Cr≤dito Conta Corrente */
                assign v_cod_forma      = '01'
                       v_cod_campo_ctro = '000'.

            if v_cdn_tip_forma_pagto    = 4 then /* Cheque Administrativo  */
                assign v_cod_forma      = '02'
                       v_cod_campo_ctro = '000'.

            /* Alterado por Amarildo para tratar Ordem de Pagamento*/
            if v_cdn_tip_forma_pagto    = 6 then /* ORDEM DE PAGAMENTO  */
               assign v_cod_forma      = '10'
                      v_cod_campo_ctro = '000'.
            /* Fim Amarildo */

            /* Alterado por Elisangela para tratar TED*/

            if v_cdn_tip_forma_pagto    = 7 then /* TED CIP  */
                assign v_cod_forma      = '03'
                       v_cod_campo_ctro = '018'.

            if v_cdn_tip_forma_pagto    = 8 then /* TED STR  */
                assign v_cod_forma      = '03'
                       v_cod_campo_ctro = '018'.

            /* Fim - Elisangela*/    
        end.

        if  v_cdn_tip_forma_pagto = 1 or  v_cdn_tip_forma_pagto = 5
        then do:
            if entry(4, v_cod_tit_ap, ';') = "" then 
               assign v_cod_tip_reg_boleto = '2'.
            else assign v_cod_tip_reg_boleto = '8'.
        end /* if */.
        
        /* --- DOC / CRêDITO CONTA CORRENTE / CHEQUE ADMINISTRATIVO / ORDEM DE PAGAMENTO / PIX TRANSFERENCIA ---*/   
        if  v_cdn_tip_forma_pagto = 2 or  v_cdn_tip_forma_pagto = 3 or  v_cdn_tip_forma_pagto = 4
        or  v_cdn_tip_forma_pagto = 6 or  v_cdn_tip_forma_pagto = 7 or  v_cdn_tip_forma_pagto = 8
        then do:        

            find first tt_param
                 where tt_param.tta_cdn_segment_edi = 0
                   and tt_param.tta_cdn_element_edi = 0 no-error.
            
            assign c-bloco = tt_param.ttv_des_contdo.

            if c-bloco = 'DOC' then    /* posicao 218 a 219 (Finalidade DOC) */
               assign v_cod_finalid_doc = "01".
            else
               assign v_cod_finalid_doc = "  ".  
            
            if c-bloco = 'TED STR' or c-bloco = 'TED CIP' then /* posicao 220 a 224 (Finalidade TED) */
               assign v_cod_finalid_ted   = "00010"
                      v_cod_finalid_compl = "CC". /* posicao 225 a 226 (Finalidade Complementar) */  
            else
               assign v_cod_finalid_ted   = "     "
                      v_cod_finalid_compl = "  ". /* posicao 225 a 226 (Finalidade Complementar) */  
            
            assign v_cod_det = caps('A' + '0' + string(v_cod_ocor_bcia,'99') + string(v_cod_campo_ctro,'999') + string(int(v_cod_sist_nac_bcio_fav),'999') +
                                   string(int(v_cod_agenc_bcia_fav),'99999') + string(substring(v_cod_digito_agenc_bcia_fav,1,1),'x') +
                                   string(dec(v_cod_cta_corren_fav),'999999999999') + string(substring(v_cod_digito_cta_corren_fav,1,1),'x') +
                                   string(substring(v_cod_digito_agenc_cta_corren,1,1),'x') + 
                                   /* Leon-10/09/2003 */
                                   string(v_nom_favorec,'x(30)') + string(v_cod_tit_ap,'x(20)') 
                                   + string(v_cod_pagto_ocor,'x(8)') + 'BRL' + fill('0',15) + string(v_val_pagto,'999999999999999') + fill(' ',20) +
                                   fill('0',23) + fill(' ',40) + string(v_cod_finalid_doc,"x(2)") + string(v_cod_finalid_ted,"x(5)") + string(v_cod_finalid_compl,"x(2)") + 
                                   fill(' ',3) +  fill('0',1) + fill(' ',10)).


            /* gera segunda parte - procura sequencia do registro */ 
            find first tt_segment_tot
                 where tt_segment_tot.tta_cdn_segment_edi = 371 no-error.

            if avail tt_segment_tot
            then do:
                assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                        tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1
                        v_num_reg_bloco                    = tt_segment_tot.ttv_qtd_bloco_docto.
            end.
            /* Atualiza somatΩria dos blocos*/
            find first tt_segment_tot
                 where tt_segment_tot.tta_cdn_segment_edi = 999999 no-error.

            if avail tt_segment_tot
            then do:
                assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                        tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1.
            end.

            /* localiza o bloco */
            find first tt_param
                 where tt_param.tta_cdn_segment_edi = 0
                   and tt_param.tta_cdn_element_edi = 2
                   and tt_param.tta_des_label_utiliz_formul_edi = 'QTD BLOCOS' no-error.
            if avail tt_param then
                 assign v_num_bloco = int(tt_param.ttv_des_contdo) + 1.

            if  v_log_pix then do:
                assign  v_cod_det = caps(v_cod_det + 
                                         chr(10) +  
                                         '237' + 
                                         string(v_num_bloco,'9999') + 
                                         '3' + 
                                         string(v_num_reg_bloco,'99999') + 
                                         'B' + 
                                         string(v_cod_id_chave_pix,"x(3)") + 
                                         string(v_num_tip_id_feder,'9') + 
                                         string(dec(v_cod_id_feder_favorec),'99999999999999') + 
                                         string(v_des_codtxid, 'x(30)')   + /* PIX - G101 - TX ID (opcional QR-CODE Est†tico) Posiá∆o (33 a 62) */
                                         fill(' ',65)                     + /* PIX - G101 -Identificaá∆o do pagamento Œ Informaá∆o entre usu†rios (opcional) Posiá∆o (63 a 127) */
                                         string(v_des_chave_pix, 'x(99)') + /* PIX - G101 -Identificaá∆o do favorecido Œ Chave PixPix : Email ou Telefone Posiá∆o (128 226 ) */
                                         fill('0',14) + chr(10)).
            end.
            else do:
                assign  v_cod_det = caps(v_cod_det + 
                                         chr(10) +  
                                         '237' + 
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
                                         fill(' ',15) + fill('0',1) + fill('0',14) + chr(10)).
            end.

            assign v_num_cont = v_num_cont + 1.
        end /* if */.

        /* --- BOLETO / PIX URL-Chave-Qrcode ---*/
        if  v_cdn_tip_forma_pagto = 1 or  v_cdn_tip_forma_pagto = 5
        then do:
            assign v_num_contador  = v_num_contador + 1
                   v_num_cont_val  = v_val_pagto + v_num_cont_val.

            /* localiza a instruá∆o de cobranáa para saber se Ç implantaá∆o/alteraá∆o ou estorno */
            find first ocor_bcia_bco no-lock
                where ocor_bcia_bco.cod_banco               = v_cod_banco
                and   ocor_bcia_bco.cod_modul_dtsul         = "APB" /*l_apb*/ 
                and   ocor_bcia_bco.ind_ocor_bcia_remes_ret = "Remessa" /*l_remessa*/ 
                and   ocor_bcia_bco.cod_ocor_bcia_bco       = v_cod_ocor_bcia no-error.
            if avail ocor_bcia_bco then do:
                if ocor_bcia_bco.ind_tip_ocor_bcia = "Implantaá∆o" /*l_implantacao*/  then
                    assign v_ind_tip_instruc = '0'. /* implantaá∆o */
                else
                    if ocor_bcia_bco.ind_tip_ocor_bcia begins "Alteraá∆o" /*l_alteracao*/ 
                    or ocor_bcia_bco.ind_tip_ocor_bcia begins "Acerto" /*l_acerto*/  then
                        assign v_ind_tip_instruc = '5'. /* alteraá∆o */
                    else
                        assign v_ind_tip_instruc = '9'. /* estorno */
            end.
            else
                assign v_ind_tip_instruc = '0'. /* sempre ser† implantaá∆o */

            assign v_cod_det = caps('J' + string(v_ind_tip_instruc,'x(1)') + string(v_cod_ocor_bcia,'x(2)') + string(v_cod_barra,'x(44)') +
                                    string(v_nom_favorec,'x(30)') + v_cod_vencto + string(v_val_titulo,'999999999999999') + string(v_val_tot_desc_abat,'999999999999999') +
                                    string(v_val_acresc,'999999999999999') + v_cod_pagto_remes + string(v_val_pagto,'999999999999999') +
                                    '000000000000000' + string(v_cod_tit_ap,'x(20)') + string(v_cod_tit_ap_bco,'x(20)') + '09' + fill(' ',6) + fill(' ',10)) + chr(10).
                                    
            /* In°cio - Alteraá∆o J-52 */
            
            /* gera segunda parte - procura sequencia do registro */ 
            find first tt_segment_tot
                 where tt_segment_tot.tta_cdn_segment_edi = 371 no-error.
                 
            if avail tt_segment_tot then
                assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                        tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1
                        v_num_reg_bloco                    = tt_segment_tot.ttv_qtd_bloco_docto.
                
            /* Atualiza somatΩria dos blocos*/
            find first tt_segment_tot no-lock
                 where tt_segment_tot.tta_cdn_segment_edi = 999999 no-error.
    
            if avail tt_segment_tot then
               assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                       tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1.
                       
            /* localiza o bloco */
            find first tt_param no-lock
                where tt_param.tta_cdn_segment_edi = 0
                and tt_param.tta_cdn_element_edi = 2
                and tt_param.tta_des_label_utiliz_formul_edi = 'QTD BLOCOS' no-error.
            if avail tt_param then
                assign v_num_bloco = int(tt_param.ttv_des_contdo) + 1.
                
            /* --- Codigo Banco ---*/
            find tt_param
                 where tt_param.tta_cdn_segment_edi = 288
                 and   tt_param.tta_cdn_element_edi = 4681 no-error.
            if avail tt_param then
               assign v_cdn_bco = int(tt_param.ttv_des_contdo).
               
            /* --- N£mero do T°tulo ---*/
            find tt_param no-lock
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 3928 no-error.
            if avail tt_param then do:
                /* --- Sacado ---*/
                find first estabelecimento no-lock
                where estabelecimento.cod_estab = getentryfield(1,tt_param.ttv_des_contdo,';') no-error.
                if avail estabelecimento then
                   assign v_num_tip_id_feder_pagad = 2
                          v_cod_id_feder_pagad     = string(estabelecimento.cod_id_feder,'99999999999999')
                          v_nom_pagad              = estabelecimento.nom_pessoa.  
            end.
            
            /* tipo CGC/CPF Favorecido */
            find tt_param no-lock
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 3915 no-error.
            if avail tt_param then
                assign v_num_tip_id_feder = int(tt_param.ttv_des_contdo).
                
            /* CGC/CPF favorecido */
            find tt_param no-lock
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 3916 no-error.
            if avail tt_param then
                assign v_cod_id_feder_favorec = tt_param.ttv_des_contdo.
                
            /* --- Nome do Favorecido ---*/
            find tt_param no-lock
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 3734 no-error.
            if avail tt_param then
                assign v_nom_favorec = tt_param.ttv_des_contdo.

            assign v_num_tip_id_benef   = v_num_tip_id_feder
                   v_cod_id_feder_benef = v_cod_id_feder_favorec
                   v_nom_benef          = v_nom_favorec.

            /* --- InformaªÑes Beneficiario/Fornecedor ---*/
            assign v_num_tip_id_feder_fornec = 0
                   v_cod_id_feder_fornec     = "000000000000000"
                   v_nom_fornec              = string(fill(" ", 40),"x(40)").

            &if defined(BF_FIN_BENEFICIARIO) &then 
                find tt_param no-lock
                    where tt_param.tta_cdn_segment_edi = 289
                    and   tt_param.tta_cdn_element_edi = 3928 no-error.
                if avail tt_param then do:
    
                    find first item_bord_ap no-lock
                         where item_bord_ap.cod_estab_bord      = getentryfield(1,tt_param.ttv_des_contdo,';')
                         and   item_bord_ap.num_id_item_bord_ap = INT(getentryfield(2,tt_param.ttv_des_contdo,';')) no-error.
                    if avail item_bord_ap then do:
                        find first tit_ap no-lock
                            where tit_ap.cod_estab = item_bord_ap.cod_estab
                              and tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
                              and tit_ap.cod_ser_docto = item_bord_ap.cod_ser_docto
                              and tit_ap.cdn_fornecedor = item_bord_ap.cdn_fornecedor
                              and tit_ap.cod_tit_ap = item_bord_ap.cod_tit_ap
                              and tit_ap.cod_parcela = item_bord_ap.cod_parcela no-error.
                        if avail tit_ap then do:
    
                            find first ext_tit_ap 
                                where ext_tit_ap.cod_estab     = tit_ap.cod_estab
                                  and ext_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap no-lock no-error.
                            if avail ext_tit_ap and ext_tit_ap.cod_id_feder_benef <> "" and ext_tit_ap.cod_id_feder_benef <> "0" then do:
                                /* Sacador - O fornecedor do boleto */
                                assign v_num_tip_id_feder_fornec = v_num_tip_id_feder
                                       v_cod_id_feder_fornec     = v_cod_id_feder_favorec  
                                       v_nom_fornec              = v_nom_favorec.
                               
                                if ext_tit_ap.ind_tip_pessoa_benef = "F°sica" then
                                    assign v_num_tip_id_benef = 1.
                                else
                                    assign v_num_tip_id_benef = 2.
    
                                assign v_cod_id_feder_benef = string(ext_tit_ap.cod_id_feder_benef,'999999999999999')
                                       v_nom_benef          = ext_tit_ap.nom_pessoa_benef. 
                                
                            end.
    
                        end.
                    end.
                end.
            &endif
                
            if  v_log_pix then do:
                assign v_des_j52   = string(v_cdn_bco,"999")                               + /* Codigo do Banco */
                                     string(v_num_bloco,"9999")                            + /* Codigo do Lote */
                                     "3"                                                   + /* Tipo de Registro */
                                     string(v_num_reg_bloco,"99999")                       + /* N£mero do Registro */
                                     "J"                                                   + /* Segmento */
                                     " "                                                   + /* Brancos */
                                     string(substr(v_cod_det,3,2),"99")                    + /* Tipo de Movimento */ 
                                     "52"                                                  + /* Codigo de Registro */
                                     string(v_num_tip_id_feder_pagad,"9")                  + /* Tipo Inscriá∆o Devedor */
                                     string(dec(v_cod_id_feder_pagad)  ,"999999999999999") + /* Numero Inscriá∆o Devedor */
                                     string(v_nom_pagad,"x(40)")                           + /* Nome Devedor */
                                     string(v_num_tip_id_benef,"9")                        + /* Tipo Inscriá∆o Favorecido */
                                     string(dec(v_cod_id_feder_benef),"999999999999999")   + /* Numero Inscriá∆o Favorecido */ 
                                     string(v_nom_benef,"x(40)")                           + /* Nome Favorecido */
                                     string(v_des_codtxid,'x(79)')                         + /* PIX - G102 - URL/Chave Endereáamento */
                                     string(v_des_url_chave_pix,'x(30)').                    /* PIX - G102 - C¢digo de Identificaá∆o do QR-Code */  
            end.
            else do:
                assign v_des_j52   = string(v_cdn_bco,"999")                               + /* Codigo do Banco */
                                     string(v_num_bloco,"9999")                            + /* Codigo do Lote */
                                     "3"                                                   + /* Tipo de Registro */
                                     string(v_num_reg_bloco,"99999")                       + /* N£mero do Registro */
                                     "J"                                                   + /* Segmento */
                                     " "                                                   + /* Brancos */
                                     string(substr(v_cod_det,3,2),"99")                    + /* Tipo de Movimento */ 
                                     "52"                                                  + /* Codigo de Registro */
                                     string(v_num_tip_id_feder_pagad,"9")                  + /* Tipo Inscriá∆o Pagador */
                                     string(dec(v_cod_id_feder_pagad)  ,"999999999999999") + /* Numero Inscriá∆o Pagador */
                                     string(v_nom_pagad,"x(40)")                           + /* Nome Pagador */
                                     string(v_num_tip_id_benef,"9")                        + /* Tipo Inscriá∆o Benefici†rio */
                                     string(dec(v_cod_id_feder_benef),"999999999999999")   + /* Numero Inscriá∆o Benefici†rio */ 
                                     string(v_nom_benef,"x(40)")                           + /* Nome Benefici†rio */ 
                                     string(v_num_tip_id_feder_fornec,"9")                 + /* Tipo Inscriá∆o Sacador/Avalista   - Dados sobre o Benefici†rio respons†vel pela emiss∆o do t°tulo original */
                                     string(dec(v_cod_id_feder_fornec),"999999999999999")  + /* Numero Inscriá∆o Sacador/Avalista - Dados sobre o Benefici†rio respons†vel pela emiss∆o do t°tulo original */
                                     string(v_nom_fornec,"x(40)").                           /* Nome Sacador/Avalista             - Dados sobre o Benefici†rio respons†vel pela emiss∆o do t°tulo original */
            end.

            assign v_des_j52   = v_des_j52 + fill(" ",(240 - length(v_des_j52)))
                   v_cod_det   = v_cod_det + v_des_j52 + chr(10).
                   
        end /* if */.
    end /* if */.
    
END PROCEDURE. /* pi_segto_tipo_A_J */

/*****************************************************************************
** Procedure Interna.....: pi_segto_tipo_N
** Descricao.............: pi_segto_tipo_N
** Criado por............: tech14020
** Criado em.............: 08/09/2006 10:21:22
** Alterado por..........: fut41420
** Alterado em...........: 11/11/2009 10:03:29
*****************************************************************************/
PROCEDURE pi_segto_tipo_N:

    /************************** Buffer Definition Begin *************************/
    def buffer b_pessoa_jurid
        for pessoa_jurid.
    /************************* Variable Definition Begin ************************/
    def var v_des_conteudo
        as character
        format "x(40)":U
        label "Texto"
        column-label "Texto"
        no-undo.
    def var v_cod_receita as char no-undo.
    def var v_estab as char no-undo.
    def var v_numid as int no-undo.
    def var v_valpagto as dec no-undo.
    def var v_txt_valpagto as char no-undo.
    def var v_num_contribuinte as dec no-undo.
    def var v_tip_contribuinte as char no-undo.
    def var c_inscricao as char no-undo.
    /************************** Variable Definition End *************************/
    assign v_cod_det = 'N' + '0'.

    find tt_param
         where tt_param.tta_cdn_segment_edi = 288
         and   tt_param.tta_cdn_element_edi = 4838 no-error. // Frm_Pagmto
    assign v_forma_pagto = trim(tt_param.ttv_des_contdo).
    
    find tt_param
        where tt_param.tta_cdn_segment_edi = 289
        and   tt_param.tta_cdn_element_edi = 3933 no-error. // Instr_Ocor

    assign v_cod_det = v_cod_det + substring(tt_param.ttv_des_contdo, 1,2). /*C¢digo da instruá∆o 16-17*/

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3928 no-lock no-error. // Cd_Tit_Emp
    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(20)" ). /* posicao 18 a 37 (Seu N£mero) */
    assign v_des_conteudo = tt_param.ttv_des_contdo.

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3743 /*Tit_Bco*/
         no-lock no-error.
    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(20)" ). /* posicao 38 a 57 (Nosso N£mero) */ 

    assign v_estab = getentryfield(1,v_des_conteudo,';')
           v_numid = int(getentryfield(2,v_des_conteudo,';')).

    if entry(3,v_des_conteudo,';') = "N" then
        find first item_bord_ap
             where item_bord_ap.cod_estab_bord      = v_estab
               and item_bord_ap.num_id_item_bord_ap = v_numid
               no-lock no-error.
    else
        find first item_bord_ap 
            where item_bord_ap.cod_estab_bord            = v_estab
            and   item_bord_ap.num_id_agrup_item_bord_ap = v_numid no-lock no-error.
    if  not avail item_bord_ap then
        return.

    find first estabelecimento
        where estabelecimento.cod_estab = item_bord_ap.cod_estab
        no-lock no-error.
    if  not avail estabelecimento then
        return.

    find b_pessoa_jurid
        where b_pessoa_jurid.num_pessoa_jurid = estabelecimento.num_pessoa_jurid
        no-lock no-error.
    if  not avail b_pessoa_jurid then
        return.

    assign v_tip_contribuinte = '01' /*CNPJ*/
           v_num_contribuinte = dec(SomenteNumeros(b_pessoa_jurid.cod_id_feder)).
    assign v_cod_det = v_cod_det  + string(b_pessoa_jurid.nom_pessoa,"x(30)"). /* posicao 58 a 87 - Nome Contribuinte */

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3709  // Dt_Pag_Tit
         no-lock no-error.
    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(08)" ).  /* posicao 88 a 95 (Data Pagamento)*/

    find first tt_param 
         where tt_param.tta_cdn_segment_edi = 289 
           and tt_param.tta_cdn_element_edi = 4436 no-lock no-error.  // Vlr_Pag_Tt (total)
    assign v_valpagto = dec(tt_param.ttv_des_contdo)
           v_txt_valpagto = string(dec(tt_param.ttv_des_contdo),'999999999999999')
           v_cod_det = v_cod_det + v_txt_valpagto. /* posicao 96 a 110 (Valor Pagamento) */

    find cst_tit_ap_tributo of item_bord_ap
        no-lock no-error.
    if  not avail cst_tit_ap_tributo then do:
        assign v_cod_det = v_cod_det + "Informaá‰es espec°ficas do tributo n∆o encontradas - prgint\edf\edf901zxBrad.py".
        return "".
    end.
    
    assign v_cod_det = v_cod_det + string(cst_tit_ap_tributo.cod_receita, "x(06)"). /* CΩdigo Receita 111-116*/                         

    case cst_tit_ap_tributo.tip_tributo:

       when 'DARF' then do:

            assign v_cod_det = v_cod_det + 
                                string(v_tip_contribuinte,'99') + /* Tipo Inscriá∆o 117-118*/
                                string(v_num_contribuinte,'99999999999999'). /* CNPJ Estabelecimento do T°tulo 119-132*/

            assign v_cod_det =  v_cod_det + '16'. /* IdentificaØ o Tributo 133-134*/

           
            assign v_cod_det = v_cod_det + string(cst_tit_ap_tributo.dat_competencia,"99999999").  // Per°odo de apuraá∆o 135-142

            assign v_cod_det = v_cod_det + fill("0", 17 - length(string(cst_tit_ap_tributo.num_referencia_darf)))
                                         + string(cst_tit_ap_tributo.num_referencia_darf).  // Numero de Referencia DARF 143-159

            find tt_param
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 4421 no-error. // Vlr_Nm_Tit
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'999999999999999'). /* Valor Principal 160-174*/

            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 4426  // Vlr_Mlt_Tt
                 no-lock no-error.
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'999999999999999'). /* Multa 175 - 189 */

            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 4422  // Vlr_Juro
                 no-lock no-error.
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'999999999999999'). /* Juros / Encargos 190-204*/
            
            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 3606  // Dt_Venc_Ti
                 no-lock no-error.
            assign v_cod_det = v_cod_det + trim(tt_param.ttv_des_contdo). /* Data Vencimento 205-212 */

            assign v_cod_det = v_cod_det + fill(' ', 18). // Brancos Uso exclusivo febraban 213-230
       end.


       when 'GPS' then do:

           assign v_cod_det = v_cod_det + 
                                string(cst_tit_ap_tributo.tip_identificador_gps,'99') + /* Tipo Inscriá∆o 117-118*/
                                string(cst_tit_ap_tributo.cod_identificador_gps,'99999999999999'). /* Identificaá∆o do Contribuinte 119-132*/

           assign v_cod_det = v_cod_det + '17'.  /* Identificaá∆o Tributo GPS 133-134 */

           assign v_cod_det = v_cod_det
                            + string(month(cst_tit_ap_tributo.dat_competencia),"99")
                            + string(year(cst_tit_ap_tributo.dat_competencia),"9999").  // Màs e Ano de Competància 135-140

           // OBS: o valor do titulo inclui "valor do tributo (INSS)" e "valor outras entidades (SEST/SENAI/..)"
           assign v_valpagto = v_valpagto - cst_tit_ap_tributo.val_outras_entidades_gps
                  v_txt_valpagto = string(v_valpagto,'999999999999999')
                  v_cod_det = v_cod_det + v_txt_valpagto. // Valor do Tributo - Valor previsto do pagamento do INSS pos.141-155
           assign v_valpagto = cst_tit_ap_tributo.val_outras_entidades_gps
                  v_txt_valpagto = string(v_valpagto,'999999999999999')
                  v_cod_det = v_cod_det + v_txt_valpagto. // Valor Outras Entidades (SEST/SENAI/...) pos.156-170

           assign v_cod_det = v_cod_det + '000000000000000' +  /* atualizaá∆o monetaria 171-185 */                  
                              string(' ',"x(45)"). /* Uso Febraban 186-230 */
        end.


        when 'GARE-SP' then do:

            assign v_cod_det = v_cod_det + 
                                 string(v_tip_contribuinte,'99') + /* Tipo Inscriá∆o 117-118*/
                                 string(v_num_contribuinte,'99999999999999'). /* CNPJ Estabelecimento do T°tulo 119-132*/

            assign v_cod_det =  v_cod_det + '22'. /* Identificaá∆o Tributo 133-134*/

            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 3606  // Dt_Venc_Ti
                 no-lock no-error.
            assign v_cod_det = v_cod_det + trim(tt_param.ttv_des_contdo). /* Data Vencimento 135-142 */

            // Encontra a Inscriá∆o Estadual do estabelecimento do t°tulo.
            find estabelec
                where estabelec.cod-estabel = item_bord_ap.cod_estab
                no-lock no-error.
            if  not avail estabelec then do:
                assign v_cod_det = v_cod_det + "N∆o localizado o estabelecimento:" + item_bord_ap.cod_estab.
                return "".
            end.
            assign c_inscricao = SomenteNumeros( estabelec.ins-estadual )
                   c_inscricao = fill('0', 12 - length(c_inscricao))
                               + c_inscricao.
            assign v_cod_det = v_cod_det + c_inscricao. // Inscriá∆o Estadual pos.143-154

            assign v_cod_det = v_cod_det + '0000000000000'.  // D°vida Ativa / Etiqueta pos.155-167
            
            assign v_cod_det = v_cod_det
                            + string(month(cst_tit_ap_tributo.dat_competencia),"99")
                            + string(year(cst_tit_ap_tributo.dat_competencia),"9999").  // Màs e Ano de Referància 168-173

            assign v_cod_det = v_cod_det + '0000000000000'.  // Numero da Parcela / Notificaá∆o pos. 174-186

            find tt_param
                where tt_param.tta_cdn_segment_edi = 289
                and   tt_param.tta_cdn_element_edi = 4421 no-error. // Vlr_Nm_Tit
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'999999999999999'). /* Valor da Receita 187-201 */

            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 4422  // Vlr_Juro
                 no-lock no-error.
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'99999999999999'). /* Juros / Encargos 202-215 */
            
            find first tt_param where
                 tt_param.tta_cdn_segment_edi = 289 and
                 tt_param.tta_cdn_element_edi = 4426  // Vlr_Mlt_Tt
                 no-lock no-error.
            assign v_cod_det = v_cod_det + string(dec(tt_param.ttv_des_contdo),'99999999999999'). /* Multa 216-229 */

            assign v_cod_det = v_cod_det + ' '. // Brancos Uso exclusivo febraban 230-230
        end.

        otherwise do:
            assign v_cod_det = v_cod_det + "Houve um problema, o tipo de tributo n∆o foi identificado:" + cst_tit_ap_tributo.tip_tributo.
            return "".
        end.
    end case.
    
    assign v_cod_det = v_cod_det + fill(' ', 10). // Brancos Uso exclusivo febraban 231-240
    assign v_cod_det = v_cod_det + chr(10). /* Gera quebra de linha */
                 
END PROCEDURE. /* pi_segto_tipo_N */
/*****************************************************************************
** Procedure Interna.....: pi_segto_tipo_O
** Descricao.............: pi_segto_tipo_O
** Criado por............: tech14020
** Criado em.............: 08/09/2006 10:23:26
** Alterado por..........: Diomar MÅhlmann
** Alterado em...........: 14/01/2020 - 12:00:00
*****************************************************************************/
PROCEDURE pi_segto_tipo_O:

    /************************** Buffer Definition Begin *************************/
    def buffer b_pessoa_jurid
        for pessoa_jurid.
    /************************* Variable Definition Begin ************************/
    def var v_des_conteudo
        as character
        format "x(40)":U
        label "Texto"
        column-label "Texto"
        no-undo.
    def var v_cod_receita as char no-undo.
    def var v_estab as char no-undo.
    def var v_numid as int no-undo.
    def var v_num_contribuinte as dec no-undo.
    /************************** Variable Definition End *************************/
    
    /* * C¢digo Movimento **/
    find tt_param
        where tt_param.tta_cdn_segment_edi = 289
          and   tt_param.tta_cdn_element_edi = 3933 no-error. // Instr_Ocor exemplo: 00
    assign v_cod_ocor_bcia = substring(tt_param.ttv_des_contdo, 1,2).

    assign v_cod_det = caps('O' + '0' + v_cod_ocor_bcia).

    find tt_param
        where tt_param.tta_cdn_segment_edi = 289
        and   tt_param.tta_cdn_element_edi = 2807 no-error. // Cod_barras

    if length(trim(tt_param.ttv_des_contdo)) >= 48 then
       assign v_cod_det = v_cod_det + substring(tt_param.ttv_des_contdo,1,11)  +
                                      substring(tt_param.ttv_des_contdo,13,11) +
                                      substring(tt_param.ttv_des_contdo,25,11) +
                                      substring(tt_param.ttv_des_contdo,37,11).             /* posicao 018 a 061 (Codigo de barras) */
    else
       assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(44)" /*l_x(44)*/ ). /* posicao 018 a 061 (Codigo de barras) */

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3734  // Nome_fav
         no-lock no-error.

    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(30)" /*l_x(30)*/ ). /* posicao 062 a 091 (Nome Concession†ria)*/

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3606  // Dt_Venc_Ti
         no-lock no-error.
    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(08)" /*l_x(08)*/ ). /* posicao 092 a 99 (Data Vencimento)*/
                         
    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3709  // Dt_Pag_Tit
         no-lock no-error.

    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(08)" ).  /* posicao 100 a 107 (Data Pagamento)*/

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         //tt_param.tta_cdn_element_edi = 4421  // Vlr_Nm_Tit (substituido pelo Vlr_Pagto pois n∆o estava incluindo os juros - Eduardo Barth 23/06/2023)
         tt_param.tta_cdn_element_edi = 4436  // Vlr_Pagto
         no-lock no-error.

    assign v_dec_aux = dec(tt_param.ttv_des_contdo).
    assign v_cod_det = v_cod_det + string(v_dec_aux,'999999999999999'). /* posicao 108 a 122 (Valor Pagamento) */

    find first tt_param where
         tt_param.tta_cdn_segment_edi = 289 and
         tt_param.tta_cdn_element_edi = 3928  // Cd_Tit_Emp
         no-lock no-error.

    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(20)" ). /* posicao 123 a 142 (Seu Número) */
    assign v_estab = getentryfield(1,tt_param.ttv_des_contdo,';')
           v_numid = int(getentryfield(2,tt_param.ttv_des_contdo,';')).

    if entry(3,tt_param.ttv_des_contdo,';') = "N" then
        find first item_bord_ap
             where item_bord_ap.cod_estab_bord      = v_estab
               and item_bord_ap.num_id_item_bord_ap = v_numid
               no-lock no-error.
    else
        find first item_bord_ap 
            where item_bord_ap.cod_estab_bord            = v_estab
            and   item_bord_ap.num_id_agrup_item_bord_ap = v_numid no-lock no-error.
    if  not avail item_bord_ap then do:
        assign v_cod_det = v_cod_det + "Informaá‰es do item do borderì n∆o encontradas - prgint\edf\edf901zxBrad.py".
        return "".
    end.

    find first tt_param where
        tt_param.tta_cdn_segment_edi = 289 and
        tt_param.tta_cdn_element_edi = 3743 /*Tit_Bco*/
        no-lock no-error.
    assign v_cod_det = v_cod_det + string(tt_param.ttv_des_contdo,"x(20)" ). /* posicao 143 a 162 (Nosso Número) */ 

    assign v_cod_det = v_cod_det +
                       fill(' ',68) + /* posicao 163 a 230 (Uso FEBRABAN) */  
                       fill(' ',10). /* posicao 230 a 240 (Ocorrencias) */  

    assign v_cod_det = v_cod_det + chr(10).  // acrescenta quebra de linha

    if  c_tipolote = "PagtoFGTS" then do:

        // Acrescenta segmento W com detalhes da guia do FGTS

        /* gera segunda parte - procura sequencia do registro */ 
        find first tt_segment_tot
             where tt_segment_tot.tta_cdn_segment_edi = 371 no-error.
        if avail tt_segment_tot
        then do:
            assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                    tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1
                    v_num_reg_bloco                    = tt_segment_tot.ttv_qtd_bloco_docto.
        end.
        /* Atualiza somatΩria dos blocos*/
        find first tt_segment_tot
             where tt_segment_tot.tta_cdn_segment_edi = 999999 no-error.
        if avail tt_segment_tot
        then do:
            assign  tt_segment_tot.ttv_qtd_proces_edi  = tt_segment_tot.ttv_qtd_proces_edi  + 1
                    tt_segment_tot.ttv_qtd_bloco_docto = tt_segment_tot.ttv_qtd_bloco_docto + 1.
        end.
        /* localiza o bloco */
        find first tt_param
             where tt_param.tta_cdn_segment_edi = 0
               and tt_param.tta_cdn_element_edi = 2
               and tt_param.tta_des_label_utiliz_formul_edi = 'QTD BLOCOS' no-error.
        if avail tt_param then
             assign v_num_bloco = int(tt_param.ttv_des_contdo) + 1.

         find cst_tit_ap_tributo of item_bord_ap
             no-lock no-error.
         if  not avail cst_tit_ap_tributo then do:
             assign v_cod_det = v_cod_det + "Informaá‰es espec°ficas do tributo n∆o encontradas - prgint\edf\edf901zxBrad.py".
             return "".
         end.

         /* Codigo Receita (6 posicoes) deve estar alinhada a direita. */
         assign v_cod_receita = string(cst_tit_ap_tributo.cod_receita, "x(06)").

         find first estabelecimento
             where estabelecimento.cod_estab = item_bord_ap.cod_estab
             no-lock no-error.
         if  not avail estabelecimento then
             return.

         find b_pessoa_jurid
             where b_pessoa_jurid.num_pessoa_jurid = estabelecimento.num_pessoa_jurid
             no-lock no-error.
         if  not avail b_pessoa_jurid then
             return.

         assign v_num_contribuinte = dec(SomenteNumeros(b_pessoa_jurid.cod_id_feder)).

         assign v_cod_det = v_cod_det +
                              '001'                           + /* Codigo do Banco */
                              string(v_num_bloco,"9999")      + /* Codigo do Lote */
                              "3"                             + /* Tipo de Registro */
                              string(v_num_reg_bloco,"99999") + /* N£mero do Registro */
                              "W"                             + /* Segmento W */
                              '1'                             + /* posicao 15 a 15 Nr. Sequencial Registro Complementar */
                              '1'                             + /* posicao 16 a 16 C¢d. Uso Informaá∆o Complementar  */
                              fill(' ',80)     + /* posicao 17 a 96  Informaá∆o Complementar 1  */
                              fill(' ',80)     + /* posicao 97 a 176 Informaá∆o Complementar 2  */
                              '01'             + /* posicao 177 a 178 Identificador de Tributo (FGTS=01) */
                              v_cod_receita    + /* posicao 179 a 184 C¢digo da Receita do Tributo */
                              '01'             + /* posicao 185 a 186 Tipo de Identificaá∆o do Contribuinte - 01-CNPJ */
                              string(v_num_contribuinte,'99999999999999') +  /* posicao 187 a 200 Identificaá∆o do Contribuinte */
                              string(cst_tit_ap_tributo.cod_identificador_fgts,"x(16)") + /* posicao 201 a 216 Campo Identificador do FGTS */
                              '         '      + /* posicao 217 a 225 Lacre do Conectividade Social */
                              '  '             + /* posicao 226 a 227 D°gito do Lacre do Conectividade Social */
                              '   '            + /* posicao 228 a 230 Brancos  */
                              '0000000000'     + /* posicao 231 a 240 C¢digo das Ocorràncias p/Retorno  */
                              chr(10).           /* para encerrar a linha com 240 caracteres */
    end.

END PROCEDURE. /* pi_segto_tipo_O */
/************************** Internal Procedure End **************************/
