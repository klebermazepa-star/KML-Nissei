&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-tit_ap NO-UNDO LIKE tit_ap
       field nom_abrev like ems5.fornecedor.nom_abrev
       field r-rowid as recid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/***
*
* PROGRAMA:
*   cstp/csap002.w
*
* FINALIDADE:
*   Programa de vinculacao de codigos de barras aos titulos a pagar
*
* VERSAO ATUAL:
*   $Version: 5.04.00.01
*
* VERSOES: 
*       5.04.00.01 - 13/05/2009 - Manoel Souza
*       
*
*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
define new global shared variable v_cod_usuar_corren as character no-undo.
define new global shared variable v_cod_estab_usuar as character no-undo.

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-valorlido     like tit_ap.val_origin_tit_ap no-undo.
def var v-digvenc       AS char no-undo.
def var v-datavenctit   AS date no-undo.

define variable nomeFornecedor as character no-undo.

def temp-table tt_tit_ap_alteracao_base_1 no-undo
    field ttv_cod_usuar_corren             as character format "x(12)" label "Usuˇrio Corrente" column-label "Usuˇrio Corrente"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_rec_tit_ap                   as recid format ">>>>>>9" initial ?
    field tta_cdn_fornecedor               as Integer format ">>>,>>>,>>9" initial 0 label "Fornecedor" column-label "Fornecedor"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp≤cie Documento" column-label "Esp≤cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S≤rie Documento" column-label "S≤rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T≠tulo" column-label "T≠tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_dat_transacao                as date format "99/99/9999" label "Data Transaªío" column-label "Data Transaªío"
    field ttv_cod_refer                    as character format "x(10)" label "Referºncia" column-label "Referºncia"
    field tta_val_sdo_tit_ap               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Saldo" column-label "Valor Saldo"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emissío" column-label "Dt Emissío"
    field tta_dat_vencto_tit_ap            as date format "99/99/9999" initial today label "Data Vencimento" column-label "Dt Vencto"
    field tta_dat_prev_pagto               as date format "99/99/9999" initial today label "Data Prevista Pgto" column-label "Dt Prev Pagto"
    field tta_dat_ult_pagto                as date format "99/99/9999" initial ? label "Data último Pagto" column-label "Data último Pagto"
    field tta_num_dias_atraso              as integer format ">9" initial 0 label "Dias Atraso" column-label "Dias Atr"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_juros_dia_atraso         as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juro" column-label "Vl Juro"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field ttv_cod_portador_mov             as character format "x(5)" label "Portador Movto" column-label "Portador Movto"
    field tta_log_pagto_bloqdo             as logical format "Sim/N o" initial no label "Bloqueia Pagamento" column-label "Pagto Bloqdo"
    field tta_cod_seguradora               as character format "x(8)" label "Seguradora" column-label "Seguradora"
    field tta_cod_apol_seguro              as character format "x(12)" label "ApΩlice Seguro" column-label "Apolice Seguro"
    field tta_cod_arrendador               as character format "x(6)" label "Arrendador" column-label "Arrendador"
    field tta_cod_contrat_leas             as character format "x(12)" label "Contrato Leasing" column-label "Contr Leas"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Esp≤cie" column-label "Tipo Esp≤cie"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequºncia" column-label "Seq"
    field ttv_ind_motiv_alter_val_tit_ap   as character format "X(09)" initial "Alteraªío" label "Motivo Alteraªío" column-label "Motivo Alteraªío"
    field ttv_wgh_lista                    as widget-handle extent 15 format ">>>>>>9"
    field ttv_log_gera_ocor_alter_valores  as logical format "Sim/Nío" initial no
    field tta_cb4_tit_ap_bco_cobdor        as Character format "x(50)" label "Titulo Bco Cobrador" column-label "Titulo Bco Cobrador"
    field tta_cod_histor_padr              as character format "x(8)" label "HistΩrico Padrío" column-label "HistΩrico Padrío"
    field tta_des_histor_padr              as character format "x(40)" label "Descriªío" column-label "Descriªío HistΩrico Padrío"
    field tta_ind_sit_tit_ap               as character format "X(13)" label "Situaªío" column-label "Situaªío"
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
    field tta_cod_refer                    as character format "x(10)" label "Referºncia" column-label "Referºncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Seq±ºncia" column-label "Seq"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contˇbil" column-label "Conta Contˇbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid NegΩcio" column-label "Un Neg"
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
    field tta_cod_espec_docto              as character format "x(3)" label "Esp≤cie Documento" column-label "Esp≤cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S≤rie Documento" column-label "S≤rie"
    field tta_cod_tit_ap                   as character format "x(10)" label "T≠tulo" column-label "T≠tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_num_id_tit_ap                as integer format "9999999999" initial 0 label "Token Tit AP" column-label "Token Tit AP"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nﬂmero" column-label "Número Mensagem"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "inconsistºncia"
    field ttv_des_msg_ajuda_1              as character format "x(360)"
    field ttv_wgh_focus                    as widget-handle format ">>>>>>9".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-tit

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tit_ap

/* Definitions for BROWSE br-tit                                        */
&Scoped-define FIELDS-IN-QUERY-br-tit tt-tit_ap.val_sdo_tit_ap tt-tit_ap.dat_vencto_tit_ap tt-tit_ap.cod_estab tt-tit_ap.cdn_fornecedor tt-tit_ap.nom_abrev tt-tit_ap.cod_espec_docto tt-tit_ap.cod_ser_docto tt-tit_ap.cod_tit_ap tt-tit_ap.cod_parcela tt-tit_ap.val_origin_tit_ap tt-tit_ap.val_sdo_tit_ap tt-tit_ap.dat_transacao tt-tit_ap.dat_liquidac_tit_ap tt-tit_ap.dat_emis_docto tt-tit_ap.ind_sit_tit_ap tt-tit_ap.cb4_tit_ap_bco_cobdor tt-tit_ap.val_juros tt-tit_ap.val_desconto   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tit   
&Scoped-define SELF-NAME br-tit
&Scoped-define QUERY-STRING-br-tit FOR EACH tt-tit_ap NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-tit OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-tit tt-tit_ap
&Scoped-define FIRST-TABLE-IN-QUERY-br-tit tt-tit_ap


/* Definitions for FRAME DEFAULT-FRAME                                  */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS valorVariacao valorTarifa diasVencimento ~
v_cod_estab_ini v_cod_estab_fim v-dt-venci v-val-tit v-cod-bar fi-lin-dig ~
bt-ok br-tit bt_fechar bt_ajuda IMAGE-1 IMAGE-2 RECT-1 RECT-16 RECT-35 ~
RECT-37 RECT-38 RECT-8 
&Scoped-Define DISPLAYED-OBJECTS valorVariacao dataVencimento valorJuros ~
valorTarifa diasVencimento v_cod_estab_ini v_cod_estab_fim v-dt-venci ~
v-val-tit v-cod-bar fi-lin-dig v-dt-venci-cb v-val-tit-cb valorDesconto 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getNomeFornecedor C-Win 
FUNCTION getNomeFornecedor RETURNS CHARACTER
  ( input codigo as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-bt_ajuda 
       MENU-ITEM m_Ajuda        LABEL "Ajuda"         
       MENU-ITEM m_Sobre        LABEL "Sobre"         .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-canc 
     IMAGE-UP FILE "image/im-can.bmp":U
     LABEL "Canc" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-confirma 
     LABEL "Confirma" 
     SIZE 15 BY 1 TOOLTIP "Confirma"
     FONT 1.

DEFINE BUTTON bt-ok 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "Ok" 
     SIZE 4 BY 1.

DEFINE BUTTON bt_ajuda 
     LABEL "Ajuda" 
     SIZE 10.57 BY 1 TOOLTIP "Ajuda/Sobre"
     FONT 1.

DEFINE BUTTON bt_fechar AUTO-GO 
     LABEL "Fechar" 
     SIZE 10.57 BY 1 TOOLTIP "Cancela"
     FONT 1.

DEFINE VARIABLE dataVencimento AS DATE FORMAT "99/99/9999":U 
     LABEL "Data vencimento" 
     VIEW-AS FILL-IN 
     SIZE 10.43 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE diasVencimento AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Variaá∆o Dias Vencto/ Valor" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE fi-lin-dig AS CHARACTER FORMAT "XXXXX.XXXXX XXXXX.XXXXXX XXXXX.XXXXXX X XXXXXXXXXXXXXX" 
     LABEL "Linha digit†vel" 
     VIEW-AS FILL-IN 
     SIZE 51.14 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE v-cod-bar AS CHARACTER FORMAT "x(47)" 
     LABEL "C¢digo de Barras" 
     VIEW-AS FILL-IN 
     SIZE 51.14 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE v-dt-venci AS DATE FORMAT "99/99/9999" 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 10.43 BY .88
     BGCOLOR 15 FONT 1 NO-UNDO.

DEFINE VARIABLE v-dt-venci-cb AS DATE FORMAT "99/99/9999" 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 10.43 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE v-val-tit AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Valor Original" 
     VIEW-AS FILL-IN 
     SIZE 14.57 BY .88
     BGCOLOR 15 FONT 1 NO-UNDO.

DEFINE VARIABLE v-val-tit-cb AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Valor Original" 
     VIEW-AS FILL-IN 
     SIZE 14.57 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE valorDesconto AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Acerto a menor" 
     VIEW-AS FILL-IN 
     SIZE 13.57 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE valorJuros AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Acerto a maior" 
     VIEW-AS FILL-IN 
     SIZE 13.57 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE valorTarifa AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Tarifa" 
     VIEW-AS FILL-IN 
     SIZE 13.57 BY .79
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE valorVariacao AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "/" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE v_cod_estab_fim AS CHARACTER FORMAT "x(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15 FONT 1 NO-UNDO.

DEFINE VARIABLE v_cod_estab_ini AS CHARACTER FORMAT "x(3)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15 FONT 1 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image/im-fir.bmp":U
     SIZE 3 BY .96.

DEFINE IMAGE IMAGE-2
     FILENAME "image/im-las.bmp":U
     SIZE 3 BY .96.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103 BY 1.75.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 102.72 BY 1.5
     BGCOLOR 18 .

DEFINE RECTANGLE RECT-35
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 72 BY 3.5.

DEFINE RECTANGLE RECT-37
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103 BY 3.25.

DEFINE RECTANGLE RECT-38
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 31 BY 3.5.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103 BY 9.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-tit FOR 
      tt-tit_ap SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-tit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tit C-Win _FREEFORM
  QUERY br-tit NO-LOCK DISPLAY
      tt-tit_ap.val_sdo_tit_ap
    tt-tit_ap.dat_vencto_tit_ap
    tt-tit_ap.cod_estab
    tt-tit_ap.cdn_fornecedor
    tt-tit_ap.nom_abrev
    tt-tit_ap.cod_espec_docto
    tt-tit_ap.cod_ser_docto
    tt-tit_ap.cod_tit_ap width 10
    tt-tit_ap.cod_parcela
    tt-tit_ap.val_origin_tit_ap
    tt-tit_ap.val_sdo_tit_ap
    tt-tit_ap.dat_transacao
    tt-tit_ap.dat_liquidac_tit_ap
    tt-tit_ap.dat_emis_docto
    tt-tit_ap.ind_sit_tit_ap
    tt-tit_ap.cb4_tit_ap_bco_cobdor
    tt-tit_ap.val_juros
    tt-tit_ap.val_desconto
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101 BY 8.5
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     valorVariacao AT ROW 1.25 COL 89 COLON-ALIGNED WIDGET-ID 10
     dataVencimento AT ROW 15.75 COL 15 COLON-ALIGNED WIDGET-ID 8
     valorJuros AT ROW 15.75 COL 37 COLON-ALIGNED WIDGET-ID 4
     valorTarifa AT ROW 15.75 COL 56 COLON-ALIGNED WIDGET-ID 6
     diasVencimento AT ROW 1.25 COL 78 COLON-ALIGNED WIDGET-ID 2
     v_cod_estab_ini AT ROW 1.29 COL 34.57 COLON-ALIGNED HELP
          "C¢digo Estabelecimento"
     v_cod_estab_fim AT ROW 1.29 COL 49.29 COLON-ALIGNED HELP
          "C¢digo Estabelecimento" NO-LABEL
     v-dt-venci AT ROW 3.04 COL 13 COLON-ALIGNED HELP
          "Data Vencimento T°tulo"
     v-val-tit AT ROW 3.08 COL 49.43 COLON-ALIGNED HELP
          "Valor Original T°tulo"
     v-cod-bar AT ROW 4.04 COL 12.86 COLON-ALIGNED
     fi-lin-dig AT ROW 5 COL 12.86 COLON-ALIGNED
     bt-ok AT ROW 4 COL 67
     v-dt-venci-cb AT ROW 3.25 COL 89 COLON-ALIGNED HELP
          "Data Vencimento T°tulo" NO-TAB-STOP 
     bt-canc AT ROW 5 COL 67
     br-tit AT ROW 6.5 COL 2
     v-val-tit-cb AT ROW 4.25 COL 85 COLON-ALIGNED HELP
          "Valor Original T°tulo" NO-TAB-STOP 
     valorDesconto AT ROW 15.75 COL 82 COLON-ALIGNED HELP
          "Valor Desconto Quando Pago AtÇ Data Desconto"
     bt-confirma AT ROW 17 COL 82.57
     bt_fechar AT ROW 18.88 COL 2.14
     bt_ajuda AT ROW 18.88 COL 92.43
     IMAGE-1 AT ROW 1.29 COL 42
     IMAGE-2 AT ROW 1.29 COL 48.14
     RECT-1 AT ROW 1 COL 1
     RECT-16 AT ROW 18.63 COL 1
     RECT-35 AT ROW 2.75 COL 1
     RECT-37 AT ROW 15.25 COL 1
     RECT-38 AT ROW 2.75 COL 73
     RECT-8 AT ROW 6.25 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 103 BY 19.25
         BGCOLOR 17 FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Temp-Tables and Buffers:
      TABLE: tt-tit_ap T "?" NO-UNDO emsfin tit_ap
      ADDITIONAL-FIELDS:
          field nom_abrev like fornecedor.nom_abrev
          field r-rowid as recid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Relacionamento boteto banc†rio com contas a pagar"
         HEIGHT             = 19.25
         WIDTH              = 103
         MAX-HEIGHT         = 24.46
         MAX-WIDTH          = 126.72
         VIRTUAL-HEIGHT     = 24.46
         VIRTUAL-WIDTH      = 126.72
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-tit bt-canc DEFAULT-FRAME */
ASSIGN 
       br-tit:COLUMN-RESIZABLE IN FRAME DEFAULT-FRAME       = TRUE
       br-tit:COLUMN-MOVABLE IN FRAME DEFAULT-FRAME         = TRUE.

/* SETTINGS FOR BUTTON bt-canc IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-confirma IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       bt_ajuda:POPUP-MENU IN FRAME DEFAULT-FRAME       = MENU POPUP-MENU-bt_ajuda:HANDLE.

/* SETTINGS FOR FILL-IN dataVencimento IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-dt-venci-cb IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-val-tit-cb IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN valorDesconto IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN valorJuros IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tit
/* Query rebuild information for BROWSE br-tit
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-tit */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Relacionamento boteto banc†rio com contas a pagar */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Relacionamento boteto banc†rio com contas a pagar */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit
&Scoped-define SELF-NAME br-tit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit C-Win
ON LEAVE OF br-tit IN FRAME DEFAULT-FRAME
DO:
    APPLY "value-changed":u TO br-tit in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit C-Win
ON MOUSE-SELECT-DBLCLICK OF br-tit IN FRAME DEFAULT-FRAME
DO:
    if not(query br-tit:query-off-end) then do:
        assign 
            dataVencimento:screen-value in frame {&frame-name} = string(input browse br-tit tt-tit_ap.dat_vencto_tit_ap).

        apply 'entry' to dataVencimento in frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit C-Win
ON RETURN OF br-tit IN FRAME DEFAULT-FRAME
DO:
    apply 'choose' to bt-confirma.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit C-Win
ON VALUE-CHANGED OF br-tit IN FRAME DEFAULT-FRAME
DO:
    assign 
        dataVencimento:screen-value in frame {&frame-name} = string(input browse br-tit tt-tit_ap.dat_vencto_tit_ap).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-canc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-canc C-Win
ON CHOOSE OF bt-canc IN FRAME DEFAULT-FRAME /* Canc */
DO:
    run clearFields.
  
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma C-Win
ON CHOOSE OF bt-confirma IN FRAME DEFAULT-FRAME /* Confirma */
DO:
    if not avail tt-tit_ap then do:

        message "Nenhum documento selecionado"
            view-as alert-box error.

        return no-apply.
    end.

    if can-find(first tit_ap
                where tit_ap.cod_estab              = tt-tit_ap.cod_estab      
                  and tit_ap.cdn_fornecedor         = tt-tit_ap.cdn_fornecedor 
                  and tit_ap.cod_espec_docto        = tt-tit_ap.cod_espec_docto
                  and tit_ap.cod_ser_docto          = tt-tit_ap.cod_ser_docto  
                  and tit_ap.cod_tit_ap             = tt-tit_ap.cod_tit_ap     
                  and tit_ap.cod_parcela            = tt-tit_ap.cod_parcela
                  and tit_ap.cb4_tit_ap_bco_cobdor <> '')
        then do:

        message "T°tulo j† vinculado"
               view-as alert-box error.

        return no-apply.
    end.

    if input frame {&frame-name} v-dt-venci-cb <> input frame {&frame-name} dataVencimento then do:

        message 'O vencimento deve ser' v-dt-venci-cb:screen-value in frame {&frame-name}
               view-as alert-box error. 

        return no-apply.
    end.

    if input frame {&frame-name} v-val-tit-cb <> tt-tit_ap.val_sdo_tit_ap 
        + input frame {&frame-name} valorJuros 
        + input frame {&frame-name} valorTarifa
        - input frame {&frame-name} valorDesconto then do:

        message "Saldo atual mais juros e mais tarifa diferente do valor do boleto"
               view-as alert-box error. 

        return no-apply.
    end.

    bloco-trans:
    do transaction on error undo, leave:
        find first tit_ap
            where tit_ap.cod_estab       = tt-tit_ap.cod_estab      
              and tit_ap.cdn_fornecedor  = tt-tit_ap.cdn_fornecedor 
              and tit_ap.cod_espec_docto = tt-tit_ap.cod_espec_docto
              and tit_ap.cod_ser_docto   = tt-tit_ap.cod_ser_docto  
              and tit_ap.cod_tit_ap      = tt-tit_ap.cod_tit_ap     
              and tit_ap.cod_parcela     = tt-tit_ap.cod_parcela
            no-lock no-error.

        if available tit_ap then do:
            
            run createLog.

            if input frame {&frame-name} dataVencimento <> tit_ap.dat_vencto_tit_ap or
                input frame {&frame-name} valorJuros > 0 or
                input frame {&frame-name} valorTarifa > 0 or
                input frame {&frame-name} valorDesconto > 0 then do:

                run clear.

                run populateAlteracaoDefault.

                assign
                    tt_tit_ap_alteracao_base_1.tta_dat_vencto_tit_ap = input frame {&frame-name} dataVencimento
                    tt_tit_ap_alteracao_base_1.tta_cb4_tit_ap_bco_cobdor = 
                        replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").

                run populateAlteracaoJuros.
                run populateAlteracaoTarifa.
                run populateAlteracaoDesconto.

                run prgfin/apb/apb767zc.py (input 1,
                                            input "APB",
                                            input "",
                                            input-output table tt_tit_ap_alteracao_base_1,
                                            input-output table tt_tit_ap_alteracao_rateio,
                                            output table tt_log_erros_tit_ap_alteracao).

                if can-find(first tt_log_erros_tit_ap_alteracao 
                            where tt_log_erros_tit_ap_alteracao.ttv_num_mensagem <> 6542) then do:
                    for each tt_log_erros_tit_ap_alteracao:
                        MESSAGE "tta_cod_estab:"       tt_log_erros_tit_ap_alteracao.tta_cod_estab       skip
                                "tta_cdn_fornecedor:"  tt_log_erros_tit_ap_alteracao.tta_cdn_fornecedor  skip
                                "tta_cod_espec_docto:" tt_log_erros_tit_ap_alteracao.tta_cod_espec_docto skip
                                "tta_cod_ser_docto:"   tt_log_erros_tit_ap_alteracao.tta_cod_ser_docto   skip
                                "tta_cod_tit_ap:"      tt_log_erros_tit_ap_alteracao.tta_cod_tit_ap      skip
                                "tta_cod_parcela:"     tt_log_erros_tit_ap_alteracao.tta_cod_parcela     skip
                                "tta_num_id_tit_ap:"   tt_log_erros_tit_ap_alteracao.tta_num_id_tit_ap   skip
                                "ttv_num_mensagem:"    tt_log_erros_tit_ap_alteracao.ttv_num_mensagem    skip
                                "ttv_cod_tip_msg_dwb:" tt_log_erros_tit_ap_alteracao.ttv_cod_tip_msg_dwb skip
                                "ttv_des_msg_erro:"    tt_log_erros_tit_ap_alteracao.ttv_des_msg_erro    
                            VIEW-AS ALERT-BOX INFO BUTTONS OK.
                    end.

                    undo bloco-trans, leave bloco-trans.
                end.
            end.
            else do:
                find current tit_ap exclusive-lock no-error.

                if avail tit_ap then
                    assign 
                        tit_ap.cb4_tit_ap_bco_cobdor = 
                            replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").

                release tit_ap no-error.
            end.
        end.
    end.
  
    run clearFields.
  
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok C-Win
ON CHOOSE OF bt-ok IN FRAME DEFAULT-FRAME /* Ok */
DO:
    DEFINE VARIABLE c-linha-digi     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE da-vencto-boleto AS DATE       NO-UNDO.
    DEFINE VARIABLE i-cont           AS INTEGER    NO-UNDO.
    DEFINE VARIABLE de-valor-boleto  AS DECIMAL    NO-UNDO.

    ASSIGN c-linha-digi = replace(replace(input frame {&frame-name} fi-lin-dig:screen-value, " ", ""), ".", "").

    IF c-linha-digi = "" THEN DO:

        MESSAGE "Linha digit†vel n∆o informada." SKIP(1)
                "ê necess†rio informar ao menos a linha" SKIP
                "digit†vel para vincular um t°tulo."
            VIEW-AS ALERT-BOX ERROR.

        RETURN NO-APPLY.
    END.

    run pi-verifica-digitos(c-linha-digi).
    if return-value = "NOK":U then do:

        message "D°gito verificador n∆o confere."
            view-as alert-box error.

        return no-apply.
    end.

    if input frame {&frame-name} v-cod-bar  <> "" or
       input frame {&frame-name} fi-lin-dig <> "" then 
        do with frame {&frame-name}:

        assign de-valor-boleto = 0.
        if length(trim(string(decimal(substring(fi-lin-dig:input-value, 34))))) < 14 then
            assign de-valor-boleto = decimal(substring(fi-lin-dig:input-value, 34)) / 100

                   /* ATENCAO: o ASSIGN na variavel i-cont eh importante para o IF..ELSE que
                      vem a seguir e que determina a data a ser considerada */
                   i-cont = length(fi-lin-dig:input-value) + 1.
        else do:
            do i-cont = 34 to length(fi-lin-dig:input-value):
                if substring(fi-lin-dig:input-value, i-cont, 1) <> '0' then
                    leave.
            end.
        end.

        /* Apenas zeros no campo de data e valor da linha digitavel? */
        if i-cont > length(fi-lin-dig:input-value) then do:
            if v-dt-venci:input-value in frame {&frame-name} = ? then do:
                message 'Data de vencimento n∆o informada e o boleto' skip
                        'tem zeros na data de vencimento/valor ou'    skip
                        'n∆o possui data (apenas valor)'
                    view-as alert-box error.
                return no-apply.
            end.

            assign da-vencto-boleto = v-dt-venci:input-value in frame {&frame-name}.
        end.
        else
            assign da-vencto-boleto = 10/07/97 + int(substring(input frame {&frame-name} fi-lin-dig, 34, 4)).
        
        if v-dt-venci:input-value in frame {&frame-name} <> ? and
           v-dt-venci:input-value in frame {&frame-name} <> da-vencto-boleto then do:
            message 'Vencimento do boleto (' + string(da-vencto-boleto) + ') Ç diferente' skip
                    'do vencimento informado (' + v-dt-venci:screen-value in frame {&frame-name} + ')'
                view-as alert-box error.

            apply 'entry' to fi-lin-dig in frame {&frame-name}.
            return no-apply.
        end.

        if input frame {&frame-name} v-dt-venci <> ? then
            assign 
                v-datavenctit = input frame {&frame-name} v-dt-venci.
        else
            assign 
                v-datavenctit = da-vencto-boleto.

        if de-valor-boleto <> 0 then
            assign 
                v-valorlido = de-valor-boleto.
        else
            assign
                v-valorlido = deci(substring(input frame {&frame-name} fi-lin-dig, 38, 10)) / 100.

        if input frame {&frame-name} v-val-tit > 0 and 
            v-valorlido > 0 and
            v-valorlido <> input frame {&frame-name} v-val-tit then do:
            message 'Valor lido pela linha digit†vel' v-valorlido 
                'diferente do valor digitado acima'
                view-as alert-box error.
            apply 'choose' to bt-canc in frame {&frame-name}.
            return no-apply.
        end.

        if input frame {&frame-name} v-val-tit > 0 and v-valorlido = 0 then
            assign
                v-valorlido = input frame {&frame-name} v-val-tit.

        assign v-dt-venci-cb:screen-value in frame {&frame-name} = string(v-datavenctit)
               v-val-tit-cb:screen-value  in frame {&frame-name} = string(v-valorlido).
    end.
    else
        assign v-datavenctit = input frame {&frame-name} v-dt-venci
               v-valorlido   = input frame {&frame-name} v-val-tit
               v-dt-venci-cb:screen-value in frame {&frame-name} = ""
               v-val-tit-cb:screen-value  in frame {&frame-name} = "".

    run searchTitulo.
    
    if not can-find(first tt-tit_ap) then do:

        message "Nenhum t°tulo encontrado."
            view-as alert-box error.

        run clearFields.

        return no-apply.
    end.
        
    if can-find( first tt-tit_ap where tt-tit_ap.cb4_tit_ap_bco_cobdor = c-linha-digi) then do:
        open query br-tit for each tt-tit_ap where tt-tit_ap.cb4_tit_ap_bco_cobdor = c-linha-digi.

        message "Boleto j† vinculado a um t°tulo"
           view-as alert-box error.
        
        run clearFields.

        return no-apply.
    end.
    else if not can-find(first tt-tit_ap) then do:

        message "N∆o foram encontrados titulos relacionados"
            view-as alert-box error.

        run clearFields.

        return no-apply.
    end.
    
    open query br-tit for each tt-tit_ap where tt-tit_ap.cb4_tit_ap_bco_cobdor = "".

    query br-tit:get-last.
    if (query br-tit:current-result-row = 1 and 
        not query br-tit:query-off-end) then do:
        if can-find(first tt-tit_ap
                    where tt-tit_ap.cod_estab       = input browse br-tit tt-tit_ap.cod_estab    
                      and tt-tit_ap.cdn_fornecedor  = input browse br-tit tt-tit_ap.cdn_fornecedor
                      and tt-tit_ap.cod_espec_docto = input browse br-tit tt-tit_ap.cod_espec_docto
                      and tt-tit_ap.cod_ser_docto   = input browse br-tit tt-tit_ap.cod_ser_docto
                      and tt-tit_ap.cod_tit_ap      = input browse br-tit tt-tit_ap.cod_tit_ap   
                      and tt-tit_ap.cod_parcela     = input browse br-tit tt-tit_ap.cod_parcela
                      AND tt-tit_ap.cb4_tit_ap_bco_cobdor <> "") then do:

            open query br-tit for each tt-tit_ap where tt-tit_ap.cb4_tit_ap_bco_cobdor <> "".

            message "T°tulo j† vinculado"
                view-as alert-box error.

            run clearFields.

            return no-apply.
        end.

        assign 
            dataVencimento:screen-value in frame {&frame-name} = string(input browse br-tit tt-tit_ap.dat_vencto_tit_ap).

        apply "leave" to br-tit in frame {&frame-name}.

        disable bt-ok with frame {&frame-name}.

        run enableVinculo.

        return no-apply.
    end.

    /* O trecho de codigo abaixo so Ç executado se nao ocorreram
       os erros tratados acima (note que no corpo dos IF's h† instrucoes
       RETURN NO-APPLY */
    if not query br-tit:query-off-end then do:
        disable bt-ok with frame {&frame-name}.

        run enableVinculo.

        return no-apply.
    end.

    run clearFields.
    
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt_fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt_fechar C-Win
ON CHOOSE OF bt_fechar IN FRAME DEFAULT-FRAME /* Fechar */
DO:
    APPLY "close" TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-lin-dig
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-lin-dig C-Win
ON RETURN OF fi-lin-dig IN FRAME DEFAULT-FRAME /* Linha digit†vel */
DO:
  apply "CHOOSE":U to bt-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Sobre C-Win
ON CHOOSE OF MENU-ITEM m_Sobre /* Sobre */
DO:

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
        format "x(20)":U
        label "Nome Externo"
        no-undo.


        assign v_nom_prog     = "T°tulos em Aberto por Cliente".
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "rpt_tit_acr_em_aberto_cliente":U.




    assign v_nom_prog_ext = "acr/dacr303.w":U
           v_cod_release  = trim(" 5.00.00.001":U).

    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-cod-bar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar C-Win
ON LEAVE OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    def var c-campo1 as char no-undo.
    def var c-campo2 as char no-undo.
    def var c-campo3 as char no-undo.
    def var c-campo4 as char no-undo.
    def var c-campo5 as char no-undo.

    if length(v-cod-bar:screen-value in frame {&frame-name}) > 35 then do:
        run pi-calc-linha-digitavel (input v-cod-bar:screen-value in frame {&frame-name},
                                     output c-campo1,
                                     output c-campo2,
                                     output c-campo3,
                                     output c-campo4,
                                     output c-campo5).

        assign fi-lin-dig:screen-value in frame {&frame-name} = c-campo1 + c-campo2 + c-campo3 + c-campo4 + c-campo5.
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = c-campo1  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = c-campo2  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = c-campo3  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = c-campo4  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = c-campo5. */
    end.
    else
        assign fi-lin-dig:screen-value in frame {&frame-name} = "".
/*         assign fi-lin-dig1:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig2:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig3:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig4:screen-value in frame {&frame-name} = ""  */
/*                fi-lin-dig5:screen-value in frame {&frame-name} = "". */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cod-bar C-Win
ON RETURN OF v-cod-bar IN FRAME DEFAULT-FRAME /* C¢digo de Barras */
DO:
    apply "leave":u to self.
    apply "choose":u to bt-ok in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME valorDesconto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL valorDesconto C-Win
ON RETURN OF valorDesconto IN FRAME DEFAULT-FRAME /* Acerto a menor */
DO:
  apply "choose" to bt-confirma.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v_cod_estab_ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v_cod_estab_ini C-Win
ON ENTRY OF v_cod_estab_ini IN FRAME DEFAULT-FRAME /* Estabelecimento */
DO:
    /*if input frame {&frame-name} v_cod_estab_ini = "" then do:
        assign v_cod_estab_ini:screen-value in frame {&frame-name} = v_cod_estab_usuar
               v_cod_estab_fim:screen-value in frame {&frame-name} = v_cod_estab_usuar.
    end.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  assign
      diasVencimento:screen-value in frame {&frame-name} = '5'
      valorVariacao:screen-value in frame {&frame-name} = '0,05'.
      
  apply 'entry' to v-dt-venci in frame {&frame-name}.     

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE canFindTituloVinculado C-Win 
PROCEDURE canFindTituloVinculado :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter found as logical    no-undo.

    find first cst_tit_ap use-index ie_cod_barras
        where cst_tit_ap.cb4_tit_ap_bco_cobdor = replace(replace(input frame {&frame-name} fi-lin-dig, ".", ""), " ", "") 
        no-lock no-error.

    if avail cst_tit_ap then do:
        find first tit_ap
            where tit_ap.cod_estab       = cst_tit_ap.cod_estab      
              and tit_ap.cod_espec_docto = cst_tit_ap.cod_espec_docto
              and tit_ap.cod_ser_docto   = cst_tit_ap.cod_ser_docto  
              and tit_ap.cdn_fornecedor  = cst_tit_ap.cdn_fornecedor 
              and tit_ap.cod_tit_ap      = cst_tit_ap.cod_tit_ap     
              and tit_ap.cod_parcela     = cst_tit_ap.cod_parcela
            no-lock no-error.

        if avail tit_ap then do:
            create tt-tit_ap.
            buffer-copy tit_ap to tt-tit_ap
                assign
                    tt-tit_ap.nom_abrev = getNomeFornecedor(tit_ap.cdn_fornecedor).

            assign
                found = true.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear C-Win 
PROCEDURE clear :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        empty temp-table tt_tit_ap_alteracao_base_1.
        empty temp-table tt_tit_ap_alteracao_rateio.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearFields C-Win 
PROCEDURE clearFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}:
        close query br-tit.

        assign
            v-cod-bar:screen-value      = ''
            fi-lin-dig:screen-value     = ''
            dataVencimento:screen-value = ''
            valorJuros:screen-value     = ''
            valorTarifa:screen-value    = ''
            valorDesconto:screen-value  = ''.

        enable 
            valorTarifa 
            v-cod-bar 
            fi-lin-dig
            bt-ok.

        disable
            dataVencimento
            valorJuros
            valorDesconto
            bt-confirma
            bt-canc.

        apply 'entry' to fi-lin-dig.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createLog C-Win 
PROCEDURE createLog :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        find first cst_tit_ap_log
            where cst_tit_ap_log.cod_estab       = tit_ap.cod_estab
              and cst_tit_ap_log.cdn_fornecedor  = tit_ap.cdn_fornecedor
              and cst_tit_ap_log.cod_espec_docto = tit_ap.cod_espec_docto
              and cst_tit_ap_log.cod_ser_docto   = tit_ap.cod_ser_docto
              and cst_tit_ap_log.cod_tit_ap      = tit_ap.cod_tit_ap
              and cst_tit_ap_log.cod_parcela     = tit_ap.cod_parcela
            exclusive-lock no-error.
    
        if not available cst_tit_ap_log then do:  
            create cst_tit_ap_log.
            assign 
                cst_tit_ap_log.cod_estab       = tit_ap.cod_estab      
                cst_tit_ap_log.cdn_fornecedor  = tit_ap.cdn_fornecedor 
                cst_tit_ap_log.cod_espec_docto = tit_ap.cod_espec_docto
                cst_tit_ap_log.cod_ser_docto   = tit_ap.cod_ser_docto  
                cst_tit_ap_log.cod_tit_ap      = tit_ap.cod_tit_ap     
                cst_tit_ap_log.cod_parcela     = tit_ap.cod_parcela.   
        end.
    
        assign 
            cst_tit_ap_log.val_desconto = tit_ap.val_desconto
            cst_tit_ap_log.data_vinculo = today
            cst_tit_ap_log.hora_vinculo = string(time, "HH:MM:SS")
            cst_tit_ap_log.vinculado    = yes
            cst_tit_ap_log.cod_usuario  = v_cod_usuar_corren.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enableVinculo C-Win 
PROCEDURE enableVinculo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    enable 
        dataVencimento
        valorJuros
        valorDesconto
        bt-confirma
        bt-canc
        with frame {&frame-name}.

    if input frame {&frame-name} valorTarifa > 0 then
        disable valorTarifa with frame {&frame-name}.

    apply "entry" to br-tit in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY valorVariacao dataVencimento valorJuros valorTarifa diasVencimento 
          v_cod_estab_ini v_cod_estab_fim v-dt-venci v-val-tit v-cod-bar 
          fi-lin-dig v-dt-venci-cb v-val-tit-cb valorDesconto 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE valorVariacao valorTarifa diasVencimento v_cod_estab_ini 
         v_cod_estab_fim v-dt-venci v-val-tit v-cod-bar fi-lin-dig bt-ok br-tit 
         bt_fechar bt_ajuda IMAGE-1 IMAGE-2 RECT-1 RECT-16 RECT-35 RECT-37 
         RECT-38 RECT-8 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-calc-linha-digitavel C-Win 
PROCEDURE pi-calc-linha-digitavel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter c-codigo-barras as char no-undo.
    define output parameter c-campo-1       as char no-undo.
    define output parameter c-campo-2       as char no-undo.
    define output parameter c-campo-3       as char no-undo.
    define output parameter c-campo-4       as char no-undo.
    define output parameter c-campo-5       as char no-undo.

    define variable c-digito    as char     no-undo.
    define variable i-pos       as integer  no-undo.
    define variable i-tot       as integer  no-undo.
    define variable i-mult      as integer  no-undo.
    define variable i-cont      as integer  no-undo.
    define variable i-aux       as integer  no-undo.

    assign c-campo-1 = substr(c-codigo-barras, 01, 04) + substr(c-codigo-barras, 20, 5)
           c-campo-2 = substr(c-codigo-barras, 25, 10)
           c-campo-3 = substr(c-codigo-barras, 35, 10)
           c-campo-4 = substr(c-codigo-barras, 05, 01)
           c-campo-5 = substr(c-codigo-barras, 06, 14).

    /* digito do campo 1 */
    assign i-pos  = 10
           i-tot  = 0.

    do i-cont = 1 to 9:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 1.
       else
           assign i-mult = 2.

       assign i-aux = int(substr(c-campo-1,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux,"99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-1 = c-campo-1 + c-digito.

    /* digito do campo 2 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-2,i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito =  "0".
    else 
        assign c-digito = string(i-aux, "9").

    assign c-campo-2 = c-campo-2 + c-digito.

    /* digito do campo 3 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c-campo-3, i-pos, 1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.

    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c-campo-3 = c-campo-3 + c-digito.

/*     /* montagem da linha digitavel */                                    */
/*     assign c-linha-digitavel = string(c-campo-1,"XXXXX.XXXXX")  + "  " + */
/*                                string(c-campo-2,"XXXXX.XXXXXX") + "  " + */
/*                                string(c-campo-3,"XXXXX.XXXXXX") + "  " + */
/*                                c-campo-4                        + "  " + */
/*                                c-campo-5.                                */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-digitos C-Win 
PROCEDURE pi-verifica-digitos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define input parameter c_linha_digitavel as character no-undo.

    def var c_campo as char extent 3 no-undo.

    define variable c-digito    as char     no-undo.
    define variable i-pos       as integer  no-undo.
    define variable i-tot       as integer  no-undo.
    define variable i-mult      as integer  no-undo.
    define variable i-cont      as integer  no-undo.
    define variable i-aux       as integer  no-undo.
    
    if length(c_linha_digitavel) > 48 then
        return "NOK":U.

    assign c_campo[1] = substr(c_linha_digitavel, 01, 09) 
           c_campo[2] = substr(c_linha_digitavel, 11, 10)
           c_campo[3] = substr(c_linha_digitavel, 22, 10).

    /* digito do campo 1 */
    assign i-pos  = 10
           i-tot  = 0.

    do i-cont = 1 to 9:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 1.
       else
           assign i-mult = 2.

       assign i-aux = int(substr(c_campo[1],i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux,"99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c_campo[1] = c_campo[1] + c-digito.

    /* digito do campo 2 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c_campo[2],i-pos,1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.
    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito =  "0".
    else 
        assign c-digito = string(i-aux, "9").

    assign c_campo[2] = c_campo[2] + c-digito.

    /* digito do campo 3 */
    assign i-pos  = 11
           i-tot  = 0.

    do i-cont = 1 to 10:
       assign i-pos = i-pos - 1.
       if i-pos modulo 2 = 0 then
           assign i-mult = 2.
       else
           assign i-mult = 1.

       assign i-aux = int(substr(c_campo[3], i-pos, 1)) * i-mult.

       if i-aux >= 10 then
           assign i-aux = int(substr(string(i-aux, "99"), 1, 1)) + int(substr(string(i-aux, "99"), 2, 1)).

       assign i-tot = i-tot + i-aux.
    end.

    assign i-aux = 0.

    repeat:
       assign i-aux = i-aux + 1.
       if (i-tot + i-aux) modulo 10 = 0 then leave.
    end.

    if i-aux = 10 then
        assign c-digito = "0".
    else
        assign c-digito = string(i-aux,"9").

    assign c_campo[3] = c_campo[3] + c-digito.

    if c_campo[1] + c_campo[2] + c_campo[3] = substring(c_linha_digitavel, 1, 32) then
        return "OK":U.

    return "NOK":U.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateAlteracaoDefault C-Win 
PROCEDURE populateAlteracaoDefault :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        create tt_tit_ap_alteracao_base_1.
        assign tt_tit_ap_alteracao_base_1.ttv_cod_usuar_corren            = v_cod_usuar_corren
               tt_tit_ap_alteracao_base_1.tta_cod_empresa                 = tit_ap.cod_empresa                              
               tt_tit_ap_alteracao_base_1.tta_cod_estab                   = tit_ap.cod_estab                                
               tt_tit_ap_alteracao_base_1.tta_num_id_tit_ap               = tit_ap.num_id_tit_ap                            
               tt_tit_ap_alteracao_base_1.ttv_rec_tit_ap                  = recid(tit_ap)                                   
               tt_tit_ap_alteracao_base_1.tta_cdn_fornecedor              = tit_ap.cdn_fornecedor                           
               tt_tit_ap_alteracao_base_1.tta_cod_espec_docto             = tit_ap.cod_espec_docto                          
               tt_tit_ap_alteracao_base_1.tta_cod_ser_docto               = tit_ap.cod_ser_docto                            
               tt_tit_ap_alteracao_base_1.tta_cod_tit_ap                  = tit_ap.cod_tit_ap                               
               tt_tit_ap_alteracao_base_1.tta_cod_parcela                 = tit_ap.cod_parcela                              
               tt_tit_ap_alteracao_base_1.ttv_dat_transacao               = today
               tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap              = tit_ap.val_sdo_tit_ap                           
               tt_tit_ap_alteracao_base_1.tta_dat_emis_docto              = ?
               tt_tit_ap_alteracao_base_1.tta_dat_vencto_tit_ap           = tit_ap.dat_vencto_tit_ap
               tt_tit_ap_alteracao_base_1.tta_dat_prev_pagto              = ?
               tt_tit_ap_alteracao_base_1.tta_dat_ult_pagto               = ?
               tt_tit_ap_alteracao_base_1.tta_dat_desconto                = date("31/12/9999")
               tt_tit_ap_alteracao_base_1.tta_cod_portador                = tit_ap.cod_portador 
               tt_tit_ap_alteracao_base_1.tta_log_pagto_bloqdo            = tit_ap.log_pagto_bloqdo                             
               tt_tit_ap_alteracao_base_1.tta_cod_seguradora              = tit_ap.cod_seguradora                           
               tt_tit_ap_alteracao_base_1.tta_cod_apol_seguro             = tit_ap.cod_apol_seguro                 
               tt_tit_ap_alteracao_base_1.tta_cod_arrendador              = tit_ap.cod_arrendador
               tt_tit_ap_alteracao_base_1.tta_cod_contrat_leas            = tit_ap.cod_contrat_leas
               tt_tit_ap_alteracao_base_1.tta_ind_tip_espec_docto         = tit_ap.ind_tip_espec_docto
               tt_tit_ap_alteracao_base_1.tta_cod_indic_econ              = tit_ap.cod_indic_econ
               tt_tit_ap_alteracao_base_1.tta_cb4_tit_ap_bco_cobdor       = ''
               tt_tit_ap_alteracao_base_1.tta_ind_sit_tit_ap              = tit_ap.ind_sit_tit_ap
               tt_tit_ap_alteracao_base_1.tta_cod_forma_pagto             = tit_ap.cod_forma_pagto
               tt_tit_ap_alteracao_base_1.tta_val_desconto                = tit_ap.val_desconto
               tt_tit_ap_alteracao_base_1.ttv_ind_motiv_alter_val_tit_ap  = "Alteraá∆o".
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateAlteracaoDesconto C-Win 
PROCEDURE populateAlteracaoDesconto :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if input frame {&frame-name} valorDesconto > 0 then do:
            create tt_tit_ap_alteracao_rateio.
            assign
                tt_tit_ap_alteracao_rateio.ttv_rec_tit_ap           = recid(tit_ap)
                tt_tit_ap_alteracao_rateio.tta_cod_estab            = tit_ap.cod_estab
                tt_tit_ap_alteracao_rateio.ttv_ind_tip_rat          = 'valor' /* valor ou Original ou ajuste */
                tt_tit_ap_alteracao_rateio.tta_num_id_tit_ap        = tit_ap.num_id_tit_ap
                tt_tit_ap_alteracao_rateio.tta_num_id_aprop_ctbl_ap = recid(tt_tit_ap_alteracao_rateio)
    /*                         tt_tit_ap_alteracao_rateio.tta_cod_refer            = */
                tt_tit_ap_alteracao_rateio.tta_num_seq_refer        = 10
                tt_tit_ap_alteracao_rateio.tta_cod_tip_fluxo_financ = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_cta_ctbl   = 'PADRAO'
                tt_tit_ap_alteracao_rateio.tta_cod_cta_ctbl         = '41202010'
                tt_tit_ap_alteracao_rateio.tta_cod_unid_negoc       = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_ccusto     = ''
                tt_tit_ap_alteracao_rateio.tta_cod_ccusto           = ''
                tt_tit_ap_alteracao_rateio.tta_val_aprop_ctbl       = input frame {&frame-name} valorDesconto.
    
            assign 
                tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap = 
                    tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap 
                    - input frame {&frame-name} valorDesconto.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateAlteracaoJuros C-Win 
PROCEDURE populateAlteracaoJuros :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if input frame {&frame-name} valorJuros > 0 then do:
            create tt_tit_ap_alteracao_rateio.
            assign
                tt_tit_ap_alteracao_rateio.ttv_rec_tit_ap           = recid(tit_ap)
                tt_tit_ap_alteracao_rateio.tta_cod_estab            = tit_ap.cod_estab
                tt_tit_ap_alteracao_rateio.ttv_ind_tip_rat          = 'valor' /* valor ou Original ou ajuste */
                tt_tit_ap_alteracao_rateio.tta_num_id_tit_ap        = tit_ap.num_id_tit_ap
                tt_tit_ap_alteracao_rateio.tta_num_id_aprop_ctbl_ap = recid(tt_tit_ap_alteracao_rateio)
    /*                         tt_tit_ap_alteracao_rateio.tta_cod_refer            = */
                tt_tit_ap_alteracao_rateio.tta_num_seq_refer        = 10
                tt_tit_ap_alteracao_rateio.tta_cod_tip_fluxo_financ = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_cta_ctbl   = 'PADRAO'
                tt_tit_ap_alteracao_rateio.tta_cod_cta_ctbl         = '41201030'
                tt_tit_ap_alteracao_rateio.tta_cod_unid_negoc       = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_ccusto     = ''
                tt_tit_ap_alteracao_rateio.tta_cod_ccusto           = ''
                tt_tit_ap_alteracao_rateio.tta_val_aprop_ctbl       = input frame {&frame-name} valorJuros.
            assign 
                tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap = 
                    tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap 
                    + input frame {&frame-name} valorJuros.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateAlteracaoTarifa C-Win 
PROCEDURE populateAlteracaoTarifa :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        if input frame {&frame-name} valorTarifa > 0 then do:
            create tt_tit_ap_alteracao_rateio.
            assign
                tt_tit_ap_alteracao_rateio.ttv_rec_tit_ap           = recid(tit_ap)
                tt_tit_ap_alteracao_rateio.tta_cod_estab            = tit_ap.cod_estab
                tt_tit_ap_alteracao_rateio.ttv_ind_tip_rat          = 'valor' /* valor ou Original ou ajuste */
                tt_tit_ap_alteracao_rateio.tta_num_id_tit_ap        = tit_ap.num_id_tit_ap
                tt_tit_ap_alteracao_rateio.tta_num_id_aprop_ctbl_ap = recid(tt_tit_ap_alteracao_rateio)
    /*                         tt_tit_ap_alteracao_rateio.tta_cod_refer            = */
                tt_tit_ap_alteracao_rateio.tta_num_seq_refer        = 10
                tt_tit_ap_alteracao_rateio.tta_cod_tip_fluxo_financ = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_cta_ctbl   = 'PADRAO'
                tt_tit_ap_alteracao_rateio.tta_cod_cta_ctbl         = '41201015'
                tt_tit_ap_alteracao_rateio.tta_cod_unid_negoc       = ''
                tt_tit_ap_alteracao_rateio.tta_cod_plano_ccusto     = ''
                tt_tit_ap_alteracao_rateio.tta_cod_ccusto           = ''
                tt_tit_ap_alteracao_rateio.tta_val_aprop_ctbl       = input frame {&frame-name} valorTarifa.
    
            assign 
                tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap = 
                    tt_tit_ap_alteracao_base_1.tta_val_sdo_tit_ap 
                    + input frame {&frame-name} valorTarifa.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE searchTitulo C-Win 
PROCEDURE searchTitulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable found as logical   no-undo.

    empty temp-table tt-tit_ap.

    do with frame {&frame-name}:
        run canFindTituloVinculado(output found).

        if found then
            return.
    
        for each cst_tit_ap use-index ie_busca_tit
            where cst_tit_ap.val_sdo_tit_ap      >= v-valorlido + valorTarifa:input-value - valorVariacao:input-value
              and cst_tit_ap.val_sdo_tit_ap      <= v-valorlido + valorTarifa:input-value + valorVariacao:input-value
              and cst_tit_ap.dat_vencto_tit_ap   >= v-datavenctit - diasVencimento:input-value
              and cst_tit_ap.dat_vencto_tit_ap   <= v-datavenctit + diasVencimento:input-value
              and cst_tit_ap.ind_tip_espec_docto  = "Normal"
              and cst_tit_ap.cod_estab           >= v_cod_estab_ini:input-value
              and cst_tit_ap.cod_estab           <= v_cod_estab_fim:input-value
              and cst_tit_ap.dat_liquidac_tit_ap  = 12/31/9999
            no-lock:
            find first tit_ap
                where tit_ap.cod_estab       = cst_tit_ap.cod_estab      
                  and tit_ap.cod_espec_docto = cst_tit_ap.cod_espec_docto
                  and tit_ap.cod_ser_docto   = cst_tit_ap.cod_ser_docto  
                  and tit_ap.cdn_fornecedor  = cst_tit_ap.cdn_fornecedor 
                  and tit_ap.cod_tit_ap      = cst_tit_ap.cod_tit_ap     
                  and tit_ap.cod_parcela     = cst_tit_ap.cod_parcela
                no-lock no-error.
    
            if avail tit_ap then do:

                if can-find(first item_bord_ap
                            where item_bord_ap.cod_estab       = tit_ap.cod_estab
                              and item_bord_ap.cod_espec_docto = tit_ap.cod_espec_docto
                              and item_bord_ap.cod_ser_docto   = tit_ap.cod_ser_docto
                              and item_bord_ap.cdn_fornecedor  = tit_ap.cdn_fornecedor
                              and item_bord_ap.cod_tit_ap      = tit_ap.cod_tit_ap
                              and item_bord_ap.cod_parcela     = tit_ap.cod_parcela) or
                    can-find(first item_lote_pagto
                                where item_lote_pagto.cod_estab       = tit_ap.cod_estab
                                  and item_lote_pagto.cod_espec_docto = tit_ap.cod_espec_docto
                                  and item_lote_pagto.cod_ser_docto   = tit_ap.cod_ser_docto
                                  and item_lote_pagto.cdn_fornecedor  = tit_ap.cdn_fornecedor
                                  and item_lote_pagto.cod_tit_ap      = tit_ap.cod_tit_ap
                                  and item_lote_pagto.cod_parcela     = tit_ap.cod_parcela) then
                    next.

                create tt-tit_ap.
                buffer-copy tit_ap to tt-tit_ap
                    assign
                        tt-tit_ap.nom_abrev = getNomeFornecedor(tit_ap.cdn_fornecedor).
            end.
        end.
        return "OK":U.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getNomeFornecedor C-Win 
FUNCTION getNomeFornecedor RETURNS CHARACTER
  ( input codigo as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    find first ems5.fornecedor
        where fornecedor.cdn_fornecedor = codigo
        no-lock no-error.

    if avail fornecedor then
        return fornecedor.nom_abrev.
    else
        return ''.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

