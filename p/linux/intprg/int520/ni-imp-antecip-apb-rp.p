/********************************************************************************
**
**  Programa - NI-IMP-ANTECIP-APB-RP.P - Importaá∆o Antecipaá∆o
**
********************************************************************************/ 

{include/i-prgvrs.i NI-IMP-ANTECIP-APB-RP 2.00.00.000 } 

DISABLE TRIGGERS FOR LOAD OF aprop_ctbl_pend_ap.
DISABLE TRIGGERS FOR LOAD OF antecip_pef_pend.

def new global shared var c-seg-usuario as char no-undo.


def new shared temp-table tt_compl_histor_padr_valor        
    field tta_cod_compl_padr               as character format "x(8)" label "Complemento Padr∆o" column-label "Comp Pad"
    field tta_cod_format_compl_padr        as character format "x(20)" label "Formato Complemento" column-label "Formato Complemento"
    field ttv_des_val_compl_padr           as character format "x(20)"
    index tt_id                            is primary unique
          tta_cod_compl_padr               ascending
    .

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

def new shared temp-table tt_dat_correc no-undo
    field ttv_dat_correc                   as date format "99/99/9999" initial today label "Data Correá∆o" column-label "Data Correá∆o"
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

def new shared temp-table tt_erros_cotac_parid no-undo
    field tta_cod_indic_econ_base          as character format "x(8)" label "Moeda Base" column-label "Moeda Base"
    field tta_cod_indic_econ_idx           as character format "x(8)" label "Moeda ÷ndice" column-label "Moeda ÷ndice"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cotaá∆o" column-label "Data Cotaá∆o"
    field tta_ind_tip_cotac_parid          as character format "X(09)" label "Tipo Cotaá∆o" column-label "Tipo  Cotaá∆o"
    index tt_id_erros                      is primary unique
          tta_cod_indic_econ_base          ascending
          tta_cod_indic_econ_idx           ascending
          tta_dat_cotac_indic_econ         ascending
          tta_ind_tip_cotac_parid          ascending
    .

def new shared temp-table tt_item_bord_lote_mensagem no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_num_seq_bord                 as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer_antecip_pef        as character format "x(10)" label "Ref Antec PEF Pend" column-label "Ref Antec PEF Pend"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_pagto                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Pagamento" column-label "Valor Pagto"
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

def new shared temp-table tt_log_erros_tit_antecip no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_tit_ap                   as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_refer                    as character format "x(10)" label "Referància" column-label "Referància"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agància Banc†ria" column-label "Agància Banc†ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_talon_cheq               as integer format ">>>,>>>,>>9" initial 0 label "Talon†rio Cheques" column-label "Talon†rio Cheques"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field ttv_log_atlzdo                   as logical format "Sim/N∆o" initial yes
    field tta_nom_favorec_cheq             as character format "x(40)" label "Nome Favorecido" column-label "Nome Favorecido"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Data Emiss∆o" column-label "Dt Emiss"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequància" column-label "Seq"
    field ttv_des_msg_erro_1               as character format "x(80)" label "Mensagem de Erro" column-label "Mensagem de Erro"
    field ttv_cod_bord_ap                  as character format "x(6)" label "Borderì" column-label "Borderì"
    field ttv_cod_seq_cheq                 as character format "x(2)" label "Sequància" column-label "Sequància"
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

def new shared temp-table tt_vl_sdo_un_origem no-undo
    field ttv_cod_unid_negoc_orig          as character format "x(3)" label "Unid Negoc" column-label "Unid Negoc"
    field ttv_val_sdo_unid_negoc           as decimal format "->>>,>>>,>>9.99" decimals 2 label "Saldo UN" column-label "Saldo UN"
    field ttv_val_tot_transfdo             as decimal format "->>>,>>>,>>9.99" decimals 2 label "Total Transferido" column-label "Total Transferido"
    .

def new shared temp-table tt_vl_transfdo_un no-undo
    field ttv_cod_unid_negoc_orig          as character format "x(3)" label "Unid Negoc" column-label "Unid Negoc"
    field ttv_cod_unid_negoc_dest          as character format "x(3)" label "UN Destino" column-label "UN Destino"
    field ttv_val_transfdo                 as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Transferido" column-label "Valor Transferido"
    field ttv_val_perc_transf              as decimal format ">>9.9999999999" decimals 10
    index tt_un_orig_dest                  is primary unique
          ttv_cod_unid_negoc_orig          ascending
          ttv_cod_unid_negoc_dest          ascending
.

define temp-table tt-param
    field destino          as integer
    field arq-destino      as char
    field arq-entrada1     as char
    field todos            as integer
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer.

def temp-table tt-raw-digita                      
    field raw-digita      as raw.                 

DEF TEMP-TABLE tt-antecip             
    FIELD cod_estab         LIKE antecip_pef_pend.cod_estab        
    FIELD cod_ser_docto     LIKE antecip_pef_pend.cod_ser_docto 
    FIELD cod_espec_docto   LIKE antecip_pef_pend.cod_espec_docto    
    FIELD cdn_fornecedor    LIKE antecip_pef_pend.cdn_fornecedor                 
    FIELD cod_tit_ap        LIKE antecip_pef_pend.cod_tit_ap          
    FIELD cod_parcela       LIKE antecip_pef_pend.cod_parcela         
    FIELD val_tit_ap        LIKE antecip_pef_pend.val_tit_ap             
    FIELD dat_emis_docto    LIKE antecip_pef_pend.dat_emis_docto           
    FIELD dat_vencto_tit_ap LIKE antecip_pef_pend.dat_vencto_tit_ap
    FIELD c-nota            AS CHAR
    FIELD dt-nota           AS DATE FORMAT "99/99/9999".

DEF TEMP-TABLE tt-erro
    FIELD desc-erro AS CHAR FORMAT "x(50)".

DEF VAR i-cont        AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR h-acomp       AS HANDLE                   NO-UNDO.
DEF VAR c-time        AS CHAR                     NO-UNDO.
DEF VAR c-refer       AS CHAR                     NO-UNDO.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Importaá∆o Antecipaá∆o").

EMPTY TEMP-TABLE tt-antecip.
EMPTY TEMP-TABLE tt-erro.
 
ASSIGN i-cont = 0.

INPUT FROM VALUE(tt-param.arq-entrada1) CONVERT SOURCE "ISO8859-1".

REPEAT:  
   CREATE tt-antecip.
   IMPORT DELIMITER ";" tt-antecip.  

   assign i-cont = i-cont + 1.
   run pi-acompanhar in h-acomp (input "Criando tt-antecip: " + string(i-cont,">>>,>>>,>>9")).
END. 
    
INPUT CLOSE.
  
ASSIGN i-cont = 0.
                                                                                               
for each tt-antecip WHERE 
         tt-antecip.val_tit_ap     <> 0  AND
         tt-antecip.cod_estab      <> "" AND
         tt-antecip.cdn_fornecedor <> 0:

    assign i-cont = i-cont + 1.
    run pi-acompanhar in h-acomp (input "Validando Registros: " + string(i-cont)).

    FOR FIRST estabelecimento WHERE
              estabelecimento.cod_estab = tt-antecip.cod_estab NO-LOCK:
    END.
    IF NOT AVAIL estabelecimento THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.desc-erro = "Estabelecimento " + tt-antecip.cod_estab + " n∆o cadastrado".
    END.

    FOR FIRST emscad.fornecedor WHERE
              emscad.fornecedor.cod_empresa    = "1" AND
              emscad.fornecedor.cdn_fornecedor = tt-antecip.cdn_fornecedor NO-LOCK:
    END.
    IF NOT AVAIL emscad.fornecedor THEN DO:
       CREATE tt-erro.
       ASSIGN tt-erro.desc-erro = "Fornecedor " + string(tt-antecip.cdn_fornecedor) + " n∆o cadastrado".
    END.
END.

ASSIGN i-cont = 0.

FOR FIRST tt-erro NO-LOCK:
END.
IF AVAIL tt-erro THEN DO:
   MESSAGE "Arquivo de Antecipaá‰es n∆o importado. Verifique log de erros."
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END.
ELSE DO:

    /*OUTPUT TO c:/temp/titulo.txt.*/

    for each tt-antecip WHERE 
             tt-antecip.val_tit_ap     <> 0  AND
             tt-antecip.cod_estab      <> "" AND
             tt-antecip.cdn_fornecedor <> 0:
    
        assign i-cont = i-cont + 1.
    
        run pi-acompanhar in h-acomp (input "Atualizando: " + string(tt-antecip.cod_tit_ap) + " - " + string(i-cont)).
    
        /*FOR FIRST tit_ap WHERE
                  tit_ap.cod_estab          = tt-antecip.cod_estab       AND
                  tit_ap.cdn_fornecedor     = tt-antecip.cdn_fornecedor  AND
                  tit_ap.cod_espec_docto    = tt-antecip.cod_espec_docto AND
                  tit_ap.cod_ser_docto      = tt-antecip.cod_ser_docto   AND
                  tit_ap.cod_tit_ap         = tt-antecip.cod_tit_ap      AND
                  tit_ap.cod_parcela        = tt-antecip.cod_parcela     AND
                  tit_ap.log_tit_ap_estordo = NO NO-LOCK:
        END.
        IF AVAIL tit_ap THEN
           DISP tit_ap.cod_estab      
                tit_ap.cdn_fornecedor 
                tit_ap.cod_espec_docto
                tit_ap.cod_ser_docto  
                tit_ap.cod_tit_ap     
                tit_ap.cod_parcela
                tit_ap.dat_transacao    
                tit_ap.val_origin_tit_ap             
                WITH STREAM-IO NO-BOX WIDTH 300 DOWN FRAME f-titulo.*/

        FOR FIRST emscad.fornecedor WHERE
                  emscad.fornecedor.cod_empresa    = "1" AND
                  emscad.fornecedor.cdn_fornecedor = tt-antecip.cdn_fornecedor NO-LOCK:
        END.
    
        /***** ANTECIPAÄ«O *****/
    
        DO TRANS:

            bloco-antec:
            REPEAT:
               ASSIGN c-time  = STRING(TIME)
                      c-refer = "AE" + c-time.

               FOR FIRST antecip_pef_pend WHERE
                         antecip_pef_pend.cod_estab = tt-antecip.cod_estab AND
                         antecip_pef_pend.cod_refer = c-time NO-LOCK:
               END.
               IF NOT AVAIL antecip_pef_pend THEN DO:
                  CREATE antecip_pef_pend.
                  ASSIGN antecip_pef_pend.cod_estab             = tt-antecip.cod_estab        
                         antecip_pef_pend.cod_ser_docto         = tt-antecip.cod_ser_docto     
                         antecip_pef_pend.cod_espec_docto       = tt-antecip.cod_espec_docto        
                         antecip_pef_pend.cdn_fornecedor        = tt-antecip.cdn_fornecedor                      
                         antecip_pef_pend.cod_tit_ap            = tt-antecip.cod_tit_ap                   
                         antecip_pef_pend.cod_parcela           = tt-antecip.cod_parcela                 
                         antecip_pef_pend.val_tit_ap            = tt-antecip.val_tit_ap       
                         antecip_pef_pend.val_cotac_indic_econ  = 1
                         antecip_pef_pend.dat_emis_docto        = tt-antecip.dat_emis_docto           
                         antecip_pef_pend.dat_vencto_tit_ap     = tt-antecip.dat_vencto_tit_ap
                         antecip_pef_pend.ind_tip_refer         = "Antecipaá∆o"
                         antecip_pef_pend.cod_cart_bcia         = "APB"
                         antecip_pef_pend.cod_empresa           = "1"  
                         antecip_pef_pend.cod_portador          = "" 
                         antecip_pef_pend.ind_sit_pef_antecip   = "Pend"
                         antecip_pef_pend.cod_indic_econ        = "Real"
                         antecip_pef_pend.ind_origin_tit_ap     = "APB"
                         antecip_pef_pend.cod_usuar_pagto       = "SUPER"
                         antecip_pef_pend.cod_finalid_econ      = "Corrente"   
                         antecip_pef_pend.dat_prev_pagto        = tt-antecip.dat_vencto_tit_ap    
                         antecip_pef_pend.cod_usuar_gerac_movto = "SUPER"  
                         antecip_pef_pend.num_pessoa            = IF AVAIL emscad.fornecedor THEN emscad.fornecedor.num_pessoa ELSE 0
                         antecip_pef_pend.cod_refer             = c-refer
                         antecip_pef_pend.des_text_histor       = "Antecipaá∆o referente Nota " + c-nota + " dia " + string(tt-antecip.dt-nota,"99/99/9999").        
                  LEAVE bloco-antec.
               END.
               ELSE
                  NEXT bloco-antec.
            END.

            /***** RATEIO *****/
            CREATE aprop_ctbl_pend_ap.    
            ASSIGN aprop_ctbl_pend_ap.cod_empresa          = "1"
                   aprop_ctbl_pend_ap.cod_estab            = tt-antecip.cod_estab              
                   aprop_ctbl_pend_ap.cod_refer            = c-refer             
                   aprop_ctbl_pend_ap.cod_plano_cta_ctbl   = "PADRAO"        
                   aprop_ctbl_pend_ap.cod_cta_ctbl         = "91103025"               
                   aprop_ctbl_pend_ap.cod_unid_negoc       = "000"            
                   aprop_ctbl_pend_ap.cod_plano_ccusto     = ""         
                   aprop_ctbl_pend_ap.cod_ccusto           = ""          
                   aprop_ctbl_pend_ap.cod_tip_fluxo_financ = "399"     
                   aprop_ctbl_pend_ap.num_seq_refer        = i-cont           
                   aprop_ctbl_pend_ap.val_aprop_ctbl       = tt-antecip.val_tit_ap          
                   aprop_ctbl_pend_ap.cod_estab_aprop_ctbl = tt-antecip.cod_estab. 
                 
            FOR first proces_pagto WHERE
                      proces_pagto.cod_estab             = tt-antecip.cod_estab AND
                      proces_pagto.cod_refer_antecip_pef = c-refer NO-LOCK:
            END.
    
            if not avail proces_pagto then do:
               create proces_pagto.
               assign proces_pagto.cod_empresa            = "1"
                      proces_pagto.cod_estab              = tt-antecip.cod_estab
                      proces_pagto.cod_refer_antecip_pef  = antecip_pef_pend.cod_refer
                      proces_pagto.cod_espec_docto        = tt-antecip.cod_espec_docto
                      proces_pagto.cod_ser_docto          = tt-antecip.cod_ser_docto
                      proces_pagto.cod_tit_ap             = tt-antecip.cod_tit_ap
                      proces_pagto.cod_parcela            = tt-antecip.cod_parcela
                      proces_pagto.cdn_fornecedor         = tt-antecip.cdn_fornecedor
                      proces_pagto.num_seq_pagto_tit_ap   = 1
                      proces_pagto.cod_portador           = ""
                      proces_pagto.dat_vencto_tit_ap      = tt-antecip.dat_vencto_tit_ap
                      proces_pagto.dat_prev_pagto         = tt-antecip.dat_vencto_tit_ap
                      proces_pagto.ind_sit_proces_pagto   = "Confirmado"   
                      proces_pagto.cod_usuar_prepar_pagto = "SUPER"
                      proces_pagto.dat_prepar_pagto       = tt-antecip.dat_emis_docto
                      proces_pagto.cod_indic_econ         = "Real"
                      proces_pagto.ind_modo_pagto         = ""
                      proces_pagto.dat_pagto              = tt-antecip.dat_emis_docto.
            END.
        END.

        run prgfin/apb/apb795za.py (Input antecip_pef_pend.val_tit_ap,
                                    Input antecip_pef_pend.cod_estab,
                                    Input antecip_pef_pend.dat_emis_docto,
                                    Input 0,
                                    Input 0,
                                    Input 0,
                                    Input 0,
                                    Input ?,
                                    Input ?,
                                    Input 0,
                                    Input "",
                                    Input "",
                                    Input 0,
                                    Input "" /* PAR∂METROS BANCO - VERS«O 5.02 */,
                                    Input "",
                                    Input "",
                                    Input "",
                                    Input "",
                                    Input 'add_antecip_pef_pend',
                                    Input recid(antecip_pef_pend),
                                    Input recid(proces_pagto),
                                    Input /*recid(bord_ap)*/ ?,
                                    Input /*recid(cheq_ap)*/ ?,
                                    Input /*recid(item_lote_pagto)*/ ?, 
                                    INPUT ""). 
    end.
    OUTPUT CLOSE.
END.

run pi-finalizar in h-acomp.

{include/i-rpvar.i}

{include/i-rpout.i &tofile=tt-param.arq-destino}

assign c-titulo-relat = "Importaá∆o Antecipaá∆o"
       c-programa     = "NI-IMP-ANTECIP-APB-RP".

{include/i-rpcab.i}

view frame f-cabec.

for each tt-erro BY tt-erro.desc-erro:
    disp tt-erro.desc-erro COLUMN-LABEL "Descriá∆o Erro"
         with width 132 no-box stream-io down frame f-erros.
end.         

view frame f-rodape.    

{include/i-rpclo.i}





