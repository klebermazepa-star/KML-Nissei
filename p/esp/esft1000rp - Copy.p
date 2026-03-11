MESSAGE "PROG 2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

{include/i-prgvrs.i ESFT1000RP 2.00.01.GCJ} 

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    FIELD c-diretorio-processar AS CHAR FORMAT "X(100)"
    FIELD c-diretorio-processado AS CHAR FORMAT "X(100)"
    FIELD rs-execucao            AS INT
    .

def temp-table tt-raw-digita
    field raw-digita as raw.



def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.                   


{include/i-rpvar.i}                                        
/* {include/i-rpcab.i} */
{include/i-rpcab.i &STREAM="str-rp"}



create tt-param.
raw-transfer raw-param to tt-param.

/*
FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER tt-raw-digita.raw-digita TO tt-digita.
END.
*/


/**============================================ Defini‡äes =================================================**/

{utp\ut-glob.i}                                                                                               
DEFINE VARIABLE h-acomp AS HANDLE      NO-UNDO.  

DEFINE VARIABLE c-cnpj-fornecedor AS CHARACTER FORMAT "x(40)"   NO-UNDO.
DEFINE VARIABLE dt-vencimento     AS CHAR        NO-UNDO.
DEFINE VARIABLE dt-pagamento      AS CHAR        NO-UNDO.
DEFINE VARIABLE c-nro-docto       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE de-valor-origin   AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-pago     AS DECIMAL     NO-UNDO.
DEFINE VARIABLE dt-vencto AS DATE FORMAT "99/99/9999"       NO-UNDO.
DEFINE VARIABLE dt-pagto  AS DATE FORMAT "99/99/9999"       NO-UNDO.
DEFINE VARIABLE c-cnpj AS CHARACTER   FORMAT "x(40)" NO-UNDO.
  
DEFINE TEMP-TABLE tt-import NO-UNDO
      FIELD i-linha     AS INT
      FIELD cod-estabel AS CHAR
      FIELD serie       AS CHAR
      FIELD nr-nota-fis AS CHAR
      FIELD nsu-admin   AS CHAR FORMAT "x(10)"
      FIELD autorizacao AS CHAR FORMAT "x(10)"
      FIELD vl-parcela  LIKE fat-duplic.vl-parcela
      FIELD taxa-admin  LIKE fat-duplic.vl-parcela
      FIELD id-erro     AS LOGICAL
      FIELD desc-erro   AS CHAR FORMAT "x(100)" COLUMN-LABEL "Desc Erro"
      FIELD r-rowid     AS ROWID
      FIELD tipo-registro   AS INT
      FIELD parcela         AS INT
      .


  DEFINE TEMP-TABLE tt-arquivos NO-UNDO 
        FIELD c-arquivo       AS CHAR FORMAT "x(100)"
        FIELD c-diretorio-a-processar AS CHAR FORMAT "x(100)"
        FIELD c-diretorio-processados AS CHAR FORMAT "x(100)"
        .                       

  DEF TEMP-TABLE tt-titulos NO-UNDO
      FIELD cod-estabel    AS CHAR
      FIELD num_id_tit_acr AS INT
      FIELD vl-parcela     LIKE fat-duplic.vl-parcela
      .

  /************************ Temp-Table definition *************************/
def temp-table tt_integr_acr_liquidac_lote        
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_cod_usuario                  as character format "x(12)" label "Usu rio" column-label "Usu rio"
    field ttv_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa‡Æo" column-label "Dat Transac"
    field tta_dat_gerac_lote_liquidac      as date format "99/99/9999" initial ? label "Data Gera‡Æo" column-label "Data Gera‡Æo"
    field tta_val_tot_lote_liquidac_infor  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado"
    field tta_val_tot_lote_liquidac_efetd  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimento" column-label "Vl Tot Movto"
    field tta_val_tot_despes_bcia          as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Desp Bcia" column-label "Desp Bcia"
    field tta_ind_tip_liquidac_acr         as character format "X(15)" initial "Lote" label "Tipo Liquidacao" column-label "Tipo Liquidacao"
    field tta_ind_sit_lote_liquidac_acr    as character format "X(15)" initial "Em Digita‡Æo" label "Situa‡Æo" column-label "Situa‡Æo"
    field tta_nom_arq_movimen_bcia         as character format "x(30)" label "Nom Arq Bancaria" column-label "Nom Arq Bancaria"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_log_enctro_cta               as logical format "Sim/NÆo" initial no label "Encontro de Contas" column-label "Encontro de Contas"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_lote_liquidac_acr        as recid format ">>>>>>9" initial ?
    field ttv_log_atualiz_refer            as logical format "Sim/NÆo" initial no
    field ttv_log_gera_lote_parcial        as logical format "Sim/NÆo" initial no
    field ttv_log_verific_reg_perda_dedut  as logical format "Sim/N’o" initial no 
    index tt_itlqdccr_id                   is primary unique
          tta_cod_estab_refer              ascending
          tta_cod_refer                    ascending.

def temp-table tt_integr_acr_liq_item_lote_3 no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_cr_liquidac_tit_acr      as date format "99/99/9999" initial ? label "Data Cr‚dito" column-label "Data Cr‚dito"
    field tta_dat_cr_liquidac_calc         as date format "99/99/9999" initial ? label "Cred Calculada" column-label "Cred Calculada"
    field tta_dat_liquidac_tit_acr         as date format "99/99/9999" initial ? label "Liquida‡Æo" column-label "Liquida‡Æo"
    field tta_cod_autoriz_bco              as character format "x(8)" label "Autoriza‡Æo Bco" column-label "Autorizacao Bco"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_liquidac_tit_acr         as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquida‡Æo" column-label "Vl Liquida‡Æo"
    field tta_val_desc_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_val_despes_bcia              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    field tta_val_multa_tit_acr            as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa" column-label "Vl Multa"
    field tta_val_juros                    as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_cm_tit_acr               as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM" column-label "Vl CM"
    field tta_val_liquidac_orig            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquid Orig" column-label "Vl Liquid Orig"
    field tta_val_desc_tit_acr_orig        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc Orig" column-label "Vl Desc Orig"
    field tta_val_abat_tit_acr_orig        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat Orig" column-label "Vl Abat Orig"
    field tta_val_despes_bcia_orig         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Bcia Orig" column-label "Vl Desp Bcia Orig"
    field tta_val_multa_tit_acr_origin     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa Orig" column-label "Vl Multa Orig"
    field tta_val_juros_tit_acr_orig       as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Juros Orig" column-label "Vl Juros Orig"
    field tta_val_cm_tit_acr_orig          as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM Orig" column-label "Vl CM Orig"
    field tta_val_nota_db_orig             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Nota DB" column-label "Valor Nota DB"
    field tta_log_gera_antecip             as logical format "Sim/NÆo" initial no label "Gera Antecipacao" column-label "Gera Antecipacao"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_ind_sit_item_lote_liquidac   as character format "X(09)" initial "Gerado" label "Situa‡Æo Item Lote" column-label "Situa‡Æo Item Lote"
    field tta_log_gera_avdeb               as logical format "Sim/NÆo" initial no label "Gera Aviso D‚bito" column-label "Gera Aviso D‚bito"
    field tta_cod_indic_econ_avdeb         as character format "x(8)" label "Moeda Aviso D‚bito" column-label "Moeda Aviso D‚bito"
    field tta_cod_portad_avdeb             as character format "x(5)" label "Portador AD" column-label "Portador AD"
    field tta_cod_cart_bcia_avdeb          as character format "x(3)" label "Carteira AD" column-label "Carteira AD"
    field tta_dat_vencto_avdeb             as date format "99/99/9999" initial ? label "Vencto AD" column-label "Vencto AD"
    field tta_val_perc_juros_avdeb         as decimal format ">>9.99" decimals 2 initial 0 label "Juros Aviso Debito" column-label "Juros ADebito"
    field tta_val_avdeb                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Aviso D‚bito" column-label "Aviso D‚bito"
    field tta_log_movto_comis_estordo      as logical format "Sim/NÆo" initial no label "Estorna ComissÆo" column-label "Estorna ComissÆo"
    field tta_ind_tip_item_liquidac_acr    as character format "X(09)" label "Tipo Item" column-label "Tipo Item"
    field ttv_rec_lote_liquidac_acr        as recid format ">>>>>>9" initial ?
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota‡Æo" column-label "Cota‡Æo"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo C lculo Juros" column-label "Tipo C lculo Juros"
    field tta_log_retenc_impto_liq         as logical format "Sim/NÆo" initial no label "Ret‚m na Liquida‡Æo" column-label "Ret na Liq"
    field tta_val_retenc_pis               as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor PIS" column-label "PIS"
    field tta_val_retenc_cofins            as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor COFINS" column-label "COFINS"
    field tta_val_retenc_csll              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CSLL" column-label "CSLL"
    field ttv_log_gera_retenc_impto_ant    as logical format "Sim/N’o" initial YES
    index tt_rec_index                    
          ttv_rec_lote_liquidac_acr        ascending.


def temp-table tt_integr_acr_abat_antecip        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_antecip_tit_abat   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abtdo" column-label "Vl Abtdo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.

def temp-table tt_integr_acr_abat_prev        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_prev_tit_abat      as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat" column-label "Vl Abat"
    field tta_log_zero_sdo_prev            as logical format "Sim/NÆo" initial no label "Zera Saldo" column-label "Zera Saldo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.


def temp-table tt_integr_acr_cheq        
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Data EmissÆo" column-label "Dt Emiss"
    field tta_dat_depos_cheq_acr           as date format "99/99/9999" initial ? label "Dep¢sito" column-label "Dep¢sito"
    field tta_dat_prev_depos_cheq_acr      as date format "99/99/9999" initial ? label "PrevisÆo Dep¢sito" column-label "PrevisÆo Dep¢sito"
    field tta_dat_desc_cheq_acr            as date format "99/99/9999" initial ? label "Data Desconto" column-label "Data Desconto"
    field tta_dat_prev_desc_cheq_acr       as date format "99/99/9999" initial ? label "Data Prev Desc" column-label "Data Prev Desc"
    field tta_val_cheque                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cheque" column-label "Valor Cheque"
    field tta_nom_emit                     as character format "x(40)" label "Nome Emitente" column-label "Nome Emitente"
    field tta_nom_cidad_emit               as character format "x(30)" label "Cidade Emitente" column-label "Cidade Emitente"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_motiv_devol_cheq         as character format "x(5)" label "Motivo Devolu‡Æo" column-label "Motivo Devolu‡Æo"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_usuar_cheq_acr_terc      as character format "x(12)" label "Usu rio" column-label "Usu rio"
    field tta_log_pend_cheq_acr            as logical format "Sim/NÆo" initial no label "Cheque Pendente" column-label "Cheque Pendente"
    field tta_log_cheq_terc                as logical format "Sim/NÆo" initial no label "Cheque Terceiro" column-label "Cheque Terceiro"
    field tta_log_cheq_acr_renegoc         as logical format "Sim/NÆo" initial no label "Cheque Reneg" column-label "Cheque Reneg"
    field tta_log_cheq_acr_devolv          as logical format "Sim/NÆo" initial no label "Cheque Devolvido" column-label "Cheque Devolvido"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    index tt_id                            is primary unique
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending.

def temp-table tt_integr_acr_liquidac_impto_2 no-undo
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa‡Æo" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_val_retid_indic_impto        as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE Imposto" column-label "Vl Retido IE Imposto"
    field tta_val_retid_indic_tit_acr      as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE T¡tulo" column-label "Vl Retido IE T¡tulo"
    field tta_val_retid_indic_pagto        as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Retido Indicador Pag" column-label "Retido Indicador Pag"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota‡Æo" column-label "Data Cota‡Æo"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota‡Æo" column-label "Cota‡Æo"
    field tta_dat_cotac_indic_econ_pagto   as date format "99/99/9999" initial ? label "Dat Cotac IE Pagto" column-label "Dat Cotac IE Pagto"
    field tta_val_cotac_indic_econ_pagto   as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Val Cotac IE Pagto" column-label "Val Cotac IE Pagto"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tribut vel" column-label "Vl Rendto Tribut".

def temp-table tt_integr_acr_liq_aprop_ctbl        
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    index tt_integr_acr_liq_aprop_ctbl_id  is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_cod_unid_negoc               ascending.

def temp-table tt_integr_acr_liq_desp_rec        
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg¢cio Externa" column-label "Unid Neg¢cio Externa"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Abatimento" column-label "Tipo de Abatimento"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropria‡Æo" column-label "Tipo Apropria‡Æo"
    field tta_val_perc_rat_ctbz            as decimal format ">>9.99" decimals 2 initial 0 label "Perc Rateio" column-label "% Rat"
    index tt_integr_acr_liq_des_rec_id     is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_cta_ctbl_ext             ascending
          tta_cod_sub_cta_ctbl_ext         ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_unid_negoc_ext           ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_ind_tip_aprop_recta_despes   ASCENDING.



def temp-table tt_integr_acr_rel_pend_cheq no-undo
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_val_vincul_cheq_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Vinculado" column-label "Valor Vinculado"
    field tta_cdn_bco_cheq_salario         as Integer format ">>9" initial 0 label "Banco Cheque Sal rio" column-label "Banco Cheque Sal rio".

def temp-table tt_integr_acr_aprop_liq_antec        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field ttv_cod_fluxo_financ_tit_ext     as character format "x(20)" label "Fuxo Tit Ext" column-label "Fuxo Tit Ext"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_unid_negoc_tit           as character format "x(3)" label "Unid Negoc T¡tulo" column-label "Unid Negoc T¡tulo"
    field tta_cod_tip_fluxo_financ_tit     as character format "x(12)" label "Tp Fluxo Financ Tit" column-label "Tp Fluxo Financ Tit"
    field tta_val_abtdo_antecip            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatido" column-label "Vl Abatido".

def temp-table tt_log_erros_import_liquidac        
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "NumSeq"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_nom_abrev_clien              as character format "x(12)" label "Cliente" column-label "Cliente"
    field ttv_num_erro_log                 as integer format ">>>>,>>9" label "N£mero Erro" column-label "N£mero Erro"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    index tt_sequencia                    
          tta_num_seq                      ASCENDING.

def temp-table tt_integr_cambio_ems5 no-undo                                                                                                              
    field ttv_rec_table_child              as recid format ">>>>>>9"                                                                                      
    field ttv_rec_table_parent             as recid format ">>>>>>9"                                                                                      
    field ttv_cod_contrat_cambio           as character format "x(15)"                                                                                    
    field ttv_dat_contrat_cambio_import    as date format "99/99/9999"                                                                                    
    field ttv_num_contrat_id_cambio        as integer format "999999999"                                                                                  
    field ttv_cod_estab_contrat_cambio     as character format "x(3)"                                                                                     
    field ttv_cod_refer_contrat_cambio     as character format "x(10)"                                                                                    
    field ttv_dat_refer_contrat_cambio     as date format "99/99/9999"                                                                                    
    index tt_rec_index                     is primary unique                                                                                              
          ttv_rec_table_parent             ascending                                                                                                      
          ttv_rec_table_child              ASCENDING.    

Def new shared temp-table tt_params_generic_api no-undo
    field ttv_rec_id                       as recid format ">>>>>>9"
    field ttv_cod_tabela                   as character format "x(28)" label "Tabela" column-label "Tabela"
    field ttv_cod_campo                    as character format "x(25)" label "Campo" column-label "Campo"  
    field ttv_cod_valor                    as character format "x(8)" label "Valor" column-label "Valor"   
    index tt_idx_param_generic             is primary unique
          ttv_cod_tabela                   ascending        
          ttv_rec_id                       ascending        
          ttv_cod_campo                    ascending.       

/****************************************** TT do Programa ***********************/
DEF TEMP-TABLE tt-erro_tit_acr NO-UNDO
    FIELD cod_estab       AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Estab"
    FIELD cod_espec_docto AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Espec"
    FIELD cod_ser_docto   AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Serie"
    FIELD cod_tit_acr     AS CHAR FORMAT "x(10)"   COLUMN-LABEL "Titulo"
    FIELD cod_parcela     AS CHAR FORMAT "x(02)"   COLUMN-LABEL "Parcela"
    FIELD texto_msg       AS CHAR FORMAT "x(200)"  COLUMN-LABEL "Mensagem"
    FIELD cod_refer       AS CHAR FORMAT "x(10)"   COLUMN-LABEL "Lote"
    FIELD seq_msg         AS INT
    FIELD tipo_msg        AS INT   /* 1-ERRO  /  2-INFORMATIVO */
    INDEX i-id IS PRIMARY seq_msg.



def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)"
    label "Grupo Usuÿrios"
    column-label "Grupo"
    no-undo.

def new global shared var v_cod_usuar_corren 
    as character 
    format "x(12)" 
    label "Usuÿrio Corrente" 
    column-label "Usuÿrio Corrente" 
    no-undo. 

def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.

  
 DEF STREAM s_dir.
 DEF STREAM s_imp.


     /************************ Bufferïs definition *************************/
    def buffer b_cobr_especial_acr for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr for lote_liquidac_acr.
    def buffer b_movto_tit_acr     for movto_tit_acr.
    def buffer b_operac_financ_acr for operac_financ_acr.
    def buffer b_renegoc_acr       for renegoc_acr.



/** =========================================  Bloco Principal ============================================== **/


find first param-global no-lock no-error.


/* {include/i-rpout.i}           */
{include/i-rpout.i &STREAM="stream str-rp"}

RUN utp\ut-acomp.p PERSISTENT SET h-acomp.

/*
view frame f-cabec. 
view frame f-rodape.
*/

VIEW STREAM str-rp FRAME f-cabec.
VIEW STREAM str-rp FRAME f-rodape.


/* RUN pi_calc_clientes. */

RUN pi_input_files.
RUN pi_import.

/* rs-execucao = 1 conciliacao */
IF tt-param.rs-execucao = 1 THEN DO:
   
   RUN pi_dados.

END.
ELSE DO:

    RUN pi_dados_2.
    RUN pi_liquidacao.
END.

RUN pi_show_log.


/*PUT STREAM str-rp "teste". */

{include/i-rpclo.i} 

RUN pi-finalizar IN h-acomp. 


RETURN "OK".

/*========================================== Procedures Internas  ============================================ **/


procedure pi_liquidacao:


    DEF VAR i-seq           AS INT INIT 0               NO-UNDO. 
    DEF VAR v_cont          AS INT                      NO-UNDO.
    DEF VAR l-erro          AS LOGICAL                  NO-UNDO.
    DEF VAR h-acomp         AS HANDLE                   NO-UNDO.
    DEF VAR i-sq-erro       AS INT INIT 0               NO-UNDO.   
    DEF VAR c-arquivo       AS CHAR FORMAT "x(400)"     NO-UNDO.
    def var v_hdl_aux       as Handle                   NO-UNDO.
    DEF VAR c-cod_refer     AS CHAR                     NO-UNDO.    
    DEF VAR v_log_refer_uni AS LOG INIT NO              NO-UNDO.      

    DEF VAR v_cod_empres_usuar_bkp AS CHAR              NO-UNDO.



    EMPTY TEMP-TABLE tt-erro_tit_acr.

    atualizacao:
    do transaction on error undo atualizacao, leave atualizacao
                   on STOP  undo atualizacao, leave atualizacao:


        ASSIGN l-erro = NO.

        blk_titulos:
        FOR EACH tt-titulos:

            /* RUN pi-acompanhar IN h-acomp (INPUT "Titulo: " + tt_movto_log_pdd.cod_tit_acr). */

            EMPTY TEMP-TABLE tt_integr_acr_liquidac_lote.
            EMPTY TEMP-TABLE tt_integr_acr_liq_item_lote_3.



            find first tit_acr no-lock
                 where tit_acr.cod_estab        = tt-titulos.cod-estabel
                 and   tit_acr.num_id_tit_acr   = tt-titulos.num_id_tit_acr no-error.

            if not avail tit_acr then do:


                CREATE tt-erro_tit_acr.                                                                                                      
                ASSIGN tt-erro_tit_acr.seq_msg         = i-sq-erro
                       tt-erro_tit_acr.cod_estab       = tt-titulos.cod-estabel
                    /*
                       tt-erro_tit_acr.cod_espec_docto = ""  
                       tt-erro_tit_acr.cod_ser_docto   = ""
                       tt-erro_tit_acr.cod_tit_acr     = ""
                       tt-erro_tit_acr.cod_parcela     = 0 */
                       tt-erro_tit_acr.texto_msg       = "num_id_tit_acr" + " - " +  string(tt-titulos.num_id_tit_acr)    
                       tt-erro_tit_acr.tipo_msg        = 1.                                                                                       

                next blk_titulos.

            end.

            pesq_ref:                                                    
            REPEAT:                                                      
               RUN /* pi_referencia */ pi_retorna_sugestao_referencia (INPUT "P",                             
                                                                       INPUT TODAY,                     
                                                                       OUTPUT c-cod_refer).                   

               RUN pi_verifica_refer_unica_acr (INPUT tit_acr.cod_estab,
                                                INPUT c-cod_refer,       
                                                INPUT "",                
                                                INPUT ?,                 
                                                OUTPUT v_log_refer_uni).

               IF v_log_refer_uni = TRUE THEN                             
                  LEAVE pesq_ref.               

            END.         

            CREATE tt_integr_acr_liquidac_lote.                                                                        
            ASSIGN tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tit_acr.cod_empresa
                   tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = tit_acr.cod_estab
                   tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod_refer
                   tt_integr_acr_liquidac_lote.tta_cod_usuario                 = v_cod_usuar_corren    
                   tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = TODAY
                   tt_integr_acr_liquidac_lote.tta_dat_transacao               = TODAY 
                   tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "Liquidacao Automatica"
                   tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Liquidado" /*"Em digita‡Æo"*/
                   tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = NO
                   tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES //tt_titulos.log_atualiz_refer
                   tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = NO
                   tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = RECID(tt_integr_acr_liquidac_lote).

            FIND FIRST tt_integr_acr_liquidac_lote NO-LOCK NO-ERROR.

            /*
            FIND FIRST tit_acr NO-LOCK WHERE
                       tit_acr.cod_estab      = tt_movto_log_pdd.cod_estab
                   AND tit_acr.num_id_tit_acr = tt_movto_log_pdd.num_id_tit_acr  NO-ERROR.    */

               ASSIGN i-seq       = 0.         
                      i-seq       = i-seq + 1. 

            CREATE tt_integr_acr_liq_item_lote_3.                                                                                       
            ASSIGN tt_integr_acr_liq_item_lote_3.tta_cod_empresa                = tit_acr.cod_empresa                                   
                   tt_integr_acr_liq_item_lote_3.tta_cod_estab                  = tit_acr.cod_estab                                     
                   tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto            = tit_acr.cod_espec_docto                               
                   tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto              = tit_acr.cod_ser_docto                                 
                   tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr                = tit_acr.cod_tit_acr                                   
                   tt_integr_acr_liq_item_lote_3.tta_cod_parcela                = tit_acr.cod_parcela                                   
                   tt_integr_acr_liq_item_lote_3.tta_cdn_cliente                = tit_acr.cdn_cliente                                   
                   tt_integr_acr_liq_item_lote_3.tta_cod_portador               = tit_acr.cod_portador                               
                   tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia              = tit_acr.cod_cart_bcia                               
                   tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ           = "Corrente"                                            
                   tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ             = tit_acr.cod_indic_econ                                
                   tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr    = TODAY
                   tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr       = TODAY
                   tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr       = tt-titulos.vl-parcela
                   tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia            = 0
                   tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip           = NO
                   tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb             = NO
                   tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr  = "Perdas"
                   tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr      = RECID(tt_integr_acr_liquidac_lote)
                   tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = RECID(tt_integr_acr_liq_item_lote_3)
                   tt_integr_acr_liq_item_lote_3.tta_num_seq_refer              = i-seq.    

            FIND FIRST tt_integr_acr_liquidac_lote   NO-LOCK NO-ERROR.
            FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.

            ASSIGN v_cod_empres_usuar = tit_acr.cod_empresa.

            RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_aux.

            RUN pi_main_code_api_integr_acr_liquidac_6 IN v_hdl_aux (INPUT 1,
                                                                     INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                     INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                     INPUT TABLE tt_integr_acr_abat_antecip,
                                                                     INPUT TABLE tt_integr_acr_abat_prev,
                                                                     INPUT TABLE tt_integr_acr_cheq,
                                                                     INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                     INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                     INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                     INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                     INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                     INPUT '', /*Matriz de tradu‡Æo*/
                                                                     OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                     INPUT TABLE tt_integr_cambio_ems5,
                                                                     INPUT TABLE tt_params_generic_api).

            IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:                                                                                                                                 
                FOR EACH tt_log_erros_import_liquidac:      

                    ASSIGN l-erro = YES
                           i-sq-erro = i-sq-erro + 1.     

                    CREATE tt-erro_tit_acr.                                                                                                      
                    ASSIGN tt-erro_tit_acr.seq_msg         = i-sq-erro
                           tt-erro_tit_acr.cod_estab       = tit_acr.cod_estab      
                           tt-erro_tit_acr.cod_espec_docto = tit_acr.cod_espec_docto  
                           tt-erro_tit_acr.cod_ser_docto   = tit_acr.cod_ser_docto    
                           tt-erro_tit_acr.cod_tit_acr     = tit_acr.cod_tit_acr      
                           tt-erro_tit_acr.cod_parcela     = tit_acr.cod_parcela      
                           tt-erro_tit_acr.texto_msg       = STRING(tt_log_erros_import_liquidac.ttv_num_erro_log) + " - " +  tt_log_erros_import_liquidac.ttv_des_msg_erro    
                           tt-erro_tit_acr.tipo_msg        = 1.                                                                                       
                END.                                      
            END.                                                                                                                                
            ELSE DO:
                /* nao ocorreram erros */
                CREATE tt-erro_tit_acr.                                                                                                      
                    ASSIGN tt-erro_tit_acr.seq_msg         = 1
                           tt-erro_tit_acr.cod_estab       = tit_acr.cod_estab      
                           tt-erro_tit_acr.cod_espec_docto = tit_acr.cod_espec_docto
                           tt-erro_tit_acr.cod_ser_docto   = tit_acr.cod_ser_docto  
                           tt-erro_tit_acr.cod_tit_acr     = tit_acr.cod_tit_acr    
                           tt-erro_tit_acr.cod_parcela     = tit_acr.cod_parcela    
                           tt-erro_tit_acr.texto_msg       = "Titulo Liquidado com Sucesso"
                           tt-erro_tit_acr.cod_refer       = c-cod_refer
                           tt-erro_tit_acr.tipo_msg        = 2.                                                                                       

            END.

            DELETE PROCEDURE v_hdl_aux.

        END. /* tt_movto_log_pdd */

        IF l-erro THEN DO:
            UNDO atualizacao, LEAVE atualizacao.    
        END.

        ASSIGN v_cod_empres_usuar = v_cod_empres_usuar_bkp.

    END. /*transaction */





  return "ok".

end procedure.

PROCEDURE pi_input_files:

     DEFINE VARIABLE c-diretorio-processar   AS CHARACTER  FORMAT "x(100)" NO-UNDO.
     DEFINE VARIABLE c-diretorio-processados AS CHARACTER  FORMAT "x(100)" NO-UNDO.
     DEFINE VARIABLE c-linha                 AS CHARACTER  FORMAT "x(100)" NO-UNDO.

     EMPTY TEMP-TABLE tt-arquivos.

     /* buscar os diretorios para leitura dos arquivos CSV*/

     ASSIGN c-diretorio-processar   = tt-param.c-diretorio-processar
            c-diretorio-processados = tt-param.c-diretorio-processado.

    IF SUBSTRING(c-diretorio-processar,LENGTH(c-diretorio-processar),1) <> "/" 
    AND SUBSTRING(c-diretorio-processar,LENGTH(c-diretorio-processar),1) <> "\"  THEN
       ASSIGN c-diretorio-processar  = c-diretorio-processar + "\".

    IF SUBSTRING(c-diretorio-processados,LENGTH(c-diretorio-processados),1) <> "/" 
    AND SUBSTRING(c-diretorio-processados,LENGTH(c-diretorio-processados),1) <> "\" THEN
       ASSIGN c-diretorio-processados  = c-diretorio-processados + "\".


    /* buscar arquivos do diretorio*/                             
    INPUT STREAM s_dir FROM OS-DIR(c-diretorio-processar) NO-ATTR-LIST. 

    blk_repeat:
    REPEAT:                      

       IMPORT STREAM s_dir c-linha.  

       IF INDEX(c-linha,".csv") <> 0  THEN DO:

           IF  NOT c-linha MATCHES('*venda*')  
           AND NOT c-linha MATCHES('*financeiro*') THEN NEXT blk_repeat.


          CREATE tt-arquivos.
          ASSIGN tt-arquivos.c-arquivo               = c-linha
                 tt-arquivos.c-diretorio-a-processar = c-diretorio-processar
                 tt-arquivos.c-diretorio-processados = c-diretorio-processados
                 .
       END.       
    END. 

    INPUT STREAM s_dir close.


    RETURN "OK".

 END PROCEDURE.

PROCEDURE pi_dados_2:


    empty temp-table tt-titulos.
    FOR EACH tt-import 
     WHERE NOT tt-import.id-erro:

         FIND FIRST cst_fat_duplic no-lock
              WHERE ROWID(cst_fat_duplic) = tt-import.r-rowid NO-ERROR.
    
    
         IF AVAIL cst_fat_duplic THEN DO:
    
             /* validar se ja existe registro */
             FIND FIRST es-fat-duplic-nexxera EXCLUSIVE-LOCK
                  WHERE es-fat-duplic-nexxera.cod-estabel = cst_fat_duplic.cod_estab   
                    AND es-fat-duplic-nexxera.serie       = cst_fat_duplic.serie       
                    AND es-fat-duplic-nexxera.nr-fatura   = cst_fat_duplic.nr_fatura   
                    AND es-fat-duplic-nexxera.parcela     = cst_fat_duplic.parcela
                    NO-ERROR.
    
    
             IF NOT AVAIL es-fat-duplic-nexxera THEN DO:
                 CREATE es-fat-duplic-nexxera.
                 ASSIGN es-fat-duplic-nexxera.cod-estabel = cst_fat_duplic.cod_estab   
                        es-fat-duplic-nexxera.serie       = cst_fat_duplic.serie       
                        es-fat-duplic-nexxera.nr-fatura   = cst_fat_duplic.nr_fatura   
                        es-fat-duplic-nexxera.parcela     = cst_fat_duplic.parcela.
             END.
    
             ASSIGN es-fat-duplic-nexxera.situacao = 3.

             find first tt-titulos 
                  where tt-titulos.cod-estabel      = cst_fat_duplic.cod_estabel
                  and   tt-titulos.num_id_tit_acr   = cst_fat_duplic.num_id_tit_acr
                  no-error.


             if not avail tt-titulos then do:
                 create tt-titulos.
                 assign tt-titulos.cod-estabel      = cst_fat_duplic.cod_estabel
                        tt-titulos.num_id_tit_acr   = cst_fat_duplic.num_id_tit_acr.
             end.

             assign tt-titulos.vl-parcela = tt-titulos.vl-parcela + tt-import.vl-parcela.
    
         END.

    END. /* each tt-import */


    RETURN "OK".

END PROCEDURE.


PROCEDURE pi_dados:

  FOR EACH tt-import 
      WHERE NOT tt-import.id-erro:

      FIND FIRST cst_fat_duplic EXCLUSIVE-LOCK
           WHERE ROWID(cst_fat_duplic) = tt-import.r-rowid NO-ERROR.


      IF AVAIL cst_fat_duplic THEN DO:

          /* validar se ja existe registro */
          FIND FIRST es-fat-duplic-nexxera EXCLUSIVE-LOCK
               WHERE es-fat-duplic-nexxera.cod-estabel = cst_fat_duplic.cod_estab   
                 AND es-fat-duplic-nexxera.serie       = cst_fat_duplic.serie       
                 AND es-fat-duplic-nexxera.nr-fatura   = cst_fat_duplic.nr_fatura   
                 AND es-fat-duplic-nexxera.parcela     = cst_fat_duplic.parcela
                 NO-ERROR.


          IF NOT AVAIL es-fat-duplic-nexxera THEN DO:
              CREATE es-fat-duplic-nexxera.
              ASSIGN es-fat-duplic-nexxera.cod-estabel = cst_fat_duplic.cod_estab   
                     es-fat-duplic-nexxera.serie       = cst_fat_duplic.serie       
                     es-fat-duplic-nexxera.nr-fatura   = cst_fat_duplic.nr_fatura   
                     es-fat-duplic-nexxera.parcela     = cst_fat_duplic.parcela.
          END.

          ASSIGN es-fat-duplic-nexxera.taxa-admin-datasul = cst_fat_duplic.taxa_admin
                 es-fat-duplic-nexxera.taxa-admin  = tt-import.taxa-admin
                 es-fat-duplic-nexxera.cod-portador = cst_fat_duplic.cod_portador

                 es-fat-duplic-nexxera.situacao = 2
                 .

          ASSIGN cst_fat_duplic.taxa_admin = tt-import.taxa-admin.

          IF  es-fat-duplic-nexxera.taxa-admin-datasul <> es-fat-duplic-nexxera.taxa-admin THEN
              ASSIGN es-fat-duplic-nexxera.id-divergente = YES.


          FIND FIRST fat-duplic EXCLUSIVE-LOCK 
               WHERE fat-duplic.cod-estabel = cst_fat_duplic.cod_estab    
               AND   fat-duplic.serie       = cst_fat_duplic.serie        
               AND   fat-duplic.nr-fatura   = cst_fat_duplic.nr_fatura    
               AND   fat-duplic.parcela     = cst_fat_duplic.parcela      NO-ERROR.

          IF AVAIL fat-duplic THEN DO:

              ASSIGN es-fat-duplic-nexxera.vl-parcela-datasul = fat-duplic.vl-parcela-me
                     es-fat-duplic-nexxera.vl-parcela         = tt-import.vl-parcela
                     es-fat-duplic-nexxera.dt-venciment       = fat-duplic.dt-venciment
                     .

              ASSIGN fat-duplic.vl-parcela      = tt-import.vl-parcela
                     fat-duplic.vl-parcela-me   = tt-import.vl-parcela.


              IF  es-fat-duplic-nexxera.vl-parcela-datasul <> es-fat-duplic-nexxera.vl-parcela THEN
                  ASSIGN es-fat-duplic-nexxera.id-divergente = YES.

          END.

      END.    

  END.


 RETURN "OK".

END PROCEDURE.


PROCEDURE pi_show_log:


    

    PUT STREAM str-rp "Log de importacao " AT 50 SKIP(2).

    if tt-param.rs-execucao = 1 then do:

        FOR EACH tt-import:
    
    
    
            DISP STREAM str-rp tt-import.i-linha   COLUMN-LABEL "Linha"
                               tt-import.cod-estabel 
                               tt-import.serie       
                               tt-import.nr-nota-fis 
    
                               STRING(dec(tt-import.nsu-admin), "99999999999")  
                               tt-import.autorizacao
                               tt-import.vl-parcela 
                               tt-import.taxa-admin 
                               tt-import.id-erro    
                               tt-import.desc-erro  
                               
    
                  WITH FRAME f-import-1 STREAM-IO DOWN WIDTH 340.
            DOWN STREAM str-rp WITH FRAME f-import-1.
    
        END.
    end.
    else do:
        FOR EACH tt-import:
    
    
    
            DISP STREAM str-rp tt-import.i-linha   COLUMN-LABEL "Linha"
                               tt-import.cod-estabel 
                               tt-import.serie       
                               tt-import.nr-nota-fis 
    
                               tt-import.nsu-admin  
                               tt-import.autorizacao
                               tt-import.vl-parcela 
                               tt-import.taxa-admin 
                               tt-import.id-erro    
                               tt-import.desc-erro  
                               
    
                  WITH FRAME f-import-3 STREAM-IO DOWN WIDTH 340.
            DOWN STREAM str-rp WITH FRAME f-import-3.
    
        END.


        for each tt-erro_tit_acr.
        
            DISP STREAM str-rp 
                tt-erro_tit_acr.seq_msg         
                tt-erro_tit_acr.cod_estab       
                tt-erro_tit_acr.cod_espec_docto 
                tt-erro_tit_acr.cod_ser_docto   
                tt-erro_tit_acr.cod_tit_acr     
                tt-erro_tit_acr.cod_parcela     
                tt-erro_tit_acr.texto_msg       
        
                WITH FRAME f-import-2 STREAM-IO DOWN WIDTH 340.
          DOWN STREAM str-rp WITH FRAME f-import-2.
        
        end.
    end.    

    RETURN "Ok".

END PROCEDURE.


 PROCEDURE pi_import:

    DEFINE VARIABLE c_cod_estab AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-cont AS INTEGER     NO-UNDO.

    DEFINE VARIABLE c-diretorio AS CHARACTER FORMAT "x(100)"   NO-UNDO.
    DEFINE VARIABLE c-diretorio-2 AS CHARACTER FORMAT "x(100)"   NO-UNDO.
    DEFINE VARIABLE c-empresa-estab AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE id-imposto-aux AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE i-tipo-registro AS INTEGER     NO-UNDO.


    DEFINE VARIABLE c-import AS CHARACTER FORMAT "x(100)" EXTENT 55   NO-UNDO.

    RUN pi-inicializar IN h-acomp (INPUT "Lendo Planilhas....").

    FOR EACH tt-arquivos:

        ASSIGN c-diretorio   = tt-arquivos.c-diretorio-a-processar + tt-arquivos.c-arquivo
               c-diretorio-2 = tt-arquivos.c-diretorio-processados + tt-arquivos.c-arquivo.


        .MESSAGE c-diretorio
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

        ASSIGN i-cont = 0.

        INPUT STREAM s_imp FROM VALUE(c-diretorio).
    
        blk_import:
        REPEAT:            
    
            ASSIGN i-cont = i-cont + 1.

            RUN pi-acompanhar IN h-acomp (INPUT STRING(i-cont)).


            IMPORT stream s_imp DELIMITER "," 

                   c-import[1]
                   c-import[2]
                   c-import[3]
                   c-import[4]
                   c-import[5]
                   c-import[6]
                   c-import[7]
                   c-import[8]
                   c-import[9]
                   c-import[10] 

                   c-import[11]    
                   c-import[12]    
                   c-import[13]    
                   c-import[14]    
                   c-import[15]    
                   c-import[16]    
                   c-import[17]    
                   c-import[18]    
                   c-import[19]    
                   c-import[20]   

                    c-import[21]    
                    c-import[22]    
                    c-import[23]    
                    c-import[24]    
                    c-import[25]    
                    c-import[26]    
                    c-import[27]    
                    c-import[28]    
                    c-import[29]    
                    c-import[30]   

                    c-import[31]    
                    c-import[32]    
                    c-import[33]    
                    c-import[34]    
                    c-import[35]    
                    c-import[36]    
                    c-import[37]    
                    c-import[38]    
                    c-import[39]    
                    c-import[40]   

                    c-import[41]    
                    c-import[42]    
                    c-import[43]    
                    c-import[44]    
                    c-import[45]    
                    c-import[46]    
                    c-import[47]    
                    c-import[48]    
                    c-import[49]    
                    c-import[50]   
                    c-import[51]    
                    c-import[52]    
                    c-import[53]    
                    c-import[54]    
                    c-import[55]    


                  NO-ERROR
                  .

            /* linha do header */
            IF c-import[1] <> "0" THEN DO:
                ASSIGN i-tipo-registro = INT(c-import[8]).
            END.

/*
            /* 1 - conciliacao 2 - baixar titulos */
            IF tt-param.rs-execucao = 1  THEN DO:

                IF i-tipo-registro <> 1 THEN LEAVE blk_import.

            END.
            ELSE DO:
                IF i-tipo-registro <> 5 THEN LEAVE blk_import.
            END.
            */

            /* Somente buscar informacoes do registro 11  */
            IF c-import[1] <> "11" THEN NEXT blk_import.
            


            /*  temp-table importacao */
            CREATE tt-import.
            ASSIGN tt-import.i-linha            = i-cont
                   tt-import.id-erro            = NO
                   .


            ASSIGN tt-import.nsu-admin   = c-import[6]
                   tt-import.autorizacao = c-import[7]
                   tt-import.vl-parcela  = DEC(c-import[17]) / 100
                   tt-import.taxa-admin  = DEC(c-import[29]) / 100
                   tt-import.parcela     = IF INT(c-import[12]) = 0 THEN 1 ELSE INT(c-import[12])
                   tt-import.tipo-registro = i-tipo-registro
                   NO-ERROR
                   .
                   
                   .MESSAGE tt-import.nsu-admin 
                       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            /* busca tabela especifica */
            FIND FIRST cst_fat_duplic NO-LOCK
                 WHERE cst_fat_duplic.nsu_numero  = STRING(DEC(tt-import.nsu-admin), "99999999999") // KML TESTE
                 AND   cst_fat_duplic.autorizacao = tt-import.autorizacao
                 AND   cst_fat_duplic.parcela     = string(tt-import.parcela, "99") NO-ERROR.
                 
                 .MESSAGE  "NSU"
                          STRING(DEC(tt-import.nsu-admin), "99999999999")
                     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                 

            IF AVAIL cst_fat_duplic THEN DO:

                FIND FIRST es-fat-duplic-nexxera NO-LOCK
                     WHERE es-fat-duplic-nexxera.cod-estabel = cst_fat_duplic.cod_estab
                     AND   es-fat-duplic-nexxera.serie       = cst_fat_duplic.serie
                     AND   es-fat-duplic-nexxera.nr-fatura   = cst_fat_duplic.nr_fatura
                     AND   es-fat-duplic-nexxera.parcela     = cst_fat_duplic.parcela
                     NO-ERROR.
                     

                IF AVAIL es-fat-duplic-nexxera  AND es-fat-duplic-nexxera.situacao > 2 THEN DO:

                    ASSIGN tt-import.id-erro    = YES
                           tt-import.desc-erro  = "Registro ja atualizado"
                           tt-import.r-rowid    = ROWID(cst_fat_duplic)
                           .                              
                END.

                ASSIGN tt-import.cod-estabel       = cst_fat_duplic.cod_estab   
                       tt-import.serie             = cst_fat_duplic.serie       
                       tt-import.nr-nota-fis       = cst_fat_duplic.nr_fatura
                       tt-import.r-rowid           = ROWID(cst_fat_duplic).

            END.
            ELSE DO:

                ASSIGN tt-import.id-erro    = YES
                       tt-import.desc-erro  = "Duplicata nÆo encontrada".


            END.
    
        END. 

        INPUT STREAM s_imp CLOSE.

       /* DOS SILENT  MOVE VALUE(c-diretorio) VALUE(c-diretorio-2).  */

    END. /* each tt-arquivos */


    RETURN "OK".

END PROCEDURE.


PROCEDURE pi_retorna_sugestao_referencia:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
                       + substring(v_des_dat,1,2)
                       + substring(p_ind_tip_atualiz,1,1)
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 3:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + chr(v_num_aux).
    end.
END PROCEDURE. /* pi_retorna_sugestao_referencia */


/*****************************************************************************
** Procedure Interna.....: pi_verifica_refer_unica_acr
** Descricao.............: pi_verifica_refer_unica_acr
** Criado por............: Claudia
** Criado em.............: 14/08/1996 09:34:38
** Alterado por..........: its0105
** Alterado em...........: 23/08/2005 17:52:01
*****************************************************************************/
PROCEDURE pi_verifica_refer_unica_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as Character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/N’o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.02" &then
    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_operac_financ_acr
        for operac_financ_acr.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_renegoc_acr
        for renegoc_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "Opera»’o financeira" /*l_operacao_financ*/  then do:
        find first b_operac_financ_acr no-lock
             where b_operac_financ_acr.cod_estab               = p_cod_estab
               and b_operac_financ_acr.cod_movto_operac_financ = p_cod_refer
               and recid( b_operac_financ_acr )               <> p_rec_tabela
             use-index oprcfnna_id no-error.
        if  avail b_operac_financ_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.

    &if defined (BF_FIN_BCOS_HISTORICOS) &then
        if  v_log_utiliza_mbh
        and can-find (his_movto_tit_acr_histor no-lock
                      where his_movto_tit_acr_histor.cod_estab = p_cod_estab
                      and   his_movto_tit_acr_histor.cod_refer = p_cod_refer)
        then do:

            assign p_log_refer_uni = no.
        end.
    &endif
END PROCEDURE. /* pi_verifica_refer_unica_acr */


/*

/****************************************************************************/
/* ESP/ESACR022F.p - Programa chamado pelo Monitor PDD.                     */
/*                   Efetua a baixa dos t¡tulos por PEDA DEDUTÖVEL          */  
/****************************************************************************/

/************************ Temp-Table definition *************************/
def temp-table tt_integr_acr_liquidac_lote        
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_cod_usuario                  as character format "x(12)" label "Usu rio" column-label "Usu rio"
    field ttv_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa‡Æo" column-label "Dat Transac"
    field tta_dat_gerac_lote_liquidac      as date format "99/99/9999" initial ? label "Data Gera‡Æo" column-label "Data Gera‡Æo"
    field tta_val_tot_lote_liquidac_infor  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado"
    field tta_val_tot_lote_liquidac_efetd  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimento" column-label "Vl Tot Movto"
    field tta_val_tot_despes_bcia          as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Desp Bcia" column-label "Desp Bcia"
    field tta_ind_tip_liquidac_acr         as character format "X(15)" initial "Lote" label "Tipo Liquidacao" column-label "Tipo Liquidacao"
    field tta_ind_sit_lote_liquidac_acr    as character format "X(15)" initial "Em Digita‡Æo" label "Situa‡Æo" column-label "Situa‡Æo"
    field tta_nom_arq_movimen_bcia         as character format "x(30)" label "Nom Arq Bancaria" column-label "Nom Arq Bancaria"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_log_enctro_cta               as logical format "Sim/NÆo" initial no label "Encontro de Contas" column-label "Encontro de Contas"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_lote_liquidac_acr        as recid format ">>>>>>9" initial ?
    field ttv_log_atualiz_refer            as logical format "Sim/NÆo" initial no
    field ttv_log_gera_lote_parcial        as logical format "Sim/NÆo" initial no
    field ttv_log_verific_reg_perda_dedut  as logical format "Sim/N’o" initial no 
    index tt_itlqdccr_id                   is primary unique
          tta_cod_estab_refer              ascending
          tta_cod_refer                    ascending.

def temp-table tt_integr_acr_liq_item_lote_3 no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_cr_liquidac_tit_acr      as date format "99/99/9999" initial ? label "Data Cr‚dito" column-label "Data Cr‚dito"
    field tta_dat_cr_liquidac_calc         as date format "99/99/9999" initial ? label "Cred Calculada" column-label "Cred Calculada"
    field tta_dat_liquidac_tit_acr         as date format "99/99/9999" initial ? label "Liquida‡Æo" column-label "Liquida‡Æo"
    field tta_cod_autoriz_bco              as character format "x(8)" label "Autoriza‡Æo Bco" column-label "Autorizacao Bco"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_liquidac_tit_acr         as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquida‡Æo" column-label "Vl Liquida‡Æo"
    field tta_val_desc_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_val_despes_bcia              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    field tta_val_multa_tit_acr            as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa" column-label "Vl Multa"
    field tta_val_juros                    as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_cm_tit_acr               as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM" column-label "Vl CM"
    field tta_val_liquidac_orig            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquid Orig" column-label "Vl Liquid Orig"
    field tta_val_desc_tit_acr_orig        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc Orig" column-label "Vl Desc Orig"
    field tta_val_abat_tit_acr_orig        as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat Orig" column-label "Vl Abat Orig"
    field tta_val_despes_bcia_orig         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Bcia Orig" column-label "Vl Desp Bcia Orig"
    field tta_val_multa_tit_acr_origin     as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa Orig" column-label "Vl Multa Orig"
    field tta_val_juros_tit_acr_orig       as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Juros Orig" column-label "Vl Juros Orig"
    field tta_val_cm_tit_acr_orig          as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM Orig" column-label "Vl CM Orig"
    field tta_val_nota_db_orig             as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Nota DB" column-label "Valor Nota DB"
    field tta_log_gera_antecip             as logical format "Sim/NÆo" initial no label "Gera Antecipacao" column-label "Gera Antecipacao"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_ind_sit_item_lote_liquidac   as character format "X(09)" initial "Gerado" label "Situa‡Æo Item Lote" column-label "Situa‡Æo Item Lote"
    field tta_log_gera_avdeb               as logical format "Sim/NÆo" initial no label "Gera Aviso D‚bito" column-label "Gera Aviso D‚bito"
    field tta_cod_indic_econ_avdeb         as character format "x(8)" label "Moeda Aviso D‚bito" column-label "Moeda Aviso D‚bito"
    field tta_cod_portad_avdeb             as character format "x(5)" label "Portador AD" column-label "Portador AD"
    field tta_cod_cart_bcia_avdeb          as character format "x(3)" label "Carteira AD" column-label "Carteira AD"
    field tta_dat_vencto_avdeb             as date format "99/99/9999" initial ? label "Vencto AD" column-label "Vencto AD"
    field tta_val_perc_juros_avdeb         as decimal format ">>9.99" decimals 2 initial 0 label "Juros Aviso Debito" column-label "Juros ADebito"
    field tta_val_avdeb                    as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Aviso D‚bito" column-label "Aviso D‚bito"
    field tta_log_movto_comis_estordo      as logical format "Sim/NÆo" initial no label "Estorna ComissÆo" column-label "Estorna ComissÆo"
    field tta_ind_tip_item_liquidac_acr    as character format "X(09)" label "Tipo Item" column-label "Tipo Item"
    field ttv_rec_lote_liquidac_acr        as recid format ">>>>>>9" initial ?
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota‡Æo" column-label "Cota‡Æo"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo C lculo Juros" column-label "Tipo C lculo Juros"
    field tta_log_retenc_impto_liq         as logical format "Sim/NÆo" initial no label "Ret‚m na Liquida‡Æo" column-label "Ret na Liq"
    field tta_val_retenc_pis               as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor PIS" column-label "PIS"
    field tta_val_retenc_cofins            as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor COFINS" column-label "COFINS"
    field tta_val_retenc_csll              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor CSLL" column-label "CSLL"
    field ttv_log_gera_retenc_impto_ant    as logical format "Sim/N’o" initial YES
    index tt_rec_index                    
          ttv_rec_lote_liquidac_acr        ascending.


def temp-table tt_integr_acr_abat_antecip        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_antecip_tit_abat   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abtdo" column-label "Vl Abtdo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.

def temp-table tt_integr_acr_abat_prev        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_prev_tit_abat      as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat" column-label "Vl Abat"
    field tta_log_zero_sdo_prev            as logical format "Sim/NÆo" initial no label "Zera Saldo" column-label "Zera Saldo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.


def temp-table tt_integr_acr_cheq        
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Data EmissÆo" column-label "Dt Emiss"
    field tta_dat_depos_cheq_acr           as date format "99/99/9999" initial ? label "Dep¢sito" column-label "Dep¢sito"
    field tta_dat_prev_depos_cheq_acr      as date format "99/99/9999" initial ? label "PrevisÆo Dep¢sito" column-label "PrevisÆo Dep¢sito"
    field tta_dat_desc_cheq_acr            as date format "99/99/9999" initial ? label "Data Desconto" column-label "Data Desconto"
    field tta_dat_prev_desc_cheq_acr       as date format "99/99/9999" initial ? label "Data Prev Desc" column-label "Data Prev Desc"
    field tta_val_cheque                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cheque" column-label "Valor Cheque"
    field tta_nom_emit                     as character format "x(40)" label "Nome Emitente" column-label "Nome Emitente"
    field tta_nom_cidad_emit               as character format "x(30)" label "Cidade Emitente" column-label "Cidade Emitente"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_motiv_devol_cheq         as character format "x(5)" label "Motivo Devolu‡Æo" column-label "Motivo Devolu‡Æo"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_usuar_cheq_acr_terc      as character format "x(12)" label "Usu rio" column-label "Usu rio"
    field tta_log_pend_cheq_acr            as logical format "Sim/NÆo" initial no label "Cheque Pendente" column-label "Cheque Pendente"
    field tta_log_cheq_terc                as logical format "Sim/NÆo" initial no label "Cheque Terceiro" column-label "Cheque Terceiro"
    field tta_log_cheq_acr_renegoc         as logical format "Sim/NÆo" initial no label "Cheque Reneg" column-label "Cheque Reneg"
    field tta_log_cheq_acr_devolv          as logical format "Sim/NÆo" initial no label "Cheque Devolvido" column-label "Cheque Devolvido"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    index tt_id                            is primary unique
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending.

def temp-table tt_integr_acr_liquidac_impto_2 no-undo
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequˆncia" column-label "Seq"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa‡Æo" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_val_retid_indic_impto        as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE Imposto" column-label "Vl Retido IE Imposto"
    field tta_val_retid_indic_tit_acr      as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE T¡tulo" column-label "Vl Retido IE T¡tulo"
    field tta_val_retid_indic_pagto        as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Retido Indicador Pag" column-label "Retido Indicador Pag"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota‡Æo" column-label "Data Cota‡Æo"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota‡Æo" column-label "Cota‡Æo"
    field tta_dat_cotac_indic_econ_pagto   as date format "99/99/9999" initial ? label "Dat Cotac IE Pagto" column-label "Dat Cotac IE Pagto"
    field tta_val_cotac_indic_econ_pagto   as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Val Cotac IE Pagto" column-label "Val Cotac IE Pagto"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical format "Sim/NÆo" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical format "Sim/NÆo" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tribut vel" column-label "Vl Rendto Tribut".

def temp-table tt_integr_acr_liq_aprop_ctbl        
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    index tt_integr_acr_liq_aprop_ctbl_id  is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_cod_unid_negoc               ascending.

def temp-table tt_integr_acr_liq_desp_rec        
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg¢cio Externa" column-label "Unid Neg¢cio Externa"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Abatimento" column-label "Tipo de Abatimento"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropria‡Æo" column-label "Tipo Apropria‡Æo"
    field tta_val_perc_rat_ctbz            as decimal format ">>9.99" decimals 2 initial 0 label "Perc Rateio" column-label "% Rat"
    index tt_integr_acr_liq_des_rec_id     is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_cta_ctbl_ext             ascending
          tta_cod_sub_cta_ctbl_ext         ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_unid_negoc_ext           ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_ind_tip_aprop_recta_despes   ASCENDING.



def temp-table tt_integr_acr_rel_pend_cheq no-undo
    field ttv_rec_item_lote_liquidac_acr   as recid format ">>>>>>9"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_val_vincul_cheq_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Vinculado" column-label "Valor Vinculado"
    field tta_cdn_bco_cheq_salario         as Integer format ">>9" initial 0 label "Banco Cheque Sal rio" column-label "Banco Cheque Sal rio".

def temp-table tt_integr_acr_aprop_liq_antec        
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field ttv_cod_fluxo_financ_tit_ext     as character format "x(20)" label "Fuxo Tit Ext" column-label "Fuxo Tit Ext"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_unid_negoc_tit           as character format "x(3)" label "Unid Negoc T¡tulo" column-label "Unid Negoc T¡tulo"
    field tta_cod_tip_fluxo_financ_tit     as character format "x(12)" label "Tp Fluxo Financ Tit" column-label "Tp Fluxo Financ Tit"
    field tta_val_abtdo_antecip            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatido" column-label "Vl Abatido".

def temp-table tt_log_erros_import_liquidac        
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequˆncia" column-label "NumSeq"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Referˆncia" column-label "Referˆncia"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp‚cie Documento" column-label "Esp‚cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S‚rie Documento" column-label "S‚rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_nom_abrev_clien              as character format "x(12)" label "Cliente" column-label "Cliente"
    field ttv_num_erro_log                 as integer format ">>>>,>>9" label "N£mero Erro" column-label "N£mero Erro"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    index tt_sequencia                    
          tta_num_seq                      ASCENDING.

def temp-table tt_integr_cambio_ems5 no-undo                                                                                                              
    field ttv_rec_table_child              as recid format ">>>>>>9"                                                                                      
    field ttv_rec_table_parent             as recid format ">>>>>>9"                                                                                      
    field ttv_cod_contrat_cambio           as character format "x(15)"                                                                                    
    field ttv_dat_contrat_cambio_import    as date format "99/99/9999"                                                                                    
    field ttv_num_contrat_id_cambio        as integer format "999999999"                                                                                  
    field ttv_cod_estab_contrat_cambio     as character format "x(3)"                                                                                     
    field ttv_cod_refer_contrat_cambio     as character format "x(10)"                                                                                    
    field ttv_dat_refer_contrat_cambio     as date format "99/99/9999"                                                                                    
    index tt_rec_index                     is primary unique                                                                                              
          ttv_rec_table_parent             ascending                                                                                                      
          ttv_rec_table_child              ASCENDING.    

Def new shared temp-table tt_params_generic_api no-undo
    field ttv_rec_id                       as recid format ">>>>>>9"
    field ttv_cod_tabela                   as character format "x(28)" label "Tabela" column-label "Tabela"
    field ttv_cod_campo                    as character format "x(25)" label "Campo" column-label "Campo"  
    field ttv_cod_valor                    as character format "x(8)" label "Valor" column-label "Valor"   
    index tt_idx_param_generic             is primary unique
          ttv_cod_tabela                   ascending        
          ttv_rec_id                       ascending        
          ttv_cod_campo                    ascending.       

/****************************************** TT do Programa ***********************/
DEF TEMP-TABLE tt-erro_tit_acr NO-UNDO
    FIELD cod_estab       AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Estab"
    FIELD cod_espec_docto AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Espec"
    FIELD cod_ser_docto   AS CHAR FORMAT "x(3)"    COLUMN-LABEL "Serie"
    FIELD cod_tit_acr     AS CHAR FORMAT "x(10)"   COLUMN-LABEL "Titulo"
    FIELD cod_parcela     AS CHAR FORMAT "x(02)"   COLUMN-LABEL "Parcela"
    FIELD texto_msg       AS CHAR FORMAT "x(200)"  COLUMN-LABEL "Mensagem"
    FIELD cod_refer       AS CHAR FORMAT "x(10)"   COLUMN-LABEL "Lote"
    FIELD seq_msg         AS INT
    FIELD tipo_msg        AS INT   /* 1-ERRO  /  2-INFORMATIVO */
    INDEX i-id IS PRIMARY seq_msg.
/*
DEF TEMP-TABLE tt_movto_log_pdd NO-UNDO                    /* TT do BROWSER de LOG PDD */
    FIELD ind_selec             AS CHAR  FORMAT "x(01)"
    FIELD ind_sit_mov           AS CHAR  FORMAT "x(09)"
    FIELD cod_empresa           AS CHAR  FORMAT "x(03)"                       
    FIELD cod_estab             AS CHAR  FORMAT "x(05)"                       
    FIELD cod_espec_docto       AS CHAR  FORMAT "x(03)"                       
    FIELD cod_ser_docto         AS CHAR  FORMAT "x(03)"                        
    FIELD cod_tit_acr           AS CHAR  FORMAT "x(10)"
    FIELD cod_parcela           AS CHAR  FORMAT "x(02)"
    FIELD dat_emissao           AS DATE  FORMAT 99/99/9999
    FIELD dat_vencto_tit_acr    AS DATE  FORMAT 99/99/9999
    FIELD dat_transacao         AS DATE  FORMAT 99/99/9999
    FIELD dat_gerac_movto       AS DATE  FORMAT 99/99/9999
    FIELD qtd_dias_vencidos     AS INT   FORMAT ">>>9"
    FIELD ind_log_pdd           AS CHAR  FORMAT "x(10)"
    FIELD ind_ctbz_val          AS CHAR  FORMAT "x(10)"
    FIELD cdn_cliente           AS INT   FORMAT ">>>,>>>,>>9"
    FIELD nom_abrev             AS CHAR  FORMAT "x(15)"
    FIELD nom_pessoa            AS CHAR  FORMAT "x(40)"
    FIELD num_id_feder          AS CHAR  FORMAT "99.999.999/9999-99"
    FIELD cod_cart_bcia         AS CHAR  FORMAT "x(03)"
    FIELD val_movto             AS DEC   FORMAT ">>>,>>>,>>9.99"
    FIELD dat_ctbz              AS DATE  FORMAT 99/99/9999
    FIELD cod_usuar_gerac_movto AS CHAR  FORMAT "x(12)"
    FIELD cod_usuar_ctbz        AS CHAR  FORMAT "x(12)"
    FIELD num_id_tit_acr        AS INT
    FIELD num_id_movto_tit_acr  AS INT
    FIELD recid_movto           AS RECID
    FIELD num_seq_mov           AS INT   FORMAT ">9"
    FIELD cpo_class_1           AS CHAR  FORMAT "x(20)"
    FIELD cpo_class_2           AS CHAR  FORMAT "x(20)"
    FIELD cpo_class_3           AS CHAR  FORMAT "x(20)"
    FIELD ind_regra_incobr      AS CHAR  FORMAT "x(5)"
    INDEX classif
          cpo_class_1
          cpo_class_2
          cpo_class_3.
*/

DEF TEMP-TABLE tt_movto_log_pdd NO-UNDO                               
    FIELD ind_selec             AS CHAR  FORMAT "x(01)"               
    FIELD ind_sit_mov           AS CHAR  FORMAT "x(09)"               
    FIELD cod_empresa           AS CHAR  FORMAT "x(03)"               
    FIELD cod_estab             AS CHAR  FORMAT "x(05)"               
    FIELD cod_espec_docto       AS CHAR  FORMAT "x(03)"               
    FIELD cod_ser_docto         AS CHAR  FORMAT "x(03)"               
    FIELD cod_tit_acr           AS CHAR  FORMAT "x(10)"               
    FIELD cod_parcela           AS CHAR  FORMAT "x(02)"               
    FIELD dat_emissao           AS DATE  FORMAT 99/99/9999            
    FIELD dat_vencto_tit_acr    AS DATE  FORMAT 99/99/9999            
    FIELD dat_transacao         AS DATE  FORMAT 99/99/9999            
    FIELD dat_gerac_movto       AS DATE  FORMAT 99/99/9999            
    FIELD qtd_dias_vencidos     AS INT   FORMAT ">>>9"                
    FIELD ind_log_pdd           AS CHAR  FORMAT "x(10)"               
    FIELD ind_ctbz_val          AS CHAR  FORMAT "x(10)"               
    FIELD cdn_cliente           AS INT   FORMAT ">>>,>>>,>>9"         
    FIELD nom_abrev             AS CHAR  FORMAT "x(15)"               
    FIELD nom_pessoa            AS CHAR  FORMAT "x(40)"               
    FIELD num_id_feder          AS CHAR  FORMAT "99.999.999/9999-99"  
    FIELD cod_cart_bcia         AS CHAR  FORMAT "x(03)"               
    FIELD val_movto             AS DEC   FORMAT ">>>,>>>,>>9.99"      
    FIELD val_bruto             AS DEC   FORMAT ">>>,>>>,>>9.99"      
    FIELD dat_ctbz              AS DATE  FORMAT 99/99/9999            
    FIELD cod_usuar_gerac_movto AS CHAR  FORMAT "x(12)"               
    FIELD cod_usuar_ctbz        AS CHAR  FORMAT "x(12)"               
    FIELD num_id_tit_acr        AS INT                                
    FIELD num_id_movto_tit_acr  AS INT                                
    FIELD recid_movto           AS RECID                              
    FIELD num_seq_mov           AS INT   FORMAT ">9"                  
    FIELD cpo_class_1           AS CHAR  FORMAT "x(20)"               
    FIELD cpo_class_2           AS CHAR  FORMAT "x(20)"               
    FIELD cpo_class_3           AS CHAR  FORMAT "x(20)"               
    FIELD ind_regra_incobr      AS CHAR  FORMAT "x(5)"                
    INDEX classif                                                     
          cpo_class_1                                                 
          cpo_class_2                                                 
          cpo_class_3.                                                

/************************ Patametros definition *************************/
DEF INPUT PARAM TABLE FOR tt_movto_log_pdd.

/************************ Variaveid definition *************************/

DEF VAR i-seq           AS INT INIT 0               NO-UNDO. 
DEF VAR v_cont          AS INT                      NO-UNDO.
DEF VAR l-erro          AS LOGICAL                  NO-UNDO.
DEF VAR h-acomp         AS HANDLE                   NO-UNDO.
DEF VAR i-sq-erro       AS INT INIT 0               NO-UNDO.   
DEF VAR c-arquivo       AS CHAR FORMAT "x(400)"     NO-UNDO.
def var v_hdl_aux       as Handle                   NO-UNDO.
DEF VAR c-cod_refer     AS CHAR                     NO-UNDO.    
DEF VAR v_log_refer_uni AS LOG INIT NO              NO-UNDO.      

DEF VAR v_cod_empres_usuar_bkp AS CHAR              NO-UNDO.

/************************ Bufferïs definition *************************/
def buffer b_cobr_especial_acr for cobr_especial_acr.
def buffer b_lote_impl_tit_acr for lote_impl_tit_acr.
def buffer b_lote_liquidac_acr for lote_liquidac_acr.
def buffer b_movto_tit_acr     for movto_tit_acr.
def buffer b_operac_financ_acr for operac_financ_acr.
def buffer b_renegoc_acr       for renegoc_acr.

/************************ STREAM definition *************************/
DEF STREAM s-log.

/*********************** MAIN CODE begin ***************************/
ASSIGN c-arquivo              = SESSION:TEMP-DIRECTORY + "ESACR022_" + STRING(TIME) + ".txt".
       v_cod_empres_usuar_bkp = v_cod_empres_usuar.

OUTPUT STREAM s-log TO VALUE(c-arquivo).
                                                                                           
RUN utp\ut-acomp.p PERSISTENT SET h-acomp.

RUN pi-inicializar IN h-acomp (INPUT "Liquidando Titulos").

EMPTY TEMP-TABLE tt-erro_tit_acr.

atualizacao:
do transaction on error undo atualizacao, leave atualizacao
               on STOP  undo atualizacao, leave atualizacao:

    ASSIGN l-erro = NO.

    FOR EACH tt_movto_log_pdd 
    BREAK BY tt_movto_log_pdd.cod_estab:
    
        RUN pi-acompanhar IN h-acomp (INPUT "Titulo: " + tt_movto_log_pdd.cod_tit_acr).
        
        EMPTY TEMP-TABLE tt_integr_acr_liquidac_lote.
        EMPTY TEMP-TABLE tt_integr_acr_liq_item_lote_3.
    
        pesq_ref:                                                    
        REPEAT:                                                      
           RUN /* pi_referencia */ pi_retorna_sugestao_referencia (INPUT "P",                             
                                                                   INPUT TODAY,                     
                                                                   OUTPUT c-cod_refer).                   
                                                                     
           RUN pi_verifica_refer_unica_acr (INPUT tt_movto_log_pdd.cod_estab,       
                                            INPUT c-cod_refer,       
                                            INPUT "",                
                                            INPUT ?,                 
                                            OUTPUT v_log_refer_uni).
    
           IF v_log_refer_uni = TRUE THEN                             
              LEAVE pesq_ref.               
    
        END.         
    
        CREATE tt_integr_acr_liquidac_lote.                                                                        
        ASSIGN tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tt_movto_log_pdd.cod_empresa
               tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = tt_movto_log_pdd.cod_estab
               tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod_refer
               tt_integr_acr_liquidac_lote.tta_cod_usuario                 = v_cod_usuar_corren    
               tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = TODAY
               tt_integr_acr_liquidac_lote.tta_dat_transacao               = TODAY 
               tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "Perda Dedut¡vel" //tt_titulos.ind_tip_liq_acr
               tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Liquidado" /*"Em digita‡Æo"*/
               tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = NO
               tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES //tt_titulos.log_atualiz_refer
               tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = NO
               tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = RECID(tt_integr_acr_liquidac_lote).
    
        FIND FIRST tt_integr_acr_liquidac_lote NO-LOCK NO-ERROR.
    
        FIND FIRST tit_acr NO-LOCK WHERE
                   tit_acr.cod_estab      = tt_movto_log_pdd.cod_estab
               AND tit_acr.num_id_tit_acr = tt_movto_log_pdd.num_id_tit_acr  NO-ERROR.
    
           ASSIGN i-seq       = 0.         
                  i-seq       = i-seq + 1. 
    
        CREATE tt_integr_acr_liq_item_lote_3.                                                                                       
        ASSIGN tt_integr_acr_liq_item_lote_3.tta_cod_empresa                = tit_acr.cod_empresa                                   
               tt_integr_acr_liq_item_lote_3.tta_cod_estab                  = tit_acr.cod_estab                                     
               tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto            = tit_acr.cod_espec_docto                               
               tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto              = tit_acr.cod_ser_docto                                 
               tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr                = tit_acr.cod_tit_acr                                   
               tt_integr_acr_liq_item_lote_3.tta_cod_parcela                = tit_acr.cod_parcela                                   
               tt_integr_acr_liq_item_lote_3.tta_cdn_cliente                = tit_acr.cdn_cliente                                   
               tt_integr_acr_liq_item_lote_3.tta_cod_portador               = tit_acr.cod_portador                               
               tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia              = tit_acr.cod_cart_bcia                               
               tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ           = "Corrente"                                            
               tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ             = tit_acr.cod_indic_econ                                
               tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr    = TODAY
               tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr       = TODAY
               tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr       = tt_movto_log_pdd.val_movto
               tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia            = 0
               tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip           = NO
               tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb             = NO
               tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr  = "Perdas"
               tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr      = RECID(tt_integr_acr_liquidac_lote)
               tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = RECID(tt_integr_acr_liq_item_lote_3)
               tt_integr_acr_liq_item_lote_3.tta_num_seq_refer              = i-seq.    
        
        FIND FIRST tt_integr_acr_liquidac_lote   NO-LOCK NO-ERROR.
        FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
        
        ASSIGN v_cod_empres_usuar = tit_acr.cod_empresa.

        RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_aux.
    
        RUN pi_main_code_api_integr_acr_liquidac_6 IN v_hdl_aux (INPUT 1,
                                                                 INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                 INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                 INPUT TABLE tt_integr_acr_abat_antecip,
                                                                 INPUT TABLE tt_integr_acr_abat_prev,
                                                                 INPUT TABLE tt_integr_acr_cheq,
                                                                 INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                 INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                 INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                 INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                 INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                 INPUT '', /*Matriz de tradu‡Æo*/
                                                                 OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                 INPUT TABLE tt_integr_cambio_ems5,
                                                                 INPUT TABLE tt_params_generic_api).
            
        IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:                                                                                                                                 
            FOR EACH tt_log_erros_import_liquidac:      
    
                ASSIGN l-erro = YES
                       i-sq-erro = i-sq-erro + 1.     
    
                CREATE tt-erro_tit_acr.                                                                                                      
                ASSIGN tt-erro_tit_acr.seq_msg         = i-sq-erro
                       tt-erro_tit_acr.cod_estab       = tit_acr.cod_estab      
                       tt-erro_tit_acr.cod_espec_docto = tit_acr.cod_espec_docto  
                       tt-erro_tit_acr.cod_ser_docto   = tit_acr.cod_ser_docto    
                       tt-erro_tit_acr.cod_tit_acr     = tit_acr.cod_tit_acr      
                       tt-erro_tit_acr.cod_parcela     = tit_acr.cod_parcela      
                       tt-erro_tit_acr.texto_msg       = STRING(tt_log_erros_import_liquidac.ttv_num_erro_log) + " - " +  tt_log_erros_import_liquidac.ttv_des_msg_erro    
                       tt-erro_tit_acr.tipo_msg        = 1.                                                                                       
            END.                                      
        END.                                                                                                                                
        ELSE DO:
            /* nao ocorreram erros */
            CREATE tt-erro_tit_acr.                                                                                                      
                ASSIGN tt-erro_tit_acr.seq_msg         = 1
                       tt-erro_tit_acr.cod_estab       = tit_acr.cod_estab      
                       tt-erro_tit_acr.cod_espec_docto = tit_acr.cod_espec_docto
                       tt-erro_tit_acr.cod_ser_docto   = tit_acr.cod_ser_docto  
                       tt-erro_tit_acr.cod_tit_acr     = tit_acr.cod_tit_acr    
                       tt-erro_tit_acr.cod_parcela     = tit_acr.cod_parcela    
                       tt-erro_tit_acr.texto_msg       = "Titulo Liquidado com Sucesso"
                       tt-erro_tit_acr.cod_refer       = c-cod_refer
                       tt-erro_tit_acr.tipo_msg        = 2.                                                                                       
    
        END.
    
        DELETE PROCEDURE v_hdl_aux.
    
    END. /* tt_movto_log_pdd */

    IF l-erro THEN DO:
        UNDO atualizacao, LEAVE atualizacao.    
    END.

    ASSIGN v_cod_empres_usuar = v_cod_empres_usuar_bkp.

END. /*transaction */

RUN pi-finalizar IN h-acomp.

RUN pi_show_log.

/*********************************************************************/
RETURN "OK":U.



*/
 

