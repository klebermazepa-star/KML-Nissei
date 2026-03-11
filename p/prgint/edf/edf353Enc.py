def var c-versao-prg as char initial " 1.00.00.001":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=0":U.
/*************************************  *************************************/

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_param_program_formul no-undo
    field tta_cdn_segment_edi              as int format ">>>>>9" initial 0 label "Segmento" column-label "Segmento"
    field tta_cdn_element_edi              as int format ">>>>>9" initial 0 label "Elemento" column-label "Elemento"
    field tta_des_label_utiliz_formul_edi  as char format "x(10)" label "Label Utiliz Formula" column-label "Label Utiliz Formula"
    field ttv_des_contdo                   as char format "x(47)" label "Conteudo" column-label "Conteudo"
    index tt_param_program_formul_id       is primary
          tta_cdn_segment_edi              ascending
          tta_cdn_element_edi              ascending.

/************************ Parameter Definition Begin ************************/

def Input param p_cdn_mapa_edi    as Int form ">>>>>9" no-undo.
def Input param p_cdn_segment_edi as Int form ">>>>>9" no-undo.
def Input param p_cdn_element_edi as Int form ">>>>>9" no-undo.
def Input param table for tt_param_program_formul.

/* ************************ Parameter Definition End *************************/

def NEW GLOBAL SHARED VAR h_cod_estab_bord    as CHARACTER    no-undo.  
def NEW GLOBAL SHARED VAR h_cod_portador      as CHARACTER    no-undo.  
def NEW GLOBAL SHARED VAR h_num_bord_ap       as INTEGER      no-undo.

def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

   find first tt_param_program_formul
        where tt_param_program_formul.tta_cdn_segment_edi = 288
        and   tt_param_program_formul.tta_cdn_element_edi = 003729 
        no-error.
   if avail tt_param_program_formul then do:
       case INT(tt_param_program_formul.ttv_des_contdo) :
           when 2 /*l_doc*/  then
               run piRetornaValorTaxaEngargo.
           when 3 /*l_credito_cc*/  then
               run piRetornaValorTaxaEngargo.
           when 7 /*l_ted_cip*/  then
               run piRetornaValorTaxaEngargo.
           when 8 /*l_ted_str*/  then
               run piRetornaValorTaxaEngargo.
       end.
   end.
   else do:
       return "0".
   end.


PROCEDURE piRetornaValorTaxaEngargo:
    DEFINE VAR vValorEncargo AS CHAR NO-UNDO.

    find first bord_ap no-lock
         where bord_ap.cod_estab_bord = h_cod_estab_bord
           and bord_ap.cod_portador   = h_cod_portador  
           and bord_ap.num_bord_ap    = h_num_bord_ap    no-error.
    if avail bord_ap then do:
        assign vValorEncargo = STRING(DEC((bord_ap.val_tot_lote_pagto_infor * (bord_ap.val_livre_1)/ 100 )) * 100,"9999999999999") .

        return vValorEncargo.
    end.
    else do:
        return "0".
    end.
    
END PROCEDURE.

