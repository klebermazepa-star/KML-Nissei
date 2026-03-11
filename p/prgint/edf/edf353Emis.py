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
               run piRetornaValorEmissao.
           when 3 /*l_credito_cc*/  then
               run piRetornaValorEmissao.
           when 7 /*l_ted_cip*/  then
               run piRetornaValorEmissao.
           when 8 /*l_ted_str*/  then
               run piRetornaValorEmissao.
       end.
   end.
   else do:
       return "0".
   end.


PROCEDURE piRetornaValorEmissao:
    DEFINE VAR vValorEmissao AS CHAR NO-UNDO.
    DEFINE VAR dValorEmissao AS DATE NO-UNDO.

    ASSIGN dValorEmissao = ?.
    
    FIND FIRST bord_ap NO-LOCK
         WHERE bord_ap.cod_estab_bord = h_cod_estab_bord
           AND bord_ap.cod_portador   = h_cod_portador  
           AND bord_ap.num_bord_ap    = h_num_bord_ap    NO-ERROR.
    IF AVAIL bord_ap THEN DO:

        FOR EACH item_bord_ap OF bord_ap NO-LOCK:

            IF dValorEmissao = ? THEN DO:

                FIND FIRST tit_ap NO-LOCK
                     WHERE tit_ap.cod_estab       = item_bord_ap.cod_estab      
                       AND tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor 
                       AND tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
                       AND tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto  
                       AND tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap     
                       AND tit_ap.cod_parcela     = item_bord_ap.cod_parcela     NO-ERROR.
                IF AVAIL tit_ap THEN DO: 
                    ASSIGN dValorEmissao = tit_ap.dat_emis_docto.
                END.
            END.
            ELSE DO:

                FIND FIRST tit_ap NO-LOCK
                     WHERE tit_ap.cod_estab       = item_bord_ap.cod_estab      
                       AND tit_ap.cdn_fornecedor  = item_bord_ap.cdn_fornecedor 
                       AND tit_ap.cod_espec_docto = item_bord_ap.cod_espec_docto
                       AND tit_ap.cod_ser_docto   = item_bord_ap.cod_ser_docto  
                       AND tit_ap.cod_tit_ap      = item_bord_ap.cod_tit_ap     
                       AND tit_ap.cod_parcela     = item_bord_ap.cod_parcela     NO-ERROR.
                IF AVAIL tit_ap THEN DO:
                    IF tit_ap.dat_emis_docto < dValorEmissao THEN
                        ASSIGN dValorEmissao = tit_ap.dat_emis_docto.
                END.
            END.
        END.

        ASSIGN vValorEmissao = REPLACE(STRING(dValorEmissao,"99/99/9999"),"/","").

        RETURN vValorEmissao.
    END.
    ELSE DO:
        RETURN "00000000".
    END.
    
END PROCEDURE.


